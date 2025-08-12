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
| **Weakness**          | Vulnerable early game; struggles vs. rush                              |
| **Visual Theme**      | Dense cityscapes, paved tiles, urban decor                             |
| **Keywords**          | Concrete, Industrial, Zoned                                            |
| **Passive**           | Gain 1 stone per (5s)                                                  |

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
| **Keywords**          | Rush, Overgrowth, and Populate                                         |
| **Passive**           | Every building spawns a population                                     |

---

## 👑 Royalty

> “Legacy is the only true victory.”

| Category              | Detail                                                                 |
|-----------------------|------------------------------------------------------------------------|
| **Style**             | Greedy / Prestige                                                      |
| **Mechanics**         | - Influence buildings count as bonus<br>- Monuments with objective based scoring<br>- Wins by own rules |
| **Playstyle**         | Builds slow but powerful engines, wins via alt win cons rather than solely tile count |
| **Signature Mechanic**| **Crown Influence** – Gain bonus points through buildings              |
| **Weakness**          | Jack of all trades that requires help from other types to achieve goals|
| **Visual Theme**      | Regal halls, marble plazas, glowing crowns                             |
| **Passive**           | Large buildings count as double vp at the end of the game              |

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

---

## Battle Rules

- **Start:**
  - Map spawns with player HQs and 4 starting Plebs.  
  - Player draws 5 cards; Players may place buildings before the round timer begins during the pre-battle phase.

- **Gameplay:**
  - 4-player FFA (1v1v1v1).
  - Rounds start at **2 minutes**, increasing by 30s per round (capped at **6 minutes**).
  - Cards played are discarded to the graveyard. If there are cards in the deck always draw to hand size (5).
  - The user should be able to view active deck and graveyard here!
  - **Real-time** play with time control:
	- `Space` – Pause  
	- `1–4` – Speed tiers

- **Battle-Results:**
  - Ranked by **tile count** at round end.
  - Some buildings may influence tile count at the end.
  - Chart showing match (tiles claimed, total bounces, total gold, cards placed)

---

## Plebs

- Plebs can't die. When a pleb is on a square that is being switched they fly back to their hq
- Pleb count can be increased by buildings that will instantly spawn plebs. When building is destroyed plebs will be removed.
- A Force can be applied to the plebs that will launch them in a direction
- Move in straight lines until:
  - Hitting a building = bounce and (attack or touch).
  - Hitting unclaimed area = bounce, gain ducats and claim.
  - Hitting a claimed territory = bouce and declaim.
  - Hitting a terrain = bounce.
- **Bounce Behavior:**
  - Redirects Pleb in a non-blocked direction.
  - Slight randomness to increase excitement
  - Force is reflected on bounce lossing magnitude
  - Some Plebs have bounce direction preferences?
  
### Keywords

#### Rush

Plebs gain a movement speed buff for three seconds up to three stacks. (125%, 150%, 200%)

#### Industrial

Plebs will trigger on touch effects twice for five seconds

#### Exploit

Plebs will deal double damage for five seconds

#### Bewitched

Plebs moved randomly for 5 seconds

---

## Buildings

### Building Data

- id: A constant number given to all buildings
- cost: Total cost of ducats in game
- faction: The faction the building belongs to
- rarity: Common, Rare, Epic, and Legendary tiers, affecting cost and power.
- description: Text describing how a building operates

### Placement

- Only on owned tiles.
- Cost **Ducats**, and possibly **Wood** or **Stone**.
- Drag and drop to place cards
- Buildings can't be placed next to one another.

### Health

- All buildings have base HP (Default: 10).
- When an enemy pleb hits the building it will take one damage.
- Destroyed buildings leave behind Ruins tiles, which some archetypes (e.g. Scrap) can exploit?

### Activation Types

- **On Touch** – When a Pleb bounces on it.
- **On Placement** – Triggers on deployment.
- **Countdown** – Periodic effect over time.
- **On Attack** – When hit by an enemy Pleb.

### Effect Examples

- Grant resources  
- Spawn additional Plebs  
- Upgrade nearby structures  
- Fire projectiles  
- Redirect or move Plebs  
- Influence any game mechanic

### Keywords

#### Directional

Building can be rotated

#### Concrete

Buildingss gain 5 health

#### Large

Buildings size is 2x2

#### Populate

Gain one pleb

#### Zoned

Building can be placed next to another building

#### Ghost

Plebs can go through this building

#### Connection

The number of buildings that either are connected to this building or connected to a building that is connected to this

#### Overgrowth

Building gains a growth stack lasting 1 seconds. If the buidling already contains a growth stack a vine appears nearby and clears the growth stack. Vines are resources with two health that are owned by a the building owner. Vines can be traversed by the owner.

#### Vanguard

