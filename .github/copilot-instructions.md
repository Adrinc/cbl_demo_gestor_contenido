# EnergyMedia Content Manager - AI Coding Agent Instructions

## Project Overview
**EnergyMedia Content Manager** is a Flutter web application for managing multimedia content (videos, posters, categories) for the EnergyMedia platform. Single-organization focused system with video upload, categorization, playback, and analytics dashboard.

**Tech Stack:** Flutter 3.1.4+, Provider (state), GoRouter (navigation), PlutoGrid (tables), Video Players (appinio_video_player/video_player)

**DEMO MODE:** This is a 100% offline demo with hardcoded data from `assets/videos/*.mp4`. No database or external APIs required.

## Architecture & Key Patterns

### Demo Mode Architecture
- ✅ **100% Offline:** No Supabase, no backend, no database
- ✅ **Hardcoded Videos:** 9 videos loaded from `assets/videos/` with real durations and file sizes
- ✅ **In-Memory Operations:** Upload, edit, delete work locally (changes lost on reload)
- ✅ **Real Video Loading:** Uses VideoPlayerController to capture actual duration and size
- ✅ **Async Initialization:** Videos load asynchronously on app start

### State Management (Provider)
All providers declared in [lib/main.dart](lib/main.dart):
- `UserState`: Mock auth state (no real authentication)
- `VisualStateProvider`: Theme/visual preferences (light/dark mode)
- `VideosProvider`: **Core demo provider** - manages all video data in memory
- **Pattern:** Use `context.read<T>()` for one-time actions, `context.watch<T>()` for reactive UI

### VideosProvider Initialization Flow
**CRITICAL:** The provider uses an async initialization pattern that UI widgets MUST respect:

```dart
// VideosProvider flags
bool isLoading = false;        // True during data loading
bool isInitialized = false;    // ✅ True when initial load completes

// Initialization sequence
constructor() 
  → postFrameCallback 
  → _initializeHardcodedData() 
  → load 9 videos from assets
  → isInitialized = true + notifyListeners()
  → Second notifyListeners() in postFrameCallback (ensures UI updates)
```

**Widgets MUST wait for initialization:**
```dart
// ✅ CORRECT - Wait for isInitialized
Future<void> loadData() async {
  final provider = context.read<VideosProvider>();
  
  while (!provider.isInitialized && mounted) {
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  // Now safe to use provider data
  final stats = await provider.getDashboardStats();
}

// ❌ WRONG - Don't check only isLoading
if (!provider.isLoading) {
  // Provider might not have data yet!
}
```

**Why this matters:**
- Dashboard widgets render immediately but provider loads async
- Without waiting for `isInitialized`, widgets show 0/empty data
- User must manually refresh to see data (bad UX)
- Solution: All data-dependent widgets check `isInitialized` before loading

### Navigation Structure
```
/login (mock auth) → /dashboard (stats: reproducciones, videos, categorías)
                     └── Sidemenu:
                         ├── Dashboard (default) - Shows stats + top 5 videos
                         ├── Gestor de Videos (PlutoGrid con CRUD)
                         └── Configuración (placeholder - work in progress)
```
- **Demo Mode:** Login bypassed with mock user, logout clears local state only
- **Single Organization:** No empresa/negocio selection needed
- See [lib/router/router.dart](lib/router/router.dart)

## Demo Data Structure

### Hardcoded Videos (assets/videos/)
9 MP4 files with complete metadata loaded on app start:
1. `black_friday_spot.mp4` - 1,250 views
2. `disney_on_ice_lets_dance.mp4` - 3,420 views
3. `green_screen.mp4` - 890 views
4. `healthtest.mp4` - 567 views
5. `hisp_heritage.mp4` - 2,100 views
6. `kimball_holiday.mp4` - 1,840 views
7. `Lost_Medicaid.mp4` - 456 views
8. `Metallic_phone.mp4` - 5,230 views (most viewed)
9. `sweetwater_authority.mp4` - 720 views

**Total Statistics:**
- Total Videos: 9
- Total Reproducciones: 16,473
- Promedio/Día: 549 (calculated from video age)

### Video Loading Process
Each video loads asynchronously with 3-second timeout:
```dart
// Real data capture
VideoPlayerController.asset(path)
  .initialize()
  .timeout(Duration(seconds: 3))

// Captures:
- Real duration (in seconds)
- File size (from bytes)

// Fallback if timeout:
- Simulated realistic durations (30-120s)
- Estimated file sizes based on duration
```

### metadata_json Structure
Standard fields in each video's metadata:
```json
{
  "uploaded_at": "2026-01-10T10:30:00Z",
  "reproducciones": 1250,
  "original_file_name": "video_original.mp4",
  "duration_seconds": 30,
  "file_size_bytes": 15000000,
  "tags": ["promoción", "ventas"]
}
```

## Responsive Design Standards
**Breakpoints:** Mobile ≤800px, Tablet 801-1200px, Desktop >1200px

**Common pattern:**
```dart
final isMobile = MediaQuery.of(context).size.width <= 800;
// Desktop: PlutoGrid tables with video thumbnails
// Mobile: Card-based lists with posters
```

