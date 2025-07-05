extends Node

enum EffectName {
	INDUSTRIAL,
	EXPLOIT,
	RUSH
}

enum Faction {
	DEFAULT,
	URBAN,
	ROYALTY,
	NATURE
}

enum BuildingKeyword {
	VANGUARD,
	WATER,
	DIRECTIONAL,
	CONCRETE,
	LARGE,
	POPULATE,
	ZONED,
	GHOST
}

enum YieldName {
	WOOD,
	STONE,
	VINES,
}

enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum BuildingName {
	HQ,
	HOUSE,
	STALL,
	WALL,
	CAMPFIRE,
	LAUNCH,
	TOWER,
	CRATE,
	BRIDGE,
	ONEWAY,
	CAFE,
	RANGEFINDER,
	GATE,
	GATLING_GUN,
	IRS,
	GROCERY_STORE,
	REINFORCED_WALL,
	MALL,
	STONE_QUARRY,
	CANOPY,
	PEA_SHOOTER,
	LUMBERYARD,
	DAM,
	BOMB,
	WINDMILL,
	MINE,
	OUTPOST,
	FOREST,
	SWAMP,
	ALARM_TOWER,
	VINEPIT,
	STATUE,
	LIBRARY,
	FARM,
	BAZAAR,
	MINT,
	THRONE,
	PALACE_GATE,
	CENSUS_OFFICE,
	FLAG
}

enum Speed {
	PAUSED,
	NORMAL,
	X2,
	X4,
	X8
}

const RARITY_TO_STRING := {
	Rarity.COMMON: "Common",
	Rarity.RARE: "Rare",
	Rarity.EPIC: "Epic",
	Rarity.LEGENDARY: "Legendary"
}

const BUILDING_NAME_TO_STRING := {
	BuildingName.HQ: "hq",
	BuildingName.HOUSE: "house",
	BuildingName.STALL: "stall",
	BuildingName.WALL: "wall",
	BuildingName.CAMPFIRE: "campfire",
	BuildingName.LAUNCH: "launch",
	BuildingName.TOWER: "tower",
	BuildingName.CRATE: "crate",
	BuildingName.BRIDGE: "bridge",
	BuildingName.ONEWAY: "oneway",
	BuildingName.CAFE: "cafe",
	BuildingName.RANGEFINDER: "rangefinder",
	BuildingName.GATE: "gate",
	BuildingName.GATLING_GUN: "gatling_gun",
	BuildingName.IRS: "irs",
	BuildingName.GROCERY_STORE: "grocery_store",
	BuildingName.REINFORCED_WALL: "reinforced_wall",
	BuildingName.MALL: "mall",
	BuildingName.STONE_QUARRY: "stone_quarry",
	BuildingName.CANOPY: "canopy",
	BuildingName.PEA_SHOOTER: "pea_shooter",
	BuildingName.LUMBERYARD: "lumberyard",
	BuildingName.DAM: "dam",
	BuildingName.BOMB: "bomb",
	BuildingName.WINDMILL: "windmill",
	BuildingName.MINE: "mine",
	BuildingName.OUTPOST: "outpost",
	BuildingName.FOREST: "forest",
	BuildingName.SWAMP: "swamp",
	BuildingName.ALARM_TOWER: "alarm_tower",
	BuildingName.VINEPIT: "vinepit",
	BuildingName.STATUE: "statue",
	BuildingName.LIBRARY: "library",
	BuildingName.FARM: "farm",
	BuildingName.BAZAAR: "bazaar",
	BuildingName.MINT: "mint",
	BuildingName.THRONE: "throne",
	BuildingName.PALACE_GATE: "palace_gate",
	BuildingName.CENSUS_OFFICE: "census_office",
	BuildingName.FLAG: "flag"
}

const SPEED_TO_SCALE := {
	Speed.PAUSED: 0.0,
	Speed.NORMAL: 1.0,
	Speed.X2: 2.0,
	Speed.X4: 4.0,
	Speed.X8: 8.0
}
