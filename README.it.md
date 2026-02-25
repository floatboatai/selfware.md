# Demo del Protocollo Selfware

Lingua: [English](README.md) | [中文](README.zh-CN.md) | **Italiano** | [日本語](README.ja.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

Questo repository è la versione demo del **Protocollo Selfware** e fornisce modelli di protocollo in cinese e inglese.

## Contenuto Attuale

- `template.self/selfware-zh.md`: bozza del protocollo (edizione cinese)
- `template.self/selfware.md`: bozza del protocollo (edizione inglese)

Versione attuale del protocollo: `v0.1.0 (Draft)`

## Cos'è Selfware

Selfware mira a definire un protocollo di file unificato per l'era degli Agent:

- A file is an app. Everything is a file.
- Dati, logica e viste possono essere opzionalmente uniti in una singola unità distribuibile (file singolo o contenitore `.self`).
- La collaborazione è decentralizzata tra flussi human↔Agent e Agent↔Agent.

## Principi Chiave (Sintesi)

- **Canonical Data Authority**: ogni istanza deve definire una fonte di verità.
- **Write Scope Boundary**: le scritture devono essere limitate a `content/` (o a un ambito canonico equivalente dichiarato).
- **No Silent Apply**: gli aggiornamenti non devono essere applicati senza informare l'utente e ottenere conferma.
- **View as Function**: `View = f(Data, Intent, Rules)`; le viste non sono la fonte di verità.

## Come Usare

Per una prova rapida, puoi usare questa demo: `https://github.com/awesome-selfware/openoffice.self`

1. Leggi la bozza cinese: `template.self/selfware-zh.md`
2. Leggi la bozza inglese: `template.self/selfware.md`
3. Crea il tuo file protocollo di istanza da questi modelli ed estendi i moduli runtime secondo necessità (API, packaging, collaborazione, Memory, Discovery, ecc.).

## Note sul Repository

- Questo repository contiene attualmente solo documenti template del protocollo.
- Non include un'implementazione completa runtime/server.

## Licenza

Il testo del protocollo dichiara una licenza MIT opzionale (vedi i file del protocollo per i dettagli).

