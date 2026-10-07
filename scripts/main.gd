extends Node2D

const CityArt = preload("res://scripts/city_art.gd")
const CityAccess = preload("res://scripts/city_access.gd")
const CityMenus = preload("res://scripts/city_menus.gd")
const InteriorArt = preload("res://scripts/interior_art.gd")
const WireTile = preload("res://scripts/wire_tile.gd")
const PhotoArt = preload("res://scripts/photo_art.gd")
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

const VS_ASPHALT: Texture2D = preload("res://assets/visual/tiles/asphalt_cinematic.svg")
const VS_SIDEWALK: Texture2D = preload("res://assets/visual/tiles/sidewalk_cinematic.svg")
const VS_PALM: Texture2D = preload("res://assets/visual/props/palm_comic.svg")
const VS_NEON_SIGN: Texture2D = preload("res://assets/visual/props/neon_sign_comic.svg")
const VS_ROOF_DETAIL: Texture2D = preload("res://assets/visual/props/roof_detail_comic.svg")
const VISUAL_SLICE_RECT := Rect2(5250.0,3820.0,3650.0,2580.0)

var rng := RandomNumberGenerator.new()
var districts: Array = []
var roads: Array = []
var junctions: Array = []
var parks: Array = []
var waters: Array = []
var buildings: Array = []
var collision_grid: Dictionary = {}
var collision_index_ready := false
var access_repairs := 0
var district_access_points: Dictionary = {}
var interior_exit_button: Button
var recenter_hud_button: Button
var hud_root: Control
var modal_root: Control
var city_menus: PanelContainer
var modal_state := ""
var modal_fit_pending := false
var reward_tween: Tween
var notice_tween: Tween
var trees: Array = []
var parked_cars: Array = []
var traffic: Array = []
var smart_agents: Array = []
var street_lights: Array = []
var street_props: Array = []
var street_ensembles: Array = []
var landmarks: Array = []
var storefronts: Array = []
var vegetation_props: Array = []
var pedestrians: Array = []
var social_setpieces: Array = []
var response_incidents: Array = []
var traffic_accidents: Array = []
var traffic_accident_scan_timer: float = 0.0
var traffic_accident_serial: int = 0
var active_crossings_by_road: Dictionary = {}
var transit_vehicles: Array = []
var transit_transfer_hubs: Array = []
var last_transit_exit_hub: String = ""
var last_transit_exit_line: String = ""
var last_transit_exit_time: float = -9999.0
var transit_transfer_count: int = 0
var fragments: Array = []
var secrets: Array = []
var camera_pos := Vector2.ZERO
var camera_shake_strength: float = 0.0
var camera_shake_phase: float = 0.0
var player_pos := Vector2(5100, 4220)
var player_heading := 0.0
var current_vehicle := -1
var vehicle_velocity := 0.0
var vehicle_braking := false
var vehicle_turn_error := 0.0
var hospital_transition: float = 0.0
var hospital_transition_total: float = 4.8
var accident_cooldown: float = 0.0
var accident_count: int = 0
var last_accident_speed: float = 0.0
var response_dispatch_slot: int = -1
var view_touch := Vector2.ZERO
var sensor_view := Vector2.ZERO
var view_amount := Vector2.ZERO
var default_view_bias := Vector2(0.0,-0.18)
var headtrack_gravity_zero := Vector3.ZERO
var headtrack_integrated := Vector2.ZERO
var headtrack_calibrated: bool = false
var headtrack_motion_strength: float = 0.0
var headtrack_sensor_mode: String = "initializing"
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
var photo_occluders: Array = []
var photo_found: Dictionary = {}
var photo_scores: Dictionary = {}
var photo_yaw: float = 0.0
var photo_pitch: float = -0.10
var photo_fov: float = 68.0
var photo_drag_touch: int = -1
var photo_drag_last := Vector2.ZERO
var photo_viewport: SubViewport
var photo_view_rect: TextureRect
var photo_ui_layer: CanvasLayer
var photo_crosshair: Label
var photo_flash_rect: ColorRect
var photo_world_root: Node3D
var photo_environment: Environment
var photo_sky_material: ProceduralSkyMaterial
var photo_sun: DirectionalLight3D
var photo_camera: Camera3D
var photo_target_label: Label
var photo_status_label: Label
var photo_feedback: String = ""
var photo_feedback_until: int = 0
var photo_session: int = 0
var photo_shutter_button: Button
var photo_exit_button: Button
var photo_hint_button: Button
var photo_zoom_in_button: Button
var photo_zoom_out_button: Button
var photo_dynamic_cars: Dictionary = {}
var photo_dynamic_peds: Dictionary = {}
var photo_dynamic_transit: Dictionary = {}
var photo_facade_materials: Dictionary = {}
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
var interior_size := Vector2(920,1260)
var world_zoom: float = 1.0
var target_world_zoom: float = 1.0
var map_open: bool = false
var missions_open: bool = false
var collection_open: bool = false
var missions_page: int = 0
var collection_page: int = 0
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
var game_moves: int = 0
var game_hints: int = 0
var minigame_session: int = 0
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
var camera_tracking_enabled: bool = false
var camera_tracker: Object
var camera_head_view := Vector2.ZERO
var camera_head_depth: float = 0.0
var camera_head_zero := Vector3.ZERO
var camera_pose_zero := Vector2.ZERO
var camera_head_calibrated: bool = false
var camera_head_last_ms: int = 0
var camera_tracking_state: String = "aus"
var camera_option_button: Button
var tracking_label: Label
var hud_details_visible: bool = false
var minigame_finishing: bool = false
var ui_refresh_timer: float = 0.0
var desktop_look_drag: bool = false
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
var city_micro_events: Array = []
var micro_event_seen: Dictionary = {}
var micro_event_choices: Dictionary = {}
var city_reputation := 0
var proximity_event_id := ""
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
var objective_label: Label
var mission_progress_bar: ProgressBar
var detail_label: Label
var status_label: Label
var district_banner: Label
var reward_panel: PanelContainer
var reward_title: Label
var reward_body: Label
var interact_button: Button
var scan_button: Button
var sfx_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var weather_player: AudioStreamPlayer
var sounds := {}
var ambient_sounds := {}
var current_ambient_key := ""
var current_weather_audio_key := ""
var last_secret_sound_ms := -99999

func _ready() -> void:
    get_tree().quit_on_go_back=false
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
    # Legacy procedural masses could cover observation points. Keep the real
    # fixed camera position and its approach clear in both street and photo views.
    buildings=buildings.filter(func(b): return not photo_points.any(func(ph): return Rect2(b.rect).grow(75).has_point(Vector2(ph.pos))) and not waters.any(func(w): return Rect2(w.rect).grow(22).intersects(Rect2(b.rect))))
    trees=trees.filter(func(t): return not _point_on_road(Vector2(t.pos)))
    CityArt.add_street_blocks(self)
    texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
    _generate_traffic()
    _generate_visual_props()
    _generate_storefronts()
    trees=trees.filter(func(t): return not waters.any(func(w): return Rect2(w.rect).has_point(Vector2(t.pos))))
    vegetation_props=vegetation_props.filter(func(v): return not waters.any(func(w): return Rect2(w.rect).has_point(Vector2(v.pos))))
    _generate_transit()
    _build_transit_stops()
    _build_social_setpieces()
    _update_response_dispatches(true)
    _generate_collectibles()
    _seed_neighborhood_start()
    CityAccess.repair(self)
    _build_ui()
    _build_photo_3d_system()
    _build_audio()
    _bootstrap_android_camera()
    camera_pos = player_pos
    current_district = _district_at(player_pos).get("name", "Megacity")
    _refresh_main_menu()
    _update_ui()
    queue_redraw()
    if "--city-smoke" in OS.get_cmdline_user_args():
        call_deferred("_run_city_smoke_test")
    if "--art-capture" in OS.get_cmdline_user_args():
        call_deferred("_run_art_capture")
    if "--photo-smoke" in OS.get_cmdline_user_args():
        call_deferred("_run_photo_smoke_test")
    if "--quality-smoke" in OS.get_cmdline_user_args():
        call_deferred("_run_quality_smoke_test")
    if "--quality-capture" in OS.get_cmdline_user_args():
        call_deferred("_run_quality_capture")
    if "--experience-smoke" in OS.get_cmdline_user_args():
        call_deferred("_run_experience_smoke_test")

func _exit_tree() -> void:
    for player in [sfx_player,ambient_player,weather_player]:
        if is_instance_valid(player):
            player.stop()
            player.stream=null
    sounds.clear()
    ambient_sounds.clear()

func _process(delta: float) -> void:
    delta=minf(delta,0.10)
    _sync_modal_ui()
    _update_sensor(delta)
    if move_touch<0 and OS.get_name()!="Android" and not photo_mode:
        move_vec=Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).limit_length(1.0)
    _update_ambient_audio(delta)
    _update_event_proximity_audio()
    if main_menu_active:
        world_clock = fposmod(world_clock + delta * 0.006,24.0)
        queue_redraw()
        return
    if _modal_active():
        queue_redraw()
        return
    accident_cooldown=maxf(0.0,accident_cooldown-delta)
    if hospital_transition>0.0:
        _update_hospital_transition(delta)
        queue_redraw()
        return
    if photo_mode:
        target_world_zoom = 1.0
    elif interior_active:
        target_world_zoom = 1.0
    elif current_vehicle >= 0:
        target_world_zoom = lerpf(1.35,1.05,clampf(absf(vehicle_velocity)/610.0,0.0,1.0))
    elif transit_riding >= 0:
        target_world_zoom = 1.30
    else:
        target_world_zoom = 2.65
    world_zoom = lerpf(world_zoom,target_world_zoom,minf(1.0,delta*4.5))
    _update_player(delta)
    if not interior_active:
        _update_response_dispatches()
        _update_traffic(delta)
        _update_traffic_accidents(delta)
        _check_player_traffic_accident()
        _update_pedestrians(delta)
        _update_transit(delta)
    if photo_mode:
        _update_photo_3d_scene(delta)
    world_clock = fposmod(world_clock + delta * 0.018, 24.0)
    scan_time = maxf(0.0, scan_time - delta)
    photo_flash_alpha=maxf(0.0,photo_flash_alpha-delta*2.8)
    camera_shake_strength=move_toward(camera_shake_strength,0.0,delta*18.0)
    camera_shake_phase=fposmod(camera_shake_phase+delta*48.0,TAU*8.0)
    autosave_timer += delta
    if autosave_timer >= 12.0:
        autosave_timer = 0.0
        _save_game()
    var passive_bias:=default_view_bias
    if current_vehicle>=0:
        passive_bias=Vector2(0.0,-0.12)
    elif transit_riding>=0:
        passive_bias=Vector2(0.0,-0.15)
    var active_head: Vector2 = camera_head_view if camera_tracking_enabled and Time.get_ticks_msec()-camera_head_last_ms<700 else sensor_view
    var view_target: Vector2=(passive_bias+active_head*0.92+view_touch*0.98).limit_length(1.0)
    view_amount = view_amount.lerp(view_target,minf(1.0,delta*8.5))
    if not interior_active:
        var lead: Vector2=Vector2.from_angle(player_heading)*clampf(vehicle_velocity*0.22,-36.0,120.0) if current_vehicle>=0 else move_vec*30.0
        camera_pos = camera_pos.lerp(player_pos+lead, 1.0-exp(-delta*(4.5 if current_vehicle>=0 else 7.0)))
        _update_secrets()
        _update_district()
        _check_npc_contract()
        _check_active_job_progress()
        _update_active_race(delta)
        _check_milestones()
    ui_refresh_timer+=delta
    if ui_refresh_timer>=0.12:
        ui_refresh_timer=0.0
        _update_ui()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE and _modal_active():
        if map_open or missions_open or collection_open: _close_overview()
        elif minigame_open: _close_minigame()
        elif commerce_panel.visible: _close_commerce()
        elif dialogue_panel.visible: _close_dialogue()
        get_viewport().set_input_as_handled()
        return
    if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT:
        desktop_look_drag=event.pressed
        look_origin=event.position
        if not event.pressed:
            view_touch=Vector2.ZERO
    elif event is InputEventMouseMotion and desktop_look_drag:
        if photo_mode:
            photo_yaw=wrapf(photo_yaw-event.relative.x*0.0045,-PI,PI)
            photo_pitch=clampf(photo_pitch-event.relative.y*0.0038,-0.72,0.48)
            _photo_update_camera()
        else:
            view_touch=((event.position-look_origin)/165.0).limit_length(1.0)
    if photo_mode:
        _input_photo_mode(event)
        return
    if main_menu_active:
        return
    if hospital_transition>0.0:
        return
    if _modal_active():
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
        if event.physical_keycode==KEY_ESCAPE:
            if map_open or missions_open or collection_open:
                map_open=false
                missions_open=false
                collection_open=false
            else:
                _return_to_main_menu()
        elif event.physical_keycode==KEY_C:
            _recenter_headtracking()
        elif event.is_action_pressed("interact"):
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
            var bridge := false
            # Road-to-road crossings are at grade. Canal spans are rendered separately.
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
        {"name":"Terminal Crown","district":"Terminal East","pos":Vector2(22200,13900),"size":Vector2(820,520),"h":165.0,"kind":"terminal","accent":Color("#d9e5ef")},
        {"name":"Parallax Stadtklinikum","district":"Bioquartier","pos":Vector2(14400,11950),"size":Vector2(820,560),"h":155.0,"kind":"hospital","accent":Color("#8fe7d7")}
    ]

func _hospital_world_pos() -> Vector2:
    for l in landmarks:
        if str(l.get("kind",""))=="hospital":
            return Vector2(l.pos)
    return Vector2(14400,11950)

func _hospital_spawn_pos() -> Vector2:
    for l in landmarks:
        if str(l.get("kind",""))=="hospital":
            return Vector2(l.pos)+Vector2(0,float(Vector2(l.size).y)*0.5+105.0)
    return _hospital_world_pos()+Vector2(0,385)

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
        {"title":"Photo Hunt I","desc":"Starte drei feste 3D-Fotospots und finde dort jeweils alle versteckten Motive.","kind":"photo","goal":3},
        {"title":"Fahrzeugkunde","desc":"Fahre mindestens vier unterschiedliche Fahrzeugklassen.","kind":"vehicles","goal":4},
        {"title":"Stadtentdecker","desc":"Besuche zwölf unterschiedliche Stadtteile.","kind":"districts","goal":12},
        {"title":"Photo Hunt II","desc":"Vervollständige acht feste 3D-Foto-Challenges und verbessere dein Framing.","kind":"photo","goal":8},
        {"title":"District Lens","desc":"Schließe fünfzehn 3D-Fotospots in unterschiedlichen Stadtteilen ab.","kind":"photo","goal":15},
        {"title":"Stadtarchiv","desc":"Sichere insgesamt 25 Sammlerstücke aus Caches, Sigils und Photo Hunt.","kind":"archive","goal":25},
        {"title":"Street Signals","desc":"Finde und scanne fünf versteckte Stadt-Signale.","kind":"scan_collect","goal":5},
        {"title":"Urban Spectrum","desc":"Scanne fünfzehn versteckte Street Signals.","kind":"scan_collect","goal":15},
        {"title":"Hacking Marathon","desc":"Schließe mindestens zehn unterschiedliche Hacking-Terminals ab.","kind":"hack_count","goal":10},
        {"title":"Sammler","desc":"Berge acht Caches und sechs Stadtsigils.","kind":"collector","goal":14},
        {"title":"Hack Replay","desc":"Wiederhole fünf Hacking-Terminals für Bonus-Credits.","kind":"hack_replays","goal":5},
        {"title":"Street Trials","desc":"Gewinne drei unterschiedliche Zeitprüfungen.","kind":"races","goal":3},
        {"title":"Tuning-Projekt","desc":"Kaufe drei Werkstatt-Upgrades für deine Fahrzeugklassen.","kind":"upgrades","goal":3},
        {"title":"Signal Sweep","desc":"Scanne alle 25 Street Signals der Megacity.","kind":"scan_collect","goal":25},
        {"title":"Photo Virtuoso","desc":"Erreiche insgesamt 4500 Framing-Punkte in den festen 3D-Foto-Challenges.","kind":"photo_score","goal":4500},
        {"title":"City Circuit","desc":"Gewinne alle sechs Zeitprüfungen mindestens einmal.","kind":"races","goal":6},
        {"title":"Security Master","desc":"Löse alle zwölf Hacking-Terminals.","kind":"hack_count","goal":12},
        {"title":"District Complete","desc":"Besuche alle 25 Stadtteile.","kind":"districts","goal":25},
        {"title":"Tuning Specialist","desc":"Investiere in zwölf Fahrzeug-Upgrades.","kind":"upgrades","goal":12},
        {"title":"City Professional II","desc":"Schließe 25 Stadtaufträge ab.","kind":"jobs","goal":25},
        {"title":"Urban Pulse","desc":"Entdecke vier unterschiedliche Live-Events und erlebe die Stadt abseits der Missionen.","kind":"citylife","goal":4},
        {"title":"Lokale Hände","desc":"Unterstütze bei vier unterschiedlichen Live-Events aktiv die Menschen vor Ort.","kind":"cityhelp","goal":4},
        {"title":"Megacity Insider","desc":"Entdecke alle zwölf wechselnden Live-Events der Stadt.","kind":"citylife","goal":12},
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
    city_micro_events = [
        {"type":"busker","label":"Live Busker","pos":Vector2(6750,5250),"accent":Color("#73f3ce")},
        {"type":"foodtruck","label":"Night Bites","pos":Vector2(12600,5750),"accent":Color("#ffb66f")},
        {"type":"yoga","label":"Park Flow","pos":Vector2(11950,1250),"accent":Color("#8ff0b4")},
        {"type":"drone_show","label":"Drone Light Show","pos":Vector2(22250,8950),"accent":Color("#ff80ef")},
        {"type":"street_market","label":"Oldtown Market","pos":Vector2(2500,1450),"accent":Color("#ffcd8a")},
        {"type":"maintenance","label":"Grid Maintenance","pos":Vector2(20800,2350),"accent":Color("#f1e36f")},
        {"type":"run_club","label":"City Run Club","pos":Vector2(8700,8900),"accent":Color("#b0c8ff")},
        {"type":"street_art","label":"Live Mural","pos":Vector2(7000,1550),"accent":Color("#9bdcff")},
        {"type":"fountain_show","label":"Fountain Sequence","pos":Vector2(12600,1100),"accent":Color("#8ff0b4")},
        {"type":"repair_crew","label":"Rail Crew","pos":Vector2(22500,16050),"accent":Color("#e8a977")},
        {"type":"campus_group","label":"Campus Meetup","pos":Vector2(8200,10100),"accent":Color("#b0c8ff")},
        {"type":"boardwalk_music","label":"Coast Session","pos":Vector2(18200,16300),"accent":Color("#72d7e6")}
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

func _building_recipe(style: String) -> Dictionary:
    match style:
        "heritage":
            return {"massing":["slab","courtyard","terrace"],"facade":["arches","balconies","mixed"],"roof":["pitched","terrace","garden"]}
        "culture":
            return {"massing":["slab","terrace","courtyard"],"facade":["mixed","ribs","grid"],"roof":["terrace","antenna","garden"]}
        "glass","center":
            return {"massing":["tower","tower","slab","terrace"],"facade":["grid","ribs","windows"],"roof":["antenna","utility","terrace"]}
        "green","garden":
            return {"massing":["terrace","courtyard","slab"],"facade":["living","balconies","windows"],"roof":["garden","terrace","solar"]}
        "solar","wind","data":
            return {"massing":["slab","tower","terrace"],"facade":["ribs","grid","living"],"roof":["solar","antenna","utility"]}
        "canal","coast":
            return {"massing":["terrace","slab","courtyard"],"facade":["balconies","windows","mixed"],"roof":["terrace","garden","pitched"]}
        "harbor","industry","rail":
            return {"massing":["slab","slab","tower"],"facade":["ribs","striped","grid"],"roof":["utility","antenna","flat"]}
        "terminal","air":
            return {"massing":["slab","tower","terrace"],"facade":["grid","ribs","windows"],"roof":["antenna","utility","solar"]}
        "campus":
            return {"massing":["courtyard","terrace","slab"],"facade":["windows","living","balconies"],"roof":["garden","solar","terrace"]}
        "astro":
            return {"massing":["tower","terrace","slab"],"facade":["grid","ribs","mixed"],"roof":["antenna","solar","terrace"]}
        "neon":
            return {"massing":["tower","terrace","tower"],"facade":["grid","ribs","mixed"],"roof":["antenna","terrace","utility"]}
        "expo":
            return {"massing":["terrace","slab","tower"],"facade":["ribs","grid","mixed"],"roof":["terrace","antenna","solar"]}
        _:
            return {"massing":["slab","tower","terrace","courtyard"],"facade":["windows","mixed","grid"],"roof":["flat","utility","terrace"]}

func _pick_recipe_value(values: Array) -> String:
    return str(values[rng.randi_range(0,values.size()-1)])

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
            var recipe:=_building_recipe(str(district.style))
            var massing: String=_pick_recipe_value(Array(recipe.massing))
            var facade_mode: String=_pick_recipe_value(Array(recipe.facade))
            var roof_mode: String=_pick_recipe_value(Array(recipe.roof))
            var wall_variant: Color=Color(district.wall)
            var roof_variant: Color=Color(district.roof)
            if rng.randf()<0.55:
                wall_variant=wall_variant.lerp(Color(district.accent),rng.randf_range(0.025,0.085))
            if str(district.style) in ["heritage","harbor"]:
                wall_variant=wall_variant.lightened(rng.randf_range(0.00,0.06))
            elif str(district.style) in ["industry","rail","data"]:
                wall_variant=wall_variant.darkened(rng.randf_range(0.00,0.07))
            buildings.append({"rect":rect,"height":h,"wall":wall_variant,"roof":roof_variant,"accent":district.accent,"style":district.style,"seed":rng.randi(),"floors":maxi(2,int(h/28.0)),"massing":massing,"facade":facade_mode,"roof_mode":roof_mode})
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

func _is_emergency_archetype(archetype: String) -> bool:
    return archetype in ["response","ambulance"]

func _vehicle_class_for_district(style: String) -> String:
    var pool: Array = ["micro","hatch","sedan","sedan","suv","van"]
    if style in ["heritage","garden","green","campus"]:
        pool=["micro","micro","hatch","hatch","sedan","van","delivery"]
    elif style in ["harbor","industry","rail","terminal"]:
        pool=["pickup","pickup","van","delivery","delivery","suv","sedan"]
    elif style in ["glass","center","neon","astro"]:
        pool=["sedan","executive","executive","suv","sport","hatch"]
        if rng.randf()<0.035:
            return "hyper"
    elif style in ["air","ring","coast"]:
        pool=["sedan","suv","pickup","sport","van","hatch"]
    elif style in ["solar","data","wind"]:
        pool=["hatch","sedan","executive","delivery","suv","sport"]
    return str(pool[rng.randi_range(0,pool.size()-1)])

func _traffic_archetype_for(style: String, cls: String) -> String:
    var roll:=rng.randf()
    if style in ["industry","rail","harbor","terminal"] and cls in ["pickup","van","delivery","suv"]:
        if roll<0.30: return "service"
        if roll<0.48: return "utility"
    if style in ["center","glass","terminal"] and cls in ["sedan","executive","suv","van"]:
        if roll<0.055: return "response"
        if roll<0.20: return "taxi"
    if style in ["campus","culture","expo"] and cls in ["sedan","hatch","suv"]:
        if roll<0.22: return "rideshare"
    if style in ["green","garden","wind","solar"] and cls in ["pickup","van","delivery"]:
        if roll<0.26: return "maintenance"
    if cls=="delivery" and roll<0.22:
        return "courier"
    return ""

func _generate_traffic() -> void:
    traffic.clear()
    for i in range(155):
        var road_index := rng.randi_range(0, roads.size()-1)
        var t_value:=rng.randf()
        var spawn_pos:=_sample_polyline(roads[road_index].points,t_value)
        var spawn_style:=str(_district_at(spawn_pos).get("style","center"))
        var cls: String = _vehicle_class_for_district(spawn_style)
        var archetype:=_traffic_archetype_for(spawn_style,cls)
        var cruise:=rng.randf_range(0.024,0.050)
        if archetype=="response":
            cruise*=1.14
        elif archetype in ["service","maintenance"]:
            cruise*=0.90
        var reverse := rng.randf()<0.5
        var response_route: Array=_new_response_route(road_index) if archetype=="response" else []
        traffic.append({
            "road":road_index,
            "t":t_value,
            "speed":rng.randf_range(0.020,0.044),
            "cruise":cruise,
            "class":cls,
            "archetype":archetype,
            "response_route":response_route,
            "response_route_index":0,
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
    var hospital_pos:=_hospital_world_pos()
    var hospital_road:=_nearest_road_index(hospital_pos)
    for e in range(4):
        var eroad: int=hospital_road if e<2 else (hospital_road+3+e*4)%roads.size()
        var epos: Vector2=hospital_pos if eroad==hospital_road else _sample_polyline(roads[eroad].points,0.18+float(e)*0.12)
        var et: float=_nearest_road_t_to_point(eroad,epos)
        var earch: String="ambulance" if e<2 else "response"
        var ecls: String="van" if earch=="ambulance" else "suv"
        traffic.append({
            "road":eroad,"t":et,"speed":0.020,"cruise":0.046 if earch=="ambulance" else 0.050,
            "class":ecls,"archetype":earch,"response_route":_new_response_route(eroad),"response_route_index":0,
            "response_target":Vector2.ZERO,"response_target_kind":"","response_target_id":"","response_dwell":0.0,
            "emergency_id":e,"color":Color("#f1f6f6") if earch=="ambulance" else Color("#d7e2e8"),
            "reverse":false,"lane":0,"wait":0.0,"turn_cooldown":0.0,"parking":false,"park_timer":0.0,
            "lateral":0.0,"lane_change":0.0,"lane_from":0,"lane_to":0,"indicator":0,"turn_anim":0.0,
            "turn_from":Vector2.ZERO,"turn_to":Vector2.ZERO
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
    # Extra street-life dressing for a less procedural, more game-like city.
    var extra_types := ["planter","utility_box","cafe_table","construction_cone","hydrant"]
    for i in range(54):
        var eroad = roads[rng.randi_range(0,roads.size()-1)]
        var et := rng.randf_range(0.06,0.94)
        var ep := _sample_polyline(eroad.points,et)
        var etan := _polyline_tangent(eroad.points,et)
        var enorm := Vector2(-etan.y,etan.x)
        var eside := -1.0 if i%2==0 else 1.0
        var etype: String = str(extra_types[i%extra_types.size()])
        street_props.append({
            "type":etype,
            "pos":ep+enorm*eside*(float(eroad.width)*0.5+45.0+rng.randf_range(0.0,34.0)),
            "rot":etan.angle(),
            "tint":_district_at(ep).get("accent",Color("#9ad5ff"))
        })
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
    # Animated flags and ventilation stacks make district skylines less static.
    for di in range(districts.size()):
        var d: Dictionary=districts[di]
        var center:=Vector2(d.rect.get_center())
        if str(d.style) in ["center","heritage","campus","expo","harbor"]:
            street_props.append({"type":"flag","pos":center+Vector2(210,-180),"rot":0.0,"tint":Color(d.accent)})
        if str(d.style) in ["industry","rail","terminal","data"]:
            street_props.append({"type":"vent_stack","pos":center+Vector2(-190,160),"rot":0.0,"tint":Color(d.accent)})
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
            "routine":["work","shop","park","home","transit"][rng.randi_range(0,4)],
            "state":"walk",
            "cross_progress":0.0,
            "cross_from_side":0.0,
            "social_partner":-1
        })
    # Seed a few real social pairs so paused pedestrians can visibly talk together.
    for pair_start in range(0,pedestrians.size()-1,22):
        var a: Dictionary=pedestrians[pair_start]
        var b: Dictionary=pedestrians[pair_start+1]
        b["road"]=a.road
        b["t"]=fposmod(float(a.t)+0.006,1.0)
        b["target_t"]=a.target_t
        b["side"]=a.side
        b["speed"]=a.speed
        b["routine"]=a.routine
        a["social_partner"]=pair_start+1
        b["social_partner"]=pair_start
        pedestrians[pair_start]=a
        pedestrians[pair_start+1]=b


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
    for shop in storefronts:
        if str(shop.kind)=="restaurant" and str(shop.district) in ["Zentrum","Neon Mile","Altstadt"]:
            shop["kind"]="bar"
            shop["name"]="Copper Bar" if str(shop.district)=="Altstadt" else ("Afterglow Bar" if str(shop.district)=="Neon Mile" else "Lumen Bar")
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
            "stop_index":-1,
            "passengers":10+i*3,
            "boarding_seed":i*31+7
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
            "stop_index":-1,
            "passengers":14+i*4,
            "boarding_seed":i*37+13
        })

func _build_transit_stops() -> void:
    transit_stops.clear()
    transit_transfer_hubs.clear()
    for vi in range(transit_vehicles.size()):
        var tv: Dictionary = transit_vehicles[vi]
        var rd = roads[int(tv.road)]
        for si in range(4):
            var tt: float = 0.12 + float(si)*0.24
            var pos: Vector2 = _sample_polyline(rd.points,tt)
            var stop_index: int = transit_stops.size()
            var style: String = str(_district_at(pos).get("style","center"))
            var base_waiting: int = 2 + (stop_index*3 + vi*5) % 5
            if style in ["center","campus","terminal","expo"]:
                base_waiting += 2
            elif style in ["industry","rail","harbor"]:
                base_waiting += 1
            transit_stops.append({
                "vehicle":vi,
                "t":tt,
                "pos":pos,
                "line":str(tv.line),
                "name":"%s · Halt %d" % [str(tv.line),si+1],
                "waiting":base_waiting,
                "arrivals":0,
                "last_boarded":0,
                "last_exited":0,
                "demand_slot":-1,
                "transfer_hub":""
            })
    _build_transit_transfer_hubs()

func _build_transit_transfer_hubs() -> void:
    var road_vehicle: Dictionary={}
    for vi in range(transit_vehicles.size()):
        road_vehicle[int(transit_vehicles[vi].road)]=vi
    var hub_count:=0
    for j in junctions:
        if bool(j.get("bridge",false)):
            continue
        var a: int=int(j.a)
        var b: int=int(j.b)
        if not road_vehicle.has(a) or not road_vehicle.has(b):
            continue
        var va: int=int(road_vehicle[a])
        var vb: int=int(road_vehicle[b])
        if va==vb:
            continue
        var line_a:=str(transit_vehicles[va].line)
        var line_b:=str(transit_vehicles[vb].line)
        if line_a==line_b:
            continue
        var hub_id:="transfer_%d" % hub_count
        var pos:=Vector2(j.pos)
        var stop_a:=transit_stops.size()
        transit_stops.append({
            "vehicle":va,"t":float(j.ta),"pos":pos,"line":line_a,"name":"%s · Umstieg" % line_a,
            "waiting":3+(hub_count%4),"arrivals":0,"last_boarded":0,"last_exited":0,"demand_slot":-1,"transfer_hub":hub_id
        })
        var stop_b:=transit_stops.size()
        transit_stops.append({
            "vehicle":vb,"t":float(j.tb),"pos":pos,"line":line_b,"name":"%s · Umstieg" % line_b,
            "waiting":3+((hub_count+2)%4),"arrivals":0,"last_boarded":0,"last_exited":0,"demand_slot":-1,"transfer_hub":hub_id
        })
        transit_transfer_hubs.append({"id":hub_id,"pos":pos,"lines":[line_a,line_b],"stops":[stop_a,stop_b]})
        hub_count+=1
        if hub_count>=8:
            break

func _transit_hub_lines(hub_id: String, exclude_line: String = "") -> Array:
    for hub in transit_transfer_hubs:
        if str(hub.id)!=hub_id:
            continue
        var result: Array=[]
        for line in Array(hub.lines):
            if str(line)!=exclude_line:
                result.append(str(line))
        return result
    return []

func _build_social_setpieces() -> void:
    social_setpieces.clear()
    response_incidents.clear()

    var transit_added:=0
    for si in range(transit_stops.size()):
        if transit_added>=10:
            break
        var st: Dictionary=transit_stops[si]
        social_setpieces.append({
            "kind":"transit_wait",
            "pos":Vector2(st.pos),
            "stop_index":si,
            "seed":si*19+7,
            "count":3+(si%3)
        })
        transit_added+=1

    var cafe_added:=0
    for si in range(storefronts.size()):
        var st: Dictionary=storefronts[si]
        if str(st.kind) not in ["cafe","restaurant"]:
            continue
        social_setpieces.append({
            "kind":"cafe_cluster",
            "pos":Vector2(st.pos)+Vector2(0,58),
            "seed":si*23+11,
            "count":3+(si%2)
        })
        cafe_added+=1
        if cafe_added>=9:
            break

    for hi in range(transit_transfer_hubs.size()):
        var hub: Dictionary=transit_transfer_hubs[hi]
        social_setpieces.append({"kind":"transfer_hub","pos":Vector2(hub.pos),"hub_id":str(hub.id),"seed":hi*71+9,"count":5+(hi%3)})

    var delivery_added:=0
    for si in range(storefronts.size()):
        var st: Dictionary=storefronts[si]
        if str(st.kind) not in ["shop","restaurant","cafe"]:
            continue
        var heading:=float(st.heading)
        var side:=Vector2.from_angle(heading+PI*0.5)
        social_setpieces.append({
            "kind":"delivery_loading","pos":Vector2(st.pos)+side*72.0,"heading":heading,
            "seed":si*79+17,"count":2,"store_name":str(st.name),"store_kind":str(st.kind)
        })
        delivery_added+=1
        if delivery_added>=12:
            break

    for di in range(districts.size()):
        var d: Dictionary=districts[di]
        var center:=Vector2(d.rect.get_center())
        social_setpieces.append({"kind":"district_signature","pos":center+Vector2(260,-220),"style":str(d.style),"district":str(d.name),"seed":di*83+29,"count":3})
        if str(d.style) in ["harbor","industry","rail"]:
            social_setpieces.append({"kind":"dock_loading","pos":center+Vector2(-260,220),"heading":0.0,"seed":di*89+31,"count":3,"district":str(d.name)})

    for i in range(mini(7,junctions.size())):
        var idx: int=(i*13+9)%junctions.size()
        var j: Dictionary=junctions[idx]
        if bool(j.get("bridge",false)):
            continue
        social_setpieces.append({
            "kind":"corner_queue",
            "pos":Vector2(j.pos)+Vector2(86 if i%2==0 else -86,72 if i%3==0 else -72),
            "seed":idx*31,
            "count":3+(i%3)
        })

    # Authored crowd pockets in plazas, heritage markets and nightlife zones.
    for di in range(districts.size()):
        var d: Dictionary=districts[di]
        var style:=str(d.style)
        if style in ["center","heritage","neon","expo","harbor","campus"]:
            social_setpieces.append({
                "kind":"plaza_crowd" if style not in ["heritage","harbor"] else "market_crowd",
                "pos":Vector2(d.rect.get_center())+Vector2((di%3-1)*140.0,((di*2)%3-1)*120.0),
                "seed":di*47+17,
                "count":5+(di%4)
            })

    # District-authored scene identities beyond generic plazas.
    for di in range(districts.size()):
        var d: Dictionary=districts[di]
        var center:=Vector2(d.rect.get_center())
        var style:=str(d.style)
        if style in ["harbor","industry","rail"]:
            social_setpieces.append({"kind":"work_shift","pos":center+Vector2(180,-120),"seed":di*61+5,"count":4+(di%3)})
        elif style=="campus":
            social_setpieces.append({"kind":"campus_edge","pos":center+Vector2(-160,130),"seed":di*61+11,"count":5+(di%2)})
        elif style in ["neon","culture"]:
            social_setpieces.append({"kind":"nightlife_cluster","pos":center+Vector2(150,90),"seed":di*61+17,"count":5+(di%3)})
        elif style in ["green","garden"]:
            social_setpieces.append({"kind":"park_picnic","pos":center+Vector2(-120,-100),"seed":di*61+23,"count":4+(di%3)})

    # Rain shelters near selected cafés and transit stops.
    var shelter_count:=0
    for si in range(social_setpieces.size()):
        var base: Dictionary=social_setpieces[si]
        if str(base.kind) not in ["transit_wait","cafe_cluster"]:
            continue
        social_setpieces.append({
            "kind":"rain_shelter",
            "pos":Vector2(base.pos)+Vector2(22,-18),
            "seed":int(base.seed)+503,
            "count":3+(shelter_count%3)
        })
        shelter_count+=1
        if shelter_count>=10:
            break

    var incident_indices: Array=[5,18,31,44,57,70]
    for ii in range(incident_indices.size()):
        if junctions.is_empty():
            break
        var ji: int=int(incident_indices[ii])%junctions.size()
        var jn: Dictionary=junctions[ji]
        response_incidents.append({
            "id":"incident_%d" % ii,
            "pos":Vector2(jn.pos)+Vector2(55 if ii%2==0 else -55,42 if ii%3==0 else -42),
            "road":int(jn.a) if ii%2==0 else int(jn.b),
            "kind":["maintenance","response","utility"][ii%3],
            "seed":ii*37+3
        })

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
    hud_root=Control.new()
    hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud_root.mouse_filter=Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud_root)

    var mission_panel := PanelContainer.new()
    mission_panel.position = Vector2(20, 38)
    mission_panel.custom_minimum_size = Vector2(655, 122)
    mission_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0.025,0.075,0.105,0.91)
    sb.border_color = Color(0.35,0.85,0.75,0.22)
    sb.set_border_width_all(2)
    sb.content_margin_left=16
    sb.content_margin_right=150
    sb.content_margin_top=10
    sb.content_margin_bottom=12
    sb.corner_radius_top_left = 22
    sb.corner_radius_top_right = 22
    sb.corner_radius_bottom_left = 22
    sb.corner_radius_bottom_right = 22
    mission_panel.add_theme_stylebox_override("panel", sb)
    var vb := VBoxContainer.new()
    vb.add_theme_constant_override("separation", 5)
    mission_panel.add_child(vb)
    var title := Label.new()
    title.text = "PARALLAX HUNT · 1.23"
    title.add_theme_font_size_override("font_size", 24)
    title.modulate = Color("#7ff0d2")
    vb.add_child(title)
    mission_label = Label.new()
    mission_label.text = "Echoes in the Megacity"
    mission_label.add_theme_font_size_override("font_size", 30)
    vb.add_child(mission_label)
    mission_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    mission_label.custom_minimum_size.x=465
    mission_progress_bar=ProgressBar.new()
    mission_progress_bar.custom_minimum_size=Vector2(0,5)
    mission_progress_bar.show_percentage=false
    var track:=StyleBoxFlat.new()
    track.bg_color=Color("#193341")
    track.set_corner_radius_all(3)
    var fill:=StyleBoxFlat.new()
    fill.bg_color=Color("#73f3ce")
    fill.set_corner_radius_all(3)
    mission_progress_bar.add_theme_stylebox_override("background",track)
    mission_progress_bar.add_theme_stylebox_override("fill",fill)
    vb.add_child(mission_progress_bar)
    detail_label = Label.new()
    detail_label.text = "Echo-Signale bergen und Perspektivverstecke entdecken."
    detail_label.visible=hud_details_visible
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.add_theme_font_size_override("font_size", 20)
    detail_label.modulate = Color("#c7d6de")
    vb.add_child(detail_label)
    hud_root.add_child(mission_panel)
    var hud_button=Button.new()
    hud_button.text="INFO"
    hud_button.position=Vector2(525,42)
    hud_button.size=Vector2(122,72)
    hud_button.pressed.connect(func():
        hud_details_visible=not hud_details_visible
        detail_label.visible=hud_details_visible)
    hud_root.add_child(hud_button)
    tracking_label=Label.new()
    tracking_label.position=Vector2(24,300)
    tracking_label.add_theme_font_size_override("font_size",20)
    tracking_label.modulate=Color("#9cb9c4")
    hud_root.add_child(tracking_label)
    recenter_hud_button=Button.new()
    var recenter_button=recenter_hud_button
    recenter_button.text="◎"
    recenter_button.tooltip_text="Perspektive zentrieren"
    recenter_button.position=Vector2(952,300)
    recenter_button.size=Vector2(90,76)
    recenter_button.pressed.connect(_recenter_headtracking)
    hud_root.add_child(recenter_button)
    interior_exit_button=Button.new()
    interior_exit_button.text="ZUR STRASSE"
    interior_exit_button.position=Vector2(775,300)
    interior_exit_button.size=Vector2(265,76)
    interior_exit_button.visible=false
    interior_exit_button.pressed.connect(_leave_interior)
    hud_root.add_child(interior_exit_button)
    objective_label=Label.new()
    objective_label.position=Vector2(140,392)
    objective_label.size=Vector2(800,80)
    objective_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    objective_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    objective_label.add_theme_font_size_override("font_size",23)
    objective_label.add_theme_color_override("font_shadow_color",Color("#07131c"))
    objective_label.add_theme_constant_override("shadow_offset_x",2)
    objective_label.add_theme_constant_override("shadow_offset_y",2)
    hud_root.add_child(objective_label)

    status_label = Label.new()
    status_label.position = Vector2(20, 205)
    status_label.size=Vector2(1035,90)
    status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    status_label.add_theme_font_size_override("font_size", 21)
    status_label.modulate = Color("#d9e9ef")
    hud_root.add_child(status_label)

    district_banner = Label.new()
    district_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    district_banner.position = Vector2(80, 735)
    district_banner.size = Vector2(920, 100)
    district_banner.add_theme_font_size_override("font_size", 27)
    district_banner.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    district_banner.add_theme_color_override("font_shadow_color",Color("#06121a"))
    district_banner.add_theme_constant_override("shadow_offset_y",3)
    district_banner.modulate = Color(1,1,1,0)
    hud_root.add_child(district_banner)

    reward_panel = PanelContainer.new()
    reward_panel.position = Vector2(68,510)
    reward_panel.size = Vector2(944,190)
    reward_panel.visible = false
    reward_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var rsb := StyleBoxFlat.new()
    rsb.bg_color = Color(0.025,0.06,0.075,0.96)
    rsb.border_color = Color(0.45,0.95,0.82,0.72)
    rsb.set_content_margin_all(32)
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
    reward_body.add_theme_font_size_override("font_size",25)
    reward_body.modulate = Color("#e4eef1")
    rvb.add_child(reward_body)
    hud_root.add_child(reward_panel)

    var pause_button := Button.new()
    pause_button.text = "☰"
    pause_button.position = Vector2(690,42)
    pause_button.size = Vector2(70,72)
    pause_button.add_theme_font_size_override("font_size",28)
    pause_button.pressed.connect(_return_to_main_menu)
    hud_root.add_child(pause_button)

    var map_button := Button.new()
    map_button.text = "KARTE"
    map_button.position = Vector2(770,42)
    map_button.size = Vector2(125,72)
    map_button.add_theme_font_size_override("font_size",22)
    map_button.pressed.connect(_toggle_map)
    hud_root.add_child(map_button)

    var mission_button := Button.new()
    mission_button.text = "AUFTRÄGE"
    mission_button.position = Vector2(905,42)
    mission_button.size = Vector2(150,72)
    mission_button.add_theme_font_size_override("font_size",19)
    mission_button.pressed.connect(_toggle_missions)
    hud_root.add_child(mission_button)

    var collection_button := Button.new()
    collection_button.text = "SAMMLUNG"
    collection_button.position = Vector2(610,2060)
    collection_button.size = Vector2(200,110)
    collection_button.add_theme_font_size_override("font_size",18)
    collection_button.pressed.connect(_toggle_collection)
    hud_root.add_child(collection_button)

    photo_target_label = Label.new()
    photo_target_label.position=Vector2(55,90)
    photo_target_label.size=Vector2(970,115)
    photo_target_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    photo_target_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    photo_target_label.add_theme_font_size_override("font_size",25)
    photo_target_label.modulate=Color("#f7fbff")
    photo_target_label.visible=false
    hud_root.add_child(photo_target_label)

    photo_status_label = Label.new()
    photo_status_label.position=Vector2(60,205)
    photo_status_label.size=Vector2(960,80)
    photo_status_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    photo_status_label.add_theme_font_size_override("font_size",17)
    photo_status_label.modulate=Color("#ffcf8a")
    photo_status_label.visible=false
    hud_root.add_child(photo_status_label)

    photo_shutter_button = Button.new()
    photo_shutter_button.text="FOTO"
    photo_shutter_button.position=Vector2(400,1910)
    photo_shutter_button.size=Vector2(280,120)
    photo_shutter_button.add_theme_font_size_override("font_size",27)
    photo_shutter_button.visible=false
    photo_shutter_button.pressed.connect(_photo_shutter)
    hud_root.add_child(photo_shutter_button)

    photo_exit_button = Button.new()
    photo_exit_button.text="VERLASSEN"
    photo_exit_button.position=Vector2(70,1940)
    photo_exit_button.size=Vector2(220,90)
    photo_exit_button.visible=false
    photo_exit_button.pressed.connect(_exit_photo_mode)
    hud_root.add_child(photo_exit_button)

    photo_hint_button = Button.new()
    photo_hint_button.text="HINWEIS"
    photo_hint_button.position=Vector2(790,1940)
    photo_hint_button.size=Vector2(220,90)
    photo_hint_button.visible=false
    photo_hint_button.pressed.connect(_photo_hint)
    hud_root.add_child(photo_hint_button)

    photo_zoom_in_button = Button.new()
    photo_zoom_in_button.text="+"
    photo_zoom_in_button.position=Vector2(890,1680)
    photo_zoom_in_button.size=Vector2(110,100)
    photo_zoom_in_button.add_theme_font_size_override("font_size",30)
    photo_zoom_in_button.visible=false
    photo_zoom_in_button.pressed.connect(_photo_zoom.bind(-7.0))
    hud_root.add_child(photo_zoom_in_button)

    photo_zoom_out_button = Button.new()
    photo_zoom_out_button.text="−"
    photo_zoom_out_button.position=Vector2(890,1790)
    photo_zoom_out_button.size=Vector2(110,100)
    photo_zoom_out_button.add_theme_font_size_override("font_size",30)
    photo_zoom_out_button.visible=false
    photo_zoom_out_button.pressed.connect(_photo_zoom.bind(7.0))
    hud_root.add_child(photo_zoom_out_button)

    game_panel = PanelContainer.new()
    game_panel.position = Vector2(80,510)
    game_panel.size = Vector2(920,1300)
    game_panel.visible = false
    var gsb := StyleBoxFlat.new()
    gsb.bg_color = Color(0.025,0.055,0.075,0.985)
    gsb.border_color = Color(0.45,0.95,0.82,0.45)
    gsb.set_border_width_all(2)
    gsb.corner_radius_top_left = 24
    gsb.corner_radius_top_right = 24
    gsb.corner_radius_bottom_left = 24
    gsb.corner_radius_bottom_right = 24
    gsb.content_margin_left=30
    gsb.content_margin_right=30
    gsb.content_margin_top=30
    gsb.content_margin_bottom=26
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
    game_info.add_theme_font_size_override("font_size",26)
    gvb.add_child(game_info)
    game_status = Label.new()
    game_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    game_status.add_theme_font_size_override("font_size",26)
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
    hud_root.add_child(game_panel)

    commerce_panel = PanelContainer.new()
    commerce_panel.position = Vector2(80,590)
    commerce_panel.size = Vector2(920,1180)
    commerce_panel.visible = false
    var csb := StyleBoxFlat.new()
    csb.bg_color = Color(0.025,0.055,0.075,0.985)
    csb.border_color = Color(1.0,0.82,0.47,0.38)
    csb.set_content_margin_all(32)
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
    commerce_info.add_theme_font_size_override("font_size",26)
    cvb.add_child(commerce_info)
    commerce_actions = VBoxContainer.new()
    commerce_actions.add_theme_constant_override("separation",10)
    cvb.add_child(commerce_actions)
    var close_commerce := Button.new()
    close_commerce.text = "SCHLIESSEN"
    close_commerce.custom_minimum_size = Vector2(0,70)
    close_commerce.pressed.connect(_close_commerce)
    cvb.add_child(close_commerce)
    hud_root.add_child(commerce_panel)

    scan_button = Button.new()
    scan_button.text = "SCAN"
    scan_button.position = Vector2(820, 2060)
    scan_button.size = Vector2(210, 110)
    scan_button.add_theme_font_size_override("font_size", 28)
    scan_button.pressed.connect(_scan)
    hud_root.add_child(scan_button)
    interact_button = Button.new()
    interact_button.text = "INTERACT"
    interact_button.position = Vector2(790, 1925)
    interact_button.size = Vector2(240, 115)
    interact_button.add_theme_font_size_override("font_size", 25)
    interact_button.pressed.connect(_interact)
    hud_root.add_child(interact_button)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.position = Vector2(80,780)
    dialogue_panel.size = Vector2(920,780)
    dialogue_panel.visible = false
    var dsb := StyleBoxFlat.new()
    dsb.bg_color = Color(0.025,0.055,0.075,0.97)
    dsb.border_color = Color(0.60,0.92,0.86,0.38)
    dsb.set_content_margin_all(32)
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
    dialogue_body.add_theme_font_size_override("font_size",26)
    dialogue_body.custom_minimum_size = Vector2(0,210)
    dvb.add_child(dialogue_body)
    dialogue_actions = VBoxContainer.new()
    dialogue_actions.add_theme_constant_override("separation",8)
    dvb.add_child(dialogue_actions)
    hud_root.add_child(dialogue_panel)

    # Full-screen native main menu. Added last so it owns input while visible.
    main_menu_panel = PanelContainer.new()
    main_menu_panel.position = Vector2(0,0)
    main_menu_panel.size = Vector2(1080,2340)
    var msb := StyleBoxFlat.new()
    msb.bg_color = Color(0.018,0.045,0.064,0.94)
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
    camera_option_button=Button.new()
    camera_option_button.custom_minimum_size=Vector2(0,62)
    camera_option_button.pressed.connect(_toggle_camera_tracking)
    options_box.add_child(camera_option_button)
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
    hud_root.add_child(main_menu_panel)
    _apply_game_theme(layer)
    _build_modal_layer()

