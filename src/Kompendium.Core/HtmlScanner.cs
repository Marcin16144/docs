using System.Net;
using System.Text.RegularExpressions;

namespace Kompendium.Core;

/// <summary>Regex-based reader tuned to the Kompendium page template (consistent across the base).</summary>
public static partial class HtmlScanner
{
    public static readonly string[] SkipDirs = { ".git", ".claude", ".vs", "node_modules", "__pycache__", "obj", "bin", "publish" };

    // Stopwords (PL + EN) to keep keyword sets meaningful.
    private static readonly HashSet<string> Stop = new(StringComparer.OrdinalIgnoreCase)
    {
        "i","oraz","lub","albo","ale","że","się","na","do","od","za","po","ze","we","the","and","for","with","from",
        "jak","czy","to","co","jest","są","być","może","nie","tak","dla","przez","pod","nad","bez","już","tylko",
        "w","z","o","a","u","an","of","in","on","by","is","są","jako","gdy","lub","ich","jego","jej","ten","ta","te",
        "html","index","podstawy","wprowadzenie","przewodnik","kompendium","część","temat","strona",
    };

    [GeneratedRegex(@"<title>(.*?)</title>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex TitleRx();
    [GeneratedRegex(@"<h1[^>]*>(.*?)</h1>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex H1Rx();
    [GeneratedRegex(@"class=""subtitle""[^>]*>(.*?)</", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex SubtitleRx();
    [GeneratedRegex(@"class=""updated""[^>]*>\s*(?:Aktualizacja:?\s*)?(.*?)</", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex UpdatedRx();
    [GeneratedRegex(@"<h([23])\b([^>]*)>(.*?)</h\1>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex HeadingRx();
    [GeneratedRegex(@"id=""([^""]+)""", RegexOptions.IgnoreCase)]
    private static partial Regex IdAttrRx();
    [GeneratedRegex(@"[^a-z0-9]+")]
    private static partial Regex SlugRx();
    [GeneratedRegex(@"<p[^>]*>(.*?)</p>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex ParaRx();
    [GeneratedRegex(@"href\s*=\s*[""']([^""']+)[""']", RegexOptions.IgnoreCase)]
    private static partial Regex HrefRx();
    [GeneratedRegex(@"<[^>]+>")]
    private static partial Regex TagRx();
    [GeneratedRegex(@"\s+")]
    private static partial Regex WsRx();
    [GeneratedRegex(@"[\p{L}\p{Nd}]{3,}", RegexOptions.IgnoreCase)]
    private static partial Regex WordRx();

    public static List<string> EnumeratePages(string root)
    {
        var list = new List<string>();
        Walk(root, root, list);
        return list;
    }

    private static void Walk(string root, string dir, List<string> acc)
    {
        foreach (var sub in Directory.EnumerateDirectories(dir))
        {
            var name = Path.GetFileName(sub);
            if (SkipDirs.Contains(name, StringComparer.OrdinalIgnoreCase)) continue;
            Walk(root, sub, acc);
        }
        foreach (var f in Directory.EnumerateFiles(dir, "*.html"))
            acc.Add(f);
    }

    public static DocPage Scan(string root, string fullPath)
    {
        var html = File.ReadAllText(fullPath);
        var rel = Path.GetRelativePath(root, fullPath).Replace('\\', '/');
        var parts = rel.Split('/');
        var top = parts.Length > 1 ? parts[0] : "(root)";
        var sub = parts.Length > 2 ? parts[1] : "";

        var page = new DocPage
        {
            Path = rel,
            Section = top,
            Subsection = sub,
            Depth = parts.Length - 1,
            IsIndex = string.Equals(Path.GetFileName(rel), "index.html", StringComparison.OrdinalIgnoreCase),
        };

        var title = Clean(TitleRx().Match(html).Groups[1].Value);
        var h1 = Clean(H1Rx().Match(html).Groups[1].Value);
        page.Heading = h1;
        page.Title = !string.IsNullOrWhiteSpace(title) ? title : (!string.IsNullOrWhiteSpace(h1) ? h1 : PrettyName(rel));
        page.Subtitle = Clean(SubtitleRx().Match(html).Groups[1].Value);
        page.Updated = Clean(UpdatedRx().Match(html).Groups[1].Value);

        var slugSeen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (Match m in HeadingRx().Matches(html))
        {
            var text = Clean(m.Groups[3].Value);
            if (text.Length == 0) continue;
            var idm = IdAttrRx().Match(m.Groups[2].Value);
            var id = idm.Success ? idm.Groups[1].Value : Slug(text);
            if (!idm.Success) { var baseId = id; int n = 2; while (!slugSeen.Add(id)) id = $"{baseId}-{n++}"; }
            page.Headings.Add(new Heading { Level = int.Parse(m.Groups[1].Value), Id = id, Text = text });
        }

        // Excerpt: first non-trivial paragraph.
        foreach (Match m in ParaRx().Matches(html))
        {
            var t = Clean(m.Groups[1].Value);
            if (t.Length >= 40) { page.Excerpt = t.Length > 240 ? t[..240].TrimEnd() + "…" : t; break; }
        }
        if (string.IsNullOrEmpty(page.Excerpt) && !string.IsNullOrEmpty(page.Subtitle))
            page.Excerpt = page.Subtitle;

        // Word count from stripped text.
        var plain = Clean(TagRx().Replace(html, " "));
        page.Words = plain.Length == 0 ? 0 : WsRx().Split(plain).Count(s => s.Length > 0);

        // Keywords from title + headings + subtitle.
        AddKeywords(page.Keywords, page.Title);
        AddKeywords(page.Keywords, page.Subtitle);
        foreach (var h in page.Headings) AddKeywords(page.Keywords, h.Text);

        // Breadcrumb labels = section + subsection.
        var meta = Sections.For(top);
        page.Breadcrumb.Add($"{meta.Icon} {meta.Title}");
        if (sub.Length > 0) page.Breadcrumb.Add(sub);

        // Internal outlinks (resolved, normalized to forward-slash rel paths) for relation building.
        var baseDir = Path.GetDirectoryName(fullPath)!;
        foreach (Match m in HrefRx().Matches(html))
        {
            var href = m.Groups[1].Value.Trim();
            if (href.Length == 0) continue;
            if (href.StartsWith("http", StringComparison.OrdinalIgnoreCase) ||
                href.StartsWith("mailto:", StringComparison.OrdinalIgnoreCase) ||
                href.StartsWith("tel:", StringComparison.OrdinalIgnoreCase) ||
                href.StartsWith('#') || href.StartsWith("javascript:", StringComparison.OrdinalIgnoreCase) ||
                href.StartsWith("data:", StringComparison.OrdinalIgnoreCase)) continue;
            var hash = href.IndexOf('#'); if (hash >= 0) href = href[..hash];
            if (href.Length == 0) continue;
            href = WebUtility.UrlDecode(href);
            string resolved;
            try { resolved = Path.GetFullPath(Path.Combine(baseDir, href)); }
            catch { continue; }
            if (Directory.Exists(resolved)) resolved = Path.Combine(resolved, "index.html");
            if (!resolved.EndsWith(".html", StringComparison.OrdinalIgnoreCase)) continue;
            var rrel = Path.GetRelativePath(root, resolved).Replace('\\', '/');
            if (!rrel.StartsWith("..") && rrel != rel) page.OutLinks.Add(rrel);
        }
        page.OutLinks = page.OutLinks.Distinct().ToList();

        page.Tags = meta.Tags.ToList();
        return page;
    }

    private static void AddKeywords(HashSet<string> set, string text)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        foreach (Match m in WordRx().Matches(text))
        {
            var w = m.Value.ToLowerInvariant();
            if (!Stop.Contains(w)) set.Add(w);
        }
    }

    private static string Clean(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        s = TagRx().Replace(s, "");
        s = WebUtility.HtmlDecode(s);
        return WsRx().Replace(s, " ").Trim();
    }

    private static string Slug(string text)
    {
        var s = text.ToLowerInvariant()
            .Replace('ą', 'a').Replace('ć', 'c').Replace('ę', 'e').Replace('ł', 'l').Replace('ń', 'n')
            .Replace('ó', 'o').Replace('ś', 's').Replace('ź', 'z').Replace('ż', 'z');
        s = SlugRx().Replace(s, "-").Trim('-');
        return s.Length == 0 ? "sek" : (s.Length > 60 ? s[..60].Trim('-') : s);
    }

    private static string PrettyName(string rel)
    {
        var name = Path.GetFileNameWithoutExtension(rel);
        name = Regex.Replace(name, @"^\d+([-_]\d+)*[-_]?", "");
        name = name.Replace('-', ' ').Replace('_', ' ').Trim();
        return name.Length == 0 ? rel : char.ToUpperInvariant(name[0]) + name[1..];
    }
}
