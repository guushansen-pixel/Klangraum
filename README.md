# Klangraum

Offline-Android-App: Klanglandschaften zum Einschlafen, Konzentrieren und
Meditieren, die das Handy im Moment des Abspielens selbst berechnet (Web
Audio). Es gibt keine einzige Audiodatei, und nichts wiederholt sich.

APK: [dist/klangraum-1.1.apk](dist/klangraum-1.1.apk)

## Ebenen

Sechs Ebenen, einzeln schaltbar und mischbar:

| Ebene | Wie sie entsteht | Regler |
|---|---|---|
| Rauschen | 6-Sekunden-Schleife (weiß, rosa nach Kellet, braun durch Aufsummieren), an der Naht überblendet, Tiefpass | Farbe, dumpf–hell |
| Regen | rosa Rauschen über Hochpass plus einzelne Tropfen: kurze, zufällig gefilterte Rauschstöße, zufällig im Stereobild | Niesel–Schauer |
| Wellen | braunes Rauschen, Lautstärke und Filter von zwei langsamen Schwingungen mit ungleichen Perioden bewegt | langsam–schnell |
| Klangteppich | vier Oszillatoren (Grundton, leicht verstimmt, Quinte, Oktave) hinter einem langsam atmenden Filter | Grundton C/D/E/G/A, dunkel–hell |
| Glocken | Sinustöne aus der Dur-Pentatonik zwei Oktaven über dem Grundton, zufällige Abstände, Echo | selten–oft |
| Binaurale Beats | Grundton links, Grundton plus Schwebung rechts | Schwebung 0,5–40 Hz (Schnellwahl 2, 6, 10, 16, 40), Grundton 100–400 Hz, Verlauf: Schwebung gleitet in 10, 20 oder 30 Minuten zu einem Zielwert |

Dazu: sechs fertige Mischungen (Schlaf, Regen, Fokus, Meditation, Meer,
Einschlafen mit gleitender Schwebung von 10 auf 2 Hz),
eigene Mischungen speichern, Gesamtlautstärke, Einschlaf-Timer (15 bis 90
Minuten, letzte Minute wird leiser), Nachtbildschirm (schwarz, dunkelste
Helligkeit).

Am Ausgang sitzt ein Kompressor und dahinter eine weiche Begrenzung bei
0,98, damit auch alle Ebenen auf voller Lautstärke nicht übersteuern.

## Was geprüft ist

Der Selbsttest (`?debug=1`) rendert jede Ebene, jede Mischung und alle
Ebenen zusammen vier Sekunden lang ohne Lautsprecher
(`OfflineAudioContext`) und prüft: hörbarer Pegel, keine Übersteuerung,
keine ungültigen Werte, bei den binauralen Beats unterschiedliche Kanäle.
Dazu die Eigenschaften der drei Rauschfarben und die Naht der Schleife.

**Nicht geprüft ist, wie es klingt.** Die Ebenen sind nach Zahlen
abgestimmt, kein Mensch hat sie bisher gehört.

## Grenzen

- Der Klang läuft, solange die App im Vordergrund ist; dafür bleibt das
  Display an (Nachtbildschirm). Ob er bei ausgeschaltetem Display oder in
  einer anderen App weiterläuft, ist ungeprüft. Sicher ginge das nur mit
  einem Android-Vordergrunddienst, den die App nicht hat.
- Binaurale Beats brauchen Kopfhörer; die Studienlage zu ihrer Wirkung ist
  dünn und uneinheitlich.

## Datenmodell (localStorage)

`klangraum.settings.v1`: `vol`, `timerMin`, `layers` (je Ebene `on`, `vol`
und ihre Regler), `own` (eigene Mischungen `[{name, layers}]`), `schema`.
