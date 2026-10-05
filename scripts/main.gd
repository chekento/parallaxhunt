extends Node2D

const WORLD_SIZE := Vector2(26000.0, 18000.0)
const WALK_SPEED := 165.0
const VEHICLE_SPEEDS := {"micro": 340.0, "sedan": 430.0, "van": 365.0, "sport": 545.0}
const VEHICLE_SIZES := {"micro": Vector2(36, 19), "sedan": Vector2(44, 22), "van": Vector2(50, 25), "sport": Vector2(48, 20)}

var rng := RandomNumberGenerator.new()
var districts: Array = []
var roads: Array = []
var parks: Array = []
var waters: Array = []
var buildings: Array = []
var trees: Array = []
var parked_cars: Array = []
var traffic: Array = []
var street_lights: Array = []
var street_props: Array = []
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
var current_district := ""
var camera_status := "Sensor-PMDD"
var world_clock := 19.15

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
var interact_button: Button
var scan_button: Button
var sfx_player: AudioStreamPlayer
var sounds := {}
var last_secret_sound_ms := -99999

func _ready() -> void:
    rng.seed = 420042
    _build_districts()
    _build_roads()
    _build_parks()
    _build_water()
    _generate_city()
    _generate_traffic()
    _generate_visual_props()
    _generate_transit()
    _generate_collectibles()
    _build_ui()
    _build_audio()
    _bootstrap_android_camera()
    camera_pos = player_pos
    current_district = _district_at(player_pos).get("name", "Megacity")
    _update_ui()
    queue_redraw()

func _process(delta: float) -> void:
    _update_sensor(delta)
    _update_player(delta)
    _update_traffic(delta)
    _update_pedestrians(delta)
    _update_transit(delta)
    world_clock = fposmod(world_clock + delta * 0.018, 24.0)
    scan_time = maxf(0.0, scan_time - delta)
    view_amount = view_amount.lerp((sensor_view * 0.72 + view_touch * 0.95).limit_length(1.0), minf(1.0, delta * 8.0))
    camera_pos = camera_pos.lerp(player_pos, minf(1.0, delta * (4.0 if current_vehicle >= 0 else 7.0)))
    _update_secrets()
    _update_district()
    _update_ui()
    queue_redraw()

func _input(event: InputEvent) -> void:
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
            move_vec = delta_move.limit_length(72.0) / 72.0
        elif d.index == look_touch:
            look_now = d.position
            var delta_look := look_now - look_origin
            view_touch = Vector2(delta_look.x, delta_look.y).limit_length(150.0) / 150.0
    elif event is InputEventKey and event.pressed:
        if event.is_action_pressed("interact"):
            _interact()
        elif event.is_action_pressed("scan"):
            _scan()