func _build_modal_layer() -> void:
    var layer=CanvasLayer.new()
    layer.layer=45
    add_child(layer)
    modal_root=Control.new()
    modal_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_root.mouse_filter=Control.MOUSE_FILTER_STOP
    layer.add_child(modal_root)
    var dimmer=ColorRect.new()
    dimmer.color=Color(0.015,0.035,0.05,0.88)
    dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    dimmer.mouse_filter=Control.MOUSE_FILTER_STOP
    modal_root.add_child(dimmer)
    city_menus=CityMenus.new()
    modal_root.add_child(city_menus)
    city_menus.setup(self)
    for panel in [game_panel,commerce_panel,dialogue_panel,main_menu_panel]:
        panel.reparent(modal_root)
        if panel!=main_menu_panel: panel.minimum_size_changed.connect(_queue_modal_fit)
    _sync_modal_ui()

func _modal_active() -> bool:
    return main_menu_active or map_open or missions_open or collection_open or minigame_open or (is_instance_valid(commerce_panel) and commerce_panel.visible) or (is_instance_valid(dialogue_panel) and dialogue_panel.visible)

func _sync_modal_ui() -> void:
    if not is_instance_valid(modal_root): return
    var active:=_modal_active()
    var state: String="map" if map_open else ("missions" if missions_open else ("collection" if collection_open else ("main" if main_menu_active else ("puzzle" if minigame_open else ("commerce" if commerce_panel.visible else ("dialogue" if dialogue_panel.visible else ""))))))
    hud_root.visible=not active and not photo_mode
    modal_root.visible=active
    city_menus.visible=map_open or missions_open or collection_open
    if state!=modal_state:
        move_touch=-1
        look_touch=-1
        move_vec=Vector2.ZERO
        move_origin=Vector2.ZERO
        move_now=Vector2.ZERO
        view_touch=Vector2.ZERO
        desktop_look_drag=false
        vehicle_velocity=0.0
        if city_menus.visible: city_menus.show_section(state)
        if active:
            if reward_tween: reward_tween.kill()
            if notice_tween: notice_tween.kill()
            reward_panel.visible=false
            district_banner.modulate.a=0
        modal_state=state
        if active: _queue_modal_fit()

func _queue_modal_fit() -> void:
    if modal_fit_pending: return
    modal_fit_pending=true
    call_deferred("_fit_modal_cards")

func _fit_modal_cards() -> void:
    # Wrapped labels need their assigned width before measuring the card height.
    await get_tree().process_frame
    await get_tree().process_frame
    for panel in [dialogue_panel,commerce_panel,game_panel]:
        if panel.visible:
            panel.size=Vector2(920,maxf(640,panel.get_combined_minimum_size().y))
            panel.position=Vector2(80,maxf(150,(get_viewport_rect().size.y-panel.size.y)*0.5))
    modal_fit_pending=false

func _close_overview() -> void:
    map_open=false
    missions_open=false
    collection_open=false
    _sync_modal_ui()
    _update_ui()

func _open_overview(kind: String) -> void:
    if photo_mode or minigame_open or main_menu_active: return
    _close_dialogue()
    _close_commerce()
    map_open=kind=="map"
    missions_open=kind=="missions"
    collection_open=kind=="collection"
    _sync_modal_ui()
    queue_redraw()

func _apply_game_theme(node: Node) -> void:
    if node is Button:
        var normal:=StyleBoxFlat.new()
        normal.bg_color=Color(0.025,0.050,0.072,0.95)
        normal.border_color=Color(0.50,0.66,0.72,0.40)
        normal.set_border_width_all(2)
        normal.set_corner_radius_all(14)
        normal.content_margin_left=16
        normal.content_margin_right=16
        normal.content_margin_top=9
        normal.content_margin_bottom=9
        var pressed: StyleBoxFlat=normal.duplicate()
        pressed.bg_color=Color("#24675f")
        pressed.border_color=Color("#73f3ce")
        var hover: StyleBoxFlat=normal.duplicate()
        hover.bg_color=Color("#1c3749")
        hover.border_color=Color("#a7cbd2")
        node.add_theme_stylebox_override("normal",normal)
        node.add_theme_stylebox_override("pressed",pressed)
        node.add_theme_stylebox_override("hover",hover)
        node.add_theme_color_override("font_color",Color("#e4ece9"))
        node.add_theme_font_size_override("font_size",maxi(23,node.get_theme_font_size("font_size")))
    for child in node.get_children():
        _apply_game_theme(child)

func _haptic(duration_ms: int = 45) -> void:
    if not haptics_enabled:
        return
    if OS.get_name()=="Android":
        Input.vibrate_handheld(duration_ms)

func _polyline_length(points: PackedVector2Array) -> float:
    var total: float=0.0
    for i in range(points.size()-1):
        total+=points[i].distance_to(points[i+1])
    return total

func _seed_neighborhood_start() -> void:
    # A walkable first minute, with the same permanent collectible IDs and vehicle indices.
    var nearby: Array[Vector2]=[Vector2(5120,4140),Vector2(5150,4320),Vector2(5190,4480),Vector2(4940,4490),Vector2(4860,4380)]
    for i in range(mini(nearby.size(),fragments.size())):
        var candidate:=nearby[i]
        for n in range(16):
            if not _point_blocked(candidate,14):
                break
            candidate=nearby[i]+Vector2.from_angle(float(n)*TAU/16.0)*65
        if not _point_blocked(candidate,14):
            fragments[i]["pos"]=candidate
    for entry in [{"pos":Vector2(5090,4390),"class":"hatch","heading":-PI*0.5,"color":Color("#e3b456"),"occupied":false},{"pos":Vector2(7400,4515),"class":"sport","heading":0.0,"color":Color("#e24c4c"),"occupied":false}]:
        if not _point_blocked(Vector2(entry.pos),20):
            parked_cars.append(entry)
    mission_sites.append({"id":"centerWarmup","name":"Boulevard Signal Terminal","pos":Vector2(5200,4380),"game":"wire","reward":"Boulevard Key","difficulty":1})
    side_job_sites.append({"id":"jobs_boulevard","name":"Boulevard Jobboard","pos":Vector2(5200,4500)})
    # Reuse existing simulation actors for a populated first neighborhood;
    # the global actor count and persistent vehicle indices do not grow.
    var local_road:=_nearest_road_index(player_pos)
    var length:=_polyline_length(roads[local_road].points)
    var start_t:=_nearest_road_t_to_point(local_road,player_pos)
    for k in range(12):
        var index:=pedestrians.size()-1-k
        var ped: Dictionary=pedestrians[index]
        var direction:=1.0 if k%2==0 else -1.0
        ped["road"]=local_road
        ped["t"]=clampf(start_t+float(k-6)*61.0/length,0.02,0.98)
        ped["target_t"]=clampf(float(ped.t)+direction*760.0/length,0.02,0.98)
        ped["reverse"]=direction<0
        ped["side"]=-1.0 if k%3==0 else 1.0
        ped["speed"]=(28.0+float(k%4)*4.0)/length
        ped["state"]="walk"
        ped["pause"]=0.0
        ped["social_partner"]=-1
        pedestrians[index]=ped
    var car_count:=0
    for index in range(traffic.size()-1,-1,-1):
        var car: Dictionary=traffic[index]
        if _is_emergency_archetype(str(car.archetype)):
            continue
        car["road"]=local_road
        car["t"]=clampf(start_t+float(car_count-1)*280.0/length,0.02,0.98)
        car["reverse"]=car_count%2==0
        car["speed"]=120.0/length
        car["cruise"]=135.0/length
        traffic[index]=car
        car_count+=1
        if car_count>=3:
            break

func _on_tracking_status(message: String) -> void:
    camera_tracking_state=message
    _refresh_option_labels()

func _on_camera_head_pose(x: float, y: float, face_size: float, yaw: float, pitch: float) -> void:
    if not camera_tracking_enabled:
        return
    var pose:=Vector3(x,y,face_size)
    if not camera_head_calibrated:
        camera_head_zero=pose
        camera_pose_zero=Vector2(yaw,pitch)
        camera_head_calibrated=true
    var displacement:=pose-camera_head_zero
    var turn:=Vector2(yaw,pitch)-camera_pose_zero
    var target:=Vector2(displacement.x*2.4+turn.x/140.0,-displacement.y*2.4-turn.y/140.0)*sensor_gain
    var now:=Time.get_ticks_msec()
    var dt:=clampf(float(now-camera_head_last_ms)/1000.0,0.025,0.16)
    var smoothing:=1.0-exp(-dt*10.0)
    camera_head_view=camera_head_view.lerp(target.limit_length(0.85),smoothing)
    camera_head_depth=lerpf(camera_head_depth,clampf(displacement.z*2.5,-0.5,0.5),smoothing)
    camera_head_last_ms=now
    camera_tracking_state="Gesicht erkannt"

func _toggle_camera_tracking() -> void:
    camera_tracking_enabled=not camera_tracking_enabled
    camera_head_calibrated=false
    camera_head_last_ms=0
    camera_head_view=Vector2.ZERO
    if camera_tracker!=null:
        camera_tracker.call("startTracking" if camera_tracking_enabled else "stopTracking")
        camera_tracking_state="Gesicht suchen" if camera_tracking_enabled else "aus"
    elif camera_tracking_enabled:
        camera_tracking_state="nicht verfügbar"
    _save_options()
    _refresh_option_labels()

func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_GO_BACK_REQUEST:
        if photo_mode: _exit_photo_mode()
        elif map_open or missions_open or collection_open: _close_overview()
        elif minigame_open: _close_minigame()
        elif commerce_panel.visible: _close_commerce()
        elif dialogue_panel.visible: _close_dialogue()
        elif interior_active: _leave_interior()
        elif not main_menu_active: _return_to_main_menu()
        else: get_tree().quit()
    elif what==NOTIFICATION_APPLICATION_PAUSED:
        if camera_tracker!=null:
            camera_tracker.call("stopTracking")
        if not main_menu_active:
            _save_game()
    elif what==NOTIFICATION_APPLICATION_RESUMED:
        _recenter_headtracking()
        if camera_tracking_enabled and camera_tracker!=null:
            camera_tracker.call("startTracking")

func _restore_collectible_flags(items: Array, flags: Variant, field: String, legacy_count: int) -> void:
    if flags is Array and not flags.is_empty():
        for i in range(mini(items.size(),flags.size())):
            items[i][field]=bool(flags[i])
    elif legacy_count>0:
        # Old saves stored totals only. Preserve them instead of granting the same rewards again.
        for i in range(mini(items.size(),legacy_count)):
            items[i][field]=true

func _run_quality_smoke_test() -> void:
    set_process(false)
    main_menu_active=false
    main_menu_panel.visible=false
    selected_save_slot=3
    _sync_modal_ui()
    assert(buildings.all(func(b): return waters.all(func(w): return not Rect2(w.rect).intersects(Rect2(b.rect)))),"No unexplained houses may sit inside water")
    var point_count:=0
    for group in [named_npcs,caches,glyphs,mission_sites,property_sites,vertical_sites,scan_points,photo_points,side_job_sites,city_micro_events,storefronts,fragments,secrets]:
        for entry in group:
            assert(CityAccess.connected(self,Vector2(entry.pos),14),"Every objective needs a continuous walking approach: "+str(entry))
            point_count+=1
    assert(junctions.all(func(j): return not bool(j.bridge)),"Every road-to-road node must be at grade")
    var road_x: float=roads[0].points[0].x
    var foot_a=Vector2(road_x+float(roads[0].width)*0.5+11.5,0)
    var foot_b=Vector2(foot_a.x,WORLD_SIZE.y)
    var sections=CityArt.clear_crossings(self,0,foot_a,foot_b,5)
    for junction in junctions:
        if int(junction.a)!=0: continue
        var crossing=Vector2(foot_a.x,junction.pos.y)
        assert(sections.all(func(section): return _distance_to_polyline(crossing,section)>10),"3D footways must have a gap across every crossing road")
    assert(not _point_blocked(Vector2(caches[1].pos),16),"Mira's canal archive must be reachable")
    active_npc_contract=_make_npc_contract("mira","Mira")
    player_pos=Vector2(caches[1].pos)+Vector2(0,25)
    assert(_npc_contract_target()==Vector2(caches[1].pos),"Mira must guide to the nearest remaining archive")
    var archive: Vector2=caches[1].pos
    player_pos=CityAccess.road_projections(self,archive)[0].pos
    move_vec=(archive-player_pos).normalized()
    for frame in range(90):
        if player_pos.distance_to(archive)<7: break
        _update_player(1.0/60.0)
    move_vec=Vector2.ZERO
    assert(player_pos.distance_to(archive)<12 and _nearest_interactable().type=="cache","The canal target must be collectable after a real walk across its bridge approach")

    active_npc_contract={}
    player_pos=Vector2(5100,4220)
    assert(CityAccess.connected(self,Vector2(_make_npc_contract("nova","Nova").target),14),"New personal visit contracts must have a walking approach")
    for target in district_access_points.values():
        assert(CityAccess.connected(self,Vector2(target),14),"Every district survey target must be accessible")
    var old_rng_state:=rng.state
    var old_jobs_done:=jobs_done
    var job_kinds: Dictionary={}
    rng.seed=123
    for attempt in range(49):
        active_job={}
        jobs_done=attempt
        _open_jobboard(attempt%side_job_sites.size())
        assert(not active_job.is_empty() and CityAccess.connected(self,Vector2(active_job.target),14),"New city jobs must guide to an accessible target")
        job_kinds[str(active_job.kind)]=true
    assert(job_kinds.has("delivery") and job_kinds.has("transit") and job_kinds.has("district"),"Exercise delivery, transit and survey creation")
    active_job={}
    jobs_done=old_jobs_done
    rng.state=old_rng_state
    for menu in ["map","collection","missions"]:
        _open_overview(menu)
        await get_tree().process_frame
        assert(modal_root.visible and city_menus.visible and not status_label.is_visible_in_tree() and not scan_button.is_visible_in_tree() and not tracking_label.is_visible_in_tree(),"Menus must own a clean layer without gameplay text or controls")
        var before:=player_pos
        move_vec=Vector2.RIGHT
        _update_player(0.25)
        assert(player_pos==before,"Modal UI must prevent movement")
        var touch=InputEventScreenTouch.new()
        touch.index=0
        touch.position=Vector2(160,1250)
        touch.pressed=true
        Input.parse_input_event(touch)
        await get_tree().process_frame
        touch.pressed=false
        Input.parse_input_event(touch)
        await get_tree().process_frame
        assert(move_touch==-1,"Menu scroll touches must never start the world joystick")
        _notification(NOTIFICATION_WM_GO_BACK_REQUEST)
        assert(hud_root.visible and not modal_root.visible)
    _talk_named_npc(0)
    for frame in range(5): await get_tree().process_frame
    assert(dialogue_panel.size.y<1100 and dialogue_panel.position.y>500,"Dialogue card must fit its actual content without filling the screen")
    _close_dialogue()
    for kind in ["bar","cafe","restaurant","home","shop","garage","workshop","hospital","openai_hq","roof","sublevel"]:
        for floor_index in range(2 if kind=="home" else 1):
            interior_kind=kind
            interior_floor=floor_index
            var grid=AStarGrid2D.new()
            grid.region=Rect2i(0,0,46,63)
            grid.cell_size=Vector2(20,20)
            grid.offset=Vector2(10,10)
            grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
            grid.update()
            for x in range(46):
                for y in range(63):
                    grid.set_point_solid(Vector2i(x,y),not InteriorArt.walkable(self,Vector2(x*20+10,y*20+10)))
            var start=Vector2i(23,57)
            var end=Vector2i(_interior_feature_pos()/20)
            assert(not grid.get_id_path(start,end).is_empty(),"Room feature must be reachable around furniture: "+kind+str(floor_index))
            assert(InteriorArt.walkable(self,Vector2(interior_size.x*.5,interior_size.y-48)),"Exit must stay accessible")
    interior_active=false
    var old_traffic:=traffic.duplicate(true)
    var old_agents:=smart_agents.duplicate(true)
    var old_cars:=parked_cars.duplicate(true)
    traffic.clear()
    smart_agents.clear()
    parked_cars=[{"pos":Vector2(12200,1200),"class":"hatch","heading":0.0,"color":Color.WHITE,"occupied":true}]
    current_vehicle=0
    for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
        player_pos=Vector2(12200,1200)
        parked_cars[0]["pos"]=player_pos
        var start:=player_pos
        player_heading=direction.angle()-PI*.5
        vehicle_velocity=0
        move_vec=direction*.65
        _update_player(0.02)
        assert(absf(wrapf(player_heading-direction.angle(),-PI,PI))>0.3,"Heading must turn smoothly, not snap")
        for frame in range(120): _update_player(1.0/60.0)
        assert(Vector2.from_angle(player_heading).dot(direction)>0.99 and (player_pos-start).dot(direction)>80,"Car must drive toward the chosen world direction")
        var released_pos:=player_pos
        move_vec=Vector2.ZERO
        for frame in range(90): _update_player(1.0/60.0)
        assert(vehicle_velocity==0 and player_pos.distance_to(released_pos)<110,"Releasing the stick must brake predictably")
    current_vehicle=-1
    traffic=old_traffic
    smart_agents=old_agents
    parked_cars=old_cars
    _show_reward_popup("ERSTE MELDUNG","Test")
    await get_tree().create_timer(0.9).timeout
    _show_reward_popup("NEUE MELDUNG","Bleibt bis zum eigenen Ablauf sichtbar")
    await get_tree().create_timer(3.0).timeout
    assert(reward_panel.visible and reward_title.text=="NEUE MELDUNG","An old popup timer must not hide a newer popup")
    print("QUALITY_SMOKE_OK · %d connected objectives / modal input / 12 room routes / directional steering / independent popup lifetime" % point_count)
    get_tree().quit()

func _capture_quality_frame(filename: String) -> void:
    _update_ui()
    queue_redraw()
    await get_tree().create_timer(0.4).timeout
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png("res://build/"+filename+".png")

func _run_quality_capture() -> void:
    main_menu_active=false
    main_menu_panel.visible=false
    camera_pos=player_pos
    world_zoom=2.65
    target_world_zoom=2.65
    for menu in ["map","collection","missions"]:
        _open_overview(menu)
        await _capture_quality_frame("menu-"+menu)
        _close_overview()
    var crossing: Dictionary=junctions.filter(func(j): return not bool(j.bridge) and Vector2(j.pos)==Vector2(2700,2600))[0]
    player_pos=Vector2(crossing.pos)+Vector2(80,100)
    camera_pos=Vector2(crossing.pos)
    set_process(false)
    await _capture_quality_frame("crossing-at-grade")
    for kind in ["bar","cafe","home","garage","shop","hospital","roof"]:
        _enter_interior({"bar":"Lumen Bar","cafe":"Prism Café","home":"Canal Loft","garage":"Vector Garage","shop":"Signal Store","hospital":"Parallax Stadtklinikum","roof":"Glass Quarter Roof"}[kind],kind,Color("#73f3ce"),player_pos)
        if notice_tween: notice_tween.kill()
        district_banner.modulate.a=0
        interior_player_pos=Vector2(460,1060)
        await _capture_quality_frame("interior-"+kind)
        _leave_interior()
    active_npc_contract=_make_npc_contract("mira","Mira")
    player_pos=Vector2(caches[1].pos)+Vector2(200,0)
    player_pos=CityAccess.safe_point(self,player_pos)
    camera_pos=player_pos
    current_vehicle=-1
    world_zoom=2.0
    if notice_tween: notice_tween.kill()
    district_banner.modulate.a=0
    await _capture_quality_frame("mira-canal-access")
    active_npc_contract={}
    _talk_named_npc(0)
    await _capture_quality_frame("dialogue-card")
    _close_dialogue()
    var warmup: Dictionary=mission_sites.filter(func(site): return str(site.id)=="centerWarmup")[0]
    _start_minigame(warmup)
    await _capture_quality_frame("puzzle-card")
    _close_minigame()
    get_tree().quit()

func _run_experience_smoke_test() -> void:
    main_menu_active=false
    main_menu_panel.visible=false
    selected_save_slot=3
    assert(CityArt.character_direction(0)==3 and CityArt.character_direction(PI)==1)
    assert(CityArt.character_direction(PI*0.5)==0 and CityArt.character_direction(-PI*0.5)==2)
    var target:=_closest_uncollected(fragments,"taken")
    assert(target!=Vector2.ZERO and player_pos.distance_to(target)<100)
    for fragment in fragments:
        if Vector2(fragment.pos)==target:
            fragment["taken"]=true
    assert(_closest_uncollected(fragments,"taken")!=target,"Collected signals must leave the objective route")
    _update_ui()
    assert(not objective_label.text.is_empty() and mission_progress_bar.max_value>0)
    assert(_localized_action("ENTER CAR")=="EINSTEIGEN")
    var site: Dictionary=mission_sites.filter(func(m): return str(m.id)=="centerWarmup")[0]
    _start_minigame(site)
    game_current=game_target.duplicate()
    assert(_wire_solved(),"Generated wire circuit must have a real source-to-target path")
    game_current[0]=_rotate_wire_mask(int(game_current[0]))
    assert(not _wire_solved(),"Disconnected source must break the circuit")
    var credits_before:=credits
    _wire_hint()
    assert(game_hints==1 and _wire_solved() and credits==credits_before+35)
    _wire_hint()
    _on_wire_cell(0)
    assert(game_hints==1 and credits==credits_before+35,"Finished circuit must grant one reward")
    _close_minigame()
    _start_minigame(site)
    await get_tree().create_timer(0.8).timeout
    assert(minigame_open,"A stale completion timer must not close a newly opened replay")
    _close_minigame()
    _start_photo_challenge(0)
    await get_tree().process_frame
    assert(photo_environment.background_mode==Environment.BG_SKY and photo_sky_material!=null)
    assert(photo_world_root.get_children().any(func(n): return n.name.begins_with("StreetEnsemble_")),"Photo street furniture must exist")
    _photo_hint()
    var hint_text:=photo_status_label.text
    _photo_refresh_labels()
    assert(photo_status_label.text==hint_text and photo_feedback_until>Time.get_ticks_msec(),"Photo hint must survive label refresh")
    _exit_photo_mode()
    _reset_game_state()
    await get_tree().create_timer(1.2).timeout
    print("EXPERIENCE_SMOKE_OK · directional art / nearest objectives / real circuits / hints / session guards / photo dressing")
    get_tree().quit()

func _run_city_smoke_test() -> void:
    main_menu_active=false
    main_menu_panel.visible=false
    selected_save_slot=3
    var original_pos:=player_pos
    assert(buildings.any(func(b): return bool(b.get("street_block",false))),"Authored street blocks missing")
    assert(street_ensembles.all(func(s): return CityArt.frontage_is_clear(self,Vector2(s.pos))),"Street furniture must stay off carriageways")
    assert(photo_points.all(func(ph): return not _point_blocked(Vector2(ph.pos),14)),"Photo observation points must be accessible")
    for i in range(5):
        assert(player_pos.distance_to(Vector2(fragments[i].pos))<500 and not _point_blocked(Vector2(fragments[i].pos),14),"Starter signals must be nearby and walkable")
    world_zoom=2.65
    camera_pos=player_pos
    view_amount=default_view_bias
    var delta_z:=_project(player_pos,100)-_project(player_pos)
    assert(delta_z.y<-100,"Buildings must show depth without a touch")
    move_vec=Vector2(1,0)
    var start:=player_pos
    _update_player(0.05)
    assert(player_pos!=start,"Player spawn must be walkable")
    move_vec=Vector2.ZERO
    var before_photo:=player_pos
    _start_photo_challenge(0)
    move_vec=Vector2(1,1)
    _update_player(0.2)
    assert(player_pos==before_photo,"Photo challenge must lock movement")
    assert(photo_viewport.render_target_update_mode==SubViewport.UPDATE_ALWAYS)
    _exit_photo_mode()
    assert(photo_viewport.render_target_update_mode==SubViewport.UPDATE_DISABLED)
    camera_tracking_enabled=true
    _on_camera_head_pose(0,0,0.3,0,0)
    _on_camera_head_pose(0.15,-0.1,0.38,12,5)
    assert(camera_head_view.x>0 and camera_head_depth>0,"Camera tracking must react to actual head position")
    camera_tracking_enabled=false
    camera_head_view=Vector2.ZERO
    var before_credits:=credits
    _start_minigame(mission_sites[0])
    _finish_minigame()
    _finish_minigame()
    assert(credits==before_credits+35,"Hack must grant exactly one reward")
    await get_tree().create_timer(0.8).timeout
    fragments[2]["taken"]=true
    photo_found["test"]=true
    micro_event_seen["test"]=true
    _save_game()
    fragments[2]["taken"]=false
    _load_game(3)
    assert(bool(fragments[2].taken),"Collectibles must survive a save/load")
    _reset_game_state()
    assert(photo_found.is_empty() and micro_event_seen.is_empty(),"New games must clear old progress")
    player_pos=original_pos
    print("CITY_SMOKE_OK · %d buildings · %d street blocks · %d chapters · tracking / photo / rewards / saves" % [buildings.size(),buildings.filter(func(b): return bool(b.get("street_block",false))).size(),native_chapters.size()])
    get_tree().quit()

func _run_art_capture() -> void:
    main_menu_active=false
    main_menu_panel.visible=false
    camera_pos=player_pos
    world_zoom=2.65
    target_world_zoom=2.65
    view_amount=default_view_bias
    await get_tree().create_timer(1.5).timeout
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png("res://build/city-foot.png")
    player_pos=Vector2(7450,4450)
    camera_pos=player_pos
    world_zoom=1.35
    current_vehicle=0
    await get_tree().create_timer(0.8).timeout
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png("res://build/city-drive.png")
    player_pos=Vector2(photo_points[0].pos)
    camera_pos=player_pos
    _start_photo_challenge(0)
    await get_tree().create_timer(0.8).timeout
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png("res://build/photo-hunt.png")
    _exit_photo_mode()
    reward_panel.visible=false
    player_pos=Vector2(5200,4380)
    current_vehicle=-1
    camera_pos=player_pos
    var warmup: Dictionary=mission_sites.filter(func(site): return str(site.id)=="centerWarmup")[0]
    _start_minigame(warmup)
    await get_tree().create_timer(0.3).timeout
    await RenderingServer.frame_post_draw
    get_viewport().get_texture().get_image().save_png("res://build/hacking.png")
    _close_minigame()
    await get_tree().create_timer(1.2).timeout
    get_tree().quit()

func _run_photo_smoke_test() -> void:
    main_menu_active=false
    if photo_points.is_empty():
        push_error("PHOTO_SMOKE: no photo points")
        get_tree().quit(41)
        return
    player_pos=Vector2(photo_points[0].pos)
    camera_pos=player_pos
    _start_photo_challenge(0)
    await get_tree().process_frame
    await get_tree().process_frame
    if not photo_mode or photo_viewport==null or photo_camera==null or photo_targets.size()<3 or photo_occluders.is_empty():
        push_error("PHOTO_SMOKE: photo mode failed to initialize")
        get_tree().quit(42)
        return
    _photo_update_camera()
    _update_photo_3d_scene(0.016)
    print("PHOTO_SMOKE_OK targets=",photo_targets.size()," cars=",photo_dynamic_cars.size()," peds=",photo_dynamic_peds.size())
    _exit_photo_mode()
    await get_tree().process_frame
    selected_save_slot=3
    var verified_spots:=0
    for index in range(photo_points.size()):
        _start_photo_challenge(index)
        await get_tree().process_frame
        var road_count:=0
        for child in photo_world_root.get_children():
            if child.name.begins_with("Road_") and not child.is_queued_for_deletion():
                road_count+=1
        if road_count==0:
            push_error("PHOTO_SMOKE: local roads missing at "+str(photo_points[index].id))
            get_tree().quit(43)
            return
        for target in photo_targets:
            if _photo_position_occluded(target.node.global_position):
                push_error("PHOTO_SMOKE: unreachable subject at "+str(photo_points[index].id))
                get_tree().quit(44)
                return
        if index==0:
            var target: Dictionary=photo_targets[0]
            photo_camera.look_at(target.node.global_position,Vector3.UP)
            _photo_shutter()
            assert(bool(photo_found.get(target.key,false)),"A visible centered photo subject must be collectible")
        _exit_photo_mode()
        await get_tree().process_frame
        verified_spots+=1
    print("PHOTO_SITES_OK · %d fixed spots · roads / visible subjects / shutter" % verified_spots)
    await get_tree().create_timer(1.6).timeout
    get_tree().quit(0)

