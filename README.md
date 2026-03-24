# WO Inventory — iOS App

iPhone version of the WO Inventory Android app.
Same features, same data, built with **Swift + SwiftUI + SQLite3**.

---

## Features

| Feature | Details |
|---------|---------|
| Work order list | Card view with all 13 fields |
| Sort | Picker at top — sort by any field |
| Search | Full-text search across all fields |
| Add / Edit | Native form sheet |
| Delete | Per-row confirmation or "Delete All" |
| Seed data | Auto-loads `data.csv` on first launch |
| Persistence | SQLite database in the app's Documents folder |

---

## Project structure

```
WO_crud_database_ipa/
├── WOInventory.xcodeproj/          ← Open this in Xcode
│   ├── project.pbxproj
│   └── project.xcworkspace/
└── WOInventory/                    ← All source files
    ├── WOInventoryApp.swift        ← App entry point
    ├── WorkOrder.swift             ← Data model
    ├── DatabaseManager.swift       ← SQLite3 wrapper (CRUD)
    ├── CSVParser.swift             ← Parses data.csv
    ├── WorkOrderViewModel.swift    ← State / business logic
    ├── ContentView.swift           ← Main list screen
    ├── WorkOrderRowView.swift      ← Card view per record
    ├── WorkOrderFormView.swift     ← Add / Edit form
    ├── Extensions.swift            ← Color helpers
    ├── data.csv                    ← Seed data (partial)
    ├── Assets.xcassets/
    └── Info.plist
```

---

## Opening in Xcode (requires a Mac)

1. Copy this folder to a Mac (or clone it).
2. Open `WOInventory.xcodeproj` in **Xcode 15** or later.
3. Select your iPhone or a simulator as the run destination.
4. Press **⌘R** to build and run.

> **First launch** — the app will seed ~149 records from `data.csv`.
> To use the full dataset, copy `data.csv` from the Android project:
> `WO_crud_database/app/src/main/assets/data.csv`
> and replace `WOInventory/data.csv` before building.

---

## Requirements

- Xcode 15+
- iOS 16.0+ deployment target
- No external dependencies (uses built-in SQLite3)

---

## Architecture

```
View (SwiftUI)  ←→  WorkOrderViewModel (ObservableObject)
                          ↕
                    DatabaseManager (SQLite3)
```

- **MVVM** with `@EnvironmentObject`
- **Combine** for reactive search / sort
- **SQLite3** (system framework, no CocoaPods / SPM needed)
