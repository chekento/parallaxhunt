extends PanelContainer
## Real controls own menu input and scrolling; no world HUD shares this canvas.
const WorldAtlas=preload("res://scripts/world_atlas.gd")
var game: Node
var section := ""
var album_tab := 0
var mission_tab := "Entdecken"
var case_open:=false
var journal_chapter: int=-1
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
    add_theme_stylebox_override("panel",card_style(Color("#101f26"),Color("#52675f"),32))
    var column=VBoxContainer.new()
    column.add_theme_constant_override("separation",24)
    add_child(column)
    var top=HBoxContainer.new()
    top.add_theme_constant_override("separation",20)
    column.add_child(top)
    var titles=VBoxContainer.new()
    titles.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    top.add_child(titles)
    titles.add_child(label("PARALLAX  /  DEIN REISEBUCH",22,Color("#eccb91")))
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
    column.add_child(label("Jeder Ort hat eine Geschichte.  ·  Wischen zum Weiterlesen.",21,Color("#91aaad")))
    visible=false

static func card_style(bg: Color, border: Color, margin: int=24) -> StyleBoxFlat:
    var style=StyleBoxFlat.new()
    style.bg_color=bg
    style.border_color=border
    style.set_border_width_all(1)
    style.set_corner_radius_all(24)
    style.set_content_margin_all(margin)
    style.shadow_color=Color(0.02,0.06,0.06,.24)
    style.shadow_size=5
    style.shadow_offset=Vector2(0,3)
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
    b.custom_minimum_size=Vector2(0,84)
    b.add_theme_font_size_override("font_size",25)
    b.add_theme_color_override("font_color",Color("#f0ecdc"))
    b.add_theme_color_override("font_hover_color",Color("#ffffff"))
    b.add_theme_stylebox_override("normal",card_style(Color("#25413f"),Color("#638476"),18))
    b.add_theme_stylebox_override("hover",card_style(Color("#35594e"),Color("#b4d1a8"),18))
    b.add_theme_stylebox_override("pressed",card_style(Color("#466f5a"),Color("#e5cd92"),18))
    var focus=card_style(Color.TRANSPARENT,Color("#f1d19a"),0)
    focus.set_border_width_all(3)
    b.add_theme_stylebox_override("focus",focus)
    b.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
    b.clip_text=true
    b.pressed.connect(callback)
    return b

