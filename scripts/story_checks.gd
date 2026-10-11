extends RefCounted
## Traverse the complete authored story through its actual UI, scan and puzzles.
static func key(g: Node,lane: String) -> String:return g.MainStory.token(g,lane)
static func play(g: Node,lane: String) -> void:
    var before_key: String=key(g,lane);var t: Dictionary=g.MainStory.task(g,lane).duplicate(true)
    g.player_pos=g.MainStory.target(g,lane);g.camera_pos=g.player_pos
    assert(g.player_pos!=Vector2.ZERO and not g._point_blocked(g.player_pos,18),"Every story objective is an accessible place")
    assert(g._current_objective_pos()==g.player_pos,"Story and route guidance share the same next objective")
    var n: Dictionary=g._nearest_interactable()
    assert(n.get("type","")=="story_task" and str(n.lane)==lane,"Normal interaction prioritizes the active authored story")
    var original: Vector2=g.player_pos;var credits: int=g.credits
    g.player_pos+=Vector2(800,0);g.MainStory.advance(g,lane,before_key)
    assert(key(g,lane)==before_key and g.credits==credits,"Remote callbacks cannot advance or grant rewards")
    g.player_pos=original;g._interact()
    assert(g.commerce_panel.visible and not g.hud_root.visible,"Story dialog owns modal input")
    if t.kind=="deduce":
        g.commerce_actions.get_child((int(t.answer)+1)%t.choices.size()).pressed.emit()
        assert(key(g,lane)==before_key and g.commerce_panel.visible,"Incorrect deduction keeps the puzzle and a useful hint")
    var answer: int=int(t.answer) if t.kind=="deduce" else (1 if t.kind=="choice" else 0)
    g.commerce_actions.get_child(answer).pressed.emit()
    if t.kind in ["wire","frequency","mastermind","memory"]:
        assert(g.minigame_open and g.game_type==t.kind,"Story launches an actual circuit or spectrum puzzle")
        g._finish_minigame()
        assert(key(g,lane)==before_key and not g.minigame_finishing,"Unsolved story puzzle cannot be skipped")
        if t.kind in ["wire","frequency"]:await preload("res://scripts/life_checks.gd").solve(g)
        elif t.kind=="mastermind":
            for i in range(4):
                var turns:=0
                while int(g.game_guess[i])!=int(g.game_secret[i]) and turns<8:g._on_mastermind_digit(i);turns+=1
            g._test_mastermind();await g.get_tree().create_timer(.75).timeout
        else:
            while g.game_memory_locked:await g.get_tree().process_frame
            for cell in g.game_memory_seq.duplicate():g._on_memory_cell(int(cell))
            await g.get_tree().create_timer(.75).timeout
    if t.kind=="photo":
        assert(g.photo_mode,"A photo investigation starts the actual native 3D challenge")
        g._complete_photo_challenge();assert(key(g,lane)==before_key,"An unfinished photo search cannot advance")
        for target in g.photo_targets:
            g.photo_camera.look_at(target.node.global_position,Vector3.UP);g._photo_shutter()
            assert(g.photo_found.get(str(target.key),false),"Visible centered subject is photographed through the real shutter")
        await g.get_tree().create_timer(.95).timeout
        assert(not g.photo_mode,"Completed photo investigation returns to the street")
    if g.commerce_panel.visible:g.commerce_actions.get_child(0).pressed.emit()
    assert(key(g,lane)!=before_key,"A real action advances exactly one story step")
    credits=g.credits;var after: String=key(g,lane);g.MainStory.advance(g,lane,before_key)
    assert(g.credits==credits and key(g,lane)==after,"Duplicate or stale callbacks do not grant progress or rewards")
