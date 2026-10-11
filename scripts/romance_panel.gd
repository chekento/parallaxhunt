extends PanelContainer
const Data=preload("res://scripts/romance_data.gd")
const World=preload("res://scripts/romance_world.gd")
const Portrait=preload("res://scripts/romance_portrait.gd")
const UI=preload("res://scripts/city_menus.gd")
var game: Node
var person_id: String=""
var home_id: String=""
var notice: String=""
var content: VBoxContainer
var heading: Label
var scroll: ScrollContainer
var actions: Dictionary={}
const ROSE=Color("#e8b0ba")

func setup(g: Node) -> void:
    game=g;position=Vector2(40,95);size=Vector2(1000,2140)
    add_theme_stylebox_override("panel",UI.card_style(Color("#14232a"),Color("#9c7680"),32))
    var column:=VBoxContainer.new();column.add_theme_constant_override("separation",20);add_child(column)
    var top:=HBoxContainer.new();column.add_child(top)
    var titles:=VBoxContainer.new();titles.size_flags_horizontal=Control.SIZE_EXPAND_FILL;top.add_child(titles)
    titles.add_child(UI.label("PARALLAX  /  HERZ & HEIM",22,ROSE));heading=UI.label("",37);titles.add_child(heading)
    var close_button=UI.button("SCHLIESSEN",func():game.Romance.close(game));close_button.custom_minimum_size=Vector2(215,84);top.add_child(close_button)
    scroll=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus=true;column.add_child(scroll)
    content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",18);scroll.add_child(content)
    column.add_child(UI.label("Ein Gespräch darf dauern.  ·  Wischen zeigt weitere Möglichkeiten.",21,Color("#9eb4b3")))
    visible=false

func prepare(title: String) -> void:
    game.love_session+=1;game._close_overview();game._close_dialogue();game._close_commerce()
    heading.text=title;visible=true;actions.clear();game.move_vec=Vector2.ZERO
    for child in content.get_children():content.remove_child(child);child.queue_free()
    scroll.scroll_vertical=0;game._sync_modal_ui()
func card(title: String,text: String,accent: Color=ROSE) -> VBoxContainer:
    var box:=PanelContainer.new();box.add_theme_stylebox_override("panel",UI.card_style(Color("#23333a"),Color(accent,.4),22));content.add_child(box)
    var v:=VBoxContainer.new();v.add_theme_constant_override("separation",13);box.add_child(v)
    if not title.is_empty():v.add_child(UI.label(title,27,accent))
    if not text.is_empty():v.add_child(UI.label(text,26,Color("#d7e1df")))
    return v
func add_action(parent: Control,key: String,text: String,callback: Callable,disabled: bool=false) -> Button:
    var b=UI.button(text,callback);b.disabled=disabled;parent.add_child(b);actions[key]=b;return b
func add_choice(parent: Control,key: String,text: String,callback: Callable,disabled: bool=false) -> Button:
    var b=UI.button("",callback);b.disabled=disabled;b.custom_minimum_size.y=132
    var l=UI.label(text,25,Color("#dbe4dd") if not disabled else Color("#86948f"));b.add_child(l);l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);l.offset_left=22;l.offset_right=-22;l.offset_top=14;l.offset_bottom=-14;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    parent.add_child(b);actions[key]=b;return b
func meters(r: Dictionary) -> void:
    var row:=HBoxContainer.new();row.add_theme_constant_override("separation",16);content.add_child(row)
    for item in [["Vertrauen","trust","#a9c9b4"],["Knistern","spark","#e8b0ba"],["Wohlgefühl","comfort","#e2c694"]]:
        var v:=VBoxContainer.new();v.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(v)
        v.add_child(UI.label(str(item[0])+" · "+str(int(r.get(item[1],0))),23,Color(item[2])))
        var bar:=ProgressBar.new();bar.show_percentage=false;bar.custom_minimum_size.y=12;bar.value=int(r.get(item[1],0));bar.add_theme_stylebox_override("background",UI.card_style(Color("#30434a"),Color.TRANSPARENT,0));bar.add_theme_stylebox_override("fill",UI.card_style(Color(item[2]),Color.TRANSPARENT,0));v.add_child(bar)
