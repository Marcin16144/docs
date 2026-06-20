namespace Kompendium.Core;

/// <summary>Derives "related materials" edges from in-content links, section siblings, and keyword overlap.</summary>
public static class RelationBuilder
{
    public static Dictionary<string, List<RelatedLink>> BuildAll(List<DocPage> pages, int perPage = 6)
    {
        var byPath = pages.ToDictionary(p => p.Path, StringComparer.OrdinalIgnoreCase);
        var icon = (string section) => Sections.For(section).Icon;

        // Inverted keyword index -> page indices.
        var inverted = new Dictionary<string, List<int>>(StringComparer.OrdinalIgnoreCase);
        for (int i = 0; i < pages.Count; i++)
            foreach (var kw in pages[i].Keywords)
                (inverted.TryGetValue(kw, out var l) ? l : inverted[kw] = new List<int>()).Add(i);

        var result = new Dictionary<string, List<RelatedLink>>(StringComparer.OrdinalIgnoreCase);

        for (int i = 0; i < pages.Count; i++)
        {
            var p = pages[i];
            var scores = new Dictionary<string, (double score, string reason)>(StringComparer.OrdinalIgnoreCase);

            void Add(string path, double score, string reason)
            {
                if (string.Equals(path, p.Path, StringComparison.OrdinalIgnoreCase)) return;
                if (!byPath.ContainsKey(path)) return;
                if (!scores.TryGetValue(path, out var cur) || score > cur.score)
                    scores[path] = (score, scores.TryGetValue(path, out var ex) && ex.score >= score ? ex.reason : reason);
            }

            // 1) In-content links (strongest) — skip nav/index noise.
            if (!p.IsIndex)
                foreach (var link in p.OutLinks)
                {
                    if (link.EndsWith("/index.html", StringComparison.OrdinalIgnoreCase) ||
                        link.Equals("index.html", StringComparison.OrdinalIgnoreCase)) continue;
                    Add(link, 100, "Powiązany w treści");
                }

            // 2) Same subsection siblings.
            if (!string.IsNullOrEmpty(p.Subsection) && !p.IsIndex)
                foreach (var q in pages)
                    if (!q.IsIndex && q.Section == p.Section && q.Subsection == p.Subsection && q.Path != p.Path)
                        Add(q.Path, 50, "Ta sama sekcja");

            // 3) Keyword overlap (cosine over keyword sets) via inverted index.
            var shared = new Dictionary<int, int>();
            foreach (var kw in p.Keywords)
                if (inverted.TryGetValue(kw, out var lst))
                    foreach (var j in lst)
                        if (j != i) shared[j] = shared.TryGetValue(j, out var c) ? c + 1 : 1;

            foreach (var (j, c) in shared)
            {
                if (c < 2) continue;
                var q = pages[j];
                double denom = Math.Sqrt(Math.Max(1, p.Keywords.Count) * Math.Max(1, q.Keywords.Count));
                double sim = c / denom;
                if (sim < 0.18) continue;
                var reason = q.Section == p.Section ? "Podobny temat" : "Powiązany dział";
                Add(q.Path, sim * 40, reason);
            }

            var links = scores
                .OrderByDescending(kv => kv.Value.score)
                .Take(perPage)
                .Select(kv =>
                {
                    var q = byPath[kv.Key];
                    return new RelatedLink
                    {
                        Path = q.Path,
                        Title = q.Title,
                        Section = q.Section,
                        Icon = icon(q.Section),
                        Reason = kv.Value.reason,
                        Score = Math.Round(kv.Value.score, 3),
                    };
                })
                .ToList();

            if (links.Count > 0) result[p.Path] = links;
        }

        return result;
    }
}
