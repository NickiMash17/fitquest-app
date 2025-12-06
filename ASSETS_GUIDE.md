# Image Assets Guide

This document outlines all the image assets needed for the premium FitQuest app experience.

## Required Image Assets

### Plant Companion Images
Location: `assets/images/companion/`

- `seed.png` - Initial stage (evolution stage 0-1)
- `sprout.png` - Early growth (evolution stage 2-3)
- `sapling.png` - Mid growth (evolution stage 4-5)
- `tree.png` - Mature plant (evolution stage 6+)

**Recommended specs:**
- Size: 200x200px minimum
- Format: PNG with transparency
- Style: Cute, friendly, nature-themed illustrations

### Activity Images
Location: `assets/images/activities/`

#### Main Activity Images
- `exercise.png` - Exercise activity type
- `meditation.png` - Meditation activity type
- `hydration.png` - Hydration activity type
- `sleep.png` - Sleep activity type

#### Quick Action Images
- `workout.png` - Quick workout action
- `meditate.png` - Quick meditation action
- `hydrate.png` - Quick hydration action
- (sleep.png can be reused)

#### Placeholder Images
- `exercise_placeholder.png`
- `meditation_placeholder.png`
- `hydration_placeholder.png`
- `sleep_placeholder.png`

**Recommended specs:**
- Size: 128x128px minimum
- Format: PNG with transparency
- Style: Modern, minimalist icons or illustrations

### Achievement Badge Images
Location: `assets/images/badges/`

#### Badge Images by Type and Rarity
Format: `{type}_{rarity}.png`

**Types:**
- `streak` - Streak achievements
- `xp` - XP achievements
- `activities` - Activity count achievements
- `level` - Level achievements
- `special` - Special achievements

**Rarities:**
- `common` - Common badges
- `rare` - Rare badges
- `epic` - Epic badges
- `legendary` - Legendary badges

**Examples:**
- `streak_common.png`
- `xp_rare.png`
- `activities_epic.png`
- `level_legendary.png`
- `special_legendary.png`

#### Locked Badge Images
- `locked_common.png`
- `locked_rare.png`
- `locked_epic.png`
- `locked_legendary.png`

#### Placeholder
- `placeholder.png` - Generic badge placeholder

**Recommended specs:**
- Size: 128x128px minimum
- Format: PNG with transparency
- Style: Badge/medal design with rarity-appropriate colors

### Onboarding Images
Location: `assets/images/onboarding/`

- `slide1.png` - Track Your Wellness
- `slide2.png` - Grow Your Companion
- `slide3.png` - Compete & Connect

**Recommended specs:**
- Size: 400x400px minimum
- Format: PNG with transparency
- Style: Modern illustrations matching app theme

## Image Generation Tips

### Using AI Image Generators
1. **Plant Companion Images:**
   - Prompt: "Cute friendly plant illustration, seed/sprout/sapling/tree, green, nature theme, simple style, transparent background"
   - Use consistent art style across all stages

2. **Activity Images:**
   - Prompt: "Modern minimalist icon, [activity type], fitness wellness, simple clean design, transparent background"
   - Keep consistent style and color palette

3. **Achievement Badges:**
   - Prompt: "Gaming badge design, [rarity] quality, [type] theme, medal style, transparent background"
   - Use color coding: Common (gray), Rare (blue), Epic (purple), Legendary (gold)

4. **Onboarding Images:**
   - Prompt: "Modern illustration, wellness fitness app, [slide theme], friendly colorful, transparent background"

### Using Design Tools
- **Figma/Adobe Illustrator:** Create vector illustrations, export as PNG
- **Canva:** Use templates, customize, export as PNG with transparency
- **Placeholder Services:** Use placeholder.com or similar for temporary images

## Temporary Placeholders

Until actual images are added, the app will gracefully fall back to:
- Icon-based placeholders
- Shimmer loading effects
- Error widgets with icons

## Image Optimization

Before adding to the app:
1. Optimize images using tools like:
   - TinyPNG (tinypng.com)
   - ImageOptim
   - Squoosh (squoosh.app)
2. Target file sizes:
   - Small icons: < 50KB
   - Medium images: < 200KB
   - Large images: < 500KB
3. Use appropriate formats:
   - PNG for images with transparency
   - WebP for better compression (if supported)

## Asset Organization

```
assets/
├── images/
│   ├── companion/
│   │   ├── seed.png
│   │   ├── sprout.png
│   │   ├── sapling.png
│   │   └── tree.png
│   ├── activities/
│   │   ├── exercise.png
│   │   ├── meditation.png
│   │   ├── hydration.png
│   │   ├── sleep.png
│   │   ├── workout.png
│   │   ├── meditate.png
│   │   ├── hydrate.png
│   │   └── *_placeholder.png
│   ├── badges/
│   │   ├── streak_common.png
│   │   ├── streak_rare.png
│   │   ├── ... (all combinations)
│   │   ├── locked_common.png
│   │   └── placeholder.png
│   └── onboarding/
│       ├── slide1.png
│       ├── slide2.png
│       └── slide3.png
```

## Testing

After adding images:
1. Test on different screen sizes
2. Verify hero animations work correctly
3. Check loading states (shimmer effects)
4. Test error states (missing images)
5. Verify image quality on high-DPI displays

