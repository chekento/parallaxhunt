extends RefCounted
const Data=preload("res://scripts/romance_data.gd")
const World=preload("res://scripts/romance_world.gd")
const ROSE=Color("#e8b0ba")

static func blank_person() -> Dictionary:
    return {"met":false,"trust":0,"spark":0,"comfort":38,"pressure":0,"dates":0,"kissed":false,"status":"kennenlernen","used":{},"window":-1,"exchanges":0,"topics":{},"history":[],"future":"","last":""}
static func clear(g: Node,enabled: bool=false) -> void:
    g.love_state={"enabled":enabled,"hours":0.0,"people":{},"partner":"","focus":"","date":{},"tracking":false,"journal":[],"serial":0}
    g.home_state={"primary":"","leases":{},"living":false,"nursery":false,"family":0,"family_at":0.0,"family_path":"","rituals":{},"style":"warm"}
    g.love_session+=1;g.active_apartment=""
    for p in Data.PEOPLE:g.love_state.people[p.id]=blank_person()
static func restore(g: Node,data: Dictionary,homes: Dictionary) -> void:
    clear(g,true)
    g.love_state.enabled=bool(data.get("enabled",true))
    g.love_state.hours=clampf(float(data.get("hours",0)),0,1000000)
    g.love_state.serial=maxi(0,int(data.get("serial",0)))
    g.love_state.tracking=bool(data.get("tracking",false))
    for key in ["partner","focus"]:
        var id:=str(data.get(key,""))
        if not Data.person(id).is_empty():g.love_state[key]=id
    var people: Dictionary=data.get("people",{}) if data.get("people",{}) is Dictionary else {}
    for p in Data.PEOPLE:
        var old: Dictionary=people.get(p.id,{}) if people.get(p.id,{}) is Dictionary else {}
        var r: Dictionary=g.love_state.people[p.id]
        for key in ["trust","spark","comfort","pressure"]:r[key]=clampi(int(old.get(key,r[key])),0,100)
        for key in ["met","kissed"]:r[key]=bool(old.get(key,false))
        r.dates=clampi(int(old.get("dates",0)),0,10000);r.window=int(old.get("window",-1));r.exchanges=clampi(int(old.get("exchanges",0)),0,5)
        for key in ["used","topics"]:
            if old.get(key,{}) is Dictionary:r[key]=Dictionary(old.get(key,{})).duplicate(true)
        r.status=str(old.get("status","kennenlernen"))
        if not r.status in ["kennenlernen","beziehung","verlobt","verheiratet","freundschaft"]:r.status="kennenlernen"
        r.future=str(old.get("future",""));r.last=str(old.get("last",""))
        if old.get("history",[]) is Array:
            for value in old.get("history",[]):
                if value is String and not g.MainStory.location(g,value).is_empty():r.history.append(value)
    if data.get("journal",[]) is Array:
        for e in data.get("journal",[]):
            if e is Dictionary and e.has("text"):g.love_state.journal.append({"person":str(e.get("person","")),"text":str(e.text),"hour":maxf(0,float(e.get("hour",0)))})
    var leases: Dictionary=homes.get("leases",{}) if homes.get("leases",{}) is Dictionary else {}
    for id in leases:
        if World.home(g,str(id)).is_empty() or not leases[id] is Dictionary:continue
        var l: Dictionary=leases[id]
        if not str(l.get("mode","")) in ["rent","own"]:continue
        g.home_state.leases[id]={"mode":str(l.mode),"deposit":clampi(int(l.get("deposit",0)),0,int(World.home(g,id).deposit)),"next":maxf(g.love_state.hours-720,float(l.get("next",g.love_state.hours+72))),"arrears":clampi(int(l.get("arrears",0)),0,1000000)}
    if not g.owned_property.is_empty() and not World.home(g,g.owned_property).is_empty():
        g.home_state.leases[g.owned_property]={"mode":"own","deposit":0,"next":0.0,"arrears":0}
    var primary:=str(homes.get("primary",g.owned_property))
    if g.home_state.leases.has(primary):g.home_state.primary=primary
    elif not g.home_state.leases.is_empty():g.home_state.primary=str(g.home_state.leases.keys()[0])
    g.home_state.living=bool(homes.get("living",false)) and not g.love_state.partner.is_empty() and not g.home_state.primary.is_empty()
    g.home_state.nursery=bool(homes.get("nursery",false));g.home_state.family=clampi(int(homes.get("family",0)),0,2)
    if g.love_state.partner.is_empty():g.home_state.family=0
    g.home_state.family_at=clampf(float(homes.get("family_at",0)),0,1000000);g.home_state.family_path=str(homes.get("family_path",""))
    if homes.get("rituals",{}) is Dictionary:g.home_state.rituals=Dictionary(homes.get("rituals",{})).duplicate(true)
    g.home_state.style=str(homes.get("style","warm"))
    if not g.home_state.style in ["warm","sea","garden"]:g.home_state.style="warm"
    var date: Dictionary=data.get("date",{}) if data.get("date",{}) is Dictionary else {}
    var person_id:=str(date.get("person",""));var at:=str(date.get("at",""))
    if not Data.person(person_id).is_empty() and not g.MainStory.location(g,at).is_empty():
        g.love_state.date={"person":person_id,"at":at,"step":clampi(int(date.get("step",0)),0,2),"number":maxi(1,int(date.get("number",1)))}
    if is_instance_valid(g.romance_panel):g.romance_panel.visible=false

