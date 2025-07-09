# SmartSweep - Storage Dashboard UI Mockup Description

## Overall Layout
The storage dashboard serves as the primary visual element on the home screen, positioned prominently below the header and above the Smart Scan button. It uses a card-based design with rounded corners and subtle shadows to create depth.

## Visual Components

### 1. Progress Circle (Primary Element)
**Position**: Center of dashboard card
**Size**: 120x120 points
**Design**:
- **Background Circle**: Light gray stroke (#F2F2F7), 8pt line width
- **Progress Circle**: Gradient stroke from primary teal (#2AB7CA) to lighter teal (#2AB7CA with 60% opacity)
- **Animation**: Smooth progress animation on data load/refresh
- **Line Style**: Round line caps for modern appearance

**Center Content**:
- **Primary Text**: Used space (e.g., "5.1 GB") - Headline font, semibold weight
- **Secondary Text**: Total space (e.g., "/ 20 GB") - Caption font, gray color
- **Spacing**: 4pt between primary and secondary text

### 2. Cleanable Space Indicator
**Position**: Below progress circle
**Conditional Display**: Only shown when cleanable space > 0
**Design**:
- **Container**: Rounded pill shape (20pt corner radius)
- **Background**: Warning orange with 10% opacity (#FF9500 alpha 0.1)
- **Border**: None
- **Padding**: 16pt horizontal, 8pt vertical

**Content**:
- **Icon**: `trash.circle.fill` system icon in warning orange
- **Text**: "[X.X GB] Dapat Dibersihkan" - Subheadline font, medium weight
- **Layout**: Horizontal stack with 8pt spacing

### 3. Card Container
**Background**: System gray 6 (#F2F2F7)
**Corner Radius**: 16pt
**Padding**: 20pt all sides
**Shadow**: None (relies on background color for depth)
**Spacing**: 16pt between progress circle and cleanable space indicator

## Color Scheme

### Primary Colors
- **Teal Primary**: #2AB7CA (42, 183, 202)
- **Teal Gradient End**: #2AB7CA with 60% opacity
- **Background**: White (#FFFFFF)
- **Card Background**: System Gray 6 (#F2F2F7)

### Text Colors
- **Primary Text**: Charcoal Gray (#4A4A4A)
- **Secondary Text**: System Gray (#8E8E93)
- **Warning**: Orange (#FF9500)

## Responsive Behavior

### iPhone (Compact Width)
- Dashboard spans full width minus 20pt margins
- Progress circle maintains 120pt diameter
- Text scales appropriately for device size

### iPad (Regular Width)
- Dashboard maintains max width of 400pt, centered
- Progress circle can scale up to 140pt diameter
- Increased padding for better proportions

## Animation Specifications

### Progress Circle Animation
- **Duration**: 0.3 seconds
- **Timing**: Ease-in-out
- **Trigger**: On data load, scan completion, or manual refresh
- **Effect**: Smooth arc drawing from 0° to target percentage

### Cleanable Space Appearance
- **Duration**: 0.2 seconds
- **Effect**: Fade in with slight scale (0.95 to 1.0)
- **Delay**: 0.1 seconds after progress circle completes

### Hover/Touch States (Future Enhancement)
- Light scale effect (1.0 to 1.02) on touch
- Subtle shadow increase for depth feedback

## Data Display Logic

### Storage Calculation
- **Total Space**: Device storage capacity
- **Used Space**: Currently occupied storage
- **Available Space**: Remaining free storage
- **Cleanable Space**: Calculated from scan results (duplicates + temporary files)

### Progress Percentage
```
Usage Percentage = (Used Space / Total Space) × 100
```

### Text Formatting
- File sizes use `ByteCountFormatter` with `.file` style
- Automatic unit selection (MB, GB, TB)
- Localized number formatting for Indonesian market

## Accessibility Features

### VoiceOver Support
- Progress circle: "Storage usage: [X] percent full, [used] of [total] used"
- Cleanable space: "[amount] can be cleaned"
- Semantic labels for all interactive elements

### Dynamic Type
- All text respects user's preferred text size
- Layout adjusts for larger text sizes
- Minimum touch targets maintained at 44pt

## Error States

### No Storage Data
- Gray progress circle at 0%
- Text shows "Calculating..." or loading state
- Cleanable space indicator hidden

### Storage Calculation Error
- Progress circle shows last known state
- Error message replaces cleanable space indicator
- Retry button provided

## Integration Points

### Data Sources
- **Storage Info**: From `ImageRepository.getStorageInfo()`
- **Cleanable Space**: From scan results (`ScanResult.totalCleanableSpace`)
- **Updates**: Real-time updates from `HomeViewModel.storageInfo`

### User Interactions
- Tap on dashboard could trigger detailed storage breakdown (future feature)
- Cleanable space indicator taps could scroll to suggestions section
- Progress circle could show animated breakdown of file types (future enhancement)

This dashboard design balances visual appeal with functional clarity, providing users with immediate insight into their storage situation while encouraging action through the cleanable space indicator.
