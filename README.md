# Parallax Hunt

**Parallax Hunt 1.8.0 Native Alpha** is the current Godot 4.7.2 Android build of the PMDD open-world prototype.

## 1.8.0 — Fixed 3D Photo Hunt

- 25 fixed Photo Challenge locations across the megacity
- activating a Photo Spot freezes player/vehicle movement completely
- the normal 2D/PMDD world is replaced by a dedicated native Godot 3D SubViewport
- nearby roads, sidewalks, procedural buildings, landmark architecture and vegetation are rebuilt locally in 3D
- moving traffic, buses, trams and pedestrians continue moving inside the photo scene
- district-specific hidden subjects include PMDD symbols, drones, rare cars, roof cats, neon codes, antennas, window reflections and birds
- drag-to-look camera, zoom controls, centered camera reticle and target lock feedback
- photo framing score up to 100 per subject / 300 per spot
- quality bonuses and persistent per-subject best scores
- completed Photo Spots can be replayed to improve scores without duplicating first-clear rewards
- partial subject progress is saved if a challenge is left early
- day, dusk and night lighting are reflected in the 3D photo scene
- visible shutter flash and photo-specific reward popups
- landmark-specific 3D silhouettes including OpenAI HQ twin volumes + skybridge, Clock Tower, Solar Beacon, Observatory, Glasshouse, Theatre and Harbor Crane Hall

## 1.7.0 — Gameplay, Collection & Variety

### Driving and vehicles
- 10 vehicle classes: Micro, Hatch, Sedan, Executive, SUV, Pickup, Van, Delivery, Sport and Hyper
- four performance groups: CITY, ROAD, UTILITY, PERFORMANCE plus HYPER
- class-specific top speed, acceleration, braking and handling
- progressive mobile steering, throttle/brake/reverse joystick semantics and configurable driving assist
- dynamic collisions with parked and moving traffic
- weighted vehicle rarity: common city cars, uncommon utility/executive vehicles, rare sports cars and ultra-rare hypercars
- class-specific visual silhouettes and details
- persistent class tuning in workshops:
  - engine
  - handling
  - brakes
  - three upgrade levels each
- six repeatable time trials with class requirements, checkpoints, best times, rewards and 3-2-1 countdown
- unique trial completion tracking plus repeat wins for best-time chasing
- Android haptics for impacts, race starts and reward moments

### Long-term gameplay
- 35 main/native mission chapters
- repeatable city-job board with multiple job types
- NPC trust contracts
- milestone rewards
- Collection dashboard with completion bars and detailed progress
- persistent three-slot save system
- active mission compass and world/map objectives

### Hacking overhaul
- 12 hacking terminals across the city
- security difficulty levels
- replayable terminals with smaller replay rewards
- six hacking families:
  - true-connectivity Wire network (4×4 / 5×5)
  - Sliding routing puzzle
  - variable-range Mastermind
  - Frequency alignment
  - Packet-memory sequence
  - Lights Out firewall
- rich completion popups and rewards
- Hacking Marathon + replay progression

### Exploration and collection
- 25 PMDD Photo Hunt viewpoints across the city
- viewpoint alignment uses PMDD perspective, not just proximity
- camera-flash feedback and photo rewards
- 25 hidden Street Signals found through active SCAN gameplay
- Echo fragments
- perspective secrets
- data caches
- city sigils
- rooftop relays
- sublevel utility nodes
- collection milestones such as Photo Scout, District Lens, Photo Master, Signal Hunter and Spectrum Archivist

### World and visual variety
- 25 city districts
- organic secondary road routes mixed with the main street grid
- 12 parks / pocket parks with unique attractions
- district-specific micro-assets:
  - wind turbines
  - runway lights
  - data pylons
  - coastal boardwalk details
  - market stalls
  - bike racks
  - industrial gantries
  - neon totems
  - garden arches
- unique district ground motifs for Aerodrome, Windfeld, Data Fields, coast, Railworks, industry/harbor, campus and observatory zones
- unique park attractions including Art Wall, Pond, Skate Bowl, Drone Pad, Rose Garden and Playground
- improved water, façades, vegetation, road furniture and night ambience

### Missions / UI
- World map with POI categories for missions, shops, restaurants, garages, homes, NPCs, transit, vertical access, Photo Hunt and time trials
- Missions overlay with long-term statistics
- Collection overlay for photos, cars, hacking, districts, trials, NPC trust and milestones
- rich reward popups for hacks, races, photos, milestones and new missions
- main menu with Continue, New Game, three save slots and options
- options for sound, graphics quality, PMDD depth, sensor sensitivity and driving assist

### Existing city systems
- smart right-hand traffic
- lane changes, traffic lights and turn behavior
- bridges / underpasses visually distinguished from normal intersections
- NPC drivers who park, exit vehicles, walk to destinations and return later
- pedestrian routines
- enterable multi-floor interiors
- OpenAI HQ
- purchasable homes and private garages
- restaurants, shops, workshops, economy and energy
- functional buses / trams
- native synthesized sound effects

## Android build safeguards

Every push to `main` runs:

1. Godot 4.7.2 Android debug export
2. headless main-scene runtime smoke test
3. APK verification
4. artifact upload

The workflow now uses a concurrency group so new commits cancel stale in-progress builds and prioritize the newest `main` state.

## Tracking status

PMDD perspective currently uses Android motion sensors plus multi-touch Touch Peek. Front-camera permission/feed detection is prepared, but full native MediaPipe face/iris tracking remains a separate Android-plugin milestone.
