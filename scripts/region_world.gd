extends RefCounted
## Original city indices stay stable; countryside detail is streamed around the camera.
const CELL:=1600.0
const GRASS=preload("res://assets/visual/materials/country_grass.tres")
const TRAIL=preload("res://assets/visual/materials/country_trail.tres")
const Expansion=preload("res://scripts/region_expansion.gd")
const OUTINGS: Array=[
    {"id":"welcome","title":"Raus aus der Stadt","desc":"Über den Grüngürtel nach Sonnenhagen. Am Dorfplatz beginnt dein Ausflug.","stops":["greenbelt","suburb_square","suburb_cafe"],"reward":140},
    {"id":"neighborhood","title":"Sonnenhagen entdecken","desc":"Nachbarschaft, Obstwiese und ein ruhiger Platz am See.","stops":["suburb_square","orchard","farm_stall","lake_view"],"reward":180},
    {"id":"forest","title":"Auf den Waldpfaden","desc":"Vom Waldrand über den Fluss zur Rangerstation und zum Camp.","stops":["trailhead","river_bridge","ranger","pine_camp","ridge_view"],"reward":220},
    {"id":"panorama","title":"Die große Panoramarunde","desc":"Eine längere Tour durch Felder, Seen und offenes Bergland. Nimm ein Auto oder den Regionalbus.","stops":["farm_stall","lake_view","ridge_view","far_view"],"reward":260},
    {"id":"heath","title":"Hinter dem Heidekamm","desc":"Eine weite Reise aus dem Freiland bis ins Dorf Mühlenau. Auto oder Regionalbus empfohlen.","stops":["far_view","heath_view","village_square","old_mill"],"reward":300},
    {"id":"mill","title":"Mühlenau und die Auen","desc":"Vom Dorfplatz über die Mühlenbrücke in die weite südliche Landschaft.","stops":["village_square","village_cafe","old_bridge","old_mill","south_view"],"reward":280}
]
static func build(g: Node) -> void:
    g.world_regions=[
        region("Sonnenhagen",Rect2(30700,7900,10800,10500),"suburb","#6a7858","#ebce8e"),
        region("Lindenfelder",Rect2(26000,0,18400,36000),"meadow","#53674d","#d9d390"),
        region("Lindensee",Rect2(43400,4300,8400,8200),"lake","#3b6255","#91d6d0"),
        region("Fichtenwald",Rect2(44400,0,24800,36000),"forest","#34584a","#91c99b"),
        region("Hohes Freiland",Rect2(69200,0,16800,36000),"wild","#526051","#d7c4a4"),
        region("Südliche Auen",Rect2(0,18000,26000,18000),"meadow","#425c4b","#a3d2b0")]
    add_road(g,"L 01 · Lindenstraße",[Vector2(24400,9000),Vector2(29500,9000),Vector2(31800,10200),Vector2(34400,10200),Vector2(37400,11200),Vector2(41100,11200),Vector2(44400,13200),Vector2(49000,13200),Vector2(53000,14600),Vector2(56600,14600),Vector2(60400,17300),Vector2(65000,18100),Vector2(70500,18100),Vector2(75800,20500),Vector2(83800,20500)],112,"country")
    add_road(g,"Gartenring",[Vector2(31800,10200),Vector2(31800,14500),Vector2(37400,14500),Vector2(37400,11200)],82,"residential")
    add_road(g,"Sonnenweg",[Vector2(34400,10200),Vector2(34400,16200),Vector2(39100,16200),Vector2(41100,11200)],76,"residential")
    add_road(g,"Obstgartenstraße",[Vector2(32600,14500),Vector2(32600,18000),Vector2(41000,18000),Vector2(43300,15500),Vector2(44400,13200)],78,"residential")
    add_road(g,"Lindensee-Runde",[Vector2(44400,13200),Vector2(43800,12000),Vector2(43500,9000),Vector2(44300,7000),Vector2(45600,5800),Vector2(48700,5400),Vector2(50900,6700),Vector2(51000,9600),Vector2(51800,11600),Vector2(53000,14600)],44,"trail")
    add_road(g,"Rangerweg",[Vector2(56600,14600),Vector2(56600,11300),Vector2(60000,9700),Vector2(63400,11400),Vector2(65000,18100)],48,"trail")
    add_road(g,"Höhenpfad",[Vector2(60400,17300),Vector2(59000,19000),Vector2(62000,23000),Vector2(65500,24000),Vector2(68800,22000),Vector2(70500,18100)],46,"trail")
    add_road(g,"Mühlenweg",[Vector2(41100,11200),Vector2(41900,6900),Vector2(46500,3500),Vector2(60000,3500),Vector2(60000,9700)],72,"country")
    add_water(g,"Lindensee",PackedVector2Array([Vector2(44900,7400),Vector2(45700,6400),Vector2(47700,6100),Vector2(49300,7500),Vector2(50100,9500),Vector2(49300,10900),Vector2(47800,11600),Vector2(46000,10800),Vector2(44900,9400)]),Color("#35778a"))
    add_water(g,"Lindenfluss",PackedVector2Array([Vector2(52100,0),Vector2(52200,8500),Vector2(53500,12000),Vector2(53800,16400),Vector2(52600,20700),Vector2(52900,26000),Vector2(55500,36000),Vector2(55900,36000),Vector2(53300,25900),Vector2(53000,20700),Vector2(54200,16400),Vector2(53900,11900),Vector2(52600,8400),Vector2(52500,0)]),Color("#326b7e"))
    g.region_pois=[
        poi("city_bus","Zentrum · Regionalbus",Vector2(5280,4560),"bus","Abfahrt ins Umland. Der Regionalbus bringt dich auch wieder zurück."),
        poi("greenbelt","Tor zu den Lindenfeldern",Vector2(28300,8870),"sign","Die Stadt liegt hinter dir. Felder und Baumreihen begleiten die Straße nach Sonnenhagen."),
        poi("suburb_square","Sonnenhagen · Dorfplatz",Vector2(33600,10310),"square","Niedrige Häuser, Gärten und ein offener Nachbarschaftsplatz. Hier starten die Umland-Touren."),
        poi("suburb_bus","Sonnenhagen · Regionalbus",Vector2(33400,10070),"bus","Zentrum, Lindensee oder Waldrand: der Regionalbus verbindet die Region."),
        poi("suburb_cafe","Café Sonnenfenster",Vector2(34310,11950),"cafe","Kaffee, ein warmer Innenraum und ein ruhiger Blick auf die Gartenstraße."),
        poi("suburb_garage","Werkstatt Gartenring",Vector2(31910,13500),"garage","Fahrzeugpflege und Upgrades vor der nächsten Landstraßenfahrt."),
        poi("orchard","Alte Obstwiese",Vector2(34800,17890),"rest","Eine Bank unter Obstbäumen. Rasten kostet nichts und füllt deine Energie auf."),
        poi("farm_stall","Lindenhof · Hofladen",Vector2(42020,7380),"farm","Ein kleiner Hof zwischen Getreidefeldern. Hier beginnt die Panoramarunde."),
        poi("lake_view","Lindensee · Aussicht",Vector2(48100,5500),"view","Wasser, Schilf und ein freier Blick auf den See. Der Uferpfad führt um die Bucht."),
        poi("lake_bus","Lindensee · Regionalbus",Vector2(48700,5270),"bus","Der Bus hält am befestigten Zugang zum Uferweg."),
        poi("trailhead","Waldtor · Rastplatz",Vector2(44700,13330),"rest","Hier beginnt die Wildnis. Schmale Wege führen zum See und in den Wald."),
        poi("forest_bus","Waldtor · Regionalbus",Vector2(45000,13070),"bus","Ein sicherer Start für Wanderungen. Die Stadt bleibt mit dem Bus erreichbar."),
        poi("river_bridge","Lindenbrücke",Vector2(53600,14600),"bridge","Der Fluss läuft unter der Brücke. Geländer und begehbare Ränder sichern den Übergang."),
        poi("ranger","Rangerstation Fichtenwald",Vector2(60000,9820),"ranger","Eine kleine Station zwischen den Bäumen. Hier gibt es Orientierung und eine kostenlose Pause."),
        poi("pine_camp","Camp unter den Fichten",Vector2(63200,11200),"camp","Zelte, Holzbank und Feuerstelle. Ein ruhiger Platz zum Ausruhen."),
        poi("ridge_view","Höhenpfad · Panorama",Vector2(65500,24110),"view","Ein weiter Blick über Wald, Fluss und offene Landschaft."),
        poi("far_view","Freiland · Fernblick",Vector2(78900,20370),"view","Viel Raum zwischen einzelnen Orten. Die Straße führt durch offenes Bergland."),
        poi("country_rally","Lindenfelder · Zeitprüfung",Vector2(30000,9260),"race","Eine lange Straßenrunde für jede Fahrzeugklasse. Kontrollpunkte liegen auf der befahrbaren Strecke.")]
    var random:=RandomNumberGenerator.new()
    random.seed=1242026
    for x in [31800.0,34400.0,37400.0]:
        for y in range(10900,14300,440):
            for side in [-1.0,1.0]:
                var center:=Vector2(x+side*185,float(y))
                var rect:=Rect2(center-Vector2(85,68),Vector2(170,136))
                if not g._rect_near_road(rect,46):house(g,rect,random.randi(),"home")
    for x in range(33300,39800,460):
        for y in [14500.0,18000.0]:
            for side in [-1.0,1.0]:
                var center:=Vector2(float(x),y+side*180)
                var rect:=Rect2(center-Vector2(90,66),Vector2(180,132))
                if not g._rect_near_road(rect,45):house(g,rect,random.randi(),"home")
    for entry in [[Rect2(34000,11830,205,160),"cafe"],[Rect2(32040,13390,230,185),"garage"],[Rect2(42130,7300,240,180),"farm"],[Rect2(60140,9790,200,145),"ranger"]]:house(g,entry[0],random.randi(),entry[1])
    for p in [Vector2(33750,10430),Vector2(32000,13800),Vector2(42300,7720),Vector2(44900,13450),Vector2(60100,9960)]:
        g.parked_cars.append({"pos":p,"class":"suv" if p.x>43000 else "hatch","heading":0.0,"color":Color("#b0cab2"),"occupied":false})
    Expansion.build(g)
    g.StoryRegion.build(g)
    g.country_segments.clear()
    for road in g.roads:
        if not road.get("regional",false):continue
        for i in range(road.points.size()-1):
            var a: Vector2=road.points[i]
            var b: Vector2=road.points[i+1]
            g.country_segments.append({"a":a,"b":b,"rect":Rect2(a.min(b),a.max(b)-a.min(b)).grow(float(road.width)*.5+180),"width":float(road.width),"kind":str(road.kind)})
    g.race_sites.append({"id":"linden_rally","name":"Lindenfelder-Rallye","pos":Vector2(30000,9260),"limit":155.0,"reward":210,"group":"ANY","points":[Vector2(31800,10200),Vector2(37400,11200),Vector2(41100,11200),Vector2(44400,13200),Vector2(49000,13200),Vector2(53000,14600),Vector2(56600,14600),Vector2(60400,17300),Vector2(65000,18100)]})

