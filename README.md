# Parallax Hunt

**Parallax Hunt 1.26.0 Native Alpha** is the current Godot 4.7.2 Android build of the PMDD open-world prototype. The repository remains private.

## 1.26.0 — A continuous campaign from the first moment

- **Die Stadt, die sich erinnert** begins in a fresh game with a message seventeen seconds before an interrupted station clock. Twelve authored chapters contain **144 sequential story steps**, recurring characters, evidence gathering, real circuit, spectrum, code and sequence puzzles plus native 3D photo investigations, scan objectives, deductions with retryable hints, choices about trust and shared memory, a complete ending and epilogue. The mystery connects the city, Sonnenhagen, lake, forest, distant Mühlenau and the new Echowarte. There are no real-time waiting gates; routes and optional work support play over many separate sessions. Exact human playtime has not been measured.
- A saved storyjournal reveals only completed clues. It retains evidence, decisions, chapter conclusions and the exact next step. Major decisions reappear in later conversations and the final archive arrangement. The original 45 native goals remain available as additional city projects with all prior progress preserved. Existing saves gain the new campaign without resetting collections, chapter progress or neighborhood stories.
- **Twelve additional optional missions with 43 steps** appear through a nonblocking nearby invitation. Discoveries unlock with campaign progress and remain listed under **AUFTRÄGE → NEBENWEGE**. Accept, ignore, pause or resume freely; these tasks never gate the main story. Rewards pay once, and old dialog or puzzle callbacks cannot advance a changed task.
- Eight more authored city pockets add Ivo's clock, Mira's open archive, the neighborhood noticeboard, Rafi's repair market, Nova's freight window, a harbor reader, Dora's glass-roof shelter and Edda's independent relay. They sit on reserved dry, accessible plazas outside carriageways. The independent neighborhood lights appear after the corresponding chapter; the archive visibly reflects its final arrangement.
- Playable bounds become **144,000 × 56,000 game units**, keeping the original city size and saved indices. L03 crosses the broad Wacholderweiten to the remote Echowarte, with a real stream crossing, walking path, lookout, observation station, camp and sixth regional bus stop. Eight new regional places bring the total to 35. Large unbuilt corridors remain between settlements for later expansion.
- The mission menu adds an illustrated dossier cover, chapter progress, a chapter-by-chapter casefile, gathered evidence, remembered decisions and discovered side missions. Clear buttons return to the main route or pause optional work while retaining progress. The atlas marks the expanded landscape and travel routes.

Start a fresh slot for the opening, or choose **AUFTRÄGE → HAUPTSTORY → HAUPTSTORY VERFOLGEN** in an existing save. **STORYJOURNAL** shows your secured clues and recap. **NEBENWEGE** remembers offers discovered while walking; **KIEZBUCH** retains the seven existing neighborhood stories. The complete main arc has an ending, while open-world activities remain available afterwards.

The new `--story-smoke` integration check traverses all 144 main steps and every new optional mission through actual buttons, scans and puzzle moves, validates deductions, guarded callbacks, chapter and mission rewards, evidence, final choices, save/load and old-save migration. All eight runtime/regression checks run before Android export. Physical-device camera operation and performance still require an on-phone test.

## 1.25.0 — A neighborhood full of stories, a travel book and distant Mühlenau

