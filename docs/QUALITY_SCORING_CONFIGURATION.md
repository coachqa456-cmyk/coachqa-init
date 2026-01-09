# Quality Scoring Configuration

## Overview

The Quality Scoring Configuration feature allows tenant administrators to customize how self-rated quality scores (1-5) are converted to points in the quality scorecard. This provides flexibility in scoring methodology while maintaining consistency across the platform.

## Features

- **Enable/Disable**: Toggle whether self-rated quality contributes to the scorecard
- **Configurable Max Points**: Set the maximum points that can be earned (default: 20)
- **Configurable Scale**: Set the maximum rating value teams can use (default: 5)
- **Custom Point Mapping**: Optionally define custom point values for each rating level
- **Linear Mapping**: Default automatic calculation: `Points = (Rating / ScaleMax) × MaxPoints`

## Accessing Configuration

1. Navigate to **Settings** → **Quality Scoring** tab
2. Configure the settings as needed
3. Click **Save Configuration** to apply changes

## Configuration Options

### Enable Self-Rated Quality in Scorecard
- **Default**: Enabled
- When disabled, self-rated quality scores return 0 points regardless of rating

### Maximum Points
- **Default**: 20
- **Range**: 1-100
- The maximum points that can be earned from self-rated quality
- This is typically a component of the total scorecard (e.g., out of 100 total points)

### Rating Scale Maximum
- **Default**: 5
- **Range**: 1-10
- The maximum value teams can rate themselves
- Typically 5 (1 = Very Poor, 5 = Very Confident)

### Custom Point Mapping
- **Default**: Disabled (uses linear mapping)
- When enabled, allows you to set custom point values for each rating level
- Example custom mapping:
  - Rating 1 → 0 points
  - Rating 2 → 5 points
  - Rating 3 → 10 points
  - Rating 4 → 15 points
  - Rating 5 → 20 points

## Calculation Examples

### Default Linear Mapping (ScaleMax=5, MaxPoints=20)
- Rating 1 → 4 points (1/5 × 20 = 4)
- Rating 2 → 8 points (2/5 × 20 = 8)
- Rating 3 → 12 points (3/5 × 20 = 12)
- Rating 4 → 16 points (4/5 × 20 = 16)
- Rating 5 → 20 points (5/5 × 20 = 20)

### Custom Mapping Example
If you want to penalize low ratings more:
- Rating 1 → 0 points
- Rating 2 → 4 points
- Rating 3 → 10 points
- Rating 4 → 16 points
- Rating 5 → 20 points

## Using in Code

### Frontend (TypeScript/React)

```typescript
import { calculateSelfRatedPoints } from '../utils/qualityScoring';
import { QualityScoringConfig } from '../utils/api';

// Get config from tenant settings (via API)
const qualityScoringConfig: QualityScoringConfig | null = await fetchTenantQualityScoringConfig();

// Calculate points for a team's self-rated quality (1-5)
const selfRatedQuality: 1 | 2 | 3 | 4 | 5 = 4; // Team's rating
const points = calculateSelfRatedPoints(selfRatedQuality, qualityScoringConfig);
// Returns: 16 (if using default config)
```

### Backend (TypeScript/Node.js)

The backend stores the configuration in the `tenants` table as JSONB:

```typescript
// Get tenant with quality scoring config
const tenant = await Tenant.findByPk(tenantId);
const config = tenant.qualityScoringConfig;

// Use config in scorecard calculation
if (config?.enabled) {
  const points = calculatePoints(selfRatedQuality, config);
  // Include points in overall quality score calculation
}
```

## Database Schema

The configuration is stored in the `tenants` table:

```sql
ALTER TABLE tenants
ADD COLUMN quality_scoring_config JSONB;
```

**JSON Structure:**
```json
{
  "enabled": true,
  "maxPoints": 20,
  "scaleMax": 5,
  "customMapping": {
    "1": 4,
    "2": 8,
    "3": 12,
    "4": 16,
    "5": 20
  }
}
```

## Migration

To add this feature to an existing database, run:

```sql
-- Migration: 017-add-quality-scoring-config.sql
ALTER TABLE tenants
ADD COLUMN quality_scoring_config JSONB;

CREATE INDEX idx_tenants_quality_scoring_config 
ON tenants USING GIN (quality_scoring_config);
```

## API Endpoints

### Get Tenant Configuration
```
GET /api/tenants/me
```

Response includes `qualityScoringConfig`:
```json
{
  "success": true,
  "data": {
    "id": "...",
    "name": "...",
    "qualityScoringConfig": {
      "enabled": true,
      "maxPoints": 20,
      "scaleMax": 5
    }
  }
}
```

### Update Configuration
```
PATCH /api/tenants/me
Content-Type: application/json

{
  "qualityScoringConfig": {
    "enabled": true,
    "maxPoints": 20,
    "scaleMax": 5,
    "customMapping": {
      "1": 4,
      "2": 8,
      "3": 12,
      "4": 16,
      "5": 20
    }
  }
}
```

## Best Practices

1. **Start with Defaults**: Use the default linear mapping unless you have specific requirements
2. **Document Custom Mappings**: If using custom mappings, document the rationale
3. **Test Changes**: Test configuration changes in a development environment first
4. **Consistent Scale**: Keep the rating scale consistent across all squads (typically 1-5)
5. **Review Periodically**: Review and adjust configuration quarterly based on team feedback

## Integration with Quality Scorecard

When calculating the overall quality score:

1. Get self-rated quality from the squad (1-5)
2. Get quality scoring configuration from tenant settings
3. Calculate points using `calculateSelfRatedPoints()`
4. Include points in the overall scorecard calculation

Example:
```typescript
const overallScore = 
  testCoveragePoints + 
  bugCountPoints + 
  processPoints +
  calculateSelfRatedPoints(selfRatedQuality, config) +
  // ... other components
```

## Troubleshooting

### Configuration Not Saving
- Ensure you have admin permissions
- Check browser console for errors
- Verify backend API is accessible

### Points Not Calculating Correctly
- Verify configuration is loaded from tenant settings
- Check that `enabled` is `true` if expecting points
- Ensure rating value is within the configured scale (1 to scaleMax)

### Custom Mapping Not Working
- Verify all rating levels (1 to scaleMax) have values in customMapping
- Check that custom mapping values don't exceed maxPoints
- Ensure `useCustomMapping` toggle is enabled in UI

## Related Documentation

- [Maturity Ladder Assessment](./maturity-ladder.md)
- [Quality Scorecard](./quality-scorecard.md)
- [Tenant Settings](./tenant-settings.md)

