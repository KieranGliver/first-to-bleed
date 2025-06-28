extends Node

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
	BuildingName.STALL: "stall"
}

const SPEED_TO_SCALE := {
	Speed.PAUSED: 0.0,
	Speed.NORMAL: 1.0,
	Speed.X2: 2.0,
	Speed.X4: 4.0,
	Speed.X8: 8.0
}