func card(title: String, detail: String, accent: Color=Color("#73f3ce")) -> VBoxContainer:
    var panel=PanelContainer.new()
    var style=card_style(Color("#1b3036"),Color(accent,0.35),26)
    style.border_width_left=5
    panel.add_theme_stylebox_override("panel",style)
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
    heading.text="Geschichten & Wege"
    subtitle.text="Kapitel %d / 12  ·  %d Nebenwege entdeckt  ·  %d CR" % [mini(12,int(game.campaign_state.get("chapter",0))+1),game.street_state.get("seen",{}).size(),game.credits]
    var nav=HBoxContainer.new();nav.add_theme_constant_override("separation",10);content.add_child(nav)
    for name in ["Entdecken","Kiezbuch","Umland","Hauptstory","Nebenwege"]:
        var category: String=name
        var b=button(name,func(): mission_tab=category;show_section("missions"));b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        b.add_theme_font_size_override("font_size",19)
        if mission_tab==name:b.add_theme_stylebox_override("normal",card_style(Color("#5c6043"),Color("#e2c58c"),14))
        nav.add_child(b)
    if not game.street_state.get("active","").is_empty():
        var q: Dictionary=game.MainStory.side_quest(game.street_state.active)
        var active=card("NEBENAUFTRAG · "+str(q.title),str(game.MainStory.task(game,"side").title),Color("#b8d5a9"))
        progress_bar(active,int(game.street_state.progress.get(q.id,0)),q.steps.size(),Color("#b8d5a9"))
        active.add_child(button("PAUSIEREN · SCHRITT BEHALTEN",func(): game.MainStory.pause_side(game);show_section("missions")))
    if not game.life_active.is_empty():
        var s: Dictionary=game.CityLife.story(game.life_active)
        var active=card("AKTIV · "+str(s.title),str(game.CityLife.step(game).task),Color(s.accent))
        progress_bar(active,int(game.life_progress.get(s.id,0)),s.steps.size(),Color(s.accent))
        active.add_child(button("NÄCHSTEN SCHRITT AUF DER KARTE",func(): game._open_overview("map")))
        active.add_child(button("PAUSIEREN · FORTSCHRITT BEHALTEN",func(): game.CityLife.pause(game);show_section("missions")))
    if not game.active_npc_contract.is_empty():
        card("PERSÖNLICHER AUFTRAG",game._contract_description(game.active_npc_contract),Color("#ffb3e6"))
    if not game.active_job.is_empty():
        card("STADTAUFTRAG · "+str(game.active_job.get("title","")),str(game.active_job.get("task","Ziel auf der Karte erreichen")),Color("#ffd27a"))
    if not game.region_contract.is_empty():
        var trip: Dictionary=game.RegionWorld.OUTINGS[int(game.region_contract.tour)]
        var active=card("AKTIVER AUSFLUG · "+str(trip.title),"%d / %d Stationen  ·  %s" % [int(game.region_contract.step),trip.stops.size(),game._objective_action()],Color("#c9e4a2"))
        active.add_child(button("AUSFLUG BEENDEN",func(): game.region_contract={};game.navigation_timer=0;show_section("missions")))
    if mission_tab=="Kiezbuch":build_stories();return
    if mission_tab=="Umland":build_outings();return
    if mission_tab=="Hauptstory":build_campaign();return
    if mission_tab=="Nebenwege":build_sidequests();return
    var welcome=card("EIN VIERTEL VOLLER KLEINER GESCHICHTEN","Emil sucht seinen Hund, Jo plant ein Straßenfest und Ada möchte die Uferwand bemalen. Alle Geschichten lassen sich pausieren und später fortsetzen.",Color("#edca91"))
    welcome.add_child(button("DAS KIEZBUCH ÖFFNEN",func(): mission_tab="Kiezbuch";show_section("missions")))
    var nearby: Array=game.life_places.duplicate()
    nearby.sort_custom(func(a,b):return Vector2(a.pos).distance_squared_to(game.player_pos)<Vector2(b.pos).distance_squared_to(game.player_pos))
    for i in range(mini(3,nearby.size())):
        var place: Dictionary=nearby[i]
        var v=card(str(place.name),"%d m entfernt  ·  %s" % [int(game.player_pos.distance_to(place.pos)/10),"Schon entdeckt" if game.life_seen.get(place.id,false) else "Ein neuer Ort für dein Kiezbuch"],Color("#a8d2ba"))
        v.add_child(button("WEG DORTHIN",navigate_place.bind(place)))
    var main=card("DIE STADT, DIE SICH ERINNERT",game.MainStory.recap(game),Color("#efca85"))
    main.add_child(label("12 Hauptkapitel · 144 Handlungsschritte · fortsetzbar über viele Spielsitzungen",22,Color("#a9c5ba")))
    main.add_child(button("HAUPTSTORY & STORYJOURNAL",func(): mission_tab="Hauptstory";show_section("missions")))
    var sides=card("KLEINE WEGE, EIGENE GESCHICHTEN","Zwölf weitere Aufträge werden in der Nähe und mit deinem Storyfortschritt entdeckt. Ein Hinweis erscheint im Spiel; die Hauptstory bleibt dabei gespeichert.",Color("#b8d5a9"))
    sides.add_child(button("ENTDECKTE NEBENWEGE",func(): mission_tab="Nebenwege";show_section("missions")))
    var out=card("WEITER HINAUS","Sonnenhagen, Seen, Wald, Mühlenau und die weite Reise zur Echowarte.",Color("#c9e4a2"))
    out.add_child(button("AUSFLÜGE INS UMLAND",func(): mission_tab="Umland";show_section("missions")))

func progress_bar(parent: Control,value: int,total: int,accent: Color) -> void:
    parent.add_child(label("%d / %d Schritte" % [value,total],22,Color("#b9ccc7")))
    var bar=ProgressBar.new();bar.custom_minimum_size.y=10;bar.show_percentage=false;bar.max_value=maxi(1,total);bar.value=value
    bar.add_theme_stylebox_override("background",card_style(Color("#2d4244"),Color.TRANSPARENT,0))
    bar.add_theme_stylebox_override("fill",card_style(accent,Color.TRANSPARENT,0));parent.add_child(bar)
