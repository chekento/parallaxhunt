extends RefCounted
## Exercise actual interaction buttons and puzzle moves, including save migration.
static func solve(g: Node) -> void:
    if g.game_type=="wire":
        for i in range(g.game_current.size()):
            var turns:=0
            while int(g.game_current[i])!=int(g.game_target[i]) and turns<4 and not g.minigame_finishing:
                g._on_wire_cell(i);turns+=1
        assert(g._wire_solved(),"Wire story step must be solved through actual tile moves")
    else:
        for i in range(g.game_current.size()):
            var turns:=0
            while int(g.game_current[i])!=int(g.game_target[i]) and turns<5 and not g.minigame_finishing:
                g._on_frequency_cell(i);turns+=1
        assert(g.game_current==g.game_target,"Radio uses the actual frequency puzzle")
    await g.get_tree().create_timer(.75).timeout
    assert(not g.minigame_open,"Solved story puzzle closes cleanly")
static func play_step(g: Node) -> void:
    var id: String=g.life_active;var index: int=int(g.life_progress.get(id,0));var task: Dictionary=g.CityLife.step(g)
    g.player_pos=g.CityLife.target(g)
    assert(g._current_objective_pos()==g.player_pos,"Story guidance targets its real next interaction")
    assert(g._nearest_interactable().type=="life_place","Active story interaction takes priority at its own place")
    g._interact()
    assert(g.commerce_panel.visible and not g.hud_root.visible,"Story card owns input and hides the world HUD")
    var before: int=g.credits
    var original: Vector2=g.player_pos;g.player_pos+=Vector2(500,0)
    g.CityLife.advance(g,id,index)
    assert(int(g.life_progress.get(id,0))==index and g.credits==before,"Distant and stale callbacks cannot advance a story")
    g.player_pos=original
    if task.has("choices"):
        g.commerce_actions.get_child((int(task.answer)+1)%task.choices.size()).pressed.emit()
        assert(int(g.life_progress.get(id,0))==index,"Wrong choices keep the step available with a hint")
    g.commerce_actions.get_child(int(task.answer) if task.has("choices") else 0).pressed.emit()
    if task.has("puzzle"):
        assert(g.minigame_open and g.game_type==str(task.puzzle),"Story launches the promised real puzzle")
        g._finish_minigame()
        assert(int(g.life_progress.get(id,0))==index and not g.minigame_finishing,"Unsolved puzzles cannot advance a story")
        await solve(g)
    assert(int(g.life_progress.get(id,0))==index+1,"Interaction advances exactly one story step")
    var after: int=g.credits;g.CityLife.advance(g,id,index)
    assert(g.credits==after and int(g.life_progress.get(id,0))==index+1,"A repeated callback cannot pay or progress twice")
