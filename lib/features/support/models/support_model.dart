class Support {
  final String name;
  final String message;
  final String time;
  final String image;
  final bool isOnline;

  Support({
    required this.name,
    required this.message,
    required this.time,
    required this.image,
    required this.isOnline,
  });

  factory Support.fromMap(Map<String, String> data) {
    return Support(
      name: data['name'] ?? '',
      message: data['message'] ?? '',
      time: data['time'] ?? '',
      image: data['image'] ?? '',
      isOnline: data['status'] == 'online',
    );
  }
}