func _build_photo_3d_system() -> void:
    var screen_size := get_viewport_rect().size
    photo_viewport=SubViewport.new()
    photo_viewport.size=Vector2i(maxi(640,int(screen_size.x)),maxi(960,int(screen_size.y)))
    photo_viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED
    photo_viewport.transparent_bg=false
    add_child(photo_viewport)

    photo_world_root=Node3D.new()
    photo_viewport.add_child(photo_world_root)

    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    photo_environment=env
    env.background_mode=Environment.BG_COLOR
    env.background_color=Color("#9cc5d8")
    env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color=Color("#d8e7ec")
    env.ambient_light_energy=0.72
    env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
    photo_sky_material=ProceduralSkyMaterial.new()
    photo_sky_material.sky_curve=0.25
    photo_sky_material.ground_curve=0.20
    photo_sky_material.sun_angle_max=8
    var sky:=Sky.new()
    sky.sky_material=photo_sky_material
    sky.radiance_size=Sky.RADIANCE_SIZE_128
    env.sky=sky
    env.background_mode=Environment.BG_SKY
    world_env.environment=env
    photo_world_root.add_child(world_env)

    var sun := DirectionalLight3D.new()
    photo_sun=sun
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
    photo_view_rect.size=screen_size
    photo_view_rect.texture=photo_viewport.get_texture()
    photo_view_rect.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    photo_view_rect.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    photo_view_rect.visible=false
    photo_view_rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var layer := CanvasLayer.new()
    layer.layer=30
    add_child(layer)
    layer.add_child(photo_view_rect)

    photo_ui_layer=CanvasLayer.new()
    photo_ui_layer.layer=40
    add_child(photo_ui_layer)

    photo_flash_rect=ColorRect.new()
    photo_flash_rect.position=Vector2.ZERO
    photo_flash_rect.size=screen_size
    photo_flash_rect.color=Color.WHITE
    photo_flash_rect.modulate=Color(1,1,1,0)
    photo_flash_rect.mouse_filter=Control.MOUSE_FILTER_IGNORE
    photo_ui_layer.add_child(photo_flash_rect)

    for ctrl in [photo_target_label,photo_status_label,photo_shutter_button,photo_exit_button,photo_hint_button,photo_zoom_in_button,photo_zoom_out_button]:
        ctrl.reparent(photo_ui_layer)

    photo_crosshair=Label.new()
    photo_crosshair.text="+"
    photo_crosshair.position=screen_size*0.5-Vector2(38,42)
    photo_crosshair.size=Vector2(76,76)
    photo_crosshair.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    photo_crosshair.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    photo_crosshair.add_theme_font_size_override("font_size",42)
    photo_crosshair.modulate=Color(1,1,1,0.82)
    photo_crosshair.visible=false
    photo_crosshair.mouse_filter=Control.MOUSE_FILTER_IGNORE
    photo_ui_layer.add_child(photo_crosshair)

func _photo_apply_lighting() -> void:
    if photo_environment==null or photo_sun==null:
        return
    var hour: float = fposmod(world_clock,24.0)
    var daylight: float = clampf(sin((hour-6.0)/12.0*PI),0.0,1.0)
    var twilight: float = clampf(1.0-abs(hour-18.5)/2.5,0.0,1.0)
    if hour<6.0:
        twilight=maxf(twilight,clampf(1.0-abs(hour-5.5)/2.0,0.0,1.0))
    var day_sky := Color("#9cc5d8")
    var dusk_sky := Color("#7d7892")
    var night_sky := Color("#101927")
    var sky: Color = night_sky.lerp(dusk_sky,twilight*0.72).lerp(day_sky,daylight)
    var weather := _weather_state()
    var weather_strength := _weather_strength()
    if weather=="mist":
        sky=sky.lerp(Color("#9aadb2"),0.46)
    elif weather=="rain":
        sky=sky.lerp(Color("#526671"),0.52)
    elif weather=="storm":
        sky=sky.lerp(Color("#303b4a"),0.70)
    photo_environment.background_color=sky
    if photo_sky_material!=null:
        photo_sky_material.sky_top_color=sky.darkened(0.32)
        photo_sky_material.sky_horizon_color=sky.lerp(Color("#dcb4a0"),twilight*0.45).lightened(0.18)
        photo_sky_material.ground_bottom_color=Color("#28363b")
        photo_sky_material.ground_horizon_color=photo_sky_material.sky_horizon_color
        photo_sky_material.sky_energy_multiplier=0.8
    photo_environment.ambient_light_color=Color("#7f91aa").lerp(Color("#d8e7ec"),daylight)
    photo_environment.ambient_light_energy=(0.50+daylight*0.30+twilight*0.18)*(1.0-weather_strength*0.20)
    photo_environment.fog_enabled=true
    photo_environment.fog_sky_affect=0.12
    if photo_environment.fog_enabled:
        photo_environment.fog_light_color=sky.lightened(0.12)
        photo_environment.fog_density=0.008 if weather=="mist" else (0.004 if weather=="rain" else (0.006 if weather=="storm" else 0.0013))
    else:
        photo_environment.fog_density=0.0
    photo_sun.light_energy=(0.25+daylight*1.10+twilight*0.35)*(1.0-weather_strength*0.38)
    photo_sun.light_color=Color("#ffb987").lerp(Color("#fff6db"),daylight)
    photo_sun.rotation_degrees=Vector3(-18.0-daylight*42.0,-40.0+hour*5.0,0.0)

func _photo_clear_3d_scene() -> void:
    if photo_world_root==null:
        return
    for child in photo_world_root.get_children():
        if child==photo_camera or child is WorldEnvironment or child is DirectionalLight3D:
            continue
        child.queue_free()
    photo_dynamic_cars.clear()
    photo_dynamic_peds.clear()
    photo_dynamic_transit.clear()
    photo_targets.clear()
    photo_occluders.clear()

func _photo_material(color: Color, metallic: float = 0.0, roughness: float = 0.72) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color=color
    mat.metallic=metallic
    mat.roughness=roughness
    if color.a < 0.995:
        mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
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

func _photo_clip_road(a: Vector2, b: Vector2, center: Vector2, radius: float) -> PackedVector2Array:
    # Long city roads often have their midpoint outside the local photo scene.
    # Clip the actual segment against the scene bounds instead of dropping it.
    var bounds:=Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2)
    var direction:=b-a
    var first:=0.0
    var last:=1.0
    for axis in range(2):
        if absf(direction[axis])<0.0001:
            if a[axis]<bounds.position[axis] or a[axis]>bounds.end[axis]:
                return PackedVector2Array()
        else:
            var near_t: float=(bounds.position[axis]-a[axis])/direction[axis]
            var far_t: float=(bounds.end[axis]-a[axis])/direction[axis]
            first=maxf(first,minf(near_t,far_t))
            last=minf(last,maxf(near_t,far_t))
            if first>last:
                return PackedVector2Array()
    return PackedVector2Array([a.lerp(b,first),a.lerp(b,last)])

func _photo_build_scene(index: int) -> void:
    _photo_clear_3d_scene()
    var ph: Dictionary = photo_points[index]
    var center: Vector2 = Vector2(ph.pos)
    var radius: float = 1250.0

    var photo_weather := _weather_state()
    var ground_color := Color("#596b62")
    if photo_weather in ["rain","storm"]:
        ground_color=Color("#465651")
    elif photo_weather=="mist":
        ground_color=Color("#56615c")
    var ground:=_photo_box("Ground",Vector3(0,-0.35,0),Vector3(320,0.6,320),ground_color)
    var district_style: String=str(_district_at(center).style)
    if district_style not in ["green","garden","wind"] and graphics_quality>0:
        ground.material_override=PhotoArt.paving_material(district_style)

    # Roads become real 3D slabs around the fixed observation point.
    for ri in range(roads.size()):
        var road = roads[ri]
        var pts: PackedVector2Array = road.points
        for k in range(pts.size()-1):
            var segment:=_photo_clip_road(pts[k],pts[k+1],center,radius)
            if segment.is_empty():
                continue
            var a: Vector2 = segment[0]
            var b: Vector2 = segment[1]
            var la := _photo_local(a,center,0.0)
            var lb := _photo_local(b,center,0.0)
            var delta := lb-la
            var length: float = Vector2(delta.x,delta.z).length()
            if length<0.5:
                continue
            var road_color := Color("#30383d")
            if photo_weather in ["rain","storm"]:
                road_color=Color("#1f292f")
            var slab := _photo_box("Road_%d_%d" % [ri,k],(la+lb)*0.5+Vector3(0,0.14,0),Vector3(float(road.width)*0.10,0.16,length),road_color)
            if graphics_quality>0:
                var asphalt:=StandardMaterial3D.new()
                asphalt.albedo_texture=CityArt.ASPHALT
                asphalt.albedo_color=Color(0.64,0.70,0.81)
                asphalt.uv1_scale=Vector3(float(road.width)*0.10/16.0,length/16.0,1)
                asphalt.roughness=0.96
                slab.material_override=asphalt
            slab.rotation.y=atan2(delta.x,delta.z)
            var flat_dir := Vector2(delta.x,delta.z).normalized()
            var flat_normal := Vector2(-flat_dir.y,flat_dir.x)
            var world_tangent=(b-a).normalized()
            var world_normal=Vector2(-world_tangent.y,world_tangent.x)
            for side_sign in [-1.0,1.0]:
                var offset=world_normal*(float(road.width)*0.5+11.5)*side_sign
                var footways=CityArt.clear_crossings(self,ri,a+offset,b+offset,5.0)
                for footway in footways:
                    var wa=_photo_local(footway[0],center,0.0)
                    var wb=_photo_local(footway[1],center,0.0)
                    var distance=wa.distance_to(wb)
                    var walk=_photo_box("Walk_%d_%d_%d" % [ri,k,int(side_sign)],(wa+wb)*0.5+Vector3(0,0.26,0),Vector3(2.0,0.24,distance),Color("#82908f"))
                    walk.rotation.y=atan2((wb-wa).x,(wb-wa).z)
                    if graphics_quality>0: walk.material_override=PhotoArt.paving_material(str(_district_at(center).style))
            for lane_section in CityArt.clear_crossings(self,ri,a,b,47):
                var lane_a=_photo_local(lane_section[0],center,0.0)
                var lane_b=_photo_local(lane_section[1],center,0.0)
                var lane=_photo_box("Lane_%d_%d" % [ri,k],(lane_a+lane_b)*0.5+Vector3(0,0.25,0),Vector3(0.16,0.05,lane_a.distance_to(lane_b)),Color(0.92,0.90,0.72,0.85))
                lane.rotation.y=atan2((lane_b-lane_a).x,(lane_b-lane_a).z)

    for j in junctions:
        if Vector2(j.pos).distance_to(center)>radius or bool(j.bridge):
            continue
        for axis in range(2):
            var own: Dictionary=roads[int(j.a) if axis==0 else int(j.b)]
            var other: Dictionary=roads[int(j.b) if axis==0 else int(j.a)]
            var tangent:=_closest_road_tangent(int(j.a) if axis==0 else int(j.b),Vector2(j.pos))
            var normal:=Vector2(-tangent.y,tangent.x)
            var count:=maxi(3,int(float(own.width)/13.0))
            for side_sign in [-1.0,1.0]:
                for stripe in range(count):
                    var offset: Vector2=tangent*(float(other.width)*0.5+19)*side_sign+normal*(float(stripe)-float(count-1)*0.5)*12
                    var crossing:=_photo_box("Crossing",_photo_local(Vector2(j.pos)+offset,center,0.28),Vector3(0.65,0.025,2.7),Color("#e6e1cf"))
                    crossing.rotation.y=-tangent.angle()+PI*0.5

    # Nearby procedural buildings become 3D masses with roof caps and windows.
    var built: int = 0
    var local_buildings: Array=buildings.filter(func(b): return Rect2(b.rect).get_center().distance_to(center)<radius)
    local_buildings.sort_custom(func(a,b): return Rect2(a.rect).get_center().distance_squared_to(center)<Rect2(b.rect).get_center().distance_squared_to(center))
    for bi in range(local_buildings.size()):
        var b: Dictionary = local_buildings[bi]
        var rect: Rect2 = b.rect
        var bc: Vector2 = rect.get_center()
        if bc.distance_to(center)>radius:
            continue
        var h: float = maxf(4.0,float(b.height)*0.075)
        var local := _photo_local(bc,center,h*0.5)
        var size := Vector3(rect.size.x*0.10,h,rect.size.y*0.10)
        var body := _photo_box("Building_%d" % bi,local,size,Color(b.wall))
        var roof := _photo_box("Roof_%d" % bi,local+Vector3(0,h*0.52,0),Vector3(size.x*0.94,0.35,size.z*0.94),Color(b.roof))
        photo_occluders.append({"center":local,"size":size})
        var detail_limit: int = 26 if graphics_quality>=2 else 14
        if built < detail_limit:
            _photo_add_building_details(b,local,size,h,bi)
        if built<20:
            PhotoArt.add_roof(self,local,size,h,b)
        built+=1
        if built>55:
            break

    # Landmark volumes get stronger silhouettes.
    for li in range(landmarks.size()):
        var l: Dictionary = landmarks[li]
        var lp: Vector2 = Vector2(l.pos)
        if lp.distance_to(center)>radius*1.25:
            continue
        var lh:=maxf(8.0,float(l.h)*0.085)
        var lsz:=Vector2(l.size)*0.10
        var lcenter:=_photo_local(lp,center,lh*0.5)
        photo_occluders.append({"center":lcenter,"size":Vector3(maxf(8.0,lsz.x*0.78),lh,maxf(8.0,lsz.y*0.78))})
        _photo_make_landmark(l,center)

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

    PhotoArt.add_streets(self,center,radius)

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
        var car_node := _photo_make_car("Traffic_%d" % ti,wp,Vector2(tf.tangent).angle(),str(trf["class"]),Color(trf.color),center,null,str(trf.get("archetype","")))
        photo_dynamic_cars[ti]=car_node
        traffic_count+=1
        if traffic_count>30:
            break

    # Buses and trams keep moving through the 3D photo scene.
    for vi in range(transit_vehicles.size()):
        var tv: Dictionary = transit_vehicles[vi]
        var rd = roads[int(tv.road)]
        var vp: Vector2 = _sample_polyline(rd.points,float(tv.t))
        if vp.distance_to(center)>radius*1.15:
            continue
        var tan := _polyline_tangent(rd.points,float(tv.t))
        if bool(tv.reverse):
            tan*=-1.0
        var transit_root := Node3D.new()
        transit_root.name="Transit_%d" % vi
        photo_world_root.add_child(transit_root)
        var long_size := Vector3(9.0,2.8,2.7) if str(tv.kind)=="bus" else Vector3(12.0,2.9,2.65)
        _photo_box("TransitBody",Vector3(0,1.55,0),long_size,Color(tv.color),transit_root)
        _photo_box("TransitGlass",Vector3(-0.4,2.65,0),Vector3(long_size.x*0.70,0.70,long_size.z*0.78),Color("#79b5cc"),transit_root)
        transit_root.position=_photo_local(vp,center,0.0)
        transit_root.rotation.y=-tan.angle()
        photo_dynamic_transit[vi]=transit_root

    # Moving pedestrians are mirrored as simple 3D characters.
    var ped_count: int = 0
    for pi in range(pedestrians.size()):
        var ped: Dictionary = pedestrians[pi]
        var rd = roads[int(ped.road)]
        var pp: Vector2 = _sample_polyline(rd.points,float(ped.t))
        var tan := _polyline_tangent(rd.points,float(ped.t))
        if bool(ped.reverse):
            tan*=-1.0
        var normal := Vector2(-tan.y,tan.x)
        pp += normal*(float(rd.width)*0.5+18.0)*float(ped.side)
        if pp.distance_to(center)>radius:
            continue
        var ped_root := Node3D.new()
        ped_root.name="Ped_%d" % pi
        photo_world_root.add_child(ped_root)
        PhotoArt.person(self,ped_root,ped)
        ped_root.position=_photo_local(pp,center,0.0)
        ped_root.rotation.y=-tan.angle()+PI*0.5
        photo_dynamic_peds[pi]=ped_root
        ped_count+=1
        if ped_count>22:
            break

    _photo_spawn_targets(index,center)

func _photo_add_building_details(b: Dictionary, local: Vector3, size: Vector3, h: float, index: int) -> void:
    if graphics_quality>0:
        var region:=CityArt.facade_region(str(b.style),int(b.seed))
        var material_key:=str(region)
        if not photo_facade_materials.has(material_key):
            var texture_image: Image=CityArt.FACADES.get_image()
            var tile:=texture_image.get_region(Rect2i(Vector2i(region*Vector2(texture_image.get_size())),Vector2i(texture_image.get_size()/2)))
            var mat:=StandardMaterial3D.new()
            mat.albedo_texture=ImageTexture.create_from_image(tile)
            mat.roughness=0.88
            mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
            photo_facade_materials[material_key]=mat
        for side in range(4):
            var face:=MeshInstance3D.new()
            var mesh:=QuadMesh.new()
            mesh.size=Vector2(size.x if side%2==0 else size.z,h)
            face.mesh=mesh
            face.rotation.y=float(side)*PI*0.5
            face.position=local+Vector3(sin(face.rotation.y)*(size.x*0.5+0.025),0,cos(face.rotation.y)*(size.z*0.5+0.025))
            face.material_override=photo_facade_materials[material_key]
            photo_world_root.add_child(face)
        _photo_box("RoofCornice_%d" % index,local+Vector3(0,h*0.49,0),Vector3(size.x+0.3,0.3,size.z+0.3),Color("#a1a496"))
        _photo_box("RoofUnit_%d" % index,local+Vector3(size.x*0.18,h*0.58,size.z*0.16),Vector3(2.5,1.4,1.8),Color("#7b858c"))
        return
    var rows: int = clampi(int(h/3.2),2,5)
    var cols_x: int = clampi(int(size.x/5.2),2,5)
    var cols_z: int = clampi(int(size.z/5.2),2,5)
    var daylight := clampf(sin((world_clock-6.0)/24.0*TAU)*0.5+0.5,0.0,1.0)
    var night_factor := 1.0-daylight
    var seed_value: int = int(b.get("seed",index))
    for row in range(rows):
        var fy := (float(row)+0.75)/float(rows+0.5)
        var y := local.y-h*0.42+fy*h*0.76
        for col in range(cols_x):
            if (seed_value+row*7+col*13)%5==0:
                continue
            var fx := (float(col)+0.5)/float(cols_x)-0.5
            var x := local.x+fx*size.x*0.78
            var warm: bool = (seed_value+row*11+col*17)%4==0
            var pane := Color("#83c7da")
            pane.a=0.50
            if warm:
                pane=Color(1.0,0.76,0.38,0.30+night_factor*0.58)
            _photo_box("WinF_%d_%d_%d" % [index,row,col],Vector3(x,y,local.z-size.z*0.505),Vector3(maxf(0.65,size.x/float(cols_x)*0.46),0.72,0.12),pane)
            _photo_box("WinB_%d_%d_%d" % [index,row,col],Vector3(x,y,local.z+size.z*0.505),Vector3(maxf(0.65,size.x/float(cols_x)*0.46),0.72,0.12),pane)
        if row<4:
            for col in range(cols_z):
                if (seed_value+row*5+col*19)%6==0:
                    continue
                var fz := (float(col)+0.5)/float(cols_z)-0.5
                var z := local.z+fz*size.z*0.76
                var pane_side := Color("#75b9ce")
                pane_side.a=0.42+night_factor*0.12
                _photo_box("WinL_%d_%d_%d" % [index,row,col],Vector3(local.x-size.x*0.505,y,z),Vector3(0.12,0.70,maxf(0.62,size.z/float(cols_z)*0.42)),pane_side)
                _photo_box("WinR_%d_%d_%d" % [index,row,col],Vector3(local.x+size.x*0.505,y,z),Vector3(0.12,0.70,maxf(0.62,size.z/float(cols_z)*0.42)),pane_side)
    var facade: String = str(b.get("facade","windows"))
    if facade in ["living","balconies"]:
        _photo_box("FacadeGreen_%d" % index,Vector3(local.x,local.y-h*0.16,local.z-size.z*0.54),Vector3(size.x*0.62,0.34,0.48),Color("#4d8c5e"))
    elif facade=="ribs":
        for rib in range(-2,3):
            _photo_box("FacadeRib_%d_%d" % [index,rib],Vector3(local.x+float(rib)*size.x*0.16,local.y,local.z-size.z*0.54),Vector3(0.22,h*0.86,0.32),Color(b.accent))
    if str(b.get("roof_mode","flat"))=="antenna":
        _photo_box("RoofMast_%d" % index,Vector3(local.x,local.y+h*0.62,local.z),Vector3(0.28,h*0.24,0.28),Color("#c3d0d5"))

func _photo_make_landmark(l: Dictionary, center: Vector2) -> void:
    var lp: Vector2 = Vector2(l.pos)
    var kind: String = str(l.kind)
    var h: float = maxf(8.0,float(l.h)*0.085)
    var sz: Vector2 = Vector2(l.size)*0.10
    var base := _photo_local(lp,center,0.0)
    var accent: Color = Color(l.accent)

    if kind=="hospital":
        _photo_box("HospitalMain",base+Vector3(0,h*0.46,0),Vector3(sz.x*0.92,h*0.92,sz.y*0.82),Color("#d5e2e3"))
        _photo_box("HospitalER",base+Vector3(0,h*0.16,-sz.y*0.49),Vector3(sz.x*0.48,h*0.24,sz.y*0.18),Color("#31535a"))
        _photo_box("HospitalCrossV",base+Vector3(0,h*0.92,-sz.y*0.43),Vector3(1.4,h*0.18,0.8),Color("#3abf9f"))
        _photo_box("HospitalCrossH",base+Vector3(0,h*0.92,-sz.y*0.43),Vector3(sz.x*0.13,1.4,0.8),Color("#3abf9f"))
        for y in range(2,7):
            for x in range(-3,4):
                _photo_box("HospitalWindow",base+Vector3(float(x)*sz.x*0.11,h*float(y)/8.0,-sz.y*0.415),Vector3(sz.x*0.065,0.20,0.12),Color("#78b4c0"))
    elif kind=="openai_hq":
        var left := _photo_box("OpenAI_Left",base+Vector3(-sz.x*0.23,h*0.50,0),Vector3(sz.x*0.42,h,sz.y*0.78),Color("#35505c"))
        var right := _photo_box("OpenAI_Right",base+Vector3(sz.x*0.23,h*0.50,0),Vector3(sz.x*0.42,h,sz.y*0.78),Color("#3b5965"))
        _photo_box("OpenAI_Skybridge",base+Vector3(0,h*0.58,0),Vector3(sz.x*0.28,2.7,sz.y*0.30),Color("#9acbd7"))
        _photo_box("OpenAI_Plaza",base+Vector3(0,0.35,sz.y*0.50),Vector3(sz.x*0.85,0.55,sz.y*0.28),Color("#d7e2e5"))
        for x in [-0.23,0.23]:
            for y in range(2,8):
                _photo_box("OpenAI_Glass",base+Vector3(sz.x*x,h*float(y)/9.0,sz.y*0.401),Vector3(sz.x*0.31,0.22,0.14),Color(0.55,0.82,0.90,0.78))
    elif kind=="clock":
        _photo_box("ClockTower",base+Vector3(0,h*0.50,0),Vector3(sz.x*0.36,h,sz.y*0.38),Color("#725747"))
        var clock := CylinderMesh.new()
        clock.top_radius=2.8
        clock.bottom_radius=2.8
        clock.height=0.30
        var cn := MeshInstance3D.new()
        cn.mesh=clock
        cn.rotation_degrees=Vector3(90,0,0)
        cn.position=base+Vector3(0,h*0.76,-sz.y*0.20)
        cn.material_override=_photo_material(Color("#f4ead0"))
        photo_world_root.add_child(cn)
        _photo_box("ClockSpire",base+Vector3(0,h+4.5,0),Vector3(0.65,9.0,0.65),accent)
    elif kind in ["greenhouse","conservatory"]:
        _photo_box("Glasshouse",base+Vector3(0,4.0,0),Vector3(sz.x,8.0,sz.y),Color(0.40,0.70,0.58,0.38))
        for x in range(-3,4):
            _photo_box("GlassRib",base+Vector3(float(x)*sz.x/7.0,8.8,0),Vector3(0.24,9.5,sz.y*1.02),Color("#b9e4d7"))
    elif kind=="solar_beacon":
        _photo_box("SolarMast",base+Vector3(0,h*0.50,0),Vector3(1.4,h,1.4),Color("#606970"))
        for y in range(1,5):
            _photo_box("SolarWing",base+Vector3(0,h*float(y)/5.0,0),Vector3(sz.x*0.62,0.45,3.2),accent)
    elif kind=="observatory":
        var dome := SphereMesh.new()
        dome.radius=maxf(6.0,sz.x*0.22)
        dome.height=dome.radius*1.45
        var dn := MeshInstance3D.new()
        dn.mesh=dome
        dn.position=base+Vector3(0,h*0.55,0)
        dn.material_override=_photo_material(Color("#544e7a"))
        photo_world_root.add_child(dn)
        _photo_box("ObservatoryBase",base+Vector3(0,h*0.20,0),Vector3(sz.x*0.55,h*0.40,sz.y*0.55),Color("#38344f"))
        _photo_box("Scope",base+Vector3(4,h*0.80,-2),Vector3(3.0,3.0,15.0),accent)
    elif kind=="crystal":
        var root := Node3D.new()
        root.position=base
        photo_world_root.add_child(root)
        for i in range(5):
            var shard := _photo_box("CrystalShard",Vector3(float(i-2)*4.0,7.0+float(i%2)*3.0,float((i*5)%7)-3.0),Vector3(5.0,15.0+float(i)*2.5,5.0),Color(accent.r,accent.g,accent.b,0.70),root)
            shard.rotation_degrees=Vector3(float(i)*3.0,float(i)*19.0,float(i-2)*5.0)
    elif kind=="theatre":
        _photo_box("TheatreBody",base+Vector3(0,h*0.42,0),Vector3(sz.x,h*0.84,sz.y),Color("#342244"))
        _photo_box("TheatreMarquee",base+Vector3(0,h*0.40,-sz.y*0.56),Vector3(sz.x*0.78,3.2,sz.y*0.18),accent)
        for x in range(-3,4):
            _photo_box("NeonStrip",base+Vector3(float(x)*sz.x/8.0,h*0.55,-sz.y*0.575),Vector3(0.35,h*0.48,0.20),accent)
    elif kind=="crane":
        _photo_box("CraneHall",base+Vector3(0,5.0,0),Vector3(sz.x,10.0,sz.y),Color("#4b4039"))
        _photo_box("CraneMast",base+Vector3(-sz.x*0.30,h*0.52,0),Vector3(1.8,h,1.8),Color("#806d60"))
        _photo_box("CraneArm",base+Vector3(sz.x*0.05,h,0),Vector3(sz.x*0.72,1.8,1.8),accent)
    elif kind=="rotunda":
        var rotunda := CylinderMesh.new()
        rotunda.top_radius=maxf(5.0,sz.x*0.30)
        rotunda.bottom_radius=maxf(6.0,sz.x*0.36)
        rotunda.height=h*0.58
        var rn:=MeshInstance3D.new()
        rn.mesh=rotunda
        rn.position=base+Vector3(0,h*0.29,0)
        rn.material_override=_photo_material(Color("#315a63"))
        photo_world_root.add_child(rn)
        for k in range(10):
            var a:=float(k)*TAU/10.0
            _photo_box("RotundaFin",base+Vector3(cos(a)*sz.x*0.38,h*0.34,sin(a)*sz.y*0.38),Vector3(0.32,h*0.48,1.8),accent)
        _photo_box("RotundaLantern",base+Vector3(0,h*0.72,0),Vector3(sz.x*0.18,h*0.24,sz.y*0.18),Color("#8edbd8"))
    elif kind=="civic":
        _photo_box("CivicCore",base+Vector3(0,h*0.48,0),Vector3(sz.x*0.58,h*0.96,sz.y*0.58),Color("#314b5b"))
        for k in range(4):
            var fin:=_photo_box("CivicBlade",base+Vector3(float(k-1)*sz.x*0.16,h*(0.42+float(k%2)*0.08),0),Vector3(sz.x*0.11,h*(0.70+float(k%2)*0.18),sz.y*0.74),accent)
            fin.rotation_degrees.y=float(k-1)*8.0
        _photo_box("CivicPortal",base+Vector3(0,h*0.22,-sz.y*0.42),Vector3(sz.x*0.30,h*0.28,1.4),Color("#b8e2ef"))
    elif kind=="library":
        _photo_box("LibraryPlinth",base+Vector3(0,2.2,0),Vector3(sz.x*1.05,4.4,sz.y*0.95),Color("#39445b"))
        for k in range(5):
            var wing:=_photo_box("LibraryWing",base+Vector3(float(k-2)*sz.x*0.16,h*(0.38+float(abs(k-2))*0.045),0),Vector3(sz.x*0.15,h*(0.66-float(abs(k-2))*0.06),sz.y*0.78),Color("#52698c"))
            wing.rotation_degrees.y=float(k-2)*4.0
        _photo_box("LibraryAxis",base+Vector3(0,h*0.72,-sz.y*0.20),Vector3(sz.x*0.56,2.0,sz.y*0.20),accent)
    elif kind=="terminal":
        _photo_box("TerminalBase",base+Vector3(0,h*0.25,0),Vector3(sz.x,h*0.50,sz.y),Color("#414a51"))
        _photo_box("TerminalCrown",base+Vector3(0,h*0.67,0),Vector3(sz.x*0.64,h*0.34,sz.y*0.64),Color("#65717a"))
        for k in range(6):
            var a:=float(k)*TAU/6.0
            _photo_box("TerminalSpoke",base+Vector3(cos(a)*sz.x*0.30,h*0.88,sin(a)*sz.y*0.30),Vector3(1.2,h*0.22,1.2),accent)
        _photo_box("TerminalBeacon",base+Vector3(0,h*1.08,0),Vector3(1.5,h*0.25,1.5),Color("#d9e5ef"))
    else:
        _photo_box("Landmark_%s" % str(l.name),base+Vector3(0,h*0.5,0),Vector3(maxf(8.0,sz.x),h,maxf(8.0,sz.y)),Color(l.accent).darkened(0.42))
        _photo_box("LandmarkCap_%s" % str(l.name),base+Vector3(0,h*1.03,0),Vector3(maxf(6.0,sz.x*0.72),1.0,maxf(6.0,sz.y*0.72)),accent)

func _photo_make_car(name_text: String, world_pos: Vector2, heading: float, cls: String, color: Color, center: Vector2, parent: Node3D = null, archetype: String = "") -> Node3D:
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
    for axle in [-0.30,0.30]:
        for side_sign in [-1.0,1.0]:
            _photo_box(name_text+"_Wheel",Vector3(sz.x*float(axle),0.62,sz.y*0.54*float(side_sign)),Vector3(0.78,0.54,0.30),Color("#11171a"),root)
    for side_sign in [-1.0,1.0]:
        _photo_box(name_text+"_Head",Vector3(sz.x*0.50,1.18,sz.y*0.28*float(side_sign)),Vector3(0.14,0.28,0.38),Color("#ffe8a8"),root)
        _photo_box(name_text+"_Tail",Vector3(-sz.x*0.50,1.16,sz.y*0.28*float(side_sign)),Vector3(0.14,0.26,0.34),Color("#ff5f65"),root)
    if cls in ["sport","hyper"]:
        _photo_box(name_text+"_Spoiler",Vector3(-sz.x*0.40,1.82,0),Vector3(0.22,0.18,sz.y*0.82),Color("#1b2428"),root)
    elif cls=="pickup":
        _photo_box(name_text+"_Bed",Vector3(-sz.x*0.28,1.35,0),Vector3(sz.x*0.34,0.35,sz.y*0.82),color.darkened(0.18),root)
    if archetype=="ambulance":
        _photo_box(name_text+"_AmbStripe",Vector3(0,1.35,sz.y*0.51),Vector3(sz.x*0.74,0.24,0.12),Color("#48bfa9"),root)
        _photo_box(name_text+"_AmbLightbar",Vector3(0,2.78,0),Vector3(1.9,0.18,0.42),Color("#5b6870"),root)
        _photo_box(name_text+"_AmbRed",Vector3(-0.50,2.90,0),Vector3(0.58,0.16,0.34),Color("#ff4057"),root)
        _photo_box(name_text+"_AmbBlue",Vector3(0.50,2.90,0),Vector3(0.58,0.16,0.34),Color("#55aaff"),root)
    elif archetype=="response":
        _photo_box(name_text+"_Lightbar",Vector3(0,2.72,0),Vector3(1.8,0.18,0.42),Color("#6f7b80"),root)
        _photo_box(name_text+"_Red",Vector3(-0.48,2.84,0),Vector3(0.55,0.16,0.34),Color("#ff4057"),root)
        _photo_box(name_text+"_Blue",Vector3(0.48,2.84,0),Vector3(0.55,0.16,0.34),Color("#55aaff"),root)
    elif archetype in ["service","maintenance"]:
        _photo_box(name_text+"_RackL",Vector3(-0.6,2.70,-sz.y*0.28),Vector3(2.8,0.16,0.16),Color("#252e32"),root)
        _photo_box(name_text+"_RackR",Vector3(-0.6,2.70,sz.y*0.28),Vector3(2.8,0.16,0.16),Color("#252e32"),root)
        if archetype=="maintenance":
            _photo_box(name_text+"_Amber",Vector3(0,2.92,0),Vector3(0.40,0.28,0.40),Color("#ffb12d"),root)
    elif archetype=="taxi":
        _photo_box(name_text+"_Taxi",Vector3(0,2.74,0),Vector3(1.15,0.26,0.48),Color("#f2cf4f"),root)
    elif archetype=="courier":
        _photo_box(name_text+"_CourierStripe",Vector3(0,1.28,sz.y*0.51),Vector3(sz.x*0.68,0.20,0.12),Color("#72d7e6"),root)
    root.position=_photo_local(world_pos,center,0.0)
    root.rotation.y=-heading
    return root

func _photo_position_occluded(target_pos: Vector3) -> bool:
    var cam:=photo_camera.position if photo_camera!=null else Vector3(0,7.0,0)
    var direction:=target_pos-cam
    if direction.length_squared()<0.001:
        return false
    for occ in photo_occluders:
        var center:=Vector3(occ.center)
        var size:=Vector3(occ.size)
        var first:=0.02
        var last:=0.98
        var intersects:=true
        for axis in range(3):
            var low: float=center[axis]-size[axis]*0.5
            var high: float=center[axis]+size[axis]*0.5
            if absf(direction[axis])<0.0001:
                if cam[axis]<low or cam[axis]>high:
                    intersects=false
                    break
            else:
                var near_t: float=(low-cam[axis])/direction[axis]
                var far_t: float=(high-cam[axis])/direction[axis]
                first=maxf(first,minf(near_t,far_t))
                last=minf(last,maxf(near_t,far_t))
                if first>last:
                    intersects=false
                    break
        if intersects:
            return true
    return false

func _photo_find_visible_target_position(base: Vector3, variant: int) -> Vector3:
    var base_xz:=Vector2(base.x,base.z)
    for radius_scale in [1.0,0.75,1.25,0.45]:
        for attempt in range(24):
            var angle:=float(attempt)*TAU/24.0
            var rotated: Vector2=base_xz.rotated(angle)*radius_scale
            var candidate:=Vector3(rotated.x,base.y,rotated.y)
            if not _photo_position_occluded(candidate):
                return candidate
    # The reserved observation plaza also provides a visible last-resort anchor.
    var safe:=Vector2.from_angle(float(variant)*TAU/3.0-PI*0.5)*6.0
    return Vector3(safe.x,base.y,safe.y)

func _photo_anchor_subject(base: Vector3, kind: String) -> Dictionary:
    if kind=="rarecar":
        var spot_center:=Vector2(photo_points[active_photo_index].pos)
        var best_road:=INF
        var road_result: Dictionary={}
        for road in roads:
            var points: PackedVector2Array=road.points
            for i in range(points.size()-1):
                var a:=Vector2(_photo_local(points[i],spot_center).x,_photo_local(points[i],spot_center).z)
                var b:=Vector2(_photo_local(points[i+1],spot_center).x,_photo_local(points[i+1],spot_center).z)
                var delta:=b-a
                var near:=a+delta*clampf((Vector2(base.x,base.z)-a).dot(delta)/maxf(0.1,delta.length_squared()),0,1)
                var pos:=Vector3(near.x,1.25,near.y)
                var distance:=base.distance_squared_to(pos)
                if pos.length()<85 and distance<best_road and not _photo_position_occluded(pos):
                    best_road=distance
                    road_result={"pos":pos,"rotation":-delta.angle()}
        return road_result
    if kind not in ["window","neoncode","cat","antenna","bird"]:
        return {}
    var result: Dictionary={}
    var best:=INF
    for occluder in photo_occluders:
        var center: Vector3=occluder.center
        var half: Vector3=Vector3(occluder.size)*0.5
        if center.length()>90 or half.x<3 or half.z<3:
            continue
        var roof: float=center.y+half.y
        var positions: Array[Vector3]=[]
        var rotations: Array[float]=[]
        if kind in ["cat","antenna","bird"]:
            var towards: Vector3=(photo_camera.position-center).normalized()
            positions.append(Vector3(center.x+towards.x*half.x*0.80,roof+0.85,center.z+towards.z*half.z*0.80))
            rotations.append(0)
        else:
            for side in range(4):
                var angle:=float(side)*PI*0.5
                var normal:=Vector3(sin(angle),0,cos(angle))
                var extent:=half.x if side%2==1 else half.z
                var point:=center+normal*(extent+0.45)
                point.y=clampf(base.y,2.0,maxf(2.0,roof-1.6))
                positions.append(point)
                rotations.append(angle)
        for i in range(positions.size()):
            var pos:=positions[i]
            var distance:=base.distance_squared_to(pos)
            if distance<best and not _photo_position_occluded(pos):
                best=distance
                result={"pos":pos,"rotation":rotations[i]}
    return result

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
        p=_photo_find_visible_target_position(p,i)
        var anchor:=_photo_anchor_subject(p,str(t.kind))
        if not anchor.is_empty():
            p=anchor.pos
        t["pos"]=p
        t["key"]="%s_%d" % [id,i]
        var root := Node3D.new()
        root.name="PhotoTarget_%d" % i
        root.position=p
        root.rotation.y=float(anchor.get("rotation",0))
        photo_world_root.add_child(root)
        _photo_build_target_visual(root,str(t.kind),i)
        root.visible=not bool(photo_found.get(str(t.key),false))
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
        var car:=_photo_make_car("RareSubject",Vector2.ZERO,0,"hyper",Color("#ff4f65"),Vector2.ZERO,root)
        car.position.y=-1.25
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
    if index<0 or index>=photo_points.size():
        return
    active_photo_index=index
    photo_session+=1
    photo_feedback=""
    photo_feedback_until=0
    if bool(photo_points[index].taken):
        var replay_id: String = str(photo_points[index].id)
        for i in range(3):
            photo_found["%s_%d" % [replay_id,i]]=false
    photo_mode=true
    photo_viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    var initial_dir: Vector2 = Vector2(photo_points[index].dir).normalized()
    photo_yaw=atan2(-initial_dir.x,-initial_dir.y)
    photo_pitch=-0.045
    photo_fov=66.0
    photo_drag_touch=-1
    move_vec=Vector2.ZERO
    vehicle_velocity=0.0
    if current_vehicle>=0:
        parked_cars[current_vehicle]["occupied"]=true
    _photo_update_camera()
    _photo_apply_lighting()
    _photo_build_scene(index)
    _photo_show_ui(true)
    photo_view_rect.visible=true
    _photo_update_camera()
    _photo_refresh_labels()
    var already_complete := true
    for t in photo_targets:
        if not bool(photo_found.get(str(t.key),false)):
            already_complete=false
            break
    if already_complete:
        _complete_photo_challenge()
        return
    _play_sfx("mission")
    _show_reward_popup("PHOTO CHALLENGE",str(photo_points[index].label)+"\nFinde und fotografiere alle versteckten Motive.",Color("#ffb3e6"))