Building can be placed outside of territory

#### Waterbound

Building can only be placed on water

### Building Types

- **Income** – Boosts resource generation  
- **Attack** – Damages enemy tiles/buildings  
- **Defense** – Protects territory  
- **Enhancer** – Upgrades nearby buildings  
- **Resource** – Spawns gatherable resources  
- **Directional** – Alters Pleb pathing


### Buildings:

| Name              | Faction   | Cost      | Description                                                                |
|-------------------|-----------|-----------|----------------------------------------------------------------------------|
| Walls             | Default   | 100d      | **Concrete**                                                               |
| Stall             | Default   | 200d      | On Touch: Gain 5 Ducats                                                    |
| Campfire          | Default   | 200d      | Countdown (10s): Gain 20 gold                                              |
| House             | Default   | 200d      | **Populate** 2                                                             |
| Launch            | Default   | 200d      | **Ghost**, **Directional**, On Touch: Launch Pleb                          |
| Tower             | Default   | 200d      | On Touch: Fire projectile within 3 tiles                                   |
| Bridge            | Default   | 100d      | **Ghost**, **Vanguard**, **Waterbound**                                    |
| Crate             | Default   | 100d      | **Dense**, on placement: Gain 50 ducats                                    |
| One Way           | Urban     | 200d      | **Directional**, **Ghost**, On Touch: Change pleb direction                |
| Café              | Urban     | 400d      | Countdown (5s): Nearest 2 plebs gain **Industrial**                        |
| Rangefinder       | Urban     | 300d      | **Zoned**, Buildings within the connection gain +2 range                   |
| Gate              | Urban     | 200d      | **Ghosted**, **Zoned**                                                     |
| Gatling Gun       | Urban     | 300d      | +1 projectile per connection ; Countdown (15s): Fire within 3 tiles        |
| IRS               | Urban     | 500d      | On any building placed: Gain 50 Ducats                                     |
| Grocery           | Urban     | 200d      | Countdown (15s): Gain 5 Ducats per connection                              |
| Reinforced Wall   | Urban     | 200d      | **Zoned**, Connected buildings gain **Concrete**                           |
| Mall              | Urban     | 300d      | **Zoned**, +1 VP per Mall connected at End of Game                         |
| Stone Quarry      | Urban     | 200d      | On Touch: Gain 1 Stone                                                     |
| Canopy            | Nature    | 200d      | On Touch: Plebs gain **Rush**                                              |
| Pea Shooter       | Nature    | 500d      | On touch: **Overgrowth**, Countdown (7s): Fire 3 projectiles within 1 tile, +1 range per Vines within 1 tile |
| Lumberyard        | Nature    | 200d      | On Pleb attack on forest: Gain 10 ducats                                   |
| Dam               | Nature    | 400d      | On tree destruction: Plebs gain **Rush**                                   |
| Bomb              | Nature    | 200d      | Countdown (10s): Self-destruct; Remove terrain in 2-tile radius            |
| Windmill          | Nature    | 100d      | Countdown (10s): Gain 1 Ducat per Pleb                                     |
| Mine              | Nature    | 200d      | On Attack: Self-destruct, claim all tiles within 2 tile                    |
| Outpost           | Nature    | 100d      | **Populate** 1                                                             |
| Forest            | Nature    | 200d      | Countdown (10s): Spawn tree within 1 tile                                  |
| Swamp             | Nature    | 300d      | On touch: **Overgrowth**. Countdown (5s): Turn vine into tree resource     |
| Alarm Tower       | Nature    | 300d      | On Attack: All nearby Plebs gain Rush                                      |
| Vine Pit          | Nature    | 200d      | On attack: Gain **Overgrowth**                                             |
| Statue            | Royalty   | 300d      | Nearby plebs gain **Exploit**                                              |
| Library           | Royalty   | 500d      | Worth 10 VP at the end of the game                                         |
| Farm              | Royalty   | 400d      | On Touch: Gain 15 Gold                                                     |
| Bazaar            | Royalty   | 200d      | On Touch: Gain 1 random resource                                           |
| Mint              | Royalty   | 300d      | Countdown (15s): Convert 5 stone to 50 Ducats                              |
| Throne            | Royalty   | 300d      | **Large**. End of Game: +1 VP per building                                 |
| Palace Gate       | Royalty   | 500d      | **Large**, **Ghost**. Plebs gain **Rush** + **Exploit** passing through    |
| Census Office     | Royalty   | 250d      | On Placement: +1 VP per 3 plebs                                            |
| Flag              | Royalty   | 100d      | On attack: Nearby pleb gains exploit                                       |


### Additional