static func region(name: String,rect: Rect2,style: String,ground: String,accent: String) -> Dictionary:
    return {"name":name,"rect":rect,"style":style,"ground":Color(ground),"accent":Color(accent),"wall":Color("#ccbda3"),"roof":Color("#876c55"),"regional":true}
static func poi(id: String,name: String,pos: Vector2,kind: String,desc: String) -> Dictionary:
    return {"id":id,"name":name,"pos":pos,"kind":kind,"desc":desc,"accent":Color("#b6d8a7") if kind in ["rest","ranger","camp"] else Color("#f2d28c")}
static func add_road(g: Node,name: String,points: Array,width: float,kind: String) -> void:
    g.roads.append({"name":name,"points":PackedVector2Array(points),"width":width,"kind":kind,"regional":true})
static func add_water(g: Node,name: String,poly: PackedVector2Array,tint: Color) -> void:
    var lo: Vector2=poly[0]
    var hi:=lo
    for p in poly:lo=lo.min(p);hi=hi.max(p)
    g.waters.append({"name":name,"rect":Rect2(lo,hi-lo),"polygon":poly,"tint":tint,"regional":true})
static func house(g: Node,rect: Rect2,seed_value: int,kind: String) -> void:
    g.buildings.append({"rect":rect,"height":62.0 if kind=="home" else 78.0,"seed":seed_value,"kind":kind,"style":"suburb","wall":[Color("#d3c8ad"),Color("#b4c5b7"),Color("#d2b29d"),Color("#c4c2a9")][seed_value%4],"roof":Color("#9d715b"),"accent":Color("#e9c780"),"floors":2,"massing":"gable","facade":"sash","roof_mode":"solar","regional":true})
