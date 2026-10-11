extends RefCounted
## One persistent campaign and optional proximity quests share guarded real actions.
const Data=preload("res://scripts/campaign_data.gd")
const Side=preload("res://scripts/street_quest_data.gd")
const ACCENT=Color("#efca85")

static func clear(g: Node,enabled: bool=false) -> void:
    g.campaign_state={"enabled":enabled,"follow":true,"chapter":0,"step":0,"claimed":{},"journal":[],"choices":{},"items":{},"seconds":0.0,"introduced":false}
    g.street_state={"active":"","progress":{},"seen":{},"completed":{},"choices":{},"hidden":{}}
    g.encounter_id="";g.encounter_clock=0
static func restore(g: Node,c: Dictionary,s: Dictionary) -> void:
    clear(g,true)
    for key in ["enabled","follow","introduced"]:g.campaign_state[key]=bool(c.get(key,g.campaign_state[key]))
    g.campaign_state.chapter=clampi(int(c.get("chapter",0)),0,Data.CHAPTERS.size())
    g.campaign_state.step=clampi(int(c.get("step",0)),0,Data.CHAPTERS[int(g.campaign_state.chapter)].steps.size()-1) if int(g.campaign_state.chapter)<Data.CHAPTERS.size() else 0
    g.campaign_state.seconds=maxf(0,float(c.get("seconds",0)))
    for key in ["claimed","choices","items"]:
        if c.get(key,{}) is Dictionary:g.campaign_state[key]=Dictionary(c.get(key,{})).duplicate(true)
    if c.get("journal",[]) is Array:
        for entry in c.get("journal",[]):
            if entry is Dictionary and entry.has("title") and entry.has("text"):g.campaign_state.journal.append({"title":str(entry.title),"text":str(entry.text),"chapter":clampi(int(entry.get("chapter",0)),0,11)})
    for key in ["seen","completed","choices","hidden"]:
        if s.get(key,{}) is Dictionary:g.street_state[key]=Dictionary(s.get(key,{})).duplicate(true)
    var progress: Dictionary=Dictionary(s.get("progress",{})) if s.get("progress",{}) is Dictionary else {}
    for q in Side.QUESTS:
        g.street_state.progress[q.id]=clampi(int(progress.get(q.id,0)),0,q.steps.size())
    var active:=str(s.get("active",""))
    var quest:=side_quest(active)
    if not quest.is_empty() and int(g.street_state.progress[active])<quest.steps.size():g.street_state.active=active
static func side_quest(id: String) -> Dictionary:
    for q in Side.QUESTS:
        if q.id==id:return q
    return {}
static func chapter(g: Node) -> Dictionary:
    var index:=int(g.campaign_state.get("chapter",0))
    return Data.CHAPTERS[index] if index<Data.CHAPTERS.size() else {}
static func task(g: Node,lane: String="main") -> Dictionary:
    if lane=="side":
        var q:=side_quest(str(g.street_state.get("active","")))
        var step:=int(Dictionary(g.street_state.get("progress",{})).get(q.get("id",""),0))
        return q.steps[step] if not q.is_empty() and step<q.steps.size() else {}
    var c:=chapter(g)
    return c.steps[int(g.campaign_state.get("step",0))] if not c.is_empty() else {}
static func location(g: Node,id: String) -> Dictionary:
    var p: Dictionary=g.CityLife.get_place(g,id)
    if not p.is_empty():return p
    p=g.RegionWorld.get_poi(g,id)
    if not p.is_empty():return p
    for photo in g.photo_points:
        if str(photo.id)==id:return {"id":id,"name":str(photo.label),"pos":photo.pos}
    for npc in g.named_npcs:
        if str(npc.id)==id:return npc
    return {}
static func target(g: Node,lane: String="main") -> Vector2:
    if lane=="main" and (not g.campaign_state.get("enabled",false) or not g.campaign_state.get("follow",true)):return Vector2.ZERO
    var t:=task(g,lane)
    var p:=location(g,str(t.get("at","")))
    return Vector2(p.pos) if not p.is_empty() else Vector2.ZERO
static func token(g: Node,lane: String) -> String:
    return ("main:%d:%d" % [int(g.campaign_state.chapter),int(g.campaign_state.step)]) if lane=="main" else ("side:%s:%d" % [str(g.street_state.active),int(g.street_state.progress.get(g.street_state.active,0))])
static func valid(g: Node,lane: String,key: String) -> bool:
    return token(g,lane)==key and not task(g,lane).is_empty() and target(g,lane)!=Vector2.ZERO and g.player_pos.distance_to(target(g,lane))<108 and g.current_vehicle<0 and not g.interior_active and g.transit_riding<0
