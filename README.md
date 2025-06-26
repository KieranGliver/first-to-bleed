# One King is Enough – Clone Design Document

**Genre:** Tile-painting Roguelike Deckbuilder  
**Overview:**  
Players face off in competitive, real-time rounds by deploying units ("Plebs") and buildings to control territory on a shared grid. Victory comes through strategic placement, deck optimization, and area control over multiple days.

---

## Game Theory Highlights

- As players claim more territory, maintaining control becomes more difficult due to spreading resources and fewer collision interactions with buildings.
- Balancing offense, defense, and resource generation is key to long-term success.

---

## Game Loop & Progression

### Player Setup

- Choose a **Class** (TBD): Grants unique passive or active abilities.
- Start with **3 lives**.
- Achieve **5 total victories** to win:
  - 1st place = +1 Victory  
  - 2nd place = +0.5 Victory  
  - 3rd place = -0.5 Life  
  - 4th place = -1 Life

### Day Cycle

- **Dawn – Shop Phase:**  
  - Earn **Bucks** based on income.  
  - Spend Bucks to buy or reroll cards.

- **Day – Battle Phase:**  
  - Real-time 4-player FFA match.

- **Evening – Reward Phase:**  
  - Gain one free card.

---

## Battle Rules

- **Start:**
  - Map spawns with player HQs and 4 starting Plebs.  
  - Player hand is drawn; cards may be placed before starting the round.

- **Gameplay:**
  - 4-player FFA (1v1v1v1).
  - Rounds start at **2 minutes**, increasing by 30s per round (capped at **6 minutes**).
  - **Real-time** play with time control:
    - `Space` – Pause  
    - `1–4` – Speed tiers (4 = unlimited)

- **Victory:**
  - Ranked by **tile count** at round end.

---

## Core Mechanics

### Plebs

- Move in straight lines until:
  - Hitting a building or another faction's Pleb = bounce.
- **Bounce Behavior:**
  - Redirects Pleb in a non-blocked direction.
  - Some Plebs have bounce direction preferences.

### Tiles

- **Neutral tile hit:**
  - Becomes claimed by Pleb’s faction.
  - Grants **Ducats**.
  - Pleb bounces.

- **Claimed tile hit:**
  - Becomes neutral.
  - Pleb bounces.

---

## Buildings

### Placement

- Only on owned tiles.
- Cost **Ducats**, and possibly **Wood** or **Stone**.

### Health

- All buildings have base HP.

### Activation Types

- **On Touch** – When a Pleb bounces on it.
- **On Placement** – Triggers on deployment.
- **Passive** – Periodic effect over time.
- **On Attack** – When hit by an enemy Pleb.

### Effect Examples

- Grant resources  
- Spawn additional Plebs  
- Upgrade nearby structures  
- Fire projectiles  
- Redirect or move Plebs  
- Target enemy Plebs  
- Influence any game mechanic

### Building Types

- **Income** – Boosts resource generation  
- **Attack** – Damages enemy tiles/buildings  
- **Defense** – Protects territory  
- **Enhancer** – Upgrades nearby buildings  
- **Resource** – Spawns gatherable resources  
- **Directional** – Alters Pleb pathing

---

## Resources

| Type     | Use                              | Gained From                              |
|----------|-----------------------------------|-------------------------------------------|
| **Bucks**  | Shop purchases                     | Start of each round, based on income      |
| **Ducats** | Placing cards (buildings)         | - Buildings<br>- Plebs hitting gold or neutral tiles |
| **Wood**   | Placing specific building cards   | Plebs hitting **trees**                  |
| **Stone**  | Placing specific building cards   | Plebs hitting **rocks/stones**           |

---

## Deck & Store

### Deck

- Represents player’s building options during battles.
- Each card = one building.
- Starts with a base number of cards (TBD).

### Store (Dawn Phase)

- **Buy Cards**: Spend Bucks to add to deck.
- **Reroll**: Refresh store offers for Y Bucks.

### Passive Income Scaling

- Base: +5 Bucks per day  
- For every 5 unspent Bucks (up to 25), gain +1 permanent income

---
