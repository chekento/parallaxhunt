extends RefCounted
const Data=preload("res://scripts/romance_data.gd")
const World=preload("res://scripts/romance_world.gd")

static func frames(g: Node,count: int=2) -> void:
    for i in range(count):await g.get_tree().process_frame
static func press(g: Node,key: String) -> void:
    assert(g.romance_panel.actions.has(key),"Expected real UI action: "+key)
    var b: Button=g.romance_panel.actions[key]
    assert(not b.disabled,"The required UI action is enabled: "+key)
    b.pressed.emit();await frames(g)
static func touch(g: Node,point: Vector2,index: int=0) -> void:
    var e:=InputEventScreenTouch.new();e.index=index;e.position=g.get_viewport().get_screen_transform()*point;e.pressed=true;Input.parse_input_event(e);await frames(g)
    e=e.duplicate();e.pressed=false;Input.parse_input_event(e);await frames(g)
static func go(g: Node,p: Vector2) -> void:
    g.Romance.close(g);g._close_overview();g._close_commerce();g._close_dialogue()
    if g.interior_active:g._leave_interior()
    g.player_pos=p;g.camera_pos=p;g.current_vehicle=-1;g.transit_riding=-1;g.move_vec=Vector2.ZERO;g._update_ui()
    await frames(g)
static func saved_equal(a: Variant,b: Variant) -> bool:
    if (a is float or a is int) and (b is float or b is int):return absf(float(a)-float(b))<0.000001
    if a is Dictionary and b is Dictionary:
        if a.size()!=b.size():return false
        for key in a:
            if not b.has(key) or not saved_equal(a[key],b[key]):return false
        return true
    if a is Array and b is Array:
        if a.size()!=b.size():return false
        for i in range(a.size()):
            if not saved_equal(a[i],b[i]):return false
        return true
    return a==b
static func talk(g: Node,id: String) -> void:
    await go(g,World.person_pos(g,id));g.Romance.open(g,id);await frames(g)
    assert(g.romance_panel.visible and g._modal_active() and not g.hud_root.visible,"Romance is a true isolated modal")
static func real_date(g: Node,id: String,at: String) -> void:
    await talk(g,id)
    var money: int=g.credits;var previous: int=g.Romance.record(g,id).dates
    await press(g,"invite_"+at)
    assert(g.credits==money-18 and g.love_state.date.person==id,"Date budget is paid exactly once")
    var pos: Vector2=g.MainStory.location(g,at).pos
    assert(g.CityAccess.connected(g,pos,14),"Date venue has an actual approach")
    await go(g,pos)
    assert(g._nearest_interactable().get("action","")=="DATE","The scheduled date wins its own action button")
    g._interact();await frames(g)
    await press(g,"date_0")
    var pending: Dictionary=g.love_state.date.duplicate(true)
    g._save_game();g.Romance.close(g);g._load_game(3)
    assert(g.love_state.date==pending and g.credits==money-18,"Half-finished dates survive save/load without paying again")
    g.Romance.open(g,id);await frames(g)
    await press(g,"date_0")
    await press(g,"date_2")
    assert(g.love_state.date.is_empty() and int(g.Romance.record(g,id).dates)==previous+1,"Three real conversation choices complete one date")

static func room_route(g: Node,target: Vector2) -> bool:
    var start:=Vector2i(23,57);var end:=Vector2i(roundi(target.x/20),roundi(target.y/20));var open: Array[Vector2i]=[start];var seen: Dictionary={start:true}
    while not open.is_empty():
        var at: Vector2i=open.pop_front()
        if at.distance_to(end)<=1:return true
        for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
            var next: Vector2i=at+d
            if seen.has(next) or not g._interior_walkable(Vector2(next)*20):continue
            seen[next]=true;open.append(next)
    return false