static func record(g: Node,id: String) -> Dictionary:
    return g.love_state.get("people",{}).get(id,{})
static func log_moment(g: Node,id: String,text: String) -> void:
    g.love_state.journal.append({"person":id,"text":text,"hour":float(g.love_state.hours)})
    if g.love_state.journal.size()>240:g.love_state.journal.pop_front()
static func persist(g: Node) -> void:
    g.navigation_timer=0;g._save_game();g._update_ui();g.queue_redraw()
static func begin_window(g: Node,r: Dictionary) -> void:
    var window:=int(float(g.love_state.hours)/8.0)
    if int(r.window)!=window:r.window=window;r.used={};r.exchanges=0;r.pressure=maxi(0,int(r.pressure)-8)
static func valid(g: Node,id: String,session: int) -> bool:
    if not g.love_state.enabled or g.love_session!=session or not is_instance_valid(g.romance_panel) or not g.romance_panel.visible:return false
    if g.photo_mode or g.current_vehicle>=0 or g.transit_riding>=0:return false
    if g.interior_active:return g.interior_kind=="apartment" and g.active_apartment==g.home_state.primary and bool(g.home_state.living) and id==g.love_state.partner
    return not Data.person(id).is_empty() and g.player_pos.distance_to(World.person_pos(g,id))<140
static func at_home(g: Node) -> bool:
    return g.interior_active and g.interior_kind=="apartment" and g.active_apartment==str(g.home_state.primary) and g.home_state.leases.has(g.active_apartment)
static func open(g: Node,id: String) -> void:
    if Data.person(id).is_empty() or not g.love_state.enabled or g.photo_mode or g.current_vehicle>=0 or g.transit_riding>=0:return
    var near: bool=g.player_pos.distance_to(World.person_pos(g,id))<140 and not g.interior_active
    var resident: bool=at_home(g) and g.home_state.living and id==g.love_state.partner
    if not near and not resident:return
    var r:=record(g,id);begin_window(g,r)
    if not r.met:r.met=true;r.trust=4;r.spark=3;log_moment(g,id,"Du hast "+str(Data.person(id).name)+" kennengelernt.")
    g.love_state.focus=id
    g.romance_panel.open_person(id)
    persist(g)
static func risk(g: Node,id: String,flirt_id: String) -> int:
    var p:=Data.person(id);var f:=Data.flirt(flirt_id);var r:=record(g,id)
    if p.is_empty() or f.is_empty():return 100
    var value:=int(f.risk)+int(r.pressure)*.6-int(r.trust)*.17-(int(r.comfort)-38)*.28
    value+=-8 if f.tone==p.tone else 6
    if int(f.risk)>=35 and int(r.spark)<25:value+=14
    if not g.love_state.partner.is_empty() and g.love_state.partner!=id:value+=30
    return clampi(int(value),3,92)
static func answer(g: Node,id: String,text: String) -> void:
    record(g,id).last=text
    g.romance_panel.open_person(id)
    persist(g)
