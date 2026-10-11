extends RefCounted
const Data=preload("res://scripts/romance_data.gd")
const World=preload("res://scripts/romance_world.gd")
const Portrait=preload("res://scripts/romance_portrait.gd")

static func build(menu: Node) -> void:
    var g: Node=menu.game
    menu.heading.text="Herz & Heim"
    menu.subtitle.text="Zweiter Hauptbogen · Dein Protagonist ist 28 · Fortschritt bleibt gespeichert"
    var banner:=Portrait.new();banner.banner=true;banner.custom_minimum_size=Vector2(0,190);menu.content.add_child(banner)
    var phase: int=g.Romance.phase(g)
    var main=menu.card("EIN ZUHAUSE FÜR ZWEI",Data.PHASES[phase]+"\nEine Frau kennenlernen, Nähe und Vertrauen aufbauen, gemeinsam wohnen und eine glückliche Familie gründen.",Color("#e8b0ba"))
    menu.progress_bar(main,phase,8,Color("#e8b0ba"))
    main.add_child(menu.button("BEZIEHUNGSBOGEN VERFOLGEN",func():g.Romance.focus(g)))
    if g.love_state.tracking:main.add_child(menu.button("ZUR STADTSTORY ZURÜCK · BEZIEHUNG BEHALTEN",func():g.love_state.tracking=false;g.MainStory.focus(g)))
    main.add_child(menu.button("WOHNUNGEN ANSEHEN",func():menu.mission_tab="Wohnungen";menu.show_section("missions")))
    if not g.love_state.date.is_empty():
        var date: Dictionary=g.love_state.date;var p:=Data.person(date.person);var loc: Dictionary=g.MainStory.location(g,date.at)
        var d=menu.card("VERABREDET · "+str(p.name),str(loc.name)+"\n%d / 3 Gesprächsmomente abgeschlossen" % int(date.step),Color("#e8b0ba"))
        d.add_child(menu.button("ZUM TREFFPUNKT",func():g.Romance.focus(g,str(date.person))))
        d.add_child(menu.button("VERABREDUNG VERSCHIEBEN",func():g.Romance.cancel_date(g);menu.show_section("missions")))
    if not g.love_state.partner.is_empty():
        var p:=Data.person(str(g.love_state.partner));var r: Dictionary=g.Romance.record(g,p.id)
        var couple=menu.card("DEINE PARTNERIN · "+str(p.name),"%d gemeinsame Dates · %s" % [int(r.dates),{"beziehung":"feste Beziehung","verlobt":"verlobt","verheiratet":"verheiratet"}.get(str(r.status),"verbunden")],Color("#c8d3b5"))
        couple.add_child(menu.button("PARTNERIN AUFSUCHEN",func():g.Romance.focus(g,str(p.id))))
    var journal=menu.card("EURE GEMEINSAMEN MOMENTE","Persönliche Geschichten, Dates und wichtige Entscheidungen bleiben hier erhalten.",Color("#dac69b"))
    if g.love_state.journal.is_empty():journal.add_child(menu.label("Ein erster Blick ist ein guter Anfang. Unterwegs erscheint HERZ, wenn du eine erwachsene Frau ansprechen kannst.",24,Color("#bbc8c3")))
    else:
        var entries: Array=g.love_state.journal
        for i in range(entries.size()-1,maxi(-1,entries.size()-10),-1):
            var e: Dictionary=entries[i];var p:=Data.person(str(e.person));journal.add_child(menu.label((str(p.name)+" · " if not p.is_empty() else "Zuhause · ")+str(e.text),24,Color("#c7d5ce")))
        journal.add_child(menu.button("DIE GESAMTE GESCHICHTE ANSEHEN",func():show_journal(menu)))
    var people: Array=Data.PEOPLE.duplicate()
    people.sort_custom(func(a,b):return World.person_pos(g,a.id).distance_squared_to(g.player_pos)<World.person_pos(g,b.id).distance_squared_to(g.player_pos))
    for p in people:
        var id: String=p.id;var r: Dictionary=g.Romance.record(g,id)
        var card=menu.card(str(p.name)+" · "+str(p.age)+" · "+str(p.role),"%d m entfernt · %s\nVertrauen %d · Knistern %d · %d Dates" % [int(g.player_pos.distance_to(World.person_pos(g,id))/10),"Kennengelernt" if r.met else "Eine neue Begegnung",int(r.trust),int(r.spark),int(r.dates)],Color(p.color))
        if r.met:card.add_child(menu.button("IHRE GESCHICHTE & DEIN FORTSCHRITT",func():g.romance_panel.open_person(id,true)))
        card.add_child(menu.button("ZU "+str(p.name).to_upper()+" · ROUTE",func():g.Romance.focus(g,id)))
static func homes(menu: Node) -> void:
    var g: Node=menu.game
    menu.heading.text="Ein Zuhause finden"
    menu.subtitle.text="Mieten oder kaufen · %d CR · Miete zählt nur in der Spielwelt" % g.credits
    menu.card("WOHNEN, DAS ZU DEINEM LEBEN PASST","Vom günstigen Studio bis zum Familienhaus im Umland. Besichtige kostenlos, miete mit Kaution oder spare auf Eigentum. Miete und Kauf verändern dein echtes Spielguthaben.",Color("#d9c49a"))
    var homes: Array=g.apartment_sites.duplicate()
    homes.sort_custom(func(a,b):return (a.id==g.home_state.primary) or (b.id!=g.home_state.primary and Vector2(a.pos).distance_squared_to(g.player_pos)<Vector2(b.pos).distance_squared_to(g.player_pos)))
    for h in homes:
        var id: String=h.id;var lease: Dictionary=g.home_state.leases.get(id,{})
        var status: String=" · HAUPTZUHAUSE" if id==g.home_state.primary else ""
        if not lease.is_empty():status+=" · EIGENTUM" if lease.mode=="own" else " · GEMIETET"
        var c=menu.card(str(h.name)+status,str(h.desc)+"\n\n%d Zimmer · %d Personen · %d m\nMiete %d CR / 3 Spieltage · Kaution %d CR\nKauf %d CR" % [int(h.rooms),int(h.capacity),int(g.player_pos.distance_to(h.pos)/10),int(h.rent),int(h.deposit),int(h.price)],Color(h.color))
        c.add_child(menu.button("WOHNUNG & KOSTEN ANSEHEN",func():g.romance_panel.open_home(id)))
        c.add_child(menu.button("ZUR HAUSTÜR · ROUTE",func():g.map_waypoint={"pos":h.pos,"name":h.name};g.navigation_timer=0;g._close_overview();g._save_game()))
static func show_journal(menu: Node) -> void:
    for child in menu.content.get_children():menu.content.remove_child(child);child.queue_free()
    menu.heading.text="Eure Geschichte"
    menu.content.add_child(menu.button("ZURÜCK ZU HERZ & HEIM",func():menu.show_section("missions")))
    for e in menu.game.love_state.journal:
        var p:=Data.person(str(e.person));menu.card(str(p.name) if not p.is_empty() else "Dein Zuhause",str(e.text),Color("#e8b0ba"))