static func region_at(g: Node,pos: Vector2) -> Dictionary:
    for r in g.world_regions:
        if Rect2(r.rect).has_point(pos):return r
    return region("Freie Landschaft",Rect2(Vector2.ZERO,g.WORLD_SIZE),"wild","#526051","#d7c4a4")
static func get_poi(g: Node,id: String) -> Dictionary:
    for p in g.region_pois:
        if str(p.id)==id:return p
    return {}
static func active_target(g: Node) -> Vector2:
    if g.region_contract.is_empty():return Vector2.ZERO
    var trip: Dictionary=OUTINGS[int(g.region_contract.tour)]
    var step: int=int(g.region_contract.step)
    return Vector2(get_poi(g,str(trip.stops[step])).pos) if step<trip.stops.size() else Vector2.ZERO
static func begin_outing(g: Node,index: int) -> void:
    if index<0 or index>=OUTINGS.size():return
    g.CityLife.pause(g)
    g.region_contract={"tour":index,"step":0};g.map_waypoint={};g.navigation_timer=0
    g._close_overview();g._close_commerce()
    g._notify(str(OUTINGS[index].title)+" · Folge der Route zum ersten Halt.");g._save_game()
static func visit(g: Node,index: int) -> void:
    if index<0 or index>=g.region_pois.size():return
    var p: Dictionary=g.region_pois[index]
    var discovery: bool=not bool(g.region_seen.get(str(p.id),false))
    if discovery:g.region_seen[str(p.id)]=true;g.credits+=20;g._play_sfx("collect")
    if not g.region_contract.is_empty():
        var trip: Dictionary=OUTINGS[int(g.region_contract.tour)]
        var step: int=int(g.region_contract.step)
        if step<trip.stops.size() and str(trip.stops[step])==str(p.id):
            g.region_contract.step=step+1
            if step+1>=trip.stops.size():
                var first: bool=not bool(g.region_completed.get(str(trip.id),false))
                if first:g.credits+=int(trip.reward);g.city_reputation+=1
                g.region_completed[str(trip.id)]=true;g.region_contract={}
                g._show_reward_popup("AUSFLUG ABGESCHLOSSEN",str(trip.title)+(" · +%d CR" % int(trip.reward) if first else " · erneut erkundet"),Color("#b6d8a7"))
            else:g._notify("Halt %d / %d · Nächster Wegpunkt ist markiert." % [step+1,trip.stops.size()])
    g._save_game()
    g._open_commerce(str(p.name),str(p.desc)+( "\nNeu entdeckt · +20 CR" if discovery else "\nDu kennst diesen Ort bereits."))
    if p.kind=="bus":
        for stop in g.region_pois:
            if stop.kind=="bus" and stop.id!=p.id:g.commerce_actions.add_child(g._commerce_button("NACH "+str(stop.name).split(" · ")[0].to_upper()+" · 15 CR",board_bus.bind(g,str(stop.id))))
    elif p.kind in ["rest","ranger","camp","view","farm","square"]:g.commerce_actions.add_child(g._commerce_button("RASTEN · ENERGIE AUFFÜLLEN",rest.bind(g)))
    if p.kind in ["square","sign","ranger"]:
        for i in range(OUTINGS.size()):g.commerce_actions.add_child(g._commerce_button(str(OUTINGS[i].title).to_upper(),begin_outing.bind(g,i)))
    if p.kind in ["cafe","garage"]:g.commerce_actions.add_child(g._commerce_button("CAFÉ BETRETEN" if p.kind=="cafe" else "WERKSTATT BETRETEN",enter_room.bind(g,index)))
    elif p.kind=="race":g.commerce_actions.add_child(g._commerce_button("ZEITPRÜFUNG STARTEN",start_rally.bind(g)))
    g.commerce_actions.add_child(g._commerce_button("KARTE / ROUTE",g._open_overview.bind("map")))
    g.commerce_actions.add_child(g._commerce_button("WEITER",g._close_commerce))
static func rest(g: Node) -> void:
    g.energy=100;g._close_commerce();g._notify("Ausgeruht · Energie 100 %");g._save_game()
