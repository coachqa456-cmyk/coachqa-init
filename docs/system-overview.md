## Quality Assistance Platform – System Overview

### 1. Tech Stack

- **Frontend framework**: React 18 with TypeScript
- **Bundler/Dev server**: Vite
- **Routing**: `react-router-dom` v6
- **UI library**: MUI (`@mui/material`, `@mui/x-charts`, `@mui/x-date-pickers`)
- **Styling**: MUI theming + TailwindCSS (configured, used minimally)
- **Forms & validation**: Formik + Yup (present for pages that need forms)
- **Icons**: Lucide React, Heroicons

The main package metadata and scripts are defined in `package.json`:
- **Scripts**: `dev` (Vite dev server), `build`, `preview`, `lint`
- **Type**: `"module"` (ESM)

### 2. Application Entry & Providers

- **Entry file**: `src/main.tsx`
  - Mounts the React app into the `root` DOM element.
  - Wraps the app with:
    - `BrowserRouter` (React Router v6, with v7 compatibility options)
    - `AuthProvider` (authentication context)
    - `ThemeProvider` (MUI theme + light/dark mode support)

This ensures that routing, auth state, and theming are available throughout the component tree.

### 3. Routing Architecture

- **Root router**: Defined in `src/App.tsx`
- **Public layout & pages** (unauthenticated):
  - Layout: `layouts/PublicLayout`
  - Routes:
    - `/` → marketing/landing (`HomePage`)
    - `/product` → `ProductPage`
    - `/pricing` → `PricingPage`
    - `/docs` → `DocsPage`
    - `/get-demo` → `GetDemoPage`
    - `/login` → `LoginPage`

- **Authenticated layout & pages** (secured under `/dashboard`):
  - Wrapper: `ProtectedRoute` (from `components/auth/ProtectedRoute`)
    - Props: `isAuthenticated`, `redirectPath`, `children`
    - If `isAuthenticated` is false, it redirects to `redirectPath` using `<Navigate>`.
  - Layout: `components/layout/Layout`
    - Renders `Header`, `Sidebar`, and an MUI `Container` where nested `Outlet` routes render.
  - Nested routes under `/dashboard`:
    - Index (`/dashboard`) → `Dashboard`
    - `/dashboard/squads` → `SquadManagement`
    - `/dashboard/users` → `UserManagement`
    - `/dashboard/coaching-tracker` → `CoachingTracker`
    - `/dashboard/quality-scorecard` → `QualityScorecard`
    - `/dashboard/feedback-form` → `FeedbackForm`
    - `/dashboard/maturity-ladder` → `MaturityLadder`
    - `/dashboard/enablement-hub` → `EnablementHub`
    - `/dashboard/impact-timeline` → `ImpactTimeline`
    - `/dashboard/test-logger` → `TestLogger`
    - `/dashboard/test-debt` → `TestDebtRegister`
    - `/dashboard/change-tracker` → `ChangeTracker`
    - `/dashboard/career-framework` → `CareerFramework`

Most of these module pages are lazy-loaded in `App.tsx` using `React.lazy`, all wrapped in a `Suspense` boundary that shows a centered MUI `CircularProgress` while bundles load.

### 4. Authentication & Authorization

- **Auth context**: `src/contexts/AuthContext.tsx`
  - **User model**: `{ id, name, email, role, teams, avatarUrl? }`
  - **Roles**: `admin`, `qe`, `manager`, `developer`, `executive`
  - **Context shape**:
    - `isAuthenticated: boolean`
    - `user: User | null`
    - `loading: boolean`
    - `login(email, password): Promise<void>`
    - `logout(): void`
    - `hasAccess(requiredRoles: string[]): boolean`

- **Auth behavior**:
  - On mount, `AuthProvider` checks `localStorage` for a stored `user` and restores it if present.
  - `login`:
    - Simulates an API call (with a timeout).
    - Looks up the user from a mock `MOCK_USERS` array by email.
    - If found, stores the user in state and `localStorage`, then navigates to a route (currently `/`).
    - If not found, throws an `Error('Invalid credentials')`.
  - `logout`:
    - Clears user from state and `localStorage`, navigates to `/login`.
  - `hasAccess(requiredRoles)`:
    - Returns `true` if the current user’s `role` is in `requiredRoles`.

- **Notes**:
  - Authentication is front-end only and mock-based, suitable for demos and prototypes.
  - For production, this layer should be wired to real APIs, token-based auth, and server-side validation.

### 5. Theming & Design System

- **Theme context**: `src/contexts/ThemeContext.tsx`
  - Exposes:
    - `mode: 'light' | 'dark'`
    - `toggleColorMode()`
  - Uses MUI’s `createTheme` and `ThemeProvider` to set:
    - `palette` with brand colors and `background.default/paper` that change by mode.
    - `typography` scale (Inter/Roboto stack, sized headings).
    - Component overrides for `MuiButton`, `MuiCard`, etc. (radius, shadows, text transforms).
  - `CssBaseline` is applied globally for consistent base styles.

- **Theme usage**:
  - `Header` uses `useTheme()` from `ThemeContext` to access `mode` and `toggleColorMode` for the light/dark toggle button.
  - The layout background uses `background.default` so it respects the current MUI theme.

