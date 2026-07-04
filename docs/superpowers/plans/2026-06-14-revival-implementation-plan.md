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
- [x] Modernize register screen to match sign-in
- [x] Replace home spending boxes with `SummaryCard`
- [x] Apply `AppCard` + `MemberAvatar` to transaction tiles

**Verify:** `flutter run -d "iPhone 15 Pro"` → sign-in shows new theme

---

## Phase 1 — P0 bug fixes

### Task 1: User bootstrap service

**Files:**

- Create: `lib/services/user_bootstrap.dart`
- Modify: `lib/main.dart`, `lib/screens/authenticate/register.dart`

- [x] Create `ensureUserDocument(uid)` writing `users/{uid}` with `householdId: null`, `createdAt`
- [x] Fix `register.dart` — call bootstrap + household seed only inside `if (result is User?)` success branch
- [x] Call `NotificationService.initNotification()` in `main.dart` after Firebase init
- [x] Replace hardcoded timezone with `flutter_timezone` or device local

**Verify:** Register with bad password does not crash; notifications init without error

### Task 2: Settings null safety

**Files:**

- Modify: `lib/screens/setting/settings.dart`, `lib/screens/setting/account_screen.dart`

- [x] Use `displayName ?? 'User'` for avatar initials
- [x] Remove pig watermark from settings

### Task 3: Budget remaining

**Files:**

- Modify: `lib/screens/home/spending_and_budget/set_budget_and_donut_chart.dart`

- [x] Show `budget - spent` as primary label, not raw budget cap

### Task 4: CI

**Files:**

- Modify: `.github/workflows/flutter.yml`, `pubspec.yaml`

- [x] Enable `flutter analyze` in CI
- [x] Move `mockito`, `flutter_launcher_icons` to dev_dependencies
- [x] Add `timezone` as explicit dependency

**Verify:** `flutter test && flutter analyze` pass

---

## Phase 2 — Household backend ✅

### Task 5: Household model + service

**Files:**

- Create: `lib/models/household.dart`
- Create: `lib/services/household_service.dart`
- Modify: `lib/models/user.dart`, `lib/services/auth_service.dart`

- [x] Add `householdId` to app `User` model (load from `users/{uid}` doc)
- [x] Implement `createHousehold(name, uid, displayName)` → household + inviteCodes + member + users.householdId
- [x] Implement `joinHousehold(code, uid, displayName)` → validate cap 2, add member, set householdId
- [x] Implement `householdStream(householdId)`, `membersStream(householdId)`, `updateHouseholdName`
- [x] Generate 6-char uppercase invite codes (no ambiguous chars); write `inviteCodes/{code}`
- [x] `AuthService.user` streams `householdId` live by switching the `users/{uid}` listener on each auth change (fixes a logout hang — see Phase 2.5)

### Task 6: Refactor DatabaseService

**Files:**

- Modify: `lib/services/database.dart`
- Modify: `lib/models/transaction.dart`

- [x] Replace `uid` with `householdId` for transaction paths: `households/{id}/transactions/`
- [x] Move settings reads/writes to household doc (budget, categories, selectedCategoryIds)
- [x] Add `createdByUid`, `createdByName` on new transactions
- [x] Update helper functions: `getHouseholdCategoriesMap`, `getHouseholdSelectedCategoryIds`, `updateHouseholdSelectedCategoryIds`, `updateHouseholdCategoryName`
- [x] Drop `addDefaultSetting` from register/sign-in (defaults now seeded on household create); notification time moved to `users/{uid}`

### Task 7: Firestore rules

**Files:**

- Create: `firestore.rules`, `firebase.json`, `.firebaserc`, `firestore.indexes.json`

- [x] Deploy rules from spec section 2.6 (membership-gated) to project `aiko-ben-expense-app`
- [x] Fix join flow: allow signed-in `get` on a household + read members so a non-member can join via code before membership exists
- [ ] Wipe old `settings/` and `transactions/` collections in Firebase Console (fresh start)

### Task 8: Routing + setup UI

**Files:**

- Create: `lib/screens/household/household_setup_screen.dart`
- Create: `lib/screens/setting/household_settings_screen.dart`
- Modify: `lib/screens/wrapper.dart`, `lib/screens/navigation.dart`

- [x] Wrapper: auth → householdId check → setup or Navigation
- [x] Setup screen: create / join flows
- [x] Household settings: name, invite code copy, member list (owner badge)
- [x] Pass `householdId` through Navigation to DatabaseService (screens read it from the `User` provider)

**Verify:** ✅ Covered by automated E2E tests (Phase 2.5) — create + join, shared ledger, 2-member cap.

---

## Phase 2.5 — End-to-end testing & stability ✅

**Files:**

- Create: `integration_test/household_e2e_test.dart`
- Modify: `lib/main.dart` (emulator wiring behind `USE_EMULATOR`), `pubspec.yaml` (`integration_test`), `firebase.json` (emulator ports)
- Modify: `lib/services/auth_service.dart`, `lib/screens/setting/settings.dart`, `lib/screens/single_transaction/numeric_keypad.dart` (bug/UI fixes surfaced by tests)