func _exit_photo_mode() -> void:
    photo_session+=1
    photo_mode=false
    photo_viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED
    active_photo_index=-1
    photo_drag_touch=-1
    photo_view_rect.visible=false
    _photo_show_ui(false)
    _photo_clear_3d_scene()
    reward_panel.visible=false
    queue_redraw()

func _photo_show_ui(show: bool) -> void:
    photo_target_label.visible=show
    if photo_crosshair!=null:
        photo_crosshair.visible=show
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
    var head: Vector2=camera_head_view if camera_tracking_enabled and Time.get_ticks_msec()-camera_head_last_ms<700 else sensor_view
    photo_camera.position=Vector3(head.x*0.85,3.1-head.y*0.55,-camera_head_depth*0.45)
    photo_camera.rotation=Vector3(clampf(photo_pitch+head.y*0.14,-1.30,0.65),photo_yaw-head.x*0.16,0)
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
        if _photo_position_occluded(node.global_position):
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
    if photo_flash_rect!=null:
        photo_flash_rect.modulate=Color(1,1,1,0.88)
        var flash_tw := create_tween()
        flash_tw.tween_property(photo_flash_rect,"modulate:a",0.0,0.16)
    _play_sfx("photo")
    var target := _photo_center_target()
    if target.is_empty():
        _photo_set_feedback("Noch kein Motiv im Sucher · drehe die Kamera oder nutze HINWEIS.")
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
    _save_game()
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
    photo_target_label.text="%s\nMotive %d / %d · Score %d/300 · %s" % [str(photo_points[active_photo_index].label),found_count,photo_targets.size(),score_sum,_weather_label()]
    photo_status_label.text=photo_feedback if Time.get_ticks_msec()<photo_feedback_until else (("Noch suchen: "+", ".join(remaining)) if not remaining.is_empty() else "Alle Motive gefunden.")
    if photo_crosshair!=null:
        photo_crosshair.modulate=Color("#73f3ce") if not _photo_center_target().is_empty() else Color(1,1,1,0.82)

func _photo_hint() -> void:
    if not photo_mode:
        return
    for t in photo_targets:
        if not bool(photo_found.get(str(t.key),false)):
            var node: Node3D=t.node
            var delta:=node.global_position-photo_camera.global_position
            var angle:=wrapf(atan2(-delta.x,-delta.z)-photo_camera.rotation.y,-PI,PI)
            var turn: String="Drehe nach links" if angle>0.12 else ("Drehe nach rechts" if angle< -0.12 else "In deiner Blickrichtung")
            var height: String=" · höher schauen" if delta.y>3 else (" · tiefer schauen" if delta.y< -3 else "")
            _photo_set_feedback("%s%s · %s\n%s" % [turn,height,str(t.label),str(t.hint)],6500)
            return

func _photo_set_feedback(message: String, duration: int = 4000) -> void:
    photo_feedback=message
    photo_feedback_until=Time.get_ticks_msec()+duration
    photo_status_label.text=message

func _complete_photo_challenge() -> void:
    if active_photo_index<0:
        return
    var ph: Dictionary = photo_points[active_photo_index]
    var session:=photo_session
    var quality: int = 0
    for t in photo_targets:
        quality+=int(photo_scores.get(str(t.key),0))
    if not bool(ph.taken):
        photo_points[active_photo_index]["taken"]=true
        photo_count+=1
        var quality_bonus: int = 25 if quality>=270 else (12 if quality>=225 else 0)
        credits+=int(ph.reward)+quality_bonus
        _save_game()
        _advance_native_chapter()
        _check_milestones()
        _show_reward_popup("PHOTO SPOT ABGESCHLOSSEN","%s\n3 Motive · +%d CR%s" % [str(ph.label),int(ph.reward),(" · Qualitätsbonus" if quality_bonus>0 else "")],Color("#ffb3e6"))
    else:
        _save_game()
        _show_reward_popup("PHOTO REPLAY","%s\nNeuer Spot-Score: %d/300" % [str(ph.label),quality],Color("#ffb3e6"))
    await get_tree().create_timer(0.85).timeout
    if photo_mode and photo_session==session:
        _exit_photo_mode()

func _update_photo_3d_scene(_delta: float) -> void:
    _photo_update_camera()
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
        node.rotation.y=-Vector2(tf.tangent).angle()

    for key in photo_dynamic_transit.keys():
        var vi: int = int(key)
        if vi<0 or vi>=transit_vehicles.size():
            continue
        var vnode: Node3D = photo_dynamic_transit[key]
        if not is_instance_valid(vnode):
            continue
        var tv: Dictionary = transit_vehicles[vi]
        var rd = roads[int(tv.road)]
        var vp: Vector2 = _sample_polyline(rd.points,float(tv.t))
        var vtan := _polyline_tangent(rd.points,float(tv.t))
        if bool(tv.reverse):
            vtan*=-1.0
        vnode.position=_photo_local(vp,center,0.0)
        vnode.rotation.y=-vtan.angle()

    for key in photo_dynamic_peds.keys():
        var pi: int = int(key)
        if pi<0 or pi>=pedestrians.size():
            continue
        var pnode: Node3D = photo_dynamic_peds[key]
        if not is_instance_valid(pnode):
            continue
        var ped: Dictionary = pedestrians[pi]
        var rd = roads[int(ped.road)]
        var pp: Vector2 = _sample_polyline(rd.points,float(ped.t))
        var tan := _polyline_tangent(rd.points,float(ped.t))
        if bool(ped.reverse):
            tan*=-1.0
        var normal := Vector2(-tan.y,tan.x)
        pp += normal*(float(rd.width)*0.5+18.0)*float(ped.side)
        pnode.position=_photo_local(pp,center,0.0)
        pnode.rotation.y=-tan.angle()+PI*0.5
        pnode.position.y=abs(sin(float(ped.phase)))*0.12

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

    ambient_player = AudioStreamPlayer.new()
    ambient_player.volume_db = -30.0
    add_child(ambient_player)

    weather_player = AudioStreamPlayer.new()
    weather_player.volume_db = -36.0
    add_child(weather_player)

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
    sounds["traffic_crash"] = _make_chime([118.0,82.0,64.0],[0.045,0.065,0.085],0.10)
    sounds["city_event"] = _make_chime([392.0,523.0,659.0],[0.04,0.05,0.09],0.08)
    sounds["event_music"] = _make_chime([330.0,440.0,494.0,659.0],[0.08,0.08,0.08,0.14],0.055)
    sounds["event_work"] = _make_chime([125.0,190.0,145.0],[0.055,0.04,0.075],0.050)
    sounds["event_crowd"] = _make_chime([260.0,310.0,390.0],[0.045,0.055,0.075],0.038)

    ambient_sounds["urban"] = _make_ambient_loop(42.0,2.0,0.052)
    ambient_sounds["heritage"] = _make_ambient_loop(38.0,1.0,0.045)
    ambient_sounds["green"] = _make_ambient_loop(34.0,3.0,0.040)
    ambient_sounds["water"] = _make_ambient_loop(30.0,4.0,0.050)
    ambient_sounds["industrial"] = _make_ambient_loop(46.0,5.0,0.052)
    ambient_sounds["neon"] = _make_ambient_loop(54.0,7.0,0.045)
    ambient_sounds["campus"] = _make_ambient_loop(40.0,6.0,0.040)
    ambient_sounds["open"] = _make_ambient_loop(28.0,4.0,0.038)
    ambient_sounds["rain"] = _make_ambient_loop(62.0,11.0,0.060)
    ambient_sounds["storm"] = _make_ambient_loop(26.0,13.0,0.070)

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

func _make_ambient_loop(base_freq: float, activity: float, amp: float) -> AudioStreamWAV:
    var rate := 16000
    var duration := 2.0
    var samples := int(rate*duration)
    var data := PackedByteArray()
    data.resize(samples*2)
    for i in range(samples):
        var t := float(i)/float(rate)
        var sample := (
            sin(TAU*base_freq*t)*0.34
            + sin(TAU*(base_freq+24.0)*t)*0.13
            + sin(TAU*(4.0+activity)*t)*0.09
            + sin(TAU*(91.0+activity*11.0)*t)*0.035
            + sin(TAU*(143.0+activity*7.0)*t)*0.022
        )*amp
        var iv := int(clampf(sample,-1.0,1.0)*32767.0)
        if iv<0:
            iv+=65536
        data[i*2]=iv&255
        data[i*2+1]=(iv>>8)&255
    var wav := AudioStreamWAV.new()
    wav.format=AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate=rate
    wav.stereo=false
    wav.loop_mode=AudioStreamWAV.LOOP_FORWARD
    wav.loop_begin=0
    wav.loop_end=samples
    wav.data=data
    return wav

func _ambient_profile_for_style(style: String) -> String:
    if style=="heritage":
        return "heritage"
    if style in ["green","garden","wind"]:
        return "green"
    if style in ["canal","harbor","coast"]:
        return "water"
    if style in ["industry","rail","terminal","data","solar"]:
        return "industrial"
    if style in ["neon","astro","glass"]:
        return "neon"
    if style in ["campus","culture","expo","center"]:
        return "campus"
    if style in ["air","ring"]:
        return "open"
    return "urban"

func _update_ambient_audio(_delta: float) -> void:
    if ambient_player==null or weather_player==null:
        return
    if not sound_enabled or main_menu_active:
        if ambient_player.playing:
            ambient_player.stop()
        if weather_player.playing:
            weather_player.stop()
        current_ambient_key=""
        current_weather_audio_key=""
        return

    var district := _district_at(player_pos)
    var profile := _ambient_profile_for_style(str(district.get("style","center")))
    if profile!=current_ambient_key:
        current_ambient_key=profile
        ambient_player.stop()
        ambient_player.stream=ambient_sounds.get(profile,ambient_sounds.get("urban"))
        ambient_player.play()
    elif not ambient_player.playing:
        ambient_player.play()

    var night := world_clock>=19.0 or world_clock<6.0
    var base_db := -29.0
    if night:
        base_db=-27.0
    if interior_active:
        base_db=-36.0
    elif photo_mode:
        base_db=-31.0
    elif current_vehicle>=0:
        base_db=-25.5
    ambient_player.volume_db=base_db
    ambient_player.pitch_scale=1.0
    if current_vehicle>=0:
        var cls := str(parked_cars[current_vehicle].get("class","sedan"))
        var max_speed := maxf(1.0,float(VEHICLE_SPEEDS.get(cls,420.0)))
        ambient_player.pitch_scale=1.0+clampf(abs(vehicle_velocity)/max_speed,0.0,1.0)*0.035

    var state := _weather_state()
    var weather_key := ""
    if state=="rain":
        weather_key="rain"
    elif state=="storm":
        weather_key="storm"
    if weather_key=="":
        if weather_player.playing:
            weather_player.stop()
        current_weather_audio_key=""
    else:
        if weather_key!=current_weather_audio_key:
            current_weather_audio_key=weather_key
            weather_player.stop()
            weather_player.stream=ambient_sounds[weather_key]
            weather_player.play()
        elif not weather_player.playing:
            weather_player.play()
        weather_player.volume_db=-26.0 if state=="rain" else -21.5
        if interior_active:
            weather_player.volume_db-=9.0
        elif current_vehicle>=0:
            weather_player.volume_db-=4.0

func _update_event_proximity_audio() -> void:
    if not sound_enabled or main_menu_active or interior_active or photo_mode:
        proximity_event_id=""
        return
    var nearest_label:=""
    var nearest_kind:=""
    var nearest_dist:=999999.0
    for i in range(city_micro_events.size()):
        var event: Dictionary=city_micro_events[i]
        if not _micro_event_active(i,event):
            continue
        var d:=player_pos.distance_to(Vector2(event.pos))
        if d<nearest_dist:
            nearest_dist=d
            nearest_label=str(event.label)
            nearest_kind=str(event.type)
    if nearest_dist<285.0 and nearest_label!="" and nearest_label!=proximity_event_id:
        proximity_event_id=nearest_label
        if nearest_kind in ["busker","boardwalk_music","drone_show"]:
            _play_sfx("event_music")
        elif nearest_kind in ["maintenance","repair_crew"]:
            _play_sfx("event_work")
        else:
            _play_sfx("event_crowd")
    elif nearest_dist>420.0:
        proximity_event_id=""

func _play_sfx(name: String) -> void:
    if not sound_enabled:
        return
    if not sounds.has(name):
        return
    sfx_player.stop()
    sfx_player.stream = sounds[name]
    sfx_player.play()

func _bootstrap_android_camera() -> void:
    if OS.get_name()!="Android":
        camera_status="Touch / Maus"
        headtrack_sensor_mode="desktop"
        return
    _recenter_headtracking()
    if Engine.has_singleton("ParallaxHeadTracker"):
        camera_tracker=Engine.get_singleton("ParallaxHeadTracker")
        camera_tracker.connect("head_pose",_on_camera_head_pose)
        camera_tracker.connect("tracking_status",_on_tracking_status)
        if camera_tracking_enabled:
            camera_tracker.call("startTracking")
    elif camera_tracking_enabled:
        camera_tracking_state="nicht verfügbar"
    camera_status="Neigung · kalibriert"

func _recenter_headtracking() -> void:
    headtrack_integrated=Vector2.ZERO
    camera_head_calibrated=false
    camera_head_view=Vector2.ZERO
    camera_head_depth=0.0
    sensor_view=Vector2.ZERO
    headtrack_motion_strength=0.0
    if OS.get_name()!="Android":
        headtrack_calibrated=false
        return
    var g:=Input.get_gravity()
    if g.length()>1.0:
        headtrack_gravity_zero=g
        headtrack_calibrated=true
        headtrack_sensor_mode="gyro_gravity"
    else:
        headtrack_gravity_zero=Vector3.ZERO
        headtrack_calibrated=false
        headtrack_sensor_mode="waiting"

func _update_sensor(delta: float) -> void:
    if OS.get_name()!="Android":
        sensor_view=sensor_view.lerp(Vector2.ZERO,minf(1.0,delta*2.0))
        return
    if camera_tracking_enabled and Time.get_ticks_msec()-camera_head_last_ms>700:
        camera_head_view=camera_head_view.lerp(Vector2.ZERO,1.0-exp(-delta*3.0))
        camera_head_depth=lerpf(camera_head_depth,0.0,1.0-exp(-delta*3.0))
    var g:=Input.get_gravity()
    var gyro:=Input.get_gyroscope()
    var has_gravity:=g.length()>1.0
    var has_gyro:=gyro.length()>0.002

    if not headtrack_calibrated and has_gravity:
        headtrack_gravity_zero=g
        headtrack_calibrated=true
        headtrack_integrated=Vector2.ZERO

    if not has_gravity and not has_gyro:
        headtrack_sensor_mode="unavailable"
        camera_status="Headtracking · Sensoren nicht verfügbar"
        sensor_view=sensor_view.lerp(Vector2.ZERO,minf(1.0,delta*2.0))
        return

    var tilt:=Vector2.ZERO
    if has_gravity and headtrack_calibrated:
        tilt=Vector2(
            (g.x-headtrack_gravity_zero.x)/9.8,
            -(g.y-headtrack_gravity_zero.y)/9.8
        )*0.95

    if has_gyro:
        # Portrait device axes: Y maps horizontal yaw, X maps vertical pitch.
        var gyro_step:=Vector2(-gyro.y,gyro.x)*delta*0.58
        headtrack_integrated+=gyro_step
        headtrack_integrated=headtrack_integrated.limit_length(0.58)
        headtrack_motion_strength=lerpf(headtrack_motion_strength,clampf(gyro.length()/1.8,0.0,1.0),minf(1.0,delta*8.0))
    else:
        headtrack_motion_strength=lerpf(headtrack_motion_strength,0.0,minf(1.0,delta*4.0))

    # Gravity gives drift-free recentering while gyro gives immediate movement response.
    if has_gravity:
        headtrack_integrated=headtrack_integrated.lerp(tilt*0.72,minf(1.0,delta*0.62))

    var target: Vector2=(tilt*0.48+headtrack_integrated*0.92)*sensor_gain
    target=target.limit_length(0.72)
    sensor_view=sensor_view.lerp(target,minf(1.0,delta*(7.0 if has_gyro else 4.2)))
    headtrack_sensor_mode="gyro_gravity" if has_gyro else "gravity"
    camera_status="Headtracking · %s · %.0f%%" % [("GYRO+GRAVITY" if has_gyro else "GRAVITY"),headtrack_motion_strength*100.0]

func _traffic_world_speed(car: Dictionary) -> float:
    var road_index:=int(car.road)
    if road_index<0 or road_index>=roads.size():
        return 0.0
    var t:=float(car.t)
    var direction: float=-1.0 if bool(car.reverse) else 1.0
    var p1:=_sample_polyline(roads[road_index].points,t)
    var p2:=_sample_polyline(roads[road_index].points,clampf(t+0.001*direction,0.0,1.0))
    return p1.distance_to(p2)*abs(float(car.speed))/0.001

func _check_player_traffic_accident() -> void:
    if accident_cooldown>0.0 or hospital_transition>0.0:
        return
    if current_vehicle>=0 or transit_riding>=0 or interior_active or photo_mode:
        return
    for car in traffic:
        var tr:=_traffic_world_transform(car)
        if player_pos.distance_to(Vector2(tr.pos))>22.0:
            continue
        var speed_world: float=_traffic_world_speed(car)
        if speed_world<78.0:
            continue
        _trigger_player_accident(speed_world,str(car.get("archetype","")))
        return

func _trigger_player_accident(speed_world: float, archetype: String) -> void:
    hospital_transition=hospital_transition_total
    accident_cooldown=7.0
    accident_count+=1
    last_accident_speed=speed_world
    move_vec=Vector2.ZERO
    vehicle_velocity=0.0
    camera_shake_strength=9.0
    camera_shake_phase=0.0
    _play_sfx("impact")
    _haptic(140)
    _notify("Unfall · Rettungsdienst wurde alarmiert.")

func _update_hospital_transition(delta: float) -> void:
    hospital_transition=maxf(0.0,hospital_transition-delta)
    camera_shake_strength=move_toward(camera_shake_strength,0.0,delta*3.0)
    if hospital_transition<=0.0:
        _finish_hospital_respawn()

func _finish_hospital_respawn() -> void:
    if current_vehicle>=0 and current_vehicle<parked_cars.size():
        parked_cars[current_vehicle]["occupied"]=false
    current_vehicle=-1
    transit_riding=-1
    interior_active=false
    photo_mode=false
    vehicle_velocity=0.0
    player_pos=_hospital_spawn_pos()
    camera_pos=player_pos
    player_heading=-PI*0.5
    energy=maxf(75.0,energy)
    _notify("Stadtklinikum · Behandlung abgeschlossen. Achte beim Überqueren auf den Verkehr.")
    _save_game()

func _draw_hospital_cutscene() -> void:
    if hospital_transition<=0.0:
        return
    var screen:=get_viewport_rect().size
    var progress:=1.0-clampf(hospital_transition/hospital_transition_total,0.0,1.0)
    var fade:=clampf(sin(progress*PI)*1.25,0.0,1.0)
    draw_rect(Rect2(Vector2.ZERO,screen),Color(0.015,0.028,0.035,0.78+fade*0.16),true)
    var stage_text:="UNFALL · RETTUNGSDIENST ALARMIERT"
    var sub_text:="Der Verkehr stoppt. Hilfe ist unterwegs."
    if progress>0.34:
        stage_text="KRANKENWAGEN · TRANSPORT ZUM STADTKLINIKUM"
        sub_text="Kurze Fahrt durch die Stadt …"
    if progress>0.72:
        stage_text="PARALLAX STADTKLINIKUM · NOTAUFNAHME"
        sub_text="Du wirst versorgt und kannst gleich weiterspielen."
    var center:=screen*0.5
    draw_string(ThemeDB.fallback_font,center+Vector2(-430,-110),stage_text,HORIZONTAL_ALIGNMENT_CENTER,860,28,Color("#eafafa"))
    draw_string(ThemeDB.fallback_font,center+Vector2(-390,-62),sub_text,HORIZONTAL_ALIGNMENT_CENTER,780,17,Color("#a9c7ce"))
    var amb:=center+Vector2(0,45)
    draw_rect(Rect2(amb-Vector2(76,28),Vector2(152,56)),Color("#edf5f4"),true)
    draw_rect(Rect2(amb-Vector2(76,28),Vector2(152,56)),Color("#48bfa9"),false,3.0)
    draw_rect(Rect2(amb+Vector2(-10,-16),Vector2(20,32)),Color("#48bfa9"),true)
    draw_rect(Rect2(amb+Vector2(-28,-6),Vector2(56,12)),Color("#48bfa9"),true)
    draw_circle(amb+Vector2(-50,34),13,Color("#182126"))
    draw_circle(amb+Vector2(50,34),13,Color("#182126"))
    var flash:=int(Time.get_ticks_msec()/180)%2==0
    draw_circle(amb+Vector2(-15,-35),6,Color("#ff4057") if flash else Color("#32404a"))
    draw_circle(amb+Vector2(15,-35),6,Color("#55aaff") if not flash else Color("#32404a"))
    draw_rect(Rect2(center+Vector2(-280,135),Vector2(560,8)),Color(1,1,1,0.10),true)
    draw_rect(Rect2(center+Vector2(-280,135),Vector2(560*progress,8)),Color("#73f3ce"),true)

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
        var candidate:=interior_player_pos+iv*delta
        var horizontal:=Vector2(candidate.x,interior_player_pos.y)
        if InteriorArt.walkable(self,horizontal): interior_player_pos.x=horizontal.x
        var vertical:=Vector2(interior_player_pos.x,candidate.y)
        if InteriorArt.walkable(self,vertical): interior_player_pos.y=vertical.y
        player_heading = iv.angle()
        return
    if current_vehicle>=0 and not active_race.is_empty() and float(active_race.get("countdown",0.0))>0.0:
        vehicle_velocity=move_toward(vehicle_velocity,0.0,delta*600.0)
        return
    if move_vec.length() < 0.04 and current_vehicle<0:
        energy=minf(100.0,energy+delta*1.4)
        return
    if current_vehicle >= 0:
        var car: Dictionary = parked_cars[current_vehicle]
        var cls: String = str(car["class"])
        var max_speed: float = float(VEHICLE_SPEEDS.get(cls,400.0)) * _vehicle_tune_multiplier(cls,"engine")
        var accel: float = float(VEHICLE_ACCEL.get(cls,240.0)) * _vehicle_tune_multiplier(cls,"engine")
        var brake: float = float(VEHICLE_BRAKE.get(cls,350.0)) * _vehicle_tune_multiplier(cls,"brake")
        var handling: float = float(VEHICLE_HANDLING.get(cls,2.2)) * _vehicle_tune_multiplier(cls,"handling")
        var input_amount: float=clampf(move_vec.length(),0.0,1.0)
        vehicle_turn_error=0.0
        var speed_ratio: float=clampf(absf(vehicle_velocity)/max_speed,0.0,1.0)
        var desired_speed: float=0.0
        if input_amount>0.04:
            var desired_heading: float=move_vec.angle()
            var angle_error: float=wrapf(desired_heading-player_heading,-PI,PI)
            vehicle_turn_error=angle_error
            # Stick/WASD directions are world directions, shared with walking.
            # Slow for tight corners before turning; never steer against the stick.
            var turn_rate: float=handling*(2.15-0.72*speed_ratio)
            if driving_assist: turn_rate*=1.12
            player_heading=wrapf(player_heading+clampf(angle_error,-turn_rate*delta,turn_rate*delta),-PI,PI)
            var corner_factor: float=clampf(1.0-absf(angle_error)/PI*1.05,0.12,1.0)
            desired_speed=max_speed*input_amount*corner_factor
            if absf(angle_error)>2.2 and absf(vehicle_velocity)<65.0:
                desired_speed=0.0
        vehicle_braking=desired_speed<vehicle_velocity-20.0
        var rate: float=accel if desired_speed>vehicle_velocity else brake*(1.15 if driving_assist else 1.0)
        vehicle_velocity=move_toward(maxf(0.0,vehicle_velocity),desired_speed,rate*delta)
        var velocity := Vector2.from_angle(player_heading)*vehicle_velocity
        var np := player_pos+velocity*delta
        if not _point_blocked(np,18.0) and not _vehicle_dynamic_blocked(np,current_vehicle):
            player_pos=np
        else:
            var impact_speed: float = abs(vehicle_velocity)
            vehicle_velocity=0.0
            _play_sfx("impact")
            camera_shake_strength=maxf(camera_shake_strength,clampf(impact_speed/42.0,1.8,7.5))
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
        var safe_pos:=player_pos
        if not _point_blocked(np2,12.0):
            safe_pos=np2
        else:
            var step_x:=Vector2(np2.x,player_pos.y)
            if not _point_blocked(step_x,12.0):
                safe_pos.x=step_x.x
            var step_y:=Vector2(safe_pos.x,np2.y)
            if not _point_blocked(step_y,12.0):
                safe_pos.y=step_y.y
        player_pos=safe_pos
        player_heading=velocity2.angle()
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

func _road_neighbors(road_index: int) -> Array:
    var result: Array=[]
    for j in junctions:
        if bool(j.get("bridge",false)):
            continue
        var a: int=int(j.a)
        var b: int=int(j.b)
        if a==road_index and b not in result:
            result.append(b)
        elif b==road_index and a not in result:
            result.append(a)
    return result

func _build_road_route(start_road: int, goal_road: int) -> Array:
    if start_road==goal_road:
        return [start_road]
    var frontier: Array=[start_road]
    var parent: Dictionary={start_road:-1}
    var cursor: int=0
    while cursor<frontier.size():
        var current: int=int(frontier[cursor])
        cursor+=1
        for neighbor_value in _road_neighbors(current):
            var neighbor: int=int(neighbor_value)
            if parent.has(neighbor):
                continue
            parent[neighbor]=current
            if neighbor==goal_road:
                var path: Array=[goal_road]
                var walk: int=current
                while walk>=0:
                    path.push_front(walk)
                    walk=int(parent.get(walk,-1))
                return path
            frontier.append(neighbor)
    return [start_road]

func _new_response_route(start_road: int) -> Array:
    if roads.size()<2:
        return [start_road]
    var goal: int=(start_road+5+rng.randi_range(0,maxi(1,roads.size()-2)))%roads.size()
    if goal==start_road:
        goal=(goal+1)%roads.size()
    return _build_road_route(start_road,goal)

func _response_route_next_road(car: Dictionary, junction: Dictionary) -> int:
    var route: Array=Array(car.get("response_route",[]))
    var index: int=int(car.get("response_route_index",0))
    if route.size()<2 or index>=route.size()-1:
        return -1
    var current: int=int(car.road)
    var next_road: int=int(route[index+1])
    var a: int=int(junction.a)
    var b: int=int(junction.b)
    if (a==current and b==next_road) or (b==current and a==next_road):
        return next_road
    return -1

func _active_response_incident_indices() -> Array:
    var result: Array=[]
    for i in range(response_incidents.size()):
        if _incident_active(i):
            result.append(i)
    return result

func _active_emergency_targets() -> Array:
    var result: Array=[]
    for i in range(response_incidents.size()):
        if not _incident_active(i):
            continue
        var incident: Dictionary=response_incidents[i]
        result.append({
            "id":str(incident.id),
            "pos":Vector2(incident.pos),
            "kind":"service_incident",
            "priority":1
        })
    for accident in traffic_accidents:
        if str(accident.get("state","active"))!="active":
            continue
        result.append({
            "id":str(accident.id),
            "pos":Vector2(accident.pos),
            "kind":"traffic_accident",
            "priority":2
        })
    result.sort_custom(func(a,b): return int(a.priority)>int(b.priority))
    return result

func _assign_emergency_target(car: Dictionary, target_pos: Vector2, target_kind: String, target_id: String) -> Dictionary:
    var start_road: int=int(car.road)
    var goal_road: int=_nearest_road_index(target_pos)
    car["response_target"]=target_pos
    car["response_target_kind"]=target_kind
    car["response_target_id"]=target_id
    car["response_route"]=_build_road_route(start_road,goal_road)
    car["response_route_index"]=0
    car["response_dwell"]=0.0
    return car

func _retask_emergency_car(car: Dictionary, index: int) -> Dictionary:
    var archetype:=str(car.get("archetype",""))
    var current_kind:=str(car.get("response_target_kind",""))
    if archetype=="ambulance" and current_kind in ["incident","traffic_accident"]:
        return _assign_emergency_target(car,_hospital_world_pos(),"hospital","hospital")
    var targets:=_active_emergency_targets()
    if not targets.is_empty():
        var target: Dictionary=targets[index%targets.size()]
        var kind: String="traffic_accident" if str(target.kind)=="traffic_accident" else "incident"
        return _assign_emergency_target(car,Vector2(target.pos),kind,str(target.id))
    return _assign_emergency_target(car,_hospital_world_pos(),"hospital","hospital")

func _update_response_dispatches(force: bool = false) -> void:
    if response_incidents.is_empty() and traffic_accidents.is_empty():
        return
    var slot: int=int(floor(world_clock*1.35))
    if not force and slot==response_dispatch_slot:
        return
    response_dispatch_slot=slot
    var targets:=_active_emergency_targets()
    var emergency_order:=0
    for i in range(traffic.size()):
        var car: Dictionary=traffic[i]
        if not _is_emergency_archetype(str(car.get("archetype",""))):
            continue
        if bool(car.get("crashed",false)):
            continue
        if targets.is_empty():
            car=_assign_emergency_target(car,_hospital_world_pos(),"hospital","hospital")
        else:
            # Ambulances and response vehicles distribute across the most urgent live targets.
            var target: Dictionary=targets[emergency_order%targets.size()]
            var target_kind: String="traffic_accident" if str(target.kind)=="traffic_accident" else "incident"
            car=_assign_emergency_target(car,Vector2(target.pos),target_kind,str(target.id))
        traffic[i]=car
        emergency_order+=1

func _response_priority_pressure(index: int, car: Dictionary) -> float:
    if _is_emergency_archetype(str(car.get("archetype",""))):
        return 0.0
    var road_index:=int(car.road)
    var car_t:=float(car.t)
    var reverse:=bool(car.reverse)
    for k in range(traffic.size()):
        if k==index:
            continue
        var other: Dictionary=traffic[k]
        if not _is_emergency_archetype(str(other.get("archetype",""))):
            continue
        if int(other.road)!=road_index or bool(other.reverse)!=reverse:
            continue
        var direction: float=-1.0 if reverse else 1.0
        var gap: float=(car_t-float(other.t))*direction
        if gap<0.0:
            gap+=1.0
        if gap>0.0 and gap<0.075:
            return 1.0-clampf(gap/0.075,0.0,1.0)
    return 0.0

func _traffic_accident_pair_valid(a: Dictionary, b: Dictionary) -> bool:
    if bool(a.get("crashed",false)) or bool(b.get("crashed",false)):
        return false
    if _is_emergency_archetype(str(a.get("archetype",""))) or _is_emergency_archetype(str(b.get("archetype",""))):
        return false
    if abs(float(a.get("speed",0.0)))<0.020 or abs(float(b.get("speed",0.0)))<0.020:
        return false
    var ta:=_traffic_world_transform(a)
    var tb:=_traffic_world_transform(b)
    var pa:=Vector2(ta.pos)
    var pb:=Vector2(tb.pos)
    if pa.distance_to(pb)>34.0:
        return false
    var dir_a:=Vector2(ta.tangent).normalized()
    var dir_b:=Vector2(tb.tangent).normalized()
    var conflict_angle:=absf(dir_a.angle_to(dir_b))
    var turning_conflict:=float(a.get("turn_anim",0.0))>0.0 or float(b.get("turn_anim",0.0))>0.0
    var lane_conflict:=float(a.get("lane_change",0.0))>0.0 or float(b.get("lane_change",0.0))>0.0
    return conflict_angle>0.34 or turning_conflict or lane_conflict

func _create_traffic_accident(a_index: int, b_index: int) -> void:
    if a_index<0 or b_index<0 or a_index>=traffic.size() or b_index>=traffic.size():
        return
    var a: Dictionary=traffic[a_index]
    var b: Dictionary=traffic[b_index]
    var ta:=_traffic_world_transform(a)
    var tb:=_traffic_world_transform(b)
    var pos: Vector2=(Vector2(ta.pos)+Vector2(tb.pos))*0.5
    var id:="traffic_crash_%d" % traffic_accident_serial
    traffic_accident_serial+=1
    var severity:=clampf((abs(float(a.speed))+abs(float(b.speed)))/0.10,0.35,1.0)
    a["crashed"]=true
    b["crashed"]=true
    a["speed"]=0.0
    b["speed"]=0.0
    a["cruise_before_crash"]=float(a.get("cruise",0.03))
    b["cruise_before_crash"]=float(b.get("cruise",0.03))
    a["crash_id"]=id
    b["crash_id"]=id
    a["crash_angle"]=rng.randf_range(-0.18,0.18)
    b["crash_angle"]=rng.randf_range(-0.18,0.18)
    a["hazard_after_crash"]=true
    b["hazard_after_crash"]=true
    traffic[a_index]=a
    traffic[b_index]=b
    traffic_accidents.append({
        "id":id,
        "pos":pos,
        "car_a":a_index,
        "car_b":b_index,
        "severity":severity,
        "age":0.0,
        "state":"active",
        "road":int(a.road)
    })
    _play_sfx("impact")
    if player_pos.distance_to(pos)<850.0:
        camera_shake_strength=maxf(camera_shake_strength,3.2+severity*2.2)
        _notify("Verkehrsunfall gemeldet · Rettungskräfte werden disponiert.")
    response_dispatch_slot=-1
    _update_response_dispatches(true)

func _maybe_create_ai_traffic_accident() -> void:
    if traffic_accidents.size()>=3:
        return
    var weather:=_weather_state()
    var risk:=0.018
    if weather=="rain":
        risk=0.032
    elif weather=="storm":
        risk=0.050
    elif weather=="mist":
        risk=0.027
    for i in range(traffic.size()):
        var a: Dictionary=traffic[i]
        if bool(a.get("crashed",false)):
            continue
        var pa:=Vector2(_traffic_world_transform(a).pos)
        if player_pos.distance_to(pa)>2400.0:
            continue
        for k in range(i+1,traffic.size()):
            var b: Dictionary=traffic[k]
            if not _traffic_accident_pair_valid(a,b):
                continue
            if rng.randf()<risk:
                _create_traffic_accident(i,k)
                return

func _release_crashed_vehicle(index: int) -> void:
    if index<0 or index>=traffic.size():
        return
    var car: Dictionary=traffic[index]
    car["crashed"]=false
    car["crash_id"]=""
    car["hazard_after_crash"]=false
    car["crash_angle"]=0.0
    car["speed"]=0.0
    car["cruise"]=float(car.get("cruise_before_crash",car.get("cruise",0.03)))
    car["t"]=fposmod(float(car.t)+rng.randf_range(0.025,0.070),1.0)
    car["lane"]=rng.randi_range(0,1)
    traffic[index]=car

func _update_traffic_accidents(delta: float) -> void:
    traffic_accident_scan_timer-=delta
    if traffic_accident_scan_timer<=0.0:
        traffic_accident_scan_timer=1.15
        _maybe_create_ai_traffic_accident()
    for i in range(traffic_accidents.size()-1,-1,-1):
        var accident: Dictionary=traffic_accidents[i]
        accident["age"]=float(accident.get("age",0.0))+delta
        var age: float=float(accident.age)
        if age>42.0 and str(accident.state)=="active":
            accident["state"]="clearing"
        if age>58.0:
            _release_crashed_vehicle(int(accident.car_a))
            _release_crashed_vehicle(int(accident.car_b))
            traffic_accidents.remove_at(i)
            response_dispatch_slot=-1
            continue
        traffic_accidents[i]=accident

func _traffic_near_dynamic_accident(car: Dictionary) -> bool:
    if bool(car.get("crashed",false)):
        return true
    var pos:=Vector2(_traffic_world_transform(car).pos)
    for accident in traffic_accidents:
        if str(accident.get("state","active"))=="cleared":
            continue
        if pos.distance_to(Vector2(accident.pos))<175.0:
            return true
    return false

func _draw_traffic_accidents() -> void:
    for accident in traffic_accidents:
        var pos:=Vector2(accident.pos)
        if player_pos.distance_to(pos)>1850.0:
            continue
        var age:=float(accident.get("age",0.0))
        var severity:=float(accident.get("severity",0.5))
        var p:=_project(pos,5)
        var pulse:=0.55+0.45*sin(float(Time.get_ticks_msec())/220.0)
        draw_circle(p,26.0+severity*12.0,Color(1.0,0.38,0.20,0.035+0.025*pulse))
        draw_line(p+Vector2(-52,-18),p+Vector2(-12,-4),Color(0.04,0.05,0.06,0.30),3.0,true)
        draw_line(p+Vector2(48,20),p+Vector2(10,6),Color(0.04,0.05,0.06,0.24),2.6,true)
        if _weather_state() in ["rain","storm"]:
            draw_circle(p+Vector2(4,15),34.0,Color(0.32,0.46,0.50,0.035))
            draw_line(p+Vector2(-18,15),p+Vector2(18,15),Color(0.72,0.82,0.86,0.055),3.0,true)
        for k in range(6):
            var a:=float(k)*TAU/6.0+float(int(accident.id.hash())%11)*0.08
            var d:=Vector2.from_angle(a)
            var debris:=p+d*(18.0+float(k%3)*7.0)
            draw_rect(Rect2(debris-Vector2(3,2),Vector2(6,4)),Color("#4d5456"),true)
        if age>5.0:
            for k in range(4):
                var a:=float(k)*TAU/4.0
                var cone:=p+Vector2.from_angle(a)*45.0
                var poly:=PackedVector2Array([cone+Vector2(-4,5),cone+Vector2(4,5),cone+Vector2(1,-6),cone+Vector2(-1,-6)])
                draw_colored_polygon(poly,Color("#e77e36"))
        if age<6.0 and graphics_quality>=1:
            for k in range(3):
                var spark:=p+Vector2.from_angle(float(k)*2.1+age)*float(8+k*5)
                draw_circle(spark,2.0,Color(1.0,0.70,0.25,0.55))
        if graphics_quality>=1 and age<28.0:
            for smoke_i in range(3):
                var drift:=fposmod(age*10.0+float(smoke_i)*17.0,54.0)
                var smoke_pos:=p+Vector2(sin(age*0.8+float(smoke_i))*7.0,-10.0-drift)
                draw_circle(smoke_pos,6.0+drift*0.07,Color(0.52,0.57,0.58,0.055*(1.0-drift/60.0)))
        var emergency_near:=false
        for car_state in traffic:
            if not _is_emergency_archetype(str(car_state.get("archetype",""))):
                continue
            if Vector2(_traffic_world_transform(car_state).pos).distance_to(pos)<180.0:
                emergency_near=true
                break
        if emergency_near:
            var siren:=0.5+0.5*sin(float(Time.get_ticks_msec())/120.0)
            draw_circle(p+Vector2(-22,8),18,Color(1.0,0.18,0.23,0.012+(1.0-siren)*0.020))
            draw_circle(p+Vector2(22,8),18,Color(0.18,0.52,1.0,0.012+siren*0.020))
        draw_string(ThemeDB.fallback_font,p+Vector2(-80,-48),"UNFALLSTELLE",HORIZONTAL_ALIGNMENT_CENTER,160,10,Color("#ffb36d"))

