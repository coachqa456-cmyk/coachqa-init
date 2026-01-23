# Quality Scoring Integration Guide

This guide shows how to integrate the configurable quality scoring system into your quality scorecard calculations.

## Overview

The integration involves:
1. **Backend**: Adding self-rated quality to scorecard model and calculating points using tenant config
2. **Frontend**: Fetching config and using it in scorecard calculations/display
3. **Database**: Storing self-rated quality in scorecards

---

## Part 1: Backend Integration

### Step 1: Add Self-Rated Quality to Scorecard Model

First, we need to add a field to store the team's self-rated quality (1-5):

```typescript
// QEnabler-backend/src/models/QualityScorecard.ts

export interface QualityScorecardAttributes {
  id: string;
  tenantId: string;
  squadId: string;
  periodStart: Date;
  periodEnd: Date;
  testCoveragePercent: number;
  bugCount: number;
  qualityScore: number;
  selfRatedQuality?: number | null; // Add this field (1-5)
  metricsData?: Record<string, any> | null;
  createdBy: string;
  createdAt?: Date;
  updatedAt?: Date;
}

// In the class definition:
class QualityScorecard extends Model<QualityScorecardAttributes, QualityScorecardCreationAttributes>
  implements QualityScorecardAttributes
{
  // ... existing fields
  public selfRatedQuality!: number | null; // Add this
  // ... rest of fields
}

// In QualityScorecard.init(), add:
selfRatedQuality: {
  type: DataTypes.INTEGER,
  allowNull: true,
  field: 'self_rated_quality',
  validate: {
    min: 1,
    max: 5,
  },
},
```

### Step 2: Create Backend Utility Function

Create a utility function similar to the frontend one:

```typescript
// QEnabler-backend/src/utils/qualityScoring.ts

import { QualityScoringConfig } from '../models/Tenant';

export type SelfRatedQualityScore = 1 | 2 | 3 | 4 | 5;

/**
 * Calculates points for self-rated quality based on tenant configuration
 * @param rawScore - The team's self-rated quality score (1-5)
 * @param config - Quality scoring configuration from tenant settings
 * @returns Points out of maxPoints (default 20)
 */
export function calculateSelfRatedPoints(
  rawScore: SelfRatedQualityScore,
  config: QualityScoringConfig | null | undefined
): number {
  // Default config if none provided
  const defaultConfig: QualityScoringConfig = {
    enabled: true,
    maxPoints: 20,
    scaleMax: 5,
  };

  const effectiveConfig = config || defaultConfig;

  // If disabled, return 0
  if (!effectiveConfig.enabled) {
    return 0;
  }

  // Use custom mapping if provided
  if (effectiveConfig.customMapping && effectiveConfig.customMapping[rawScore] != null) {
    return effectiveConfig.customMapping[rawScore];
  }

  // Default linear mapping: rawScore / scaleMax * maxPoints
  return Math.round((rawScore / effectiveConfig.scaleMax) * effectiveConfig.maxPoints);
}
```

### Step 3: Update Scorecard Service

Update the service to calculate quality score including self-rated quality:

