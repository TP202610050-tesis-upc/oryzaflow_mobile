import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_dimensions.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppDimensions.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? const Color(0xFF1E2E2E) : const Color(0xFFE5E7EB),
      highlightColor: dark ? const Color(0xFF2A4040) : const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1E2E2E) : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 4, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingS),
      itemBuilder: (_, __) => LoadingShimmer(
        width: double.infinity,
        height: itemHeight,
      ),
    );
  }
}
