// TryOn API Service - Connects Flutter app to Backend
import 'package:dio/dio.dart';

/// Backend API Service - connects to local server (mobile hotspot setup)
class TryOnApiService {
  // 🏠 LOCAL SERVER - Update this IP when your WiFi/hotspot changes
  // Run `ipconfig` on your laptop to find your current IP
  static const String _baseUrl = 'http://192.168.1.41:8000';
  
  // 🌐 RENDER (backup) - Uncomment to use cloud server
  // static const String _baseUrl = 'https://tryon-backend-8fnh.onrender.com';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30), // Local is fast
    receiveTimeout: const Duration(seconds: 120), // Processing time
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  // === Health Check ===
  
  Future<bool> isBackendAvailable() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // === Step 2: Face & Skin Extraction ===
  
  Future<FaceExtractionResult> extractFace({
    required String selfiePath,
    required String userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'selfie': await MultipartFile.fromFile(selfiePath, filename: 'selfie.jpg'),
      });
      
      final response = await _dio.post(
        '/api/extract-face',
        data: formData,
        queryParameters: {'user_id': userId},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return FaceExtractionResult.fromJson(response.data);
      }
      
      return FaceExtractionResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return FaceExtractionResult(success: false, error: _handleError(e));
    }
  }
  
  // === Step 2A: Hair Extraction ===
  
  Future<HairExtractionResult> extractHair({
    required String selfiePath,
    required String userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'selfie': await MultipartFile.fromFile(selfiePath, filename: 'selfie.jpg'),
      });
      
      final response = await _dio.post(
        '/api/extract-hair',
        data: formData,
        queryParameters: {'user_id': userId},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return HairExtractionResult.fromJson(response.data);
      }
      
      return HairExtractionResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return HairExtractionResult(success: false, error: _handleError(e));
    }
  }
  
  // === Step 3: Base Body Creation ===
  
  Future<BaseBodyResult> createBaseBody({
    required String userId,
    required String gender,
    required String bodyBuild,
    required int heightCm,
    required List<int> skinToneRgb,
  }) async {
    try {
      final response = await _dio.post('/api/create-base-body', data: {
        'user_id': userId,
        'gender': gender,
        'body_build': bodyBuild,
        'height_cm': heightCm,
        'skin_tone_rgb': skinToneRgb,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return BaseBodyResult.fromJson(response.data);
      }
      
      return BaseBodyResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return BaseBodyResult(success: false, error: _handleError(e));
    }
  }
  
  // === Step 4: Garment Segmentation ===
  
  Future<GarmentSegmentResult> segmentGarmentFromUrl({
    required String imageUrl,
    required String userId,
    String? garmentId,
  }) async {
    try {
      final response = await _dio.post('/api/segment-garment-url', data: {
        'image_url': imageUrl,
        'user_id': userId,
        'garment_id': garmentId,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return GarmentSegmentResult.fromJson(response.data);
      }
      
      return GarmentSegmentResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return GarmentSegmentResult(success: false, error: _handleError(e));
    }
  }
  
  Future<GarmentSegmentResult> segmentGarmentFromFile({
    required String imagePath,
    required String userId,
    String? garmentId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        if (garmentId != null) 'garment_id': garmentId,
        'image': await MultipartFile.fromFile(imagePath, filename: 'garment.jpg'),
      });
      
      final response = await _dio.post(
        '/api/segment-garment',
        data: formData,
        queryParameters: {'user_id': userId},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return GarmentSegmentResult.fromJson(response.data);
      }
      
      return GarmentSegmentResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return GarmentSegmentResult(success: false, error: _handleError(e));
    }
  }
  
  // === Step 5: Try-On Generation ===
  
  Future<TryOnResult> generateTryOn({
    required String userId,
    required String garmentPath,
    String garmentType = 'upper_body',
  }) async {
    try {
      final response = await _dio.post('/api/tryon', data: {
        'user_id': userId,
        'garment_path': garmentPath,
        'garment_type': garmentType,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return TryOnResult.fromJson(response.data);
      }
      
      return TryOnResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return TryOnResult(success: false, error: _handleError(e));
    }
  }
  
  // === Step 6: Composite (add face/hair back) ===
  
  Future<CompositeResult> compositeFace({
    required String userId,
    required String tryonImagePath,
    required List<int> skinToneRgb,
    String? hairImagePath,
  }) async {
    try {
      final response = await _dio.post('/api/composite', data: {
        'user_id': userId,
        'tryon_image_path': tryonImagePath,
        'skin_tone_rgb': skinToneRgb,
        if (hairImagePath != null) 'hair_image_path': hairImagePath,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        return CompositeResult.fromJson(response.data);
      }
      
      return CompositeResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return CompositeResult(success: false, error: _handleError(e));
    }
  }
  
  // === Product Search ===
  
  Future<ProductSearchResult> searchProducts({
    required String imageUrl,
    int maxResults = 10,
    String country = 'in',
    bool includeGlobal = true,
    String? size,  // User's clothing size (S, M, L, XL, XXL)
    String? bodyType,  // User's body type for better recommendations
  }) async {
    try {
      final data = <String, dynamic>{
        'image_url': imageUrl,
        'max_results': maxResults,
        'country': country,
        'include_global': includeGlobal,
      };
      
      // Add size to search query for refined results
      if (size != null && size.isNotEmpty) {
        data['size'] = size;
      }
      if (bodyType != null && bodyType.isNotEmpty) {
        data['body_type'] = bodyType;
      }
      
      final response = await _dio.post('/api/search-products', data: data);
      
      if (response.statusCode == 200 && response.data != null) {
        return ProductSearchResult.fromJson(response.data);
      }
      
      return ProductSearchResult(success: false, error: 'Unexpected response');
    } catch (e) {
      return ProductSearchResult(success: false, error: _handleError(e));
    }
  }
  
  // === Error Handling ===
  
  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        if (statusCode == 400) return data?['detail'] ?? 'Invalid request';
        if (statusCode == 500) return data?['detail'] ?? 'Server error';
        return 'Server error: $statusCode';
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Server is waking up... Please try again in 30 seconds.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Cannot connect to server. Check your internet.';
      }
    }
    
    return e.toString().replaceAll('Exception: ', '');
  }
}

