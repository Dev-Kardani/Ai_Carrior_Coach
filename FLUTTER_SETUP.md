# Flutter SDK Installation Guide

This guide will help you install Flutter SDK and all required dependencies for the AI Career Coach app.

## Prerequisites

- Windows 10 or later (64-bit)
- At least 2.5 GB of free disk space
- Administrator access to your computer

## Automated Installation (Recommended)

### Step 1: Download Flutter SDK

1. **Download Flutter SDK manually**:
   - Visit: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
   - Click **"Download Flutter SDK"**
   - Save the ZIP file (approximately 1.5GB)

2. **Extract Flutter**:
   - Extract the downloaded ZIP file to `C:\` (so you have `C:\flutter`)
   - **Important**: Do NOT extract to `C:\Program Files\` as it requires elevated privileges

### Step 2: Add Flutter to PATH

1. **Open Environment Variables**:
   - Press `Win + X` and select **"System"**
   - Click **"Advanced system settings"**
   - Click **"Environment Variables"**

2. **Edit PATH**:
   - Under **"User variables"**, find and select **"Path"**
   - Click **"Edit"**
   - Click **"New"**
   - Add: `C:\flutter\bin`
   - Click **"OK"** on all dialogs

3. **Restart PowerShell**:
   - Close all PowerShell/Command Prompt windows
   - Open a new PowerShell window

### Step 3: Verify Flutter Installation

Open a **new** PowerShell window and run:

```powershell
flutter doctor
```

You should see Flutter checking your system. Don't worry about warnings for now.

### Step 4: Accept Android Licenses (if using Android)

```powershell
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

### Step 5: Install Project Dependencies

Navigate to your project and install dependencies:

```powershell
cd c:\Users\HP\.gemini\antigravity\scratch\ai_career_coach
flutter pub get
```

## Manual Installation Steps

If you prefer manual installation:

### 1. Download Flutter

- Go to: [https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip)
- Save to your Downloads folder

### 2. Extract Flutter

```powershell
# Run in PowerShell as Administrator
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter_windows_*-stable.zip" -DestinationPath "C:\"
```

### 3. Add to PATH

```powershell
# Add Flutter to User PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

### 4. Restart PowerShell

Close and reopen PowerShell, then verify:

```powershell
flutter --version
```

## Troubleshooting

### "Flutter not recognized" after installation

**Solution 1: Restart PowerShell**
- Close all PowerShell windows
- Open a new PowerShell window
- Try `flutter --version` again

**Solution 2: Verify PATH**
```powershell
$env:Path -split ';' | Select-String -Pattern 'flutter'
```

If you don't see `C:\flutter\bin`, add it manually:
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

**Solution 3: Use full path temporarily**
```powershell
C:\flutter\bin\flutter.bat doctor
```

### "cmdlet not found" errors

- Make sure you extracted Flutter to `C:\flutter` (not `C:\Program Files\flutter`)
- Verify the file `C:\flutter\bin\flutter.bat` exists
- Run PowerShell as Administrator

### Git not installed

Flutter requires Git. Install it from: [https://git-scm.com/download/win](https://git-scm.com/download/win)

## Required Dependencies

### For Android Development

1. **Android Studio**: [https://developer.android.com/studio](https://developer.android.com/studio)
2. **Android SDK**: Installed automatically with Android Studio
3. **Android Emulator**: Can be set up through Android Studio

### For Windows Desktop Development

```powershell
flutter config --enable-windows-desktop
```

## Verify Complete Setup

Run this command to check everything:

```powershell
flutter doctor -v
```

You should see:
- ✅ Flutter (Channel stable)
- ✅ Windows Version
- ✅ Android toolchain (if Android Studio is installed)
- ✅ VS Code or Android Studio
- ✅ Connected device

## Next Steps

Once Flutter is installed:

1. **Install project dependencies**:
   ```powershell
   cd c:\Users\HP\.gemini\antigravity\scratch\ai_career_coach
   flutter pub get
   ```

2. **Create `.env` file**:
   ```powershell
   Copy-Item .env.example .env
   ```

3. **Configure Supabase** (see [SUPABASE_SETUP.md](SUPABASE_SETUP.md))

4. **Run the app**:
   ```powershell
   flutter run
   ```

## Quick Reference Commands

```powershell
# Check Flutter version
flutter --version

# Check system setup
flutter doctor

# Update Flutter
flutter upgrade

# Install dependencies
flutter pub get

# Run app
flutter run

# Clean build files
flutter clean
```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Windows Setup](https://docs.flutter.dev/get-started/install/windows)
- [Flutter Doctor](https://docs.flutter.dev/get-started/install/windows#run-flutter-doctor)

---

**Need Help?** If you encounter any issues, check the [Troubleshooting](#troubleshooting) section above or open an issue on GitHub.
