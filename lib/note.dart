class Note {
	// Note properties
  final int? id;
  String content;
	bool isFavorite;

  // Constructor with named parameters
  Note({
    this.id,
    required this.content,
    required this.isFavorite,
  });

	// Factory constructor to create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,      // Convert 'id' from JSON to int
      content: json['body'] as String, // Convert 'body' from JSON to String
      isFavorite: json['is_favorite'] ?? false,
    );
  }
   // Method to convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'body': content,    // Only content is serialized to JSON
      'is_favorite': isFavorite,
    };
  }
}