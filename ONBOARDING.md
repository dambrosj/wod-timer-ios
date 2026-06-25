# WOD Timer iOS — Onboarding per AI Agent / Developer

> **Mandato fondamentale**: l'app iOS deve essere **identica** all'app Android sia per UI/UX che per funzionalità. Prima di implementare qualsiasi feature, leggere sempre la controparte Android come riferimento canonico.

---

## 1. Struttura dei progetti sul disco

```
~/Documents/progetti/
├── wod/          ← Android (Kotlin + Jetpack Compose) — fonte di verità
└── wod-ios/      ← iOS (Swift 6 + SwiftUI) — questo progetto
```

I due progetti devono restare in **parità completa**. Ogni feature presente su Android deve esistere su iOS con lo stesso comportamento.

---

## 2. Prerequisiti

| Tool | Versione minima | Verifica |
|------|----------------|---------|
| Xcode | 16.x | `xcodebuild -version` |
| xcodegen | qualsiasi | `xcodegen version` |
| iOS Simulator | iOS 26.5 / iPhone 17 | `xcrun simctl list devices` |
| Swift | 6.0 | già incluso in Xcode 16 |

**Installare xcodegen** se mancante:
```bash
brew install xcodegen
```

---

## 3. Setup iniziale (una tantum)

```bash
cd ~/Documents/progetti/wod-ios

# 1. Genera il progetto Xcode da project.yml
xcodegen generate

# 2. Verifica che sia stato creato
ls WodTimer.xcodeproj
```

`project.yml` è la sorgente di verità per la configurazione del progetto. **Non editare mai** `.xcodeproj` a mano — usare sempre `project.yml` + `xcodegen generate`.

---

## 4. Build

Tutti i comandi vanno lanciati da shell `zsh` (la bash di Claude ha alias che creano conflitti):

```bash
# Build per simulatore
zsh -c "cd ~/Documents/progetti/wod-ios && xcodebuild \
  -project WodTimer.xcodeproj \
  -scheme WodTimer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build 2>&1 | tail -5"
```

Output atteso: `** BUILD SUCCEEDED **`

### Aggiungere nuovi file Swift

1. Creare il file nella cartella corretta sotto `WodTimer/`
2. Eseguire `xcodegen generate` per aggiornare `.xcodeproj`
3. Ricompilare

Non serve toccare nulla di altro — `project.yml` include automaticamente tutto il contenuto di `WodTimer/`.

---

## 5. Avviare il Simulatore

### Boot e install

```bash
# ID del simulatore iPhone 17
SIM_ID=$(xcrun simctl list devices | grep 'iPhone 17' | grep -v Pro | grep -v Max | grep -v 'e ' | grep -oE '[A-F0-9-]{36}' | head -1)

# Boot (se non già avviato)
xcrun simctl boot $SIM_ID

# Percorso dell'app compilata
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/WodTimer-*/Build \
  -name 'WodTimer.app' -not -path '*/Index.noindex/*' | head -1)

# Termina eventuale istanza precedente, installa e avvia
xcrun simctl terminate $SIM_ID com.dambrosj.wod-timer 2>/dev/null
xcrun simctl install $SIM_ID "$APP_PATH"
xcrun simctl launch $SIM_ID com.dambrosj.wod-timer
```

### Aprire il Simulator.app (per vederlo)

```bash
open -a Simulator
```

### Rotazione nel Simulator

| Tasto | Azione |
|-------|--------|
| `Cmd+Left` | Ruota a sinistra (landscape) |
| `Cmd+Right` | Ruota a destra / torna portrait |

> **Nota**: l'app usa portrait lock su tutte le schermate tranne Timer e Completion. Il contenuto resta in portrait anche quando il device viene ruotato — stesso comportamento dell'app Android.

---

## 6. Struttura del codice iOS

