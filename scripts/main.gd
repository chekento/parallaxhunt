extends Node2D

const WORLD_SIZE := Vector2(26000.0, 18000.0)
const WALK_SPEED := 165.0
const VEHICLE_SPEEDS := {"micro": 340.0, "sedan": 430.0, "van": 365.0, "sport": 545.0}
const VEHICLE_SIZES := {"micro": Vector2(36, 19), "sedan": Vector2(44, 22), "van": Vector2(50, 25), "sport": Vector2(48, 20)}

var rng := RandomNumberGenerator.new()
var districts: Array = []
var roads: Array = []
var parks: Array = []
var buildings: Array = []
var trees: Array = []
var parked_cars: Array = []
var traffic: Array = []
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
    _generate_city()
    _generate_traffic()
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
            buildings.append({"rect":rect, "height":h, "wall":district.wall, "roof":district.roof, "accent":district.accent, "style":district.style})
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
    _draw_parks()
    _draw_roads()
    _draw_buildings()
    _draw_trees()
    _draw_traffic()
    _draw_parked_cars()
    _draw_collectibles()
    _draw_player()
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

func _draw_roads() -> void:
    for road in roads:
        var pts: PackedVector2Array = road.points
        var screen := PackedVector2Array()
        for p in pts:
            screen.append(_project(p))
        draw_polyline(screen, Color("#151d23"), road.width + 28.0, true)
        draw_polyline(screen, Color("#303c43"), road.width, true)
        draw_polyline(screen, Color(0.92,0.86,0.63,0.34), 3.0, true)

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
        draw_circle(c,42,Color("#23333b"))
        draw_circle(c,31,Color("#54bad5"))
        draw_string(ThemeDB.fallback_font,c+Vector2(-80,-58),park.name,HORIZONTAL_ALIGNMENT_CENTER,160,16,Color("#d9efe3"))

func _draw_buildings() -> void:
    for b in buildings:
        var r: Rect2 = b.rect
        if not _world_rect_visible(r.grow(220)):
            continue
        var z: float = b.height
        var base := [_project(r.position),_project(Vector2(r.end.x,r.position.y)),_project(r.end),_project(Vector2(r.position.x,r.end.y))]
        var top := [_project(r.position,z),_project(Vector2(r.end.x,r.position.y),z),_project(r.end,z),_project(Vector2(r.position.x,r.end.y),z)]
        var side1 := PackedVector2Array([base[1],base[2],top[2],top[1]])
        var side2 := PackedVector2Array([base[2],base[3],top[3],top[2]])
        draw_colored_polygon(side1,b.wall.darkened(0.22))
        draw_colored_polygon(side2,b.wall.darkened(0.34))
        draw_colored_polygon(PackedVector2Array(top),b.roof)
        draw_polyline(PackedVector2Array([top[0],top[1],top[2],top[3],top[0]]),Color(1,1,1,0.10),1.5,true)
        var glow: Color = b.accent
        glow.a = 0.10 + minf(0.15,view_amount.length()*0.10)
        draw_polyline(PackedVector2Array([top[0],top[1],top[2],top[3],top[0]]),glow,4.0,true)
        if b.style in ["glass","neon"]:
            for k in range(1,5):
                var t := float(k)/5.0
                draw_line(top[0].lerp(top[3],t),top[1].lerp(top[2],t),Color(0.7,0.9,1.0,0.12),1.0)
        elif b.style == "heritage":
            var roof_center: Vector2 = (top[0]+top[1]+top[2]+top[3])/4.0
            draw_circle(roof_center,8,Color(1.0,0.83,0.58,0.20))

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
    var s := Vector2(-f.y,f.x)
    var pts := PackedVector2Array([center+f*sz.x*.5+s*sz.y*.5,center+f*sz.x*.5-s*sz.y*.5,center-f*sz.x*.5-s*sz.y*.5,center-f*sz.x*.5+s*sz.y*.5])
    draw_colored_polygon(pts,color)
    draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),Color(1,1,1,0.18),1.2,true)
    var cabin := _project(pos,15)
    draw_circle(cabin,sz.y*.30,Color(0.68,0.86,0.92,0.65))
    if not parked:
        var tail := center - f * sz.x*.62
        draw_line(tail,tail-f*18,Color(0.35,0.85,1.0,0.12),3.0,true)

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
