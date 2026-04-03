# GigReady - Setlist & Lyrics Manager for iPad
## Visual Overview & Setup Guide

### 🎯 What You'll See

The app has **6 main screens** organized in a navigation hierarchy:

---

## **Screen 1: Authentication**
**When you first launch the app**

```
┌─────────────────────────────┐
│                             │
│         🎵 GigReady         │
│  Setlist & Lyrics Manager   │
│                             │
│                             │
│    [Get Started] ────→ Login│
│        (Blue Button)        │
│                             │
│                             │
└─────────────────────────────┘
```

**What it does:**
- Anonymous login to Firebase
- No authentication required
- One tap to start using the app

---

## **Screen 2: Venue List (Home)**
**Main hub for organizing by location**

```
┌─────────────────────────────┐
│  ← Back          [+]         │ ← Add button
├─────────────────────────────┤
│                             │
│  ┌──────────────────────┐  │
│  │  🏢 Madison Square   │  │
│  │      Garden          │  │
│  │  Location: NYC       │  │
│  │  📍 3 performances   │  │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │  🏟️  Red Rocks       │  │
│  │      Amphitheatre    │  │
│  │  Location: Denver    │  │
│  │  📍 5 performances   │  │
│  └──────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Features:**
- Grid of venues
- Quick stats (number of performances)
- Tap to see performances at that venue

---

## **Screen 3: Performance List**
**Manage setlists for a specific venue**

```
┌──────────────────────────┐
│  ← Back   Madison Square  │
│         Garden    [+]     │
├──────────────────────────┤
│                          │
│ Spring Tour 2024      →  │
│ 📅 Mar 15, 2024         │
│ 🎵 Set 1: 8 songs       │
│ 🎵 Set 2: 6 songs       │
│ 🎵 Set 3: 4 songs       │
│                          │
│ Summer Residency      →  │
│ 📅 Jun 1, 2024          │
│ 🎵 Set 1: 12 songs      │
│                          │
│ Studio Sessions       →  │
│ 📅 Jul 10, 2024         │
│ 🎵 Set 1: 5 songs       │
│                          │
└──────────────────────────┘
```

**Features:**
- List of performances
- Quick view of setlist info
- Tap to edit that setlist

---

## **Screen 4: Setlist Manager (Main Home Screen)**
**The core workspace with sets and songs**

```
┌─────────────────────────────────────────────────────┐
│ ← Back    Spring Tour 2024     ⋮ Menu              │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ │  SET 1   │ │  SET 2   │ │  SET 3   │ │  SET 4   │
│ │  (8)     │ │  (6)     │ │  (4)     │ │  (3)     │
│ ├──────────┤ ├──────────┤ ├──────────┤ ├──────────┤
│ │          │ │          │ │          │ │          │
│ │ Bohemian │ │ Imagine  │ │ Stairway │ │ Hey Jude │
│ │ Rhapsody │ │          │ │ to       │ │          │
│ │          │ │ Let It Be │ │ Heaven  │ │ Come     │
│ │ Don't    │ │          │ │          │ │ Together │
│ │ Stop     │ │ With or  │ │ Black    │ │          │
│ │ Me Now   │ │ Without  │ │ Dog      │ │ Yesterday│
│ │          │ │ You      │ │          │ │          │
│ │ Another  │ │          │ │ Hotel    │ │ Helter   │
│ │ One Bites│ │ My       │ │ California││ Skelter  │
│ │ the Dust │ │ Immortal │ │          │ │          │
│ │          │ │          │ │          │ │          │
│ │ ▼ Drop   │ │ ▼ Drop   │ │ ▼ Drop   │ │ ▼ Drop   │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘
│
│ ┌───────────────────────────────────────────────────┐
│ │  🎵 Extra Songs                    (12 available) ▼│
│ │                                                   │
│ │  If you seek Amy (Tempo: 124)      + Add to Set  │
│ │  Toxic (Tempo: 103)                + Add to Set  │
│ │  Seven (Tempo: 98)                 + Add to Set  │
│ │  ...                                              │
│ └───────────────────────────────────────────────────┘
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Features:**
- 4 scrollable set columns with songs
- Drag & drop songs between sets
- Extra songs dropdown (searchable)
- Sort options (alphabetical, tempo, randomize)
- Add songs button in menu
- Import button to add songs from files/Ultimate Guitar