| Name              | Faction   | Cost      | Description                                                                |
|-------------------|-----------|-----------|----------------------------------------------------------------------------|
| Subway            | Urban     | 300d      | **Directional**, **Ghost**, On Touch: Warp pleb to another station         |
| Skyscrapper       | Urban     | 600d      | **Large**, **Zoned**, countdown(5s): all friendly plebs gain industrial    |
| Power Plant       | Urban     | 300d      | On Touch: Connected buildings trigger countdown effects                    |
| Sewer             | Urban     | 200d      | On Touch: Spawn a temp pleb that despawns after 10s                        |

---

## Resources

### User resources

| Type       | Use                               | Gained From                               |
|------------|-----------------------------------|-------------------------------------------|
| **Bucks**  | Shop purchases                    | Start of each round, based on income      |
| **Reroll** | Reroll hand and store             | Purchase at the shop                      |
| **Ducats** | Placing cards (buildings)         | - Buildings<br>- Plebs hitting gold or neutral tiles |
| **Wood**   | Placing specific building cards   | Plebs hitting **trees**                   |
| **Stone**  | Placing specific building cards   | Plebs hitting **rocks/stones**            |

In battles wood is more common than stone

### Map resources

- Trees: Gain 1 wood on touch takes 2 hits
- Stone: Gain 1 stone on touch takes 5 hits
- Vines: takes 1 hit
- Ruins: Takes 3 hits
  
---

## Store

Gain 10 coins each day, it doesn't roll over.

### Store Options
- **Buy Cards**: Spend bucks to buy cards. Display up to 3 cards. Cards cost three bucks.
- **Buy Reroll**: Buy rerolls to use either in battle or store. Rerolls cost 1 dollar.
- **Remove a Card**: Removes one card of the player's choice from their deck. Each subsequent use permently cost one more buck

The user should be able to view their deck here!

---

## Map Generation

**Goals**:
- Tactical: Multiple viable paths and choke points.
- Replayable: Never feel same-y.
- Thematic: Feel distinct per map theme.
- Fair: Each player should have roughly equal opportunity.

### Setup

- An appropriate spot is picked for each team start.
- A HQ is placed in the center of a 4x4 claimed area.
- All tiles in the area are removed of all terrain and made floors.

### Size

Map will start at the base size 15x15 or 255 tiles. Size will increase by 2 each round

### Terrain

- Water
- Cliffs
- Resources - Tree, stones, vines, and ruins
- Buildings

### Patterns

- **Field**: Wide open terrain, not many obsticles
- **Maze**: Water creates narrow lines in interesting pattern for plebs to follow. No cliffs
- **Lake**: Large water feature in the center
- **Highlands**: High cliff density
- **Swamp**: Lots of small water groups and vines present. Low cliff, high tree
- **Wasteland**: minimal resources, ruins everywhere
- **Fortress**: Starts are surrounded by symetrical resources and terrain
- **DeathMatch**: Teams are locked into two different 1v1 battles with equal tiles
- **Hill**: Stones and trees concentrated in the center

---

## Asynchronous multiplayer

During battles the player will face three computer opponents controlling other users decks. These decks will be real decks made by other players on their runs

### Uploading your deck

The decks are saved in a sql database that contains two tables:

#### sessions

| id (uuid) | day (int) | created_at (timestamp) |
|-----------|-----------|------------------------|

#### decks

| deck_id (uuid) | building_id (int) | amount (int) |
|----------------|-------------------|--------------|

- The primary key for sessions is id
- The primary key for decks is deck_id, building_id
- deck_id is a foreign key for id in sessions

Before battle (After the store) the players deck is uploaded to the database

### Loading your decks

At the beginning of the battle the gamemanager will load three random decks from the day after to each opponent. The decks will be one day advanced as the ai cheats always.
If the player isnt connected to the internet base decks will need to be manually stored in the game to load on each day.

## ESC Menu

Can only be pulled up when the player is currently in a run

### Restart

restarts the current run from the beginning

### Settings

Includes different settings the user may want to change:
- Audio: Volume sliders for music, effects, ambient sounds.
- Graphics: Display size, UI scaling.
- Controls: Key bindings overview, toggle mouse/touch/gamepad support.

### Encyclopedia

Contains useful information about gameplay and buildings

### Save & Quit

Saves the current deck and session and exits to the main menu. If the run is currently in a battle it will count as a loss

### Quick Access

small buttons at bottom for easy user access

- Mute button: Controls sound

## Main Menu

Displayed when the player boots up the game. Cool splash screen with movement and music!

### New Game

Start a new game and overwrite previous save

### Load Game

If the player has an unfinished run they may resume it. The current deck and date is displayed to the user

### Encyclopedia

Contains useful information about gameplay and buildings

### Quit

Exits Game

### Quick Access

small buttons at bottom for easy user access

- Mute button: Controls sound
- Credits: Displays my glory
- Settings: Opens setting menu
