extends RefCounted
## Authored neighborhood stories use normal proximity, real puzzles and saved steps.
const STORIES: Array=[
    {"id":"pico","title":"Pico ist verschwunden","tag":"NACHBARSCHAFT","reward":160,"accent":"#f1cc8c","desc":"Emils kleiner Hund ist ausgebüxt. Folge seinen Spuren und bring ihn behutsam nach Hause.","steps":[
        {"at":"kiosk","task":"Mit Emil am Lindenkiosk sprechen","text":"Emil zeigt dir Picos Foto: braune Ohren, helle Pfoten. Er mag ruhige Stimmen und wartet gern beim Parkbrunnen.","act":"FOTO UND HINWEIS MERKEN"},
        {"at":"park","task":"Die Spuren am Parkbrunnen lesen","text":"Kleine Pfotenabdrücke laufen vom Wasser zum schattigen Rosenbogen. Am Straßenrand gibt es keine Spuren.","choices":["Zur großen Straße","Zum Rosenbogen","Zur Bushaltestelle"],"answer":1,"hint":"Die Pfotenabdrücke führen zum Rosenbogen."},
        {"at":"dog","task":"Pico am Rosenbogen beruhigen","text":"Pico wedelt, weicht aber vor schnellen Bewegungen zurück. Emil hatte dir geraten, ruhig zu sprechen.","choices":["Hinterherlaufen","Laut nach ihm rufen","Leise sprechen und warten"],"answer":2,"hint":"Pico braucht einen ruhigen Moment."},
        {"at":"kiosk","task":"Pico zu Emil zurückbringen","text":"Pico trottet neben dir. Emil kniet sich hin, und sofort landet eine feuchte Hundenase in seiner Hand.","act":"PICO NACH HAUSE BRINGEN"}]},
    {"id":"festival","title":"Ein Abend fürs Viertel","tag":"KULTUR & TECHNIK","reward":220,"accent":"#e5a5c7","desc":"Jo bereitet ein kleines Straßenfest vor. Licht, Blumen und eine freie Bühne fehlen noch.","steps":[
        {"at":"stage","task":"Jo an der kleinen Bühne treffen","text":"»Ein Fest braucht keine riesige Anlage«, sagt Jo. »Aber ohne Licht sieht niemand, wie schön unser Platz ist.« Der Schaltkasten ist gleich um die Ecke.","act":"BEIM FEST MITHELFEN"},
        {"at":"switch","task":"Die Lichterkette mit dem Stromkasten verbinden","text":"Drehe die Leitungen zu einem durchgehenden Netz. Der Schaltkasten versorgt die ganze Lichterkette.","puzzle":"wire","act":"LEITUNGSNETZ REPARIEREN"},
        {"at":"flowers","task":"Nelas Blumenkübel abholen","text":"Nela leiht drei Kübel für die Bühne. Sie sagt ausdrücklich: »Bitte die Töpfe zurückbringen – die Blumen dürfen bleiben.«","choices":["Töpfe als Leihgabe notieren","Alle Töpfe verschenken","Blumen im Laden lassen"],"answer":0,"hint":"Nela leiht die Töpfe; notiere die Rückgabe."},
        {"at":"stage","task":"Die Bühne für das Viertel eröffnen","text":"Das Licht geht an. Jo stimmt die Gitarre, Nela winkt vom Rand, und die ersten Nachbarn bleiben stehen.","act":"STRASSENFEST ERÖFFNEN"}]},
    {"id":"post","title":"Die blaue Nachbarschaftspost","tag":"KURIERGESCHICHTE","reward":180,"accent":"#a4cfe4","desc":"Eine kleine Sendung verbindet Kiosk, Atelier und Buchladen. Ihr Stempel verrät das richtige Ziel.","steps":[
        {"at":"post","task":"Die blaue Sendung an der Paketstation abholen","text":"Auf dem Päckchen steht »Für Lina – Buchladen«. Der Künstlerstempel fehlt noch; den bekommst du im Atelier.","act":"PÄCKCHEN EINPACKEN"},
        {"at":"atelier","task":"Im Atelier den passenden Stempel wählen","text":"Ada zeigt drei Stempel. Lina hat das blaue Wellenmotiv bestellt – es passt zu ihrem neuen Lesefenster.","choices":["Roter Blitz","Blaue Welle","Grünes Blatt"],"answer":1,"hint":"Linas Bestellung nennt ausdrücklich die blaue Welle."},
        {"at":"books","task":"Lina das gestempelte Päckchen bringen","text":"Lina öffnet das Päckchen: ein handgemachtes Schild für ihr Lesefenster. »Magst du Emil sagen, dass alles gut angekommen ist?«","act":"PÄCKCHEN ABGEBEN"},
        {"at":"kiosk","task":"Emil die Zustellung bestätigen","text":"Emil streicht die Sendung von seiner Liste. Hinter der nüchternen Paketnummer steckt jetzt eine kleine Geschichte.","act":"ZUSTELLUNG BESTÄTIGEN"}]},
    {"id":"garden","title":"Ein Garten zwischen Häusern","tag":"GRÜNES VIERTEL","reward":180,"accent":"#b6d9a0","desc":"Ein leeres Beet wird zur bunten Nachbarschaftsecke. Hilf beim Pflanzen und hinterlasse eine kleine Nachricht.","steps":[
        {"at":"garden","task":"Mara am Gemeinschaftsbeet treffen","text":"Mara möchte robuste, bienenfreundliche Blumen. »Ringelblumen wären wunderbar. Nela hat bestimmt welche.«","act":"BEIM BEET MITMACHEN"},
        {"at":"flowers","task":"Bienenfreundliche Pflanzen aussuchen","text":"Drei Kisten stehen bereit. Mara hat Ringelblumen genannt: Sie sind pflegeleicht und ihre offenen Blüten helfen den Bienen.","choices":["Kunststoffpalmen","Geschnittene Rosen","Ringelblumen"],"answer":2,"hint":"Mara braucht lebende Ringelblumen für das Beet."},
        {"at":"garden","task":"Die Pflanzen setzen und behutsam gießen","text":"Die Pflanzen stehen im lockeren Boden. Die Erde soll feucht werden, ohne die jungen Wurzeln wegzuspülen.","choices":["Den Weg fluten","Langsam an der Wurzel gießen","Ohne Wasser gehen"],"answer":1,"hint":"Ein langsamer Wasserstrahl schützt die jungen Pflanzen."},
        {"at":"library","task":"Eine Gartennotiz am Tauschregal hinterlassen","text":"Du legst eine kleine Pflegekarte zwischen die Bücher. Wer hier etwas mitnimmt, kann morgen auch das Beet gießen.","act":"PFLEGEKARTE HINTERLEGEN"}]},
    {"id":"radio","title":"Radio zwischen den Häusern","tag":"MUSIK & RÄTSEL","reward":240,"accent":"#c4b1e1","desc":"Sam sendet Musik fürs Viertel. Kalibriere die Anlage und finde die richtige Frequenz.","steps":[
        {"at":"records","task":"Sam am Plattenladen treffen","text":"Sam hat eine Sendung vorbereitet. Seine Notiz lautet »88,4 – ruhig zwischen den starken Sendern«. Zuerst muss der Verstärker kalibriert werden.","act":"BEI DER SENDUNG HELFEN"},
        {"at":"radio_box","task":"Das Spektrum des Verstärkers abstimmen","text":"Stimme die vier Kanäle auf das angezeigte Ziel ab. Erst das passende Spektrum lässt das Signal sauber durch.","puzzle":"frequency","act":"VERSTÄRKER KALIBRIEREN"},
        {"at":"antenna","task":"Die Antenne an der Uferpromenade prüfen","text":"Der kleine Richtungsanzeiger leuchtet grün. Ein Aufkleber bestätigt die Frequenz: 88,4.","act":"ANTENNE AUSRICHTEN"},
        {"at":"records","task":"Sams Sender einstellen","text":"Der Verstärker läuft ruhig. Welche Frequenz hatte Sam für seine Nachbarschaftssendung notiert?","choices":["108,9","76,0","88,4"],"answer":2,"hint":"Die Notiz und der Aufkleber nennen beide 88,4."},
        {"at":"stage","task":"Die erste Sendung am Platz einschalten","text":"Zwischen den Häusern klingt Sams erste Auswahl. Jo macht es sich auf der Bühnenkante bequem und hört zu.","act":"NACHBARSCHAFTSRADIO EINSCHALTEN"}]},
    {"id":"mural","title":"Farben für die Uferwand","tag":"KUNST IM ALLTAG","reward":200,"accent":"#8ed8cd","desc":"Ada gestaltet eine graue Ecke neu. Sammle Material und hilf beim Farbmuster.","steps":[
        {"at":"mural","task":"Ada an der Uferwand treffen","text":"Ada skizziert eine Sonne über Wellen. »Türkis fürs Wasser, Ocker für das Licht – und möglichst wiederverwendete Materialien.«","act":"ADAS ENTWURF ANSEHEN"},
        {"at":"recycling","task":"Saubere Materialreste am Recyclingstand holen","text":"Die Box enthält Holzreste, leere saubere Farbschalen und eine alte Pinselrolle. Alles lässt sich noch benutzen.","act":"MATERIAL EINPACKEN"},
        {"at":"atelier","task":"Das Farbmuster für die Uferwand wählen","text":"Adas Skizze zeigt warmes Sonnenlicht über kühlem Wasser. Welche beiden Farben hatte sie genannt?","choices":["Schwarz und Grau","Türkis und Ocker","Rot und Violett"],"answer":1,"hint":"Ada hat Wasser in Türkis und Licht in Ocker geplant."},
        {"at":"mural","task":"Das neue Uferbild freigeben","text":"Die Sonne auf der Wand fängt den echten Abend ein. Zwei Passanten bleiben stehen – diese Ecke hat jetzt ein Gesicht.","act":"WANDBILD VOLLENDEN"}]},
    {"id":"millpost","title":"Post hinter dem Heidekamm","tag":"STADT & LAND","reward":320,"accent":"#edc690","desc":"Eine längere Reise nach Mühlenau: Bring die Reparaturnotiz zur alten Mühle und hilf dem Dorf beim Licht.","steps":[
        {"at":"post","task":"Die Mühlenpost in der Stadt abholen","text":"Ein Umschlag für Tessa in Mühlenau. Das Dorf liegt weit hinter dem Freiland; Bus oder Auto machen die Reise angenehm.","act":"MÜHLENPOST MITNEHMEN"},
        {"at":"village_board","task":"Tessa am Dorfbrett von Mühlenau treffen","text":"Tessa bedankt sich. Die Notiz beschreibt das Leitungsnetz der Mühle. »Komm mit – vielleicht bekommen wir das Licht wieder an.«","act":"REPARATURNOTIZ ÜBERGEBEN"},
        {"at":"mill_box","task":"Den alten Mühlenkasten reparieren","text":"Verbinde die Leitungen zu einem geschlossenen Netz. Das reparierte Licht macht den Mühlenhof wieder nutzbar.","puzzle":"wire","act":"MÜHLENLICHT REPARIEREN"},
        {"at":"village_board","task":"Tessa vom reparierten Mühlenlicht erzählen","text":"Tessa hängt die gute Nachricht ans Dorfbrett. »Das nächste Mal gibt es Kuchen«, sagt sie. Zwischen Stadt und Dorf ist eine Verbindung entstanden.","act":"MÜHLENAUFTRAG ABSCHLIESSEN"}]}
]
static func place(id: String,name: String,pos: Vector2,kind: String,desc: String) -> Dictionary:
    return {"id":id,"name":name,"pos":pos,"kind":kind,"desc":desc}
