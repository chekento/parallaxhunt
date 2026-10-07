extends RefCounted
## A distant village preserves broad empty corridors for future settlements.
static func build(g: Node) -> void:
    g.world_regions.append_array([
        g.RegionWorld.region("Mühlenau",Rect2(92200,27800,8300,8000),"village","#768269","#edc690"),
        g.RegionWorld.region("Heidekamm",Rect2(86000,0,24000,46000),"heath","#706d59","#d5b697"),
        g.RegionWorld.region("Weite Südauen",Rect2(0,36000,86000,10000),"meadow","#536c56","#b7d2a1")])
    g.RegionWorld.add_road(g,"L 02 · Heidechaussee",[Vector2(83800,20500),Vector2(87500,23120),Vector2(91400,24900),Vector2(94400,29400),Vector2(97000,32200),Vector2(102700,38600),Vector2(108000,42200)],108,"country")
    g.RegionWorld.add_road(g,"Mühlenauer Dorfstraße",[Vector2(94400,29400),Vector2(97000,29400),Vector2(97000,34200),Vector2(94400,34200),Vector2(94400,29400)],80,"residential")
    g.RegionWorld.add_road(g,"Am Mühlenhof",[Vector2(97000,32200),Vector2(96200,32200),Vector2(96200,33300)],76,"residential")
    g.RegionWorld.add_road(g,"Heideuferweg",[Vector2(87500,23120),Vector2(87200,19500),Vector2(88700,17000),Vector2(92300,16300),Vector2(94000,18900),Vector2(94300,22300),Vector2(91400,24900)],46,"trail")
    g.RegionWorld.add_road(g,"Auenpfad",[Vector2(97000,34200),Vector2(99600,36300),Vector2(102700,38600),Vector2(104000,40800),Vector2(108000,42200)],46,"trail")
    g.RegionWorld.add_water(g,"Heideteich",PackedVector2Array([Vector2(89000,18000),Vector2(91000,17300),Vector2(92800,19000),Vector2(93000,20700),Vector2(91700,22000),Vector2(89900,21300),Vector2(88900,19500)]),Color("#638b8b"))
    g.RegionWorld.add_water(g,"Mühlenbach",PackedVector2Array([Vector2(88100,30700),Vector2(93000,31300),Vector2(96000,31700),Vector2(98600,32600),Vector2(101200,34100),Vector2(104200,38900),Vector2(109500,45200),Vector2(109100,45500),Vector2(103800,39100),Vector2(100900,34400),Vector2(98300,33000),Vector2(95800,32100),Vector2(92900,31700),Vector2(88000,31100)]),Color("#507e85"))
    g.region_pois.append_array([
        g.RegionWorld.poi("heath_gate","Tor zum Heidekamm",Vector2(84800,21460),"sign","Hinter dem Freiland beginnt die Heide. Bis Mühlenau bleibt viel offene Landschaft zwischen den Orten."),
        g.RegionWorld.poi("heath_view","Heidekamm · Fernsicht",Vector2(87360,23280),"view","Weite Wege, niedrige Vegetation und ein Horizont jenseits der Stadt."),
        g.RegionWorld.poi("heath_lake","Heideteich · Uferbank",Vector2(88620,17100),"rest","Eine stille Bucht am Heideuferweg. Der Weg umrundet das Wasser auf trockenem Boden."),
        g.RegionWorld.poi("village_bus","Mühlenau · Regionalbus",Vector2(94280,29510),"bus","Ein Anschluss in die Stadt, nach Sonnenhagen, zum Lindensee und zum Waldtor."),
        g.RegionWorld.poi("village_square","Mühlenau · Dorfplatz",Vector2(95280,29610),"square","Ein kleiner Platz zwischen niedrigen Häusern. Tessa sammelt die Geschichten des Dorfes am blauen Dorfbrett."),
        g.RegionWorld.poi("village_cafe","Café Mühlenpause",Vector2(96890,30370),"cafe","Ein warmer Innenraum, Kuchen und eine Pause vor dem Weg zur alten Mühle."),
        g.RegionWorld.poi("old_bridge","Brücke am Mühlenbach",Vector2(97000,32200),"bridge","Der Bach läuft sichtbar unter dem durchgehenden Straßensteg. Die Mühle liegt am trockenen Hof daneben."),
        g.RegionWorld.poi("old_mill","Alte Mühle von Mühlenau",Vector2(96090,33000),"mill","Die Flügel drehen sich langsam über dem Hof. Das Dorfbrett führt zur Reparaturgeschichte der Mühle."),
        g.RegionWorld.poi("south_view","Auenhöhe · Weites Land",Vector2(102550,38730),"view","Viel offener Raum zwischen einzelnen Orten. Hier wird das spätere Land weiter wachsen.")])
    var random:=RandomNumberGenerator.new();random.seed=1252026
    for x in [94400.0,97000.0]:
        for y in [30100.0,30900.0,33100.0,33900.0]:
            for side in [-1.0,1.0]:
                var p:=Vector2(x+side*185,y)
                var rect:=Rect2(p-Vector2(82,62),Vector2(164,124))
                if not g._rect_near_road(rect,45) and not g._point_blocked(p,122):
                    g.RegionWorld.house(g,rect,random.randi(),"home")
                    g.buildings[-1].style="village";g.buildings[-1].roof=Color("#7e785d")
    for item in [[Rect2(97150,30270,205,160),"cafe"],[Rect2(95915,33050,195,190),"mill"]]:
        g.RegionWorld.house(g,item[0],random.randi(),item[1]);g.buildings[-1].style="village"
    for p in [Vector2(95000,29220),Vector2(95600,29220),Vector2(96200,29220),Vector2(95800,29620),Vector2(96400,29620)]:
        var rect:=Rect2(p-Vector2(82,62),Vector2(164,124))
        if not g._point_blocked(p,120):g.RegionWorld.house(g,rect,random.randi(),"home");g.buildings[-1].style="village"
    for p in [Vector2(94300,29680),Vector2(97120,30500),Vector2(96320,32900)]:g.parked_cars.append({"pos":p,"class":"pickup","heading":PI*.5,"color":Color("#c1ac8b"),"occupied":false})
static func draw(g: Node2D) -> void:
    var mill: Dictionary=g.RegionWorld.get_poi(g,"old_mill")
    if mill.is_empty():return
    var p: Vector2=Vector2(96015,33145);var s: float=g.world_zoom
    if not g._tile_visible(g._project(p),300):return
    var axis: Vector2=g._project(p,145)
    var angle: float=fposmod(Time.get_ticks_msec()*.00013,TAU)
    for i in range(4):
        var direction:=Vector2.from_angle(angle+i*PI*.5)
        var a:=axis+direction*15*s;var b:=axis+direction*75*s
        g.draw_line(axis,b,Color("#594c3f"),3*s,true)
        var normal:=direction.orthogonal()*9*s
        var sail:=PackedVector2Array([a-normal,b-normal,b+normal,a+normal])
        g.draw_colored_polygon(sail,Color("#dccda9"));sail.append(sail[0]);g.draw_polyline(sail,Color("#82775d"),s,true)
        for k in range(5):
            var center: Vector2=a.lerp(b,float(k)/4)
            g.draw_line(center-normal,center+normal,Color("#9a8a68"),s,true)
    g.draw_circle(axis,6*s,Color("#6a5b46"));g.draw_circle(axis,3*s,Color("#e4cd96"))