func _update_traffic(delta: float) -> void:
    for i in range(traffic.size()):
        var c: Dictionary = traffic[i]
        if bool(c.get("crashed",false)):
            c["speed"]=0.0
            c["indicator"]=0
            traffic[i]=c
            continue
        c["turn_cooldown"]=maxf(0.0,float(c.get("turn_cooldown",0.0))-delta)
        c["turn_anim"]=maxf(0.0,float(c.get("turn_anim",0.0))-delta)
        if float(c.get("turn_anim",0.0))<=0.0 and float(c.get("lane_change",0.0))<=0.0:
            c["indicator"]=0
        var direction: float = -1.0 if bool(c.reverse) else 1.0
        var target_speed: float = float(c.cruise)
        var response_priority:=_is_emergency_archetype(str(c.get("archetype","")))
        if response_priority:
            target_speed*=1.22
            var route: Array=Array(c.get("response_route",[]))
            var route_index: int=int(c.get("response_route_index",0))
            if route.is_empty() or route_index>=route.size() or int(route[mini(route_index,route.size()-1)])!=int(c.road):
                var target_pos:=Vector2(c.get("response_target",Vector2.ZERO))
                if target_pos!=Vector2.ZERO:
                    c["response_route"]=_build_road_route(int(c.road),_nearest_road_index(target_pos))
                else:
                    c["response_route"]=_new_response_route(int(c.road))
                c["response_route_index"]=0
            var emergency_target:=Vector2(c.get("response_target",Vector2.ZERO))
            var emergency_dwell: float=float(c.get("response_dwell",0.0))
            if emergency_dwell>0.0:
                c["response_dwell"]=maxf(0.0,emergency_dwell-delta)
                target_speed=0.0
                if float(c.response_dwell)<=0.0:
                    c=_retask_emergency_car(c,i)
            elif emergency_target!=Vector2.ZERO and Vector2(_traffic_world_transform(c).pos).distance_to(emergency_target)<125.0:
                c["response_dwell"]=5.5 if str(c.get("archetype",""))=="ambulance" else 4.0
                target_speed=0.0
        var response_pressure:=_response_priority_pressure(i,c)
        c["response_yield"]=response_pressure>0.0
        if response_pressure>0.0:
            target_speed*=lerpf(1.0,0.18,response_pressure)

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

        if current_vehicle<0 and transit_riding<0 and not interior_active:
            var foot_tr:=_traffic_world_transform(c)
            var foot_car_pos:=Vector2(foot_tr.pos)
            var foot_gap: float=foot_car_pos.distance_to(player_pos)
            if foot_gap<105.0:
                var to_player:=player_pos-foot_car_pos
                var closing:=Vector2(foot_tr.tangent).dot(to_player.normalized()) if to_player.length()>0.001 else 1.0
                if closing>0.15:
                    if foot_gap<30.0:
                        target_speed*=0.10
                    elif foot_gap<65.0:
                        target_speed*=0.32
                    else:
                        target_speed*=0.68

        var ped_yield:=_traffic_has_crossing_hazard(c)
        c["ped_yield"]=ped_yield
        if ped_yield:
            target_speed=0.0

        var incident_yield:=_traffic_near_active_incident(c)
        c["incident_yield"]=incident_yield
        if incident_yield:
            target_speed*=0.28

        var crash_yield:=_traffic_near_dynamic_accident(c)
        c["crash_yield"]=crash_yield
        if crash_yield:
            target_speed*=0.20

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
                if response_priority:
                    target_speed*=0.72
                else:
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
            var forced_response_road: int=_response_route_next_road(c,j) if response_priority else -1
            var should_turn: bool=forced_response_road>=0 or rng.randf()<0.30
            if crossed and should_turn:
                var old_road: int = int(c.road)
                var new_road: int = forced_response_road if forced_response_road>=0 else (int(j.b) if int(j.a)==old_road else int(j.a))
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
                if forced_response_road>=0:
                    c["response_route_index"]=int(c.get("response_route_index",0))+1
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

func _ped_world_pos(p: Dictionary) -> Vector2:
    var rd=roads[int(p.road)]
    var pos:=_sample_polyline(rd.points,float(p.t))
    var tan:=_polyline_tangent(rd.points,float(p.t))
    if bool(p.get("reverse",false)):
        tan*=-1.0
    var normal:=Vector2(-tan.y,tan.x)
    var sidewalk:=float(rd.width)*0.5+18.0
    var side_factor:=float(p.get("side",1.0))
    if str(p.get("state","walk"))=="cross":
        var from_side:=float(p.get("cross_from_side",side_factor))
        side_factor=lerpf(from_side,-from_side,clampf(float(p.get("cross_progress",0.0)),0.0,1.0))
    return pos+normal*sidewalk*side_factor

func _crossing_vehicle_near(p: Dictionary, threshold: float = 85.0) -> bool:
    var road_index:=int(p.road)
    var pt:=float(p.t)
    for car in traffic:
        if int(car.road)!=road_index:
            continue
        var dt: float=absf(float(car.t)-pt)
        dt=minf(dt,1.0-dt)
        if dt<0.020:
            var tr:=_traffic_world_transform(car)
            if Vector2(tr.pos).distance_to(_ped_world_pos(p))<threshold:
                return true
    if current_vehicle>=0 and player_pos.distance_to(_ped_world_pos(p))<threshold:
        return true
    return false

func _traffic_has_crossing_hazard(car: Dictionary) -> bool:
    var road_index:=int(car.road)
    if not active_crossings_by_road.has(road_index):
        return false
    var car_t:=float(car.t)
    for cross_t in Array(active_crossings_by_road[road_index]):
        var dt: float=absf(float(cross_t)-car_t)
        dt=minf(dt,1.0-dt)
        if dt<0.018:
            return true
    return false

func _junction_between_roads(a: int, b: int) -> Dictionary:
    for j in junctions:
        if bool(j.get("bridge",false)):
            continue
        if (int(j.a)==a and int(j.b)==b) or (int(j.a)==b and int(j.b)==a):
            return j
    return {}

func _shelter_target_t_for_route(p: Dictionary) -> float:
    var route: Array=Array(p.get("shelter_route",[]))
    var route_index: int=int(p.get("shelter_route_index",0))
    var current_road: int=int(p.road)
    if route.is_empty() or route_index>=route.size()-1:
        return _nearest_road_t_to_point(current_road,Vector2(p.get("shelter_target",Vector2.ZERO)))
    var next_road: int=int(route[route_index+1])
    var j:=_junction_between_roads(current_road,next_road)
    if j.is_empty():
        return _nearest_road_t_to_point(current_road,Vector2(p.get("shelter_target",Vector2.ZERO)))
    return float(j.ta) if int(j.a)==current_road else float(j.tb)

func _configure_ped_shelter_route(p: Dictionary, shelter: Vector2) -> Dictionary:
    var current_road: int=int(p.road)
    var shelter_road: int=_nearest_road_index(shelter)
    p["shelter_target"]=shelter
    p["shelter_route"]=_build_road_route(current_road,shelter_road)
    p["shelter_route_index"]=0
    p["state"]="seek_shelter"
    p["target_t"]=_shelter_target_t_for_route(p)
    return p

func _advance_ped_shelter_route(p: Dictionary) -> Dictionary:
    var route: Array=Array(p.get("shelter_route",[]))
    var route_index: int=int(p.get("shelter_route_index",0))
    if route.is_empty() or route_index>=route.size()-1:
        p["state"]="shelter"
        p["pause"]=rng.randf_range(5.0,11.0)
        return p
    var current_road: int=int(p.road)
    var next_road: int=int(route[route_index+1])
    var j:=_junction_between_roads(current_road,next_road)
    if j.is_empty():
        p["state"]="shelter"
        p["pause"]=rng.randf_range(5.0,11.0)
        return p
    p["road"]=next_road
    p["t"]=float(j.tb) if int(j.b)==next_road else float(j.ta)
    p["shelter_route_index"]=route_index+1
    p["side"]=-1.0 if rng.randf()<0.5 else 1.0
    p["target_t"]=_shelter_target_t_for_route(p)
    if int(p.shelter_route_index)>=route.size()-1 and abs(float(p.target_t)-float(p.t))<0.008:
        p["state"]="shelter"
        p["pause"]=rng.randf_range(5.0,11.0)
    return p

func _nearest_rain_shelter(pos: Vector2, max_distance: float = 650.0) -> Vector2:
    var best:=Vector2.ZERO
    var best_dist: float=max_distance
    for s in social_setpieces:
        if str(s.kind)!="rain_shelter":
            continue
        var shelter_pos:=Vector2(s.pos)
        var dist: float=pos.distance_to(shelter_pos)
        if dist<best_dist:
            best=shelter_pos
            best_dist=dist
    return best

func _ped_should_seek_shelter(index: int, p: Dictionary) -> bool:
    if _weather_state() not in ["rain","storm"]:
        return false
    if index%4==0:
        return false
    if str(p.get("state","walk")) in ["cross","alert","wave","shelter","seek_shelter"]:
        return false
    return true

func _update_pedestrians(delta: float) -> void:
    active_crossings_by_road.clear()
    for i in range(pedestrians.size()):
        var p: Dictionary = pedestrians[i]
        p["phase"]=fposmod(float(p.phase)+delta*5.0,TAU)
        var state:=str(p.get("state","walk"))
        if _weather_state() not in ["rain","storm"] and state in ["shelter","seek_shelter"]:
            p["state"]="walk"
            p["pause"]=0.0
            p["shelter_target"]=Vector2.ZERO
            p["shelter_route"]=[]
            p["shelter_route_index"]=0
            state="walk"
        elif _ped_should_seek_shelter(i,p):
            var current_pos:=_ped_world_pos(p)
            var shelter:=_nearest_rain_shelter(current_pos,650.0)
            if shelter!=Vector2.ZERO:
                p=_configure_ped_shelter_route(p,shelter)
                state="seek_shelter"

        if state=="cross":
            if not _crossing_vehicle_near(p,72.0):
                p["cross_progress"]=minf(1.0,float(p.get("cross_progress",0.0))+delta*0.34)
            if float(p.cross_progress)>=1.0:
                p["side"]=-float(p.get("cross_from_side",p.side))
                p["state"]="walk"
                p["cross_progress"]=0.0
                p["pause"]=rng.randf_range(0.4,1.3)
                p["target_t"]=rng.randf_range(0.05,0.95)
            else:
                if not active_crossings_by_road.has(int(p.road)):
                    active_crossings_by_road[int(p.road)]=[]
                var crossings: Array=active_crossings_by_road[int(p.road)]
                crossings.append(float(p.t))
                active_crossings_by_road[int(p.road)]=crossings
            pedestrians[i]=p
            continue

        var pause: float = float(p.get("pause",0.0))
        if _ped_near_transit_arrival(p):
            p["state"]="wave"
            p["pause"]=maxf(pause,0.85)
            pause=float(p.pause)
        if pause>0.0:
            p["pause"]=maxf(0.0,pause-delta)
            if current_vehicle>=0 and player_pos.distance_to(_ped_world_pos(p))<70.0:
                p["state"]="alert"
                p["pause"]=maxf(float(p.pause),0.75)
            elif float(p.pause)<=0.0:
                p["state"]="walk"
            pedestrians[i]=p
            continue

        var target_t: float = float(p.get("target_t",float(p.t)))
        var diff: float = target_t-float(p.t)
        if abs(diff)>0.5:
            diff=-sign(diff)*(1.0-abs(diff))
        var direction: float = sign(diff)
        if abs(diff)>0.008:
            p["state"]="walk"
            p["reverse"]=direction<0.0
            p["t"]=fposmod(float(p.t)+float(p.speed)*delta*direction,1.0)
        else:
            if state=="seek_shelter" and _weather_state() in ["rain","storm"]:
                p=_advance_ped_shelter_route(p)
                pedestrians[i]=p
                continue
            # Arrive at a routine stop, then choose a social/idle action.
            var role: String = str(p.get("routine","work"))
            var dwell: float = rng.randf_range(2.0,5.0)
            if role=="shop": dwell=rng.randf_range(3.0,7.0)
            elif role=="park": dwell=rng.randf_range(4.0,10.0)
            elif role=="transit": dwell=rng.randf_range(2.0,5.0)
            elif role=="home": dwell=rng.randf_range(5.0,12.0)

            var junction:=_junction_for_car(int(p.road),float(p.t),0.040)
            var pedestrian_green:=not junction.is_empty() and not _junction_green(junction,int(p.road))
            if pedestrian_green and rng.randf()<0.42:
                p["state"]="cross"
                p["cross_progress"]=0.0
                p["cross_from_side"]=float(p.side)
                p["pause"]=0.0
                if not active_crossings_by_road.has(int(p.road)):
                    active_crossings_by_road[int(p.road)]=[]
                var starts: Array=active_crossings_by_road[int(p.road)]
                starts.append(float(p.t))
                active_crossings_by_road[int(p.road)]=starts
            else:
                var idle_roll:=rng.randf()
                var partner:=int(p.get("social_partner",-1))
                if partner>=0 and partner<pedestrians.size() and idle_roll<0.46:
                    p["state"]="chat"
                    var other: Dictionary=pedestrians[partner]
                    if int(other.road)==int(p.road):
                        other["pause"]=dwell
                        other["state"]="chat"
                        other["target_t"]=p.target_t
                        pedestrians[partner]=other
                elif role in ["park","home"] and idle_roll<0.72:
                    p["state"]="sit"
                elif idle_roll<0.88:
                    p["state"]="phone"
                else:
                    p["state"]="idle"
                p["pause"]=dwell
                p["target_t"]=rng.randf_range(0.05,0.95)

                if rng.randf()<0.16:
                    var j := _junction_for_car(int(p.road),float(p.t),0.055)
                    if not j.is_empty():
                        var new_road: int = int(j.b) if int(j.a)==int(p.road) else int(j.a)
                        p["road"]=new_road
                        p["t"]=float(j.tb) if new_road==int(j.b) else float(j.ta)
                        p["side"]=-1.0 if rng.randf()<0.5 else 1.0
        pedestrians[i]=p

func _transit_stop_has_arrival(stop_index: int) -> bool:
    if stop_index<0 or stop_index>=transit_stops.size():
        return false
    var st: Dictionary=transit_stops[stop_index]
    var vi:=int(st.vehicle)
    if vi<0 or vi>=transit_vehicles.size():
        return false
    var tv: Dictionary=transit_vehicles[vi]
    return bool(tv.get("at_stop",false)) and int(tv.get("stop_index",-1))==stop_index

func _ped_near_transit_arrival(p: Dictionary) -> bool:
    if str(p.get("routine",""))!="transit":
        return false
    var pp:=_ped_world_pos(p)
    for si in range(transit_stops.size()):
        if not _transit_stop_has_arrival(si):
            continue
        if pp.distance_to(Vector2(transit_stops[si].pos))<185.0:
            return true
    return false

func _incident_active(index: int) -> bool:
    var slot:=int(floor(world_clock*1.35))
    return ((slot+index*3)%9) in [0,1]

func _traffic_near_active_incident(car: Dictionary) -> bool:
    var tr:=_traffic_world_transform(car)
    var pos:=Vector2(tr.pos)
    for i in range(response_incidents.size()):
        if not _incident_active(i):
            continue
        if int(response_incidents[i].road)!=int(car.road):
            continue
        if pos.distance_to(Vector2(response_incidents[i].pos))<165.0:
            return true
    return false

func _draw_social_person(pos: Vector2, accent: Color, state: String, seed: int) -> void:
    var base:=_project(pos,0)
    var pelvis:=_project(pos,10)
    var head:=_project(pos,19)
    var skin: Color=[Color("#f1c7a8"),Color("#d79b75"),Color("#b87655"),Color("#7b4f3d")][absi(seed)%4]
    var cloth:=accent.lerp(Color("#d7e1e5"),0.36+float(absi(seed)%3)*0.10)
    draw_circle(base+Vector2(2,5),5.0,Color(0,0,0,0.16))
    if state=="sit":
        pelvis.y+=5.0
        head.y+=7.0
        draw_line(pelvis,pelvis+Vector2(0,10),cloth,4.0,true)
        draw_line(pelvis+Vector2(0,8),pelvis+Vector2(-8,14),Color("#66747b"),2.4,true)
        draw_line(pelvis+Vector2(0,8),pelvis+Vector2(8,14),Color("#66747b"),2.4,true)
    else:
        draw_line(pelvis,pelvis+Vector2(0,13),cloth,4.0,true)
        draw_line(pelvis+Vector2(0,8),pelvis+Vector2(-4,18),Color("#66747b"),2.2,true)
        draw_line(pelvis+Vector2(0,8),pelvis+Vector2(4,18),Color("#66747b"),2.2,true)
    draw_circle(head,4.6,skin)
    if state=="wave":
        draw_line(pelvis+Vector2(0,2),pelvis+Vector2(10,-10),cloth,2.4,true)
        draw_circle(pelvis+Vector2(11,-11),2.0,skin)
    elif state=="chat":
        draw_line(pelvis+Vector2(0,2),pelvis+Vector2(8,-2),cloth,2.2,true)
        draw_circle(head+Vector2(8,-14),6.0,Color(0.95,0.98,1.0,0.74))
        draw_circle(head+Vector2(6,-14),1.0,Color("#324047"))
        draw_circle(head+Vector2(9,-14),1.0,Color("#324047"))

func _draw_loading_scene(s: Dictionary, dock: bool) -> void:
    var pos:=Vector2(s.pos)
    var heading:=float(s.get("heading",0.0))
    var f:=Vector2.from_angle(heading)
    var side:=Vector2(-f.y,f.x)
    var t:=float(Time.get_ticks_msec())/1000.0+float(int(s.seed)%17)
    var cycle:=fposmod(t,5.2)/5.2
    var van_pos:=pos-f*52.0
    _draw_car(van_pos,heading,"delivery",Color("#edf2ee"),true,"courier")
    var door:=_project(van_pos+f*28.0,10)
    draw_rect(Rect2(door-Vector2(8,10),Vector2(16,20)),Color("#1d272b"),true)
    var target:=pos+f*(74.0 if not dock else 110.0)
    var crate_world:=van_pos.lerp(target,clampf(cycle*1.35,0.0,1.0))
    var crate:=_project(crate_world,7)
    draw_rect(Rect2(crate-Vector2(9,7),Vector2(18,14)),Color("#9a6d45"),true)
    draw_rect(Rect2(crate-Vector2(9,7),Vector2(18,14)),Color("#d6a66b"),false,1.4)
    var worker_pos:=crate_world-side*18.0
    _draw_social_person(worker_pos,Color("#f0b84b"),"walk",int(s.seed)+4)
    if dock:
        var base:=_project(target,4)
        for k in range(3):
            draw_rect(Rect2(base+Vector2(float(k)*18.0-26,-float(k%2)*12.0),Vector2(16,14)),Color("#76543d"),true)
        var lift_x:=sin(t*1.2)*28.0
        draw_rect(Rect2(base+Vector2(lift_x-13,22),Vector2(26,13)),Color("#d59a3f"),true)
        draw_circle(base+Vector2(lift_x-7,37),5,Color("#22282b"))
        draw_circle(base+Vector2(lift_x+8,37),5,Color("#22282b"))
        draw_line(base+Vector2(lift_x+10,20),base+Vector2(lift_x+10,-14),Color("#4a555a"),3.0,true)
        draw_line(base+Vector2(lift_x+10,-14),base+Vector2(lift_x+30,-14),Color("#4a555a"),2.0,true)

func _draw_district_signature_scene(s: Dictionary) -> void:
    var pos:=Vector2(s.pos)
    var style:=str(s.style)
    var district:=str(s.district)
    var c:=_project(pos,8)
    var accent: Color=Color(_district_at(pos).get("accent",Color("#9ad5ff")))
    var t:=float(Time.get_ticks_msec())/1000.0
    if style=="heritage":
        draw_rect(Rect2(c-Vector2(42,18),Vector2(84,36)),Color("#5c4638"),true)
        draw_line(c+Vector2(-34,-18),c+Vector2(-28,-42),accent,3.0,true)
        draw_line(c+Vector2(34,-18),c+Vector2(28,-42),accent,3.0,true)
    elif style=="culture":
        draw_rect(Rect2(c-Vector2(46,30),Vector2(92,60)),Color("#263641"),true)
        for k in range(4):
            draw_arc(c+Vector2(float(k-1)*15.0,0),18+float(k)*3.0,t*0.4+float(k),t*0.4+float(k)+PI,18,accent,2.0,true)
    elif style=="glass":
        var q:=PackedVector2Array([c+Vector2(0,-52),c+Vector2(38,24),c+Vector2(0,42),c+Vector2(-38,24)])
        draw_colored_polygon(q,Color(accent.r,accent.g,accent.b,0.20))
        draw_polyline(PackedVector2Array([q[0],q[1],q[2],q[3],q[0]]),accent,2.0,true)
    elif style in ["green","garden"]:
        draw_arc(c,44,PI,TAU,24,Color("#6fc58a"),5.0,true)
        for k in range(5):
            draw_circle(c+Vector2(float(k-2)*15.0,18),8,Color("#4d8f5b"))
    elif style=="solar":
        for k in range(4):
            var d:=Vector2.from_angle(float(k)*PI*0.5+t*0.08)
            draw_rect(Rect2(c+d*24.0-Vector2(12,6),Vector2(24,12)),Color("#d8cf67"),true)
    elif style in ["canal","coast"]:
        draw_line(c+Vector2(-44,18),c+Vector2(44,18),Color("#6e8f98"),4.0,true)
        for k in range(4):
            draw_circle(c+Vector2(float(k-2)*22.0,9),5,accent)
    elif style=="center":
        draw_rect(Rect2(c-Vector2(22,42),Vector2(44,84)),Color("#314a57"),true)
        draw_string(ThemeDB.fallback_font,c+Vector2(-16,-12),"i",HORIZONTAL_ALIGNMENT_CENTER,32,32,accent)
    elif style=="harbor":
        for k in range(4):
            draw_rect(Rect2(c+Vector2(float(k%2)*30-30,float(k/2)*17-6),Vector2(28,15)),[Color("#b56c4f"),Color("#47768a")][k%2],true)
        draw_line(c+Vector2(40,28),c+Vector2(40,-52),Color("#8c765f"),4.0,true)
        draw_line(c+Vector2(40,-52),c+Vector2(78,-52),accent,3.0,true)
    elif style in ["industry","rail"]:
        for k in range(3):
            draw_line(c+Vector2(float(k-1)*22,30),c+Vector2(float(k-1)*22,-36),Color("#6c6e6c"),7.0,true)
        draw_circle(c+Vector2(0,-46),8+sin(t*2.0)*2.0,Color(0.82,0.86,0.86,0.12))
    elif style=="terminal":
        draw_rect(Rect2(c-Vector2(48,28),Vector2(96,56)),Color("#29343a"),true)
        for k in range(3):
            draw_string(ThemeDB.fallback_font,c+Vector2(-40,-18+float(k)*17),"→ %02d:%02d" % [12+k,int(fposmod(t*3.0+float(k)*7.0,60.0))],HORIZONTAL_ALIGNMENT_LEFT,82,10,accent)
    elif style=="campus":
        for k in range(4):
            draw_circle(c+Vector2(float(k-2)*20.0,18),9,Color("#4b647d"),false,2.0)
            draw_line(c+Vector2(float(k-2)*20.0-8,18),c+Vector2(float(k-2)*20.0+8,18),Color("#4b647d"),2.0,true)
        draw_rect(Rect2(c-Vector2(34,34),Vector2(68,18)),Color("#536c8a"),true)
    elif style=="astro":
        draw_arc(c+Vector2(0,10),38,PI,TAU,28,accent,4.0,true)
        draw_line(c+Vector2(12,-22),c+Vector2(42,-48),Color("#8f84b8"),6.0,true)
    elif style=="neon":
        draw_rect(Rect2(c-Vector2(44,24),Vector2(88,48)),Color("#241c35"),true)
        draw_arc(c,30,0,TAU,24,Color(accent.r,accent.g,accent.b,0.65+0.25*sin(t*3.0)),4.0,true)
    elif style=="expo":
        var q:=PackedVector2Array([c+Vector2(-46,20),c+Vector2(46,20),c+Vector2(28,-30),c+Vector2(-28,-30)])
        draw_colored_polygon(q,Color(accent.r,accent.g,accent.b,0.35))
        draw_polyline(PackedVector2Array([q[0],q[1],q[2],q[3],q[0]]),accent,2.0,true)
    elif style=="air":
        draw_line(c+Vector2(-48,18),c+Vector2(48,18),Color("#9fb1b8"),5.0,true)
        draw_circle(c+Vector2(sin(t)*30,-6),5,Color("#f8e7a8"))
    elif style=="wind":
        draw_line(c+Vector2(0,32),c+Vector2(0,-36),Color("#9aa7ad"),4.0,true)
        for k in range(3):
            draw_line(c+Vector2(0,-36),c+Vector2(0,-36)+Vector2.from_angle(t+float(k)*TAU/3.0)*28.0,accent,3.0,true)
    elif style=="data":
        draw_rect(Rect2(c-Vector2(32,42),Vector2(64,84)),Color("#202d44"),true)
        for k in range(5):
            draw_line(c+Vector2(-24,-28+float(k)*14),c+Vector2(24,-28+float(k)*14),Color(accent.r,accent.g,accent.b,0.35+0.10*sin(t*2.0+float(k))),2.0,true)
    else:
        draw_arc(c,32,0,TAU,24,accent,3.0,true)
    draw_string(ThemeDB.fallback_font,c+Vector2(-80,58),district.to_upper(),HORIZONTAL_ALIGNMENT_CENTER,160,10,Color(accent.r,accent.g,accent.b,0.78))

func _draw_social_setpieces() -> void:
    for i in range(social_setpieces.size()):
        var s: Dictionary=social_setpieces[i]
        var pos:=Vector2(s.pos)
        if player_pos.distance_to(pos)>1500.0:
            continue
        var kind:=str(s.kind)
        var count:=int(s.count)
        var seed:=int(s.seed)
        var accent: Color=Color(_district_at(pos).get("accent",Color("#9ad5ff")))
        if kind=="transit_wait":
            var arriving:=_transit_stop_has_arrival(int(s.stop_index))
            var stop_data: Dictionary=transit_stops[int(s.stop_index)]
            var vi: int=int(stop_data.vehicle)
            var tv: Dictionary=transit_vehicles[vi] if vi>=0 and vi<transit_vehicles.size() else {}
            count=clampi(int(stop_data.get("waiting",count)),1,8)
            for k in range(count):
                var off:=Vector2(float(k-(count-1)*0.5)*18.0,22.0+float(k%2)*5.0)
                _draw_social_person(pos+off,accent,"wave" if arriving and k==0 else ("phone" if k==count-1 else "idle"),seed+k)
            if arriving and not tv.is_empty():
                var rd=roads[int(tv.road)]
                var vehicle_pos:=_sample_polyline(rd.points,float(tv.t))
                var phase:=clampf(float(tv.get("dwell",0.0))/3.8,0.0,1.0)
                var boarding_count:=mini(2,int(tv.get("board_count",1)))
                var exit_count:=mini(2,int(tv.get("exit_count",1)))
                for k in range(boarding_count):
                    var from:=pos+Vector2(float(k)*14.0-8.0,18.0)
                    var to:=vehicle_pos+Vector2(float(k)*8.0,8.0)
                    _draw_social_person(from.lerp(to,1.0-phase),accent,"walk",seed+70+k)
                for k in range(exit_count):
                    var from:=vehicle_pos+Vector2(float(k)*8.0,8.0)
                    var to:=pos+Vector2(float(k)*15.0+20.0,26.0)
                    _draw_social_person(from.lerp(to,phase),accent,"walk",seed+90+k)
                var p:=_project(pos,5)
                draw_string(ThemeDB.fallback_font,p+Vector2(-80,-42),"EIN %d · AUS %d" % [int(stop_data.get("last_boarded",0)),int(stop_data.get("last_exited",0))],HORIZONTAL_ALIGNMENT_CENTER,160,10,Color("#72d7e6"))
        elif kind=="cafe_cluster":
            var center:=_project(pos,4)
            draw_circle(center,11,Color("#695646"))
            draw_line(center,center+Vector2(0,13),Color("#4c5960"),2.0,true)
            for k in range(count):
                var a:=float(k)*TAU/float(count)
                var off:=Vector2.from_angle(a)*28.0
                _draw_social_person(pos+off,accent,"sit" if k%2==0 else "chat",seed+k)
        elif kind=="corner_queue":
            for k in range(count):
                var off:=Vector2(float(k)*15.0-float(count)*7.5,0)
                _draw_social_person(pos+off,accent,"phone" if k%3==0 else "idle",seed+k)
        elif kind in ["plaza_crowd","market_crowd"]:
            for k in range(count):
                var a:=float(k)*TAU/float(maxi(1,count))
                var radius:=34.0+float(k%3)*12.0
                var off:=Vector2.from_angle(a)*radius
                var state:="chat" if k%3==0 else ("phone" if k%4==0 else "idle")
                _draw_social_person(pos+off,accent,state,seed+k)
            var cp:=_project(pos,5)
            if kind=="market_crowd":
                for k in range(3):
                    var q:=cp+Vector2(float(k-1)*26.0,20)
                    draw_rect(Rect2(q-Vector2(11,5),Vector2(22,10)),Color("#6b4f3d"),true)
                    draw_colored_polygon(PackedVector2Array([q+Vector2(-14,-5),q+Vector2(14,-5),q+Vector2(10,-14),q+Vector2(-10,-14)]),Color(accent.r,accent.g,accent.b,0.62))
        elif kind=="rain_shelter":
            if _weather_state() not in ["rain","storm"]:
                continue
            var sp:=_project(pos,7)
            draw_line(sp+Vector2(-28,8),sp+Vector2(-28,-20),Color("#596970"),2.5,true)
            draw_line(sp+Vector2(28,8),sp+Vector2(28,-20),Color("#596970"),2.5,true)
            draw_line(sp+Vector2(-32,-20),sp+Vector2(32,-20),Color("#7c8d94"),4.0,true)
            draw_colored_polygon(PackedVector2Array([sp+Vector2(-34,-21),sp+Vector2(34,-21),sp+Vector2(26,-30),sp+Vector2(-26,-30)]),Color(accent.r,accent.g,accent.b,0.36))
            for k in range(count):
                var off:=Vector2(float(k-(count-1)*0.5)*16.0,8.0)
                _draw_social_person(pos+off,accent,"phone" if k%2==0 else "idle",seed+k)
        elif kind=="work_shift":
            for k in range(count):
                var off:=Vector2(float(k-(count-1)*0.5)*22.0,0)
                _draw_social_person(pos+off,Color("#f0b84b"),"chat" if k%3==0 else "idle",seed+k)
            var wp:=_project(pos,5)
            draw_line(wp+Vector2(-42,20),wp+Vector2(42,20),Color("#d99a4d"),4.0,true)
        elif kind=="campus_edge":
            for k in range(count):
                var a:=float(k)*TAU/float(maxi(1,count))
                _draw_social_person(pos+Vector2.from_angle(a)*38.0,Color("#8fb8ff"),"phone" if k%2==0 else "chat",seed+k)
            var cp:=_project(pos,4)
            draw_circle(cp,13,Color("#4f735b"))
        elif kind=="nightlife_cluster":
            for k in range(count):
                var off:=Vector2(float(k-(count-1)*0.5)*16.0,sin(float(k))*8.0)
                _draw_social_person(pos+off,Color("#ff80ef"),"chat" if k%2==0 else "idle",seed+k)
            var np:=_project(pos,12)
            draw_circle(np+Vector2(0,-24),18,Color(1.0,0.35,0.82,0.05))
        elif kind=="park_picnic":
            var pp:=_project(pos,2)
            draw_rect(Rect2(pp-Vector2(26,8),Vector2(52,16)),Color("#8fb87b"),true)
            for k in range(count):
                var a:=float(k)*TAU/float(maxi(1,count))
                _draw_social_person(pos+Vector2.from_angle(a)*34.0,Color("#8ff0b4"),"sit",seed+k)
        elif kind=="transfer_hub":
            var hub_id:=str(s.hub_id)
            var lines:=_transit_hub_lines(hub_id)
            for k in range(count):
                var off:=Vector2(float(k-(count-1)*0.5)*16.0,10.0+float(k%2)*7.0)
                _draw_social_person(pos+off,Color("#72d7e6"),"phone" if k%2==0 else "idle",seed+k)
            var hp:=_project(pos,6)
            draw_rect(Rect2(hp-Vector2(48,42),Vector2(96,20)),Color("#17313b"),true)
            draw_string(ThemeDB.fallback_font,hp+Vector2(-42,-39),"↔ %s" % " / ".join(lines),HORIZONTAL_ALIGNMENT_CENTER,84,10,Color("#72d7e6"))
        elif kind=="delivery_loading":
            _draw_loading_scene(s,false)
        elif kind=="dock_loading":
            _draw_loading_scene(s,true)
        elif kind=="district_signature":
            _draw_district_signature_scene(s)

func _draw_response_incidents() -> void:
    for i in range(response_incidents.size()):
        if not _incident_active(i):
            continue
        var incident: Dictionary=response_incidents[i]
        var pos:=Vector2(incident.pos)
        if player_pos.distance_to(pos)>1750.0:
            continue
        var kind:=str(incident.kind)
        var heading:=0.0
        if int(incident.road)>=0 and int(incident.road)<roads.size():
            heading=_polyline_tangent(roads[int(incident.road)].points,0.5).angle()
        var cls:="van" if kind!="utility" else "pickup"
        var color:=Color("#d9e3e7") if kind=="response" else Color("#d9a85e")
        var archetype:="response" if kind=="response" else ("maintenance" if kind=="maintenance" else "service")
        _draw_car(pos,heading,cls,color,true,archetype)
        var f:=Vector2.from_angle(heading)
        var side:=Vector2(-f.y,f.x)
        for k in range(3):
            var cone_pos:=pos-f*(24.0+float(k)*18.0)+side*(18.0 if k%2==0 else -18.0)
            var cp:=_project(cone_pos,5)
            var cone:=PackedVector2Array([cp+Vector2(-5,6),cp+Vector2(5,6),cp+Vector2(2,-7),cp+Vector2(-2,-7)])
            draw_colored_polygon(cone,Color("#e77e36"))
        for k in range(2):
            var worker_pos:=pos+side*(34.0+float(k)*22.0)-f*8.0
            _draw_social_person(worker_pos,Color("#f0b84b"),"idle",i*11+k)
        var pp:=_project(pos,20)
        draw_string(ThemeDB.fallback_font,pp+Vector2(-70,-42),"SERVICE-EINSATZ",HORIZONTAL_ALIGNMENT_CENTER,140,10,Color("#ffcf72"))

func _update_transit_stop_demand() -> void:
    var slot: int=int(floor(world_clock*2.0))
    for si in range(transit_stops.size()):
        var stop: Dictionary=transit_stops[si]
        if int(stop.get("demand_slot",-1))==slot:
            continue
        stop["demand_slot"]=slot
        var pos:=Vector2(stop.pos)
        var style:=str(_district_at(pos).get("style","center"))
        var hour_factor:=1
        if (world_clock>=7.0 and world_clock<=9.5) or (world_clock>=16.0 and world_clock<=19.5):
            hour_factor=2
        var add_waiting: int=1+((si+slot*3)%2)*hour_factor
        if style in ["center","campus","terminal","expo"]:
            add_waiting+=1
        stop["waiting"]=mini(14,int(stop.get("waiting",0))+add_waiting)
        stop["arrivals"]=maxi(0,int(stop.get("arrivals",0))-1)
        transit_stops[si]=stop

func _update_transit(delta: float) -> void:
    _update_transit_stop_demand()
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
                tveh["dwell"]=3.8
                tveh["at_stop"]=true
                var stop_index: int=transit_stops.find(stop)
                tveh["stop_index"]=stop_index
                var stop_data: Dictionary=transit_stops[stop_index]
                var stop_seed: int=int(tveh.get("boarding_seed",7))+stop_index*13
                var exiting: int=mini(1+absi(stop_seed)%4,int(tveh.get("passengers",0)))
                var capacity: int=42 if str(tveh.kind)=="bus" else 58
                var free_seats: int=maxi(0,capacity-(int(tveh.get("passengers",0))-exiting))
                var waiting_now: int=int(stop_data.get("waiting",0))
                var boarding: int=mini(waiting_now,mini(free_seats,2+absi(stop_seed/3)%5))
                tveh["exit_count"]=exiting
                tveh["board_count"]=boarding
                tveh["passengers"]=maxi(0,int(tveh.get("passengers",0))-exiting+boarding)
                stop_data["waiting"]=maxi(0,waiting_now-boarding)
                stop_data["arrivals"]=mini(12,int(stop_data.get("arrivals",0))+exiting)
                stop_data["last_boarded"]=boarding
                stop_data["last_exited"]=exiting
                transit_stops[stop_index]=stop_data
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
        district_banner.text = "%s · %s" % [name,_district_identity_label(str(d.get("style","center")))]
        district_banner.modulate = Color(1,1,1,1)
        var tw := create_tween()
        tw.tween_interval(1.15)
        tw.tween_property(district_banner, "modulate:a", 0.0, 0.70)

func _district_identity_label(style: String) -> String:
    var labels := {
        "heritage":"HERITAGE CORE",
        "culture":"CULTURE LOOP",
        "glass":"GLASS CANYON",
        "green":"BIO URBAN",
        "solar":"SOLAR RIDGE",
        "canal":"WATERSIDE",
        "center":"CITY CORE",
        "harbor":"HARBOR LIFE",
        "industry":"INDUSTRIAL GRID",
        "terminal":"TRANSIT NODE",
        "garden":"GARDEN CITY",
        "campus":"CAMPUS WALK",
        "astro":"NIGHT SKY",
        "ring":"OUTER LOOP",
        "neon":"NIGHT DISTRICT",
        "expo":"EXPO AXIS",
        "air":"OPEN SKY",
        "wind":"WIND PARK",
        "data":"DATA GRID",
        "coast":"COAST WALK",
        "rail":"RAIL WORKS"
    }
    return str(labels.get(style,"MEGACITY"))

