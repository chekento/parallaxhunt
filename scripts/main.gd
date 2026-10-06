extends Node2D

const WORLD_SIZE := Vector2(26000.0, 18000.0)
const WALK_SPEED := 165.0
const VEHICLE_CLASSES := ["micro","hatch","sedan","executive","suv","pickup","van","delivery","sport","hyper"]
const VEHICLE_SPEEDS := {
    "micro": 315.0, "hatch": 355.0, "sedan": 415.0, "executive": 455.0,
    "suv": 390.0, "pickup": 370.0, "van": 350.0, "delivery": 325.0,
    "sport": 535.0, "hyper": 610.0
}
const VEHICLE_ACCEL := {
    "micro": 260.0, "hatch": 275.0, "sedan": 245.0, "executive": 265.0,
    "suv": 220.0, "pickup": 205.0, "van": 190.0, "delivery": 175.0,
    "sport": 335.0, "hyper": 390.0
}
const VEHICLE_BRAKE := {
    "micro": 360.0, "hatch": 370.0, "sedan": 355.0, "executive": 375.0,
    "suv": 340.0, "pickup": 330.0, "van": 315.0, "delivery": 300.0,
    "sport": 440.0, "hyper": 500.0
}
const VEHICLE_HANDLING := {
    "micro": 2.85, "hatch": 2.65, "sedan": 2.30, "executive": 2.15,
    "suv": 1.95, "pickup": 1.82, "van": 1.70, "delivery": 1.58,
    "sport": 2.55, "hyper": 2.40
}
const VEHICLE_SPEED_GROUP := {
    "micro":"CITY","hatch":"CITY","sedan":"ROAD","executive":"ROAD",
    "suv":"UTILITY","pickup":"UTILITY","van":"UTILITY","delivery":"UTILITY",
    "sport":"PERFORMANCE","hyper":"HYPER"
}
const VEHICLE_SIZES := {
    "micro":Vector2(35,19),"hatch":Vector2(40,20),"sedan":Vector2(45,22),"executive":Vector2(49,23),
    "suv":Vector2(48,25),"pickup":Vector2(51,24),"van":Vector2(51,26),"delivery":Vector2(54,27),
    "sport":Vector2(49,20),"hyper":Vector2(52,19)
}

var rng := RandomNumberGenerator.new()
var districts: Array = []
var roads: Array = []
var junctions: Array = []
var parks: Array = []
var waters: Array = []
var buildings: Array = []
var trees: Array = []
var parked_cars: Array = []
var traffic: Array = []
var smart_agents: Array = []
var street_lights: Array = []
var street_props: Array = []
var landmarks: Array = []
var storefronts: Array = []
var vegetation_props: Array = []
var pedestrians: Array = []
var transit_vehicles: Array = []
var fragments: Array = []
var secrets: Array = []
var camera_pos := Vector2.ZERO
var player_pos := Vector2(5200, 4200)
var player_heading := 0.0
var current_vehicle := -1
var vehicle_velocity := 0.0
var view_touch := Vector2.ZERO
var sensor_view := Vector2.ZERO
var view_amount := Vector2.ZERO
var parallax_strength := 1.75
var scan_time := 0.0
var mission_fragments := 0
var mission_secrets := 0
var cache_count: int = 0
var glyph_count: int = 0
var photo_points: Array = []
var photo_count: int = 0
var photo_flash_alpha: float = 0.0
var photo_mode: bool = false
var active_photo_index: int = -1
var photo_targets: Array = []
var photo_found: Dictionary = {}
var photo_scores: Dictionary = {}
var photo_yaw: float = 0.0
var photo_pitch: float = -0.10
var photo_fov: float = 68.0
var photo_drag_touch: int = -1
var photo_drag_last := Vector2.ZERO
var photo_viewport: SubViewport
var photo_view_rect: TextureRect
var photo_world_root: Node3D
var photo_camera: Camera3D
var photo_target_label: Label
var photo_status_label: Label
var photo_shutter_button: Button
var photo_exit_button: Button
var photo_hint_button: Button
var photo_zoom_in_button: Button
var photo_zoom_out_button: Button
var photo_dynamic_cars: Dictionary = {}
var scan_points: Array = []
var scan_collect_count: int = 0
var visited_districts: Dictionary = {}
var driven_classes: Dictionary = {}
var current_district := ""
var camera_status := "Sensor-PMDD"
var world_clock := 19.15
var interior_active := false
var interior_name := ""
var interior_kind := ""
var interior_accent := Color("#73f3ce")
var interior_return_pos := Vector2.ZERO
var interior_player_pos := Vector2(450,560)
var interior_floor: int = 0
var interior_size := Vector2(900,700)
var world_zoom: float = 1.0
var target_world_zoom: float = 1.0
var map_open: bool = false
var missions_open: bool = false
var collection_open: bool = false
var credits: int = 520
var energy: float = 100.0
var inventory: Dictionary = {"scan_cell":0,"energy_drink":0,"transit_pass":0}
var shop_stock: Dictionary = {}
var owned_property: String = ""
var property_sites: Array = []
var mission_sites: Array = []
var hack_done: Dictionary = {}
var native_chapter: int = 0
var native_chapters: Array = []
var minigame_open: bool = false
var active_mission_site: Dictionary = {}
var game_panel: PanelContainer
var game_title: Label
var game_info: Label
var game_status: Label
var game_grid: GridContainer
var game_controls: HBoxContainer
var game_type: String = ""
var game_target: Array = []
var game_current: Array = []
var game_secret: Array = []
var game_guess: Array = []
var game_tries: int = 0
var game_memory_seq: Array = []
var game_memory_input: Array = []
var game_memory_locked: bool = false
var active_mission_replay: bool = false
var hack_replays: int = 0
var main_menu_active: bool = true
var selected_save_slot: int = 1
var new_game_mode: bool = false
var sound_enabled: bool = true
var sensor_gain: float = 1.0
var driving_assist: bool = true
var haptics_enabled: bool = true
var graphics_quality: int = 2
var main_menu_panel: PanelContainer
var menu_status: Label
var menu_slot_buttons: Array = []
var options_box: VBoxContainer
var sound_option_button: Button
var graphics_option_button: Button
var pmdd_option_button: Button
var sensor_option_button: Button
var drive_option_button: Button
var haptics_option_button: Button
var dialogue_panel: PanelContainer
var dialogue_title: Label
var dialogue_body: Label
var dialogue_actions: VBoxContainer
var active_dialogue_npc: int = -1
var npc_trust: Dictionary = {}
var active_npc_contract: Dictionary = {}
var npc_contracts_done: Dictionary = {}
var transit_trip_count: int = 0
var owned_cars: Array = []
var current_paint: String = ""
var service_vehicle_index: int = -1
var jobs_done: int = 0
var active_job: Dictionary = {}
var side_job_sites: Array = []
var named_npcs: Array = []
var caches: Array = []
var glyphs: Array = []
var npc_flags: Dictionary = {}
var vertical_sites: Array = []
var vertical_flags: Dictionary = {}
var current_vertical_id: String = ""
var relay_count: int = 0
var sublevel_count: int = 0
var transit_riding: int = -1
var transit_stops: Array = []
var autosave_timer: float = 0.0
var race_sites: Array = []
var active_race: Dictionary = {}
var race_best: Dictionary = {}
var race_wins: int = 0
var race_completed: Dictionary = {}
var vehicle_upgrades: Dictionary = {}
var milestones_claimed: Dictionary = {}
var commerce_panel: PanelContainer
var commerce_title: Label
var commerce_info: Label
var commerce_actions: VBoxContainer

# True multi-touch state: left and right touches can coexist.
var move_touch := -1
var look_touch := -1
var move_origin := Vector2.ZERO
var move_now := Vector2.ZERO
var look_origin := Vector2.ZERO
var look_now := Vector2.ZERO
var move_vec := Vector2.ZERO

var mission_label: Label
var detail_label: Label
var status_label: Label
var district_banner: Label
var reward_panel: PanelContainer
var reward_title: Label
var reward_body: Label
var interact_button: Button
var scan_button: Button
var sfx_player: AudioStreamPlayer
var sounds := {}
var last_secret_sound_ms := -99999

func _ready() -> void:
    rng.seed = 420042
    _build_districts()
    _build_roads()
    _build_water()
    _build_junctions()
    _build_parks()
    _build_landmarks()
    _build_native_gameplay_data()
    _build_story_content()
    _load_options()
    _generate_city()
    _generate_traffic()
    _generate_visual_props()
    _generate_storefronts()
    _generate_transit()
    _build_transit_stops()
    _generate_collectibles()
    _build_ui()
    _build_photo_3d_system()
    _build_audio()
    _bootstrap_android_camera()
    camera_pos = player_pos
    current_district = _district_at(player_pos).get("name", "Megacity")
    _refresh_main_menu()
    _update_ui()
    queue_redraw()

func _process(delta: float) -> void:
    _update_sensor(delta)
    if main_menu_active:
        world_clock = fposmod(world_clock + delta * 0.006,24.0)
        queue_redraw()
        return
    if photo_mode:
        target_world_zoom = 1.0
    elif interior_active:
        target_world_zoom = 1.0
    elif current_vehicle >= 0:
        target_world_zoom = 0.76
    else:
        target_world_zoom = 1.55
    world_zoom = lerpf(world_zoom,target_world_zoom,minf(1.0,delta*4.5))
    _update_player(delta)
    if not interior_active:
        _update_traffic(delta)
        _update_pedestrians(delta)
        _update_transit(delta)
    if photo_mode:
        _update_photo_3d_scene(delta)
    world_clock = fposmod(world_clock + delta * 0.018, 24.0)
    scan_time = maxf(0.0, scan_time - delta)
    photo_flash_alpha=maxf(0.0,photo_flash_alpha-delta*2.8)
    autosave_timer += delta
    if autosave_timer >= 12.0:
        autosave_timer = 0.0
        _save_game()
    view_amount = view_amount.lerp((sensor_view * 0.72 + view_touch * 0.95).limit_length(1.0), minf(1.0, delta * 8.0))
    if not interior_active:
        camera_pos = camera_pos.lerp(player_pos, minf(1.0, delta * (4.0 if current_vehicle >= 0 else 7.0)))
        _update_secrets()
        _update_district()
        _check_npc_contract()
        _check_active_job_progress()
        _update_active_race(delta)
        _check_milestones()
    _update_ui()
    queue_redraw()

func _input(event: InputEvent) -> void:
    if photo_mode:
        _input_photo_mode(event)
        return
    if main_menu_active:
        return
    if event is InputEventScreenTouch:
        var t := event as InputEventScreenTouch
        if t.pressed:
            if t.position.x < get_viewport_rect().size.x * 0.48 and move_touch < 0:
                move_touch = t.index
                move_origin = t.position
                move_now = t.position
            elif look_touch < 0:
                look_touch = t.index
                look_origin = t.position
                look_now = t.position
        else:
            if t.index == move_touch:
                move_touch = -1
                move_vec = Vector2.ZERO
                move_origin = Vector2.ZERO
                move_now = Vector2.ZERO
            if t.index == look_touch:
                look_touch = -1
                view_touch = Vector2.ZERO
                look_origin = Vector2.ZERO
                look_now = Vector2.ZERO
    elif event is InputEventScreenDrag:
        var d := event as InputEventScreenDrag
        if d.index == move_touch:
            move_now = d.position
            var delta_move := move_now - move_origin
            var raw_move := delta_move.limit_length(82.0)/82.0
            if raw_move.length()<0.11:
                move_vec=Vector2.ZERO
            else:
                var mag := pow((raw_move.length()-0.11)/0.89,1.18)
                move_vec=raw_move.normalized()*clampf(mag,0.0,1.0)
        elif d.index == look_touch:
            look_now = d.position
            var delta_look := look_now - look_origin
            var raw_look := Vector2(delta_look.x,delta_look.y).limit_length(165.0)/165.0
            view_touch = Vector2.ZERO if raw_look.length()<0.075 else raw_look
    elif event is InputEventKey and event.pressed:
        if event.is_action_pressed("interact"):
            _interact()
        elif event.is_action_pressed("scan"):
            _scan()

func _build_districts() -> void:
    districts = [
        {"name":"Altstadt","rect":Rect2(0,0,5200,3600),"ground":Color("#1d252d"),"wall":Color("#76584b"),"roof":Color("#9b7560"),"accent":Color("#ffcd8a"),"style":"heritage"},
        {"name":"Kulturviertel","rect":Rect2(5200,0,5200,3600),"ground":Color("#17242d"),"wall":Color("#4c5d67"),"roof":Color("#687b87"),"accent":Color("#9bdcff"),"style":"culture"},
        {"name":"Glasdistrikt","rect":Rect2(10400,0,5200,3600),"ground":Color("#102532"),"wall":Color("#285166"),"roof":Color("#39758d"),"accent":Color("#67d9ff"),"style":"glass"},
        {"name":"Nordpark","rect":Rect2(15600,0,5200,3600),"ground":Color("#182a22"),"wall":Color("#395744"),"roof":Color("#55745b"),"accent":Color("#8ff0b4"),"style":"green"},
        {"name":"Solar Heights","rect":Rect2(20800,0,5200,3600),"ground":Color("#222a2d"),"wall":Color("#596140"),"roof":Color("#7f8953"),"accent":Color("#f1e36f"),"style":"solar"},
        {"name":"Kanäle","rect":Rect2(0,3600,5200,3600),"ground":Color("#10242b"),"wall":Color("#354e59"),"roof":Color("#4b6570"),"accent":Color("#64e7e4"),"style":"canal"},
        {"name":"Zentrum","rect":Rect2(5200,3600,5200,3600),"ground":Color("#17222b"),"wall":Color("#485966"),"roof":Color("#657786"),"accent":Color("#9ad5ff"),"style":"center"},
        {"name":"Hafen","rect":Rect2(10400,3600,5200,3600),"ground":Color("#20252a"),"wall":Color("#55473e"),"roof":Color("#736155"),"accent":Color("#ffb66f"),"style":"harbor"},
        {"name":"Industrie","rect":Rect2(15600,3600,5200,3600),"ground":Color("#252525"),"wall":Color("#575554"),"roof":Color("#75716d"),"accent":Color("#ff986e"),"style":"industry"},
        {"name":"Transit Yard","rect":Rect2(20800,3600,5200,3600),"ground":Color("#20272b"),"wall":Color("#505f66"),"roof":Color("#6e7a80"),"accent":Color("#9adbe5"),"style":"terminal"},
        {"name":"Gärten","rect":Rect2(0,7200,5200,3600),"ground":Color("#17271d"),"wall":Color("#425c41"),"roof":Color("#5d7658"),"accent":Color("#9be993"),"style":"garden"},
        {"name":"Universität","rect":Rect2(5200,7200,5200,3600),"ground":Color("#182131"),"wall":Color("#45516b"),"roof":Color("#65718c"),"accent":Color("#b0c8ff"),"style":"campus"},
        {"name":"Observatorium","rect":Rect2(10400,7200,5200,3600),"ground":Color("#18182a"),"wall":Color("#413b61"),"roof":Color("#625a88"),"accent":Color("#c3a6ff"),"style":"astro"},
        {"name":"Außenring","rect":Rect2(15600,7200,5200,3600),"ground":Color("#242b2d"),"wall":Color("#4d5d5c"),"roof":Color("#6b7976"),"accent":Color("#a8d7c9"),"style":"ring"},
        {"name":"Neon Mile","rect":Rect2(20800,7200,5200,3600),"ground":Color("#1d1930"),"wall":Color("#53375e"),"roof":Color("#764b82"),"accent":Color("#ff80ef"),"style":"neon"},
        {"name":"Moorhafen","rect":Rect2(0,10800,5200,3600),"ground":Color("#172329"),"wall":Color("#3e5555"),"roof":Color("#58706d"),"accent":Color("#79d7c5"),"style":"canal"},
        {"name":"Messe","rect":Rect2(5200,10800,5200,3600),"ground":Color("#21242c"),"wall":Color("#545b70"),"roof":Color("#707993"),"accent":Color("#a9bcff"),"style":"expo"},
        {"name":"Bioquartier","rect":Rect2(10400,10800,5200,3600),"ground":Color("#182820"),"wall":Color("#3c6249"),"roof":Color("#568362"),"accent":Color("#82e59b"),"style":"green"},
        {"name":"Aurora Hills","rect":Rect2(15600,10800,5200,3600),"ground":Color("#201e31"),"wall":Color("#554d77"),"roof":Color("#71669a"),"accent":Color("#c0a7ff"),"style":"astro"},
        {"name":"Terminal East","rect":Rect2(20800,10800,5200,3600),"ground":Color("#20262a"),"wall":Color("#535a60"),"roof":Color("#747c83"),"accent":Color("#d9e5ef"),"style":"terminal"},
        {"name":"Aerodrome","rect":Rect2(0,14400,5200,3600),"ground":Color("#252a2e"),"wall":Color("#59636a"),"roof":Color("#78848b"),"accent":Color("#c9e7f3"),"style":"air"},
        {"name":"Windfeld","rect":Rect2(5200,14400,5200,3600),"ground":Color("#1d2928"),"wall":Color("#4b6661"),"roof":Color("#67847d"),"accent":Color("#8be8d7"),"style":"wind"},
        {"name":"Data Fields","rect":Rect2(10400,14400,5200,3600),"ground":Color("#171f2c"),"wall":Color("#3c4d68"),"roof":Color("#566a8b"),"accent":Color("#77aaff"),"style":"data"},
        {"name":"Küstenband","rect":Rect2(15600,14400,5200,3600),"ground":Color("#15272c"),"wall":Color("#3f6066"),"roof":Color("#5c7e83"),"accent":Color("#72d7e6"),"style":"coast"},
        {"name":"Railworks","rect":Rect2(20800,14400,5200,3600),"ground":Color("#282626"),"wall":Color("#665b55"),"roof":Color("#84746a"),"accent":Color("#e8a977"),"style":"rail"}
    ]

func _build_roads() -> void:
    roads.clear()
    for x in [900.0, 2700.0, 5000.0, 7500.0, 10100.0, 12800.0, 15400.0, 18100.0, 21000.0, 24400.0]:
        roads.append({"points":PackedVector2Array([Vector2(x,0),Vector2(x,WORLD_SIZE.y)]), "width":180.0})
    for y in [900.0, 2600.0, 4450.0, 6500.0, 9000.0, 11600.0, 14300.0, 16800.0]:
        roads.append({"points":PackedVector2Array([Vector2(0,y),Vector2(WORLD_SIZE.x,y)]), "width":170.0})
    roads.append({"points":PackedVector2Array([Vector2(1200,10500),Vector2(3700,9800),Vector2(6200,10300),Vector2(9000,12100),Vector2(12400,12600),Vector2(16000,11800)]), "width":150.0})
    roads.append({"points":PackedVector2Array([Vector2(16800,1200),Vector2(18000,2600),Vector2(19200,5000),Vector2(21000,6800),Vector2(24800,7600)]), "width":140.0})
    roads.append({"points":PackedVector2Array([Vector2(500,15500),Vector2(3300,14600),Vector2(5400,15000),Vector2(7800,16500),Vector2(11200,17000)]), "width":130.0})
    roads.append({"points":PackedVector2Array([Vector2(900,3200),Vector2(2200,3550),Vector2(3600,3300),Vector2(4700,2700),Vector2(6100,2350)]), "width":118.0})
    roads.append({"points":PackedVector2Array([Vector2(9900,7800),Vector2(11200,8200),Vector2(12600,8050),Vector2(13900,7500),Vector2(15200,7700)]), "width":122.0})
    roads.append({"points":PackedVector2Array([Vector2(16000,15100),Vector2(17700,14650),Vector2(19400,14900),Vector2(21000,15700),Vector2(24400,16050)]), "width":124.0})
    roads.append({"points":PackedVector2Array([Vector2(14800,10400),Vector2(16400,9800),Vector2(18000,10150),Vector2(19400,11000),Vector2(21100,11350)]), "width":116.0})
    roads.append({"points":PackedVector2Array([Vector2(5200,7200),Vector2(6500,6800),Vector2(7900,7050),Vector2(9300,7900),Vector2(10100,9000)]), "width":112.0})

func _build_junctions() -> void:
    junctions.clear()
    # The first 10 roads are vertical and the next 8 horizontal.
    for vi in range(10):
        for hi in range(10,18):
            var vx: float = float(roads[vi].points[0].x)
            var hy: float = float(roads[hi].points[0].y)
            var pos := Vector2(vx,hy)
            var bridge := ((vi*7 + hi*3) % 17 == 0) or _point_over_water(pos)
            # Bridges are exceptional. Normal nodes are true same-level intersections.
            junctions.append({
                "pos":pos,
                "a":vi,
                "b":hi,
                "ta":hy/WORLD_SIZE.y,
                "tb":vx/WORLD_SIZE.x,
                "bridge":bridge,
                "over":vi if (vi+hi)%2==0 else hi,
                "phase":(vi+hi)%2
            })

func _point_over_water(p: Vector2) -> bool:
    for w in waters:
        if (w.rect as Rect2).grow(120).has_point(p):
            return true
    return false

func _junction_green(j: Dictionary, road_index: int) -> bool:
    if bool(j.bridge):
        return true
    var phase: int = int(floor(Time.get_ticks_msec()/6500.0)) % 2
    var green_road: int = int(j.a) if phase==int(j.phase) else int(j.b)
    return road_index==green_road

func _junction_for_car(road_index: int, t: float, lookahead: float = 0.035) -> Dictionary:
    for j in junctions:
        if bool(j.bridge):
            continue
        var jt: float = -1.0
        if int(j.a)==road_index:
            jt=float(j.ta)
        elif int(j.b)==road_index:
            jt=float(j.tb)
        if jt<0.0:
            continue
        if abs(jt-t)<=lookahead:
            return j
    return {}

func _traffic_world_transform(c: Dictionary) -> Dictionary:
    var road = roads[int(c.road)]
    var t: float = float(c.t)
    var tangent := _polyline_tangent(road.points,t)
    if bool(c.reverse):
        tangent *= -1.0
    var normal := Vector2(-tangent.y,tangent.x)
    var lane: int = int(c.get("lane",0))
    var lane_offset: float = float(road.width)*(0.18 + float(lane)*0.14)
    # Right-hand traffic: +normal is the right side relative to travel direction.
    var pos := _sample_polyline(road.points,t) + normal*lane_offset
    return {"pos":pos,"tangent":tangent,"normal":normal}

func _build_parks() -> void:
    parks = [
        {"rect":Rect2(11200,500,2800,1500),"name":"Nordpark","attraction":"Fountain"},
        {"rect":Rect2(1200,10800,2200,1700),"name":"Garden Commons","attraction":"Stage"},
        {"rect":Rect2(7600,10400,1900,1400),"name":"Campus Green","attraction":"Sculpture"},
        {"rect":Rect2(17400,6900,2500,1300),"name":"Neon Plaza","attraction":"Light Spire"},
        {"rect":Rect2(14600,13700,1800,1400),"name":"Aurora Park","attraction":"Pavilion"},
        {"rect":Rect2(21600,12300,2100,1250),"name":"Terminal Pocket Park","attraction":"Clock"},
        {"rect":Rect2(5600,900,1500,1050),"name":"Culture Courtyard","attraction":"Art Wall"},
        {"rect":Rect2(1600,7900,1500,1100),"name":"Canal Steps","attraction":"Pond"},
        {"rect":Rect2(16400,4200,1600,1100),"name":"Foundry Square","attraction":"Skate Bowl"},
        {"rect":Rect2(22200,7800,1550,1050),"name":"Neon Pocket","attraction":"Drone Pad"},
        {"rect":Rect2(10700,11300,1450,1050),"name":"Bio Garden","attraction":"Rose Garden"},
        {"rect":Rect2(3900,14500,1600,1150),"name":"Aerodrome Family Park","attraction":"Playground"}
    ]

func _build_water() -> void:
    waters = [
        {"rect":Rect2(430,4750,720,3600), "tint":Color("#174b61"), "name":"Westkanal"},
        {"rect":Rect2(3500,5050,1050,2700), "tint":Color("#15566a"), "name":"Museumskanal"},
        {"rect":Rect2(11000,6900,3900,780), "tint":Color("#194c61"), "name":"Hafenbecken"},
        {"rect":Rect2(12100,7700,1850,900), "tint":Color("#1b5268"), "name":"Dock Basin"},
        {"rect":Rect2(18000,7300,3100,620), "tint":Color("#25235a"), "name":"Neon Reflecting Pool"}
    ]

func _build_landmarks() -> void:
    landmarks = [
        {"name":"Old Clock Tower","district":"Altstadt","pos":Vector2(1850,1650),"size":Vector2(360,300),"h":220.0,"kind":"clock","accent":Color("#ffcd8a")},
        {"name":"Crystal Forum","district":"Glasdistrikt","pos":Vector2(8050,1700),"size":Vector2(520,380),"h":310.0,"kind":"crystal","accent":Color("#67d9ff")},
        {"name":"OpenAI HQ","district":"Glasdistrikt","pos":Vector2(9000,3150),"size":Vector2(820,520),"h":295.0,"kind":"openai_hq","accent":Color("#f2f7f7")},
        {"name":"Nordpark Glasshouse","district":"Nordpark","pos":Vector2(12800,1480),"size":Vector2(600,420),"h":120.0,"kind":"greenhouse","accent":Color("#8ff0b4")},
        {"name":"Solar Beacon","district":"Solar Heights","pos":Vector2(20600,1550),"size":Vector2(460,360),"h":255.0,"kind":"solar_beacon","accent":Color("#f1e36f")},
        {"name":"Canal Rotunda","district":"Kanäle","pos":Vector2(2700,6500),"size":Vector2(480,420),"h":145.0,"kind":"rotunda","accent":Color("#64e7e4")},
        {"name":"Civic Prism","district":"Zentrum","pos":Vector2(7900,6500),"size":Vector2(520,440),"h":285.0,"kind":"civic","accent":Color("#9ad5ff")},
        {"name":"Harbor Crane Hall","district":"Hafen","pos":Vector2(13100,6150),"size":Vector2(720,430),"h":135.0,"kind":"crane","accent":Color("#ffb66f")},
        {"name":"Neon Theatre","district":"Neon Mile","pos":Vector2(19800,6000),"size":Vector2(680,500),"h":205.0,"kind":"theatre","accent":Color("#ff80ef")},
        {"name":"Garden Conservatory","district":"Gärten","pos":Vector2(3300,13500),"size":Vector2(640,520),"h":125.0,"kind":"conservatory","accent":Color("#9be993")},
        {"name":"Axis Library","district":"Universität","pos":Vector2(9300,13200),"size":Vector2(700,520),"h":175.0,"kind":"library","accent":Color("#b0c8ff")},
        {"name":"Astra Observatory","district":"Observatorium","pos":Vector2(15600,13650),"size":Vector2(620,540),"h":245.0,"kind":"observatory","accent":Color("#c3a6ff")},
        {"name":"Terminal Crown","district":"Terminal East","pos":Vector2(22200,13900),"size":Vector2(820,520),"h":165.0,"kind":"terminal","accent":Color("#d9e5ef")}
    ]

func _landmark_rect(l: Dictionary) -> Rect2:
    return Rect2(l.pos - l.size * 0.5, l.size)

func _rect_hits_landmark(r: Rect2) -> bool:
    for l in landmarks:
        if _landmark_rect(l).grow(70).intersects(r):
            return true
    return false

func _build_native_gameplay_data() -> void:
    property_sites = [
        {"id":"canal_loft","name":"Canal Loft","pos":Vector2(4420,5480),"price":460,"garage":5},
        {"id":"garden_house","name":"Garden House","pos":Vector2(2480,9080),"price":720,"garage":8},
        {"id":"aurora_home","name":"Aurora Residence","pos":Vector2(18200,12650),"price":980,"garage":10}
    ]
    mission_sites = [
        {"id":"gridRepair","name":"Solar Grid Terminal","pos":Vector2(23100,1750),"game":"wire","reward":"Grid Key","difficulty":1},
        {"id":"transitMosaic","name":"Transit Routing Wall","pos":Vector2(22800,5250),"game":"slide","reward":"Route Tile","difficulty":1},
        {"id":"cipherGate","name":"Neon Cipher Gate","pos":Vector2(23600,8700),"game":"mastermind","reward":"Cipher Core","difficulty":2},
        {"id":"spectrum","name":"Spectrum Array","pos":Vector2(13000,8750),"game":"frequency","reward":"Spectrum Seal","difficulty":2},
        {"id":"packetTrace","name":"Expo Packet Node","pos":Vector2(7550,12600),"game":"memory","reward":"Packet Token","difficulty":2},
        {"id":"firewall","name":"Bio Firewall","pos":Vector2(12650,12650),"game":"lightsout","reward":"Firewall Shard","difficulty":3},
        {"id":"railCipher","name":"Railworks Signal Cipher","pos":Vector2(23200,16250),"game":"mastermind","reward":"Rail Token","difficulty":3},
        {"id":"windSync","name":"Windfeld Phase Sync","pos":Vector2(7600,16050),"game":"frequency","reward":"Wind Seal","difficulty":3},
        {"id":"dataTrace","name":"Data Fields Trace","pos":Vector2(12850,16000),"game":"memory","reward":"Data Trace","difficulty":3},
        {"id":"coastGrid","name":"Coast Relay Grid","pos":Vector2(18150,16050),"game":"wire","reward":"Coast Key","difficulty":3},
        {"id":"airportRoute","name":"Aerodrome Routing","pos":Vector2(2600,16050),"game":"slide","reward":"Runway Tile","difficulty":2},
        {"id":"auroraFirewall","name":"Aurora Light Lattice","pos":Vector2(18150,12600),"game":"lightsout","reward":"Aurora Shard","difficulty":3}
    ]
    side_job_sites = [
        {"id":"jobs_center","name":"Zentrum Jobboard","pos":Vector2(8050,5650)},
        {"id":"jobs_harbor","name":"Hafen Dispatch","pos":Vector2(13250,5850)},
        {"id":"jobs_terminal","name":"Terminal Courier Hub","pos":Vector2(23200,12600)}
    ]
    race_sites = [
        {"id":"oldtown_loop","name":"Oldtown Handling Loop","pos":Vector2(2700,2600),"limit":58.0,"reward":90,"group":"CITY","points":[Vector2(5000,2600),Vector2(5000,4450),Vector2(2700,4450),Vector2(900,3200),Vector2(2700,2600)]},
        {"id":"glass_sprint","name":"Glass District Sprint","pos":Vector2(10100,2600),"limit":48.0,"reward":105,"group":"ROAD","points":[Vector2(12800,2600),Vector2(15400,4450),Vector2(12800,6500),Vector2(10100,4450)]},
        {"id":"harbor_run","name":"Harbor Utility Run","pos":Vector2(12800,6500),"limit":62.0,"reward":115,"group":"UTILITY","points":[Vector2(15400,6500),Vector2(15400,9000),Vector2(12800,9000),Vector2(10100,6500)]},
        {"id":"neon_velocity","name":"Neon Velocity Trial","pos":Vector2(21000,9000),"limit":42.0,"reward":145,"group":"PERFORMANCE","points":[Vector2(24400,9000),Vector2(24400,11600),Vector2(21000,11600),Vector2(18100,9000)]},
        {"id":"coastal_gt","name":"Coastal GT","pos":Vector2(18100,14300),"limit":52.0,"reward":135,"group":"ROAD","points":[Vector2(21000,14300),Vector2(24400,16050),Vector2(21000,16800),Vector2(18100,16050)]},
        {"id":"hyperline","name":"Hyperline Challenge","pos":Vector2(24400,7600),"limit":36.0,"reward":190,"group":"HYPER","points":[Vector2(21000,6800),Vector2(18100,5000),Vector2(15400,2600),Vector2(12800,900)]}
    ]
    native_chapters = [
        {"title":"Echo-Signale bergen","desc":"Sammle fünf Echo-Signale in der Stadt.","kind":"frag","goal":5},
        {"title":"Mira finden","desc":"Sprich mit Mira im Zentrum.","kind":"npc","id":"mira","goal":1},
        {"title":"Verdeckte Wege","desc":"Entdecke drei Perspektiv-Geheimnisse.","kind":"secret","goal":3},
        {"title":"Verlorene Caches","desc":"Berge vier Daten-Caches.","kind":"cache","goal":4},
        {"title":"Stadtsigils","desc":"Sichere drei Stadtsigils.","kind":"glyph","goal":3},
        {"title":"Nova am Hafen","desc":"Sprich mit Nova im Hafen.","kind":"npc","id":"nova","goal":1},
        {"title":"Aufstieg","desc":"Finde einen Dachzugang und aktiviere ein Relay.","kind":"relay","goal":1},
        {"title":"Über den Dächern","desc":"Synchronisiere drei Dach-Relays.","kind":"relay","goal":3},
        {"title":"Unter der Stadt","desc":"Aktiviere zwei Sublevel-Knoten.","kind":"sublevel","goal":2},
        {"title":"OpenAI HQ","desc":"Besuche das OpenAI HQ im Glasdistrikt.","kind":"visit_openai","goal":1},
        {"title":"Solar Grid Repair","desc":"Löse das Leitungs-Puzzle am Solar Grid Terminal.","kind":"hack","id":"gridRepair","goal":1},
        {"title":"Transit Mosaic","desc":"Setze das Transit-Routing als Schiebepuzzle zusammen.","kind":"hack","id":"transitMosaic","goal":1},
        {"title":"Cipher Gate","desc":"Knacke den Mastermind-Code in Neon Mile.","kind":"hack","id":"cipherGate","goal":1},
        {"title":"Spectrum Alignment","desc":"Stimme die Frequenzkanäle am Observatorium ab.","kind":"hack","id":"spectrum","goal":1},
        {"title":"Packet Trace","desc":"Rekonstruiere die Paketfolge am Expo-Knoten.","kind":"hack","id":"packetTrace","goal":1},
        {"title":"Firewall Lattice","desc":"Schalte das Firewall-Raster vollständig dunkel.","kind":"hack","id":"firewall","goal":1},
        {"title":"Iris","desc":"Melde dich nach dem Firewall-Hack bei Iris.","kind":"npc","id":"iris","goal":1},
        {"title":"Nebenjobs","desc":"Schließe zwei Stadtaufträge ab und verdiene Credits.","kind":"jobs","goal":2},
        {"title":"Werkstatt","desc":"Besuche eine Garage oder Werkstatt und lackiere ein Fahrzeug.","kind":"paint","goal":1},
        {"title":"Eigenheim","desc":"Kaufe ein Gebäude mit Garage.","kind":"property","goal":1},
        {"title":"Fahrzeugsammlung","desc":"Lagere mindestens ein Fahrzeug in deiner Hausgarage.","kind":"stored_car","goal":1},
        {"title":"Photo Hunt I","desc":"Fotografiere drei markierte PMDD-Fotopunkte aus dem richtigen Blickwinkel.","kind":"photo","goal":3},
        {"title":"Fahrzeugkunde","desc":"Fahre mindestens vier unterschiedliche Fahrzeugklassen.","kind":"vehicles","goal":4},
        {"title":"Stadtentdecker","desc":"Besuche zwölf unterschiedliche Stadtteile.","kind":"districts","goal":12},
        {"title":"Photo Hunt II","desc":"Vervollständige acht Fotopunkte.","kind":"photo","goal":8},
        {"title":"District Lens","desc":"Sammle fünfzehn PMDD-Fotopunkte aus verschiedenen Stadtzonen.","kind":"photo","goal":15},
        {"title":"Stadtarchiv","desc":"Sichere insgesamt 25 Sammlerstücke aus Caches, Sigils und Photo Hunt.","kind":"archive","goal":25},
        {"title":"Street Signals","desc":"Finde und scanne fünf versteckte Stadt-Signale.","kind":"scan_collect","goal":5},
        {"title":"Urban Spectrum","desc":"Scanne fünfzehn versteckte Street Signals.","kind":"scan_collect","goal":15},
        {"title":"Hacking Marathon","desc":"Schließe mindestens zehn unterschiedliche Hacking-Terminals ab.","kind":"hack_count","goal":10},
        {"title":"Sammler","desc":"Berge acht Caches und sechs Stadtsigils.","kind":"collector","goal":14},
        {"title":"Hack Replay","desc":"Wiederhole fünf Hacking-Terminals für Bonus-Credits.","kind":"hack_replays","goal":5},
        {"title":"Street Trials","desc":"Gewinne drei unterschiedliche Zeitprüfungen.","kind":"races","goal":3},
        {"title":"Tuning-Projekt","desc":"Kaufe drei Werkstatt-Upgrades für deine Fahrzeugklassen.","kind":"upgrades","goal":3},
        {"title":"Freies Stadtleben","desc":"Erkunde POIs, Innenräume, Fahrzeuge und Nebenaktivitäten.","kind":"free","goal":1}
    ]
    if shop_stock.is_empty():
        shop_stock = {
            "energy_drink":8,
            "scan_cell":6,
            "transit_pass":3
        }

func _build_story_content() -> void:
    named_npcs = [
        {"id":"mira","name":"Mira","pos":Vector2(6900,5100),"role":"Archivarin","accent":Color("#73f3ce"),"text":"Die Stadt verschiebt sich nicht nur optisch. Einige Daten existieren nur aus dem richtigen Blickwinkel."},
        {"id":"nova","name":"Nova","pos":Vector2(12850,5700),"role":"Hafen-Kurierin","accent":Color("#ffb66f"),"text":"Wenn du die Caches findest, kann ich die Routen der alten Infrastruktur wieder zusammensetzen."},
        {"id":"luna","name":"Luna","pos":Vector2(22800,1700),"role":"Solar-Technikerin","accent":Color("#f1e36f"),"text":"Das Solar Grid braucht jemanden, der nicht nur Leitungen sieht, sondern räumliche Zusammenhänge."},
        {"id":"iris","name":"Iris","pos":Vector2(12700,12550),"role":"Bio-Security","accent":Color("#82e59b"),"text":"Die Firewall ist absichtlich räumlich fragmentiert. Eine flache Ansicht reicht hier nicht."},
        {"id":"vio","name":"Vio","pos":Vector2(23200,8600),"role":"Arcade Host","accent":Color("#ff80ef"),"text":"Cipher Gate ist mein Lieblingsspiel. Vier Stellen, sechs Zustände, keine Ausreden."},
        {"id":"bram","name":"Bram","pos":Vector2(23000,5400),"role":"Transitmeister","accent":Color("#9adbe5"),"text":"Die Linien funktionieren wieder besser. Achte auf die Haltephasen, bevor du einsteigst."}
    ]
    caches = [
        {"pos":Vector2(1800,2600),"taken":false},
        {"pos":Vector2(4200,6100),"taken":false},
        {"pos":Vector2(8450,4750),"taken":false},
        {"pos":Vector2(11800,6100),"taken":false},
        {"pos":Vector2(17100,5150),"taken":false},
        {"pos":Vector2(23200,5900),"taken":false},
        {"pos":Vector2(3600,9000),"taken":false},
        {"pos":Vector2(8900,8900),"taken":false},
        {"pos":Vector2(13700,9300),"taken":false},
        {"pos":Vector2(18700,9150),"taken":false},
        {"pos":Vector2(7400,12700),"taken":false},
        {"pos":Vector2(12600,12800),"taken":false}
    ]
    vertical_sites = [
        {"id":"roof_glass","name":"Glass Quarter Roof","pos":Vector2(12150,2450),"kind":"roof","accent":Color("#67d9ff")},
        {"id":"roof_solar","name":"Solar Beacon Roof","pos":Vector2(22500,2200),"kind":"roof","accent":Color("#f1e36f")},
        {"id":"roof_neon","name":"Neon Mile Roof","pos":Vector2(23500,9250),"kind":"roof","accent":Color("#ff80ef")},
        {"id":"roof_observatory","name":"Observatory Roof","pos":Vector2(13000,9300),"kind":"roof","accent":Color("#c3a6ff")},
        {"id":"sub_harbor","name":"Harbor Service Sublevel","pos":Vector2(13350,6400),"kind":"sublevel","accent":Color("#ffb66f")},
        {"id":"sub_transit","name":"Transit Utility Node","pos":Vector2(23200,6000),"kind":"sublevel","accent":Color("#9adbe5")},
        {"id":"sub_bio","name":"Bio Utility Lab","pos":Vector2(12850,12850),"kind":"sublevel","accent":Color("#82e59b")}
    ]
    scan_points = [
        {"id":"scan_oldwall","label":"Oldwall Echo","pos":Vector2(1450,2950),"taken":false,"district":"Altstadt","reward":18},
        {"id":"scan_culture","label":"Culture Pulse","pos":Vector2(6500,2900),"taken":false,"district":"Kulturviertel","reward":18},
        {"id":"scan_glass","label":"Glasscode 7","pos":Vector2(11100,3000),"taken":false,"district":"Glasdistrikt","reward":20},
        {"id":"scan_north","label":"Green Signal","pos":Vector2(16700,2500),"taken":false,"district":"Nordpark","reward":18},
        {"id":"scan_solar","label":"Helio Tag","pos":Vector2(22100,2850),"taken":false,"district":"Solar Heights","reward":20},
        {"id":"scan_canal","label":"Canal Cipher","pos":Vector2(1850,5600),"taken":false,"district":"Kanäle","reward":18},
        {"id":"scan_center","label":"Civic Trace","pos":Vector2(6500,5650),"taken":false,"district":"Zentrum","reward":20},
        {"id":"scan_harbor","label":"Dock Signal","pos":Vector2(11600,5650),"taken":false,"district":"Hafen","reward":18},
        {"id":"scan_industry","label":"Foundry Mark","pos":Vector2(16900,6000),"taken":false,"district":"Industrie","reward":20},
        {"id":"scan_transit","label":"Route Ghost","pos":Vector2(22100,6000),"taken":false,"district":"Transit Yard","reward":20},
        {"id":"scan_garden","label":"Garden Frequency","pos":Vector2(2100,9600),"taken":false,"district":"Gärten","reward":18},
        {"id":"scan_uni","label":"Campus Packet","pos":Vector2(6400,9700),"taken":false,"district":"Universität","reward":18},
        {"id":"scan_observe","label":"Astra Whisper","pos":Vector2(11600,9600),"taken":false,"district":"Observatorium","reward":22},
        {"id":"scan_ring","label":"Ring Marker","pos":Vector2(16900,9600),"taken":false,"district":"Außenring","reward":18},
        {"id":"scan_neon","label":"Neon Ghost","pos":Vector2(22100,9700),"taken":false,"district":"Neon Mile","reward":22},
        {"id":"scan_moor","label":"Moor Signal","pos":Vector2(2000,12800),"taken":false,"district":"Moorhafen","reward":18},
        {"id":"scan_expo","label":"Expo Ping","pos":Vector2(6500,12800),"taken":false,"district":"Messe","reward":20},
        {"id":"scan_bio","label":"Bio Signature","pos":Vector2(11600,13000),"taken":false,"district":"Bioquartier","reward":22},
        {"id":"scan_aurora","label":"Aurora Trace","pos":Vector2(16900,13000),"taken":false,"district":"Aurora Hills","reward":22},
        {"id":"scan_terminal","label":"Terminal Hash","pos":Vector2(22200,13000),"taken":false,"district":"Terminal East","reward":20},
        {"id":"scan_aero","label":"Runway Ghost","pos":Vector2(1900,16500),"taken":false,"district":"Aerodrome","reward":22},
        {"id":"scan_wind","label":"Wind Harmonic","pos":Vector2(6500,16500),"taken":false,"district":"Windfeld","reward":22},
        {"id":"scan_data","label":"Data Shard","pos":Vector2(11600,16500),"taken":false,"district":"Data Fields","reward":24},
        {"id":"scan_coast","label":"Coastline Ping","pos":Vector2(16900,16500),"taken":false,"district":"Küstenband","reward":22},
        {"id":"scan_rail","label":"Rail Pulse","pos":Vector2(22200,16500),"taken":false,"district":"Railworks","reward":24}
    ]
    photo_points = [
        {"id":"photo_clock","label":"Clock Tower Parallax","pos":Vector2(1850,1950),"dir":Vector2(0.75,-0.20),"taken":false,"district":"Altstadt","reward":32},
        {"id":"photo_crystal","label":"Crystal Reflection","pos":Vector2(8050,2080),"dir":Vector2(-0.72,0.16),"taken":false,"district":"Kulturviertel","reward":34},
        {"id":"photo_openai","label":"OpenAI Skybridge","pos":Vector2(9000,3560),"dir":Vector2(0.82,-0.14),"taken":false,"district":"Glasdistrikt","reward":45},
        {"id":"photo_greenhouse","label":"Nordpark Glasshouse","pos":Vector2(12800,1950),"dir":Vector2(-0.62,-0.40),"taken":false,"district":"Nordpark","reward":32},
        {"id":"photo_solar","label":"Solar Beacon","pos":Vector2(20600,2020),"dir":Vector2(0.18,-0.84),"taken":false,"district":"Solar Heights","reward":36},
        {"id":"photo_rotunda","label":"Canal Rotunda","pos":Vector2(2700,6900),"dir":Vector2(0.70,0.24),"taken":false,"district":"Kanäle","reward":30},
        {"id":"photo_prism","label":"Civic Prism","pos":Vector2(7900,6970),"dir":Vector2(-0.68,0.20),"taken":false,"district":"Zentrum","reward":36},
        {"id":"photo_crane","label":"Harbor Crane","pos":Vector2(13100,6620),"dir":Vector2(0.76,0.06),"taken":false,"district":"Hafen","reward":34},
        {"id":"photo_neon","label":"Neon Theatre","pos":Vector2(19800,6550),"dir":Vector2(-0.72,-0.10),"taken":false,"district":"Neon Mile","reward":40},
        {"id":"photo_garden","label":"Conservatory Depth","pos":Vector2(3300,14050),"dir":Vector2(0.55,-0.55),"taken":false,"district":"Gärten","reward":34},
        {"id":"photo_library","label":"Axis Library","pos":Vector2(9300,13800),"dir":Vector2(-0.58,-0.48),"taken":false,"district":"Universität","reward":34},
        {"id":"photo_astra","label":"Astra Dome","pos":Vector2(15600,14250),"dir":Vector2(0.64,-0.30),"taken":false,"district":"Observatorium","reward":42},
        {"id":"photo_foundry","label":"Foundry Geometry","pos":Vector2(17300,5200),"dir":Vector2(-0.70,0.24),"taken":false,"district":"Industrie","reward":34},
        {"id":"photo_transit","label":"Transit Crown Lines","pos":Vector2(22800,5200),"dir":Vector2(0.52,-0.60),"taken":false,"district":"Transit Yard","reward":36},
        {"id":"photo_moor","label":"Moorhafen Reflection","pos":Vector2(2300,12200),"dir":Vector2(0.78,0.18),"taken":false,"district":"Moorhafen","reward":34},
        {"id":"photo_expo","label":"Expo Axis","pos":Vector2(7700,12300),"dir":Vector2(-0.54,-0.50),"taken":false,"district":"Messe","reward":36},
        {"id":"photo_bio","label":"Bio Garden Layers","pos":Vector2(11800,12500),"dir":Vector2(0.62,-0.42),"taken":false,"district":"Bioquartier","reward":38},
        {"id":"photo_aurora","label":"Aurora Ridge Light","pos":Vector2(18200,12500),"dir":Vector2(-0.66,-0.32),"taken":false,"district":"Aurora Hills","reward":42},
        {"id":"photo_terminal","label":"Terminal East Crown","pos":Vector2(22800,13200),"dir":Vector2(-0.55,-0.56),"taken":false,"district":"Terminal East","reward":40},
        {"id":"photo_aero","label":"Aerodrome Runway","pos":Vector2(2600,15700),"dir":Vector2(0.82,-0.08),"taken":false,"district":"Aerodrome","reward":40},
        {"id":"photo_wind","label":"Windfield Blades","pos":Vector2(7600,15700),"dir":Vector2(-0.72,-0.20),"taken":false,"district":"Windfeld","reward":40},
        {"id":"photo_data","label":"Data Pylon Forest","pos":Vector2(12900,15600),"dir":Vector2(0.58,-0.54),"taken":false,"district":"Data Fields","reward":42},
        {"id":"photo_coast","label":"Coastal Boardwalk","pos":Vector2(18100,15700),"dir":Vector2(-0.80,0.06),"taken":false,"district":"Küstenband","reward":40},
        {"id":"photo_rail","label":"Railworks Gantry","pos":Vector2(23200,15700),"dir":Vector2(0.68,-0.30),"taken":false,"district":"Railworks","reward":42},
        {"id":"photo_ring","label":"Outer Ring Overpass","pos":Vector2(18100,8900),"dir":Vector2(0.62,0.44),"taken":false,"district":"Außenring","reward":38}
    ]
    glyphs = [
        {"pos":Vector2(2450,1450),"taken":false,"district":"Altstadt"},
        {"pos":Vector2(7350,1750),"taken":false,"district":"Kulturviertel"},
        {"pos":Vector2(12600,1750),"taken":false,"district":"Glasdistrikt"},
        {"pos":Vector2(18100,1650),"taken":false,"district":"Nordpark"},
        {"pos":Vector2(23200,1700),"taken":false,"district":"Solar Heights"},
        {"pos":Vector2(2700,8800),"taken":false,"district":"Gärten"},
        {"pos":Vector2(7900,8800),"taken":false,"district":"Universität"},
        {"pos":Vector2(13000,8800),"taken":false,"district":"Observatorium"},
        {"pos":Vector2(23500,9000),"taken":false,"district":"Neon Mile"},
        {"pos":Vector2(7800,12600),"taken":false,"district":"Messe"},
        {"pos":Vector2(13200,12600),"taken":false,"district":"Bioquartier"},
        {"pos":Vector2(23400,16200),"taken":false,"district":"Railworks"}
    ]

func _random_vehicle_class(allow_hyper: bool = true) -> String:
    var roll := rng.randf()*100.0
    if roll<16.0: return "micro"
    if roll<33.0: return "hatch"
    if roll<54.0: return "sedan"
    if roll<63.0: return "executive"
    if roll<75.0: return "suv"
    if roll<82.0: return "pickup"
    if roll<90.0: return "van"
    if roll<96.0: return "delivery"
    if roll<99.3: return "sport"
    return "hyper" if allow_hyper else "sport"

func _generate_city() -> void:
    buildings.clear()
    trees.clear()
    parked_cars.clear()
    for district in districts:
        var r: Rect2 = district.rect
        var count := int(r.size.x * r.size.y / 150000.0)
        for _i in range(count):
            var size := Vector2(rng.randf_range(150, 360), rng.randf_range(130, 320))
            if district.style in ["glass", "center", "neon"]:
                size *= rng.randf_range(1.0, 1.35)
            var pos := Vector2(rng.randf_range(r.position.x + 80, r.end.x - size.x - 80), rng.randf_range(r.position.y + 80, r.end.y - size.y - 80))
            var rect := Rect2(pos, size)
            if _rect_near_road(rect, 75.0) or _rect_in_park(rect) or _rect_hits_landmark(rect):
                continue
            var blocked := false
            for b in buildings:
                if (b.rect as Rect2).grow(35).intersects(rect):
                    blocked = true
                    break
            if blocked:
                continue
            var h := rng.randf_range(45, 125)
            if district.style in ["glass", "center", "neon"]:
                h += rng.randf_range(45, 165)
            var massing: String = ["slab","tower","terrace","courtyard"][rng.randi_range(0,3)]
            var facade_mode: String = ["windows","striped","balconies","mixed"][rng.randi_range(0,3)]
            var roof_mode: String = ["flat","utility","garden","pitched","solar"][rng.randi_range(0,4)]
            buildings.append({"rect":rect, "height":h, "wall":district.wall, "roof":district.roof, "accent":district.accent, "style":district.style, "seed":rng.randi(), "floors":maxi(2, int(h / 28.0)), "massing":massing, "facade":facade_mode, "roof_mode":roof_mode})
        var tree_count := 80 if district.style in ["green", "garden"] else 26
        for _j in range(tree_count):
            var tp := Vector2(rng.randf_range(r.position.x, r.end.x), rng.randf_range(r.position.y, r.end.y))
            if not _point_in_building(tp):
                var species := "cypress" if district.style in ["heritage","canal"] else ("birch" if district.style in ["campus","terminal"] else ("palm" if district.style=="neon" else ("pine" if district.style=="astro" else "broadleaf")))
                trees.append({"pos":tp, "h":rng.randf_range(32,75), "r":rng.randf_range(11,24), "tint":district.accent.lerp(Color("#56a36b"),0.65), "species":species, "phase":rng.randf_range(0,TAU)})
    for park in parks:
        var pr: Rect2 = park.rect
        for _k in range(38):
            trees.append({"pos":Vector2(rng.randf_range(pr.position.x+40,pr.end.x-40),rng.randf_range(pr.position.y+40,pr.end.y-40)),"h":rng.randf_range(35,82),"r":rng.randf_range(13,26),"tint":Color("#63b878"),"species":["broadleaf","birch","pine"][rng.randi_range(0,2)],"phase":rng.randf_range(0,TAU)})
    for _n in range(92):
        var rd = roads[rng.randi_range(0, roads.size()-1)]
        var t_sample := rng.randf()
        var p := _sample_polyline(rd.points, t_sample)
        var tangent := _polyline_tangent(rd.points, t_sample)
        var normal := Vector2(-tangent.y, tangent.x)
        var cls: String = _random_vehicle_class(true)
        parked_cars.append({"pos":p + normal * rng.randf_range(45,70), "class":cls, "heading":tangent.angle(), "color":_car_color(cls), "occupied":false})

func _generate_traffic() -> void:
    traffic.clear()
    for i in range(155):
        var road_index := rng.randi_range(0, roads.size()-1)
        var cls: String = _random_vehicle_class(true)
        var reverse := rng.randf()<0.5
        traffic.append({
            "road":road_index,
            "t":rng.randf(),
            "speed":rng.randf_range(0.020,0.044),
            "cruise":rng.randf_range(0.024,0.050),
            "class":cls,
            "color":_car_color(cls),
            "reverse":reverse,
            "lane":rng.randi_range(0,1),
            "wait":0.0,
            "turn_cooldown":rng.randf_range(0.0,2.0),
            "parking":false,
            "park_timer":0.0,
            "lateral":0.0,
            "lane_change":0.0,
            "lane_from":0,
            "lane_to":0,
            "indicator":0,
            "turn_anim":0.0,
            "turn_from":Vector2.ZERO,
            "turn_to":Vector2.ZERO
        })
    _generate_smart_agents()

func _generate_smart_agents() -> void:
    smart_agents.clear()
    for i in range(28):
        var road_index := rng.randi_range(0,17)
        var smart_cls: String = _random_vehicle_class(false)
        smart_agents.append({
            "state":"walking" if i%3==0 else "driving",
            "road":road_index,
            "t":rng.randf_range(0.05,0.95),
            "reverse":rng.randf()<0.5,
            "lane":rng.randi_range(0,1),
            "timer":rng.randf_range(8.0,26.0),
            "speed":rng.randf_range(0.018,0.032),
            "class":smart_cls,
            "color":_car_color(smart_cls),
            "skin":[Color("#f1c7a8"),Color("#d79b75"),Color("#b87655"),Color("#7b4f3d")][rng.randi_range(0,3)],
            "clothes":[Color("#8dcfff"),Color("#ff9fc1"),Color("#90dfb8"),Color("#ffd477")][rng.randi_range(0,3)],
            "phase":rng.randf_range(0,TAU),
            "parking_progress":0.0,
            "car_parked":false,
            "parked_t":0.0,
            "activity":"home",
            "destination":Vector2.ZERO,
            "dwell":0.0
        })

func _generate_visual_props() -> void:
    street_lights.clear()
    street_props.clear()
    pedestrians.clear()
    for ri in range(roads.size()):
        var road = roads[ri]
        for k in range(4, 97, 7):
            var t := float(k) / 100.0
            var pos := _sample_polyline(road.points, t)
            var tangent := _polyline_tangent(road.points, t)
            var normal := Vector2(-tangent.y, tangent.x)
            var offset: float = float(road.width) * 0.5 + 23.0
            street_lights.append({"pos":pos + normal * offset, "h":44.0, "tint":Color("#ffd99a")})
            if k % 14 == 4:
                street_lights.append({"pos":pos - normal * offset, "h":44.0, "tint":Color("#b9e9ff")})
    for park in parks:
        var r: Rect2 = park.rect
        for i in range(8):
            street_props.append({"type":"bench", "pos":r.position + Vector2(120 + (i%4)*210, 150 + (i/4)*220), "rot":0.0, "tint":Color("#b9875f")})
        street_props.append({"type":"attraction", "pos":r.get_center(), "kind":park.attraction, "name":park.name})
    for d in districts:
        var r: Rect2 = d.rect
        if d.style in ["neon","center","glass","terminal"]:
            for i in range(8):
                street_props.append({"type":"billboard", "pos":Vector2(rng.randf_range(r.position.x+180,r.end.x-180),rng.randf_range(r.position.y+180,r.end.y-180)), "rot":rng.randf_range(-0.35,0.35), "tint":d.accent})
        if d.style in ["heritage","canal","harbor"]:
            for i in range(10):
                street_props.append({"type":"crate", "pos":Vector2(rng.randf_range(r.position.x+120,r.end.x-120),rng.randf_range(r.position.y+120,r.end.y-120)), "rot":0.0, "tint":d.accent.darkened(0.45)})
    # District-specific micro-landmarks and street assets.
    for d in districts:
        var rr: Rect2 = d.rect
        var center: Vector2 = rr.get_center()
        var style: String = str(d.style)
        if style=="wind":
            for k in range(5):
                street_props.append({"type":"wind_turbine","pos":rr.position+Vector2(650+k*820,650+(k%2)*900),"rot":0.0,"tint":d.accent})
        elif style=="air":
            for k in range(8):
                street_props.append({"type":"runway_light","pos":rr.position+Vector2(520+k*540,1800+(k%2)*80),"rot":0.0,"tint":d.accent})
        elif style=="data":
            for k in range(6):
                street_props.append({"type":"data_pylon","pos":rr.position+Vector2(600+k*720,700+(k%3)*780),"rot":0.0,"tint":d.accent})
        elif style in ["coast","canal"]:
            for k in range(7):
                street_props.append({"type":"boardwalk","pos":rr.position+Vector2(420+k*620,rr.size.y-420-(k%2)*80),"rot":0.0,"tint":d.accent})
        elif style=="heritage":
            for k in range(6):
                street_props.append({"type":"market_stall","pos":rr.position+Vector2(620+k*650,680+(k%2)*540),"rot":0.0,"tint":d.accent})
        elif style=="campus":
            for k in range(7):
                street_props.append({"type":"bike_rack","pos":rr.position+Vector2(480+k*620,600+(k%3)*500),"rot":0.0,"tint":d.accent})
        elif style in ["harbor","industry","rail"]:
            for k in range(6):
                street_props.append({"type":"gantry","pos":rr.position+Vector2(550+k*700,720+(k%2)*820),"rot":0.0,"tint":d.accent})
        elif style=="neon":
            for k in range(8):
                street_props.append({"type":"neon_totem","pos":rr.position+Vector2(430+k*560,500+(k%3)*620),"rot":0.0,"tint":d.accent})
        elif style in ["green","garden"]:
            for k in range(8):
                street_props.append({"type":"garden_arch","pos":rr.position+Vector2(500+k*550,620+(k%2)*700),"rot":0.0,"tint":d.accent})
    # Major intersections: traffic lights, crossings and signs.
    var ix_list := [2700.0,5000.0,7500.0,10100.0,12800.0,15400.0,18100.0,21000.0]
    var iy_list := [2600.0,4450.0,6500.0,9000.0,11600.0,14300.0]
    for ix in ix_list:
        for iy in iy_list:
            if int(ix + iy) % 3 == 0:
                continue
            street_props.append({"type":"traffic_light","pos":Vector2(ix+115,iy+105),"phase":int(ix/100+iy/100)%3,"rot":0.0,"tint":Color("#9fd5e5")})
            street_props.append({"type":"traffic_light","pos":Vector2(ix-115,iy-105),"phase":int(ix/100+iy/100+1)%3,"rot":PI,"tint":Color("#9fd5e5")})
            street_props.append({"type":"crossing","pos":Vector2(ix,iy),"rot":0.0,"tint":Color.WHITE})
    # Stops and wayfinding.
    for i in range(10):
        var rd = roads[(i*2+1) % roads.size()]
        var tt := 0.10 + float(i) * 0.075
        var sp := _sample_polyline(rd.points, fposmod(tt,0.92))
        var st := _polyline_tangent(rd.points, fposmod(tt,0.92))
        var sn := Vector2(-st.y,st.x)
        street_props.append({"type":"bus_stop","pos":sp+sn*(float(rd.width)*0.5+32.0),"line":"B%d" % (12+(i%4)*4),"rot":st.angle(),"tint":Color("#64d7c1")})
    for i in range(7):
        var rd2 = roads[(i*3+2) % roads.size()]
        var tt2 := 0.15 + float(i) * 0.10
        var sp2 := _sample_polyline(rd2.points, fposmod(tt2,0.9))
        var st2 := _polyline_tangent(rd2.points, fposmod(tt2,0.9))
        var sn2 := Vector2(-st2.y,st2.x)
        street_props.append({"type":"tram_stop","pos":sp2-sn2*(float(rd2.width)*0.5+36.0),"line":"T%d" % (2+(i%3)),"rot":st2.angle(),"tint":Color("#e66a84")})
    # Small street life props.
    for i in range(36):
        var rd3 = roads[rng.randi_range(0,roads.size()-1)]
        var tt3 := rng.randf_range(0.05,0.95)
        var pp := _sample_polyline(rd3.points,tt3)
        var tg := _polyline_tangent(rd3.points,tt3)
        var nn := Vector2(-tg.y,tg.x)
        street_props.append({"type":"bollard","pos":pp+nn*(float(rd3.width)*0.5+18.0),"rot":0.0,"tint":Color("#8c989f")})
    for i in range(18):
        var rd4 = roads[rng.randi_range(0,roads.size()-1)]
        var tt4 := rng.randf_range(0.05,0.95)
        var pp2 := _sample_polyline(rd4.points,tt4)
        var tg2 := _polyline_tangent(rd4.points,tt4)
        var nn2 := Vector2(-tg2.y,tg2.x)
        street_props.append({"type":"sign","pos":pp2-nn2*(float(rd4.width)*0.5+30.0),"rot":tg2.angle(),"tint":Color("#a8d8ec")})
    # Marked roadside parking bays on selected urban roads.
    for ri in range(mini(18,roads.size())):
        if ri%3==2:
            continue
        var rd5 = roads[ri]
        for pk in [0.18,0.36,0.64,0.82]:
            var ppk := _sample_polyline(rd5.points,float(pk))
            var ttk := _polyline_tangent(rd5.points,float(pk))
            var nnk := Vector2(-ttk.y,ttk.x)
            var side_sign := 1.0 if int(float(pk)*100.0+float(ri))%2==0 else -1.0
            street_props.append({"type":"parking_bay","pos":ppk+nnk*side_sign*(float(rd5.width)*0.5+34.0),"rot":ttk.angle(),"tint":Color("#b9c6cc")})
    for i in range(220):
        var road_index := rng.randi_range(0, roads.size()-1)
        pedestrians.append({
            "road":road_index,
            "t":rng.randf(),
            "speed":rng.randf_range(0.006,0.017),
            "reverse":rng.randf()<0.5,
            "side":-1.0 if rng.randf()<0.5 else 1.0,
            "color":[Color("#eef4f7"),Color("#ffbf9a"),Color("#a8c7ff"),Color("#ff9fc1"),Color("#90dfb8")][rng.randi_range(0,4)],
            "skin":[Color("#f1c7a8"),Color("#d79b75"),Color("#b87655"),Color("#7b4f3d")][rng.randi_range(0,3)],
            "hair":[Color("#30251f"),Color("#6a4b30"),Color("#d8b77d"),Color("#22252c"),Color("#8d4a38")][rng.randi_range(0,4)],
            "role":["commuter","student","worker","shopper","runner"][rng.randi_range(0,4)],
            "bag":rng.randf() < 0.36,
            "phase":rng.randf_range(0,TAU),
            "pause":0.0,
            "target_t":rng.randf(),
            "routine":["work","shop","park","home","transit"][rng.randi_range(0,4)]
        })


func _generate_storefronts() -> void:
    storefronts.clear()
    vegetation_props.clear()
    var shop_kinds := ["restaurant","cafe","shop","garage","workshop"]
    for d in districts:
        var r: Rect2 = d.rect
        var count := 5 if d.style in ["center","neon","heritage"] else 3
        for i in range(count):
            var road = roads[(i + int(r.position.x/1000.0) + int(r.position.y/1000.0)) % roads.size()]
            var tt := clampf(0.12 + float(i)*0.16,0.08,0.88)
            var pos := _sample_polyline(road.points,tt)
            if not r.grow(-180).has_point(pos):
                pos = r.position + Vector2(220 + i*260, 230 + (i%2)*180)
            var tang := _polyline_tangent(road.points,tt)
            var norm := Vector2(-tang.y,tang.x)
            pos += norm*(float(road.width)*0.5+42.0)
            storefronts.append({
                "pos":pos,
                "heading":tang.angle(),
                "kind":shop_kinds[(i+int(r.position.x/500.0))%shop_kinds.size()],
                "name":_shop_name(d.name,shop_kinds[(i+int(r.position.x/500.0))%shop_kinds.size()],i),
                "accent":d.accent,
                "district":d.name
            })
    for d in districts:
        var r2: Rect2 = d.rect
        var plant_count := 18 if d.style in ["green","garden","campus"] else 7
        for j in range(plant_count):
            vegetation_props.append({
                "pos":Vector2(rng.randf_range(r2.position.x+120,r2.end.x-120),rng.randf_range(r2.position.y+120,r2.end.y-120)),
                "kind":["flowerbed","shrub","planter"][rng.randi_range(0,2)],
                "tint":d.accent.lerp(Color("#4ca966"),0.68),
                "phase":rng.randf_range(0,TAU)
            })

func _shop_name(district_name: String, kind: String, index: int) -> String:
    var prefixes := {
        "restaurant":["Lumen","Copper","Astra","Canal","Garden"],
        "cafe":["Orbit","Moss","Prism","Dock","North"],
        "shop":["Facet","Loop","Signal","Corner","Axis"],
        "garage":["Torque","Mako","Vector","Pulse","Lane"],
        "workshop":["Forge","Depth","Relay","Glass","Echo"]
    }
    var arr: Array = prefixes[kind]
    var suffix: String = str({"restaurant":"Kitchen","cafe":"Café","shop":"Store","garage":"Garage","workshop":"Works"}[kind])
    return "%s %s" % [arr[(index+district_name.length())%arr.size()],suffix]

func _generate_transit() -> void:
    transit_vehicles.clear()
    var bus_routes := [0, 5, 8, 12]
    for i in range(bus_routes.size()):
        transit_vehicles.append({
            "kind":"bus",
            "road":bus_routes[i] % roads.size(),
            "t":float(i) * 0.23,
            "speed":0.010 + float(i) * 0.0015,
            "reverse":i % 2 == 1,
            "color":[Color("#64d7c1"),Color("#f0b45f"),Color("#7ab8ff"),Color("#c79bff")][i % 4],
            "line":"B%d" % (12 + i * 4),
            "dwell":0.0,
            "at_stop":false,
            "stop_index":-1
        })
    var tram_routes := [1, 7, 10]
    for i in range(tram_routes.size()):
        transit_vehicles.append({
            "kind":"tram",
            "road":tram_routes[i] % roads.size(),
            "t":0.15 + float(i) * 0.29,
            "speed":0.008 + float(i) * 0.0012,
            "reverse":i % 2 == 0,
            "color":[Color("#e66a84"),Color("#67cde8"),Color("#f0d36d")][i % 3],
            "line":"T%d" % (2 + i),
            "dwell":0.0,
            "at_stop":false,
            "stop_index":-1
        })

func _build_transit_stops() -> void:
    transit_stops.clear()
    for vi in range(transit_vehicles.size()):
        var tv: Dictionary = transit_vehicles[vi]
        var rd = roads[int(tv.road)]
        for si in range(4):
            var tt: float = 0.12 + float(si)*0.24
            var pos := _sample_polyline(rd.points,tt)
            transit_stops.append({"vehicle":vi,"t":tt,"pos":pos,"line":str(tv.line),"name":"%s · Halt %d" % [str(tv.line),si+1]})

func _generate_collectibles() -> void:
    fragments.clear()
    secrets.clear()
    for i in range(34):
        var p := _random_open_point()
        fragments.append({"pos":p, "taken":false, "phase":rng.randf_range(0,TAU)})
    for j in range(16):
        var p2 := _random_open_point()
        var dirs := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
        secrets.append({"pos":p2, "found":false, "revealed":false, "dir":dirs[rng.randi_range(0,3)], "label":"Perspective Cache %02d" % (j+1)})

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.layer=20
    add_child(layer)

    var mission_panel := PanelContainer.new()
    mission_panel.position = Vector2(20, 38)
    mission_panel.custom_minimum_size = Vector2(430, 150)
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0.025,0.075,0.105,0.91)
    sb.border_color = Color(0.35,0.85,0.75,0.22)
    sb.set_border_width_all(2)
    sb.corner_radius_top_left = 22
    sb.corner_radius_top_right = 22
    sb.corner_radius_bottom_left = 22
    sb.corner_radius_bottom_right = 22
    mission_panel.add_theme_stylebox_override("panel", sb)
    var vb := VBoxContainer.new()
    vb.add_theme_constant_override("separation", 5)
    mission_panel.add_child(vb)
    var title := Label.new()
    title.text = "PARALLAX HUNT · NATIVE FEATURE ALPHA 1.7"
    title.add_theme_font_size_override("font_size", 24)
    title.modulate = Color("#7ff0d2")
    vb.add_child(title)
    mission_label = Label.new()
    mission_label.text = "Echoes in the Megacity"
    mission_label.add_theme_font_size_override("font_size", 30)
    vb.add_child(mission_label)
    detail_label = Label.new()
    detail_label.text = "Collect fragments and reveal perspective caches."
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.add_theme_font_size_override("font_size", 20)
    detail_label.modulate = Color("#c7d6de")
    vb.add_child(detail_label)
    layer.add_child(mission_panel)

    status_label = Label.new()
    status_label.position = Vector2(20, 205)
    status_label.add_theme_font_size_override("font_size", 21)
    status_label.modulate = Color("#d9e9ef")
    layer.add_child(status_label)

    district_banner = Label.new()
    district_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    district_banner.position = Vector2(260, 250)
    district_banner.size = Vector2(560, 75)
    district_banner.add_theme_font_size_override("font_size", 36)
    district_banner.modulate = Color(1,1,1,0)
    layer.add_child(district_banner)

    reward_panel = PanelContainer.new()
    reward_panel.position = Vector2(165,350)
    reward_panel.size = Vector2(750,220)
    reward_panel.visible = false
    reward_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var rsb := StyleBoxFlat.new()
    rsb.bg_color = Color(0.025,0.06,0.075,0.96)
    rsb.border_color = Color(0.45,0.95,0.82,0.72)
    rsb.set_border_width_all(3)
    rsb.corner_radius_top_left = 24
    rsb.corner_radius_top_right = 24
    rsb.corner_radius_bottom_left = 24
    rsb.corner_radius_bottom_right = 24
    reward_panel.add_theme_stylebox_override("panel",rsb)
    var rvb := VBoxContainer.new()
    rvb.add_theme_constant_override("separation",8)
    reward_panel.add_child(rvb)
    reward_title = Label.new()
    reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reward_title.add_theme_font_size_override("font_size",27)
    reward_title.modulate = Color("#73f3ce")
    rvb.add_child(reward_title)
    reward_body = Label.new()
    reward_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    reward_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    reward_body.add_theme_font_size_override("font_size",17)
    reward_body.modulate = Color("#e4eef1")
    rvb.add_child(reward_body)
    layer.add_child(reward_panel)

    var pause_button := Button.new()
    pause_button.text = "☰"
    pause_button.position = Vector2(690,42)
    pause_button.size = Vector2(70,72)
    pause_button.add_theme_font_size_override("font_size",28)
    pause_button.pressed.connect(_return_to_main_menu)
    layer.add_child(pause_button)

    var map_button := Button.new()
    map_button.text = "MAP"
    map_button.position = Vector2(770,42)
    map_button.size = Vector2(125,72)
    map_button.add_theme_font_size_override("font_size",22)
    map_button.pressed.connect(_toggle_map)
    layer.add_child(map_button)

    var mission_button := Button.new()
    mission_button.text = "MISSIONS"
    mission_button.position = Vector2(905,42)
    mission_button.size = Vector2(150,72)
    mission_button.add_theme_font_size_override("font_size",19)
    mission_button.pressed.connect(_toggle_missions)
    layer.add_child(mission_button)

    var collection_button := Button.new()
    collection_button.text = "COLLECTION"
    collection_button.position = Vector2(610,2060)
    collection_button.size = Vector2(200,110)
    collection_button.add_theme_font_size_override("font_size",18)
    collection_button.pressed.connect(_toggle_collection)
    layer.add_child(collection_button)

    photo_target_label = Label.new()
    photo_target_label.position=Vector2(55,90)
    photo_target_label.size=Vector2(970,115)
    photo_target_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    photo_target_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    photo_target_label.add_theme_font_size_override("font_size",25)
    photo_target_label.modulate=Color("#f7fbff")
    photo_target_label.visible=false
    layer.add_child(photo_target_label)

    photo_status_label = Label.new()
    photo_status_label.position=Vector2(60,205)
    photo_status_label.size=Vector2(960,80)
    photo_status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    photo_status_label.add_theme_font_size_override("font_size",17)
    photo_status_label.modulate=Color("#ffcf8a")
    photo_status_label.visible=false
    layer.add_child(photo_status_label)

    photo_shutter_button = Button.new()
    photo_shutter_button.text="📷 FOTO"
    photo_shutter_button.position=Vector2(400,1910)
    photo_shutter_button.size=Vector2(280,120)
    photo_shutter_button.add_theme_font_size_override("font_size",27)
    photo_shutter_button.visible=false
    photo_shutter_button.pressed.connect(_photo_shutter)
    layer.add_child(photo_shutter_button)

    photo_exit_button = Button.new()
    photo_exit_button.text="VERLASSEN"
    photo_exit_button.position=Vector2(70,1940)
    photo_exit_button.size=Vector2(220,90)
    photo_exit_button.visible=false
    photo_exit_button.pressed.connect(_exit_photo_mode)
    layer.add_child(photo_exit_button)

    photo_hint_button = Button.new()
    photo_hint_button.text="HINWEIS"
    photo_hint_button.position=Vector2(790,1940)
    photo_hint_button.size=Vector2(220,90)
    photo_hint_button.visible=false
    photo_hint_button.pressed.connect(_photo_hint)
    layer.add_child(photo_hint_button)

    photo_zoom_in_button = Button.new()
    photo_zoom_in_button.text="＋"
    photo_zoom_in_button.position=Vector2(890,1680)
    photo_zoom_in_button.size=Vector2(110,100)
    photo_zoom_in_button.add_theme_font_size_override("font_size",30)
    photo_zoom_in_button.visible=false
    photo_zoom_in_button.pressed.connect(_photo_zoom.bind(-7.0))
    layer.add_child(photo_zoom_in_button)

    photo_zoom_out_button = Button.new()
    photo_zoom_out_button.text="−"
    photo_zoom_out_button.position=Vector2(890,1790)
    photo_zoom_out_button.size=Vector2(110,100)
    photo_zoom_out_button.add_theme_font_size_override("font_size",30)
    photo_zoom_out_button.visible=false
    photo_zoom_out_button.pressed.connect(_photo_zoom.bind(7.0))
    layer.add_child(photo_zoom_out_button)

    game_panel = PanelContainer.new()
    game_panel.position = Vector2(105,420)
    game_panel.size = Vector2(870,1180)
    game_panel.visible = false
    var gsb := StyleBoxFlat.new()
    gsb.bg_color = Color(0.025,0.055,0.075,0.985)
    gsb.border_color = Color(0.45,0.95,0.82,0.45)
    gsb.set_border_width_all(2)
    gsb.corner_radius_top_left = 24
    gsb.corner_radius_top_right = 24
    gsb.corner_radius_bottom_left = 24
    gsb.corner_radius_bottom_right = 24
    game_panel.add_theme_stylebox_override("panel",gsb)
    var gvb := VBoxContainer.new()
    gvb.add_theme_constant_override("separation",14)
    game_panel.add_child(gvb)
    game_title = Label.new()
    game_title.add_theme_font_size_override("font_size",28)
    game_title.modulate = Color("#73f3ce")
    gvb.add_child(game_title)
    game_info = Label.new()
    game_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    game_info.add_theme_font_size_override("font_size",18)
    gvb.add_child(game_info)
    game_status = Label.new()
    game_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    game_status.add_theme_font_size_override("font_size",17)
    game_status.modulate = Color("#c7d6de")
    gvb.add_child(game_status)
    var center_box := CenterContainer.new()
    center_box.custom_minimum_size = Vector2(0,690)
    game_grid = GridContainer.new()
    game_grid.columns = 4
    game_grid.add_theme_constant_override("h_separation",10)
    game_grid.add_theme_constant_override("v_separation",10)
    center_box.add_child(game_grid)
    gvb.add_child(center_box)
    game_controls = HBoxContainer.new()
    game_controls.alignment = BoxContainer.ALIGNMENT_CENTER
    game_controls.add_theme_constant_override("separation",8)
    gvb.add_child(game_controls)
    var close_game := Button.new()
    close_game.text = "SCHLIESSEN"
    close_game.custom_minimum_size = Vector2(0,70)
    close_game.pressed.connect(_close_minigame)
    gvb.add_child(close_game)
    layer.add_child(game_panel)

    commerce_panel = PanelContainer.new()
    commerce_panel.position = Vector2(145,520)
    commerce_panel.size = Vector2(790,980)
    commerce_panel.visible = false
    var csb := StyleBoxFlat.new()
    csb.bg_color = Color(0.025,0.055,0.075,0.985)
    csb.border_color = Color(1.0,0.82,0.47,0.38)
    csb.set_border_width_all(2)
    csb.corner_radius_top_left = 24
    csb.corner_radius_top_right = 24
    csb.corner_radius_bottom_left = 24
    csb.corner_radius_bottom_right = 24
    commerce_panel.add_theme_stylebox_override("panel",csb)
    var cvb := VBoxContainer.new()
    cvb.add_theme_constant_override("separation",14)
    commerce_panel.add_child(cvb)
    commerce_title = Label.new()
    commerce_title.add_theme_font_size_override("font_size",28)
    commerce_title.modulate = Color("#ffd27a")
    cvb.add_child(commerce_title)
    commerce_info = Label.new()
    commerce_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    commerce_info.add_theme_font_size_override("font_size",18)
    cvb.add_child(commerce_info)
    commerce_actions = VBoxContainer.new()
    commerce_actions.add_theme_constant_override("separation",10)
    cvb.add_child(commerce_actions)
    var close_commerce := Button.new()
    close_commerce.text = "SCHLIESSEN"
    close_commerce.custom_minimum_size = Vector2(0,70)
    close_commerce.pressed.connect(_close_commerce)
    cvb.add_child(close_commerce)
    layer.add_child(commerce_panel)

    scan_button = Button.new()
    scan_button.text = "SCAN"
    scan_button.position = Vector2(820, 2060)
    scan_button.size = Vector2(210, 110)
    scan_button.add_theme_font_size_override("font_size", 28)
    scan_button.pressed.connect(_scan)
    layer.add_child(scan_button)
    interact_button = Button.new()
    interact_button.text = "INTERACT"
    interact_button.position = Vector2(790, 1925)
    interact_button.size = Vector2(240, 115)
    interact_button.add_theme_font_size_override("font_size", 25)
    interact_button.pressed.connect(_interact)
    layer.add_child(interact_button)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(120,1340)
    dialogue_panel.size = Vector2(840,650)
    dialogue_panel.visible = false
    var dsb := StyleBoxFlat.new()
    dsb.bg_color = Color(0.025,0.055,0.075,0.97)
    dsb.border_color = Color(0.60,0.92,0.86,0.38)
    dsb.set_border_width_all(2)
    dsb.corner_radius_top_left = 24
    dsb.corner_radius_top_right = 24
    dsb.corner_radius_bottom_left = 24
    dsb.corner_radius_bottom_right = 24
    dialogue_panel.add_theme_stylebox_override("panel",dsb)
    var dvb := VBoxContainer.new()
    dvb.add_theme_constant_override("separation",10)
    dialogue_panel.add_child(dvb)
    dialogue_title = Label.new()
    dialogue_title.add_theme_font_size_override("font_size",26)
    dialogue_title.modulate = Color("#73f3ce")
    dvb.add_child(dialogue_title)
    dialogue_body = Label.new()
    dialogue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_body.add_theme_font_size_override("font_size",18)
    dialogue_body.custom_minimum_size = Vector2(0,210)
    dvb.add_child(dialogue_body)
    dialogue_actions = VBoxContainer.new()
    dialogue_actions.add_theme_constant_override("separation",8)
    dvb.add_child(dialogue_actions)
    layer.add_child(dialogue_panel)

    # Full-screen native main menu. Added last so it owns input while visible.
    main_menu_panel = PanelContainer.new()
    main_menu_panel.position = Vector2(0,0)
    main_menu_panel.size = Vector2(1080,2340)
    var msb := StyleBoxFlat.new()
    msb.bg_color = Color(0.018,0.045,0.064,0.66)
    msb.border_color = Color(0.45,0.95,0.82,0.32)
    msb.set_border_width_all(2)
    msb.corner_radius_top_left = 34
    msb.corner_radius_top_right = 34
    msb.corner_radius_bottom_left = 34
    msb.corner_radius_bottom_right = 0
    msb.corner_radius_top_left = 0
    msb.corner_radius_top_right = 0
    msb.corner_radius_bottom_left = 0
    msb.content_margin_left = 95.0
    msb.content_margin_right = 95.0
    msb.content_margin_top = 270.0
    msb.content_margin_bottom = 150.0
    main_menu_panel.add_theme_stylebox_override("panel",msb)
    var mvb := VBoxContainer.new()
    mvb.add_theme_constant_override("separation",14)
    main_menu_panel.add_child(mvb)
    var logo := Label.new()
    logo.text = "PARALLAX HUNT"
    logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    logo.add_theme_font_size_override("font_size",56)
    logo.modulate = Color("#eafafa")
    mvb.add_child(logo)
    var subtitle := Label.new()
    subtitle.text = "NATIVE FEATURE ALPHA · PMDD MEGACITY"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size",19)
    subtitle.modulate = Color("#73f3ce")
    mvb.add_child(subtitle)
    menu_status = Label.new()
    menu_status.text = "Wähle einen Spielstand."
    menu_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    menu_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    menu_status.add_theme_font_size_override("font_size",17)
    menu_status.modulate = Color("#c7d6de")
    mvb.add_child(menu_status)

    var continue_button := Button.new()
    continue_button.text = "FORTFAHREN"
    continue_button.custom_minimum_size = Vector2(0,84)
    continue_button.add_theme_font_size_override("font_size",24)
    continue_button.pressed.connect(_continue_latest_save)
    mvb.add_child(continue_button)

    var new_button := Button.new()
    new_button.text = "NEUES SPIEL"
    new_button.custom_minimum_size = Vector2(0,76)
    new_button.add_theme_font_size_override("font_size",21)
    new_button.pressed.connect(_select_new_game_mode)
    mvb.add_child(new_button)

    var slot_title := Label.new()
    slot_title.text = "SPIELSTÄNDE"
    slot_title.add_theme_font_size_override("font_size",18)
    slot_title.modulate = Color("#9ad5ff")
    mvb.add_child(slot_title)
    menu_slot_buttons.clear()
    for slot in range(1,4):
        var slot_btn := Button.new()
        slot_btn.custom_minimum_size = Vector2(0,92)
        slot_btn.add_theme_font_size_override("font_size",18)
        slot_btn.pressed.connect(_select_save_slot.bind(slot))
        mvb.add_child(slot_btn)
        menu_slot_buttons.append(slot_btn)

    var options_button := Button.new()
    options_button.text = "OPTIONEN"
    options_button.custom_minimum_size = Vector2(0,72)
    options_button.add_theme_font_size_override("font_size",19)
    options_button.pressed.connect(_toggle_options_box)
    mvb.add_child(options_button)

    options_box = VBoxContainer.new()
    options_box.visible = false
    options_box.add_theme_constant_override("separation",8)
    mvb.add_child(options_box)
    sound_option_button = Button.new()
    sound_option_button.custom_minimum_size = Vector2(0,62)
    sound_option_button.pressed.connect(_cycle_sound_option)
    options_box.add_child(sound_option_button)
    graphics_option_button = Button.new()
    graphics_option_button.custom_minimum_size = Vector2(0,62)
    graphics_option_button.pressed.connect(_cycle_graphics_option)
    options_box.add_child(graphics_option_button)
    pmdd_option_button = Button.new()
    pmdd_option_button.custom_minimum_size = Vector2(0,62)
    pmdd_option_button.pressed.connect(_cycle_pmdd_option)
    options_box.add_child(pmdd_option_button)
    sensor_option_button = Button.new()
    sensor_option_button.custom_minimum_size = Vector2(0,62)
    sensor_option_button.pressed.connect(_cycle_sensor_option)
    options_box.add_child(sensor_option_button)
    drive_option_button = Button.new()
    drive_option_button.custom_minimum_size = Vector2(0,62)
    drive_option_button.pressed.connect(_cycle_drive_assist)
    options_box.add_child(drive_option_button)
    haptics_option_button = Button.new()
    haptics_option_button.custom_minimum_size = Vector2(0,62)
    haptics_option_button.pressed.connect(_cycle_haptics)
    options_box.add_child(haptics_option_button)

    var hint := Label.new()
    hint.text = "3 getrennte Spielstände · Autosave · Karte · Missionen · Optionen"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size",14)
    hint.modulate = Color("#8fa7b2")
    mvb.add_child(hint)
    layer.add_child(main_menu_panel)

func _haptic(duration_ms: int = 45) -> void:
    if not haptics_enabled:
        return
    if OS.get_name()=="Android":
        Input.vibrate_handheld(duration_ms)

func _build_photo_3d_system() -> void:
    photo_viewport=SubViewport.new()
    photo_viewport.size=Vector2i(1080,2340)
    photo_viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    photo_viewport.transparent_bg=false
    add_child(photo_viewport)

    photo_world_root=Node3D.new()
    photo_viewport.add_child(photo_world_root)

    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode=Environment.BG_COLOR
    env.background_color=Color("#9cc5d8")
    env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color=Color("#d8e7ec")
    env.ambient_light_energy=0.72
    env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
    world_env.environment=env
    photo_world_root.add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees=Vector3(-54,-28,0)
    sun.light_energy=1.15
    sun.shadow_enabled=true
    photo_world_root.add_child(sun)

    photo_camera=Camera3D.new()
    photo_camera.current=true
    photo_camera.near=0.08
    photo_camera.far=420.0
    photo_camera.fov=photo_fov
    photo_world_root.add_child(photo_camera)

    photo_view_rect=TextureRect.new()
    photo_view_rect.position=Vector2.ZERO
    photo_view_rect.size=Vector2(1080,2340)
    photo_view_rect.texture=photo_viewport.get_texture()
    photo_view_rect.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    photo_view_rect.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    photo_view_rect.visible=false
    photo_view_rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var layer := CanvasLayer.new()
    layer.layer=10
    add_child(layer)
    layer.add_child(photo_view_rect)

func _photo_clear_3d_scene() -> void:
    if photo_world_root==null:
        return
    for child in photo_world_root.get_children():
        if child==photo_camera or child is WorldEnvironment or child is DirectionalLight3D:
            continue
        child.queue_free()
    photo_dynamic_cars.clear()
    photo_targets.clear()

func _photo_material(color: Color, metallic: float = 0.0, roughness: float = 0.72) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color=color
    mat.metallic=metallic
    mat.roughness=roughness
    return mat

func _photo_box(name_text: String, pos: Vector3, size: Vector3, color: Color, parent: Node3D = photo_world_root) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name=name_text
    var mesh := BoxMesh.new()
    mesh.size=size
    node.mesh=mesh
    node.position=pos
    node.material_override=_photo_material(color)
    parent.add_child(node)
    return node

func _photo_local(world: Vector2, center: Vector2, y: float = 0.0) -> Vector3:
    return Vector3((world.x-center.x)*0.10,y,(world.y-center.y)*0.10)

func _photo_build_scene(index: int) -> void:
    _photo_clear_3d_scene()
    var ph: Dictionary = photo_points[index]
    var center: Vector2 = Vector2(ph.pos)
    var radius: float = 1250.0

    _photo_box("Ground",Vector3(0,-0.35,0),Vector3(260,0.6,260),Color("#596b62"))

    # Roads become real 3D slabs around the fixed observation point.
    for ri in range(roads.size()):
        var road = roads[ri]
        var pts: PackedVector2Array = road.points
        for k in range(pts.size()-1):
            var a: Vector2 = pts[k]
            var b: Vector2 = pts[k+1]
            var mid: Vector2 = (a+b)*0.5
            if mid.distance_to(center)>radius+650.0:
                continue
            var la := _photo_local(a,center,0.0)
            var lb := _photo_local(b,center,0.0)
            var delta := lb-la
            var length: float = Vector2(delta.x,delta.z).length()
            if length<0.5:
                continue
            var slab := _photo_box("Road_%d_%d" % [ri,k],(la+lb)*0.5+Vector3(0,0.02,0),Vector3(float(road.width)*0.10,0.10,length),Color("#30383d"))
            slab.rotation.y=atan2(delta.x,delta.z)

    # Nearby procedural buildings become 3D masses with roof caps and windows.
    var built: int = 0
    for bi in range(buildings.size()):
        var b: Dictionary = buildings[bi]
        var rect: Rect2 = b.rect
        var bc: Vector2 = rect.get_center()
        if bc.distance_to(center)>radius:
            continue
        var h: float = maxf(4.0,float(b.height)*0.075)
        var local := _photo_local(bc,center,h*0.5)
        var size := Vector3(rect.size.x*0.10,h,rect.size.y*0.10)
        var body := _photo_box("Building_%d" % bi,local,size,Color(b.wall))
        var roof := _photo_box("Roof_%d" % bi,local+Vector3(0,h*0.52,0),Vector3(size.x*0.94,0.35,size.z*0.94),Color(b.roof))
        built+=1
        if built>55:
            break

    # Landmark volumes get stronger silhouettes.
    for li in range(landmarks.size()):
        var l: Dictionary = landmarks[li]
        var lp: Vector2 = Vector2(l.pos)
        if lp.distance_to(center)>radius*1.25:
            continue
        var h: float = maxf(8.0,float(l.h)*0.085)
        var sz: Vector2 = Vector2(l.size)*0.10
        var local := _photo_local(lp,center,h*0.5)
        var lm := _photo_box("Landmark_%s" % str(l.name),local,Vector3(maxf(8.0,sz.x),h,maxf(8.0,sz.y)),Color(l.accent).darkened(0.42))
        var cap := _photo_box("LandmarkCap_%s" % str(l.name),local+Vector3(0,h*0.53,0),Vector3(maxf(6.0,sz.x*0.72),1.0,maxf(6.0,sz.y*0.72)),Color(l.accent))

    # Trees as trunk/crown 3D forms.
    var tree_count: int = 0
    for tr in trees:
        var tp: Vector2 = Vector2(tr.pos)
        if tp.distance_to(center)>radius*0.80:
            continue
        var base := _photo_local(tp,center,0)
        _photo_box("TreeTrunk",base+Vector3(0,2.2,0),Vector3(0.8,4.4,0.8),Color("#6c543d"))
        var crown := SphereMesh.new()
        crown.radius=maxf(1.5,float(tr.r)*0.12)
        crown.height=crown.radius*2.0
        var crown_node := MeshInstance3D.new()
        crown_node.mesh=crown
        crown_node.position=base+Vector3(0,5.5+crown.radius*0.5,0)
        crown_node.material_override=_photo_material(Color(tr.tint))
        photo_world_root.add_child(crown_node)
        tree_count+=1
        if tree_count>38:
            break

    # Static parked cars.
    var parked_count: int = 0
    for ci in range(parked_cars.size()):
        var car: Dictionary = parked_cars[ci]
        var cp: Vector2 = Vector2(car.pos)
        if cp.distance_to(center)>radius:
            continue
        _photo_make_car("Parked_%d" % ci,cp,float(car.heading),str(car["class"]),Color(car.color),center,null)
        parked_count+=1
        if parked_count>22:
            break

    # Moving traffic is mirrored and updated each frame.
    var traffic_count: int = 0
    for ti in range(traffic.size()):
        var trf: Dictionary = traffic[ti]
        var tf := _traffic_world_transform(trf)
        var wp: Vector2 = Vector2(tf.pos)
        if wp.distance_to(center)>radius:
            continue
        var car_node := _photo_make_car("Traffic_%d" % ti,wp,Vector2(tf.tangent).angle(),str(trf["class"]),Color(trf.color),center,null)
        photo_dynamic_cars[ti]=car_node
        traffic_count+=1
        if traffic_count>30:
            break

    _photo_spawn_targets(index,center)

func _photo_make_car(name_text: String, world_pos: Vector2, heading: float, cls: String, color: Color, center: Vector2, parent: Node3D = null) -> Node3D:
    var root := Node3D.new()
    root.name=name_text
    (photo_world_root if parent==null else parent).add_child(root)
    var sz: Vector2 = VEHICLE_SIZES.get(cls,Vector2(45,22))*0.10
    var body := _photo_box(name_text+"_Body",Vector3(0,1.15,0),Vector3(sz.x,1.3,sz.y),color,root)
    var cabin := _photo_box(name_text+"_Cabin",Vector3(-0.2,2.0,0),Vector3(sz.x*0.48,0.85,sz.y*0.78),Color("#74a7bd"),root)
    if cls in ["suv","van","delivery"]:
        cabin.scale.y=1.20
    if cls in ["sport","hyper"]:
        body.scale.y=0.72
        cabin.scale.y=0.72
    root.position=_photo_local(world_pos,center,0.0)
    root.rotation.y=-heading+PI*0.5
    return root

func _photo_spawn_targets(index: int, center: Vector2) -> void:
    var ph: Dictionary = photo_points[index]
    var id: String = str(ph.id)
    var district: String = str(ph.district)
    var library: Array = [
        {"kind":"symbol","label":"Verstecktes PMDD-Symbol","hint":"Suche hoch an einer Fassade.","pos":Vector3(-18,13,-32)},
        {"kind":"drone","label":"Wartungsdrohne","hint":"Sie schwebt oberhalb der Straße.","pos":Vector3(27,17,-10)},
        {"kind":"rarecar","label":"Seltenes Fahrzeug","hint":"Achte auf eine ungewöhnliche Karosserie.","pos":Vector3(-30,2.8,22)},
        {"kind":"cat","label":"Dachkatze","hint":"Schau auf niedrige Dächer und Vorsprünge.","pos":Vector3(20,10,-28)},
        {"kind":"neoncode","label":"Leuchtender Code","hint":"Suche eine kleine helle Zeichenfolge.","pos":Vector3(-24,9,-20)},
        {"kind":"antenna","label":"Seltsame Antenne","hint":"Sie ragt deutlich über die Dachkante.","pos":Vector3(32,19,18)},
        {"kind":"window","label":"Ungewöhnlicher Fensterreflex","hint":"Ein Fenster leuchtet anders als die anderen.","pos":Vector3(18,12,31)},
        {"kind":"bird","label":"Seltener Vogel","hint":"Suche in der Nähe von Dachkante oder Baumkrone.","pos":Vector3(-16,16,26)}
    ]
    var picks: Array = []
    if district in ["Glasdistrikt","Zentrum","Kulturviertel"]:
        picks=[0,1,6]
    elif district in ["Hafen","Kanäle","Küstenband"]:
        picks=[1,2,7]
    elif district in ["Nordpark","Gärten","Universität"]:
        picks=[3,6,7]
    elif district in ["Neon Mile","Solar Heights"]:
        picks=[2,4,5]
    elif district=="Observatorium":
        picks=[0,5,7]
    else:
        picks=[0,2,3]

    var offset_seed: int = abs(id.hash())%19
    for i in range(3):
        var t: Dictionary = Dictionary(library[int(picks[i])]).duplicate(true)
        var p: Vector3 = Vector3(t.pos)
        p.x += float((offset_seed+i*7)%13)-6.0
        p.z += float((offset_seed+i*11)%17)-8.0
        t["pos"]=p
        t["key"]="%s_%d" % [id,i]
        var root := Node3D.new()
        root.name="PhotoTarget_%d" % i
        root.position=p
        photo_world_root.add_child(root)
        _photo_build_target_visual(root,str(t.kind),i)
        t["node"]=root
        photo_targets.append(t)

func _photo_build_target_visual(root: Node3D, kind: String, variant: int) -> void:
    if kind=="symbol":
        var mesh := SphereMesh.new()
        mesh.radius=1.4
        mesh.height=2.8
        var node := MeshInstance3D.new()
        node.mesh=mesh
        node.material_override=_photo_material(Color("#ff73d1"),0.15,0.28)
        root.add_child(node)
        for a in range(3):
            var ring := TorusMesh.new()
            ring.inner_radius=1.8+float(a)*0.55
            ring.outer_radius=2.05+float(a)*0.55
            var ring_node := MeshInstance3D.new()
            ring_node.mesh=ring
            ring_node.rotation_degrees=Vector3(90,0,float(a)*35)
            ring_node.material_override=_photo_material(Color(1.0,0.42,0.82,0.62),0.25,0.20)
            root.add_child(ring_node)
    elif kind=="drone":
        _photo_box("DroneBody",Vector3.ZERO,Vector3(3.2,0.9,2.2),Color("#dce8ec"),root)
        for dx in [-2.1,2.1]:
            for dz in [-1.5,1.5]:
                _photo_box("Rotor",Vector3(dx,0,dz),Vector3(1.8,0.15,1.8),Color("#35464f"),root)
    elif kind=="rarecar":
        _photo_box("RareBody",Vector3.ZERO,Vector3(5.4,1.2,2.1),Color("#ff4f65"),root)
        _photo_box("RareCabin",Vector3(-0.3,1.0,0),Vector3(2.4,0.8,1.65),Color("#68efd7"),root)
    elif kind=="cat":
        _photo_box("CatBody",Vector3.ZERO,Vector3(1.4,0.8,2.2),Color("#51473f"),root)
        _photo_box("CatHead",Vector3(0,0.6,-1.25),Vector3(1.0,1.0,1.0),Color("#5d5147"),root)
        _photo_box("EarL",Vector3(-0.28,0.72,-1.35),Vector3(0.22,0.45,0.22),Color("#5d5147"),root)
        _photo_box("EarR",Vector3(0.28,0.72,-1.35),Vector3(0.22,0.45,0.22),Color("#5d5147"),root)
    elif kind=="neoncode":
        for k in range(5):
            _photo_box("Code_%d" % k,Vector3(float(k)*0.8-1.6,float(k%2)*0.45,0),Vector3(0.55,0.24,0.18),Color("#67f7df") if k%2==0 else Color("#ff6bd6"),root)
    elif kind=="antenna":
        _photo_box("Mast",Vector3(0,4.5,0),Vector3(0.45,9.0,0.45),Color("#8d9ba3"),root)
        for k in range(3):
            _photo_box("Cross_%d" % k,Vector3(0,2.4+float(k)*2.1,0),Vector3(4.8-float(k)*0.8,0.25,0.25),Color("#d3e1e5"),root)
    elif kind=="window":
        _photo_box("WindowGlow",Vector3.ZERO,Vector3(4.2,3.0,0.20),Color("#ffd47f"),root)
        _photo_box("WindowCore",Vector3(0,0,0.18),Vector3(2.8,1.8,0.12),Color("#fff5d0"),root)
    elif kind=="bird":
        _photo_box("BirdBody",Vector3.ZERO,Vector3(1.3,0.6,1.8),Color("#27343a"),root)
        _photo_box("WingL",Vector3(-1.0,0,0),Vector3(1.6,0.18,0.8),Color("#3e5059"),root)
        _photo_box("WingR",Vector3(1.0,0,0),Vector3(1.6,0.18,0.8),Color("#3e5059"),root)

func _start_photo_challenge(index: int) -> void:
    if index<0 or index>=photo_points.size() or bool(photo_points[index].taken):
        return
    active_photo_index=index
    photo_mode=true
    photo_yaw=0.0
    photo_pitch=-0.08
    photo_fov=68.0
    photo_drag_touch=-1
    move_vec=Vector2.ZERO
    vehicle_velocity=0.0
    if current_vehicle>=0:
        parked_cars[current_vehicle]["occupied"]=true
    _photo_build_scene(index)
    _photo_show_ui(true)
    photo_view_rect.visible=true
    _photo_update_camera()
    _photo_refresh_labels()
    _play_sfx("mission")
    _show_reward_popup("PHOTO CHALLENGE",str(photo_points[index].label)+"\nFinde und fotografiere alle versteckten Motive.",Color("#ffb3e6"))

func _exit_photo_mode() -> void:
    photo_mode=false
    active_photo_index=-1
    photo_drag_touch=-1
    photo_view_rect.visible=false
    _photo_show_ui(false)
    _photo_clear_3d_scene()
    queue_redraw()

func _photo_show_ui(show: bool) -> void:
    photo_target_label.visible=show
    photo_status_label.visible=show
    photo_shutter_button.visible=show
    photo_exit_button.visible=show
    photo_hint_button.visible=show
    photo_zoom_in_button.visible=show
    photo_zoom_out_button.visible=show

func _input_photo_mode(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var t := event as InputEventScreenTouch
        if t.pressed and photo_drag_touch<0:
            photo_drag_touch=t.index
            photo_drag_last=t.position
        elif not t.pressed and t.index==photo_drag_touch:
            photo_drag_touch=-1
    elif event is InputEventScreenDrag:
        var d := event as InputEventScreenDrag
        if d.index==photo_drag_touch:
            var delta := d.position-photo_drag_last
            photo_drag_last=d.position
            photo_yaw=wrapf(photo_yaw-delta.x*0.0045,-PI,PI)
            photo_pitch=clampf(photo_pitch-delta.y*0.0038,-0.72,0.48)
            _photo_update_camera()

func _photo_update_camera() -> void:
    if photo_camera==null:
        return
    photo_camera.position=Vector3(0,6.2,0)
    photo_camera.rotation=Vector3(photo_pitch,photo_yaw,0)
    photo_camera.fov=photo_fov

func _photo_zoom(amount: float) -> void:
    photo_fov=clampf(photo_fov+amount,34.0,82.0)
    _photo_update_camera()

func _photo_center_target() -> Dictionary:
    if photo_camera==null:
        return {}
    var center := Vector2(photo_viewport.size)*0.5
    var best: Dictionary = {}
    var best_d: float = 99999.0
    for t in photo_targets:
        var key := str(t.key)
        if bool(photo_found.get(key,false)):
            continue
        var node: Node3D = t.node
        if photo_camera.is_position_behind(node.global_position):
            continue
        var screen := photo_camera.unproject_position(node.global_position)
        var d: float = screen.distance_to(center)
        if d<best_d:
            best_d=d
            best=t
    if best_d<115.0:
        return best
    return {}

func _photo_shutter() -> void:
    if not photo_mode:
        return
    photo_flash_alpha=1.0
    _play_sfx("photo")
    var target := _photo_center_target()
    if target.is_empty():
        photo_status_label.text="Kein Suchmotiv sauber im Sucher."
        return
    var key := str(target.key)
    var node: Node3D = target.node
    var screen_pos := photo_camera.unproject_position(node.global_position)
    var center := Vector2(photo_viewport.size)*0.5
    var framing: float = clampf(1.0-screen_pos.distance_to(center)/115.0,0.0,1.0)
    var zoom_bonus: float = clampf((82.0-photo_fov)/48.0,0.0,1.0)
    var score: int = int(60.0+framing*30.0+zoom_bonus*10.0)
    photo_found[key]=true
    photo_scores[key]=maxi(score,int(photo_scores.get(key,0)))
    _show_reward_popup("MOTIV GEFUNDEN","%s · %d/100" % [str(target.label),score],Color("#ffb3e6"))
    node.visible=false
    _photo_refresh_labels()
    var complete := true
    for t in photo_targets:
        if not bool(photo_found.get(str(t.key),false)):
            complete=false
            break
    if complete:
        _complete_photo_challenge()

func _photo_refresh_labels() -> void:
    if not photo_mode or active_photo_index<0:
        return
    var remaining: Array = []
    var found_count: int = 0
    for t in photo_targets:
        if bool(photo_found.get(str(t.key),false)):
            found_count+=1
        else:
            remaining.append(str(t.label))
    var score_sum: int = 0
    for t in photo_targets:
        score_sum+=int(photo_scores.get(str(t.key),0))
    photo_target_label.text="%s\nMotive %d / %d · Score %d/300" % [str(photo_points[active_photo_index].label),found_count,photo_targets.size(),score_sum]
    photo_status_label.text=("Noch suchen: "+", ".join(remaining)) if not remaining.is_empty() else "Alle Motive gefunden."

func _photo_hint() -> void:
    if not photo_mode:
        return
    for t in photo_targets:
        if not bool(photo_found.get(str(t.key),false)):
            photo_status_label.text="HINWEIS · "+str(t.hint)
            return

func _complete_photo_challenge() -> void:
    if active_photo_index<0:
        return
    var ph: Dictionary = photo_points[active_photo_index]
    if not bool(ph.taken):
        photo_points[active_photo_index]["taken"]=true
        photo_count+=1
        var quality: int = 0
        for t in photo_targets:
            quality+=int(photo_scores.get(str(t.key),0))
        var quality_bonus: int = 25 if quality>=270 else (12 if quality>=225 else 0)
        credits+=int(ph.reward)+quality_bonus
        _save_game()
        _advance_native_chapter()
        _check_milestones()
        _show_reward_popup("PHOTO SPOT ABGESCHLOSSEN","%s\n3 Motive · +%d CR%s" % [str(ph.label),int(ph.reward),(" · Qualitätsbonus" if quality_bonus>0 else "")],Color("#ffb3e6"))
    await get_tree().create_timer(0.85).timeout
    _exit_photo_mode()

func _update_photo_3d_scene(_delta: float) -> void:
    if active_photo_index<0:
        return
    var center: Vector2 = Vector2(photo_points[active_photo_index].pos)
    for key in photo_dynamic_cars.keys():
        var ti: int = int(key)
        if ti<0 or ti>=traffic.size():
            continue
        var node: Node3D = photo_dynamic_cars[key]
        if not is_instance_valid(node):
            continue
        var tf := _traffic_world_transform(traffic[ti])
        var wp: Vector2 = Vector2(tf.pos)
        node.position=_photo_local(wp,center,0.0)
        node.rotation.y=-Vector2(tf.tangent).angle()+PI*0.5

    # Add a subtle animation to photo targets.
    var time := Time.get_ticks_msec()/1000.0
    for i in range(photo_targets.size()):
        var t: Dictionary = photo_targets[i]
        var node: Node3D = t.node
        if not is_instance_valid(node) or not node.visible:
            continue
        if str(t.kind)=="drone":
            var base: Vector3 = Vector3(t.pos)
            node.position=base+Vector3(sin(time*1.7+float(i))*2.0,sin(time*2.4)*0.8,cos(time*1.3+float(i))*1.4)
        elif str(t.kind)=="symbol":
            node.rotation.y=time*0.45
        elif str(t.kind)=="bird":
            var base: Vector3 = Vector3(t.pos)
            node.position=base+Vector3(sin(time*0.9+float(i))*3.2,sin(time*1.8)*0.5,cos(time*0.9+float(i))*2.2)
            node.rotation.y=time*0.75
        elif str(t.kind)=="neoncode":
            node.scale=Vector3.ONE*(1.0+sin(time*3.0)*0.06)
    _photo_refresh_labels()

func _build_audio() -> void:
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -7.0
    add_child(sfx_player)
    sounds["collect"] = _make_chime([659.0, 988.0], [0.06, 0.11], 0.12)
    sounds["secret"] = _make_chime([784.0, 1175.0, 1568.0], [0.09, 0.11, 0.16], 0.16)
    sounds["scan"] = _make_chime([310.0, 465.0, 620.0], [0.05, 0.07, 0.09], 0.09)
    sounds["vehicle"] = _make_chime([180.0,240.0],[0.06,0.08],0.07)
    sounds["photo"] = _make_chime([523.0,784.0,1047.0],[0.035,0.045,0.12],0.15)
    sounds["mission"] = _make_chime([440.0,659.0,880.0],[0.06,0.08,0.13],0.13)
    sounds["cash"] = _make_chime([740.0,988.0],[0.035,0.08],0.10)
    sounds["door"] = _make_chime([210.0,330.0],[0.035,0.06],0.055)
    sounds["hack_click"] = _make_chime([520.0],[0.025],0.055)
    sounds["error"] = _make_chime([190.0,145.0],[0.055,0.09],0.08)
    sounds["impact"] = _make_chime([95.0,72.0],[0.035,0.055],0.11)

func _make_chime(freqs: Array, durations: Array, amp: float) -> AudioStreamWAV:
    var rate := 22050
    var gap := 0.035
    var total := 0.0
    for d in durations:
        total += float(d) + gap
    var samples := int(total * rate)
    var data := PackedByteArray()
    data.resize(samples * 2)
    var cursor := 0
    for n in range(freqs.size()):
        var dur := float(durations[n])
        var count := int(dur * rate)
        for i in range(count):
            var phase := float(i) / rate
            var env := minf(1.0, float(i)/150.0) * pow(maxf(0.0, 1.0 - float(i)/maxf(1.0,float(count))), 1.7)
            var sample := sin(TAU * float(freqs[n]) * phase) * amp * env
            var iv := int(clampf(sample,-1.0,1.0) * 32767.0)
            if iv < 0:
                iv += 65536
            var idx := (cursor + i) * 2
            if idx + 1 < data.size():
                data[idx] = iv & 255
                data[idx+1] = (iv >> 8) & 255
        cursor += count + int(gap * rate)
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = rate
    wav.stereo = false
    wav.data = data
    return wav

func _play_sfx(name: String) -> void:
    if not sound_enabled:
        return
    if not sounds.has(name):
        return
    sfx_player.stop()
    sfx_player.stream = sounds[name]
    sfx_player.play()

func _bootstrap_android_camera() -> void:
    if OS.get_name() != "Android":
        camera_status = "Desktop · Touch Peek"
        return
    OS.request_permissions()
    camera_status = "Frontkamera: Plugin vorbereitet · Sensor-PMDD aktiv"
    if CameraServer.has_method("feeds"):
        CameraServer.set("monitoring_feeds", true)
        await get_tree().create_timer(0.75).timeout
        var feeds = CameraServer.call("feeds")
        if feeds is Array and feeds.size() > 0:
            camera_status = "Frontkamera erkannt · Sensor-PMDD aktiv"

func _update_sensor(delta: float) -> void:
    if OS.get_name() == "Android":
        var g := Input.get_gravity()
        if g.length() > 1.0:
            var target := Vector2(g.x / 9.8, -g.y / 9.8) * 0.32 * sensor_gain
            sensor_view = sensor_view.lerp(target.limit_length(0.58), minf(1.0,delta*3.5))
            return
    sensor_view = sensor_view.lerp(Vector2.ZERO, minf(1.0,delta*2.0))

func _update_player(delta: float) -> void:
    if photo_mode:
        move_vec=Vector2.ZERO
        vehicle_velocity=move_toward(vehicle_velocity,0.0,delta*620.0)
        return
    if transit_riding >= 0:
        move_vec = Vector2.ZERO
        return
    if map_open or missions_open or collection_open or minigame_open or commerce_panel.visible or dialogue_panel.visible:
        vehicle_velocity = move_toward(vehicle_velocity,0.0,delta*320.0)
        return
    if interior_active:
        if move_vec.length() < 0.04:
            return
        var iv := move_vec.normalized() * WALK_SPEED * minf(1.0,move_vec.length())
        interior_player_pos += iv * delta
        interior_player_pos.x = clampf(interior_player_pos.x,45.0,interior_size.x-45.0)
        interior_player_pos.y = clampf(interior_player_pos.y,45.0,interior_size.y-45.0)
        player_heading = iv.angle()
        return
    if current_vehicle>=0 and not active_race.is_empty() and float(active_race.get("countdown",0.0))>0.0:
        vehicle_velocity=move_toward(vehicle_velocity,0.0,delta*600.0)
        return
    if move_vec.length() < 0.04:
        vehicle_velocity = move_toward(vehicle_velocity, 0.0, delta * 280.0)
        return
    if current_vehicle >= 0:
        var car: Dictionary = parked_cars[current_vehicle]
        var cls: String = str(car["class"])
        var max_speed: float = float(VEHICLE_SPEEDS.get(cls,400.0)) * _vehicle_tune_multiplier(cls,"engine")
        var accel: float = float(VEHICLE_ACCEL.get(cls,240.0)) * _vehicle_tune_multiplier(cls,"engine")
        var brake: float = float(VEHICLE_BRAKE.get(cls,350.0)) * _vehicle_tune_multiplier(cls,"brake")
        var handling: float = float(VEHICLE_HANDLING.get(cls,2.2)) * _vehicle_tune_multiplier(cls,"handling")
        var throttle: float = clampf(-move_vec.y,-1.0,1.0)
        var steer_raw: float = clampf(move_vec.x,-1.0,1.0)
        var steer: float = sign(steer_raw)*pow(abs(steer_raw),1.32)
        var desired_speed: float = max_speed*throttle if throttle>=0.0 else max_speed*0.30*throttle
        var rate: float = accel if abs(desired_speed)>abs(vehicle_velocity) and sign(desired_speed)==sign(vehicle_velocity) else brake
        if abs(throttle)<0.08:
            desired_speed=0.0
            rate=105.0
        vehicle_velocity=move_toward(vehicle_velocity,desired_speed,rate*delta)
        var speed_ratio: float = clampf(abs(vehicle_velocity)/maxf(1.0,max_speed),0.0,1.0)
        var steer_gain: float = handling*(0.24+0.92*speed_ratio)
        var reverse_sign: float = -1.0 if vehicle_velocity<0.0 else 1.0
        player_heading += steer*steer_gain*delta*reverse_sign
        if driving_assist and abs(steer)<0.16 and abs(vehicle_velocity)>55.0:
            var nearest_road: int = _nearest_road_index(player_pos)
            if nearest_road>=0:
                var road_tangent := _closest_road_tangent(nearest_road,player_pos)
                var desired: float = road_tangent.angle()
                if abs(wrapf(desired-player_heading,-PI,PI))>PI*0.5:
                    desired=wrapf(desired+PI,-PI,PI)
                player_heading=lerp_angle(player_heading,desired,minf(1.0,delta*(0.45+speed_ratio*0.75)))
        var velocity := Vector2.from_angle(player_heading)*vehicle_velocity
        var np := player_pos+velocity*delta
        if not _point_blocked(np,18.0) and not _vehicle_dynamic_blocked(np,current_vehicle):
            player_pos=np
        else:
            var impact_speed: float = abs(vehicle_velocity)
            vehicle_velocity*=-0.06
            _play_sfx("impact")
            _haptic(75 if impact_speed>170.0 else 35)
            if impact_speed>170.0:
                _notify("Kollision · Geschwindigkeit reduzieren")
        car["pos"]=player_pos
        car["heading"]=player_heading
        parked_cars[current_vehicle]=car
        driven_classes[cls]=true
    else:
        var foot_speed: float = WALK_SPEED if energy > 5.0 else 105.0
        var velocity2 := move_vec.normalized() * foot_speed * minf(1.0, move_vec.length())
        var np2 := player_pos + velocity2 * delta
        if not _point_blocked(np2, 12.0):
            player_pos = np2
            player_heading = velocity2.angle()
    player_pos.x = clampf(player_pos.x, 20.0, WORLD_SIZE.x-20.0)
    player_pos.y = clampf(player_pos.y, 20.0, WORLD_SIZE.y-20.0)
    if move_vec.length() > 0.08:
        var drain: float = 0.018 if current_vehicle >= 0 else 0.055
        energy = maxf(0.0,energy-delta*drain*10.0)

func _closest_road_tangent(road_index: int, p: Vector2) -> Vector2:
    if road_index<0 or road_index>=roads.size():
        return Vector2.RIGHT
    var best_t: float = 0.0
    var best_d: float = INF
    for n in range(31):
        var t: float = float(n)/30.0
        var sample := _sample_polyline(roads[road_index].points,t)
        var d := sample.distance_to(p)
        if d<best_d:
            best_d=d
            best_t=t
    return _polyline_tangent(roads[road_index].points,best_t)

func _vehicle_dynamic_blocked(candidate: Vector2, ignore_parked: int = -1) -> bool:
    for i in range(parked_cars.size()):
        if i==ignore_parked:
            continue
        var pc: Dictionary = parked_cars[i]
        if Vector2(pc.pos).distance_to(candidate)<34.0:
            return true
    for c in traffic:
        var tr := _traffic_world_transform(c)
        if Vector2(tr.pos).distance_to(candidate)<32.0:
            return true
    for a in smart_agents:
        var state := str(a.state)
        if state not in ["driving","parking","parked","entering"]:
            continue
        var rd = roads[int(a.road)]
        var tan := _polyline_tangent(rd.points,float(a.t))
        if bool(a.reverse): tan*=-1.0
        var normal := Vector2(-tan.y,tan.x)
        var pos := _sample_polyline(rd.points,float(a.t))+normal*(float(rd.width)*(0.18+float(int(a.lane))*0.14))
        if pos.distance_to(candidate)<32.0:
            return true
    return false

func _lane_is_clear(car_index: int, lane: int, radius_t: float = 0.045) -> bool:
    if car_index<0 or car_index>=traffic.size():
        return false
    var c: Dictionary = traffic[car_index]
    for k in range(traffic.size()):
        if k==car_index:
            continue
        var other: Dictionary = traffic[k]
        if int(other.road)!=int(c.road) or int(other.lane)!=lane or bool(other.reverse)!=bool(c.reverse):
            continue
        var gap: float = abs(float(other.t)-float(c.t))
        gap=minf(gap,1.0-gap)
        if gap<radius_t:
            return false
    return true

func _choose_agent_activity(_a: Dictionary) -> Dictionary:
    var candidates: Array = []
    for st in storefronts:
        if str(st.kind) in ["restaurant","cafe","shop","garage","workshop"]:
            candidates.append({"kind":str(st.kind),"pos":Vector2(st.pos)})
    for park in parks:
        candidates.append({"kind":"park","pos":Vector2(park.rect.get_center())})
    for prop in property_sites:
        candidates.append({"kind":"residential","pos":Vector2(prop.pos)})
    if candidates.is_empty():
        return {"kind":"walk","pos":player_pos}
    return Dictionary(candidates[rng.randi_range(0,candidates.size()-1)])

func _nearest_road_t_to_point(road_index: int, target: Vector2) -> float:
    if road_index<0 or road_index>=roads.size():
        return 0.0
    var best_t: float = 0.0
    var best_d: float = INF
    for n in range(41):
        var tt: float = float(n)/40.0
        var p: Vector2 = _sample_polyline(roads[road_index].points,tt)
        var d: float = p.distance_to(target)
        if d<best_d:
            best_d=d
            best_t=tt
    return best_t

func _update_traffic(delta: float) -> void:
    for i in range(traffic.size()):
        var c: Dictionary = traffic[i]
        c["turn_cooldown"]=maxf(0.0,float(c.get("turn_cooldown",0.0))-delta)
        c["turn_anim"]=maxf(0.0,float(c.get("turn_anim",0.0))-delta)
        if float(c.get("turn_anim",0.0))<=0.0 and float(c.get("lane_change",0.0))<=0.0:
            c["indicator"]=0
        var direction: float = -1.0 if bool(c.reverse) else 1.0
        var target_speed: float = float(c.cruise)

        # Car-following on the active lane.
        var best_gap: float = 999.0
        for k in range(traffic.size()):
            if k==i:
                continue
            var other: Dictionary = traffic[k]
            if int(other.road)!=int(c.road) or int(other.lane)!=int(c.lane) or bool(other.reverse)!=bool(c.reverse):
                continue
            var gap: float = (float(other.t)-float(c.t))*direction
            if gap<0.0:
                gap+=1.0
            if gap>0.0 and gap<best_gap:
                best_gap=gap

        # Overtake / lane change if the current lane is blocked.
        if best_gap<0.050 and float(c.get("lane_change",0.0))<=0.0:
            var other_lane: int = 1-int(c.lane)
            if _lane_is_clear(i,other_lane,0.050):
                c["lane_from"]=int(c.lane)
                c["lane_to"]=other_lane
                c["lane"]=other_lane
                c["lane_change"]=1.0
                c["indicator"]=1 if other_lane>int(c.lane_from) else -1
        if float(c.get("lane_change",0.0))>0.0:
            c["lane_change"]=maxf(0.0,float(c.lane_change)-delta*1.65)
            if float(c.lane_change)<=0.0:
                c["indicator"]=0

        if current_vehicle>=0:
            var tr_now := _traffic_world_transform(c)
            var player_gap: float = Vector2(tr_now.pos).distance_to(player_pos)
            if player_gap<58.0:
                target_speed=0.0
            elif player_gap<92.0:
                target_speed*=0.45

        if best_gap<0.018:
            target_speed=0.0
        elif best_gap<0.035:
            target_speed*=0.35
        elif best_gap<0.055:
            target_speed*=0.68

        var j := _junction_for_car(int(c.road),float(c.t),0.028)
        if not j.is_empty():
            var jt: float = float(j.ta) if int(j.a)==int(c.road) else float(j.tb)
            var signed_gap: float = (jt-float(c.t))*direction
            if signed_gap<0.0:
                signed_gap+=1.0
            if signed_gap<0.020 and not _junction_green(j,int(c.road)):
                target_speed=0.0

        var speed_now: float = float(c.speed)
        speed_now=move_toward(speed_now,target_speed,delta*0.08)
        c["speed"]=speed_now
        var old_t: float = float(c.t)
        var old_pos: Vector2 = Vector2(_traffic_world_transform(c).pos)
        var new_t: float = fposmod(old_t+speed_now*delta*direction,1.0)

        if not j.is_empty() and float(c.turn_cooldown)<=0.0 and _junction_green(j,int(c.road)):
            var jt2: float = float(j.ta) if int(j.a)==int(c.road) else float(j.tb)
            var crossed: bool = (direction>0.0 and old_t<=jt2 and new_t>=jt2) or (direction<0.0 and old_t>=jt2 and new_t<=jt2)
            if crossed and rng.randf()<0.30:
                var old_road: int = int(c.road)
                var new_road: int = int(j.b) if int(j.a)==old_road else int(j.a)
                var new_t_at_j: float = float(j.tb) if new_road==int(j.b) else float(j.ta)
                # Choose the legal direction that best matches a real left/right turn instead of random teleporting.
                var old_tangent := _polyline_tangent(roads[old_road].points,jt2)
                if bool(c.reverse):
                    old_tangent*=-1.0
                var tangent_forward := _polyline_tangent(roads[new_road].points,new_t_at_j)
                var tangent_reverse := -tangent_forward
                var turn_forward: float = abs(old_tangent.angle_to(tangent_forward))
                var turn_reverse: float = abs(old_tangent.angle_to(tangent_reverse))
                var choose_reverse: bool = turn_reverse<turn_forward
                if rng.randf()<0.48:
                    choose_reverse=not choose_reverse
                c["road"]=new_road
                c["t"]=new_t_at_j
                c["reverse"]=choose_reverse
                c["lane"]=rng.randi_range(0,1)
                c["turn_cooldown"]=2.8
                c["turn_anim"]=0.55
                c["turn_from"]=old_pos
                var temp: Dictionary = c.duplicate()
                c["turn_to"]=Vector2(_traffic_world_transform(temp).pos)
                c["indicator"]=1 if old_tangent.cross(Vector2(_traffic_world_transform(temp).tangent))>0.0 else -1
                traffic[i]=c
                continue
        c["t"]=new_t
        traffic[i]=c
    _update_smart_agents(delta)

func _update_smart_agents(delta: float) -> void:
    for i in range(smart_agents.size()):
        var a: Dictionary = smart_agents[i]
        a["timer"]=float(a.timer)-delta
        a["phase"]=fposmod(float(a.phase)+delta*5.0,TAU)
        var state: String = str(a.state)

        if Vector2(a.get("destination",Vector2.ZERO))==Vector2.ZERO:
            var activity: Dictionary = _choose_agent_activity(a)
            a["activity"]=str(activity.kind)
            a["destination"]=Vector2(activity.pos)

        if state=="walking":
            var dest: Vector2 = Vector2(a.destination)
            var walk_target_t: float = _nearest_road_t_to_point(int(a.road),dest)
            var diff: float = walk_target_t-float(a.t)
            if abs(diff)>0.5:
                diff=-sign(diff)*(1.0-abs(diff))
            var dir: float = sign(diff)
            if abs(diff)>0.010:
                a["t"]=fposmod(float(a.t)+float(a.speed)*0.38*delta*dir,1.0)
                a["reverse"]=dir<0.0
            else:
                a["dwell"]=float(a.get("dwell",0.0))+delta
            if float(a.get("dwell",0.0))>rng.randf_range(2.5,5.5) or float(a.timer)<=0.0:
                a["state"]="entering"
                a["timer"]=1.1
                a["parking_progress"]=0.0
                a["dwell"]=0.0
                if bool(a.get("car_parked",false)):
                    a["t"]=float(a.get("parked_t",a.t))

        elif state=="entering":
            a["parking_progress"]=minf(1.0,float(a.parking_progress)+delta/1.1)
            if float(a.timer)<=0.0:
                a["state"]="driving"
                a["timer"]=rng.randf_range(18.0,38.0)
                a["parking_progress"]=0.0
                a["car_parked"]=false
                var next_activity: Dictionary = _choose_agent_activity(a)
                a["activity"]=str(next_activity.kind)
                a["destination"]=Vector2(next_activity.pos)

        elif state=="driving":
            var target_t: float = _nearest_road_t_to_point(int(a.road),Vector2(a.destination))
            var diff_drive: float = target_t-float(a.t)
            if abs(diff_drive)>0.5:
                diff_drive=-sign(diff_drive)*(1.0-abs(diff_drive))
            var dir2: float = sign(diff_drive)
            if abs(diff_drive)>0.020 and float(a.timer)>0.0:
                a["reverse"]=dir2<0.0
                a["t"]=fposmod(float(a.t)+float(a.speed)*delta*dir2,1.0)
            else:
                a["state"]="parking"
                a["timer"]=1.8
                a["parking_progress"]=0.0
                a["parked_t"]=float(a.t)

        elif state=="parking":
            a["parking_progress"]=minf(1.0,float(a.parking_progress)+delta/1.8)
            if float(a.timer)<=0.0:
                a["state"]="parked"
                a["timer"]=rng.randf_range(2.5,6.0)
                a["parking_progress"]=1.0

        elif state=="parked":
            if float(a.timer)<=0.0:
                a["state"]="walking"
                a["timer"]=rng.randf_range(9.0,18.0)
                a["parking_progress"]=0.0
                a["car_parked"]=true

        smart_agents[i]=a

func _update_pedestrians(delta: float) -> void:
    for i in range(pedestrians.size()):
        var p: Dictionary = pedestrians[i]
        p["phase"]=fposmod(float(p.phase)+delta*5.0,TAU)
        var pause: float = float(p.get("pause",0.0))
        if pause>0.0:
            p["pause"]=maxf(0.0,pause-delta)
            pedestrians[i]=p
            continue

        var target_t: float = float(p.get("target_t",float(p.t)))
        var diff: float = target_t-float(p.t)
        if abs(diff)>0.5:
            diff=-sign(diff)*(1.0-abs(diff))
        var direction: float = sign(diff)
        if abs(diff)>0.008:
            p["reverse"]=direction<0.0
            p["t"]=fposmod(float(p.t)+float(p.speed)*delta*direction,1.0)
        else:
            # Arrive at a routine stop, wait, then choose another destination.
            var role: String = str(p.get("routine","work"))
            var dwell: float = 1.5
            if role=="shop": dwell=rng.randf_range(3.0,7.0)
            elif role=="park": dwell=rng.randf_range(4.0,10.0)
            elif role=="transit": dwell=rng.randf_range(2.0,5.0)
            elif role=="home": dwell=rng.randf_range(5.0,12.0)
            else: dwell=rng.randf_range(2.5,6.0)
            p["pause"]=dwell
            p["target_t"]=rng.randf_range(0.05,0.95)
            if rng.randf()<0.18:
                # Change sidewalk corridor at a nearby flat intersection.
                var j := _junction_for_car(int(p.road),float(p.t),0.055)
                if not j.is_empty():
                    var new_road: int = int(j.b) if int(j.a)==int(p.road) else int(j.a)
                    p["road"]=new_road
                    p["t"]=float(j.tb) if new_road==int(j.b) else float(j.ta)
                    p["side"]=-1.0 if rng.randf()<0.5 else 1.0
        pedestrians[i]=p

func _update_transit(delta: float) -> void:
    for i in range(transit_vehicles.size()):
        var tveh: Dictionary = transit_vehicles[i]
        var dwell: float = float(tveh.get("dwell",0.0))
        if dwell > 0.0:
            dwell = maxf(0.0,dwell-delta)
            tveh["dwell"]=dwell
            tveh["at_stop"]=dwell>0.0
            transit_vehicles[i]=tveh
            continue
        var direction: float = -1.0 if bool(tveh.reverse) else 1.0
        var old_t: float = float(tveh.t)
        var new_t: float = fposmod(old_t + float(tveh.speed)*delta*direction,1.0)
        tveh["t"]=new_t
        tveh["at_stop"]=false
        tveh["stop_index"]=-1
        for stop in transit_stops:
            if int(stop.vehicle)!=i:
                continue
            var st: float = float(stop.t)
            var crossed := false
            if direction>0.0:
                crossed = (old_t<=st and new_t>=st) or (new_t<old_t and (st>=old_t or st<=new_t))
            else:
                crossed = (old_t>=st and new_t<=st) or (new_t>old_t and (st<=old_t or st>=new_t))
            if crossed:
                tveh["t"]=st
                tveh["dwell"]=3.2
                tveh["at_stop"]=true
                tveh["stop_index"]=transit_stops.find(stop)
                break
        transit_vehicles[i]=tveh
    if transit_riding>=0 and transit_riding<transit_vehicles.size():
        var ride: Dictionary = transit_vehicles[transit_riding]
        var road = roads[int(ride.road)]
        player_pos = _sample_polyline(road.points,float(ride.t))
        camera_pos = player_pos

func _update_secrets() -> void:
    for i in range(secrets.size()):
        var s = secrets[i]
        if s.found:
            continue
        var d := player_pos.distance_to(s.pos)
        if d < 480.0:
            var peek_score := view_amount.dot(s.dir)
            if peek_score > 0.38 or scan_time > 0.0:
                if not s.revealed:
                    s.revealed = true
                    _play_sfx("secret")
                    last_secret_sound_ms = Time.get_ticks_msec()
                secrets[i] = s

func _update_district() -> void:
    var d := _district_at(player_pos)
    var name: String = d.get("name","Megacity")
    if name != current_district:
        current_district = name
        district_banner.text = name
        district_banner.modulate = Color(1,1,1,1)
        var tw := create_tween()
        tw.tween_interval(1.0)
        tw.tween_property(district_banner, "modulate:a", 0.0, 0.65)

func _update_ui() -> void:
    if photo_mode:
        mission_label.text="PHOTO CHALLENGE"
        detail_label.text="Position fixiert · Kamera drehen, zoomen und versteckte Motive fotografieren."
        status_label.text="3D FOTO-MODUS · Bewegung gesperrt · Kamera aktiv"
        interact_button.disabled=true
        scan_button.disabled=true
        return
    scan_button.disabled=false
    var chapter: Dictionary = Dictionary(native_chapters[mini(native_chapter,native_chapters.size()-1)]) if native_chapters.size()>0 else {"title":"Explore","desc":""}
    mission_label.text = str(chapter.title)
    if interior_active:
        detail_label.text = "%s · %s" % [interior_name,_interior_feature_message()]
    elif not active_job.is_empty():
        detail_label.text = "Stadtauftrag: %s · %d CR · Ziel auf Karte/Kompass." % [str(active_job.get("title","Auftrag")),int(active_job.get("pay",0))]
    else:
        detail_label.text = "Links bewegen · rechts Perspektive · MAP/MISSIONS für Übersicht."
    var mode: String = "Inside · %s" % interior_name if interior_active else "On foot"
    if current_vehicle >= 0:
        var drive_cls: String = str(parked_cars[current_vehicle]["class"])
        var group: String = str(VEHICLE_SPEED_GROUP.get(drive_cls,"ROAD"))
        var speed_kmh: int = int(abs(vehicle_velocity)*0.42)
        mode = "Driving · %s · %s · %d km/h" % [drive_cls.capitalize(),group,speed_kmh]
    elif transit_riding >= 0 and transit_riding < transit_vehicles.size():
        mode = "Transit · %s" % str(transit_vehicles[transit_riding].line)
    status_label.text = "%s · %s · Zoom %.2fx\n%d CR · Energie %d%% · Jobs %d" % [("Interior" if interior_active else current_district),mode,world_zoom,credits,int(energy),jobs_done]
    var near := _nearest_interactable()
    interact_button.disabled = near.is_empty()
    interact_button.text = "INTERACT" if near.is_empty() else str(near.get("action","INTERACT"))

func _scan() -> void:
    scan_time = 2.2
    _play_sfx("scan")
    var found := false
    for i in range(scan_points.size()):
        if bool(scan_points[i].taken):
            continue
        var d: float = player_pos.distance_to(Vector2(scan_points[i].pos))
        if d<145.0:
            scan_points[i]["taken"]=true
            scan_collect_count+=1
            credits+=int(scan_points[i].reward)
            found=true
            _play_sfx("collect")
            _haptic(35)
            _show_reward_popup("STREET SIGNAL GESCANNT","%s · %s\n+%d CR" % [str(scan_points[i].label),str(scan_points[i].district),int(scan_points[i].reward)],Color("#78d8ff"))
            _save_game()
            _advance_native_chapter()
            break
    if not found:
        _notify("Scan aktiv · versteckte Signale in der Nähe werden sichtbar.")

func _interact() -> void:
    if photo_mode:
        return
    if map_open or missions_open or minigame_open or dialogue_panel.visible:
        return
    var n := _nearest_interactable()
    if n.is_empty():
        return
    if n.type == "race":
        _start_race(int(n.index))
        return
    elif n.type == "interior_floor":
        _toggle_interior_floor()
        return
    elif n.type == "transit":
        _toggle_transit(int(n.index))
        return
    elif n.type == "interior_exit":
        _leave_interior()
        return
    elif n.type == "interior_feature":
        _use_interior_feature()
        return
    elif n.type == "storefront":
        var st = storefronts[int(n.index)]
        if current_vehicle>=0 and str(st.kind) in ["garage","workshop"]:
            service_vehicle_index=current_vehicle
        _enter_interior(str(st.name),str(st.kind),st.accent,player_pos)
        return
    elif n.type == "jobboard":
        _open_jobboard(int(n.index))
        return
    elif n.type == "job_target":
        _complete_side_job()
        return
    elif n.type == "openai_hq":
        hack_done["visited_openai"] = true
        _enter_interior("OpenAI HQ","openai_hq",Color("#f2f7f7"),player_pos)
        _advance_native_chapter()
        return
    elif n.type == "vertical":
        _enter_vertical(int(n.index))
        return
    elif n.type == "property":
        if current_vehicle>=0:
            service_vehicle_index=current_vehicle
        _interact_property(int(n.index))
        return
    elif n.type == "mission_site":
        _start_minigame(mission_sites[int(n.index)])
        return
    elif n.type == "named_npc":
        _talk_named_npc(int(n.index))
        return
    elif n.type == "cache":
        var cidx: int = int(n.index)
        if not bool(caches[cidx].taken):
            caches[cidx]["taken"]=true
            cache_count += 1
            credits += 18
            _play_sfx("collect")
            _notify("Daten-Cache geborgen · +18 CR")
            _save_game()
            _advance_native_chapter()
            _check_npc_contract()
        return
    elif n.type == "glyph":
        var gidx: int = int(n.index)
        if not bool(glyphs[gidx].taken):
            glyphs[gidx]["taken"]=true
            glyph_count += 1
            _play_sfx("secret")
            _notify("Stadtsigil gesichert · %s" % str(glyphs[gidx].district))
            _save_game()
            _advance_native_chapter()
        return
    elif n.type == "photo":
        _start_photo_challenge(int(n.index))
        return
    elif n.type == "fragment":
        var idx: int = n.index
        if not fragments[idx].taken:
            fragments[idx].taken = true
            mission_fragments += 1
            _play_sfx("collect")
            _save_game()
            _advance_native_chapter()
    elif n.type == "secret":
        var si: int = n.index
        if secrets[si].revealed and not secrets[si].found:
            secrets[si].found = true
            mission_secrets += 1
            _play_sfx("secret")
            _save_game()
            _advance_native_chapter()
    elif n.type == "car":
        var ci: int = n.index
        if current_vehicle == ci:
            parked_cars[ci].occupied = false
            current_vehicle = -1
            vehicle_velocity = 0.0
        elif current_vehicle < 0:
            current_vehicle = ci
            parked_cars[ci].occupied = true
            player_pos = parked_cars[ci].pos
            player_heading = parked_cars[ci].heading
            _play_sfx("vehicle")

func _nearest_interactable() -> Dictionary:
    if transit_riding>=0:
        var tv: Dictionary = transit_vehicles[transit_riding]
        if bool(tv.get("at_stop",false)):
            return {"type":"transit","index":transit_riding,"action":"AUSSTEIGEN"}
        return {}
    if interior_active:
        var exit_pos := Vector2(interior_size.x*0.5,interior_size.y-48)
        if interior_player_pos.distance_to(exit_pos) < 78.0:
            return {"type":"interior_exit","action":"EXIT"}
        if interior_kind in ["openai_hq","home","shop","restaurant","cafe"] and interior_player_pos.distance_to(_interior_elevator_pos())<78.0:
            return {"type":"interior_floor","action":"ETAGE %d" % (2 if interior_floor==0 else 1)}
        var feature := _interior_feature_pos()
        if interior_player_pos.distance_to(feature) < 82.0:
            return {"type":"interior_feature","action":"USE","message":_interior_feature_message()}
        return {}
    if current_vehicle >= 0:
        if active_race.is_empty():
            for ri in range(race_sites.size()):
                var drace: float = player_pos.distance_to(Vector2(race_sites[ri].pos))
                if drace<145.0:
                    return {"type":"race","index":ri,"action":"ZEITPRÜFUNG"}
        for si in range(storefronts.size()):
            var vst: Dictionary = storefronts[si]
            if str(vst.kind) not in ["garage","workshop"]:
                continue
            if player_pos.distance_to(Vector2(vst.pos)) < 135.0:
                return {"type":"storefront","index":si,"action":"WERKSTATT"}
        for pi in range(property_sites.size()):
            if player_pos.distance_to(Vector2(property_sites[pi].pos)) < 135.0:
                return {"type":"property","index":pi,"action":"GARAGE"}
        return {"type":"car", "index":current_vehicle, "action":"EXIT CAR"}
    var best := {}
    var bd := 999999.0
    for ni in range(named_npcs.size()):
        var dn: float = player_pos.distance_to(Vector2(named_npcs[ni].pos))
        if dn < 82.0 and dn < bd:
            best = {"type":"named_npc","index":ni,"action":"SPRECHEN"}
            bd = dn
    for ci in range(caches.size()):
        if bool(caches[ci].taken):
            continue
        var dc: float = player_pos.distance_to(Vector2(caches[ci].pos))
        if dc < 72.0 and dc < bd:
            best = {"type":"cache","index":ci,"action":"CACHE"}
            bd = dc
    for gi in range(glyphs.size()):
        if bool(glyphs[gi].taken):
            continue
        var dg: float = player_pos.distance_to(Vector2(glyphs[gi].pos))
        if dg < 72.0 and dg < bd:
            best = {"type":"glyph","index":gi,"action":"SIGIL"}
            bd = dg
    for pi in range(photo_points.size()):
        if bool(photo_points[pi].taken):
            continue
        var dphoto: float = player_pos.distance_to(Vector2(photo_points[pi].pos))
        if dphoto < 150.0 and dphoto < bd:
            best = {"type":"photo","index":pi,"action":"PHOTO CHALLENGE"}
            bd = dphoto
    for i in range(fragments.size()):
        if fragments[i].taken:
            continue
        var d := player_pos.distance_to(fragments[i].pos)
        if d < 62.0 and d < bd:
            best = {"type":"fragment","index":i,"action":"COLLECT"}
            bd = d
    for j in range(secrets.size()):
        if secrets[j].found or not secrets[j].revealed:
            continue
        var d2 := player_pos.distance_to(secrets[j].pos)
        if d2 < 88.0 and d2 < bd:
            best = {"type":"secret","index":j,"action":"OPEN SECRET"}
            bd = d2
    for ti in range(transit_vehicles.size()):
        var tv: Dictionary = transit_vehicles[ti]
        if not bool(tv.get("at_stop",false)):
            continue
        var rd = roads[int(tv.road)]
        var tp: Vector2 = _sample_polyline(rd.points,float(tv.t))
        var dt: float = player_pos.distance_to(tp)
        if dt < 115.0 and dt < bd:
            best = {"type":"transit","index":ti,"action":"EINSTEIGEN %s" % str(tv.line)}
            bd = dt
    if not active_job.is_empty() and str(active_job.get("kind","delivery"))=="delivery":
        var target_pos: Vector2 = Vector2(active_job.get("target",Vector2.ZERO))
        var djob: float = player_pos.distance_to(target_pos)
        if djob < 105.0 and djob < bd:
            best = {"type":"job_target","action":"DELIVER"}
            bd = djob
    for ji in range(side_job_sites.size()):
        var djb: float = player_pos.distance_to(Vector2(side_job_sites[ji].pos))
        if djb < 110.0 and djb < bd:
            best = {"type":"jobboard","index":ji,"action":"JOBS"}
            bd = djb
    for vi in range(vertical_sites.size()):
        var dv: float = player_pos.distance_to(Vector2(vertical_sites[vi].pos))
        if dv < 105.0 and dv < bd:
            best = {"type":"vertical","index":vi,"action":"AUFSTIEG" if str(vertical_sites[vi].kind)=="roof" else "SUBLEVEL"}
            bd = dv
    for pi in range(property_sites.size()):
        var dp := player_pos.distance_to(Vector2(property_sites[pi].pos))
        if dp < 105.0 and dp < bd:
            best = {"type":"property","index":pi,"action":"PROPERTY"}
            bd = dp
    for mi in range(mission_sites.size()):
        var dm := player_pos.distance_to(Vector2(mission_sites[mi].pos))
        if dm < 95.0 and dm < bd:
            best = {"type":"mission_site","index":mi,"action":"HACK"}
            bd = dm
    for k in range(parked_cars.size()):
        if parked_cars[k].occupied:
            continue
        var d3 := player_pos.distance_to(parked_cars[k].pos)
        if d3 < 82.0 and d3 < bd:
            best = {"type":"car","index":k,"action":"ENTER CAR"}
            bd = d3
    for si in range(storefronts.size()):
        var ds := player_pos.distance_to(storefronts[si].pos)
        if ds < 88.0 and ds < bd:
            best = {"type":"storefront","index":si,"action":"ENTER"}
            bd = ds
    for l in landmarks:
        if str(l.kind) == "openai_hq":
            var entrance: Vector2 = Vector2(l.pos) + Vector2(0,float(l.size.y)*0.5+48.0)
            var dl := player_pos.distance_to(entrance)
            if dl < 105.0 and dl < bd:
                best = {"type":"openai_hq","action":"ENTER OPENAI HQ"}
                bd = dl
    return best

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#07131b"))
    if main_menu_active:
        _draw_title_art()
        return
    if photo_mode:
        return
    if interior_active:
        _draw_interior_scene()
        _draw_interior_player()
        _draw_ambient_overlay()
        _draw_touch_controls()
        _draw_peek_meter()
        return
    _draw_district_ground()
    _draw_water()
    _draw_parks()
    _draw_roads()
    _draw_buildings()
    _draw_landmarks()
    _draw_trees()
    _draw_vegetation_props()
    _draw_storefronts()
    _draw_named_npcs()
    _draw_story_collectibles()
    _draw_scan_points()
    _draw_photo_points()
    _draw_race_markers()
    _draw_transit_stops()
    _draw_jobboards()
    _draw_street_props()
    _draw_pedestrians()
    _draw_traffic()
    _draw_transit()
    _draw_parked_cars()
    _draw_collectibles()
    _draw_player()
    _draw_ambient_overlay()
    if photo_flash_alpha>0.0:
        draw_rect(Rect2(Vector2.ZERO,get_viewport_rect().size),Color(1,1,1,photo_flash_alpha*0.72),true)
        var frame := Rect2(Vector2(42,130),get_viewport_rect().size-Vector2(84,260))
        draw_rect(frame,Color(1,1,1,photo_flash_alpha*0.45),false,4.0)
    _draw_touch_controls()
    _draw_peek_meter()
    _draw_mission_compass()
    if map_open:
        _draw_map_overlay()
    elif missions_open:
        _draw_missions_overlay()
    elif collection_open:
        _draw_collection_overlay()

func _draw_district_ground() -> void:
    for d in districts:
        var r: Rect2 = d.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        draw_rect(Rect2(p, r.size), d.ground)
        var accent: Color = d.accent
        accent.a = 0.06
        var style: String = str(d.style)

        if style in ["glass","center","neon"]:
            for x in range(int(r.position.x)+100, int(r.end.x), 280):
                var a := _project(Vector2(x,r.position.y))
                var b := _project(Vector2(x,r.end.y))
                draw_line(a,b,accent,2.0)
            for y in range(int(r.position.y)+180,int(r.end.y),420):
                draw_line(_project(Vector2(r.position.x,y)),_project(Vector2(r.end.x,y)),Color(accent.r,accent.g,accent.b,0.035),1.0)

        elif style in ["green","garden"]:
            for i in range(14):
                var cp := _project(r.position + Vector2(180+(i%7)*620, 240+(i/7)*760))
                draw_circle(cp, 32+(i%4)*9, Color(accent.r,accent.g,accent.b,0.05))

        elif style=="air":
            var center_y: float = r.get_center().y
            for x in range(int(r.position.x)+180,int(r.end.x)-180,260):
                var c := _project(Vector2(x,center_y))
                draw_rect(Rect2(c-Vector2(34,4),Vector2(68,8)),Color(0.86,0.90,0.93,0.13),true)
            draw_line(_project(Vector2(r.position.x+100,center_y-120)),_project(Vector2(r.end.x-100,center_y-120)),Color(1,1,1,0.045),4.0)
            draw_line(_project(Vector2(r.position.x+100,center_y+120)),_project(Vector2(r.end.x-100,center_y+120)),Color(1,1,1,0.045),4.0)

        elif style=="wind":
            for i in range(8):
                var base := _project(r.position+Vector2(420+(i%4)*1100,550+(i/4)*1500))
                draw_arc(base,55,0,TAU,28,Color(accent.r,accent.g,accent.b,0.055),2.0,true)
                draw_line(base+Vector2(-40,0),base+Vector2(40,0),Color(accent.r,accent.g,accent.b,0.035),1.0)
                draw_line(base+Vector2(0,-40),base+Vector2(0,40),Color(accent.r,accent.g,accent.b,0.035),1.0)

        elif style=="data":
            for gx in range(0,7):
                for gy in range(0,5):
                    var q := _project(r.position+Vector2(260+gx*720,260+gy*650))
                    draw_rect(Rect2(q-Vector2(18,18),Vector2(36,36)),Color(accent.r,accent.g,accent.b,0.045),false,1.0)
                    if (gx+gy)%3==0:
                        draw_circle(q,3,Color(accent.r,accent.g,accent.b,0.16))

        elif style=="coast":
            for y in range(int(r.position.y)+260,int(r.end.y),360):
                var a := _project(Vector2(r.position.x+80,y))
                var b := _project(Vector2(r.end.x-80,y))
                draw_line(a,b,Color(accent.r,accent.g,accent.b,0.04),2.0)
            for i in range(10):
                var q := _project(r.position+Vector2(240+i*490,520+(i%2)*1200))
                draw_arc(q,26,0,PI,18,Color(0.72,0.88,0.93,0.06),1.5,true)

        elif style=="rail":
            for yoff in [620.0,1180.0,2360.0,2920.0]:
                var a := _project(Vector2(r.position.x+120,r.position.y+yoff))
                var b := _project(Vector2(r.end.x-120,r.position.y+yoff))
                draw_line(a,b,Color(0.60,0.58,0.55,0.10),4.0)
                draw_line(a+Vector2(0,8),b+Vector2(0,8),Color(0.60,0.58,0.55,0.10),4.0)
                for x in range(0,18):
                    var t := float(x)/17.0
                    var c := a.lerp(b,t)
                    draw_line(c+Vector2(0,-5),c+Vector2(0,13),Color(0.43,0.40,0.38,0.08),2.0)

        elif style in ["industry","harbor"]:
            for gx in range(6):
                var q := _project(r.position+Vector2(350+gx*820,420+(gx%2)*1450))
                draw_rect(Rect2(q-Vector2(48,26),Vector2(96,52)),Color(accent.r,accent.g,accent.b,0.025),false,2.0)
                draw_line(q+Vector2(-42,0),q+Vector2(42,0),Color(accent.r,accent.g,accent.b,0.035),1.0)

        elif style=="campus":
            for i in range(10):
                var q := _project(r.position+Vector2(300+(i%5)*920,480+(i/5)*1750))
                draw_circle(q,58,Color(accent.r,accent.g,accent.b,0.035))
                draw_circle(q,20,Color(accent.r,accent.g,accent.b,0.045),false,2.0)

        elif style=="astro":
            for i in range(24):
                var q := _project(r.position+Vector2(160+(i*733)%4700,180+(i*947)%3200))
                draw_circle(q,1.5+(i%3),Color(accent.r,accent.g,accent.b,0.08))

func _draw_water() -> void:
    for w in waters:
        var r: Rect2 = w.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        var tint: Color = w.tint
        draw_rect(Rect2(p,r.size*world_zoom),tint.darkened(0.18))
        var shimmer := Time.get_ticks_msec() / 900.0
        for yy in range(26,int(r.size.y*world_zoom)-20,54):
            var y := p.y + yy
            var phase := shimmer + float(yy) * 0.025
            var start := p.x + 18 + sin(phase) * 12
            draw_line(Vector2(start,y),Vector2(p.x+r.size.x*world_zoom-20,y+sin(phase*1.7)*4),Color(tint.r+0.12,tint.g+0.18,tint.b+0.22,0.24),2.0,true)
        draw_rect(Rect2(p+Vector2(3,3),r.size*world_zoom-Vector2(6,6)),Color(0.55,0.85,1.0,0.10),false,3.0)

func _draw_roads() -> void:
    for road in roads:
        var pts: PackedVector2Array = road.points
        var screen := PackedVector2Array()
        for p in pts:
            screen.append(_project(p))
        draw_polyline(screen, Color("#0e151a"), road.width + 42.0, true)
        draw_polyline(screen, Color("#67737a"), road.width + 24.0, true)
        draw_polyline(screen, Color("#29343b"), road.width, true)
        draw_polyline(screen, Color(1.0,0.88,0.58,0.16), 3.0, true)
        draw_polyline(screen, Color(0.72,0.82,0.85,0.10), maxf(2.0,float(road.width)-20.0), true)
        for k in range(3, 98, 6):
            var t := float(k)/100.0
            var wp := _sample_polyline(pts,t)
            var tan := _polyline_tangent(pts,t)
            var c := _project(wp,1.0)
            draw_line(c-tan*14.0,c+tan*14.0,Color(0.92,0.89,0.72,0.48),3.0,true)
    _draw_junction_overlays()

func _draw_junction_overlays() -> void:
    for j in junctions:
        var wp: Vector2 = Vector2(j.pos)
        if player_pos.distance_to(wp)>1900.0:
            continue
        var p := _project(wp,1.0)
        var wa: float = float(roads[int(j.a)].width)
        var wb: float = float(roads[int(j.b)].width)
        if not bool(j.bridge):
            # True same-level intersection: one unified asphalt plate with lane/crosswalk logic.
            draw_rect(Rect2(p-Vector2(wb*0.52,wa*0.52),Vector2(wb*1.04,wa*1.04)),Color("#2b363d"),true)
            draw_rect(Rect2(p-Vector2(wb*0.52,wa*0.52),Vector2(wb*1.04,wa*1.04)),Color(1,1,1,0.035),false,1.0)
            for k in [-1,1]:
                for n in range(-3,4):
                    draw_rect(Rect2(p+Vector2(float(n)*13-4,float(k)*wa*0.43-3),Vector2(8,6)),Color(0.92,0.92,0.86,0.34),true)
                    draw_rect(Rect2(p+Vector2(float(k)*wb*0.43-3,float(n)*13-4),Vector2(6,8)),Color(0.92,0.92,0.86,0.34),true)
            var a_green: bool = _junction_green(j,int(j.a))
            var b_green: bool = _junction_green(j,int(j.b))
            for corner in [Vector2(-wb*0.43,-wa*0.43),Vector2(wb*0.43,wa*0.43)]:
                draw_circle(p+corner,4,Color("#63e28b") if a_green else Color("#ff665d"))
            for corner in [Vector2(wb*0.43,-wa*0.43),Vector2(-wb*0.43,wa*0.43)]:
                draw_circle(p+corner,4,Color("#63e28b") if b_green else Color("#ff665d"))
        else:
            var over: int = int(j.over)
            var over_vertical: bool = over<10
            var nearest_road := _nearest_road_index(player_pos)
            var under: int = int(j.b) if over==int(j.a) else int(j.a)
            var on_under: bool = nearest_road==under and player_pos.distance_to(wp)<380.0
            # Underpass is deliberately darker. The upper deck fades when player passes underneath.
            if over_vertical:
                draw_rect(Rect2(p-Vector2(wb*0.60,wa*0.55),Vector2(wb*1.20,wa*1.10)),Color(0.08,0.11,0.13,0.62),true)
                draw_rect(Rect2(p-Vector2(wa*0.52,wb*0.70),Vector2(wa*1.04,wb*1.40)),Color(0.34,0.39,0.42,0.42 if on_under else 0.96),true)
                draw_line(p+Vector2(-wa*0.52,-wb*0.70),p+Vector2(-wa*0.52,wb*0.70),Color(0,0,0,0.28),5.0)
                draw_line(p+Vector2(wa*0.52,-wb*0.70),p+Vector2(wa*0.52,wb*0.70),Color(0,0,0,0.28),5.0)
            else:
                draw_rect(Rect2(p-Vector2(wb*0.55,wa*0.60),Vector2(wb*1.10,wa*1.20)),Color(0.08,0.11,0.13,0.62),true)
                draw_rect(Rect2(p-Vector2(wb*0.70,wa*0.52),Vector2(wb*1.40,wa*1.04)),Color(0.34,0.39,0.42,0.42 if on_under else 0.96),true)
                draw_line(p+Vector2(-wb*0.70,-wa*0.52),p+Vector2(wb*0.70,-wa*0.52),Color(0,0,0,0.28),5.0)
                draw_line(p+Vector2(-wb*0.70,wa*0.52),p+Vector2(wb*0.70,wa*0.52),Color(0,0,0,0.28),5.0)

func _nearest_road_index(p: Vector2) -> int:
    var best := INF
    var best_i := -1
    for i in range(roads.size()):
        var d := _distance_to_polyline(p,roads[i].points)
        if d<best:
            best=d
            best_i=i
    return best_i

func _draw_parks() -> void:
    for park in parks:
        var r: Rect2 = park.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        draw_rect(Rect2(p,r.size*world_zoom),Color("#173d2b"))
        var rs := r.size*world_zoom
        var path := PackedVector2Array([p+Vector2(30,rs.y*.28),p+Vector2(rs.x*.32,50),p+Vector2(rs.x*.58,rs.y*.73),p+Vector2(rs.x-40,rs.y*.52)])
        draw_polyline(path,Color(0.85,0.82,0.62,0.20),12.0,true)
        var c := p + rs * 0.5
        draw_string(ThemeDB.fallback_font,c+Vector2(-95,-70),park.name,HORIZONTAL_ALIGNMENT_CENTER,190,17,Color("#d9efe3"))


func _draw_buildings() -> void:
    for b in buildings:
        var r: Rect2 = b.rect
        if not _world_rect_visible(r.grow(260)):
            continue
        var z: float = b.height
        var base := [_project(r.position),_project(Vector2(r.end.x,r.position.y)),_project(r.end),_project(Vector2(r.position.x,r.end.y))]
        var top := [_project(r.position,z),_project(Vector2(r.end.x,r.position.y),z),_project(r.end,z),_project(Vector2(r.position.x,r.end.y),z)]
        var roof_poly := PackedVector2Array([top[0],top[1],top[2],top[3]])
        var shadow_shift := view_amount * z * 0.22 + Vector2(8,12)
        draw_colored_polygon(PackedVector2Array([base[0]+shadow_shift,base[1]+shadow_shift,base[2]+shadow_shift,base[3]+shadow_shift]),Color(0,0,0,0.16))
        for edge in range(4):
            var next := (edge+1)%4
            var face := PackedVector2Array([base[edge],base[next],top[next],top[edge]])
            var shade := 0.12 + 0.09 * float(edge)
            var fc: Color = b.wall.darkened(shade)
            fc.a = 0.95
            draw_colored_polygon(face,fc)
            _draw_facade_face(b,base[edge],base[next],top[next],top[edge],edge)
        draw_colored_polygon(roof_poly,b.roof)
        var glow: Color = b.accent
        glow.a = 0.11 + minf(0.22,view_amount.length()*0.16)
        draw_polyline(PackedVector2Array([top[0],top[1],top[2],top[3],top[0]]),Color(1,1,1,0.12),1.2,true)
        draw_polyline(PackedVector2Array([top[0],top[1],top[2],top[3],top[0]]),glow,4.2,true)
        _draw_roof_detail(b,top)
        _draw_massing_detail(b,top)

func _draw_facade_face(b: Dictionary, a: Vector2, bb: Vector2, c: Vector2, d: Vector2, edge: int) -> void:
    var height_vec := d-a
    if height_vec.length() < 5.0:
        return
    var floors: int = int(b.get("floors",4))
    var face_len := a.distance_to(bb)
    var cols := 4
    if face_len > 220.0:
        cols = 6
    elif face_len < 110.0:
        cols = 3
    var face_alpha := clampf(height_vec.length()/70.0,0.0,1.0)
    var facade := str(b.get("facade","windows"))
    var window_color := Color("#ffdca0") if b.style in ["heritage","harbor","terminal"] else Color("#9cddff")
    if b.style == "neon":
        window_color = b.accent.lightened(0.12)
    window_color.a = 0.18 + face_alpha*0.25
    var max_rows := mini(floors,8)
    for fy in range(1,max_rows):
        var v := float(fy)/float(max_rows)
        draw_line(a.lerp(d,v),bb.lerp(c,v),Color(1,1,1,0.045),1.0)
    for row in range(1,mini(floors,7)):
        var v0 := float(row)/float(mini(floors,7)+1)
        for col in range(cols):
            if (int(b.seed) + row*7 + col*13 + edge*17) % 6 == 0:
                continue
            var u := (float(col)+0.5)/float(cols)
            var center := _quad_bilerp(a,bb,c,d,u,v0)
            var along := (bb-a).normalized() * clampf(face_len / float(cols) * 0.18,5.0,10.0)
            var up := (d-a).normalized() * 3.5
            if facade == "striped":
                draw_line(center-along,center+along,window_color,2.8)
            elif facade == "balconies":
                var balcony_color := Color(window_color.r,window_color.g,window_color.b,0.10)
                var bp := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(bp,balcony_color)
                draw_line(center-along*1.15+up,center+along*1.15+up,Color(1,1,1,0.12),1.1)
            else:
                var wpoly := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(wpoly,window_color)
                if facade == "mixed" and (row+col+edge+int(b.seed)) % 3 == 0:
                    draw_line(center-along*0.8,center+along*0.8,Color(1,1,1,0.12),1.0)
    if b.style == "heritage":
        var sill := a.lerp(d,0.18)
        draw_line(sill,bb.lerp(c,0.18),Color("#e5b889"),2.0)
        draw_line(a.lerp(d,0.72),bb.lerp(c,0.72),Color(0.95,0.76,0.58,0.11),2.0)
    elif b.style in ["glass","center"]:
        for u_i in range(1,4):
            var uu := float(u_i)/4.0
            draw_line(a.lerp(bb,uu),d.lerp(c,uu),Color(0.65,0.90,1.0,0.10+face_alpha*0.08),1.5)
    elif b.style == "neon":
        draw_line(a.lerp(d,0.55),bb.lerp(c,0.55),Color(b.accent.r,b.accent.g,b.accent.b,0.55),2.5)
    elif b.style in ["green","garden"]:
        draw_line(a.lerp(d,0.32),bb.lerp(c,0.32),Color(0.48,0.83,0.55,0.34),3.0)

func _draw_roof_detail(b: Dictionary, top: Array) -> void:
    var center: Vector2 = (top[0]+top[1]+top[2]+top[3])/4.0
    var style: String = b.style
    var roof_mode: String = str(b.get("roof_mode","flat"))
    if style == "heritage" or roof_mode == "pitched":
        var ridge_a: Vector2 = Vector2(top[0]).lerp(Vector2(top[3]),0.5)
        var ridge_b: Vector2 = Vector2(top[1]).lerp(Vector2(top[2]),0.5)
        draw_line(ridge_a,ridge_b,Color(1.0,0.82,0.61,0.24),3.0,true)
        draw_circle(center,6,Color("#b78d70"))
    if style in ["glass","center"] or roof_mode == "utility":
        draw_rect(Rect2(center-Vector2(15,8),Vector2(30,16)),Color(0.48,0.77,0.88,0.22),true)
        draw_line(center,center+Vector2(0,-22),Color(b.accent.r,b.accent.g,b.accent.b,0.45),2.0,true)
        draw_circle(center+Vector2(0,-24),3.5,Color(b.accent.r,b.accent.g,b.accent.b,0.7))
    if style == "solar" or roof_mode == "solar":
        for ix in [-1,0,1]:
            var q := center + Vector2(ix*18,-3)
            draw_rect(Rect2(q-Vector2(7,5),Vector2(14,10)),Color(0.16,0.30,0.38,0.9),true)
            draw_rect(Rect2(q-Vector2(7,5),Vector2(14,10)),Color("#f1e36f"),false,1.0)
    if style in ["green","garden"] or roof_mode == "garden":
        draw_circle(center+Vector2(-12,0),9,Color(0.28,0.58,0.34,0.75))
        draw_circle(center+Vector2(11,2),8,Color(0.35,0.68,0.40,0.72))
        draw_rect(Rect2(center+Vector2(-4,-12),Vector2(8,24)),Color(0.58,0.44,0.29,0.55),true)
    if style == "harbor":
        draw_rect(Rect2(center-Vector2(18,7),Vector2(36,14)),Color(0.16,0.20,0.22,0.85),true)
        draw_line(center+Vector2(15,-3),center+Vector2(15,-22),Color("#ffb66f"),2.0)
    elif style == "neon":
        draw_line(top[0].lerp(top[1],0.18),top[3].lerp(top[2],0.18),Color(b.accent.r,b.accent.g,b.accent.b,0.58),3.0,true)
        draw_line(top[0].lerp(top[3],0.78),top[1].lerp(top[2],0.78),Color(0.45,0.78,1.0,0.42),2.0,true)
    elif style == "campus":
        draw_rect(Rect2(center-Vector2(18,10),Vector2(36,20)),Color(0.55,0.74,0.94,0.22),true)
        draw_rect(Rect2(center-Vector2(18,10),Vector2(36,20)),Color("#b0c8ff"),false,1.0)
    elif style == "astro":
        draw_circle(center,15,Color(0.33,0.30,0.55,0.95))
        draw_arc(center,15,PI,TAU,18,Color("#c3a6ff"),2.0,true)
    elif style == "terminal":
        for ix in range(-2,3):
            draw_line(center+Vector2(ix*11,-12),center+Vector2(ix*11,12),Color(0.75,0.83,0.88,0.20),2.0)

func _draw_massing_detail(b: Dictionary, top: Array) -> void:
    var mode: String = str(b.get("massing","slab"))
    var center: Vector2 = (top[0]+top[1]+top[2]+top[3])/4.0
    if mode == "slab":
        return
    var inset: float = 0.26 if mode=="tower" else 0.18
    var base := PackedVector2Array([
        top[0].lerp(center,inset),
        top[1].lerp(center,inset),
        top[2].lerp(center,inset),
        top[3].lerp(center,inset)
    ])
    if mode == "courtyard":
        var hole := PackedVector2Array([
            top[0].lerp(center,0.58),top[1].lerp(center,0.58),
            top[2].lerp(center,0.58),top[3].lerp(center,0.58)
        ])
        draw_colored_polygon(hole,Color(0.04,0.07,0.08,0.55))
        draw_polyline(PackedVector2Array([hole[0],hole[1],hole[2],hole[3],hole[0]]),Color(1,1,1,0.08),1.2,true)
        return
    var extra_h: float = 28.0 if mode=="terrace" else 48.0
    var shift: Vector2 = view_amount * extra_h * parallax_strength * 0.72
    var cap: PackedVector2Array = PackedVector2Array([base[0]+shift,base[1]+shift,base[2]+shift,base[3]+shift])
    var shade: Color = Color(b.wall).darkened(0.20)
    draw_colored_polygon(PackedVector2Array([base[1],base[2],cap[2],cap[1]]),shade)
    draw_colored_polygon(PackedVector2Array([base[2],base[3],cap[3],cap[2]]),shade.darkened(0.12))
    draw_colored_polygon(cap,b.roof.lightened(0.06))
    draw_polyline(PackedVector2Array([cap[0],cap[1],cap[2],cap[3],cap[0]]),Color(b.accent.r,b.accent.g,b.accent.b,0.28),2.0,true)
    if mode == "terrace":
        draw_circle((cap[0]+cap[2])/2.0,6,Color(0.30,0.62,0.36,0.72))
    else:
        draw_line((cap[0]+cap[3])/2.0,(cap[0]+cap[3])/2.0+Vector2(0,-18),Color(b.accent.r,b.accent.g,b.accent.b,0.45),2.0,true)

func _quad_bilerp(a: Vector2, b: Vector2, c: Vector2, d: Vector2, u: float, v: float) -> Vector2:
    return a.lerp(b,u).lerp(d.lerp(c,u),v)

func _draw_landmarks() -> void:
    for l in landmarks:
        var r := _landmark_rect(l)
        if not _world_rect_visible(r.grow(350)):
            continue
        var center: Vector2 = Vector2(l.pos)
        var kind := str(l.kind)
        var h: float = l.h
        var base := _project(center,0)
        var top := _project(center,h)
        var accent: Color = l.accent
        _draw_poly_ellipse(base+Vector2(8,14),Vector2(l.size.x*0.34,l.size.y*0.25),0.0,Color(0,0,0,0.18))
        if kind == "clock":
            _draw_landmark_tower(base,top,accent,true)
        elif kind == "openai_hq":
            _draw_landmark_openai(l,base,top,accent)
        elif kind == "crystal":
            _draw_landmark_crystal(base,top,accent)
        elif kind in ["greenhouse","conservatory"]:
            _draw_landmark_greenhouse(base,top,accent,l.size)
        elif kind == "solar_beacon":
            _draw_landmark_solar(base,top,accent)
        elif kind == "rotunda":
            _draw_landmark_rotunda(base,top,accent)
        elif kind == "civic":
            _draw_landmark_tower(base,top,accent,false)
        elif kind == "crane":
            _draw_landmark_crane(base,top,accent)
        elif kind == "theatre":
            _draw_landmark_theatre(base,top,accent)
        elif kind == "library":
            _draw_landmark_library(base,top,accent)
        elif kind == "observatory":
            _draw_landmark_observatory(base,top,accent)
        else:
            _draw_landmark_terminal(base,top,accent)
        draw_string(ThemeDB.fallback_font,base+Vector2(-110,52),str(l.name),HORIZONTAL_ALIGNMENT_CENTER,220,16,Color(0.93,0.98,1.0,0.80))

func _draw_landmark_openai(l: Dictionary, base: Vector2, top: Vector2, accent: Color) -> void:
    # Stylized in-game interpretation: twin glass volumes joined by a luminous skybridge.
    var spread := 92.0
    var left_base := base+Vector2(-spread,18)
    var right_base := base+Vector2(spread,18)
    var left_top := top+Vector2(-spread,14)
    var right_top := top+Vector2(spread,14)
    var glass := Color("#bddde8")
    var side_col := Color("#334b57")
    var lt := PackedVector2Array([left_base+Vector2(-48,26),left_base+Vector2(48,26),left_top+Vector2(38,10),left_top+Vector2(-38,10)])
    var rt := PackedVector2Array([right_base+Vector2(-48,26),right_base+Vector2(48,26),right_top+Vector2(38,10),right_top+Vector2(-38,10)])
    draw_colored_polygon(lt,side_col)
    draw_colored_polygon(rt,side_col.lightened(0.04))
    for k in range(1,7):
        var v := float(k)/7.0
        draw_line(lt[0].lerp(lt[3],v),lt[1].lerp(lt[2],v),Color(glass.r,glass.g,glass.b,0.34),2.0)
        draw_line(rt[0].lerp(rt[3],v),rt[1].lerp(rt[2],v),Color(glass.r,glass.g,glass.b,0.34),2.0)
    for k in range(1,4):
        var u := float(k)/4.0
        draw_line(lt[0].lerp(lt[1],u),lt[3].lerp(lt[2],u),Color(1,1,1,0.12),1.0)
        draw_line(rt[0].lerp(rt[1],u),rt[3].lerp(rt[2],u),Color(1,1,1,0.12),1.0)
    var bridge_y := top.lerp(base,0.44).y
    var bridge := Rect2(base.x-spread+34,bridge_y-13,(spread*2)-68,26)
    draw_rect(bridge,Color(0.44,0.74,0.84,0.24),true)
    draw_rect(bridge,Color(0.82,0.94,0.97,0.64),false,2.0)
    draw_line(Vector2(bridge.position.x,bridge.position.y+8),Vector2(bridge.end.x,bridge.position.y+8),Color(1,1,1,0.16),1.0)
    # Public visitor entrance/plaza.
    draw_rect(Rect2(base+Vector2(-64,34),Vector2(128,34)),Color(0.04,0.08,0.10,0.88),true)
    draw_rect(Rect2(base+Vector2(-64,34),Vector2(128,34)),Color(0.88,0.96,0.97,0.42),false,2.0)
    draw_string(ThemeDB.fallback_font,base+Vector2(-54,44),"OPENAI HQ",HORIZONTAL_ALIGNMENT_CENTER,108,14,Color("#f2f7f7"))
    var emblem := base+Vector2(0,21)
    draw_circle(emblem,10,Color(0.96,0.98,0.98,0.10))
    draw_arc(emblem,10,0,TAU,20,Color("#f2f7f7"),1.7,true)
    draw_arc(emblem,6,0.6,5.7,18,Color("#f2f7f7"),1.3,true)

func _draw_landmark_tower(base: Vector2, top: Vector2, accent: Color, clock: bool) -> void:
    var w := 54.0
    var body := PackedVector2Array([base+Vector2(-w,18),base+Vector2(w,18),top+Vector2(w*0.65,10),top+Vector2(-w*0.65,10)])
    draw_colored_polygon(body,accent.darkened(0.48))
    draw_polyline(PackedVector2Array([body[0],body[1],body[2],body[3],body[0]]),Color(accent.r,accent.g,accent.b,0.62),2.2,true)
    draw_line(top+Vector2(-35,10),top+Vector2(35,10),Color(1,1,1,0.18),2.0)
    if clock:
        draw_circle(top+Vector2(0,28),15,Color("#f4ead0"))
        draw_circle(top+Vector2(0,28),15,Color(accent.r,accent.g,accent.b,0.8),false,2.0)
        draw_line(top+Vector2(0,28),top+Vector2(0,17),Color("#3d3b35"),2.0)
        draw_line(top+Vector2(0,28),top+Vector2(9,28),Color("#3d3b35"),2.0)
    draw_line(top,top+Vector2(0,-36),accent,3.0,true)

func _draw_landmark_crystal(base: Vector2, top: Vector2, accent: Color) -> void:
    var pts := PackedVector2Array([top+Vector2(0,-35),base+Vector2(95,30),base+Vector2(0,55),base+Vector2(-95,30)])
    draw_colored_polygon(pts,Color(accent.r,accent.g,accent.b,0.24))
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),accent,3.0,true)
    draw_line(pts[0],pts[2],Color(0.8,0.96,1.0,0.38),2.0)
    draw_line(pts[3],pts[1],Color(0.8,0.96,1.0,0.22),2.0)

func _draw_landmark_greenhouse(base: Vector2, top: Vector2, accent: Color, size: Vector2) -> void:
    var w := size.x*0.30
    var h := 65.0
    draw_rect(Rect2(base-Vector2(w,h*0.5),Vector2(w*2,h)),Color(0.30,0.68,0.52,0.18),true)
    draw_rect(Rect2(base-Vector2(w,h*0.5),Vector2(w*2,h)),Color(accent.r,accent.g,accent.b,0.72),false,2.0)
    for k in range(-3,4):
        draw_line(base+Vector2(float(k)*w/3.5,-h*0.5),base+Vector2(float(k)*w/3.5,h*0.5),Color(0.78,0.96,0.91,0.20),1.0)
    draw_arc(base+Vector2(0,-h*0.5),w*0.45,PI,TAU,20,accent,2.0,true)
    draw_circle(base+Vector2(-35,4),14,Color(0.30,0.68,0.38,0.70))
    draw_circle(base+Vector2(22,9),18,Color(0.36,0.74,0.43,0.68))

func _draw_landmark_solar(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_line(base,top,Color("#606970"),9.0,true)
    for k in range(4):
        var yy := top.lerp(base,float(k+1)/5.0)
        draw_line(yy+Vector2(-65,0),yy+Vector2(65,0),Color(accent.r,accent.g,accent.b,0.72),5.0,true)
    draw_circle(top,18,accent)
    draw_circle(top,38,Color(accent.r,accent.g,accent.b,0.10))

func _draw_landmark_rotunda(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_circle(base,68,accent.darkened(0.50))
    draw_circle(base,68,Color(accent.r,accent.g,accent.b,0.58),false,3.0)
    for a in range(0,360,45):
        var d := Vector2.from_angle(deg_to_rad(float(a)))
        draw_line(base+d*42,top+d*28,Color(accent.r,accent.g,accent.b,0.62),3.0)
    draw_circle(top,38,Color(accent.r,accent.g,accent.b,0.25))
    draw_arc(top,38,PI,TAU,24,accent,3.0,true)

func _draw_landmark_crane(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_rect(Rect2(base-Vector2(95,35),Vector2(190,70)),Color("#403b38"),true)
    draw_line(base+Vector2(-62,-35),top+Vector2(-62,0),Color("#7a6759"),6.0,true)
    draw_line(top+Vector2(-62,0),top+Vector2(85,0),accent,5.0,true)
    draw_line(top+Vector2(60,0),top+Vector2(60,62),Color("#9d8b7c"),2.0)
    draw_rect(Rect2(top+Vector2(52,62),Vector2(16,12)),accent.darkened(0.25),true)

func _draw_landmark_theatre(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_rect(Rect2(base-Vector2(105,60),Vector2(210,120)),Color("#342244"),true)
    draw_rect(Rect2(base-Vector2(105,60),Vector2(210,120)),accent,false,3.0)
    for k in range(-3,4):
        draw_line(base+Vector2(float(k)*25,-40),base+Vector2(float(k)*25,25),Color(accent.r,accent.g,accent.b,0.34),5.0)
    draw_line(top+Vector2(-55,0),top+Vector2(55,0),accent,7.0,true)
    draw_circle(top+Vector2(0,-12),15,Color(1.0,0.55,0.94,0.18))

func _draw_landmark_library(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_rect(Rect2(base-Vector2(110,45),Vector2(220,90)),accent.darkened(0.55),true)
    for k in range(-4,5):
        draw_line(base+Vector2(float(k)*22,-42),base+Vector2(float(k)*22,35),Color(accent.r,accent.g,accent.b,0.35),3.0)
    draw_line(top+Vector2(-95,0),top+Vector2(95,0),accent,5.0,true)

func _draw_landmark_observatory(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_circle(base,78,Color("#353254"))
    draw_arc(base,78,PI,TAU,30,accent,4.0,true)
    draw_circle(top,44,Color(0.34,0.31,0.58,0.94))
    draw_arc(top,44,PI,TAU,28,accent,3.0,true)
    draw_line(top,top+Vector2(65,-45),Color("#8b8fae"),5.0,true)
    draw_circle(top+Vector2(67,-47),7,accent)

func _draw_landmark_terminal(base: Vector2, top: Vector2, accent: Color) -> void:
    draw_rect(Rect2(base-Vector2(120,52),Vector2(240,104)),Color("#485057"),true)
    for k in range(-5,6):
        draw_line(base+Vector2(float(k)*20,-50),top+Vector2(float(k)*11,0),Color(accent.r,accent.g,accent.b,0.32),3.0,true)
    draw_line(top+Vector2(-75,0),top+Vector2(75,0),accent,5.0,true)

func _draw_storefronts() -> void:
    for st in storefronts:
        if player_pos.distance_to(st.pos)>1650.0:
            continue
        var c := _project(st.pos,6)
        var accent: Color = st.accent
        draw_rect(Rect2(c-Vector2(30,13),Vector2(60,26)),Color(0.04,0.08,0.10,0.90),true)
        draw_rect(Rect2(c-Vector2(30,13),Vector2(60,26)),Color(accent.r,accent.g,accent.b,0.62),false,2.0)
        var icon := "R" if st.kind=="restaurant" else ("C" if st.kind=="cafe" else ("S" if st.kind=="shop" else ("G" if st.kind=="garage" else "W")))
        draw_circle(c+Vector2(-20,0),7,accent)
        draw_string(ThemeDB.fallback_font,c+Vector2(-23,-5),icon,HORIZONTAL_ALIGNMENT_CENTER,8,9,Color("#102028"))
        draw_string(ThemeDB.fallback_font,c+Vector2(-10,-5),str(st.name),HORIZONTAL_ALIGNMENT_LEFT,52,9,Color.WHITE)
        if st.kind in ["garage","workshop"]:
            draw_line(c+Vector2(-18,13),c+Vector2(-18,24),Color("#7d8a90"),2.0)
            draw_line(c+Vector2(18,13),c+Vector2(18,24),Color("#7d8a90"),2.0)
            draw_line(c+Vector2(-18,24),c+Vector2(18,24),accent,2.0)
        elif st.kind in ["restaurant","cafe"]:
            draw_circle(c+Vector2(-10,23),5,Color("#5f4b3e"))
            draw_circle(c+Vector2(10,23),5,Color("#5f4b3e"))

func _draw_vegetation_props() -> void:
    for v in vegetation_props:
        if player_pos.distance_to(v.pos)>1700.0:
            continue
        var c := _project(v.pos,4)
        var tint: Color = v.tint
        var sway := sin(Time.get_ticks_msec()/800.0+float(v.phase))*1.4
        if v.kind=="planter":
            draw_rect(Rect2(c-Vector2(10,5),Vector2(20,10)),Color("#6d5945"),true)
            draw_circle(c+Vector2(-5+sway,-7),7,tint)
            draw_circle(c+Vector2(5+sway,-8),6,tint.lightened(0.08))
        elif v.kind=="flowerbed":
            _draw_poly_ellipse(c,Vector2(16,8),0.0,Color(0.25,0.47,0.28,0.65))
            for k in range(5):
                var ang := float(k)/5.0*TAU
                var p := c+Vector2(cos(ang)*9,sin(ang)*4)
                draw_circle(p,2.2,[Color("#ff9fc1"),Color("#f0d36d"),Color("#9cc9ff")][k%3])
        else:
            draw_circle(c,10,tint.darkened(0.15))
            draw_circle(c+Vector2(-4,-4),6,tint.lightened(0.10))

func _draw_trees() -> void:
    for t in trees:
        if player_pos.distance_to(t.pos) > 1800.0:
            continue
        var b := _project(t.pos,0)
        var c := _project(t.pos,t.h)
        var sway := sin(Time.get_ticks_msec()/900.0 + float(t.get("phase",0.0))) * 2.0
        c.x += sway
        draw_line(b,c,Color("#604b35"),4.0,true)
        var species := str(t.get("species","broadleaf"))
        draw_circle(c+Vector2(3,6),t.r*1.08,Color(0,0,0,0.16))
        if species == "pine":
            var col: Color = t.tint.darkened(0.24)
            for k in range(3):
                var yy := float(k)*8.0
                var rr: float = float(t.r)*(1.0-float(k)*0.18)
                var pts := PackedVector2Array([c+Vector2(0,-rr-yy),c+Vector2(rr,rr*0.55-yy),c+Vector2(-rr,rr*0.55-yy)])
                draw_colored_polygon(pts,col.lightened(float(k)*0.05))
        elif species == "cypress":
            _draw_poly_ellipse(c,Vector2(t.r*0.55,t.r*1.55),0.0,t.tint.darkened(0.18))
            _draw_poly_ellipse(c+Vector2(-2,-7),Vector2(t.r*0.32,t.r*1.1),0.0,t.tint.lightened(0.07))
        elif species == "palm":
            draw_line(c,c+Vector2(0,-18),Color("#806342"),3.0,true)
            var crown := c+Vector2(0,-21)
            for a in range(0,360,45):
                var dir := Vector2.from_angle(deg_to_rad(float(a)))
                draw_line(crown,crown+dir*t.r*1.3,t.tint,4.0,true)
        elif species == "birch":
            draw_line(b,c,Color("#d7d0bc"),4.0,true)
            for off in [Vector2(-6,-4),Vector2(4,-8),Vector2(8,3),Vector2(-9,5)]:
                draw_circle(c+off,t.r*0.60,t.tint.lightened(0.08))
        else:
            draw_circle(c,t.r,t.tint.darkened(0.2))
            draw_circle(c+Vector2(-5,-5),t.r*0.62,t.tint.lightened(0.12))
            draw_circle(c+Vector2(7,-1),t.r*0.48,t.tint)

func _draw_named_npcs() -> void:
    for npc in named_npcs:
        if player_pos.distance_to(Vector2(npc.pos))>1700.0:
            continue
        var p := _project(Vector2(npc.pos),16)
        var accent: Color = npc.accent
        draw_circle(p+Vector2(3,8),8,Color(0,0,0,0.18))
        draw_line(p+Vector2(0,3),p+Vector2(0,15),accent,5.0,true)
        draw_circle(p,5,Color("#e8ba96"))
        draw_arc(p+Vector2(0,-1),5.1,PI,TAU,12,accent.darkened(0.55),2.2,true)
        draw_circle(p+Vector2(0,-16),5,Color(accent.r,accent.g,accent.b,0.28))
        draw_string(ThemeDB.fallback_font,p+Vector2(-45,-28),str(npc.name),HORIZONTAL_ALIGNMENT_CENTER,90,11,Color.WHITE)

func _draw_story_collectibles() -> void:
    for c in caches:
        if bool(c.taken) or player_pos.distance_to(Vector2(c.pos))>1700.0:
            continue
        var p := _project(Vector2(c.pos),12)
        draw_rect(Rect2(p-Vector2(12,8),Vector2(24,16)),Color("#253941"),true)
        draw_rect(Rect2(p-Vector2(12,8),Vector2(24,16)),Color("#73f3ce"),false,2.0)
        draw_circle(p,3,Color("#73f3ce"))
    for g in glyphs:
        if bool(g.taken) or player_pos.distance_to(Vector2(g.pos))>1700.0:
            continue
        var q := _project(Vector2(g.pos),18)
        var pts := PackedVector2Array([q+Vector2(0,-12),q+Vector2(10,0),q+Vector2(0,12),q+Vector2(-10,0)])
        draw_colored_polygon(pts,Color(0.48,0.72,1.0,0.14))
        draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color("#a8c7ff"),2.0,true)

func _talk_named_npc(index: int) -> void:
    if index<0 or index>=named_npcs.size():
        return
    active_dialogue_npc=index
    var npc: Dictionary = named_npcs[index]
    dialogue_title.text="%s · %s" % [str(npc.name),str(npc.role)]
    dialogue_body.text=str(npc.text)
    for child in dialogue_actions.get_children():
        child.queue_free()
    var mission_btn := _commerce_button("MISSION BESPRECHEN",_dialogue_mission)
    var contract_btn := _commerce_button("PERSÖNLICHER AUFTRAG",_dialogue_contract)
    var city_btn := _commerce_button("ÜBER DIE STADT",_dialogue_city)
    var close_btn := _commerce_button("GESPRÄCH BEENDEN",_close_dialogue)
    dialogue_actions.add_child(mission_btn)
    dialogue_actions.add_child(contract_btn)
    dialogue_actions.add_child(city_btn)
    dialogue_actions.add_child(close_btn)
    dialogue_panel.visible=true
    move_vec=Vector2.ZERO

func _dialogue_mission() -> void:
    if active_dialogue_npc<0 or active_dialogue_npc>=named_npcs.size():
        return
    var npc: Dictionary = named_npcs[active_dialogue_npc]
    var id := str(npc.id)
    var hint: String = str({
        "mira":"Caches reagieren auf die Perspektive. Nutze Karte, Scan und Seitenblick gemeinsam.",
        "nova":"Die Hafenrouten verbinden Caches, Jobboards und Sublevel-Knoten.",
        "luna":"Am Solar Grid brauchst du saubere Leitungsorientierung und Geduld an den Kreuzungen.",
        "iris":"Nach dem Firewall-Hack lohnt sich ein Blick in die Bio-Sublevels.",
        "vio":"Der Cipher Gate Code gibt nur Positionsfeedback. Jede Vermutung sollte Information gewinnen.",
        "bram":"Busse und Trams halten nur kurz. Steig am markierten Halt ein und erst am nächsten wieder aus."
    }.get(id,"Erkunde die markierten POIs und verknüpfe ihre Hinweise."))
    dialogue_body.text=str(hint)
    if not bool(npc_flags.get(id,false)):
        npc_flags[id]=true
        npc_trust[id]=int(npc_trust.get(id,0))+1
        credits+=12
        _play_sfx("collect")
        _save_game()
        _advance_native_chapter()

func _dialogue_contract() -> void:
    if active_dialogue_npc<0 or active_dialogue_npc>=named_npcs.size():
        return
    var npc: Dictionary = named_npcs[active_dialogue_npc]
    var id := str(npc.id)
    if bool(npc_contracts_done.get(id,false)):
        dialogue_body.text="%s: Den persönlichen Auftrag hast du bereits abgeschlossen. Vertrauen %d." % [str(npc.name),int(npc_trust.get(id,0))]
        return
    if not active_npc_contract.is_empty() and str(active_npc_contract.get("npc",""))!=id:
        dialogue_body.text="Du hast bereits einen persönlichen Auftrag von %s aktiv." % str(active_npc_contract.get("npc_name","jemand anderem"))
        return
    if active_npc_contract.is_empty():
        active_npc_contract=_make_npc_contract(id,str(npc.name))
        _save_game()
    dialogue_body.text=_contract_description(active_npc_contract)

func _make_npc_contract(id: String, npc_name: String) -> Dictionary:
    if id=="mira":
        return {"npc":id,"npc_name":npc_name,"kind":"cache","start":cache_count,"goal":2,"reward":85,"title":"Miras verlorene Archive","target":Vector2.ZERO}
    if id=="nova":
        return {"npc":id,"npc_name":npc_name,"kind":"visit","start":0,"goal":1,"reward":95,"title":"Novas Hafenroute","target":Vector2(7550,12600)}
    if id=="luna":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"gridRepair","goal":1,"reward":110,"title":"Lunas Grid-Diagnose","target":Vector2(23100,1750)}
    if id=="iris":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"firewall","goal":1,"reward":125,"title":"Iris Firewall-Audit","target":Vector2(12650,12650)}
    if id=="vio":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"cipherGate","goal":1,"reward":105,"title":"Vios Cipher Challenge","target":Vector2(23600,8700)}
    if id=="bram":
        return {"npc":id,"npc_name":npc_name,"kind":"transit","start":transit_trip_count,"goal":1,"reward":75,"title":"Brams Liniencheck","target":Vector2(23200,5400)}
    return {"npc":id,"npc_name":npc_name,"kind":"visit","goal":1,"reward":70,"title":"Persönlicher Auftrag","target":Vector2(player_pos)}

func _contract_description(c: Dictionary) -> String:
    if c.is_empty():
        return "Kein persönlicher Auftrag aktiv."
    var kind := str(c.kind)
    if kind=="cache":
        return "%s: Berge %d zusätzliche Daten-Caches. Belohnung %d CR." % [str(c.title),int(c.goal),int(c.reward)]
    if kind=="visit":
        return "%s: Erreiche den markierten Zielpunkt. Belohnung %d CR." % [str(c.title),int(c.reward)]
    if kind=="hack":
        return "%s: Schließe das markierte Hacking-Terminal ab. Belohnung %d CR." % [str(c.title),int(c.reward)]
    if kind=="transit":
        return "%s: Fahre mindestens eine Station mit Bus oder Tram. Belohnung %d CR." % [str(c.title),int(c.reward)]
    return str(c.title)

func _npc_contract_target() -> Vector2:
    if active_npc_contract.is_empty():
        return Vector2.ZERO
    var kind := str(active_npc_contract.kind)
    if kind=="cache":
        for ca in caches:
            if not bool(ca.taken):
                return Vector2(ca.pos)
    return Vector2(active_npc_contract.get("target",Vector2.ZERO))

func _check_npc_contract() -> void:
    if active_npc_contract.is_empty():
        return
    var kind := str(active_npc_contract.kind)
    var complete := false
    if kind=="cache":
        complete=(cache_count-int(active_npc_contract.get("start",0)))>=int(active_npc_contract.goal)
    elif kind=="visit":
        var target := Vector2(active_npc_contract.get("target",Vector2.ZERO))
        complete=target!=Vector2.ZERO and player_pos.distance_to(target)<120.0
    elif kind=="hack":
        complete=bool(hack_done.get(str(active_npc_contract.get("hack","")),false))
    elif kind=="transit":
        complete=(transit_trip_count-int(active_npc_contract.get("start",0)))>=int(active_npc_contract.goal)
    if not complete:
        return
    var id := str(active_npc_contract.npc)
    var reward := int(active_npc_contract.reward)
    credits+=reward
    npc_trust[id]=int(npc_trust.get(id,0))+2
    npc_contracts_done[id]=true
    _play_sfx("secret")
    _notify("%s abgeschlossen · +%d CR · Vertrauen gestiegen" % [str(active_npc_contract.title),reward])
    active_npc_contract={}
    _save_game()

func _dialogue_city() -> void:
    if active_dialogue_npc<0 or active_dialogue_npc>=named_npcs.size():
        return
    var npc: Dictionary = named_npcs[active_dialogue_npc]
    dialogue_body.text="%s: In %s ändern Höhe, Verkehr, Gebäude und POIs den Rhythmus. Die Karte zeigt dir die wichtigsten Ebenen." % [str(npc.name),current_district]

func _close_dialogue() -> void:
    dialogue_panel.visible=false
    active_dialogue_npc=-1

func _draw_scan_points() -> void:
    for sp in scan_points:
        if bool(sp.taken) or player_pos.distance_to(Vector2(sp.pos))>1200.0:
            continue
        var distance: float = player_pos.distance_to(Vector2(sp.pos))
        var visible: bool = scan_time>0.0 or distance<95.0
        if not visible:
            continue
        var p := _project(Vector2(sp.pos),10)
        var flicker := 0.6+0.4*sin(Time.get_ticks_msec()/120.0+float(sp.pos.x)*0.003)
        draw_rect(Rect2(p-Vector2(11,9),Vector2(22,18)),Color(0.30,0.70,0.95,0.05+0.09*flicker),true)
        draw_rect(Rect2(p-Vector2(11,9),Vector2(22,18)),Color(0.48,0.84,1.0,0.55+0.35*flicker),false,1.5)
        draw_line(p+Vector2(-6,0),p+Vector2(6,0),Color("#78d8ff"),2.0)
        draw_line(p+Vector2(0,-5),p+Vector2(0,5),Color("#78d8ff"),2.0)
        if distance<180.0:
            draw_string(ThemeDB.fallback_font,p+Vector2(-65,-28),"SCAN SIGNAL",HORIZONTAL_ALIGNMENT_CENTER,130,10,Color("#ccefff"))

func _draw_photo_points() -> void:
    for ph in photo_points:
        if bool(ph.taken) or player_pos.distance_to(Vector2(ph.pos))>1750.0:
            continue
        var p := _project(Vector2(ph.pos),20)
        var pulse: float = 1.0+sin(Time.get_ticks_msec()/260.0+float(ph.pos.x)*0.001)*0.12
        draw_circle(p,14.0*pulse,Color(1.0,0.55,0.86,0.05))
        draw_arc(p,14.0*pulse,0,TAU,26,Color("#ff9fdd"),2.0,true)
        draw_arc(p,8.0*pulse,-1.0,1.0,12,Color("#f2f8ff"),2.0,true)
        if player_pos.distance_to(Vector2(ph.pos))<180.0:
            draw_string(ThemeDB.fallback_font,p+Vector2(-90,-30),str(ph.label),HORIZONTAL_ALIGNMENT_CENTER,180,12,Color.WHITE)
            draw_string(ThemeDB.fallback_font,p+Vector2(-90,34),"PHOTO CHALLENGE STARTEN",HORIZONTAL_ALIGNMENT_CENTER,180,10,Color("#ffcf8a"))

func _draw_transit_stops() -> void:
    for st in transit_stops:
        if player_pos.distance_to(Vector2(st.pos))>1700.0:
            continue
        var c := _project(Vector2(st.pos),6)
        draw_line(c,c+Vector2(0,-28),Color("#697980"),2.5,true)
        draw_rect(Rect2(c+Vector2(-18,-44),Vector2(36,20)),Color(0.04,0.09,0.11,0.94),true)
        draw_rect(Rect2(c+Vector2(-18,-44),Vector2(36,20)),Color("#72d7e6"),false,1.5)
        draw_string(ThemeDB.fallback_font,c+Vector2(-14,-40),str(st.line),HORIZONTAL_ALIGNMENT_CENTER,28,9,Color.WHITE)

func _draw_jobboards() -> void:
    for j in side_job_sites:
        if player_pos.distance_to(Vector2(j.pos))>1700.0:
            continue
        var c := _project(Vector2(j.pos),8)
        draw_rect(Rect2(c-Vector2(24,26),Vector2(48,52)),Color(0.04,0.10,0.09,0.92),true)
        draw_rect(Rect2(c-Vector2(24,26),Vector2(48,52)),Color("#8de9aa"),false,2.0)
        draw_string(ThemeDB.fallback_font,c+Vector2(-16,-8),"JOBS",HORIZONTAL_ALIGNMENT_CENTER,32,10,Color.WHITE)
        draw_circle(c+Vector2(0,13),5,Color("#8de9aa"))

func _draw_street_props() -> void:
    for l in street_lights:
        if player_pos.distance_to(l.pos) > 1750.0:
            continue
        var base := _project(l.pos,0)
        var top := _project(l.pos,l.h)
        draw_line(base,top,Color("#607079"),3.0,true)
        draw_line(top,top+Vector2(8,-5),Color("#87959d"),2.0,true)
        var bulb := top+Vector2(9,-6)
        draw_circle(bulb,4.5,l.tint)
        draw_circle(bulb,12.0,Color(l.tint.r,l.tint.g,l.tint.b,0.07))
    for p in street_props:
        if player_pos.distance_to(p.pos) > 1700.0:
            continue
        if p.type == "bench":
            var c := _project(p.pos,4)
            draw_line(c-Vector2(13,0),c+Vector2(13,0),p.tint,5.0,true)
            draw_line(c-Vector2(10,-6),c+Vector2(10,-6),p.tint.lightened(0.08),3.0,true)
            draw_line(c+Vector2(-9,1),c+Vector2(-9,8),Color("#59636a"),2.0)
            draw_line(c+Vector2(9,1),c+Vector2(9,8),Color("#59636a"),2.0)
        elif p.type == "billboard":
            var btm := _project(p.pos,0)
            var top := _project(p.pos,38)
            draw_line(btm,top,Color("#59636d"),3.0,true)
            draw_rect(Rect2(top-Vector2(22,14),Vector2(44,22)),Color(0.03,0.06,0.10,0.92),true)
            draw_rect(Rect2(top-Vector2(22,14),Vector2(44,22)),Color(p.tint.r,p.tint.g,p.tint.b,0.72),false,2.0)
            draw_line(top+Vector2(-16,-2),top+Vector2(16,-2),Color(p.tint.r,p.tint.g,p.tint.b,0.45),3.0)
        elif p.type == "crate":
            var cr := _project(p.pos,8)
            draw_rect(Rect2(cr-Vector2(8,6),Vector2(16,12)),p.tint,true)
            draw_rect(Rect2(cr-Vector2(8,6),Vector2(16,12)),Color(1,1,1,0.12),false,1.0)
        elif p.type == "traffic_light":
            _draw_traffic_light_prop(p)
        elif p.type == "crossing":
            _draw_crossing_prop(p)
        elif p.type == "bus_stop":
            _draw_stop_prop(p,false)
        elif p.type == "tram_stop":
            _draw_stop_prop(p,true)
        elif p.type == "parking_bay":
            var pc := _project(p.pos,1)
            var pf := Vector2.from_angle(float(p.rot))
            var ps := Vector2(-pf.y,pf.x)
            var bay := PackedVector2Array([pc-pf*26-ps*13,pc+pf*26-ps*13,pc+pf*26+ps*13,pc-pf*26+ps*13])
            draw_polyline(PackedVector2Array([bay[0],bay[1],bay[2],bay[3],bay[0]]),Color(0.82,0.86,0.86,0.18),1.3,true)
            draw_string(ThemeDB.fallback_font,pc+Vector2(-5,-5),"P",HORIZONTAL_ALIGNMENT_CENTER,10,8,Color(0.84,0.90,0.92,0.28))
        elif p.type == "bollard":
            var bp := _project(p.pos,5)
            draw_line(bp,bp+Vector2(0,-9),Color("#69767d"),3.0,true)
            draw_circle(bp+Vector2(0,-10),2.5,Color("#d6e0e5"))
        elif p.type == "sign":
            var sg := _project(p.pos,8)
            draw_line(sg,sg+Vector2(0,-22),Color("#68757c"),2.5,true)
            draw_circle(sg+Vector2(0,-28),8,Color("#244858"))
            draw_arc(sg+Vector2(0,-28),8,0,TAU,16,Color(p.tint.r,p.tint.g,p.tint.b,0.8),2.0,true)
        elif p.type == "wind_turbine":
            _draw_world_prop_wind(p)
        elif p.type == "runway_light":
            _draw_world_prop_runway(p)
        elif p.type == "data_pylon":
            _draw_world_prop_data(p)
        elif p.type == "boardwalk":
            _draw_world_prop_boardwalk(p)
        elif p.type == "market_stall":
            _draw_world_prop_market(p)
        elif p.type == "bike_rack":
            _draw_world_prop_bikes(p)
        elif p.type == "gantry":
            _draw_world_prop_gantry(p)
        elif p.type == "neon_totem":
            _draw_world_prop_neon(p)
        elif p.type == "garden_arch":
            _draw_world_prop_garden_arch(p)
        elif p.type == "attraction":
            _draw_attraction(p)

func _draw_traffic_light_prop(p: Dictionary) -> void:
    var base := _project(p.pos,0)
    var mast := _project(p.pos,34)
    draw_line(base,mast,Color("#58656c"),3.0,true)
    draw_line(mast,mast+Vector2(9,-3),Color("#76838a"),2.0,true)
    var box := mast+Vector2(11,-7)
    draw_rect(Rect2(box-Vector2(5,11),Vector2(10,22)),Color("#151a1e"),true)
    var phase := (int(Time.get_ticks_msec()/1300)+int(p.phase))%3
    draw_circle(box+Vector2(0,-6),2.6,Color("#ff665d") if phase==0 else Color(0.28,0.10,0.10,0.7))
    draw_circle(box,2.6,Color("#ffd663") if phase==1 else Color(0.28,0.23,0.08,0.7))
    draw_circle(box+Vector2(0,6),2.6,Color("#6ee293") if phase==2 else Color(0.08,0.26,0.13,0.7))

func _draw_crossing_prop(p: Dictionary) -> void:
    var c := _project(p.pos,1)
    for i in range(-4,5):
        draw_rect(Rect2(c+Vector2(float(i)*10.0-3,-33),Vector2(6,66)),Color(0.88,0.90,0.88,0.22),true)

func _draw_stop_prop(p: Dictionary, tram: bool) -> void:
    var c := _project(p.pos,8)
    var tint: Color = p.tint
    draw_line(c,c+Vector2(0,-35),Color("#67747b"),3.0,true)
    draw_rect(Rect2(c+Vector2(-18,-43),Vector2(36,22)),Color(0.04,0.08,0.10,0.92),true)
    draw_rect(Rect2(c+Vector2(-18,-43),Vector2(36,22)),Color(tint.r,tint.g,tint.b,0.76),false,2.0)
    draw_string(ThemeDB.fallback_font,c+Vector2(-15,-39),str(p.line),HORIZONTAL_ALIGNMENT_CENTER,30,10,Color.WHITE)
    draw_line(c+Vector2(-28,-4),c+Vector2(28,-4),Color("#7b8b93"),3.0,true)
    draw_line(c+Vector2(-24,-4),c+Vector2(-24,8),Color("#7b8b93"),2.0,true)
    draw_line(c+Vector2(24,-4),c+Vector2(24,8),Color("#7b8b93"),2.0,true)
    if tram:
        draw_line(c+Vector2(-30,12),c+Vector2(30,12),Color("#b4bfc5"),2.0,true)
        draw_line(c+Vector2(-30,17),c+Vector2(30,17),Color("#b4bfc5"),2.0,true)

func _draw_world_prop_wind(p: Dictionary) -> void:
    var b := _project(Vector2(p.pos),0)
    var top := _project(Vector2(p.pos),72)
    draw_line(b,top,Color("#9aa7ad"),4.0,true)
    var a: float = Time.get_ticks_msec()/700.0+float(p.pos.x)*0.001
    for k in range(3):
        var d := Vector2.from_angle(a+float(k)*TAU/3.0)
        draw_line(top,top+d*31,Color("#d6e4e8"),3.0,true)
    draw_circle(top,5,Color(p.tint))

func _draw_world_prop_runway(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),2)
    var pulse: float = 0.55+0.45*sin(Time.get_ticks_msec()/300.0+float(p.pos.x)*0.002)
    draw_circle(c,5,Color(p.tint.r,p.tint.g,p.tint.b,0.55+0.35*pulse))
    draw_circle(c,13,Color(p.tint.r,p.tint.g,p.tint.b,0.05+0.06*pulse))

func _draw_world_prop_data(p: Dictionary) -> void:
    var b := _project(Vector2(p.pos),0)
    var t := _project(Vector2(p.pos),46)
    draw_line(b,t,Color("#344755"),4.0,true)
    for y in [-28,-14,0]:
        draw_rect(Rect2(t+Vector2(-13,y),Vector2(26,8)),Color(0.14,0.28,0.38,0.95),true)
        draw_line(t+Vector2(-10,y+4),t+Vector2(10,y+4),Color(p.tint.r,p.tint.g,p.tint.b,0.45),2.0)

func _draw_world_prop_boardwalk(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),1)
    for k in range(-3,4):
        draw_line(c+Vector2(float(k)*12,-15),c+Vector2(float(k)*12,15),Color("#7a6753"),3.0)
    draw_line(c+Vector2(-42,-18),c+Vector2(42,-18),Color("#a48a6c"),2.0)
    draw_line(c+Vector2(-42,18),c+Vector2(42,18),Color("#a48a6c"),2.0)

func _draw_world_prop_market(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),8)
    draw_rect(Rect2(c-Vector2(24,8),Vector2(48,24)),Color("#5d4436"),true)
    var awn := PackedVector2Array([c+Vector2(-30,-8),c+Vector2(30,-8),c+Vector2(22,-22),c+Vector2(-22,-22)])
    draw_colored_polygon(awn,Color(p.tint.r,p.tint.g,p.tint.b,0.75))
    for x in [-14,0,14]:
        draw_circle(c+Vector2(x,8),3,Color("#ffd77a"))

func _draw_world_prop_bikes(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),4)
    for k in range(3):
        var x := float(k)*16-16.0
        draw_circle(c+Vector2(x-5,5),5,Color("#a9b7bd"),false,1.5)
        draw_circle(c+Vector2(x+5,5),5,Color("#a9b7bd"),false,1.5)
        draw_line(c+Vector2(x-5,5),c+Vector2(x,0),Color(p.tint),1.5)
        draw_line(c+Vector2(x,0),c+Vector2(x+5,5),Color(p.tint),1.5)

func _draw_world_prop_gantry(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),4)
    draw_line(c+Vector2(-30,18),c+Vector2(-30,-26),Color("#666d70"),4.0)
    draw_line(c+Vector2(30,18),c+Vector2(30,-26),Color("#666d70"),4.0)
    draw_line(c+Vector2(-30,-26),c+Vector2(30,-26),Color(p.tint.r,p.tint.g,p.tint.b,0.65),4.0)
    draw_rect(Rect2(c+Vector2(-15,-39),Vector2(30,11)),Color("#252b2e"),true)

func _draw_world_prop_neon(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),12)
    draw_line(c+Vector2(0,24),c+Vector2(0,-38),Color("#454b55"),4.0)
    draw_arc(c+Vector2(0,-38),15,0,TAU,20,Color(p.tint.r,p.tint.g,p.tint.b,0.88),3.0,true)
    draw_circle(c+Vector2(0,-38),28,Color(p.tint.r,p.tint.g,p.tint.b,0.06))

func _draw_world_prop_garden_arch(p: Dictionary) -> void:
    var c := _project(Vector2(p.pos),8)
    draw_arc(c,30,PI,TAU,24,Color("#6d8870"),4.0,true)
    draw_line(c+Vector2(-30,0),c+Vector2(-30,28),Color("#6d8870"),4.0)
    draw_line(c+Vector2(30,0),c+Vector2(30,28),Color("#6d8870"),4.0)
    for ang in [3.45,4.15,5.0,5.65]:
        var q := c+Vector2.from_angle(float(ang))*30
        draw_circle(q,6,Color(p.tint.r,p.tint.g,p.tint.b,0.75))

func _draw_attraction(p: Dictionary) -> void:
    var c := _project(p.pos,14)
    var kind: String = p.kind
    if kind == "Fountain":
        draw_circle(c,34,Color("#203f4b"))
        draw_circle(c,26,Color("#4bb8d5"))
        draw_circle(c,16,Color(0.65,0.92,1.0,0.22))
        draw_line(c,c+Vector2(0,-28),Color(0.75,0.95,1.0,0.72),3.0,true)
    elif kind == "Stage":
        draw_rect(Rect2(c-Vector2(42,18),Vector2(84,36)),Color("#5e453b"),true)
        draw_line(c+Vector2(-34,-18),c+Vector2(-22,-42),Color("#ffc980"),3.0)
        draw_line(c+Vector2(34,-18),c+Vector2(22,-42),Color("#ffc980"),3.0)
        draw_line(c+Vector2(-22,-42),c+Vector2(22,-42),Color("#ffc980"),3.0)
    elif kind == "Sculpture":
        var pts := PackedVector2Array([c+Vector2(0,-34),c+Vector2(20,-2),c+Vector2(2,28),c+Vector2(-22,4)])
        draw_colored_polygon(pts,Color(0.55,0.72,1.0,0.24))
        draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color("#b0c8ff"),3.0,true)
    elif kind == "Light Spire":
        draw_line(c+Vector2(0,22),c+Vector2(0,-48),Color("#ff80ef"),5.0,true)
        draw_circle(c+Vector2(0,-50),12,Color(1.0,0.38,0.91,0.18))
        draw_circle(c+Vector2(0,-50),4,Color("#ffb7f7"))
    elif kind == "Pavilion":
        draw_circle(c,34,Color(0.1,0.16,0.2,0.75))
        for a in range(0,360,60):
            var dir := Vector2.from_angle(deg_to_rad(float(a)))
            draw_line(c+dir*20,c+dir*35,Color("#d9c2ff"),3.0)
        draw_circle(c,35,Color("#c3a6ff"),false,3.0)
    elif kind == "Art Wall":
        draw_rect(Rect2(c-Vector2(45,24),Vector2(90,48)),Color("#26343c"),true)
        for k in range(5):
            draw_line(c+Vector2(-36,float(k)*8-16),c+Vector2(36-float(k)*8,float(k)*5-10),[Color("#ff80ef"),Color("#67d9ff"),Color("#f1e36f")][k%3],3.0)
    elif kind == "Pond":
        _draw_poly_ellipse(c,Vector2(48,27),0.0,Color("#2d7f92"))
        draw_arc(c,38,-0.5,2.2,22,Color(0.72,0.94,1.0,0.35),2.0,true)
        draw_circle(c+Vector2(-12,3),5,Color("#75b75d"))
    elif kind == "Skate Bowl":
        _draw_poly_ellipse(c,Vector2(45,28),0.0,Color("#59656c"))
        _draw_poly_ellipse(c,Vector2(34,18),0.0,Color("#303a40"))
        draw_arc(c,36,0,TAU,24,Color("#a8b5ba"),2.0,true)
    elif kind == "Drone Pad":
        draw_circle(c,34,Color("#222d36"))
        draw_circle(c,27,Color("#ff80ef"),false,3.0)
        draw_string(ThemeDB.fallback_font,c+Vector2(-12,-8),"H",HORIZONTAL_ALIGNMENT_CENTER,24,18,Color.WHITE)
        var drone := c+Vector2(sin(Time.get_ticks_msec()/700.0)*20,-42+cos(Time.get_ticks_msec()/600.0)*5)
        draw_circle(drone,5,Color("#dff7ff"))
        draw_line(drone-Vector2(12,0),drone+Vector2(12,0),Color("#9ad5ff"),2.0)
    elif kind == "Rose Garden":
        for a in range(0,360,45):
            var dir := Vector2.from_angle(deg_to_rad(float(a)))
            draw_circle(c+dir*28,8,[Color("#ff8ca5"),Color("#ffd0d8"),Color("#d78cff")][(a/45)%3])
        draw_circle(c,20,Color("#3f7449"))
    elif kind == "Playground":
        draw_line(c+Vector2(-28,20),c+Vector2(-8,-26),Color("#f2c65e"),5.0)
        draw_line(c+Vector2(-8,-26),c+Vector2(14,20),Color("#f2c65e"),5.0)
        draw_line(c+Vector2(-18,-2),c+Vector2(4,-2),Color("#6bc4e8"),4.0)
        draw_arc(c+Vector2(28,3),18,PI,TAU,18,Color("#ff8fa6"),4.0,true)
    else:
        draw_circle(c,26,Color("#303d44"))
        draw_circle(c,18,Color("#d9e5ef"),false,3.0)
        draw_line(c,c+Vector2(0,-12),Color("#d9e5ef"),2.0)
        draw_line(c,c+Vector2(8,0),Color("#d9e5ef"),2.0)
    draw_string(ThemeDB.fallback_font,c+Vector2(-72,52),str(p.name),HORIZONTAL_ALIGNMENT_CENTER,144,14,Color(0.88,0.96,0.95,0.82))

func _draw_pedestrians() -> void:
    for ped in pedestrians:
        var rd = roads[ped.road]
        var pos := _sample_polyline(rd.points,float(ped.t))
        var ped_draw_distance: float = [900.0,1300.0,1700.0][graphics_quality]
        if player_pos.distance_to(pos) > ped_draw_distance:
            continue
        var tan := _polyline_tangent(rd.points,float(ped.t))
        if ped.reverse:
            tan *= -1.0
        var normal := Vector2(-tan.y,tan.x)
        pos += normal * (float(rd.width)*0.5 + 18.0) * float(ped.side)
        var base := _project(pos,0)
        var pelvis := _project(pos,10)
        var head := _project(pos,19)
        var phase := float(ped.phase)
        var bob := sin(phase)*1.4
        head.y += bob
        pelvis.y += bob*0.5
        draw_circle(base+Vector2(2,5),5.5,Color(0,0,0,0.18))
        var swing := sin(phase)*4.0
        var side_dir := normal.normalized()
        draw_line(pelvis+Vector2(0,1),pelvis+Vector2(swing*0.35,9),ped.color,4.0,true)
        draw_line(pelvis+Vector2(-2,7),pelvis+Vector2(-swing,15),Color("#7b8790"),2.3,true)
        draw_line(pelvis+Vector2(2,7),pelvis+Vector2(swing,15),Color("#697783"),2.3,true)
        draw_line(pelvis+Vector2(0,2),pelvis+Vector2(swing*0.8,-3),ped.color.darkened(0.12),2.2,true)
        draw_circle(head,4.8,ped.skin)
        draw_arc(head+Vector2(0,-1),4.7,PI,TAU,12,ped.hair,2.4,true)
        if ped.role == "runner":
            draw_line(pelvis+Vector2(-4,2),pelvis+Vector2(4,2),Color("#73f3ce"),1.4)
        elif ped.role == "worker":
            draw_rect(Rect2(pelvis+Vector2(-4,-1),Vector2(8,3)),Color("#ffd46d"),true)
        elif ped.role == "student":
            draw_circle(pelvis+side_dir*5.0,3.0,Color("#88a9d9"))
        if ped.bag:
            var bag_pos := pelvis + side_dir*5.5 + Vector2(0,2)
            draw_rect(Rect2(bag_pos-Vector2(2.5,2.5),Vector2(5,6)),Color("#5f4f47"),true)

func _draw_traffic() -> void:
    for c in traffic:
        var tr := _traffic_world_transform(c)
        var pos: Vector2 = Vector2(tr.pos)
        var tangent: Vector2 = Vector2(tr.tangent)

        if float(c.get("turn_anim",0.0))>0.0:
            var amount: float = 1.0-clampf(float(c.turn_anim)/0.55,0.0,1.0)
            amount=amount*amount*(3.0-2.0*amount)
            pos=Vector2(c.turn_from).lerp(Vector2(c.turn_to),amount)

        if float(c.get("lane_change",0.0))>0.0:
            var road = roads[int(c.road)]
            var normal := Vector2(-tangent.y,tangent.x)
            var from_lane: int = int(c.get("lane_from",int(c.lane)))
            var to_lane: int = int(c.get("lane_to",int(c.lane)))
            var phase: float = 1.0-clampf(float(c.lane_change),0.0,1.0)
            var from_off: float = float(road.width)*(0.18+float(from_lane)*0.14)
            var to_off: float = float(road.width)*(0.18+float(to_lane)*0.14)
            pos += normal*(lerpf(from_off,to_off,phase)-to_off)

        var traffic_draw_distance: float = [1050.0,1450.0,1800.0][graphics_quality]
        if player_pos.distance_to(pos)>traffic_draw_distance:
            continue
        _draw_car(pos,tangent.angle(),str(c["class"]),Color(c.color),false)
        var ind: int = int(c.get("indicator",0))
        if ind!=0 and int(Time.get_ticks_msec()/320)%2==0:
            var fwd := tangent.normalized()
            var side := Vector2(-fwd.y,fwd.x)*float(ind)
            var lamp := _project(pos,5)+fwd*12.0+side*7.0
            draw_circle(lamp,2.8,Color("#ffb343"))

func _draw_smart_agents() -> void:
    for a in smart_agents:
        var road = roads[int(a.road)]
        var t: float = float(a.t)
        var tangent := _polyline_tangent(road.points,t)
        if bool(a.reverse):
            tangent*=-1.0
        var normal := Vector2(-tangent.y,tangent.x)
        var lane_offset: float = float(road.width)*(0.18+float(int(a.lane))*0.14)
        var lane_pos := _sample_polyline(road.points,t)+normal*lane_offset
        var sidewalk_pos := _sample_polyline(road.points,t)+normal*(float(road.width)*0.5+24.0)
        var state := str(a.state)
        if state=="walking" and bool(a.get("car_parked",false)):
            var parked_t: float = float(a.get("parked_t",t))
            var ptan := _polyline_tangent(road.points,parked_t)
            if bool(a.reverse):
                ptan*=-1.0
            var pnorm := Vector2(-ptan.y,ptan.x)
            var ppos := _sample_polyline(road.points,parked_t)+pnorm*(float(road.width)*0.5+50.0)
            if player_pos.distance_to(ppos)<1850.0:
                _draw_car(ppos,ptan.angle(),str(a["class"]),Color(a.color),true)
        if state in ["driving","parking","parked","entering"]:
            var park_extra: float = 0.0
            if state=="parking" or state=="parked":
                var park_depth: float = float(road.width)*0.34 + (34.0 if int(a.road)%3==0 else 20.0)
                park_extra = lerpf(0.0,park_depth,float(a.parking_progress))
            elif state=="entering":
                var enter_depth: float = float(road.width)*0.34 + (34.0 if int(a.road)%3==0 else 20.0)
                park_extra = lerpf(enter_depth,0.0,float(a.parking_progress))
            var car_pos := lane_pos+normal*park_extra
            if player_pos.distance_to(car_pos)<1850.0:
                _draw_car(car_pos,tangent.angle(),str(a["class"]),Color(a.color),state=="parked")
        if state=="walking" or state=="entering":
            if player_pos.distance_to(sidewalk_pos)<1750.0:
                _draw_agent_person(sidewalk_pos,tangent,a)

func _draw_agent_person(pos: Vector2, tangent: Vector2, a: Dictionary) -> void:
    var base := _project(pos,0)
    var head := _project(pos,18)
    var swing := sin(float(a.phase))*3.5
    draw_circle(base+Vector2(2,5),5,Color(0,0,0,0.18))
    draw_line(head+Vector2(0,5),head+Vector2(0,13),Color(a.clothes),4.0,true)
    draw_line(head+Vector2(0,11),head+Vector2(swing,18),Color("#6e7a82"),2.0,true)
    draw_line(head+Vector2(0,11),head+Vector2(-swing,18),Color("#7c8890"),2.0,true)
    draw_circle(head,4.5,Color(a.skin))

func _draw_transit() -> void:
    for tv in transit_vehicles:
        var rd = roads[tv.road]
        var tt: float = tv.t
        var pos := _sample_polyline(rd.points,tt)
        if player_pos.distance_to(pos) > 1900.0:
            continue
        var tangent := _polyline_tangent(rd.points,tt)
        if tv.reverse:
            tangent *= -1.0
        _draw_transit_vehicle(pos,tangent.angle(),tv)

func _draw_transit_vehicle(pos: Vector2, heading: float, tv: Dictionary) -> void:
    var center := _project(pos,10)
    var f := Vector2.from_angle(heading)
    var side := Vector2(-f.y,f.x)
    var is_tram: bool = str(tv.kind) == "tram"
    var length: float = 88.0 if is_tram else 74.0
    var width: float = 24.0 if is_tram else 27.0
    _draw_poly_ellipse(center+Vector2(5,8),Vector2(length*0.50,width*0.48),heading,Color(0,0,0,0.19))
    var pts := PackedVector2Array([
        center+f*length*0.5+side*width*0.48,
        center+f*length*0.5-side*width*0.48,
        center-f*length*0.5-side*width*0.48,
        center-f*length*0.5+side*width*0.48
    ])
    draw_colored_polygon(pts,tv.color)
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color(1,1,1,0.20),1.3,true)
    var glass_col := Color(0.55,0.84,0.94,0.72)
    for k in range(-3,4):
        var q := center + f*float(k)*9.0
        draw_line(q-side*width*0.31,q+side*width*0.31,glass_col,5.0,true)
    var nose := center+f*length*0.45
    draw_circle(nose+side*width*0.23,2.8,Color("#ffe6a8"))
    draw_circle(nose-side*width*0.23,2.8,Color("#ffe6a8"))
    if is_tram:
        draw_line(center-f*18,center+f*18,Color(1,1,1,0.12),1.0)
        var mast := center+Vector2(0,-4)
        draw_line(mast,mast+Vector2(0,-17),Color("#4f5960"),2.0)
        draw_line(mast+Vector2(0,-17),mast+Vector2(10,-24),Color("#6d777e"),2.0)
        draw_line(center-side*width*0.48,center+side*width*0.48,Color(0.10,0.12,0.14,0.48),2.0)
    else:
        draw_line(center+f*9-side*width*0.48,center+f*9+side*width*0.48,Color(1,1,1,0.16),2.0)
        draw_rect(Rect2(center+f*22-side*width*0.47-Vector2(4,6),Vector2(8,12)),Color(0.12,0.15,0.18,0.55),true)
    draw_string(ThemeDB.fallback_font,center-f*2+Vector2(-18,-21),str(tv.line),HORIZONTAL_ALIGNMENT_CENTER,36,11,Color.WHITE)

func _draw_parked_cars() -> void:
    for i in range(parked_cars.size()):
        if i == current_vehicle:
            continue
        var c = parked_cars[i]
        if player_pos.distance_to(c.pos)>1800:
            continue
        _draw_car(c.pos,c.heading,c["class"],c.color,true)

func _draw_car(pos: Vector2, heading: float, cls: String, color: Color, parked: bool) -> void:
    var sz: Vector2 = VEHICLE_SIZES.get(cls,Vector2(45,22))
    var center := _project(pos,8)
    var f := Vector2.from_angle(heading)
    var side := Vector2(-f.y,f.x)
    _draw_poly_ellipse(center+Vector2(4,7),Vector2(sz.x*.53,sz.y*.43),heading,Color(0,0,0,0.19))

    var nose: float = 0.50
    var rear: float = 0.50
    if cls in ["sport","hyper"]:
        nose=0.60
        rear=0.46
    elif cls=="micro":
        nose=0.50
        rear=0.44
    elif cls=="hatch":
        nose=0.51
        rear=0.48
    elif cls in ["van","delivery"]:
        nose=0.48
        rear=0.53
    elif cls=="pickup":
        nose=0.54
        rear=0.55

    var pts := PackedVector2Array([
        center+f*sz.x*nose+side*sz.y*.43,
        center+f*sz.x*nose-side*sz.y*.43,
        center-f*sz.x*rear-side*sz.y*.50,
        center-f*sz.x*rear+side*sz.y*.50
    ])
    draw_colored_polygon(pts,color)
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color(1,1,1,0.20),1.2,true)

    var cabin_shift: float = 0.0
    var cabin_scale: float = 0.26
    if cls in ["sport","hyper"]:
        cabin_shift=-4.0
        cabin_scale=0.20
    elif cls in ["van","delivery"]:
        cabin_shift=4.0
        cabin_scale=0.32
    elif cls=="pickup":
        cabin_shift=7.0
        cabin_scale=0.22
    elif cls=="suv":
        cabin_scale=0.28
    var cabin_center := center + f*cabin_shift
    var cabin_len := sz.x*cabin_scale
    var glass_w: float = sz.y*(0.28 if cls not in ["suv","van","delivery"] else 0.32)
    var wind_a := cabin_center+f*cabin_len+side*glass_w
    var wind_b := cabin_center+f*cabin_len-side*glass_w
    var wind_c := cabin_center-f*cabin_len-side*glass_w
    var wind_d := cabin_center-f*cabin_len+side*glass_w
    draw_colored_polygon(PackedVector2Array([wind_a,wind_b,wind_c,wind_d]),Color(0.58,0.82,0.92,0.72))
    draw_line(wind_a,wind_b,Color(1,1,1,0.24),1.0)

    var front_l := center+f*sz.x*.49+side*sz.y*.25
    var front_r := center+f*sz.x*.49-side*sz.y*.25
    var rear_l := center-f*sz.x*.45+side*sz.y*.25
    var rear_r := center-f*sz.x*.45-side*sz.y*.25
    draw_circle(front_l,2.4,Color("#ffe0a0"))
    draw_circle(front_r,2.4,Color("#ffe0a0"))
    draw_circle(rear_l,2.2,Color("#ff726f"))
    draw_circle(rear_r,2.2,Color("#ff726f"))
    _draw_car_wheels(center,f,side,sz)

    if cls=="micro":
        draw_line(center-f*2-side*sz.y*.37,center-f*2+side*sz.y*.37,Color(1,1,1,0.16),1.2)
    elif cls=="hatch":
        draw_line(center-f*sz.x*.30-side*sz.y*.44,center-f*sz.x*.30+side*sz.y*.44,Color(1,1,1,0.13),1.4)
        draw_circle(center-f*sz.x*.39,3.2,Color(0.12,0.14,0.16,0.6))
    elif cls=="sedan":
        draw_line(center+side*sz.y*.44,center-side*sz.y*.44,Color(1,1,1,0.10),1.0)
    elif cls=="executive":
        draw_line(center+f*sz.x*.18-side*sz.y*.45,center+f*sz.x*.18+side*sz.y*.45,Color(0.85,0.92,0.95,0.16),2.0)
        draw_line(center-f*sz.x*.20-side*sz.y*.44,center-f*sz.x*.20+side*sz.y*.44,Color(0.85,0.92,0.95,0.10),1.2)
    elif cls=="suv":
        draw_line(center+f*sz.x*.34-side*sz.y*.47,center+f*sz.x*.34+side*sz.y*.47,Color(0.12,0.15,0.16,0.52),2.2)
        draw_line(center-f*sz.x*.32-side*sz.y*.47,center-f*sz.x*.32+side*sz.y*.47,Color(0.12,0.15,0.16,0.52),2.2)
        draw_line(center-f*sz.x*.10-side*sz.y*.34,center+f*sz.x*.26-side*sz.y*.34,Color(1,1,1,0.12),1.2)
    elif cls=="pickup":
        var bed := PackedVector2Array([
            center-f*sz.x*.17+side*sz.y*.40,center-f*sz.x*.17-side*sz.y*.40,
            center-f*sz.x*.48-side*sz.y*.44,center-f*sz.x*.48+side*sz.y*.44])
        draw_colored_polygon(bed,color.darkened(0.16))
        draw_polyline(PackedVector2Array([bed[0],bed[1],bed[2],bed[3],bed[0]]),Color(1,1,1,0.12),1.0,true)
    elif cls=="van":
        draw_line(center-f*7-side*sz.y*.44,center-f*7+side*sz.y*.44,Color(1,1,1,0.16),1.5)
        draw_line(center+side*sz.y*.49-f*6,center+side*sz.y*.49+f*10,Color(0.16,0.18,0.20,0.62),2.0)
        draw_line(center-side*sz.y*.49-f*6,center-side*sz.y*.49+f*10,Color(0.16,0.18,0.20,0.62),2.0)
    elif cls=="delivery":
        draw_rect(Rect2(center-f*8-side*sz.y*.34,Vector2(16,sz.y*.68)),Color(1,1,1,0.06),true)
        draw_line(center-f*sz.x*.16-side*sz.y*.46,center-f*sz.x*.16+side*sz.y*.46,Color(0.10,0.13,0.15,0.48),2.0)
    elif cls=="sport":
        draw_line(center-f*sz.x*.35-side*sz.y*.49,center-f*sz.x*.35+side*sz.y*.49,Color(0.05,0.07,0.09,0.64),2.2)
        draw_line(center+f*sz.x*.20-side*sz.y*.28,center+f*sz.x*.29-side*sz.y*.12,Color(1,1,1,0.15),1.0)
    elif cls=="hyper":
        draw_line(center-f*sz.x*.38-side*sz.y*.50,center-f*sz.x*.38+side*sz.y*.50,Color(0.04,0.06,0.08,0.82),3.0)
        draw_line(center+f*sz.x*.30-side*sz.y*.30,center+f*sz.x*.42-side*sz.y*.12,Color(0.45,1.0,0.92,0.24),2.0)
        draw_line(center+f*sz.x*.30+side*sz.y*.30,center+f*sz.x*.42+side*sz.y*.12,Color(0.45,1.0,0.92,0.24),2.0)

    var livery := int(abs(pos.x+pos.y)) % 17
    if livery==0:
        draw_line(center-f*sz.x*.10-side*sz.y*.45,center-f*sz.x*.10+side*sz.y*.45,Color(0.98,0.88,0.34,0.58),2.0)
    elif livery==1:
        draw_line(center-f*sz.x*.28,center+f*sz.x*.30,Color(1,1,1,0.16),1.2)
    if not parked:
        var tail := center-f*sz.x*.62
        draw_line(tail,tail-f*(30 if cls in ["sport","hyper"] else 22),Color(0.35,0.85,1.0,0.11),4.0,true)

func _draw_car_wheels(center: Vector2, f: Vector2, side: Vector2, sz: Vector2) -> void:
    for ax in [0.28,-0.28]:
        var axle := center + f*sz.x*float(ax)
        var w1 := axle + side*sz.y*.52
        var w2 := axle - side*sz.y*.52
        draw_line(w1-f*4,w1+f*4,Color(0.05,0.05,0.06,0.92),2.4)
        draw_line(w2-f*4,w2+f*4,Color(0.05,0.05,0.06,0.92),2.4)

func _draw_poly_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i in range(24):
        var a := TAU*float(i)/24.0
        pts.append(center+Vector2(cos(a)*radii.x,sin(a)*radii.y))
    draw_colored_polygon(pts,color)

func _draw_poly_ellipse(center: Vector2, radii: Vector2, rotation: float, color: Color) -> void:
    var pts := PackedVector2Array()
    for i in range(18):
        var a := TAU*float(i)/18.0
        var p := Vector2(cos(a)*radii.x,sin(a)*radii.y).rotated(rotation)
        pts.append(center+p)
    draw_colored_polygon(pts,color)

func _draw_collectibles() -> void:
    for f in fragments:
        if f.taken:
            continue
        if player_pos.distance_to(f.pos)>1800:
            continue
        var p := _project(f.pos,18)
        var rr := 8.0 + sin(Time.get_ticks_msec()/280.0 + f.phase)*2.0
        draw_circle(p,rr,Color(0.45,0.96,0.82,0.18))
        draw_arc(p,rr+5,0,TAU,24,Color("#73f3ce"),2.0,true)
    for s in secrets:
        if s.found:
            continue
        if player_pos.distance_to(s.pos)>1800:
            continue
        if not s.revealed and scan_time<=0:
            continue
        var p2 := _project(s.pos,28)
        var c := Color("#ffd27a")
        c.a = 0.9 if s.revealed else 0.25
        draw_rect(Rect2(p2-Vector2(18,13),Vector2(36,26)),Color(c.r,c.g,c.b,0.10),true)
        draw_rect(Rect2(p2-Vector2(18,13),Vector2(36,26)),c,false,2.0)
        if s.revealed:
            draw_string(ThemeDB.fallback_font,p2+Vector2(-60,-22),s.label,HORIZONTAL_ALIGNMENT_CENTER,120,14,Color.WHITE)

func _draw_player() -> void:
    if current_vehicle >= 0:
        var c = parked_cars[current_vehicle]
        _draw_car(player_pos,player_heading,c["class"],c.color,false)
        return
    var foot := _project(player_pos,0)
    var pelvis := _project(player_pos,10)
    var chest := _project(player_pos,17)
    var head := _project(player_pos,24)
    var f := Vector2.from_angle(player_heading)
    var side := Vector2(-f.y,f.x)
    var walking := move_vec.length() > 0.08
    var phase: float = float(Time.get_ticks_msec())/95.0 if walking else 0.0
    var swing: float = sin(phase)*5.0 if walking else 0.0
    var bob: float = abs(sin(float(phase)))*1.5 if walking else 0.0
    pelvis.y -= bob
    chest.y -= bob
    head.y -= bob
    _draw_poly_ellipse(foot+Vector2(3,5),Vector2(9,5),player_heading,Color(0,0,0,0.24))
    var left_leg := pelvis + f*5.0 + side*swing
    var right_leg := pelvis + f*5.0 - side*swing
    draw_line(pelvis,left_leg+Vector2(0,7),Color("#5c6974"),3.0,true)
    draw_line(pelvis,right_leg+Vector2(0,7),Color("#687886"),3.0,true)
    var torso := PackedVector2Array([chest+f*7+side*6,chest+f*7-side*6,pelvis-side*6,pelvis+side*6])
    draw_colored_polygon(torso,Color("#e8f2f6"))
    draw_polyline(PackedVector2Array([torso[0],torso[1],torso[2],torso[3],torso[0]]),Color(0.2,0.35,0.42,0.45),1.0,true)
    draw_line(chest+side*4,chest-side*swing+Vector2(0,7),Color("#cfdde4"),2.4,true)
    draw_line(chest-side*4,chest+side*swing+Vector2(0,7),Color("#cfdde4"),2.4,true)
    draw_circle(head,5.2,Color("#e8ba96"))
    draw_arc(head+Vector2(0,-1),5.3,PI,TAU,14,Color("#263039"),2.5,true)
    draw_line(chest-f*2-side*6,chest-f*2+side*6,Color("#73f3ce"),1.8,true)
    # small tech pack that visually anchors the PMDD theme
    var pack := chest - f*4.0
    draw_rect(Rect2(pack-Vector2(3,4),Vector2(6,8)),Color("#20343f"),true)
    draw_circle(pack+Vector2(0,-1),1.6,Color("#73f3ce"))

func _enter_interior(name: String, kind: String, accent: Color, return_pos: Vector2) -> void:
    if kind in ["garage","workshop","home"]:
        if current_vehicle < 0:
            service_vehicle_index=-1
    else:
        service_vehicle_index=-1
    interior_active = true
    interior_floor = 0
    interior_name = name
    interior_kind = kind
    interior_accent = accent
    interior_return_pos = return_pos
    interior_player_pos = Vector2(interior_size.x*0.5,interior_size.y-120)
    current_vehicle = -1
    vehicle_velocity = 0.0
    _play_sfx("collect")
    _notify("%s · entered" % name)

func _leave_interior() -> void:
    commerce_panel.visible = false
    interior_active = false
    current_vertical_id = ""
    player_pos = interior_return_pos + Vector2(0,42)
    if service_vehicle_index>=0 and service_vehicle_index<parked_cars.size():
        current_vehicle=service_vehicle_index
        parked_cars[current_vehicle]["occupied"]=true
        player_pos=Vector2(parked_cars[current_vehicle]["pos"])
        service_vehicle_index=-1
    camera_pos = player_pos
    _play_sfx("door")
    _notify("Back outside · %s" % current_district)

func _show_reward_popup(title_text: String, body_text: String, accent: Color = Color("#73f3ce")) -> void:
    if reward_panel==null:
        return
    reward_title.text=title_text
    reward_title.modulate=accent
    reward_body.text=body_text
    reward_panel.visible=true
    reward_panel.modulate=Color(1,1,1,1)
    var tw := create_tween()
    tw.tween_interval(2.15)
    tw.tween_property(reward_panel,"modulate:a",0.0,0.50)
    tw.tween_callback(func(): reward_panel.visible=false)

func _notify(text: String) -> void:
    district_banner.text = text
    district_banner.modulate = Color(1,1,1,1)
    var tw := create_tween()
    tw.tween_interval(1.0)
    tw.tween_property(district_banner,"modulate:a",0.0,0.65)

func _interior_elevator_pos() -> Vector2:
    return Vector2(interior_size.x-105,interior_size.y-115)

func _toggle_interior_floor() -> void:
    interior_floor=1-interior_floor
    interior_player_pos=Vector2(interior_size.x-145,interior_size.y-150)
    _play_sfx("door")
    _notify("%s · Etage %d" % [interior_name,interior_floor+1])

func _interior_feature_pos() -> Vector2:
    if interior_kind == "openai_hq":
        return Vector2(interior_size.x*0.5,210 if interior_floor==0 else 285)
    if interior_kind in ["garage","workshop"]:
        return Vector2(interior_size.x*0.68,250)
    if interior_kind in ["restaurant","cafe"]:
        return Vector2(interior_size.x*0.30,250)
    return Vector2(interior_size.x*0.5,250)

func _interior_feature_message() -> String:
    if interior_kind == "openai_hq":
        return "Visitor lab display: multimodal research visualization active."
    if interior_kind == "roof":
        return "Dach-Relay synchronisieren."
    if interior_kind == "sublevel":
        return "Sublevel-Knoten aktivieren."
    if interior_kind == "garage":
        return "Garage service bay ready for vehicle storage and paint systems."
    if interior_kind == "workshop":
        return "Workshop diagnostics online."
    if interior_kind in ["restaurant","cafe"]:
        return "A quiet table restores the pace of the journey."
    return "Interactive display online."

func _draw_interior_scene() -> void:
    var size := get_viewport_rect().size
    var origin := size*0.5 - interior_size*0.5
    var accent := interior_accent
    draw_rect(Rect2(origin,interior_size),Color("#111a20"),true)
    draw_rect(Rect2(origin,interior_size),Color(accent.r,accent.g,accent.b,0.28),false,3.0)
    # floor grid and light pools
    for x in range(30,int(interior_size.x),54):
        draw_line(origin+Vector2(x,20),origin+Vector2(x,interior_size.y-20),Color(1,1,1,0.025),1.0)
    for y in range(30,int(interior_size.y),54):
        draw_line(origin+Vector2(20,y),origin+Vector2(interior_size.x-20,y),Color(1,1,1,0.025),1.0)
    draw_circle(origin+Vector2(interior_size.x*0.28,180),80,Color(accent.r,accent.g,accent.b,0.035))
    draw_circle(origin+Vector2(interior_size.x*0.72,180),80,Color(accent.r,accent.g,accent.b,0.035))
    if interior_floor==1:
        draw_rect(Rect2(origin+Vector2(20,70),Vector2(interior_size.x-40,405)),Color(accent.r,accent.g,accent.b,0.035),true)
    # room partitions
    draw_line(origin+Vector2(250,90),origin+Vector2(250,470),Color(0.45,0.56,0.62,0.30),4.0)
    draw_line(origin+Vector2(650,90),origin+Vector2(650,470),Color(0.45,0.56,0.62,0.30),4.0)
    draw_line(origin+Vector2(250,470),origin+Vector2(650,470),Color(0.45,0.56,0.62,0.30),4.0)
    # Elevator / stairs for multi-level interiors.
    if interior_kind in ["openai_hq","home","shop","restaurant","cafe"]:
        var lift := origin+_interior_elevator_pos()
        draw_rect(Rect2(lift-Vector2(32,24),Vector2(64,48)),Color(0.07,0.11,0.14,0.94),true)
        draw_rect(Rect2(lift-Vector2(32,24),Vector2(64,48)),Color(accent.r,accent.g,accent.b,0.48),false,2.0)
        draw_string(ThemeDB.fallback_font,lift+Vector2(-22,-5),"LIFT",HORIZONTAL_ALIGNMENT_CENTER,44,10,Color.WHITE)
        draw_string(ThemeDB.fallback_font,lift+Vector2(-28,38),"ETAGE %d" % (interior_floor+1),HORIZONTAL_ALIGNMENT_CENTER,56,9,Color("#9fb3bd"))
    # proximity-sliding exit door
    var exitp := origin+Vector2(interior_size.x*0.5,interior_size.y-48)
    var door_near: float = clampf(1.0-interior_player_pos.distance_to(Vector2(interior_size.x*0.5,interior_size.y-48))/135.0,0.0,1.0)
    draw_rect(Rect2(exitp-Vector2(48,20),Vector2(96,40)),Color(0.04,0.08,0.10,0.94),true)
    var leaf_offset: float = door_near*32.0
    draw_rect(Rect2(exitp+Vector2(-46-leaf_offset,-17),Vector2(44,34)),Color(0.16,0.23,0.27,0.95),true)
    draw_rect(Rect2(exitp+Vector2(2+leaf_offset,-17),Vector2(44,34)),Color(0.16,0.23,0.27,0.95),true)
    draw_rect(Rect2(exitp-Vector2(48,20),Vector2(96,40)),Color(accent.r,accent.g,accent.b,0.46),false,2.0)
    draw_string(ThemeDB.fallback_font,exitp+Vector2(-32,-6),"EXIT",HORIZONTAL_ALIGNMENT_CENTER,64,12,Color.WHITE)
    if interior_kind == "openai_hq":
        _draw_openai_interior(origin,accent)
    elif interior_kind == "roof":
        _draw_roof_interior(origin,accent)
    elif interior_kind == "sublevel":
        _draw_sublevel_interior(origin,accent)
    elif interior_kind in ["garage","workshop"]:
        _draw_garage_interior(origin,accent)
    elif interior_kind in ["restaurant","cafe"]:
        _draw_restaurant_interior(origin,accent)
    elif interior_kind=="home":
        _draw_home_interior(origin,accent)
    else:
        _draw_shop_interior(origin,accent)
    _draw_interior_people(origin)
    _draw_interior_room_labels(origin)
    draw_string(ThemeDB.fallback_font,origin+Vector2(32,42),"%s · Etage %d" % [interior_name,interior_floor+1],HORIZONTAL_ALIGNMENT_LEFT,520,22,Color(0.94,0.98,0.99,0.92))

func _enter_vertical(index: int) -> void:
    if index<0 or index>=vertical_sites.size():
        return
    var site: Dictionary = vertical_sites[index]
    current_vertical_id = str(site.id)
    _enter_interior(str(site.name),str(site.kind),Color(site.accent),player_pos)

func _activate_vertical_feature() -> void:
    if current_vertical_id=="":
        return
    if bool(vertical_flags.get(current_vertical_id,false)):
        _notify("Knoten bereits synchronisiert.")
        return
    vertical_flags[current_vertical_id]=true
    if interior_kind=="roof":
        relay_count += 1
        credits += 28
        _notify("Dach-Relay synchronisiert · +28 CR")
    else:
        sublevel_count += 1
        credits += 32
        _notify("Sublevel-Knoten aktiviert · +32 CR")
    _play_sfx("secret")
    _save_game()
    _advance_native_chapter()

func _draw_roof_interior(origin: Vector2, accent: Color) -> void:
    draw_rect(Rect2(origin+Vector2(90,90),Vector2(720,360)),Color("#16222a"),true)
    for i in range(8):
        var x := origin.x+110+float(i)*90.0
        var h := 60.0+float((i*37)%120)
        draw_rect(Rect2(x,origin.y+450-h,55,h),Color(0.16,0.23,0.28,0.9),true)
        draw_line(Vector2(x,origin.y+450-h),Vector2(x+55,origin.y+450-h),Color(accent.r,accent.g,accent.b,0.22),2.0)
    var relay := origin+_interior_feature_pos()
    draw_line(relay+Vector2(0,40),relay+Vector2(0,-45),Color("#59676e"),5.0,true)
    draw_circle(relay+Vector2(0,-52),11,accent)
    draw_circle(relay+Vector2(0,-52),26,Color(accent.r,accent.g,accent.b,0.08))
    draw_string(ThemeDB.fallback_font,relay+Vector2(-55,64),"ROOF RELAY",HORIZONTAL_ALIGNMENT_CENTER,110,12,Color.WHITE)

func _draw_sublevel_interior(origin: Vector2, accent: Color) -> void:
    draw_rect(Rect2(origin+Vector2(85,90),Vector2(730,390)),Color("#0b1115"),true)
    for y in [135.0,205.0,275.0,345.0]:
        draw_line(origin+Vector2(105,y),origin+Vector2(795,y),Color(0.35,0.45,0.49,0.14),4.0)
    for x in [165.0,340.0,515.0,690.0]:
        draw_line(origin+Vector2(x,110),origin+Vector2(x,455),Color(0.26,0.34,0.38,0.16),3.0)
    var node := origin+_interior_feature_pos()
    draw_rect(Rect2(node-Vector2(42,28),Vector2(84,56)),Color(0.07,0.11,0.14,0.96),true)
    draw_rect(Rect2(node-Vector2(42,28),Vector2(84,56)),Color(accent.r,accent.g,accent.b,0.62),false,2.0)
    draw_circle(node,8,accent)
    draw_string(ThemeDB.fallback_font,node+Vector2(-45,50),"UTILITY NODE",HORIZONTAL_ALIGNMENT_CENTER,90,11,Color.WHITE)

func _draw_interior_people(origin: Vector2) -> void:
    var positions: Array = []
    if interior_kind in ["restaurant","cafe"]:
        positions=[Vector2(360,190),Vector2(520,190),Vector2(360,330),Vector2(520,330),Vector2(730,235)]
    elif interior_kind in ["garage","workshop"]:
        positions=[Vector2(335,250),Vector2(520,300),Vector2(700,220)]
    elif interior_kind=="openai_hq":
        positions=[Vector2(145,205),Vector2(330,330),Vector2(450,330),Vector2(570,330),Vector2(700,350)]
    elif interior_kind=="shop":
        positions=[Vector2(680,230),Vector2(340,355)]
    elif interior_kind=="home":
        positions=[]
    else:
        positions=[Vector2(720,250)]
    var t := Time.get_ticks_msec()/350.0
    for i in range(positions.size()):
        var p: Vector2 = origin+Vector2(positions[i])
        var bob := sin(t+float(i))*1.2
        draw_circle(p+Vector2(2,7),6,Color(0,0,0,0.18))
        draw_line(p+Vector2(0,-5+bob),p+Vector2(0,9+bob),[Color("#8dcfff"),Color("#ff9fc1"),Color("#90dfb8"),Color("#ffd477")][i%4],4.0,true)
        draw_circle(p+Vector2(0,-10+bob),4.5,[Color("#f1c7a8"),Color("#d79b75"),Color("#b87655")][i%3])
        var arm := sin(t*1.4+float(i))*3.0
        draw_line(p+Vector2(0,-1+bob),p+Vector2(arm,5+bob),Color("#c7d3d8"),2.0,true)

func _draw_interior_room_labels(origin: Vector2) -> void:
    var labels: Array = []
    if interior_kind=="openai_hq":
        labels=[["LOBBY",Vector2(70,105)],["VISITOR LAB",Vector2(350,105)],["RESEARCH PODS",Vector2(330,455)]]
    elif interior_kind in ["garage","workshop"]:
        labels=[["SERVICE BAY",Vector2(300,105)],["TOOLS",Vector2(665,105)],["DIAGNOSTICS",Vector2(635,430)]]
    elif interior_kind in ["restaurant","cafe"]:
        labels=[["DINING",Vector2(320,105)],["KITCHEN",Vector2(675,105)],["LOUNGE",Vector2(330,445)]]
    elif interior_kind=="shop":
        labels=[["RETAIL",Vector2(310,105)],["STOCK",Vector2(675,105)],["CHECKOUT",Vector2(620,445)]]
    elif interior_kind=="home":
        labels=[["LIVING",Vector2(300,105)],["GARAGE",Vector2(665,105)],["PRIVATE",Vector2(320,445)]]
    for item in labels:
        draw_string(ThemeDB.fallback_font,origin+Vector2(item[1]),str(item[0]),HORIZONTAL_ALIGNMENT_LEFT,160,11,Color(0.72,0.84,0.88,0.62))

func _draw_openai_interior(origin: Vector2, accent: Color) -> void:
    if interior_floor==0:
        # Lobby / public visitor lab.
        draw_rect(Rect2(origin+Vector2(285,90),Vector2(330,115)),Color(0.44,0.71,0.79,0.10),true)
        draw_rect(Rect2(origin+Vector2(285,90),Vector2(330,115)),Color(0.83,0.94,0.97,0.34),false,2.0)
        for k in range(1,6):
            draw_line(origin+Vector2(285+k*55,90),origin+Vector2(285+k*55,205),Color(1,1,1,0.08),1.0)
        var feature := origin+_interior_feature_pos()
        draw_circle(feature,44,Color(0.95,0.98,0.98,0.06))
        draw_circle(feature,27,Color(0.95,0.98,0.98,0.04))
        for a in range(0,360,60):
            var d := Vector2.from_angle(deg_to_rad(float(a)))
            draw_arc(feature+d*14,12,0,TAU,16,Color(0.93,0.98,0.98,0.50),1.4,true)
        draw_string(ThemeDB.fallback_font,feature+Vector2(-68,58),"VISITOR LAB",HORIZONTAL_ALIGNMENT_CENTER,136,12,Color("#eaf5f6"))
        for q in [Vector2(330,330),Vector2(450,330),Vector2(570,330)]:
            var c: Vector2 = origin+Vector2(q)
            draw_rect(Rect2(c-Vector2(38,24),Vector2(76,48)),Color(0.10,0.17,0.20,0.9),true)
            draw_rect(Rect2(c-Vector2(38,24),Vector2(76,48)),Color(0.75,0.91,0.94,0.22),false,1.5)
            draw_line(c+Vector2(-24,0),c+Vector2(24,0),Color(0.45,0.86,0.91,0.32),2.0)
            draw_circle(c+Vector2(0,-8),4,Color("#73f3ce"))
        draw_rect(Rect2(origin+Vector2(70,140),Vector2(120,44)),Color("#24323a"),true)
        draw_string(ThemeDB.fallback_font,origin+Vector2(90,154),"WELCOME",HORIZONTAL_ALIGNMENT_CENTER,80,10,Color.WHITE)
    else:
        # Upper research floor: quieter, denser workstation / collaboration layout.
        draw_rect(Rect2(origin+Vector2(285,95),Vector2(330,82)),Color(0.30,0.55,0.64,0.10),true)
        draw_string(ThemeDB.fallback_font,origin+Vector2(365,125),"RESEARCH GALLERY",HORIZONTAL_ALIGNMENT_CENTER,170,13,Color("#e9f6f7"))
        for row in range(2):
            for col in range(4):
                var c := origin+Vector2(300+float(col)*95,235+float(row)*105)
                draw_rect(Rect2(c-Vector2(34,20),Vector2(68,40)),Color("#18252b"),true)
                draw_rect(Rect2(c+Vector2(-24,-16),Vector2(48,18)),Color(0.38,0.78,0.85,0.14),true)
                draw_circle(c+Vector2(0,7),3,Color("#73f3ce"))
        var collab := origin+Vector2(465,455)
        draw_circle(collab,58,Color("#25353d"))
        for ang in range(0,360,60):
            var d := Vector2.from_angle(deg_to_rad(float(ang)))
            draw_circle(collab+d*82,12,Color("#44545c"))
        draw_circle(collab,19,Color(accent.r,accent.g,accent.b,0.12))
        draw_string(ThemeDB.fallback_font,collab+Vector2(-65,-5),"COLLAB CORE",HORIZONTAL_ALIGNMENT_CENTER,130,11,Color("#dff2f3"))

func _draw_garage_interior(origin: Vector2, accent: Color) -> void:
    for x in [330.0,520.0]:
        var c := origin+Vector2(x,260)
        draw_rect(Rect2(c-Vector2(64,110),Vector2(128,220)),Color(0.10,0.12,0.14,0.82),true)
        draw_line(c+Vector2(-48,-82),c+Vector2(-48,82),Color(accent.r,accent.g,accent.b,0.36),4.0)
        draw_line(c+Vector2(48,-82),c+Vector2(48,82),Color(accent.r,accent.g,accent.b,0.36),4.0)
        draw_rect(Rect2(c-Vector2(35,18),Vector2(70,36)),Color("#59646b"),true)
    var feature := origin+_interior_feature_pos()
    draw_rect(Rect2(feature-Vector2(42,22),Vector2(84,44)),Color(0.08,0.12,0.14,0.95),true)
    draw_rect(Rect2(feature-Vector2(42,22),Vector2(84,44)),Color(accent.r,accent.g,accent.b,0.55),false,2.0)
    draw_string(ThemeDB.fallback_font,feature+Vector2(-30,-5),"SERVICE",HORIZONTAL_ALIGNMENT_CENTER,60,10,Color.WHITE)

func _draw_restaurant_interior(origin: Vector2, accent: Color) -> void:
    if interior_floor==0:
        for yy in [190.0,330.0]:
            for xx in [360.0,520.0]:
                var c := origin+Vector2(xx,yy)
                draw_circle(c,28,Color("#684e3f"))
                for a in range(0,360,90):
                    var d := Vector2.from_angle(deg_to_rad(float(a)))
                    draw_circle(c+d*45,10,Color("#334047"))
        var counter := origin+Vector2(730,190)
        draw_rect(Rect2(counter-Vector2(60,24),Vector2(120,48)),Color("#5e493d"),true)
        draw_line(counter+Vector2(-55,-18),counter+Vector2(55,-18),Color(accent.r,accent.g,accent.b,0.42),2.0)
    else:
        # Lounge / quiet seating floor.
        for x in [330.0,500.0,670.0]:
            var sofa := origin+Vector2(x,240)
            draw_rect(Rect2(sofa-Vector2(55,22),Vector2(110,44)),Color("#43515a"),true)
            draw_circle(sofa+Vector2(0,70),25,Color("#644d3f"))
        draw_rect(Rect2(origin+Vector2(300,390),Vector2(400,42)),Color(0.25,0.38,0.42,0.55),true)
        draw_string(ThemeDB.fallback_font,origin+Vector2(410,403),"SKY LOUNGE",HORIZONTAL_ALIGNMENT_CENTER,180,12,Color.WHITE)

func _draw_shop_interior(origin: Vector2, accent: Color) -> void:
    if interior_floor==0:
        for x in [330.0,450.0,570.0]:
            draw_rect(Rect2(origin+Vector2(x-32,130),Vector2(64,250)),Color("#263139"),true)
            for y in [175.0,235.0,295.0]:
                draw_line(origin+Vector2(x-26,y),origin+Vector2(x+26,y),Color(accent.r,accent.g,accent.b,0.28),2.0)
        var desk := origin+_interior_feature_pos()
        draw_rect(Rect2(desk-Vector2(45,20),Vector2(90,40)),Color("#36434a"),true)
    else:
        for x in [315.0,430.0,545.0,660.0]:
            draw_rect(Rect2(origin+Vector2(x-36,120),Vector2(72,300)),Color("#202a30"),true)
            for y in [170.0,230.0,290.0,350.0]:
                draw_rect(Rect2(origin+Vector2(x-27,y),Vector2(54,8)),Color(accent.r,accent.g,accent.b,0.18),true)
        draw_string(ThemeDB.fallback_font,origin+Vector2(395,455),"STOCK / PICKUP",HORIZONTAL_ALIGNMENT_CENTER,210,12,Color("#dbe9ee"))

func _draw_interior_player() -> void:
    var size := get_viewport_rect().size
    var origin := size*0.5-interior_size*0.5
    var p := origin+interior_player_pos
    var f := Vector2.from_angle(player_heading)
    var side := Vector2(-f.y,f.x)
    var walking := move_vec.length()>0.08
    var phase := Time.get_ticks_msec()/95.0 if walking else 0.0
    var swing := sin(phase)*4.0 if walking else 0.0
    _draw_poly_ellipse(p+Vector2(3,6),Vector2(9,5),player_heading,Color(0,0,0,0.24))
    draw_line(p,p+Vector2(-swing,13),Color("#667682"),3.0,true)
    draw_line(p,p+Vector2(swing,13),Color("#758692"),3.0,true)
    var chest := p+Vector2(0,-9)
    var torso := PackedVector2Array([chest+side*6-f*5,chest-side*6-f*5,p-side*6,p+side*6])
    draw_colored_polygon(torso,Color("#e8f2f6"))
    draw_circle(chest-f*10,5.0,Color("#e8ba96"))
    draw_arc(chest-f*10+Vector2(0,-1),5.1,PI,TAU,12,Color("#263039"),2.2,true)
    draw_line(chest-side*6,chest-side*6+Vector2(-swing,7),Color("#cfdde4"),2.2)
    draw_line(chest+side*6,chest+side*6+Vector2(swing,7),Color("#cfdde4"),2.2)

func _clear_game_ui() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    for child in game_controls.get_children():
        child.queue_free()

func _game_button(text_value: String, callback: Callable, active: bool = false) -> Button:
    var b := Button.new()
    b.text = text_value
    b.custom_minimum_size = Vector2(126,104)
    b.add_theme_font_size_override("font_size",28)
    if active:
        b.modulate = Color("#73f3ce")
    b.pressed.connect(_play_sfx.bind("hack_click"))
    b.pressed.connect(callback)
    return b

func _start_minigame(site: Dictionary) -> void:
    var sid := str(site.id)
    active_mission_replay = bool(hack_done.get(sid,false))
    active_mission_site = site
    game_type = str(site.game)
    minigame_open = true
    map_open = false
    missions_open = false
    move_vec = Vector2.ZERO
    game_panel.visible = true
    game_title.text = str(site.name)
    var diff: int = int(site.get("difficulty",1))
    game_info.text = "%s · Sicherheitsstufe %d · %s" % [("REPLAY" if active_mission_replay else "HACKING-SUBMISSION"),diff,("12 CR Replay-Bonus" if active_mission_replay else "Belohnung: %s" % str(site.reward))]
    game_status.text = ""
    _clear_game_ui()
    if game_type=="wire":
        _init_wire()
    elif game_type=="slide":
        _init_slide()
    elif game_type=="mastermind":
        _init_mastermind()
    elif game_type=="frequency":
        _init_frequency()
    elif game_type=="memory":
        _init_memory()
    else:
        _init_lightsout()

func _close_minigame() -> void:
    minigame_open = false
    game_panel.visible = false
    active_mission_site = {}
    game_type = ""
    move_vec = Vector2.ZERO

func _finish_minigame() -> void:
    if active_mission_site.is_empty():
        return
    var sid: String = str(active_mission_site.id)
    var site_name: String = str(active_mission_site.name)
    var site_reward: String = str(active_mission_site.reward)
    var was_replay: bool = active_mission_replay
    var reward_credits: int = 12 if was_replay else 35
    if was_replay:
        hack_replays += 1
    else:
        hack_done[sid] = true
    credits += reward_credits
    _save_game()
    _play_sfx("secret")
    _haptic(55)
    game_status.text = "ERFOLG · %s · +%d Credits" % [("Replay abgeschlossen" if was_replay else "%s erhalten" % site_reward),reward_credits]
    await get_tree().create_timer(0.65).timeout
    _close_minigame()
    _show_reward_popup("HACK ERFOLGREICH",("%s\n%s · +%d CR" % [site_name,("Replay" if was_replay else site_reward),reward_credits]),Color("#ffdf75"))
    _notify("%s %s." % [site_name,("wiederholt" if was_replay else "abgeschlossen")])
    active_mission_replay=false
    _advance_native_chapter()
    _check_npc_contract()

func _wire_bit_for_delta(d: Vector2i) -> int:
    if d==Vector2i(0,-1): return 1
    if d==Vector2i(1,0): return 2
    if d==Vector2i(0,1): return 4
    return 8

func _rotate_wire_mask(mask: int) -> int:
    var out := 0
    if mask&1: out|=2
    if mask&2: out|=4
    if mask&4: out|=8
    if mask&8: out|=1
    return out

func _wire_symbol(mask: int) -> String:
    match mask:
        10: return "━"
        5: return "┃"
        3: return "┗"
        6: return "┏"
        12: return "┓"
        9: return "┛"
        _: return "•"

func _init_wire() -> void:
    var diff: int = int(active_mission_site.get("difficulty",1))
    var cols: int = 5 if diff>=3 else 4
    var rows: int = cols
    game_grid.columns = cols
    var total: int = cols*rows
    game_target = []
    game_current = []
    game_target.resize(total)
    game_current.resize(total)
    for i in range(total):
        game_target[i]=0

    # Build one guaranteed connected snake from the left edge through every tile.
    var path: Array = []
    for x in range(cols):
        if x%2==0:
            for y in range(rows):
                path.append(Vector2i(x,y))
        else:
            for y in range(rows-1,-1,-1):
                path.append(Vector2i(x,y))

    for i in range(path.size()-1):
        var a: Vector2i = path[i]
        var b: Vector2i = path[i+1]
        var da: Vector2i = b-a
        var db: Vector2i = a-b
        var ia: int = a.y*cols+a.x
        var ib: int = b.y*cols+b.x
        game_target[ia]=int(game_target[ia])|_wire_bit_for_delta(da)
        game_target[ib]=int(game_target[ib])|_wire_bit_for_delta(db)

    var start_index: int = int(path[0].y)*cols+int(path[0].x)
    var end_pos: Vector2i = path[path.size()-1]
    var end_index: int = end_pos.y*cols+end_pos.x
    game_target[start_index]=int(game_target[start_index])|8
    game_target[end_index]=int(game_target[end_index])|2
    game_secret=[end_index,cols]

    for i in range(total):
        var mask: int = int(game_target[i])
        var turns: int = rng.randi_range(0,3)
        for _t in range(turns):
            mask=_rotate_wire_mask(mask)
        game_current[i]=mask

    game_status.text = "Verbinde SOURCE links mit TARGET rechts. Alle %d Leitungsfelder müssen Teil des Netzes sein." % total
    _render_wire()

func _render_wire() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    var cols: int = int(game_secret[1])
    var end_index: int = int(game_secret[0])
    for i in range(game_current.size()):
        var idx := i
        var label := _wire_symbol(int(game_current[i]))
        if i==0:
            label="S "+label
        elif i==end_index:
            label=label+" T"
        var button := _game_button(label,_on_wire_cell.bind(idx))
        if _wire_reachable_cells().has(i):
            button.modulate=Color("#73f3ce")
        game_grid.add_child(button)
    game_info.text = "%s · Netz %d×%d" % [("REPLAY" if active_mission_replay else "HACKING-SUBMISSION"),cols,cols]
    await get_tree().process_frame

func _wire_reachable_cells() -> Array:
    var out: Array = []
    if game_current.is_empty() or game_secret.size()<2:
        return out
    var cols: int = int(game_secret[1])
    var rows: int = int(game_current.size()/cols)
    if (int(game_current[0])&8)==0:
        return out
    var queue: Array = [0]
    var seen: Dictionary = {0:true}
    var dirs := [
        [Vector2i(0,-1),1,4],
        [Vector2i(1,0),2,8],
        [Vector2i(0,1),4,1],
        [Vector2i(-1,0),8,2]
    ]
    while not queue.is_empty():
        var idx: int = int(queue.pop_front())
        out.append(idx)
        var x: int = idx%cols
        var y: int = int(idx/cols)
        var mask: int = int(game_current[idx])
        for entry in dirs:
            var d: Vector2i = entry[0]
            var bit: int = int(entry[1])
            var opposite: int = int(entry[2])
            if (mask&bit)==0:
                continue
            var nx: int = x+d.x
            var ny: int = y+d.y
            if nx<0 or nx>=cols or ny<0 or ny>=rows:
                continue
            var ni: int = ny*cols+nx
            if (int(game_current[ni])&opposite)==0:
                continue
            if not seen.has(ni):
                seen[ni]=true
                queue.append(ni)
    return out

func _wire_solved() -> bool:
    if game_secret.size()<2:
        return false
    var end_index: int = int(game_secret[0])
    var reachable := _wire_reachable_cells()
    return reachable.size()==game_current.size() and reachable.has(end_index) and (int(game_current[end_index])&2)!=0

func _on_wire_cell(index: int) -> void:
    game_current[index]=_rotate_wire_mask(int(game_current[index]))
    _play_sfx("hack_click")
    _render_wire()
    if _wire_solved():
        _finish_minigame()

func _init_slide() -> void:
    game_grid.columns = 3
    game_current = [1,2,3,4,5,6,7,8,0]
    var diff: int = int(active_mission_site.get("difficulty",1))
    for k in range(55+diff*35):
        var z := game_current.find(0)
        var opts: Array = []
        if z-3>=0: opts.append(z-3)
        if z+3<9: opts.append(z+3)
        if z%3>0: opts.append(z-1)
        if z%3<2: opts.append(z+1)
        var q: int = int(opts[rng.randi_range(0,opts.size()-1)])
        var tmp = game_current[z]
        game_current[z] = game_current[q]
        game_current[q] = tmp
    game_status.text = "Ordne die Routing-Kacheln von 1 bis 8."
    _render_slide()

func _render_slide() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    for i in range(9):
        var idx := i
        var val := int(game_current[i])
        game_grid.add_child(_game_button("" if val==0 else str(val),_on_slide_cell.bind(idx),val==0))
    await get_tree().process_frame

func _on_slide_cell(index: int) -> void:
    var z := game_current.find(0)
    var valid: bool = abs(index-z)==3 or (int(index/3)==int(z/3) and abs(index-z)==1)
    if not valid:
        _play_sfx("error")
        return
    var tmp = game_current[index]
    game_current[index] = game_current[z]
    game_current[z] = tmp
    _render_slide()
    var solved := true
    for i in range(8):
        if int(game_current[i]) != i+1:
            solved = false
            break
    if solved and int(game_current[8])==0:
        _finish_minigame()

func _init_mastermind() -> void:
    game_grid.columns = 4
    game_secret = []
    game_guess = [1,1,1,1]
    game_tries = 0
    var diff: int = int(active_mission_site.get("difficulty",1))
    var max_digit: int = mini(8,5+diff)
    for i in range(4):
        game_secret.append(rng.randi_range(1,max_digit))
    game_status.text = "Zahlenbereich 1–%d · Tippe jede Stelle zum Hochzählen. Dann TEST." % max_digit
    _render_mastermind()

func _render_mastermind() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    for i in range(4):
        var idx := i
        game_grid.add_child(_game_button(str(game_guess[i]),_on_mastermind_digit.bind(idx)))
    for child in game_controls.get_children():
        child.queue_free()
    var test := Button.new()
    test.text = "TEST"
    test.custom_minimum_size = Vector2(180,70)
    test.pressed.connect(_test_mastermind)
    game_controls.add_child(test)
    await get_tree().process_frame

func _on_mastermind_digit(index: int) -> void:
    var diff: int = int(active_mission_site.get("difficulty",1))
    var max_digit: int = mini(8,5+diff)
    game_guess[index] = (int(game_guess[index])%max_digit)+1
    _play_sfx("hack_click")
    _render_mastermind()

func _test_mastermind() -> void:
    game_tries += 1
    var exact := 0
    var near := 0
    var remaining_secret: Array = []
    var remaining_guess: Array = []
    for i in range(4):
        if int(game_guess[i])==int(game_secret[i]):
            exact += 1
        else:
            remaining_secret.append(game_secret[i])
            remaining_guess.append(game_guess[i])
    for v in remaining_guess:
        var pos := remaining_secret.find(v)
        if pos>=0:
            near += 1
            remaining_secret.remove_at(pos)
    game_status.text = "Versuch %d · %d exakt · %d richtige Zahl/falsche Position" % [game_tries,exact,near]
    if exact==4:
        _finish_minigame()

func _init_frequency() -> void:
    game_grid.columns = 4
    game_target = []
    game_current = []
    for i in range(4):
        game_target.append(rng.randi_range(0,4))
        game_current.append(rng.randi_range(0,4))
    game_info.text = "Ziel-Spektrum: %s" % _frequency_text(game_target)
    game_status.text = "Tippe jeden Kanal bis das Ziel-Spektrum erreicht ist."
    _render_frequency()

func _frequency_text(values: Array) -> String:
    var symbols := ["▁","▂","▃","▄","▅"]
    var out := ""
    for v in values:
        out += str(symbols[int(v)])+" "
    return out.strip_edges()

func _render_frequency() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    var symbols := ["▁","▂","▃","▄","▅"]
    for i in range(4):
        var idx := i
        game_grid.add_child(_game_button(str(symbols[int(game_current[i])]),_on_frequency_cell.bind(idx)))
    await get_tree().process_frame

func _on_frequency_cell(index: int) -> void:
    game_current[index] = (int(game_current[index])+1)%5
    _render_frequency()
    var ok := true
    for i in range(4):
        if int(game_current[i])!=int(game_target[i]):
            ok = false
    if ok:
        _finish_minigame()

func _init_memory() -> void:
    game_grid.columns = 3
    game_memory_seq = []
    game_memory_input = []
    game_memory_locked = true
    var diff: int = int(active_mission_site.get("difficulty",1))
    for i in range(4+diff*2):
        game_memory_seq.append(rng.randi_range(0,8))
    _render_memory()
    _show_memory_sequence()

func _render_memory(highlight: int = -1) -> void:
    for child in game_grid.get_children():
        child.queue_free()
    for i in range(9):
        var idx := i
        game_grid.add_child(_game_button(str(i+1),_on_memory_cell.bind(idx),i==highlight))
    await get_tree().process_frame

func _show_memory_sequence() -> void:
    game_memory_locked = true
    game_status.text = "Paketfolge merken …"
    for v in game_memory_seq:
        _render_memory(int(v))
        await get_tree().create_timer(0.34).timeout
        _render_memory(-1)
        await get_tree().create_timer(0.16).timeout
    game_memory_locked = false
    game_status.text = "Jetzt die Paketfolge wiederholen."

func _on_memory_cell(index: int) -> void:
    if game_memory_locked:
        return
    game_memory_input.append(index)
    if int(game_memory_input[-1]) != int(game_memory_seq[game_memory_input.size()-1]):
        game_memory_input.clear()
        _play_sfx("error")
        game_status.text = "Falsche Folge · Sequenz erneut."
        _show_memory_sequence()
        return
    if game_memory_input.size()==game_memory_seq.size():
        _finish_minigame()

func _init_lightsout() -> void:
    game_grid.columns = 4
    game_current = []
    for i in range(16):
        game_current.append(false)
    var diff: int = int(active_mission_site.get("difficulty",1))
    for k in range(7+diff*5):
        _toggle_light(rng.randi_range(0,15))
    game_status.text = "Schalte das Firewall-Raster vollständig dunkel."
    _render_lightsout()

func _toggle_light(index: int) -> void:
    var r: int = int(index/4)
    var c: int = index%4
    for delta in [Vector2i(0,0),Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
        var rr: int = r+int(delta.x)
        var cc: int = c+int(delta.y)
        if rr>=0 and rr<4 and cc>=0 and cc<4:
            var j: int = rr*4+cc
            game_current[j] = not bool(game_current[j])

func _render_lightsout() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    for i in range(16):
        var idx := i
        game_grid.add_child(_game_button("●" if bool(game_current[i]) else "○",_on_lightsout_cell.bind(idx),bool(game_current[i])))
    await get_tree().process_frame

func _on_lightsout_cell(index: int) -> void:
    _toggle_light(index)
    _render_lightsout()
    var any_on := false
    for v in game_current:
        if bool(v): any_on = true
    if not any_on:
        _finish_minigame()

func _toggle_transit(index: int) -> void:
    if transit_riding>=0:
        var ride: Dictionary = transit_vehicles[transit_riding]
        if not bool(ride.get("at_stop",false)):
            _notify("Aussteigen erst am nächsten Halt.")
            return
        var road = roads[int(ride.road)]
        var tang := _polyline_tangent(road.points,float(ride.t))
        var normal := Vector2(-tang.y,tang.x)
        player_pos = _sample_polyline(road.points,float(ride.t)) + normal*85.0
        transit_riding=-1
        transit_trip_count+=1
        _play_sfx("vehicle")
        _notify("ÖPNV verlassen.")
        _check_npc_contract()
        _save_game()
        return
    if index<0 or index>=transit_vehicles.size():
        return
    var tv: Dictionary = transit_vehicles[index]
    if not bool(tv.get("at_stop",false)):
        _notify("Fahrzeug ist nicht am Halt.")
        return
    transit_riding=index
    current_vehicle=-1
    vehicle_velocity=0.0
    _play_sfx("vehicle")
    _notify("%s bestiegen." % str(tv.line))

func _read_save_summary(slot: int) -> Dictionary:
    var path := _save_path(slot)
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path,FileAccess.READ)
    if not file:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        return parsed
    return {}

func _latest_save_slot() -> int:
    var best_slot := 0
    var best_time := -1.0
    for slot in range(1,4):
        var d := _read_save_summary(slot)
        if d.is_empty():
            continue
        var stamp := float(d.get("saved_at",0.0))
        if stamp>best_time:
            best_time=stamp
            best_slot=slot
    return best_slot

func _refresh_main_menu() -> void:
    if main_menu_panel==null:
        return
    main_menu_panel.visible=main_menu_active
    for slot in range(1,4):
        var d := _read_save_summary(slot)
        var b: Button = menu_slot_buttons[slot-1]
        if d.is_empty():
            b.text = "SPIELSTAND %d · LEER" % slot
        else:
            var ch: int = int(d.get("chapter",0))+1
            var cr: int = int(d.get("credits",0))
            b.text = "SPIELSTAND %d · Mission %02d · %d CR" % [slot,ch,cr]
    if new_game_mode:
        menu_status.text="NEUES SPIEL · Slot wählen (vorhandener Stand wird überschrieben)"
    else:
        menu_status.text="Fortsetzen oder einen der drei Spielstände wählen."
    _refresh_option_labels()

func _continue_latest_save() -> void:
    var slot := _latest_save_slot()
    if slot<=0:
        new_game_mode=true
        _refresh_main_menu()
        return
    _start_game_from_slot(slot,false)

func _select_new_game_mode() -> void:
    new_game_mode=true
    _refresh_main_menu()

func _select_save_slot(slot: int) -> void:
    var exists := FileAccess.file_exists(_save_path(slot))
    _start_game_from_slot(slot,new_game_mode or not exists)

func _start_game_from_slot(slot: int, fresh: bool) -> void:
    selected_save_slot=clampi(slot,1,3)
    if fresh:
        _reset_game_state()
    else:
        _load_game(selected_save_slot)
    main_menu_active=false
    new_game_mode=false
    main_menu_panel.visible=false
    options_box.visible=false
    camera_pos=player_pos
    current_district=str(_district_at(player_pos).get("name","Megacity"))
    if fresh:
        _save_game()
    _play_sfx("collect")
    queue_redraw()

func _reset_game_state() -> void:
    player_pos=Vector2(5200,4200)
    camera_pos=player_pos
    credits=520
    energy=100.0
    owned_property=""
    owned_cars.clear()
    current_paint=""
    jobs_done=0
    active_job={}
    hack_done.clear()
    npc_flags.clear()
    npc_trust.clear()
    npc_contracts_done.clear()
    active_npc_contract={}
    transit_trip_count=0
    vertical_flags.clear()
    relay_count=0
    sublevel_count=0
    native_chapter=0
    mission_fragments=0
    mission_secrets=0
    cache_count=0
    glyph_count=0
    photo_count=0
    scan_collect_count=0
    for i in range(scan_points.size()):
        scan_points[i]["taken"]=false
    visited_districts.clear()
    driven_classes.clear()
    hack_replays=0
    race_best.clear()
    race_wins=0
    race_completed.clear()
    vehicle_upgrades.clear()
    milestones_claimed.clear()
    active_race={}
    for i in range(photo_points.size()):
        photo_points[i]["taken"]=false
    inventory={"scan_cell":0,"energy_drink":0,"transit_pass":0}
    shop_stock={"energy_drink":8,"scan_cell":6,"transit_pass":3}
    transit_riding=-1
    current_vehicle=-1
    service_vehicle_index=-1
    for i in range(fragments.size()):
        fragments[i]["taken"]=false
    for i in range(secrets.size()):
        secrets[i]["found"]=false
        secrets[i]["revealed"]=false
    for i in range(caches.size()):
        caches[i]["taken"]=false
    for i in range(glyphs.size()):
        glyphs[i]["taken"]=false
    _save_game()

func _return_to_main_menu() -> void:
    if photo_mode:
        _exit_photo_mode()
    _save_game()
    minigame_open=false
    game_panel.visible=false
    commerce_panel.visible=false
    dialogue_panel.visible=false
    map_open=false
    missions_open=false
    collection_open=false
    main_menu_active=true
    main_menu_panel.visible=true
    move_vec=Vector2.ZERO
    _refresh_main_menu()

func _toggle_options_box() -> void:
    options_box.visible=not options_box.visible

func _cycle_sound_option() -> void:
    sound_enabled=not sound_enabled
    _save_options()
    _refresh_option_labels()

func _cycle_graphics_option() -> void:
    graphics_quality=(graphics_quality+1)%3
    _save_options()
    _refresh_option_labels()

func _cycle_pmdd_option() -> void:
    if parallax_strength<1.35:
        parallax_strength=1.75
    elif parallax_strength<2.05:
        parallax_strength=2.35
    else:
        parallax_strength=1.10
    _save_options()
    _refresh_option_labels()

func _cycle_haptics() -> void:
    haptics_enabled=not haptics_enabled
    _save_options()
    _refresh_option_labels()

func _cycle_drive_assist() -> void:
    driving_assist=not driving_assist
    _save_options()
    _refresh_option_labels()

func _cycle_sensor_option() -> void:
    if sensor_gain<0.8:
        sensor_gain=1.0
    elif sensor_gain<1.25:
        sensor_gain=1.5
    else:
        sensor_gain=0.6
    _save_options()
    _refresh_option_labels()

func _refresh_option_labels() -> void:
    if sound_option_button==null:
        return
    sound_option_button.text="Sound · %s" % ("AN" if sound_enabled else "AUS")
    var qualities := ["ECO","BALANCED","HIGH"]
    graphics_option_button.text="Grafik · %s" % qualities[graphics_quality]
    pmdd_option_button.text="PMDD Tiefe · %.2fx" % parallax_strength
    sensor_option_button.text="Sensor-Empfindlichkeit · %.1fx" % sensor_gain
    if drive_option_button!=null:
        drive_option_button.text="Fahrhilfe · %s" % ("AN" if driving_assist else "AUS")
    if haptics_option_button!=null:
        haptics_option_button.text="Haptik · %s" % ("AN" if haptics_enabled else "AUS")

func _save_options() -> void:
    var f := FileAccess.open("user://parallaxhunt_options.json",FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"sound":sound_enabled,"graphics":graphics_quality,"pmdd":parallax_strength,"sensor":sensor_gain,"drive_assist":driving_assist,"haptics":haptics_enabled}))

func _load_options() -> void:
    if not FileAccess.file_exists("user://parallaxhunt_options.json"):
        return
    var f := FileAccess.open("user://parallaxhunt_options.json",FileAccess.READ)
    if not f:
        return
    var d = JSON.parse_string(f.get_as_text())
    if d is Dictionary:
        sound_enabled=bool(d.get("sound",sound_enabled))
        graphics_quality=clampi(int(d.get("graphics",graphics_quality)),0,2)
        parallax_strength=float(d.get("pmdd",parallax_strength))
        sensor_gain=float(d.get("sensor",sensor_gain))
        driving_assist=bool(d.get("drive_assist",driving_assist))
        haptics_enabled=bool(d.get("haptics",haptics_enabled))

func _draw_title_art() -> void:
    var size := get_viewport_rect().size
    var t := Time.get_ticks_msec()/1000.0
    # Atmospheric gradient bands.
    draw_rect(Rect2(Vector2.ZERO,size),Color("#07131b"),true)
    draw_rect(Rect2(0,size.y*0.38,size.x,size.y*0.62),Color("#0d2029"),true)
    var horizon := size.y*0.43
    # Three PMDD skyline layers with slow independent drift.
    for layer in range(3):
        var layer_y := horizon + float(layer)*85.0
        var alpha := 0.24+float(layer)*0.17
        var drift := sin(t*(0.18+float(layer)*0.05))*18.0*float(layer+1)
        for i in range(13):
            var w := 60.0+float((i*37+layer*29)%70)
            var h := 110.0+float((i*71+layer*43)%230)
            var x := -40.0+float(i)*92.0+drift
            var col := Color(0.12+layer*0.035,0.26+layer*0.045,0.32+layer*0.05,alpha)
            draw_rect(Rect2(x,layer_y-h,w,h),col,true)
            if (i+layer)%3==0:
                draw_line(Vector2(x+8,layer_y-h+18),Vector2(x+w-8,layer_y-h+18),Color(0.45,0.95,0.82,0.10+alpha*0.35),2.0)
    # Perspective road.
    var road_top := Vector2(size.x*0.5,horizon+120)
    var road_bottom_y := size.y
    var road_poly := PackedVector2Array([
        road_top+Vector2(-55,0),road_top+Vector2(55,0),
        Vector2(size.x*0.88,road_bottom_y),Vector2(size.x*0.12,road_bottom_y)
    ])
    draw_colored_polygon(road_poly,Color("#111b21"))
    for k in range(8):
        var yy := lerpf(road_top.y,road_bottom_y,float(k)/8.0)
        var span := lerpf(8.0,170.0,float(k)/8.0)
        draw_line(Vector2(size.x*0.5-span*0.08,yy),Vector2(size.x*0.5+span*0.08,yy),Color(0.85,0.90,0.82,0.26),3.0)
    # PMDD secret pulse.
    var pulse := Vector2(size.x*0.5,horizon-145)
    var pr := 42.0+sin(t*2.0)*8.0
    draw_circle(pulse,pr,Color(0.45,0.95,0.82,0.035))
    draw_arc(pulse,pr,0,TAU,36,Color(0.45,0.95,0.82,0.33),2.0,true)
    draw_arc(pulse,pr*0.55,t*0.3,t*0.3+PI*1.55,28,Color("#9ad5ff"),2.0,true)

func _save_path(slot: int = selected_save_slot) -> String:
    return "user://parallaxhunt_save_%d.json" % clampi(slot,1,3)

func _save_game() -> void:
    if main_menu_active:
        return
    var data := {
        "player":[player_pos.x,player_pos.y],
        "credits":credits,
        "energy":energy,
        "owned_property":owned_property,
        "owned_cars":owned_cars,
        "current_paint":current_paint,
        "jobs_done":jobs_done,
        "active_job":_serialize_job(active_job),
        "hack_done":hack_done,
        "chapter":native_chapter,
        "inventory":inventory,
        "shop_stock":shop_stock,
        "frag_count":mission_fragments,
        "secret_count":mission_secrets,
        "cache_count":cache_count,
        "glyph_count":glyph_count,
        "photo_count":photo_count,
        "photos":photo_points.map(func(x): return bool(x.taken)),
        "photo_found":photo_found,
        "photo_scores":photo_scores,
        "scan_collect_count":scan_collect_count,
        "scan_points":scan_points.map(func(x): return bool(x.taken)),
        "visited_districts":visited_districts,
        "driven_classes":driven_classes,
        "hack_replays":hack_replays,
        "race_best":race_best,
        "race_wins":race_wins,
        "race_completed":race_completed,
        "vehicle_upgrades":vehicle_upgrades,
        "milestones_claimed":milestones_claimed,
        "npc_flags":npc_flags,
        "npc_trust":npc_trust,
        "npc_contracts_done":npc_contracts_done,
        "active_npc_contract":_serialize_contract(active_npc_contract),
        "transit_trip_count":transit_trip_count,
        "vertical_flags":vertical_flags,
        "relay_count":relay_count,
        "sublevel_count":sublevel_count,
        "caches":caches.map(func(x): return bool(x.taken)),
        "glyphs":glyphs.map(func(x): return bool(x.taken)),
        "saved_at":Time.get_unix_time_from_system(),
        "slot":selected_save_slot
    }
    var file := FileAccess.open(_save_path(),FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))

func _load_game(slot: int = selected_save_slot) -> void:
    selected_save_slot=clampi(slot,1,3)
    if not FileAccess.file_exists(_save_path()):
        return
    var file := FileAccess.open(_save_path(),FileAccess.READ)
    if not file:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        return
    var d: Dictionary = parsed
    if d.has("player") and d.player is Array and d.player.size()>=2:
        player_pos = Vector2(float(d.player[0]),float(d.player[1]))
    credits = int(d.get("credits",credits))
    energy = float(d.get("energy",energy))
    owned_property = str(d.get("owned_property",""))
    owned_cars = Array(d.get("owned_cars",[]))
    current_paint = str(d.get("current_paint",""))
    jobs_done = int(d.get("jobs_done",0))
    active_job = _deserialize_job(Dictionary(d.get("active_job",{})))
    hack_done = Dictionary(d.get("hack_done",{}))
    native_chapter = int(d.get("chapter",0))
    inventory = Dictionary(d.get("inventory",inventory))
    shop_stock = Dictionary(d.get("shop_stock",shop_stock))
    mission_fragments = int(d.get("frag_count",0))
    mission_secrets = int(d.get("secret_count",0))
    cache_count = int(d.get("cache_count",0))
    glyph_count = int(d.get("glyph_count",0))
    photo_count = int(d.get("photo_count",0))
    scan_collect_count = int(d.get("scan_collect_count",0))
    var scan_taken = d.get("scan_points",[])
    if scan_taken is Array:
        for i in range(mini(scan_taken.size(),scan_points.size())):
            scan_points[i]["taken"]=bool(scan_taken[i])
    photo_found = Dictionary(d.get("photo_found",{}))
    photo_scores = Dictionary(d.get("photo_scores",{}))
    var photo_taken = d.get("photos",[])
    if photo_taken is Array:
        for i in range(mini(photo_taken.size(),photo_points.size())):
            photo_points[i]["taken"]=bool(photo_taken[i])
    visited_districts = Dictionary(d.get("visited_districts",{}))
    driven_classes = Dictionary(d.get("driven_classes",{}))
    hack_replays = int(d.get("hack_replays",0))
    race_best = Dictionary(d.get("race_best",{}))
    race_wins = int(d.get("race_wins",0))
    race_completed = Dictionary(d.get("race_completed",{}))
    vehicle_upgrades = Dictionary(d.get("vehicle_upgrades",{}))
    milestones_claimed = Dictionary(d.get("milestones_claimed",{}))
    npc_flags = Dictionary(d.get("npc_flags",{}))
    npc_trust = Dictionary(d.get("npc_trust",{}))
    npc_contracts_done = Dictionary(d.get("npc_contracts_done",{}))
    active_npc_contract = _deserialize_contract(Dictionary(d.get("active_npc_contract",{})))
    transit_trip_count = int(d.get("transit_trip_count",0))
    vertical_flags = Dictionary(d.get("vertical_flags",{}))
    relay_count = int(d.get("relay_count",0))
    sublevel_count = int(d.get("sublevel_count",0))
    var cache_taken = d.get("caches",[])
    if cache_taken is Array:
        for i in range(mini(cache_taken.size(),caches.size())):
            caches[i]["taken"]=bool(cache_taken[i])
    var glyph_taken = d.get("glyphs",[])
    if glyph_taken is Array:
        for i in range(mini(glyph_taken.size(),glyphs.size())):
            glyphs[i]["taken"]=bool(glyph_taken[i])

func _serialize_contract(c: Dictionary) -> Dictionary:
    if c.is_empty():
        return {}
    var out := c.duplicate(true)
    if out.has("target") and out.target is Vector2:
        var t: Vector2 = Vector2(out.target)
        out["target"]=[t.x,t.y]
    return out

func _deserialize_contract(c: Dictionary) -> Dictionary:
    if c.is_empty():
        return {}
    var out := c.duplicate(true)
    var target = out.get("target",[])
    if target is Array and target.size()>=2:
        out["target"]=Vector2(float(target[0]),float(target[1]))
    return out

func _serialize_job(job: Dictionary) -> Dictionary:
    if job.is_empty():
        return {}
    var out := job.duplicate(true)
    if out.has("target") and out.target is Vector2:
        var t: Vector2 = Vector2(out.target)
        out["target"]=[t.x,t.y]
    return out

func _deserialize_job(job: Dictionary) -> Dictionary:
    if job.is_empty():
        return {}
    var out := job.duplicate(true)
    var target = out.get("target",[])
    if target is Array and target.size()>=2:
        out["target"]=Vector2(float(target[0]),float(target[1]))
    return out

func _commerce_button(label_text: String, callback: Callable) -> Button:
    var b := Button.new()
    b.text = label_text
    b.custom_minimum_size = Vector2(0,72)
    b.add_theme_font_size_override("font_size",18)
    b.pressed.connect(callback)
    return b

func _clear_commerce_actions() -> void:
    for child in commerce_actions.get_children():
        child.queue_free()

func _open_commerce(title: String, info: String) -> void:
    commerce_title.text = title
    commerce_info.text = info
    commerce_panel.visible = true
    _clear_commerce_actions()

func _close_commerce() -> void:
    commerce_panel.visible = false

func _use_interior_feature() -> void:
    if commerce_panel.visible:
        return
    if interior_kind in ["roof","sublevel"]:
        _activate_vertical_feature()
    elif interior_kind in ["restaurant","cafe"]:
        _open_restaurant_menu()
    elif interior_kind=="shop":
        _open_shop_menu()
    elif interior_kind in ["garage","workshop"]:
        _open_garage_menu()
    elif interior_kind=="home":
        _open_home_garage_menu()
    else:
        _play_sfx("collect")
        _notify(_interior_feature_message())

func _open_restaurant_menu() -> void:
    _open_commerce(interior_name,"Energie %d%% · Credits %d" % [int(energy),credits])
    commerce_actions.add_child(_commerce_button("Snack · 10 CR · +22 Energie",_buy_food.bind(10,22.0)))
    commerce_actions.add_child(_commerce_button("Warme Mahlzeit · 24 CR · +55 Energie",_buy_food.bind(24,55.0)))
    commerce_actions.add_child(_commerce_button("Ausruhen · 38 CR · volle Energie",_buy_food.bind(38,100.0)))

func _buy_food(cost: int, amount: float) -> void:
    if credits < cost:
        _notify("Nicht genug Credits.")
        return
    credits -= cost
    energy = 100.0 if amount>=100.0 else minf(100.0,energy+amount)
    _play_sfx("collect")
    _save_game()
    _open_restaurant_menu()

func _open_shop_menu() -> void:
    _open_commerce(interior_name,"Inventar · Credits %d" % credits)
    commerce_actions.add_child(_commerce_button("Energy Drink · 18 CR · Bestand %d" % int(shop_stock.get("energy_drink",0)),_buy_shop_item.bind("energy_drink",18)))
    commerce_actions.add_child(_commerce_button("Scan Cell · 20 CR · Bestand %d" % int(shop_stock.get("scan_cell",0)),_buy_shop_item.bind("scan_cell",20)))
    commerce_actions.add_child(_commerce_button("Transit Pass · 35 CR · Bestand %d" % int(shop_stock.get("transit_pass",0)),_buy_shop_item.bind("transit_pass",35)))

func _buy_shop_item(item: String, cost: int) -> void:
    var stock: int = int(shop_stock.get(item,0))
    if stock<=0:
        _notify("Ausverkauft.")
        return
    if credits<cost:
        _notify("Nicht genug Credits.")
        return
    credits -= cost
    shop_stock[item]=stock-1
    inventory[item]=int(inventory.get(item,0))+1
    if item=="energy_drink":
        energy=minf(100.0,energy+30.0)
        inventory[item]=maxi(0,int(inventory[item])-1)
    elif item=="scan_cell":
        scan_time=2.2
        inventory[item]=maxi(0,int(inventory[item])-1)
    _play_sfx("collect")
    _save_game()
    _open_shop_menu()

func _open_garage_menu() -> void:
    _open_commerce(interior_name,"Werkstatt · Lackierung + klassenbasiertes Performance-Tuning.")
    var colors := [["Arctic",Color("#e7edf1")],["Crimson",Color("#e95862")],["Ocean",Color("#5ba8df")],["Mint",Color("#66d7b0")],["Violet",Color("#9b7ad7")],["Sunburst",Color("#efcf55")]]
    for entry in colors:
        commerce_actions.add_child(_commerce_button("Lack %s · 45 CR" % str(entry[0]),_paint_current_vehicle.bind(str(entry[0]),Color(entry[1]))))
    var idx: int = service_vehicle_index if service_vehicle_index>=0 else current_vehicle
    if idx>=0 and idx<parked_cars.size():
        var cls: String = str(parked_cars[idx]["class"])
        var up: Dictionary = _vehicle_upgrade_state(cls)
        commerce_actions.add_child(_commerce_button("Motor Stufe %d → %d · %d CR" % [int(up.engine),mini(3,int(up.engine)+1),_upgrade_cost(int(up.engine))],_buy_vehicle_upgrade.bind(cls,"engine")))
        commerce_actions.add_child(_commerce_button("Handling Stufe %d → %d · %d CR" % [int(up.handling),mini(3,int(up.handling)+1),_upgrade_cost(int(up.handling))],_buy_vehicle_upgrade.bind(cls,"handling")))
        commerce_actions.add_child(_commerce_button("Bremsen Stufe %d → %d · %d CR" % [int(up.brake),mini(3,int(up.brake)+1),_upgrade_cost(int(up.brake))],_buy_vehicle_upgrade.bind(cls,"brake")))

func _paint_current_vehicle(paint_name: String, color: Color) -> void:
    var idx: int = service_vehicle_index if service_vehicle_index>=0 else current_vehicle
    if idx<0 or idx>=parked_cars.size():
        _notify("Du musst mit einem Auto zur Werkstatt kommen.")
        return
    if credits<45:
        _notify("Nicht genug Credits.")
        return
    credits-=45
    parked_cars[idx]["color"]=color
    current_paint=paint_name
    _play_sfx("vehicle")
    _save_game()
    _advance_native_chapter()
    _open_garage_menu()

func _open_home_garage_menu() -> void:
    _open_commerce(interior_name,"Eigene Garage · gespeicherte Fahrzeuge: %d" % owned_cars.size())
    commerce_actions.add_child(_commerce_button("Aktuelles Fahrzeug einlagern",_store_current_vehicle))
    for i in range(owned_cars.size()):
        var car: Dictionary = Dictionary(owned_cars[i])
        var stored_cls: String = str(car.get("class","sedan"))
        commerce_actions.add_child(_commerce_button("Ausparken: %s · %s" % [stored_cls.capitalize(),str(VEHICLE_SPEED_GROUP.get(stored_cls,"ROAD"))],_spawn_owned_car.bind(i)))

func _store_current_vehicle() -> void:
    var idx: int = service_vehicle_index if service_vehicle_index>=0 else current_vehicle
    if idx<0 or idx>=parked_cars.size():
        _notify("Kein Fahrzeug zum Einlagern.")
        return
    var cap := 5
    for p in property_sites:
        if str(p.id)==owned_property:
            cap=int(p.garage)
    if owned_cars.size()>=cap:
        _notify("Garage voll.")
        return
    var car: Dictionary = parked_cars[idx]
    owned_cars.append({"class":str(car["class"]),"color":car["color"].to_html(false)})
    car["occupied"]=false
    parked_cars[idx]=car
    if current_vehicle==idx:
        current_vehicle=-1
    service_vehicle_index=-1
    vehicle_velocity=0.0
    _save_game()
    _advance_native_chapter()
    _open_home_garage_menu()

func _spawn_owned_car(index: int) -> void:
    if index<0 or index>=owned_cars.size():
        return
    var saved: Dictionary = Dictionary(owned_cars[index])
    owned_cars.remove_at(index)
    var color := Color("#d6dce2")
    var html := str(saved.get("color","d6dce2"))
    color = Color("#"+html)
    parked_cars.append({"pos":player_pos+Vector2(65,0),"class":str(saved.get("class","sedan")),"heading":player_heading,"color":color,"occupied":false})
    _save_game()
    _open_home_garage_menu()

func _open_jobboard(index: int) -> void:
    if not active_job.is_empty():
        _notify("Aktiver Stadtauftrag läuft bereits.")
        return
    if index<0 or index>=side_job_sites.size():
        return
    var source: Vector2 = Vector2(side_job_sites[index].pos)
    var type_roll: int = (jobs_done+index+rng.randi_range(0,4))%5
    if type_roll==0:
        var targets := [Vector2(23800,1600),Vector2(13200,6150),Vector2(7900,12600),Vector2(18400,9100),Vector2(4200,15100),Vector2(23200,15100)]
        var target: Vector2 = targets[rng.randi_range(0,targets.size()-1)]
        var km_factor: float = source.distance_to(target)/1000.0
        var pay: int = clampi(int(55.0+km_factor*13.0),60,190)
        active_job={"kind":"delivery","title":"Stadtlieferung","target":target,"pay":pay}
    elif type_roll==1:
        var photo_target := _next_photo_target()
        if photo_target==Vector2.ZERO:
            photo_target=Vector2(9000,3560)
        active_job={"kind":"photo","title":"PMDD-Fotosurvey","target":photo_target,"start":photo_count,"goal":1,"pay":95}
    elif type_roll==2:
        var hack_target := _next_hack_replay_target()
        active_job={"kind":"hack_replay","title":"Security Regression Test","target":hack_target,"start":hack_replays,"goal":1,"pay":105}
    elif type_roll==3:
        active_job={"kind":"transit","title":"ÖPNV Qualitätscheck","target":_nearest_transit_stop_pos(source),"start":transit_trip_count,"goal":1,"pay":75}
    else:
        var unvisited := _next_unvisited_district_center()
        if unvisited==Vector2.ZERO:
            unvisited=Vector2(18400,9100)
        active_job={"kind":"district","title":"District Survey","target":unvisited,"goal":1,"pay":90}
    _play_sfx("mission")
    _notify("%s angenommen · %d CR" % [str(active_job.title),int(active_job.pay)])
    _save_game()

func _complete_side_job() -> void:
    if active_job.is_empty():
        return
    var pay: int = int(active_job.get("pay",60))
    credits += pay
    jobs_done += 1
    var title: String = str(active_job.get("title","Auftrag"))
    active_job={}
    _play_sfx("cash")
    _notify("%s erledigt · +%d Credits" % [title,pay])
    _save_game()
    _advance_native_chapter()

func _next_photo_target() -> Vector2:
    for ph in photo_points:
        if not bool(ph.taken):
            return Vector2(ph.pos)
    return Vector2.ZERO

func _next_hack_replay_target() -> Vector2:
    for m in mission_sites:
        if bool(hack_done.get(str(m.id),false)):
            return Vector2(m.pos)
    for m in mission_sites:
        if not bool(hack_done.get(str(m.id),false)):
            return Vector2(m.pos)
    return Vector2.ZERO

func _nearest_transit_stop_pos(from: Vector2) -> Vector2:
    var best: float = INF
    var out := Vector2.ZERO
    for st in transit_stops:
        var p := Vector2(st.pos)
        var d: float = from.distance_to(p)
        if d<best:
            best=d
            out=p
    return out

func _next_unvisited_district_center() -> Vector2:
    for d in districts:
        var name := str(d.name)
        if not bool(visited_districts.get(name,false)):
            return Vector2((d.rect as Rect2).get_center())
    return Vector2.ZERO

func _check_active_job_progress() -> void:
    if active_job.is_empty():
        return
    var kind := str(active_job.get("kind","delivery"))
    var done: bool = false
    if kind=="photo":
        done=(photo_count-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done:
            active_job["target"]=_next_photo_target()
    elif kind=="hack_replay":
        done=(hack_replays-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done:
            active_job["target"]=_next_hack_replay_target()
    elif kind=="transit":
        done=(transit_trip_count-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
    elif kind=="district":
        done=player_pos.distance_to(Vector2(active_job.get("target",Vector2.ZERO)))<260.0
    if done:
        _complete_side_job()

func _vehicle_upgrade_state(cls: String) -> Dictionary:
    if not vehicle_upgrades.has(cls):
        vehicle_upgrades[cls]={"engine":0,"handling":0,"brake":0}
    return Dictionary(vehicle_upgrades[cls])

func _vehicle_tune_multiplier(cls: String, channel: String) -> float:
    var up := _vehicle_upgrade_state(cls)
    var level: int = int(up.get(channel,0))
    if channel=="engine":
        return 1.0+float(level)*0.075
    if channel=="handling":
        return 1.0+float(level)*0.085
    return 1.0+float(level)*0.10

func _upgrade_cost(level: int) -> int:
    return [80,135,220,9999][clampi(level,0,3)]

func _buy_vehicle_upgrade(cls: String, channel: String) -> void:
    var up := _vehicle_upgrade_state(cls)
    var level: int = int(up.get(channel,0))
    if level>=3:
        _notify("%s ist bereits auf Maximalstufe." % channel.capitalize())
        return
    var cost := _upgrade_cost(level)
    if credits<cost:
        _play_sfx("error")
        _notify("Nicht genug Credits · %d benötigt." % cost)
        return
    credits-=cost
    up[channel]=level+1
    vehicle_upgrades[cls]=up
    _play_sfx("cash")
    _notify("%s · %s jetzt Stufe %d" % [cls.capitalize(),channel.capitalize(),level+1])
    _save_game()
    _advance_native_chapter()
    _open_garage_menu()

func _total_upgrade_count() -> int:
    var total := 0
    for cls in vehicle_upgrades.keys():
        var up: Dictionary = Dictionary(vehicle_upgrades[cls])
        total += int(up.get("engine",0))+int(up.get("handling",0))+int(up.get("brake",0))
    return total

func _start_race(index: int) -> void:
    if index<0 or index>=race_sites.size() or current_vehicle<0:
        return
    var race: Dictionary = race_sites[index]
    var cls: String = str(parked_cars[current_vehicle]["class"])
    var required: String = str(race.group)
    var actual: String = str(VEHICLE_SPEED_GROUP.get(cls,"ROAD"))
    var allowed := required==actual or required=="ROAD" and actual in ["ROAD","PERFORMANCE","HYPER"] or required=="PERFORMANCE" and actual in ["PERFORMANCE","HYPER"]
    if not allowed:
        _play_sfx("error")
        _show_reward_popup("FALSCHE FAHRZEUGKLASSE","%s benötigt %s\nAktuell: %s · %s" % [str(race.name),required,cls.capitalize(),actual],Color("#ff8f7a"))
        _notify("%s benötigt Klasse %s · aktuelles Fahrzeug: %s" % [str(race.name),required,actual])
        return
    active_race={"index":index,"checkpoint":0,"remaining":float(race.limit),"elapsed":0.0,"countdown":3.0,"count_tick":3}
    vehicle_velocity=0.0
    _play_sfx("hack_click")
    _haptic(35)
    _notify("%s · Start in 3…" % str(race.name))

func _update_active_race(delta: float) -> void:
    if active_race.is_empty():
        return
    if current_vehicle<0:
        _notify("Zeitprüfung abgebrochen · Fahrzeug verlassen.")
        active_race={}
        return
    var race: Dictionary = race_sites[int(active_race.index)]
    var countdown: float = float(active_race.get("countdown",0.0))
    if countdown>0.0:
        var next_count: float = maxf(0.0,countdown-delta)
        active_race["countdown"]=next_count
        var tick: int = int(ceil(next_count))
        if tick<int(active_race.get("count_tick",3)):
            active_race["count_tick"]=tick
            if tick>0:
                _play_sfx("hack_click")
                _haptic(28)
            else:
                _play_sfx("mission")
                _haptic(60)
                _show_reward_popup("GO!",str(race.name),Color("#ffd36b"))
        return
    active_race["remaining"]=float(active_race.remaining)-delta
    active_race["elapsed"]=float(active_race.elapsed)+delta
    if float(active_race.remaining)<=0.0:
        _play_sfx("error")
        _notify("%s · Zeit abgelaufen." % str(race.name))
        active_race={}
        return
    var cp_index: int = int(active_race.checkpoint)
    var pts: Array = Array(race.points)
    if cp_index<pts.size() and player_pos.distance_to(Vector2(pts[cp_index]))<145.0:
        active_race["checkpoint"]=cp_index+1
        _play_sfx("hack_click")
        if cp_index+1>=pts.size():
            var elapsed: float = float(active_race.elapsed)
            var id: String = str(race.id)
            var previous: float = float(race_best.get(id,99999.0))
            if elapsed<previous:
                race_best[id]=elapsed
            credits+=int(race.reward)
            race_wins+=1
            race_completed[id]=true
            active_race={}
            _play_sfx("mission")
            _show_reward_popup("ZEITPRÜFUNG GESCHAFFT","%s · %.1fs\n+%d CR" % [str(race.name),elapsed,int(race.reward)],Color("#ffd36b"))
            _notify("%s geschafft · %.1fs · +%d CR" % [str(race.name),elapsed,int(race.reward)])
            _save_game()
            _advance_native_chapter()

func _draw_race_markers() -> void:
    for i in range(race_sites.size()):
        var race: Dictionary = race_sites[i]
        var p := _project(Vector2(race.pos),12)
        if player_pos.distance_to(Vector2(race.pos))<1800.0:
            draw_arc(p,18,0,TAU,26,Color("#ffcf68"),2.0,true)
            draw_string(ThemeDB.fallback_font,p+Vector2(-55,30),"TRIAL",HORIZONTAL_ALIGNMENT_CENTER,110,10,Color("#ffdf94"))
    if active_race.is_empty():
        return
    var race: Dictionary = race_sites[int(active_race.index)]
    var pts: Array = Array(race.points)
    var cp: int = int(active_race.checkpoint)
    if cp<pts.size():
        var q := _project(Vector2(pts[cp]),8)
        var pulse := 22.0+sin(Time.get_ticks_msec()/150.0)*4.0
        draw_circle(q,pulse,Color(1.0,0.82,0.30,0.055))
        draw_arc(q,pulse,0,TAU,30,Color("#ffd45c"),3.0,true)
        draw_string(ThemeDB.fallback_font,q+Vector2(-55,-34),"CHECK %d/%d" % [cp+1,pts.size()],HORIZONTAL_ALIGNMENT_CENTER,110,11,Color.WHITE)
    var size := get_viewport_rect().size
    var countdown: float = float(active_race.get("countdown",0.0))
    if countdown>0.0:
        draw_string(ThemeDB.fallback_font,Vector2(size.x*0.5-100,395),str(maxi(1,int(ceil(countdown)))),HORIZONTAL_ALIGNMENT_CENTER,200,54,Color("#ffd96d"))
        draw_string(ThemeDB.fallback_font,Vector2(size.x*0.5-150,455),str(race.name),HORIZONTAL_ALIGNMENT_CENTER,300,16,Color.WHITE)
    else:
        draw_string(ThemeDB.fallback_font,Vector2(size.x*0.5-140,405),"%s · %.1fs" % [str(race.name),float(active_race.remaining)],HORIZONTAL_ALIGNMENT_CENTER,280,18,Color("#ffd96d"))

func _check_milestones() -> void:
    var milestones := [
        ["photos_5",photo_count>=5,60,"Photo Scout"],
        ["photos_15",photo_count>=15,110,"District Lens"],
        ["signals_10",scan_collect_count>=10,90,"Signal Hunter"],
        ["signals_all",scan_collect_count>=scan_points.size() and scan_points.size()>0,220,"Spectrum Archivist"],
        ["photos_all",photo_count>=photo_points.size() and photo_points.size()>0,260,"Photo Master"],
        ["cars_5",driven_classes.size()>=5,75,"Class Explorer"],
        ["cars_all",driven_classes.size()>=VEHICLE_CLASSES.size(),220,"Full Garage"],
        ["districts_15",visited_districts.size()>=15,85,"Urban Explorer"],
        ["hacks_8",_completed_hack_count()>=8,90,"Security Runner"],
        ["races_3",race_completed.size()>=3,110,"Street Trialist"],
        ["jobs_10",jobs_done>=10,120,"City Professional"]
    ]
    for m in milestones:
        var id := str(m[0])
        if bool(m[1]) and not bool(milestones_claimed.get(id,false)):
            milestones_claimed[id]=true
            credits+=int(m[2])
            _play_sfx("mission")
            _show_reward_popup("MEILENSTEIN",str(m[3])+"\n+%d CR" % int(m[2]),Color("#ffd36b"))
            _notify("MEILENSTEIN · %s · +%d CR" % [str(m[3]),int(m[2])])
            _save_game()

func _current_objective_pos() -> Vector2:
    if not active_race.is_empty():
        var rr: Dictionary = race_sites[int(active_race.index)]
        var cp: int = int(active_race.checkpoint)
        var rpts: Array = Array(rr.points)
        if cp<rpts.size():
            return Vector2(rpts[cp])
    var contract_target := _npc_contract_target()
    if contract_target!=Vector2.ZERO:
        return contract_target
    if native_chapters.is_empty():
        return Vector2.ZERO
    var c: Dictionary = native_chapters[mini(native_chapter,native_chapters.size()-1)]
    var kind := str(c.kind)
    if kind=="frag":
        for f in fragments:
            if not bool(f.taken): return Vector2(f.pos)
    elif kind=="secret":
        for sec in secrets:
            if not bool(sec.found): return Vector2(sec.pos)
    elif kind=="cache":
        for ca in caches:
            if not bool(ca.taken): return Vector2(ca.pos)
    elif kind=="glyph":
        for g in glyphs:
            if not bool(g.taken): return Vector2(g.pos)
    elif kind=="npc":
        for npc in named_npcs:
            if str(npc.id)==str(c.id): return Vector2(npc.pos)
    elif kind=="relay":
        for v in vertical_sites:
            if str(v.kind)=="roof" and not bool(vertical_flags.get(str(v.id),false)): return Vector2(v.pos)
    elif kind=="sublevel":
        for v in vertical_sites:
            if str(v.kind)=="sublevel" and not bool(vertical_flags.get(str(v.id),false)): return Vector2(v.pos)
    elif kind=="visit_openai":
        for l in landmarks:
            if str(l.kind)=="openai_hq": return Vector2(l.pos)
    elif kind=="hack":
        for m in mission_sites:
            if str(m.id)==str(c.id): return Vector2(m.pos)
    elif kind=="jobs":
        if not active_job.is_empty(): return Vector2(active_job.get("target",Vector2.ZERO))
        if not side_job_sites.is_empty(): return Vector2(side_job_sites[0].pos)
    elif kind=="photo":
        return _next_photo_target()
    elif kind=="vehicles":
        for car in parked_cars:
            if not bool(driven_classes.get(str(car["class"]),false)):
                return Vector2(car["pos"])
    elif kind=="districts":
        return _next_unvisited_district_center()
    elif kind=="hack_count":
        for m in mission_sites:
            if not bool(hack_done.get(str(m.id),false)): return Vector2(m.pos)
    elif kind=="collector":
        for ca in caches:
            if not bool(ca.taken): return Vector2(ca.pos)
        for g in glyphs:
            if not bool(g.taken): return Vector2(g.pos)
    elif kind=="hack_replays":
        return _next_hack_replay_target()
    elif kind=="paint":
        for st in storefronts:
            if str(st.kind) in ["garage","workshop"]: return Vector2(st.pos)
    elif kind in ["property","stored_car"]:
        if not property_sites.is_empty(): return Vector2(property_sites[0].pos)
    return Vector2.ZERO

func _draw_mission_compass() -> void:
    if main_menu_active or map_open or missions_open or interior_active:
        return
    var target := _current_objective_pos()
    if target==Vector2.ZERO:
        return
    var delta := target-player_pos
    var distance := delta.length()
    if distance<55.0:
        return
    var size := get_viewport_rect().size
    var center := Vector2(size.x*0.5,345)
    var dir := delta.normalized()
    var angle := dir.angle()+PI*0.5
    var arrow := PackedVector2Array([Vector2(0,-18),Vector2(12,12),Vector2(0,7),Vector2(-12,12)])
    for i in range(arrow.size()):
        arrow[i]=arrow[i].rotated(angle)+center
    draw_colored_polygon(arrow,Color("#73f3ce"))
    draw_string(ThemeDB.fallback_font,center+Vector2(-90,38),"%d m · %s" % [int(distance/10.0),str(native_chapters[native_chapter].title)],HORIZONTAL_ALIGNMENT_CENTER,180,13,Color("#d9f5ef"))

func _toggle_map() -> void:
    if minigame_open or photo_mode:
        return
    map_open = not map_open
    missions_open = false
    collection_open = false
    move_vec = Vector2.ZERO
    queue_redraw()

func _toggle_collection() -> void:
    if minigame_open or photo_mode:
        return
    collection_open=not collection_open
    map_open=false
    missions_open=false
    move_vec=Vector2.ZERO
    queue_redraw()

func _toggle_missions() -> void:
    if minigame_open or photo_mode:
        return
    missions_open = not missions_open
    map_open = false
    collection_open = false
    move_vec = Vector2.ZERO
    queue_redraw()

func _map_point(world_pos: Vector2, rect: Rect2) -> Vector2:
    return rect.position + Vector2(world_pos.x/WORLD_SIZE.x*rect.size.x,world_pos.y/WORLD_SIZE.y*rect.size.y)

func _draw_map_overlay() -> void:
    var screen := get_viewport_rect().size
    draw_rect(Rect2(Vector2(28,170),Vector2(screen.x-56,1900)),Color(0.025,0.055,0.075,0.97),true)
    draw_rect(Rect2(Vector2(28,170),Vector2(screen.x-56,1900)),Color("#73f3ce"),false,2.0)
    draw_string(ThemeDB.fallback_font,Vector2(62,225),"GESAMTKARTE · PARALLAX MEGACITY",HORIZONTAL_ALIGNMENT_LEFT,760,28,Color.WHITE)
    var map_rect := Rect2(65,270,950,660)
    draw_rect(map_rect,Color("#0d1820"),true)
    for d in districts:
        var dr: Rect2 = d.rect
        var p := _map_point(dr.position,map_rect)
        var sz := Vector2(dr.size.x/WORLD_SIZE.x*map_rect.size.x,dr.size.y/WORLD_SIZE.y*map_rect.size.y)
        draw_rect(Rect2(p,sz),Color(d.ground.r,d.ground.g,d.ground.b,0.92),true)
        draw_rect(Rect2(p,sz),Color(d.accent.r,d.accent.g,d.accent.b,0.35),false,1.0)
        draw_string(ThemeDB.fallback_font,p+Vector2(4,15),str(d.name),HORIZONTAL_ALIGNMENT_LEFT,maxf(50.0,sz.x-8),10,Color(0.92,0.96,0.97,0.76))
    for road in roads:
        var pts := PackedVector2Array()
        for wp in road.points:
            pts.append(_map_point(wp,map_rect))
        draw_polyline(pts,Color(0.75,0.80,0.78,0.16),2.0,true)
    for l in landmarks:
        _draw_map_marker(_map_point(Vector2(l.pos),map_rect),Color(l.accent),"★")
    for npc in named_npcs:
        _draw_map_marker(_map_point(Vector2(npc.pos),map_rect),Color(npc.accent),"N")
    for ph in photo_points:
        if not bool(ph.taken):
            _draw_map_marker(_map_point(Vector2(ph.pos),map_rect),Color("#ffb3e6"),"◎")
    for race in race_sites:
        _draw_map_marker(_map_point(Vector2(race.pos),map_rect),Color("#ffd36b"),"R")
    for i in range(storefronts.size()):
        var st = storefronts[i]
        var col := Color("#ffd27a") if st.kind in ["restaurant","cafe"] else (Color("#73f3ce") if st.kind=="shop" else Color("#ff9b72"))
        _draw_map_marker(_map_point(Vector2(st.pos),map_rect),col,"R" if st.kind in ["restaurant","cafe"] else ("G" if st.kind in ["garage","workshop"] else "S"))
    for p in property_sites:
        _draw_map_marker(_map_point(Vector2(p.pos),map_rect),Color("#d6a8ff"),"H")
    for vs in vertical_sites:
        _draw_map_marker(_map_point(Vector2(vs.pos),map_rect),Color(vs.accent),"↑" if str(vs.kind)=="roof" else "↓")
    for j in side_job_sites:
        _draw_map_marker(_map_point(Vector2(j.pos),map_rect),Color("#8de9aa"),"J")
    for ts in transit_stops:
        _draw_map_marker(_map_point(Vector2(ts.pos),map_rect),Color("#72d7e6"),"T")
    if not active_job.is_empty():
        _draw_map_marker(_map_point(Vector2(active_job.get("target",Vector2.ZERO)),map_rect),Color("#ffffff"),"➤")
    var contract_target := _npc_contract_target()
    if contract_target!=Vector2.ZERO:
        _draw_map_marker(_map_point(contract_target,map_rect),Color("#ff9fe8"),"◆")
    for m in mission_sites:
        var done := bool(hack_done.get(str(m.id),false))
        _draw_map_marker(_map_point(Vector2(m.pos),map_rect),Color("#66717a") if done else Color("#ffdf75"),"!")
    var pp := _map_point(player_pos,map_rect)
    draw_circle(pp,7,Color.WHITE)
    draw_circle(pp,12,Color("#73f3ce"),false,2.0)
    var y := 980.0
    draw_string(ThemeDB.fallback_font,Vector2(70,y),"LEGENDE / POIs",HORIZONTAL_ALIGNMENT_LEFT,300,22,Color("#73f3ce"))
    y += 44
    var legend := [
        ["★","Sehenswürdigkeit / Landmark",Color("#9ad5ff")],
        ["N","Benannter NPC / Kontakt",Color("#c7f2e7")],
        ["◎","PMDD Photo Point",Color("#ffb3e6")],
        ["R","Zeitprüfung / Fahrchallenge",Color("#ffd36b")],
        ["R","Restaurant / Café",Color("#ffd27a")],
        ["G","Garage / Werkstatt",Color("#ff9b72")],
        ["S","Shop / betretbares Geschäft",Color("#73f3ce")],
        ["H","Kaufbare Immobilie / Hausgarage",Color("#d6a8ff")],
        ["↑","Dachzugang / Relay",Color("#9bdcff")],
        ["↓","Sublevel / Untergrundknoten",Color("#ffb66f")],
        ["J","Nebenjob-Board",Color("#8de9aa")],
        ["T","Bus-/Tram-Haltestelle",Color("#72d7e6")],
        ["◆","Persönlicher NPC-Auftrag",Color("#ff9fe8")],
        ["!","Mission / Hacking-Minispiel",Color("#ffdf75")]
    ]
    for row in legend:
        draw_circle(Vector2(82,y-5),11,row[2])
        draw_string(ThemeDB.fallback_font,Vector2(76,y-10),str(row[0]),HORIZONTAL_ALIGNMENT_CENTER,12,11,Color("#101820"))
        draw_string(ThemeDB.fallback_font,Vector2(112,y),str(row[1]),HORIZONTAL_ALIGNMENT_LEFT,700,17,Color.WHITE)
        y += 38
    draw_string(ThemeDB.fallback_font,Vector2(70,1275),"Stadtteile: %d · Landmarken: %d · betretbare POIs: %d" % [districts.size(),landmarks.size(),storefronts.size()],HORIZONTAL_ALIGNMENT_LEFT,900,17,Color("#c7d6de"))
    draw_string(ThemeDB.fallback_font,Vector2(70,1320),"MAP erneut antippen zum Schließen.",HORIZONTAL_ALIGNMENT_LEFT,900,16,Color("#91a7b3"))

func _draw_map_marker(p: Vector2, color: Color, glyph: String) -> void:
    draw_circle(p,7,color)
    draw_circle(p,10,Color(color.r,color.g,color.b,0.25),false,2.0)
    draw_string(ThemeDB.fallback_font,p+Vector2(-5,-5),glyph,HORIZONTAL_ALIGNMENT_CENTER,10,9,Color("#101820"))

func _completed_hack_count() -> int:
    var count: int = 0
    for key in hack_done.keys():
        if str(key)!="visited_openai" and bool(hack_done[key]):
            count+=1
    return count

func _chapter_progress(c: Dictionary) -> int:
    var kind := str(c.kind)
    if kind=="frag": return mini(mission_fragments,int(c.goal))
    if kind=="secret": return mini(mission_secrets,int(c.goal))
    if kind=="cache": return mini(cache_count,int(c.goal))
    if kind=="glyph": return mini(glyph_count,int(c.goal))
    if kind=="relay": return mini(relay_count,int(c.goal))
    if kind=="sublevel": return mini(sublevel_count,int(c.goal))
    if kind=="npc": return 1 if bool(npc_flags.get(str(c.id),false)) else 0
    if kind=="visit_openai": return 1 if bool(hack_done.get("visited_openai",false)) else 0
    if kind=="hack": return 1 if bool(hack_done.get(str(c.id),false)) else 0
    if kind=="jobs": return mini(jobs_done,int(c.goal))
    if kind=="paint": return 1 if current_paint!="" else 0
    if kind=="property": return 1 if owned_property!="" else 0
    if kind=="stored_car": return 1 if owned_cars.size()>0 else 0
    if kind=="photo": return mini(photo_count,int(c.goal))
    if kind=="vehicles": return mini(driven_classes.size(),int(c.goal))
    if kind=="districts": return mini(visited_districts.size(),int(c.goal))
    if kind=="hack_count": return mini(_completed_hack_count(),int(c.goal))
    if kind=="collector": return mini(cache_count+glyph_count,int(c.goal))
    if kind=="archive": return mini(cache_count+glyph_count+photo_count+scan_collect_count,int(c.goal))
    if kind=="scan_collect": return mini(scan_collect_count,int(c.goal))
    if kind=="hack_replays": return mini(hack_replays,int(c.goal))
    if kind=="races": return mini(race_completed.size(),int(c.goal))
    if kind=="upgrades": return mini(_total_upgrade_count(),int(c.goal))
    return 1

func _photo_spot_score(id: String) -> int:
    var total := 0
    for i in range(3):
        total+=int(photo_scores.get("%s_%d" % [id,i],0))
    return total

func _draw_collection_overlay() -> void:
    var screen := get_viewport_rect().size
    draw_rect(Rect2(Vector2(38,160),Vector2(screen.x-76,1920)),Color(0.025,0.055,0.075,0.97),true)
    draw_rect(Rect2(Vector2(38,160),Vector2(screen.x-76,1920)),Color("#ffb3e6"),false,2.0)
    draw_string(ThemeDB.fallback_font,Vector2(72,220),"SAMMLUNG / LANGZEITFORTSCHRITT",HORIZONTAL_ALIGNMENT_LEFT,820,28,Color.WHITE)

    var y := 285.0
    var sections := [
        ["PMDD PHOTO HUNT",photo_count,photo_points.size(),Color("#ffb3e6")],
        ["STREET SIGNALS",scan_collect_count,scan_points.size(),Color("#78d8ff")],
        ["FAHRZEUGKLASSEN",driven_classes.size(),VEHICLE_CLASSES.size(),Color("#73f3ce")],
        ["HACKING TERMINALS",_completed_hack_count(),mission_sites.size(),Color("#ffdf75")],
        ["STADTTEILE",visited_districts.size(),districts.size(),Color("#9ad5ff")],
        ["ZEITPRÜFUNGEN",race_completed.size(),race_sites.size(),Color("#ffd36b")],
        ["NPC-VERTRAUEN",_total_npc_trust(),named_npcs.size()*3,Color("#ff9fe8")]
    ]
    for sec in sections:
        draw_string(ThemeDB.fallback_font,Vector2(80,y),str(sec[0]),HORIZONTAL_ALIGNMENT_LEFT,390,18,Color(sec[3]))
        draw_string(ThemeDB.fallback_font,Vector2(780,y),"%d / %d" % [int(sec[1]),int(sec[2])],HORIZONTAL_ALIGNMENT_RIGHT,190,17,Color.WHITE)
        var ratio: float = clampf(float(sec[1])/maxf(1.0,float(sec[2])),0.0,1.0)
        draw_rect(Rect2(80,y+16,890,10),Color(1,1,1,0.08),true)
        draw_rect(Rect2(80,y+16,890*ratio,10),Color(sec[3].r,sec[3].g,sec[3].b,0.72),true)
        y+=72

    draw_string(ThemeDB.fallback_font,Vector2(80,y+8),"FOTOPOINTS",HORIZONTAL_ALIGNMENT_LEFT,300,20,Color("#ffb3e6"))
    y+=45
    for i in range(photo_points.size()):
        var ph: Dictionary = photo_points[i]
        var done: bool = bool(ph.taken)
        var spot_score: int = _photo_spot_score(str(ph.id))
        draw_string(ThemeDB.fallback_font,Vector2(92,y),"%s %02d · %s · %s · %d/300" % [("✓" if done else "○"),i+1,str(ph.label),str(ph.district),spot_score],HORIZONTAL_ALIGNMENT_LEFT,850,13,Color("#8de9aa") if done else Color("#c7d6de"))
        y+=30
        if y>1150: break

    y=1190
    draw_string(ThemeDB.fallback_font,Vector2(80,y),"FAHRZEUGKLASSEN & TUNING",HORIZONTAL_ALIGNMENT_LEFT,420,20,Color("#73f3ce"))
    y+=42
    for cls in VEHICLE_CLASSES:
        var seen: bool = bool(driven_classes.get(cls,false))
        var up: Dictionary = _vehicle_upgrade_state(cls)
        var rarity := "COMMON"
        if cls in ["executive","suv","pickup"]: rarity="UNCOMMON"
        elif cls in ["van","delivery"]: rarity="UTILITY"
        elif cls=="sport": rarity="RARE"
        elif cls=="hyper": rarity="ULTRA RARE"
        draw_string(ThemeDB.fallback_font,Vector2(92,y),"%s %-10s · %-10s · %-10s · E%d H%d B%d" % [("✓" if seen else "○"),cls.capitalize(),str(VEHICLE_SPEED_GROUP.get(cls,"ROAD")),rarity,int(up.engine),int(up.handling),int(up.brake)],HORIZONTAL_ALIGNMENT_LEFT,850,13,Color("#8de9aa") if seen else Color("#c7d6de"))
        y+=31

    y+=12
    draw_string(ThemeDB.fallback_font,Vector2(80,y),"MEILENSTEINE",HORIZONTAL_ALIGNMENT_LEFT,300,20,Color("#ffd36b"))
    y+=38
    var milestones := [
        ["Photo Scout","photos_5"],["District Lens","photos_15"],["Photo Master","photos_all"],["Signal Hunter","signals_10"],["Spectrum Archivist","signals_all"],["Class Explorer","cars_5"],["Full Garage","cars_all"],
        ["Urban Explorer","districts_15"],["Security Runner","hacks_8"],["Street Trialist","races_3"],["City Professional","jobs_10"]
    ]
    for m in milestones:
        var done: bool = bool(milestones_claimed.get(str(m[1]),false))
        draw_string(ThemeDB.fallback_font,Vector2(92,y),"%s %s" % [("✓" if done else "○"),str(m[0])],HORIZONTAL_ALIGNMENT_LEFT,420,14,Color("#8de9aa") if done else Color("#b5c4ca"))
        y+=29
    draw_string(ThemeDB.fallback_font,Vector2(72,2030),"COLLECTION erneut antippen zum Schließen.",HORIZONTAL_ALIGNMENT_LEFT,900,16,Color("#91a7b3"))

func _total_npc_trust() -> int:
    var total := 0
    for key in npc_trust.keys():
        total+=int(npc_trust[key])
    return total

func _draw_missions_overlay() -> void:
    var screen := get_viewport_rect().size
    draw_rect(Rect2(Vector2(38,160),Vector2(screen.x-76,1920)),Color(0.025,0.055,0.075,0.97),true)
    draw_rect(Rect2(Vector2(38,160),Vector2(screen.x-76,1920)),Color("#9ad5ff"),false,2.0)
    draw_string(ThemeDB.fallback_font,Vector2(72,220),"MISSIONEN",HORIZONTAL_ALIGNMENT_LEFT,600,30,Color.WHITE)
    draw_string(ThemeDB.fallback_font,Vector2(72,255),"Photo %d/%d · Fahrzeuge %d/%d · Stadtteile %d/%d · Hacks %d/%d · Rennen %d · Tuning %d" % [photo_count,photo_points.size(),driven_classes.size(),VEHICLE_CLASSES.size(),visited_districts.size(),districts.size(),_completed_hack_count(),mission_sites.size(),race_wins,_total_upgrade_count()],HORIZONTAL_ALIGNMENT_LEFT,900,14,Color("#9fb7c2"))
    var y := 300.0
    for i in range(native_chapters.size()):
        var c: Dictionary = native_chapters[i]
        var progress := _chapter_progress(c)
        var goal := int(c.goal)
        var active := i==native_chapter
        var done := progress>=goal
        var bg := Color(0.14,0.29,0.34,0.58) if active else Color(0.08,0.13,0.16,0.62)
        draw_rect(Rect2(70,y-24,930,72),bg,true)
        draw_rect(Rect2(70,y-24,930,72),Color("#73f3ce") if active else Color(1,1,1,0.08),false,1.5)
        draw_string(ThemeDB.fallback_font,Vector2(86,y),"%02d  %s" % [i+1,str(c.title)],HORIZONTAL_ALIGNMENT_LEFT,620,17,Color("#73f3ce") if active else Color.WHITE)
        draw_string(ThemeDB.fallback_font,Vector2(710,y),("✓" if done else "%d/%d" % [progress,goal]),HORIZONTAL_ALIGNMENT_RIGHT,250,16,Color("#8de9aa") if done else Color("#c7d6de"))
        draw_string(ThemeDB.fallback_font,Vector2(86,y+25),str(c.desc),HORIZONTAL_ALIGNMENT_LEFT,850,13,Color("#aebfc9"))
        y += 82
        if y > 1960:
            break
    draw_string(ThemeDB.fallback_font,Vector2(72,2030),"MISSIONS erneut antippen zum Schließen.",HORIZONTAL_ALIGNMENT_LEFT,900,16,Color("#91a7b3"))

func _interact_property(index: int) -> void:
    if index<0 or index>=property_sites.size():
        return
    var p: Dictionary = property_sites[index]
    if owned_property == str(p.id):
        _enter_interior(str(p.name),"home",Color("#d6a8ff"),player_pos)
        return
    if owned_property != "":
        _notify("Du besitzt bereits %s." % owned_property)
        return
    if credits < int(p.price):
        _notify("%s kostet %d Credits." % [str(p.name),int(p.price)])
        return
    credits -= int(p.price)
    owned_property = str(p.id)
    service_vehicle_index=-1
    _save_game()
    _play_sfx("collect")
    _notify("%s gekauft · Garage %d Plätze" % [str(p.name),int(p.garage)])
    _advance_native_chapter()

func _advance_native_chapter() -> void:
    while native_chapter < native_chapters.size()-1:
        var c: Dictionary = native_chapters[native_chapter]
        if _chapter_progress(c) < int(c.goal):
            break
        native_chapter += 1
        _play_sfx("mission")
        var nc: Dictionary = native_chapters[native_chapter]
        _show_reward_popup("NEUE MISSION",str(nc.title)+"\n"+str(nc.desc),Color("#73f3ce"))
        _notify("Neue Mission: %s" % str(nc.title))

func _draw_ambient_overlay() -> void:
    var size := get_viewport_rect().size
    var daylight := clampf(sin((world_clock-6.0)/24.0*TAU)*0.5+0.5,0.0,1.0)
    var night_alpha := lerpf(0.28,0.04,daylight)
    draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.055,0.12,night_alpha))
    var edge_alpha := 0.12
    draw_rect(Rect2(0,0,size.x,70),Color(0,0,0,edge_alpha))
    draw_rect(Rect2(0,size.y-90,size.x,90),Color(0,0,0,edge_alpha))

func _draw_touch_controls() -> void:
    var size := get_viewport_rect().size
    var center := move_origin if move_touch>=0 else Vector2(112,size.y-135)
    var knob := move_now if move_touch>=0 else center
    draw_circle(center,62,Color(0.04,0.11,0.15,0.36))
    draw_arc(center,62,0,TAU,48,Color(0.45,0.95,0.82,0.28),2,true)
    draw_circle(knob,24,Color(0.45,0.95,0.82,0.30))
    if current_vehicle>=0:
        draw_string(ThemeDB.fallback_font,center+Vector2(-48,-82),"GAS",HORIZONTAL_ALIGNMENT_CENTER,96,11,Color(0.75,0.95,0.90,0.70))
        draw_string(ThemeDB.fallback_font,center+Vector2(-48,94),"BREMSE / R",HORIZONTAL_ALIGNMENT_CENTER,96,10,Color(0.95,0.78,0.70,0.70))
        draw_string(ThemeDB.fallback_font,center+Vector2(-92,-5),"←",HORIZONTAL_ALIGNMENT_CENTER,36,14,Color(0.80,0.90,0.93,0.60))
        draw_string(ThemeDB.fallback_font,center+Vector2(56,-5),"→",HORIZONTAL_ALIGNMENT_CENTER,36,14,Color(0.80,0.90,0.93,0.60))
        draw_string(ThemeDB.fallback_font,center+Vector2(-48,72),"LENKEN",HORIZONTAL_ALIGNMENT_CENTER,96,10,Color(0.70,0.86,0.92,0.55))
    if look_touch>=0:
        draw_circle(look_origin,48,Color(0.04,0.11,0.15,0.25))
        draw_circle(look_now,16,Color(0.55,0.78,1.0,0.35))

func _draw_peek_meter() -> void:
    var size := get_viewport_rect().size
    var c := Vector2(size.x-62,size.y*0.58)
    draw_line(c-Vector2(28,0),c+Vector2(28,0),Color(1,1,1,0.16),1.0)
    draw_line(c-Vector2(0,28),c+Vector2(0,28),Color(1,1,1,0.16),1.0)
    draw_circle(c+view_amount*23,5,Color("#73f3ce"))
    draw_string(ThemeDB.fallback_font,c+Vector2(-28,44),"PEEK",HORIZONTAL_ALIGNMENT_CENTER,56,12,Color(0.8,0.9,0.93,0.7))

func _project(world: Vector2, z: float = 0.0) -> Vector2:
    var screen_center := get_viewport_rect().size * 0.5
    var par := view_amount * z * parallax_strength * 0.72
    return (world - camera_pos + par) * world_zoom + screen_center

func _district_at(p: Vector2) -> Dictionary:
    for d in districts:
        if (d.rect as Rect2).has_point(p):
            return d
    return districts[0]

func _world_rect_visible(r: Rect2) -> bool:
    var screen := Rect2(_project(r.position),r.size*world_zoom).grow(380)
    return screen.intersects(Rect2(Vector2.ZERO,get_viewport_rect().size))

func _point_in_building(p: Vector2) -> bool:
    for b in buildings:
        if (b.rect as Rect2).has_point(p):
            return true
    return false

func _point_blocked(p: Vector2, radius: float) -> bool:
    for l in landmarks:
        if _landmark_rect(l).grow(radius).has_point(p):
            return true
    for b in buildings:
        if (b.rect as Rect2).grow(radius).has_point(p):
            return true
    for w in waters:
        if (w.rect as Rect2).grow(radius).has_point(p) and not _point_on_road(p):
            return true
    return false

func _point_on_road(p: Vector2) -> bool:
    for road in roads:
        if _distance_to_polyline(p,road.points) < float(road.width)*0.55:
            return true
    return false

func _rect_in_park(r: Rect2) -> bool:
    for p in parks:
        if (p.rect as Rect2).grow(25).intersects(r):
            return true
    return false

func _rect_near_road(rect: Rect2, margin: float) -> bool:
    var samples := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y),rect.get_center()]
    for p in samples:
        for road in roads:
            if _distance_to_polyline(p,road.points) < road.width*0.5 + margin:
                return true
    return false

func _distance_to_polyline(p: Vector2, pts: PackedVector2Array) -> float:
    var best := INF
    for i in range(pts.size()-1):
        var a := pts[i]
        var b := pts[i+1]
        var ab := b-a
        var t := clampf((p-a).dot(ab)/maxf(1.0,ab.length_squared()),0,1)
        best = minf(best,p.distance_to(a+ab*t))
    return best

func _sample_polyline(pts: PackedVector2Array, t: float) -> Vector2:
    var total := 0.0
    var lengths := PackedFloat32Array()
    for i in range(pts.size()-1):
        var l := pts[i].distance_to(pts[i+1])
        lengths.append(l)
        total += l
    var target := clampf(t,0,1)*total
    var run := 0.0
    for i in range(lengths.size()):
        if target <= run+lengths[i]:
            return pts[i].lerp(pts[i+1],(target-run)/maxf(1.0,lengths[i]))
        run += lengths[i]
    return pts[pts.size()-1]

func _polyline_tangent(pts: PackedVector2Array, t: float) -> Vector2:
    var p1 := _sample_polyline(pts,maxf(0.0,t-0.002))
    var p2 := _sample_polyline(pts,minf(1.0,t+0.002))
    return (p2-p1).normalized()

func _random_open_point() -> Vector2:
    for _i in range(300):
        var p := Vector2(rng.randf_range(100,WORLD_SIZE.x-100),rng.randf_range(100,WORLD_SIZE.y-100))
        if not _point_blocked(p,45.0) and _distance_to_any_road(p)<500.0:
            return p
    return Vector2(5200,4200)

func _distance_to_any_road(p: Vector2) -> float:
    var best := INF
    for road in roads:
        best = minf(best,_distance_to_polyline(p,road.points))
    return best

func _car_color(cls: String) -> Color:
    var palettes := {
        "micro":[Color("#ef6b74"),Color("#70b8e8"),Color("#f4d37b"),Color("#d6dce2")],
        "hatch":[Color("#68c5df"),Color("#e18a72"),Color("#9bd27f"),Color("#b7a7ea")],
        "sedan":[Color("#6aa8ff"),Color("#8e7fd8"),Color("#d7d7dc"),Color("#ffad91")],
        "executive":[Color("#293846"),Color("#d2d7dc"),Color("#776b85"),Color("#36586c")],
        "suv":[Color("#6e8c7a"),Color("#c6ad84"),Color("#72869b"),Color("#4f5f66")],
        "pickup":[Color("#d48262"),Color("#7d9fbc"),Color("#4e6a5a"),Color("#d4c6a6")],
        "van":[Color("#98e1bd"),Color("#ffd3a0"),Color("#c7d5e4"),Color("#9eb9ff")],
        "delivery":[Color("#f0efe9"),Color("#ffcb67"),Color("#78a6ba"),Color("#c8d4db")],
        "sport":[Color("#ff6eaa"),Color("#68efd7"),Color("#f2df61"),Color("#bba2ff")],
        "hyper":[Color("#ff4f65"),Color("#51f0e1"),Color("#df67ff"),Color("#f3f7f8")]
    }
    var arr: Array = palettes.get(cls,palettes["sedan"])
    return arr[rng.randi_range(0,arr.size()-1)]

func _draw_home_interior(origin: Vector2, accent: Color) -> void:
    if interior_floor==0:
        draw_rect(Rect2(origin+Vector2(300,130),Vector2(250,150)),Color("#2c3438"),true)
        draw_rect(Rect2(origin+Vector2(325,155),Vector2(95,55)),Color("#59686f"),true)
        draw_rect(Rect2(origin+Vector2(455,155),Vector2(70,55)),Color("#49545a"),true)
        draw_circle(origin+Vector2(390,360),42,Color("#5d493b"))
        draw_rect(Rect2(origin+Vector2(610,120),Vector2(170,310)),Color(0.08,0.10,0.12,0.88),true)
        draw_rect(Rect2(origin+Vector2(610,120),Vector2(170,310)),Color(accent.r,accent.g,accent.b,0.35),false,2.0)
        draw_string(ThemeDB.fallback_font,origin+Vector2(635,150),"PRIVATE GARAGE",HORIZONTAL_ALIGNMENT_LEFT,130,12,Color.WHITE)
    else:
        draw_rect(Rect2(origin+Vector2(305,135),Vector2(220,120)),Color("#30383d"),true)
        draw_rect(Rect2(origin+Vector2(330,158),Vector2(170,72)),Color("#53616a"),true)
        draw_rect(Rect2(origin+Vector2(590,140),Vector2(170,105)),Color("#242e34"),true)
        draw_string(ThemeDB.fallback_font,origin+Vector2(615,175),"BEDROOM",HORIZONTAL_ALIGNMENT_LEFT,120,12,Color.WHITE)
        draw_circle(origin+Vector2(430,365),54,Color(0.24,0.34,0.38,0.55))
        draw_string(ThemeDB.fallback_font,origin+Vector2(360,365),"PRIVATE STUDIO",HORIZONTAL_ALIGNMENT_CENTER,140,11,Color("#dfecee"))
