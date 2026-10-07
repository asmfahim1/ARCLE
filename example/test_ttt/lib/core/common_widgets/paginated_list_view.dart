import 'package:flutter/material.dart';
import '../utils/dimensions.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef SeparatorBuilder = Widget Function(BuildContext context, int index);
typedef LoadMoreCallback = void Function();

/// Pure-UI paginated list — state (items, loading, hasReachedMax) lives in
/// the caller's state management layer (BLoC / GetX / Riverpod / etc.).
class PaginatedListView<T> extends StatelessWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.isLoading,
    required this.onLoadMore,
    this.hasReachedMax = false,
    this.scrollController,
    this.padding,
    this.reverse = false,
    this.primary,
    this.separatorBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.endWidget,
    this.loadThreshold = 0.8,
    this.showLoadingIndicator = true,
  });

  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final bool isLoading;
  final LoadMoreCallback onLoadMore;
  final bool hasReachedMax;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool reverse;
  final bool? primary;
  final SeparatorBuilder? separatorBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? endWidget;
  final double loadThreshold;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading && emptyWidget != null) {
      return emptyWidget!;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScroll(notification);
        return false;
      },
      child: CustomScrollView(
        key: const PageStorageKey<String>('paginated_list'),
        controller: scrollController,
        reverse: reverse,
        primary: primary,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (padding != null) SliverPadding(padding: padding!),
          separatorBuilder != null ? _separatedList() : _normalList(),
          if (_bottomWidget() != null) _bottomWidget()!,
        ],
      ),
    );
  }

  Widget _normalList() => SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => itemBuilder(ctx, items[i], i),
          childCount: items.length,
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: true,
        ),
      );

  Widget _separatedList() => SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (ctx, i) => separatorBuilder!(ctx, i),
        itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
      );

  Widget? _bottomWidget() {
    if (isLoading && showLoadingIndicator) {
      return SliverToBoxAdapter(
        child: loadingWidget ??
            Padding(
              padding: Dimensions.allPadding(16),
              child: Center(
                child: SizedBox(
                  height: Dimensions.height(40),
                  width: Dimensions.width(40),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
      );
    }
    if (hasReachedMax && endWidget != null && items.isNotEmpty) {
      return SliverToBoxAdapter(child: endWidget);
    }
    return null;
  }

  void _handleScroll(ScrollNotification notification) {
    if (isLoading || hasReachedMax || items.isEmpty) return;
    if (notification is ScrollUpdateNotification) {
      final m = notification.metrics;
      if (m.maxScrollExtent > 0 && m.pixels >= m.maxScrollExtent * loadThreshold) {
        onLoadMore();
      }
    }
    if (notification is ScrollEndNotification) {
      final m = notification.metrics;
      if (m.atEdge && m.pixels > 0) onLoadMore();
    }
  }
}
