extends RefCounted
## Authored proximity discoveries, never mandatory for the campaign.
const QUESTS: Array = [
    {
        "id": "bell",
        "title": "Der Ton, der fehlt",
        "desc": "Uhrmacher Ivo hört die Bahnhofsglocke nur noch halb.",
        "steps": [
            {
                "at": "clock",
                "title": "Ivos fehlenden Ton hören",
                "text": "Ivo hat ein neues Klangmodul eingesetzt. Ein tiefer Ton fehlt seit der Registerstörung. Du hilfst ohne den Zeitgeber zu verändern.",
                "kind": "talk"
            },
            {
                "at": "repair",
                "title": "Ein passendes Modul holen",
                "text": "Rafi hat ein älteres Ersatzmodul mit mechanischer Rückmeldung. Ivo hat genau dieses Modell auf seiner Zeichnung markiert.",
                "kind": "talk"
            },
            {
                "at": "clock",
                "title": "Das Klangmodul abstimmen",
                "text": "Stimme die vier Klangkanäle aufeinander ab. Der Zeitgeber bleibt unangetastet.",
                "kind": "frequency"
            },
            {
                "at": "clock",
                "title": "Ivo die Glocke zurückgeben",
                "text": "Die Glocke schlägt wieder vollständig. Ivo behält beide Module und schreibt die Reparatur auf Papier.",
                "kind": "talk"
            }
        ],
        "chapter": 0,
        "reward": 90
    },
    {
        "id": "soup",
        "title": "Ein Topf für die Nachtschicht",
        "desc": "Dora möchte der Hafenschicht ein warmes Essen bringen.",
        "steps": [
            {
                "at": "shelter",
                "title": "Doras Bestellung entgegennehmen",
                "text": "Dora hat sechs Portionen Suppe bezahlt. Nelas Kräuter fehlen, dann geht es zum Frachtfenster.",
                "kind": "talk"
            },
            {
                "at": "flowers",
                "title": "Die Kräuter für die Suppe holen",
                "text": "Nela hat die essbaren Kräuter getrennt von den Zierpflanzen bereitgestellt.",
                "kind": "talk"
            },
            {
                "at": "freight",
                "title": "Die Suppe an die Nachtschicht bringen",
                "text": "Die Schicht macht gemeinsam Pause. Eine Kollegin schreibt Doras Namen in ihr Dankesbuch.",
                "kind": "talk"
            }
        ],
        "chapter": 0,
        "reward": 90
    },
    {
        "id": "lantern",
        "title": "Licht am Lesefenster",
        "desc": "Lina braucht eine kleine Reparatur für die Abendlesung.",
        "steps": [
            {
                "at": "books",
                "title": "Linas Leselicht prüfen",
                "text": "Die Lampe flackert. Lina möchte die Lesung trotzdem halten, wenn du die Ersatzleitung prüfen kannst.",
                "kind": "talk"
            },
            {
                "at": "repair",
                "title": "Rafis Ersatzleitung holen",
                "text": "Rafi gibt dir eine geprüfte Leitung. Das beschädigte Stück soll zum Wiederverwendungsstand.",
                "kind": "talk"
            },
            {
                "at": "books",
                "title": "Die Lampe verbinden",
                "text": "Verbinde das kleine sichere Ersatznetz.",
                "kind": "wire"
            },
            {
                "at": "recycling",
                "title": "Die alte Leitung abgeben",
                "text": "Der Stand sortiert die Leitung für eine spätere Reparatur. Im Lesefenster geht warmes Licht an.",
                "kind": "talk"
            }
        ],
        "chapter": 0,
        "reward": 90
    },
    {
        "id": "paperboats",
        "title": "Boote für die stille Bucht",
        "desc": "Ada sucht eine ungiftige Idee für das Kinderfest.",
        "steps": [
            {
                "at": "atelier",
                "title": "Adas Papierboote ansehen",
                "text": "Ada möchte die Boote in einer flachen Wanne treiben lassen. Die echte Uferbucht bleibt sauber.",
                "kind": "talk"
            },
            {
                "at": "library",
                "title": "Eine Faltanleitung finden",
                "text": "Im Tauschregal liegt eine Anleitung mit breitem Boden. Sie eignet sich für die kleine Wanne.",
                "kind": "talk"
            },
            {
                "at": "mural",
                "title": "Das Muster für die Boote wählen",
                "text": "Ada braucht leicht faltbares, unbeschichtetes Papier. Was passt?",
                "kind": "deduce",
                "choices": [
                    "Unbeschichtetes Papier",
                    "Ölige Folie",
                    "Schwere Holzplatten"
                ],
                "answer": 0,
                "hint": "Die Anleitung verlangt leichtes, unbeschichtetes Papier."
            },
            {
                "at": "atelier",
                "title": "Die Wanne fürs Fest aufstellen",
                "text": "Die Boote treiben im geschlossenen Becken. Nach dem Fest kommt das Papier ins Recycling.",
                "kind": "talk"
            }
        ],
        "chapter": 0,
        "reward": 90
    },
    {
        "id": "lostkeys",
        "title": "Ein Schlüssel und zwei Erinnerungen",
        "desc": "Ein Schlüsselbund liegt am Nachbarschaftsbrett.",
        "steps": [
            {
                "at": "notice",
                "title": "Den gefundenen Schlüssel ansehen",
                "text": "Am Band hängt ein kleiner blauer Mond. Noor hat einen Aushang mit genau diesem Zeichen geschrieben.",
                "kind": "talk"
            },
            {
                "at": "repair",
                "title": "Noors Aushang vergleichen",
                "text": "Rafi hat den vollständigen Aushang. Noor beschreibt einen blauen Mond und zwei gleich lange Schlüssel.",
                "kind": "talk"
            },
            {
                "at": "notice",
                "title": "Den Bund an Noor zurückgeben",
                "text": "Noor zeigt das passende Schlossfoto. Du gibst ihr den Schlüssel, ohne seine Adresse öffentlich zu machen.",
                "kind": "talk"
            }
        ],
        "chapter": 0,
        "reward": 90
    },
    {
        "id": "relayhelp",
        "title": "Ein Notruf ohne Rauschen",
        "desc": "Eine Technikerin möchte den unabhängigen Notrufkanal prüfen.",
        "steps": [
            {
                "at": "relay_city",
                "title": "Edda nach der Störung fragen",
                "text": "Edda braucht einen lokalen Test. Es wird kein echter Notruf ausgelöst, nur die Wartungsfrequenz geprüft.",
                "kind": "talk"
            },
            {
                "at": "antenna",
                "title": "Den Wartungston abhören",
                "text": "Die Antenne meldet vier ungleiche Kanäle. Edda hat eine Zielkurve hinterlegt.",
                "kind": "scan"
            },
            {
                "at": "relay_city",
                "title": "Den Ersatzkanal abstimmen",
                "text": "Stimme die Wartungskanäle auf die Zielkurve ab.",
                "kind": "frequency"
            },
            {
                "at": "relay_city",
                "title": "Den geprüften Kanal dokumentieren",
                "text": "Edda legt den Test ins lokale Protokoll. Die Stadt hat nun einen unabhängigen Wartungsnachweis.",
                "kind": "talk"
            }
        ],
        "chapter": 1,
        "reward": 90
    },
    {
        "id": "nightmarket",
        "title": "Ein Tisch für den Nachtmarkt",
        "desc": "Rafi hat einen Platz für einen kleinen Reparaturmarkt reserviert.",
        "steps": [
            {
                "at": "repair",
                "title": "Den Reparaturmarkt vorbereiten",
                "text": "Ein Markt braucht Helfer, einen Tisch und Licht. Du übernimmst die zwei fehlenden Zusagen.",
                "kind": "talk"
            },
            {
                "at": "kiosk",
                "title": "Emils Tisch ausleihen",
                "text": "Emil leiht den klappbaren Zeitungstisch. Er freut sich über eine Rückgabe nach dem Markt.",
                "kind": "talk"
            },
            {
                "at": "stage",
                "title": "Jo um Licht bitten",
                "text": "Jo stellt eine geprüfte Lichterkette bereit. Rafi unterschreibt die Leihnotiz.",
                "kind": "talk"
            },
            {
                "at": "repair",
                "title": "Den Markt eröffnen",
                "text": "Auf dem Tisch liegen reparierbare Radios und Werkzeuge. Der kleine Markt wird Teil des Viertels.",
                "kind": "talk"
            }
        ],
        "chapter": 2,
        "reward": 120
    },
    {
        "id": "orchardnote",
        "title": "Ein Baum mit Geschichte",
        "desc": "Levin hat an der Obstwiese einen verwitterten Namen gefunden.",
        "steps": [
            {
                "at": "orchard",
                "title": "Die Baumnotiz lesen",
                "text": "Die Tafel erinnert an eine gemeinsame Pflanzung. Ein Name ist verwittert; der Hofladen bewahrt eine Kopie.",
                "kind": "talk"
            },
            {
                "at": "farm_stall",
                "title": "Die Kopie am Hofladen prüfen",
                "text": "Ari findet den Namen und das Pflanzdatum. Die Quelle steht auf der Rückseite.",
                "kind": "talk"
            },
            {
                "at": "orchard",
                "title": "Die Tafel behutsam ergänzen",
                "text": "Du ergänzt Name und Quelle auf einer abnehmbaren Karte. Spätere Korrekturen bleiben möglich.",
                "kind": "talk"
            }
        ],
        "chapter": 4,
        "reward": 90
    },
    {
        "id": "rangerbattery",
        "title": "Eine Lampe am Waldweg",
        "desc": "Sana sucht Hilfe für eine schwache Wegleuchte.",
        "steps": [
            {
                "at": "ranger",
                "title": "Sanas Wegleuchte prüfen",
                "text": "Die Leuchte am Rastplatz benutzt einen austauschbaren Akku. Die alte Leitung kann weiter genutzt werden.",
                "kind": "talk"
            },
            {
                "at": "pine_camp",
                "title": "Den Ersatzakku im Camp abholen",
                "text": "Das Camp hat einen geladenen Akku bereitgestellt. Die defekte Batterie geht zurück zur Rangerstation.",
                "kind": "talk"
            },
            {
                "at": "trailhead",
                "title": "Die Leuchte neu verbinden",
                "text": "Schließe den sicheren Kreis zur Wegleuchte.",
                "kind": "wire"
            },
            {
                "at": "ranger",
                "title": "Sana den alten Akku bringen",
                "text": "Sana übernimmt die fachgerechte Wiederverwendung. Das Licht am Rastplatz bleibt an.",
                "kind": "talk"
            }
        ],
        "chapter": 5,
        "reward": 90
    },
    {
        "id": "millmusic",
        "title": "Musik hinter dem Heidekamm",
        "desc": "Tessa möchte Mühlenau beim Stadtfest hörbar machen.",
        "steps": [
            {
                "at": "village_board",
                "title": "Tessas kleinen Mitschnitt abholen",
                "text": "Im Dorf haben sechs Menschen ein Lied aufgenommen. Alle haben der Übertragung zugestimmt.",
                "kind": "talk"
            },
            {
                "at": "mill_box",
                "title": "Das Übertragungsgerät abstimmen",
                "text": "Stimme die Kanäle des Dorfgeräts auf den Landring ab.",
                "kind": "frequency"
            },
            {
                "at": "records",
                "title": "Sam die Aufnahme übergeben",
                "text": "Sam nennt die Urheber und den Aufnahmeort. Das Dorf bleibt im Stadtprogramm hörbar.",
                "kind": "talk"
            }
        ],
        "chapter": 7,
        "reward": 150
    },
    {
        "id": "observations",
        "title": "Ein Himmel, zwei Standpunkte",
        "desc": "Aven möchte eine alte Wetterbeobachtung ergänzen.",
        "steps": [
            {
                "at": "echo_station",
                "title": "Avens Beobachtungsblatt abholen",
                "text": "Die Warte vergleicht den Himmel von Station und Kamm. Für beide Messungen gibt es denselben Prüfpunkt.",
                "kind": "talk"
            },
            {
                "at": "echo_view",
                "title": "Das Kammsignal messen",
                "text": "Du liest das lokale Messsignal. Ein anderer Blickwinkel verändert die Reflexion, nicht die Quelle.",
                "kind": "scan"
            },
            {
                "at": "echo_station",
                "title": "Die Messung mit Aven vergleichen",
                "text": "Aven legt beide Beobachtungen nebeneinander. Sie sind verschieden, aber miteinander vereinbar.",
                "kind": "talk"
            }
        ],
        "chapter": 8,
        "reward": 160
    },
    {
        "id": "thankyou",
        "title": "Briefe nach einem langen Weg",
        "desc": "Mira möchte den Menschen hinter dem Netz danken.",
        "steps": [
            {
                "at": "archive",
                "title": "Miras Dankeskarten mitnehmen",
                "text": "Mira hat Karten für Jo, Sana und Tessa geschrieben. Jede nennt etwas Konkretes, das die Person beigetragen hat.",
                "kind": "talk"
            },
            {
                "at": "stage",
                "title": "Jos Dankeskarte übergeben",
                "text": "Jo legt die Karte zwischen seine Noten. Die kleinen Stimmen des Viertels bleiben bei der Musik.",
                "kind": "talk"
            },
            {
                "at": "ranger",
                "title": "Sanas Dankeskarte übergeben",
                "text": "Sana steckt die Karte neben ihren Fahrplan. Die Menschen, nicht nur die Messgeräte, gehören zur Region.",
                "kind": "talk"
            },
            {
                "at": "village_board",
                "title": "Tessas Dankeskarte übergeben",
                "text": "Tessa hängt die Karte ans Dorfbrett. Ein weiter Weg ist zu einer Verbindung zwischen Orten geworden.",
                "kind": "talk"
            }
        ],
        "chapter": 11,
        "reward": 210
    }
]