- [x] `integration_test` harness running the real app against the Firebase Emulator Suite (Auth + Firestore, loads `firestore.rules`)
- [x] `main.dart` connects to emulators when `--dart-define=USE_EMULATOR=true`; skips notification init under emulator; idempotent across test app launches
- [x] E2E test 1: sign up → household gate → create household → add transaction (asserts Firestore write + `createdByName`) → household settings/invite code → **logout**
- [x] E2E test 2: second account joins via invite code → shared ledger (same `householdId`, 2 members) → third account blocked by 2-member cap
- [x] **Bug fix:** logout never returned to sign-in — `authStateChanges().asyncExpand(users/{uid}.snapshots())` never completed the inner stream, so the sign-out event was dropped. Rewritten to manually switch the doc subscription.
- [x] **Bug fix:** swallow `permission-denied` on the `users/{uid}` listener during sign-out
- [x] UI fixes: Settings `ListTile` wrapped in `Material` (background warning); keypad date button no longer overflows

**Run:**

```bash
firebase emulators:start --only auth,firestore
flutter test integration_test/household_e2e_test.dart \
  -d "iPhone 17 Pro" --dart-define=USE_EMULATOR=true
```

**Status:** `All tests passed!` (2/2), zero exceptions.
**Not automated:** Google Sign-In (external web flow) — manual check only.

---

## Phase 3 — UI redesign (remaining screens) ✅

**Status:** Complete. `flutter analyze` clean (only pre-existing infos); E2E suite
`All tests passed!` (2/2) on iPhone 17 Pro against the emulator, zero RenderFlex
overflows / zero caught exceptions.

### Task 9: Home screen ✅

**Files:**

- Rewrote: `lib/screens/home/home.dart` — `AppScaffold` with live household-name
  header (via `getHouseholdName`) + date subtitle + calendar trailing button.
- Rewrote: `daily_and_monthly_total.dart` → `SpendingSummary` widget rendering the
  shared `SummaryCard` (daily/monthly/budget ring); tap opens an edit-budget dialog
  writing `monthlyBudget` on the household doc (live via `snapshots()`).
- Rewrote: `transaction_tile.dart` — `AppCard` row, category icon chip, `AmountText`,
  and `MemberAvatar` + name for `createdByName`.
- Updated: `transactions_list.dart` — themed date-group headers (`Today`/`Yesterday`/
  date + group total), per-row `Dismissible` with rounded delete background, threads
  `createdByName`, and `EmptyState` ("No expenses yet — tap a category above…").
- Deleted: `category_icon_button.dart` (replaced by `CategoryChip` whose `onTap`
  opens the add sheet) and `set_budget_and_donut_chart.dart` (folded into
  `SpendingSummary`).

- [x] Use `AppScaffold` with household name header
- [x] Replace spending boxes with `SummaryCard`
- [x] Use `CategoryChip` horizontal list
- [x] `AppCard` transaction rows with `MemberAvatar` for `createdByName`
- [x] `EmptyState` when no transactions
- [x] Remove pig watermark

### Task 10: Add/edit transaction sheet ✅

**Files:**

- `add_or_edit_single_transaction.dart` — drag handle, centered category label,
  centered `displayLarge` amount with `$` prefix, themed description field
  (`surfaceVariant` fill), keypad pinned to bottom. Field order preserved
  (amount index 0, description index 1) for the E2E harness.
- `numeric_keypad.dart` — theme tokens throughout; **made the keypad flex-based**
  (`Expanded` 3:1 columns) instead of `MediaQuery` width fractions, fixing a 28px
  horizontal overflow once the sheet gained side padding. Digit keys stay
  `TextButton`, Submit stays `ElevatedButton` (E2E finders).

- [x] Theme-aligned amount display, keypad buttons, save button

### Task 11: Insights + Settings ✅

**Files:**

- `insights.dart` — `AppScaffold` title + pill/segmented `TabBar`
  (surfaceVariant track, surface indicator).
- Chart widgets (`expense_by_category_bar_chart`, `month/week/year_expense_spline_chart`,
  `total_amount`) — replaced hardcoded `0xFF6200EE` with palette
  (`primary`/`secondary`/`categoryAccent`); themed total hero text.
- `settings.dart` — rewrote with `AppScaffold`, `MemberAvatar` profile header
  (null-safe), grouped `ACCOUNT` / `PREFERENCES` sections in `AppCard` (tiles
  wrapped in a transparent `Material` to avoid the ListTile-ink assertion), themed
  destructive `Log Out` (kept as `TextButton` for E2E).
- `register.dart` — rebuilt to mirror `sign_in.dart` (SafeArea + scroll, headline
  "Create account", themed fields, `FilledButton` "Sign up", "Sign in" toggle);
  removed pig watermark. Updated E2E `_signUp` finders accordingly.

- [x] Chart colors from AppColors
- [x] Grouped settings sections
- [x] Register matches sign-in layout

---

## Phase 4 — TestFlight prep

### Task 12: Bundle ID + Firebase

- [x] Change iOS bundle ID to `com.aikoben.expense` (Runner + RunnerTests in
  `project.pbxproj`) and Android `applicationId` to `com.aikoben.expense` in
  `android/app/build.gradle` (Kotlin `namespace` left as-is so `MainActivity`
  doesn't move; `applicationId` is what the store/Firebase use).
- [x] Regenerate app icon — generated `assets/icon/app_icon.png` (1024², two
  overlapping circles + `$` on indigo) and wired `flutter_launcher_icons`
  (`remove_alpha_ios: true`, indigo adaptive icon). Ran the generator → all iOS
  + Android icons regenerated. Also removed the unused `finance_pig.jpg` asset.
- [ ] **Pending (user, interactive):** `flutterfire configure` for the new bundle
  ID to re-register the iOS/Android apps and regenerate `firebase_options.dart` +
  `GoogleService-Info.plist`. Build will not run on device until this + signing
  Team are set. The app will NOT build/connect to Firebase until this is done.

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

