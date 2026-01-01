---
name: Maturity Ladder Enhancement
overview: Update maturity levels to match the new specification (Ad Hoc through Whole Team Quality), enhance the assessment form with reasoning, target level, and self-rated quality score fields, and update the database schema and UI accordingly.
todos: []
---

# Mat

urity Ladder Enhancement Plan

## Overview

Update the Maturity Ladder system to match the documented specification with new level names, enhanced assessment fields, and self-rated quality scoring.

## Changes Required

### 1. Update Maturity Levels Data

**Files to modify:**

- `coachqa-backend/migrations/009-seed-maturity-levels.sql`

**Updates needed:**

- Replace level names: Initial → Ad Hoc, Managed → Strategy Exists, Defined → Basic Automation, Measured → Quality Built-In, Optimizing → Whole Team Quality
- Update descriptions to match the specification
- Update detailed criteria arrays to reflect the documented characteristics

**New level structure:**

- L1: Ad Hoc - "No clear strategy, testing is manual, reactive, usually QE-only"
- L2: Strategy Exists - "A testing strategy exists but is not consistently followed"
- L3: Basic Automation - "Unit/E2E coverage in place, shift-left beginning, still QE-led"
- L4: Quality Built-In - "Testing integrated into DoD, all roles participate, CI pipeline stable"
- L5: Whole Team Quality - "Developers, designers, and PMs actively own and evolve quality"

### 2. Database Schema Updates

**Files to modify:**

- `coachqa-backend/src/models/MaturityAssessment.ts`
- Create new migration file: `coachqa-backend/migrations/012-add-maturity-assessment-fields.sql`

**New fields to add:**

- `reasoning` (TEXT, nullable) - "Why do we think we're here?"
- `targetLevel` (INTEGER, nullable) - Optional target level for next quarter
- `selfRatedQuality` (INTEGER, nullable) - Self-rated quality score (1-5)

### 3. Backend API Updates

**Files to modify:**

- `coachqa-backend/src/services/maturity.service.ts` - Update interfaces and service methods
- `coachqa-backend/src/controllers/maturity.controller.ts` - Update payload handling
- `coachqa-ui/src/utils/api.ts` - Update TypeScript interfaces

**Changes:**

- Add new fields to `CreateMaturityData` interface
- Update `createAssessment` and `updateAssessment` methods to handle new fields
- Add validation for self-rated quality (1-5 range)

### 4. Frontend Assessment Form Enhancement

**Files to modify:**

- `coachqa-ui/src/pages/maturity-ladder/AssessmentFormDialog.tsx`

**Updates:**

- Add "Reasoning" field (text area) - Required field for explaining the level choice
- Add "Target Level" field (optional dropdown) - For setting next quarter goal
- Add "Self-Rated Quality" field (1-5 scale with visual rating component)
- Update form validation
- Add helper text explaining the collaborative assessment process
- Rename "Notes" to "Additional Notes" (or keep as is, but add reasoning as separate field)

### 5. UI/UX Improvements

**Files to modify:**

- `coachqa-ui/src/pages/maturity-ladder/MaturityLadder.tsx`

**Updates:**

- Display reasoning in assessment history/view
- Display target level if set
- Display self-rated quality score with visual indicator
- Add context/guidance about collaborative assessment process

### 6. Display Updates

**Files to modify:**

- `coachqa-ui/src/pages/maturity-ladder/MaturityLadder.tsx` - History table/display
- Assessment detail views

**Updates:**

- Show reasoning in assessment details
- Show target level progression
- Show self-rated quality alongside maturity level

## Implementation Order

1. Create database migration for new assessment fields
2. Update backend models and interfaces
3. Update backend services and controllers
4. Update frontend TypeScript interfaces
5. Update assessment form component
6. Update maturity levels seed data
7. Update display components to show new fields

## Notes

- Self-rated quality score (1-5) can be used separately or combined with maturity level