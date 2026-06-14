# Aiko Ben Expense App — Revival Design Spec

**Date:** 2026-06-14  
**Status:** Approved — ready for implementation plan  
**Ship target:** Personal / couple use via TestFlight  
**Scope:** Shared household data model + modern UI/UX + P0 bug fixes

---

## 1. Goals

### Success criteria (v1.0)

- Ben and Aiko each have **separate Firebase Auth accounts**
- Both join the **same household** and see the same transactions, budget, and categories in real time
- App installs via **TestFlight** and is usable daily without crashes
- UI feels **modern and cohesive** — not a prototype with hardcoded colors and placeholder layouts
- Daily expense reminders work per person

### Out of scope (v1.0)

- Public App Store release
- Android build
- Profile photo upload / Firebase Storage
- Category drag-to-reorder
- Password reset UI polish
- Anonymous sign-in
- Cloud Functions
- Dark mode (design tokens should support it later, but not implemented in v1.0)

---

## 2. Shared household architecture

### 2.1 Concept

```
Firebase Auth (per person)          Firestore (shared)
┌─────────────┐                     ┌──────────────────────────┐
│ Ben's uid   │──member────────────▶│ households/{householdId} │
│ Aiko's uid  │──member────────────▶│   transactions           │
└─────────────┘                     │   budget, categories     │
                                    └──────────────────────────┘
```

| Layer | Scope | Data |
|-------|-------|------|
| Auth | Per person | Login, display name, email |
| Household | Shared | Transactions, budget, categories |
| User prefs | Per person | Notification time |

### 2.2 Firestore schema

```
users/{uid}
├── householdId: string | null
├── notificationTime?: Timestamp
└── createdAt: Timestamp

households/{householdId}
├── name: string                    # e.g. "Ben & Aiko"
├── inviteCode: string              # 6 uppercase alphanumeric chars
├── monthlyBudget: number
├── selectedCategoryIds: string[]
├── categories: map<id, { categoryName, categoryIcon }>
├── createdBy: string               # uid of creator
└── createdAt: Timestamp

households/{householdId}/members/{uid}
├── displayName: string
├── role: "owner" | "member"
└── joinedAt: Timestamp

households/{householdId}/transactions/{transactionId}
├── transactionId: string
├── dateTime: Timestamp
├── categoryId: string
├── transactionAmount: number
├── transactionComment: string
├── createdByUid: string
└── createdByName: string           # denormalized for list display

inviteCodes/{code}
└── householdId: string             # flat lookup for join flow
```

### 2.3 User flows

**First user (creator)**
```
Sign in → no householdId → HouseholdSetupScreen
  → "Create household" → enter name
  → app creates household + inviteCodes doc + owner member doc
  → sets users/{uid}.householdId
  → show invite code in Settings → Household
  → Home
```

**Second user (joiner)**
```
Sign in → no householdId → HouseholdSetupScreen
  → "Join household" → enter 6-char code
  → lookup inviteCodes/{code} → validate household exists
  → check member count < 2 (couple cap for v1.0)
  → add members/{uid}, set users/{uid}.householdId
  → Home
```

**Returning user**
```
Sign in → householdId set → Home (skip setup)
```

### 2.4 Household settings (new screen)

- Household name (editable by any member)
- Invite code with copy-to-clipboard button
- Member list with initials avatars
- Leave household (confirm dialog; v1.0: warn that data stays with household)

**Couple cap:** Max 2 members. Join rejected with friendly message if full.

### 2.5 Code changes

**New files**
- `lib/models/household.dart`
- `lib/services/household_service.dart`
- `lib/services/user_bootstrap.dart`
- `lib/screens/household/household_setup_screen.dart`
- `lib/screens/setting/household_settings_screen.dart`
- `firestore.rules`

**Modified files**
- `lib/models/user.dart` — add `householdId`
- `lib/models/transaction.dart` — add `createdByUid`, `createdByName`
- `lib/services/database.dart` — read/write by `householdId`
- `lib/screens/wrapper.dart` — auth → household gate → app
- `lib/screens/navigation.dart` — pass `householdId`, lift category fetch
- All screens using `DatabaseService(uid:)` → `DatabaseService(householdId:)`
- `lib/screens/home/transactions_list/transaction_tile.dart` — show `createdByName`

