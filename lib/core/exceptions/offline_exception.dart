/// Custom exception thrown when there's no internet connection
/// This allows views to easily identify offline state and show appropriate UI
class OfflineException implements Exception {
  final String message;

  const OfflineException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}