func open_person(id: String,remote: bool=false) -> void:
    var p:=Data.person(id)
    if p.is_empty():return
    person_id=id;home_id="";prepare(str(p.name)+" · Ein Moment für euch")
    var token: int=game.love_session;var r: Dictionary=game.Romance.record(game,id)
    var portrait:=Portrait.new();portrait.profile=p;portrait.custom_minimum_size=Vector2(0,210);content.add_child(portrait)
    meters(r)
    var status: String={"kennenlernen":"Kennenlernen","beziehung":"Feste Beziehung","verlobt":"Verlobt","verheiratet":"Verheiratet","freundschaft":"Freundschaft"}.get(str(r.status),"Kennenlernen")
    content.add_child(UI.label(status+" · "+str(int(r.dates))+" gemeinsame Dates"+(" · erster Kuss" if r.kissed else ""),23,ROSE))
    if not str(r.last).is_empty():card("IHRE REAKTION",str(r.last))
    else:card("DER ERSTE BLICK","»"+str(p.intro)+"«")
    if remote or not game.Romance.valid(game,id,token):
        var v=card("BIS ZUM NÄCHSTEN WIEDERSEHEN","Ihre Vorlieben, gemeinsamen Momente und euer Fortschritt bleiben gespeichert.",Color("#b3c8b8"))
        add_action(v,"route","ZU IHR · ROUTE VERFOLGEN",func():game.Romance.close(game);game.Romance.focus(game,id))
        return
    var date: Dictionary=game.love_state.date
    if not date.is_empty() and date.person==id and not game.interior_active and game.player_pos.distance_to(game.MainStory.location(game,date.at).pos)<110:
        var step: int=int(date.step);var beat: Dictionary=Data.DATE_BEATS[step]
        var v=card("DATE %d · %d / 3 · %s" % [int(date.number),step+1,str(beat.title)],str(beat.text))
        for i in range(3):
            var choice: int=i;add_choice(v,"date_"+str(i),str(beat.choices[i]),func():game.Romance.date_choice(game,id,choice,token))
        return
    var intro=card("WAS SIE MAG",{"attentive":"Aufmerksame Fragen, echte Erinnerungen und eine ruhige Stimme.","playful":"Humor, freche Blicke und Leichtigkeit ohne Druck.","bold":"Eine direkte Einladung und die Freiheit, selbst näherzukommen."}[p.tone]+"\n\nMutige Sätze können knistern. Wenn sie Abstand braucht, nimm Tempo heraus.",Color("#dbc797"))
    if int(r.pressure)>0:add_action(intro,"apology","TEMPO RAUSNEHMEN · EHRLICH ENTSCHULDIGEN",func():game.Romance.apology(game,id,token))
    var flirting=card("FLIRTEN · DEIN TON, IHRE REAKTION","%d / 5 neue Eindrücke in diesem Spielabschnitt. Ihre Antwort entscheidet, wie es weitergeht." % int(r.exchanges))
    for f in Data.FLIRTS:
        var fid: String=f.id;var risk: int=game.Romance.risk(game,id,fid)
        var used: bool=r.used.get(fid,false)
        add_choice(flirting,"flirt_"+fid,str(f.text)+"\n"+("Schon gesagt · keine neuen Punkte" if used else "Risiko einer unpassenden Annäherung: %d %%" % risk),func():game.Romance.flirt(game,id,fid,token))
    var personal=card("PERSÖNLICH WERDEN","Du kannst Geheimnisse, Wünsche und kleine Vorlieben kennenlernen.",Color("#b3c8b8"))
    add_action(personal,"secret","EINE PERSÖNLICHE GESCHICHTE HÖREN",func():game.Romance.topic(game,id,"secret",token))
    add_action(personal,"dream","WOVON TRÄUMST DU?",func():game.Romance.topic(game,id,"dream",token))
    for key in Data.GIFTS:
        var gift_id: String=key;var gift: Dictionary=Data.GIFTS[key]
        add_action(personal,"gift_"+key,str(gift.name)+" · "+str(int(gift.price))+" CR",func():game.Romance.gift(game,id,gift_id,token),game.credits<int(gift.price) or r.used.get("gift",false))
    var dates=card("EIN DATE VORSCHLAGEN","18 Vertrauen und 12 Knistern öffnen eine Verabredung. 18 CR für den Abend; ihr trefft euch am echten Ort.")
    for at in p.venues:
        var place_id: String=at;var loc: Dictionary=game.MainStory.location(game,place_id)
        add_action(dates,"invite_"+place_id,str(loc.get("name","Treffpunkt")),func():game.Romance.begin_date(game,id,place_id,token),not game.Romance.can_date(game,id) or not game.love_state.date.is_empty())
    var closeness=card("NÄHE & GEMEINSAME ZUKUNFT","Jeder größere Schritt entsteht aus einem gegenseitigen Ja.")
    add_action(closeness,"kiss","DÜRFTE ICH DICH KÜSSEN?",func():game.Romance.kiss(game,id,token))
    if game.love_state.partner.is_empty():add_action(closeness,"commit","EINE FESTE BEZIEHUNG VORSCHLAGEN",func():game.Romance.commit(game,id,token))
    elif game.love_state.partner==id:
        if not game.home_state.living:add_action(closeness,"move_in","WOLLEN WIR ZUSAMMENZIEHEN?",func():game.Romance.move_in(game,id,token))
        add_action(closeness,"future_family","ÜBER EINE GEMEINSAME FAMILIE SPRECHEN",func():game.Romance.future(game,id,"family",token))
        add_action(closeness,"future_together","ERST EINMAL DAS LEBEN ZU ZWEIT",func():game.Romance.future(game,id,"together",token))
        if r.status=="beziehung":add_action(closeness,"propose","EIN ANTRAG · ERINNERUNGSRING 85 CR",func():game.Romance.propose(game,id,token))
        if r.status=="verlobt":add_action(closeness,"marry","UNSERE KLEINE HOCHZEIT · 120 CR",func():game.Romance.marry(game,id,token))
        if int(game.home_state.family)==0:
            add_action(closeness,"breakup_dialog","ÜBER UNSERE BEZIEHUNG SPRECHEN",func():confirm_breakup(id))
    var finish=card("DEIN NÄCHSTER WEG","Du kannst diese Geschichte parallel zur Stadtstory verfolgen.",Color("#a8bfba"))
    add_action(finish,"track","BEZIEHUNGSBOGEN VERFOLGEN",func():game.Romance.close(game);game.Romance.focus(game,id))
