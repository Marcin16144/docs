using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Kompendium.Core;

// Kompendium Indexer
//   Scans the documentation root, writes the values/ data layer (catalog, sections,
//   relations), injects the shared reading-position / related-materials widget into
//   every doc page (idempotent), and prints a gap report.
//
// Usage:  dotnet run --project src/Kompendium.Indexer -- [root] [--no-inject]

string root = Directory.GetCurrentDirectory();
bool inject = true;
foreach (var a in args)
{
    if (a == "--no-inject") inject = false;
    else if (!a.StartsWith("--") && Directory.Exists(a)) root = Path.GetFullPath(a);
}
if (!File.Exists(Path.Combine(root, "index.html")))
    Console.WriteLine($"⚠  No index.html in '{root}'. Pass the docs root as the first argument.");

Console.WriteLine($"📂 Root: {root}");
var valuesDir = Path.Combine(root, "values");
var dataDir = Path.Combine(valuesDir, "data");
Directory.CreateDirectory(dataDir);

// ── 1. Scan ───────────────────────────────────────────────────────────────
var files = HtmlScanner.EnumeratePages(root);
var pages = new List<DocPage>(files.Count);
foreach (var f in files)
{
    try { pages.Add(HtmlScanner.Scan(root, f)); }
    catch (Exception ex) { Console.WriteLine($"  ! scan failed {f}: {ex.Message}"); }
}
pages = pages.OrderBy(p => p.Path, StringComparer.OrdinalIgnoreCase).ToList();
Console.WriteLine($"📄 Pages scanned: {pages.Count}");

// ── 2. Sections ───────────────────────────────────────────────────────────
var sections = pages
    .GroupBy(p => p.Section)
    .Select(g =>
    {
        var meta = Sections.For(g.Key);
        var idx = g.FirstOrDefault(p => p.IsIndex && p.Depth <= 1)?.Path;
        return new SectionInfo
        {
            Id = g.Key, Title = meta.Title, Icon = meta.Icon, Color = meta.Color,
            Order = meta.Order, Tags = meta.Tags.ToList(),
            Index = idx, PageCount = g.Count(),
        };
    })
    .OrderBy(s => s.Order).ThenBy(s => s.Id)
    .ToList();

// ── 3. Relations (computed + curated) ─────────────────────────────────────
var relations = RelationBuilder.BuildAll(pages);
var curatedPath = Path.Combine(valuesDir, "relations.curated.json");
int curatedCount = 0;
if (File.Exists(curatedPath))
{
    var curated = CatalogStore.LoadRelations(curatedPath);
    var byPath = pages.ToDictionary(p => p.Path, StringComparer.OrdinalIgnoreCase);
    foreach (var (page, links) in curated)
    {
        if (!byPath.ContainsKey(page)) continue;
        var merged = relations.TryGetValue(page, out var ex) ? new List<RelatedLink>(ex) : new();
        foreach (var l in links.AsEnumerable().Reverse())
        {
            if (!byPath.TryGetValue(l.Path, out var tgt)) continue;
            merged.RemoveAll(x => string.Equals(x.Path, l.Path, StringComparison.OrdinalIgnoreCase));
            merged.Insert(0, new RelatedLink
            {
                Path = tgt.Path, Title = string.IsNullOrWhiteSpace(l.Title) ? tgt.Title : l.Title,
                Section = tgt.Section, Icon = Sections.For(tgt.Section).Icon,
                Reason = string.IsNullOrWhiteSpace(l.Reason) ? "Polecane" : l.Reason,
            });
            curatedCount++;
        }
        relations[page] = merged.Take(8).ToList();
    }
}
Console.WriteLine($"🔗 Relations: {relations.Count} pages have related links ({curatedCount} curated edges)");

