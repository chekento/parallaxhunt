extends PanelContainer
## Real controls own menu input and scrolling; no world HUD shares this canvas.
var game: Node
var section := ""
var album_tab := 0
var map_local := false
var map_category := "Ziele"
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
    titles.add_child(label("PARALLAX  /  DEINE STADT",22,Color("#73f3ce")))
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
    column.add_child(label("Wischen zum Scrollen  ·  Die Stadt wartet auf dich.",21,Color("#7894a3")))
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
    heading.text="Parallax Megacity"
    subtitle.text="%s  ·  Aktuelles Ziel: %s" % [game.current_district,game._current_objective_label()]
    var controls=HBoxContainer.new()
    controls.add_theme_constant_override("separation",12)
    content.add_child(controls)
    controls.add_child(button("GANZE STADT" if map_local else "UMGEBUNG",func(): map_local=not map_local; show_section("map")))
    for key in ["Ziele","Orte","Fotos","Transit"]:
        var category: String=key
        var b=button(key,func(): map_category=category; show_section("map"))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        if key==map_category:
            b.add_theme_color_override("font_color",Color("#73f3ce"))
        controls.add_child(b)
    var map=MapCanvas.new()
    map.game=game
    map.local=map_local
    map.category=map_category
    map.custom_minimum_size=Vector2(0,890)
    map.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    content.add_child(map)
    var guidance=card("AKTUELLES ZIEL",game._objective_action(),Color("#73f3ce"))
    guidance.add_child(label("Mint: Du  ·  Gold: Ziel  ·  Blau: Wasser und Kanäle",23,Color("#afc5d0")))
    var grid=GridContainer.new()
    grid.columns=2
    grid.add_theme_constant_override("h_separation",24)
    grid.add_theme_constant_override("v_separation",22)
    content.add_child(grid)
    for entry in [["●  Kontakte / NPCs","#c7f2e7"],["!  Hacking-Terminals","#ffdf75"],["↑  Dachzugang / Relay","#9bdcff"],["↓  Untergrundzugang","#ffb66f"],["H  Wohnung / Garage","#d6a8ff"],["J  Nebenjobs","#8de9aa"],["R  Zeitprüfungen","#ffd36b"],["◎  Foto-Spots","#ffb3e6"],["G  Werkstatt / Garage","#ff9b72"],["S  Shop / Café / Bar","#ffd27a"],["T  Bus / Tram","#72d7e6"],["◆  Live-Events","#ffb66f"]]:
        var l=label(entry[0],23,Color(entry[1]))
        l.custom_minimum_size.x=420
        l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        grid.add_child(l)

class MapCanvas extends Control:
    var game: Node
    var local: bool
    var category: String
    var region: Rect2
    var map_rect: Rect2

    func point(world: Vector2) -> Vector2:
        return map_rect.position+(world-region.position)/region.size*map_rect.size

    func marker(world: Vector2, color: Color, glyph: String="") -> void:
        if not region.has_point(world): return
        var p=point(world)
        draw_circle(p+Vector2(1,2),13,Color("#07131b"))
        draw_circle(p,10,color)
        if not glyph.is_empty():
            draw_string(ThemeDB.fallback_font,p+Vector2(-7,5),glyph,HORIZONTAL_ALIGNMENT_CENTER,14,13,Color("#07131b"))

    func _draw() -> void:
        if game==null: return
        map_rect=Rect2(Vector2(4,4),size-Vector2(8,8))
        region=Rect2(Vector2.ZERO,game.WORLD_SIZE)
        if local:
            region=Rect2(game._district_at(game.player_pos).rect).grow(250).intersection(region)
        draw_style_box(CityMenusStyle(),Rect2(Vector2.ZERO,size))
        for d in game.districts:
            var r: Rect2=Rect2(d.rect).intersection(region)
            if r.size.x<=0 or r.size.y<=0: continue
            var screen=Rect2(point(r.position),r.size/region.size*map_rect.size)
            draw_rect(screen,Color(d.ground).lightened(0.06))
            draw_rect(screen,Color(Color(d.accent),0.20),false,1)
            draw_string(ThemeDB.fallback_font,screen.position+Vector2(8,25),str(d.name),HORIZONTAL_ALIGNMENT_LEFT,screen.size.x-12,18,Color("#c6d9e0"))
        for w in game.waters:
            var r: Rect2=Rect2(w.rect).intersection(region)
            if r.size.x>0 and r.size.y>0:
                draw_rect(Rect2(point(r.position),r.size/region.size*map_rect.size),Color("#24617b"))
        for road in game.roads:
            for k in range(road.points.size()-1):
                var clipped: PackedVector2Array=game._photo_clip_road(road.points[k],road.points[k+1],region.get_center(),maxf(region.size.x,region.size.y)*0.5)
                if clipped.size()<2: continue
                draw_line(point(clipped[0]),point(clipped[1]),Color("#788d91"),2 if not local else 7,true)
        if category=="Ziele":
            for npc in game.named_npcs: marker(npc.pos,npc.accent,"N")
            for m in game.mission_sites: marker(m.pos,Color("#66717a") if game.hack_done.get(str(m.id),false) else Color("#ffdf75"),"!")
            for v in game.vertical_sites: marker(v.pos,v.accent,"↑" if v.kind=="roof" else "↓")
            for p in game.property_sites: marker(p.pos,Color("#d6a8ff"),"H")
            for j in game.side_job_sites: marker(j.pos,Color("#8de9aa"),"J")
            for r in game.race_sites: marker(r.pos,Color("#ffd36b"),"R")
        elif category=="Orte":
            for l in game.landmarks: marker(l.pos,l.accent,"+")
            for s in game.storefronts: marker(s.pos,Color("#ff9b72") if s.kind in ["garage","workshop"] else Color("#ffd27a"),"G" if s.kind in ["garage","workshop"] else "S")
            for i in range(game.city_micro_events.size()):
                var e: Dictionary=game.city_micro_events[i]
                if game._micro_event_active(i,e): marker(e.pos,e.accent)
        elif category=="Fotos":
            for ph in game.photo_points: marker(ph.pos,Color("#526c6d") if ph.taken else Color("#ffb3e6"),"◎")
        else:
            for stop in game.transit_stops: marker(stop.pos,Color("#72d7e6"),"T")
        var objective: Vector2=game._current_objective_pos()
        if objective!=Vector2.ZERO and region.has_point(objective):
            var p=point(objective)
            draw_circle(p,20,Color("#ffdf75"),false,3,true)
            draw_line(p-Vector2(26,0),p+Vector2(26,0),Color("#ffdf75"),2)
            draw_line(p-Vector2(0,26),p+Vector2(0,26),Color("#ffdf75"),2)
        var player=point(game.player_pos)
        draw_circle(player,17,Color("#07131b"))
        draw_circle(player,12,Color("#73f3ce"))
        var f=Vector2.from_angle(game.player_heading)
        draw_colored_polygon(PackedVector2Array([player+f*20,player+f.rotated(2.5)*9,player+f.rotated(-2.5)*9]),Color.WHITE)

    func CityMenusStyle() -> StyleBoxFlat:
        var style=StyleBoxFlat.new()
        style.bg_color=Color("#10202b")
        style.border_color=Color("#36535e")
        style.set_border_width_all(2)
        return style
