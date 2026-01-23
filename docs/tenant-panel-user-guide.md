# Tenant Panel User Guide

## Table of Contents

1. [Introduction & Getting Started](#1-introduction--getting-started)
2. [Authentication & Login Flow](#2-authentication--login-flow)
3. [Onboarding Experience](#3-onboarding-experience)
4. [Navigation & Layout](#4-navigation--layout)
5. [Dashboard Overview](#5-dashboard-overview)
6. [Core Modules & Features](#6-core-modules--features)
7. [Settings & Administration](#7-settings--administration)
8. [Role-Based Access Control](#8-role-based-access-control)
9. [Subscription & Feature Access](#9-subscription--feature-access)
10. [Common Workflows](#10-common-workflows)
11. [Data Isolation & Multi-Tenant Context](#11-data-isolation--multi-tenant-context)
12. [Tips & Best Practices](#12-tips--best-practices)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Introduction & Getting Started

### What is the Tenant Panel?

The **Tenant Panel** is the main dashboard interface for users working within a tenant organization. It provides access to all quality assurance tools, coaching trackers, team management features, and analytics specific to your organization.

### Who Can Access the Tenant Panel?

- **Tenant Users**: Users who belong to one or more tenant organizations
- **User Types**: Admin, QE, Manager, Developer, Executive
- **Access Method**: Login through `/login` (not the platform admin login at `/admin/login`)

### Prerequisites for Access

To access the tenant panel, you need:

1. **Valid User Account**: An account associated with at least one tenant organization
2. **Active Status**: Your user account must be in "Active" status for the tenant
3. **Authentication**: Valid email/password or Google OAuth credentials

### First-Time User Overview

When you first log in:

1. You'll see the **onboarding wizard** (if not previously completed)
2. The wizard guides you through setting up your tenant organization
3. You'll be introduced to key features and navigation
4. After onboarding, you'll land on the main Dashboard

---

## 2. Authentication & Login Flow

### Login Process

#### Email/Password Login

1. Navigate to `/login`
2. Enter your **email address** and **password**
3. Click **Sign In**
4. The system verifies your credentials

#### Google OAuth Login

1. Navigate to `/login`
2. Click **Sign in with Google**
3. Select your Google account
4. Authorize the application

### Tenant Selection

After successful authentication:

#### Single Tenant User
- If you belong to only **one tenant**, you'll be automatically logged in
- No tenant selection step required
- You'll be redirected directly to the Dashboard

#### Multiple Tenant User
- If you belong to **multiple tenants**, you'll see the **Tenant Selector Page**
- Each tenant shows:
  - Organization name
  - Your role in that tenant
  - A "Select" button
- **Select the tenant** you want to work in
- Your session will be scoped to that tenant's data

### Session Management

- **Access Token**: Stored securely in browser localStorage (key: `tenant.accessToken`)
- **Refresh Token**: Used to maintain session without re-logging in
- **User Data**: Your user profile and tenant context are stored in localStorage
- **Session Duration**: Access tokens expire; refresh tokens last 7 days

### Logout Process

1. Click your **avatar** in the top-right corner
2. Select **Logout** from the menu
3. Your session is cleared
4. You're redirected to the login page (`/login`)

**Note**: Logging out clears your current tenant session. To switch to a different tenant, log out and log back in with a different tenant selection.

---

## 3. Onboarding Experience

### First-Time User Onboarding

When you first access the tenant panel (or if onboarding wasn't completed), you'll see:

#### Onboarding Notification

- **Location**: Notification icon in the header (top-right)
- **Indicator**: Red badge showing "New" notification
- **Click**: Opens the onboarding wizard

#### Onboarding Wizard Steps

The wizard guides you through:

1. **Welcome**: Introduction to the platform
2. **Organization Setup**: Basic tenant information
3. **Team Configuration**: Setting up your teams/squads
4. **Feature Tour**: Overview of available modules
5. **Completion**: Final step confirming setup

#### Progress Tracking

- Progress bar shows completion percentage
- You can complete onboarding at your own pace
- Progress is saved between sessions

### Accessing Onboarding Later

If you skipped onboarding or want to review it:

1. Click the **notifications icon** in the header
2. If onboarding is available, you'll see the notification
3. Click to open the wizard

---

## 4. Navigation & Layout

### Header Components

The header is fixed at the top of the page and contains:

#### Logo and Branding
- **Left side**: QEnabler Platform logo and title
- **Click logo**: Navigates to Dashboard

#### Theme Toggle
- **Icon**: Sun/Moon icon (right side of header)
- **Function**: Toggle between light and dark mode
- **Persistence**: Your theme preference is saved

#### Help Icon
- **Icon**: Question mark icon
- **Function**: Access help documentation and support

#### Notifications
- **Icon**: Bell icon with badge (shows count of new notifications)
- **Notifications Include**:
  - Onboarding reminders
  - System alerts
  - Important updates
- **Click**: Opens notifications menu

#### User Menu
- **Trigger**: Click your avatar (top-right)
- **Menu Items**:
  - **Profile Settings**: View/edit your profile
  - **Logout**: End your session

**User Menu Details**:
- Displays your name, email, and role
- Shows your tenant ID (for reference)
- Lists teams you're associated with

### Sidebar Navigation

The sidebar is located on the left side of the screen and organizes features into sections:

#### Overview Section
- **Dashboard**: Main overview page with metrics and charts

#### Modules Section
Contains all feature modules (visibility depends on role and subscription):
- **Squad Management**: Manage teams and squads
- **User Management**: Invite and manage users
- **Coaching Tracker**: Record and track coaching sessions
- **Quality Scorecard**: Assess and track quality metrics
- **Feedback Form**: Collect and view feedback
- **Maturity Ladder**: Track team maturity progression
- **Test Debt Register**: Manage test debt items
- **Enablement Hub**: Access quality resources (subscription required)
- **Impact Timeline**: Visualize improvements over time (subscription required)
- **Exploratory Testing**: Log exploratory test sessions (subscription required)
- **Change Tracker**: Track change initiatives (subscription required)
- **Career Framework**: Career growth tools (subscription required)

#### Administration Section (Admin Only)
- **Roles**: Manage custom roles and permissions
- **Module Access**: Control module access by role
- **Settings**: Tenant settings and configuration

### Role-Based Menu Visibility

- **Admin Role**: Sees all available menus for their tenant
- **Other Roles**: See only menus they have permission to access
- **Custom Roles**: May have customized menu access set by admins
- **Hidden Menus**: Menus you don't have access to won't appear in the sidebar

### Subscription Feature Gating

- Some modules require specific subscription plans
- If your tenant doesn't have access to a feature, the menu item won't appear
- **Feature Gates**: Features may be hidden or show upgrade prompts based on subscription

### Mobile Responsive Behavior

#### Desktop (Medium screens and up)
- Sidebar is permanently visible
- Full navigation always accessible

#### Mobile (Small screens)
- Sidebar is hidden by default
- **Menu button** (hamburger icon) in header opens/closes sidebar
- Sidebar closes automatically after navigation
- Touch-friendly interface

---

## 5. Dashboard Overview

### Purpose

The Dashboard (`/dashboard`) provides a high-level overview of your tenant's quality metrics, recent activities, and quick access to key features.

### Key Metrics Cards

The top section displays important metrics:

#### Teams Coached
- Number of unique teams/squads that have received coaching
- Shows your coaching coverage

#### Average Quality Score
- Average quality scorecard rating across all teams
- Trend indicator (up/down arrow) shows change over time

#### Test Debt Items
- Total number of test debt items logged
- Tracks technical debt in your testing

### Charts and Visualizations

#### Coaching Activities Chart
- **Type**: Bar chart
- **Shows**: Monthly coaching session counts
- **Purpose**: Track coaching frequency and trends

#### Quality Scores by Team
- **Type**: Pie chart
- **Shows**: Distribution of quality scores across teams
- **Purpose**: Identify teams that may need more support

#### Team Maturity Levels
- **Type**: Bar chart
- **Shows**: Current maturity level for each team
- **Purpose**: Track progression along the maturity ladder

#### Test Debt Status
- **Type**: Donut chart
- **Shows**: Open vs. resolved test debt items
- **Purpose**: Monitor debt resolution progress

### Recent Activities Feed

- **Location**: Below the charts
- **Shows**: Recent actions taken in the platform:
  - Coaching sessions created
  - Feedback submissions
  - Maturity assessments
  - Test debt items added
- **Interactive**: Click an activity to navigate to the relevant module

### Quick Access Module Cards

The bottom section provides quick access cards for major modules:

- **Coaching Tracker**: Track coaching sessions
- **Quality Scorecard**: View quality metrics
- **Feedback Form**: Submit feedback
- **Maturity Ladder**: Assess team maturity
- **Test Debt**: Manage test debt
- **Squad Management**: Manage squads
- **User Management**: Manage users
- **Settings**: Tenant settings

**Function**: Click any card to navigate directly to that module.

---

## 6. Core Modules & Features

### 6.1 Squad Management

**Purpose**: Organize and manage teams (squads) within your tenant.

#### Viewing Squads
- **Access**: Navigate to `/dashboard/squads`
- **Display**: Table or list view of all squads
- **Information Shown**:
  - Squad name
  - Member count
  - Associated users
  - Creation date

#### Creating Squads
1. Click **"New Squad"** or **"Create Squad"** button
2. Enter squad details:
   - Squad name (required)
   - Description (optional)
   - Tags or categories (if available)
3. Click **"Save"** to create

#### Editing Squads
1. Find the squad in the list
2. Click **Edit** icon/button
3. Modify details as needed
4. Click **"Save"** to update

#### Assigning Users to Squads
1. Open the squad details
2. Navigate to **Members** or **Users** section
3. Click **"Add Member"** or **"Assign User"**
4. Select users from the list
5. Click **"Assign"** to save

#### Squad Details
- View all squad information
- See all associated members
- View coaching sessions for the squad
- Access quality scorecards for the squad

**Note**: Squad Management requires the `squad_management` feature (Growth plan or higher).

---

### 6.2 User Management

**Purpose**: Invite, manage, and organize users within your tenant.

#### Viewing Users
- **Access**: Navigate to `/dashboard/users`
- **Display**: Table showing all tenant users
- **Columns**:
  - Name
  - Email
  - Role
  - Status (Active, Pending, Inactive)
  - Actions (Edit, Delete)

#### Inviting New Users
1. Click **"Invite User"** or **"Add User"** button
2. Enter user details:
   - **Email** (required)
   - **Name** (required)
   - **Role** (required): Select from admin, qe, manager, developer, executive
   - **Password** (optional): If not provided, user receives invitation email
   - **Squads** (optional): Assign to squads immediately
3. Click **"Send Invitation"** or **"Create User"**
4. User receives invitation email (if password not set)

#### Managing User Roles
1. Find the user in the list
2. Click **Edit** icon
3. Select new **Role** from dropdown
4. Click **"Save"** to update
5. User's permissions update immediately

#### User Status Management
- **Active**: User can log in and access the platform
- **Pending**: User has been invited but hasn't accepted yet
- **Inactive**: User account is disabled (cannot log in)

**Changing Status**:
1. Edit the user
2. Select new status from dropdown
3. Save changes

#### Pending Invitations
- **Tab/View**: Separate section showing pending invitations
- **Actions Available**:
  - **Resend Invitation**: Send invitation email again
  - **Cancel Invitation**: Remove pending invitation
  - **Copy Invitation Link**: Share invitation link manually

---

### 6.3 Coaching Tracker

**Purpose**: Record, track, and analyze coaching sessions with teams.

#### Recording Coaching Sessions
1. Navigate to `/dashboard/coaching-tracker`
2. Click **"New Session"** or **"Log Session"** button
3. Fill in session details:
   - **Squad/Team**: Select the team coached
   - **Date**: Session date
   - **Duration**: Length of session
   - **Type**: Session type (one-on-one, team session, etc.)
   - **Notes**: Coaching notes and observations
   - **Outcomes**: Key outcomes or action items
4. Click **"Save"** to record the session

#### Viewing Coaching History
- **View**: List or table of all coaching sessions
- **Filters Available**:
  - By squad/team
  - By date range
  - By session type
  - By coach (if multiple coaches)
- **Sorting**: By date, squad, or other criteria

#### Filtering and Searching
- **Search Bar**: Search by squad name, notes, or other keywords
- **Date Range Filter**: Filter sessions by date
- **Squad Filter**: Show sessions for specific squads only
- **Type Filter**: Filter by session type

#### Coaching Metrics
- **Sessions per Team**: Number of sessions per squad
- **Total Sessions**: Overall coaching activity
- **Frequency**: Average sessions per week/month
- **Coverage**: Percentage of teams receiving coaching

---

### 6.4 Quality Scorecard

**Purpose**: Assess and track quality metrics across teams.

#### Creating Scorecards
1. Navigate to `/dashboard/quality-scorecard`
2. Click **"New Scorecard"** or **"Create Assessment"** button
3. Fill in scorecard details:
   - **Squad/Team**: Select team being assessed
   - **Assessment Date**: Date of assessment
   - **Assessor**: Person conducting assessment
   - **Categories**: Rate various quality categories:
     - Test coverage
     - Code quality
     - Process maturity
     - Automation
     - Documentation
   - **Overall Score**: Aggregate score
   - **Comments**: Notes and observations
4. Click **"Save"** to create scorecard

#### Viewing Quality Metrics
- **Dashboard View**: Overview of all team scores
- **Team Comparison**: Compare scores across teams
- **Trend Analysis**: Track score changes over time
- **Filtering**: Filter by team, date range, or score range

#### Team Quality Assessments
- **Per-Team View**: Detailed assessment history for each team
- **Score Trends**: Charts showing score progression
- **Gap Analysis**: Identify areas needing improvement

#### Scorecard History
- **Timeline View**: Historical scorecards for each team
- **Version Comparison**: Compare assessments over time
- **Export**: Download scorecard data (if available)

---

### 6.5 Feedback Form

**Purpose**: Collect and manage feedback from team members about quality practices.

#### Submitting Feedback
1. Navigate to `/dashboard/feedback-form`
2. Click **"New Feedback"** or **"Submit Feedback"** button
3. Fill in the feedback form:
   - **Form Type**: Select feedback category
   - **Squad/Team**: Related team (if applicable)
   - **Ratings**: Rate various aspects (if using structured form)
   - **Comments**: Detailed feedback text
   - **Suggestions**: Improvement suggestions
4. Click **"Submit"** to send feedback

#### Viewing Feedback Responses
- **List View**: All submitted feedback
- **Filters**: Filter by team, date, form type
- **Search**: Search feedback by keywords
- **Detail View**: Click to see full feedback details

#### Feedback Analytics
- **Response Rates**: Percentage of team members who submitted feedback
- **Average Ratings**: Aggregated scores (if using ratings)
- **Trends**: Feedback trends over time
- **Common Themes**: Frequent topics or issues mentioned

---

### 6.6 Maturity Ladder

**Purpose**: Track team progression through quality maturity levels.

#### Team Maturity Assessments
1. Navigate to `/dashboard/maturity-ladder`
2. Select a team/squad
3. Click **"New Assessment"** or **"Assess Maturity"**
4. Complete assessment:
   - **Current Level**: Select current maturity level
   - **Assessment Date**: Date of assessment
   - **Criteria**: Evaluate against maturity criteria
   - **Evidence**: Supporting evidence for level
   - **Next Steps**: Actions to reach next level
5. Click **"Save"** to record assessment

#### Maturity Level Tracking
- **Level Display**: Current level for each team
- **Progress Indicators**: Visual progress toward next level
- **Historical Data**: Past assessments and level changes
- **Team Comparison**: Compare maturity across teams

#### Growth Tracking
- **Progress Charts**: Visual representation of maturity progression
- **Timeline**: When teams moved between levels
- **Goals**: Target maturity levels for teams
- **Achievements**: Milestones reached

**Maturity Levels**: Defined in tenant settings; common levels include Initial, Managed, Defined, Quantitatively Managed, Optimizing.

---

### 6.7 Test Debt Register

**Purpose**: Track and manage untested areas or technical debt in testing.

#### Logging Test Debt Items
1. Navigate to `/dashboard/test-debt`
2. Click **"New Debt Item"** or **"Log Debt"** button
3. Fill in debt details:
   - **Title**: Brief description
   - **Description**: Detailed explanation
   - **Squad/Area**: Related team or codebase area
   - **Priority**: High, Medium, Low
   - **Category**: Type of debt (coverage, automation, etc.)
   - **Impact**: Potential impact if not addressed
   - **Estimated Effort**: Time to resolve
4. Click **"Save"** to log the debt item

#### Tracking Debt Status
- **Status Options**:
  - **Open**: Not yet addressed
  - **In Progress**: Currently being worked on
  - **Resolved**: Completed
- **Update Status**: Click item and change status

#### Prioritizing Debt
- **Priority Levels**: High, Medium, Low
- **Sorting**: Sort by priority, date, impact
- **Filtering**: Filter by status, priority, squad
- **Views**: Kanban board or list view

#### Resolving Debt Items
1. Find the debt item
2. Click to open details
3. Update status to **"In Progress"** or **"Resolved"**
4. Add resolution notes
5. Save changes

**Note**: Test Debt Register requires the `test_debt_register` feature (Growth plan or higher).

---

### 6.8 Additional Modules (Subscription Required)

#### Enablement Hub

**Purpose**: Central repository for quality resources, templates, and enablement materials.

**Features**:
- **Resource Library**: Templates, guides, playbooks
- **Test Strategy Guides**: Best practices and frameworks
- **Documentation**: Quality assurance documentation
- **Templates**: Reusable testing templates

**Access**: Requires `enablement_hub_basic` or `enablement_hub_advanced` feature (Growth plan or higher).

---

#### Impact Timeline

**Purpose**: Visualize improvements and coaching interventions over time.

**Features**:
- **Timeline View**: Chronological view of events
- **Coaching Impact**: Correlation between coaching and quality improvements
- **Milestones**: Key achievements and milestones
- **Trend Analysis**: Long-term trend visualization

**Access**: Requires `impact_timeline` feature (Growth plan or higher).

---

#### Exploratory Testing (Test Logger)

**Purpose**: Log and share exploratory test sessions.

**Features**:
- **Session Logging**: Record exploratory test sessions
- **Findings**: Document discoveries and issues
- **Session Sharing**: Share insights across teams
- **Session Analysis**: Analyze testing patterns

**Access**: Requires `exploratory_testing` feature (Enterprise plan).

---

#### Change Tracker

**Purpose**: Track change initiatives and measure QA transformation.

**Features**:
- **Change Initiatives**: Log organizational changes
- **Adoption Tracking**: Track adoption of new practices
- **Impact Measurement**: Measure impact of changes
- **Transformation Metrics**: Overall transformation progress

**Access**: Requires `change_management` feature (Growth plan or higher).

---

#### Career Framework

**Purpose**: Support career growth for Quality Engineers based on coaching impact.

**Features**:
- **Career Paths**: Defined career progression paths
- **Skills Assessment**: Evaluate QE skills
- **Growth Planning**: Plan career development
- **Achievement Tracking**: Track career milestones

**Access**: Requires `career_framework` feature (Enterprise plan).

---

## 7. Settings & Administration

### Tenant Settings Page

**Access**: Navigate to `/dashboard/settings` (Admin role required)

The Settings page is organized into tabs:

#### General Settings Tab
- **Tenant Information**:
  - Organization name
  - Slug/identifier
  - Company details
- **Branding**:
  - Logo upload
  - Company website
  - Custom branding

#### Theme Configuration Tab
- **Color Customization**:
  - Primary color
  - Secondary color
  - Accent colors
- **Preview**: See theme changes in real-time
- **Save**: Apply theme to entire tenant

#### Maturity Levels Management Tab
- **Define Maturity Levels**:
  - Add/edit maturity level names
  - Set level descriptions
  - Configure level order
- **Default Levels**: Use system defaults or customize

#### Subscription Management Tab
- **Current Plan**: View active subscription plan
- **Plan Details**: Features included in current plan
- **Billing Information**: Subscription status and dates
- **Upgrade Options**: View available plan upgrades (if applicable)

**Note**: Subscription changes may require platform admin approval.

---

### Profile Settings

**Access**: Click your avatar → **Profile Settings** or navigate to `/dashboard/profile`

#### User Profile Information
- **Name**: Update your display name
- **Email**: View your email (usually not editable)
- **Role**: View your current role (not directly editable)

#### Avatar Management
- **Current Avatar**: View current profile picture
- **Upload New**: Upload a new avatar image
- **Remove**: Remove avatar (uses initials instead)

#### Password Changes
1. Navigate to Profile Settings
2. Find **Password** section
3. Enter:
   - Current password
   - New password
   - Confirm new password
4. Click **"Change Password"** to save

---

### Role Management (Admin Only)

**Access**: Navigate to `/dashboard/roles`

#### Creating Custom Roles
1. Click **"New Role"** or **"Create Role"** button
2. Enter role details:
   - **Role Name**: Unique name for the role
   - **Description**: What this role is for
3. Click **"Save"** to create

#### Assigning Permissions
1. Select a role
2. Navigate to **Permissions** or **Module Access** section
3. For each module/menu:
   - Check boxes to allow access
   - Uncheck to deny access
4. Click **"Save Permissions"** to apply

#### Module Access Control
- **Granular Control**: Set access per module
- **Menu Visibility**: Control which menus appear for the role
- **Permission Inheritance**: System roles have predefined permissions

**Note**: Admin role always has full access and cannot be modified.

---

## 8. Role-Based Access Control

### Understanding Roles

The platform supports the following **system roles**:

#### Admin
- **Full Access**: Can access all features and settings
- **Management**: Can manage users, roles, and tenant settings
- **Cannot Be Restricted**: Admin always has full permissions

#### QE (Quality Engineer)
- **Primary Focus**: Quality assurance activities
- **Typical Access**: Coaching Tracker, Quality Scorecard, Test Debt, Maturity Ladder
- **Permissions**: May vary based on custom role configuration

#### Manager
- **Management Focus**: Team oversight and coordination
- **Typical Access**: Dashboard, User Management, Coaching Tracker, Reports
- **Permissions**: May have access to administrative features for their teams

#### Developer
- **Development Focus**: Development and testing activities
- **Typical Access**: Feedback Form, Test Debt, Quality Scorecard (view)
- **Limited Access**: Typically cannot manage users or settings

#### Executive
- **Strategic Focus**: High-level metrics and insights
- **Typical Access**: Dashboard, Reports, Analytics
- **Limited Access**: Usually view-only for most features

### What Each Role Can Access

Access depends on:
1. **System Role**: Base permissions for standard roles
2. **Custom Roles**: Custom permissions if using custom roles
3. **Menu Permissions**: Granular menu access settings
4. **Subscription**: Feature availability based on plan

### Menu Visibility Based on Role

- **Visible Menus**: Only menus you have permission to access appear in the sidebar
- **Hidden Menus**: Menus without permission don't appear
- **Dynamic Loading**: Menus load based on your role and permissions

### Permission-Based Feature Access

- **Module-Level**: Access to entire modules can be restricted
- **Feature-Level**: Specific features within modules may be restricted
- **Action-Level**: Certain actions (create, edit, delete) may be restricted per role

### Custom Roles and Permissions

If your tenant uses custom roles:

- **Custom Permissions**: Set by tenant admins
- **Granular Control**: Fine-grained access to modules and features
- **Role Assignment**: Users can be assigned to custom roles
- **Inheritance**: Custom roles may extend system role permissions

**Viewing Your Permissions**: Check with your tenant admin or review your role in Profile Settings.

---

## 9. Subscription & Feature Access

### Subscription Plans Overview

The platform offers three subscription tiers:

#### Starter Plan
- **Basic Features**: Core quality assurance tools
- **Ideal For**: Small teams getting started
- **Features**: Dashboard, Coaching Tracker, Quality Scorecard, Feedback Form, Maturity Ladder

#### Growth Plan
- **Expanded Features**: Additional modules and capabilities
- **Ideal For**: Growing organizations
- **Additional Features**: Squad Management, Test Debt Register, Enablement Hub, Impact Timeline, Change Tracker

#### Enterprise Plan
- **Full Features**: All available modules and advanced capabilities
- **Ideal For**: Large organizations with advanced needs
- **Additional Features**: Exploratory Testing (Test Logger), Career Framework

### Feature Gating Based on Subscription

- **Access Control**: Features are automatically hidden if not in your plan
- **Menu Visibility**: Menu items for unavailable features don't appear
- **Upgrade Prompts**: Some areas may show upgrade prompts if accessed

### Which Features Require Which Plans

| Feature | Starter | Growth | Enterprise |
|---------|---------|--------|------------|
| Dashboard | ✅ | ✅ | ✅ |
| Coaching Tracker | ✅ | ✅ | ✅ |
| Quality Scorecard | ✅ | ✅ | ✅ |
| Feedback Form | ✅ | ✅ | ✅ |
| Maturity Ladder | ✅ | ✅ | ✅ |
| Squad Management | ❌ | ✅ | ✅ |
| Test Debt Register | ❌ | ✅ | ✅ |
| Enablement Hub | ❌ | ✅ | ✅ |
| Impact Timeline | ❌ | ✅ | ✅ |
| Change Tracker | ❌ | ✅ | ✅ |
| Exploratory Testing | ❌ | ❌ | ✅ |
| Career Framework | ❌ | ❌ | ✅ |

### Subscription Management in Settings

- **View Current Plan**: Settings → Subscription tab
- **Plan Details**: See what's included in your plan
- **Upgrade Requests**: Contact platform admin or use upgrade prompts

### Feature Availability Indicators

- **Visible Features**: Available in your subscription appear normally
- **Hidden Features**: Unavailable features don't appear in navigation
- **Upgrade Prompts**: Some areas may suggest upgrading your plan

**Note**: Subscription management is typically handled by tenant admins or platform admins.

---

## 10. Common Workflows

### Daily Workflows

#### Logging a Coaching Session

1. Navigate to **Coaching Tracker** (`/dashboard/coaching-tracker`)
2. Click **"New Session"**
3. Select the **Squad** you coached
4. Enter **Date** and **Duration**
5. Add **Notes** about the session
6. Document **Outcomes** or action items
7. Click **"Save"**

**Time**: 2-3 minutes per session

---

#### Creating a Quality Scorecard

1. Navigate to **Quality Scorecard** (`/dashboard/quality-scorecard`)
2. Click **"New Scorecard"**
3. Select the **Team** being assessed
4. Rate each **Category** (coverage, quality, process, etc.)
5. Enter **Overall Score**
6. Add **Comments** with observations
7. Click **"Save"**

**Time**: 5-10 minutes per scorecard

---

#### Inviting a New Team Member

1. Navigate to **User Management** (`/dashboard/users`)
2. Click **"Invite User"**
3. Enter **Email** and **Name**
4. Select **Role** (qe, developer, manager, etc.)
5. Optionally assign to **Squads**
6. Click **"Send Invitation"**
7. User receives email invitation

**Time**: 1-2 minutes per invitation

---

#### Checking Dashboard Metrics

1. Navigate to **Dashboard** (`/dashboard`)
2. Review **Key Metrics** cards:
   - Teams coached
   - Average quality score
   - Test debt items
3. Check **Charts** for trends
4. Review **Recent Activities** feed
5. Use **Quick Access** cards for common tasks

**Time**: 1-2 minutes for overview

---

### Weekly/Monthly Workflows

#### Reviewing Team Maturity

1. Navigate to **Maturity Ladder** (`/dashboard/maturity-ladder`)
2. Review current **Maturity Levels** for all teams
3. Identify teams that need assessment
4. Schedule maturity assessments
5. Review **Progress Charts** to see improvements
6. Set **Goals** for teams to reach next level

**Frequency**: Monthly or quarterly

---

#### Analyzing Quality Trends

1. Navigate to **Dashboard**
2. Review **Quality Scores by Team** chart
3. Navigate to **Quality Scorecard** for detailed analysis
4. Filter by **Date Range** (last month/quarter)
5. Compare scores across teams
6. Identify teams needing support
7. Review **Trend Analysis** charts

**Frequency**: Weekly or monthly

---

#### Managing Test Debt Backlog

1. Navigate to **Test Debt Register** (`/dashboard/test-debt`)
2. Review **Open** debt items
3. **Sort by Priority** to identify critical items
4. **Assign** debt items to teams or individuals
5. Update **Status** as items are worked on
6. **Resolve** completed items
7. Review **Debt Status** chart for progress

**Frequency**: Weekly backlog review, daily updates

---

## 11. Data Isolation & Multi-Tenant Context

### Understanding Tenant Context

When you log in and select a tenant, all your work is **scoped to that tenant**:

- **Data Isolation**: You only see data from your selected tenant
- **Team Data**: Squads, users, and teams are tenant-specific
- **Metrics**: All metrics and analytics are for your tenant only
- **Security**: You cannot access data from other tenants

### How Data is Isolated Per Tenant

**Technical Implementation**:
- Your **access token** includes your `tenantId`
- All API requests automatically filter by `tenantId`
- Database queries only return data for your tenant
- Cross-tenant access is prevented

**What This Means**:
- If you belong to multiple tenants, each tenant has separate:
  - Teams/Squads
  - Users
  - Coaching sessions
  - Quality scorecards
  - All other data

### Switching Between Tenants

**Current Method**: Logout and Re-Login

1. **Logout**: Click avatar → Logout
2. **Login Again**: Go to `/login` and enter credentials
3. **Select Different Tenant**: Choose a different tenant from the selector
4. **New Session**: You'll see data for the newly selected tenant

**Future Enhancement**: A tenant switcher may be added in the future to switch without logging out.

### What Data is Visible in Current Tenant

You see **only** data that belongs to your currently selected tenant:

✅ **Visible**:
- Squads belonging to your tenant
- Users in your tenant
- Coaching sessions for your tenant's squads
- Quality scorecards for your tenant
- All other tenant-specific data

❌ **Not Visible**:
- Data from other tenants (even if you belong to them)
- Platform-wide data (only visible to platform admins)
- Data from tenants you don't belong to

**Example**:
- If you're an admin in "Acme Corp" and a developer in "Tech Startup Inc"
- When logged into "Acme Corp", you only see Acme Corp's data
- To see Tech Startup Inc's data, you must logout and login with that tenant

---

## 12. Tips & Best Practices

### Navigation Shortcuts

- **Dashboard**: Click logo in header to return to dashboard
- **Quick Access Cards**: Use dashboard quick access for common modules
- **Breadcrumbs**: Some pages show navigation breadcrumbs
- **Keyboard**: Use browser back/forward buttons for navigation

### Efficient Workflows

#### Batch Operations
- **Invite Multiple Users**: Invite all new team members in one session
- **Bulk Updates**: Update multiple items when possible (if feature available)
- **Template Use**: Use templates for repetitive tasks (coaching sessions, scorecards)

#### Time-Saving Tips
- **Bookmark Frequently Used Pages**: Bookmark your most-used modules
- **Use Filters**: Use filters to quickly find specific items
- **Save Drafts**: Save incomplete items as drafts (if feature available)
- **Keyboard Shortcuts**: Use keyboard shortcuts where available

### Using Filters and Search

#### Effective Filtering
- **Date Ranges**: Use date filters to focus on recent data
- **Multiple Filters**: Combine filters for precise results
- **Saved Filters**: Save common filter combinations (if available)

#### Search Strategies
- **Keywords**: Use specific keywords for better results
- **Partial Matches**: Search often works with partial text
- **Clear Searches**: Clear filters/search to see all data

### Mobile Usage Tips

#### Best Practices
- **Use Landscape**: Some features work better in landscape orientation
- **Pinch to Zoom**: Zoom in on charts or detailed views
- **Save Often**: Mobile connections may be unstable; save frequently
- **Offline**: Some features may not work offline

---

## 13. Troubleshooting

### Common Issues

#### Can't See Certain Modules

**Possible Causes**:
1. **Role Permissions**: Your role doesn't have access
2. **Subscription**: Feature not included in your plan
3. **Menu Permissions**: Custom role has menu access restricted

**Solutions**:
- Check with your tenant admin about role permissions
- Verify your subscription includes the feature (Settings → Subscription)
- Confirm menu permissions for your role

---

#### Missing Menu Items

**Possible Causes**:
1. **Role Restriction**: Role doesn't have menu access
2. **Subscription**: Feature not in your plan
3. **Custom Role**: Custom role has restricted menu access

**Solutions**:
- Contact tenant admin to review role permissions
- Check subscription plan (Settings → Subscription)
- Request menu access if needed

---

#### Access Denied Errors

**Possible Causes**:
1. **Session Expired**: Access token expired
2. **Role Change**: Your role/permissions changed
3. **Tenant Access**: Lost access to tenant

**Solutions**:
- **Refresh Page**: Sometimes fixes session issues
- **Logout and Login**: Refresh your session
- **Check Status**: Verify your account is still active
- **Contact Admin**: If issue persists, contact tenant admin

---

#### Feature Not Available

**Possible Causes**:
1. **Subscription Plan**: Feature requires higher plan
2. **Feature Gating**: Feature disabled for your tenant
3. **Role Permission**: Role doesn't have feature access

**Solutions**:
- Check Settings → Subscription for plan details
- Contact tenant admin about feature availability
- Review role permissions with admin

---

#### Login Issues

**Possible Causes**:
1. **Invalid Credentials**: Wrong email/password
2. **Account Status**: Account inactive or suspended
3. **No Tenant Access**: No active tenant associations

**Solutions**:
- Verify email and password
- Check if account is active (contact admin)
- Ensure you have at least one active tenant association

---

#### Data Not Loading

**Possible Causes**:
1. **Network Issues**: Internet connection problems
2. **Session Expired**: Need to refresh session
3. **Backend Issues**: Temporary service problems

**Solutions**:
- Check internet connection
- Refresh the page
- Logout and login again
- Wait a few minutes and try again
- Contact support if issue persists

---

#### Theme Not Saving

**Possible Causes**:
1. **Browser Storage**: localStorage blocked or full
2. **Permissions**: Browser restrictions

**Solutions**:
- Clear browser cache and try again
- Check browser settings for localStorage
- Try different browser
- Contact support if issue persists

---

### Getting Help

#### Support Channels

1. **Help Icon**: Click help icon in header for documentation
2. **Tenant Admin**: Contact your tenant administrator
3. **Platform Support**: Contact platform support team (if available)

#### Information to Provide

When reporting issues, include:
- **Description**: What you were trying to do
- **Error Messages**: Exact error text (if any)
- **Steps**: Steps to reproduce the issue
- **Browser**: Browser and version
- **Role**: Your role in the tenant
- **Screenshots**: Screenshots of the issue (if possible)

---

## Summary

This guide covers all aspects of working in the tenant panel:

✅ **Getting Started**: Login, tenant selection, first-time setup  
✅ **Navigation**: Understanding the layout and menu structure  
✅ **Features**: All available modules and how to use them  
✅ **Administration**: Settings, roles, and permissions  
✅ **Access Control**: Role-based and subscription-based access  
✅ **Workflows**: Common daily and weekly tasks  
✅ **Context**: Understanding multi-tenant data isolation  
✅ **Troubleshooting**: Resolving common issues  

For additional information, refer to:
- **[Tenant Login Flow](./tenant-login-flow.md)** - Detailed login process
- **[Multi-Tenant Dashboard](./multi-tenant-dashboard.md)** - How multi-tenant works
- **[Role-Based Menu Access Control](./role-based-menu-access-control.md)** - Menu permissions
- **[Subscription Implementation Summary](./SUBSCRIPTION_IMPLEMENTATION_SUMMARY.md)** - Subscription features

---

**Last Updated**: [Current Date]  
**Version**: 1.0