static func run(g: Node) -> void:
    g.main_menu_active=false;g.main_menu_panel.visible=false;g.selected_save_slot=3
    g._reset_game_state();g.MainStory.clear(g,false);g.credits=5000
    assert(Data.PEOPLE.size()==24 and g.apartment_sites.size()==15)
    var ids: Dictionary={}
    for p in Data.PEOPLE:
        assert(int(p.age)>=24 and not ids.has(p.id),"All romance characters are distinct adults");ids[p.id]=true
        var pos:=World.person_pos(g,p.id)
        assert(g.CityAccess.connected(g,pos,14),"Every woman has a walking approach")
        var route: PackedVector2Array=g.WorldNavigation.route(g,Vector2(5100,4220),pos)
        assert(not route.is_empty(),"Every woman can be reached through the existing country and city road graph")
        await talk(g,p.id)
        assert(g.romance_panel.person_id==p.id and g.Romance.record(g,p.id).met)
        await press(g,"secret");await press(g,"dream")
        var favorite: String="listen" if p.tone=="attentive" else ("smile" if p.tone=="playful" else "close")
        await press(g,"flirt_"+favorite)
        assert(g.Romance.record(g,p.id).topics.size()==2,"Each adult has an authored personal story and dream")
    for h in g.apartment_sites:
        assert(g.CityAccess.connected(g,h.pos,18),"Each real apartment entrance has body clearance")
        var route: PackedVector2Array=g.WorldNavigation.route(g,Vector2(5100,4220),h.pos)
        assert(not route.is_empty(),"Apartments are connected to the road graph")
        for k in range(route.size()-1):assert(g.CityAccess.path_clear(g,route[k],route[k+1],14),"Home routes may not cross a building or open water")
    # Real touch opens the nearby encounter without dragging the street player.
    await go(g,World.person_pos(g,"mira"));g._update_ui();await frames(g)
    assert(g.love_hint_button.visible)
    await touch(g,g.love_hint_button.position+g.love_hint_button.size*.5)
    assert(g.romance_panel.visible and g.move_touch==-1 and g.move_vec==Vector2.ZERO)
    var stale: Callable=g.romance_panel.actions.flirt_listen.get_signal_connection_list("pressed")[0].callable
    await talk(g,"nova");var old: Dictionary=g.love_state.duplicate(true);stale.call()
    assert(g.love_state==old,"A callback from another woman's closed dialogue cannot alter a relationship")
    await talk(g,"mira")
    var before: Dictionary=g.Romance.record(g,"mira").duplicate(true)
    await press(g,"secret");assert(g.Romance.record(g,"mira").trust==before.trust,"Retelling a secret cannot farm affinity")
    var used: String=str(g.Romance.record(g,"mira").used.keys()[0]);before=g.Romance.record(g,"mira").duplicate(true)
    await press(g,"flirt_"+used)
    assert(g.Romance.record(g,"mira").trust==before.trust and g.Romance.record(g,"mira").spark==before.spark,"Repeated lines give no additional points")
    var comfort: int=g.Romance.record(g,"mira").comfort
    g.Romance.apology(g,"mira",g.love_session);await frames(g)
    assert(g.Romance.record(g,"mira").comfort==comfort,"Apologies cannot farm permission or intimacy")
    var r: Dictionary=g.Romance.record(g,"mira")
    var early: int=r.pressure
    await talk(g,"charlotte");await press(g,"kiss")
    assert(not g.Romance.record(g,"charlotte").kissed,"Early intimate requests are declined without an unwanted kiss")
    # Housing costs, duplicate guards, viewing and recoverable rent debt.
    var studio:=World.home(g,"lindenstudio");await go(g,studio.pos);g.romance_panel.open_home(studio.id);await frames(g)
    var money: int=g.credits;var duplicate_rent: Callable=g.romance_panel.actions.rent.get_signal_connection_list("pressed")[0].callable
    await press(g,"rent");assert(g.credits==money-int(studio.rent)-int(studio.deposit))
    var paid: int=g.credits;duplicate_rent.call();assert(g.credits==paid,"A stale purchase button cannot charge twice")
    g.love_state.hours=g.home_state.leases[studio.id].next;g.Romance.charge_rent(g)
    assert(g.credits==paid-int(studio.rent));paid=g.credits;g.Romance.charge_rent(g);assert(g.credits==paid)
    var debt_budget: int=g.credits;g.credits=0;g.love_state.hours=g.home_state.leases[studio.id].next;g.Romance.charge_rent(g)
    assert(g.home_state.leases[studio.id].arrears==int(studio.rent) and g.home_state.primary==studio.id,"Rent debt never deletes the home or story")
    g.credits=debt_budget;g.romance_panel.open_home(studio.id);await press(g,"pay");assert(g.home_state.leases[studio.id].arrears==0)
    var rich:=World.home(g,"aurorapenthouse");await go(g,rich.pos);g.romance_panel.open_home(rich.id);await frames(g)
    g.credits=0;var snapshot: Dictionary=g.home_state.duplicate(true);g.Romance.housing(g,rich.id,"own",g.love_session)
    assert(g.credits==0 and g.home_state==snapshot,"Unaffordable property purchases are rejected atomically")
    g.credits=5000
    await go(g,Vector2(5100,4220));g.romance_panel.open_home(rich.id);await frames(g)
    assert(not g.romance_panel.actions.has("buy"));snapshot=g.home_state.duplicate(true);g.Romance.housing(g,rich.id,"rent",g.love_session);assert(g.home_state==snapshot,"Remote catalogue cards cannot buy or rent")
    # Play the second main arc through actual dialogue controls.
    g.Romance.close(g);g.Romance.clear(g,true);g.credits=5000
    await talk(g,"mira");await press(g,"secret");await press(g,"dream");await press(g,"gift_book")
    for key in ["listen","voice","smile","tease","close"]:await press(g,"flirt_"+key)
    assert(g.Romance.can_date(g,"mira"),"Considerate conversations genuinely unlock a date")
    await real_date(g,"mira","books")
    await talk(g,"mira")
    for key in ["listen","voice","smile"]:await press(g,"flirt_"+key)
    await real_date(g,"mira","lake_view")
    await talk(g,"mira");await press(g,"commit")
    assert(g.love_state.partner=="mira" and g.Romance.record(g,"mira").status=="beziehung")
    await press(g,"move_in");assert(not g.home_state.living,"Moving in needs an actual home")
    var family_home:=World.home(g,"oldtownflat");await go(g,family_home.pos);g.romance_panel.open_home(family_home.id);await frames(g)
    money=g.credits;await press(g,"rent");assert(g.credits==money-int(family_home.rent)-int(family_home.deposit))
    money=g.credits;await press(g,"buy");assert(g.credits==money-int(family_home.price)+int(family_home.deposit))
    assert(g.home_state.leases[family_home.id].mode=="own" and g.home_state.primary==family_home.id)
    await talk(g,"mira");await press(g,"move_in");assert(g.home_state.living)
    await real_date(g,"mira","echo_view")
    await talk(g,"mira");await press(g,"future_family");await press(g,"propose")
    assert(g.Romance.record(g,"mira").status=="verlobt");await press(g,"marry")
    assert(g.Romance.record(g,"mira").status=="verheiratet")
    await real_date(g,"mira","books")
    await go(g,family_home.pos);g.romance_panel.open_home(family_home.id);await frames(g);await press(g,"enter")
    assert(g.interior_active and g.interior_kind=="apartment")
    for point in [Vector2(360,390),Vector2(565,495),Vector2(375,625),Vector2(460,840),Vector2(575,970),Vector2(460,1210)]:assert(room_route(g,point),"Apartment kitchen, bed, partner, family area and exit stay walkable")
    g.romance_panel.open_home(family_home.id);await frames(g)
    await press(g,"meal");await press(g,"album");await press(g,"music");await press(g,"nursery")
    assert(g.home_state.rituals.size()==3 and g.home_state.nursery)
    var progress: Dictionary=g.home_state.rituals.duplicate();var trust: int=g.Romance.record(g,"mira").trust
    await press(g,"meal");assert(g.home_state.rituals==progress and g.Romance.record(g,"mira").trust==trust)
    await press(g,"family");assert(g.home_state.family==1)
    assert(g.romance_panel.actions.welcome.disabled,"Family preparation takes actual in-game time")
    for i in range(6):await press(g,"rest")
    await press(g,"welcome");assert(g.home_state.family==2 and g.Romance.phase(g)==8)
    var complete: Dictionary=g.home_state.duplicate(true);var people: Dictionary=g.love_state.people.duplicate(true);money=g.credits
    g._save_game();g.Romance.close(g);g._leave_interior();g._load_game(3)
    assert(saved_equal(g.home_state,complete) and saved_equal(g.love_state.people,people) and g.credits==money,"The entire family arc, ownership, money and individual relationships survive save/load, allowing only sub-microhour JSON rounding")
    await talk(g,"nova");trust=g.Romance.record(g,"mira").trust;var new_spark: int=g.Romance.record(g,"nova").spark
    await press(g,"flirt_close");assert(g.Romance.record(g,"nova").spark==new_spark and g.Romance.record(g,"mira").trust<trust,"Flirting across an agreed relationship has real consequences")
    # Native touch on the new second navigation row, then a legacy save migration.
    g.Romance.close(g);g._open_overview("missions");await frames(g,4)
    var nav: HBoxContainer=g.city_menus.content.get_child(1);var button: Button=nav.get_child(0)
    await touch(g,button.global_position+button.size*.5)
    assert(g.city_menus.mission_tab=="Herz & Heim" and g.move_touch==-1)
    g._close_overview();g.owned_property="canal_loft";g._save_game()
    var file=FileAccess.open(g._save_path(),FileAccess.READ);var old_save: Dictionary=JSON.parse_string(file.get_as_text());file.close()
    old_save.erase("romance");old_save.erase("homes");old_save.save_version=3
    file=FileAccess.open(g._save_path(),FileAccess.WRITE);file.store_string(JSON.stringify(old_save));file.close();money=g.credits
    g._load_game(3)
    assert(g.love_state.enabled and g.home_state.leases.canal_loft.mode=="own" and g.home_state.primary=="canal_loft" and g.credits==money,"Earlier owned housing migrates without another charge")
    print("ROMANCE_SMOKE_OK · 24 distinct adult women / real dialogue and risk / proximity touch / full dates with saved halfway progress / guarded callbacks / 15 accessible apartments / real rent and purchase costs / debt and migration / begehbare rooms / relationship, wedding and family through actual actions")
    g.get_tree().quit()