```typescript
// QEnabler-backend/src/services/scorecard.service.ts

import Tenant from '../models/Tenant';
import { calculateSelfRatedPoints } from '../utils/qualityScoring';

export interface CreateScorecardData {
  squadId: string;
  periodStart: string;
  periodEnd: string;
  testCoveragePercent: number;
  bugCount: number;
  selfRatedQuality?: number; // Add this field (1-5)
  metricsData?: Record<string, any>;
  // Note: qualityScore will be calculated, not passed in
}

/**
 * Calculate overall quality score from components
 */
async function calculateQualityScore(
  testCoveragePercent: number,
  bugCount: number,
  selfRatedQuality: number | null | undefined,
  qualityScoringConfig: QualityScoringConfig | null,
  tenantId: string
): Promise<number> {
  // Get tenant config if not provided
  let config = qualityScoringConfig;
  if (!config) {
    const tenant = await Tenant.findByPk(tenantId);
    config = tenant?.qualityScoringConfig || null;
  }

  // Calculate component scores (example weights - adjust as needed)
  const testCoveragePoints = Math.min(testCoveragePercent, 100); // Max 100 points
  const bugCountPoints = Math.max(0, 100 - (bugCount * 2)); // Deduct 2 points per bug, min 0
  
  // Calculate self-rated quality points
  let selfRatedPoints = 0;
  if (selfRatedQuality !== null && selfRatedQuality !== undefined) {
    selfRatedPoints = calculateSelfRatedPoints(
      selfRatedQuality as 1 | 2 | 3 | 4 | 5,
      config
    );
  }

  // Calculate weighted overall score (example: out of 100)
  // Adjust weights based on your scoring model
  const overallScore = Math.round(
    (testCoveragePoints * 0.4) +      // 40% weight
    (bugCountPoints * 0.4) +           // 40% weight
    (selfRatedPoints * 0.2)             // 20% weight (max 20 points = 4% of 100)
  );

  return Math.min(100, Math.max(0, overallScore)); // Clamp between 0-100
}

export const createScorecard = async (
  data: CreateScorecardData,
  tenantId: string,
  createdBy: string
) => {
  // Get tenant to access quality scoring config
  const tenant = await Tenant.findByPk(tenantId);
  
  // Calculate quality score including self-rated quality
  const qualityScore = await calculateQualityScore(
    data.testCoveragePercent,
    data.bugCount,
    data.selfRatedQuality,
    tenant?.qualityScoringConfig || null,
    tenantId
  );

  return QualityScorecard.create({
    ...data,
    tenantId,
    createdBy,
    qualityScore, // Use calculated score
    periodStart: new Date(data.periodStart),
    periodEnd: new Date(data.periodEnd),
  });
};

export const updateScorecard = async (
  id: string,
  data: Partial<CreateScorecardData>,
  tenantId: string
) => {
  const scorecard = await QualityScorecard.findOne({ where: { id, tenantId } });
  if (!scorecard) throw new NotFoundError('Scorecard');

  // If quality-affecting fields are updated, recalculate score
  if (data.testCoveragePercent !== undefined || 
      data.bugCount !== undefined || 
      data.selfRatedQuality !== undefined) {
    
    const tenant = await Tenant.findByPk(tenantId);
    const qualityScore = await calculateQualityScore(
      data.testCoveragePercent ?? scorecard.testCoveragePercent,
      data.bugCount ?? scorecard.bugCount,
      data.selfRatedQuality ?? scorecard.selfRatedQuality,
      tenant?.qualityScoringConfig || null,
      tenantId
    );
    
    data.qualityScore = qualityScore;
  }

  const updateData: any = { ...data };
  if (data.periodStart) {
    updateData.periodStart = new Date(data.periodStart);
  }
  if (data.periodEnd) {
    updateData.periodEnd = new Date(data.periodEnd);
  }
  await scorecard.update(updateData);
  return scorecard;
};
```

### Step 4: Update Database Schema

Create a migration to add the `self_rated_quality` column:

```sql
-- Migration: 018-add-self-rated-quality-to-scorecards.sql
ALTER TABLE quality_scorecards
ADD COLUMN self_rated_quality INTEGER CHECK (self_rated_quality >= 1 AND self_rated_quality <= 5);

COMMENT ON COLUMN quality_scorecards.self_rated_quality IS 'Team self-rated quality score (1-5 scale)';
```

---

## Part 2: Frontend Integration

### Step 1: Update API Types

```typescript
// QEnabler-ui/src/utils/api.ts

export interface QualityScorecard {
  id: string;
  squadId: string;
  periodStart: string;
  periodEnd: string;
  testCoveragePercent: number;
  bugCount: number;
  qualityScore: number;
  selfRatedQuality?: number | null; // Add this
  metricsData?: Record<string, any>;
  createdAt: string;
  updatedAt: string;
}

export interface CreateScorecardPayload {
  squadId: string;
  periodStart: string;
  periodEnd: string;
  testCoveragePercent: number;
  bugCount: number;
  selfRatedQuality?: number; // Add this (1-5)
  metricsData?: Record<string, any>;
}
```

### Step 2: Create Scorecard Calculation Hook

```typescript
// QEnabler-ui/src/hooks/useQualityScorecard.ts

import { useState, useEffect } from 'react';
import { fetchCurrentTenant, QualityScoringConfig } from '../utils/api';
import { calculateSelfRatedPoints } from '../utils/qualityScoring';

export function useQualityScorecard() {
  const [qualityScoringConfig, setQualityScoringConfig] = useState<QualityScoringConfig | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadConfig = async () => {
      try {
        const response = await fetchCurrentTenant();
        if (response.ok) {
          const result = await response.json();
          setQualityScoringConfig(result.data.qualityScoringConfig || null);
        }
      } catch (error) {
        console.error('Failed to load quality scoring config:', error);
      } finally {
        setLoading(false);
      }
    };

    loadConfig();
  }, []);

  const calculateScorecardScore = (
    testCoveragePercent: number,
    bugCount: number,
    selfRatedQuality?: number | null
  ): number => {
    // Calculate component scores (same logic as backend)
    const testCoveragePoints = Math.min(testCoveragePercent, 100);
    const bugCountPoints = Math.max(0, 100 - (bugCount * 2));
    
    // Calculate self-rated quality points
    let selfRatedPoints = 0;
    if (selfRatedQuality !== null && selfRatedQuality !== undefined) {
      selfRatedPoints = calculateSelfRatedPoints(
        selfRatedQuality as 1 | 2 | 3 | 4 | 5,
        qualityScoringConfig
      );
    }

    // Calculate weighted overall score
    const overallScore = Math.round(
      (testCoveragePoints * 0.4) +
      (bugCountPoints * 0.4) +
      (selfRatedPoints * 0.2)
    );

    return Math.min(100, Math.max(0, overallScore));
  };

  return {
    qualityScoringConfig,
    loading,
    calculateScorecardScore,
  };
}
```