static func build(g: Node) -> void:
    g.life_places=[
        place("kiosk","Emils Lindenkiosk",Vector2(5150,4650),"kiosk","Zeitungen, Nachbarschaftspost und ein freundliches Wort. Emil kennt die kleinen Geschichten des Viertels."),
        place("park","Brunnen am Taschenpark",Vector2(7470,4770),"fountain","Eine ruhige Ecke mit Wasser, Sitzrand und einem Rosenbogen. Hier fällt die Stadt für einen Moment leiser aus."),
        place("dog","Rosenbogen · Pico",Vector2(7750,4760),"dog","Zwischen Rosen und Pflanzkübeln wartet ein kleiner Hund mit braunen Ohren."),
        place("stage","Jos kleine Bühne",Vector2(7650,6680),"stage","Eine Holzplattform für kleine Konzerte. Das Viertel bringt seine eigene Kultur auf die Straße."),
        place("switch","Lichtkasten am Platz",Vector2(7470,6990),"utility","Ein unscheinbarer Kasten verbindet die Lichter über dem Platz."),
        place("flowers","Nelas Blumenstand",Vector2(5260,6780),"flowers","Blumen, Saatgut und geliehene Kübel. Nela hilft mit Pflanzen, die auch im Stadtalltag zurechtkommen."),
        place("post","Blaue Paketstation",Vector2(5380,9140),"post","Kleine Sendungen reisen von hier zu Nachbarn und manchmal weit hinaus aufs Land."),
        place("atelier","Adas Atelierfenster",Vector2(10240,6620),"atelier","Stempel, Farbproben und Skizzen erzählen von Adas Arbeiten für die Stadt."),
        place("books","Linas Lesefenster",Vector2(10260,4630),"books","Ein Lesefenster mit handgeschriebenen Empfehlungen. Lina findet für fast jeden Anlass eine Geschichte."),
        place("garden","Maras Gemeinschaftsbeet",Vector2(12700,6770),"garden","Ein gemeinsames Beet zwischen Häusern. Mara freut sich über jede helfende Hand."),
        place("library","Offenes Tauschregal",Vector2(12700,4730),"books","Nimm eine Geschichte mit, lass eine andere da. Auch Nachbarschaftsnotizen finden hier einen Platz."),
        place("records","Sams Plattenfenster",Vector2(15300,6720),"records","Vinyl, Kopfhörer und Sams Idee für ein kleines Nachbarschaftsradio."),
        place("radio_box","Verstärker am Plattenfenster",Vector2(15530,6790),"utility","Vier Kanäle müssen zusammenpassen, damit die Musik unverzerrt durchs Viertel klingt."),
        place("antenna","Uferantenne",Vector2(18120,9170),"antenna","Eine kleine Antenne fängt das Signal zwischen Häusern und Wasser ein."),
        place("mural","Adas Uferwand",Vector2(18310,11750),"mural","Eine graue Wand wird zur Leinwand für Sonnenlicht und Wasser."),
        place("recycling","Wiederverwendungsstand",Vector2(15400,11850),"recycling","Saubere Materialreste bekommen hier eine zweite Aufgabe."),
        place("arcade","Spieltisch am Bahnhof",Vector2(21400,6550),"arcade","Ein öffentlicher Rätseltisch. Die Leitungen lassen sich jederzeit kostenlos ausprobieren."),
        place("lookout","Bank der Abendlichter",Vector2(24600,14430),"bench","Eine Bank am östlichen Stadtrand. Ein guter Ort, um ohne Eile wieder zu Kräften zu kommen."),
        place("village_board","Mühlenau · Dorfbrett",Vector2(94950,29570),"post","Tessa sammelt Neuigkeiten von Hof, Mühle und Stadt."),
        place("mill_box","Lichtkasten der alten Mühle",Vector2(96095,32820),"utility","Das Dorf wartet auf die Reparatur des alten Mühlenlichts.")]
    var plazas: Array=[]
    for p in g.life_places:
        if Vector2(p.pos).x>=g.CITY_SIZE.x:continue
        var candidates: Array=[]
        var projections: Array=g.CityAccess.road_projections(g,p.pos)
        for i in range(mini(8,projections.size())):
            var road: Dictionary=projections[i]
            var normal:=Vector2(-road.tangent.y,road.tangent.x)
            for along in [0.0,-210.0,210.0,-440.0,440.0]:
                var road_point: Vector2=road.pos+road.tangent*along
                for side in [-1.0,1.0]:
                    var scene: Vector2=road_point+normal*(float(road.width)*.5+210)*side
                    var rect:=Rect2(scene-Vector2(150,115),Vector2(300,230))
                    if not Rect2(Vector2(50,50),g.CITY_SIZE-Vector2(100,100)).encloses(rect):continue
                    if plazas.any(func(r):return Rect2(r).grow(35).intersects(rect)):continue
                    if g._rect_near_road(rect,22):continue
                    var corridor: Rect2=rect.merge(Rect2(road_point-Vector2(35,35),Vector2(70,70)))
                    if g.landmarks.any(func(l):return g._landmark_rect(l).grow(28).intersects(corridor)):continue
                    if water_overlap(g,corridor):continue
                    if g.photo_points.any(func(ph):return corridor.grow(60).has_point(ph.pos)):continue
                    candidates.append({"scene":scene,"rect":rect,"corridor":corridor,"score":Vector2(p.pos).distance_squared_to(scene)})
        candidates.sort_custom(func(a,b):return a.score<b.score)
        if not candidates.is_empty():
            var chosen: Dictionary=candidates[0]
            p.scene=chosen.scene;p.plaza=chosen.rect;p.pos=chosen.scene+Vector2(0,70)
            plazas.append(chosen.rect)
            g.buildings=g.buildings.filter(func(b):return not Rect2(b.rect).intersects(chosen.corridor))
            g.trees=g.trees.filter(func(t):return not chosen.rect.has_point(t.pos))
            g.vegetation_props=g.vegetation_props.filter(func(v):return not chosen.rect.has_point(v.pos))
    var used: Array=[]
    for p in g.life_places:
        p.pos=g.CityAccess.safe_point(g,p.pos)
        if used.any(func(q):return Vector2(q).distance_to(p.pos)<155):
            for offset in [Vector2(240,0),Vector2(-240,0),Vector2(0,240),Vector2(0,-240)]:
                var candidate: Vector2=g.CityAccess.safe_point(g,p.pos+offset)
                if not used.any(func(q):return Vector2(q).distance_to(candidate)<155):p.pos=candidate;break
        used.append(p.pos)