static func focus(g: Node) -> void:
    g.campaign_state.enabled=true;g.campaign_state.follow=true;g.street_state.active=""
    g.CityLife.pause(g);g.region_contract={};g.map_waypoint={};g.navigation_timer=0
    g._close_overview();g._close_commerce();g._save_game();g._update_ui()
    if not chapter(g).is_empty():g._notify("HAUPTSTORY · "+str(task(g).title))
static func introduce(g: Node) -> void:
    if not g.campaign_state.get("enabled",false) or g.campaign_state.get("introduced",false):return
    g.campaign_state.introduced=true;g._save_game()
    g._open_commerce("17 SEKUNDEN ZU FRÜH","Ein Radio am Lindenkiosk spricht deinen nächsten Moment aus. Kurz darauf stockt die Bahnhofsuhr. Jemand wusste davon.\n\nDIE STADT, DIE SICH ERINNERT\nEine Geschichte in zwölf Kapiteln. Du kannst jederzeit speichern, andere Wege gehen und später mit deinem Journal zurückkehren.")
    g.commerce_actions.add_child(g._commerce_button("EMIL AM KIOSK AUFSUCHEN",g._close_commerce))
    g.commerce_actions.add_child(g._commerce_button("MEINE HAUPTSTORY ANSEHEN",open_book.bind(g)))
static func open_book(g: Node) -> void:
    g._close_commerce();g.city_menus.mission_tab="Hauptstory";g._open_overview("missions")
static func interactable(g: Node) -> Dictionary:
    for lane in ["side","main"]:
        var p:=target(g,lane)
        if p!=Vector2.ZERO and p.distance_to(g.player_pos)<100:
            if lane=="main" and (not g.life_active.is_empty() or not g.region_contract.is_empty()):continue
            return {"type":"story_task","lane":lane,"action":"SPUR SCANNEN" if str(task(g,lane).kind)=="scan" else ("NEBENAUFTRAG" if lane=="side" else "HAUPTSTORY")}
    if not g.life_active.is_empty() and g.CityLife.target(g).distance_to(g.player_pos)<100:return {}
    for q in Side.QUESTS:
        if available(g,q) and Vector2(location(g,q.steps[0].at).pos).distance_to(g.player_pos)<95:return {"type":"street_offer","id":q.id,"action":"NEBENAUFTRAG"}
    return {}
static func visit(g: Node,lane: String) -> void:
    var key:=token(g,lane)
    if not valid(g,lane,key):return
    var t:=task(g,lane);var c:=chapter(g) if lane=="main" else side_quest(g.street_state.active)
    var title:=str(c.title)
    var index:=int(g.campaign_state.step) if lane=="main" else int(g.street_state.progress.get(g.street_state.active,0))
    g._open_commerce(title,"%s  ·  %d / %d\n%s\n\n%s" % ["HAUPTSTORY" if lane=="main" else "NEBENAUFTRAG",index+1,c.steps.size(),str(t.title),description(g,t,lane)])
    if t.kind in ["choice","deduce"]:
        for i in range(t.choices.size()):g.commerce_actions.add_child(g._commerce_button(str(t.choices[i]),choose.bind(g,lane,key,i)))
    elif t.kind in ["wire","frequency","mastermind","memory"]:g.commerce_actions.add_child(g._commerce_button("LEITUNGSNETZ ÖFFNEN" if t.kind=="wire" else ("PRÜFCODE ERMITTELN" if t.kind=="mastermind" else ("SIGNALFOLGE MERKEN" if t.kind=="memory" else "SIGNAL ABSTIMMEN")),puzzle.bind(g,lane,key)))
    elif t.kind=="photo":g.commerce_actions.add_child(g._commerce_button("3D-FOTOERMITTLUNG STARTEN",photo.bind(g,lane,key)))
    elif t.kind=="scan":g.commerce_actions.add_child(g._commerce_button("SCANNER EINSETZEN",scan_card.bind(g,lane,key)))
    else:g.commerce_actions.add_child(g._commerce_button("HINWEIS SICHERN / WEITER",advance.bind(g,lane,key)))
    g.commerce_actions.add_child(g._commerce_button("SPÄTER · SCHRITT BEHALTEN",g._close_commerce))
static func choose(g: Node,lane: String,key: String,index: int) -> void:
    if not valid(g,lane,key):return
    var t:=task(g,lane)
    if index<0 or index>=t.choices.size():return
    if t.kind=="deduce" and index!=int(t.answer):
        g.commerce_info.text=str(t.text)+"\n\nHINWEIS · "+str(t.hint);g._play_sfx("error");g._queue_modal_fit();return
    var state: Dictionary=g.campaign_state if lane=="main" else g.street_state
    state.choices[str(t.get("key",key))]=str(t.choices[index])
    advance(g,lane,key)
static func scan_card(g: Node,lane: String,key: String) -> void:
    if not valid(g,lane,key):return
    g._close_commerce();g._scan()