### Step 3: Update Quality Scorecard Component

```typescript
// QEnabler-ui/src/pages/quality-scorecard/QualityScorecard.tsx

import { useState, useEffect } from 'react';
import { useQualityScorecard } from '../../hooks/useQualityScorecard';
import { fetchScorecards, createScorecard, QualityScorecard } from '../../utils/api';
import { 
  TextField, 
  Rating, 
  FormHelperText 
} from '@mui/material';

// Add to component state
const { qualityScoringConfig, loading: configLoading, calculateScorecardScore } = useQualityScorecard();
const [selfRatedQuality, setSelfRatedQuality] = useState<number | null>(null);

// In your scorecard form/creation:
<Box sx={{ mb: 3 }}>
  <Typography variant="subtitle2" gutterBottom>
    Self-Rated Quality
  </Typography>
  <Rating
    value={selfRatedQuality || 0}
    onChange={(_, newValue) => setSelfRatedQuality(newValue)}
    max={qualityScoringConfig?.scaleMax || 5}
    size="large"
  />
  <FormHelperText>
    Rate your team's confidence in the quality of delivered features (1-{qualityScoringConfig?.scaleMax || 5})
  </FormHelperText>
  {selfRatedQuality && qualityScoringConfig && (
    <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
      This will contribute {calculateSelfRatedPoints(
        selfRatedQuality as 1 | 2 | 3 | 4 | 5,
        qualityScoringConfig
      )} points to the overall scorecard
    </Typography>
  )}
</Box>

// When creating/updating scorecard:
const handleCreateScorecard = async () => {
  const calculatedScore = calculateScorecardScore(
    testCoveragePercent,
    bugCount,
    selfRatedQuality
  );

  await createScorecard({
    squadId,
    periodStart,
    periodEnd,
    testCoveragePercent,
    bugCount,
    selfRatedQuality: selfRatedQuality || undefined,
    qualityScore: calculatedScore, // Or let backend calculate
  });
};
```

### Step 4: Display Self-Rated Quality in Scorecard View

```typescript
// In your scorecard display component:

{scorecard.selfRatedQuality && (
  <Grid item xs={12} md={6}>
    <Card>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          Self-Rated Quality
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Rating 
            value={scorecard.selfRatedQuality} 
            readOnly 
            max={qualityScoringConfig?.scaleMax || 5}
          />
          <Typography variant="body1">
            {scorecard.selfRatedQuality} / {qualityScoringConfig?.scaleMax || 5}
          </Typography>
        </Box>
        {qualityScoringConfig && (
          <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
            Contributed {calculateSelfRatedPoints(
              scorecard.selfRatedQuality as 1 | 2 | 3 | 4 | 5,
              qualityScoringConfig
            )} points to overall score
          </Typography>
        )}
      </CardContent>
    </Card>
  </Grid>
)}
```

---

## Part 3: Complete Example

### Backend: Full Scorecard Service with Integration

```typescript
// QEnabler-backend/src/services/scorecard.service.ts

import QualityScorecard from '../models/QualityScorecard';
import Tenant from '../models/Tenant';
import { NotFoundError } from '../utils/errors';
import { calculateSelfRatedPoints } from '../utils/qualityScoring';

export interface CreateScorecardData {
  squadId: string;
  periodStart: string;
  periodEnd: string;
  testCoveragePercent: number;
  bugCount: number;
  selfRatedQuality?: number;
  metricsData?: Record<string, any>;
}

/**
 * Calculate quality score with configurable self-rated quality component
 */
async function calculateQualityScore(
  testCoveragePercent: number,
  bugCount: number,
  selfRatedQuality: number | null | undefined,
  tenantId: string
): Promise<number> {
  // Get tenant config
  const tenant = await Tenant.findByPk(tenantId);
  const config = tenant?.qualityScoringConfig || null;

  // Component calculations
  const testCoveragePoints = Math.min(testCoveragePercent, 100);
  const bugCountPoints = Math.max(0, 100 - (bugCount * 2));
  
  // Self-rated quality points (using config)
  let selfRatedPoints = 0;
  if (selfRatedQuality !== null && selfRatedQuality !== undefined) {
    selfRatedPoints = calculateSelfRatedPoints(
      selfRatedQuality as 1 | 2 | 3 | 4 | 5,
      config
    );
  }

  // Weighted calculation (adjust weights as needed)
  const overallScore = Math.round(
    (testCoveragePoints * 0.4) +
    (bugCountPoints * 0.4) +
    (selfRatedPoints * 0.2)
  );

  return Math.min(100, Math.max(0, overallScore));
}

export const createScorecard = async (
  data: CreateScorecardData,
  tenantId: string,
  createdBy: string
) => {
  const qualityScore = await calculateQualityScore(
    data.testCoveragePercent,
    data.bugCount,
    data.selfRatedQuality,
    tenantId
  );

  return QualityScorecard.create({
    ...data,
    tenantId,
    createdBy,
    qualityScore,
    periodStart: new Date(data.periodStart),
    periodEnd: new Date(data.periodEnd),
  });
};
```