- Twenty authored interaction places include eighteen city locations and two countryside story locations: a striped neighborhood kiosk, small stage, flower stall, parcel station, reading windows, shared garden, vinyl shop, radio equipment, mural wall, recycling stand, puzzle table and rest bank. Small paved pockets keep stalls and the stage clear of carriageways and building footprints. A small animated dog, planters, fountain ripples, book spines and lights make these places visually distinct.
- Seven optional stories contain 29 steps with clues, choices, deliveries and real wire/frequency puzzles. Find Pico, prepare a neighborhood festival, carry a parcel, plant a garden, tune a local radio, help create a mural, and deliver the mill repair note to Mühlenau. The dog follows during the return step; completed garden, festival and mural stories change their street scenes.
- Story progress is stored per story. Switching and pausing retain each unfinished step, remembered choices and discovered place notes. Completion credits and reputation pay once, including puzzle replays. Story puzzles use the existing real minigame controls while preserving the original city's hacking flags and chapters. Wrong decisions offer clues and remain retryable. Interactions require proximity; stale callbacks cannot advance or pay twice.
- The playable bounds expand to 110,000 × 46,000 units. L02 leads across the Heidekamm to Mühlenau, over 60,000 game units from Sonnenhagen. The low-house village has a square, cafe, mill with slowly turning sails, a real stream crossing and a fifth regional bus stop. Broad open corridors between settlements remain available for later villages and cities. Five new roads/trails, two watercourses and nine regional places extend the earlier region without changing its persistent IDs.
- Six outings now reach twenty-seven regional places; the two new tours explore the heath, village, mill and southern meadows. The regional bus keeps the 15 CR fare. The existing seven races and all original city/collectible/vehicle indices remain available.
- Menus become a travel book with warmer accents, shaped cards, clearer buttons and visible keyboard focus. Missions split into Discover, Neighborhood Book, Countryside and Main Story categories, showing active steps and nearby activities first. A place journal joins the collection; the atlas adds an Experience filter for neighborhood stories and markers for the expanded landscape.

Start with **AUFTRÄGE → KIEZBUCH**, or visit Emil at the Lindenkiosk near the starting district. For the long journey, choose **AUFTRÄGE → UMLAND → Hinter dem Heidekamm**, take a car or use the regional bus to Mühlenau. **KARTE → ERLEBEN** shows the city interaction places. The original 45 chapters, 25 city districts and 25 fixed Photo Hunt locations stay intact.

The new `--life-smoke` check walks all story logic through normal interaction buttons and actual puzzle moves, checking wrong choices, proximity guards, seven completion/replay rewards, paused progress, full save/load, native touch category navigation, the journal and older-save migration. `--region-smoke` now verifies all 27 city-to-country routes and both new outings. Physical Android camera operation and device performance still need an on-phone test.

## 1.24.0 — Sonnenhagen, countryside and a navigable atlas

- The original city occupies its original 26,000 × 18,000 units. The playable world extends to 86,000 × 36,000 units. A greenbelt of at least 4,700 units separates Megacity from Sonnenhagen. Low houses, gabled roofs, gardens, fences, planters, a square, cafe and workshop give the suburb a distinct identity. Existing city generation, collectible IDs, photo spots and vehicle indices stay stable.
- Eight connected roads and trails lead through cultivated fields, the Lindensee shore, Fichtenwald, a real river bridge, ranger station, campsite and high-country viewpoints. Long open corridors leave room for later villages and towns. Those additional settlements are a future step, not included in this build.
- The map is an illustrated, aspect-preserving atlas with city, regional and nearby views. Tap places or free ground to select a safe waypoint, start a route, drag to pan, zoom with large controls and recenter on the player. Place labels avoid each other. Road guidance is shared with the in-world path and measures the actual route instead of the straight-line distance.
- Eighteen regional places reward first discovery. Four optional multi-stop excursions have saved progress and one-time completion rewards; replaying them cannot duplicate credits. Free rest stops restore energy. A regional bus connects the city, suburb, lake and woodland gateway for 15 CR per trip, leaving an occupied car safely parked.
- The Lindenfelder road rally accepts every vehicle class and follows clear road checkpoints. Existing directional steering, release braking, clean modal menus and furnished interiors remain integrated. City district visits are now recorded during normal play without counting countryside regions as city districts.
- Lake and river collision follow their real shore polygons; dry ground in the surrounding bounding boxes remains walkable. Bridges carry continuous body-clear roads. Ground texture, crop rows, layered trees, rocks and gradual biome bands enrich the countryside. Vegetation cells load near the camera and their cache is capped at 96 cells.

Start a countryside excursion from **AUFTRÄGE**, or use **KARTE → UMLAND** and set a waypoint. The regional bus near the starting neighborhood is shown in the Transit map filter. The UI distance scale is unchanged: ten game units are displayed as one meter. These are stylized game distances rather than a geographic map.

The `--region-smoke` integration check covers city preservation, all 18 routes from the city, full land-road and bridge clearance, lake collision, four excursions through normal interaction, reward replays, bus fare and parking, rest, full save/load, actual screen-touch map selection and drag, and bounded landscape generation. Physical Android camera behavior and device performance still need an on-phone test.

## 1.23.0 — Clean menus, authored interiors and reliable city access

