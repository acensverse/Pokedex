# Upstream data sources for the auto-update pipeline

Phase 0 research (2026-10-28). Goal: keep the Champions Pokédex, Speed Tiers,
and legal-item data in sync with Pokémon Champions **without app/code changes**
— a CI job regenerates the JSON seeds, the app downloads them at runtime.

## Candidate sources evaluated

| Source | Verdict | Blocking issue |
| --- | --- | --- |
| champsmeta.com | ❌ as automated upstream | Vercel Security Checkpoint blocks non-browser clients (verified via curl: JS challenge page). No external data API — a `/species` page load fetches only `/_next/static` chunks, `/api/auth/session`, and `_vercel/insights/view`. All data lives in same-domain Next.js/RSC payloads. |
| pokemon-zone.com | ❌ as automated upstream | Cloudflare error 1010 ("banned browser signature") even for `/robots.txt`. Moot anyway: speed tiers are pure formulas over base Speed (verified against all 347 site rows), so the site is a cross-check, not a source. |
| projectpokemon/champout | ✅ **chosen primary** | None. GitHub raw URLs are robot-friendly. MIT license. |

## champout (github.com/projectpokemon/champout)

Datamine dumps from the actual game (Nintendo Switch), maintained by
projectpokemon (PKHeX team ecosystem). Updated 2026-09-09 for game v1.2.0 —
the same version our baked data matches. `masterdata/` updates without game
patches, which is exactly what changes when the roster/regulation changes.

### Layout

- `masterdata/personal.json` (291 KB) — one entry per **form** (396 entries,
  231 species): `no` (dex), `fo` (form index), stats `hp/atk/def/spatk/spdef/agi`,
  `type1`/`type2` (mainline type enum, see below), `toku0/1/2` (ability ids),
  `is_valid` (all 1), `reg_no` (324×`1`, 38×`2`, 34×`3` — semantics unclear,
  likely regulation/patch of introduction; not needed by the app),
  label refs `ms_name_lbl` (`MONSNAME_003`) and `ms_form_lbl`
  (`ZKN_FORM_003_000`).
- `masterdata/waza.json` (427 KB) — 920 moves: type/category/power/accuracy/pp/
  priority/`available`, label `WAZANAME_xxx`.
- `masterdata/item.json` (62 KB) — 166 items, label `ITEMNAME_xxx`.
- `masterdata/waza_learn.json` (107 KB) — learnsets.
- `parse/personal_dump.txt` — human-readable per-form dump: `NNNN - Name`,
  stats line, types, abilities, full learnset. **Contains the Z-megas**
  (`0359 - Absol-Mega Z`). Its ability-name table is slightly stale (prints
  raw ids for brand-new Champion abilities); the rom-txt labels are complete.
- `parse/species_with_move.txt` — move → learner list.
- `rom-txt/<lang>/*.json` — Unity text tables: `{mSDataSet: [{LabelName,
  TextInfos[0].Text}]}`. English in `rom-txt/usa/`: `monsname_syn.json`,
  `zkn_form_syn.json`, `wazaname.json`, `itemname.json`, `tokusei.json`
  (abilities, incl. `TOKUSEI_312 => Dragonize`, `TOKUSEI_315 => Mega Sol`),
  `tokuseiinfo_syn.json` / `wazainfo_syn.json` / `iteminfo_syn.json`
  (descriptions).

### Conventions decoded

- **Type ids** in `personal.json` follow the mainline enum
  (0 Normal, 1 Fighting, 2 Flying, 3 Poison, 4 Ground, 5 Rock, 6 Bug, 7 Ghost,
  8 Steel, 9 Fire, 10 Water, 11 Grass, 12 Electric, 13 Psychic, 14 Ice,
  15 Dragon, 16 Dark, 17 Fairy). Verified: Venusaur `11/3` = Grass/Poison.
  (The `typename.json` *label indexes* are offset by one from ids ≥ 9 — do not
  use them for id mapping; hardcode the enum.)
- **Ability ids** are the standard national ability numbering (Venusaur
  `65/65/34` = Overgrow/Overgrow/Chlorophyll); resolve names via
  `TOKUSEI_<id padded to 3>` labels. Dedupe repeated slots
  (`Thick Fat/Thick Fat/Thick Fat` → one ability).
- `id` = dex×1000 + form index (`0003000` = Venusaur base).

## Validation against our baked data

`tool`-level comparison of champout (396 forms) vs the champsmeta extract
(`research/data/champsmeta-species.json`, 346 forms), matching per dex on a
stats+types signature:

- **334/346 exact matches** (stats, types, ability sets all agree).
- 6 more match on stats with cosmetic type/ability-slot differences
  (Pyroar, Heliolisk, Indeedee ×2, Arboliva — duplicate-slot listing).
- champout is a **strict superset**: it additionally has Castform
  Sunny/Rainy/Snowy, Aegislash-Blade, Squawkabilly-Blue, and correct data
  where champsmeta is wrong or missing:
  - **Mega Baxcalibur**: champsmeta claimed 145/92/75/86 atk/def/spA/spD; the
    game data (and our `pokedex_seed.json`, which was right all along) says
    **175/117/105/101**.
  - **Patrat (dex 504) does not exist in the game data at all** — champsmeta
    lists it; champout has no dex-504 entry. champsmeta error.
- Items: champout's 166 items ⊂ champsmeta's 200; the 34 extras are
  Tickets/Coupons (consumables, not held items). Using champout's item table
  makes the app's legal-held-item list strictly more correct.

## Architecture decision

```
champout (GitHub raw, robot-friendly, MIT)
   │  nightly GitHub Actions job (schedule + manual dispatch)
   ▼
tool/build_champions_from_champout.js
   │  champions roster  → assets/champions_seed.json (id/dex/name from seed)
   │  base Speed × formulas → assets/speed_tiers.json
   ▼  fail-loud validation vs pokedex_seed.json (unknown form = build error)
commit + publish bundle (GitHub Pages / repo raw)
   ▼
app: manifest check on launch → download → validate → cache override
providers prefer override over baked asset; offline ⇒ baked data, always safe
```

- champout decides **which forms** are Champions; `pokedex_seed.json` stays the
  identity/display authority (ids, names, sprites, flavors). A new game patch
  that adds forms will fail the build until the seed learns the new rows —
  deliberate: a human adds seed rows once, after which everything flows again.
- Speed tiers are **derived** (Level-50 formulas verified against all 347
  pokemon-zone rows), so no second upstream is needed.
- champsmeta / pokemon-zone remain manual cross-checks (browser extraction into
  `research/data/`) when investigating discrepancies — not part of the pipeline.

## Legal items

`item.json` (166) is the complete held-item table. The champsmeta-derived
baked list (200) additionally contained 34 Tickets/Coupons which are not held
items; the champout build drops them (documented improvement).

## Runbook

- Rebuild locally: `node tool/build_champions_from_champout.js`
  (downloads to `research/cache/champout/`, so repeats are offline).
- Force a refresh in CI: Actions → update-data → Run workflow.
- The workflow commits regenerated assets only when they actually changed, and
  the run fails loudly on any unmapped form or stat disagreement.