static func smoke(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false;g.selected_save_slot=3;g._sync_modal_ui()
    var path: String=g._save_path();var existed:=FileAccess.file_exists(path);var saved:=FileAccess.get_file_as_string(path) if existed else ""
    g.active_npc_contract={};g.active_job={};g.region_contract={};g.life_active="";g.map_waypoint={};g.current_vehicle=-1;g.transit_riding=-1
    assert(g.native_chapters.size()==45 and g.photo_points.size()==25,"Legacy native goals and photo indices remain intact")
    assert(g.MainStory.Data.CHAPTERS.size()==12 and g.MainStory.Side.QUESTS.size()==12,"Full campaign and optional encounter catalog exist")
    var count:=0
    for c in g.MainStory.Data.CHAPTERS:
        for t in c.steps:
            count+=1;var p: Dictionary=g.MainStory.location(g,t.at)
            assert(not p.is_empty(),"Story references a real place: "+str(t.at))
            assert(g.CityAccess.connected(g,p.pos,18),"Every plot location has a body-clear approach")
    assert(count==144,"All twelve chapters have authored steps")
    g._start_game_from_slot(3,true)
    assert(g.campaign_state.enabled and g.campaign_state.introduced and g.commerce_panel.visible,"A fresh game begins with the actual storyline introduction")
    g.commerce_actions.get_child(0).pressed.emit()
    assert(g.MainStory.target(g)!=Vector2.ZERO,"The opening immediately guides to Emil")
    # Nearby discovery is automatic and remains optional; future offers are gated.
    g.player_pos=g.MainStory.location(g,"clock").pos;g.MainStory.update(g,.6)
    assert(g.encounter_id=="bell" and g.encounter_button.visible and not g._modal_active(),"A nearby side mission appears without blocking street movement")
    assert(g.street_state.seen.get("bell",false) and not g.street_state.seen.get("observations",false),"Future encounters stay undiscovered until their chapter")
    g.encounter_button.pressed.emit();assert(g.commerce_panel.visible,"The real nearby button opens the offer")
    g.commerce_actions.get_child(0).pressed.emit();assert(g.street_state.active=="bell","Offer is accepted through the actual button")
    await play(g,"side");g.MainStory.pause_side(g)
    assert(int(g.street_state.progress.bell)==1 and g.MainStory.target(g)!=Vector2.ZERO,"Pausing optional work restores the main goal without erasing steps")
    # Saving and returning resumes exact clues, choices, items and pending optional steps.
    await play(g,"main");await play(g,"main")
    g._save_game();var snapshot: Dictionary=g.campaign_state.duplicate(true)
    g.MainStory.clear(g);g._load_game(3)
    assert(g.campaign_state==snapshot and int(g.street_state.progress.bell)==1,"Full save/load restores the exact campaign and optional progress")
    g._open_overview("missions");g.city_menus.mission_tab="Hauptstory";g.city_menus.case_open=true;g.city_menus.show_section("missions")
    for i in range(3):await g.get_tree().process_frame
    assert(not g.hud_root.visible and g.city_menus.content.get_child_count()>6,"Casefile has its own clean scrollable mobile layout")
    var side_button: Control=g.city_menus.content.get_child(0).get_child(4)
    var touch:=InputEventScreenTouch.new();touch.index=0;touch.position=g.get_viewport().get_screen_transform()*(side_button.global_position+side_button.size*.5);touch.pressed=true;Input.parse_input_event(touch)
    await g.get_tree().process_frame;touch.pressed=false;Input.parse_input_event(touch)
    for i in range(3):await g.get_tree().process_frame
    assert(g.city_menus.mission_tab=="Nebenwege" and g.move_touch==-1,"Native touch opens discovered side missions without moving the street player")

    g._close_overview();g.city_menus.case_open=false
    var main_credits: int=g.credits
    var photo_credits:=0
    while int(g.campaign_state.chapter)<12:
        var was_photo: bool=g.MainStory.task(g).kind=="photo"
        var step_credits: int=g.credits
        await play(g,"main")
        if was_photo:photo_credits+=g.credits-step_credits
    var expected:=0
    for c in g.MainStory.Data.CHAPTERS:expected+=int(c.reward)
    assert(g.credits==main_credits+expected+photo_credits and g.campaign_state.claimed.size()==12,"Each main chapter pays once, including the epilogue")
    assert(g.campaign_state.journal.size()==156 and g.campaign_state.items.size()>=12,"All played clues, chapter conclusions and evidence are recorded")
    assert(g.campaign_state.choices.has("ending") and g.campaign_state.choices.has("elin_truth"),"Major choices and ending survive the full story")
    assert(g.MainStory.target(g)==Vector2.ZERO,"Finished main story leaves a playable open world")
    var before: int=g.credits;g.MainStory.advance(g,"main","main:11:7");assert(g.credits==before,"Epilogue cannot be claimed twice")
    # Every side mission is genuinely playable and never duplicates credits.
    for q in g.MainStory.Side.QUESTS:
        g.player_pos=g.MainStory.location(g,str(q.steps[0].at)).pos
        g.MainStory.update(g,.6);g.MainStory.offer(g,str(q.id));g.commerce_actions.get_child(0).pressed.emit()
        before=g.credits
        while not g.street_state.active.is_empty():await play(g,"side")
        assert(g.street_state.completed.get(q.id,false) and g.credits==before+int(q.reward),"Optional mission finishes with its one-time reward")
        g.MainStory.begin_side(g,str(q.id));assert(g.street_state.active.is_empty(),"Completed encounters cannot mint duplicate credits")
    assert(g.street_state.completed.size()==12,"All proximity mission paths complete")
    # Choices alter the displayed ending and world consequences remain saved.
    g._save_game();snapshot=g.campaign_state.duplicate(true);g.MainStory.clear(g);g._load_game(3)
    assert(g.campaign_state==snapshot and g.street_state.completed.size()==12,"Ending, evidence and all optional completions survive reload")
    for tab in ["Entdecken","Hauptstory","Nebenwege"]:
        g._open_overview("missions");g.city_menus.mission_tab=tab;g.city_menus.show_section("missions")
        for i in range(2):await g.get_tree().process_frame
        assert(g.city_menus.content.get_child_count()>3,"Every new mission menu exposes playable content")
        g._close_overview()
    # Loading an old save adds the story without deleting legacy collections.
    var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify({"chapter":9,"credits":713,"frag_count":4,"caches":[true],"city_life":{"progress":{"pico":2}}}));file.close()
    g._load_game(3)
    assert(g.campaign_state.enabled and int(g.campaign_state.chapter)==0 and g.native_chapter==9 and g.credits==713 and g.mission_fragments==4 and int(g.life_progress.pico)==2,"Old saves gain a fresh main storyline while retaining all prior progress")
    g.MainStory.restore(g,{"chapter":999,"step":-9,"journal":["bad"]},{"active":"missing","progress":{"bell":-6}})
    assert(int(g.campaign_state.chapter)==12 and g.campaign_state.journal.is_empty() and g.street_state.active.is_empty() and int(g.street_state.progress.bell)==0,"Malformed future progress is clamped safely")
    if existed:
        file=FileAccess.open(path,FileAccess.WRITE);file.store_string(saved);file.close()
    else:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("STORY_SMOKE_OK · 12 chapters / 144 real actions / 12 nearby missions / actual scans, circuits, codes, sequences and 3D photo shutters / choices, evidence, ending and chapter rewards / pause-save-load / older-save migration")
    g.get_tree().call_deferred("quit")
