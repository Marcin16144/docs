using System.Collections.ObjectModel;
using System.Windows;

namespace Kompendium.Desktop;

public sealed class NavSection
{
    public string Header { get; set; } = "";
    public ObservableCollection<NavPage> Pages { get; set; } = new();
}

public sealed class NavPage
{
    public string Header { get; set; } = "";
    public string Sub { get; set; } = "";
    public string Path { get; set; } = "";
    public Visibility SubVisible { get; set; } = Visibility.Collapsed;
}