static func capture(g: Node) -> void:
    g.main_menu_active=false;g.main_menu_panel.visible=false;g.selected_save_slot=3;g._reset_game_state();g.MainStory.clear(g,false);g.credits=5000
    DirAccess.make_dir_recursive_absolute("res://build")
    await go(g,World.person_pos(g,"nela"));g.world_zoom=2.65;g.target_world_zoom=2.65;await frames(g,8);await g._capture_quality_frame("romance-street")
    g.Romance.open(g,"nela");await frames(g,5);await g._capture_quality_frame("romance-profile")
    await press(g,"flirt_smile");await g._capture_quality_frame("romance-response")
    g.Romance.close(g);g._open_overview("missions");g.city_menus.mission_tab="Herz & Heim";g.city_menus.show_section("missions");await frames(g,5);await g._capture_quality_frame("romance-book")
    g.city_menus.mission_tab="Wohnungen";g.city_menus.show_section("missions");await frames(g,5);await g._capture_quality_frame("romance-homes")
    var home:=World.home(g,"oldtownflat");await go(g,home.pos);g.camera_pos=home.scene;g.world_zoom=2.65;await frames(g,4);await g._capture_quality_frame("romance-exterior")
    g.romance_panel.open_home(home.id);await frames(g,5);await g._capture_quality_frame("romance-rental")
    await press(g,"rent");await press(g,"enter");g.interior_player_pos=Vector2(420,730);await frames(g,5);await g._capture_quality_frame("romance-apartment")
    g.home_state.living=true;g.love_state.partner="nela";g.Romance.record(g,"nela").status="verheiratet";g.home_state.nursery=true
    await frames(g,5);await g._capture_quality_frame("romance-family-room")
    g.romance_panel.open_home(home.id);await frames(g,5);await g._capture_quality_frame("romance-home-menu")
    g.Romance.close(g);g.Romance.open(g,"nela");await frames(g,5);await g._capture_quality_frame("romance-at-home")
    print("ROMANCE_CAPTURE_OK");g.get_tree().quit()