static func enter_room(g: Node,index: int) -> void:
    var p: Dictionary=g.region_pois[index]
    if g.current_vehicle>=0:
        g.service_vehicle_index=g.current_vehicle;g.parked_cars[g.current_vehicle].occupied=false;g.current_vehicle=-1
    g._close_commerce();g._enter_interior(str(p.name),str(p.kind),Color(p.accent),g.player_pos)
static func start_rally(g: Node) -> void:
    g._close_commerce()
    if g.current_vehicle<0:g._notify("Steige für die Landstraßenprüfung in ein Fahrzeug.");return
    g._start_race(g.race_sites.size()-1)
static func board_bus(g: Node,id: String) -> void:
    if g.credits<15:g._notify("Die Fahrt kostet 15 CR.");return
    var stop:=get_poi(g,id)
    if stop.is_empty():return
    if g.current_vehicle>=0:g.parked_cars[g.current_vehicle].occupied=false;g.current_vehicle=-1
    g.credits-=15;g.world_clock=fposmod(g.world_clock+.22,24)
    g.player_pos=g.CityAccess.safe_point(g,Vector2(stop.pos));g.camera_pos=g.player_pos
    g.vehicle_velocity=0;g.move_vec=Vector2.ZERO;g.move_touch=-1;g.region_fade=1;g.navigation_timer=0
    g._close_commerce();g._update_district();g._notify("Ankunft · "+str(stop.name));g._save_game()
static func save_state(g: Node) -> Dictionary:
    var pin: Dictionary={}
    if not g.map_waypoint.is_empty():pin={"x":g.map_waypoint.pos.x,"y":g.map_waypoint.pos.y,"name":str(g.map_waypoint.name)}
    return {"seen":g.region_seen,"completed":g.region_completed,"contract":g.region_contract,"pin":pin}
static func load_state(g: Node,data: Dictionary) -> void:
    g.region_seen=Dictionary(data.get("seen",{}));g.region_completed=Dictionary(data.get("completed",{}));g.region_contract=Dictionary(data.get("contract",{}))
    if not g.region_contract.is_empty():
        var tour: int=int(g.region_contract.get("tour",-1))
        var step: int=int(g.region_contract.get("step",-1))
        if tour<0 or tour>=OUTINGS.size() or step<0 or step>=OUTINGS[tour].stops.size():g.region_contract={}
    g.map_waypoint={}
    var pin: Dictionary=Dictionary(data.get("pin",{}))
    if pin.has("x") and pin.has("y"):g.map_waypoint={"pos":g.CityAccess.safe_point(g,Vector2(float(pin.x),float(pin.y))),"name":str(pin.get("name","Wegpunkt"))}
    g.navigation_timer=0
static func check_arrival(g: Node) -> void:
    if not g.map_waypoint.is_empty() and g.player_pos.distance_to(Vector2(g.map_waypoint.pos))<70:
        var name: String=g.map_waypoint.name
        g.map_waypoint={};g.navigation_timer=0;g._notify("Wegpunkt erreicht · "+name)
    if Rect2(Vector2.ZERO,g.CITY_SIZE).has_point(g.player_pos):g.visited_districts[str(g._district_at(g.player_pos).name)]=true
static func near_road(g: Node,p: Vector2,margin: float) -> bool:
    for s in g.country_segments:
        if Rect2(s.rect).has_point(p) and g._distance_to_polyline(p,PackedVector2Array([s.a,s.b]))<float(s.width)*.5+margin:return true
    return false
static func cells(g: Node2D) -> Array[Vector2i]:
    var half: Vector2=g.get_viewport_rect().size/maxf(g.world_zoom,.5)*.5+Vector2(260,260)
    var lo:=Vector2i(floori((g.camera_pos.x-half.x)/CELL),floori((g.camera_pos.y-half.y)/CELL))
    var hi:=Vector2i(floori((g.camera_pos.x+half.x)/CELL),floori((g.camera_pos.y+half.y)/CELL))
    var out: Array[Vector2i]=[]
    for x in range(maxi(0,lo.x),mini(hi.x+1,ceili(g.WORLD_SIZE.x/CELL))):
        for y in range(maxi(0,lo.y),mini(hi.y+1,ceili(g.WORLD_SIZE.y/CELL))):
            if (x+1)*CELL<=g.CITY_SIZE.x and (y+1)*CELL<=g.CITY_SIZE.y:continue
            out.append(Vector2i(x,y))
    return out
static func cell_data(g: Node,key: Vector2i) -> Array:
    if g.landscape_cells.has(key):return g.landscape_cells[key]
    var random:=RandomNumberGenerator.new();random.seed=absi(key.x*73856093 ^ key.y*19349663 ^ 124999)
    var items: Array=[]
    var origin:=Vector2(key)*CELL
    var center:=origin+Vector2(CELL*.5,CELL*.5)
    var style: String=str(region_at(g,center).style)
    var forest: bool=style in ["forest","lake"]
    var count: int=roundi(lerpf(22,90,smoothstep(43000,46500,center.x))) if forest else 22
    for i in range(count):
        var p:=origin+Vector2(random.randf_range(0,CELL),random.randf_range(0,CELL))
        if Rect2(Vector2.ZERO,g.CITY_SIZE).has_point(p) or near_road(g,p,120) or g._point_blocked(p,80):continue
        if g.region_pois.any(func(q):return Vector2(q.pos).distance_to(p)<180):continue
        var kind: String="pine" if forest and p.x>44400 else ("oak" if i%4 else "rock")
        if style=="heath" and i%4:kind="heather"
        items.append({"pos":p,"r":random.randf_range(22,39) if kind=="heather" else random.randf_range(25,58),"h":random.randf_range(18,34) if kind=="heather" else random.randf_range(65,126),"kind":kind,"seed":random.randi()})
    if g.landscape_cells.size()>=96:g.landscape_cells.erase(g.landscape_cells.keys()[0])
    g.landscape_cells[key]=items
    return items
