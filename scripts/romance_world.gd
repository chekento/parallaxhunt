extends RefCounted
const Data=preload("res://scripts/romance_data.gd")

static func build(g: Node) -> void:
    g.apartment_sites.clear()
    var occupied: Array=[]
    for home in Data.HOMES:
        var desired:=Vector2(float(home.at[0]),float(home.at[1]))
        var candidates: Array=[]
        var projections: Array=g.CityAccess.road_projections(g,desired)
        for i in range(mini(20,projections.size())):
            var road: Dictionary=projections[i]
            var normal:=Vector2(-road.tangent.y,road.tangent.x)
            for along in [0.0,-260.0,260.0,-520.0,520.0]:
                var road_point: Vector2=road.pos+road.tangent*along
                for side in [-1.0,1.0]:
                    var center: Vector2=road_point+normal*(float(road.width)*.5+195)*side
                    var rect:=Rect2(center-Vector2(120,85),Vector2(240,170))
                    if not Rect2(Vector2(60,60),g.WORLD_SIZE-Vector2(120,120)).encloses(rect):continue
                    if desired.x<g.CITY_SIZE.x and rect.end.x>=g.CITY_SIZE.x:continue
                    if g._rect_near_road(rect,22):continue
                    if occupied.any(func(r):return Rect2(r).grow(70).intersects(rect)):continue
                    if g.life_places.any(func(p):return p.has("plaza") and Rect2(p.plaza).grow(35).intersects(rect)):continue
                    var corridor:=rect.grow(25).merge(Rect2(road_point-Vector2(30,30),Vector2(60,60)))
                    if g.landmarks.any(func(l):return g._landmark_rect(l).grow(32).intersects(corridor)):continue
                    if g.CityLife.water_overlap(g,corridor):continue
                    var blocked_goal:=false
                    for group in [g.photo_points,g.property_sites,g.vertical_sites,g.mission_sites,g.named_npcs,g.region_pois,g.life_places,g.storefronts]:
                        if group.any(func(p):return rect.grow(90).has_point(Vector2(p.pos))):blocked_goal=true;break
                    if blocked_goal:continue
                    var face: Vector2=normal*side
                    var edge:=minf(120/absf(face.x) if absf(face.x)>.001 else 100000,85/absf(face.y) if absf(face.y)>.001 else 100000)
                    var entry: Vector2=center-face*(edge+48)
                    candidates.append({"center":center,"rect":rect,"corridor":corridor,"entry":entry,"road":road_point,"footway":road_point+face*(float(road.width)*.5+24),"score":desired.distance_squared_to(center)})
        candidates.sort_custom(func(a,b):return a.score<b.score)
        assert(not candidates.is_empty(),"Each apartment needs a dry parcel and its own entrance")
        if candidates.is_empty():continue
        var chosen: Dictionary=candidates[0]
        g.buildings=g.buildings.filter(func(b):return not Rect2(b.rect).intersects(chosen.corridor))
        g.trees=g.trees.filter(func(t):return not chosen.corridor.has_point(t.pos))
        g.vegetation_props=g.vegetation_props.filter(func(p):return not chosen.corridor.has_point(p.pos))
        g.RegionWorld.house(g,chosen.rect,int(str(home.id).hash()),"apartment")
        var building: Dictionary=g.buildings.back()
        building.wall=Color(home.color);building.accent=Color("#e8c49a")
        if desired.x<g.CITY_SIZE.x:
            building.regional=false;building.style=str(g._district_at(chosen.center).get("style","heritage"));building.height=85 if int(home.rooms)<3 else 125;building.massing="slab";building.roof_mode="garden" if int(home.rooms)>=3 else "terrace"
        var item: Dictionary=home.duplicate(true)
        item.pos=chosen.entry;item.scene=chosen.center;item.rect=chosen.rect;item.road=chosen.road;item.footway=chosen.footway;item.legacy=false
        g.apartment_sites.append(item);occupied.append(chosen.rect)
    g.collision_index_ready=false
    g.CityAccess.rebuild_index(g)
    for p in Data.PEOPLE:
        var found:=false
        for npc in g.named_npcs:
            if str(npc.id)==str(p.id):npc.romance=true;npc.age=p.age;found=true;break
        if found:continue
        var anchor: Dictionary=g.MainStory.location(g,str(p.at))
        assert(not anchor.is_empty(),"A romance actor needs an authored location")
        var pos: Vector2=g.CityAccess.safe_point(g,Vector2(anchor.get("pos",Vector2(5150,4650)))+Vector2(-64,44))
        g.named_npcs.append({"id":p.id,"name":p.name,"age":p.age,"role":p.role,"pos":pos,"accent":Color(p.color),"text":p.intro,"romance":true,"new_romance":true})

static func finish(g: Node) -> void:
    for property in g.property_sites:
        g.apartment_sites.append({"id":property.id,"name":property.name,"pos":property.pos,"scene":property.pos-Vector2(0,170),"rent":30,"deposit":75,"price":int(property.price),"rooms":2 if property.id=="canal_loft" else 3,"capacity":3 if property.id=="canal_loft" else 4,"color":"#b2bda3","desc":"Bestehendes Wohngebäude mit Hausgarage. Frühere Eigentumsrechte bleiben erhalten.","legacy":true})
    for home in g.apartment_sites:
        home.pos=g.CityAccess.safe_point(g,home.pos)

static func npc(g: Node,id: String) -> Dictionary:
    for n in g.named_npcs:
        if str(n.id)==id:return n
    return {}
static func home(g: Node,id: String) -> Dictionary:
    for h in g.apartment_sites:
        if str(h.id)==id:return h
    return {}
static func person_pos(g: Node,id: String) -> Vector2:
    var date: Dictionary=g.love_state.get("date",{})
    if str(date.get("person",""))==id:
        var loc: Dictionary=g.MainStory.location(g,str(date.get("at","")))
        if not loc.is_empty():return Vector2(loc.pos)
    var n:=npc(g,id)
    return Vector2(n.get("pos",Vector2.ZERO))
static func nearest(g: Node,radius: float=135) -> String:
    var id: String="";var distance:=radius
    for p in Data.PEOPLE:
        var d: float=g.player_pos.distance_to(person_pos(g,p.id))
        if d<distance:id=p.id;distance=d
    return id