- Map, missions and collection are real controls on an input-owning modal canvas. Opening any menu, dialogue, commerce card or puzzle hides the entire gameplay HUD and pauses street movement. Large close buttons, scrollable cards, collection tabs, map categories and a neighborhood view replace fixed draw coordinates. Popup timers cancel their predecessors instead of hiding newer notifications.
- Eleven interior identities use larger authored cutaway layouts: bars with bottle shelves and taps, cafes and restaurants, furnished homes, stocked shops, service bays, a clinic, research spaces, roof terraces and utility rooms. Directional character sprites share the exterior style. Furniture has collision, and feature, exit and stair routes are checked on a walking grid.
- Every road-to-road junction is at grade. Footways and curbs are drawn first, followed by all asphalt carriageways, so no sidewalk continues across the intersecting road. Zebras and stop bars lie on the approaches. Canal spans have an actual continuous deck, footways, railings and abutments above the water. 3D photo footways and lane sections are also split at crossings.
- Buildings, trees and ground vegetation are excluded from canal water. A deterministic access pass checks 250 interaction and collectible positions for a clear body-width route from a road, relocating blocked coordinates while retaining item IDs and flags. The reported canal archive is now on a bridge footway and is checked through actual player walking and interaction proximity. Mira points to the nearest remaining archive and gives the archive count. Roof relays point to street-level entrances and use the explorable roof scene.
- Cars follow the chosen joystick/WASD world direction with bounded smooth turning, corner slowdown, acceleration and automatic braking when released. Driving assist improves braking and turn rate without pulling against the chosen direction. Stop collisions do not bounce the car into reverse. Idle walking restores energy gradually.
- Animated bird and drone subjects in Photo Hunt keep their orbit on visible positions, so an animation phase cannot put a required subject behind a facade. Their motion ranges are checked at all 25 photo spots.
- A spatial index limits collision checks to nearby buildings. Existing preview slots, collected flags, credits and the delivered test signature are retained. A saved blocked position or obsolete active-job coordinate is moved to a reachable approach.

The `--quality-smoke` regression covers menu input isolation, all 250 street approaches, the reported canal route, all 25 district survey points, 49 newly generated city jobs, twelve interior routes, all four car directions and popup timer replacement. New visit contracts, deliveries and event follow-ups also use reachable approaches. Real OpenGL captures cover the three menus, junction, bar, cafe, home, garage, shop, clinic, rooftop, dialogue and puzzle. Android camera behavior and phone frame pacing still require a physical-device test.

## 1.22.0 — Characters, readable missions and richer Photo Hunt

- Sixteen authored comic character sprites cover four directions and four outfits. The player, street residents and named contacts use consistent foot pivots, directional facing, walking sway, weather umbrellas and visible interaction names. The character sheet is bundled locally with the other city assets.
- The mission HUD gains a compact progress bar, a readable next-action instruction, an in-world goal ring and edge arrows with distance. Collecting chapters point to the closest remaining signal, cache or sigil. Completed collectibles immediately leave the route; active races, jobs and personal contracts retain priority.
- Wire hacking uses actual drawn circuit paths instead of font-dependent line glyphs. Powered tiles, S/T endpoints, connected-count feedback, turn counts and a one-tile hint make the puzzle understandable. Its generated solution is checked as a real connected circuit, and completion locks further rewards and input.
- Native 3D Photo Hunt gains staggered stone paving, a procedural twilight sky, local lamps and warm lighting, palms, benches, cafe tables and umbrellas, differentiated rooftop details, and fuller articulated pedestrian geometry. Buildings are selected by proximity to the viewpoint so detail is spent on the nearby streets. Graphics quality limits furniture, lights and roof details.
- The fixed photo camera uses a street-height eye position. Window reflections and codes attach to visible facades; cats, birds and antennas sit on suitable roofs. Rare vehicles use the full vehicle model and a visible road anchor when available. Collected subjects disappear on scene reconstruction.
- Photo hints give a direction and height cue and remain visible for several seconds. Missed shots retain feedback instead of losing their message on the next frame. Session guards prevent an old completion timer from closing a newly opened photo spot or hack replay.
- Buttons share a consistent theme, everyday HUD text is simpler, and common actions are localized. Audio playback is stopped during scene teardown.