**Wrapper routing**
```dart
if (user == null) return Authenticate();
if (user.householdId == null) return HouseholdSetupScreen();
return Navigation(householdId: user.householdId!);
```

### 2.6 Security rules (draft)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isMember(householdId) {
      return request.auth != null &&
        exists(/databases/$(database)/documents/households/$(householdId)/members/$(request.auth.uid));
    }

    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    match /inviteCodes/{code} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /households/{householdId} {
      allow read, update: if isMember(householdId);
      allow create: if request.auth != null;

      match /members/{memberId} {
        allow read: if isMember(householdId);
        allow create: if request.auth != null && request.auth.uid == memberId;
      }

      match /transactions/{txId} {
        allow read, write: if isMember(householdId);
      }
    }
  }
}
```

### 2.7 Data migration

**Recommended: Option A — fresh start**

Wipe dev Firestore data. Both users create/join a new household on TestFlight.

**Option B — one-time migration (if dev data must be kept)**

On login, if `settings/{uid}` exists and `users/{uid}.householdId` is null:
1. Create household from old settings
2. Copy transactions to `households/{id}/transactions`
3. Set `users/{uid}.householdId`

Default: **Option A**.

---

## 3. P0 bug fixes (must ship with household work)

| # | Fix | File(s) |
|---|-----|---------|
| 1 | Unified onboarding via `ensureUserSettings()` on every auth path | `user_bootstrap.dart`, auth screens |
| 2 | Only call `addDefaultSetting` on successful register | `register.dart` |
| 3 | Wire `NotificationService.initNotification()` in `main.dart` | `main.dart` |
| 4 | Remove anonymous sign-in button | `sign_in.dart` |
| 5 | Fix Settings crash on null `displayName` | `settings.dart` |
| 6 | Budget shows **remaining** (budget − spent), not cap | `set_budget_and_donut_chart.dart` |
| 7 | Fix broken test + enable `flutter analyze` in CI | `test/`, `.github/workflows/flutter.yml` |
| 8 | Use device timezone instead of hardcoded `America/Los_Angeles` | `main.dart` |

---

## 4. Modern UI/UX design

### 4.1 Current UI problems

| Issue | Where |
|-------|-------|
| Inconsistent typography — RockSalt + Montserrat references, Montserrat not bundled | `constants.dart`, auth, home |
| `google_fonts` imported but theme doesn't use it | `constants.dart` |
| Hardcoded `% of screen height` containers — fragile on different iPhones | `home.dart`, auth screens |
| Finance pig watermark on every screen — repetitive, dated | auth, home, settings |
| Plain `ListTile` + default `Card` for transactions | `transaction_tile.dart` |
| Clunky nested boxes for spending summary | `daily_and_monthly_total.dart` |
| Colors applied inline, not via design tokens | throughout |
| No shared widget library | — |
| No empty states | transaction list |
| No household context in UI | — |
| Category row is flat icon buttons | `category_icon_button.dart` |

### 4.2 Design direction

**Aesthetic:** Calm, modern fintech — clean surfaces, generous whitespace, confident typography. Think Copilot Money / Monarch-lite, not spreadsheet.

**Personality:** Warm enough for a couple app (soft neutrals, one accent color), professional enough to use daily.

**Principles**
1. **One design system** — all colors, type, spacing from tokens; no inline `Color(0xFF...)` in screens
2. **Content first** — household name + spending summary is the hero; decorative assets removed
3. **Touch-friendly** — 48dp min tap targets, rounded 16px cards, smooth bottom sheets
4. **Attribution visible** — show who logged each expense (supports shared household)
5. **Progressive disclosure** — quick add from home; details in bottom sheet

### 4.3 Design tokens

**New file structure**
```
lib/core/theme/
├── app_colors.dart
├── app_typography.dart
├── app_spacing.dart
└── app_theme.dart

lib/shared/widgets/
├── app_card.dart
├── app_scaffold.dart
├── amount_text.dart
├── category_chip.dart
├── member_avatar.dart
├── section_header.dart
├── summary_card.dart
└── empty_state.dart
```

**Color palette**

| Token | Value | Use |
|-------|-------|-----|
| `background` | `#F7F6F3` | Scaffold background (warm off-white) |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceVariant` | `#F0EEE9` | Secondary cards, chips |
| `primary` | `#4F46E5` | Buttons, active nav, accents (indigo) |
| `primaryContainer` | `#EEF2FF` | Selected category, budget ring bg |
| `secondary` | `#059669` | Positive / under-budget indicator |
| `error` | `#DC2626` | Over budget, validation |
| `textPrimary` | `#1C1917` | Headlines, amounts |
| `textSecondary` | `#78716C` | Labels, subtitles |
| `textTertiary` | `#A8A29E` | Hints, disabled |
| `border` | `#E7E5E4` | Card borders, dividers |
| `categoryAccent` | `#818CF8` | Category icon tint |