func build_stories() -> void:
    for s in game.CityLife.STORIES:
        var done: bool=bool(game.life_completed.get(s.id,false));var current: int=int(game.life_progress.get(s.id,0))
        var v=card(str(s.tag)+("  ·  ABGESCHLOSSEN" if done else "  ·  KIEZGESCHICHTE"),str(s.title)+"\n\n"+str(s.desc),Color(s.accent))
        progress_bar(v,current,s.steps.size(),Color(s.accent))
        v.add_child(label("Einmalige Belohnung: %d CR  ·  +2 Stadtruf" % int(s.reward) if not done else "Deine Hilfe hat diesen Ort verändert. Wiederholen ist kostenlos.",22,Color("#b9ccc7")))
        if s.id!=game.life_active:
            var id: String=s.id
            v.add_child(button("ERNEUT ERLEBEN" if current>=s.steps.size() else ("FORTSETZEN" if current>0 else "GESCHICHTE BEGINNEN"),func(): game.CityLife.begin(game,id)))
        if current>0 and current<s.steps.size():v.add_child(label("Letzter Hinweis: "+str(s.steps[current-1].text),23,Color("#b4c7c3")))
func build_outings() -> void:
    card("RAUS AUS DER STADT","Sechs Ausflüge führen durch Sonnenhagen, Wald und Heide bis nach Mühlenau. An den Stationen aussteigen und ENTDECKEN wählen.",Color("#c9e4a2"))
    for i in range(game.RegionWorld.OUTINGS.size()):
        var index: int=i
        var trip: Dictionary=game.RegionWorld.OUTINGS[index]
        var complete: bool=bool(game.region_completed.get(str(trip.id),false))
        var v=card(str(trip.title),str(trip.desc),Color("#c9e4a2"))
        v.add_child(label("%d Stationen  ·  %s" % [trip.stops.size(),"BEREITS ENTDECKT" if complete else "%d CR Belohnung" % int(trip.reward)],23,Color("#aac39b")))
        v.add_child(button("ERNEUT ERKUNDEN" if complete else "AUSFLUG STARTEN",func(): game.RegionWorld.begin_outing(game,index)))
func build_chapters() -> void:
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
    for i in range(4):
        var index=i
        var b=button(["ÜBERSICHT","FOTOALBUM","GARAGE","KIEZBUCH"][i],func(): album_tab=index; show_section("collection"))
        b.add_theme_font_size_override("font_size",22)
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
        entries.append_array([["Kiez-Orte",game.life_seen.size(),game.life_places.size(),"#edca91"],["Kiezgeschichten",game.life_completed.size(),game.CityLife.STORIES.size(),"#edca91"]])
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
    elif album_tab==2:
        for cls in game.VEHICLE_CLASSES:
            var up: Dictionary=game._vehicle_upgrade_state(cls)
            var seen: bool=bool(game.driven_classes.get(cls,false))
            card(cls.capitalize()+"  ·  "+("GEFAHREN" if seen else "NOCH ENTDECKEN"),"Motor %d  ·  Handling %d  ·  Bremsen %d" % [up.engine,up.handling,up.brake],Color("#73f3ce") if seen else Color("#9cb6c5"))
    else:
        for p in game.life_places:
            var seen: bool=bool(game.life_seen.get(p.id,false))
            var v=card(("●  " if seen else "○  ")+str(p.name),str(p.desc) if seen else "Eine neue Geschichte wartet hier. Besuche den Ort, um seine Notiz ins Kiezbuch aufzunehmen.",Color("#edca91") if seen else Color("#94ada4"))
            v.add_child(button("ORT AUF DER KARTE",navigate_place.bind(p)))

