# FirstToBleed - Game Design Document

**Genre:** Asynchronous Tile-painting Roguelike Deckbuilder  
**Overview:**  
Players face off in competitive, real-time rounds by deploying units ("Plebs") and buildings to control territory on a shared grid. Victory comes through strategic placement, deck optimization, and area control.

---

## Strategic Principles

- As players claim more territory, maintaining control becomes more difficult as Plebs bounce less frequently off strategically placed buildings and resources become spread thin.
- Balancing offense, defense, and resource generation is key to long-term success.
- Archetypes are designed to counter and outmaneuver each other, encouraging dynamic matchup

---

## Archetypes

## 🏙️ Urban

> “Order, structure, density.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Builder / Optimizer                                                    |
| **Mechanics**         | - Buffs for clustered buildings<br>- High stone, low wood use<br>- Strong passive income |
| **Playstyle**         | Turtle up, optimize layout, outscale late-game                         |
| **Signature Mechanic**| **Zoning Bonus** – adjacency buffs based on building layout            |
| **Weakness**          | Vulnerable early game; struggles vs. rush                         |
| **Visual Theme**      | Dense cityscapes, paved tiles, urban decor                             |
| **Example Cards**     | Stone Bank, Merchant Quarter, Trade Guild                              |

---

## 🌿 Nature

> “Grow wild, tear down walls.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Swarm / Disrupt                                                        |
| **Mechanics**         | - Cheap, fast cards<br>- Disables or destroys buildings<br>- Excels in open space |
| **Playstyle**         | Pressure early, control space, deny opponent value                     |
| **Signature Mechanic**| **Wild Growth** – Fast spawning plebs                                  |
| **Weakness**          | Weak in tight maps; falls off if denied space                          |
| **Visual Theme**      | Overgrown fields, vines, cracked earth                                 |
| **Example Cards**     | Vine Burst, Root Hive, Rampant Grove                                   |

---

## ✨ Magical

> “A plan today is victory tomorrow.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Flashy / Stompy                                                        |
| **Mechanics**         | - Magic circles<br>- Deck/hand manipulation<br>- Defensive buildings   |
| **Playstyle**         | Manipulate luck, survive until power spike, then dominate              |
| **Signature Mechanic**| **Magic Circle** – powerful effects from building layout               |
| **Weakness**          | Relies on setup; vulnerable to disruption                              |
| **Visual Theme**      | Arcane sigils, glowing runes, purple stone                             |
| **Example Cards**     | Chrono Pillar, Leyline Knot, Hex Spire                                 |

---

## ♻️ Scrap

> “Waste not. Want not.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Scavenger / Adaptive                                                   |
| **Mechanics**         | - Bonuses from destruction <br>- Modular buildings<br>- Recycle cards and plebs |
| **Playstyle**         | Adapts fast, thrives in chaos, turns entropy into value                |
| **Signature Mechanic**| **Junk Harvest** – gains bonuses destroyed buildings                   |
| **Weakness**          | Requires burns bright early and can run out of fuel fast               |
| **Visual Theme**      | Rusted machinery, broken tiles, scavenged signage                      |
| **Example Cards**     | Salvage Core, Patch Hub, Gear Totem                                    |

---

## 👑 Royalty

> “Legacy is the only true victory.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Greedy / Prestige                                                      |
| **Mechanics**         | - Influence buildings count as bonus<br>- Monuments with objective based scoring<br>- Wins by own rules |
| **Playstyle**         | Builds slow but powerful engines, wins via alt win cons rather than solely tile count |
| **Signature Mechanic**| **Crown Influence** – Gain bonus points through buildings              |
| **Weakness**          | Jack of all trades that requires help from other types to achieve goals |
| **Visual Theme**      | Regal halls, marble plazas, glowing crowns                             |
| **Example Cards**     | Monument of Might, Royal Decree, Throne of Gold                        |



---

## Game Loop & Progression

### Player Setup

- Choose a starting archetype (e.g. Urban, Nature) - determines your initial deck and extra bonus.
- Start with **3 lives**. If the player reaches 0 lives they are eliminated and must restart.
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
  - Remove cards from deck
  - Upgrade exisiting cards in the deck

---

## Battle Rules

- **Start:**
  - Map spawns with player HQs and 4 starting Plebs with a limit of 10.  
  - Player hand is drawn; Players may place buildings before the round timer begins during the pre-battle phase.

- **Gameplay:**
  - 4-player FFA (1v1v1v1).
  - Rounds start at **2 minutes**, increasing by 30s per round (capped at **6 minutes**).
  - **Real-time** play with time control:
    - `Space` – Pause  
    - `1–4` – Speed tiers (4 = unlimited)

- **Victory:**
  - Ranked by **tile count** at round end.
  - Some buildings may influence tile count at the end

---

## Core Mechanics

### Plebs

- Plebs can die. They will be spawned by a buildings that spawn them. Players will have a max capacity
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

### Rarity

Buildings come in Common, Rare, and Legendary tiers, affecting cost and power.

### Placement

- Only on owned tiles.
- Cost **Ducats**, and possibly **Wood** or **Stone**.

### Health

- All buildings have base HP.
- When a pleb hits the building it will take one damage.
- Destroyed buildings leave behind Ruins tiles, which some archetypes (e.g. Scrap) can exploit.

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
- For every 5 unspent Bucks (up to 25), gain +1 income

---

## Asynchronous

- Players will play against other players decks handled by ai.
- 