static func flirt(g: Node,id: String,flirt_id: String,session: int) -> void:
    if not valid(g,id,session):return
    var r:=record(g,id);var p:=Data.person(id);var f:=Data.flirt(flirt_id)
    if f.is_empty():return
    begin_window(g,r)
    if not g.love_state.partner.is_empty() and g.love_state.partner!=id:
        record(g,g.love_state.partner).trust=maxi(0,int(record(g,g.love_state.partner).trust)-8)
        r.pressure=mini(100,int(r.pressure)+12)
        log_moment(g,id,"Eine zu romantische Annäherung widerspricht deiner vereinbarten festen Beziehung.")
        answer(g,id,"»Du bist in einer festen Beziehung. Ich möchte nicht die Person sein, mit der du diese Absprache übergehst. Wir können uns freundlich unterhalten.«");return
    if r.used.get(flirt_id,false) or int(r.exchanges)>=5:
        answer(g,id,"»Du musst mich nicht mit Sprüchen überreden. Lass den Moment doch einfach ein bisschen atmen.«\n\nFür dieses Gespräch sind die neuen Eindrücke gesammelt. Ein Date oder ein späterer Spielabschnitt schafft einen neuen Moment.");return
    r.used[flirt_id]=true;r.exchanges=int(r.exchanges)+1
    var chance:=risk(g,id,flirt_id)
    var random:=RandomNumberGenerator.new();random.seed=int(id.hash())+int(g.love_state.serial)*7919+int(r.dates)*101
    g.love_state.serial=int(g.love_state.serial)+1
    var success:=random.randi_range(0,99)>=chance
    if success:
        var matched: bool=f.tone==p.tone
        r.trust=mini(100,int(r.trust)+(6 if matched else 3));r.spark=mini(100,int(r.spark)+(8 if matched else 4));r.comfort=mini(100,int(r.comfort)+4);r.pressure=maxi(0,int(r.pressure)-2)
        var response:=str(p.yes) if matched else "»Du machst mich neugierig. Ich möchte dich lieber in deinem eigenen Tempo kennenlernen.«"
        answer(g,id,str(f.line)+"\n\n"+response+"\n\n"+("Ihr haltet den Blick einen Moment länger. Die Nähe ist gegenseitig." if int(r.spark)>=35 else "Das erste Knistern bleibt zwischen euch stehen."))
    else:
        r.trust=maxi(0,int(r.trust)-2);r.comfort=maxi(0,int(r.comfort)-8);r.pressure=mini(100,int(r.pressure)+12)
        answer(g,id,"»Das ist mir gerade zu forsch. Ich möchte erst herausfinden, ob wir uns wirklich verstehen.«\n\nSie weicht einen kleinen Schritt zurück. Gib ihr Raum; eine ehrliche Entschuldigung oder ein ruhiges Thema hilft mehr als Nachsetzen.")
static func topic(g: Node,id: String,key: String,session: int) -> void:
    if not valid(g,id,session) or not key in ["secret","dream"]:return
    var r:=record(g,id);var p:=Data.person(id)
    if not r.topics.get(key,false):r.topics[key]=true;r.trust=mini(100,int(r.trust)+7);r.comfort=mini(100,int(r.comfort)+5);log_moment(g,id,str(p.name)+" erzählt: "+str(p[key]))
    answer(g,id,"»"+str(p[key])+"«\n\nDu antwortest mit etwas Persönlichem aus deinem eigenen Leben. Ihr hört einander zu.")
static func apology(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session):return
    var r:=record(g,id);r.pressure=maxi(0,int(r.pressure)-18)
    answer(g,id,"»Danke, dass du das merkst. Ich mag Nähe, wenn sie sich für uns beide gut anfühlt.«\n\nDu nimmst Druck aus dem Gespräch. Dafür gibt es keine zusätzlichen Beziehungspunkte.")