func navigate_place(place: Dictionary) -> void:
    game.map_waypoint={"pos":place.pos,"name":str(place.name)};game.navigation_timer=0
    game._close_overview();game._notify("Route zu "+str(place.name)+" gestartet");game._save_game()

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
    for key in ["Ziele","Orte","Erleben","Fotos","Transit"]:
        var category: String=key
        var b=button(key,func(): map_category=category;show_section("map"))
        b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        b.add_theme_font_size_override("font_size",23)
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
    guide.add_child(label("L01 führt nach Sonnenhagen und in die Wildnis. L02 verbindet das Freiland mit Mühlenau; L03 führt weiter zur Echowarte. Sechs Regionalhaltestellen verbinden die Orte für 15 CR pro Fahrt. ERLEBEN zeigt Kiez-Orte und Geschichten.",23,Color("#afc5d0")))
func _select_map_point(selection: Dictionary) -> void:
    map_selection=selection
    selected_title.text=str(selection.name)
    var route: PackedVector2Array=game.WorldNavigation.route(game,game.player_pos,selection.pos)
    selected_detail.text=("%d m Wegstrecke  ·  Route folgt freien Wegen" % int(game.WorldNavigation.length(route)/10)) if not route.is_empty() else "Kein durchgehender Weg gefunden. Wähle einen anderen Zugang."
func _navigate_selection() -> void:
    if map_selection.is_empty():return
    game.map_waypoint=map_selection.duplicate(true);game.navigation_timer=0
    game._close_overview();game._notify("Route zu "+str(map_selection.name)+" gestartet")

func build_campaign() -> void:
    heading.text="Die offene Akte"
    var state: Dictionary=game.campaign_state
    var index:=int(state.get("chapter",0))
    var done: bool=index>=game.MainStory.Data.CHAPTERS.size()
    var cover=preload("res://scripts/story_book_banner.gd").new()
    cover.chapter_number=mini(12,index+1);cover.completed=done;content.add_child(cover)
    var active=card(game.MainStory.Data.TITLE,game.MainStory.recap(game),Color("#efca85"))
    if not done:
        active.add_child(label("JETZT · "+str(game.MainStory.task(game).title),27,Color("#edf1de")))
        progress_bar(active,game.MainStory.completed_steps(game),game.MainStory.total_steps(),Color("#efca85"))
        active.add_child(button("HAUPTSTORY VERFOLGEN",func(): game.MainStory.focus(game)))
    else:
        active.add_child(label("12 / 12 Kapitel abgeschlossen · die offene Welt bleibt spielbar",25,Color("#b8d5a9")))
        active.add_child(label("Deine Archiventscheidung: "+str(Dictionary(state.get("choices",{})).get("ending","Noch nicht gewählt")),24,Color("#dfd4b4")))
    active.add_child(label("Jeder abgeschlossene Schritt wird gespeichert. Nach einer Pause findest du hier den Rückblick und deine nächste Spur.",22,Color("#a9c5ba")))
    var nav=HBoxContainer.new();nav.add_theme_constant_override("separation",12);content.add_child(nav)
    for entry in [[false,"KAPITEL"],[true,"STORYJOURNAL"]]:
        var journal: bool=entry[0]
        var b=button(entry[1],func(): case_open=journal;show_section("missions"));b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;nav.add_child(b)
    if case_open:build_casefile();return
    for i in range(game.MainStory.Data.CHAPTERS.size()):
        var c: Dictionary=game.MainStory.Data.CHAPTERS[i]
        var status: String="ABGESCHLOSSEN" if i<index else ("DEIN AKTUELLES KAPITEL" if i==index else "WIRD IM VERLAUF FREIGESCHALTET")
        var v=card("%02d  %s" % [i+1,str(c.title)],status,Color("#b6d3b8") if i<index else (Color("#efca85") if i==index else Color("#839e98")))
        if i<index:v.add_child(label(str(c.reveal),24,Color("#b8cec5")))
        if i==index:
            v.add_child(label(str(c.recap),24,Color("#b8cec5")))
            progress_bar(v,int(state.get("step",0)),c.steps.size(),Color("#efca85"))
    var legacy=card("WEITERE STADTPROJEKTE","Die bisherigen 45 Sammel-, Hacking-, Fahrzeug- und Stadtziele bleiben als zusätzliche langfristige Projekte erhalten.",Color("#a4bfd0"))
    legacy.add_child(button("STADTPROJEKTE ANSEHEN",show_projects))
