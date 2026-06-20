using System.Text.Json;
using System.Text.Json.Serialization;

namespace Kompendium.Core;

public static class CatalogStore
{
    public static readonly JsonSerializerOptions Json = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    public static void Write(string path, object value)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        File.WriteAllText(path, JsonSerializer.Serialize(value, Json));
    }

    public static Catalog? LoadCatalog(string path) =>
        File.Exists(path) ? JsonSerializer.Deserialize<Catalog>(File.ReadAllText(path), Json) : null;

    public static Dictionary<string, List<RelatedLink>> LoadRelations(string path) =>
        File.Exists(path)
            ? JsonSerializer.Deserialize<Dictionary<string, List<RelatedLink>>>(File.ReadAllText(path), Json) ?? new()
            : new();
}
