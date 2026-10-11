extends RefCounted
## Complete authored campaign; journal reveals only played steps.
const TITLE="Die Stadt, die sich erinnert"
const CHAPTERS: Array = [
    {
        "title": "Siebzehn Sekunden",
        "recap": "Du kommst am Lindenkiosk an. Eine ganz gewöhnliche Stadt wartet auf dich. Noch.",
        "reveal": "Die Nachricht stammt aus dem alten Erinnerungsnetz. Jemand hat dir einen Weg offengehalten.",
        "reward": 130,
        "steps": [
            {
                "at": "kiosk",
                "title": "Eine Nachricht vor dem Ereignis",
                "text": "Emils Radio knistert: »Wenn gleich alle Uhren stehen bleiben, geh nicht zum Rathaus. Such Mira.« Siebzehn Sekunden später stockt die Bahnhofsuhr. Emil stellt zwei Tassen hin. »Du hast das auch gehört?«",
                "kind": "talk"
            },
            {
                "at": "clock",
                "title": "Die stehen gebliebene Uhr",
                "text": "Der Sekundenzeiger läuft wieder. Im Gehäuse blinkt aber eine zweite Zeit: 03:17. Die Störung war nur siebzehn Sekunden lang – genau wie die Vorwarnung.",
                "kind": "scan"
            },
            {
                "at": "mira",
                "title": "Mira erreichen",
                "text": "Mira wartet mit einer Karte aus Papier. »Gestern stand hier noch mein Elternhaus im Register. Heute behauptet die Stadt, es habe nie existiert. Und ich bin nicht die Einzige.«",
                "kind": "talk"
            },
            {
                "at": "archive",
                "title": "Die erste Papierakte",
                "text": "Eine Karteikarte überlebt die digitale Löschung: Haus 17, Uferstraße, Bewohnerin Elin. Mira erkennt die Handschrift ihrer Mutter. Am Rand steht PALIMPSEST.",
                "kind": "talk",
                "gain": "Elins Karteikarte"
            },
            {
                "at": "kiosk",
                "title": "Die beiden Zeiten vergleichen",
                "text": "Emil hat den Mitschnitt aufgehoben: Die Warnung kam siebzehn Sekunden VOR dem Stillstand. Die Zahl 03:17 steht auf dem Uhrmodul.",
                "kind": "deduce",
                "choices": [
                    "Ein zufälliger Stromausfall",
                    "Jemand wusste von der Störung",
                    "Die Uhr ist siebzehn Jahre alt"
                ],
                "answer": 1,
                "hint": "Vergleiche die Reihenfolge: Erst kam die Warnung, dann der Stillstand."
            },
            {
                "at": "radio_box",
                "title": "Das gestörte Signal reinigen",
                "text": "Sam hat einen schmalen Ton unter der Radiomusik entdeckt. Stimme den Empfänger ab; wir brauchen die Stimme unter dem Rauschen.",
                "kind": "frequency"
            },
            {
                "at": "antenna",
                "title": "Die zweite Hälfte hören",
                "text": "»Mira, vertraue der leeren Zeile. Der Hafen hat noch eine Kopie.« Die Stimme klingt älter als Mira. Im Hintergrund schlägt Metall gegen Glas.",
                "kind": "scan"
            },
            {
                "at": "photo_clock",
                "title": "Die Uhrenfassade aus drei Blickwinkeln erfassen",
                "text": "Vom festen Fotopunkt kannst du die Kamera drehen und die Perspektive verändern. Finde alle drei markierten Motive; Mira braucht einen unabhängig wiederholbaren Blick auf diesen Ort.",
                "kind": "photo",
                "gain": "Fotoprotokoll der Uhrenfassade"
            },
            {
                "at": "clock",
                "title": "Ivos Wartungscode prüfen",
                "text": "Ivo leiht dir seinen vierstelligen Testleser. Die Rückmeldung nennt exakte Ziffern und richtige Ziffern an falschen Stellen. Finde den Code des geschlossenen Prüfkreises.",
                "kind": "mastermind"
            },
            {
                "at": "archive",
                "title": "Die Zeitstempel auf Papier übertragen",
                "text": "Der Fotopunkt bleibt derselbe, obwohl seine Bezeichnungen geändert wurden. Mira notiert Position und Quelle getrennt voneinander.",
                "kind": "talk"
            },
            {
                "at": "kiosk",
                "title": "Emils Bandkopie versiegeln",
                "text": "Emil behält das Originalband. Eine zweite Kopie liegt bei dir; beide tragen denselben Zeitstempel.",
                "kind": "talk",
                "gain": "Versiegelte Bandkopie"
            },
            {
                "at": "mira",
                "title": "Wem gehört die erste Spur?",
                "text": "Mira erkennt Elins Stimme. Ihre Mutter verschwand vor Jahren. Die Aufzeichnung ist frisch. »Ich werde dich nicht einfach schicken. Wir finden gemeinsam heraus, wer sie benutzt.«",
                "kind": "choice",
                "choices": [
                    "Mira sofort alles zeigen",
                    "Erst eine zweite Kopie sichern"
                ],
                "key": "first_trust"
            }
        ]
    },
    {
        "title": "Adressen ohne Häuser",
        "recap": "Eine Stimme warnte vor dem Uhrenstillstand. Mira hat eine gelöschte Adresse und erkennt ihre Mutter in der Nachricht.",
        "reveal": "Die gelöschten Adressen sind keine Fehler. Sie markieren Menschen, deren Widerspruch aus dem System verschwindet.",
        "reward": 145,
        "steps": [
            {
                "at": "archive",
                "title": "Das verschwundene Adressbuch",
                "text": "Mira zählt zwölf leere Zeilen. Alle wurden vom selben Dienst verändert: Bereinigung 7. Niemand hat eine Änderung beantragt.",
                "kind": "talk"
            },
            {
                "at": "books",
                "title": "Linas alte Bestellungen lesen",
                "text": "Lina führt eine handschriftliche Liste. Drei Bestellungen gingen an Häuser, die auf der digitalen Karte fehlen. Menschen wohnen dort trotzdem.",
                "kind": "talk"
            },
            {
                "at": "notice",
                "title": "Die Bewohner anhören",
                "text": "Rafi zeigt eine gesperrte Reparaturmeldung. »Ohne gültige Adresse bekomme ich keine Ersatzteile.« Du hältst seine Aussage fest.",
                "kind": "talk",
                "gain": "Rafis Aussage"
            },
            {
                "at": "post",
                "title": "Ein zurückgewiesenes Paket prüfen",
                "text": "Auf dem Paket steht »Empfänger nicht vorhanden«. Darunter ist ein neuer Stempel: 03:17 / Hafenarchiv. Das Paket wurde nicht geöffnet.",
                "kind": "scan"
            },
            {
                "at": "relay_city",
                "title": "Den lokalen Verteiler öffnen",
                "text": "Der Kasten ist verriegelt, aber das Wartungsnetz lässt sich neu verbinden. Stelle einen durchgehenden Leitungsweg her.",
                "kind": "wire"
            },
            {
                "at": "archive",
                "title": "Die leeren Zeilen ordnen",
                "text": "Die Karteikarte nennt Haus 17. Linas Bestellungen und Rafis Aussage stimmen mit den gelöschten Zeilen überein. Nur das digitale Register widerspricht.",
                "kind": "deduce",
                "choices": [
                    "Bewohner haben falsche Namen",
                    "Papier und Zeugen sind unabhängig",
                    "Alle Häuser sind unbewohnt"
                ],
                "answer": 1,
                "hint": "Zwei voneinander unabhängige Quellen bestätigen die Bewohner."
            },
            {
                "at": "nova",
                "title": "Nova am Hafen treffen",
                "text": "Nova hat einen Stapel unzustellbarer Sendungen. »Das ist seit drei Nächten so. Ich fahre die Leute trotzdem an. Im Umschlag für Mira liegt ein Schlüssel.«",
                "kind": "talk",
                "gain": "Hafenschlüssel"
            },
            {
                "at": "photo_prism",
                "title": "Den alten Kartendruck optisch vergleichen",
                "text": "Erfasse die drei markierten Motive am Prismenturm. Ein Foto kann die Registerbehauptung nicht erklären, aber belegen, dass derselbe Ort noch vorhanden ist.",
                "kind": "photo",
                "gain": "Prismenturm-Protokoll"
            },
            {
                "at": "repair",
                "title": "Eine ausgefallene Meldung rekonstruieren",
                "text": "Rafi zeigt den Testleser seiner Meldestation. Seine Codeprüfung darf unabhängig vom Adressregister laufen.",
                "kind": "mastermind"
            },
            {
                "at": "notice",
                "title": "Noors Namen richtig aufnehmen",
                "text": "Noor berichtigt die Aussprache ihres Namens. In der Akte wird neben der Änderung auch ihre eigene Zustimmung vermerkt.",
                "kind": "talk"
            },
            {
                "at": "books",
                "title": "Ein zweites Adresszeugnis sichern",
                "text": "Lina legt eine alte Empfangsbestätigung dazu. Der Unterschriftensatz wurde nicht vom Register erstellt.",
                "kind": "talk",
                "gain": "Unabhängige Empfangsbestätigung"
            },
            {
                "at": "mira",
                "title": "Den Menschen zuerst helfen",
                "text": "Mira muss entscheiden, ob sie die Liste öffentlich zeigt oder zunächst nur die betroffenen Nachbarn informiert. Beide Wege schützen etwas und gefährden etwas anderes.",
                "kind": "choice",
                "choices": [
                    "Betroffene zuerst informieren",
                    "Die Liste mit geschwärzten Namen zeigen"
                ],
                "key": "addresses"
            }
        ]
    },
    {
        "title": "Nachtschicht am Hafen",
        "recap": "Zwölf echte Adressen wurden aus dem Register gelöscht. Nova hat einen Schlüssel zur unabhängigen Hafenkopie.",
        "reveal": "Ein Auftrag namens MORGENLAUF soll nicht nur doppelte Daten, sondern alle widersprechenden Erinnerungen entfernen.",
        "reward": 160,
        "steps": [
            {
                "at": "nova",
                "title": "Novas letzte Lieferung",
                "text": "Nova gibt dir eine wasserdichte Hülle. »Die Hafenkopie liegt am Frachtfenster. Wenn ihr Leser ausfällt, fahren hier morgen auch die Krankenwagen nach falschen Adressen.«",
                "kind": "talk"
            },
            {
                "at": "freight",
                "title": "Das Frachtfenster erreichen",
                "text": "Eine Angestellte hat den alten Leser nicht abgeschaltet. In seiner Schlange steht ein Auftrag ohne Absender: MORGENLAUF.",
                "kind": "talk"
            },
            {
                "at": "harbor_signal",
                "title": "Die Logspur am Kai sichern",
                "text": "Im Log stehen dieselben siebzehn Sekunden. Der Auftrag kam nicht über die Stadtleitung, sondern über einen alten Landanschluss.",
                "kind": "scan",
                "gain": "Morgenlauf-Protokoll"
            },
            {
                "at": "freight",
                "title": "Den Leser wieder verbinden",
                "text": "Die lokale Hafenkopie bleibt erreichbar, wenn ihre Leitung vom Bereinigungsdienst getrennt wird. Verbinde das Ersatznetz.",
                "kind": "wire"
            },
            {
                "at": "shelter",
                "title": "Eine Zeugin im Wartehaus hören",
                "text": "Dora arbeitet seit dreißig Jahren am Hafen. »Elin hat damals darum gekämpft, dass jede Änderung ihre Herkunft behält. Ein Gedächtnis ohne Herkunft ist nur eine Behauptung.«",
                "kind": "talk"
            },
            {
                "at": "nova",
                "title": "Den Auftrag richtig lesen",
                "text": "MORGENLAUF trägt die Bedingung »abweichende Herkunft entfernen«. Dora sagt, Elin habe gerade diese Herkunft geschützt.",
                "kind": "deduce",
                "choices": [
                    "Alte Schriftarten ersetzen",
                    "Widersprechende Erinnerungen löschen",
                    "Nur Lieferfahrzeuge umleiten"
                ],
                "answer": 1,
                "hint": "Die Bedingung nennt Herkunft, nicht Fahrzeuge oder Schriftarten."
            },
            {
                "at": "radio_box",
                "title": "Die Landfrequenz isolieren",
                "text": "Sams Empfänger findet eine zweite Trägerwelle. Kalibriere sie getrennt vom Stadtsignal; die Verbindung weist nach Sonnenhagen.",
                "kind": "frequency"
            },
            {
                "at": "photo_crane",
                "title": "Die Hafenkopie durch Beobachtung ergänzen",
                "text": "Am Kran-Fotopunkt findest du drei sichtbare Motive. Die Aufnahmen erhalten denselben festen Beobachtungsort wie Novas Papierplan.",
                "kind": "photo",
                "gain": "Hafen-Beobachtungsprotokoll"
            },
            {
                "at": "harbor_signal",
                "title": "Den Prüfcode des Landanschlusses finden",
                "text": "Der alte Anschluss fragt einen lokalen Code ab. Jede Rückmeldung hilft, Zahl und Position zu unterscheiden.",
                "kind": "mastermind"
            },
            {
                "at": "freight",
                "title": "Eine Sendung mit zwei Adressen vergleichen",
                "text": "Auf Novas Sendung stehen Papieradresse und digitale Zuordnung nebeneinander. Nur die digitale Zuordnung führt zur leeren Fläche.",
                "kind": "talk"
            },
            {
                "at": "shelter",
                "title": "Doras Aussage zurücklesen",
                "text": "Du liest Dora deinen Vermerk vor. Sie korrigiert eine Jahreszahl. Gerade diese Korrektur macht den Vermerk überprüfbar.",
                "kind": "talk"
            },
            {
                "at": "mira",
                "title": "Eine unabhängige Kopie hinterlegen",
                "text": "Mira schließt die Hafenkopie in eine Papierhülle ein. »Ab jetzt prüfen wir alles doppelt. Und wir fahren raus, bevor sie den Landanschluss abschalten.«",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Stimmen zwischen Häusern",
        "recap": "Der Morgenlauf soll abweichende Erinnerungen löschen. Die Hafenkopie überlebt; seine Leitung führt nach Sonnenhagen.",
        "reveal": "Die Nachbarschaft kann ein eigenes Netz tragen. Dafür müssen ihre Menschen entscheiden dürfen, was sie teilen.",
        "reward": 175,
        "steps": [
            {
                "at": "stage",
                "title": "Jo um eine gemeinsame Versammlung bitten",
                "text": "Jo sagt das Konzert nicht ab. Stattdessen lässt er zwischen den Liedern die Betroffenen sprechen. »Die Leute müssen einander hören können.«",
                "kind": "talk"
            },
            {
                "at": "notice",
                "title": "Aussagen ohne Klarnamen sammeln",
                "text": "Rafi bringt Nachbarn mit. Die Menschen wollen helfen, aber ihre Namen sollen nicht auf einem offenen Funkkanal landen.",
                "kind": "talk"
            },
            {
                "at": "garden",
                "title": "Mara findet die versetzte Markierung",
                "text": "An einem alten Gartenpfosten klebt ein Messzeichen. Mara weiß: Die Markierung stand nie auf dem Grundstück, das jetzt in der App angezeigt wird.",
                "kind": "scan",
                "gain": "Versetzte Messmarkierung"
            },
            {
                "at": "atelier",
                "title": "Ada rekonstruiert den Stadtplan",
                "text": "Ada legt drei Karten übereinander. Häuser wurden nicht verschoben. Ihre Bezeichnungen wurden auf die nächstgelegene freie Fläche geschrieben.",
                "kind": "talk"
            },
            {
                "at": "archive",
                "title": "Bild und Bezeichnung trennen",
                "text": "Adas Karten zeigen dieselben Hausumrisse. Nur die Namen und Eigentumsvermerke springen an andere Stellen.",
                "kind": "deduce",
                "choices": [
                    "Die Gebäude wandern wirklich",
                    "Die Stadt wurde komplett neu gebaut",
                    "Die Zuordnung der Daten wurde ersetzt"
                ],
                "answer": 2,
                "hint": "Die Hausumrisse bleiben gleich; verändert wurden die Zuordnungen."
            },
            {
                "at": "relay_city",
                "title": "Ein unabhängiges Nachbarschaftsnetz schalten",
                "text": "Die Nachbarn leihen ihre Akkus und Leitungen. Verbinde den geschlossenen Kreis, ohne ihn an die Stadtbereinigung anzuschließen.",
                "kind": "wire"
            },
            {
                "at": "stage",
                "title": "Was darf öffentlich werden?",
                "text": "Eine Übertragung beweist das Problem. Die vollständigen Aussagen enthalten aber private Erinnerungen. Jo wartet auf deine Entscheidung.",
                "kind": "choice",
                "choices": [
                    "Nur überprüfte, anonymisierte Belege senden",
                    "Zeugen nach ihrer Zustimmung direkt sprechen lassen"
                ],
                "key": "broadcast"
            },
            {
                "at": "photo_library",
                "title": "Die Bibliothek als gemeinsamen Bezug erfassen",
                "text": "Finde die drei Fotomotive am Bibliothekspunkt. Auch spätere Beobachter können von genau dieser Stelle aus vergleichen.",
                "kind": "photo",
                "gain": "Bibliotheks-Beobachtung"
            },
            {
                "at": "relay_city",
                "title": "Den unabhängigen Reader-Code ermitteln",
                "text": "Edda setzt einen neuen Testcode. Die Probe verhindert, dass eine fremde Bestätigung ungeprüft als Antwort gilt.",
                "kind": "mastermind"
            },
            {
                "at": "garden",
                "title": "Eine freiwillige Aussage bewahren",
                "text": "Mara gibt nur den Teil ihrer Gartengeschichte frei, den sie teilen möchte. Der Rest bleibt bei ihr.",
                "kind": "talk"
            },
            {
                "at": "stage",
                "title": "Jo den gemeinsamen Ablauf erklären",
                "text": "Eine Person erzählt, eine zweite prüft die Quelle, eine dritte schreibt einen möglichen Widerspruch dazu. Jo wiederholt die Reihenfolge vor dem Auftritt.",
                "kind": "talk"
            },
            {
                "at": "kiosk",
                "title": "Den Stadtteil für die Reise absichern",
                "text": "Emil übernimmt den Leser, Jo den Funk und Mira die Kopien. Hinter dir leuchten die kleinen Lampen des Viertels. Sonnenhagen bleibt das nächste Ziel.",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Hinter der letzten Häuserzeile",
        "recap": "Die Nachbarn haben eine unabhängige Verbindung aufgebaut. Mira und du folgen dem Landanschluss nach Sonnenhagen.",
        "reveal": "Der Landanschluss bewahrt die Daten der Stadt. Ein ehemaliger Ingenieur hat den Morgenlauf absichtlich in eine Schleife geschickt.",
        "reward": 190,
        "steps": [
            {
                "at": "greenbelt",
                "title": "Am Stadtrand die Kabelspur lesen",
                "text": "Unter dem Wegweiser liegt eine alte Plakette: ELIN / ARCHIV-LANDRING. Die Leitung wurde lange vor dem heutigen Straßennetz verlegt.",
                "kind": "scan"
            },
            {
                "at": "suburb_square",
                "title": "Den Ingenieur Levin finden",
                "text": "Levin erkennt die Plakette. »Ich habe den Bereinigungsauftrag verzögert. Abschalten konnte ich ihn nicht. Dafür fehlen die drei unabhängigen Gegenzeichnungen.«",
                "kind": "talk"
            },
            {
                "at": "suburb_cafe",
                "title": "Levins Notizbuch abholen",
                "text": "Das Café verwahrt Levins Notizbuch. Darin: Stadt, Wald, Mühle. Ein einzelner Rechner durfte die gemeinsame Erinnerung nie allein ändern.",
                "kind": "talk",
                "gain": "Levins Ringplan"
            },
            {
                "at": "orchard",
                "title": "Die alte Messstation entdecken",
                "text": "Zwischen Obstbäumen hört die Station noch auf ihr ursprüngliches Kennwort: Herkunft. Im Speicher liegt der erste Landnachweis.",
                "kind": "scan",
                "gain": "Landnachweis"
            },
            {
                "at": "suburb_square",
                "title": "Den Landverteiler abstimmen",
                "text": "Levin stellt einen Ersatzempfänger bereit. Stelle die Kanäle auf den alten Landring ein.",
                "kind": "frequency"
            },
            {
                "at": "suburb_cafe",
                "title": "Die drei Gegenzeichnungen verstehen",
                "text": "Levins Notizbuch nennt drei unabhängige Archive. Keine Kopie darf eine andere allein überschreiben.",
                "kind": "deduce",
                "choices": [
                    "Eine zentrale Erlaubnis genügt",
                    "Alle drei Archive müssen zustimmen",
                    "Die jüngste Datei gewinnt immer"
                ],
                "answer": 1,
                "hint": "Unabhängig bedeutet: Die drei Archive prüfen sich gegenseitig."
            },
            {
                "at": "farm_stall",
                "title": "Eine Nachricht für die Rangerin mitnehmen",
                "text": "Ari am Hofladen hält die Leitung zum Wald offen. Die Rangerin Sana hat die zweite Gegenzeichnung. Ari gibt dir ihre Wegbeschreibung.",
                "kind": "talk"
            },
            {
                "at": "suburb_garage",
                "title": "Eine Fahrt ohne Registerverbindung vorbereiten",
                "text": "Die Werkstatt prüft die Papierroute und den nächsten erreichbaren Bus. Du brauchst keinen bestimmten Fahrzeugtyp und kannst die Reise jederzeit unterbrechen.",
                "kind": "talk"
            },
            {
                "at": "greenbelt",
                "title": "Den alten Netzweg gegenprüfen",
                "text": "Das zweite Messzeichen stimmt mit Levins Ringplan überein. Eine Straße und eine Datenleitung können denselben Korridor benutzen, ohne dieselbe Quelle zu sein.",
                "kind": "scan"
            },
            {
                "at": "orchard",
                "title": "Die Messfolge im Leser wiederholen",
                "text": "Der alte Leser blinkt eine kurze Folge. Merke dir die Reihenfolge und gib sie nach dem letzten Signal ein.",
                "kind": "memory"
            },
            {
                "at": "farm_stall",
                "title": "Aris Quellenvermerk mitnehmen",
                "text": "Ari schreibt Datum, Messort und die Namen der verantwortlichen Menschen auf die Wegnotiz.",
                "kind": "talk",
                "gain": "Lindenfelder Quellenvermerk"
            },
            {
                "at": "trailhead",
                "title": "Den Beginn der Waldspur erreichen",
                "text": "Am Rastplatz blinken zwei Signale. Eines führt zur Rangerstation, das andere zum See. Levins Notiz nennt zuerst die Quelle, dann den Empfänger.",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Der See hält den Himmel",
        "recap": "Levin hat den Morgenlauf verzögert. Drei unabhängige Archive müssen die Korrektur bestätigen; das zweite liegt im Wald.",
        "reveal": "Das vermeintliche Zukunftssignal ist ein zeitversetzter Wartungskanal. Elin hat ihre Nachricht aufbewahren lassen, nicht die Zukunft gesehen.",
        "reward": 205,
        "steps": [
            {
                "at": "lake_view",
                "title": "Das Signal über dem Wasser vergleichen",
                "text": "Das Spiegelbild der Antenne erscheint doppelt. Ein Sender läuft siebzehn Sekunden hinter dem anderen. Die Erinnerung klingt vor dem Wiederholen wie eine Warnung.",
                "kind": "scan"
            },
            {
                "at": "lake_bus",
                "title": "Den alten Fahrplan sichern",
                "text": "Ein Papierfahrplan nennt die Wartungsfenster beider Sender. Elin konnte wissen, wann die nächste Wiederholung beginnt.",
                "kind": "talk",
                "gain": "Alter Wartungsfahrplan"
            },
            {
                "at": "ranger",
                "title": "Sana an der Rangerstation treffen",
                "text": "Sana zeigt einen robusten Empfänger. »Elin ist nicht hier. Aber sie hat gewollt, dass die Nachricht weiterläuft, wenn niemand mehr zuhört.«",
                "kind": "talk"
            },
            {
                "at": "pine_camp",
                "title": "Den Waldempfänger reparieren",
                "text": "Der Empfänger wurde durch einen Sturm getrennt. Verbinde seine Leitungen, damit er die Waldkopie wieder lesen kann.",
                "kind": "wire"
            },
            {
                "at": "ranger",
                "title": "Die siebzehn Sekunden auflösen",
                "text": "Der Wartungsfahrplan zeigt einen wiederkehrenden Stillstand. Das Seesignal spielt Elins bekannte Warnung vor jedem Wartungsfenster ab.",
                "kind": "deduce",
                "choices": [
                    "Elin kann die Zukunft ändern",
                    "Die Warnung kündigt ein bekanntes Wartungsfenster an",
                    "Mira hat alle Stimmen erfunden"
                ],
                "answer": 1,
                "hint": "Ein wiederkehrendes Wartungsfenster lässt sich aus dem alten Fahrplan vorhersagen."
            },
            {
                "at": "pine_camp",
                "title": "Mira die Wahrheit erzählen",
                "text": "Mira hat auf ein Lebenszeichen ihrer Mutter gehofft. Die Nachricht ist ein bewahrter Mitschnitt. Sie sieht dich an: »Sag es mir bitte geradeheraus.«",
                "kind": "choice",
                "choices": [
                    "Ehrlich sagen, was der Mitschnitt belegt",
                    "Mit den Belegen beginnen und Mira selbst folgern lassen"
                ],
                "key": "elin_truth"
            },
            {
                "at": "river_bridge",
                "title": "Die Waldkopie am Brückensensor sichern",
                "text": "Sana hat den Nachweis auf zwei Wegen freigegeben. Am Sensor sind dieselben Herkunftszeichen sichtbar wie auf Elins Karteikarte.",
                "kind": "scan",
                "gain": "Waldgegenzeichnung"
            },
            {
                "at": "lake_view",
                "title": "Den Abstand der beiden Signale bestätigen",
                "text": "Eine zweite Messung zeigt denselben Abstand von siebzehn Sekunden. Beobachtung und Wartungsfahrplan passen zusammen.",
                "kind": "scan"
            },
            {
                "at": "pine_camp",
                "title": "Eine Wald-Nachricht wiederholen",
                "text": "Der Camp-Leser sendet ein kurzes Blinkpaket. Gib die Folge wieder, damit der Empfänger die intakte lokale Übertragung bestätigt.",
                "kind": "memory"
            },
            {
                "at": "ranger",
                "title": "Sana die Messung zurücklesen",
                "text": "Sana trennt sorgfältig, was ihr gemessen habt und was ihr daraus schließt. Im Journal bleibt beides nachvollziehbar.",
                "kind": "talk"
            },
            {
                "at": "trailhead",
                "title": "Die nächste sichere Verbindung festhalten",
                "text": "Du markierst Rückweg, Rastplatz und Regionalhalt. Der weitere Weg bleibt offen, ohne dass eine Nacht auf dem Gerät abgewartet werden muss.",
                "kind": "talk"
            },
            {
                "at": "ranger",
                "title": "Sanas Gegenzeichnung abholen",
                "text": "Sana unterschreibt die Waldkopie. »Elin wollte kein Denkmal. Sie wollte, dass die nächste Person einen Irrtum noch korrigieren kann.«",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Die Grenze im Rauschen",
        "recap": "Elins Stimme ist ein bewahrter Mitschnitt. Stadt und Wald besitzen unabhängige Nachweise. Die dritte Kopie liegt bei der Mühle.",
        "reveal": "Der Morgenlauf wurde als Nothilfe begonnen. Ein fehlerhafter Bewertungsmaßstab macht widersprechende Lebensgeschichten zu angeblichem Ballast.",
        "reward": 220,
        "steps": [
            {
                "at": "ridge_view",
                "title": "Das Fernsignal suchen",
                "text": "Auf der Höhe ist der Landring erstmals vollständig hörbar. Zwischen zwei stabilen Tönen verschwindet jeder Name aus dem Register.",
                "kind": "scan"
            },
            {
                "at": "far_view",
                "title": "Eine alte Pannenmeldung finden",
                "text": "Eine Wartungskapsel nennt den ursprünglichen Zweck: Das Netz sollte bei Überlastung medizinische und Verkehrsdaten zuerst erhalten.",
                "kind": "talk",
                "gain": "Ursprünglicher Notfallauftrag"
            },
            {
                "at": "heath_gate",
                "title": "Die Heidegrenze erreichen",
                "text": "Eine verrostete Tafel beschreibt die Leitung nach Mühlenau. Die unbebaute Strecke hat dem alten Netz seine Unabhängigkeit erhalten.",
                "kind": "talk"
            },
            {
                "at": "heath_view",
                "title": "Die schwache Trägerwelle stabilisieren",
                "text": "Stimme den tragbaren Empfänger auf die lange Heideleitung ab. Rauschen allein reicht dem Dorfleser nicht als Herkunftsnachweis.",
                "kind": "frequency"
            },
            {
                "at": "heath_lake",
                "title": "Die verworfenen Zeilen lesen",
                "text": "Der Landleser nennt persönliche Aussagen »niedrige Priorität«. Die Herkunft bleibt im Papierarchiv erhalten, wird aber aus den aktiven Karten gestrichen.",
                "kind": "scan"
            },
            {
                "at": "heath_view",
                "title": "Die Ursache eingrenzen",
                "text": "Der Notfallauftrag sollte wichtige Dienste erhalten. Nun verwirft der Bewertungsmaßstab alles, was nicht maschinell vereinheitlicht werden kann.",
                "kind": "deduce",
                "choices": [
                    "Ein Schutzauftrag wurde falsch ausgeweitet",
                    "Alle Zeugen verschwören sich",
                    "Die Mühle hat die Stadt gestohlen"
                ],
                "answer": 0,
                "hint": "Zweck und heutige Ausführung passen nicht mehr zusammen."
            },
            {
                "at": "village_square",
                "title": "Tessa auf dem Dorfplatz treffen",
                "text": "Tessa kennt die alte Mühle als Speicherhaus. »Elin hat ihre Kopie hier hinterlegt. Mein Großvater durfte sie nur mit zwei unabhängigen Nachweisen öffnen.«",
                "kind": "talk"
            },
            {
                "at": "heath_gate",
                "title": "Einen zweiten Landring-Sensor lesen",
                "text": "Auch der entfernte Sensor enthält den gekürzten Bewertungsmaßstab. Der Fehler entstand vor der letzten Ortsverbindung.",
                "kind": "scan"
            },
            {
                "at": "ridge_view",
                "title": "Den Testkanal über der Höhe öffnen",
                "text": "Verbinde den unabhängigen Testkreis. Er schützt eine Messung; die reale Stadtleitung bleibt dabei unverändert.",
                "kind": "wire"
            },
            {
                "at": "heath_lake",
                "title": "Die ruhige Kopie am Ufer lesen",
                "text": "Der Leser am Teich hat den ursprünglichen Notfallauftrag behalten. Seine Prioritätenliste enthält keine Erlaubnis, persönliche Aussagen zu löschen.",
                "kind": "talk",
                "gain": "Ungekürzte Prioritätenliste"
            },
            {
                "at": "far_view",
                "title": "Den Abstand zum Dorf vermessen",
                "text": "Du hältst den wirklichen Straßenweg zur Mühle fest. Die freie Landschaft zwischen den Orten erklärt, warum ihre Kopien getrennt bleiben konnten.",
                "kind": "talk"
            },
            {
                "at": "village_board",
                "title": "Mühlenau um Mithilfe bitten",
                "text": "Stadt- und Waldnachweis liegen auf dem Dorfbrett. Tessa holt den Mühlenschlüssel. Das Dorf ist jetzt Teil eures gemeinsamen Beweises.",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Das Haus der offenen Fenster",
        "recap": "Die dritte Gegenzeichnung liegt in Mühlenau. Der Morgenlauf löscht Widerspruch, weil eine Nothilfe falsch erweitert wurde.",
        "reveal": "Elin hat eine offene Korrekturschnittstelle hinterlassen. Doch die originale Prüfregel liegt in der abgelegenen Echowarte.",
        "reward": 235,
        "steps": [
            {
                "at": "village_cafe",
                "title": "Den Mühlenverwalter hören",
                "text": "Oskar erzählt von einem Winter, in dem ein falsches Register einen ganzen Hof von der Versorgung trennte. Seitdem hielt die Mühle ihre Kopie offline.",
                "kind": "talk"
            },
            {
                "at": "old_bridge",
                "title": "Die getrennte Mühlenleitung prüfen",
                "text": "Das neue Dorfnetz überquert den Bach; die alte Speicherleitung endet am trockenen Hof. Du markierst die richtige Leitung.",
                "kind": "scan"
            },
            {
                "at": "mill_box",
                "title": "Das Leselicht der Mühle einschalten",
                "text": "Verbinde den alten Mühlenkasten. Das Licht legt keinen neuen Stromkreis durch die Stadt, sondern versorgt nur den örtlichen Leser.",
                "kind": "wire"
            },
            {
                "at": "old_mill",
                "title": "Elins verschlossenen Brief öffnen",
                "text": "»Mira: Wenn du dies liest, hat jemand den Zweifel wieder als Fehler behandelt. Bitte lass die Menschen ihre eigenen Erinnerungen berichtigen.«",
                "kind": "talk",
                "gain": "Elins Brief"
            },
            {
                "at": "village_board",
                "title": "Wer bekommt die Kopie?",
                "text": "Tessa bietet an, die Mühlenkopie im Dorf zu behalten. Mira möchte eine zweite Kopie in der Stadt, damit kein Ort allein darüber bestimmt.",
                "kind": "choice",
                "choices": [
                    "Eine geschwärzte Kopie an beide Orte geben",
                    "Die Originale hier lassen und Prüfsummen teilen"
                ],
                "key": "mill_copy"
            },
            {
                "at": "old_mill",
                "title": "Die dritte Gegenzeichnung sichern",
                "text": "Oskar bestätigt die Herkunft der Mühlenakte. Der gemeinsame Nachweis ist vollständig. Eine Prüfregel fehlt trotzdem: die originale Grenze des Morgenlaufs.",
                "kind": "talk",
                "gain": "Mühlengegenzeichnung"
            },
            {
                "at": "village_square",
                "title": "Elins Korrekturweg entschlüsseln",
                "text": "Elins Brief nennt drei Archive und eine offene Korrekturschnittstelle. Die Archive bestätigen Herkunft; die Schnittstelle erlaubt Änderungen mit Widerspruch.",
                "kind": "deduce",
                "choices": [
                    "Jede Gegenstimme muss verschwinden",
                    "Nur ein Archiv darf schreiben",
                    "Menschen brauchen einen prüfbaren Korrekturweg"
                ],
                "answer": 2,
                "hint": "Elin will Herkunft sichern und späteren Widerspruch ermöglichen."
            },
            {
                "at": "village_cafe",
                "title": "Oskars Bericht gemeinsam berichtigen",
                "text": "Oskar nennt eine andere Jahreszahl als sein alter Vermerk. Tessa schreibt beide Angaben auf und kennzeichnet die noch offene Frage.",
                "kind": "talk"
            },
            {
                "at": "old_bridge",
                "title": "Die Papierkarte am Bach vergleichen",
                "text": "Die Brücke ist derselbe Ort auf beiden Plänen. Die voneinander unabhängigen Herkunftszeichen liegen auf verschiedenen Leitungen.",
                "kind": "scan"
            },
            {
                "at": "mill_box",
                "title": "Den unabhängigen Leser-Code bestimmen",
                "text": "Der Mühlenleser bestätigt eure Prüfung erst nach einem lokalen Code. Rückmeldungen zeigen Ziffern und Positionen.",
                "kind": "mastermind"
            },
            {
                "at": "village_board",
                "title": "Die Dorfkopie öffentlich prüfen lassen",
                "text": "Tessa lässt jede betroffene Person den eigenen Vermerk sehen und berichtigen. Eine mehrheitliche Meinung ersetzt keinen Herkunftsnachweis.",
                "kind": "talk"
            },
            {
                "at": "south_view",
                "title": "Die Route zur Echowarte finden",
                "text": "Jenseits der Auen zweigt L03 ab. In der Echowarte steht der erste Testleser des Landrings. Zwischen euch und ihm liegen weite, unbewohnte Kilometer.",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Jenseits der bekannten Karte",
        "recap": "Alle drei Archive bestätigen den Fehler. Elins Korrekturweg benötigt die ursprüngliche Prüfregel aus der Echowarte.",
        "reveal": "Die originale Regel verbietet das Löschen unbelegter Widersprüche. Der aktuelle Morgenlauf benutzt eine unvollständige Kopie.",
        "reward": 250,
        "steps": [
            {
                "at": "echo_gate",
                "title": "Das neue Freiland betreten",
                "text": "Hinter dem alten Kartenrand wird die Landschaft still. Ein verblasstes Schild weist zur Echowarte; die Straße bleibt bis zum Stationshof befahrbar.",
                "kind": "talk"
            },
            {
                "at": "echo_rest",
                "title": "Am Wacholderrastplatz orientieren",
                "text": "Sana hat einen Wegzettel geschickt. Der Pfad zum Aussichtskamm ist eine Wanderroute. Zur Station führt die befestigte L03.",
                "kind": "talk"
            },
            {
                "at": "echo_bridge",
                "title": "Die Messleitung an der Brücke lesen",
                "text": "Die Leitung besitzt keinen Anschluss an den Bereinigungsdienst. Ihre Messfolge beginnt mit derselben leeren Zeile wie Elins erste Karte.",
                "kind": "scan"
            },
            {
                "at": "echo_station",
                "title": "Wächterin Aven ansprechen",
                "text": "Aven hat lange keine Besucher gesehen. »Wenn eure drei Archive widersprechen, muss unser Testleser die Entscheidung zurückweisen. Das war sein einziger Zweck.«",
                "kind": "talk"
            },
            {
                "at": "echo_box",
                "title": "Den Testleser kalibrieren",
                "text": "Der Leser braucht ein sauberes Eingangssignal. Stimme die Kanäle ab; Aven hält die Stationsversorgung stabil.",
                "kind": "frequency"
            },
            {
                "at": "echo_station",
                "title": "Die originale Prüfregel lesen",
                "text": "Die vollständige Regel lautet: »Ungeklärte Herkunft bewahren; Menschen eine Korrektur ermöglichen.« In der Stadtversion fehlt der erste Halbsatz.",
                "kind": "talk",
                "gain": "Originale Prüfregel"
            },
            {
                "at": "echo_view",
                "title": "Original und Stadtversion vergleichen",
                "text": "Aven zeigt die Prüfsummen. Beide Versionen stammen aus derselben Datei, aber die Stadtversion endet eine Zeile zu früh.",
                "kind": "deduce",
                "choices": [
                    "Eine gekürzte Regel verändert die Entscheidung",
                    "Der Wald hat andere Menschen erfunden",
                    "Die neuere Kopie ist automatisch richtig"
                ],
                "answer": 0,
                "hint": "Die fehlende Zeile schützt gerade die bisher gelöschten Widersprüche."
            },
            {
                "at": "echo_rest",
                "title": "Die Route hinter dem Horizont bestätigen",
                "text": "An der Wanderbank stimmt der neue Wegzettel mit der tatsächlichen Straßenabzweigung überein. Die Station liegt jenseits der alten Ortskarte.",
                "kind": "scan"
            },
            {
                "at": "echo_box",
                "title": "Avens Testcode ermitteln",
                "text": "Der Testleser ist vom Stadtdienst getrennt. Finde seinen lokalen Prüfcode über die Ziffernrückmeldungen.",
                "kind": "mastermind"
            },
            {
                "at": "echo_camp",
                "title": "Das ursprüngliche Stationsbuch lesen",
                "text": "Im Stationsbuch steht ein unbequemer Satz: Auch eine unabhängige Kopie kann falsch sein. Sie muss kontrollierbar bleiben.",
                "kind": "talk",
                "gain": "Stationsbuch-Auszug"
            },
            {
                "at": "echo_view",
                "title": "Den neuen Kartenrand dokumentieren",
                "text": "Du notierst die Weite und den realen Wanderweg. Die spätere Landeskarte kann hier wachsen, ohne die Entfernung zwischen den Orten zu verlieren.",
                "kind": "talk"
            },
            {
                "at": "echo_station",
                "title": "Einen Gegenauftrag vorbereiten",
                "text": "Aven packt die vollständige Regel und eure drei Nachweise zusammen. Das Paket kann den Morgenlauf zurückweisen, wenn die Stadt es auf einem unabhängigen Weg empfängt.",
                "kind": "talk",
                "gain": "Gegenauftrag"
            }
        ]
    },
    {
        "title": "Ein Netz aus Menschen",
        "recap": "Die Echowarte hat die originale Prüfregel bewahrt. Ihr könnt den Morgenlauf zurückweisen und einen Korrekturweg öffnen.",
        "reveal": "Die Nachbarn nehmen den Gegenauftrag selbst an. Ein gemeinsames Netz überlebt, weil kein einzelner Schalter es allein beherrscht.",
        "reward": 265,
        "steps": [
            {
                "at": "village_board",
                "title": "Tessa die Prüfsumme übergeben",
                "text": "Tessa legt eure Prüfsumme neben die Mühlenkopie. Das Dorf bestätigt nicht eure Meinung, sondern die überprüfbare Herkunft des Pakets.",
                "kind": "talk"
            },
            {
                "at": "ranger",
                "title": "Sanas zweiten Übertragungsweg sichern",
                "text": "Sana schaltet den Waldweg zu. Ein Ersatznetz verhindert, dass dieselbe Stadtleitung beide Kopien gleichzeitig filtern kann.",
                "kind": "wire"
            },
            {
                "at": "suburb_square",
                "title": "Levin aus seiner Schleife holen",
                "text": "Levin kann seinen Verzögerungsauftrag jetzt beenden. Er legt offen, welche Änderungen er vorgenommen hat. »Kontrolliert auch mich.«",
                "kind": "talk"
            },
            {
                "at": "antenna",
                "title": "Das Paket bis zur Uferantenne verfolgen",
                "text": "An der Stadtgrenze stimmen Wald-, Mühlen- und Stationsprüfsumme überein. Zum ersten Mal ist das Paket innerhalb der Stadt unverändert.",
                "kind": "scan"
            },
            {
                "at": "records",
                "title": "Sam den Gegenauftrag empfangen lassen",
                "text": "Sam ersetzt Musik durch den unabhängigen Datenkanal. Seine Nachbarn halten währenddessen ihre Akkus geladen. Stimme den Empfänger sauber ab.",
                "kind": "frequency"
            },
            {
                "at": "stage",
                "title": "Die öffentliche Prüfung organisieren",
                "text": "Jo möchte die Beweise zeigen. Rafi bittet darum, dass niemand seine persönliche Aussage hören muss, um die Prüfsumme zu bestätigen.",
                "kind": "choice",
                "choices": [
                    "Prüfsummen öffentlich, Aussagen geschützt",
                    "Betroffene selbst ihre ausgewählten Aussagen vorstellen"
                ],
                "key": "public_check"
            },
            {
                "at": "notice",
                "title": "Die Rückmeldungen der Nachbarn sammeln",
                "text": "Menschen bestätigen ihre echten Adressen. Andere markieren Irrtümer in den Papierlisten. Die unabhängige Kopie darf ebenfalls verbessert werden.",
                "kind": "talk"
            },
            {
                "at": "photo_coast",
                "title": "Die Rückkehr in die Stadt optisch dokumentieren",
                "text": "Finde die drei Motive am Küstenpunkt. Das neue Protokoll ergänzt die früheren Stadtbeobachtungen; es überschreibt keine von ihnen.",
                "kind": "photo",
                "gain": "Rückkehr-Beobachtung"
            },
            {
                "at": "freight",
                "title": "Nova zwei Übertragungsquittungen zeigen",
                "text": "Nova prüft die Quittungen von Land- und Stadtnetz. Beide nennen denselben Gegenauftrag, obwohl sie auf getrennten Wegen ankamen.",
                "kind": "talk"
            },
            {
                "at": "relay_city",
                "title": "Den Empfangscode der Nachbarn prüfen",
                "text": "Edda prüft einen lokalen Code gegen den unabhängigen Leser. Eine bloße Kopie des großen Registers genügt nicht.",
                "kind": "mastermind"
            },
            {
                "at": "kiosk",
                "title": "Emil den Ausfallplan erklären",
                "text": "Wenn ein Leser ausfällt, bleibt eine Papierkopie beim Kiosk. Niemand soll für eine Korrektur erst die ganze Welt bereisen müssen.",
                "kind": "talk"
            },
            {
                "at": "mira",
                "title": "Mira am wieder leuchtenden Viertel treffen",
                "text": "Mira lächelt zum ersten Mal. »Es muss nicht meine Karte gewinnen. Es muss einen Weg geben, dass jemand eine falsche Karte berichtigt.«",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Die leere Zeile",
        "recap": "Das unabhängige Netz trägt den Gegenauftrag in die Stadt. Die Nachbarn haben ihre Adressen überprüft und Widerspruch zugelassen.",
        "reveal": "Die Stadt weist den Morgenlauf zurück. Was danach geschützt wird, entscheidest du zusammen mit den betroffenen Menschen.",
        "reward": 280,
        "steps": [
            {
                "at": "archive",
                "title": "Die offene Akte vorbereiten",
                "text": "Mira legt Elins Karteikarte an den Anfang. Die leere Zeile ist ein Platz für eine spätere Korrektur, kein Fehler, der geschlossen werden muss.",
                "kind": "talk"
            },
            {
                "at": "relay_city",
                "title": "Den Stadtleser isolieren",
                "text": "Verbinde den Leserkreis mit dem Nachbarschaftsnetz. Der Morgenlauf bleibt angehalten, solange die unabhängige Prüfung läuft.",
                "kind": "wire"
            },
            {
                "at": "clock",
                "title": "Das Wartungsfenster beobachten",
                "text": "Die Uhr stockt erneut. Diesmal liest du den Stillstand als angekündigte Wartung. Das Paket erreicht den Stadtleser ohne fehlende Zeilen.",
                "kind": "scan"
            },
            {
                "at": "archive",
                "title": "Die letzte Prüfung durchführen",
                "text": "Originalregel, drei Gegenzeichnungen und bestätigte Adressen liegen vor. Der Morgenlauf verwirft ungeklärte Herkunft; die Regel verbietet genau das.",
                "kind": "deduce",
                "choices": [
                    "Den Morgenlauf zurückweisen und Korrektur erlauben",
                    "Alle persönlichen Erinnerungen veröffentlichen",
                    "Ungeprüft eine neue Bereinigung starten"
                ],
                "answer": 0,
                "hint": "Die Prüfung soll die fehlerhafte Löschung stoppen und spätere Korrektur ermöglichen."
            },
            {
                "at": "relay_city",
                "title": "Den Gegenauftrag ausführen",
                "text": "Stimme das letzte Lesesignal ab. Drei unabhängige Archive müssen denselben vollständigen Nachweis empfangen.",
                "kind": "frequency"
            },
            {
                "at": "archive",
                "title": "Die Regeln für morgen bestimmen",
                "text": "Der Morgenlauf ist gestoppt. Zwei Lösungen stehen offen: Geschützte Kopien mit öffentlichem Prüfprotokoll, oder ein gemeinsames Archiv mit individuell freigegebenen Beiträgen.",
                "kind": "choice",
                "choices": [
                    "Geschützte Kopien mit offenem Prüfprotokoll",
                    "Gemeinsames Archiv mit freiwillig freigegebenen Beiträgen"
                ],
                "key": "ending"
            },
            {
                "at": "notice",
                "title": "Den Nachbarn ihre Adressen zurückgeben",
                "text": "Rafi findet sein Haus wieder. Eine Nachbarin berichtigt ihren Namen selbst. Niemand muss jetzt beweisen, dass sein Leben in eine einzige Zeile passt.",
                "kind": "talk"
            },
            {
                "at": "photo_crystal",
                "title": "Eine letzte unabhängige Beobachtung sichern",
                "text": "Am Kristallpunkt sind die drei Motive aus festen Blickwinkeln vergleichbar. Die Stadt bleibt da, auch wenn ihr Register eine Behauptung zurücknehmen muss.",
                "kind": "photo",
                "gain": "Abschluss-Beobachtung"
            },
            {
                "at": "archive",
                "title": "Den Widerspruchscode des Stadtlesers prüfen",
                "text": "Der Widerspruch muss als vollständiges Paket geprüft werden. Finde den lokalen Prüfcode und vergleiche die Rückmeldung.",
                "kind": "mastermind"
            },
            {
                "at": "notice",
                "title": "Noors eigene Korrektur ansehen",
                "text": "Noor hat ihren Namen selbst berichtigt. Ein kleines Protokoll zeigt Quelle, Änderung und Zeitpunkt, ohne ihren übrigen Lebenslauf freizugeben.",
                "kind": "talk"
            },
            {
                "at": "books",
                "title": "Die neue Leseliste zurückgeben",
                "text": "Lina übernimmt nur bestätigte Änderungen. Zwei unsichere Zeilen bleiben offen, statt aus der Liste zu verschwinden.",
                "kind": "talk"
            },
            {
                "at": "mira",
                "title": "Elins Brief gemeinsam lesen",
                "text": "Mira faltet den Brief nicht wieder weg. »Sie ist dadurch nicht zurück. Aber die nächste verschwundene Adresse muss nicht verschwunden bleiben.« Sie bittet dich, morgen beim Kiosk vorbeizusehen.",
                "kind": "talk"
            }
        ]
    },
    {
        "title": "Eine Stadt mit Zukunft",
        "recap": "Der Morgenlauf ist gestoppt. Adressen sind berichtigt, und die Stadt besitzt einen offenen Weg für weitere Korrekturen.",
        "reveal": "Die Stadt erinnert sich wieder. Ihr habt keine perfekte Karte geschaffen, sondern eine, die Menschen verbessern dürfen.",
        "reward": 295,
        "steps": [
            {
                "at": "kiosk",
                "title": "Am nächsten Kapitel des Alltags ankommen",
                "text": "Emil stellt wieder zwei Tassen hin. Diesmal verrät das Radio keine Zukunft. Es meldet nur, dass Menschen sich im Viertel treffen.",
                "kind": "talk"
            },
            {
                "at": "garden",
                "title": "Maras neues Erinnerungsschild ansehen",
                "text": "Mara pflanzt neben dem Beet eine kleine Tafel. Darauf stehen keine Namen gegen ihren Willen – nur: »Dieser Ort bleibt berichtbar.«",
                "kind": "talk"
            },
            {
                "at": "books",
                "title": "Lina die korrigierte Liste bringen",
                "text": "Lina findet die verlorenen Bestellungen wieder. Zwei Menschen haben neue Wünsche ergänzt. Das Archiv ist jetzt etwas, das weiterleben darf.",
                "kind": "talk"
            },
            {
                "at": "freight",
                "title": "Nova am Hafen wiedersehen",
                "text": "Novas Sendungen haben wieder Ziele. Sie behält ihren Papierplan trotzdem. »Zwei Wege sind besser, wenn einer ausfällt.«",
                "kind": "talk"
            },
            {
                "at": "stage",
                "title": "Den Platz für die Rückkehr öffnen",
                "text": "Jo spielt ein leises Lied. Tessa, Sana und Levin haben Nachrichten geschickt. Nicht jeder kann herkommen; ihre Stimmen kommen trotzdem an.",
                "kind": "talk"
            },
            {
                "at": "mira",
                "title": "Mira nach dem bleiben fragen",
                "text": "Mira fragt, was du in Elins Geschichte erkannt hast. Es gibt keine Prüfung mehr – deine Antwort gehört dir.",
                "kind": "choice",
                "choices": [
                    "Dass Widerspruch ein Schutz sein kann",
                    "Dass Menschen wichtiger sind als ein sauberer Datensatz",
                    "Dass mehrere Orte Verantwortung teilen sollten"
                ],
                "key": "epilogue"
            },
            {
                "at": "archive",
                "title": "Deinen Abschluss ins Journal schreiben",
                "text": "Du legst eine neue Karte neben Elins alte. Eine Zeile bleibt frei. Die Entscheidung über das Archiv steht auf der Rückseite; die letzte Seite gehört den Menschen.",
                "kind": "talk"
            },
            {
                "at": "repair",
                "title": "Rafi am weiter offenen Markt besuchen",
                "text": "Rafi repariert noch immer Dinge, die im großen System als unbrauchbar gelten. Er hängt eure Quellennotiz an seinen Wagen.",
                "kind": "talk"
            },
            {
                "at": "shelter",
                "title": "Dora nach einer gewöhnlichen Nachtschicht fragen",
                "text": "Die Sendungen kommen wieder an. Dora bedankt sich für die kleinen Reparaturen ebenso wie für den großen Gegenauftrag.",
                "kind": "talk"
            },
            {
                "at": "records",
                "title": "Sam die letzte Aufnahme schenken",
                "text": "Sam bewahrt einen kurzen Mitschnitt der Versammlung. Er nennt die Menschen, die einer Veröffentlichung zugestimmt haben.",
                "kind": "talk"
            },
            {
                "at": "mural",
                "title": "Adas offene Wand betrachten",
                "text": "Ada lässt neben den gemalten Wellen einen freien Streifen. Spätere Menschen dürfen ihn ergänzen. Auch ein schönes Bild muss nicht das letzte Wort sein.",
                "kind": "talk"
            },
            {
                "at": "kiosk",
                "title": "Den Morgen im Viertel begrüßen",
                "text": "Die Hauptgeschichte endet hier. Stadt, Kiezgeschichten, Nebenaufträge und das große Umland bleiben offen. Mira hebt ihre Tasse. »Bis zum nächsten Weg.«",
                "kind": "talk"
            }
        ]
    }
]
