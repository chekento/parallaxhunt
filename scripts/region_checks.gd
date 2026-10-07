extends RefCounted
## Integration checks exercise real actions, persistence, input and route geometry.
static func smoke(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false;g.selected_save_slot=3;g._sync_modal_ui()
    var path: String=g._save_path()
    var existed: bool=FileAccess.file_exists(path)
    var saved: String=FileAccess.get_file_as_string(path) if existed else ""
    assert(g.districts.size()==25 and g.photo_points.size()==25 and g.native_chapters.size()==45,"Original content and saved indices stay stable")
    assert(Vector2(g.roads[0].points[-1]).y==g.CITY_SIZE.y and Vector2(g.roads[10].points[-1]).x==g.CITY_SIZE.x,"Original city road lengths stay stable")
    assert(Rect2(g.world_regions[0].rect).position.x-g.CITY_SIZE.x>=4500,"Greenbelt separates the city and suburb")
    assert(g.region_pois.size()==18 and g.race_sites.size()==7,"All regional places and the road rally are built")
    var start: Vector2=g.RegionWorld.get_poi(g,"city_bus").pos
    for p in g.region_pois:
        assert(g.CityAccess.connected(g,Vector2(p.pos),18),"Each new place needs an approach: "+str(p.id))
        var route: PackedVector2Array=g.WorldNavigation.route(g,start,p.pos)
        assert(route.size()>=2,"A road route must lead from the city to "+str(p.id))
        for k in range(route.size()-1):assert(g.CityAccess.path_clear(g,route[k],route[k+1],14),"Displayed routes may not cross walls or open water")
    for p in g.race_sites[-1].points:assert(not g._point_blocked(p,18),"Rally checkpoints need vehicle clearance")
    var highway: Dictionary=g.roads.filter(func(r):return r.get("name","")=="L 01 · Lindenstraße")[0]
    for k in range(highway.points.size()-1):assert(g.CityAccess.path_clear(g,highway.points[k],highway.points[k+1],18),"The whole land road must be driveable")
    assert(g._point_blocked(Vector2(47700,9000),18),"Lake water blocks walking")
    assert(not g._point_blocked(Vector2(45000,11200),18),"Dry corners of a water bounding box stay open")
    assert(g.CityAccess.path_clear(g,Vector2(53400,14600),Vector2(54200,14600),18),"River bridge carries the road")
    g.region_seen.clear();g.region_completed.clear();g.credits=500
    for tour in range(g.RegionWorld.OUTINGS.size()):
        g.RegionWorld.begin_outing(g,tour)
        var trip: Dictionary=g.RegionWorld.OUTINGS[tour]
        var before: int=g.credits
        var new_stops:=0
        for id in trip.stops:
            var poi: Dictionary=g.RegionWorld.get_poi(g,id)
            if not g.region_seen.has(id):new_stops+=1
            g.player_pos=poi.pos
            assert(g._current_objective_pos()==g.player_pos,"An outing points at its actual next stop")
            assert(g._nearest_interactable().type=="region_poi","A stop must be interactable at its rendered position")
            g._interact();g._close_commerce()
        assert(g.region_contract.is_empty() and g.region_completed.get(trip.id,false),"An outing finishes through normal interaction")
        assert(g.credits==before+new_stops*20+int(trip.reward),"Discovery and completion pay once")
        before=g.credits;g.RegionWorld.begin_outing(g,tour)
        for id in trip.stops:
            var poi: Dictionary=g.RegionWorld.get_poi(g,id)
            g.player_pos=poi.pos;g.RegionWorld.visit(g,g.region_pois.find(poi));g._close_commerce()
        assert(g.credits==before,"Replaying completed excursions cannot duplicate rewards")
    g.energy=5;g.RegionWorld.rest(g);assert(g.energy==100,"Rest recovers energy")
    var car: int=g.parked_cars.size()-1
    g.current_vehicle=car;g.parked_cars[car].occupied=true;g.player_pos=g.parked_cars[car].pos
    var departure: Vector2=g.player_pos;var before_bus: int=g.credits
    g.move_vec=Vector2.RIGHT;g.move_touch=0;g.vehicle_velocity=200
    g.RegionWorld.board_bus(g,"suburb_bus")
    assert(g.credits==before_bus-15 and g.current_vehicle==-1 and not g.parked_cars[car].occupied,"Bus trip handles its fare and vehicle once")
    assert(g.parked_cars[car].pos==departure and not g._point_blocked(g.player_pos,18),"Car stays parked and arrival is clear")
    assert(g.move_touch==-1 and g.move_vec==Vector2.ZERO and g.vehicle_velocity==0,"Bus trip clears old input")
    g.region_fade=0;g.RegionWorld.begin_outing(g,2);g.region_contract.step=2
    g.map_waypoint={"pos":Vector2(78900,20370),"name":"Freiland · Fernblick"}
    g._save_game();g.region_contract={};g.map_waypoint={};g.region_seen.clear();g.region_completed.clear();g._load_game(3)
    assert(int(g.region_contract.tour)==2 and int(g.region_contract.step)==2 and g.map_waypoint.pos==Vector2(78900,20370),"Outing and waypoint survive a full save/load")
    assert(g.region_completed.size()==4 and g.region_seen.size()>=10,"Discoveries survive a save/load")
    g.player_pos=Vector2(33600,10310)
    var visited: int=g.visited_districts.size();g.RegionWorld.check_arrival(g)
    assert(g.visited_districts.size()==visited,"Country regions never inflate city district progress")
    g.player_pos=start;g.RegionWorld.check_arrival(g);assert(g.visited_districts.has(g._district_at(start).name),"City visits are recorded")
    g.current_vehicle=car;g.parked_cars[car].occupied=true;g.player_pos=g.race_sites[-1].pos
    g._start_race(g.race_sites.size()-1)
    assert(not g.active_race.is_empty(),"The new rally accepts an SUV through normal race start")
    g.active_race={};g.current_vehicle=-1;g.parked_cars[car].occupied=false;g.player_pos=start
    g._open_overview("map")
    for i in range(4):await g.get_tree().process_frame
    assert(not g.hud_root.visible and g.city_menus.visible,"Atlas owns a clean modal canvas")
    g.city_menus.map_mode="region";g.city_menus.show_section("map")
    for i in range(4):await g.get_tree().process_frame
    var atlas: Control=g.city_menus.atlas
    assert(atlas.initialized and atlas.size.x>800,"Atlas gets its portrait layout")
    var old_zoom: float=atlas.zoom;atlas.zoom_by(1.25);assert(atlas.zoom>old_zoom,"Zoom changes actual projection")
    atlas.center=Vector2(33600,10310);atlas.queue_redraw()
    await g.get_tree().process_frame
    g.city_menus.map_selection={}
    var touch:=InputEventScreenTouch.new();touch.index=0
    touch.position=g.get_viewport().get_screen_transform()*(atlas.global_position+atlas.size*.5)
    touch.pressed=true;Input.parse_input_event(touch)
    await g.get_tree().process_frame
    touch.pressed=false;Input.parse_input_event(touch)
    await g.get_tree().process_frame
    assert(not g.city_menus.map_selection.is_empty(),"A real screen touch selects an atlas place")
    assert(g.city_menus.map_selection.pos.distance_to(Vector2(33600,10310))<150,"Map selection corresponds to the visible location")
    var before_pan: Vector2=atlas.center
    touch.pressed=true;Input.parse_input_event(touch)
    await g.get_tree().process_frame
    var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=touch.position+Vector2(70,0);drag.relative=Vector2(70,0);Input.parse_input_event(drag)
    await g.get_tree().process_frame
    touch.pressed=false;touch.position=drag.position;Input.parse_input_event(touch)
    await g.get_tree().process_frame
    assert(atlas.center!=before_pan and g.move_touch==-1,"Real touch drag pans the map without starting the world joystick")
    g.city_menus._navigate_selection();assert(not g.map_open and not g.map_waypoint.is_empty(),"Waypoint route dismisses the modal")
    g.WorldNavigation.refresh(g,2);assert(g.navigation_route.size()>2,"Chosen waypoint creates a road route")
    g.player_pos=g.map_waypoint.pos;g.RegionWorld.check_arrival(g);assert(g.map_waypoint.is_empty(),"Reached waypoint restores the active objective")
    g.RegionWorld.load_state(g,{"contract":{"tour":999,"step":0}});assert(g.region_contract.is_empty(),"Unknown future outing ID loads safely")
    g.camera_pos=Vector2(63200,11200)
    for cell in g.RegionWorld.cells(g):g.RegionWorld.cell_data(g,cell)
    assert(g.RegionWorld.cells(g).size()<20 and g.landscape_cells.size()<=96,"Landscape generation and cache are bounded")
    if existed:
        var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(saved);file.close()
    else:DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    print("REGION_SMOKE_OK · 18 connected places / road and bridge clearance / 4 replay-safe outings / bus and rest / save-load / native atlas tap and drag / bounded landscape")
    g.get_tree().call_deferred("quit")
static func capture(g: Node) -> void:
    g.set_process(false);g.main_menu_active=false;g.main_menu_panel.visible=false
    g.world_clock=13;g.world_zoom=2.15;g.target_world_zoom=2.15;g.view_amount=Vector2(0,-.22);g.region_fade=0;g._sync_modal_ui()
    for entry in [["region-suburb",Vector2(34400,12450)],["region-square",Vector2(33600,10310)],["region-fields",Vector2(29300,8900)],["region-lake",Vector2(48100,5850)],["region-bridge",Vector2(54000,14600)],["region-camp",Vector2(63200,11200)],["region-wilderness",Vector2(78900,20370)]]:
        g.player_pos=g.CityAccess.safe_point(g,entry[1]);g.camera_pos=g.player_pos;g._update_district();g.district_banner.modulate.a=0
        await g._capture_quality_frame(entry[0])
    g.player_pos=Vector2(33600,10310);g.camera_pos=g.player_pos;g._update_district();g.WorldNavigation.refresh(g,2);g._open_overview("map")
    for mode in ["region","city","local"]:
        g.city_menus.map_mode=mode;g.city_menus.map_selection={};g.city_menus.show_section("map")
        await g._capture_quality_frame("atlas-"+mode)
    g._close_overview();g._open_overview("missions");await g._capture_quality_frame("menu-outings");g._close_overview()
    g.RegionWorld.visit(g,g.region_pois.find(g.RegionWorld.get_poi(g,"suburb_square")))
    for i in range(6):await g.get_tree().process_frame
    await g._capture_quality_frame("region-place-card");g._close_commerce()
    g.RegionWorld.enter_room(g,g.region_pois.find(g.RegionWorld.get_poi(g,"suburb_cafe")))
    await g._capture_quality_frame("region-cafe-interior")
    print("REGION_CAPTURE_OK");g.get_tree().call_deferred("quit")
