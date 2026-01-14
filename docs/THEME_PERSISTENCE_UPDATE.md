# Theme Persistence Implementation

## Overview

Enhanced the theme system to persist tenant-specific themes in both **localStorage** (for fast loading) and **database** (for permanent storage). Theme changes are now automatically saved and persist across browser refreshes and sessions.

## What Changed

### 1. Enhanced ThemeContext ✅

**File:** `coachqa-ui/src/contexts/ThemeContext.tsx`

#### New Features:
- **localStorage Caching**: Theme configuration cached locally for instant loading
- **Auto-save Mode**: Light/dark mode preference persisted
- **Update Function**: `updateTenantTheme()` saves to both DB and localStorage
- **Loading State**: `isUpdatingTheme` flag for UI feedback
- **Smart Refresh**: Auto-clears cache when switching between tenant/platform routes

#### New Context Properties:
```typescript
{
  // ... existing properties
  updateTenantTheme: (themeConfig, branding?) => Promise<boolean>,
  isUpdatingTheme: boolean
}
```

#### LocalStorage Keys:
- `tenant.themeConfig` - Stores the full theme configuration
- `theme.mode` - Stores light/dark mode preference

### 2. Tenant Settings Page ✅

**File:** `coachqa-ui/src/pages/settings/TenantSettings.tsx`

A comprehensive settings page where tenant admins can:
- **Update theme colors** with live preview
- **Manage company branding** (name, website, logo)
- **See unsaved changes** with visual indicators
- **Save changes** to database and localStorage
- **Reset to saved** configuration
- **Preview logo** with automatic error handling

#### Features:
- ✅ Two-section layout (Branding + Theme)
- ✅ Unsaved changes indicator
- ✅ Save/Reset buttons
- ✅ Loading states
- ✅ Success/error notifications
- ✅ Logo preview with fallback
- ✅ Integrated ThemeCustomizer

### 3. Route Addition ✅

**File:** `coachqa-ui/src/App.tsx`

Added route: `/dashboard/settings` → `TenantSettings` page
- Protected by RoleProtectedRoute
- Lazy-loaded for performance

## How It Works

### Theme Loading Flow

```
1. User authenticates and navigates to tenant dashboard
   ↓
2. ThemeContext initializes:
   - Checks localStorage for cached theme
   - Loads cached theme immediately (instant!)
   ↓
3. ThemeContext fetches fresh theme from API:
   - Makes request to /api/tenants/me/theme
   - Updates localStorage with fresh data
   - Updates UI if theme changed
   ↓
4. Theme applied to all components
```

### Theme Update Flow

```
1. User goes to /dashboard/settings
   ↓
2. User customizes theme colors/branding
   ↓
3. User clicks "Save Changes"
   ↓
4. updateTenantTheme() called:
   - Sends PATCH request to /api/tenants/me
   - Database updated with new theme
   ↓
5. On success:
   - localStorage updated with new theme
   - Context state updated
   - UI re-renders with new theme
   - Success notification shown
   ↓
6. Theme persists across:
   - Page refreshes
   - Browser sessions
   - Different tabs
```

### Persistence Mechanism

#### localStorage (Client-side Cache)
- **Key**: `tenant.themeConfig`
- **Format**: JSON string of ThemeConfig
- **Benefit**: Instant theme loading on page load
- **Lifecycle**: Cleared when switching to platform routes

#### Database (Permanent Storage)
- **Table**: `tenants`
- **Column**: `theme_config` (JSONB)
- **Benefit**: Survives cache clears, available across devices
- **Lifecycle**: Permanent until explicitly changed

#### Mode Persistence
- **Key**: `theme.mode`
- **Values**: `'light'` or `'dark'`
- **Scope**: Per-browser, persists across sessions

## Usage Examples

### In Components

```typescript
import { useTheme } from '../../contexts/ThemeContext';

function MyComponent() {
  const { 
    tenantTheme, 
    updateTenantTheme, 
    isUpdatingTheme,
    refreshTenantTheme 
  } = useTheme();

  const handleSave = async () => {
    const success = await updateTenantTheme(newThemeConfig, {
      logoUrl: 'https://example.com/logo.png',
      companyName: 'Acme Corp'
    });
    
    if (success) {
      console.log('Theme saved!');
    }
  };

  return (
    <div>
      {isUpdatingTheme && <CircularProgress />}
      <button onClick={handleSave}>Save Theme</button>
    </div>
  );
}
```

### Direct localStorage Access

```typescript
// Get cached theme
const cachedTheme = localStorage.getItem('tenant.themeConfig');
const theme = cachedTheme ? JSON.parse(cachedTheme) : null;

// Get mode preference
const mode = localStorage.getItem('theme.mode'); // 'light' or 'dark'

// Clear cache (handled automatically by ThemeContext)
localStorage.removeItem('tenant.themeConfig');
localStorage.removeItem('theme.mode');
```

## Accessing Tenant Settings

### For Tenant Users

1. Log in to your tenant account
2. Navigate to **Dashboard** → **Settings** (or `/dashboard/settings`)
3. Update **Company Branding** section:
   - Company Name
   - Company Website
   - Logo URL
4. Update **Theme Customization** section:
   - Select a template or customize colors
   - Preview changes in real-time
5. Click **"Save Changes"** (theme is saved to DB and localStorage)

### Adding to Navigation

To add the Settings link to your sidebar/navigation:

```typescript
<MenuItem onClick={() => navigate('/dashboard/settings')}>
  <SettingsIcon />
  Settings
</MenuItem>
```

## API Integration

The settings page uses these API calls:

```typescript
// GET current tenant (includes theme and branding)
GET /api/tenants/me
Response: {
  id, name, slug,
  themeConfig, logoUrl, companyName, companyWebsite
}

// GET theme only (faster, used by ThemeContext)
GET /api/tenants/me/theme
Response: {
  themeConfig, logoUrl, companyName, companyWebsite
}

// PATCH update tenant (saves theme and branding)
PATCH /api/tenants/me
Body: {
  themeConfig?: ThemeConfig,
  logoUrl?: string,
  companyName?: string,
  companyWebsite?: string
}
```

## Benefits

### Performance
- **Instant Load**: Cached theme loads immediately (no API wait)
- **Optimistic Updates**: UI updates before API response
- **Reduced API Calls**: Only fetches when needed

### User Experience
- **No Flash**: Theme applied instantly on page load
- **Persistent Preferences**: Mode (light/dark) remembered
- **Cross-Session**: Works across different browser tabs
- **Offline-Ready**: Cached theme works even if API is slow

### Developer Experience
- **Type-Safe**: Full TypeScript support
- **React Hooks**: Easy to use with `useTheme()`
- **Automatic**: Cache management handled by context
- **Debugging**: Console logs for theme operations

## Cache Management

### Automatic Cache Updates

The cache is automatically updated when:
- ✅ User saves theme in settings page
- ✅ Theme is fetched from API
- ✅ User logs out (cache is cleared)
- ✅ User switches to platform admin routes

### Manual Cache Refresh

```typescript
const { refreshTenantTheme } = useTheme();

// Manually refresh from API
await refreshTenantTheme();
```

## Testing

### Test Theme Persistence

1. **Update Theme:**
   - Go to `/dashboard/settings`
   - Change theme colors
   - Save changes
   - Verify success notification

2. **Test Page Refresh:**
   - Refresh the page (F5)
   - Theme should load instantly
   - Colors should be preserved

3. **Test New Tab:**
   - Open new tab
   - Navigate to dashboard
   - Theme should match

4. **Test Browser Restart:**
   - Close browser completely
   - Reopen and log in
   - Theme should be restored

5. **Test Cache Clear:**
   - Open DevTools → Application → Storage
   - Clear `tenant.themeConfig` from localStorage
   - Refresh page
   - Theme should be fetched from API and re-cached

### Developer Testing

```javascript
// Console testing (in browser DevTools)

// Check cached theme
console.log(JSON.parse(localStorage.getItem('tenant.themeConfig')));

// Check mode
console.log(localStorage.getItem('theme.mode'));

// Clear cache
localStorage.clear();

// Test theme context
const { tenantTheme, updateTenantTheme } = useTheme();
console.log('Current theme:', tenantTheme);
```

## Troubleshooting

### Theme Not Persisting

1. **Check localStorage:**
   - Open DevTools → Application → Local Storage
   - Look for `tenant.themeConfig` and `theme.mode`
   - If missing, cache might be disabled

2. **Check API Response:**
   - Open DevTools → Network
   - Look for `/api/tenants/me/theme` request
   - Verify response contains `themeConfig`

3. **Check Context:**
   - Add `console.log` in ThemeContext
   - Verify `updateTenantTheme` is being called
   - Check for errors in console

### Theme Loads Slowly

1. **Clear Cache:**
   - localStorage might be corrupted
   - Clear and let it rebuild

2. **Check API Performance:**
   - Network tab shows request timing
   - Backend might be slow

3. **Verify Cache Hit:**
   - Theme should load before API response
   - If not, localStorage might not be working

### Colors Look Different After Refresh

1. **Check Cache Consistency:**
   - Compare localStorage theme with API response
   - They should match

2. **Verify Save Operation:**
   - Ensure save completed successfully
   - Check database directly

## Security Considerations

- ✅ localStorage is origin-specific (isolated per domain)
- ✅ Theme data is not sensitive (safe to cache)
- ✅ API authentication required for updates
- ✅ Validation on backend prevents malicious themes
- ✅ Cache cleared on logout

## Browser Compatibility

- ✅ Chrome/Edge: Full support
- ✅ Firefox: Full support
- ✅ Safari: Full support
- ✅ Mobile browsers: Full support
- ⚠️ Incognito/Private: Cache cleared on close (expected)

## Future Enhancements

Potential improvements:
- [ ] IndexedDB for larger theme assets
- [ ] Service Worker for offline theme management
- [ ] Theme versioning and rollback
- [ ] Multi-device sync via WebSocket
- [ ] Theme A/B testing

## Files Modified

1. `coachqa-ui/src/contexts/ThemeContext.tsx` - Enhanced with persistence
2. `coachqa-ui/src/pages/settings/TenantSettings.tsx` - New settings page
3. `coachqa-ui/src/App.tsx` - Added settings route

## Summary

The theme system now provides:
- ⚡ **Instant loading** via localStorage cache
- 💾 **Permanent storage** in database
- 🔄 **Auto-sync** between cache and DB
- 🎨 **Live editing** via settings page
- 🔐 **Secure** with proper authentication
- 📱 **Cross-session** persistence

Users can now customize their theme once and have it persist forever, across all sessions, browsers, and devices!

---

**Version:** 2.0  
**Date:** January 4, 2026  
**Author:** CoachQA Development Team