The preview retains the 1.21.0 application ID and delivered test signing key, so it can update that preview installation. Existing preview saves continue to use the same slots. Physical-device camera tracking, frame pacing, heat and battery use still need a phone test; the local checks do not establish those measurements.

## 1.21.0 — City, camera and first-minute rebuild

- 1,299 additional street-facing blocks bring the city to 2,085 buildings. Authored comic facade textures, amber windows, blue storefronts, ink contours, cornices and roof equipment replace the flat facade treatment throughout the street renderer.
- Streets use textured asphalt, correctly scaled lane markings and crossings, tiled sidewalks, warm lamps, palms, cafe umbrellas, benches and planters. Furniture is kept clear of every carriageway, including intersecting roads.
- Twelve vehicle sprites cover the ten civilian classes, response cars and ambulances, with heading rotation, headlights, brake lights and emergency lighting.
- The pedestrian camera now runs at 2.65x zoom. Buildings retain visible depth at rest; motion adds smooth perspective and camera lead. Pedestrians and vehicles scale with the world instead of remaining tiny at close zoom.
- The first five Echo signals, a parked hatchback, a simple wire terminal and a jobboard are near the starting neighborhood. Twelve existing pedestrians and three civilian cars populate its boulevard without increasing the simulation count. Existing collectible IDs and vehicle indices remain stable.
- The compact HUD shows the next mission and its progress. INFO opens details; interface touches are handled before world movement. Pedestrians slide along walls instead of sticking on diagonal movement.
- Optional **real front-camera headtracking** uses Camera2 and the bundled ML Kit face detector. Face position, distance and head angles drive perspective; recentering, smoothing, pause/resume and gyro fallback are integrated. Camera permission is requested when the option is enabled. Frames are processed in memory.
- Photo Hunt remains a stationary, native 3D challenge. Its camera responds to headtracking, buildings share the new facade atlas, and its viewport stops rendering when closed. Covered observation points are cleared; long road segments are clipped into the local scene instead of disappearing. Target visibility uses a 3D segment/box test, and all 25 spots are checked for roads and visible subjects.
- Hacking grants its reward once. New games clear previous photo/event progress; collected fragments and secrets now persist across save/load.

### Install and play

The delivered **Parallax Hunt · Preview** APK installs as `com.kosch.parallaxhunt.preview` alongside the previous app. The old debug signing key was unavailable, so the preview keeps the previous installation and its saves intact. The preview starts with separate saves. The standard `Android` export preset retains the original app ID.

Use the left joystick to choose the world direction for walking or driving; release it to brake the car. Use the right side to adjust perspective, AKTION (or the contextual action label) for nearby actions and SCAN for signals. For camera tracking, enable **Kamera-Headtracking** in options, grant camera access and use the recenter button while looking at the phone. Without camera tracking, touch and phone tilt remain available. On desktop: WASD/arrows, E to interact, Q to scan, right drag for perspective, C to recenter and Escape to close a panel.

### Build and validation

Install Godot **4.7.2** and its matching Android export templates, Java 17, Android platform 36 and build-tools 36.1.0. Enable the included editor plugin, then prepare the official template before exporting:

```bash
python3 scripts/prepare_android.py --template /path/to/android_source.zip
godot --headless --editor --path . --import --quit
godot --headless --path . -- --city-smoke
godot --headless --path . -- --experience-smoke
godot --headless --path . -- --photo-smoke
godot --headless --path . -- --quality-smoke
godot --headless --path . -- --region-smoke
godot --headless --path . -- --life-smoke
godot --headless --path . -- --story-smoke
godot --headless --path . --export-debug "Android Preview" build/ParallaxHunt-1.26.0-preview.apk
```

Set the Java and Android SDK paths in Godot's editor settings. The workflow installs the native tracker source and its bundled detector dependency, imports the project, runs the runtime, city, experience, quality, region, life, story and photo checks and exports a signed preview APK. Native libraries are compressed for direct APK downloads; screenshots and build files are excluded from the game.

The private source archive supplied with this build includes `signing/debug.keystore` for subsequent local test builds. Use `GODOT_ANDROID_KEYSTORE_DEBUG_PATH` to point to it (debug alias `androiddebugkey`, password `android`). The key is excluded from the repository. CI can reuse it through the optional `PARALLAX_DEBUG_KEYSTORE_BASE64` repository secret; otherwise a CI run creates its own test key.

