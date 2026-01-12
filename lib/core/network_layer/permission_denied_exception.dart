/// Exception thrown when user doesn't have permission to access a resource
class PermissionDeniedException implements Exception {
  final String message;
  final String? feature;
  final String? permission;

  PermissionDeniedException({
    required this.message,
    this.feature,
    this.permission,
  });

  @override
  String toString() => 'PermissionDeniedException: $message';
}
