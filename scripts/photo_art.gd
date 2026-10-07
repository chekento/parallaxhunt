extends RefCounted
## Shared street-front details reconstructed at the fixed photo viewpoint.
const PAVING_SHADER=preload("res://shaders/plaza.gdshader")

static func paving_material(style: String) -> ShaderMaterial:
    var mat:=ShaderMaterial.new()
    mat.shader=PAVING_SHADER
    var colors=[Color("#938c79"),Color("#aaa28a")]
    if style in ["glass","data","astro"]:
        colors=[Color("#72848b"),Color("#92a5a8")]
    elif style in ["neon","culture","expo"]:
        colors=[Color("#706d7a"),Color("#8b8390")]
    mat.set_shader_parameter("stone_a",colors[0])
    mat.set_shader_parameter("stone_b",colors[1])
    return mat

static func cylinder(g: Node2D, parent: Node3D, name_text: String, pos: Vector3, radius: float, height: float, color: Color, top_radius: float = -1.0) -> MeshInstance3D:
    var mesh:=CylinderMesh.new()
    mesh.bottom_radius=radius
    mesh.top_radius=radius if top_radius<0 else top_radius
    mesh.height=height
    mesh.radial_segments=8
    var node:=MeshInstance3D.new()
    node.name=name_text
    node.mesh=mesh
    node.position=pos
    node.material_override=g._photo_material(color)
    parent.add_child(node)
    return node

static func glow(g: Node2D, node: MeshInstance3D, color: Color, energy: float = 0.8) -> void:
    var mat: StandardMaterial3D=g._photo_material(color)
    mat.emission_enabled=true
    mat.emission=color
    mat.emission_energy_multiplier=energy
    node.material_override=mat

static func palm(g: Node2D, parent: Node3D, pos: Vector3, seed_value: int) -> void:
    cylinder(g,parent,"PalmPlanter",pos+Vector3(0,0.35,0),1.2,0.7,Color("#6e6554"),1.35)
    cylinder(g,parent,"PalmTrunk",pos+Vector3(0,2.7,0),0.24,5.4,Color("#877451"),0.16)
    var vertices:=PackedVector3Array()
    var colors:=PackedColorArray()
    var normals:=PackedVector3Array()
    var indices:=PackedInt32Array()
    var center:=pos+Vector3(0,5.3,0)
    for i in range(9):
        var angle:=float(i)*TAU/9+float(seed_value%7)*0.14
        var dir:=Vector3(cos(angle),0,sin(angle))
        var side:=Vector3(-dir.z,0,dir.x)
        var mid:=center+dir*1.6+Vector3(0,0.52,0)
        var tip:=center+dir*3.0-Vector3(0,0.55,0)
        var first:=vertices.size()
        vertices.append_array(PackedVector3Array([center,mid-side*0.46,mid+side*0.46,tip]))
        for n in range(4):
            colors.append(Color("#4e985e") if i%2==0 else Color("#30714b"))
            normals.append(Vector3.UP)
        indices.append_array(PackedInt32Array([first,first+1,first+2,first+1,first+3,first+2]))
    var arrays:=[]
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX]=vertices
    arrays[Mesh.ARRAY_COLOR]=colors
    arrays[Mesh.ARRAY_NORMAL]=normals
    arrays[Mesh.ARRAY_INDEX]=indices
    var mesh:=ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
    var node:=MeshInstance3D.new()
    node.name="PalmFronds"
    node.mesh=mesh
    var material:=StandardMaterial3D.new()
    material.vertex_color_use_as_albedo=true
    material.cull_mode=BaseMaterial3D.CULL_DISABLED
    material.roughness=0.95
    node.material_override=material
    parent.add_child(node)

static func bench(g: Node2D, parent: Node3D, pos: Vector3) -> void:
    for slat in range(4):
        g._photo_box("BenchSlat",pos+Vector3(float(slat)*0.19-0.28,0.70,0),Vector3(0.16,0.11,2.4),Color("#9c7450"),parent)
    for end in [-0.85,0.85]:
        g._photo_box("BenchLeg",pos+Vector3(0,0.34,end),Vector3(0.58,0.64,0.16),Color("#1a2931"),parent)
    g._photo_box("BenchBack",pos+Vector3(0.36,1.15,0),Vector3(0.12,0.76,2.4),Color("#785c43"),parent)

