# Subscription Expiry & Payment Alert Implementation

## Overview

This document describes the industry-standard subscription expiry tracking and payment alert system implemented for QEnabler. The system automatically tracks subscription end dates, sends email notifications, and handles grace periods before suspension.

## Features Implemented

### 1. Subscription End Date Management

- **Automatic End Date Calculation**: Subscriptions now automatically get `subscriptionEndDate` set based on:
  - **Trial plans**: Start date + trial days
  - **Monthly plans**: Start date + 1 month
  - **Yearly plans**: Start date + 1 year
  - **Enterprise plans**: No end date (null)

- **Renewal Handling**: When subscriptions are renewed (via payment webhooks), the end date is automatically extended by the billing period.

### 2. Email Notifications

The system sends automated email alerts at the following intervals:

- **7 days before expiry**: Reminder email
- **3 days before expiry**: Urgent reminder email
- **1 day before expiry**: Final reminder email
- **On expiry**: Expired notification with grace period information
- **After grace period**: Suspension notification

All emails include:
- Subscription plan details
- Expiry date
- Direct link to billing/payment page
- Clear call-to-action buttons

### 3. Grace Period Management

- **Default grace period**: 7 days after expiry
- **During grace period**: 
  - Subscription status remains `active` or `trial`
  - Users receive expired notifications
  - Service continues to function
- **After grace period**:
  - Subscription status changes to `suspended`
  - Users receive suspension notification
  - Service access is restricted (handled by subscription guards)

### 4. Scheduled Job System

- **Daily cron job**: Runs at 2:00 AM UTC every day
- **Tasks performed**:
  1. Check subscriptions expiring in 7, 3, and 1 days
  2. Send appropriate email notifications
  3. Check expired subscriptions (within grace period)
  4. Suspend subscriptions past grace period
  5. Log all actions to subscription history

### 5. Payment Webhook Integration

- **Stripe webhooks**: `invoice.payment_succeeded` event now:
  - Extends `subscriptionEndDate` for renewals
  - Updates subscription status to `active`
  - Logs renewal in subscription history

- **PayPal webhooks**: `PAYMENT.CAPTURE.COMPLETED` event now:
  - Extends `subscriptionEndDate` for renewals
  - Updates subscription status to `active`
  - Logs renewal in subscription history

## Technical Implementation

### Files Created/Modified

1. **`src/services/subscription-expiry.service.ts`** (NEW)
   - Core expiry checking logic
   - Email notification orchestration
   - Suspension handling

2. **`src/utils/scheduler.ts`** (NEW)
   - Cron job initialization
   - Scheduled task management

3. **`src/services/email.service.ts`** (MODIFIED)
   - Added `sendSubscriptionExpiryEmail()` function
   - Email templates for all expiry scenarios

4. **`src/services/subscription.service.ts`** (MODIFIED)
   - Updated `updateTenantSubscription()` to set end dates based on billing period
   - Handles renewal vs new subscription logic

5. **`src/services/payment.service.ts`** (MODIFIED)
   - Updated Stripe webhook handler to extend end dates on renewal
   - Updated PayPal webhook handler to extend end dates on renewal

6. **`src/server.ts`** (MODIFIED)
   - Initializes scheduled jobs on server startup

### Dependencies Added

- `node-cron`: For scheduled job execution
- `@types/node-cron`: TypeScript types

## Configuration

### Environment Variables

No new environment variables required. The system uses existing email configuration:
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`
- `EMAIL_FROM`

### Cron Schedule

Default schedule: `0 2 * * *` (Daily at 2:00 AM UTC)

To change the schedule, modify `src/utils/scheduler.ts`:
```typescript
cron.schedule('0 2 * * *', async () => {
  // Your custom schedule here
});
```

### Grace Period

Default grace period: 7 days

To change the grace period, modify the calls in `subscription-expiry.service.ts`:
```typescript
await suspendExpiredSubscriptions(7); // Change 7 to your desired days
```

## Database Schema

No schema changes required. The system uses existing fields:
- `tenants.subscription_end_date`
- `tenants.subscription_status`
- `tenants.subscription_start_date`
- `subscription_history` table (for audit trail)

## Email Templates

All email templates are HTML-formatted with:
- Professional styling
- Clear call-to-action buttons
- Responsive design
- Plain text fallback

Templates handle:
- Expiring soon (7, 3, 1 days)
- Expired (within grace period)
- Suspended (after grace period)

## Testing

### Manual Testing

1. **Test expiry notifications**:
   ```sql
   -- Set a subscription to expire in 7 days
   UPDATE tenants 
   SET subscription_end_date = CURRENT_DATE + INTERVAL '7 days'
   WHERE id = 'your-tenant-id';
   ```

2. **Test suspension**:
   ```sql
   -- Set a subscription to expire 8 days ago (past grace period)
   UPDATE tenants 
   SET subscription_end_date = CURRENT_DATE - INTERVAL '8 days'
   WHERE id = 'your-tenant-id';
   ```

3. **Run expiry check manually**:
   ```typescript
   import { checkSubscriptionExpiry } from './services/subscription-expiry.service';
   await checkSubscriptionExpiry();
   ```

### Automated Testing

Consider adding tests for:
- End date calculation logic
- Grace period handling
- Email sending (mock email service)
- Suspension logic

## Monitoring

All actions are logged using Winston logger:
- `[Subscription Expiry]` prefix for expiry-related logs
- `[Scheduler]` prefix for scheduled job logs
- `[Payment]` prefix for payment-related logs

Check logs for:
- Number of subscriptions checked
- Number of emails sent
- Number of subscriptions suspended
- Any errors encountered

## Industry Standards Compliance

This implementation follows industry best practices:

✅ **Proactive notifications**: Multiple reminders before expiry  
✅ **Grace period**: Allows time for payment before suspension  
✅ **Automatic renewal tracking**: End dates extended on payment  
✅ **Audit trail**: All changes logged in subscription history  
✅ **Email notifications**: Professional, clear, actionable  
✅ **Scheduled automation**: Daily checks without manual intervention  
✅ **Status management**: Clear status transitions (active → expired → suspended)  

## Future Enhancements

Potential improvements:
1. **Payment retry logic**: Automatically retry failed payments
2. **Custom grace periods**: Per-plan or per-tenant grace periods
3. **SMS notifications**: Add SMS alerts for critical expiry
4. **Dashboard alerts**: In-app notifications for expiring subscriptions
5. **Analytics**: Track renewal rates, expiry patterns
6. **Dunning management**: Multiple payment attempt strategies

## Support

For issues or questions:
1. Check application logs for error details
2. Verify email service configuration
3. Ensure cron jobs are running (check server logs)
4. Verify subscription end dates are set correctly in database
