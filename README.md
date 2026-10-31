<div align="center">

  <br />

  <img src="./assets/pokedex.png" alt="Pokédex Flutter Logo" width="130" height="130" style="border-radius: 32px; box-shadow: 0 16px 36px rgba(0,0,0,0.18);" />

  # **POKÉDEX**
  ### *An Offline-First, High-Performance Pokémon Encyclopedia & Battle Suite*

  <p align="center">
    <b>Crafted with Flutter 3.x • Dart 3.12+ • Riverpod 3 • Drift (SQLite) • Material Design 3</b>
  </p>

  <p align="center">
    <a href="https://f-droid.org"><img src="https://img.shields.io/badge/F--Droid-Ready-1976D2?style=for-the-badge&logo=fdroid&logoColor=white" alt="F-Droid" /></a>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.12+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
    <a href="https://drift.simonbinder.eu/"><img src="https://img.shields.io/badge/Drift-Offline_DB-388E3C?style=for-the-badge" alt="Drift" /></a>
    <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod_3-673AB7?style=for-the-badge" alt="Riverpod" /></a>
    <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge" alt="License" /></a>
  </p>

  <p align="center">
    <a href="#-highlights">Highlights</a> •
    <a href="#-feature-suite">Feature Suite</a> •
    <a href="#-tools--battle-utilities">Battle Tools</a> •
    <a href="#-tech-stack--architecture">Architecture</a> •
    <a href="#-getting-started">Getting Started</a> •
    <a href="#-building-for-f-droid--offline-apk">Builds</a> •
    <a href="#-privacy-manifesto">Privacy</a> •
    <a href="#-license--disclaimer">Legal</a>
  </p>

  <br />

</div>

---

## ⚡ Highlights

<table>
  <tr>
    <td width="50%">
      <h3>📶 Offline-First by Architecture</h3>
      <ul>
        <li>Pre-seeded SQLite database powered by <b>Drift</b>.</li>
        <li>Instant startup, ultra-responsive queries, and zero load spinners for core data.</li>
        <li>Local asset fallback for artwork, home sprites, shiny variants, and types.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🛡️ 100% Free & F-Droid Compliant</h3>
      <ul>
        <li>Zero trackers, zero analytics, zero ad frameworks.</li>
        <li>Clean, reproducible build structure suitable for F-Droid inclusion.</li>
        <li>Pure open-source dependencies without proprietary Google Play Services.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🎙️ Next-Gen UX & Voice Search</h3>
      <ul>
        <li><b>Voice Search</b> enabled with Speech-to-Text for instant lookup.</li>
        <li>Silky 60/120 FPS transitions and tactile haptic feedback.</li>
        <li>Adaptive Material 3 theme switching (Light / Dark).</li>
      </ul>
    </td>
    <td width="50%">
      <h3>⚔️ Competitive Toolset</h3>
      <ul>
        <li>Full <b>Team Builder</b> with weakness matrices and move customization.</li>
        <li><b>Speed Tiers</b> benchmark and <b>Pokémon Comparator</b>.</li>
        <li>Breeding egg group compatibility calculator.</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🧭 Feature Suite

```
  ┌────────────────────────────────────────────────────────────────────────┐
  │                         POKÉDEX FLUTTER                                │
  ├────────────────┬─────────────────┬──────────────────┬──────────────────┤
  │   Pokédex UI   │  Battle Detail  │  Tactical Tools  │     Settings     │
  │ • Voice Search │ • Base Stats/EV │ • Team Builder   │ • Theme Modes    │
  │ • Gen Filters  │ • Learnsets     │ • Speed Tiers    │ • Shiny Toggles  │
  │ • Type Badges  │ • Audio Cries   │ • Egg Breeding   │ • Local Storage  │
  │ • Fast Grid    │ • Evolutions    │ • Head-to-Head   │ • Database Stats │
  └────────────────┴─────────────────┴──────────────────┴──────────────────┘
```

### 🔴 1. National Pokédex & Rapid Exploration
* **Generations 1 through 9:** Comprehensive, fast-scrolling Pokémon grid with dynamic card styling based on primary typing.
* **Smart Filtering:** Filter by single or dual types, generation batches, or sort by standard/reverse national dex numbers.
* **Voice Search:** Tap the mic icon to search any Pokémon hands-free using speech recognition.
* **Artwork & Shiny Toggles:** Instant switching between standard HOME sprites and shiny variants.

### 🔵 2. Species Detail & Anatomy
* **Radar & Stat Bars:** Base HP, Attack, Defense, Sp. Atk, Sp. Def, and Speed visual charts with stat EV yields.
* **Damage Effectiveness:** Interactive defensive table calculating incoming damage factors (`4×`, `2×`, `½×`, `¼×`, `0×`).
* **Categorized Learnsets:** Moves organized by Level-up, TM/HM, Egg, and Tutor with power, accuracy, damage class, and PP.
* **Evolution Trees:** Interactive visual pathways supporting multi-branching evolutions (Eevee, Tyrogue, Wurmple) with condition requirements.
* **Authentic Audio Cries:** Native high-quality creature cry playback via `audioplayers`.

