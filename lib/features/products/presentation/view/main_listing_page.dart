import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/features/auth/presentation/state/auth_provider.dart';
import 'package:zavimart/features/products/presentation/state/products_provider.dart';
import 'package:zavimart/features/products/presentation/widgets/product_card.dart';

class MainListingPage extends ConsumerWidget {
  const MainListingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Failed to load categories"))),
      data: (categories) {
        final allTabs = ['All', ...categories.map((c) => c.name)];

        return DefaultTabController(
          length: allTabs.length,
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await ref.read(categoriesProvider.notifier).refetch();
                await ref
                    .read(productsProvider.notifier)
                    .filterByCategory(null);
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 1,
                    title: const Text(
                      "ZaviMart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black54),
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                        },
                      ),
                    ],
                    bottom: TabBar(
                      isScrollable: true,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: allTabs.map((name) => Tab(text: name)).toList(),
                      onTap: (index) {
                        final selectedCategory = index == 0
                            ? null
                            : allTabs[index];
                        ref
                            .read(productsProvider.notifier)
                            .filterByCategory(selectedCategory);
                      },
                    ),
                  ),
                  productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: Text("No products found.")),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return ProductCard(product: product, onTap: () {});
                          }, childCount: products.length),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Failed to load products.\n${err.toString()}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
