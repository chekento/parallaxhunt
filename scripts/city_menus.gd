extends PanelContainer
## Real controls own menu input and scrolling; no world HUD shares this canvas.
const WorldAtlas=preload("res://scripts/world_atlas.gd")
var game: Node
var section := ""
var album_tab := 0
var map_mode := "city"
var map_category := "Ziele"
var atlas: Control
var map_selection: Dictionary={}
var selected_title: Label
var selected_detail: Label
var content: VBoxContainer
var scroll: ScrollContainer
var heading: Label
var subtitle: Label
var tabs: Dictionary = {}

func setup(owner_game: Node) -> void:
    game=owner_game
    position=Vector2(40,84)
    size=Vector2(1000,2170)
    add_theme_stylebox_override("panel",card_style(Color("#0b1923"),Color("#36535e"),30))
    var column=VBoxContainer.new()
    column.add_theme_constant_override("separation",24)
    add_child(column)
    var top=HBoxContainer.new()
    top.add_theme_constant_override("separation",20)
    column.add_child(top)
    var titles=VBoxContainer.new()
    titles.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    top.add_child(titles)
    titles.add_child(label("PARALLAX  /  STADT & UMLAND",22,Color("#73f3ce")))
    heading=label("",42)
    titles.add_child(heading)
    var close=button("SCHLIESSEN",game._close_overview)
    close.custom_minimum_size=Vector2(210,86)
    top.add_child(close)
    var nav=HBoxContainer.new()
    nav.add_theme_constant_override("separation",12)
    column.add_child(nav)
    for item in [["map","KARTE"],["missions","AUFTRÄGE"],["collection","SAMMLUNG"]]:
        var key: String=item[0]
        var b=button(item[1],func(): game._open_overview(key))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        nav.add_child(b)
        tabs[key]=b
    subtitle=label("",24,Color("#afc5d0"))
    column.add_child(subtitle)
    scroll=ScrollContainer.new()
    scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    scroll.follow_focus=true
    column.add_child(scroll)
    content=VBoxContainer.new()
    content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation",20)
    scroll.add_child(content)
    column.add_child(label("Wischen zum Scrollen  ·  Entdecke, was hinter der Stadt liegt.",21,Color("#7894a3")))
    visible=false

static func card_style(bg: Color, border: Color, margin: int=24) -> StyleBoxFlat:
    var style=StyleBoxFlat.new()
    style.bg_color=bg
    style.border_color=border
    style.set_border_width_all(2)
    style.set_corner_radius_all(20)
    style.set_content_margin_all(margin)
    return style

static func label(text: String, font_size: int=26, color: Color=Color.WHITE) -> Label:
    var l=Label.new()
    l.text=text
    l.add_theme_font_size_override("font_size",font_size)
    l.add_theme_color_override("font_color",color)
    l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    l.mouse_filter=Control.MOUSE_FILTER_IGNORE
    return l

static func button(text: String, callback: Callable) -> Button:
    var b=Button.new()
    b.text=text
    b.custom_minimum_size=Vector2(0,76)
    b.add_theme_font_size_override("font_size",25)
    b.pressed.connect(callback)
    return b

func card(title: String, detail: String, accent: Color=Color("#73f3ce")) -> VBoxContainer:
    var panel=PanelContainer.new()
    panel.add_theme_stylebox_override("panel",card_style(Color("#122731"),Color(accent,0.28)))
    content.add_child(panel)
    var v=VBoxContainer.new()
    v.add_theme_constant_override("separation",12)
    panel.add_child(v)
    v.add_child(label(title,29,accent))
    if not detail.is_empty():
        v.add_child(label(detail,25,Color("#c6d9e0")))
    return v

func show_section(kind: String) -> void:
    section=kind
    visible=true
    for key in tabs:
        tabs[key].add_theme_stylebox_override("normal",card_style(Color("#24494d") if key==kind else Color("#122731"),Color("#73f3ce") if key==kind else Color("#36535e"),14))
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    scroll.scroll_vertical=0
    if kind=="map":
        build_map()
    elif kind=="missions":
        build_missions()
    else:
        build_collection()

