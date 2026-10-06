# Parallax Hunt

**Parallax Hunt 1.15.0 Native Alpha** is the current Godot 4.7.2 Android build of the PMDD open-world prototype.

## 1.15.0 — Living Streets

- transit vehicles now carry a lightweight passenger count and boarding/exiting state
- visible boarding and exiting waves move between the waiting group and the actual stopped bus/tram
- bus/tram doors visibly open while dwelling at a stop
- denser authored plaza, market, harbor, campus, expo and nightlife crowd pockets add stronger district-specific activity
- selected cafés and transit areas spawn rain-shelter groups during rain and storms
- spectators now gather around music, mural, drone and fountain live events; some watch while others visibly use phones/cameras
- restaurant/café awnings sway subtly, restaurant steam animates, market canopies move and neon props pulse
- response vehicles now receive real right-of-way behavior instead of only visual styling
- nearby traffic detects an approaching response vehicle on the same road, slows/yields and flashes hazards
- response vehicles retain speed priority through red phases instead of behaving exactly like ordinary traffic
- the new crowd/animation systems remain graphics-quality aware and reuse existing deterministic world data for mobile stability

## 1.14.0 — Street Scenes

- social street set-pieces now appear around real transit stops, cafés/restaurants and selected street corners
- transit-stop groups visibly wait together and one NPC reacts when the linked bus/tram is actually dwelling at that stop
- café clusters include seated and chatting people instead of relying only on moving sidewalk pedestrians
- corner queues add small static social groups that make intersections feel less empty
- normal pedestrians now react to transit arrivals with a wave state
- pedestrian crossings are now traffic-light aware: crossings are attempted when the active road phase is red for vehicles
- six rotating service / response incidents are staged around the city with cones, crew, service vehicles and flashing warning equipment
- nearby AI traffic slows significantly around active incidents and displays hazard lights
- active response incidents appear on the city map with their own warning marker and live incident count
- the social scene system is intentionally lightweight and deterministic to preserve Android performance

## 1.13.0 — Social World

- pedestrians now use explicit social states instead of a single walk/pause loop: walking, road crossing, sitting, chatting, phone use and alert reactions
- seeded social pairs can pause together and visibly converse instead of every pedestrian behaving independently
- pedestrians can cross at junctions and player/AI traffic reacts by yielding to active crossings
- nearby player vehicles can trigger pedestrian alert behavior instead of NPCs ignoring traffic completely
- district clothing/accessory identity from 1.12 now carries through the richer social states
- traffic now contains explicit archetypes such as taxi, rideshare, service, maintenance, courier and city-response vehicles
- service archetypes receive class-aware roof racks, markings, beacons or lightbars rather than relying on random livery only
- those archetypes also carry into the fixed 3D Photo Hunt traffic scene
- actively helping at selected live events can unlock short local follow-up jobs with their own compass guidance, world target marker and payout
- follow-up jobs reuse the normal save/job/progression systems instead of creating a parallel quest implementation
- Photo Hunt now builds a lightweight static-occluder model from nearby buildings and landmarks
- hidden Photo Hunt subjects are repositioned toward clear sight lines when necessary
- the camera target check rejects subjects hidden behind static world masses, preventing captures through buildings
- the 3D smoke test now verifies that occlusion data is actually built alongside the three search targets

## 1.12.0 — Open-World Depth

- mission overlay is now paged so the full long-form campaign remains readable instead of clipping after the first screen
- collection progression is split into three pages: overview + city life, all Photo Hunt spots, and vehicles + milestones
- bottom-left / bottom-right paging zones make the large mobile overlays navigable without tiny controls
- all rotating city micro-events now open a real two-choice interaction instead of resolving with a single tap
- choices are remembered per event and can represent simply experiencing an event or actively helping the people running it
- City Reputation, event discovery and the chosen branch persist in save slots
- three new campaign chapters integrate street life directly into long-term progression: Urban Pulse, Lokale Hände and Megacity Insider
- the mission compass can guide the player toward suitable unseen / unsupported live events
- close-range event audio one-shots differentiate music/show, work/repair and crowd/market encounters
- district-specific pedestrian accessories add stronger local visual identity in neon, green, industrial, campus, heritage and waterfront areas
- Canal Rotunda, Civic Prism, Axis Library and Terminal Crown now have bespoke native 3D Photo Hunt geometry instead of generic landmark blocks
- modal commerce/event windows now lock background movement and duplicate interaction input
- active live events are shown on the city map with a dedicated legend marker and live count
- traffic composition now varies by district identity: industrial/harbor areas favor utility vehicles, glass/neon areas skew executive/performance, while campus/green zones favor smaller city cars

