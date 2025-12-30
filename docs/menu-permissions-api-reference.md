# Menu Permissions API Reference

## Base URL
All endpoints are prefixed with `/api`

## Authentication
Most endpoints require authentication via Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

## System Menu Endpoints

### Get Active System Menus (Public)
Get all active system menus (readonly for tenants).

**Endpoint:** `GET /api/system-menus`

**Authentication:** Optional

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "path": "/dashboard",
      "title": "Dashboard",
      "icon": "BarChart",
      "groupName": "Overview",
      "orderIndex": 0,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### List All System Menus (Platform Admin)
**Endpoint:** `GET /api/platform-admin/system-menus?activeOnly=true`

**Authentication:** Required (Platform Admin)

**Query Parameters:**
- `activeOnly` (optional): Filter to only active menus (default: false)

**Response:** Same as above

### Get System Menu by ID (Platform Admin)
**Endpoint:** `GET /api/platform-admin/system-menus/:id`

**Authentication:** Required (Platform Admin)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "path": "/dashboard",
    "title": "Dashboard",
    "icon": "BarChart",
    "groupName": "Overview",
    "orderIndex": 0,
    "isActive": true
  }
}
```

### Create System Menu (Platform Admin)
**Endpoint:** `POST /api/platform-admin/system-menus`

**Authentication:** Required (Platform Admin)

**Request Body:**
```json
{
  "path": "/dashboard/new-feature",
  "title": "New Feature",
  "icon": "BookOpen",
  "groupName": "Modules",
  "orderIndex": 0,
  "isActive": true
}
```

**Response:** Created menu object

### Update System Menu (Platform Admin)
**Endpoint:** `PUT /api/platform-admin/system-menus/:id`

**Authentication:** Required (Platform Admin)

**Request Body:** Partial menu object (same fields as create)

**Response:** Updated menu object

### Delete System Menu (Platform Admin)
**Endpoint:** `DELETE /api/platform-admin/system-menus/:id`

**Authentication:** Required (Platform Admin)

**Response:**
```json
{
  "success": true,
  "message": "System menu deleted successfully"
}
```

## Custom Menu Endpoints

### List Custom Menus (Tenant Admin)
**Endpoint:** `GET /api/custom-menus?activeOnly=true`

**Authentication:** Required (Tenant Admin)

**Query Parameters:**
- `activeOnly` (optional): Filter to only active menus (default: false)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "tenantId": "uuid",
      "path": "/dashboard/custom-feature",
      "title": "Custom Feature",
      "icon": "BookOpen",
      "groupName": "Modules",
      "orderIndex": 0,
      "isActive": true
    }
  ]
}
```

### Get Custom Menu by ID (Tenant Admin)
**Endpoint:** `GET /api/custom-menus/:id`

**Authentication:** Required (Tenant Admin)

**Response:** Custom menu object

### Create Custom Menu (Tenant Admin)
**Endpoint:** `POST /api/custom-menus`

**Authentication:** Required (Tenant Admin)

**Request Body:**
```json
{
  "path": "/dashboard/custom-feature",
  "title": "Custom Feature",
  "icon": "BookOpen",
  "groupName": "Modules",
  "orderIndex": 0,
  "isActive": true
}
```

**Response:** Created custom menu object

### Update Custom Menu (Tenant Admin)
**Endpoint:** `PUT /api/custom-menus/:id`

**Authentication:** Required (Tenant Admin)

**Request Body:** Partial menu object

**Response:** Updated custom menu object

### Delete Custom Menu (Tenant Admin)
**Endpoint:** `DELETE /api/custom-menus/:id`

**Authentication:** Required (Tenant Admin)

**Response:**
```json
{
  "success": true,
  "message": "Custom menu deleted successfully"
}
```

## Menu Permission Endpoints

### Get Menu Permissions for Role
**Endpoint:** `GET /api/roles/:roleId/menu-permissions`

**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "data": {
    "/dashboard": true,
    "/dashboard/coaching-tracker": true,
    "/dashboard/quality-scorecard": false,
    "/dashboard/custom-feature": true
  }
}
```

**Note:** For admin role, all menus are returned as `true` (full access).

### Update Menu Permissions for Role
**Endpoint:** `PUT /api/roles/:roleId/menu-permissions`

**Authentication:** Required

**Authorization:**
- Platform admin: Can edit all role permissions
- Tenant admin: Can only edit custom menu permissions (system menu permissions are ignored)

**Request Body:**
```json
{
  "permissions": {
    "/dashboard": true,
    "/dashboard/coaching-tracker": true,
    "/dashboard/quality-scorecard": false,
    "/dashboard/custom-feature": true
  }
}
```

**Response:** Updated permissions object

**Error Responses:**
- `403 Forbidden`: User doesn't have permission to edit these permissions
- `400 Bad Request`: Invalid permissions object

### Get Available Menus for Tenant
**Endpoint:** `GET /api/menus`

**Authentication:** Required (Tenant User)

**Response:**
```json
{
  "success": true,
  "data": {
    "systemMenus": [
      {
        "id": "uuid",
        "path": "/dashboard",
        "title": "Dashboard",
        "icon": "BarChart",
        "group": "Overview",
        "orderIndex": 0,
        "menuType": "system"
      }
    ],
    "customMenus": [
      {
        "id": "uuid",
        "path": "/dashboard/custom-feature",
        "title": "Custom Feature",
        "icon": "BookOpen",
        "group": "Modules",
        "orderIndex": 0,
        "menuType": "custom"
      }
    ]
  }
}
```

## Error Responses

All endpoints return errors in the following format:

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "statusCode": 400
  }
}
```

### Common Error Codes

- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User doesn't have permission for this operation
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., duplicate menu path)
- `500 Internal Server Error`: Server error

## Rate Limiting

All endpoints are subject to rate limiting:
- 100 requests per 15 minutes per IP address

## Notes

1. **Role ID vs Role Name**: Currently, the API accepts both role ID and role name. In production, role ID should be used for better performance and security.

2. **Admin Role**: The admin role always returns all menus as allowed, regardless of stored permissions. This is enforced at the service level.

3. **Menu Path Uniqueness**: 
   - System menus: Path must be unique across all system menus
   - Custom menus: Path must be unique within a tenant

4. **Menu Types**: Menu permissions distinguish between 'system' and 'custom' menu types to enforce proper authorization.

5. **Tenant Isolation**: Custom menus and their permissions are isolated per tenant. Tenant admin can only manage their own tenant's custom menus.