func _update_ui() -> void:
    _sync_modal_ui()
    if photo_mode:
        objective_label.visible=false
        mission_label.text="PHOTO CHALLENGE"
        detail_label.text="Position fixiert · Kamera drehen, zoomen und versteckte Motive fotografieren."
        status_label.text="3D FOTO-MODUS · Bewegung gesperrt · Kamera aktiv"
        interact_button.disabled=true
        scan_button.disabled=true
        return
    scan_button.disabled=false
    objective_label.visible=not (main_menu_active or map_open or missions_open or collection_open or minigame_open or dialogue_panel.visible or commerce_panel.visible)
    var target:=_current_objective_pos()
    var objective_distance: int=int(player_pos.distance_to(target)/10) if target!=Vector2.ZERO else 0
    objective_label.text=("%s · %d m\n%s" % [_current_objective_label(),objective_distance,_objective_action()]) if target!=Vector2.ZERO else "Die Stadt gehört dir · neue Aufträge und Motive entdecken"
    interior_exit_button.visible=interior_active
    recenter_hud_button.visible=not interior_active
    scan_button.visible=not interior_active
    if interior_active:
        objective_label.text={"bar":"Zum markierten Tresen gehen und BESTELLEN","cafe":"Kaffee und Gebäck am markierten Tresen bestellen","restaurant":"Zur Küche gehen und BESTELLEN","home":"Hausgarage am Terminal öffnen · Treppe zur zweiten Etage","shop":"Zur Kasse gehen und EINKAUFEN","garage":"Am Diagnose-Terminal SERVICE wählen","workshop":"Am Diagnose-Terminal SERVICE wählen","hospital":"Zur Triage gehen und Energie auffüllen","openai_hq":"Die markierte Ausstellung erkunden","roof":"Zum leuchtenden Dach-Relay gehen und SYNCHRONISIEREN","sublevel":"Zum Terminal gehen und den Knoten AKTIVIEREN"}.get(interior_kind,"Den markierten Punkt erkunden")
    if tracking_label!=null:
        tracking_label.text=("KOPF · "+camera_tracking_state) if camera_tracking_enabled else "PERSPEKTIVE · Touch / Neigung"
        tracking_label.modulate=Color("#73f3ce") if camera_tracking_state=="Gesicht erkannt" and camera_tracking_enabled else Color("#9cb9c4")
    var chapter: Dictionary = Dictionary(native_chapters[mini(native_chapter,native_chapters.size()-1)]) if native_chapters.size()>0 else {"title":"Explore","desc":""}
    mission_label.text = "%s · %d/%d" % [str(chapter.title),mini(_chapter_progress(chapter),int(chapter.get("goal",1))),int(chapter.get("goal",1))]
    mission_progress_bar.max_value=maxf(1,float(chapter.get("goal",1)))
    mission_progress_bar.value=minf(_chapter_progress(chapter),mission_progress_bar.max_value)
    mission_progress_bar.visible=not interior_active
    if interior_active: mission_label.text=InteriorArt.title(interior_kind,interior_floor)+" · "+interior_name
    if interior_active:
        detail_label.text = "%s · %s" % [interior_name,_interior_feature_message()]
    elif not active_job.is_empty():
        var job_target := Vector2(active_job.get("target",Vector2.ZERO))
        var job_distance := int(player_pos.distance_to(job_target)/10.0) if job_target!=Vector2.ZERO else 0
        var task_text:=str(active_job.get("task",""))
        detail_label.text = "Stadtauftrag: %s · %d CR · Ziel %d m%s · Kompass aktiv." % [str(active_job.get("title","Auftrag")),int(active_job.get("pay",0)),job_distance,(" · "+task_text if task_text!="" else "")]
    else:
        detail_label.text = "Links Richtung wählen · rechts Perspektive · loslassen bremst das Auto."
    var mode: String = "Etage %d" % (interior_floor+1) if interior_active else "Zu Fuß"
    if current_vehicle >= 0:
        var drive_cls: String = str(parked_cars[current_vehicle]["class"])
        var group: String = str(VEHICLE_SPEED_GROUP.get(drive_cls,"ROAD"))
        var speed_kmh: int = int(abs(vehicle_velocity)*0.42)
        mode = "%s · %s · %d km/h" % [drive_cls.capitalize(),group,speed_kmh]
    elif transit_riding >= 0 and transit_riding < transit_vehicles.size():
        mode = "Transit · %s" % str(transit_vehicles[transit_riding].line)
    var clock_h := int(floor(world_clock))
    var clock_m := int(floor((world_clock-float(clock_h))*60.0))
    status_label.text = "%s · %s · %02d:%02d · %s\n%d CR · Energie %d%% · Stadtruf %d" % [(interior_name if interior_active else current_district),mode,clock_h,clock_m,_weather_label(),credits,int(energy),city_reputation]
    var near := _nearest_interactable()
    interact_button.disabled = near.is_empty()
    interact_button.text = "AKTION" if near.is_empty() else _localized_action(str(near.get("action","AKTION")))

func _scan() -> void:
    if _modal_active() or photo_mode or interior_active: return
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
    if map_open or missions_open or collection_open or minigame_open or dialogue_panel.visible or commerce_panel.visible:
        return
    var n := _nearest_interactable()
    if n.is_empty():
        return
    if n.type == "race":
        _start_race(int(n.index))
    elif n.type == "micro_event":
        _join_micro_event(int(n.index))
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
    elif n.type == "hospital":
        _enter_interior("Parallax Stadtklinikum","hospital",Color("#8fe7d7"),player_pos)
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
            var ride_stop_index:=int(tv.get("stop_index",-1))
            var ride_stop: Dictionary=transit_stops[ride_stop_index] if ride_stop_index>=0 and ride_stop_index<transit_stops.size() else {}
            var ride_hub:=str(ride_stop.get("transfer_hub",""))
            return {"type":"transit","index":transit_riding,"action":"AUSSTEIGEN / UMSTEIGEN" if ride_hub!="" else "AUSSTEIGEN"}
        return {}
    if interior_active:
        var exit_pos := Vector2(interior_size.x*0.5,interior_size.y-48)
        if interior_player_pos.distance_to(exit_pos) < 78.0:
            return {"type":"interior_exit","action":"EXIT"}
        if interior_kind in ["openai_hq","home","shop","restaurant","cafe","bar","hospital"] and interior_player_pos.distance_to(_interior_elevator_pos())<78.0:
            return {"type":"interior_floor","action":"ETAGE %d" % (2 if interior_floor==0 else 1)}
        var feature := _interior_feature_pos()
        if interior_player_pos.distance_to(feature) < 82.0:
            return {"type":"interior_feature","action":{"bar":"BESTELLEN","restaurant":"BESTELLEN","cafe":"BESTELLEN","shop":"EINKAUFEN","home":"HAUSGARAGE","garage":"SERVICE","workshop":"SERVICE","roof":"SYNCHRONISIEREN","sublevel":"AKTIVIEREN","hospital":"HEILEN"}.get(interior_kind,"BENUTZEN"),"message":_interior_feature_message()}
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
    for ei in range(city_micro_events.size()):
        var event: Dictionary = city_micro_events[ei]
        if not _micro_event_active(ei,event):
            continue
        var de: float = player_pos.distance_to(Vector2(event.pos))
        if de<118.0 and de<bd:
            var seen := bool(micro_event_seen.get(str(event.label),false))
            best={"type":"micro_event","index":ei,"action":"NOCHMAL MITMACHEN" if seen else "MITMACHEN"}
            bd=de
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
        var dphoto: float = player_pos.distance_to(Vector2(photo_points[pi].pos))
        if dphoto < 150.0 and dphoto < bd:
            best = {"type":"photo","index":pi,"action":"PHOTO REPLAY" if bool(photo_points[pi].taken) else "PHOTO CHALLENGE"}
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
            var ti_stop:=int(tv.get("stop_index",-1))
            var ti_stop_data: Dictionary=transit_stops[ti_stop] if ti_stop>=0 and ti_stop<transit_stops.size() else {}
            var ti_hub:=str(ti_stop_data.get("transfer_hub",""))
            var transfer_now:=ti_hub!="" and ti_hub==last_transit_exit_hub and str(tv.line)!=last_transit_exit_line and float(Time.get_ticks_msec())/1000.0-last_transit_exit_time<=120.0
            best = {"type":"transit","index":ti,"action":("UMSTEIGEN %s" if transfer_now else "EINSTEIGEN %s") % str(tv.line)}
            bd = dt
    if not active_job.is_empty() and str(active_job.get("kind","delivery")) in ["delivery","event_followup"]:
        var target_pos: Vector2 = Vector2(active_job.get("target",Vector2.ZERO))
        var djob: float = player_pos.distance_to(target_pos)
        if djob < 115.0 and djob < bd:
            var action:="ÜBERGEBEN" if str(active_job.get("kind",""))=="event_followup" else "DELIVER"
            best = {"type":"job_target","action":action}
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
        if str(l.kind) in ["openai_hq","hospital"]:
            var entrance: Vector2 = Vector2(l.pos) + Vector2(0,float(l.size.y)*0.5+48.0)
            var dl := player_pos.distance_to(entrance)
            if dl < 105.0 and dl < bd:
                if str(l.kind)=="hospital":
                    best = {"type":"hospital","action":"STADTKLINIKUM"}
                else:
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
        if interior_kind=="roof": _draw_ambient_overlay()
        if not _modal_active():
            _draw_touch_controls()
            _draw_peek_meter()
        return
    _draw_district_ground()
    _draw_water()
    _draw_parks()
    _draw_roads()
    CityArt.draw_street_pools(self)
    _draw_vertical_slice_road_materials()
    _draw_buildings()
    _draw_landmarks()
    _draw_trees()
    _draw_vegetation_props()
    CityArt.draw_street_ensembles(self)
    _draw_storefronts()
    _draw_vertical_slice_architecture()
    _draw_named_npcs()
    _draw_story_collectibles()
    _draw_scan_points()
    _draw_photo_points()
    _draw_race_markers()
    _draw_transit_stops()
    _draw_jobboards()
    _draw_active_job_target()
    _draw_street_props()
    _draw_city_micro_events()
    _draw_social_setpieces()
    _draw_response_incidents()
    _draw_traffic_accidents()
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
    if not _modal_active():
        _draw_touch_controls()
        _draw_peek_meter()
        _draw_mission_compass()
    if hospital_transition>0.0:
        _draw_hospital_cutscene()

func _tile_visible(p: Vector2, margin: float = 90.0) -> bool:
    var s:=get_viewport_rect().size
    return p.x>-margin and p.y>-margin and p.x<s.x+margin and p.y<s.y+margin

func _draw_district_tile_pattern(d: Dictionary) -> void:
    var r: Rect2=d.rect
    var style:=str(d.style)
    var accent: Color=Color(d.accent)
    var step_world:=280.0
    if style in ["heritage","campus","culture"]:
        step_world=220.0
    elif style in ["industry","harbor","rail","terminal"]:
        step_world=320.0
    var cols:=int(ceil(r.size.x/step_world))
    var rows:=int(ceil(r.size.y/step_world))
    var tile_px:=step_world*world_zoom
    for gx in range(cols):
        for gy in range(rows):
            var wp:=r.position+Vector2((float(gx)+0.5)*step_world,(float(gy)+0.5)*step_world)
            var p:=_project(wp,0)
            if not _tile_visible(p,tile_px*0.55):
                continue
            if style=="heritage":
                var w:=tile_px*0.42
                var h:=tile_px*0.18
                var stagger:=w*0.48 if gy%2==1 else 0.0
                draw_rect(Rect2(p-Vector2(w*0.5-stagger,h*0.5),Vector2(w,h)),Color(0.56,0.49,0.42,0.055),false,maxf(1.0,world_zoom*0.75))
                draw_line(p+Vector2(-w*0.45,h*0.05),p+Vector2(w*0.45,h*0.05),Color(0.92,0.82,0.68,0.035),1.0,true)
            elif style in ["culture","campus"]:
                var sq:=tile_px*0.34
                draw_rect(Rect2(p-Vector2(sq*0.5,sq*0.5),Vector2(sq,sq)),Color(accent.r,accent.g,accent.b,0.035),false,maxf(1.0,world_zoom*0.65))
                if (gx+gy)%3==0:
                    draw_circle(p,3.0*clampf(world_zoom,0.8,1.8),Color(accent.r,accent.g,accent.b,0.16))
            elif style in ["glass","center","neon","expo","data"]:
                var slab:=tile_px*0.72
                draw_rect(Rect2(p-Vector2(slab*0.5,slab*0.5),Vector2(slab,slab)),Color(0.68,0.83,0.88,0.025),false,maxf(1.0,world_zoom*0.55))
                if (gx*3+gy)%4==0:
                    draw_line(p-Vector2(slab*0.38,0),p+Vector2(slab*0.38,0),Color(accent.r,accent.g,accent.b,0.055),2.0,true)
                    draw_circle(p+Vector2(slab*0.28,0),2.4*clampf(world_zoom,0.8,1.7),Color(accent.r,accent.g,accent.b,0.28))
            elif style in ["green","garden"]:
                var patch:=tile_px*0.28
                draw_circle(p,patch*0.38,Color(0.30,0.55,0.31,0.040))
                draw_circle(p+Vector2(patch*0.28,-patch*0.15),patch*0.17,Color(0.49,0.72,0.42,0.035))
            elif style in ["canal","coast"]:
                var plank:=tile_px*0.70
                draw_line(p-Vector2(plank*0.5,0),p+Vector2(plank*0.5,0),Color(0.74,0.71,0.62,0.050),2.0,true)
                draw_line(p+Vector2(-plank*0.20,-8),p+Vector2(-plank*0.20,8),Color(0.45,0.47,0.45,0.045),1.0,true)
                draw_line(p+Vector2(plank*0.20,-8),p+Vector2(plank*0.20,8),Color(0.45,0.47,0.45,0.045),1.0,true)
            elif style in ["industry","harbor","rail","terminal"]:
                var slab:=tile_px*0.62
                draw_rect(Rect2(p-Vector2(slab*0.5,slab*0.34),Vector2(slab,slab*0.68)),Color(0.68,0.66,0.60,0.032),false,maxf(1.0,world_zoom*0.55))
                if (gx+gy)%4==0:
                    draw_line(p+Vector2(-slab*0.25,slab*0.24),p+Vector2(-slab*0.05,slab*0.04),Color(0.92,0.67,0.26,0.11),3.0,true)
                    draw_line(p+Vector2(0,slab*0.24),p+Vector2(slab*0.20,slab*0.04),Color(0.92,0.67,0.26,0.11),3.0,true)
            elif style in ["solar","wind","air"]:
                var slab:=tile_px*0.64
                draw_line(p-Vector2(slab*0.5,0),p+Vector2(slab*0.5,0),Color(accent.r,accent.g,accent.b,0.050),2.0,true)
                draw_line(p-Vector2(0,slab*0.28),p+Vector2(0,slab*0.28),Color(0.85,0.90,0.90,0.030),1.0,true)
            else:
                draw_circle(p,2.2*clampf(world_zoom,0.8,1.8),Color(accent.r,accent.g,accent.b,0.10))

func _draw_sidewalk_tiles(road: Dictionary) -> void:
    var pts: PackedVector2Array=road.points
    var scale:=clampf(world_zoom,0.78,1.65)
    for k in range(3,98,4):
        var t:=float(k)/100.0
        var wp:=_sample_polyline(pts,t)
        var tan:=_polyline_tangent(pts,t)
        var normal:=Vector2(-tan.y,tan.x)
        var edge_world:=float(road.width)*0.5+13.0
        for side_sign in [-1.0,1.0]:
            var edge:=_project(wp+normal*edge_world*float(side_sign),0.6)
            var half:=tan*9.0*scale
            draw_line(edge-half,edge+half,Color(0.78,0.82,0.82,0.16),1.2*scale,true)
            if k%12==3:
                draw_circle(edge,2.2*scale,Color(0.92,0.78,0.44,0.24))

func _in_visual_slice(world_pos: Vector2, margin: float = 0.0) -> bool:
    return VISUAL_SLICE_RECT.grow(margin).has_point(world_pos)

func _draw_rotated_texture(texture: Texture2D, center: Vector2, size: Vector2, angle: float, modulate: Color = Color.WHITE) -> void:
    draw_set_transform(center,angle,Vector2.ONE)
    draw_texture_rect(texture,Rect2(-size*0.5,size),false,modulate)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_vertical_slice_road_materials() -> void:
    # Material now belongs to the road bed pass, below lane paint.
    pass

func _draw_vertical_slice_architecture() -> void:
    if not _world_rect_visible(VISUAL_SLICE_RECT.grow(400.0)):
        return
    var quality_step:=1 if graphics_quality>=2 else 2
    # Rooftop mechanical modules and stronger comic roof clutter.
    var roof_index:=0
    for b in buildings:
        var center_world: Vector2=Rect2(b.rect).get_center()
        if not _in_visual_slice(center_world,120.0):
            continue
        if roof_index%quality_step==0 and (int(b.seed)&3)!=0:
            var roof_screen:=_project(center_world,float(b.height)+3.0)
            var scale:=clampf(world_zoom*0.42,0.56,1.12)
            var module_size:=Vector2(86,59)*scale
            draw_texture_rect(VS_ROOF_DETAIL,Rect2(roof_screen-module_size*0.5,module_size),false,Color(1,1,1,0.78))
        if str(b.style) in ["center","glass","culture"] and (int(b.seed)&5)==1:
            var facade_world:=Vector2(b.rect.get_center().x,b.rect.end.y+7.0)
            var sign_pos:=_project(facade_world,float(b.height)*0.28)
            var sign_scale:=clampf(world_zoom*0.33,0.48,0.92)
            var sign_size:=Vector2(92,55)*sign_scale
            draw_texture_rect(VS_NEON_SIGN,Rect2(sign_pos-sign_size*0.5,sign_size),false,Color(1,1,1,0.82))
            draw_circle(sign_pos,sign_size.x*0.42,Color(1.0,0.22,0.72,0.018))
        roof_index+=1

    # Palm-lined boulevard modules inspired by dense warm-climate city streets.
    var palm_positions: Array=[
        Vector2(5520,4140),Vector2(5840,4140),Vector2(6180,4140),Vector2(6510,4140),
        Vector2(6860,4140),Vector2(7210,4140),Vector2(7560,4140),Vector2(7920,4140),
        Vector2(5520,5710),Vector2(5880,5710),Vector2(6250,5710),Vector2(6620,5710),
        Vector2(7000,5710),Vector2(7380,5710),Vector2(7760,5710),Vector2(8140,5710)
    ]
    for i in range(0,palm_positions.size(),quality_step):
        var wp:=Vector2(palm_positions[i])
        if player_pos.distance_to(wp)>1850.0 or _point_on_road(wp) or _point_in_building(wp):
            continue
        var base:=_project(wp,0.0)
        var scale:=clampf(world_zoom*0.34,0.48,0.96)
        var size:=Vector2(80,111)*scale
        draw_texture_rect(VS_PALM,Rect2(base+Vector2(-size.x*0.5,-size.y+8.0),size),false,Color(1,1,1,0.96))
        draw_circle(base+Vector2(4,7),size.x*0.28,Color(0,0,0,0.11))

    # Dense street-corner visual anchors: warm pools, neon signs and planter islands.
    var corner_positions: Array=[
        Vector2(5660,4480),Vector2(6450,4480),Vector2(7240,4480),Vector2(8030,4480),
        Vector2(5660,5360),Vector2(6450,5360),Vector2(7240,5360),Vector2(8030,5360)
    ]
    for i in range(0,corner_positions.size(),quality_step):
        var cp_world:=Vector2(corner_positions[i])
        if player_pos.distance_to(cp_world)>1900.0 or _point_on_road(cp_world) or _point_in_building(cp_world):
            continue
        var cp:=_project(cp_world,5.0)
        var glow:=0.55+0.45*sin(float(Time.get_ticks_msec())/420.0+float(i))
        draw_circle(cp,24.0*clampf(world_zoom,0.8,1.6),Color(1.0,0.54,0.18,0.018+glow*0.012))
        draw_rect(Rect2(cp-Vector2(15,7),Vector2(30,14)),Color("#4b3e35"),true)
        draw_circle(cp+Vector2(-8,-10),8,Color("#3d7d4c"))
        draw_circle(cp+Vector2(6,-12),10,Color("#4e9558"))
        if i%2==0:
            var sign_size:=Vector2(68,41)*clampf(world_zoom*0.28,0.42,0.72)
            draw_texture_rect(VS_NEON_SIGN,Rect2(cp+Vector2(18,-54)-sign_size*0.5,sign_size),false,Color(1,1,1,0.76))

    # Architectural dark ink line around the visual slice for a comic-render read.
    var slice_corners: Array=[
        VISUAL_SLICE_RECT.position,
        Vector2(VISUAL_SLICE_RECT.end.x,VISUAL_SLICE_RECT.position.y),
        VISUAL_SLICE_RECT.end,
        Vector2(VISUAL_SLICE_RECT.position.x,VISUAL_SLICE_RECT.end.y)
    ]
    var screen_poly:=PackedVector2Array()
    for q in slice_corners:
        screen_poly.append(_project(Vector2(q),0.0))
    draw_polyline(PackedVector2Array([screen_poly[0],screen_poly[1],screen_poly[2],screen_poly[3],screen_poly[0]]),Color(0.05,0.06,0.08,0.12),2.2,true)

func _draw_district_ground() -> void:
    for d in districts:
        var r: Rect2 = d.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        draw_rect(Rect2(p,r.size*world_zoom),Color(d.ground).lightened(0.10))
        CityArt.draw_pavers(self,d)
        _draw_district_tile_pattern(d)
        var accent: Color = d.accent
        accent.a = 0.06
        var style: String = str(d.style)
        var night_factor:=1.0-clampf(sin((world_clock-6.0)/24.0*TAU)*0.5+0.5,0.0,1.0)
        var wet_ground:=_weather_state() in ["rain","storm"]

        if style in ["glass","center","neon"]:
            for x in range(int(r.position.x)+100, int(r.end.x), 280):
                var a := _project(Vector2(x,r.position.y))
                var b := _project(Vector2(x,r.end.y))
                draw_line(a,b,accent,2.0)
            for y in range(int(r.position.y)+180,int(r.end.y),420):
                draw_line(_project(Vector2(r.position.x,y)),_project(Vector2(r.end.x,y)),Color(accent.r,accent.g,accent.b,0.035),1.0)
            if night_factor>0.25:
                for i in range(8):
                    var glow_pos:=_project(r.position+Vector2(260+(i*607)%4600,360+(i*911)%2900))
                    draw_circle(glow_pos,16+float(i%3)*6,Color(d.accent.r,d.accent.g,d.accent.b,0.012+night_factor*0.020))
                    if wet_ground:
                        draw_line(glow_pos,glow_pos+Vector2(0,34+float(i%4)*7),Color(d.accent.r,d.accent.g,d.accent.b,0.025+night_factor*0.025),5.0,true)

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
                for hz in range(3):
                    var hx:=q+Vector2(-32+float(hz)*30.0,34)
                    draw_line(hx+Vector2(-8,5),hx+Vector2(8,-5),Color("#d8a84c",0.10),2.0,true)

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
        draw_rect(Rect2(p-Vector2(12,12)*world_zoom,(r.size+Vector2(24,24))*world_zoom),Color("#50636b"))
        draw_rect(Rect2(p,r.size*world_zoom),tint.darkened(0.18))
        draw_rect(Rect2(p,r.size*world_zoom),Color("#8a9b99"),false,3*world_zoom)
        var shimmer := Time.get_ticks_msec() / 900.0
        for yy in range(26,int(r.size.y*world_zoom)-20,54):
            var y := p.y + yy
            var phase := shimmer + float(yy) * 0.025
            var start := p.x + 18 + sin(phase) * 12
            draw_line(Vector2(start,y),Vector2(p.x+r.size.x*world_zoom-20,y+sin(phase*1.7)*4),Color(tint.r+0.12,tint.g+0.18,tint.b+0.22,0.24),2.0,true)
        draw_rect(Rect2(p+Vector2(3,3),r.size*world_zoom-Vector2(6,6)),Color(0.55,0.85,1.0,0.10),false,3.0)

func _draw_roads() -> void:
    CityArt.draw_roads(self)

func _draw_road_surface_details(road: Dictionary) -> void:
    if graphics_quality<=0:
        return
    var pts: PackedVector2Array = road.points
    var weather:=_weather_state()
    var wet:=weather in ["rain","storm"]
    var dark:=world_clock>18.0 or world_clock<6.5
    var step: int = 19 if graphics_quality==1 else 13
    for k in range(9,96,step):
        var t := float(k)/100.0
        var wp := _sample_polyline(pts,t)
        if player_pos.distance_to(wp)>1900.0:
            continue
        var tan := _polyline_tangent(pts,t)
        var normal := Vector2(-tan.y,tan.x)
        var detail := _project(wp+normal*float(road.width)*0.17,1.2)
        var variant := (k+int(road.width))%4
        if variant==0:
            draw_circle(detail,8.0,Color(0.08,0.11,0.13,0.52))
            draw_arc(detail,6.5,0,TAU,14,Color(0.62,0.68,0.70,0.22),1.2,true)
            draw_line(detail-tan*4.5,detail+tan*4.5,Color(0.55,0.60,0.62,0.18),1.0)
        elif variant==1:
            draw_line(detail-normal*8.0,detail+normal*8.0,Color(0.05,0.07,0.08,0.36),4.0,true)
            for g in [-5.0,0.0,5.0]:
                draw_line(detail-normal*7.0+tan*g,detail+normal*7.0+tan*g,Color(0.52,0.58,0.60,0.14),1.0)
        elif variant==2:
            var patch := PackedVector2Array([detail+Vector2(-10,-5),detail+Vector2(7,-8),detail+Vector2(12,4),detail+Vector2(-6,8)])
            draw_colored_polygon(patch,Color(0.08,0.10,0.11,0.24))
        else:
            var edge := _project(wp-normal*float(road.width)*0.40,1.0)
            draw_circle(edge,2.2,Color(0.90,0.78,0.48,0.40))
        if dark:
            var stud:=_project(wp-normal*float(road.width)*0.34,1.1)
            draw_circle(stud,2.0,Color(0.96,0.82,0.48,0.34 if not wet else 0.52))
            if wet:
                draw_circle(stud,5.0,Color(1.0,0.78,0.42,0.035))
        if wet and (k+int(road.width))%3==0:
            var puddle_center:=_project(wp+normal*float(road.width)*0.27,0.9)
            var puddle_w:=16.0+float(k%5)*3.0
            _draw_poly_ellipse(puddle_center,Vector2(puddle_w,5.0+float(k%3)),tan.angle(),Color(0.42,0.66,0.76,0.055))
            draw_line(puddle_center-tan*puddle_w*0.55,puddle_center+tan*puddle_w*0.55,Color(0.78,0.90,0.94,0.055),1.0,true)

func _draw_junction_overlays() -> void:
    for junction in junctions:
        if player_pos.distance_to(Vector2(junction.pos))<1900:
            CityArt.draw_junction(self,junction)

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
        if _world_rect_visible(Rect2(b.rect).grow(float(b.height)+100)):
            CityArt.draw_building(self,b)

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
    var daylight := clampf(sin((world_clock-6.0)/24.0*TAU)*0.5+0.5,0.0,1.0)
    var night_factor := 1.0-daylight
    var wet_facade:=_weather_state() in ["rain","storm"]
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
            var pane_color: Color = window_color
            if (int(b.seed)+row*11+col*17+edge*5)%5==0:
                pane_color=Color(1.0,0.78,0.43,0.18+night_factor*0.52)
            if facade == "striped":
                draw_line(center-along,center+along,pane_color,2.8)
            elif facade == "balconies":
                var balcony_color := Color(pane_color.r,pane_color.g,pane_color.b,0.10+night_factor*0.08)
                var bp := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(bp,balcony_color)
                draw_line(center-along*1.15+up,center+along*1.15+up,Color(1,1,1,0.12),1.1)
            elif facade == "grid":
                var gp := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(gp,pane_color)
                draw_line(center-up,center+up,Color(0.88,0.96,1.0,0.12),1.0)
                draw_line(center-along,center+along,Color(0.88,0.96,1.0,0.10),1.0)
            elif facade == "arches":
                var ap := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(ap,pane_color)
                draw_arc(center-up*0.55,along.length()*0.62,PI,TAU,10,Color(pane_color.r,pane_color.g,pane_color.b,0.72),1.3,true)
            elif facade == "ribs":
                draw_line(center-up*1.2,center+up*1.2,pane_color,3.0)
            elif facade == "living":
                var lp := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(lp,pane_color)
                draw_line(center-along*0.95+up*1.25,center+along*0.95+up*1.25,Color(0.38,0.75,0.43,0.48),2.4)
            else:
                var wpoly := PackedVector2Array([center-along-up,center+along-up,center+along+up,center-along+up])
                draw_colored_polygon(wpoly,pane_color)
                if facade == "mixed" and (row+col+edge+int(b.seed)) % 3 == 0:
                    draw_line(center-along*0.8,center+along*0.8,Color(1,1,1,0.12),1.0)
    if facade=="ribs":
        for u_i in range(1,6):
            var uu := float(u_i)/6.0
            draw_line(a.lerp(bb,uu),d.lerp(c,uu),Color(b.accent.r,b.accent.g,b.accent.b,0.16),2.2)
    if b.style == "heritage":
        var sill := a.lerp(d,0.18)
        draw_line(sill,bb.lerp(c,0.18),Color("#e5b889"),2.0)
        draw_line(a.lerp(d,0.72),bb.lerp(c,0.72),Color(0.95,0.76,0.58,0.11),2.0)
    elif b.style in ["glass","center"]:
        for u_i in range(1,4):
            var uu := float(u_i)/4.0
            draw_line(a.lerp(bb,uu),d.lerp(c,uu),Color(0.65,0.90,1.0,0.10+face_alpha*0.08),1.5)
        if night_factor>0.35:
            draw_line(a.lerp(d,0.42),bb.lerp(c,0.42),Color(0.42,0.82,1.0,0.08+night_factor*0.12),2.0)
    elif b.style == "neon":
        var pulse := 0.70+0.30*sin(Time.get_ticks_msec()/520.0+float(int(b.seed)%31))
        draw_line(a.lerp(d,0.55),bb.lerp(c,0.55),Color(b.accent.r,b.accent.g,b.accent.b,0.40+0.22*pulse),2.5)
    elif b.style in ["green","garden"]:
        draw_line(a.lerp(d,0.32),bb.lerp(c,0.32),Color(0.48,0.83,0.55,0.34),3.0)
    if wet_facade and b.style in ["glass","center","neon","terminal","expo"]:
        for sheen_i in range(1,4):
            var u:=float(sheen_i)/4.0
            var p0:=a.lerp(bb,u)
            var p1:=d.lerp(c,u)
            draw_line(p0.lerp(p1,0.08),p0.lerp(p1,0.92),Color(0.72,0.90,1.0,0.035+night_factor*0.025),1.2,true)
    if night_factor>0.38 and b.style in ["center","neon","terminal","culture","expo"]:
        var sign_center:=a.lerp(bb,0.50).lerp(d.lerp(c,0.50),0.22)
        var sign_half:=minf(28.0,face_len*0.14)
        var sign_pulse:=0.72+0.28*sin(float(Time.get_ticks_msec())/410.0+float(int(b.seed)%23))
        draw_line(sign_center-(bb-a).normalized()*sign_half,sign_center+(bb-a).normalized()*sign_half,Color(b.accent.r,b.accent.g,b.accent.b,0.20+sign_pulse*0.18),3.0,true)

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
    if roof_mode == "antenna":
        draw_line(center,center+Vector2(0,-34),Color("#b8c7cd"),2.2,true)
        draw_line(center+Vector2(0,-18),center+Vector2(13,-12),Color(b.accent.r,b.accent.g,b.accent.b,0.48),1.5,true)
        draw_circle(center+Vector2(0,-35),3.0,Color(b.accent.r,b.accent.g,b.accent.b,0.72))
    elif roof_mode == "terrace":
        draw_rect(Rect2(center-Vector2(21,12),Vector2(42,24)),Color(0.08,0.13,0.15,0.42),true)
        draw_rect(Rect2(center-Vector2(21,12),Vector2(42,24)),Color(1,1,1,0.12),false,1.2)
        draw_circle(center+Vector2(-11,0),5,Color(0.31,0.62,0.38,0.78))
        draw_circle(center+Vector2(12,2),4,Color(0.42,0.70,0.43,0.70))
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
        elif kind == "hospital":
            _draw_landmark_hospital(base,top,accent,l.size)
        else:
            _draw_landmark_terminal(base,top,accent)
        draw_string(ThemeDB.fallback_font,base+Vector2(-110,52),str(l.name),HORIZONTAL_ALIGNMENT_CENTER,220,16,Color(0.93,0.98,1.0,0.80))

func _draw_landmark_hospital(base: Vector2, top: Vector2, accent: Color, size: Vector2) -> void:
    var body:=PackedVector2Array([base+Vector2(-110,34),base+Vector2(110,34),top+Vector2(82,14),top+Vector2(-82,14)])
    draw_colored_polygon(body,Color("#d5e2e3"))
    draw_polyline(PackedVector2Array([body[0],body[1],body[2],body[3],body[0]]),Color(accent.r,accent.g,accent.b,0.72),2.2,true)
    for row in range(1,5):
        var yy:=lerpf(top.y+30.0,base.y+12.0,float(row)/5.0)
        for col in range(-3,4):
            var x:=base.x+float(col)*24.0
            draw_rect(Rect2(Vector2(x-7,yy-5),Vector2(14,10)),Color("#6fa6b1"),true)
    draw_rect(Rect2(base+Vector2(-38,14),Vector2(76,38)),Color("#24434a"),true)
    draw_rect(Rect2(base+Vector2(-38,14),Vector2(76,38)),accent,false,2.0)
    draw_rect(Rect2(top+Vector2(-28,-10),Vector2(56,22)),Color("#f2f7f7"),true)
    draw_rect(Rect2(top+Vector2(-5,-23),Vector2(10,48)),Color("#3abf9f"),true)
    draw_rect(Rect2(top+Vector2(-19,-9),Vector2(38,10)),Color("#3abf9f"),true)
    draw_string(ThemeDB.fallback_font,base+Vector2(-80,58),"NOTAUFNAHME",HORIZONTAL_ALIGNMENT_CENTER,160,12,Color("#dffbf4"))
    var ambulance_bay:=base+Vector2(145,30)
    draw_rect(Rect2(ambulance_bay-Vector2(38,16),Vector2(76,32)),Color(0.08,0.14,0.16,0.90),true)
    draw_rect(Rect2(ambulance_bay-Vector2(38,16),Vector2(76,32)),accent,false,1.5)
    draw_string(ThemeDB.fallback_font,ambulance_bay+Vector2(-30,-7),"RETTUNG",HORIZONTAL_ALIGNMENT_CENTER,60,10,Color.WHITE)

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
        var slice_store:=_in_visual_slice(Vector2(st.pos),120.0)
        var store_scale:=clampf(pow(world_zoom,0.26),0.95,1.24) if slice_store else 1.0
        var store_half:=Vector2(30,13)*store_scale
        draw_rect(Rect2(c-store_half,store_half*2.0),Color(0.025,0.055,0.07,0.94),true)
        draw_rect(Rect2(c-store_half,store_half*2.0),Color(accent.r,accent.g,accent.b,0.70),false,2.0*store_scale)
        if slice_store:
            draw_rect(Rect2(c+Vector2(-store_half.x+5,store_half.y+3),Vector2(store_half.x*2.0-10,9*store_scale)),Color(accent.r,accent.g,accent.b,0.18),true)
            draw_circle(c+Vector2(0,store_half.y+10),26*store_scale,Color(accent.r,accent.g,accent.b,0.015))
        var icon := "B" if st.kind=="bar" else ("R" if st.kind=="restaurant" else ("C" if st.kind=="cafe" else ("S" if st.kind=="shop" else ("G" if st.kind=="garage" else "W"))))
        draw_circle(c+Vector2(-20,0),7,accent)
        draw_string(ThemeDB.fallback_font,c+Vector2(-23,-5),icon,HORIZONTAL_ALIGNMENT_CENTER,8,9,Color("#102028"))
        draw_string(ThemeDB.fallback_font,c+Vector2(-10,-5),str(st.name),HORIZONTAL_ALIGNMENT_LEFT,52,9,Color.WHITE)
        if st.kind in ["garage","workshop"]:
            draw_line(c+Vector2(-18,13),c+Vector2(-18,24),Color("#7d8a90"),2.0)
            draw_line(c+Vector2(18,13),c+Vector2(18,24),Color("#7d8a90"),2.0)
            draw_line(c+Vector2(-18,24),c+Vector2(18,24),accent,2.0)
        elif st.kind in ["restaurant","cafe","bar"]:
            draw_circle(c+Vector2(-10,23),5,Color("#5f4b3e"))
            draw_circle(c+Vector2(10,23),5,Color("#5f4b3e"))
            var awn_wave:=sin(float(Time.get_ticks_msec())/520.0+float(int(st.pos.x+st.pos.y)%13))*3.0
            var awn:=PackedVector2Array([c+Vector2(-28,13),c+Vector2(28,13),c+Vector2(23+awn_wave,19),c+Vector2(-23+awn_wave,19)])
            draw_colored_polygon(awn,Color(accent.r,accent.g,accent.b,0.42))
            if st.kind=="restaurant":
                for steam_i in range(2):
                    var sy:=fposmod(float(Time.get_ticks_msec())*0.018+float(steam_i)*14.0,28.0)
                    draw_arc(c+Vector2(18+steam_i*5,10-sy),4.0+sy*0.05,0.2,2.7,10,Color(0.86,0.91,0.92,0.18),1.4,true)

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
            var trunk_width:=4.0*clampf(pow(world_zoom,0.25),0.95,1.25)
            draw_line(c,c+Vector2(0,-18),Color("#382419"),trunk_width+2.0,true)
            draw_line(c,c+Vector2(0,-18),Color("#8b6142"),trunk_width,true)
            var crown := c+Vector2(0,-21)
            for a in range(0,360,45):
                var dir := Vector2.from_angle(deg_to_rad(float(a)))
                var tip: Vector2=crown+dir*float(t.r)*1.45
                draw_line(crown,tip,Color("#15391f"),6.0,true)
                draw_line(crown,tip,t.tint.lightened(0.06),3.6,true)
            draw_circle(crown,t.r*0.28,Color("#2d6b3a"))
        elif species == "birch":
            draw_line(b,c,Color("#d7d0bc"),4.0,true)
            for off in [Vector2(-6,-4),Vector2(4,-8),Vector2(8,3),Vector2(-9,5)]:
                draw_circle(c+off,t.r*0.60,t.tint.lightened(0.08))
        else:
            draw_circle(c,t.r,t.tint.darkened(0.2))
            draw_circle(c+Vector2(-5,-5),t.r*0.62,t.tint.lightened(0.12))
            draw_circle(c+Vector2(7,-1),t.r*0.48,t.tint)

func _draw_named_npcs() -> void:
    for i in range(named_npcs.size()):
        var npc: Dictionary=named_npcs[i]
        var pos:=Vector2(npc.pos)
        var foot:=_project(pos)
        if not _tile_visible(foot,120):
            continue
        var accent: Color=npc.accent
        var heading: float=(player_pos-pos).angle() if pos.distance_to(player_pos)<160 else PI*0.5
        CityArt.draw_character(self,pos,heading,1+i%3,0,"idle",accent.lightened(0.78))
        var top:=foot-Vector2(0,43)*world_zoom
        var width: float=110*clampf(world_zoom,1,1.8)
        draw_rect(Rect2(top-Vector2(width*0.5,21),Vector2(width,32)),Color(0.025,0.075,0.10,0.87))
        draw_string(ThemeDB.fallback_font,top+Vector2(-width*0.5,0),str(npc.name),HORIZONTAL_ALIGNMENT_CENTER,width,18,Color("#e9f6f4"))

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
    dialogue_body.text=str(npc.text)+"\n\n"+_npc_context_line(npc)
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
    commerce_panel.visible=false
    dialogue_panel.visible=true
    move_vec=Vector2.ZERO
    _sync_modal_ui()

