# Klangraum

Offline-Android-App mit live erzeugten Klanglandschaften (Web Audio, keine
Audiodateien). Reine Web-App in einer Datei, die per
[apk-builder](../apk-builder) zur APK wird. Ebenen, Prüfumfang, Grenzen und
Datenmodell stehen in [README.md](README.md), Versionen in
[CHANGELOG.md](CHANGELOG.md).

## Build & Test

Kein Bundler, kein Build-Step. Testserver `klangraum` aus der
Workspace-`.claude/launch.json` (Port 8180), dann
`http://localhost:8180/web/`. `?debug=1` führt den Selbsttest aus (Konsole
und Zeile auf der Startseite, auch per `await krTests()`; asynchron, weil er
Klang ohne Lautsprecher rendert). Er muss komplett `OK` zeigen.

Im Browser-Pane von Claude Code läuft auch der echte `AudioContext`
(`E.ac.state === 'running'` nach Klick auf Start). Hören kann Claude ihn
nicht: Klangqualität beurteilt nur Daniel am Gerät.

APK bauen, **immer über den eigenen Wrapper** (baut die Brücke `KrAndroid`
ein: `android-src/ScreenBridge.java`):

```powershell
cd "D:\claude code projects\klangraum"
.\build.ps1 -VersionName "1.1" -VersionCode 2 -Release   # signiert -> dist\klangraum-<v>.apk
```

Der Wrapper ruft `new-app.ps1` bewusst ohne `-KeepScreenOn` auf: Das Display
bleibt nur an, während Klang läuft (`setKeepScreenOn` über die Brücke).

## Konventionen

- Alles in `web/index.html`, kein Framework, kein Netzwerk, keine
  Audiodateien, keine Pakete.
- Jede Ebene ist ein Eintrag in `LAYERS` mit `def` (Vorgaben) und
  `build(ac, out, p, ctx)` und muss auch auf einem `OfflineAudioContext`
  laufen. Zeitgesteuerte Ebenen (Regen, Glocken) planen ihre Ereignisse in
  `tick(now)` voraus.
- Neue Ebene oder neuer Regler: in `LAYERS`, `ORDER`, `layerControls` und
  ggf. `PRESETS` ergänzen. `normLayers` füllt gespeicherte Mischungen mit
  neuen Reglern auf, eine Migration ist dafür nicht nötig.
- Pegel nach dem Selbsttest abstimmen: Jede Mischung muss unter 0,99 Spitze
  bleiben, ohne dass die Begrenzung am Ausgang ständig arbeitet.
- Kein `confirm()`/`alert()`: eigene Dialoge über `openModal`.

## Aktueller Stand

v1.0 (code 1, 2026-11-15): sechs Ebenen, fünf Mischungen, eigene
Mischungen, Timer, Nachtbildschirm. Selbsttest 26/26; Start, Stopp,
Zuschalten einer Ebene und Timer im Browser geprüft. Signierte APK
`dist/klangraum-1.0.apk`.

**Am Gerät noch nichts getestet und noch von niemandem gehört.** Offen:

1. Klingt es gut? Erwartbar sind Nachbesserungen an Pegeln und Klangfarben
   (Regen und Wellen sind die heikelsten).
2. Knackt oder stottert die Wiedergabe im WebView (Regen erzeugt viele
   kurze Klangquellen pro Sekunde)?
3. Läuft der Klang bei ausgeschaltetem Display oder im Hintergrund weiter?
   Wenn nicht und Daniel das braucht: Vordergrunddienst im Wrapper ergänzen.
4. Nachtbildschirm: Helligkeit und Display-an über die Brücke.

Geplante Aufbauten aus der Ideenliste: Flow-Timer (Fokus-Blöcke mit
Soundscape) und Herzschlag-Musik (Tempo aus der Puls-Kamera des
Körper-Labors).

v1.1 (code 2, 2026-11-15): Binaurale Beats auf Daniels Wunsch ausgebaut
(`beatAt`, Regler mit echtem Wertebereich über `slider(..., rng)`): freie
Schwebung 0,5–40 Hz, Grundton 100–400 Hz, Verlauf zu einem Zielwert in 10,
20 oder 30 Minuten; neue Mischung "Einschlafen". Selbsttest 30/30, im
Browser geprüft. Daniel hat Kopfhörer. Signierte APK
`dist/klangraum-1.1.apk`; am Gerät weiterhin nichts getestet und gehört.

v1.2 (code 3, 2026-11-16): Atem-Dirigent auf Daniels Wunsch (`breathTracker`,
`pacerRate`, `dirigentSummary`, Zustand `D`, Ansicht `atem`). Nutzt den
Bewegungssensor, der auf dem Pixel im WebView nachweislich läuft
(Körper-Labor). Im Browser mit `DeviceMotionEvent`s aus der Konsole testbar:
`S.dirigent.min` klein setzen und per Intervall eine Sinusbewegung auf x
einspeisen. Selbsttest 36/36. Am Körper noch nicht ausprobiert. APK
`dist/klangraum-1.2.apk`.