func _build_districts() -> void:
    districts = [
        {"name":"Altstadt", "rect":Rect2(0,0,5200,4200), "ground":Color("#1d252d"), "wall":Color("#76584b"), "roof":Color("#9b7560"), "accent":Color("#ffcd8a"), "style":"heritage"},
        {"name":"Glass Quarter", "rect":Rect2(5200,0,5200,4200), "ground":Color("#102532"), "wall":Color("#285166"), "roof":Color("#39758d"), "accent":Color("#67d9ff"), "style":"glass"},
        {"name":"Nordpark", "rect":Rect2(10400,0,5200,4200), "ground":Color("#182a22"), "wall":Color("#395744"), "roof":Color("#55745b"), "accent":Color("#8ff0b4"), "style":"green"},
        {"name":"Solar Heights", "rect":Rect2(15600,0,10400,4200), "ground":Color("#222a2d"), "wall":Color("#596140"), "roof":Color("#7f8953"), "accent":Color("#f1e36f"), "style":"solar"},
        {"name":"Kanäle", "rect":Rect2(0,4200,5200,5000), "ground":Color("#10242b"), "wall":Color("#354e59"), "roof":Color("#4b6570"), "accent":Color("#64e7e4"), "style":"canal"},
        {"name":"Zentrum", "rect":Rect2(5200,4200,5200,5000), "ground":Color("#17222b"), "wall":Color("#485966"), "roof":Color("#657786"), "accent":Color("#9ad5ff"), "style":"center"},
        {"name":"Hafen", "rect":Rect2(10400,4200,5200,5000), "ground":Color("#20252a"), "wall":Color("#55473e"), "roof":Color("#736155"), "accent":Color("#ffb66f"), "style":"harbor"},
        {"name":"Neon Mile", "rect":Rect2(15600,4200,10400,5000), "ground":Color("#1d1930"), "wall":Color("#53375e"), "roof":Color("#764b82"), "accent":Color("#ff80ef"), "style":"neon"},
        {"name":"Gärten", "rect":Rect2(0,9200,6500,8800), "ground":Color("#17271d"), "wall":Color("#425c41"), "roof":Color("#5d7658"), "accent":Color("#9be993"), "style":"garden"},
        {"name":"Universität", "rect":Rect2(6500,9200,6500,8800), "ground":Color("#182131"), "wall":Color("#45516b"), "roof":Color("#65718c"), "accent":Color("#b0c8ff"), "style":"campus"},
        {"name":"Observatorium", "rect":Rect2(13000,9200,6000,8800), "ground":Color("#18182a"), "wall":Color("#413b61"), "roof":Color("#625a88"), "accent":Color("#c3a6ff"), "style":"astro"},
        {"name":"Terminal East", "rect":Rect2(19000,9200,7000,8800), "ground":Color("#20262a"), "wall":Color("#535a60"), "roof":Color("#747c83"), "accent":Color("#d9e5ef"), "style":"terminal"}
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

func _build_parks() -> void:
    parks = [
        {"rect":Rect2(11200,500,2800,1500), "name":"Nordpark", "attraction":"Fountain"},
        {"rect":Rect2(1200,10800,2200,1700), "name":"Garden Commons", "attraction":"Stage"},
        {"rect":Rect2(7600,10400,1900,1400), "name":"Campus Green", "attraction":"Sculpture"},
        {"rect":Rect2(17400,6900,2500,1300), "name":"Neon Plaza", "attraction":"Light Spire"},
        {"rect":Rect2(14600,13700,1800,1400), "name":"Aurora Park", "attraction":"Pavilion"},
        {"rect":Rect2(21600,12300,2100,1250), "name":"Terminal Pocket Park", "attraction":"Clock"}
    ]

func _build_water() -> void:
    waters = [
        {"rect":Rect2(430,4750,720,3600), "tint":Color("#174b61"), "name":"Westkanal"},
        {"rect":Rect2(3500,5050,1050,2700), "tint":Color("#15566a"), "name":"Museumskanal"},
        {"rect":Rect2(11000,6900,3900,780), "tint":Color("#194c61"), "name":"Hafenbecken"},
        {"rect":Rect2(12100,7700,1850,900), "tint":Color("#1b5268"), "name":"Dock Basin"},
        {"rect":Rect2(18000,7300,3100,620), "tint":Color("#25235a"), "name":"Neon Reflecting Pool"}
    ]

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
            if _rect_near_road(rect, 75.0) or _rect_in_park(rect):
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
                trees.append({"pos":tp, "h":rng.randf_range(32,75), "r":rng.randf_range(11,24), "tint":district.accent.lerp(Color("#56a36b"),0.65)})
    for park in parks:
        var pr: Rect2 = park.rect
        for _k in range(38):
            trees.append({"pos":Vector2(rng.randf_range(pr.position.x+40,pr.end.x-40),rng.randf_range(pr.position.y+40,pr.end.y-40)),"h":rng.randf_range(35,82),"r":rng.randf_range(13,26),"tint":Color("#63b878")})
    for _n in range(92):
        var rd = roads[rng.randi_range(0, roads.size()-1)]
        var t_sample := rng.randf()
        var p := _sample_polyline(rd.points, t_sample)
        var tangent := _polyline_tangent(rd.points, t_sample)
        var normal := Vector2(-tangent.y, tangent.x)
        var cls: String = ["micro","sedan","van","sport"][rng.randi_range(0,3)]
        parked_cars.append({"pos":p + normal * rng.randf_range(45,70), "class":cls, "heading":tangent.angle(), "color":_car_color(cls), "occupied":false})

func _generate_traffic() -> void:
    traffic.clear()
    for _i in range(155):
        var road_index := rng.randi_range(0, roads.size()-1)
        var cls: String = ["micro","sedan","van","sport"][rng.randi_range(0,3)]
        traffic.append({"road":road_index, "t":rng.randf(), "speed":rng.randf_range(0.018,0.052), "class":cls, "color":_car_color(cls), "reverse":rng.randf()<0.5})


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
            "phase":rng.randf_range(0,TAU)
        })


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
            "line":"B%d" % (12 + i * 4)
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
            "line":"T%d" % (2 + i)
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
    title.text = "PARALLAX HUNT · NATIVE ALPHA"
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

