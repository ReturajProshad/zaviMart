# ZaviMart — Flutter Task Submission

A Daraz-style product listing app built with Flutter + Riverpod, consuming the [Fake Store API](https://fakestoreapi.com/).

---

## Getting Started
### Environment
Implemented with:
```
Flutter 3.38.1 • channel stable
Dart 3.10.0
```

#### setup
```bash
git clone https://github.com/ReturajProshad/zaviMart.git
cd zaviMart
flutter pub get
flutter run
```

**Login credentials** (hint shown on login screen):
- Username: `mor_2314`
- Password: `83r5^_`

---

## Features

- JWT-authenticated login via Fake Store API
- Collapsible header with search bar + sticky tab bar
- Product listing by category in a 2-column grid
- Pull-to-refresh per tab
- User profile screen fetched from the API
- Persistent session via Flutter Secure Storage

---

## Architecture

The project follows **Clean Architecture** with a feature-first folder structure.

```
lib/
├── core/              # Network, routing, services, shared providers
└── features/
    ├── auth/          # Login, session management
    ├── products/      # Product & category listing
    └── profile/       # User profile
```

Each feature is split into three layers:

| Layer | Responsibility |
|---|---|
| `domain` | Entities, repository contracts, use cases |
| `data` | API models, repository implementations, remote data sources |
| `presentation` | Riverpod providers/notifiers, views, widgets |

State is managed exclusively with **Riverpod** (`AsyncNotifierProvider`, `AsyncNotifierProvider.family`). No `setState` is used for business logic.

---

## Scroll Architecture (The Core Problem)

> This is not a UI task — it is a scroll-architecture and gesture-coordination problem.

### 1. How Horizontal Swipe Was Implemented

Tabs are switchable by both **tap** and **horizontal swipe** using Flutter's `DefaultTabController` + `TabBarView`.

`TabBarView` wraps a `PageView` internally. This means:
- All horizontal swipe gestures are natively consumed by `PageView`
- `DefaultTabController` keeps `TabBar` and `TabBarView` in sync automatically
- No manual `GestureDetector` or custom gesture handling is needed
- Horizontal swipe never bleeds into or triggers vertical scrolling

### 2. Who Owns the Vertical Scroll and Why

There is **exactly one vertical scrollable** active at any time. Ownership is split deliberately:

| Scrollable | Owns |
|---|---|
| `NestedScrollView` | The **outer** scroll — collapses/expands the `SliverAppBar` |
| Each tab's `CustomScrollView` | The **inner** scroll — scrolls the product grid within that tab |

`SliverOverlapAbsorber` (in the header builder) and `SliverOverlapInjector` (inside each tab) act as a bridge between the two scrollables. This ensures product content is never hidden behind the pinned `TabBar` and that the single-scroll contract is maintained.

Each tab's `CustomScrollView` uses a `PageStorageKey` to independently preserve its scroll offset. Switching tabs does not reset or jump scroll positions.

### 3. Trade-offs and Limitations

| Trade-off | Detail |
|---|---|
| No iOS stretch overscroll on inner scroll | A known Flutter engine limitation — `NestedScrollView`'s inner `CustomScrollView` cannot rubber-band on iOS. This can be resolved by replacing `NestedScrollView` with `NestedScrollViewPlus` from the `nested_scroll_view_plus` package, using `SliverOverlapAbsorberPlus` and `SliverOverlapInjectorPlus` as drop-in replacements |
| `floating + snap` on `SliverAppBar` | The banner re-appears fully on any upward scroll (intentional Daraz-like behaviour). Removing `snap` gives a more subtle feel if preferred |
| Search bar is UI-only | The `_SearchBar` widget captures input but is not wired to a filter provider. Connecting it requires debouncing and passing the query to `productsProvider` |
| `productsProvider.family` per category | Each category tab gets its own notifier instance. This keeps state isolated but means each tab makes its own network request on first load |
| Layout optimized for mobile portrait | Tablet/adaptive layouts were intentionally not implemented, as the focus of this task is scroll architecture and gesture coordination |

### 4. Why `AsyncNotifierProvider.family` for Tab State

Each tab's product list is powered by `productsProvider(category)` — a **family provider** keyed by the category string.

This means:
- Every tab owns its **own independent `AsyncNotifier` instance** and its own `AsyncValue<List<Product>>` state
- Once a tab loads its data, Riverpod **caches that state** for the lifetime of the provider. Switching away from a tab and back does not re-trigger a network request — the data is already there
- A loading or error state in one tab has **zero effect** on any other tab
- Pull-to-refresh (`filterByCategory`) only re-fetches the **current tab**, not all tabs
- The `All` tab uses `productsProvider(null)` as its key, keeping it cleanly separated from category-specific tabs

This approach eliminates redundant API calls while keeping each tab's scroll position, loading state, and data fully isolated from one another.

---

## API

All requests go through a `Dio`-based `ApiClient` with a custom pretty-print interceptor.

| Endpoint | Used for |
|---|---|
| `POST /auth/login` | Authenticate and receive JWT token |
| `GET /products` | Fetch all products |
| `GET /products/category/{name}` | Fetch products by category |
| `GET /products/categories` | Fetch category list for tab bar |
| `GET /users/{id}` | Fetch logged-in user's profile |

The JWT token is stored in **Flutter Secure Storage** (AES encrypted on Android, Keychain on iOS). On app start, the session is restored by checking whether a valid token exists — no re-login required.

---

## Dependencies

```yaml
flutter_riverpod          # State management
dio                       # HTTP client
go_router                 # Declarative routing
flutter_secure_storage    # Encrypted token persistence
cached_network_image      # Efficient network image loading with caching
dartz                     # Functional Either type for error handling
equatable                 # Value equality for domain entities
```
