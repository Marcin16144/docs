using System.Text.Json.Serialization;

namespace Kompendium.Core;

/// <summary>Whole-base catalog written to values/catalog.json.</summary>
public sealed class Catalog
{
    public string Generated { get; set; } = "";
    public string Root { get; set; } = ".";
    public int PageCount { get; set; }
    public List<SectionInfo> Sections { get; set; } = new();
    public List<DocPage> Pages { get; set; } = new();
}

/// <summary>A top-level knowledge domain (one per top folder).</summary>
public sealed class SectionInfo
{
    public string Id { get; set; } = "";        // top dir, e.g. "software"
    public string Title { get; set; } = "";
    public string Icon { get; set; } = "📁";
    public string Color { get; set; } = "#38bdf8";
    public string? Index { get; set; }           // path to its index.html, if any
    public int PageCount { get; set; }
    public int Order { get; set; } = 999;
    public List<string> Tags { get; set; } = new();
}

/// <summary>One documentation page.</summary>
public sealed class DocPage
{
    public string Path { get; set; } = "";       // "software/llm/09-rag.html"
    public string Section { get; set; } = "";
    public string Subsection { get; set; } = "";
    public string Title { get; set; } = "";
    public string Heading { get; set; } = "";
    public string Subtitle { get; set; } = "";
    public string Updated { get; set; } = "";
    public string Excerpt { get; set; } = "";
    public int Depth { get; set; }
    public int Words { get; set; }
    public bool IsIndex { get; set; }
    public List<Heading> Headings { get; set; } = new();
    public List<string> Tags { get; set; } = new();
    public List<string> Breadcrumb { get; set; } = new();

    [JsonIgnore] public bool IsRedirect { get; set; }                  // meta-refresh / location.replace stub
    [JsonIgnore] public bool IsHub { get; set; }                       // sub-TOC navigation page
    [JsonIgnore] public bool MdBacked { get; set; }                    // content loaded from a sibling .md
    [JsonIgnore] public List<string> OutLinks { get; set; } = new();   // resolved internal links (for relations)
    [JsonIgnore] public HashSet<string> Keywords { get; set; } = new();
}

public sealed class Heading
{
    public string Id { get; set; } = "";
    public string Text { get; set; } = "";
    public int Level { get; set; } = 2;
}

/// <summary>A related-material edge, written into relations.json and embedded per page.</summary>
public sealed class RelatedLink
{
    public string Path { get; set; } = "";
    public string Title { get; set; } = "";
    public string Section { get; set; } = "";
    public string Icon { get; set; } = "📄";
    public string Reason { get; set; } = "";
    [JsonIgnore] public double Score { get; set; }
}
