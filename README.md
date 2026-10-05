# Parallax Hunt

**Parallax Hunt 1.4.0 Native Alpha** is the Godot 4.7.2 Android migration of the original HTML prototype.

## Native systems currently implemented

- 25 visually distinct city districts in a 26,000 × 18,000 open world
- dynamic camera zoom: closer on foot, wider while driving
- PMDD-style parallax with Android motion-sensor input and simultaneous touch peek
- mobile multi-touch movement + perspective control
- procedural buildings, landmark architecture, vegetation, pedestrians, cars, buses and trams
- OpenAI HQ landmark with a stylized visitor-lab interior
- world map with POI legend and player position
- mission menu with chapter progression and completion state
- named NPCs including Mira, Nova, Luna, Iris, Vio and Bram
- echo fragments, perspective secrets, data caches and city sigils
- rooftop relays and sublevel utility nodes
- six native hacking minigames:
  - wire rotation
  - sliding puzzle
  - Mastermind
  - frequency alignment
  - packet-memory sequence
  - Lights Out firewall
- enterable restaurants, cafés, shops, garages, workshops, homes and special interiors
- energy, credits, shop inventory and restaurant recovery
- side jobs / city deliveries with distance-scaled rewards
- vehicle classes, driving, paint workshop and persistent home-garage storage
- purchasable homes with garage capacity
- functional buses/trams with stops, dwell time, boarding and exiting
- save/load and periodic autosave
- native synthesized sound effects and perspective-secret reveal chime
- runtime smoke test in CI: builds fail if the Godot main scene cannot actually start

## Android build

Every push to `main` runs:

1. Godot 4.7.2 Android debug export
2. headless runtime startup smoke test
3. APK verification
4. GitHub Actions artifact upload

## Important tracking status

The native game currently uses Android motion sensors plus touch peek for PMDD perspective. Front-camera permission/feed detection is prepared, but full native MediaPipe face/iris tracking is still a separate Android-plugin milestone and is not claimed as finished.

## Repository structure

- `scripts/main.gd` — current native gameplay/world implementation
- `scenes/Main.tscn` — main scene
- `assets/visual/` — building, vehicle, character and transit design sheets
- `docs/ROADMAP.md` — native migration roadmap
- `.github/workflows/android-debug.yml` — reproducible Android build + runtime test