### Frontend: Complete Component Example

```typescript
// QEnabler-ui/src/pages/quality-scorecard/CreateScorecardDialog.tsx

import { useState, useEffect } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField, Rating } from '@mui/material';
import { useQualityScorecard } from '../../hooks/useQualityScorecard';
import { createScorecard } from '../../utils/api';
import { calculateSelfRatedPoints } from '../../utils/qualityScoring';

export function CreateScorecardDialog({ open, onClose, squadId }: Props) {
  const { qualityScoringConfig, calculateScorecardScore } = useQualityScorecard();
  const [formData, setFormData] = useState({
    periodStart: '',
    periodEnd: '',
    testCoveragePercent: 0,
    bugCount: 0,
    selfRatedQuality: null as number | null,
  });

  const handleSubmit = async () => {
    const qualityScore = calculateScorecardScore(
      formData.testCoveragePercent,
      formData.bugCount,
      formData.selfRatedQuality
    );

    await createScorecard({
      squadId,
      periodStart: formData.periodStart,
      periodEnd: formData.periodEnd,
      testCoveragePercent: formData.testCoveragePercent,
      bugCount: formData.bugCount,
      selfRatedQuality: formData.selfRatedQuality || undefined,
    });

    onClose();
  };

  const selfRatedPoints = formData.selfRatedQuality && qualityScoringConfig
    ? calculateSelfRatedPoints(
        formData.selfRatedQuality as 1 | 2 | 3 | 4 | 5,
        qualityScoringConfig
      )
    : 0;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>Create Quality Scorecard</DialogTitle>
      <DialogContent>
        {/* Other form fields */}
        
        <TextField
          label="Test Coverage %"
          type="number"
          value={formData.testCoveragePercent}
          onChange={(e) => setFormData({ ...formData, testCoveragePercent: Number(e.target.value) })}
          fullWidth
          margin="normal"
        />

        <TextField
          label="Bug Count"
          type="number"
          value={formData.bugCount}
          onChange={(e) => setFormData({ ...formData, bugCount: Number(e.target.value) })}
          fullWidth
          margin="normal"
        />

        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle2" gutterBottom>
            Self-Rated Quality
          </Typography>
          <Rating
            value={formData.selfRatedQuality || 0}
            onChange={(_, newValue) => setFormData({ ...formData, selfRatedQuality: newValue })}
            max={qualityScoringConfig?.scaleMax || 5}
            size="large"
          />
          {formData.selfRatedQuality && (
            <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
              Will contribute {selfRatedPoints} points to overall score
            </Typography>
          )}
        </Box>

        {qualityScoringConfig && !qualityScoringConfig.enabled && (
          <Alert severity="info" sx={{ mt: 2 }}>
            Self-rated quality is currently disabled in tenant settings
          </Alert>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Cancel</Button>
        <Button onClick={handleSubmit} variant="contained">Create</Button>
      </DialogActions>
    </Dialog>
  );
}
```

---

## Testing the Integration

1. **Configure Quality Scoring**:
   - Go to Settings → Quality Scoring
   - Set max points to 20, scale max to 5
   - Enable custom mapping if desired
   - Save configuration

2. **Create a Scorecard**:
   - Navigate to Quality Scorecard
   - Create a new scorecard
   - Enter test coverage, bug count
   - Rate self-rated quality (1-5)
   - Verify the calculated score includes self-rated points

3. **Verify Calculation**:
   - Check that self-rated quality points are calculated correctly
   - Verify overall score reflects the configuration
   - Test with different configurations (custom mapping, disabled, etc.)

---

## Summary

The integration involves:
- ✅ Adding `selfRatedQuality` field to scorecard model
- ✅ Creating backend utility function for point calculation
- ✅ Updating scorecard service to use tenant config
- ✅ Creating frontend hook to fetch and use config
- ✅ Updating UI to collect and display self-rated quality
- ✅ Calculating overall score with configurable weights

This provides a flexible, configurable quality scoring system that respects tenant-specific settings!

