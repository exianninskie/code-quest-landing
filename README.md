# ⚔️ Code Quest

A Flutter + Supabase game that teaches coding concepts through storytelling.
Players progress through narrative chapters, solving code puzzles to earn XP.

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Mobile app | Flutter (Dart) |
| State management | Riverpod |
| Navigation | go_router |
| Backend / DB | Supabase (PostgreSQL) |
| Auth | Supabase Auth (email + magic link) |
| CI/CD | GitHub Actions |

---

## 1. Prerequisites

Install these before anything else:

1. **Flutter SDK** → https://docs.flutter.dev/get-started/install
   - After installing, run `flutter doctor` and fix any issues shown
2. **Git** → https://git-scm.com
3. **VS Code** (recommended) → https://code.visualstudio.com
   - Install the **Flutter** and **Dart** extensions

---

## 2. Clone and install

```bash
git clone https://github.com/YOUR_USERNAME/code-quest.git
cd code-quest
flutter pub get
```

---

## 3. Set up Supabase (your backend)

Supabase is a free, open-source backend. Think of it as your database + login system.

### 3a. Create a project
1. Go to https://supabase.com and sign up for free
2. Click **New project**
3. Give it a name (e.g. `code-quest`) and a database password — save this password!
4. Choose a region close to you (e.g. Singapore for Bali)
5. Wait ~2 minutes for it to spin up

### 3b. Run the database migrations
1. In your Supabase dashboard, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open the file `supabase/migrations/001_initial_schema.sql` from this project
4. Copy all the SQL and paste it into the editor
5. Click **Run** — you should see "Success. No rows returned"

This creates all your tables: `profiles`, `chapters`, `puzzles`, `player_progress`.

### 3c. Get your API keys
1. In Supabase dashboard → **Settings** → **API**
2. Copy:
   - **Project URL** (looks like `https://abcxyz.supabase.co`)
   - **anon / public key** (the long string under "Project API keys")

---

## 4. Configure the app

Create a file called `.env` in the project root (this file is gitignored — never commit it):

```
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

To run the app with these values, use:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key-here
```

Or in VS Code, create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Code Quest (dev)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your-anon-key-here"
      ]
    }
  ]
}
```

---

## 5. Generate code (required before first run)

Some files are auto-generated from annotations. Run this once:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Re-run it any time you modify a model or provider marked with `@freezed` or `@riverpod`.

---

## 6. Run the app

```bash
flutter run
```

If you have both an Android emulator and a browser available, Flutter will ask which device to use.
For beginners, running in **Chrome** is the easiest way to start:

```bash
flutter run -d chrome
```

---

## 7. Set up GitHub

### 7a. Create the repo
1. Go to https://github.com/new
2. Name it `code-quest`, keep it private, click **Create repository**
3. Push your local code:

```bash
git init
git add .
git commit -m "feat: initial project setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/code-quest.git
git push -u origin main
```

### 7b. Add secrets for CI
The GitHub Actions workflow needs your Supabase keys.

1. On GitHub → your repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** and add:
   - Name: `SUPABASE_URL` — Value: your Supabase project URL
   - Name: `SUPABASE_ANON_KEY` — Value: your anon key

Now every push to `main` will automatically lint, test, and build the APK.

### 7c. Recommended branch workflow (beginner-friendly)

```
main      ← stable, protected. Only merge via pull request.
develop   ← your working branch
feature/  ← one branch per feature, e.g. feature/leaderboard
```

```bash
# Start a new feature
git checkout -b feature/add-loops-chapter

# Save your work
git add .
git commit -m "feat: add loops chapter with 3 puzzles"
git push origin feature/add-loops-chapter

# Then open a Pull Request on GitHub to merge into develop
```

---

## 8. Project structure

```
lib/
├── main.dart                  ← App entry point, Supabase init
├── core/
│   ├── router.dart            ← All app routes
│   └── theme.dart             ← Colors, fonts, button styles
├── models/
│   ├── chapter.dart           ← Chapter data model
│   ├── puzzle.dart            ← Puzzle data model
│   └── progress.dart          ← Player progress model
├── services/
│   ├── auth_service.dart      ← Sign up, sign in, sign out
│   └── game_service.dart      ← Fetch chapters, puzzles, save progress
└── screens/
    ├── splash_screen.dart
    ├── auth/login_screen.dart
    ├── home/home_screen.dart
    ├── game/chapter_screen.dart
    ├── game/puzzle_screen.dart
    └── profile/profile_screen.dart

supabase/
└── migrations/
    └── 001_initial_schema.sql ← Run this in Supabase SQL editor

.github/
└── workflows/
    └── ci.yml                 ← Automated lint + test + build
```

---

## 9. Next steps

Once this is running, here are good features to build next:

- **More puzzle types** — `fillInTheBlank`, `orderTheCode`, `spotTheBug`
- **Leaderboard screen** — query `profiles` ordered by `total_xp`
- **Streak tracking** — add a `last_active_at` column to `profiles`
- **Push notifications** — via Supabase Edge Functions + Firebase Messaging
- **Sound effects** — use the `audioplayers` package

---

## Common issues

| Problem | Fix |
|---------|-----|
| `flutter: command not found` | Add Flutter to your PATH — see flutter doctor output |
| `Could not find a file named 'pubspec.yaml'` | Make sure you're in the project root folder |
| `Supabase error: Invalid API key` | Double-check your --dart-define values match Supabase dashboard exactly |
| Build runner errors | Delete `.dart_tool/` folder and re-run `flutter pub run build_runner build --delete-conflicting-outputs` |
