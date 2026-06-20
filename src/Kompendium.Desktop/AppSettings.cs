using System.IO;
using System.Text.Json;

namespace Kompendium.Desktop;

/// <summary>Persisted UI state stored under %APPDATA%\Kompendium\settings.json.</summary>
public sealed class AppSettings
{
    public string? DocsRoot { get; set; }
    public string? LastPage { get; set; }
    public double Width { get; set; } = 1240;
    public double Height { get; set; } = 780;
    public double SidebarWidth { get; set; } = 340;

    private static readonly JsonSerializerOptions Json = new() { WriteIndented = true };

    public static string Dir =>
        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Kompendium");

    public static string FilePath => Path.Combine(Dir, "settings.json");

    public static AppSettings Load()
    {
        try
        {
            if (File.Exists(FilePath))
                return JsonSerializer.Deserialize<AppSettings>(File.ReadAllText(FilePath)) ?? new();
        }
        catch { /* corrupt settings — fall back to defaults */ }
        return new();
    }

    public void Save()
    {
        try
        {
            Directory.CreateDirectory(Dir);
            File.WriteAllText(FilePath, JsonSerializer.Serialize(this, Json));
        }
        catch { /* non-fatal: settings are a convenience, not required */ }
    }
}