static func gift(g: Node,id: String,gift_id: String,session: int) -> void:
    if not valid(g,id,session) or not Data.GIFTS.has(gift_id):return
    var r:=record(g,id);begin_window(g,r)
    if r.used.get("gift",false):answer(g,id,"»Ein Geschenk reicht. Bleib lieber noch ein bisschen bei mir.«");return
    var item: Dictionary=Data.GIFTS[gift_id]
    if g.credits<int(item.price):answer(g,id,"Für dieses Geschenk fehlen dir Credits. Ein aufmerksames Gespräch kostet nichts.");return
    g.credits-=int(item.price);r.used.gift=true
    var good:=str(Data.person(id).gift)==gift_id
    r.trust=mini(100,int(r.trust)+(5 if good else 1));r.spark=mini(100,int(r.spark)+(3 if good else 1))
    answer(g,id,"»Du hast dir etwas gemerkt. Das ist das Schöne daran.«" if good else "»Das ist lieb. Aber du musst nichts kaufen, damit ich dich kennenlernen möchte.«")
static func can_date(g: Node,id: String) -> bool:
    var r:=record(g,id)
    return not r.is_empty() and int(r.trust)>=18 and int(r.spark)>=12 and int(r.pressure)<35 and (g.love_state.partner.is_empty() or g.love_state.partner==id)
static func begin_date(g: Node,id: String,at: String,session: int) -> void:
    if not valid(g,id,session) or not can_date(g,id) or not at in Data.person(id).venues:return
    if not g.love_state.date.is_empty():answer(g,id,"Ihr habt bereits eine Verabredung. Beendet oder verschiebt sie zuerst im Reisebuch.");return
    if g.credits<18:answer(g,id,"Für die Verabredung sind 18 CR eingeplant. Sammle zuerst etwas Geld; euer bisheriger Fortschritt bleibt.");return
    g.credits-=18
    var r:=record(g,id)
    g.love_state.date={"person":id,"at":at,"step":0,"number":int(r.dates)+1};g.love_state.tracking=true;g.map_waypoint={}
    log_moment(g,id,"Verabredung bei "+str(g.MainStory.location(g,at).name)+". 18 CR einmalig für den gemeinsamen Abend.")
    close(g);persist(g);g._notify("DATE · "+str(Data.person(id).name)+" wartet am markierten Ort.")
static func date_choice(g: Node,id: String,choice: int,session: int) -> void:
    if not valid(g,id,session) or g.interior_active or g.love_state.date.is_empty() or g.love_state.date.person!=id or choice<0 or choice>2:return
    var date: Dictionary=g.love_state.date
    var location: Dictionary=g.MainStory.location(g,date.at)
    if g.player_pos.distance_to(location.pos)>=110:return
    var r:=record(g,id);var best:= ["attentive","playful","bold"].find(str(Data.person(id).tone))
    r.trust=mini(100,int(r.trust)+(6 if choice==best else 4));r.spark=mini(100,int(r.spark)+(6 if choice==best else 4));r.comfort=mini(100,int(r.comfort)+5);r.pressure=maxi(0,int(r.pressure)-8)
    var message: String="Sie lächelt und erzählt weiter. Eure Aufmerksamkeit bleibt ganz beieinander."
    if int(date.step)==2 and choice==2:
        if int(r.trust)>=35 and int(r.comfort)>=55 and int(r.spark)>=30:
            if not r.kissed:r.kissed=true;r.spark=mini(100,int(r.spark)+5);log_moment(g,id,"Euer erster Kuss. Sie hat selbst Ja gesagt.")
            message="»Ja«, sagt sie leise. Sie kommt dir entgegen. Ein warmer Kuss, ein kleines Lächeln – und niemand hat es eilig."
        else:message="»Heute lieber meine Hand«, sagt sie. Du nickst, und sie legt ihre Hand in deine. Ihre Grenze macht den Moment nicht weniger schön."
    date.step=int(date.step)+1
    if int(date.step)>=3:
        r.dates=int(r.dates)+1;r.history.append(str(date.at));r.used={};r.exchanges=0
        log_moment(g,id,"Date %d bei %s: %s" % [int(r.dates),str(location.name),message])
        g.love_state.date={};r.last=message+"\n\nDieser Abend gehört jetzt zu eurer Geschichte. Ihr könnt euch am ursprünglichen Treffpunkt wiedersehen."
        g.romance_panel.open_person(id,true);persist(g)
    else:answer(g,id,message)
