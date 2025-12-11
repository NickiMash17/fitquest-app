# ♿ Accessibility Quick Start Guide

**Priority**: 🔴 Critical  
**Estimated Time**: 2-3 days  
**Impact**: Enables app for all users, improves App Store ratings

---

## Why Accessibility Matters

- **Legal Compliance**: WCAG 2.1 AA is required in many regions
- **User Base**: 15% of users have disabilities
- **Better UX**: Accessibility improvements benefit all users
- **App Store**: Required for App Store and Play Store

---

## Quick Implementation Checklist

### Day 1: Core Accessibility

#### 1. Add Semantics to All Buttons

```dart
// Before
PremiumButton(
  label: 'Add Activity',
  onPressed: () {},
)

// After
Semantics(
  label: 'Add new activity',
  hint: 'Opens form to log exercise, meditation, hydration, or sleep',
  button: true,
  child: PremiumButton(
    label: 'Add Activity',
    onPressed: () {},
  ),
)
```

**Files to Update**:
- `lib/shared/widgets/premium_button.dart`
- All button usages

#### 2. Add Labels to Form Inputs

```dart
// Before
TextField(
  decoration: InputDecoration(hintText: 'Email'),
)

// After
Semantics(
  label: 'Email address',
  textField: true,
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Email',
      hintText: 'Enter your email address',
    ),
  ),
)
```

**Files to Update**:
- `lib/features/authentication/pages/login_page.dart`
- `lib/features/authentication/pages/signup_page.dart`
- `lib/features/activities/pages/add_activity_page.dart`
- `lib/features/goals/widgets/create_goal_dialog.dart`

#### 3. Add Semantics to Plant Widget

```dart
Semantics(
  label: 'Plant companion at ${stageName} stage, ${health}% health',
  hint: 'Double tap to view plant details',
  image: true,
  child: CustomPlantWidget(...),
)
```

**Files to Update**:
- `lib/shared/widgets/custom_plant_widget.dart`
- `lib/features/home/widgets/enhanced_plant_card.dart`

---

### Day 2: Navigation & Focus

#### 4. Add Focus Management

```dart
class _LoginPageState extends State<LoginPage> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Focus(
            focusNode: _emailFocus,
            child: TextField(...),
          ),
          Focus(
            focusNode: _passwordFocus,
            child: TextField(...),
          ),
        ],
      ),
    );
  }
}
```

#### 5. Add Keyboard Navigation

```dart
// Add to all lists
Semantics(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => Semantics(
      label: 'Activity ${index + 1} of ${items.length}',
      child: ActivityCard(items[index]),
    ),
  ),
)
```

#### 6. Add Screen Reader Support

```dart
// Announce important changes
void _onPlantEvolved() {
  SemanticsService.announce(
    'Congratulations! Your plant evolved to ${newStage}',
    TextDirection.ltr,
  );
}

// Live regions for dynamic content
Semantics(
  liveRegion: true,
  child: Text('XP: ${currentXp}'),
)
```

---

### Day 3: Visual Accessibility

#### 7. Verify Color Contrast

```dart
// Use theme-aware colors
final textColor = Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : Colors.black87;

// Ensure 4.5:1 contrast
Text(
  'Important text',
  style: TextStyle(
    color: textColor, // High contrast
  ),
)
```

#### 8. Add Focus Indicators

```dart
// Visible focus indicators
Focus(
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Theme.of(context).focusColor,
        width: 2,
      ),
    ),
    child: Button(...),
  ),
)
```

#### 9. Support Text Scaling

```dart
// Use relative font sizes
Text(
  'Label',
  style: TextStyle(
    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
  ),
)

// Or use theme text styles (they scale)
Text(
  'Label',
  style: Theme.of(context).textTheme.bodyLarge,
)
```

---

## Testing Accessibility

### 1. Enable Screen Reader

**iOS**: Settings → Accessibility → VoiceOver  
**Android**: Settings → Accessibility → TalkBack

### 2. Test Keyboard Navigation

**Web**: Tab through all interactive elements  
**Desktop**: Use keyboard only

### 3. Use Accessibility Scanner

**Android**: Install "Accessibility Scanner" from Play Store  
**iOS**: Use VoiceOver Inspector

### 4. Automated Testing

```dart
// Add to widget tests
testWidgets('button is accessible', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  final semantics = tester.getSemantics(find.byType(Button));
  expect(semantics.label, isNotEmpty);
  expect(semantics.hint, isNotEmpty);
});
```

---

## Common Patterns

### Interactive Card

```dart
Semantics(
  label: '${cardTitle} card',
  hint: 'Double tap to open',
  button: true,
  onTap: onTap,
  child: Card(
    onTap: onTap,
    child: Content(...),
  ),
)
```

### Icon Button

```dart
Semantics(
  label: 'Delete activity',
  hint: 'Removes this activity from your history',
  button: true,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: onDelete,
  ),
)
```

### Progress Indicator

```dart
Semantics(
  label: 'Progress: ${progress}%',
  value: '${currentValue} of ${totalValue}',
  child: LinearProgressIndicator(value: progress),
)
```

---

## Priority Order

1. **Buttons & Links** (Highest impact)
2. **Form Inputs** (Critical for usability)
3. **Images & Icons** (Visual content)
4. **Navigation** (App structure)
5. **Dynamic Content** (Live regions)

---

## Resources

- [Flutter Accessibility](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)

---

**Start with buttons and form inputs - these have the highest impact!**