func confirm_breakup(id: String) -> void:
    prepare("Ein ehrliches Gespräch");person_id=id;home_id="";var token: int=game.love_session
    var v=card("EURE BEZIEHUNG","Möchtest du die feste Beziehung beenden? Eure Erinnerungen bleiben; der Schritt verändert eure gemeinsame Zukunft.")
    add_action(v,"breakup_confirm","BEZIEHUNG OFFEN BEENDEN",func():game.Romance.break_up(game,id,token))
    add_action(v,"back","WEITER ZUSAMMEN BLEIBEN",func():open_person(id))

func open_home(id: String) -> void:
    var h:=World.home(game,id)
    if h.is_empty():return
    if home_id!=id:notice=""
    home_id=id;person_id="";prepare(str(h.name));var token: int=game.love_session
    card("EIN ORT FÜR DEIN LEBEN",str(h.desc)+"\n\n%d Zimmer · Platz für %d Personen" % [int(h.rooms),int(h.capacity)],Color("#dcc99c"))
    if not notice.is_empty():card("DEIN ZUHAUSE",notice,Color("#b2c7ad"))
    var lease: Dictionary=game.home_state.leases.get(id,{})
    var primary: bool=id==str(game.home_state.primary)
    var state: String="EIGENTUM" if lease.get("mode","")=="own" else ("GEMIETET" if not lease.is_empty() else "VERFÜGBAR")
    var costs=card(state+(" · HAUPTZUHAUSE" if primary else ""),"%d CR verfügbar\nMiete: %d CR je 3 Spieltage · Kaution: %d CR\nKaufpreis: %d CR\nKeine Kosten während du das Spiel geschlossen hast." % [game.credits,int(h.rent),int(h.deposit),int(h.price)],Color("#b8cdb2"))
    var near: bool=not game.interior_active and game.player_pos.distance_to(h.pos)<145 and game.current_vehicle<0 and game.transit_riding<0
    var inside: bool=game.interior_active and game.active_apartment==id
    if not near and not inside:
        add_action(costs,"home_route","WOHNUNG BESICHTIGEN · ROUTE STARTEN",func():game.Romance.close(game);game.map_waypoint={"pos":h.pos,"name":h.name};game.navigation_timer=0;game._save_game())
        return
    if lease.is_empty():
        add_action(costs,"rent","MIETEN · JETZT %d CR" % (int(h.rent)+int(h.deposit)),func():game.Romance.housing(game,id,"rent",token),game.credits<int(h.rent)+int(h.deposit))
        add_action(costs,"buy","KAUFEN · %d CR" % int(h.price),func():game.Romance.housing(game,id,"own",token),game.credits<int(h.price))
    elif lease.mode=="rent":
        costs.add_child(UI.label("Nächste Miete in %d Spielstunden · offen: %d CR" % [maxi(0,int(float(lease.next)-float(game.love_state.hours))),int(lease.arrears)],23,Color("#b8cdb2")))
        var buy_price: int=int(h.price)-int(lease.deposit)+int(lease.arrears)
        add_action(costs,"buy","KAUFEN · KAUTION ANGERECHNET · %d CR" % buy_price,func():game.Romance.housing(game,id,"own",token),game.credits<buy_price)
        if int(lease.arrears)>0:add_action(costs,"pay","OFFENE MIETE BEGLEICHEN · %d CR" % int(lease.arrears),func():game.Romance.housing(game,id,"pay",token),game.credits<int(lease.arrears))
        if not (primary and game.home_state.living):add_action(costs,"leave","MIETE BEENDEN · KAUTION ABRECHNEN",func():game.Romance.housing(game,id,"leave",token))
    if not lease.is_empty() and not primary:add_action(costs,"primary","ALS HAUPTZUHAUSE WÄHLEN",func():game.Romance.housing(game,id,"primary",token))
    if near:add_action(costs,"enter","BETRETEN" if not lease.is_empty() else "KOSTENLOS BESICHTIGEN",func():game.Romance.enter_home(game,id,lease.is_empty()))
    if bool(h.legacy) and not lease.is_empty():add_action(costs,"garage","BESTEHENDE HAUSGARAGE",func():game.Romance.close(game);game._enter_interior(str(h.name),"home",Color(h.color),h.pos);game.interior_floor=1)
    if not inside or lease.is_empty():return
    if not primary:card("DEINE WOHNUNG","Wähle diesen Ort als Hauptzuhause, um hier Alltag und Familiengeschichte fortzuführen.",Color("#b2c7ad"));return
    var everyday=card("ANKOMMEN & BLEIBEN","Die Wohnung ist begehbar. Küche, Ruhebereich und Wohnzimmertisch öffnen gemeinsame Momente.",Color("#dcc99c"))
    add_action(everyday,"rest","AUSRUHEN · +8 SPIELSTUNDEN · ENERGIE AUFFÜLLEN",func():game.Romance.home_action(game,"rest",token))
    if game.home_state.living:
        for item in [["meal","GEMEINSAM KOCHEN"],["album","ERINNERUNGEN TEILEN"],["music","LANGSAM ZUSAMMEN TANZEN"]]:
            var action_id: String=item[0];add_action(everyday,action_id,item[1],func():game.Romance.home_action(game,action_id,token))
        add_action(everyday,"partner","EIN INTIMER MOMENT MIT "+str(Data.person(str(game.love_state.partner)).name).to_upper(),func():game.Romance.open(game,str(game.love_state.partner)))
    var design=card("DEIN STIL","Wohntextilien, Farben und Fensterlicht geben dem Ort einen eigenen Charakter.",Color("#a6bfba"))
    for item in [["warm","WARM & GEMÜTLICH"],["sea","BLAUE STUNDE"],["garden","GRÜNER RÜCKZUG"]]:
        var style_id: String=item[0];add_action(design,"style_"+style_id,item[1],func():game.Romance.home_action(game,style_id,token))
    var family=card("RAUM FÜR EURE FAMILIE","Für eine Familie: gemeinsamer Wunsch, Ehe, 4 Dates, 85 Vertrauen, drei Alltagsmomente und ein eingerichtetes Familienzimmer.")
    if int(h.capacity)<3:family.add_child(UI.label("Diese Wohnung ist ein Zuhause zu zweit. Für ein Kind braucht ihr eine größere Wohnung.",25,ROSE));return
    if not game.home_state.nursery:add_action(family,"nursery","FAMILIENZIMMER EINRICHTEN · 120 CR",func():game.Romance.home_action(game,"nursery",token),game.credits<120)
    if int(game.home_state.family)==0:
        add_action(family,"family","UNSERE FAMILIENGESCHICHTE BEGINNEN",func():game.Romance.home_action(game,"family",token))
        add_action(family,"adopt","GEMEINSAM EIN KIND AUFNEHMEN",func():game.Romance.home_action(game,"adopt",token))
    elif int(game.home_state.family)==1:
        var remaining: int=ceili(maxf(0,float(game.home_state.family_at)-float(game.love_state.hours)-0.000001))
        family.add_child(UI.label("Eure gemeinsame Vorbereitung: noch %d Spielstunden. Ihr könnt weiter Abenteuer erleben oder zu Hause ausruhen. Ein erzählerischer Zeitsprung führt zum nächsten Lebensabschnitt." % remaining,25,Color("#c9d7cf")))
        add_action(family,"welcome","UNSER KIND WILLKOMMEN HEISSEN",func():game.Romance.home_action(game,"welcome",token),remaining>0)
    else:family.add_child(UI.label("Euer Kind ist zu Hause. Deine Familie, Wohnung, Partnerschaft und eure Geschichte bleiben dauerhaft gespeichert.",26,ROSE))
