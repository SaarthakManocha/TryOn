// TryOn Provider - Manage try-on history and wardrobe
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TryOn item model
class TryOnItem {
  final String id;
  final String outfitImageUri;
  final String userImageUri;
  final String resultImageUri;
  final bool isFavorite;
  final String createdAt;

  TryOnItem({
    required this.id,
    required this.outfitImageUri,
    required this.userImageUri,
    required this.resultImageUri,
    this.isFavorite = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'outfitImageUri': outfitImageUri,
        'userImageUri': userImageUri,
        'resultImageUri': resultImageUri,
        'isFavorite': isFavorite,
        'createdAt': createdAt,
      };

  factory TryOnItem.fromJson(Map<String, dynamic> json) => TryOnItem(
        id: json['id'] as String,
        outfitImageUri: json['outfitImageUri'] as String,
        userImageUri: json['userImageUri'] as String,
        resultImageUri: json['resultImageUri'] as String,
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: json['createdAt'] as String,
      );

  TryOnItem copyWith({
    String? id,
    String? outfitImageUri,
    String? userImageUri,
    String? resultImageUri,
    bool? isFavorite,
    String? createdAt,
  }) =>
      TryOnItem(
        id: id ?? this.id,
        outfitImageUri: outfitImageUri ?? this.outfitImageUri,
        userImageUri: userImageUri ?? this.userImageUri,
        resultImageUri: resultImageUri ?? this.resultImageUri,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
      );
}

// Current try-on state
class CurrentTryOn {
  final String? outfitImage;
  final String? userImage;
  final String? resultImage;

  CurrentTryOn({
    this.outfitImage,
    this.userImage,
    this.resultImage,
  });

  CurrentTryOn copyWith({
    String? outfitImage,
    String? userImage,
    String? resultImage,
  }) =>
      CurrentTryOn(
        outfitImage: outfitImage ?? this.outfitImage,
        userImage: userImage ?? this.userImage,
        resultImage: resultImage ?? this.resultImage,
      );

  CurrentTryOn clear() => CurrentTryOn();
}

// TryOn state
class TryOnState {
  final List<TryOnItem> tryOns;
  final CurrentTryOn currentTryOn;
  final bool isProcessing;

  TryOnState({
    this.tryOns = const [],
    CurrentTryOn? currentTryOn,
    this.isProcessing = false,
  }) : currentTryOn = currentTryOn ?? CurrentTryOn();

  TryOnState copyWith({
    List<TryOnItem>? tryOns,
    CurrentTryOn? currentTryOn,
    bool? isProcessing,
  }) =>
      TryOnState(
        tryOns: tryOns ?? this.tryOns,
        currentTryOn: currentTryOn ?? this.currentTryOn,
        isProcessing: isProcessing ?? this.isProcessing,
      );
}

// TryOn notifier
class TryOnNotifier extends StateNotifier<TryOnState> {
  static const String _tryOnsKey = '@tryon_history';

  TryOnNotifier() : super(TryOnState()) {
    loadTryOns();
  }

  Future<void> loadTryOns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_tryOnsKey);

      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored);
        final tryOns = decoded.map((e) => TryOnItem.fromJson(e)).toList();
        state = state.copyWith(tryOns: tryOns);
      }
    } catch (e) {
      // Handle error
    }
  }

  void setOutfitImage(String uri) {
    state = state.copyWith(
      currentTryOn: state.currentTryOn.copyWith(outfitImage: uri),
    );
  }

  void setUserImage(String uri) {
    state = state.copyWith(
      currentTryOn: state.currentTryOn.copyWith(userImage: uri),
    );
  }

  void setResultImage(String uri) {
    state = state.copyWith(
      currentTryOn: state.currentTryOn.copyWith(resultImage: uri),
    );
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  Future<void> saveTryOn(String resultUri) async {
    try {
      final newTryOn = TryOnItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        outfitImageUri: state.currentTryOn.outfitImage ?? '',
        userImageUri: state.currentTryOn.userImage ?? '',
        resultImageUri: resultUri,
        isFavorite: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      final updated = [newTryOn, ...state.tryOns];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _tryOnsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );

      state = state.copyWith(tryOns: updated);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final updated = state.tryOns.map((item) {
        if (item.id == id) {
          return item.copyWith(isFavorite: !item.isFavorite);
        }
        return item;
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _tryOnsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );

      state = state.copyWith(tryOns: updated);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTryOn(String id) async {
    try {
      final updated = state.tryOns.where((item) => item.id != id).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _tryOnsKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );

      state = state.copyWith(tryOns: updated);
    } catch (e) {
      // Handle error
    }
  }

  void clearCurrentTryOn() {
    state = state.copyWith(
      currentTryOn: CurrentTryOn(),
      isProcessing: false,
    );
  }
}

// Provider
final tryOnProvider = StateNotifierProvider<TryOnNotifier, TryOnState>((ref) {
  return TryOnNotifier();
});
