# EnergyMedia Content Manager - AI Coding Agent Instructions

## Project Overview
**EnergyMedia Content Manager** is a Flutter web application for managing multimedia content (videos, posters, categories) for the EnergyMedia platform. Single-organization focused system with video upload, categorization, playback, and analytics dashboard.

**Tech Stack:** Flutter 3.1.4+, Supabase (backend/auth/storage), Provider (state), GoRouter (navigation), PlutoGrid (tables), Video Players (appinio_video_player/video_player)

## Architecture & Key Patterns

### Dual Supabase Clients
- `supabase` (default): Standard auth schema (`public.users`) for authentication ONLY
- `supabaseML`: Custom `media_library` schema for all media content management
- **Critical:** Always use `supabaseML` for media data, `supabase` for auth only
- **Organization Filter:** ALL queries to `media_files` MUST filter by `organization_fk = 17`
- See [lib/main.dart](lib/main.dart#L35) and [lib/helpers/globals.dart](lib/helpers/globals.dart)

### State Management (Provider)
All providers declared in [lib/main.dart](lib/main.dart):
- `UserState`: Auth state and current user
- `VisualStateProvider`: Theme/visual preferences (light/dark mode)
- `VideosProvider`: Media files CRUD, upload/download, metadata management
- **Pattern:** Use `context.read<T>()` for one-time actions, `context.watch<T>()` for reactive UI

### Navigation Structure
```
/login → /dashboard (stats: reproducciones, videos, categorías)
         └── Sidemenu:
             ├── Dashboard (default)
             ├── Gestor de Videos (PlutoGrid con CRUD)
             └── Configuración (placeholder - work in progress)
```
- **Simplified:** No empresa/negocio selection - single organization (EnergyMedia)
- See [lib/router/router.dart](lib/router/router.dart)

## Database Schema & Critical Rules

### Media Library Schema (`media_library`)
**Tables:**
- `media_files`: Main video records (file_name, title, file_url, storage_path, metadata_json, media_category_fk, organization_fk)
- `media_categories`: Video categories (category_name, category_description)
- `media_posters`: Poster/thumbnail associations (media_file_id, poster_file_id)
- View: `vw_media_files_with_posters` - Complete media info with category and poster

### Organization Filter Rule
**CRITICAL:** ALL operations on `media_files` MUST include `organization_fk = 17` filter:
```dart
// CORRECT - filtered by organization
final response = await supabaseML
  .from('media_files')
  .select()
  .eq('organization_fk', 17);

// WRONG - missing organization filter
final response = await supabaseML
  .from('media_files') // ❌ Returns all organizations!
  .select();
```
**Always:** Insert/update operations must set `organization_fk: 17`

### metadata_json Structure
Standard fields in `media_files.metadata_json`:
```json
{
  "uploaded_at": "2026-01-10T10:30:00Z",
  "reproducciones": 150,
  "categorias": ["tutorial", "energía"],
  "original_file_name": "video_original.mp4",
  "duration_seconds": 320,
  "resolution": "1920x1080",
  "last_viewed_at": "2026-01-10T12:00:00Z"
}
```

### Supabase Storage
**Bucket:** `energymedia`
- `energymedia/videos/` - Video files
- `energymedia/imagenes/` - Poster/thumbnail images

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
- `supabaseML`: Media Library-specific Supabase client (schema: `media_library`)
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

### Querying Media Data
```dart
// CORRECT - uses media_library schema + organization filter
final response = await supabaseML
  .from('media_files')
  .select()
  .eq('organization_fk', 17)
  .order('created_at_timestamp', ascending: false);

// WRONG - uses default schema
final response = await supabase
  .from('media_files') // ❌ Table not found!
  .select();

// WRONG - missing organization filter
final response = await supabaseML
  .from('media_files')
  .select(); // ❌ Returns data from ALL organizations!
```

### Uploading Media Files
```dart
// 1. Upload video to storage
final videoPath = await supabaseML.storage
  .from('energymedia')
  .upload('videos/$fileName', videoBytes);

// 2. Insert record with organization filter
await supabaseML.from('media_files').insert({
  'file_name': fileName,
  'title': title,
  'file_url': publicUrl,
  'storage_path': 'videos/$fileName',
  'organization_fk': 17, // ⚠️ REQUIRED!
  'metadata_json': {
    'uploaded_at': DateTime.now().toIso8601String(),
    'reproducciones': 0,
    'original_file_name': originalName,
  }
});
```

### Working with Video Thumbnails
```dart
// Generate thumbnail from video (VideoScreenThumbnail widget)
VideoScreenThumbnail(video: videoUrl)

// Display poster from media_posters
Image.network(posterUrl, fit: BoxFit.cover)

// Fallback: Show placeholder if no poster
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
- Check browser console for Supabase RPC errors
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