---

## **Screen 5: Song Detail View**
**Perform with real-time lyrics and chords**

```
┌──────────────────┬────────────────────────────────┐
│  ← Back   [Edit] │ LYRICS & CHORDS                │
├──────────────────┼────────────────────────────────┤
│                  │                                │
│ Song Name        │ Am           F                 │
│ Bohemian Rhapsody│ Is this the real life?        │
│                  │ C            G                 │
│ Tempo: 55 BPM    │ Is this just fantasy?         │
│ Cap: Required    │                                │
│ Chords: 24       │ Am           F                 │
│                  │ Caught in a landslide         │
│ ┌──────────────┐ │ C            G                 │
│ │ Edit Mode    │ │ No escape from reality        │
│ │              │ │                                │
│ │ On Edit:     │ │ (Tap words in edit mode      │
│ │ + Tap word to│ │  to add/remove chords)       │
│ │  add chord   │ │                                │
│ │ ✏️ Existing   │ │                                │
│ │   to edit    │ │                                │
│ │ 🗑️ to delete │ │                                │
│ └──────────────┘ │                                │
│                  │                                │
│                  │ [Scroll for more lyrics]      │
│                  │                                │
└──────────────────┴────────────────────────────────┘
```

**Features:**
- Two-column layout (info left, lyrics right)
- Edit button to enter chord management mode
- Tap any word to add/edit/delete chords
- Chord selector with grid of main chords
- Search functionality for complex chords (Am7, Cadd9, etc.)
- Real-time chord display above lyrics
- Back button returns to setlist

---

## **Screen 6: Import View**
**Add songs from multiple sources**

```
┌─────────────────────────────────────────────────────┐
│  🔍 Song Title or Artist      [Search]              │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ✅ Ultimate Guitar Search                           │
│ ├─ Bohemian Rhapsody - Queen                        │
│ │  ⭐ 4.8/5 (1,234 ratings)  [Import] [Visit Site]  │
│ │                                                   │
│ ├─ Bohemian Rhapsody - Various Artists             │
│ │  ⭐ 4.5/5 (432 ratings)   [Import] [Visit Site]   │
│                                                     │
│ ✅ Import Files                                     │
│ ├─ [📄 Choose PDF/Text]  [📸 Take Photo (OCR)]    │
│ │                                                   │
│ ├─ Recently imported:                               │
│ │  ✓ Stairway to Heaven                            │
│ │    Source: PDF | 45 chords                       │
│                                                     │
│ ✅ Preview & Save                                   │
│ ├─ 1 song ready to import                           │
│ │  Bohemian Rhapsody                               │
│ │  • 240 lyric lines                               │
│ │  • 24 chords detected                            │
│ │  [Save to Setlist] [Clear]                       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Features:**
- Three tabs: Ultimate Guitar, Files, Preview
- Search and browse Ultimate Guitar tabs
- Import from PDFs, Word docs, text files
- OCR support for photos of printed tabs
- Batch import multiple files
- Preview chords and lyrics before saving
- Save directly to Extra Songs

---

## **Screen 7: Backup View**
**Sync and backup your setlists**

```
┌─────────────────────────────┐
│  Settings > Backup & Restore│
├─────────────────────────────┤
│                             │
│ ☁️ iCloud Sync              │
│ ✅ Connected                │
│ Last synced: Today at 3:45 PM
│ [Sync Now]                  │
│                             │
│ 💾 Manual Backup            │
│ [⬇️ Export]  [⬆️ Import]     │
│                             │
│ 📋 Backup History           │
│ ├─ Spring Tour (Manual)     │
│ │  Today at 2:15 PM         │
│ │  iPad (current device)    │
│ │                           │
│ ├─ Hourly Backup (iCloud)   │
│ │  Today at 3:00 PM         │
│ │  iPad Pro 12.9"           │
│                             │
└─────────────────────────────┘
```

**Features:**
- iCloud sync status and manual sync
- Export setlists as JSON files
- Import previously exported backups
- Backup history with timestamps
- Device tracking
- Manual deletion of old backups

---

## 🚀 How to Run This App

### **Option 1: Open in Xcode (Recommended)**

1. **Open the project:**
   ```bash
   cd /home/user/gigready
   open GigReady.xcodeproj
   ```

2. **Install Firebase pods:**
   ```bash
   pod install
   open GigReady.xcworkspace
   ```

3. **Select target:**
   - Select "GigReady" from the scheme dropdown
   - Select "iPad (Air)" or your preferred simulator

4. **Run:**
   - Press `Cmd + R` or click the Play button
   - Wait for the simulator to build and launch

### **Option 2: Build from Command Line**

```bash
# Install pods
cd /home/user/gigready
pod install