## 1.11.0 — Street Life & District Ambience

- district-specific synthesized ambient beds without external audio assets
- separate rain and storm ambience layers that react to interiors, vehicles and photo mode
- ambient character changes between heritage, green, waterside, industrial, neon, campus and open districts
- all 12 rotating city micro-events are now directly interactive on foot
- first-time participation earns City Reputation and a small discovery reward; repeat visits provide contextual effects instead of farming the same reward
- City Reputation is saved per slot and now has three long-term milestones: City Regular, Local Pulse and Megacity Insider
- micro-events advertise NEW/LIVE states and show a local interaction ring at close range
- district-entry banners now communicate a stronger identity such as HERITAGE CORE, GLASS CANYON, HARBOR LIFE or DATA GRID
- pedestrians pause more naturally, occasionally check phones, and use umbrellas in rain and storms
- vehicles gain taxi, service, utility-rack, response-light and EV-accent variants plus wet-road wheel spray
- collection milestone layout is now two-column so the expanded progression list remains readable

## 1.10.0 — World Alive

- dynamic clear, mist, rain and storm states tied into the world clock
- wet-road sheen, rain streaks, mist layers and restrained lightning feedback
- weather now appears in the HUD and influences NPC city advice
- 12 rotating district micro-events including buskers, food trucks, yoga sessions, drone shows, street markets, live murals, repair crews, run clubs and campus meetups
- nearby active micro-events receive a LIVE label without turning every ambient beat into a quest marker
- NPC greetings now react to trust, time of day, current district and weather
- player vehicle headlights activate at night and in poor visibility
- braking brightens tail lights and aggressive high-speed steering leaves short skid marks
- visual systems remain graphics-quality aware for mobile performance

## 1.9.0 — World Polish & City Life

### Visual world polish
- eight procedural façade families: windows, striped, balconies, mixed, grid, arches, structural ribs and living façades
- seven roof variants including antenna roofs and usable-looking terrace silhouettes
- façade windows now vary between cool glass and warm occupied interiors according to the day/night cycle
- richer road surfaces with manholes, drainage grates, repaired asphalt patches and roadside reflectors
- 54 additional street-life props distributed along the city: planters, utility cabinets, café tables, construction cones and hydrants
- improved dawn/dusk grading, scan-wave feedback, subtle high-speed streaks and stronger screen-edge ambience

### 3D Photo Hunt polish
- nearby procedural buildings now receive real 3D façade-window layers instead of plain boxes
- transparent glass/light materials are supported in the native photo scene
- living-façade, rib and rooftop antenna details carry into the fixed 3D Photo Challenges
- photo-scene cars now have wheels, headlights, tail lights and class-specific details such as spoilers and pickup beds
- detail density respects the selected graphics-quality level

### Gameplay & UX
- city job board expanded from five to seven job families
- new Street-Signal Survey jobs tie the SCAN collection system into repeatable city work
- new Timed Mobility Audit jobs integrate the race/time-trial system into the job economy
- robust fallback jobs prevent exhausted finite activities from creating impossible contracts
- active city jobs now always receive objective-compass priority
- HUD shows active-job distance plus the live in-game clock
- job acceptance now receives a dedicated reward-style presentation

### Long-term progression
- mission progression expanded to 43 chapters
- new endgame goals: Signal Sweep, Photo Virtuoso, City Circuit, Security Master, District Complete, Tuning Specialist and City Professional II
- total Photo Hunt framing score is now a progression metric
- new mastery milestones reward full-district exploration, all hacking terminals, all races, 25 jobs, 4500 photo points and deeper tuning investment

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
