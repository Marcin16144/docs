using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using Kompendium.Core;
using Microsoft.Web.WebView2.Core;

namespace Kompendium.Desktop;

public partial class MainWindow : Window
{
    private const string Host = "kompendium.local";

    private string _root = "";
    private AppSettings _settings = new();
    private Catalog? _catalog;
    private readonly List<NavPage> _allPages = new();
    private readonly List<NavSection> _sections = new();
    private bool _webReady;

    public MainWindow()
    {
        InitializeComponent();
        Loaded += OnLoaded;
        Closing += OnClosing;
    }

    private async void OnLoaded(object sender, RoutedEventArgs e)
    {
        _settings = AppSettings.Load();
        if (_settings.Width is > 400 and < 6000) Width = _settings.Width;
        if (_settings.Height is > 300 and < 4000) Height = _settings.Height;
        if (_settings.SidebarWidth is > 180 and < 900)
            SidebarCol.Width = new GridLength(_settings.SidebarWidth);

        _root = LocateRoot();
        if (_root.Length == 0)
        {
            Status.Text = "Nie znaleziono katalogu dokumentacji (index.html + values/).";
            return;
        }

        SubHead.Text = _root;
        LoadCatalog();
        BuildTree();
        await InitWeb();

        var start = !string.IsNullOrWhiteSpace(_settings.LastPage) && PageExists(_settings.LastPage!)
            ? _settings.LastPage!
            : "index.html";
        Navigate(start);
    }

    // ---- root discovery -------------------------------------------------

    private string LocateRoot()
    {
        foreach (var cand in RootCandidates())
        {
            if (string.IsNullOrWhiteSpace(cand)) continue;
            try
            {
                var full = Path.GetFullPath(cand);
                if (File.Exists(Path.Combine(full, "index.html")) &&
                    Directory.Exists(Path.Combine(full, "values")))
                    return full;
            }
            catch { /* bad path */ }
        }
        return "";
    }

    private IEnumerable<string> RootCandidates()
    {
        var args = Environment.GetCommandLineArgs();
        if (args.Length > 1) yield return args[1];
        if (_settings.DocsRoot is { } s) yield return s;

        // Walk up from the executable: handles running from bin/Debug/...
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        for (int i = 0; i < 8 && dir is not null; i++, dir = dir.Parent)
            yield return dir.FullName;

        yield return Directory.GetCurrentDirectory();
        yield return @"D:\docs";
    }

    // ---- data -----------------------------------------------------------

    private string DataDir => Path.Combine(_root, "values", "data");

    private void LoadCatalog()
    {
        try
        {
            _catalog = CatalogStore.LoadCatalog(Path.Combine(DataDir, "catalog.json"));
            if (_catalog is not null)
                Status.Text = $"{_catalog.PageCount} stron · {_catalog.Sections.Count} działów";
        }
        catch (Exception ex)
        {
            Status.Text = "Błąd wczytywania indeksu: " + ex.Message;
        }
    }

    private bool PageExists(string rel)
    {
        try { return File.Exists(Path.Combine(_root, rel.Replace('/', Path.DirectorySeparatorChar))); }
        catch { return false; }
    }

    private void BuildTree()
    {
        _sections.Clear();
        _allPages.Clear();
        if (_catalog is null) { Tree.ItemsSource = _sections; return; }

        var bySection = _catalog.Pages
            .GroupBy(p => p.Section)
            .ToDictionary(g => g.Key, g => g.ToList());

        foreach (var sec in _catalog.Sections.OrderBy(s => s.Order).ThenBy(s => s.Title))
        {
            if (!bySection.TryGetValue(sec.Id, out var pages)) continue;
            var node = new NavSection { Header = $"{sec.Icon}  {sec.Title}  ({pages.Count})" };

            foreach (var p in pages
                         .OrderByDescending(p => p.IsIndex)
                         .ThenBy(p => p.Subsection)
                         .ThenBy(p => p.Path, StringComparer.OrdinalIgnoreCase))
            {
                var np = NewPage(p);
                node.Pages.Add(np);
                _allPages.Add(np);
            }
            _sections.Add(node);
        }
        Tree.ItemsSource = _sections;
    }

    private static NavPage NewPage(DocPage p)
    {
        var title = !string.IsNullOrWhiteSpace(p.Heading) ? p.Heading
                  : !string.IsNullOrWhiteSpace(p.Title) ? p.Title
                  : Path.GetFileNameWithoutExtension(p.Path);
        var sub = !string.IsNullOrWhiteSpace(p.Subtitle) ? p.Subtitle : p.Subsection;
        return new NavPage
        {
            Header = title,
            Sub = sub,
            Path = p.Path,
            SubVisible = string.IsNullOrWhiteSpace(sub) ? Visibility.Collapsed : Visibility.Visible,
        };
    }

    // ---- WebView2 -------------------------------------------------------