Checks cover a walkable start and nearby signals, street-furniture placement, depth at rest, movement lock and viewport lifecycle in Photo Hunt, camera-pose response, one hacking reward, collectible persistence and new-game reset. The experience checks also cover sprite directions, nearest remaining objectives, real circuit connectivity, hint persistence, same-site replay session guards and photo street dressing. OpenGL screenshots of walking, driving, hacking and Photo Hunt were inspected as well. Actual camera behavior, thermals and performance on the user's Android device still require a hardware test. This remains an alpha with a 2.5D street renderer and a separate native 3D photo scene.

Older saves recorded collectible totals without IDs. On migration, the first matching number of flags is marked consumed to preserve those totals; the exact previously collected positions cannot be reconstructed.

## 1.20.0 — Modular City Vertical Slice

- first real high-detail modular visual slice added directly around the normal downtown start area
- existing SVG styleboards are no longer only documentation: new asphalt, sidewalk, palm, neon-sign and rooftop-detail SVG modules are loaded as live Godot textures
- streets inside the slice receive repeated cinematic asphalt modules instead of relying exclusively on flat procedural fills
- sidewalks inside the slice receive modular slab textures and brighter curb-edge separation
- a palm-lined boulevard layer adds denser warm-climate street identity inspired by the supplied reference direction without copying the source art
- selected roofs now receive actual mechanical rooftop modules with vents, antennae and equipment blocks
- center / glass / culture façades receive live neon-sign modules and localized glow pools
- storefronts inside the slice scale more aggressively at close pedestrian zoom and receive stronger illuminated lower-floor structure
- buildings in the slice gain heavier dark comic outlines, refined roof insets and stronger silhouette separation
- existing procedural palms were upgraded with a denser comic silhouette even outside the slice
- the visual slice uses the existing 2.5D PMDD projection and close pedestrian camera from 1.19 instead of requiring an engine migration
- Android export, runtime smoke and 3D Photo Hunt smoke all pass with the new SVG preload / texture rendering path

### Engine decision after the slice

Godot remains the active engine. The limiting factor was the former procedural-art pipeline, not Godot itself. The 1.20 slice proves that the project can mix the existing simulation / PMDD code with real modular visual assets on Android. The next visual work should therefore scale this modular 2.5D pipeline across the remaining districts rather than restart the project in another engine.

## 1.19.0 — Visual Rebuild & Headtracking Fix

- on-foot world zoom increases from 1.55x to 2.15x for a much denser pedestrian-scale view
- transit / driving zoom targets were rebalanced separately so the close pedestrian view does not make vehicles unusable
- the street camera is framed lower on screen in pedestrian mode so nearby façades and building height are visible immediately
- the PMDD projection now keeps a small default vertical perspective bias even when the player is not touching the view controls
- Photo Hunt starts from a slightly higher, downward-facing camera so architecture reads as 3D immediately
- Android gravity, gyroscope and accelerometer project sensors are now explicitly enabled
- the former gravity-only pseudo tracking is replaced by calibrated gyroscope + gravity sensor fusion with fast gyro response and slow drift correction
- changing headtracking sensitivity automatically recenters the sensor baseline
- the HUD / options surface now reports the active headtracking mode instead of claiming that merely detecting the front camera means face tracking is active
- district ground fills now scale correctly with world zoom
- roads, lane markings and sidewalk edge tiles now scale with the close world zoom instead of becoming visually too thin
- a new district-specific procedural tile pass differentiates heritage cobbles, campus/cultural paving, polished glass/center slabs, greenery, waterfront boards, industrial concrete and technical/air/solar surfaces
- sidewalk curb modules and reflector details add more street-scale texture
- building generation now uses district-specific massing / façade / roof recipes instead of drawing from one global random style pool
- heritage, green, glass, industrial, waterfront, campus, neon, terminal and other district types therefore produce more coherent architecture
- small wall / roof material variations reduce the repeated procedural look without breaking district identity
- vehicle screen size receives a restrained close-zoom compensation so the 2.15x pedestrian camera actually feels physically closer

## 1.18.0 — Cinematic Traffic & Visual Polish

