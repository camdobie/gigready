# GigReady Setup Instructions

## Quick Start (5 minutes)

### Step 1: Install CocoaPods Dependencies
```bash
cd /home/user/gigready
pod install
```

### Step 2: Open in Xcode
```bash
open GigReady.xcworkspace
```
(Important: Use `.xcworkspace`, not `.xcodeproj`)

### Step 3: Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "GigReady"
3. Create an iOS app in that project
4. Download the `GoogleService-Info.plist` file
5. Drag it into Xcode (into the GigReady folder)
6. Make sure it's added to the `GigReady` target

### Step 4: Run the App
1. Select an iPad simulator from the top toolbar
2. Press `Cmd + R` or click the Play button
3. Wait for the app to build and launch

---

## What You'll See

**First Launch:**
- Authentication screen with "Get Started" button
- Tap to login (anonymous)

**Main Screen:**
- Venue list (tap to create your first venue)
- Create a performance
- Browse setlists and songs

**Features to Try:**
- ✅ Drag songs between sets
- ✅ Search in extra songs
- ✅ Tap a song to view/edit lyrics and chords
- ✅ Add chords by tapping words
- ✅ Import songs from PDFs, images, or text files
- ✅ Backup to iCloud or manually export

---

## Firebase Setup Details

### Enable Authentication
1. In Firebase Console → Authentication
2. Click "Sign-in method"
3. Enable "Anonymous"

### Enable Realtime Database
1. In Firebase Console → Realtime Database
2. Create a new database in test mode
3. Choose region

### Add Rules (for testing)
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

---

## Troubleshooting

### "Pod install" fails
```bash
# Update CocoaPods
sudo gem install cocoapods

# Try again
pod repo update
pod install
```

### Xcode can't find Firebase
- Make sure you opened `.xcworkspace`, not `.xcodeproj`
- Try: `pod deintegrate` then `pod install` again

### Simulator won't launch
- Try: Product → Clean Build Folder (`Cmd + Shift + K`)
- Then: Product → Run (`Cmd + R`)

### Firebase not connecting
- Check GoogleService-Info.plist is added to target
- Verify bundle identifier matches Firebase project
- Check internet connection

---

## File Structure

```
/home/user/gigready/
├── GigReady.xcworkspace/        ← Open this in Xcode
├── GigReady.xcodeproj/          ← Don't open directly
├── Podfile                       ← Dependencies
├── Info.plist                    ← App configuration
├── GigReadyApp.swift             ← Main entry point
├── Models/                       ← Data structures
├── Views/                        ← UI screens
├── ViewModels/                   ← State management
├── Services/                     ← Firebase, Import, etc.
├── APP_OVERVIEW.md              ← Visual guide
└── SETUP.md                      ← This file
```

---

## Development Tips

### Adding New Features
1. Create the view in `Views/`
2. Create a ViewModel in `ViewModels/` if needed
3. Add navigation in parent views
4. Test in Xcode preview (`Cmd + Opt + P`)

### Testing in Simulator
- iPad Pro 12.9" is recommended (shows full UI)
- iOS 15+ supported
- Enable keyboard shortcuts: I/O → Input

### Debugging
- View console: View → Inspectors → Console
- Set breakpoints by clicking line numbers
- Use `print()` for logging

---

## Next Steps

1. ✅ Complete setup above
2. ✅ Test all features (see APP_OVERVIEW.md)
3. ✅ Customize Firebase configuration
4. ✅ Add your own songs and setlists
5. ✅ Test on physical iPad (if available)
6. ✅ Prepare for App Store submission

---

## App Store Submission

When ready to submit:

1. Update version number in Info.plist
2. Create app signing certificates in Apple Developer
3. Set bundle identifier: `com.yourcompany.gigready`
4. Create App Store listing
5. Build for App Store: Product → Destination → Any iOS Device (arm64)
6. Archive: Product → Archive
7. Upload in Xcode Organizer

---

Happy developing! 🎵
