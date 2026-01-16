# Tenant-Specific Theme Configuration

## Overview

The QEnabler platform now supports tenant-specific theme configuration, allowing each tenant to customize their branding and color scheme during the onboarding process. This feature enables white-labeling and better brand alignment for each organization using the platform.

## Features

### 1. Customizable Theme Elements

Each tenant can customize:
- **Primary Colors** (light, main, dark)
- **Secondary Colors** (light, main, dark)
- **Status Colors** (success, error, warning, info)
- **Company Logo URL**
- **Company Name**
- **Company Website**

### 2. Pre-built Theme Templates

Five pre-defined theme templates are available:
- **Default (Blue)** - Blue primary with teal secondary
- **Purple** - Purple primary with pink secondary
- **Green** - Green primary with teal secondary
- **Orange** - Orange primary with yellow secondary
- **Red** - Red primary with orange secondary

### 3. Advanced Customization

Users can choose a template as a starting point and then fine-tune individual colors using the advanced color picker.

## Database Schema

### Migration: `016-add-tenant-theme-config.sql`

Added the following columns to the `tenants` table:

```sql
- theme_config (JSONB) - JSON configuration for theme colors
- logo_url (VARCHAR) - URL to tenant logo
- company_name (VARCHAR) - Official company name
- company_website (VARCHAR) - Company website URL
```

**To apply the migration:**

```bash
cd QEnabler-backend
psql -U your_username -d your_database -f migrations/016-add-tenant-theme-config.sql
```

## Backend Implementation

### Model Updates

**File:** `QEnabler-backend/src/models/Tenant.ts`

Added `ThemeConfig` interface and new fields:

```typescript
export interface ThemeConfig {
  primary: { main: string; light: string; dark: string; };
  secondary: { main: string; light: string; dark: string; };
  error: { main: string; };
  warning: { main: string; };
  info: { main: string; };
  success: { main: string; };
}
```

### API Endpoints

#### Platform Admin Endpoints

**Create Tenant with Theme:**
```
POST /api/platform-admin/tenants
Body: {
  name: string,
  slug: string,
  themeConfig?: ThemeConfig,
  logoUrl?: string,
  companyName?: string,
  companyWebsite?: string
}
```

**Update Tenant Theme:**
```
PUT /api/platform-admin/tenants/:id
Body: {
  name?: string,
  slug?: string,
  themeConfig?: ThemeConfig,
  logoUrl?: string,
  companyName?: string,
  companyWebsite?: string
}
```

#### Tenant Endpoints

**Get Current Tenant (includes theme):**
```
GET /api/tenants/me
Response: {
  success: true,
  data: {
    id: string,
    name: string,
    slug: string,
    themeConfig: ThemeConfig,
    logoUrl: string,
    companyName: string,
    companyWebsite: string
  }
}
```

**Get Tenant Theme Only:**
```
GET /api/tenants/me/theme
Response: {
  success: true,
  data: {
    themeConfig: ThemeConfig,
    logoUrl: string,
    companyName: string,
    companyWebsite: string
  }
}
```

**Update Tenant Theme:**
```
PATCH /api/tenants/me
Body: {
  themeConfig?: ThemeConfig,
  logoUrl?: string,
  companyName?: string,
  companyWebsite?: string
}
```

## Frontend Implementation

### Theme Context

**File:** `QEnabler-ui/src/contexts/ThemeContext.tsx`

The `ThemeContext` has been enhanced to:
1. Fetch tenant-specific theme configuration
2. Apply custom theme colors dynamically
3. Provide theme refresh functionality

**Usage in Components:**

```typescript
import { useTheme } from '../../contexts/ThemeContext';

const MyComponent = () => {
  const { mode, themeType, tenantTheme, refreshTenantTheme } = useTheme();
  
  // tenantTheme contains the custom ThemeConfig or null
  // refreshTenantTheme() can be called to reload theme
};
```

### Theme Components

#### ThemePreview Component

**File:** `QEnabler-ui/src/components/theme/ThemePreview.tsx`

Displays a visual preview of the theme configuration showing:
- Primary and secondary color swatches
- Sample buttons
- Status color chips

**Usage:**

```typescript
import { ThemePreview } from '../../components/theme/ThemePreview';

<ThemePreview 
  themeConfig={themeConfig} 
  companyName="Acme Corp" 
/>
```

#### ThemeCustomizer Component

**File:** `QEnabler-ui/src/components/theme/ThemeCustomizer.tsx`

Interactive theme customization UI featuring:
- Template selector dropdown
- Live theme preview
- Advanced color customization accordion
- Color pickers for all theme colors

**Usage:**

```typescript
import { ThemeCustomizer } from '../../components/theme/ThemeCustomizer';

<ThemeCustomizer
  themeConfig={themeConfig}
  onChange={(config) => setThemeConfig(config)}
  companyName="Acme Corp"
/>
```

### Tenant Creation Flow

**File:** `QEnabler-ui/src/pages/platform-admin/TenantManagement.tsx`

The tenant creation dialog now has two tabs:

1. **Basic Information Tab**
   - Tenant name and slug
   - Admin user details
   - Company information (optional)

