class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final Map<String, dynamic>? meta;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasMore,
    this.meta,
  });
}