// ── 4. Write data layer ───────────────────────────────────────────────────
var catalog = new Catalog
{
    Generated = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"),
    Root = ".", PageCount = pages.Count, Sections = sections, Pages = pages,
};
CatalogStore.Write(Path.Combine(dataDir, "catalog.json"), catalog);
CatalogStore.Write(Path.Combine(dataDir, "sections.json"), sections);
CatalogStore.Write(Path.Combine(dataDir, "relations.json"), relations);
Console.WriteLine($"💾 Wrote values/data/{{catalog,sections,relations}}.json");

// ── 5. Inject shared widget ───────────────────────────────────────────────
const string startMark = "<!-- KOMPENDIUM:START -->";
const string endMark = "<!-- KOMPENDIUM:END -->";
var blockRx = new Regex(Regex.Escape(startMark) + ".*?" + Regex.Escape(endMark),
    RegexOptions.Singleline | RegexOptions.IgnoreCase);
var topbarRx = new Regex("class=\"topbar\"", RegexOptions.IgnoreCase);
var compact = new JsonSerializerOptions(CatalogStore.Json) { WriteIndented = false };

int injected = 0, skipped = 0;
if (inject)
{
    foreach (var p in pages)
    {
        var full = Path.Combine(root, p.Path.Replace('/', Path.DirectorySeparatorChar));
        string html;
        try { html = File.ReadAllText(full); } catch { continue; }

        bool docPage = topbarRx.IsMatch(html) || p.IsIndex;
        if (!docPage) { skipped++; continue; }

        var home = string.Concat(Enumerable.Repeat("../", p.Depth));
        var meta = Sections.For(p.Section);
        var rel = relations.TryGetValue(p.Path, out var rl) ? rl : new List<RelatedLink>();
        var komp = new
        {
            page = p.Path, home,
            title = p.Title, section = p.Section,
            sectionLabel = $"{meta.Icon} {meta.Title}",
            rel = rel.Select(r => new { u = home + r.Path, t = r.Title, s = r.Icon, r = r.Reason }).ToArray(),
        };
        var json = JsonSerializer.Serialize(komp, compact);
        var block = new StringBuilder()
            .Append(startMark).Append('\n')
            .Append($"<link rel=\"stylesheet\" href=\"{home}values/assets/kompendium.css\">\n")
            .Append($"<script>window.KOMP={json}</script>\n")
            .Append($"<script src=\"{home}values/assets/kompendium.js\" defer></script>\n")
            .Append(endMark).ToString();

        html = blockRx.Replace(html, "").TrimEnd();
        int at = html.LastIndexOf("</body>", StringComparison.OrdinalIgnoreCase);
        html = at >= 0 ? html[..at] + block + "\n" + html[at..] : html + "\n" + block + "\n";

        File.WriteAllText(full, html);
        injected++;
    }
    Console.WriteLine($"💉 Injected widget into {injected} pages (skipped {skipped} non-doc pages)");
}

// ── 6. Gap report ─────────────────────────────────────────────────────────
var existing = new HashSet<string>(pages.Select(p => p.Path), StringComparer.OrdinalIgnoreCase);
var broken = new List<object>();
foreach (var p in pages)
    foreach (var link in p.OutLinks)
        if (!existing.Contains(link))
            broken.Add(new { from = p.Path, to = link, promised = p.IsIndex });

var orphans = sections.Where(s => s.Id is "services" or "Kryptowaluty" or "Terapia" or "Dokumentacje")
                      .Select(s => s.Id).ToList();

var thin = pages.Where(p => !p.IsIndex && p.Words < 200)
               .OrderBy(p => p.Words)
               .Select(p => new { p.Path, p.Words, p.Title })
               .ToList();

CatalogStore.Write(Path.Combine(dataDir, "_report.json"), new
{
    generated = catalog.Generated,
    pageCount = pages.Count,
    sections = sections.Count,
    brokenLinks = broken,
    orphanSections = orphans,
    thinPages = thin,
});
Console.WriteLine($"🧭 Gap report: {broken.Count} broken links, {orphans.Count} orphan sections, {thin.Count} thin pages (<200 words)");
Console.WriteLine("✅ Done.");