---

## 🧰 Tools & Battle Utilities

A dedicated hub of competitive tools built specifically for trainers:

* **🛡️ Team Builder:** Construct custom 6-Pokémon squads. Customize held items, abilities, and 4 moves per member. Analyze team-wide defensive weaknesses to patch holes.
* **⚡ Speed Tiers:** Live tier list comparing Pokémon base speeds, max speed under +Speed natures, Choice Scarf boosts, and Tailwind modifiers.
* **⚔️ Head-to-Head Comparator:** Side-by-side comparison of any two Pokémon, evaluating stat differences, type advantages, and movepool overlap.
* **🥚 Egg & Breeding Calculator:** Quickly identify compatible egg groups and breeding partners.
* **📖 Reference Hubs:**
  * **Moves Database:** Search all moves by category, power, type, and secondary effect chance.
  * **Items Database:** Full compendium of competitive held items, battle items, and evolution stones.
  * **Abilities Database:** In-depth breakdown of battle and field ability mechanics.
  * **Natures Matrix:** 25-nature reference chart detailing boosted (+10%) and hindered (-10%) stats.
  * **Type Effectiveness Matrix:** Complete 18×18 elemental interaction table.

---

## 🏗️ Tech Stack & Architecture

Built following Clean Architecture principles, leveraging **Riverpod** for reactive state management and **Drift** for robust local persistence:

```
lib/
├── app/                  # App initialization, GoRouter routes, and Material 3 theme
├── core/                 # Shared utilities, type charts, voice search, and preferences
├── data/
│   ├── api/              # Dio HTTP client for PokéAPI synchronization
│   ├── database/         # Drift SQLite schema, migrations, and pre-seeded tables
│   └── repositories/     # Data repositories bridging API & local database
├── features/
│   ├── pokedex/          # Grid view, filtering sheets, and search bars
│   ├── pokemon_detail/   # About, Stats, Defense, Moves, and Evolution tabs
│   ├── tools/            # Team builder, speed tiers, comparator, items & breeding
│   └── settings/         # Theme toggles and storage management
└── models/               # Freezed data models (Pokemon, Move, Item, Ability)
```

| Component | Library | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | Multi-platform UI toolkit targeting Android, iOS, Web, Desktop |
| **State Management** | [flutter_riverpod 3](https://riverpod.dev) | Compile-safe, reactive state and dependency injection |
| **Local Database** | [Drift (drift_flutter)](https://drift.simonbinder.eu/) | Type-safe, high-speed SQLite persistence |
| **Navigation** | [go_router](https://pub.dev/packages/go_router) | Declarative routing with deep link support |
| **Networking** | [Dio](https://pub.dev/packages/dio) | Robust HTTP client with caching & interceptors |
| **Data Models** | [Freezed](https://pub.dev/packages/freezed) | Immutable data classes & JSON serialization |
| **Audio Engine** | [audioplayers](https://pub.dev/packages/audioplayers) | Low-latency native audio playback |
| **Speech** | [speech_to_text](https://pub.dev/packages/speech_to_text) | Device-level voice recognition |

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.0`)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / VS Code with Flutter extension
* Android Device or Emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/pokedex-flutter.git
   cd pokedex-flutter
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Drift & Freezed code:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run on your connected device:**
   ```bash
   flutter run
   ```

---

## 📦 Building for F-Droid & Offline APK

The app is architected with zero non-free dependencies, making it 100% compliant with F-Droid build standards:

```bash
# Build standalone release APK
flutter build apk --release

# Or build split per-ABI APKs (smaller file sizes)
flutter build apk --release --split-per-abi
```

*Your production APK will be available at:*  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Privacy Manifesto

* **Zero Trackers & Zero Ads:** No Google Firebase, no ad SDKs, and no background telemetry.
* **Local Offline Processing:** All Pokémon stats, calculations, speed tiers, and teams run entirely on-device via Drift SQLite.
* **Minimal Permissions:** 
  * Internet: For initial online sprite caching from PokéAPI.
  * Microphone: Optional, utilized exclusively during active voice search sessions.

---

## 📄 License & Disclaimer

This project is licensed under the **MIT License**.

> **Legal Disclaimer:**  
> *Pokémon and Pokémon character names, artwork, sprites, and audio cries are trademarks and copyrights of Nintendo, Creatures Inc., and Game Freak Inc. This is an unofficial, non-profit, community-driven educational app created under fair use policies and is in no way affiliated with or endorsed by Nintendo or The Pokémon Company.*

<br />

<div align="center">
  <sub>Crafted with passion for Pokémon trainers. Star ⭐ this repository if you find it helpful!</sub>
</div>