**Key files:**
- Desktop layouts: `lib/pages/videos/*_page.dart`
- Mobile adaptations: Check for conditional rendering in same files
- Reference constant: `mobileSize = 800` in [lib/helpers/constants.dart](lib/helpers/constants.dart#L22)

## Critical Files & Workflows

### Global State (`lib/helpers/globals.dart`)
- `currentUser`: Authenticated user model (nullable)
- `plutoGridScrollbarConfig()`, `plutoGridStyleConfig()`: Consistent table styling
- **Always check `currentUser != null` before auth-dependent operations**

### Models (Domain-Driven)
- Media models: `lib/models/media/*.dart`
- Pattern: `fromMap()` for Supabase JSON deserialization
- Key models: `MediaFileModel`, `MediaCategoryModel`, `MediaPosterModel`

### Video Players
**Libraries:** `appinio_video_player`, `video_player`, `chewie`
**Usage patterns:**
- `VideoPlayerLive`: Full-screen player with controls (chewie-based)
- `VideoScreenNew`: Embedded player (appinio-based)
- `VideoScreenThumbnail`: Generate thumbnails from video
- See [lib/pages/widgets/video_player_*.dart](lib/pages/widgets/)

### Theme & Styling
**Color Scheme (EnergyMedia):**
- **Primary Gradient:** Cyan→Yellow (linear-gradient(135deg, #4EC9F5, #FFB733))
- **Accents:** Purple (#6B2F8A), Cyan (#4EC9F5), Yellow (#FFB733), Red (#FF2D2D), Orange (#FF7A3D)
- **Dark Mode Backgrounds:** #0B0B0D (main), #121214 (surface1), #1A1A1D (surface2)
- **Light Mode Backgrounds:** #FFFFFF (main), #F7F7F7 (surface1), #EFEFEF (surface2)
- **Typography:** Google Fonts Poppins (Regular 400, Bold 700)
- Use `AppTheme.of(context)` for colors, not hardcoded values
- See [lib/theme/theme.dart](lib/theme/theme.dart)

## Development Commands
```bash
# Run (web dev)
flutter run -d chrome

# Build web (production)
flutter build web

# Dependencies
flutter pub get

# Clean build
flutter clean && flutter pub get
```

## Common Tasks

### Adding New Provider
1. Create in `lib/providers/`
2. Extend `ChangeNotifier`
3. Register in [lib/main.dart](lib/main.dart) `MultiProvider.providers`
4. Export in `lib/providers/providers.dart` if needed

### Creating Responsive Pages
1. Check screen width: `MediaQuery.of(context).size.width`
2. Desktop: Use PlutoGrid for tables, full layouts
3. Mobile: Use ListView with Cards, simplified forms
4. Reference [lib/pages/videos/gestor_videos_page.dart](lib/pages/videos/gestor_videos_page.dart) for pattern

### Working with Demo Data
```dart
// ✅ CORRECT - Wait for provider initialization
Future<void> loadData() async {
  final provider = context.read<VideosProvider>();
  
  // Wait for initial data load
  while (!provider.isInitialized && mounted) {
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  // Now safe to access data
  final videos = provider.mediaFiles;
  final stats = await provider.getDashboardStats();
}

// ❌ WRONG - Access data immediately
final videos = context.read<VideosProvider>().mediaFiles; // Empty list!
```

### Uploading Media Files (Demo Mode)
```dart
// Demo mode: Creates in-memory video with real duration
await videosProvider.uploadVideo(
  title: 'Mi Video',
  description: 'Descripción',
  tags: ['tag1', 'tag2'],
);

// The video is added to mediaFiles list locally
// Changes are NOT persisted (lost on reload)
```

### Working with Video Thumbnails
```dart
// Generate thumbnail from video (VideoScreenThumbnail widget)
VideoScreenThumbnail(video: videoUrl)

// Display poster from metadata
final posterUrl = video.metadataJson?['poster_url'];
if (posterUrl != null) 
  Image.network(posterUrl)
else 
  Icon(Icons.video_library, size: 48)
```

## Project Conventions

### Naming
- Files: `snake_case.dart` (e.g., `videos_provider.dart`)
- Classes: `PascalCase` (e.g., `VideosProvider`)
- Private members: `_underscorePrefixed` (e.g., `_selectedVideo`)
- Models suffix: `*Model` (e.g., `MediaFileModel`)

### File Organization
```
lib/
  pages/          # Full pages
    videos/       # Video management pages
      gestor_videos_page.dart
      dashboard_page.dart
      widgets/    # Video-specific widgets
    widgets/      # Shared widgets (video players, etc.)
  providers/      # State management
    videos_provider.dart
  models/         # Data models
    media/        # Media domain models
  helpers/        # Utilities, globals, extensions
  services/       # External service integrations
```

### Import Style
- Absolute imports: `import 'package:energy_media/...'`
- Barrel exports: Use `lib/models/models.dart`, `lib/providers/providers.dart`

## Testing & Debugging
- **No formal tests yet** - manual testing in browser/device
- Dev mode: Hot reload enabled (Flutter devtools)
- Check browser console for video loading errors
- Useful: Flutter Inspector for widget tree debugging

## Key Reference Documents
- [assets/referencia/tablas_energymedia.txt](assets/referencia/tablas_energymedia.txt): Database schema reference
- [pubspec.yaml](pubspec.yaml): All dependencies and versions
- [lib/helpers/constants.dart](lib/helpers/constants.dart): Environment config, API keys, constants
- GitHub repo: https://github.com/CB-Luna/energymedia_content_manager

## Known Quirks
- PlutoGrid requires `dependency_override` for `intl: ^0.19.0` compatibility
- Always call `initGlobals()` in main before app initialization
- GoRouter `optionURLReflectsImperativeAPIs` must be `true` for proper routing
- Mobile forms use full-screen modals, not dialogs (better UX on small screens)
- Video thumbnails: Use `VideoScreenThumbnail` widget or fallback to category/poster image
- **CRITICAL:** Dashboard and data-dependent widgets MUST wait for `VideosProvider.isInitialized` before loading data to avoid showing 0/empty state