# Build for simulator
xcodebuild -workspace GigReady.xcworkspace \
  -scheme GigReady \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath build

# Run simulator
xcrun simctl launch booted com.example.GigReady
```

---

## 📊 Architecture Summary

```
┌─────────────────────────────────────────────────────┐
│  SwiftUI Views (iPad-optimized, two-column layouts) │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────┐  ┌──────────────────┐        │
│  │  ViewModels     │  │  Firebase        │        │
│  │  (State Mgmt)   │◄─┤  Service         │        │
│  └─────────────────┘  └──────────────────┘        │
│         ▲                                           │
│         │                                           │
│  ┌─────────────────────────────────────────────┐   │
│  │  Data Models (Codable)                      │   │
│  │  • Song, Setlist, Venue, Performance        │   │
│  │  • ChordPlacement, SetGroup                 │   │
│  └─────────────────────────────────────────────┘   │
│         ▲                                           │
│         │                                           │
│  ┌─────────────────────────────────────────────┐   │
│  │  Services                                   │   │
│  │  • FileImportService (PDF, Word, OCR)      │   │
│  │  • ChordExtractorService (Regex)           │   │
│  │  • UltimateGuitarService (API)             │   │
│  │  • CloudKitSyncService (iCloud)            │   │
│  │  • ChordLibraryService (Chord DB)          │   │
│  └─────────────────────────────────────────────┘   │
│         ▲                                           │
│         │                                           │
│  ┌─────────────────────────────────────────────┐   │
│  │  Firebase Realtime Database                 │   │
│  │  • Cloud storage for setlists & songs       │   │
│  │  • Real-time sync across devices            │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Verification Checklist

When you run the app, verify these features work:

- [ ] **Authentication**: Tap "Get Started" - anonymous login works
- [ ] **Venue Management**: Create new venues, add performances
- [ ] **Setlist View**: See 4 set columns with sample songs
- [ ] **Drag & Drop**: Drag a song between sets (visual feedback shows)
- [ ] **Extra Songs**: Dropdown shows songs, search filters them
- [ ] **Song Detail**: Tap a song, see two-column layout with lyrics
- [ ] **Edit Mode**: Click edit, tap words to add chords
- [ ] **Chord Selector**: Grid shows chords, search works
- [ ] **Chord Display**: Chords appear above lyrics
- [ ] **Import**: Try importing a PDF or text file with lyrics
- [ ] **OCR**: Take a screenshot and import it
- [ ] **Backup**: Enable iCloud sync and create manual backup
- [ ] **Settings**: Access backup view from menu

---

## 📱 Supported Devices

- **iPad** (All sizes - optimized for iPad)
- **iPad Pro** (12.9", 11", 10.5")
- **iPad Air** (4th gen and later)
- **iPad mini** (6th gen and later)

---

## 🔧 Configuration Notes

### Firebase Setup
The app expects Firebase configuration in your project. You'll need to:
1. Create a Firebase project at console.firebase.google.com
2. Enable Firebase Authentication (Anonymous)
3. Enable Firebase Realtime Database
4. Add GoogleService-Info.plist to Xcode project

### CocoaPods Dependencies
```
Firebase/Core
Firebase/Auth
Firebase/Database
Firebase/Storage (for future features)
```

---

## 📝 Next Steps

1. ✅ **Setup**: Run `pod install` to install Firebase
2. ✅ **Open**: Open `GigReady.xcworkspace` in Xcode
3. ✅ **Configure**: Add GoogleService-Info.plist from Firebase
4. ✅ **Run**: Build and run on iPad simulator
5. ✅ **Test**: Go through verification checklist above
6. ✅ **Develop**: Make refinements and polish
7. ✅ **Submit**: Follow App Store submission guidelines

---

Enjoy using GigReady! 🎵
