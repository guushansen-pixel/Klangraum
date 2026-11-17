# Klangraum

Offline-Android-App: Klanglandschaften zum Einschlafen, Konzentrieren und
Meditieren, die das Handy im Moment des Abspielens selbst berechnet (Web
Audio). Es gibt keine einzige Audiodatei, und nichts wiederholt sich.

APK: [dist/klangraum-1.2.apk](dist/klangraum-1.2.apk) (v1.2; die APK für v1.3 ist noch nicht gebaut)

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
und ihre Regler), `own` (eigene Mischungen `[{name, layers}]`), `schema`,
`dirigent`, seit v1.3 `flow` (`fokus`, `pause`, `runden`, `mix`, `pauseMix`,
`log: [{d, min}]`), `puls` (`bpm`, `modus`, `ziel`, `min`) und `maler`
(`teppich`). Mischungen im Flow-Timer sind über den Namen verwiesen
(`b:Fokus`, `o:Eigene`); gibt es sie nicht mehr, gilt wieder „Fokus".

## Flow-Timer

Fokus-Blöcke mit Klang (Startseite → *Flow-Timer*): Fokus 15 bis 90 min,
Pause 3 bis 15 min, 1 bis 4 Runden. Im Fokus läuft eine fertige oder eigene
Mischung, in der Pause Stille oder eine andere Mischung. Jeder Abschnitt
blendet in 3 s ein und in 8 s aus; ein Gong markiert den Wechsel (einmal =
Pause, zweimal = weiter, dreimal = fertig). Gezählt werden nur
Fokus-Minuten, die letzten 40 Sitzungen bleiben gespeichert.

Der Timer rechnet mit der Uhrzeit, nicht mit Intervallen, und läuft, solange
die Ansicht offen ist (Display bleibt an). Verlassen der Ansicht beendet
ihn. Die Mischung der Startseite bleibt unberührt (`E.over`).

## Herzschlag-Musik

Ein weicher Doppelschlag (lub-dub) im eingestellten Tempo, darüber eine
zufällige Melodie in kleinen Schritten der Pentatonik und ein leiser
Liegeklang, alles in der Tonart des Klangteppichs. Das Tempo kommt vom
Mittippen des eigenen Pulses (`tapBpm`: Median der letzten bis zu acht
Abstände, ab vier Tippern, 35–200 gültig) oder vom Regler (40–140).
Zwei Arten: Tempo halten, oder in den ersten 70 % der Dauer gleichmäßig zu
einem Ziel (50–65) hinunter.

**Die App misst den Puls nicht.** Die ursprüngliche Idee (Tempo aus der
Puls-Kamera des Körper-Labors) bräuchte Kamerazugriff im WebView und eine
Brücke; das ist nicht gebaut. Ob ruhiger werdende Musik den Puls mitnimmt,
ist plausibel, aber nicht gesichert, und die App sagt das auch.

## Klangmaler

Eine Fläche als Instrument: links–rechts elf Töne der Dur-Pentatonik über
zwei Oktaven (`MALER`), oben–unten Filter von 4800 bis 400 Hz, bis zu vier
Finger zugleich, Echo. Kippen nach links/rechts verschiebt das Stereobild
(`tiltPan`), das obere Ende anheben gibt mehr Echo (`tiltEcho`). Auf Wunsch
liegt der Klangteppich darunter. Der Klangmaler stoppt eine laufende
Mischung nicht, man malt darüber.

Die Kipp-Richtungen sind nach der Android-Konvention gerechnet, am Gerät
aber ungeprüft; sind sie vertauscht, das Vorzeichen in `tiltPan` drehen.

## Atem-Dirigent

Eigener Modus, erreichbar von der Startseite: Das Handy liegt auf dem Bauch,
der Atem steuert den Klang.

- **Atem erfassen** (`breathTracker`): je Achse des Bewegungssensors ein
  schneller (0,6 s) minus ein langsamer (20 s) gleitender Mittelwert; die
  Achse mit der stärksten Bewegung wird auf etwa −1 bis 1 normiert. Ein
  Atemzug ist ein Durchgang von unten nach oben mit Hysterese; die
  Atemfrequenz kommt aus den letzten bis zu vier Atemzügen.
- **Klang:** Braunes Rauschen, dessen Lautstärke und Filter dem Atemsignal
  folgen (Brandung im eigenen Takt).
- **Leitton:** ein leiser Akkord, der einen Atemzug pro Minute langsamer
  an- und abschwillt als gemessen, aber nie unter dem gewählten Ziel (6, 5
  oder 4,5 pro Minute; abschaltbar mit "nur folgen").
- **Ende:** Dauer 5 bis 20 Minuten, letzte Minute wird leiser; danach
  Atemfrequenz am Anfang und am Ende (erstes und letztes Drittel der
  Messwerte), die letzten 20 Sitzungen werden gespeichert.

Geprüft mit künstlicher Bauchbewegung im Selbsttest (6 und 12 pro Minute
werden auf unter einen Zug genau erkannt, ein ruhig liegendes Handy ergibt
keinen Atem). Am Körper ungeprüft: ob das Signal des Pixel auf dem Bauch
reicht und ob der Klang beim Liegen angenehm ist.
