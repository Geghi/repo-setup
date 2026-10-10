# Evidenze nella PR

Ogni PR porta la prova che il cambio funziona. Chi la legge non testa a mano.
L'agente sceglie il livello, al massimo tre prove, proporzionali al cambio.

## Come si avvia e si testa

- Avvio in locale: `{{DEV_COMMAND}}`
- Unit: `{{UNIT_COMMAND}}`
- Integrazione: `{{INTEGRATION_COMMAND}}`
- E2E: `{{E2E_COMMAND}}` (se non esiste, dillo: niente comandi inventati)

## Quanto testare — i tre livelli

### Livello 0 — una riga, testo, config

Il nome del test rosso→verde e cosa verifica, in una riga.

### Livello 1 — logica o endpoint

Livello 0 + un esempio reale: {{LEVEL1_PROOF}}
(es. richiesta/risposta vera, ritorno di un tool, prima/dopo).

### Livello 2 — feature visibile o udibile

Livello 1 + {{LEVEL2_PROOF}} del percorso principale ({{MAIN_PATH}}),
allegato alla PR con `gh pr edit <numero> --attach <file>` (png/jpg/gif/webp/mp4/mov/webm).

## Nella PR

Sezione `## Evidence`: livello scelto, comandi lanciati, prova. Nient'altro.
Per produrre l'evidenza lancia solo i test che servono a produrla, non
l'intera suite.
