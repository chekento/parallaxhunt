# Native Roadmap

## Alpha 1 — engine migration
- Native Godot renderer and Android APK
- Multitouch movement + perspective peek
- Sensor PMDD/parallax
- Distinct procedural districts
- Traffic, parked vehicles, collectibles, secrets, scan, HUD, audio

## Alpha 2 — gameplay parity
- Mission chains and hacking minigames
- Shops, restaurants, energy, credits
- Interiors, garages, house ownership, vehicle storage/paint
- Bus/tram timetables and traffic-light state machine

## Alpha 3 — camera head tracking
- Android CameraX front-camera plugin
- MediaPipe Face Landmarker native bridge
- head-pose calibration + iris micro-parallax
- camera privacy/status UI and power-aware tracking rate

## Visual polish
- authored modular building kits per district
- atlas-based characters/vehicles in 8 directions
- decals, road curves, plazas, parks and landmarks
- shader-based glow, fog, reflections, depth occlusion and night lighting

## Alpha 1.8 — fixed 3D Photo Hunt
- Fixed-location Photo Spots with movement lock
- Native local 3D scene reconstruction around each spot
- Moving cars, transit and pedestrians mirrored into the photo scene
- Search subjects, reticle lock, zoom, hints and framing score
- Persistent Photo Hunt score / replay loop
- Next: richer 3D facade assets, occlusion-aware subject placement, saved photo thumbnails


## Alpha 1.9 — world polish & city life
- Expanded procedural façade vocabulary with eight façade families and seven roof silhouettes
- Day/night-aware windows and richer city surface dressing
- Road-surface details, additional street furniture and denser visual storytelling
- Fixed 3D Photo Hunt buildings with façade-window layers, transparent materials and richer vehicle geometry
- Scan-wave and high-speed presentation feedback
- Seven repeatable city-job families including signal surveys and timed mobility audits
- Active-job compass priority, objective distance and in-game clock in the HUD
- 43 progression chapters plus broader completionist/endgame milestones

### Next polish targets
- Authored material/atlas kits for district-specific façades, vehicles and characters
- Saved Photo Hunt thumbnails / gallery presentation
- More landmark-specific 3D photo geometry and occlusion-aware target staging
- Weather states, richer ambient soundscapes and district event beats
- Additional NPC reactions, micro-events and systemic world interactions
- Further mobile UX tuning based on Android playtesting


## Alpha 1.10 — world alive
- Dynamic clear, mist, rain and storm states
- Wet-road, rain, mist and lightning presentation
- Weather-aware HUD and NPC dialogue context
- Rotating district micro-events for ambient city life
- Night/poor-visibility headlights, stronger brake lights and high-speed skid feedback
- More reactive NPC trust/time/district/world-state responses

### Next immersion targets
- District-specific ambient audio beds and traffic tone
- Weather-specific photo-scene materials and reflections
- More interactive micro-events with optional rewards
- More NPC state changes tied to story and trust
- Additional authored street sets and bespoke district set-pieces


## Alpha 1.11 — street life & district ambience
- District-specific synthesized ambient sound profiles
- Separate rain/storm ambience layers
- Interactive versions of all 12 rotating micro-events
- Persistent City Reputation and three city-life mastery milestones
- Stronger district-entry identity messaging
- Weather-reactive pedestrian umbrellas and richer idle behavior
- More vehicle visual variants and wet-road spray
- Two-column milestone presentation for the expanded progression list

### Next quality targets
- authored ambient one-shots and proximity audio for transit, markets and machinery
- more micro-event interaction branches and occasional chained side objectives
- district-specific pedestrian clothing/accessory pools
- more bespoke vehicle silhouettes and service/emergency archetypes
- richer landmark-specific 3D Photo Hunt geometry and occlusion
- scrollable or paged long-form collection / mission overlays


## Alpha 1.12 — open-world depth
- Paged mission overlay for the expanded campaign
- Three-page collection / long-term progression UI
- Branching two-choice interactions for all rotating city micro-events
- Persistent event choices and deeper City Reputation integration
- Three new campaign chapters: Urban Pulse, Lokale Hände and Megacity Insider
- Compass routing toward relevant live events during city-life chapters
- Proximity event audio cues
- District-specific pedestrian accessories and local visual identity
- Bespoke 3D Photo Hunt geometry for Canal Rotunda, Civic Prism, Axis Library and Terminal Crown
- Modal UI input lock for event/shop/workshop interactions
- Active live-event markers and live count on the city map
- District-specific traffic-class mixes for stronger neighborhood identity

### Next quality targets
- more bespoke character silhouettes and animations, including sitting, chatting and crossing reactions
- optional chained objectives that can emerge from live events
- richer service/emergency vehicle archetypes and district-specific traffic mixes
- authored transit, market and machinery audio cues with distance falloff
- more landmark-specific Photo Hunt geometry and stronger occlusion-aware target placement
- richer map filters and activity discovery layers
- further mobile performance profiling on dense districts and bad-weather scenes


