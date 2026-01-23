# Login Troubleshooting Guide

## Issue: 401 Unauthorized Error on Tenant Login

### Quick Fix Steps

1. **Check if test users exist in the database**
   - The seed script creates test users with password: `Password123!`
   - Run the seed script if users don't exist

2. **Run the seed script to create test users:**
   ```bash
   cd QEnabler-backend
   npx ts-node scripts/seed-sample-data.ts
   ```

3. **Test user credentials:**
   - Email: `admin@acme.com`
   - Password: `Password123!`
   
   Other test users:
   - `qe.lead@acme.com` / `Password123!`
   - `manager@acme.com` / `Password123!`
   - `dev@acme.com` / `Password123!`
   - `qe.engineer@acme.com` / `Password123!`

### Debugging Steps

1. **Check backend console logs** when attempting to log in:
   - You should see: `[AUTH CONTROLLER] Login attempt for: <email>`
   - Then: `[AUTH SERVICE] Attempting login for email: <email>`
   - If user found: `[AUTH SERVICE] User found: {...}`
   - If password wrong: `[AUTH SERVICE] Password mismatch for email: <email>`
   - If user not found: `[AUTH SERVICE] User not found for email: <email>`
   - If status not active: `[AUTH SERVICE] User account not active. Status: <status>`

2. **Common Issues:**

   **Issue: User not found**
   - Solution: Run the seed script to create test users
   - Or create a user via registration or platform admin

   **Issue: Password mismatch**
   - Solution: Use the correct password: `Password123!`
   - Or reset the password via platform admin

   **Issue: Account not active**
   - Solution: Update user status to 'active' in the database
   - Or create a new user with ACTIVE status

3. **Verify database connection:**
   - Check if the backend can connect to PostgreSQL
   - Verify database credentials in `.env` file

4. **Check user status in database:**
   ```sql
   SELECT id, email, name, role, status FROM users WHERE email = 'admin@acme.com';
   ```
   - Status should be `'active'`
   - If status is `'pending'` or `'inactive'`, update it:
   ```sql
   UPDATE users SET status = 'active' WHERE email = 'admin@acme.com';
   ```

### Creating a New User

If you need to create a new user, you can:

1. **Via Registration** (if registration is enabled):
   - Go to registration page
   - Create a new tenant and admin user

2. **Via Platform Admin**:
   - Login as platform admin
   - Go to Tenant Management
   - Select a tenant
   - Go to Users tab
   - Click "Add User"

3. **Via Database** (for testing):
   ```sql
   -- First, get a tenant ID
   SELECT id FROM tenants LIMIT 1;
   
   -- Then create a user (password is 'Password123!' hashed)
   -- You'll need to generate the bcrypt hash first
   INSERT INTO users (tenant_id, email, password_hash, name, role, status, email_verified)
   VALUES (
     '<tenant-id>',
     'test@example.com',
     '$2b$10$...', -- Generate with: bcrypt.hash('Password123!', 10)
     'Test User',
     'admin',
     'active',
     true
   );
   ```

### Testing Login

1. **Start the backend server:**
   ```bash
   cd QEnabler-backend
   npm run dev
   ```

2. **Start the frontend:**
   ```bash
   cd QEnabler-ui
   npm run dev
   ```

3. **Try logging in with:**
   - Email: `admin@acme.com`
   - Password: `Password123!`

4. **Check the backend console** for detailed logs showing where the login fails

### Error Messages

- **"Invalid credentials"**: Either user doesn't exist or password is wrong
- **"Account is not active"**: User exists but status is not 'active'
- **"Cannot connect to server"**: Backend server is not running or wrong URL
- **401 Unauthorized**: Login failed (check backend logs for details)

### Next Steps

If login still fails after running the seed script:
1. Check backend console for detailed error logs
2. Verify the user exists in the database
3. Verify the password hash is correct
4. Check user status is 'active'
5. Verify database connection is working











