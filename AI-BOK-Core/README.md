# AI-BOK Core 1.5

Open data export of the AI Body of Knowledge (www.ai-bok.nl): 103 concepts with stable identifiers and 124 RACI assignments.

| File | Content |
|---|---|
| `aibok-core.jsonld` | All concepts as SKOS (JSON-LD), with relations between them |
| `knowledge-areas.csv`, `roles.csv`, `governance-bodies.csv`, `lifecycle-phases.csv`, `maturity-levels.csv`, `mvg.csv`, `failure-modes.csv`, `cognition-plane-constructs.csv`, `metamodel-entities.csv` | One table per object type |
| `raci.csv` | Canonical RACI grid (22 roles x 13 knowledge areas), as in Module 2 |
| `fm-crosswalk.csv` | Failure modes to OWASP (Agentic Top 10 2026, LLM Top 10 2026) and MAST |

## Identifiers

Every object has a URN of the form `urn:aibok:<code>`: `urn:aibok:KA9` (knowledge area 9; KG9 in the Dutch edition), `urn:aibok:R18` (role 18), `urn:aibok:FM23`, `urn:aibok:MVG4`, `urn:aibok:L3`, `urn:aibok:P5`, `urn:aibok:AISystem`. An identifier is never reused. When an object is withdrawn it keeps its URN and gets status `deprecated`. Use the URN as the key when you link your own register, risk log or ArchiMate model to the AI-BOK.

## Licence

The data in this folder is licensed under CC BY 4.0: you may reuse and adapt it, including commercially, with attribution "AI Body of Knowledge (www.ai-bok.nl)". The book itself is not covered by this licence.

## Generation

Generated from the SemanticXL reference pack and the book sources by `export-aibok-core.py`. Do not edit by hand.
