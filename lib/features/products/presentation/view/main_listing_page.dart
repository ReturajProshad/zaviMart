import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/routes/app_routes.dart';
import 'package:zavimart/features/auth/presentation/state/auth_provider.dart';
import 'package:zavimart/features/products/presentation/state/products_provider.dart';
import 'package:zavimart/features/products/presentation/widgets/product_card.dart';

// ══════════════════════════════════════════════════════════════════════
// ARCHITECTURE NOTES
//
// 1. HORIZONTAL SWIPE
//    TabBarView wraps Flutter's PageView internally. All horizontal
//    swipe gestures are consumed by PageView. No manual gesture
//    detection is needed. DefaultTabController keeps TabBar and
//    TabBarView in sync automatically.
//
// 2. VERTICAL SCROLL OWNERSHIP
//    NestedScrollView owns the OUTER scroll (collapses SliverAppBar).
//    Each tab's CustomScrollView owns the INNER scroll (product list).
//    SliverOverlapAbsorber (header) + SliverOverlapInjector (each tab)
//    bridge the two so content never hides under the pinned TabBar.
//    There is exactly ONE vertical scrollable active per tab at any time.
//
// 3. TRADE-OFFS / LIMITATIONS
//    • NestedScrollView does not support iOS stretch overscroll on the
//      inner scroll — a known Flutter engine limitation.
//    • PageStorageKey preserves each tab's scroll offset independently.
//    • The search bar in FlexibleSpaceBar is UI-only here; wire it to
//      a search/filter provider to make it functional.
//    • floating + snap on SliverAppBar means the banner re-appears
//      fully on any upward scroll — intentional Daraz-like behaviour.
// ══════════════════════════════════════════════════════════════════════

class MainListingPage extends ConsumerStatefulWidget {
  const MainListingPage({super.key});

  @override
  ConsumerState<MainListingPage> createState() => _MainListingPageState();
}

class _MainListingPageState extends ConsumerState<MainListingPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(
        body: Center(child: Text('Failed to load categories')),
      ),
      data: (categories) {
        final allTabs = ['All', ...categories.map((c) => c.name)];

        return DefaultTabController(
          length: allTabs.length,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                    sliver: SliverAppBar(
                      pinned: true,
                      floating: true,
                      snap: true,
                      expandedHeight: 160.0,
                      forceElevated: innerBoxIsScrolled,
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      title: const Text(
                        'ZaviMart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                          tooltip: 'Profile',
                          onPressed: () {
                            router.push(AppRoutes.profilePage);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: 'Logout',
                          onPressed: () =>
                              ref.read(authProvider.notifier).logout(),
                        ),
                      ],

                      // ── The collapsible banner area ───────────────────────
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 56,
                          ),
                          child: _SearchBar(controller: _searchController),
                        ),
                      ),
                      bottom: TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        tabAlignment: TabAlignment.start,
                        tabs: allTabs
                            .map(
                              (name) => Tab(
                                text: name[0].toUpperCase() + name.substring(1),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: allTabs.map((tab) {
                  return _CategoryProductList(
                    category: tab == 'All' ? null : tab,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Currently UI-only;
// ─────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Search products...',
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: const Icon(Icons.search, color: Colors.black45),
        suffixIcon: const Icon(Icons.mic_none, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryProductList extends ConsumerWidget {
  final String? category;
  const _CategoryProductList({this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(category));

    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (context) {
          return RefreshIndicator(
            onRefresh: () => ref
                .read(productsProvider(category).notifier)
                .filterByCategory(category),
            child: CustomScrollView(
              key: PageStorageKey<String?>(category),
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),

                productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No products found.')),
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
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(
                            product: products[index],
                            onTap: () {},
                          ),
                          childCount: products.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
