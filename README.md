# Parallax Hunt

**Parallax Hunt 1.6.0 Native Alpha** continues the Godot 4.7.2 Android migration of the original HTML game.

## 1.6.0 highlights

### Traffic AI 2.0
- right-hand traffic with separate lane offsets
- two-lane car-following
- adaptive slowing behind traffic
- autonomous lane changes when an adjacent lane is clear
- turn indicators for lane changes and junction turns
- smoother visual interpolation through turns
- normal intersections and bridge/underpass nodes are visually distinct
- synchronized signal logic
- roadside parking bays
- smart drivers can drive, park, leave the car, walk to destinations and return later
- parked NPC cars remain visible while drivers are on foot

### Smarter pedestrians and civilian routines
- pedestrians use routine targets instead of endlessly looping one corridor
- roles include work, shopping, park, home and transit behavior
- pedestrians pause at destinations
- some pedestrians change sidewalk corridors at intersections
- civilian driver agents choose real activity targets such as cafés, shops, parks, homes and workshops

### Mission / NPC gameplay
- mission compass with active objective and distance
- named NPC dialogue system
- NPC trust values
- personal optional contracts for Mira, Nova, Luna, Iris, Vio and Bram
- separate NPC contract rewards and map markers
- optional contracts cover caches, deliveries, hacking and public transit
- main story progression remains independent from personal NPC contracts

### Better interiors
- multi-floor native interiors
- lifts between floors
- unique upper-floor layouts for OpenAI HQ, shops, restaurants/cafés and owned homes
- animated sliding doors
- room labels and clearer room functions
- ambient guests, workers, mechanics and researchers
- OpenAI HQ now has a lobby / visitor lab floor plus a denser research / collaboration floor

### Main menu / saves
- animated native PMDD city title art
- Continue
- New Game
- three independent save slots
- progress / credits shown per slot
- fullscreen input-safe menu overlay
- Options:
  - sound
  - graphics quality
  - PMDD depth
  - sensor sensitivity
- in-game menu button and autosave

## Existing native systems

- 25 city districts in a 26,000 × 18,000 world
- dynamic on-foot / driving zoom
- PMDD motion-sensor perspective plus touch peek
- mobile multitouch controls
- world map with POIs
- mission menu
- OpenAI HQ landmark
- restaurants, cafés, shops, garages, workshops and homes
- property purchase and persistent garage storage
- energy / credits / shop stock / restaurants
- side jobs
- buses and trams with stops
- rooftop relays and sublevels
- six hacking minigames
- echo fragments, perspective secrets, caches and sigils
- synthesized sound effects
- save/load and autosave

## Android build safeguards

Every push to `main` runs:

1. Godot 4.7.2 Android debug export
2. headless main-scene runtime smoke test
3. APK verification
4. artifact upload

The build fails if the main Godot scene cannot load.

## Tracking status

Native PMDD currently uses Android motion sensors plus touch peek. Front-camera permission/feed detection is prepared, but full native MediaPipe face/iris tracking remains a separate Android-plugin milestone.