static func kiss(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session):return
    var r:=record(g,id)
    if int(r.trust)<35 or int(r.spark)<30 or int(r.comfort)<55 or int(r.pressure)>20:
        r.pressure=mini(100,int(r.pressure)+5);answer(g,id,"»Noch nicht. Ich möchte diesen Schritt wirklich wollen.«\n\nDu respektierst ihre Antwort. Das Gespräch bleibt offen.");return
    if not g.love_state.partner.is_empty() and g.love_state.partner!=id:answer(g,id,"»Du hast eine feste Beziehung vereinbart. Diese Grenze möchte ich nicht überschreiten.«");return
    if not r.kissed:r.kissed=true;r.spark=mini(100,int(r.spark)+5);log_moment(g,id,"Euer erster gemeinsamer Kuss.")
    answer(g,id,"»Das möchte ich«, sagt sie. Sie bleibt nah, während ihr euch küsst. Als ihr euch wieder anseht, trägt ihr Lächeln den Moment weiter.")
static func commit(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session):return
    var r:=record(g,id)
    if not g.love_state.partner.is_empty() or int(r.dates)<2 or int(r.trust)<45 or int(r.spark)<35:
        answer(g,id,"»Ich möchte diese Entscheidung nicht zwischen zwei Sprüchen treffen. Lass uns erst echte gemeinsame Abende erleben.«\n\nFür eine feste Beziehung: 2 Dates, 45 Vertrauen und 35 Knistern.");return
    g.love_state.partner=id;r.status="beziehung"
    log_moment(g,id,"Ihr entscheidet euch beide für eine feste, exklusive Beziehung.")
    answer(g,id,"»Ja. Ich möchte mit dir zusammen sein – nicht nur, wenn der Abend gerade schön ist.«\n\nIhr vereinbart eine feste Beziehung und sprecht offen darüber, was euch wichtig ist.")
static func move_in(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session) or g.love_state.partner!=id:return
    if g.home_state.primary.is_empty():answer(g,id,"»Lass uns zuerst ein Zuhause finden, das wir uns leisten können.«\n\nMiete oder kaufe eine Wohnung im Reisebuch unter WOHNUNGEN.");return
    if int(record(g,id).trust)<55:answer(g,id,"»Ich möchte unser Vertrauen noch ein wenig wachsen lassen, bevor wir zusammenziehen.«\n\n55 Vertrauen werden gebraucht.");return
    if not g.home_state.living:g.home_state.living=true;log_moment(g,id,"Ihr zieht gemeinsam in "+str(World.home(g,g.home_state.primary).name)+" ein.")
    answer(g,id,"»Ein Schlüssel für uns beide. Das fühlt sich nach etwas Echtem an.«\n\nZu Hause könnt ihr kochen, Erinnerungen teilen, zusammen entspannen und eure Zukunft planen.")
static func future(g: Node,id: String,path: String,session: int) -> void:
    if not valid(g,id,session) or g.love_state.partner!=id or not path in ["family","together","open"]:return
    var r:=record(g,id)
    if int(r.trust)<65 or int(r.dates)<3:answer(g,id,"»Ich möchte unsere gemeinsame Zukunft mit Ruhe besprechen. Lass uns vorher noch etwas mehr miteinander erleben.«\n\n3 Dates und 65 Vertrauen werden gebraucht.");return
    r.future=path
    log_moment(g,id,"Gemeinsamer Zukunftswunsch: "+{"family":"eine Familie mit Kind","together":"erst einmal das Leben zu zweit","open":"offen und ohne Druck"}[path])
    answer(g,id,"»Ich bin froh, dass wir das zusammen entscheiden. Nähe fühlt sich am besten an, wenn wir beide darin Platz haben.«")