### 6. Layout & Navigation

- **Layout**: `src/components/layout/Layout.tsx`
  - Manages mobile drawer state (`mobileOpen`).
  - Closes the drawer automatically on route change for better UX.
  - Renders:
    - `Header` (top app bar)
    - `Sidebar` (left drawer)
    - Main content area with `Toolbar` spacer and `Outlet` inside a full-width `Container`.

- **Header**: `src/components/layout/Header.tsx`
  - Shows:
    - Brand logo (`/qa-icon.svg`) and title “Quality Assistance Platform”.
    - Theme toggle (Lucide icons for light/dark).
    - Help icon.
    - Notifications icon+badge with a menu of sample notifications.
    - User avatar button opening a menu with:
      - Basic profile info (name, email, role).
      - “Profile Settings” navigation (to `/profile`) and “Logout”.

- **Sidebar**: `src/components/layout/Sidebar.tsx`
  - Drawer-based navigation with role-based visibility via `hasAccess`.
  - Groups:
    - **Overview**: `Dashboard`
    - **Modules**: core QA modules (Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder, Enablement Hub, Impact Timeline, Exploratory Testing, Test Debt Register, Change Management, Career Framework, Squad Management, User Management).
    - **Administration**: admin-only items (e.g., `/admin/users`).
  - Current route highlighting uses `location.pathname === item.path`.
  - On small screens, the temporary drawer closes after navigation.

### 7. Dashboard Page

- **File**: `src/pages/Dashboard.tsx`
- **Purpose**: High-level overview for logged-in users.
- **Key elements**:
  - Welcome header using the current user’s name.
  - **Key Metrics** cards:
    - Teams coached.
    - Average quality score (with trend indicator).
    - Test debt items.
  - **Coaching Activities** bar chart (MUI X `BarChart`) with sample monthly data.
  - **Recent Activities**:
    - List of recent sample actions (coaching, feedback, maturity updates, test debt additions).
    - Clicking an activity navigates to the relevant module.
  - **Quality Scores by Team**:
    - `PieChart` showing sample quality scores for teams.
  - **Team Maturity Levels**:
    - `BarChart` showing sample maturity levels for teams.
  - **Quick Access**:
    - Grid of cards linking to main modules (icon, color, description).

### 8. Module Pages (High-level)

Each module under `src/pages/*` represents a functional area of the Quality Assistance platform:

- **Coaching Tracker**: Tracks coaching sessions and activities.
- **Quality Scorecard**: Captures & visualizes quality metrics and maturity across squads.
- **Feedback Form**: Collects 360° feedback around quality practices.
- **Maturity Ladder**: Tracks team progression along a quality maturity model.
- **Enablement Hub**: Central place for quality resources, playbooks, and templates.
- **Impact Timeline**: Visualizes improvements and interventions over time.
- **Test Logger (Exploratory Testing)**: Logs exploratory test sessions and findings.
- **Test Debt Register**: Records and prioritizes test-related debt.
- **Change Tracker**: Tracks change initiatives and their quality impacts.
- **Career Framework**: Models QA/quality-focused career paths and skills.
- **Squad Management**: Manages squads/teams and their metadata.
- **User Management**: Manages user accounts and roles.

Most of these are loaded lazily to optimize initial bundle size and perceived performance.

### 9. Notable Design Decisions & Considerations

- **Role-based navigation**:
  - The sidebar uses `hasAccess` from `AuthContext` to control which users see which modules.
  - This is UI-level authorization; back-end enforcement would still be required in a real system.

- **Mock authentication**:
  - Using a static `MOCK_USERS` array simplifies demos and local testing.
  - Swapping to real auth later will mainly affect `AuthContext` and how `ProtectedRoute` decides `isAuthenticated`.

- **Performance & UX**:
  - Lazy-loading major dashboard modules reduces initial load time.
  - The dashboard offers “Quick Access” and “Recent Activities” to shorten navigation paths for common user actions.

### 10. Potential Improvements (Next Steps)

- **Routing & navigation consistency**:
  - Align all navigation links (e.g., Dashboard quick links and sidebar items) with the `/dashboard/...` route structure to avoid dead links.
  - Ensure any links to `/admin/...` have matching routes defined in `App.tsx`.

- **Auth flow**:
  - After `login`, redirect directly to `/dashboard` (or last visited protected route) for a smoother experience.
  - Replace mock users with real API-backed authentication and role management.

- **Docs & developer experience**:
  - Add per-module docs in this `docs` folder (e.g., `coaching-tracker.md`, `quality-scorecard.md`) describing data shapes, UX flows, and integration points.
  - Document how to run, lint, build, and deploy the app in more detail in the root `README.md`.

---

## 📚 Related Documentation

- **[Requirements Analysis](./requirements-analysis.md)** - Comprehensive analysis of requirements vs. current implementation, gap analysis, and implementation recommendations
- **[Requirements: Quality Assistance Tool](../requirements/quality-assistance-tool.md)** - Core problem statement and module definitions
- **[Requirements: Tenant Journey](../requirements/Tenant-Organization-User-Journey-in-CoachQA.md)** - End-to-end tenant organization user journey


