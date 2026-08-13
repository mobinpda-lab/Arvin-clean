/// Configuration for a cloud backup provider.
///
/// The access token is intentionally kept in memory only. Persistence of
/// credentials belongs to a platform-secure storage layer and must not use
/// SharedPreferences or source control.
class CloudBackupSettings {
  const CloudBackupSettings({
    required this.accessToken,
    this.rootPath = '/Apps/Arvin',
  });

  final String accessToken;
  final String rootPath;

  bool get isConfigured => accessToken.trim().isNotEmpty;

  CloudBackupSettings copyWith({
    String? accessToken,
    String? rootPath,
  }) {
    return CloudBackupSettings(
      accessToken: accessToken ?? this.accessToken,
      rootPath: rootPath ?? this.rootPath,
    );
  }
}