func _build_audio() -> void:
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -7.0
    add_child(sfx_player)
    sounds["collect"] = _make_chime([659.0, 988.0], [0.06, 0.11], 0.12)
    sounds["secret"] = _make_chime([784.0, 1175.0, 1568.0], [0.09, 0.11, 0.16], 0.16)
    sounds["scan"] = _make_chime([310.0, 465.0, 620.0], [0.05, 0.07, 0.09], 0.09)
    sounds["vehicle"] = _make_chime([180.0, 240.0], [0.06, 0.08], 0.07)

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
            var target := Vector2(g.x / 9.8, -g.y / 9.8) * 0.32
            sensor_view = sensor_view.lerp(target.limit_length(0.58), minf(1.0,delta*3.5))
            return
    sensor_view = sensor_view.lerp(Vector2.ZERO, minf(1.0,delta*2.0))

func _update_player(delta: float) -> void:
    if move_vec.length() < 0.04:
        vehicle_velocity = move_toward(vehicle_velocity, 0.0, delta * 280.0)
        return
    if current_vehicle >= 0:
        var car = parked_cars[current_vehicle]
        var max_speed: float = VEHICLE_SPEEDS[car["class"]]
        var desired_heading := move_vec.angle()
        player_heading = lerp_angle(player_heading, desired_heading, minf(1.0, delta * 4.5))
        vehicle_velocity = move_toward(vehicle_velocity, max_speed * move_vec.length(), delta * max_speed * 1.65)
        var velocity := Vector2.from_angle(player_heading) * vehicle_velocity
        var np := player_pos + velocity * delta
        if not _point_blocked(np, 18.0):
            player_pos = np
        else:
            vehicle_velocity *= 0.2
        car["pos"] = player_pos
        car["heading"] = player_heading
        parked_cars[current_vehicle] = car
    else:
        var velocity2 := move_vec.normalized() * WALK_SPEED * minf(1.0, move_vec.length())
        var np2 := player_pos + velocity2 * delta
        if not _point_blocked(np2, 12.0):
            player_pos = np2
            player_heading = velocity2.angle()
    player_pos.x = clampf(player_pos.x, 20.0, WORLD_SIZE.x-20.0)
    player_pos.y = clampf(player_pos.y, 20.0, WORLD_SIZE.y-20.0)

func _update_traffic(delta: float) -> void:
    for i in range(traffic.size()):
        var c = traffic[i]
        var direction := -1.0 if c.reverse else 1.0
        c.t = fposmod(float(c.t) + float(c.speed) * delta * direction, 1.0)
        traffic[i] = c


func _update_pedestrians(delta: float) -> void:
    for i in range(pedestrians.size()):
        var p = pedestrians[i]
        var direction := -1.0 if p.reverse else 1.0
        p.t = fposmod(float(p.t) + float(p.speed) * delta * direction, 1.0)
        p.phase = fposmod(float(p.phase) + delta * 5.0, TAU)
        pedestrians[i] = p


func _update_transit(delta: float) -> void:
    for i in range(transit_vehicles.size()):
        var tveh = transit_vehicles[i]
        var direction := -1.0 if tveh.reverse else 1.0
        tveh.t = fposmod(float(tveh.t) + float(tveh.speed) * delta * direction, 1.0)
        transit_vehicles[i] = tveh

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
    mission_label.text = "Echoes · %d/10   Secrets · %d/4" % [mission_fragments, mission_secrets]
    detail_label.text = "Move with left thumb. Use right thumb or device tilt to look behind height layers."
    var mode := "On foot"
    if current_vehicle >= 0:
        mode = "Driving · %s" % str(parked_cars[current_vehicle]["class"]).capitalize()
    status_label.text = "%s  ·  %s  ·  Peek %d%%\n%s" % [current_district, mode, int(view_amount.length()*100.0), camera_status]
    var near := _nearest_interactable()
    interact_button.disabled = near.is_empty()
    interact_button.text = "INTERACT" if near.is_empty() else near.get("action","INTERACT")