static func water_overlap(g: Node,rect: Rect2) -> bool:
    var poly:=PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
    for water in g.waters:
        if not Rect2(water.rect).intersects(rect):continue
        if not water.has("polygon") or not Geometry2D.intersect_polygons(poly,water.polygon).is_empty():return true
    return false
static func story(id: String) -> Dictionary:
    for s in STORIES:
        if str(s.id)==id:return s
    return {}
static func get_place(g: Node,id: String) -> Dictionary:
    for p in g.life_places:
        if str(p.id)==id:return p
    return {}
static func step(g: Node) -> Dictionary:
    var s:=story(g.life_active)
    if s.is_empty():return {}
    var index: int=int(g.life_progress.get(g.life_active,0))
    return s.steps[index] if index>=0 and index<s.steps.size() else {}
static func target(g: Node) -> Vector2:
    var task:=step(g)
    return Vector2(get_place(g,task.at).pos) if not task.is_empty() else Vector2.ZERO
static func begin(g: Node,id: String) -> void:
    var s:=story(id)
    if s.is_empty():return
    if int(g.life_progress.get(id,0))>=s.steps.size():g.life_progress[id]=0
    g.life_active=id;g.map_waypoint={};g.region_contract={};g.navigation_timer=0
    g._close_overview();g._close_commerce();g._notify(str(s.title)+" · "+str(step(g).task));g._save_game();g._update_ui()