**Typography** (via `google_fonts` — use `Plus Jakarta Sans`)

| Style | Size / Weight | Use |
|-------|---------------|-----|
| `displayLarge` | 48 / w600 | Amount entry |
| `headlineLarge` | 28 / w600 | Screen titles |
| `headlineSmall` | 20 / w600 | Section headers |
| `titleMedium` | 16 / w600 | Card titles |
| `bodyLarge` | 16 / w400 | Transaction comments |
| `bodyMedium` | 14 / w400 | Secondary text |
| `labelMedium` | 12 / w500 | Chips, badges |
| `labelSmall` | 11 / w500 | Tab labels |

**Spacing scale:** 4, 8, 12, 16, 20, 24, 32, 48  
**Radius:** sm=8, md=12, lg=16, xl=24, full=pill  
**Elevation:** cards use 0 elevation + 1px `border` (flat modern); sheets use shadow

### 4.4 Screen-by-screen redesign

#### Auth (`sign_in.dart`, `register.dart`)

**Before:** Pig watermark, RockSalt "Sign in" title, outline inputs, anon button  
**After:**
- Full-screen `background` color, no watermark
- App mark: simple wordmark "Aiko" in `headlineLarge` + tagline "Track together"
- Filled text fields with `surface` bg, `border` outline, 12px radius
- Primary filled button for sign-in; outlined for Google
- Remove anonymous sign-in
- SafeArea + keyboard-aware scroll
- Subtle top gradient optional (`primaryContainer` → `background`)

#### Household setup (new)

- Two large option cards: "Create household" / "Join with code"
- Create: name field + primary CTA
- Join: 6-box code input (monospace, auto-uppercase)
- On success: celebration state showing invite code (create) or household name (join)
- Illustration: simple icon, not pig photo

#### Home (`home.dart`)

**Before:** Date text + calendar icon, two clunky boxes, horizontal category scroll, flat list  
**After:**