```
WodTimer/
├── App/
│   ├── WodTimerApp.swift        # @main entry point + @UIApplicationDelegateAdaptor
│   ├── WodAppDelegate.swift     # supportedInterfaceOrientationsFor (portrait lock)
│   ├── OrientationManager.swift # lock(portrait:) via UIWindowScene.requestGeometryUpdate
│   ├── AppState.swift           # @Observable centrale: path, engine, store, logStore
│   └── RootView.swift           # NavigationStack + DrawerView overlay + onChange orientation
│
├── Domain/
│   ├── Model/
│   │   ├── TimerType.swift
│   │   ├── TimerConfig.swift    # enum con associated values per ogni tipo
│   │   ├── TimerPhase.swift     # stato tick-by-tick del timer
│   │   ├── SavedWod.swift
│   │   └── WorkoutLog.swift
│   └── Engine/
│       ├── BaseIntervalEngine.swift  # loop asincrono @MainActor, skip/pause/resume
│       ├── TabataEngine.swift
│       ├── AmrapEngine.swift
│       ├── ForTimeEngine.swift
│       ├── EmomEngine.swift
│       └── CustomEngine.swift
│
├── Data/
│   ├── SavedWodStore.swift      # @Observable, persiste su UserDefaults
│   ├── WorkoutLogStore.swift    # @Observable, persiste su UserDefaults
│   ├── SettingsStore.swift      # @Observable, persiste su UserDefaults
│   └── BuiltInWods.swift        # WOD predefiniti (equivalente Android built-in)
│
└── UI/
    ├── Theme/
    │   └── WodTheme.swift       # WodColors, WodSpacing (specchio esatto di Color.kt Android)
    ├── Home/HomeView.swift
    ├── Config/                  # Una View per tipo + ConfigScaffold + ConfigHelpers
    ├── Timer/TimerRunningView.swift
    ├── Completion/CompletionView.swift
    ├── Diary/                   # DiaryView + DiaryDetailView
    ├── Library/                 # WodsLibraryView + SavedWodCard
    ├── Drawer/DrawerView.swift
    ├── Settings/SettingsView.swift
    └── Components/              # ExercisesBlockView, NumberPickerView, ecc.
```

---

## 7. Struttura equivalente Android → iOS

| Android (`wod/`) | iOS (`wod-ios/`) |
|-----------------|-----------------|
| `ui/home/HomeScreen.kt` | `UI/Home/HomeView.swift` |
| `ui/config/TabataConfigScreen.kt` | `UI/Config/TabataConfigView.swift` |
| `ui/timer/TimerRunningScreen.kt` | `UI/Timer/TimerRunningView.swift` |
| `ui/completion/CompletionScreen.kt` | `UI/Completion/CompletionView.swift` |
| `ui/diary/DiaryScreen.kt` | `UI/Diary/DiaryView.swift` |
| `ui/diary/DiaryDetailScreen.kt` | `UI/Diary/DiaryDetailView.swift` |
| `ui/wods/WodsLibraryScreen.kt` | `UI/Library/WodsLibraryView.swift` |
| `ui/settings/SettingsScreen.kt` | `UI/Settings/SettingsView.swift` |
| `ui/theme/Color.kt` | `UI/Theme/WodTheme.swift` |
| `domain/engine/BaseIntervalEngine.kt` | `Domain/Engine/BaseIntervalEngine.swift` |
| `WodNavGraph.kt` (routing) | `App/RootView.swift` + `AppState.path` |
| `WodDrawerContent.kt` | `UI/Drawer/DrawerView.swift` |
| `ui/components/ExercisesBlock.kt` | `UI/Components/ExercisesBlockView.swift` |

---

## 8. Pattern architetturali chiave

### Navigation
- iOS usa `NavigationStack` con array `appState.path: [AppRoute]`
- Android usa NavController con route stringhe
- Equivalenza: `appState.path.append(.config(.tabata))` ↔ `navController.navigate(Routes.config("TABATA"))`

### State management
- iOS: `@Observable` + `@Environment` — nessun ViewModel separato
- Android: `StateFlow` + `ViewModel`
- Tutto lo stato globale è in `AppState`; i store (`SavedWodStore`, `WorkoutLogStore`, `SettingsStore`) sono proprietà di `AppState`

### Timer engine
- `BaseIntervalEngine` gira su `@MainActor` con un `Task` asincrono
- Loop: `for step in plan` → `while remaining >= 0` → sleep 20×50ms (non 1s pieno, per skip reattivo)
- `skip()` interrompe il sleep E sblocca la `pauseContinuation` se in pausa
- Android usa un `ForegroundService`; iOS usa un `Task` — comportamento equivalente ma iOS non sopravvive in background

### Orientation lock
- `WodAppDelegate.supportedInterfaceOrientationsFor` restituisce `.portrait` o `.allButUpsideDown`
- Il flag è `OrientationManager.allowLandscape`
- Viene aggiornato da `RootView.onChange(of: appState.path)`:
  - `.timer` e `.completion` → landscape libero
  - tutto il resto → portrait lock
- Per rilevare landscape dentro le view: `@Environment(\.verticalSizeClass)` — `.compact` = landscape su iPhone (NON usare `horizontalSizeClass` che rimane `.compact` anche in landscape su iPhone standard)

---

## 9. Colori e tema

Tutti i colori iOS devono essere identici agli hex Android in `Color.kt`:

