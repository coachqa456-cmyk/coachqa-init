# Quality Scoring Integration - Quick Reference

## Quick Start

### 1. Backend: Calculate Points from Self-Rated Quality

```typescript
import { calculateSelfRatedPoints } from '../utils/qualityScoring';
import Tenant from '../models/Tenant';

// Get tenant config
const tenant = await Tenant.findByPk(tenantId);
const config = tenant?.qualityScoringConfig || null;

// Calculate points (selfRatedQuality is 1-5)
const points = calculateSelfRatedPoints(
  selfRatedQuality as 1 | 2 | 3 | 4 | 5,
  config
);
// Returns: 0-20 (or configured maxPoints)
```

### 2. Frontend: Use in Scorecard Calculation

```typescript
import { useQualityScorecard } from '../hooks/useQualityScorecard';
import { calculateSelfRatedPoints } from '../utils/qualityScoring';

function MyScorecardComponent() {
  const { qualityScoringConfig, calculateScorecardScore } = useQualityScorecard();
  
  // Calculate overall score
  const overallScore = calculateScorecardScore(
    testCoveragePercent,
    bugCount,
    selfRatedQuality // 1-5
  );
  
  // Or calculate just self-rated points
  const points = calculateSelfRatedPoints(
    selfRatedQuality as 1 | 2 | 3 | 4 | 5,
    qualityScoringConfig
  );
}
```

## Key Functions

### Backend: `calculateSelfRatedPoints()`
```typescript
calculateSelfRatedPoints(
  rawScore: 1 | 2 | 3 | 4 | 5,
  config: QualityScoringConfig | null
): number
```
- Returns points based on tenant configuration
- Handles custom mapping, linear mapping, and disabled state
- Default: returns 0-20 points

### Frontend: `useQualityScorecard()` Hook
```typescript
const {
  qualityScoringConfig,    // Current tenant config
  loading,                   // Loading state
  calculateScorecardScore   // Calculate overall score
} = useQualityScorecard();
```

### Frontend: `calculateSelfRatedPoints()`
```typescript
calculateSelfRatedPoints(
  rawScore: 1 | 2 | 3 | 4 | 5,
  config: QualityScoringConfig | null
): number
```
- Same as backend function
- Use when you need just the points, not the full scorecard calculation

## Configuration Structure

```typescript
interface QualityScoringConfig {
  enabled: boolean;                    // Enable/disable feature
  maxPoints: number;                   // Max points (default: 20)
  scaleMax: number;                    // Rating scale max (default: 5)
  customMapping?: Record<number, number>; // Optional custom mapping
}
```

## Example Calculations

### Default Linear Mapping (maxPoints=20, scaleMax=5)
- Rating 1 → 4 points
- Rating 2 → 8 points
- Rating 3 → 12 points
- Rating 4 → 16 points
- Rating 5 → 20 points

### Custom Mapping Example
```typescript
{
  enabled: true,
  maxPoints: 20,
  scaleMax: 5,
  customMapping: {
    1: 0,   // Very poor → 0 points
    2: 5,   // Not confident → 5 points
    3: 10,  // Neutral → 10 points
    4: 15,  // Confident → 15 points
    5: 20   // Very confident → 20 points
  }
}
```

## Integration Checklist

### Backend
- [ ] Add `selfRatedQuality` field to QualityScorecard model
- [ ] Create database migration for `self_rated_quality` column
- [ ] Import `calculateSelfRatedPoints` utility
- [ ] Update `CreateScorecardData` interface
- [ ] Create `calculateQualityScore` helper function
- [ ] Update `createScorecard` to use helper
- [ ] Update `updateScorecard` to recalculate when needed

### Frontend
- [ ] Import `useQualityScorecard` hook
- [ ] Add `selfRatedQuality` to scorecard form
- [ ] Use `Rating` component for input (1-5 scale)
- [ ] Display calculated points in UI
- [ ] Show preview of points contribution
- [ ] Handle disabled state (when config.enabled = false)

## Common Patterns

### Pattern 1: Calculate Overall Scorecard
```typescript
// Backend
const qualityScore = await calculateQualityScore(
  testCoveragePercent,
  bugCount,
  selfRatedQuality,
  tenantId
);

// Frontend
const qualityScore = calculateScorecardScore(
  testCoveragePercent,
  bugCount,
  selfRatedQuality
);
```

### Pattern 2: Just Get Self-Rated Points
```typescript
// Both backend and frontend
const points = calculateSelfRatedPoints(
  selfRatedQuality as 1 | 2 | 3 | 4 | 5,
  config
);
```

### Pattern 3: Check if Feature is Enabled
```typescript
if (qualityScoringConfig?.enabled) {
  // Include self-rated quality in calculation
} else {
  // Skip or show message
}
```

## Files Created/Modified

### New Files
- `coachqa-backend/src/utils/qualityScoring.ts` - Backend utility
- `coachqa-ui/src/utils/qualityScoring.ts` - Frontend utility
- `coachqa-ui/src/hooks/useQualityScorecard.ts` - React hook
- `coachqa-backend/src/services/scorecard.service.example.ts` - Example implementation

### Modified Files
- `coachqa-backend/src/models/QualityScorecard.ts` - Add selfRatedQuality field
- `coachqa-backend/src/services/scorecard.service.ts` - Integrate calculation
- `coachqa-ui/src/pages/quality-scorecard/QualityScorecard.tsx` - Add UI components

### Database
- Migration: `018-add-self-rated-quality-to-scorecards.sql`

## Testing

1. **Test Default Config**: Create scorecard with self-rated quality, verify points
2. **Test Custom Mapping**: Configure custom mapping, verify different points
3. **Test Disabled**: Disable feature, verify returns 0 points
4. **Test Different Scales**: Change scaleMax, verify calculations
5. **Test Edge Cases**: null values, out of range values

## Support

See full documentation:
- [Quality Scoring Configuration](./QUALITY_SCORING_CONFIGURATION.md) - User guide
- [Quality Scoring Integration Guide](./QUALITY_SCORING_INTEGRATION_GUIDE.md) - Complete integration steps