static func cafe(g: Node2D, parent: Node3D, pos: Vector3, seed_value: int) -> void:
    cylinder(g,parent,"UmbrellaPole",pos+Vector3(0,1.8,0),0.06,3.6,Color("#e1c6a0"))
    cylinder(g,parent,"UmbrellaCanopy",pos+Vector3(0,3.5,0),2.1,0.65,Color("#c9553e") if seed_value%2==0 else Color("#348b8d"),0.15)
    cylinder(g,parent,"TableBase",pos+Vector3(0,0.60,0),0.13,1.2,Color("#293c44"))
    cylinder(g,parent,"TableTop",pos+Vector3(0,1.2,0),0.85,0.13,Color("#bd9769"))
    for sign_value in [-1.0,1.0]:
        var chair:=pos+Vector3(0,0,sign_value*1.3)
        g._photo_box("ChairSeat",chair+Vector3(0,0.55,0),Vector3(0.6,0.12,0.6),Color("#deba85"),parent)
        g._photo_box("ChairBack",chair+Vector3(0,0.98,sign_value*0.28),Vector3(0.6,0.78,0.10),Color("#8a7254"),parent)
        for dx in [-0.23,0.23]:
            g._photo_box("ChairLeg",chair+Vector3(dx,0.27,0),Vector3(0.07,0.50,0.5),Color("#2d3c41"),parent)

static func add_streets(g: Node2D, center: Vector2, radius: float) -> void:
    if g.graphics_quality==0:
        return
    var nearby: Array=g.street_ensembles.filter(func(s): return Vector2(s.pos).distance_to(center)<radius*0.9)
    nearby.sort_custom(func(a,b): return Vector2(a.pos).distance_squared_to(center)<Vector2(b.pos).distance_squared_to(center))
    var light_count:=0
    for i in range(mini(nearby.size(),24 if g.graphics_quality>=2 else 12)):
        var s: Dictionary=nearby[i]
        var root:=Node3D.new()
        root.name="StreetEnsemble_%d" % i
        root.position=g._photo_local(Vector2(s.pos),center)
        root.rotation.y=-Vector2(s.tangent).angle()
        g.photo_world_root.add_child(root)
        var seed_value:=int(s.seed)
        var pole:=Vector3(-3,0,0)
        cylinder(g,root,"LampPole",pole+Vector3(0,2.2,0),0.13,4.4,Color("#263740"))
        g._photo_box("LampArm",pole+Vector3(0,4.45,-0.4),Vector3(0.15,0.16,1),Color("#273b45"),root)
        var lamp: MeshInstance3D=g._photo_box("LampGlow",pole+Vector3(0,4.35,-0.85),Vector3(0.45,0.10,0.8),Color("#ffd493"),root)
        glow(g,lamp,Color("#ffc683"),1.2)
        if root.position.length()<65 and light_count<4 and (g.world_clock>17 or g.world_clock<6):
            var light:=OmniLight3D.new()
            light.position=pole+Vector3(0,3.5,-0.9)
            light.light_color=Color("#ffd0a1")
            light.light_energy=1.1
            light.omni_range=11
            light.omni_attenuation=1.7
            light.shadow_enabled=false
            root.add_child(light)
            light_count+=1
        var variant:=seed_value%4
        if variant==0 or str(s.style) in ["coast","canal","neon"]:
            palm(g,root,Vector3(1.6,0,0.8),seed_value)
        elif variant==1:
            cafe(g,root,Vector3.ZERO,seed_value)
        else:
            bench(g,root,Vector3.ZERO)
            cylinder(g,root,"Planter",Vector3(0,0.3,2.2),0.75,0.6,Color("#68645b"),0.85)
            cylinder(g,root,"PlanterLeaves",Vector3(0,0.75,2.2),0.82,0.75,Color("#477e50"),0.45)
    # Dress the reserved viewpoint itself with a close foreground and a readable
    # depth cue. World clearance checks keep these props off the carriageway.
    var facing: Vector2=Vector2(g.photo_points[g.active_photo_index].dir).normalized()
    var side:=Vector2(-facing.y,facing.x)
    for sign_value in [-1.0,1.0]:
        var position:=Vector2.ZERO
        for forward_distance in [90.0,70.0,55.0]:
            var candidate: Vector2=center+facing*forward_distance+side*15*sign_value
            if not g._point_on_road(candidate) and not g._point_blocked(candidate,14):
                position=candidate
                break
        if position==Vector2.ZERO:
            continue
        var plaza:=Node3D.new()
        plaza.name="ViewpointFurniture"
        plaza.position=g._photo_local(position,center)
        plaza.rotation.y=-facing.angle()
        g.photo_world_root.add_child(plaza)
        if sign_value<0:
            bench(g,plaza,Vector3.ZERO)
        else:
            palm(g,plaza,Vector3.ZERO,int(center.x+center.y))