static func pause(g: Node) -> void:
    g.life_active="";g.navigation_timer=0;g._save_game()
static func valid(g: Node,id: String,index: int) -> bool:
    return g.life_active==id and int(g.life_progress.get(id,0))==index and not g.interior_active and g.current_vehicle<0 and g.player_pos.distance_to(target(g))<105
static func visit(g: Node,index: int) -> void:
    if index<0 or index>=g.life_places.size() or g.current_vehicle>=0:return
    var p: Dictionary=g.life_places[index]
    if g.player_pos.distance_to(p.pos)>=105:return
    if not bool(g.life_seen.get(p.id,false)):g.life_seen[p.id]=true;g.credits+=8;g._play_sfx("collect")
    var task:=step(g)
    if not task.is_empty() and str(task.at)==str(p.id):
        var s:=story(g.life_active);var current: int=int(g.life_progress.get(g.life_active,0))
        g._open_commerce(str(s.title),"%d / %d  ·  %s\n\n%s" % [current+1,s.steps.size(),str(p.name),str(task.text)])
        if task.has("choices"):
            for i in range(task.choices.size()):g.commerce_actions.add_child(g._commerce_button(str(task.choices[i]),choose.bind(g,str(s.id),current,i)))
        elif task.has("puzzle"):g.commerce_actions.add_child(g._commerce_button(str(task.act),puzzle.bind(g,str(s.id),current)))
        else:g.commerce_actions.add_child(g._commerce_button(str(task.act),advance.bind(g,str(s.id),current)))
    else:
        g._open_commerce(str(p.name),str(p.desc)+("\n\nDu hast diesen Ort in deinem Kiezbuch entdeckt."))
        for s in STORIES:
            if s.steps[0].at==p.id:g.commerce_actions.add_child(g._commerce_button(("GESCHICHTE ERNEUT SPIELEN · " if g.life_completed.get(s.id,false) else "GESCHICHTE · ")+str(s.title),begin.bind(g,str(s.id))))
        if p.kind in ["bench","fountain","garden","books"]:g.commerce_actions.add_child(g._commerce_button("KURZE PAUSE · ENERGIE AUFFÜLLEN",g.RegionWorld.rest.bind(g)))
        if p.kind=="arcade":g.commerce_actions.add_child(g._commerce_button("LEITUNGSRÄTSEL ÜBEN · KOSTENLOS",practice.bind(g)))
    g.commerce_actions.add_child(g._commerce_button("KIEZBUCH / AUFTRÄGE",g._open_overview.bind("missions")))
    g.commerce_actions.add_child(g._commerce_button("WEITER",g._close_commerce));g._save_game()
