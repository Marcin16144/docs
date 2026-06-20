using System.Net;
using System.Text.RegularExpressions;

namespace Kompendium.Core;

/// <summary>Regex-based reader tuned to the Kompendium page template (consistent across the base).</summary>
public static partial class HtmlScanner
{
    public static readonly string[] SkipDirs = { ".git", ".claude", ".vs", "node_modules", "__pycache__", "obj", "bin", "publish" };

    // Excluded only when they sit directly under the docs root (the C# solution, the
    // web bundle, and the build scripts) — never when the same name appears as real
    // content deeper in the tree (e.g. software/tools/vscode).
    private static readonly string[] RootOnlySkip = { "src", "dist", "tools" };

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
    [GeneratedRegex(@"fetch\(\s*[""']([^""']+\.md)[""']", RegexOptions.IgnoreCase)]
    private static partial Regex MdFetchRx();
    [GeneratedRegex(@"http-equiv\s*=\s*[""']refresh[""']|location\.replace\s*\(", RegexOptions.IgnoreCase)]
    private static partial Regex RedirectRx();
    [GeneratedRegex(@"<(script|style)\b[^>]*>.*?</\1>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex ScriptStyleRx();
    [GeneratedRegex(@"class\s*=\s*[""'][^""']*\btoc(-sub|-item|-grid|-card)?\b", RegexOptions.IgnoreCase)]
    private static partial Regex TocRx();
    [GeneratedRegex(@"^(#{1,4})\s+(.+?)\s*#*\s*$", RegexOptions.Multiline)]
    private static partial Regex MdHeadingRx();

    public static List<string> EnumeratePages(string root)
    {
        var list = new List<string>();
        Walk(root, root, list);
        return list;
    }

    private static void Walk(string root, string dir, List<string> acc)
    {
        bool atRoot = string.Equals(Path.GetFullPath(dir), Path.GetFullPath(root), StringComparison.OrdinalIgnoreCase);
        foreach (var sub in Directory.EnumerateDirectories(dir))
        {
            var name = Path.GetFileName(sub);
            if (SkipDirs.Contains(name, StringComparer.OrdinalIgnoreCase)) continue;
            if (atRoot && RootOnlySkip.Contains(name, StringComparer.OrdinalIgnoreCase)) continue;
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

        page.IsRedirect = RedirectRx().IsMatch(html);
        page.IsHub = TocRx().IsMatch(html);

        // Many pages are thin HTML shells that fetch a sibling .md and render it
        // client-side. Pull the real content out of that markdown so the index,
        // search and relations see it — not just the loader boilerplate.
        var mdText = TryReadMarkdown(fullPath, html);
        if (mdText is not null)
        {
            page.MdBacked = true;
            EnrichFromMarkdown(page, mdText, slugSeen);
        }
        else
        {
            // Word count from visible text only (scripts/styles stripped).
            var visible = ScriptStyleRx().Replace(html, " ");
            var plain = Clean(TagRx().Replace(visible, " "));
            page.Words = plain.Length == 0 ? 0 : WsRx().Split(plain).Count(s => s.Length > 0);
        }

        // Keywords from title + headings + subtitle.
        AddKeywords(page.Keywords, page.Title);
        AddKeywords(page.Keywords, page.Heading);
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

    private static string? TryReadMarkdown(string fullPath, string html)
    {
        var m = MdFetchRx().Match(html);
        if (!m.Success) return null;
        try
        {
            var name = WebUtility.UrlDecode(m.Groups[1].Value);
            var mdPath = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(fullPath)!, name));
            return File.Exists(mdPath) ? File.ReadAllText(mdPath) : null;
        }
        catch { return null; }
    }

    private static void EnrichFromMarkdown(DocPage page, string md, HashSet<string> slugSeen)
    {
        // Headings (#…####). The first level-1 heading is the page H1.
        foreach (Match m in MdHeadingRx().Matches(md))
        {
            var level = m.Groups[1].Value.Length;
            var text = MdInline(m.Groups[2].Value);
            if (text.Length == 0) continue;
            if (level == 1 && string.IsNullOrEmpty(page.Heading)) { page.Heading = text; continue; }
            var id = Slug(text); var baseId = id; int n = 2; while (!slugSeen.Add(id)) id = $"{baseId}-{n++}";
            page.Headings.Add(new Heading { Level = Math.Clamp(level, 2, 3), Id = id, Text = text });
        }

        // Strip fenced/inline code for clean excerpt + word count.
        var prose = Regex.Replace(md, "```[\\s\\S]*?```", " ");
        prose = Regex.Replace(prose, "`[^`]*`", " ");

        if (string.IsNullOrEmpty(page.Excerpt))
        {
            foreach (var raw in prose.Split('\n'))
            {
                var line = raw.Trim();
                if (line.Length < 40) continue;
                if (line.StartsWith('#') || line.StartsWith('>') || line.StartsWith('|') ||
                    line.StartsWith("- ") || line.StartsWith("* ") || Regex.IsMatch(line, @"^\d+\.")) continue;
                var t = MdInline(line);
                if (t.Length >= 40) { page.Excerpt = t.Length > 240 ? t[..240].TrimEnd() + "…" : t; break; }
            }
        }

        var plain = MdInline(Regex.Replace(prose, @"[#>*_~|]", " "));
        page.Words = plain.Length == 0 ? 0 : WsRx().Split(plain).Count(s => s.Length > 0);
    }

    private static string MdInline(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        s = Regex.Replace(s, @"!\[[^\]]*\]\([^)]*\)", " ");      // images
        s = Regex.Replace(s, @"\[([^\]]+)\]\([^)]*\)", "$1");    // links → label
        s = s.Replace("**", "").Replace("__", "").Replace("~~", "").Replace("`", "");
        s = WebUtility.HtmlDecode(s);
        return WsRx().Replace(s, " ").Trim();
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
