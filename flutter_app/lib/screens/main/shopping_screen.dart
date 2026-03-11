// Shopping Screen - Product search results from garment image
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../services/tryon_api_service.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  bool _loading = true;
  String? _error;
  List<ProductItem> _products = [];
  int _searchTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _searchProducts();
  }

  Future<void> _searchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tryOnState = ref.read(tryOnProvider);
      final currentTryOn = tryOnState.currentTryOn;
      
      // Get the garment image URL (prefer Cloudinary URL if available)
      String? imageUrl = currentTryOn.outfitImage;
      
      if (imageUrl == null || imageUrl.isEmpty) {
        setState(() {
          _error = 'No garment image to search for';
          _loading = false;
        });
        return;
      }
      
      // If it's a local file, we can't search (need URL)
      if (!imageUrl.startsWith('http')) {
        // For now, show a message - in production, we'd upload the image first
        setState(() {
          _error = 'Please use an online garment image for shopping search';
          _loading = false;
        });
        return;
      }
      // Get user preferences for size-based search refinement
      final prefs = ref.read(preferencesProvider).preferences;
      
      // Determine user's size based on body type or explicit size preference
      String? userSize;
      if (prefs.bodyType.isNotEmpty) {
        // Map body type to approximate size
        switch (prefs.bodyType.toLowerCase()) {
          case 'slim':
            userSize = 'S';
            break;
          case 'average':
          case 'regular':
          case 'medium':
            userSize = 'M';
            break;
          case 'chubby':
            userSize = 'XL';
            break;
          case 'muscular':
          case 'athletic':
            userSize = 'L';
            break;
        }
      }
      
      // Call the product search API with size-based refinement
      final result = await tryOnApiService.searchProducts(
        imageUrl: imageUrl,
        maxResults: 10,
        country: 'in',
        includeGlobal: true,
        size: userSize,
        bodyType: prefs.bodyType.isNotEmpty ? prefs.bodyType : null,
      );
      
      if (result.success) {
        setState(() {
          _products = result.products;
          _searchTimeMs = result.searchTimeMs ?? 0;
          _loading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'Search failed';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _handleOpenLink(String url) async {
    if (url.isEmpty) return;
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tryOnState = ref.watch(tryOnProvider);
    final currentTryOn = tryOnState.currentTryOn;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.text)),
                  ),
                  Text('Shop Similar', style: AppTypography.h3),
                  GestureDetector(
                    onTap: _searchProducts,
                    child: const Text('🔄', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
            
            // Loading state
            if (_loading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Searching for similar products...', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('This may take a few seconds', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              )
            
            // Error state
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('😕', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Search Failed', style: AppTypography.h2),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: AppTypography.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          title: 'Try Again',
                          onPressed: _searchProducts,
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            
            // Results
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original Outfit Reference
                      if (currentTryOn.outfitImage != null && currentTryOn.outfitImage!.isNotEmpty)
                        AppCard(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.mediumRadius,
                                child: currentTryOn.outfitImage!.startsWith('http')
                                    ? Image.network(currentTryOn.outfitImage!, width: 80, height: 100, fit: BoxFit.cover)
                                    : Image.file(File(currentTryOn.outfitImage!), width: 80, height: 100, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Looking for this?', style: AppTypography.h3),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Found ${_products.length} similar items', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                    if (_searchTimeMs > 0)
                                      Text('Searched in ${(_searchTimeMs / 1000).toStringAsFixed(1)}s', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // No results
                      if (_products.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                const Text('🔍', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: AppSpacing.md),
                                Text('No products found', style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.sm),
                                Text('Try with a different garment image', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text('Similar Items', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Products Grid
                        ...List.generate(_products.length, (index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        }),
                      ],
                      
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          'Prices may vary. Tap to visit the store.',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
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

  Widget _buildProductCard(ProductItem product) {
    return GestureDetector(
      onTap: () => _handleOpenLink(product.link),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.largeRadius,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: AppRadius.mediumRadius,
              child: product.thumbnail != null && product.thumbnail!.isNotEmpty
                  ? Image.network(
                      product.thumbnail!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surfaceLight,
                        child: const Center(child: Text('👕', style: TextStyle(fontSize: 32))),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surfaceLight,
                      child: const Center(child: Text('👕', style: TextStyle(fontSize: 32))),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (product.price != null && product.price!.isNotEmpty)
                        Text(
                          product.price!,
                          style: AppTypography.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        )
                      else
                        Text('Price unavailable', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Text(product.store, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (product.rating != null)
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 2),
                            Text('${product.rating}', style: AppTypography.caption),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade600, Colors.blue.shade600],
                          ),
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Text('View →', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
