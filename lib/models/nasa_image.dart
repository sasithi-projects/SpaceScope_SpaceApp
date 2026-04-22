class NasaImage {
  final String title;
  final String? description;
  final String? previewUrl;
  final String mediaType; // "image" or "video"
  final String? assetUrl; // needed for video external open

  NasaImage({
    required this.title,
    this.description,
    this.previewUrl,
    required this.mediaType,
    this.assetUrl,
  });

  factory NasaImage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List?;
    final linksList = json['links'] as List?;

    final data = (dataList != null && dataList.isNotEmpty)
        ? dataList.first as Map<String, dynamic>
        : <String, dynamic>{};

    final title = (data['title'] ?? '') as String;
    final description = data['description'] as String?;
    final mediaType = (data['media_type'] ?? 'image') as String;
    final nasaId = data['nasa_id'] as String?;

    String? previewUrl;
    if (linksList != null && linksList.isNotEmpty) {
      final link0 = linksList.first as Map<String, dynamic>;
      previewUrl = link0['href'] as String?;
    }

    return NasaImage(
      title: title,
      description: description,
      previewUrl: previewUrl,
      mediaType: mediaType,
      assetUrl: nasaId != null ? 'https://images-api.nasa.gov/asset/$nasaId' : null,
    );
  }

  // For local storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'previewUrl': previewUrl,
      'mediaType': mediaType,
      'assetUrl': assetUrl,
    };
  }

  // For reading from local storage
  factory NasaImage.fromMap(Map<String, dynamic> map) {
    return NasaImage(
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      previewUrl: map['previewUrl'] as String?,
      mediaType: (map['mediaType'] ?? 'image') as String,
      assetUrl: map['assetUrl'] as String?,
    );
  }
}