func build_casefile() -> void:
    var highest:=mini(11,int(game.campaign_state.get("chapter",0)))
    if journal_chapter<0 or journal_chapter>highest:journal_chapter=highest
    var v=card("BISHER GESCHEHEN",game.MainStory.recap(game),Color("#efca85"))
    v.add_child(label("Nur gesicherte Hinweise erscheinen in der Akte. Unentdeckte Wendungen bleiben verborgen.",22,Color("#a9c5ba")))
    var nav=HBoxContainer.new();nav.add_theme_constant_override("separation",12);content.add_child(nav)
    var prev=button("‹ FRÜHERES KAPITEL",func(): journal_chapter=maxi(0,journal_chapter-1);show_section("missions"));prev.disabled=journal_chapter<=0;prev.size_flags_horizontal=Control.SIZE_EXPAND_FILL;nav.add_child(prev)
    var next=button("SPÄTERES KAPITEL ›",func(): journal_chapter=mini(highest,journal_chapter+1);show_section("missions"));next.disabled=journal_chapter>=highest;next.size_flags_horizontal=Control.SIZE_EXPAND_FILL;nav.add_child(next)
    card("KAPITEL %02d · GESICHERTE HINWEISE" % [journal_chapter+1],"",Color("#efca85"))
    var count:=0
    for entry in game.campaign_state.get("journal",[]):
        if int(entry.chapter)==journal_chapter:card(str(entry.title),str(entry.text),Color("#b6cec2"));count+=1
    if count==0:card("Die erste Zeile ist noch frei","Folge der nächsten Spur. Dein erster gesicherter Hinweis erscheint hier.",Color("#839e98"))
    var choices: Dictionary=game.campaign_state.get("choices",{})
    if not choices.is_empty():
        var record=card("DEINE ENTSCHEIDUNGEN","",Color("#efca85"))
        for answer in choices.values():record.add_child(label("● "+str(answer),24,Color("#ccd7c6")))
    var items: Dictionary=game.campaign_state.get("items",{})
    if not items.is_empty():
        var pocket=card("GESICHERTE BELEGE","",Color("#b8d5a9"))
        for name in items:pocket.add_child(label("✓ "+str(name),24,Color("#ccd7c6")))
func build_sidequests() -> void:
    card("AUFTRÄGE, DIE DU UNTERWEGS FINDEST","Ein kleiner Hinweis erscheint, sobald du in die Nähe kommst. Du entscheidest, ob du mitmachst. Pausierte Aufträge behalten jeden Schritt; spätere Kapitel öffnen weitere Begegnungen.",Color("#b8d5a9"))
    var count:=0
    for q in game.MainStory.Side.QUESTS:
        if not game.street_state.get("seen",{}).get(q.id,false):continue
        count+=1
        var done: bool=game.street_state.completed.get(q.id,false)
        var current:=int(game.street_state.progress.get(q.id,0))
        var v=card(str(q.title)+( " · ABGESCHLOSSEN" if done else ""),str(q.desc),Color("#b8d5a9"))
        progress_bar(v,current,q.steps.size(),Color("#b8d5a9"))
        if not done:
            v.add_child(label("Einmalige Belohnung: %d CR" % int(q.reward),23,Color("#c8d3ba")))
            if game.street_state.active!=q.id:
                var id: String=q.id
                v.add_child(button("FORTSETZEN" if current>0 else "ANNEHMEN",func(): game.MainStory.begin_side(game,id)))
        var place: Dictionary=game.MainStory.location(game,str(q.steps[0].at))
        v.add_child(button("AUFTRAGSORT AUF DER KARTE",navigate_place.bind(place)))
    if count==0:card("Noch keine Begegnung entdeckt","Erkunde das Viertel rund um Ivos Uhr, Linas Lesefenster und Adas Atelier. Dort warten die ersten kleinen Aufgaben.",Color("#839e98"))

func show_projects() -> void:
    for child in content.get_children():content.remove_child(child);child.queue_free()
    card("STADTPROJEKTE","45 zusätzliche Ziele. Dein Fortschritt aus früheren Versionen bleibt erhalten.",Color("#a4bfd0"))
    content.add_child(button("ZURÜCK ZUR HAUPTSTORY",func(): show_section("missions")))
    build_chapters()