- AI traffic can now very rarely produce real vehicle-to-vehicle collisions when two moving cars actually enter a spatial conflict
- accident probability stays low in clear weather and rises modestly in rain, mist and storms
- crashed cars become persistent temporary road obstacles with hazards, visible damage, debris, skid traces and a timed cleanup cycle
- dynamic accident scenes are routed into the existing emergency target system instead of using a separate fake-event layer
- ambulances and city-response vehicles can be dispatched to those newly created traffic accidents alongside the existing service incidents
- traffic slows around dynamic crash sites and uses hazards while passing
- active AI crashes appear on the city map with a dedicated accident marker
- moving traffic now uses broader headlight-beam rendering at night and in bad weather, not only the player car
- wet roads receive headlight, brake-light and emergency-light reflections
- vehicle bodies gain stronger shoulder/hood highlights plus improved glass reflections for clearer silhouettes
- ambulance and response vehicles cast subtle pulsing red/blue light spill
- roads gain wet puddles, reflective studs and stronger rain/storm sheen
- urban/glass/neon districts receive more night-light pools and wet-ground color reflections
- industrial/harbor surfaces gain additional hazard markings and visual texture
- glass, center, neon, terminal and expo façades gain wet sheen and stronger low-level illuminated signage
- accident scenes gain smoke, sparks, scuff marks, debris and nearby emergency-light spill while remaining non-gratuitous
- the visual pass remains graphics-quality-aware so the Android target is still protected

## 1.17.0 — Emergency City & Connected Transit

- traffic can now physically hit the on-foot player if a moving vehicle reaches the player before its braking logic can stop it
- AI cars actively attempt to brake for pedestrians, so collisions are avoidable rather than scripted, but stepping into traffic at the wrong moment can still cause an accident
- an accident triggers a short rescue / ambulance / emergency-room transition before respawning the player outside Parallax Stadtklinikum
- accident count persists in the save slot
- Parallax Stadtklinikum is a new Bioquartier landmark with its own map marker, bespoke 2D and 3D geometry, emergency entrance and ambulance bay
- the hospital is fully enterable with reception, triage, waiting areas, treatment / observation floor and an interactive triage station
- two dedicated ambulances and additional city-response vehicles now exist as real traffic actors
- emergency vehicles are dispatched to concrete active incident locations; multiple vehicles can be assigned to the same incident
- ambulances return to the hospital after incident service while response vehicles can be retasked to other active scenes
- normal traffic still yields for emergency vehicles and emergency routing uses the connected road graph rather than random turns
- public transit now creates real interchange hubs at junctions where different bus/tram route roads meet
- exiting at an interchange exposes the other line and boarding that line within the transfer window records a real transfer
- transfer hubs are marked on the city map and transfer count is tracked in the HUD / save data
- free pedestrians seeking shelter in rain/storms can now route across connected roads instead of being limited to cover on their current street
- selected shops, cafés and restaurants now run animated delivery/loading loops with courier vans, workers and moving crates
- harbor / industrial / rail districts add dock-loading scenes with pallets, forklifts and workers
- every district receives an additional authored signature scene so heritage, glass, solar, canal, center, harbor, industry, terminal, campus, astro, neon, expo, air, wind, data and waterfront areas read more distinctly at street level

## 1.16.0 — City Behavior

- transit stops now keep their own waiting, arrival and last-boarded / last-exited counts instead of using only decorative passenger waves
- stop demand grows over the in-game day and reacts to rush-hour windows plus district identity
- buses and trams board from the actual waiting pool, respect capacity and redistribute passengers per stop
- transit waiting groups now visually reflect real stop demand and display the actual boarding / exiting counts during dwell
- free pedestrians can interrupt their normal routine in rain or storms and actively seek a nearby authored shelter
- sheltered pedestrians remain under cover until conditions improve instead of carrying the same umbrella behavior everywhere
- response vehicles now receive BFS-generated multi-road routes across the real road graph
- routed response vehicles only turn at junctions that advance their assigned route and automatically receive a new destination when a route is complete
- district-authored social scenes add harbor / industrial work shifts, campus edges, nightlife clusters and park picnics beyond generic crowd pockets
- animated flags and ventilation stacks add more environmental motion to civic, campus, harbor, industrial, rail, terminal and data districts
- all new systems reuse the existing deterministic road, junction and social-scene data to stay lightweight on Android

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
