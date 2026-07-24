/// Swappable cloud/object storage for downloadable packages.
/// Firebase Storage, R2, B2, or Supabase can implement this without app UI changes.
abstract class PackageStorage {
  Future<Uri?> resolveBiblePackageUrl(String packageId, String relativePath);
  Future<Uri?> resolveAudioPackageUrl(String packageId, String relativePath);
}

/// Default: use catalog-provided absolute HTTPS URLs (no vendor SDK required).
class CatalogUrlPackageStorage implements PackageStorage {
  const CatalogUrlPackageStorage();

  @override
  Future<Uri?> resolveBiblePackageUrl(
      String packageId, String relativePath) async {
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return Uri.parse(relativePath);
    }
    return null;
  }

  @override
  Future<Uri?> resolveAudioPackageUrl(
      String packageId, String relativePath) async {
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return Uri.parse(relativePath);
    }
    return null;
  }
}