static func propose(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session) or g.love_state.partner!=id:return
    var r:=record(g,id)
    if r.status!="beziehung":return
    if int(r.dates)<3 or int(r.trust)<70 or int(r.spark)<60 or r.future.is_empty() or not g.home_state.living:
        answer(g,id,"»Ich möchte Ja zu unserem wirklichen Leben sagen. Lass uns dieses Leben erst gemeinsam aufbauen.«\n\nAntrag: 3 Dates, 70 Vertrauen, 60 Knistern, zusammen wohnen und über die Zukunft gesprochen haben.");return
    if g.credits<85:answer(g,id,"Für euren Erinnerungsring fehlen noch Credits. 85 CR werden gebraucht.");return
    g.credits-=85;r.status="verlobt"
    log_moment(g,id,"Sie sagt Ja zu deinem Antrag. Ihr seid verlobt.")
    answer(g,id,"Sie hält deinen Blick. »Ja. Nicht, weil alles immer leicht wird. Weil ich dieses Leben mit dir führen möchte.«\n\nSie küsst dich, bevor ihr beide zu lachen beginnt. Ihr seid verlobt.")
static func marry(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session) or g.love_state.partner!=id or record(g,id).status!="verlobt":return
    if g.credits<120:answer(g,id,"Für eure kleine Feier fehlen noch Credits. 120 CR werden gebraucht.");return
    g.credits-=120;record(g,id).status="verheiratet"
    log_moment(g,id,"Eure kleine Hochzeit: zwei freie Ja, Freunde und ein gemeinsamer Anfang.")
    answer(g,id,"Zwischen Blumen und Lichterketten sagt ihr beide Ja. Später legt sie ihre Hand in deine: »Ich freue mich auf die gewöhnlichen Tage mit dir. Und auf die unvernünftig schönen.«\n\nIhr seid verheiratet. Euer Alltag und eure Abenteuer gehen weiter.")
static func break_up(g: Node,id: String,session: int) -> void:
    if not valid(g,id,session) or g.love_state.partner!=id:return
    if int(g.home_state.family)>0:answer(g,id,"Eure Familiengeschichte bleibt bestehen. Der Familienbogen endet hier nicht durch einen beiläufigen Dialogknopf.");return
    record(g,id).status="freundschaft";record(g,id).trust=maxi(0,int(record(g,id).trust)-15)
    g.love_state.partner="";g.home_state.living=false
    log_moment(g,id,"Ihr beendet die feste Beziehung in einem offenen Gespräch. Gemeinsame Erinnerungen bleiben.")
    answer(g,id,"»Danke, dass du ehrlich bist. Ich brauche jetzt etwas Abstand.«\n\nDie feste Beziehung ist beendet. Eure bisherige Geschichte wird nicht gelöscht.")

static func target(g: Node) -> Vector2:
    if not g.love_state.get("enabled",false) or not g.love_state.get("tracking",false):return Vector2.ZERO
    if not g.love_state.date.is_empty():return Vector2(g.MainStory.location(g,g.love_state.date.at).get("pos",Vector2.ZERO))
    var id:=str(g.love_state.focus)
    if id.is_empty():return World.person_pos(g,"nela")
    if g.home_state.living and id==g.love_state.partner:
        var home:=World.home(g,g.home_state.primary)
        if not home.is_empty():return Vector2(home.pos)
    return World.person_pos(g,id)
static func task_text(g: Node) -> String:
    if not g.love_state.date.is_empty():return "Zum Treffpunkt gehen · aussteigen und DATE wählen"
    if g.home_state.living:return "Unser Zuhause betreten · gemeinsame Momente und Zukunft planen"
    return "Die markierte Frau kennenlernen · Gespräch, Flirt und Date selbst wählen"
static func focus(g: Node,id: String="") -> void:
    if not id.is_empty() and not Data.person(id).is_empty():g.love_state.focus=id
    g.love_state.tracking=true;g.map_waypoint={};g._close_overview();persist(g)
static func close(g: Node) -> void:
    g.love_session+=1
    if is_instance_valid(g.romance_panel):g.romance_panel.visible=false
    g.move_vec=Vector2.ZERO;g._sync_modal_ui()
static func cancel_date(g: Node) -> void:
    if not g.love_state.date.is_empty():log_moment(g,str(g.love_state.date.person),"Ihr verschiebt die Verabredung. Bisherige Nähe und abgeschlossene Dates bleiben.")
    g.love_state.date={};persist(g)
static func update(g: Node,delta: float) -> void:
    if not g.love_state.get("enabled",false):return
    g.love_state.hours=float(g.love_state.hours)+delta*.018
    charge_rent(g)