| Token | Hex | Uso |
|-------|-----|-----|
| `bgPrimary` | `#0D0D0D` | Sfondo principale |
| `bgSurface` | `#1A1A1A` | Card, drawer |
| `bgElevated` | `#242424` | Elementi elevati |
| `textPrimary` | `#FFFFFF` | Testo principale |
| `textSecondary` | `#8C8C8C` | Testo secondario |
| `textDisabled` | `#404040` | Testo disabilitato |
| `divider` | `#2A2A2A` | Separatori |
| `iconDefault` | `#8C8C8C` | Icone |
| `accentAmrap` | `#4CAF50` | Verde |
| `accentForTime` | `#2196F3` | Blu |
| `accentEmom` | `#FF9800` | Arancione |
| `accentTabata` | `#E91E63` | Rosa |
| `accentCustom` | `#3DBD8E` | Verde acqua |
| `accentMix` | `#5C677D` | Slate (I miei WOD) |
| `phaseWork` | `#4CAF50` | Verde (lavoro) |
| `phaseRest` | `#9C27B0` | Viola (riposo) |
| `phaseWodRest` | `#FF9800` | Arancione (riposo WOD) |

---

## 10. Workflow consigliato per implementare una nuova feature

1. **Leggere Android**: trovare il file `.kt` corrispondente in `wod/`
2. **Capire la logica**: identificare state, UI, navigazione nella versione Android
3. **Mappare iOS**: creare/modificare il file Swift equivalente rispettando la struttura
4. **Build**: `zsh -c "cd ~/Documents/progetti/wod-ios && xcodebuild ... | tail -3"`
5. **Rigenerare se nuovi file**: `xcodegen generate` prima di `xcodebuild`
6. **Installare**: `xcrun simctl install $SIM_ID "$APP_PATH"`
7. **Verificare visualmente**: aprire Simulator, navigare al flusso modificato
8. **Verificare portrait lock**: ruotare il simulatore su schermate non-timer — il contenuto deve restare in portrait

### Checklist parità Android/iOS

Ogni schermata deve avere:
- [ ] Stesso layout portrait (colori, font, spaziature, componenti)
- [ ] Stesso layout landscape (se applicabile — solo Timer e Completion)
- [ ] Stessa navigazione (tap, back, drawer)
- [ ] Stessa logica di business (calcoli timer, salvataggio dati)
- [ ] Stesse stringhe in italiano

---

## 11. Problemi noti e workaround

| Problema | Causa | Soluzione |
|----------|-------|-----------|
| `ll: command not found` in Bash | Alias bash non disponibile in shell snapshot di Claude | Usare sempre `zsh -c "..."` per i comandi build |
| App non si avvia con `xcrun simctl launch` | Bundle ID errato o app non installata | Il bundle ID è `com.dambrosj.wod-timer` (non `com.nicoladambrosio.WodTimer`) |
| Landscape non funziona su iPhone | `horizontalSizeClass` rimane `.compact` su iPhone | Usare `verticalSizeClass == .compact` per rilevare landscape |
| Skip non reagisce | Sleep da 1 secondo non interrompibile | Il loop usa 20×50ms — già corretto nel codebase |
| Nuovo file Swift non compilato | Non aggiunto al `.xcodeproj` | Eseguire `xcodegen generate` dopo ogni nuovo file |

---

## 12. Riferimenti rapidi

```bash
# Bundle ID
com.dambrosj.wod-timer

# Simulator ID iPhone 17 (Booted)
xcrun simctl list devices | grep 'iPhone 17' | grep Booted | grep -oE '[A-F0-9-]{36}'

# App path dopo build
find ~/Library/Developer/Xcode/DerivedData/WodTimer-*/Build \
  -name 'WodTimer.app' -not -path '*/Index.noindex/*' | head -1

# Ciclo completo: build → install → launch
zsh -c "
  cd ~/Documents/progetti/wod-ios
  xcodebuild -project WodTimer.xcodeproj -scheme WodTimer \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -configuration Debug build 2>&1 | tail -3
" && \
SIM_ID=$(xcrun simctl list devices | grep 'iPhone 17' | grep Booted | grep -oE '[A-F0-9-]{36}' | head -1) && \
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/WodTimer-*/Build -name 'WodTimer.app' -not -path '*/Index.noindex/*' | head -1) && \
xcrun simctl terminate $SIM_ID com.dambrosj.wod-timer 2>/dev/null && \
xcrun simctl install $SIM_ID "$APP_PATH" && \
xcrun simctl launch $SIM_ID com.dambrosj.wod-timer
```

---

## 13. Regola d'oro

> Quando sei in dubbio su come qualcosa deve funzionare, **leggi il sorgente Android**. Il file Android è sempre la fonte di verità. L'implementazione iOS deve replicare comportamento, layout e UX — non reinterpretarli.
