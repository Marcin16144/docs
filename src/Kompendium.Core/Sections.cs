namespace Kompendium.Core;

/// <summary>Built-in taxonomy for known top-level domains. Unknown folders get a sensible default.</summary>
public static class Sections
{
    public sealed record Meta(string Title, string Icon, string Color, int Order, string[] Tags);

    public static readonly Dictionary<string, Meta> Known = new(StringComparer.OrdinalIgnoreCase)
    {
        ["house"]       = new("Dom — rośliny, grzyby, kryształy", "🌿", "#4ade80", 1,  new[]{"zielarstwo","grzyby","kryształy","przepisy"}),
        ["electric"]    = new("Elektryka domowa", "⚡", "#fbbf24", 2,  new[]{"instalacja","rozdzielnica","fotowoltaika","off-grid","normy"}),
        ["electronic"]  = new("Elektronika i naprawy", "🔌", "#60a5fa", 3,  new[]{"rezystory","tranzystory","zasilacze","lutowanie","oscyloskop"}),
        ["software"]    = new("Software i programowanie", "💻", "#22d3ee", 4,  new[]{"javascript","react","docker","linux","api","llm"}),
        ["hardware"]    = new("Hardware", "🖥️", "#a78bfa", 5,  new[]{"gpu","rtx","serwery","vram","smart home","esp32"}),
        ["monitoring"]  = new("Monitoring i zabezpieczenia", "📡", "#2dd4bf", 6,  new[]{"cctv","nvr","alarmy","ppoż","domofony"}),
        ["cars"]        = new("Naprawa i serwis samochodów", "🚗", "#fb923c", 7,  new[]{"obd2","silnik","hamulce","zawieszenie","przeglądy"}),
        ["agd"]         = new("Naprawa sprzętu AGD i RTV", "🏠", "#f87171", 8,  new[]{"pralka","lodówka","bojler","tv","kody błędów"}),
        ["music"]       = new("Muzyka — nauka i produkcja", "🎵", "#f472b6", 9,  new[]{"pianino","reaper","fl studio","ai","pluginy"}),
        ["video"]       = new("Video — montaż i postprodukcja", "🎬", "#f43f5e", 10, new[]{"davinci resolve","montaż","kolor","eksport"}),
        ["grafika3d"]   = new("Grafika 3D — modelowanie i animacja", "🧊", "#818cf8", 11, new[]{"blender","modelowanie","animacja","rendering"}),
        ["Optima"]      = new("Comarch Optima — moduły ERP", "💼", "#10b981", 12, new[]{"kadry i płace","zus","pit","ppk","przepisy"}),
        ["cwiczenia"]   = new("Ćwiczenia — joga, tai chi, kung-fu", "🧘", "#a3e635", 13, new[]{"joga","asany","tai chi","qigong","kung-fu"}),
        ["services"]    = new("Usługi i API zewnętrzne", "🌐", "#38bdf8", 14, new[]{"api","seo","soundcloud","audius"}),
        ["Kryptowaluty"]= new("Kryptowaluty", "🪙", "#f59e0b", 15, new[]{"krypto","blockchain","bitcoin"}),
        ["Terapia"]     = new("Terapia i rozwój", "🧠", "#e879f9", 16, new[]{"terapia","psychologia","rozwój"}),
        ["Dokumentacje"]= new("Dokumentacje urządzeń", "📄", "#94a3b8", 17, new[]{"router","instrukcja","sprzęt"}),
    };

    public static Meta For(string topDir) =>
        Known.TryGetValue(topDir, out var m)
            ? m
            : new Meta(Capitalize(topDir), "📁", "#94a3b8", 900, Array.Empty<string>());

    private static string Capitalize(string s) =>
        string.IsNullOrEmpty(s) ? s : char.ToUpperInvariant(s[0]) + s[1..];
}