func _join_micro_event(index: int) -> void:
    if index<0 or index>=city_micro_events.size():
        return
    var event: Dictionary = city_micro_events[index]
    if not _micro_event_active(index,event):
        _notify("Das Ereignis ist gerade vorbei.")
        return
    var kind:=str(event.type)
    var label:=str(event.label)
    _open_commerce(label,"LIVE-EVENT · %s\nWie möchtest du dich einbringen?" % current_district)
    move_vec=Vector2.ZERO
    var active_label:="MITMACHEN"
    var support_label:="UNTERSTÜTZEN"
    if kind=="foodtruck":
        active_label="SNACK HOLEN"
        support_label="BEIM AUSGEBEN HELFEN"
    elif kind in ["busker","boardwalk_music"]:
        active_label="ZUHÖREN"
        support_label="KÜNSTLER UNTERSTÜTZEN"
    elif kind in ["maintenance","repair_crew"]:
        active_label="ZUSCHAUEN"
        support_label="KURZ MIT ANPACKEN"
    elif kind=="street_market":
        active_label="MARKT ERKUNDEN"
        support_label="AM STAND HELFEN"
    elif kind=="street_art":
        active_label="MURAL ANSEHEN"
        support_label="FARBE / MATERIAL HELFEN"
    elif kind=="drone_show":
        active_label="SHOW ANSEHEN"
        support_label="FORMATION SCOUTEN"
    commerce_actions.add_child(_commerce_button(active_label,_resolve_micro_event.bind(index,"ERLEBT")))
    commerce_actions.add_child(_commerce_button(support_label,_resolve_micro_event.bind(index,"GEHOLFEN")))
    commerce_actions.add_child(_commerce_button("WEITERGEHEN",_close_commerce))

func _event_followup_target(index: int, source: Vector2) -> Vector2:
    if junctions.is_empty():
        return Vector2.ZERO
    var start: int=absi(index*17+int(source.x/100.0)+int(source.y/100.0))%junctions.size()
    var fallback: Vector2=Vector2.ZERO
    for step in range(junctions.size()):
        var j: Dictionary=junctions[(start+step*7)%junctions.size()]
        if bool(j.get("bridge",false)):
            continue
        var p: Vector2=Vector2(j.pos)
        var dist: float=source.distance_to(p)
        if dist>900.0 and dist<5200.0:
            return p
        if fallback==Vector2.ZERO and dist>650.0:
            fallback=p
    return fallback

func _start_event_followup(index: int, event: Dictionary) -> bool:
    if not active_job.is_empty():
        return false
    var kind:=str(event.type)
    if kind not in ["maintenance","repair_crew","street_market","foodtruck","street_art","campus_group","busker","boardwalk_music"]:
        return false
    var source:=Vector2(event.pos)
    var target:=_event_followup_target(index,source)
    if target==Vector2.ZERO:
        return false
    target=CityAccess.safe_point(self,target)
    var title:="Lokaler Folgeauftrag"
    var task:="Material weiterbringen"
    var pay:=52
    if kind in ["maintenance","repair_crew"]:
        title="Crew-Nachschub"
        task="Ersatzteil zum markierten Übergabepunkt bringen"
        pay=68
    elif kind in ["street_market","foodtruck"]:
        title="Quartiers-Lieferung"
        task="Eine kleine Lieferung ins nächste Viertel bringen"
        pay=58
    elif kind=="street_art":
        title="Mural-Material"
        task="Material am markierten Treffpunkt abgeben"
        pay=55
    elif kind=="campus_group":
        title="Campus-Kurier"
        task="Unterlagen zum Treffpunkt bringen"
        pay=48
    elif kind in ["busker","boardwalk_music"]:
        title="Gig-Support"
        task="Equipment zum nächsten Treffpunkt bringen"
        pay=54
    active_job={
        "kind":"event_followup",
        "title":title,
        "target":target,
        "pay":pay,
        "event":str(event.label),
        "task":task
    }
    _play_sfx("mission")
    _notify("FOLGEAUFTRAG · %s · %d CR" % [title,pay])
    return true

func _resolve_micro_event(index: int, choice: String) -> void:
    if index<0 or index>=city_micro_events.size():
        return
    var event: Dictionary=city_micro_events[index]
    var kind:=str(event.type)
    var label:=str(event.label)
    var first_time:=not bool(micro_event_seen.get(label,false))
    var energy_gain:=5.0
    var credit_delta:=0
    var flavor:="Du nimmst dir Zeit für das Stadtleben."
    if choice=="GEHOLFEN":
        energy_gain=4.0
        credit_delta=4
        flavor="Du hilfst aktiv mit und bekommst ein kleines Dankeschön."
        if kind in ["busker","boardwalk_music"]:
            credit_delta=-3 if credits>=3 else 0
            energy_gain=8.0
            flavor="Du unterstützt die Musik direkt und bleibst für das Set."
        elif kind=="foodtruck":
            energy_gain=12.0
            credit_delta=5
            flavor="Du hilfst kurz beim Ausgeben und bekommst dafür einen Snack."
        elif kind in ["maintenance","repair_crew"]:
            energy_gain=3.0
            credit_delta=8
            flavor="Du hilfst bei Absicherung und Material. Die Crew bedankt sich."
    else:
        if kind in ["yoga","run_club"]:
            energy_gain=14.0
            flavor="Du machst aktiv mit und kommst mit neuer Energie zurück."
        elif kind=="foodtruck":
            if credits>=6:
                credit_delta=-6
                energy_gain=18.0
                flavor="Ein Street-Food-Stopp bringt ordentlich Energie."
            else:
                energy_gain=3.0
                flavor="Du schaust vorbei, aber ein Snack ist gerade nicht drin."
        elif kind in ["busker","boardwalk_music"]:
            energy_gain=7.0
            flavor="Du bleibst für ein komplettes Stück."
        elif kind=="street_market":
            energy_gain=8.0
            flavor="Du erkundest die Stände und hörst lokale Geschichten."
        elif kind=="drone_show":
            energy_gain=6.0
            flavor="Die Drohnenshow legt eine zweite Ebene über die Skyline."
        elif kind=="street_art":
            energy_gain=5.0
            flavor="Du beobachtest, wie das Mural Schicht für Schicht entsteht."

    credits=maxi(0,credits+credit_delta)
    energy=minf(100.0,energy+energy_gain)
    micro_event_choices[label]=choice
    if first_time:
        micro_event_seen[label]=true
        city_reputation+=1
        credits+=10
        _play_sfx("city_event")
        _show_reward_popup("STADTLEBEN · %s" % label,"%s\n+10 CR Erstentdeckung · Stadtruf %d/%d" % [flavor,city_reputation,city_micro_events.size()],Color(event.accent))
        if choice=="GEHOLFEN":
            _start_event_followup(index,event)
    else:
        _play_sfx("collect")
        var delta_text:=""
        if credit_delta>0:
            delta_text=" · +%d CR" % credit_delta
        elif credit_delta<0:
            delta_text=" · %d CR" % credit_delta
        _notify("%s · +%d Energie%s" % [label,int(energy_gain),delta_text])
    _close_commerce()
    _save_game()
    _check_milestones()
    _advance_native_chapter()

func _npc_context_line(npc: Dictionary) -> String:
    var id := str(npc.id)
    var trust := int(npc_trust.get(id,0))
    var state := _weather_state()
    var time_text := "am Tag"
    if world_clock>=18.0 or world_clock<6.0:
        time_text="bei Nacht"
    elif world_clock<10.0:
        time_text="am Morgen"
    elif world_clock>16.0:
        time_text="am Abend"
    var trust_text := "Wir kennen uns noch kaum."
    if trust>=3:
        trust_text="Du hast dir hier bereits Vertrauen erarbeitet."
    elif trust>=1:
        trust_text="Ich habe gesehen, dass du dich in der Stadt einbringst."
    return "%s Aktuell: %s, %s · %s." % [trust_text,_weather_label(),time_text,current_district]

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
        return {"npc":id,"npc_name":npc_name,"kind":"visit","start":0,"goal":1,"reward":95,"title":"Novas Hafenroute","target":CityAccess.safe_point(self,Vector2(7550,12600))}
    if id=="luna":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"gridRepair","goal":1,"reward":110,"title":"Lunas Grid-Diagnose","target":Vector2(23100,1750)}
    if id=="iris":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"firewall","goal":1,"reward":125,"title":"Iris Firewall-Audit","target":Vector2(12650,12650)}
    if id=="vio":
        return {"npc":id,"npc_name":npc_name,"kind":"hack","hack":"cipherGate","goal":1,"reward":105,"title":"Vios Cipher Challenge","target":Vector2(23600,8700)}
    if id=="bram":
        return {"npc":id,"npc_name":npc_name,"kind":"transit","start":transit_trip_count,"goal":1,"reward":75,"title":"Brams Liniencheck","target":_nearest_transit_stop_pos(player_pos)}
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
        return _closest_uncollected(caches,"taken")
    if kind=="hack":
        for site in mission_sites:
            if str(site.id)==str(active_npc_contract.get("hack","")): return Vector2(site.pos)
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
    var weather := _weather_state()
    var advice := "Die Karte zeigt dir die wichtigsten Ebenen."
    if weather=="rain":
        advice="Bei Regen spiegeln die Straßen stärker. In den Glas- und Neonvierteln lohnt sich ein langsamerer Blick."
    elif weather=="storm":
        advice="Im Gewitter wirkt die Sicht unruhiger. Foto-Spots und enge Straßen verlangen mehr Kontrolle."
    elif weather=="mist":
        advice="Im Nebel verlieren entfernte Ebenen Kontrast. Nutze PMDD-Perspektive und Landmarken zur Orientierung."
    elif world_clock>19.0 or world_clock<6.0:
        advice="Nachts werden Neonachsen, Fenster und Verkehr deutlich wichtiger für die Orientierung."
    dialogue_body.text="%s: In %s ändern Höhe, Verkehr, Gebäude und POIs den Rhythmus. %s" % [str(npc.name),current_district,advice]

func _close_dialogue() -> void:
    dialogue_panel.visible=false
    active_dialogue_npc=-1
    _sync_modal_ui()

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
        if player_pos.distance_to(Vector2(ph.pos))>1750.0:
            continue
        var p := _project(Vector2(ph.pos),20)
        var completed: bool = bool(ph.taken)
        var pulse: float = 1.0+sin(Time.get_ticks_msec()/260.0+float(ph.pos.x)*0.001)*0.12
        draw_circle(p,14.0*pulse,Color(1.0,0.55,0.86,0.05))
        draw_arc(p,14.0*pulse,0,TAU,26,Color(0.55,0.65,0.69,0.45) if completed else Color("#ff9fdd"),2.0,true)
        draw_arc(p,8.0*pulse,-1.0,1.0,12,Color("#f2f8ff"),2.0,true)
        if player_pos.distance_to(Vector2(ph.pos))<180.0:
            draw_string(ThemeDB.fallback_font,p+Vector2(-90,-30),str(ph.label),HORIZONTAL_ALIGNMENT_CENTER,180,12,Color.WHITE)
            draw_string(ThemeDB.fallback_font,p+Vector2(-90,34),"PHOTO REPLAY" if completed else "PHOTO CHALLENGE STARTEN",HORIZONTAL_ALIGNMENT_CENTER,180,10,Color("#aebcc2") if completed else Color("#ffcf8a"))

func _draw_transit_stops() -> void:
    for st in transit_stops:
        if player_pos.distance_to(Vector2(st.pos))>1700.0:
            continue
        var c := _project(Vector2(st.pos),6)
        draw_line(c,c+Vector2(0,-28),Color("#697980"),2.5,true)
        draw_rect(Rect2(c+Vector2(-18,-44),Vector2(36,20)),Color(0.04,0.09,0.11,0.94),true)
        draw_rect(Rect2(c+Vector2(-18,-44),Vector2(36,20)),Color("#72d7e6"),false,1.5)
        draw_string(ThemeDB.fallback_font,c+Vector2(-14,-40),str(st.line),HORIZONTAL_ALIGNMENT_CENTER,28,9,Color.WHITE)

func _draw_active_job_target() -> void:
    if active_job.is_empty():
        return
    var kind:=str(active_job.get("kind",""))
    if kind not in ["delivery","event_followup"]:
        return
    var target:=Vector2(active_job.get("target",Vector2.ZERO))
    if target==Vector2.ZERO or player_pos.distance_to(target)>1800.0:
        return
    var p:=_project(target,8)
    var pulse:=1.0+sin(Time.get_ticks_msec()/260.0)*0.10
    var accent:=Color("#8de9aa") if kind=="event_followup" else Color("#9ad5ff")
    draw_circle(p,22.0*pulse,Color(accent.r,accent.g,accent.b,0.08))
    draw_arc(p,22.0*pulse,0,TAU,30,Color(accent.r,accent.g,accent.b,0.55),2.0,true)
    draw_rect(Rect2(p-Vector2(9,7),Vector2(18,14)),Color(0.06,0.10,0.11,0.92),true)
    draw_rect(Rect2(p-Vector2(9,7),Vector2(18,14)),accent,false,1.5)
    draw_line(p+Vector2(-7,-2),p+Vector2(7,-2),accent,1.3,true)
    if player_pos.distance_to(target)<180.0:
        draw_string(ThemeDB.fallback_font,p+Vector2(-85,44),"FOLGEZIEL" if kind=="event_followup" else "LIEFERZIEL",HORIZONTAL_ALIGNMENT_CENTER,170,12,accent)

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
        elif p.type == "planter":
            var pl := _project(p.pos,4)
            draw_rect(Rect2(pl-Vector2(14,6),Vector2(28,12)),Color("#604d3d"),true)
            draw_rect(Rect2(pl-Vector2(14,6),Vector2(28,12)),Color(1,1,1,0.12),false,1.0)
            draw_circle(pl+Vector2(-7,-8),7,Color("#4d8f5b"))
            draw_circle(pl+Vector2(5,-10),8,Color("#63a66c"))
            draw_circle(pl+Vector2(10,-5),5,Color(p.tint.r,p.tint.g,p.tint.b,0.55))
        elif p.type == "utility_box":
            var ub := _project(p.pos,10)
            draw_rect(Rect2(ub-Vector2(10,13),Vector2(20,26)),Color("#435159"),true)
            draw_rect(Rect2(ub-Vector2(10,13),Vector2(20,26)),Color(p.tint.r,p.tint.g,p.tint.b,0.34),false,1.4)
            draw_line(ub+Vector2(-6,-4),ub+Vector2(6,-4),Color(1,1,1,0.16),1.0)
            draw_circle(ub+Vector2(5,6),1.8,Color("#ffd36b"))
        elif p.type == "cafe_table":
            var ct := _project(p.pos,5)
            draw_circle(ct,10,Color("#6f5a48"))
            draw_circle(ct,11,Color(1,1,1,0.12),false,1.0)
            draw_line(ct,ct+Vector2(0,12),Color("#4d5960"),2.0)
            for a in [0.0,PI*0.5,PI,PI*1.5]:
                var dir := Vector2.from_angle(float(a))
                draw_circle(ct+dir*20,6,Color("#37434a"))
        elif p.type == "construction_cone":
            var co := _project(p.pos,6)
            var cone := PackedVector2Array([co+Vector2(-7,8),co+Vector2(7,8),co+Vector2(3,-9),co+Vector2(-3,-9)])
            draw_colored_polygon(cone,Color("#e77e36"))
            draw_line(co+Vector2(-5,2),co+Vector2(5,2),Color("#f7e7cf"),2.5)
            draw_line(co+Vector2(-10,9),co+Vector2(10,9),Color("#374148"),3.0)
        elif p.type == "hydrant":
            var hy := _project(p.pos,7)
            draw_rect(Rect2(hy-Vector2(5,8),Vector2(10,16)),Color("#bb4d4e"),true)
            draw_circle(hy+Vector2(0,-9),6,Color("#d45f5f"))
            draw_line(hy+Vector2(-9,-1),hy+Vector2(9,-1),Color("#8f3c3d"),3.0,true)
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
        elif p.type == "flag":
            var fb:=_project(Vector2(p.pos),0)
            var ft:=_project(Vector2(p.pos),42)
            draw_line(fb,ft,Color("#7e8b91"),3.0,true)
            var wind:=sin(float(Time.get_ticks_msec())/240.0+float(int(Vector2(p.pos).x)%19))*5.0
            var flag:=PackedVector2Array([ft,ft+Vector2(26+wind,-4),ft+Vector2(22+wind,9),ft+Vector2(0,8)])
            draw_colored_polygon(flag,Color(p.tint.r,p.tint.g,p.tint.b,0.76))
        elif p.type == "vent_stack":
            var vb:=_project(Vector2(p.pos),8)
            draw_rect(Rect2(vb-Vector2(8,12),Vector2(16,24)),Color("#4b565b"),true)
            draw_rect(Rect2(vb+Vector2(-11,-15),Vector2(22,5)),Color("#68767c"),true)
            for steam_i in range(3):
                var sy:=fposmod(float(Time.get_ticks_msec())*0.025+float(steam_i)*18.0,52.0)
                var sx:=sin(float(Time.get_ticks_msec())/500.0+float(steam_i))*5.0
                draw_circle(vb+Vector2(sx,-18-sy),4.0+sy*0.05,Color(0.80,0.86,0.88,0.11))
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
    var sway:=sin(float(Time.get_ticks_msec())/480.0+float(int(Vector2(p.pos).x)%17))*3.0
    var awn := PackedVector2Array([c+Vector2(-30,-8),c+Vector2(30,-8),c+Vector2(22+sway,-22),c+Vector2(-22+sway,-22)])
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
    var neon_pulse:=0.72+0.28*sin(float(Time.get_ticks_msec())/300.0+float(int(Vector2(p.pos).y)%11))
    draw_arc(c+Vector2(0,-38),15,0,TAU,20,Color(p.tint.r,p.tint.g,p.tint.b,0.62+0.26*neon_pulse),3.0,true)
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
    var distance_limit: float=[900.0,1300.0,1700.0][graphics_quality]
    for ped in pedestrians:
        var pos:=_ped_world_pos(ped)
        if player_pos.distance_to(pos)>distance_limit or not _tile_visible(_project(pos),110):
            continue
        var rd: Dictionary=roads[int(ped.road)]
        var tangent:=_polyline_tangent(rd.points,float(ped.t))
        if bool(ped.reverse):
            tangent*=-1
        var outfit:=2 if str(ped.role)=="worker" else (3 if str(ped.role) in ["student","runner"] else 1)
        var tint: Color=Color(ped.color).lightened(0.78)
        CityArt.draw_character(self,pos,tangent.angle(),outfit,float(ped.phase),str(ped.get("state","walk")),tint)

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
        var car_heading:=tangent.angle()+float(c.get("crash_angle",0.0))
        _draw_car(pos,car_heading,str(c["class"]),Color(c.color),false,str(c.get("archetype","")))
        if bool(c.get("crashed",false)):
            var center:=_project(pos,8)
            draw_line(center+Vector2(-12,-5),center+Vector2(10,7),Color(0.10,0.10,0.10,0.82),4.0,true)
            draw_line(center+Vector2(-9,7),center+Vector2(7,-8),Color(0.70,0.78,0.80,0.30),2.0,true)
            if int(Time.get_ticks_msec()/280)%2==0:
                draw_circle(center+Vector2(-8,0),3.2,Color("#ffb343"))
                draw_circle(center+Vector2(8,0),3.2,Color("#ffb343"))
        if bool(c.get("ped_yield",false)):
            var rear_center:=_project(pos,8)-tangent.normalized()*18.0
            draw_circle(rear_center+Vector2(-5,0),3.4,Color("#ff364b"))
            draw_circle(rear_center+Vector2(5,0),3.4,Color("#ff364b"))
        if bool(c.get("incident_yield",false)) and int(Time.get_ticks_msec()/330)%2==0:
            var hazard_center:=_project(pos,8)
            var side_vec:=Vector2(-tangent.y,tangent.x).normalized()
            draw_circle(hazard_center+side_vec*8.0,2.8,Color("#ffb343"))
            draw_circle(hazard_center-side_vec*8.0,2.8,Color("#ffb343"))
        if bool(c.get("crash_yield",false)) and int(Time.get_ticks_msec()/300)%2==0:
            var crash_center:=_project(pos,8)
            var crash_side:=Vector2(-tangent.y,tangent.x).normalized()
            draw_circle(crash_center+crash_side*8.0,2.8,Color("#ffb343"))
            draw_circle(crash_center-crash_side*8.0,2.8,Color("#ffb343"))
        if bool(c.get("response_yield",false)) and int(Time.get_ticks_msec()/260)%2==0:
            var ry_center:=_project(pos,8)
            var ry_side:=Vector2(-tangent.y,tangent.x).normalized()
            draw_circle(ry_center+ry_side*8.0,2.8,Color("#ffb343"))
            draw_circle(ry_center-ry_side*8.0,2.8,Color("#ffb343"))
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
    if bool(tv.get("at_stop",false)):
        var door_phase:=0.5+0.5*sin(float(Time.get_ticks_msec())/260.0)
        var door_center:=center-f*length*0.08+side*width*0.50
        draw_rect(Rect2(door_center-Vector2(4+door_phase*3.0,7),Vector2(8+door_phase*6.0,14)),Color(0.08,0.12,0.15,0.82),true)
        draw_line(door_center+Vector2(-5-door_phase*3.0,-6),door_center+Vector2(-5-door_phase*3.0,6),Color("#a8d8ec"),1.2,true)
        draw_line(door_center+Vector2(5+door_phase*3.0,-6),door_center+Vector2(5+door_phase*3.0,6),Color("#a8d8ec"),1.2,true)
    draw_string(ThemeDB.fallback_font,center-f*2+Vector2(-18,-21),str(tv.line),HORIZONTAL_ALIGNMENT_CENTER,36,11,Color.WHITE)

func _draw_parked_cars() -> void:
    for i in range(parked_cars.size()):
        if i == current_vehicle:
            continue
        var c = parked_cars[i]
        if player_pos.distance_to(c.pos)>1800:
            continue
        _draw_car(c.pos,c.heading,c["class"],c.color,true)

func _draw_car(pos: Vector2, heading: float, cls: String, color: Color, parked: bool, archetype: String = "") -> void:
    if graphics_quality>0:
        CityArt.draw_vehicle(self,pos,heading,cls,color,parked,archetype)
        return
    var sz: Vector2 = VEHICLE_SIZES.get(cls,Vector2(45,22))
    var object_zoom:=world_zoom
    sz*=object_zoom
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
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color("#0e131b"),2.0*world_zoom,true)
    # Body shoulder line and hood highlight improve silhouette separation.
    draw_line(center-f*sz.x*.28+side*sz.y*.34,center+f*sz.x*.36+side*sz.y*.34,Color(1,1,1,0.10),1.3,true)
    draw_line(center+f*sz.x*.12-side*sz.y*.28,center+f*sz.x*.42-side*sz.y*.16,Color(1,1,1,0.075),1.1,true)

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
    draw_line(wind_d.lerp(wind_a,0.30),wind_c.lerp(wind_b,0.30),Color(0.88,0.97,1.0,0.13),1.0,true)

    var front_l := center+f*sz.x*.49+side*sz.y*.25
    var front_r := center+f*sz.x*.49-side*sz.y*.25
    var rear_l := center-f*sz.x*.45+side*sz.y*.25
    var rear_r := center-f*sz.x*.45-side*sz.y*.25
    var player_car := current_vehicle>=0 and player_pos.distance_to(pos)<2.0 and not parked
    var braking := player_car and move_vec.y>0.18
    var head_alpha := 1.0
    var rear_color := Color("#ff3f4d") if braking else Color("#ff726f")
    draw_circle(front_l,2.6 if player_car else 2.4,Color("#ffe8ae"))
    draw_circle(front_r,2.6 if player_car else 2.4,Color("#ffe8ae"))
    draw_circle(rear_l,3.2 if braking else 2.2,rear_color)
    draw_circle(rear_r,3.2 if braking else 2.2,rear_color)
    var dark_or_bad:=world_clock>18.2 or world_clock<6.4 or _weather_state() in ["rain","storm","mist"]
    if not parked and dark_or_bad:
        var beam_len:=78.0 if player_car else 48.0
        var beam_width:=19.0 if player_car else 12.0
        var beam_alpha:=0.055 if player_car else 0.026
        var beam_l := PackedVector2Array([front_l-side*3.0,front_l+side*3.0,front_l+f*beam_len+side*beam_width,front_l+f*beam_len-side*beam_width])
        var beam_r := PackedVector2Array([front_r-side*3.0,front_r+side*3.0,front_r+f*beam_len+side*beam_width,front_r+f*beam_len-side*beam_width])
        draw_colored_polygon(beam_l,Color(1.0,0.92,0.68,beam_alpha))
        draw_colored_polygon(beam_r,Color(1.0,0.92,0.68,beam_alpha))
        if _weather_state() in ["rain","storm"]:
            var reflect_alpha:=0.045 if player_car else 0.024
            draw_line(front_l+Vector2(0,3),front_l+Vector2(-f.x*9.0,26),Color(1.0,0.87,0.58,reflect_alpha),5.0,true)
            draw_line(front_r+Vector2(0,3),front_r+Vector2(-f.x*9.0,26),Color(1.0,0.87,0.58,reflect_alpha),5.0,true)
            draw_line(rear_l+Vector2(0,3),rear_l+Vector2(f.x*6.0,20),Color(1.0,0.22,0.18,reflect_alpha*0.90),4.0,true)
            draw_line(rear_r+Vector2(0,3),rear_r+Vector2(f.x*6.0,20),Color(1.0,0.22,0.18,reflect_alpha*0.90),4.0,true)
    if player_car and abs(vehicle_velocity)>210.0 and abs(move_vec.x)>0.48:
        for skid_side in [-1.0,1.0]:
            var wheel_rear := center-f*sz.x*.36+side*sz.y*.42*float(skid_side)
            draw_line(wheel_rear,wheel_rear-f*(16.0+abs(vehicle_velocity)*0.025),Color(0.04,0.05,0.06,0.28),2.2,true)
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

    if archetype=="taxi":
        draw_rect(Rect2(center-Vector2(6,sz.y*.66),Vector2(12,5)),Color("#f2cf4f"),true)
        draw_line(center-f*sz.x*.30-side*sz.y*.47,center+f*sz.x*.30-side*sz.y*.47,Color("#f2cf4f"),2.4,true)
    elif archetype=="rideshare":
        draw_circle(center+f*2.0-Vector2(0,sz.y*.63),3.5,Color("#71e0c0"))
        draw_line(center-f*sz.x*.24+side*sz.y*.46,center+f*sz.x*.24+side*sz.y*.46,Color("#71e0c0"),1.8,true)
    elif archetype in ["service","maintenance"]:
        draw_line(center-f*sz.x*.30-side*sz.y*.48,center+f*sz.x*.30-side*sz.y*.48,Color("#f2b34e"),2.2,true)
        draw_line(center-f*sz.x*.30+side*sz.y*.48,center+f*sz.x*.30+side*sz.y*.48,Color("#f2b34e"),2.2,true)
        if cls in ["pickup","van","delivery","suv"]:
            draw_line(center-f*sz.x*.18-side*sz.y*.32,center+f*sz.x*.18-side*sz.y*.32,Color("#20282c"),2.6,true)
            draw_line(center-f*sz.x*.18+side*sz.y*.32,center+f*sz.x*.18+side*sz.y*.32,Color("#20282c"),2.6,true)
        if archetype=="maintenance":
            draw_circle(center+f*1.0-Vector2(0,sz.y*.64),3.0,Color("#ffb12d") if int(Time.get_ticks_msec()/330)%2==0 else Color("#6f5224"))
    elif archetype=="ambulance":
        var amb_pulse:=0.5+0.5*sin(float(Time.get_ticks_msec())/110.0)
        draw_circle(center,24.0,Color(0.20,0.55,1.0,0.018+amb_pulse*0.018))
        draw_circle(center+Vector2(8,0),20.0,Color(1.0,0.18,0.24,0.014+(1.0-amb_pulse)*0.016))
        draw_line(center-f*sz.x*.34-side*sz.y*.47,center+f*sz.x*.34-side*sz.y*.47,Color("#48bfa9"),3.0,true)
        draw_line(center-f*sz.x*.34+side*sz.y*.47,center+f*sz.x*.34+side*sz.y*.47,Color("#48bfa9"),3.0,true)
        var amb_flash:=int(Time.get_ticks_msec()/150)%2==0 and not parked
        draw_rect(Rect2(center+f*3.0-Vector2(9,sz.y*.67),Vector2(18,4)),Color("#53636a"),true)
        draw_circle(center+f*3.0-side*5.0-Vector2(0,sz.y*.65),2.6,Color("#ff4057") if amb_flash else Color("#5b3138"))
        draw_circle(center+f*3.0+side*5.0-Vector2(0,sz.y*.65),2.6,Color("#55aaff") if not amb_flash else Color("#304760"))
        draw_rect(Rect2(center+f*sz.x*.12-side*4.0-Vector2(5,5),Vector2(10,10)),Color("#f4faf9"),true)
        draw_line(center+f*sz.x*.12+Vector2(0,-6),center+f*sz.x*.12+Vector2(0,6),Color("#3abf9f"),2.2,true)
        draw_line(center+f*sz.x*.12+Vector2(-6,0),center+f*sz.x*.12+Vector2(6,0),Color("#3abf9f"),2.2,true)
    elif archetype=="response":
        var response_pulse:=0.5+0.5*sin(float(Time.get_ticks_msec())/125.0)
        draw_circle(center,21.0,Color(0.18,0.48,1.0,0.015+response_pulse*0.016))
        draw_circle(center+Vector2(7,0),18.0,Color(1.0,0.18,0.28,0.012+(1.0-response_pulse)*0.014))
        var flash:=int(Time.get_ticks_msec()/180)%2==0 and not parked
        draw_rect(Rect2(center+f*2.0-Vector2(8,sz.y*.65),Vector2(16,4)),Color("#46545d"),true)
        draw_circle(center+f*2.0-side*4.0-Vector2(0,sz.y*.63),2.4,Color("#ff4057") if flash else Color("#5b3138"))
        draw_circle(center+f*2.0+side*4.0-Vector2(0,sz.y*.63),2.4,Color("#55aaff") if not flash else Color("#304760"))
        draw_line(center-f*sz.x*.32-side*sz.y*.46,center+f*sz.x*.32-side*sz.y*.46,Color("#d6edf2"),2.2,true)
    elif archetype=="courier":
        draw_rect(Rect2(center-f*9-side*sz.y*.31,Vector2(18,sz.y*.62)),Color(1,1,1,0.08),true)
        draw_line(center-f*sz.x*.24+side*sz.y*.47,center+f*sz.x*.20+side*sz.y*.47,Color("#72d7e6"),2.2,true)

    var livery := int(abs(pos.x+pos.y)) % 17
    if livery==0:
        draw_line(center-f*sz.x*.10-side*sz.y*.45,center-f*sz.x*.10+side*sz.y*.45,Color(0.98,0.88,0.34,0.58),2.0)
    elif livery==1:
        draw_line(center-f*sz.x*.28,center+f*sz.x*.30,Color(1,1,1,0.16),1.2)
    elif livery==2 and cls not in ["sport","hyper"]:
        draw_rect(Rect2(center-Vector2(5,sz.y*.64),Vector2(10,5)),Color("#f0c94e"),true)
        draw_line(center-f*sz.x*.18-side*sz.y*.47,center+f*sz.x*.18-side*sz.y*.47,Color("#f0c94e"),2.0,true)
    elif livery==3:
        draw_line(center-f*sz.x*.30+side*sz.y*.46,center+f*sz.x*.30+side*sz.y*.46,Color("#62c9ff"),2.3,true)
    elif livery==4 and cls in ["suv","van","pickup"]:
        draw_line(center-f*sz.x*.18-side*sz.y*.30,center+f*sz.x*.18-side*sz.y*.30,Color("#20282c"),2.4,true)
        draw_line(center-f*sz.x*.18+side*sz.y*.30,center+f*sz.x*.18+side*sz.y*.30,Color("#20282c"),2.4,true)
    elif livery==5 and cls in ["sedan","executive","suv","van"]:
        var flash_on := int(Time.get_ticks_msec()/260)%2==0 and not parked
        draw_rect(Rect2(center+f*2.0-Vector2(7,sz.y*.61),Vector2(14,4)),Color("#5a6871"),true)
        draw_circle(center+f*2.0-side*4.0-Vector2(0,sz.y*.59),2.0,Color("#ff5a6d") if flash_on else Color("#66333d"))
        draw_circle(center+f*2.0+side*4.0-Vector2(0,sz.y*.59),2.0,Color("#66baff") if flash_on else Color("#334c66"))
    elif livery==6:
        draw_line(center-f*sz.x*.22-side*sz.y*.46,center+f*sz.x*.26-side*sz.y*.46,Color("#72f0d2"),1.8,true)

    if not parked:
        if _is_emergency_archetype(archetype) and _weather_state() in ["rain","storm"]:
            var reflect_pulse:=0.5+0.5*sin(float(Time.get_ticks_msec())/130.0)
            draw_line(center+Vector2(-8,6),center+Vector2(-11,38),Color(1.0,0.16,0.22,0.025+reflect_pulse*0.030),8.0,true)
            draw_line(center+Vector2(8,6),center+Vector2(11,38),Color(0.18,0.55,1.0,0.025+(1.0-reflect_pulse)*0.030),8.0,true)
        var tail := center-f*sz.x*.62
        draw_line(tail,tail-f*(30 if cls in ["sport","hyper"] else 22),Color(0.35,0.85,1.0,0.11),4.0,true)
        if _weather_state() in ["rain","storm"]:
            var spray_alpha := 0.10 if _weather_state()=="rain" else 0.15
            draw_line(rear_l,rear_l-f*12.0+side*4.0,Color(0.72,0.86,0.92,spray_alpha),3.0,true)
            draw_line(rear_r,rear_r-f*12.0-side*4.0,Color(0.72,0.86,0.92,spray_alpha),3.0,true)

func _draw_car_wheels(center: Vector2, f: Vector2, side: Vector2, sz: Vector2) -> void:
    for ax in [0.28,-0.28]:
        var axle := center + f*sz.x*float(ax)
        var w1 := axle + side*sz.y*.52
        var w2 := axle - side*sz.y*.52
        draw_line(w1-f*4,w1+f*4,Color(0.05,0.05,0.06,0.92),2.4)
        draw_line(w2-f*4,w2+f*4,Color(0.05,0.05,0.06,0.92),2.4)

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
    if current_vehicle>=0:
        var car: Dictionary=parked_cars[current_vehicle]
        _draw_car(player_pos,player_heading,car["class"],car.color,false)
        return
    var walking:=move_vec.length()>0.08
    var phase: float=float(Time.get_ticks_msec())/95.0 if walking else 0.0
    var foot:=_project(player_pos)
    draw_arc(foot,8*world_zoom,0,TAU,32,Color(0.45,0.95,0.82,0.40),1.0*world_zoom,true)
    CityArt.draw_character(self,player_pos,player_heading,0,phase,"walk" if walking else "idle")

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
    move_vec=Vector2.ZERO
    _update_ui()
    _notify("%s · Willkommen" % name)

func _leave_interior() -> void:
    commerce_panel.visible = false
    interior_active = false
    current_vertical_id = ""
    player_pos = CityAccess.safe_point(self,interior_return_pos+Vector2(0,42))
    if service_vehicle_index>=0 and service_vehicle_index<parked_cars.size():
        current_vehicle=service_vehicle_index
        parked_cars[current_vehicle]["occupied"]=true
        player_pos=Vector2(parked_cars[current_vehicle]["pos"])
        service_vehicle_index=-1
    camera_pos = player_pos
    _play_sfx("door")
    move_vec=Vector2.ZERO
    _update_ui()
    _notify("Wieder draußen · %s" % current_district)

func _show_reward_popup(title_text: String, body_text: String, accent: Color = Color("#73f3ce")) -> void:
    if reward_panel==null: return
    if reward_tween: reward_tween.kill()
    reward_title.text=title_text
    reward_title.modulate=accent
    reward_body.text=body_text
    reward_panel.visible=true
    reward_panel.modulate=Color.WHITE
    reward_tween=create_tween()
    reward_tween.tween_interval(3.4)
    reward_tween.tween_property(reward_panel,"modulate:a",0.0,0.35)
    reward_tween.tween_callback(func(): reward_panel.visible=false)

func _notify(text: String) -> void:
    if notice_tween: notice_tween.kill()
    district_banner.text=text
    district_banner.modulate=Color.WHITE
    notice_tween=create_tween()
    notice_tween.tween_interval(2.6)
    notice_tween.tween_property(district_banner,"modulate:a",0.0,0.4)

func _interior_elevator_pos() -> Vector2:
    return Vector2(interior_size.x-105,interior_size.y-115)

func _toggle_interior_floor() -> void:
    interior_floor=1-interior_floor
    interior_player_pos=Vector2(interior_size.x-145,interior_size.y-150)
    move_vec=Vector2.ZERO
    _play_sfx("door")
    _notify("%s · Etage %d" % [interior_name,interior_floor+1])

func _interior_feature_pos() -> Vector2:
    return InteriorArt.feature_pos(interior_kind,interior_floor)

func _interior_feature_message() -> String:
    if interior_kind == "openai_hq":
        return "Interaktive Forschungsausstellung im Visitor Lab."
    if interior_kind == "hospital":
        return "Triage aktiv · Notaufnahme, Diagnostik und Beobachtung sind betriebsbereit."
    if interior_kind == "roof":
        return "Dach-Relay synchronisieren."
    if interior_kind == "sublevel":
        return "Sublevel-Knoten aktivieren."
    if interior_kind == "garage":
        return "Fahrzeug abstellen, lackieren und verbessern."
    if interior_kind == "workshop":
        return "Diagnose, Motor, Handling und Bremsen verbessern."
    if interior_kind in ["restaurant","cafe","bar"]:
        return "Am Tresen bestellen und neue Energie tanken."
    return "Am markierten Terminal die Hausgarage öffnen."

func _draw_interior_scene() -> void:
    InteriorArt.draw_room(self)

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

func _draw_interior_player() -> void:
    InteriorArt.draw_player(self)

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
    minigame_session+=1
    var sid := str(site.id)
    active_mission_replay = bool(hack_done.get(sid,false))
    active_mission_site = site
    game_type = str(site.game)
    minigame_finishing=false
    game_moves=0
    game_hints=0
    minigame_open = true
    collection_open=false
    commerce_panel.visible=false
    dialogue_panel.visible=false
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
    _sync_modal_ui()

func _close_minigame() -> void:
    minigame_session+=1
    minigame_open = false
    game_panel.visible = false
    active_mission_site = {}
    game_type = ""
    move_vec = Vector2.ZERO
    _sync_modal_ui()

func _finish_minigame() -> void:
    if active_mission_site.is_empty() or minigame_finishing:
        return
    minigame_finishing=true
    var session:=minigame_session
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
    if not minigame_open or minigame_session!=session or str(active_mission_site.get("id",""))!=sid:
        return
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
    var hint:=_game_button("HINWEIS",_wire_hint)
    hint.custom_minimum_size=Vector2(250,75)
    hint.add_theme_font_size_override("font_size",22)
    game_controls.add_child(hint)
    _render_wire()