static func scan(g: Node) -> bool:
    for lane in ["side","main"]:
        var key:=token(g,lane);var t:=task(g,lane)
        if valid(g,lane,key) and str(t.kind)=="scan":
            var detail:=description(g,t,lane)
            advance(g,lane,key)
            g._open_commerce("SPUR GESICHERT · "+str(t.title),detail+"\n\nDer Hinweis ist in deinem Storyjournal gespeichert.")
            g.commerce_actions.add_child(g._commerce_button("WEITER ZUR NÄCHSTEN SPUR",g._close_commerce))
            return true
    return false
static func puzzle(g: Node,lane: String,key: String) -> void:
    if not valid(g,lane,key):return
    var t:=task(g,lane)
    g._close_commerce();g._start_minigame({"id":"story:"+key,"name":str(t.title),"game":str(t.kind),"difficulty":2 if int(g.campaign_state.chapter)>5 else 1,"reward":"Storyhinweis","story_task":true,"lane":lane,"token":key})
    if t.kind=="frequency" and g.game_current==g.game_target:g._on_frequency_cell(0)
    if t.kind=="mastermind" and g.game_guess==g.game_secret:g._on_mastermind_digit(0)
    g.game_info.text="STORYRÄTSEL · "+g.game_info.text
static func puzzle_finished(g: Node,site: Dictionary) -> void:
    if valid(g,str(site.lane),str(site.token)):advance(g,str(site.lane),str(site.token),true)
static func advance(g: Node,lane: String,key: String,from_puzzle: bool=false) -> void:
    if not valid(g,lane,key):return
    var t:=task(g,lane)
    if t.kind in ["wire","frequency","mastermind","memory","photo"] and not from_puzzle:return
    if lane=="main":
        var c:=chapter(g)
        g.campaign_state.journal.append({"title":str(t.title),"text":str(t.text),"chapter":int(g.campaign_state.chapter)})
        if t.has("gain"):g.campaign_state.items[t.gain]=true
        g.campaign_state.step=int(g.campaign_state.step)+1
        if int(g.campaign_state.step)>=c.steps.size():
            var id:=str(g.campaign_state.chapter)
            if not g.campaign_state.claimed.get(id,false):g.credits+=int(c.reward);g.city_reputation+=1;g.campaign_state.claimed[id]=true
            g.campaign_state.journal.append({"title":"KAPITEL ABSCHLUSS · "+str(c.title),"text":str(c.reveal),"chapter":int(g.campaign_state.chapter)})
            g.campaign_state.chapter=int(g.campaign_state.chapter)+1;g.campaign_state.step=0
            g._notify("KAPITEL ABGESCHLOSSEN · "+str(c.title)+" · Fortschritt gespeichert")
        else:g._notify("Nächste Spur · "+str(task(g).title))
    else:
        var q:=side_quest(g.street_state.active);var id:=str(q.id)
        g.street_state.progress[id]=int(g.street_state.progress.get(id,0))+1
        if int(g.street_state.progress[id])>=q.steps.size():
            if not g.street_state.completed.get(id,false):g.credits+=int(q.reward);g.city_reputation+=1;g.street_state.completed[id]=true
            g.street_state.active="";g._notify("NEBENAUFTRAG ABGESCHLOSSEN · "+str(q.title))
        else:g._notify("Nächster Schritt · "+str(task(g,"side").title))
    if not from_puzzle:g._close_commerce()
    g.navigation_timer=0;g._save_game();g._update_ui()
static func available(g: Node,q: Dictionary) -> bool:
    return bool(g.campaign_state.get("enabled",false)) and int(g.campaign_state.get("chapter",0))>=int(q.chapter) and not g.street_state.completed.get(q.id,false) and str(g.street_state.get("active",""))!=str(q.id)
static func offer(g: Node,id: String) -> void:
    var q:=side_quest(id)
    if q.is_empty() or not available(g,q):return
    g.street_state.seen[id]=true;g._save_game()
    g._open_commerce("NEU IN DEINER NÄHE",str(q.title)+"\n\n"+str(q.desc)+"\n\n%d Schritte · %d CR · frei wählbar\nDeine Hauptstory bleibt gespeichert." % [q.steps.size(),int(q.reward)])
    g.commerce_actions.add_child(g._commerce_button("AUFTRAG ANNEHMEN",begin_side.bind(g,id)))
    g.commerce_actions.add_child(g._commerce_button("SPÄTER · IM JOURNAL MERKEN",g._close_commerce))
static func begin_side(g: Node,id: String) -> void:
    var q:=side_quest(id)
    if q.is_empty() or not available(g,q) or not g.street_state.seen.get(id,false):return
    g.street_state.active=id;g.street_state.progress[id]=int(g.street_state.progress.get(id,0));g.map_waypoint={};g.navigation_timer=0
    g._close_overview();g._close_commerce();g._save_game();g._notify(str(q.title)+" · "+str(task(g,"side").title))