func _scan() -> void:
    scan_time = 2.2
    _play_sfx("scan")

func _interact() -> void:
    var n := _nearest_interactable()
    if n.is_empty():
        return
    if n.type == "fragment":
        var idx: int = n.index
        if not fragments[idx].taken:
            fragments[idx].taken = true
            mission_fragments += 1
            _play_sfx("collect")
    elif n.type == "secret":
        var si: int = n.index
        if secrets[si].revealed and not secrets[si].found:
            secrets[si].found = true
            mission_secrets += 1
            _play_sfx("secret")
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
    if current_vehicle >= 0:
        return {"type":"car", "index":current_vehicle, "action":"EXIT CAR"}
    var best := {}
    var bd := 999999.0
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
    for k in range(parked_cars.size()):
        if parked_cars[k].occupied:
            continue
        var d3 := player_pos.distance_to(parked_cars[k].pos)
        if d3 < 82.0 and d3 < bd:
            best = {"type":"car","index":k,"action":"ENTER CAR"}
            bd = d3
    return best

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color("#07131b"))
    _draw_district_ground()
    _draw_water()
    _draw_parks()
    _draw_roads()
    _draw_buildings()
    _draw_trees()
    _draw_street_props()
    _draw_pedestrians()
    _draw_traffic()
    _draw_transit()
    _draw_parked_cars()
    _draw_collectibles()
    _draw_player()
    _draw_ambient_overlay()
    _draw_touch_controls()
    _draw_peek_meter()

func _draw_district_ground() -> void:
    for d in districts:
        var r: Rect2 = d.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        draw_rect(Rect2(p, r.size), d.ground)
        var accent: Color = d.accent
        accent.a = 0.06
        if d.style in ["glass","center","neon"]:
            for x in range(int(r.position.x)+100, int(r.end.x), 280):
                var a := _project(Vector2(x,r.position.y))
                var b := _project(Vector2(x,r.end.y))
                draw_line(a,b,accent,2.0)
        elif d.style in ["green","garden"]:
            for i in range(12):
                var cp := _project(r.position + Vector2(180+i*310, 240+(i%3)*220))
                draw_circle(cp, 36+(i%4)*8, accent)


func _draw_water() -> void:
    for w in waters:
        var r: Rect2 = w.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        var tint: Color = w.tint
        draw_rect(Rect2(p,r.size),tint.darkened(0.18))
        var shimmer := Time.get_ticks_msec() / 900.0
        for yy in range(26, int(r.size.y)-20, 54):
            var y := p.y + yy
            var phase := shimmer + float(yy) * 0.025
            var start := p.x + 18 + sin(phase) * 12
            draw_line(Vector2(start,y),Vector2(p.x+r.size.x-20,y+sin(phase*1.7)*4),Color(tint.r+0.12,tint.g+0.18,tint.b+0.22,0.24),2.0,true)
        draw_rect(Rect2(p+Vector2(3,3),r.size-Vector2(6,6)),Color(0.55,0.85,1.0,0.10),false,3.0)

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
        for k in range(3, 98, 6):
            var t := float(k)/100.0
            var wp := _sample_polyline(pts,t)
            var tan := _polyline_tangent(pts,t)
            var c := _project(wp,1.0)
            draw_line(c-tan*14.0,c+tan*14.0,Color(0.92,0.89,0.72,0.48),3.0,true)

