# Selfware Protocol Demo

Sprache: [English](README.md) | [中文](README.zh-CN.md) | [Italiano](README.it.md) | [日本語](README.ja.md) | [Français](README.fr.md) | **Deutsch**

Dieses Repository ist die Demo-Version des **Selfware Protocols** und stellt Protokollentwurfs-Templates in Chinesisch und Englisch bereit.

## Aktueller Inhalt

- `template.self/selfware-zh.md`: Protokollentwurf (chinesische Ausgabe)
- `template.self/selfware.md`: Protokollentwurf (englische Ausgabe)

Aktuelle Protokollversion: `v0.1.0 (Draft)`

## Was ist Selfware

Selfware will ein einheitliches Dateiprotokoll für das Agent-Zeitalter definieren:

- A file is an app. Everything is a file.
- Daten, Logik und Views können optional in einer verteilbaren Einheit gebündelt werden (Einzeldatei oder `.self`-Container).
- Zusammenarbeit ist dezentral über Mensch↔Agent- und Agent↔Agent-Workflows.

## Kernprinzipien (Kurzfassung)

- **Canonical Data Authority**: jede Instanz muss eine Quelle der Wahrheit festlegen.
- **Write Scope Boundary**: Schreibvorgaenge sollten auf `content/` (oder einen gleichwertig deklarierten kanonischen Bereich) begrenzt sein.
- **No Silent Apply**: Updates dürfen nicht ohne Offenlegung und Bestätigung des Nutzers angewendet werden.
- **View as Function**: `View = f(Data, Intent, Rules)`; Views sind nicht die Wahrheitsquelle.

## Verwendung

Für einen schnellen Einstieg kannst du diese Demo ausprobieren: `https://github.com/awesome-selfware/openoffice.self`

1. Chinesischen Entwurf lesen: `template.self/selfware-zh.md`
2. Englischen Entwurf lesen: `template.self/selfware.md`
3. Daraus eine eigene Instanz-Protokolldatei erstellen und Runtime-Module nach Bedarf erweitern (API, Packaging, Kollaboration, Memory, Discovery usw.).

## Hinweise zum Repository

- Dieses Repository enthält derzeit nur Protokoll-Template-Dokumente.
- Eine vollständige Runtime/Server-Implementierung ist nicht enthalten.

## Lizenz

Im Protokolltext ist eine optionale MIT-Lizenz angegeben (Details in den Protokolldateien).

