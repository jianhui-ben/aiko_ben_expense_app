# Aiko Ben Expense App Revival — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a couple-ready expense app on TestFlight with shared household data, modern UI, and stable Firebase onboarding.

**Architecture:** Flutter + Provider streams; Firestore `households/{id}` for shared transactions/budget/categories; `users/{uid}` for household membership and personal notification prefs; design tokens in `lib/core/theme/` with shared widgets in `lib/shared/widgets/`.

**Tech Stack:** Flutter 3.x, Firebase Auth, Cloud Firestore, Provider, google_fonts (Plus Jakarta Sans), percent_indicator, Syncfusion charts (v1.0).

**Spec:** `docs/superpowers/specs/2026-06-14-shared-household-design.md`

**Confirmed decisions:** Fresh Firestore start | Bundle ID `com.aikoben.expense`

---

## Phase 0 — Design system ✅ (started)

- [x] Create `lib/core/theme/` (AppColors, AppSpacing, AppTypography, AppTheme)
- [x] Create shared widgets (AppCard, SummaryCard, CategoryChip, MemberAvatar, EmptyState, SectionHeader, AppScaffold, AmountText)
- [x] Wire `AppTheme.light` in `main.dart`
- [x] Modernize sign-in screen (remove pig watermark, anon login)
- [x] Fix `test/dummy_test.dart`
- [ ] Modernize register screen to match sign-in
- [ ] Replace home spending boxes with `SummaryCard`
- [ ] Apply `AppCard` + `MemberAvatar` to transaction tiles

**Verify:** `flutter run -d "iPhone 15 Pro"` → sign-in shows new theme

---

## Phase 1 — P0 bug fixes

### Task 1: User bootstrap service

**Files:**
- Create: `lib/services/user_bootstrap.dart`
- Modify: `lib/main.dart`, `lib/screens/authenticate/register.dart`

- [ ] Create `ensureUserDocument(uid)` writing `users/{uid}` with `householdId: null`, `createdAt`
- [ ] Fix `register.dart` — call bootstrap + household seed only inside `if (result is User?)` success branch
- [ ] Call `NotificationService.initNotification()` in `main.dart` after Firebase init
- [ ] Replace hardcoded timezone with `flutter_timezone` or device local

**Verify:** Register with bad password does not crash; notifications init without error

### Task 2: Settings null safety

**Files:**
- Modify: `lib/screens/setting/settings.dart`, `lib/screens/setting/account_screen.dart`

- [ ] Use `displayName ?? 'User'` for avatar initials
- [ ] Remove pig watermark from settings

### Task 3: Budget remaining

**Files:**
- Modify: `lib/screens/home/spending_and_budget/set_budget_and_donut_chart.dart`

- [ ] Show `budget - spent` as primary label, not raw budget cap

### Task 4: CI

**Files:**
- Modify: `.github/workflows/flutter.yml`, `pubspec.yaml`

- [ ] Enable `flutter analyze` in CI
- [ ] Move `mockito`, `flutter_launcher_icons` to dev_dependencies
- [ ] Add `timezone` as explicit dependency

**Verify:** `flutter test && flutter analyze` pass

---

## Phase 2 — Household backend

### Task 5: Household model + service

**Files:**
- Create: `lib/models/household.dart`
- Create: `lib/services/household_service.dart`
- Modify: `lib/models/user.dart`

- [ ] Add `householdId` to app `User` model (load from `users/{uid}` doc)
- [ ] Implement `createHousehold(name, uid, displayName)` → household + inviteCodes + member + users.householdId
- [ ] Implement `joinHousehold(code, uid, displayName)` → validate cap 2, add member, set householdId
- [ ] Implement `getHouseholdStream(householdId)`, `getMembers(householdId)`
- [ ] Generate 6-char uppercase invite codes; write `inviteCodes/{code}`

### Task 6: Refactor DatabaseService

**Files:**
- Modify: `lib/services/database.dart`
- Modify: `lib/models/transaction.dart`

- [ ] Replace `uid` with `householdId` for transaction paths: `households/{id}/transactions/`
- [ ] Move settings reads/writes to household doc (budget, categories, selectedCategoryIds)
- [ ] Add `createdByUid`, `createdByName` on new transactions
- [ ] Update helper functions: `getHouseholdCategoriesMap`, etc.

### Task 7: Firestore rules

**Files:**
- Create: `firestore.rules`

- [ ] Deploy rules from spec section 2.6
- [ ] Wipe old `settings/` and `transactions/` collections in Firebase Console (fresh start)

### Task 8: Routing + setup UI

**Files:**
- Create: `lib/screens/household/household_setup_screen.dart`
- Create: `lib/screens/setting/household_settings_screen.dart`
- Modify: `lib/screens/wrapper.dart`, `lib/screens/navigation.dart`

- [ ] Wrapper: auth → householdId check → setup or Navigation
- [ ] Setup screen: create / join flows
- [ ] Household settings: name, invite code copy, member list
- [ ] Pass `householdId` through Navigation to DatabaseService

**Verify:** Two simulators / accounts — create + join, shared transaction appears on both

---

## Phase 3 — UI redesign (remaining screens)

### Task 9: Home screen

**Files:**
- Modify: `lib/screens/home/home.dart`, `daily_and_monthly_total.dart`, `transaction_tile.dart`, `category_icon_button.dart`

- [ ] Use `AppScaffold` with household name header
- [ ] Replace spending boxes with `SummaryCard`
- [ ] Use `CategoryChip` horizontal list
- [ ] `AppCard` transaction rows with `MemberAvatar` for `createdByName`
- [ ] `EmptyState` when no transactions
- [ ] Remove pig watermark

### Task 10: Add/edit transaction sheet

**Files:**
- Modify: `add_or_edit_single_transaction.dart`, `numeric_keypad.dart`

- [ ] Theme-aligned amount display, keypad buttons, save button

### Task 11: Insights + Settings

**Files:**
- Modify: `insights.dart`, chart widgets, `settings.dart`, `register.dart`

- [ ] Chart colors from AppColors
- [ ] Grouped settings sections
- [ ] Register matches sign-in layout

---

## Phase 4 — TestFlight prep

### Task 12: Bundle ID + Firebase

- [ ] Change iOS bundle ID to `com.aikoben.expense` in Xcode + `android/app/build.gradle`
- [ ] Run `flutterfire configure` for new bundle ID
- [ ] Regenerate app icon

### Task 13: TestFlight upload

- [ ] Archive in Xcode, upload to App Store Connect
- [ ] Add internal testers (Ben + Aiko)
- [ ] Run full test plan from spec section 6

---

## UI testing quick reference

```bash
open -a Simulator
cd /Users/benben/Projects/aiko_ben_expense_app
flutter run -d "iPhone 15 Pro"
# Press `r` for hot reload after UI edits
```

---

## Agent branch order

1. `feat/design-system` — Phase 0 (in progress)
2. `fix/p0-bootstrap` — Task 1–4
3. `feat/household-schema` — Task 5–8
4. `feat/ui-home` — Task 9
5. `feat/ui-transactions-settings` — Task 10–11
6. `chore/testflight-prep` — Task 12–13