2. **Theme & Branding Tab**
   - Theme template selection
   - Color customization
   - Live preview

## Usage Guide

### For Platform Administrators

#### Creating a Tenant with Custom Theme

1. Navigate to **Platform Admin** → **Tenant Management**
2. Click **"New Tenant"**
3. Fill in the **Basic Information** tab:
   - Tenant name and slug
   - Admin user credentials
   - Company information (optional)
4. Click **"Next: Theme & Branding"**
5. Choose a theme template or customize colors
6. Preview the theme in real-time
7. Click **"Create Tenant & Admin"**

#### Updating Tenant Theme

1. Go to **Tenant Management**
2. Click the **Edit** icon for a tenant
3. Modify theme settings
4. Save changes

### For Tenant Administrators

Tenant admins can update their theme through the tenant settings page (if implemented):

```typescript
import { updateCurrentTenant } from '../../utils/api';

const updateTheme = async (themeConfig: ThemeConfig) => {
  const response = await updateCurrentTenant({ themeConfig });
  if (response.ok) {
    // Theme updated successfully
    // Refresh the theme context
    refreshTenantTheme();
  }
};
```

## How It Works

### Theme Loading Flow

1. **User authenticates** and accesses the tenant dashboard
2. **ThemeContext** detects the route is a tenant route (not admin)
3. **API call** is made to `/api/tenants/me/theme`
4. **Theme configuration** is fetched and stored in context
5. **Material-UI theme** is regenerated with custom colors
6. **UI re-renders** with the new theme

### Theme Fallback

If a tenant doesn't have a custom theme configured:
- Default blue/teal theme is used
- No errors are thrown
- Theme can be configured later

### Platform Admin Theme

Platform admin routes (`/admin/*`) always use the purple/indigo theme regardless of tenant settings.

## Color Format

All colors must be in HEX format:
- ✅ Valid: `#3B82F6`, `#10B981`
- ❌ Invalid: `rgb(59, 130, 246)`, `blue`

## Best Practices

### Color Selection

1. **Contrast**: Ensure sufficient contrast between text and background
2. **Accessibility**: Test colors with accessibility tools
3. **Brand Consistency**: Use colors from company brand guidelines
4. **Light/Dark Variants**: Provide appropriate light and dark shades

### Performance

- Theme configuration is cached in context
- Only fetched once per session
- Minimal re-renders due to useMemo optimization

### Security

- Theme configurations are validated on the backend
- Only authenticated users can access theme endpoints
- Platform admins can manage any tenant's theme

## Testing

### Manual Testing

1. Create a new tenant with custom theme
2. Log in as tenant user
3. Verify custom colors are applied
4. Test dark mode (if implemented)
5. Check all UI components render correctly

### Database Testing

```sql
-- View tenant theme configuration
SELECT id, name, slug, theme_config, logo_url, company_name 
FROM tenants 
WHERE slug = 'your-tenant-slug';

-- Update theme manually
UPDATE tenants 
SET theme_config = '{
  "primary": {"main": "#FF5722", "light": "#FF7043", "dark": "#E64A19"}
}'::jsonb
WHERE slug = 'your-tenant-slug';
```

## Troubleshooting

### Theme Not Applied

1. Check browser console for API errors
2. Verify user is authenticated
3. Ensure tenant has theme configuration in database
4. Try refreshing the page
5. Clear browser cache

### Colors Look Wrong

1. Verify HEX color format
2. Check if light/dark variants are appropriate
3. Test in different browsers
4. Validate contrast ratios

### Migration Issues

```bash
# Check if migration was applied
psql -U your_username -d your_database -c "\d tenants"

# Look for theme_config, logo_url columns

# If missing, run migration manually
psql -U your_username -d your_database -f migrations/016-add-tenant-theme-config.sql
```

## Future Enhancements

Potential future improvements:
- [ ] Font family customization
- [ ] Dark mode color schemes
- [ ] Logo upload functionality
- [ ] Theme export/import
- [ ] Preview mode before saving
- [ ] Theme history/versioning
- [ ] CSS custom properties injection
- [ ] Tenant settings page for theme management

## Related Files

### Backend
- `QEnabler-backend/migrations/016-add-tenant-theme-config.sql`
- `QEnabler-backend/src/models/Tenant.ts`
- `QEnabler-backend/src/controllers/platformAdmin.controller.ts`
- `QEnabler-backend/src/controllers/tenant.controller.ts`
- `QEnabler-backend/src/routes/tenant.routes.ts`

### Frontend
- `QEnabler-ui/src/contexts/ThemeContext.tsx`
- `QEnabler-ui/src/components/theme/ThemePreview.tsx`
- `QEnabler-ui/src/components/theme/ThemeCustomizer.tsx`
- `QEnabler-ui/src/pages/platform-admin/TenantManagement.tsx`
- `QEnabler-ui/src/utils/api.ts`

## Support

For issues or questions:
1. Check this documentation
2. Review the code comments
3. Check browser console for errors
4. Contact the development team

---

**Version:** 1.0  
**Last Updated:** January 4, 2026  
**Author:** QEnabler Development Team