func build_missions() -> void:
    heading.text="Deine Aufträge"
    subtitle.text="Kapitel %d von %d  ·  %d Credits" % [game.native_chapter+1,game.native_chapters.size(),game.credits]
    if not game.active_npc_contract.is_empty():
        card("PERSÖNLICHER AUFTRAG",game._contract_description(game.active_npc_contract),Color("#ffb3e6"))
    if not game.active_job.is_empty():
        card("STADTAUFTRAG · "+str(game.active_job.get("title","")),str(game.active_job.get("task","Ziel auf der Karte erreichen")),Color("#ffd27a"))
    if not game.region_contract.is_empty():
        var trip: Dictionary=game.RegionWorld.OUTINGS[int(game.region_contract.tour)]
        var active=card("AKTIVER AUSFLUG · "+str(trip.title),"%d / %d Stationen  ·  %s" % [int(game.region_contract.step),trip.stops.size(),game._objective_action()],Color("#c9e4a2"))
        active.add_child(button("AUSFLUG BEENDEN",func(): game.region_contract={};game.navigation_timer=0;show_section("missions")))
    card("RAUS AUS DER STADT","Vier freie Ausflüge führen dich durch Sonnenhagen, die Felder und den Fichtenwald. Die Stationen ansprechen, um sie zu besuchen.",Color("#c9e4a2"))
    for i in range(game.RegionWorld.OUTINGS.size()):
        var index: int=i
        var trip: Dictionary=game.RegionWorld.OUTINGS[index]
        var complete: bool=bool(game.region_completed.get(str(trip.id),false))
        var v=card(str(trip.title),str(trip.desc),Color("#c9e4a2"))
        v.add_child(label("%d Stationen  ·  %s" % [trip.stops.size(),"BEREITS ENTDECKT" if complete else "%d CR Belohnung" % int(trip.reward)],23,Color("#aac39b")))
        v.add_child(button("ERNEUT ERKUNDEN" if complete else "AUSFLUG STARTEN",func(): game.RegionWorld.begin_outing(game,index)))
    for i in range(game.native_chapters.size()):
        var chapter: Dictionary=game.native_chapters[i]
        var progress: int=game._chapter_progress(chapter)
        var goal: int=int(chapter.goal)
        var current: bool=i==game.native_chapter
        var complete: bool=progress>=goal
        var accent=Color("#73f3ce") if current or complete else Color("#9cb6c5")
        var v=card("%02d  %s" % [i+1,str(chapter.title)],str(chapter.desc),accent)
        v.add_child(label("AKTIV  ·  %d / %d" % [progress,goal] if current else ("ABGESCHLOSSEN" if complete else "%d / %d" % [progress,goal]),23,accent))
        if current:
            v.add_child(button("ZIEL AUF DER KARTE",func(): game._open_overview("map")))

func build_collection() -> void:
    heading.text="Deine Sammlung"
    subtitle.text="%d Credits  ·  Stadtruf %d  ·  Foto-Score %d" % [game.credits,game.city_reputation,game._photo_total_score()]
    var nav=HBoxContainer.new()
    nav.add_theme_constant_override("separation",12)
    content.add_child(nav)
    for i in range(3):
        var index=i
        var b=button(["ÜBERSICHT","FOTOALBUM","GARAGE"][i],func(): album_tab=index; show_section("collection"))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        if i==album_tab:
            b.add_theme_color_override("font_color",Color("#ffb3e6"))
        nav.add_child(b)
    if album_tab==0:
        var entries=[
            ["Foto-Spots",game.photo_count,game.photo_points.size(),"#ffb3e6"],
            ["Street Signals",game.scan_collect_count,game.scan_points.size(),"#78d8ff"],
            ["Fahrzeugklassen",game.driven_classes.size(),game.VEHICLE_CLASSES.size(),"#73f3ce"],
            ["Hacking-Terminals",game._completed_hack_count(),game.mission_sites.size(),"#ffdf75"],
            ["Stadtteile",game.visited_districts.size(),game.districts.size(),"#9ad5ff"],
            ["Umland-Orte",game.region_seen.size(),game.region_pois.size(),"#c9e4a2"],
            ["Ausflüge",game.region_completed.size(),game.RegionWorld.OUTINGS.size(),"#c9e4a2"],
            ["Zeitprüfungen",game.race_completed.size(),game.race_sites.size(),"#ffd36b"],
            ["Vertrauen",game._total_npc_trust(),game.named_npcs.size()*3,"#ff9fe8"],
            ["Stadtleben",game.micro_event_seen.size(),game.city_micro_events.size(),"#ffb66f"]]
        for e in entries:
            var accent=Color(e[3])
            var v=card(e[0],"%d / %d" % [e[1],e[2]],accent)
            var bar=ProgressBar.new()
            bar.custom_minimum_size.y=12
            bar.show_percentage=false
            bar.max_value=maxf(1.0,float(e[2]))
            bar.value=float(e[1])
            bar.add_theme_stylebox_override("background",card_style(Color("#243d47"),Color.TRANSPARENT,0))
            bar.add_theme_stylebox_override("fill",card_style(accent,Color.TRANSPARENT,0))
            v.add_child(bar)
        var events=card("Entdeckte Live-Events","",Color("#ffb66f"))
        for e in game.city_micro_events:
            var done: bool=bool(game.micro_event_seen.get(str(e.label),false))
            events.add_child(label(("●  " if done else "○  ")+str(e.label),24,Color("#73f3ce") if done else Color("#9cb6c5")))
    elif album_tab==1:
        for ph in game.photo_points:
            var done: bool=bool(ph.taken)
            card(("●  " if done else "○  ")+str(ph.label),"%s  ·  %d / 300 Punkte" % [str(ph.district),game._photo_spot_score(str(ph.id))],Color("#73f3ce") if done else Color("#ffb3e6"))
    else:
        for cls in game.VEHICLE_CLASSES:
            var up: Dictionary=game._vehicle_upgrade_state(cls)
            var seen: bool=bool(game.driven_classes.get(cls,false))
            card(cls.capitalize()+"  ·  "+("GEFAHREN" if seen else "NOCH ENTDECKEN"),"Motor %d  ·  Handling %d  ·  Bremsen %d" % [up.engine,up.handling,up.brake],Color("#73f3ce") if seen else Color("#9cb6c5"))