static func charge_rent(g: Node) -> void:
    for id in g.home_state.leases:
        var lease: Dictionary=g.home_state.leases[id]
        if lease.mode!="rent":continue
        var home:=World.home(g,id)
        if home.is_empty():continue
        var periods:=maxi(0,int(floor((float(g.love_state.hours)-float(lease.next))/72.0))+1) if float(g.love_state.hours)>=float(lease.next) else 0
        if periods>0:
            var due:=periods*int(home.rent);lease.next=float(lease.next)+periods*72.0
            var paid:=mini(g.credits,due);g.credits-=paid;lease.arrears=int(lease.arrears)+due-paid
            log_moment(g,"","Wohnmiete: %d CR. Offener Betrag: %d CR. Deine Wohnung und Geschichte bleiben erhalten." % [due,int(lease.arrears)])

static func housing(g: Node,id: String,mode: String,session: int) -> void:
    if g.love_session!=session or not g.romance_panel.visible or g.romance_panel.home_id!=id or g.photo_mode or g.current_vehicle>=0 or g.transit_riding>=0:return
    var home:=World.home(g,id)
    if home.is_empty() or (not g.interior_active and g.player_pos.distance_to(home.pos)>=145) or (g.interior_active and g.active_apartment!=id):return
    if not mode in ["rent","own","primary","pay","leave"]:return
    var existing: Dictionary=g.home_state.leases.get(id,{})
    if mode=="primary":
        if existing.is_empty():return
        if g.home_state.primary==id:return
        if int(g.home_state.family)>0 and int(home.capacity)<3:
            g.romance_panel.notice="Eure Familie braucht auch im neuen Zuhause Platz für mindestens drei Personen.";g.romance_panel.open_home(id);return
        g.home_state.primary=id;g.home_state.nursery=false
    elif mode=="pay":
        if existing.is_empty():return
        var debt:=int(existing.get("arrears",0))
        if g.credits<debt:g.romance_panel.notice="Zum Begleichen fehlen dir Credits.";g.romance_panel.open_home(id);return
        g.credits-=debt;existing.arrears=0
    elif mode=="leave":
        if existing.is_empty() or existing.mode!="rent":return
        if g.home_state.living and g.home_state.primary==id:g.romance_panel.notice="Wählt vor der Kündigung zuerst ein anderes gemeinsames Zuhause.";g.romance_panel.open_home(id);return
        var net:=int(existing.deposit)-int(existing.arrears)
        if g.credits+net<0:g.romance_panel.notice="Begleiche zuerst den offenen Mietbetrag.";g.romance_panel.open_home(id);return
        g.credits+=net;g.home_state.leases.erase(id)
        if g.home_state.primary==id:g.home_state.primary=""
    else:
        if mode=="rent" and not existing.is_empty():return
        if mode=="own" and existing.get("mode","")=="own":return
        var price:=int(home.rent)+int(home.deposit) if mode=="rent" else int(home.price)
        if mode=="own" and existing.get("mode","")=="rent":price=price-int(existing.deposit)+int(existing.arrears)
        if g.credits<price:g.romance_panel.notice="Du brauchst %d CR. Deine Credits bleiben unverändert." % price;g.romance_panel.open_home(id);return
        g.credits-=price
        g.home_state.leases[id]={"mode":mode,"deposit":int(home.deposit) if mode=="rent" else 0,"next":float(g.love_state.hours)+72,"arrears":0}
        if g.home_state.primary.is_empty():g.home_state.primary=id
        if bool(home.legacy) and mode=="own":g.owned_property=id;g._advance_native_chapter()
        log_moment(g,"",str(home.name)+(" gemietet." if mode=="rent" else " gekauft."))
    g.romance_panel.notice="Wohnstatus aktualisiert. Alle Preise und Miettermine stehen in deinem Reisebuch."
    g.romance_panel.open_home(id);persist(g)
static func enter_home(g: Node,id: String,viewing: bool=false) -> void:
    var home:=World.home(g,id)
    if home.is_empty() or g.current_vehicle>=0 or g.transit_riding>=0 or g.player_pos.distance_to(home.pos)>=145:return
    if not viewing and not g.home_state.leases.has(id):return
    close(g);g.active_apartment=id;g._enter_interior(str(home.name),"apartment",Color(home.color),home.pos)