static func capture(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false;g.world_clock=18.5;g.world_zoom=2.4;g.view_amount=Vector2(0,-.22);g._sync_modal_ui();g.MainStory.clear(g,true)
    g.MainStory.introduce(g);await g._capture_quality_frame("story-opening");g._close_commerce()
    for entry in [["story-clock","clock"],["story-archive","archive"],["story-repair","repair"],["story-shelter","shelter"],["story-echo","echo_station"],["story-bridge","echo_bridge"],["story-horizon","echo_view"]]:
        g.player_pos=g.MainStory.location(g,entry[1]).pos+Vector2(0,55);g.camera_pos=g.player_pos;g._update_district();g.district_banner.modulate.a=0;g._update_ui();await g._capture_quality_frame(entry[0])
    g.player_pos=g.MainStory.location(g,"clock").pos;g.camera_pos=g.player_pos;g._update_district();g.MainStory.update(g,.6);g._update_ui();await g._capture_quality_frame("story-nearby")
    g.encounter_button.pressed.emit();await g._capture_quality_frame("story-side-offer");g._close_commerce()
    g.player_pos=g.MainStory.target(g);g.camera_pos=g.player_pos;g._interact();await g._capture_quality_frame("story-first-dialog");g._close_commerce()
    g.campaign_state.step=7;g.player_pos=g.MainStory.target(g);g.camera_pos=g.player_pos;g._interact();g.commerce_actions.get_child(0).pressed.emit();await g._capture_quality_frame("story-photo-investigation");g._exit_photo_mode()
    g.campaign_state.step=5;g.player_pos=g.MainStory.target(g);g._interact();g.commerce_actions.get_child(0).pressed.emit();await g._capture_quality_frame("story-spectrum-puzzle");g._close_minigame();g.campaign_state.step=0
    g._open_overview("missions");g.city_menus.mission_tab="Hauptstory";g.city_menus.show_section("missions");await g._capture_quality_frame("story-book")
    g.city_menus.case_open=true;g.city_menus.show_section("missions");await g._capture_quality_frame("story-journal")
    g.city_menus.case_open=false;g.city_menus.mission_tab="Nebenwege";g.city_menus.show_section("missions");await g._capture_quality_frame("story-side-menu")
    g._close_overview();g._open_overview("map");g.city_menus.map_mode="region";g.city_menus.show_section("map");await g._capture_quality_frame("story-atlas")
    print("STORY_CAPTURE_OK");g.get_tree().call_deferred("quit")
