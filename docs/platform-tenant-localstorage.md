Now there are separate localStorage namespaces for platform admin and tenant sessions.
What changed
New key sets in AuthContext:
Tenant keys:
tenant.user
tenant.userType
tenant.accessToken
tenant.refreshToken
Platform admin keys:
platform.user
platform.userType
platform.accessToken
platform.refreshToken
On initial load (AuthProvider):
If the URL starts with /admin, it looks for platform.* keys.
Otherwise, it looks for tenant.* keys.
Legacy keys (user, userType, accessToken, refreshToken) are cleaned up.
On login:
Tenant login (/login) stores only tenant.* keys.
Platform admin login (/admin/login) stores only platform.* keys.
On logout:
Both tenant and platform namespaces are cleared, and then you’re redirected to:
/admin/login if you were a platform admin
/login otherwise.
You can now be logged in as a tenant user and a platform admin without them overwriting each other’s localStorage data.