static func choose(g: Node,id: String,index: int,answer: int) -> void:
    if not valid(g,id,index):return
    var task:=step(g)
    if answer!=int(task.answer):g.commerce_info.text=str(task.text)+"\n\n"+str(task.hint);g._play_sfx("error");g._queue_modal_fit();return
    g.life_choices[id+":"+str(index)]=str(task.choices[answer]);advance(g,id,index)
static func advance(g: Node,id: String,index: int) -> void:
    if not valid(g,id,index):return
    var s:=story(id)
    g.life_progress[id]=index+1;g.navigation_timer=0;g._close_commerce()
    if index+1==s.steps.size():
        var first: bool=not bool(g.life_completed.get(id,false))
        if first:g.credits+=int(s.reward);g.city_reputation+=2
        g.life_completed[id]=true;g.life_active=""
        g._show_reward_popup("KIEZGESCHICHTE ABGESCHLOSSEN",str(s.title)+(" · +%d CR" % int(s.reward) if first else " · wieder erlebt"),Color(s.accent));g._play_sfx("secret")
    else:g._notify("Nächster Schritt · "+str(step(g).task))
    g._save_game();g._update_ui()
static func puzzle(g: Node,id: String,index: int) -> void:
    if not valid(g,id,index):return
    var task:=step(g)
    g._close_commerce();g._start_minigame({"id":"life:"+id+":"+str(index),"name":str(task.task),"game":str(task.puzzle),"difficulty":1,"reward":"Fortschritt im Kiezbuch","life":true,"story":id,"step":index})
    if str(task.puzzle)=="frequency" and g.game_current==g.game_target:g._on_frequency_cell(0)