static func smoke(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false;g.selected_save_slot=3;g._sync_modal_ui()
    var path: String=g._save_path();var existed: bool=FileAccess.file_exists(path);var saved: String=FileAccess.get_file_as_string(path) if existed else ""
    g.active_npc_contract={};g.active_job={};g.region_contract={};g.map_waypoint={};g.current_vehicle=-1
    assert(g.life_places.size()==20 and g.CityLife.STORIES.size()==7,"Authored city and cross-country content is built")
    for p in g.life_places:
        assert(g.CityAccess.connected(g,p.pos,18),"A story place needs a body-clear approach: "+str(p.id))
        var route: PackedVector2Array=g.WorldNavigation.route(g,Vector2(5100,4220),p.pos)
        assert(route.size()>=2,"A route from the city reaches "+str(p.id))
        for i in range(route.size()-1):assert(g.CityAccess.path_clear(g,route[i],route[i+1],14),"Story route avoids walls and water")
    g.CityLife.clear(g);g.credits=500;g.city_reputation=0
    for s in g.CityLife.STORIES:
        var before: int=g.credits;var new_places: Dictionary={}
        for task in s.steps:
            if not g.life_seen.get(task.at,false):new_places[task.at]=true
        g.CityLife.begin(g,str(s.id))
        for i in range(s.steps.size()):await play_step(g)
        assert(g.life_completed.get(s.id,false) and g.life_active.is_empty(),"Story finishes through normal interaction")
        assert(g.credits==before+int(s.reward)+new_places.size()*8,"First discovery and story completion pay exactly once")
        before=g.credits;g.CityLife.begin(g,str(s.id))
        for i in range(s.steps.size()):await play_step(g)
        assert(g.credits==before,"Completed stories and their puzzles do not duplicate rewards on replay")
    assert(g.city_reputation==14 and g.life_completed.size()==7,"Seven stories grant their reputation once")
    for id in g.hack_done:assert(not str(id).begins_with("life:"),"Story puzzles preserve original hack and chapter progress")
    var before: int=g.credits;g.CityLife.practice(g);await solve(g);assert(g.credits==before,"Free puzzle practice does not mint credits")
    g.CityLife.clear(g);g.CityLife.begin(g,"pico");await play_step(g);g.CityLife.pause(g)
    g.CityLife.begin(g,"post");await play_step(g);g.CityLife.begin(g,"pico")
    assert(int(g.life_progress.pico)==1 and int(g.life_progress.post)==1,"Switching stories retains both pending steps")
    var choices: Dictionary=g.life_choices.duplicate(true);g._save_game();g.CityLife.clear(g);g._load_game(3)
    assert(g.life_active=="pico" and int(g.life_progress.pico)==1 and int(g.life_progress.post)==1,"Full save/load restores active and paused stories")
    assert(g.life_choices==choices,"Remembered decisions survive save/load")
    g._open_overview("missions");g.city_menus.mission_tab="Entdecken";g.city_menus.show_section("missions")
    for i in range(4):await g.get_tree().process_frame
    var nav: Control=g.city_menus.content.get_child(0);var book: Control=nav.get_child(1)
    var touch:=InputEventScreenTouch.new();touch.index=0;touch.position=g.get_viewport().get_screen_transform()*(book.global_position+book.size*.5);touch.pressed=true;Input.parse_input_event(touch)
    await g.get_tree().process_frame
    touch.pressed=false;Input.parse_input_event(touch)
    for i in range(3):await g.get_tree().process_frame
    assert(g.city_menus.mission_tab=="Kiezbuch" and g.move_touch==-1,"A real touch switches mission category without street movement")
    for category in ["Umland","Hauptstory","Entdecken"]:
        g.city_menus.mission_tab=category;g.city_menus.show_section("missions")
        for i in range(2):await g.get_tree().process_frame
        assert(g.city_menus.content.get_child_count()>3,"Every mission category contains its real content")
    g._close_overview();g._open_overview("collection");g.city_menus.album_tab=3;g.city_menus.show_section("collection")
    assert(g.city_menus.content.get_child_count()==21,"Journal includes all twenty place notes and controls")
    g._close_overview();g.CityLife.restore(g,{"active":"unknown_future_story","progress":{"pico":-4,"post":999}})
    assert(g.life_active.is_empty() and g.life_progress.pico==0 and g.life_progress.post==4,"Unknown and malformed future saves load safely")
    g.CityLife.restore(g,{});assert(g.life_seen.is_empty() and g.life_completed.is_empty(),"Older saves start with clean optional story progress")
    if existed:
        var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(saved);file.close()
    else:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("LIFE_SMOKE_OK · 20 connected places / 7 stories through real actions and puzzles / choices and replay guards / pause and save-load / native mission-tab touch / journal / old-save migration")
    g.get_tree().call_deferred("quit")
static func capture(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false;g.world_clock=18.1;g.region_fade=0;g.world_zoom=2.3;g.target_world_zoom=2.3;g.view_amount=Vector2(0,-.22);g._sync_modal_ui()
    for entry in [["life-kiosk","kiosk"],["life-dog","dog"],["life-stage","stage"],["life-garden","garden"],["life-mural","mural"],["life-mill","mill_box"]]:
        var place: Dictionary=g.CityLife.get_place(g,entry[1]);g.player_pos=g.CityAccess.safe_point(g,place.pos+Vector2(0,65));g.camera_pos=g.player_pos;g._update_district();g.district_banner.modulate.a=0
        if entry[1]=="stage":g.life_completed.festival=true
        if entry[1]=="garden":g.life_completed.garden=true
        if entry[1]=="mural":g.life_completed.mural=true
        await g._capture_quality_frame(entry[0])
    g.player_pos=g.RegionWorld.get_poi(g,"village_square").pos;g.camera_pos=g.player_pos;g._update_district();await g._capture_quality_frame("life-village")
    g.player_pos=Vector2(5100,4220);g.camera_pos=g.player_pos;g.CityLife.begin(g,"pico");g.player_pos=g.CityLife.target(g);g._interact();await g._capture_quality_frame("life-story-card");g._close_commerce()
    g._open_overview("missions")
    for category in ["Entdecken","Kiezbuch","Umland","Hauptstory"]:
        g.city_menus.mission_tab=category;g.city_menus.show_section("missions");await g._capture_quality_frame("life-menu-"+category.to_lower())
    g._close_overview();g._open_overview("map");g.city_menus.map_mode="region";g.city_menus.show_section("map");await g._capture_quality_frame("life-atlas-region")
    g.city_menus.map_mode="local";g.city_menus.map_category="Erleben";g.city_menus.show_section("map");await g._capture_quality_frame("life-atlas-city")
    g._close_overview();g._open_overview("collection");g.city_menus.album_tab=3;g.city_menus.show_section("collection");await g._capture_quality_frame("life-journal")
    print("LIFE_CAPTURE_OK");g.get_tree().call_deferred("quit")