static func draw_ground(g: Node2D) -> void:
    for item in g.world_regions:
        var r: Rect2=item.rect
        if g._world_rect_visible(r):g.draw_rect(Rect2(g._project(r.position),r.size*g.world_zoom),Color(item.ground).darkened(.1))
    var suburb: Rect2=g.world_regions[0].rect
    if g._world_rect_visible(suburb):g.draw_rect(Rect2(g._project(suburb.position),suburb.size*g.world_zoom),Color("#6a7858"))
    for boundary in [[44400.0,Color("#4b5e45"),Color("#2f4f43")],[69200.0,Color("#2f4f43"),Color("#4a5649")]]:
        for k in range(16):
            var r:=Rect2(float(boundary[0])-800+k*100,0,102,g.WORLD_SIZE.y)
            if g._world_rect_visible(r):g.draw_rect(Rect2(g._project(r.position),r.size*g.world_zoom),Color(boundary[1]).lerp(boundary[2],float(k)/15))
    for key in cells(g):
        var origin:=Vector2(key)*CELL
        var random:=RandomNumberGenerator.new();random.seed=absi(key.x*251+key.y*7853+884)
        var style: String=region_at(g,origin+Vector2(CELL*.5,CELL*.5)).style
        var tile:=Rect2(origin,Vector2(CELL,CELL))
        if tile.position.x<g.CITY_SIZE.x and tile.position.y<g.CITY_SIZE.y:
            if tile.end.x>g.CITY_SIZE.x:tile.position.x=g.CITY_SIZE.x;tile.size.x=origin.x+CELL-tile.position.x
            elif tile.end.y>g.CITY_SIZE.y:tile.position.y=g.CITY_SIZE.y;tile.size.y=origin.y+CELL-tile.position.y
        var vertices:=PackedVector2Array();var uv:=PackedVector2Array()
        for p in [tile.position,Vector2(tile.end.x,tile.position.y),tile.end,Vector2(tile.position.x,tile.end.y)]:vertices.append(g._project(p));uv.append(p/220)
        g.draw_colored_polygon(vertices,Color.WHITE,uv,GRASS)
        if style=="meadow":
            var field:=Rect2(origin+Vector2(80,75),Vector2(1370,1340))
            if field.position.x>=g.CITY_SIZE.x or field.position.y>=g.CITY_SIZE.y:
                g.draw_rect(Rect2(g._project(field.position),field.size*g.world_zoom),Color("#8b8953") if (key.x+key.y)%3==0 else Color("#62794e"))
                for k in range(14):
                    var y: float=field.position.y+40+k*90
                    g.draw_line(g._project(Vector2(field.position.x,y)),g._project(Vector2(field.end.x,y)),Color(.76,.75,.47,.15),3*g.world_zoom,true)
        for i in range(100 if g.graphics_quality>=2 else 40):
            var p:=origin+Vector2(random.randf_range(0,CELL),random.randf_range(0,CELL))
            if Rect2(Vector2.ZERO,g.CITY_SIZE).has_point(p) or not g._tile_visible(g._project(p),30):continue
            var grass:=Color(.65,.76,.48,.18) if style!="forest" else Color(.59,.73,.57,.16)
            g.draw_line(g._project(p),g._project(p+Vector2(7,-5)),grass,1.2*g.world_zoom,true)
            if i%8==0 and style in ["meadow","suburb"]:g.draw_circle(g._project(p+Vector2(0,-5)),1.6*g.world_zoom,Color("#dacb8c") if i%3 else Color("#b5c9d3"))
static func draw_water(g: Node2D) -> void:
    for w in g.waters:
        if not w.get("regional",false) or not g._world_rect_visible(Rect2(w.rect)):continue
        var poly:=PackedVector2Array()
        for p in w.polygon:poly.append(g._project(p))
        g.draw_colored_polygon(poly,Color(w.tint).darkened(.1));poly.append(poly[0])
        g.draw_polyline(poly,Color("#abaf7a"),22*g.world_zoom,true);g.draw_polyline(poly,Color("#577d68"),8*g.world_zoom,true)
        var center: Vector2=Rect2(w.rect).get_center()
        for i in range(60):
            var p:=center+Vector2(sin(i*2.51)*Rect2(w.rect).size.x*.44,cos(i*1.72)*Rect2(w.rect).size.y*.44)
            if not Geometry2D.is_point_in_polygon(p,w.polygon) or not g._tile_visible(g._project(p),90):continue
            g.draw_line(g._project(p),g._project(p+Vector2(48,sin(Time.get_ticks_msec()/1200.0+i)*4)),Color(.6,.85,.87,.22),1.4*g.world_zoom,true)
