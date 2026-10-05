# Parallax Hunt

**Parallax Hunt 1.5.0 Native Alpha** is the Godot 4.7.2 Android migration of the original HTML prototype.

## 1.5.0 highlights

### Smarter living traffic
- right-hand traffic with separate lane offsets
- two traffic lanes per direction where road width permits
- car-following / spacing logic
- signal-aware stopping at same-level intersections
- vehicles can turn onto crossing roads
- dedicated normal-intersection rendering instead of every crossing looking like a bridge
- explicit bridge/underpass nodes; upper deck fades when the player passes underneath
- synchronized junction signal indicators
- marked roadside parking bays
- smart civilian agents switch between walking, entering cars, driving, parking, leaving cars and walking again
- parked NPC cars can remain visible while their drivers are on foot

### Main menu / save system
- animated native PMDD-city title art
- Continue
- New Game
- three independent save slots with progress / credit summaries
- fullscreen input-safe menu overlay
- Options menu:
  - sound
  - graphics quality
  - PMDD depth
  - sensor sensitivity
- in-game menu button
- autosave + manual save when returning to the main menu

### Deeper NPC / interior gameplay
- dialogue panel for named NPCs
- mission-specific dialogue / hints
- optional city-context dialogue
- animated sliding interior exit doors
- ambient restaurant guests, shop staff, mechanics and OpenAI HQ lab personnel
- room labels and clearer room functions
- expanded rooftop / sublevel / commerce / property interiors

## Existing native systems

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
- six native hacking minigames
- enterable restaurants, cafés, shops, garages, workshops, homes and special interiors
- energy, credits, shop inventory and restaurant recovery
- side jobs / city deliveries with distance-scaled rewards
- vehicle classes, driving, paint workshop and persistent home-garage storage
- purchasable homes with garage capacity
- functional buses/trams with stops, dwell time, boarding and exiting
- save/load and periodic autosave
- native synthesized sound effects and perspective-secret reveal chime

## Android build safeguards

Every push to `main` runs:

1. Godot 4.7.2 Android debug export
2. headless runtime startup smoke test
3. APK verification
4. GitHub Actions artifact upload

The CI build fails if the main Godot scene cannot actually load.

## Tracking status

The game currently uses Android motion sensors plus touch peek for PMDD perspective. Front-camera permission/feed detection is prepared, but full native MediaPipe face/iris tracking remains a separate Android-plugin milestone.
