extends RefCounted
## Remote connected landscapes add distance, rather than another crowded city.
static func build(g: Node) -> void:
    g.world_regions.append_array([
        g.RegionWorld.region("Wacholderweiten",Rect2(110000,0,34000,56000),"wild","#566d64","#d6c6a2"),
        g.RegionWorld.region("Südliche Flussauen",Rect2(0,46000,110000,10000),"meadow","#58765e","#bbd4a6")])
    g.RegionWorld.add_road(g,"L 03 · Straße zur Echowarte",[Vector2(108000,42200),Vector2(114500,45000),Vector2(123000,47000),Vector2(130500,43400),Vector2(132000,41500),Vector2(135000,41500)],102,"country")
    g.RegionWorld.add_road(g,"Stationsring",[Vector2(132000,41500),Vector2(132000,43300),Vector2(135000,43300),Vector2(135000,41500)],76,"residential")
    g.RegionWorld.add_road(g,"Wacholder-Höhenpfad",[Vector2(114500,45000),Vector2(118000,41200),Vector2(126000,39500),Vector2(132000,39500),Vector2(134000,38200),Vector2(135000,41500)],46,"trail")
    g.RegionWorld.add_water(g,"Wacholderbach",PackedVector2Array([Vector2(121200,42800),Vector2(125000,45550),Vector2(129000,51200),Vector2(128660,51400),Vector2(124650,45830),Vector2(120920,43130)]),Color("#699b9f"))
    g.region_pois.append_array([
        g.RegionWorld.poi("echo_gate","Weg in die Wacholderweiten",Vector2(111850,43960),"sign","L03 führt durch eine weite, unbebaute Landschaft zur Echowarte. Weitere Orte finden später in den freien Korridoren Platz."),
        g.RegionWorld.poi("echo_rest","Wacholder · Wanderbank",Vector2(118100,41340),"rest","Zwischen Bäumen und Felsen liegen Karte, Wasserstelle und eine ruhige Bank."),
        g.RegionWorld.poi("echo_bridge","Brücke im weiten Tal",Vector2(124780,46145),"bridge","Ein echter Straßensteg über den Bach; die Landschaft bleibt zu beiden Seiten offen."),
        g.RegionWorld.poi("echo_bus","Echowarte · Regionalbus",Vector2(132130,41700),"bus","Ein sechster Regionalhalt verbindet die entfernte Warte mit Stadt, Vorstadt, See, Wald und Mühlenau."),
        g.RegionWorld.poi("echo_station","Echowarte · Avens Station",Vector2(132280,42120),"ranger","Aven bewahrt die älteste unabhängige Testkopie des Erinnerungsnetzes. Hier beginnt eine Himmelsbeobachtung."),
        g.RegionWorld.poi("echo_box","Testleser der Echowarte",Vector2(134900,42140),"ranger","Vier Kanäle und ein unabhängiger Leser schützen das vollständige Prüfprotokoll."),
        g.RegionWorld.poi("echo_view","Wacholderkamm · Himmelblick",Vector2(133870,38300),"view","Weit voneinander entfernte Orte, ein stiller Horizont und ein freier Blick über das Tal."),
        g.RegionWorld.poi("echo_camp","Camp am Stationsring",Vector2(133050,43450),"camp","Ein kleiner Platz für eine kostenlose Rast nach einer langen Reise.")])
    var random:=RandomNumberGenerator.new();random.seed=1262026
    for rect in [Rect2(132360,41980,230,165),Rect2(134480,42020,245,160),Rect2(134300,43200,200,140)]:
        g.RegionWorld.house(g,rect,random.randi(),"ranger")
    g.buildings[-3].kind="observatory"
    g.parked_cars.append({"pos":Vector2(132070,42570),"class":"suv","heading":PI*.5,"color":Color("#dbbb87"),"occupied":false})
static func city_places(g: Node) -> Array:
    var result: Array=[]
    for item in [
        ["clock","Ivos Bahnhofsuhr",Vector2(6000,4340),"clock","Ivo pflegt eine große Uhr mit mechanischem Zifferblatt. Seit dem Stillstand hört er genauer hin."],
        ["archive","Miras offenes Archiv",Vector2(6840,5780),"archive","Papierkarten, Herkunftsnachweise und eine freie Zeile für jede spätere Korrektur."],
        ["notice","Nachbarschaftsbrett",Vector2(8720,6600),"notice","Gesuche, Aussagen und Nachrichten gehören den Menschen des Viertels."],
        ["repair","Rafis Reparaturmarkt",Vector2(10350,9240),"repair","Ein Werkzeugwagen und ein kleiner Tisch bringen alten Dingen neue Aufgaben."],
        ["freight","Frachtfenster am Hafen",Vector2(12600,5780),"freight","Nova hält die Lieferliste lesbar, auch wenn das große Register ausfällt."],
        ["harbor_signal","Unabhängiger Hafenleser",Vector2(12900,6730),"signal","Ein alter Landanschluss trägt einen Auftrag ohne Absender."],
        ["shelter","Doras Wartehaus",Vector2(15300,4680),"shelter","Glasdach, warme Bank und ein Platz für die Menschen der Nachtschicht."],
        ["relay_city","Eddas Stadtverteiler",Vector2(18220,6780),"relay","Die Nachbarschaft besitzt hier ihren eigenen kleinen Strom- und Leserkreis."]]:
        var p: Dictionary=g.CityLife.place(item[0],item[1],item[2],item[3],item[4]);p.new126=true;result.append(p)
    return result