static func draw_roads(g: Node2D) -> void:
    for pass_index in range(2):
        for road in g.roads:
            if not road.get("regional",false):continue
            for i in range(road.points.size()-1):
                var a: Vector2=road.points[i];var b: Vector2=road.points[i+1]
                var width: float=float(road.width)*g.world_zoom
                if not g._world_rect_visible(Rect2(a.min(b),a.max(b)-a.min(b)).grow(180)):continue
                var sa: Vector2=g._project(a);var sb: Vector2=g._project(b)
                if pass_index==0:
                    g.draw_line(sa,sb,Color("#34463a"),width+(16 if road.kind=="trail" else 66)*g.world_zoom,true)
                    g.draw_line(sa,sb,Color("#c4b993") if road.kind=="residential" else Color("#8c9471"),width+(8 if road.kind=="trail" else 48)*g.world_zoom,true)
                else:
                    g.draw_line(sa,sb,Color("#a69a73") if road.kind=="trail" else Color("#313d42"),width,true)
                    if g.graphics_quality>0:
                        var normal: Vector2=(b-a).normalized().orthogonal()*float(road.width)*.5
                        var poly:=PackedVector2Array();var uv:=PackedVector2Array()
                        for p in [a-normal,b-normal,b+normal,a+normal]:poly.append(g._project(p));uv.append(p/180)
                        g.draw_colored_polygon(poly,Color.WHITE if road.kind=="trail" else Color(.76,.85,.81,1),uv,TRAIL if road.kind=="trail" else g.CityArt.ASPHALT)
            for p in road.points:
                if not g._tile_visible(g._project(p),180):continue
                var radius: float=float(road.width)*g.world_zoom*.5
                if pass_index==0:
                    g.draw_circle(g._project(p),radius+(8 if road.kind=="trail" else 33)*g.world_zoom,Color("#34463a"))
                    g.draw_circle(g._project(p),radius+(4 if road.kind=="trail" else 24)*g.world_zoom,Color("#c4b993") if road.kind=="residential" else Color("#8c9471"))
                else:g.draw_circle(g._project(p),radius,Color("#a69a73") if road.kind=="trail" else Color("#3c4949"))
    for road in g.roads:
        if not road.get("regional",false):continue
        for i in range(road.points.size()-1):
            var a: Vector2=road.points[i];var b: Vector2=road.points[i+1]
            if not g._world_rect_visible(Rect2(a.min(b),a.max(b)-a.min(b)).grow(180)):continue
            var delta:=b-a;var tangent:=delta.normalized()
            var projection: float=clampf((g.camera_pos-a).dot(tangent),0,delta.length())
            var distance: float=floor(maxf(0,projection-1800)/65)*65
            var end: float=minf(delta.length(),projection+1800)
            while distance<end:
                var p:=a+tangent*distance
                if g._tile_visible(g._project(p),120) and road.kind!="trail":
                    g.draw_line(g._project(p),g._project(p+tangent*28),Color("#d7cf99"),2*g.world_zoom,true)
                    for side in [-1.0,1.0]:
                        var edge: Vector2=p+tangent.orthogonal()*(float(road.width)*.5-5)*side
                        g.draw_line(g._project(edge),g._project(edge+tangent*64),Color("#dfddd0"),1.1*g.world_zoom,true)
                distance+=65
            draw_bridges(g,a,b,float(road.width))
static func draw_bridges(g: Node2D,a: Vector2,b: Vector2,width: float) -> void:
    for w in g.waters:
        if not w.get("regional",false):continue
        var crossings: Array=[];var poly: PackedVector2Array=w.polygon
        if Geometry2D.is_point_in_polygon(a,poly):crossings.append(0.0)
        if Geometry2D.is_point_in_polygon(b,poly):crossings.append(1.0)
        for i in range(poly.size()):
            var hit=Geometry2D.segment_intersects_segment(a,b,poly[i],poly[(i+1)%poly.size()])
            if hit is Vector2:crossings.append((hit-a).dot(b-a)/(b-a).length_squared())
        if crossings.size()<2:continue
        crossings.sort()
        var start:=a.lerp(b,float(crossings[0]));var finish:=a.lerp(b,float(crossings[-1]))
        if not g._world_rect_visible(Rect2(start.min(finish),start.max(finish)-start.min(finish)).grow(180)):continue
        var normal: Vector2=(b-a).normalized().orthogonal()
        for side in [-1.0,1.0]:
            var p: Vector2=start+normal*(width*.5+23)*side;var q: Vector2=finish+normal*(width*.5+23)*side
            g.draw_line(g._project(p),g._project(q),Color("#243b3e"),10*g.world_zoom,true)
            g.draw_line(g._project(p,12),g._project(q,12),Color("#d3d6bd"),4*g.world_zoom,true)
            var count: int=maxi(1,int(p.distance_to(q)/65))
            for k in range(count+1):
                var post: Vector2=p.lerp(q,float(k)/count)
                g.draw_line(g._project(post),g._project(post,12),Color("#8eaa9e"),3*g.world_zoom,true)