static func home_action(g: Node,action: String,session: int) -> void:
    if g.love_session!=session or not g.romance_panel.visible or not at_home(g):return
    var id:=str(g.love_state.partner);var home:=World.home(g,g.active_apartment)
    if action=="rest":
        g.love_state.hours=float(g.love_state.hours)+8;g.world_clock=fposmod(g.world_clock+8,24);g.energy=100;charge_rent(g)
        g.romance_panel.notice="Acht Spielstunden später. Ausgeruht zu Hause; Mietfristen zählen nur in der Spielwelt.";g.romance_panel.open_home(home.id);persist(g);return
    if action in ["warm","sea","garden"]:g.home_state.style=action;g.romance_panel.notice="Dein Zuhause hat jetzt einen neuen Charakter.";g.romance_panel.open_home(home.id);persist(g);return
    if action=="nursery":
        if int(home.capacity)<3 or g.home_state.nursery or g.credits<120:return
        g.credits-=120;g.home_state.nursery=true;log_moment(g,id,"Ihr richtet ein kleines Familienzimmer ein.")
    elif action in ["meal","album","music"]:
        if id.is_empty() or not g.home_state.living:return
        var key:=action+":"+str(int(float(g.love_state.hours)/8))
        if not g.home_state.rituals.get(key,false):
            g.home_state.rituals[key]=true;var r:=record(g,id);r.trust=mini(100,int(r.trust)+4);r.spark=mini(100,int(r.spark)+3);r.comfort=mini(100,int(r.comfort)+3)
            log_moment(g,id,{"meal":"Ihr kocht zusammen. Kleine Gesten machen die Küche zu eurem Ort.","album":"Ihr schaut eure Erinnerungen an und sprecht darüber, welche Wege euch zusammengeführt haben.","music":"Ihr tanzt langsam im Wohnzimmer. Sie lehnt sich lächelnd an dich; der Abend darf leise werden."}[action])
        g.romance_panel.notice="Ein gemeinsamer Moment für eure Geschichte. Wiederholung im selben Spielabschnitt gibt keine zusätzlichen Punkte."
    elif action in ["family","adopt"]:
        if id.is_empty() or record(g,id).status!="verheiratet" or not g.home_state.living or int(g.home_state.family)!=0:return
        var r:=record(g,id)
        if int(home.capacity)<3 or not g.home_state.nursery or r.future!="family" or int(r.dates)<4 or int(r.trust)<85 or g.home_state.rituals.size()<3:
            g.romance_panel.notice="Familienwunsch gemeinsam besprechen, 4 Dates und 85 Vertrauen erreichen, 3 Alltagsmomente teilen und ein Familienzimmer einrichten.";g.romance_panel.open_home(home.id);return
        g.home_state.family=1;g.home_state.family_at=float(g.love_state.hours)+48;g.home_state.family_path=action
        log_moment(g,id,"Ihr entscheidet euch beide für eure Familiengeschichte. Die Vorbereitung läuft in der Spielwelt.")
    elif action=="welcome":
        if int(g.home_state.family)!=1 or float(g.love_state.hours)+0.000001<float(g.home_state.family_at) or int(home.capacity)<3:return
        g.home_state.family=2;log_moment(g,id,"Euer Kind ist zu Hause. Aus euren Begegnungen ist eine Familie geworden.")
        g.romance_panel.notice="Ein erzählerischer Zeitsprung: Ihr begrüßt euer Kind. Eure Familie und das offene Spiel gehen weiter."
    g.romance_panel.open_home(home.id);persist(g)

static func phase(g: Node) -> int:
    var id:=str(g.love_state.partner if not g.love_state.partner.is_empty() else g.love_state.focus)
    if id.is_empty() or not record(g,id).get("met",false):return 0
    var r:=record(g,id)
    if int(g.home_state.family)==2:return 8
    if r.status=="verheiratet":return 7
    if r.status=="verlobt":return 6
    if not r.future.is_empty() and g.home_state.living:return 5
    if g.home_state.living:return 4
    if g.love_state.partner==id:return 3
    if int(r.dates)>0:return 2
    return 1
