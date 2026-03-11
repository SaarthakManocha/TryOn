// Wardrobe Screen - Saved outfits
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';

enum FilterType { all, favorites, recent }

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  FilterType _filter = FilterType.all;

  @override
  void initState() {
    super.initState();
    ref.read(tryOnProvider.notifier).loadTryOns();
  }

  List<TryOnItem> get _filteredItems {
    final tryOns = ref.watch(tryOnProvider).tryOns;
    switch (_filter) {
      case FilterType.favorites:
        return tryOns.where((item) => item.isFavorite).toList();
      case FilterType.recent:
        return tryOns.take(10).toList();
      case FilterType.all:
        return tryOns;
    }
  }

  void _handleToggleFavorite(String id) {
    ref.read(tryOnProvider.notifier).toggleFavorite(id);
  }

  void _handleDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete', style: AppTypography.h3),
        content: Text('Are you sure you want to delete this try-on?', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(tryOnProvider.notifier).deleteTryOn(id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - AppSpacing.lg * 3) / 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('My Wardrobe', style: AppTypography.h1),
            ),
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: FilterType.values.map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.surface,
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          f.name[0].toUpperCase() + f.name.substring(1),
                          style: AppTypography.bodySmall.copyWith(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Content
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👗', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _filter == FilterType.favorites ? 'No favorites yet' : 'No try-ons saved',
                            style: AppTypography.h3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _filter == FilterType.favorites
                                ? 'Tap the heart on try-ons to add them here'
                                : 'Start a try-on and save your results here',
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.md,
                            children: filteredItems.map((item) {
                              return GestureDetector(
                                onLongPress: () => _handleDelete(item.id),
                                child: Container(
                                  width: cardWidth,
                                  height: cardWidth / 0.75,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.largeRadius,
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: AppRadius.largeRadius,
                                        child: item.resultImageUri.startsWith('http')
                                            ? Image.network(item.resultImageUri, fit: BoxFit.cover, width: cardWidth, height: cardWidth / 0.75)
                                            : Image.file(File(item.resultImageUri), fit: BoxFit.cover, width: cardWidth, height: cardWidth / 0.75),
                                      ),
                                      Positioned(
                                        top: AppSpacing.sm,
                                        right: AppSpacing.sm,
                                        child: GestureDetector(
                                          onTap: () => _handleToggleFavorite(item.id),
                                          child: Text(item.isFavorite ? '❤️' : '🤍', style: const TextStyle(fontSize: 20)),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(AppRadius.lg),
                                              bottomRight: Radius.circular(AppRadius.lg),
                                            ),
                                          ),
                                          child: Text(_formatDate(item.createdAt), style: AppTypography.caption.copyWith(color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            '${filteredItems.length} outfit${filteredItems.length != 1 ? 's' : ''} saved',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