    private async Task InitWeb()
    {
        var udf = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Kompendium", "WebView2");
        Directory.CreateDirectory(udf);

        var env = await CoreWebView2Environment.CreateAsync(userDataFolder: udf);
        await Web.EnsureCoreWebView2Async(env);

        var c = Web.CoreWebView2;
        c.SetVirtualHostNameToFolderMapping(Host, _root, CoreWebView2HostResourceAccessKind.Allow);
        c.Settings.AreDefaultContextMenusEnabled = true;
        c.Settings.IsZoomControlEnabled = true;
        c.Settings.AreDevToolsEnabled = false;
        c.Settings.IsStatusBarEnabled = false;

        c.SourceChanged += OnSourceChanged;
        c.WebMessageReceived += OnWebMessage;
        _webReady = true;
    }

    private void Navigate(string relPath)
    {
        if (!_webReady) return;
        var clean = relPath.Replace('\\', '/').TrimStart('/');
        Web.CoreWebView2.Navigate($"https://{Host}/{clean}");
    }

    private void OnSourceChanged(object? sender, CoreWebView2SourceChangedEventArgs e)
    {
        var src = Web.CoreWebView2?.Source;
        if (string.IsNullOrEmpty(src)) return;
        if (!Uri.TryCreate(src, UriKind.Absolute, out var uri)) return;
        if (!uri.Host.Equals(Host, StringComparison.OrdinalIgnoreCase)) return;

        var rel = Uri.UnescapeDataString(uri.AbsolutePath.TrimStart('/'));
        if (rel.Length == 0) rel = "index.html";

        Address.Text = rel;
        var page = rel.Split('#')[0];
        if (page.EndsWith(".html", StringComparison.OrdinalIgnoreCase))
            _settings.LastPage = page;
    }

    private void OnWebMessage(object? sender, CoreWebView2WebMessageReceivedEventArgs e)
    {
        try
        {
            using var doc = JsonDocument.Parse(e.WebMessageAsJson);
            var r = doc.RootElement;
            if (r.TryGetProperty("t", out var t) && t.GetString() == "progress" &&
                r.TryGetProperty("pct", out var pct))
            {
                var v = pct.GetDouble();
                Progress.Text = v > 0.01 ? $"przeczytane {v * 100:0}%" : "";
            }
        }
        catch { /* ignore malformed messages */ }
    }

    // ---- UI events ------------------------------------------------------

    private void Tree_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
    {
        if (e.NewValue is NavPage np) Navigate(np.Path);
    }

    private void Search_TextChanged(object sender, TextChangedEventArgs e)
    {
        var q = Search.Text.Trim();
        if (q.Length == 0) { Tree.ItemsSource = _sections; return; }

        var hits = _allPages
            .Where(p => p.Header.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                        p.Path.Contains(q, StringComparison.OrdinalIgnoreCase) ||
                        p.Sub.Contains(q, StringComparison.OrdinalIgnoreCase))
            .Take(200)
            .ToList();
        Tree.ItemsSource = hits;
    }

    private void Home_Click(object sender, RoutedEventArgs e) => Navigate("index.html");

    private async void Resume_Click(object sender, RoutedEventArgs e)
    {
        if (!_webReady) return;
        try
        {
            var raw = await Web.CoreWebView2.ExecuteScriptAsync("localStorage.getItem('komp:last')");
            if (raw is null or "null") { Status.Text = "Brak zapamiętanej strony."; return; }
            var page = JsonSerializer.Deserialize<string>(raw);
            if (!string.IsNullOrWhiteSpace(page) && PageExists(page)) Navigate(page);
            else Status.Text = "Brak zapamiętanej strony.";
        }
        catch { Status.Text = "Nie udało się wznowić."; }
    }

    private void Reindex_Click(object sender, RoutedEventArgs e)
    {
        LoadCatalog();
        BuildTree();
        if (Search.Text.Trim().Length > 0) Search_TextChanged(Search, null!);
        Status.Text = "Indeks odświeżony.";
    }

    private void Back_Click(object sender, RoutedEventArgs e)
    {
        if (_webReady && Web.CoreWebView2.CanGoBack) Web.CoreWebView2.GoBack();
    }

    private void Forward_Click(object sender, RoutedEventArgs e)
    {
        if (_webReady && Web.CoreWebView2.CanGoForward) Web.CoreWebView2.GoForward();
    }

    private async void InPageSearch_Click(object sender, RoutedEventArgs e)
    {
        if (_webReady)
            await Web.CoreWebView2.ExecuteScriptAsync("window.kompOpenSearch && window.kompOpenSearch()");
    }

    private void OnClosing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        _settings.Width = Width;
        _settings.Height = Height;
        _settings.SidebarWidth = SidebarCol.ActualWidth > 0 ? SidebarCol.ActualWidth : _settings.SidebarWidth;
        _settings.DocsRoot = _root.Length > 0 ? _root : _settings.DocsRoot;
        _settings.Save();
    }
}