// === Result Models ===

class FaceExtractionResult {
  final bool success;
  final String? faceImagePath;
  final String? faceImageUrl;
  final List<int>? skinToneRgb;
  final String? processedAt;
  final String? error;
  
  FaceExtractionResult({
    required this.success,
    this.faceImagePath,
    this.faceImageUrl,
    this.skinToneRgb,
    this.processedAt,
    this.error,
  });
  
  factory FaceExtractionResult.fromJson(Map<String, dynamic> json) {
    return FaceExtractionResult(
      success: json['success'] as bool? ?? false,
      faceImagePath: json['face_image_path'] as String?,
      faceImageUrl: json['face_image_url'] as String?,
      skinToneRgb: json['skin_tone_rgb'] != null
          ? List<int>.from(json['skin_tone_rgb'])
          : null,
      processedAt: json['processed_at'] as String?,
      error: json['error'] as String?,
    );
  }
}

class HairExtractionResult {
  final bool success;
  final String? hairMaskPath;
  final String? hairMaskUrl;
  final String? hairImagePath;
  final String? hairImageUrl;
  final String? error;
  
  HairExtractionResult({
    required this.success,
    this.hairMaskPath,
    this.hairMaskUrl,
    this.hairImagePath,
    this.hairImageUrl,
    this.error,
  });
  
  factory HairExtractionResult.fromJson(Map<String, dynamic> json) {
    return HairExtractionResult(
      success: json['success'] as bool? ?? false,
      hairMaskPath: json['hair_mask_path'] as String?,
      hairMaskUrl: json['hair_mask_url'] as String?,
      hairImagePath: json['hair_image_path'] as String?,
      hairImageUrl: json['hair_image_url'] as String?,
      error: json['error'] as String?,
    );
  }
}

class BaseBodyResult {
  final bool success;
  final String? baseBodyPath;
  final String? baseBodyUrl;
  final String? error;
  