func _draw_parks() -> void:
    for park in parks:
        var r: Rect2 = park.rect
        if not _world_rect_visible(r):
            continue
        var p := _project(r.position)
        draw_rect(Rect2(p,r.size),Color("#173d2b"))
        var path := PackedVector2Array([p+Vector2(30,r.size.y*.28),p+Vector2(r.size.x*.32,50),p+Vector2(r.size.x*.58,r.size.y*.73),p+Vector2(r.size.x-40,r.size.y*.52)])
        draw_polyline(path,Color(0.85,0.82,0.62,0.20),12.0,true)
        var c := p + r.size * 0.5
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
    var roof_mode := str(b.get("roof_mode","flat"))
    if style == "heritage" or roof_mode == "pitched":
        var ridge_a := top[0].lerp(top[3],0.5)
        var ridge_b := top[1].lerp(top[2],0.5)
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

func _quad_bilerp(a: Vector2, b: Vector2, c: Vector2, d: Vector2, u: float, v: float) -> Vector2:
    return a.lerp(b,u).lerp(d.lerp(c,u),v)

func _draw_trees() -> void:
    for t in trees:
        if player_pos.distance_to(t.pos) > 1800.0:
            continue
        var b := _project(t.pos,0)
        var c := _project(t.pos,t.h)
        draw_line(b,c,Color("#604b35"),4.0,true)
        draw_circle(c+Vector2(3,6),t.r,Color(0,0,0,0.18))
        draw_circle(c,t.r,t.tint.darkened(0.2))
        draw_circle(c+Vector2(-5,-5),t.r*0.62,t.tint.lightened(0.12))


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
        elif p.type == "attraction":
            _draw_attraction(p)

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
        if player_pos.distance_to(pos) > 1700.0:
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
        var rd = roads[c.road]
        var tt: float = c.t
        var pos := _sample_polyline(rd.points,tt)
        if player_pos.distance_to(pos)>1800:
            continue
        var tangent := _polyline_tangent(rd.points,tt)
        if c.reverse:
            tangent *= -1
        _draw_car(pos,tangent.angle(),c["class"],c.color,false)

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
    var is_tram := tv.kind == "tram"
    var length := 88.0 if is_tram else 74.0
    var width := 24.0 if is_tram else 27.0
    draw_ellipse(center+Vector2(5,8),Vector2(length*0.50,width*0.48),heading,Color(0,0,0,0.19))
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
    var sz: Vector2 = VEHICLE_SIZES[cls]
    var center := _project(pos,8)
    var f := Vector2.from_angle(heading)
    var side := Vector2(-f.y,f.x)
    draw_ellipse(center+Vector2(4,7),Vector2(sz.x*.52,sz.y*.42),heading,Color(0,0,0,0.18))
    var nose := 0.58 if cls=="sport" else (0.50 if cls!="micro" else 0.52)
    var rear := 0.46 if cls=="micro" else 0.50
    var pts := PackedVector2Array([
        center+f*sz.x*nose+side*sz.y*.43,
        center+f*sz.x*nose-side*sz.y*.43,
        center-f*sz.x*rear-side*sz.y*.50,
        center-f*sz.x*rear+side*sz.y*.50
    ])
    draw_colored_polygon(pts,color)
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color(1,1,1,0.20),1.2,true)
    var cabin_center := center - f*(3.0 if cls=="sport" else 0.0)
    var cabin_len := sz.x*(0.20 if cls=="micro" else (0.30 if cls=="van" else 0.26))
    var wind_a := cabin_center+f*cabin_len+side*sz.y*.29
    var wind_b := cabin_center+f*cabin_len-side*sz.y*.29
    var wind_c := cabin_center-f*cabin_len-side*sz.y*.29
    var wind_d := cabin_center-f*cabin_len+side*sz.y*.29
    draw_colored_polygon(PackedVector2Array([wind_a,wind_b,wind_c,wind_d]),Color(0.58,0.82,0.92,0.72))
    draw_line(wind_a,wind_b,Color(1,1,1,0.24),1.0)
    var front_l := center+f*sz.x*.49+side*sz.y*.25
    var front_r := center+f*sz.x*.49-side*sz.y*.25
    draw_circle(front_l,2.4,Color("#ffe0a0"))
    draw_circle(front_r,2.4,Color("#ffe0a0"))
    var rear_l := center-f*sz.x*.45+side*sz.y*.25
    var rear_r := center-f*sz.x*.45-side*sz.y*.25
    draw_circle(rear_l,2.2,Color("#ff726f"))
    draw_circle(rear_r,2.2,Color("#ff726f"))
    _draw_car_wheels(center,f,side,sz)
    if cls == "van":
        draw_line(center-f*7-side*sz.y*.44,center-f*7+side*sz.y*.44,Color(1,1,1,0.16),1.5)
        draw_line(center+side*sz.y*.49-f*6,center+side*sz.y*.49+f*10,Color(0.16,0.18,0.20,0.62),2.0)
        draw_line(center-side*sz.y*.49-f*6,center-side*sz.y*.49+f*10,Color(0.16,0.18,0.20,0.62),2.0)
    elif cls == "sport":
        draw_line(center-f*sz.x*.35-side*sz.y*.49,center-f*sz.x*.35+side*sz.y*.49,Color(0.05,0.07,0.09,0.64),2.2)
        draw_line(center+f*sz.x*.20-side*sz.y*.28,center+f*sz.x*.29-side*sz.y*.12,Color(1,1,1,0.15),1.0)
    elif cls == "micro":
        draw_line(center-f*2-side*sz.y*.37,center-f*2+side*sz.y*.37,Color(1,1,1,0.16),1.2)
    else:
        draw_line(center+side*sz.y*.44,center-side*sz.y*.44,Color(1,1,1,0.10),1.0)
    var livery := int(abs(pos.x+pos.y)) % 13
    if livery == 0:
        draw_line(center-f*sz.x*.10-side*sz.y*.45,center-f*sz.x*.10+side*sz.y*.45,Color(0.98,0.88,0.34,0.58),2.0)
    elif livery == 1:
        draw_line(center-f*sz.x*.28,center+f*sz.x*.30,Color(1,1,1,0.16),1.2)
    if not parked:
        var tail := center - f*sz.x*.62
        draw_line(tail,tail-f*24,Color(0.35,0.85,1.0,0.10),4.0,true)