static func add_roof(g: Node2D, local: Vector3, size: Vector3, height: float, b: Dictionary) -> void:
    if g.graphics_quality==0:
        return
    var roof_y:=local.y+height*0.52
    var kind:=str(b.get("roof_mode","flat"))
    if kind=="solar" or str(b.style)=="solar":
        for n in range(3):
            var panel: MeshInstance3D=g._photo_box("SolarPanel",Vector3(local.x+(float(n)-1)*2.4,roof_y+0.7,local.z),Vector3(2,0.12,3.3),Color("#174964"))
            panel.rotation.x=-0.20
            for strip in range(4):
                g._photo_box("SolarGrid",Vector3(local.x+(float(n)-1)*2.4,roof_y+0.85,local.z+float(strip)*0.7-1.1),Vector3(1.9,0.025,0.03),Color("#80b3c0"))
    elif kind in ["green","garden","terrace"] or str(b.style) in ["garden","green"]:
        g._photo_box("RoofGarden",Vector3(local.x,roof_y+0.2,local.z),Vector3(size.x*0.6,0.3,size.z*0.5),Color("#42664b"))
        for n in range(3):
            var q:=Vector3(local.x+(float(n)-1)*size.x*0.2,roof_y+0.4,local.z-size.z*0.22)
            g._photo_box("RoofPlanter",q,Vector3(1.6,0.6,1.4),Color("#91715a"))
            cylinder(g,g.photo_world_root,"RoofShrub",q+Vector3(0,0.8,0),0.85,1.2,Color("#4e9563"),0.5)
    elif kind=="antenna":
        g._photo_box("RoofAntenna",Vector3(local.x,roof_y+2.5,local.z),Vector3(0.14,5,0.14),Color("#bcc9c9"))
        for n in range(3):
            g._photo_box("AntennaBar",Vector3(local.x,roof_y+2+float(n),local.z),Vector3(2.4-float(n)*0.4,0.10,0.10),Color("#b7c8c6"))

static func person(g: Node2D, parent: Node3D, ped: Dictionary) -> void:
    var clothes: Color=Color(ped.color)
    var skin: Color=Color(ped.skin)
    g._photo_box("Body",Vector3(0,1.7,0),Vector3(0.80,1.45,0.52),clothes,parent)
    for side in [-1.0,1.0]:
        g._photo_box("Leg",Vector3(side*0.23,0.60,0),Vector3(0.26,1.15,0.30),Color("#2c3c47"),parent)
        g._photo_box("Shoe",Vector3(side*0.23,0.10,-0.1),Vector3(0.3,0.2,0.55),Color("#b1b3aa"),parent)
        var arm: MeshInstance3D=g._photo_box("Arm",Vector3(side*0.55,1.65,0),Vector3(0.22,1.30,0.24),clothes.darkened(0.10),parent)
        arm.rotation.z=-side*0.10
        g._photo_box("Hand",Vector3(side*0.59,0.94,0),Vector3(0.18,0.25,0.22),skin,parent)
    cylinder(g,parent,"Head",Vector3(0,2.75,0),0.32,0.58,skin)
    cylinder(g,parent,"Hair",Vector3(0,3.08,0.02),0.34,0.22,Color(ped.hair),0.29)
    if bool(ped.bag):
        g._photo_box("Backpack",Vector3(0,1.9,0.37),Vector3(0.60,0.86,0.30),Color("#23394b"),parent)