static func pause_side(g: Node) -> void:
    g.street_state.active="";g.navigation_timer=0;g._save_game();g._update_ui()
static func update(g: Node,delta: float) -> void:
    if g.campaign_state.get("enabled",false) and int(g.campaign_state.chapter)<Data.CHAPTERS.size():g.campaign_state.seconds=float(g.campaign_state.seconds)+delta
    g.encounter_clock+=delta
    if g.encounter_clock<.5:return
    g.encounter_clock=0;g.encounter_id=""
    if is_instance_valid(g.encounter_button):g.encounter_button.visible=false
    if g.interior_active or g.photo_mode or g.transit_riding>=0 or not g.street_state.get("active","").is_empty():return
    var distance:=400.0
    for q in Side.QUESTS:
        if not available(g,q):continue
        var p:=location(g,q.steps[0].at)
        if p.is_empty():continue
        var d: float=g.player_pos.distance_to(p.pos)
        if d<distance:
            g.encounter_id=str(q.id);distance=d
            if not g.street_state.seen.get(q.id,false):g.street_state.seen[q.id]=true;g._save_game()
    if is_instance_valid(g.encounter_button):
        g.encounter_button.visible=not g.encounter_id.is_empty()
        if not g.encounter_id.is_empty():g.encounter_button.text="IN DER NÄHE · "+str(side_quest(g.encounter_id).title)+"  ›"
static func recap(g: Node) -> String:
    var c:=chapter(g)
    return str(c.recap) if not c.is_empty() else "Der Morgenlauf ist gestoppt. "+ending(g)+" Die offene Welt und Nebenaufträge bleiben spielbar."

static func ending(g: Node) -> String:
    var choice:=str(Dictionary(g.campaign_state.get("choices",{})).get("ending",""))
    if choice.begins_with("Geschützte"):return "Geschützte Kopien bewahren persönliche Aussagen; ein öffentliches Prüfprotokoll macht Änderungen kontrollierbar."
    if not choice.is_empty():return "Ein gemeinsames Archiv nimmt nur freiwillig freigegebene Beiträge auf; persönliche Originale bleiben unter der Kontrolle ihrer Menschen."
    return "Die Entscheidung über das gemeinsame Archiv liegt noch vor dir."
static func description(g: Node,t: Dictionary,lane: String) -> String:
    var text:=str(t.text)
    if lane!="main":return text
    var choices: Dictionary=g.campaign_state.get("choices",{})
    if int(g.campaign_state.chapter)==12 or int(g.campaign_state.chapter)==11 and t.at in ["archive","kiosk"]:text+="\n\nDEIN WEG · "+ending(g)
    if int(g.campaign_state.chapter)==1 and t.at=="archive" and choices.has("first_trust"):
        text+="\n\nMira erinnert sich an deinen Entschluss: »"+str(choices.first_trust)+"«. Sie verwahrt die erste Spur entsprechend neben eurer neuen Akte."
    if int(g.campaign_state.chapter)==9 and t.at=="notice" and choices.has("public_check"):
        text+="\n\nDie Rückmeldungen folgen eurem gewählten Verfahren: "+str(choices.public_check)+"."
    return text

static func completed_steps(g: Node) -> int:
    var total:=0
    for i in range(mini(int(g.campaign_state.get("chapter",0)),Data.CHAPTERS.size())):total+=Data.CHAPTERS[i].steps.size()
    return total+int(g.campaign_state.get("step",0))
static func total_steps() -> int:
    var total:=0
    for c in Data.CHAPTERS:total+=c.steps.size()
    return total
static func puzzle_solved(g: Node) -> bool:
    match g.game_type:
        "wire":return g._wire_solved()
        "frequency":return g.game_current==g.game_target
        "mastermind":return g.game_guess==g.game_secret
        "memory":return not g.game_memory_locked and g.game_memory_input==g.game_memory_seq
    return false
static func photo(g: Node,lane: String,key: String) -> void:
    if not valid(g,lane,key):return
    var t:=task(g,lane)
    for i in range(g.photo_points.size()):
        if str(g.photo_points[i].id)==str(t.at):
            g._close_commerce();g.story_photo_context={"lane":lane,"token":key,"index":i,"session":g.photo_session+1};g._start_photo_challenge(i);return
static func photo_finished(g: Node,index: int) -> void:
    var context: Dictionary=g.story_photo_context
    if context.is_empty() or int(context.index)!=index or int(context.session)!=g.photo_session:return
    if not g.photo_targets.all(func(t):return bool(g.photo_found.get(str(t.key),false))):return
    if valid(g,str(context.lane),str(context.token)):advance(g,str(context.lane),str(context.token),true)
    g.story_photo_context={}