func build_map() -> void:
    heading.text="Stadt & Umland"
    subtitle.text="%s  ·  %s" % [game.current_district,game._current_objective_label()]
    var views=HBoxContainer.new()
    views.add_theme_constant_override("separation",12)
    content.add_child(views)
    for entry in [["city","STADT"],["region","UMLAND"],["local","UMGEBUNG"]]:
        var view: String=entry[0]
        var b=button(entry[1],func(): map_mode=view;show_section("map"))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        if view==map_mode:b.add_theme_color_override("font_color",Color("#c9e4a2"))
        views.add_child(b)
    var filters=HBoxContainer.new()
    filters.add_theme_constant_override("separation",12)
    content.add_child(filters)
    for key in ["Ziele","Orte","Fotos","Transit"]:
        var category: String=key
        var b=button(key,func(): map_category=category;show_section("map"))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        if key==map_category:b.add_theme_color_override("font_color",Color("#c9e4a2"))
        filters.add_child(b)
    atlas=WorldAtlas.new()
    atlas.setup(game,map_mode,map_category,_select_map_point)
    atlas.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    content.add_child(atlas)
    var controls=HBoxContainer.new()
    controls.add_theme_constant_override("separation",12)
    content.add_child(controls)
    for entry in [["−",.8],["+",1.25]]:
        var factor: float=entry[1]
        var b=button(entry[0],func(): atlas.zoom_by(factor))
        b.custom_minimum_size.x=120
        controls.add_child(b)
    var recenter=button("MEINE POSITION",func(): atlas.recenter())
    recenter.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    controls.add_child(recenter)
    content.add_child(label("Karte ziehen  ·  Ort oder freie Fläche antippen  ·  Mit + / − zoomen",21,Color("#afc5d0")))
    var selection=card("","",Color("#c9e4a2"))
    selected_title=selection.get_child(0)
    selected_detail=label("",24,Color("#c6d9e0"))
    selection.add_child(selected_detail)
    selection.add_child(button("ROUTE STARTEN",_navigate_selection))
    if not game.map_waypoint.is_empty():selection.add_child(button("WEGPUNKT LÖSCHEN",func(): game.map_waypoint={};game.navigation_timer=0;show_section("map")))
    if map_selection.is_empty():
        var pos: Vector2=game._current_objective_pos()
        map_selection={"pos":pos if pos!=Vector2.ZERO else game.player_pos,"name":game._current_objective_label() if pos!=Vector2.ZERO else "Deine Position"}
    _select_map_point(map_selection)
    var guide=card("ORIENTIERUNG","Mint: Du  ·  Gold: Route / Ziel  ·  Blau: Wasser\nB Bus  ·  C Café  ·  G Garage  ·  W Waldhaus  ·  V Aussicht  ·  T Zeltplatz",Color("#73f3ce"))
    guide.add_child(label("Die Landstraße L01 führt nach Sonnenhagen und weiter in die Wildnis. Vier Haltestellen verbinden die Region. Eine Busfahrt kostet 15 CR.",23,Color("#afc5d0")))
func _select_map_point(selection: Dictionary) -> void:
    map_selection=selection
    selected_title.text=str(selection.name)
    var route: PackedVector2Array=game.WorldNavigation.route(game,game.player_pos,selection.pos)
    selected_detail.text=("%d m Wegstrecke  ·  Route folgt freien Wegen" % int(game.WorldNavigation.length(route)/10)) if not route.is_empty() else "Kein durchgehender Weg gefunden. Wähle einen anderen Zugang."
func _navigate_selection() -> void:
    if map_selection.is_empty():return
    game.map_waypoint=map_selection.duplicate(true);game.navigation_timer=0
    game._close_overview();game._notify("Route zu "+str(map_selection.name)+" gestartet")