## Alpha 1.13 — social world
- Explicit pedestrian states: walking, crossing, sitting, chatting, phone use and alert reactions
- Seeded social pairs that can visibly converse together
- Junction crossing behavior with AI and player-traffic yielding
- Explicit taxi, rideshare, service, maintenance, courier and city-response traffic archetypes
- Archetype-specific markings, racks, beacons and lightbars in 2D and 3D Photo Hunt traffic
- Live-event support choices can unlock short chained city follow-up jobs
- Follow-up objectives use existing job saves, compass guidance, world markers and payouts
- Lightweight Photo Hunt occlusion model built from local buildings and landmarks
- Hidden photo targets shift toward valid sight lines and can no longer be captured through static masses
- Photo smoke test now asserts occlusion data exists

### Next quality targets
- more authored social set-pieces: benches, café clusters, queues, transit waiting groups and small crowd scenes
- pedestrian reactions to rain shelters, bus arrivals, live events and traffic-light phase
- emergency/service traffic behaviors beyond visuals, including route priority and staged roadside scenes
- optional second-step follow-up jobs with NPC callbacks rather than only destination handoffs
- stronger Photo Hunt target anchoring to actual roofs, façades, cars and props while preserving valid sight lines
- district-specific sound one-shots with spatial falloff and richer weather variation
- map filters for live events, photo points, jobs, services and transit
- performance profiling for social simulation density on mobile


## Alpha 1.14 — street scenes
- Lightweight social set-pieces at transit stops, cafés/restaurants and selected corners
- Transit-stop groups react to real bus/tram arrivals
- Café seating/chatting clusters and intersection queues
- Pedestrian transit-wave state
- Traffic-light-aware pedestrian crossing decisions
- Six rotating service / response incidents with crews, cones and marked vehicles
- AI traffic slows and uses hazard lights around active incidents
- Active incident markers and live incident count on the city map
- Deterministic scene logic designed to stay mobile-friendly

### Next quality targets
- denser authored district set-pieces: plazas, school/campus edges, markets, harbor work zones and nightlife clusters
- richer transit passenger behavior: boarding/exiting waves and crowd redistribution
- staged emergency behavior with route priority rather than visual-only response vehicles
- ambient reactions around live events and incidents: watching, photographing, dispersing and helping
- more environmental animation such as flags, awnings, steam, shop doors and moving signage
- further Photo Hunt anchoring of hidden targets to real roofs, façades, vehicles and props
- map filter controls for live events, incidents, services, photo points and transit
- profiling social-scene density and bad-weather combinations on Android


## Alpha 1.15 — living streets
- Lightweight passenger counts and boarding/exiting state for buses and trams
- Visible passenger movement between waiting groups and stopped transit vehicles
- Animated bus/tram doors while dwelling
- Denser plaza, market, harbor, campus, expo and nightlife crowd pockets
- Rain-shelter groups at selected cafés and transit stops
- Spectators and phone/camera reactions around live events
- Animated awnings, restaurant steam, moving market canopies and pulsing neon props
- Real response-vehicle right-of-way logic
- Nearby AI traffic yields and flashes hazards for approaching response vehicles
- Response vehicles keep priority through red phases instead of stopping like normal traffic
- Graphics-quality-aware crowd/event rendering to protect Android performance

### Next quality targets
- passenger redistribution after boarding/exiting instead of visual-only stop waves
- shelter-seeking movement for free pedestrians, not just authored shelter groups
- emergency-response destinations and multi-road priority routing
- more district-authored plazas, nightlife clusters, waterfront crews and campus scenes
- reactive shop doors, delivery unloading and café service loops
- richer event audience behaviors: dispersal, applause, queues and photography
- more environmental motion: flags, ventilation, traffic gantries and construction machinery
- map activity filters and optional density controls for lower-end devices


## Alpha 1.16 — city behavior
- Per-stop waiting, arrivals and board/exit counts
- Rush-hour and district-sensitive transit demand growth
- Capacity-aware passenger redistribution between real stop queues and vehicles
- Waiting-group visuals driven by actual stop demand
- Free-pedestrian rain/storm shelter seeking
- Shelter state persists until conditions improve
- BFS-based multi-road response routes across the real junction graph
- Route-aware response turns and automatic destination refresh
- District-authored work shifts, campus edges, nightlife clusters and park picnics
- Animated civic/harbor flags and industrial/data ventilation stacks
- Mobile-oriented deterministic implementation without pathfinding/navmesh overhead

### Next quality targets
- transfer passengers between lines and model destination demand rather than only local boarding capacity
- shelter seeking that can switch roads when the closest safe cover is not on the current corridor
- incident-specific response destinations and multi-vehicle dispatch waves
- more bespoke district scenes with object interaction rather than only authored animation
- animated shop doors, delivery unloading, loading docks and café service loops
- traffic density / crowd density controls in settings
- performance telemetry for lower-end devices and dense weather/event combinations
- stronger Photo Hunt anchoring to live world props and incident scenes