func _render_wire() -> void:
    for child in game_grid.get_children():
        child.queue_free()
    var reachable:=_wire_reachable_cells()
    var cols: int=int(game_secret[1])
    var end_index: int=int(game_secret[0])
    for i in range(game_current.size()):
        var button:=WireTile.new()
        button.mask=int(game_current[i])
        button.powered=reachable.has(i)
        button.source=i==0
        button.target=i==end_index
        button.disabled=minigame_finishing
        button.pressed.connect(_on_wire_cell.bind(i))
        game_grid.add_child(button)
    game_info.text="NETZWERK %d × %d · %d/%d unter Strom\n%d Drehungen · %d Hinweise · %s" % [cols,cols,reachable.size(),game_current.size(),game_moves,game_hints,("12 CR Replay" if active_mission_replay else "35 CR + "+str(active_mission_site.reward))]
    game_status.text="Tippe eine Kachel zum Drehen. Verbinde S mit T und bringe das gesamte Netz zum Leuchten."

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
    if minigame_finishing or not minigame_open:
        return
    game_moves+=1
    game_current[index]=_rotate_wire_mask(int(game_current[index]))
    _play_sfx("hack_click")
    _render_wire()
    if _wire_solved():
        _finish_minigame()

func _wire_hint() -> void:
    if minigame_finishing or game_type!="wire" or not minigame_open:
        return
    for i in range(game_current.size()):
        if int(game_current[i])!=int(game_target[i]):
            game_current[i]=game_target[i]
            game_hints+=1
            _play_sfx("scan")
            _render_wire()
            game_status.text="Eine Kachel stimmt jetzt. Folge der grünen Leitung ab S."
            if _wire_solved():
                _finish_minigame()
            return

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
        var stop_index: int=int(ride.get("stop_index",-1))
        var stop_data: Dictionary=transit_stops[stop_index] if stop_index>=0 and stop_index<transit_stops.size() else {}
        var road = roads[int(ride.road)]
        var tang := _polyline_tangent(road.points,float(ride.t))
        var normal := Vector2(-tang.y,tang.x)
        var exit_pos:=Vector2(stop_data.get("pos",_sample_polyline(road.points,float(ride.t))))
        player_pos = exit_pos + normal*85.0
        var exit_line:=str(ride.line)
        var hub_id:=str(stop_data.get("transfer_hub",""))
        transit_riding=-1
        transit_trip_count+=1
        _play_sfx("vehicle")
        if hub_id!="":
            last_transit_exit_hub=hub_id
            last_transit_exit_line=exit_line
            last_transit_exit_time=float(Time.get_ticks_msec())/1000.0
            var lines:=_transit_hub_lines(hub_id,exit_line)
            _notify("Umsteigepunkt · %s → %s" % [exit_line,", ".join(lines)] if not lines.is_empty() else "ÖPNV verlassen.")
        else:
            last_transit_exit_hub=""
            last_transit_exit_line=""
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
    var stop_index: int=int(tv.get("stop_index",-1))
    var stop_data: Dictionary=transit_stops[stop_index] if stop_index>=0 and stop_index<transit_stops.size() else {}
    var hub_id:=str(stop_data.get("transfer_hub",""))
    var line:=str(tv.line)
    var now_s:=float(Time.get_ticks_msec())/1000.0
    var is_transfer:=hub_id!="" and hub_id==last_transit_exit_hub and line!=last_transit_exit_line and now_s-last_transit_exit_time<=120.0
    transit_riding=index
    current_vehicle=-1
    vehicle_velocity=0.0
    _play_sfx("vehicle")
    if is_transfer:
        transit_transfer_count+=1
        _notify("Umstieg %s → %s · Verbindung übernommen." % [last_transit_exit_line,line])
        last_transit_exit_hub=""
        last_transit_exit_line=""
    else:
        _notify("%s bestiegen." % line)

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
    player_pos=Vector2(5100,4220)
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
    photo_found.clear()
    photo_scores.clear()
    micro_event_seen.clear()
    micro_event_choices.clear()
    city_reputation=0
    transit_transfer_count=0
    accident_count=0
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
    _recenter_headtracking()
    _save_options()
    _refresh_option_labels()

func _refresh_option_labels() -> void:
    if sound_option_button==null:
        return
    sound_option_button.text="Sound · %s" % ("AN" if sound_enabled else "AUS")
    var qualities := ["ECO","BALANCED","HIGH"]
    graphics_option_button.text="Grafik · %s" % qualities[graphics_quality]
    pmdd_option_button.text="PMDD Tiefe · %.2fx" % parallax_strength
    sensor_option_button.text="Neigungssteuerung · %.1fx · %s" % [sensor_gain,("GYRO" if headtrack_sensor_mode=="gyro_gravity" else headtrack_sensor_mode.to_upper())]
    if camera_option_button!=null:
        camera_option_button.text="Kamera-Headtracking · %s" % ("AN" if camera_tracking_enabled else "AUS")
    if drive_option_button!=null:
        drive_option_button.text="Fahrhilfe · %s" % ("AN" if driving_assist else "AUS")
    if haptics_option_button!=null:
        haptics_option_button.text="Haptik · %s" % ("AN" if haptics_enabled else "AUS")

func _save_options() -> void:
    var f := FileAccess.open("user://parallaxhunt_options.json",FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify({"sound":sound_enabled,"graphics":graphics_quality,"pmdd":parallax_strength,"sensor":sensor_gain,"drive_assist":driving_assist,"haptics":haptics_enabled,"camera_tracking":camera_tracking_enabled}))

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
        camera_tracking_enabled=bool(d.get("camera_tracking",false))

func _draw_title_art() -> void:
    _draw_district_ground()
    _draw_water()
    _draw_parks()
    _draw_roads()
    CityArt.draw_street_pools(self)
    _draw_buildings()
    _draw_landmarks()
    _draw_trees()
    CityArt.draw_street_ensembles(self)
    _draw_storefronts()
    _draw_traffic()
    _draw_parked_cars()
    draw_rect(get_viewport_rect(),Color(0.02,0.04,0.06,0.24))

func _save_path(slot: int = selected_save_slot) -> String:
    return "user://parallaxhunt_save_%d.json" % clampi(slot,1,3)

func _save_game() -> void:
    if main_menu_active:
        return
    var data := {
        "player":[player_pos.x,player_pos.y],
        "credits":credits,
        "energy":energy,
        "accident_count":accident_count,
        "owned_property":owned_property,
        "owned_cars":owned_cars,
        "current_paint":current_paint,
        "jobs_done":jobs_done,
        "active_job":_serialize_job(active_job),
        "hack_done":hack_done,
        "chapter":native_chapter,
        "inventory":inventory,
        "shop_stock":shop_stock,
        "save_version":2,
        "fragments":fragments.map(func(x): return bool(x.taken)),
        "secrets":secrets.map(func(x): return bool(x.found)),
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
        "micro_event_seen":micro_event_seen,
        "micro_event_choices":micro_event_choices,
        "city_reputation":city_reputation,
        "active_npc_contract":_serialize_contract(active_npc_contract),
        "transit_trip_count":transit_trip_count,
        "transit_transfer_count":transit_transfer_count,
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
    accident_count = int(d.get("accident_count",0))
    owned_property = str(d.get("owned_property",""))
    owned_cars = Array(d.get("owned_cars",[]))
    current_paint = str(d.get("current_paint",""))
    jobs_done = int(d.get("jobs_done",0))
    active_job = _deserialize_job(Dictionary(d.get("active_job",{})))
    hack_done = Dictionary(d.get("hack_done",{}))
    native_chapter = int(d.get("chapter",0))
    inventory = Dictionary(d.get("inventory",inventory))
    shop_stock = Dictionary(d.get("shop_stock",shop_stock))
    _restore_collectible_flags(fragments,d.get("fragments",[]),"taken",int(d.get("frag_count",0)))
    _restore_collectible_flags(secrets,d.get("secrets",[]),"found",int(d.get("secret_count",0)))
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
    micro_event_seen = Dictionary(d.get("micro_event_seen",{}))
    micro_event_choices = Dictionary(d.get("micro_event_choices",{}))
    city_reputation = int(d.get("city_reputation",micro_event_seen.size()))
    active_npc_contract = _deserialize_contract(Dictionary(d.get("active_npc_contract",{})))
    transit_trip_count = int(d.get("transit_trip_count",0))
    transit_transfer_count = int(d.get("transit_transfer_count",0))
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
    player_pos=CityAccess.safe_point(self,player_pos)
    if not active_job.is_empty() and Vector2(active_job.get("target",Vector2.ZERO))!=Vector2.ZERO:
        active_job["target"]=CityAccess.safe_point(self,Vector2(active_job.target))
    if not active_npc_contract.is_empty() and str(active_npc_contract.get("kind",""))=="visit":
        active_npc_contract["target"]=CityAccess.safe_point(self,Vector2(active_npc_contract.get("target",player_pos)))

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
    b.add_theme_font_size_override("font_size",27)
    b.pressed.connect(callback)
    return b

func _clear_commerce_actions() -> void:
    for child in commerce_actions.get_children():
        commerce_actions.remove_child(child)
        child.queue_free()

func _open_commerce(title: String, info: String) -> void:
    commerce_title.text = title
    commerce_info.text = info
    dialogue_panel.visible=false
    map_open=false
    missions_open=false
    collection_open=false
    commerce_panel.visible = true
    _clear_commerce_actions()
    _sync_modal_ui()

func _close_commerce() -> void:
    commerce_panel.visible = false
    _sync_modal_ui()

func _use_interior_feature() -> void:
    if commerce_panel.visible:
        return
    if interior_kind in ["roof","sublevel"]:
        _activate_vertical_feature()
    elif interior_kind in ["restaurant","cafe","bar"]:
        _open_restaurant_menu()
    elif interior_kind=="shop":
        _open_shop_menu()
    elif interior_kind in ["garage","workshop"]:
        _open_garage_menu()
    elif interior_kind=="home":
        _open_home_garage_menu()
    elif interior_kind=="hospital":
        energy=100.0
        _play_sfx("collect")
        _notify("Triage abgeschlossen · Energie vollständig regeneriert.")
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
    var type_roll: int = (jobs_done+index+rng.randi_range(0,6))%7
    if type_roll==0:
        var targets := [Vector2(23800,1600),Vector2(13200,6150),Vector2(7900,12600),Vector2(18400,9100),Vector2(4200,15100),Vector2(23200,15100)]
        var target: Vector2 = targets[rng.randi_range(0,targets.size()-1)]
        var km_factor: float = source.distance_to(target)/1000.0
        var pay: int = clampi(int(55.0+km_factor*13.0),60,190)
        active_job={"kind":"delivery","title":"Stadtlieferung","target":target,"pay":pay}
    elif type_roll==1:
        var photo_target := _next_photo_target()
        if photo_target==Vector2.ZERO:
            var replay_target := _next_hack_replay_target()
            active_job={"kind":"hack_replay","title":"Media Security Audit","target":replay_target,"start":hack_replays,"goal":1,"pay":108}
        else:
            active_job={"kind":"photo","title":"PMDD-Fotosurvey","target":photo_target,"start":photo_count,"goal":1,"pay":95}
    elif type_roll==2:
        var hack_target := _next_hack_replay_target()
        active_job={"kind":"hack_replay","title":"Security Regression Test","target":hack_target,"start":hack_replays,"goal":1,"pay":105}
    elif type_roll==3:
        active_job={"kind":"transit","title":"ÖPNV Qualitätscheck","target":_nearest_transit_stop_pos(source),"start":transit_trip_count,"goal":1,"pay":75}
    elif type_roll==4:
        var unvisited := _next_unvisited_district_center()
        if unvisited==Vector2.ZERO:
            var fallback_district: Dictionary = districts[(jobs_done+index)%districts.size()]
            unvisited=Vector2((fallback_district.rect as Rect2).get_center())
        active_job={"kind":"district","title":"District Survey","target":unvisited,"goal":1,"pay":90}
    elif type_roll==5:
        var signal_target := _next_signal_job_target()
        if signal_target==Vector2.ZERO:
            var replay_target := _next_hack_replay_target()
            active_job={"kind":"hack_replay","title":"Fallback Security Audit","target":replay_target,"start":hack_replays,"goal":1,"pay":110}
        else:
            active_job={"kind":"signal","title":"Street-Signal Survey","target":signal_target,"start":scan_collect_count,"goal":1,"pay":88}
    else:
        active_job={"kind":"race","title":"Timed Mobility Audit","target":_next_race_job_target(),"start":race_wins,"goal":1,"pay":128}
    if Vector2(active_job.target)!=Vector2.ZERO:
        active_job["target"]=CityAccess.safe_point(self,Vector2(active_job.target))
    _play_sfx("mission")
    _show_reward_popup("STADTAUFTRAG",str(active_job.title)+"\nBelohnung: %d CR" % int(active_job.pay),Color("#8de9aa"))
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

func _next_signal_job_target() -> Vector2:
    for sp in scan_points:
        if not bool(sp.taken):
            return Vector2(sp.pos)
    return Vector2.ZERO

func _next_race_job_target() -> Vector2:
    for rr in race_sites:
        if not bool(race_completed.get(str(rr.id),false)):
            return Vector2(rr.pos)
    if race_sites.is_empty():
        return Vector2.ZERO
    return Vector2(race_sites[(jobs_done+race_wins)%race_sites.size()].pos)

func _nearest_transit_stop_pos(from: Vector2) -> Vector2:
    var best: float = INF
    var out := Vector2.ZERO
    for st in transit_stops:
        var p := Vector2(st.pos)
        if not CityAccess.connected(self,p,14): continue
        var d: float = from.distance_to(p)
        if d<best:
            best=d
            out=p
    return out

func _next_unvisited_district_center() -> Vector2:
    for d in districts:
        var name := str(d.name)
        if not bool(visited_districts.get(name,false)):
            return Vector2(district_access_points.get(name,(d.rect as Rect2).get_center()))
    return Vector2.ZERO

func _check_active_job_progress() -> void:
    if active_job.is_empty():
        return
    var kind := str(active_job.get("kind","delivery"))
    var done: bool = false
    if kind=="photo":
        done=(photo_count-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done and photo_count<photo_points.size():
            active_job["target"]=_next_photo_target()
    elif kind=="hack_replay":
        done=(hack_replays-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done:
            active_job["target"]=_next_hack_replay_target()
    elif kind=="transit":
        done=(transit_trip_count-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
    elif kind=="district":
        done=player_pos.distance_to(Vector2(active_job.get("target",Vector2.ZERO)))<260.0
    elif kind=="signal":
        done=(scan_collect_count-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done:
            active_job["target"]=_next_signal_job_target()
    elif kind=="race":
        done=(race_wins-int(active_job.get("start",0)))>=int(active_job.get("goal",1))
        if not done and active_race.is_empty():
            active_job["target"]=_next_race_job_target()
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
        ["photos_score",_photo_total_score()>=4500,300,"Photo Virtuoso"],
        ["cars_5",driven_classes.size()>=5,75,"Class Explorer"],
        ["cars_all",driven_classes.size()>=VEHICLE_CLASSES.size(),220,"Full Garage"],
        ["districts_15",visited_districts.size()>=15,85,"Urban Explorer"],
        ["districts_all",visited_districts.size()>=districts.size() and districts.size()>0,220,"Every District"],
        ["hacks_8",_completed_hack_count()>=8,90,"Security Runner"],
        ["hacks_all",_completed_hack_count()>=mission_sites.size() and mission_sites.size()>0,230,"Security Master"],
        ["races_3",race_completed.size()>=3,110,"Street Trialist"],
        ["races_all",race_completed.size()>=race_sites.size() and race_sites.size()>0,240,"City Circuit"],
        ["jobs_10",jobs_done>=10,120,"City Professional"],
        ["jobs_25",jobs_done>=25,260,"City Professional II"],
        ["tuning_12",_total_upgrade_count()>=12,210,"Tuning Specialist"],
        ["citylife_4",micro_event_seen.size()>=4,55,"City Regular"],
        ["citylife_8",micro_event_seen.size()>=8,110,"Local Pulse"],
        ["citylife_all",micro_event_seen.size()>=city_micro_events.size() and city_micro_events.size()>0,190,"Megacity Insider"]
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

func _closest_uncollected(items: Array, field: String) -> Vector2:
    var result:=Vector2.ZERO
    var best:=INF
    for item in items:
        if bool(item.get(field,false)):
            continue
        var pos:=Vector2(item.pos)
        var distance:=player_pos.distance_squared_to(pos)
        if distance<best:
            best=distance
            result=pos
    return result

func _localized_action(action: String) -> String:
    return {"INTERACT":"AKTION","ENTER":"EINTRETEN","EXIT":"VERLASSEN","USE":"BENUTZEN","EXIT CAR":"AUSSTEIGEN","ENTER CAR":"EINSTEIGEN","PHOTO CHALLENGE":"FOTO-SUCHE","PHOTO REPLAY":"FOTO WIEDERHOLEN","COLLECT":"BERGEN","OPEN SECRET":"ÖFFNEN","PROPERTY":"WOHNUNG","DELIVER":"ABGEBEN","JOBS":"AUFTRÄGE","SIGIL":"SICHERN","CACHE":"BERGEN","ENTER OPENAI HQ":"HQ BETRETEN"}.get(action,action)

func _objective_action() -> String:
    if not active_race.is_empty():
        return "Nächsten Kontrollpunkt passieren"
    if not active_job.is_empty():
        return str(active_job.get("task","Zum markierten Ziel fahren und den Auftrag erfüllen"))
    if not active_npc_contract.is_empty():
        if str(active_npc_contract.kind)=="cache": return "Datenkoffer bergen · %d / %d Archive gefunden" % [maxi(0,cache_count-int(active_npc_contract.get("start",0))),int(active_npc_contract.goal)]
        return _contract_description(active_npc_contract)
    if native_chapters.is_empty():
        return "Straßen, Dächer und versteckte Perspektiven erkunden"
    var chapter: Dictionary=native_chapters[mini(native_chapter,native_chapters.size()-1)]
    var kind:=str(chapter.kind)
    var near:=_nearest_interactable()
    if not near.is_empty() and _current_objective_pos().distance_to(player_pos)<90:
        return "AKTION · "+_localized_action(str(near.get("action","BERGEN")))
    return {"frag":"Zum leuchtenden Signal gehen und BERGEN tippen","secret":"Perspektive ändern, bis das Versteck sichtbar wird","cache":"Datenkoffer finden und öffnen","glyph":"Stadtsigil am markierten Ort sichern","hack":"Terminal erreichen und sein Rätsel lösen","hack_count":"Ein noch offenes Terminal hacken","photo":"FOTO-SUCHE starten · drei Motive finden","vehicles":"Ein neues Fahrzeug ausprobieren","relay":"Dachzugang finden und Relay aktivieren","sublevel":"Untergrundzugang finden und Knoten aktivieren","npc":"Mit dem markierten Kontakt sprechen"}.get(kind,str(chapter.get("desc","Ziel erreichen")))

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
    if not active_job.is_empty():
        var job_target := Vector2(active_job.get("target",Vector2.ZERO))
        if job_target!=Vector2.ZERO:
            return job_target
    if native_chapters.is_empty():
        return Vector2.ZERO
    var c: Dictionary = native_chapters[mini(native_chapter,native_chapters.size()-1)]
    var kind := str(c.kind)
    if kind=="frag":
        return _closest_uncollected(fragments,"taken")
    elif kind=="secret":
        return _closest_uncollected(secrets,"found")
    elif kind=="cache":
        return _closest_uncollected(caches,"taken")
    elif kind=="glyph":
        return _closest_uncollected(glyphs,"taken")
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
            if str(l.kind)=="openai_hq": return Vector2(l.pos)+Vector2(0,float(l.size.y)*0.5+48)
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
        return _closest_uncollected(caches+glyphs,"taken")
    elif kind=="hack_replays":
        return _next_hack_replay_target()
    elif kind=="paint":
        for st in storefronts:
            if str(st.kind) in ["garage","workshop"]: return Vector2(st.pos)
    elif kind in ["property","stored_car"]:
        if not property_sites.is_empty(): return Vector2(property_sites[0].pos)
    elif kind=="citylife":
        return _next_citylife_target(false)
    elif kind=="cityhelp":
        return _next_citylife_target(true)
    return Vector2.ZERO

func _current_objective_label() -> String:
    if not active_race.is_empty():
        var rr: Dictionary = race_sites[int(active_race.index)]
        return "RENNEN · %s" % str(rr.name)
    if not active_npc_contract.is_empty():
        return str(active_npc_contract.get("title","Persönlicher Auftrag"))
    if not active_job.is_empty():
        return "JOB · %s" % str(active_job.get("title","Stadtauftrag"))
    if native_chapters.is_empty():
        return "ERKUNDUNG"
    return str(native_chapters[mini(native_chapter,native_chapters.size()-1)].title)

func _draw_mission_compass() -> void:
    if main_menu_active or map_open or missions_open or collection_open or interior_active or minigame_open or dialogue_panel.visible or commerce_panel.visible:
        return
    var target:=_current_objective_pos()
    if target==Vector2.ZERO:
        return
    var point:=_project(target)
    var screen:=get_viewport_rect().size
    var bounds:=Rect2(Vector2(70,500),screen-Vector2(140,1010))
    var accent:=Color("#73f3ce") if active_race.is_empty() else Color("#ffd36b")
    var center:=_project(player_pos)
    if bounds.has_point(point):
        var radius: float=17*world_zoom
        draw_arc(point,radius,0,TAU,48,Color(accent.r,accent.g,accent.b,0.55),1.5*world_zoom,true)
        var pulse:=0.5+0.5*sin(Time.get_ticks_msec()/320.0)
        draw_arc(point,radius+4*world_zoom*pulse,0,TAU,48,Color(accent.r,accent.g,accent.b,0.25*(1-pulse)),world_zoom,true)
        return
    var delta:=point-center
    var edge_ratio: float=1.0
    if delta.x>0: edge_ratio=minf(edge_ratio,(bounds.end.x-center.x)/delta.x)
    elif delta.x<0: edge_ratio=minf(edge_ratio,(bounds.position.x-center.x)/delta.x)
    if delta.y>0: edge_ratio=minf(edge_ratio,(bounds.end.y-center.y)/delta.y)
    elif delta.y<0: edge_ratio=minf(edge_ratio,(bounds.position.y-center.y)/delta.y)
    var anchor:=center+delta*clampf(edge_ratio,0,1)
    var angle:=delta.angle()+PI*0.5
    var arrow:=PackedVector2Array([Vector2(0,-17),Vector2(11,12),Vector2(0,6),Vector2(-11,12)])
    for i in range(arrow.size()):
        arrow[i]=arrow[i].rotated(angle)+anchor
    draw_circle(anchor,28,Color(0.025,0.075,0.10,0.87))
    draw_colored_polygon(arrow,accent)
    draw_string(ThemeDB.fallback_font,anchor+Vector2(-65,49),"%d m" % int(player_pos.distance_to(target)/10),HORIZONTAL_ALIGNMENT_CENTER,130,20,Color("#d9f5ef"))

func _toggle_map() -> void:
    if map_open: _close_overview()
    else: _open_overview("map")

func _toggle_collection() -> void:
    if collection_open: _close_overview()
    else: _open_overview("collection")

func _toggle_missions() -> void:
    if missions_open: _close_overview()
    else: _open_overview("missions")

func _map_point(world_pos: Vector2, rect: Rect2) -> Vector2:
    return rect.position + Vector2(world_pos.x/WORLD_SIZE.x*rect.size.x,world_pos.y/WORLD_SIZE.y*rect.size.y)

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

func _micro_event_help_count() -> int:
    var count:=0
    for value in micro_event_choices.values():
        if str(value)=="GEHOLFEN":
            count+=1
    return count

func _next_citylife_target(help_only: bool = false) -> Vector2:
    var fallback:=Vector2.ZERO
    var fallback_dist:=999999.0
    for i in range(city_micro_events.size()):
        var event: Dictionary=city_micro_events[i]
        var label:=str(event.label)
        var qualifies:=not bool(micro_event_seen.get(label,false))
        if help_only:
            qualifies=str(micro_event_choices.get(label,""))!="GEHOLFEN"
        if not qualifies:
            continue
        var pos:=Vector2(event.pos)
        var dist:=player_pos.distance_to(pos)
        if _micro_event_active(i,event) and dist<fallback_dist:
            return pos
        if dist<fallback_dist:
            fallback=pos
            fallback_dist=dist
    return fallback

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
    if kind=="photo_score": return mini(_photo_total_score(),int(c.goal))
    if kind=="vehicles": return mini(driven_classes.size(),int(c.goal))
    if kind=="districts": return mini(visited_districts.size(),int(c.goal))
    if kind=="hack_count": return mini(_completed_hack_count(),int(c.goal))
    if kind=="collector": return mini(cache_count+glyph_count,int(c.goal))
    if kind=="archive": return mini(cache_count+glyph_count+photo_count+scan_collect_count,int(c.goal))
    if kind=="scan_collect": return mini(scan_collect_count,int(c.goal))
    if kind=="hack_replays": return mini(hack_replays,int(c.goal))
    if kind=="races": return mini(race_completed.size(),int(c.goal))
    if kind=="upgrades": return mini(_total_upgrade_count(),int(c.goal))
    if kind=="citylife": return mini(micro_event_seen.size(),int(c.goal))
    if kind=="cityhelp": return mini(_micro_event_help_count(),int(c.goal))
    return 1

func _photo_total_score() -> int:
    var total := 0
    for key in photo_scores.keys():
        total+=int(photo_scores[key])
    return total

func _photo_spot_score(id: String) -> int:
    var total := 0
    for i in range(3):
        total+=int(photo_scores.get("%s_%d" % [id,i],0))
    return total

func _total_npc_trust() -> int:
    var total := 0
    for key in npc_trust.keys():
        total+=int(npc_trust[key])
    return total

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

func _weather_state() -> String:
    var sequence := ["clear","clear","mist","clear","rain","rain","clear","storm","rain","clear","mist","clear"]
    var slot := int(floor(world_clock/1.5)) % sequence.size()
    return str(sequence[slot])

func _weather_label() -> String:
    var state := _weather_state()
    if state=="mist": return "Nebel"
    if state=="rain": return "Regen"
    if state=="storm": return "Gewitter"
    return "Klar"

func _weather_strength() -> float:
    var state := _weather_state()
    var base := 0.0
    if state=="mist": base=0.45
    elif state=="rain": base=0.72
    elif state=="storm": base=1.0
    var style := str(_district_at(player_pos).get("style","center"))
    if state=="mist" and style in ["canal","coast","harbor"]:
        base=minf(1.0,base+0.18)
    return base

func _micro_event_active(index: int, event: Dictionary) -> bool:
    var slot := int(floor(world_clock/1.35))
    var kind := str(event.type)
    if kind in ["drone_show","foodtruck","boardwalk_music"] and world_clock>7.0 and world_clock<18.0:
        return false
    if kind in ["yoga","run_club"] and (world_clock<5.5 or world_clock>20.5):
        return false
    return ((slot + index*3) % 7) in [0,1,4]

func _draw_city_micro_events() -> void:
    for i in range(city_micro_events.size()):
        var e: Dictionary = city_micro_events[i]
        if not _micro_event_active(i,e):
            continue
        var wp := Vector2(e.pos)
        if player_pos.distance_to(wp)>1750.0:
            continue
        var p := _project(wp,8)
        var accent: Color = Color(e.accent)
        var pulse := 0.78+0.22*sin(Time.get_ticks_msec()/360.0+float(i))
        var kind := str(e.type)
        if kind=="busker" or kind=="boardwalk_music":
            draw_circle(p+Vector2(0,-12),6,Color("#d8ad8e"))
            draw_line(p+Vector2(0,-6),p+Vector2(0,14),Color("#526774"),4.0,true)
            draw_line(p+Vector2(0,2),p+Vector2(15,9),Color("#d6a66b"),3.0,true)
            draw_arc(p+Vector2(18,-7),5,0,TAU,12,Color(accent.r,accent.g,accent.b,0.75),2.0,true)
            draw_string(ThemeDB.fallback_font,p+Vector2(20,-19),"♪",HORIZONTAL_ALIGNMENT_LEFT,20,14,accent)
        elif kind=="foodtruck":
            draw_rect(Rect2(p-Vector2(30,14),Vector2(60,28)),Color("#384650"),true)
            draw_rect(Rect2(p-Vector2(10,10),Vector2(28,12)),Color(accent.r,accent.g,accent.b,0.72),true)
            draw_circle(p+Vector2(-19,17),6,Color("#151a1d"))
            draw_circle(p+Vector2(19,17),6,Color("#151a1d"))
            draw_line(p+Vector2(-8,-16),p+Vector2(24,-16),accent,4.0,true)
        elif kind=="yoga":
            for k in range(4):
                var q := p+Vector2(float(k-2)*22.0,float(k%2)*10.0)
                draw_rect(Rect2(q-Vector2(9,3),Vector2(18,6)),Color(accent.r,accent.g,accent.b,0.34),true)
                draw_circle(q+Vector2(0,-8),4,Color("#d7af93"))
        elif kind=="drone_show":
            for k in range(7):
                var a := float(Time.get_ticks_msec())/700.0+float(k)*TAU/7.0
                var q := p+Vector2(cos(a)*42.0,sin(a*1.3)*24.0-28.0)
                draw_circle(q,4,accent)
                draw_circle(q,10,Color(accent.r,accent.g,accent.b,0.08))
        elif kind=="street_market":
            for k in range(3):
                var q := p+Vector2(float(k-1)*34.0,0)
                draw_rect(Rect2(q-Vector2(14,4),Vector2(28,18)),Color("#594437"),true)
                draw_colored_polygon(PackedVector2Array([q+Vector2(-17,-4),q+Vector2(17,-4),q+Vector2(12,-16),q+Vector2(-12,-16)]),Color(accent.r,accent.g,accent.b,0.68))
        elif kind in ["maintenance","repair_crew"]:
            for k in range(3):
                var q := p+Vector2(float(k-1)*18.0,12)
                draw_colored_polygon(PackedVector2Array([q+Vector2(-5,6),q+Vector2(5,6),q+Vector2(2,-7),q+Vector2(-2,-7)]),Color("#e47d35"))
            draw_rect(Rect2(p+Vector2(-20,-20),Vector2(40,12)),Color("#3a454a"),true)
            draw_line(p+Vector2(-18,-14),p+Vector2(18,-14),accent,2.5,true)
        elif kind=="run_club":
            for k in range(5):
                var q := p+Vector2(float(k-2)*15.0,sin(Time.get_ticks_msec()/180.0+float(k))*5.0)
                draw_circle(q+Vector2(0,-10),4,Color("#d7aa8c"))
                draw_line(q+Vector2(0,-5),q+Vector2(0,9),Color(accent.r,accent.g,accent.b,0.78),3.0,true)
        elif kind=="street_art":
            draw_rect(Rect2(p-Vector2(34,25),Vector2(68,50)),Color("#25323a"),true)
            for k in range(5):
                draw_line(p+Vector2(-27,float(k)*8-16),p+Vector2(27-float(k)*6,float(k)*5-12),[accent,Color("#ff80ef"),Color("#67d9ff")][k%3],3.0,true)
        elif kind=="fountain_show":
            draw_circle(p,28,Color("#244957"))
            for k in range(-2,3):
                var x := float(k)*9.0
                draw_arc(p+Vector2(x,0),18.0+abs(float(k))*4.0,PI,TAU,20,Color(accent.r,accent.g,accent.b,0.35+0.22*pulse),2.0,true)
        elif kind=="campus_group":
            for k in range(6):
                var a := float(k)*TAU/6.0
                var q := p+Vector2.from_angle(a)*24.0
                draw_circle(q,5,Color("#d6ad92"))
                draw_line(q+Vector2(0,5),q+Vector2(0,16),Color(accent.r,accent.g,accent.b,0.55),3.0,true)
        if kind in ["busker","boardwalk_music","street_art","drone_show","fountain_show"] and graphics_quality>=1:
            var spectator_count:=4 if graphics_quality==1 else 7
            for sk in range(spectator_count):
                var angle:=float(sk)*TAU/float(spectator_count)
                var radius:=58.0+float(sk%2)*12.0
                var spectator_pos:=wp+Vector2.from_angle(angle)*radius
                _draw_social_person(spectator_pos,accent,"phone" if sk%3==0 else "idle",i*101+sk)
        var event_distance := player_pos.distance_to(wp)
        if event_distance<520.0:
            var seen := bool(micro_event_seen.get(str(e.label),false))
            var tag := "LIVE · %s" % str(e.label)
            if not seen:
                tag="NEU · "+tag
            draw_string(ThemeDB.fallback_font,p+Vector2(-100,48),tag,HORIZONTAL_ALIGNMENT_CENTER,200,12,Color(accent.r,accent.g,accent.b,0.92))
        if event_distance<135.0:
            draw_arc(p,40.0+sin(Time.get_ticks_msec()/230.0)*3.0,0,TAU,32,Color(accent.r,accent.g,accent.b,0.24),2.0,true)

func _draw_ambient_overlay() -> void:
    var size := get_viewport_rect().size
    var daylight := clampf(sin((world_clock-6.0)/24.0*TAU)*0.5+0.5,0.0,1.0)
    var night_alpha := lerpf(0.30,0.035,daylight)
    draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.055,0.12,night_alpha))
    var dusk := maxf(0.0,1.0-abs(world_clock-19.25)/2.25)
    var dawn := maxf(0.0,1.0-abs(world_clock-6.25)/1.65)
    var warm := maxf(dusk,dawn)
    if warm>0.0:
        draw_rect(Rect2(Vector2.ZERO,size),Color(0.42,0.18,0.07,0.035*warm))

    var weather := _weather_state()
    var weather_strength := _weather_strength()
    if weather=="mist":
        draw_rect(Rect2(Vector2.ZERO,size),Color(0.70,0.82,0.85,0.07+weather_strength*0.08))
        for k in range(5):
            var yy := fposmod(float(k*510)+float(Time.get_ticks_msec())*0.012,size.y+260.0)-130.0
            draw_rect(Rect2(-80,yy,size.x+160,115),Color(0.72,0.82,0.84,0.018+0.018*weather_strength),true)
    elif weather in ["rain","storm"]:
        var rain_count := 44 if graphics_quality>=2 else 24
        var speed := 0.58 if weather=="rain" else 0.88
        for i in range(rain_count):
            var seed := float(i*977)
            var x := fposmod(seed*1.71+float(Time.get_ticks_msec())*0.11,size.x+120.0)-60.0
            var y := fposmod(seed*0.83+float(Time.get_ticks_msec())*speed,size.y+180.0)-90.0
            var len := 20.0+float(i%5)*5.0
            draw_line(Vector2(x,y),Vector2(x-8.0,y+len),Color(0.70,0.86,0.94,0.12+weather_strength*0.13),1.4,true)
        draw_rect(Rect2(Vector2.ZERO,size),Color(0.08,0.14,0.19,0.04+weather_strength*0.035))
        if weather=="storm":
            var lightning := maxf(0.0,sin(float(Time.get_ticks_msec())/1730.0*TAU)-0.965)*15.0
            if lightning>0.0:
                draw_rect(Rect2(Vector2.ZERO,size),Color(0.78,0.88,1.0,minf(0.18,lightning*0.08)))

    if scan_time>0.0 and not interior_active:
        var scan_strength := clampf(scan_time/1.8,0.0,1.0)
        var radius := lerpf(70.0,minf(size.x,size.y)*0.46,1.0-scan_strength)
        draw_arc(size*0.5,radius,0,TAU,72,Color(0.35,0.95,0.86,0.13*scan_strength),3.0,true)
        draw_arc(size*0.5,radius+18.0,0,TAU,72,Color(0.35,0.75,1.0,0.07*scan_strength),1.5,true)
    if current_vehicle>=0 and abs(vehicle_velocity)>float(VEHICLE_SPEEDS.get(str(parked_cars[current_vehicle]["class"]),420.0))*0.62:
        var speed_strength := clampf(abs(vehicle_velocity)/maxf(1.0,float(VEHICLE_SPEEDS.get(str(parked_cars[current_vehicle]["class"]),420.0)))-0.55,0.0,0.45)
        for i in range(12):
            var yy := fposmod(float(i*181)+float(Time.get_ticks_msec())*0.055,size.y)
            var left_side := i%2==0
            var x0 := 22.0 if left_side else size.x-22.0
            var dir := 1.0 if left_side else -1.0
            draw_line(Vector2(x0,yy),Vector2(x0+dir*(32.0+float(i%4)*9.0),yy-12.0),Color(0.72,0.90,1.0,0.10+speed_strength*0.20),2.0,true)
    if (_weather_state() in ["rain","storm"]) and (world_clock>18.0 or world_clock<6.5):
        draw_rect(Rect2(0,size.y*0.62,size.x,size.y*0.38),Color(0.04,0.10,0.14,0.025),true)
        for glow_i in range(5):
            var gx:=fposmod(float(glow_i*337)+float(Time.get_ticks_msec())*0.006,size.x)
            draw_circle(Vector2(gx,size.y*0.78+float(glow_i%2)*70),28+float(glow_i%3)*10,Color(0.22,0.52,0.72,0.010))
    var edge_alpha := 0.13
    draw_rect(Rect2(0,0,size.x,72),Color(0,0,0,edge_alpha))
    draw_rect(Rect2(0,size.y-92,size.x,92),Color(0,0,0,edge_alpha))
    draw_rect(Rect2(0,0,18,size.y),Color(0,0,0,0.06))
    draw_rect(Rect2(size.x-18,0,18,size.y),Color(0,0,0,0.06))

func _draw_touch_controls() -> void:
    var size := get_viewport_rect().size
    var center := move_origin if move_touch>=0 else Vector2(128,size.y-156)
    var knob := center+move_vec*72
    draw_circle(center,76,Color(0.025,0.065,0.09,0.64))
    draw_arc(center,76,0,TAU,48,Color(0.45,0.95,0.82,0.42),2,true)
    draw_circle(knob,27,Color(0.45,0.95,0.82,0.58))
    if current_vehicle>=0:
        draw_string(ThemeDB.fallback_font,center+Vector2(-90,-100),"FAHRTRICHTUNG",HORIZONTAL_ALIGNMENT_CENTER,180,20,Color("#d4ede5"))
        draw_string(ThemeDB.fallback_font,center+Vector2(-100,114),"Loslassen: bremsen",HORIZONTAL_ALIGNMENT_CENTER,200,19,Color("#b2cbd2"))
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
    var frame_y:=0.0
    if not interior_active and not photo_mode:
        if current_vehicle>=0:
            frame_y=42.0
        elif transit_riding>=0:
            frame_y=56.0
        else:
            frame_y=104.0
    screen_center.y+=frame_y
    var projection_tilt:=Vector2(0.22,-0.52)+view_amount*parallax_strength*0.43
    projection_tilt*=1.0+camera_head_depth*0.35
    projection_tilt.y=clampf(projection_tilt.y,-1.30,-0.16)
    var par := projection_tilt*z
    var shake := Vector2.ZERO
    if camera_shake_strength>0.01:
        shake=Vector2(sin(camera_shake_phase*1.7),cos(camera_shake_phase*2.3))*camera_shake_strength
    return (world - camera_pos + par) * world_zoom + screen_center + shake

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
    return CityAccess.blocked(self,p,radius)

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
