class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasMore,
  });
}