```
┌─────────────────────────────────────┐
│  Ben & Aiko          [calendar]     │  ← household name + date picker
│  Thursday, 14 Jun                   │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │  $127 today  ·  $1,842 month │    │  ← unified SummaryCard
│  │  ○○○○○○○○  $358 left         │    │  ← budget ring inline
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  [🛒] [🏠] [✈️] [🍽] [+ more]       │  ← CategoryChip row
├─────────────────────────────────────┤
│  Today                              │
│  ┌─────────────────────────────┐    │
│  │ 🛒 Groceries    Ben   $42   │    │  ← AppCard + MemberAvatar
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 🍽 Dinner       Aiko  $28   │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

- Replace `% height` containers with `Flexible` / intrinsic sizing
- Remove pig watermark
- Empty state: "No expenses yet — tap a category to add one"
- Transaction groups by date with sticky-style headers

#### Add / edit transaction (bottom sheet)

- Larger `displayLarge` amount with `$` prefix, centered
- Category name + icon chip at top
- Comment field: single line, subtle
- Date: tappable row (not raw text field)
- Custom numeric keypad: rounded keys, `surfaceVariant` bg, primary tint on press
- Save button: full-width primary at bottom

#### Insights (`insights.dart`)

- Segmented control for Week / Month / Year (replace or style existing tabs)
- Charts use palette colors (`primary`, `categoryAccent`, `secondary`)
- Card wrapper around each chart with `section_header`
- Total amount hero at top of each dashboard

#### Settings (`settings.dart`)

- iOS-style grouped sections:
  - **Account** — name, email
  - **Household** — name, invite code, members
  - **Preferences** — categories, notifications
  - **Sign out**
- Profile header: large `MemberAvatar` + name (no crash on null displayName)
- Remove pig watermark

#### Navigation bar

- Keep Material 3 `NavigationBar`
- Apply `primary` to selected icon/label
- `surface` background with top `border`

### 4.5 Shared widgets spec

**`SummaryCard`** — daily total, monthly total, budget remaining in one card  
**`AppCard`** — white surface, 16px radius, 1px border, 16px padding  
**`CategoryChip`** — icon + optional label, tap opens add sheet  
**`MemberAvatar`** — circle with initials, 24px (list) or 48px (settings)  
**`AmountText`** — formatted currency with tabular figures  
**`EmptyState`** — icon + title + subtitle, centered  
**`SectionHeader`** — date group label in transaction list  
**`AppScaffold`** — SafeArea + consistent background, optional household header

### 4.6 Assets

| Asset | Action |
|-------|--------|
| `finance_pig.jpg` | Remove from screen backgrounds; keep optionally for empty state or delete |
| `RockSalt-Regular.ttf` | Remove from app UI; keep only if brand wordmark desired in splash |
| `app-icon.png` | Regenerate with modern icon during TestFlight prep |

### 4.7 Dependencies

| Package | Action |
|---------|--------|
| `google_fonts` | **Use properly** — primary typeface |
| `percent_indicator` | Keep for budget ring |
| `syncfusion_flutter_charts` | Keep for v1.0 (community license); restyle colors |
| `flutter_animate` | **Add** (optional) — subtle fade-in on cards, 200ms |
| Unused: `rxdart`, `keyboard_actions` | Remove |

---

## 5. Implementation phases

### Phase 0 — Foundation (1 day)
- Create `lib/core/theme/` design system
- Create `lib/shared/widgets/` base components
- Replace `getCustomTheme()` with `AppTheme.light`
- Upgrade FlutterFire + fix CI

### Phase 1 — Household backend (3–4 days)
- `HouseholdService` + Firestore schema
- Refactor `DatabaseService` to `householdId`
- `user_bootstrap.dart` + P0 bug fixes
- `firestore.rules`
- Wrapper routing + household setup screen (functional, not polished)

### Phase 2 — UI redesign (3–4 days)
- Auth screens
- Home + transaction list + tiles (with `createdByName`)
- Add/edit bottom sheet + keypad
- Settings + household settings
- Insights chart styling
- Remove pig watermarks, inline colors

### Phase 3 — TestFlight (1 day)
- Bundle ID: `com.aikoben.expense` (or user preference)
- Re-run FlutterFire CLI
- Archive + upload
- Smoke test both accounts

**Total estimate: ~2 weeks**

### Agent branch order

1. `feat/design-system` — theme tokens + shared widgets
2. `feat/household-schema` — models, service, rules, bootstrap
3. `refactor/database-household` — DatabaseService by householdId
4. `feat/household-setup-ui` — setup + settings screens
5. `feat/ui-auth` — auth redesign
6. `feat/ui-home` — home + transactions + add sheet
7. `feat/ui-settings-insights` — settings, insights polish
8. `chore/testflight-prep` — bundle ID, cleanup, deploy

---

## 6. Test plan

### Household
- [ ] Ben creates household, receives invite code
- [ ] Aiko joins with code, sees empty shared ledger
- [ ] Ben adds transaction → appears on Aiko's device in real time
- [ ] Aiko edits/deletes → Ben sees update
- [ ] Budget change by either user → both see updated remaining amount
- [ ] Third user join attempt → rejected (2-member cap)
- [ ] Each user sets own notification → both reminders fire

### UI
- [ ] All screens use theme tokens (no inline colors)
- [ ] No layout overflow on iPhone SE and iPhone 15 Pro Max
- [ ] Empty transaction list shows empty state
- [ ] Transaction tile shows who entered (`createdByName`)
- [ ] Google sign-in user doesn't crash on Settings

### Regression
- [ ] Email register + sign-in works
- [ ] Google sign-in works
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes

---

## 7. Open decisions

| Decision | Recommendation | Status |
|----------|----------------|--------|
| Data migration | Fresh start (Option A) — wipe dev Firestore | **Confirmed** |
| Bundle ID | `com.aikoben.expense` | **Confirmed** |
| Syncfusion vs fl_chart | Keep Syncfusion for v1.0 | Approved (couple/personal) |
| Dark mode | Defer to v1.1 | Approved |
| Subtle animations (`flutter_animate`) | Add | Proposed |

---

## 8. References

- Current theme: `lib/shared/constants.dart`
- Current home layout: `lib/screens/home/home.dart`
- Firebase project: `aiko-ben-expense-app`
- Prior audit: conversation 2026-06-14