static func draw_house(g: Node2D,b: Dictionary) -> void:
    var r: Rect2=b.rect;var z: float=b.height;var scale: float=g.world_zoom
    var foot: Array[Vector2]=[];var top: Array[Vector2]=[]
    for p in [r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]:foot.append(g._project(p));top.append(g._project(p,z))
    var yard:=Rect2(r.position-Vector2(42,48),r.size+Vector2(84,100))
    g.draw_rect(Rect2(g._project(yard.position),yard.size*scale),Color("#74865b"));g.draw_rect(Rect2(g._project(yard.position),yard.size*scale),Color("#b7ad86"),false,2*scale)
    var shadow:=PackedVector2Array()
    for p in foot:shadow.append(p+Vector2(27,35)*scale)
    g.draw_colored_polygon(shadow,Color(.04,.09,.06,.26))
    var ink:=Color("#293a32")
    for edge in [1,2]:
        var next: int=(edge+1)%4
        var wall:=PackedVector2Array([foot[edge],foot[next],top[next],top[edge]])
        g.draw_colored_polygon(wall,Color(b.wall).darkened(.18 if edge==1 else 0))
        g.draw_polyline(PackedVector2Array([wall[0],wall[1],wall[2],wall[3],wall[0]]),ink,1.4*scale,true)
        for column in range(3):
            var u: float=.2+column*.3
            var center: Vector2=foot[edge].lerp(foot[next],u).lerp(top[edge].lerp(top[next],u),.56)
            var tangent: Vector2=(foot[next]-foot[edge]).normalized()
            g.draw_line(center-tangent*8*scale,center+tangent*8*scale,Color("#445a58"),16*scale,true)
            g.draw_line(center-tangent*8*scale,center+tangent*8*scale,Color("#d8dba8"),10*scale,true)
            g.draw_line(center-tangent*8*scale,center+tangent*8*scale,ink,scale,true)
    var ra: Vector2=g._project(Vector2(r.get_center().x,r.position.y),z+35)
    var rb: Vector2=g._project(Vector2(r.get_center().x,r.end.y),z+35)
    g.draw_colored_polygon(PackedVector2Array([top[0],ra,rb,top[3]]),Color("#bb8567"))
    g.draw_colored_polygon(PackedVector2Array([ra,top[1],top[2],rb]),Color("#896452"))
    g.draw_polyline(PackedVector2Array([top[0],ra,top[1],top[2],rb,top[3],top[0]]),ink,2*scale,true)
    g.draw_line(ra,rb,Color("#dec199"),2*scale,true)
    for i in range(1,8):
        var t: float=float(i)/8
        g.draw_line(top[0].lerp(ra,t),top[3].lerp(rb,t),Color(.32,.24,.18,.35),.8*scale,true)
        g.draw_line(top[1].lerp(ra,t),top[2].lerp(rb,t),Color(.23,.20,.17,.4),.8*scale,true)
    if int(b.seed)%3==0:
        var solar:=PackedVector2Array([ra.lerp(top[1],.25).lerp(rb.lerp(top[2],.25),.2),ra.lerp(top[1],.65).lerp(rb.lerp(top[2],.65),.2),ra.lerp(top[1],.65).lerp(rb.lerp(top[2],.65),.62),ra.lerp(top[1],.25).lerp(rb.lerp(top[2],.25),.62)])
        g.draw_colored_polygon(solar,Color("#355964"));solar.append(solar[0]);g.draw_polyline(solar,Color("#aac3b7"),scale,true)
    var door: Vector2=foot[2].lerp(foot[3],.5)
    g.draw_rect(Rect2(door-Vector2(11,26)*scale,Vector2(22,27)*scale),Color("#526450"));g.draw_circle(door-Vector2(-6,11)*scale,1.4*scale,Color("#f4df99"))
    g.draw_line(door+Vector2(0,2)*scale,door+Vector2(0,48)*scale,Color("#c3b69c"),24*scale,true)
    # Fences, flower planters and letterboxes reinforce a human-scale neighborhood.
    for k in range(7):
        var fence: Vector2=g._project(Vector2(yard.position.x+k*yard.size.x/6,yard.end.y),5)
        g.draw_line(fence,fence-Vector2(0,9)*scale,Color("#b8b49a"),1.5*scale,true)
    g.draw_line(g._project(Vector2(yard.position.x,yard.end.y),8),g._project(yard.end,8),Color("#c7c0a0"),1.2*scale,true)
    for side in [-1.0,1.0]:
        var planter: Vector2=door+Vector2(side*38,-5)*scale
        g.draw_rect(Rect2(planter-Vector2(8,0)*scale,Vector2(16,7)*scale),Color("#97664d"))
        g.draw_circle(planter-Vector2(0,4)*scale,7*scale,Color("#639361"));g.draw_circle(planter-Vector2(2,7)*scale,2*scale,Color("#e2b597"))
    if b.kind!="home":
        var sign: Vector2=door-Vector2(42,48)*scale
        g.draw_rect(Rect2(sign,Vector2(84,17)*scale),Color("#355d54"))
        g.draw_string(ThemeDB.fallback_font,sign+Vector2(4,12)*scale,{"cafe":"CAFÉ","garage":"WERKSTATT","farm":"LINDENHOF","ranger":"WALDHAUS","mill":"ALTE MÜHLE","observatory":"STATION"}.get(str(b.kind),""),HORIZONTAL_ALIGNMENT_CENTER,76*scale,int(10*scale),Color("#f1dcaa"))
static func draw_tree(g: Node2D,data: Dictionary) -> void:
    var p: Vector2=data.pos;var foot: Vector2=g._project(p);var scale: float=g.world_zoom
    if not g._tile_visible(foot,180):return
    var r: float=data.r;var h: float=data.h
    g._draw_poly_ellipse(foot+Vector2(12,20)*scale,Vector2(r*.8,r*.35)*scale,0,Color(.02,.1,.07,.27))
    if data.kind=="heather":
        var center: Vector2=g._project(p,h)
        for i in range(5):
            var bloom:=center+Vector2.from_angle(i*TAU/5)*r*.3*scale
            g.draw_circle(bloom,r*.45*scale,Color("#777d61"))
            for k in range(4):g.draw_circle(bloom+Vector2.from_angle(k*TAU/4+i)*r*.24*scale,2.3*scale,Color("#c2a1ac") if i%2 else Color("#a5889d"))
        return
    if data.kind=="rock":
        var poly:=PackedVector2Array()
        for i in range(7):poly.append(g._project(p+Vector2.from_angle(i*TAU/7)*r*.65,18+sin(i*2)*5))
        g.draw_colored_polygon(poly,Color("#a4a68b"));poly.append(poly[0]);g.draw_polyline(poly,Color("#546854"),1.5*scale,true);return
    g.draw_line(foot,g._project(p,h*.75),Color("#354b3d"),7*scale,true)
    g.draw_line(foot+Vector2(2,0)*scale,g._project(p,h*.75)+Vector2(2,0)*scale,Color("#8c7b55"),2*scale,true)
    if data.kind=="pine":
        for layer in range(3):
            var center: Vector2=g._project(p,h*(.42+layer*.22))
            var radius: float=r*(1.1-layer*.23)*scale
            var leaf:=PackedVector2Array()
            for i in range(12):
                var angle: float=float(i)*TAU/12
                var distance: float=radius*(1 if i%2==0 else .72)
                leaf.append(center+Vector2(cos(angle),sin(angle)*.64)*distance)
            g.draw_colored_polygon(leaf,[Color("#234e40"),Color("#3b7053"),Color("#669369")][layer]);leaf.append(leaf[0]);g.draw_polyline(leaf,Color("#274938"),1.3*scale,true)
    else:
        var center: Vector2=g._project(p,h)
        for i in range(5):g.draw_circle(center+Vector2.from_angle(i*TAU/5)*r*.36*scale,r*.62*scale,Color("#789457") if i%2 else Color("#548454"))
        g.draw_circle(center-Vector2(8,10)*scale,r*.44*scale,Color("#9aaf66"))