func _draw_car_wheels(center: Vector2, f: Vector2, side: Vector2, sz: Vector2) -> void:
    for ax in [0.28,-0.28]:
        var axle := center + f*sz.x*float(ax)
        var w1 := axle + side*sz.y*.52
        var w2 := axle - side*sz.y*.52
        draw_line(w1-f*4,w1+f*4,Color(0.05,0.05,0.06,0.92),2.4)
        draw_line(w2-f*4,w2+f*4,Color(0.05,0.05,0.06,0.92),2.4)

func draw_ellipse(center: Vector2, radii: Vector2, rotation: float, color: Color) -> void:
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
    var p := _project(player_pos,18)
    var f := Vector2.from_angle(player_heading)
    var s := Vector2(-f.y,f.x)
    draw_circle(p+Vector2(3,8),10,Color(0,0,0,0.26))
    var body := PackedVector2Array([p+f*15,p-f*8+s*9,p-f*13,p-f*8-s*9])
    draw_colored_polygon(body,Color("#f2f7fb"))
    draw_circle(p+f*1,4,Color("#73f3ce"))


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
    return world - camera_pos + screen_center + par

func _district_at(p: Vector2) -> Dictionary:
    for d in districts:
        if (d.rect as Rect2).has_point(p):
            return d
    return districts[0]

func _world_rect_visible(r: Rect2) -> bool:
    var screen := Rect2(_project(r.position),r.size).grow(300)
    return screen.intersects(Rect2(Vector2.ZERO,get_viewport_rect().size))

func _point_in_building(p: Vector2) -> bool:
    for b in buildings:
        if (b.rect as Rect2).has_point(p):
            return true
    return false

func _point_blocked(p: Vector2, radius: float) -> bool:
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
        "sedan":[Color("#6aa8ff"),Color("#8e7fd8"),Color("#d7d7dc"),Color("#ffad91")],
        "van":[Color("#98e1bd"),Color("#ffd3a0"),Color("#c7d5e4"),Color("#9eb9ff")],
        "sport":[Color("#ff6eaa"),Color("#68efd7"),Color("#f2df61"),Color("#bba2ff")]
    }
    var arr: Array = palettes[cls]
    return arr[rng.randi_range(0,arr.size()-1)]