static func practice(g: Node) -> void:
    g._close_commerce();g._start_minigame({"id":"life:practice","name":"Spieltisch · Leitungsnetz","game":"wire","difficulty":1,"reward":"Freies Rätseltraining","life":true,"story":"","step":-1})
static func puzzle_finished(g: Node,site: Dictionary) -> void:
    if str(site.story).is_empty():return
    advance(g,str(site.story),int(site.step))
static func save(g: Node) -> Dictionary:
    return {"seen":g.life_seen,"completed":g.life_completed,"progress":g.life_progress,"active":g.life_active,"choices":g.life_choices}
static func restore(g: Node,data: Dictionary) -> void:
    g.life_seen=Dictionary(data.get("seen",{}));g.life_completed=Dictionary(data.get("completed",{}));g.life_choices=Dictionary(data.get("choices",{}));g.life_progress={}
    for s in STORIES:g.life_progress[str(s.id)]=clampi(int(Dictionary(data.get("progress",{})).get(str(s.id),0)),0,s.steps.size())
    g.life_active=str(data.get("active",""))
    if story(g.life_active).is_empty() or step(g).is_empty():g.life_active=""
static func clear(g: Node) -> void:
    g.life_seen.clear();g.life_completed.clear();g.life_progress.clear();g.life_choices.clear();g.life_active=""