static func draw_flora(g: Node2D) -> void:
    var items: Array=[]
    for key in cells(g):items.append_array(cell_data(g,key))
    items.sort_custom(func(a,b):return a.pos.y<b.pos.y)
    for item in items:draw_tree(g,item)
static func draw_pois(g: Node2D) -> void:
    for p in g.region_pois:
        var pos: Vector2=p.pos;var screen: Vector2=g._project(pos);var s: float=g.world_zoom;var kind: String=p.kind
        if not g._tile_visible(screen,180):continue
        if kind=="bus":
            g.draw_rect(Rect2(screen-Vector2(38,20)*s,Vector2(76,40)*s),Color("#b1b59a"))
            g.draw_line(screen-Vector2(26,0)*s,screen-Vector2(26,52)*s,Color("#334c42"),4*s,true)
            g.draw_rect(Rect2(screen-Vector2(39,75)*s,Vector2(26,25)*s),Color("#9bcfc4"))
            g.draw_string(ThemeDB.fallback_font,screen-Vector2(36,55)*s,"B",HORIZONTAL_ALIGNMENT_CENTER,20*s,int(16*s),Color("#233d39"))
            g.draw_line(screen+Vector2(4,-2)*s,screen+Vector2(30,-2)*s,Color("#97795b"),9*s,true)
        elif kind in ["camp","rest","view","farm","ranger"]:
            g.draw_rect(Rect2(screen-Vector2(44,30)*s,Vector2(88,60)*s),Color("#a49b74"))
            g.draw_line(screen-Vector2(25,12)*s,screen+Vector2(25,-12)*s,Color("#876647"),8*s,true)
            g.draw_line(screen-Vector2(25,2)*s,screen+Vector2(25,2)*s,Color("#b69c67"),6*s,true)
            if kind=="camp":
                var tent:=screen+Vector2(65,-25)*s
                g.draw_colored_polygon(PackedVector2Array([tent-Vector2(32,0)*s,tent-Vector2(0,50)*s,tent+Vector2(32,0)*s]),Color("#d1a65a"))
                g.draw_colored_polygon(PackedVector2Array([tent-Vector2(15,0)*s,tent-Vector2(0,34)*s,tent+Vector2(10,0)*s]),Color("#4b614b"))
                g.draw_circle(screen+Vector2(9,40)*s,13*s,Color("#53654b"));g.draw_line(screen+Vector2(-1,35)*s,screen+Vector2(19,45)*s,Color("#785d43"),4*s,true)
        elif kind=="square":
            for x in range(12):
                for y in range(8):
                    var tile: Vector2=pos+Vector2(-150+x*25,-95+y*24)
                    if g.roads.any(func(r):return g._distance_to_polyline(tile+Vector2(12,12),r.points)<float(r.width)*.5+21):continue
                    g.draw_rect(Rect2(g._project(tile),Vector2(24,23)*s),Color("#aba58a") if (x+y)%3 else Color("#bcb296"))
            g.draw_circle(screen+Vector2(40,0)*s,30*s,Color("#517f76"));g.draw_circle(screen+Vector2(40,0)*s,23*s,Color("#85b6ae"))
            g.draw_arc(screen+Vector2(40,0)*s,(8+fposmod(Time.get_ticks_msec()*.01,13))*s,0,TAU,24,Color(.8,.93,.8,.5),s,true)
            for point in [Vector2(-90,-45),Vector2(-90,50),Vector2(110,52)]:
                var bench: Vector2=screen+point*s
                g.draw_line(bench-Vector2(19,0)*s,bench+Vector2(19,0)*s,Color("#755d46"),7*s,true)
                g.draw_line(bench-Vector2(19,5)*s,bench+Vector2(19,-5)*s,Color("#b99a70"),5*s,true)
            for point in [Vector2(-130,-73),Vector2(130,-73),Vector2(132,77),Vector2(-132,77)]:
                var planter: Vector2=screen+point*s
                g.draw_rect(Rect2(planter-Vector2(10,7)*s,Vector2(20,14)*s),Color("#8d7056"));g.draw_circle(planter-Vector2(0,7)*s,10*s,Color("#6c9862"))
                for k in range(5):g.draw_circle(planter+(Vector2.from_angle(k*TAU/5)*6-Vector2(0,8))*s,2.5*s,Color("#e8bc91"))
            g.CityArt.draw_character(g,pos+Vector2(-35,0),0,1,0,"chat")
        var sign:=screen-Vector2(0,30)*s
        g.draw_line(sign,sign-Vector2(0,25)*s,Color("#405548"),3*s,true);g.draw_circle(sign-Vector2(0,30)*s,9*s,Color(p.accent))
        if active_target(g)==pos:g.draw_circle(screen,31*s,Color("#f2d28c"),false,2*s,true)
        if g.player_pos.distance_to(pos)<430 and not g._modal_active():g.draw_string(ThemeDB.fallback_font,sign-Vector2(125,60)*s,str(p.name),HORIZONTAL_ALIGNMENT_CENTER,250*s,int(13*s),Color("#eee9c9"))