  BaseBodyResult({
    required this.success,
    this.baseBodyPath,
    this.baseBodyUrl,
    this.error,
  });
  
  factory BaseBodyResult.fromJson(Map<String, dynamic> json) {
    return BaseBodyResult(
      success: json['success'] as bool? ?? false,
      baseBodyPath: json['base_body_path'] as String?,
      baseBodyUrl: json['base_body_url'] as String?,
      error: json['error'] as String?,
    );
  }
}

class GarmentSegmentResult {
  final bool success;
  final String? garmentImagePath;
  final String? garmentImageUrl;
  final String? garmentId;
  final String? garmentType;
  final String? error;
  
  GarmentSegmentResult({
    required this.success,
    this.garmentImagePath,
    this.garmentImageUrl,
    this.garmentId,
    this.garmentType,
    this.error,
  });
  
  factory GarmentSegmentResult.fromJson(Map<String, dynamic> json) {
    return GarmentSegmentResult(
      success: json['success'] as bool? ?? false,
      garmentImagePath: json['garment_image_path'] as String?,
      garmentImageUrl: json['garment_image_url'] as String?,
      garmentId: json['garment_id'] as String?,
      garmentType: json['garment_type'] as String?,
      error: json['error'] as String?,
    );
  }
}

class TryOnResult {
  final bool success;
  final String? tryonImagePath;
  final String? tryonImageUrl;
  final String? tryonId;
  final bool? isMock;
  final String? message;
  final String? error;
  
  TryOnResult({
    required this.success,
    this.tryonImagePath,
    this.tryonImageUrl,
    this.tryonId,
    this.isMock,
    this.message,
    this.error,
  });
  
  factory TryOnResult.fromJson(Map<String, dynamic> json) {
    return TryOnResult(
      success: json['success'] as bool? ?? false,
      tryonImagePath: json['tryon_image_path'] as String?,
      tryonImageUrl: json['tryon_image_url'] as String?,
      tryonId: json['tryon_id'] as String?,
      isMock: json['mock'] as bool?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class CompositeResult {
  final bool success;
  final String? finalImagePath;
  final String? finalImageUrl;
  final String? finalId;
  final String? error;
  
  CompositeResult({
    required this.success,
    this.finalImagePath,
    this.finalImageUrl,
    this.finalId,
    this.error,
  });
  
  factory CompositeResult.fromJson(Map<String, dynamic> json) {
    return CompositeResult(
      success: json['success'] as bool? ?? false,
      finalImagePath: json['final_image_path'] as String?,
      finalImageUrl: json['final_image_url'] as String?,
      finalId: json['final_id'] as String?,
      error: json['error'] as String?,
    );
  }
}

class ProductSearchResult {
  final bool success;
  final String? queryImage;
  final List<ProductItem> products;
  final int totalFound;
  final int? searchTimeMs;
  final String? error;
  
  ProductSearchResult({
    required this.success,
    this.queryImage,
    this.products = const [],
    this.totalFound = 0,
    this.searchTimeMs,
    this.error,
  });
  
  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      success: json['success'] as bool? ?? false,
      queryImage: json['query_image'] as String?,
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => ProductItem.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      totalFound: json['total_found'] as int? ?? 0,
      searchTimeMs: json['search_time_ms'] as int?,
      error: json['error'] as String?,
    );
  }
}

class ProductItem {
  final String title;
  final String? price;
  final double? priceValue;
  final String currency;
  final String store;
  final String link;
  final String? thumbnail;
  final double? rating;
  final int? reviewsCount;
  final bool inStock;
  
  ProductItem({
    required this.title,
    this.price,
    this.priceValue,
    this.currency = 'INR',
    required this.store,
    required this.link,
    this.thumbnail,
    this.rating,
    this.reviewsCount,
    this.inStock = true,
  });
  
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      title: json['title'] as String? ?? 'Unknown Product',
      price: json['price'] as String?,
      priceValue: (json['price_value'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      store: json['store'] as String? ?? 'Unknown',
      link: json['link'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] as int?,
      inStock: json['in_stock'] as bool? ?? true,
    );
  }
}

// === Singleton Instance ===
final tryOnApiService = TryOnApiService();
