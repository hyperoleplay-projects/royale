-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMLIST
-----------------------------------------------------------------------------------------------------------------------------------------
local itemlist = {
	["WEAPON_HATCHET"] = {
		["index"] = "hatchet",
		["name"] = "Machado",
		["type"] = "Armamento",
		["drop"] = true,
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_HATCHET"
	},

	["WEAPON_BAT"] = {
		["index"] = "bat",
		["name"] = "Bastão de Beisebol",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_BAT"
	},
	
	["WEAPON_KATANA"] = {
		["index"] = "katana",
		["name"] = "Katana",
		["type"] = "Armamento",
		["drop"] = true,
		["durability"] = 3,
		["weight"] = 0.75,
		["spawName"] = "WEAPON_KATANA"
	},
	["WEAPON_KARAMBIT"] = {
		["index"] = "karambit",
		["name"] = "Karambit",
		["type"] = "Armamento",
		["drop"] = true,
		["durability"] = 3,
		["weight"] = 0.75,
		["spawName"] = "WEAPON_KARAMBIT"
	},


	["WEAPON_KNIFE"] = {
		["index"] = "knife",
		["name"] = "Faca",
		["type"] = "Armamento",
		["drop"] = true,
		["durability"] = 3,
		["weight"] = 0.75,
		["spawName"] = "WEAPON_KNIFE"
	},

	["WEAPON_BATTLEAXE"] = {
		["index"] = "battleaxe",
		["name"] = "Machado de Batalha",
		["drop"] = true,
		["type"] = "Armamento",
		["weight"] = 0.75,
		["spawName"] = "WEAPON_BATTLEAXE"
	},
	["WEAPON_CROWBAR"] = {
		["index"] = "crowbar",
		["name"] = "Pé de Cabra",
		["drop"] = true,
		["type"] = "Armamento",
		["weight"] = 0.75,
		["spawName"] = "WEAPON_CROWBAR"
	},
	["WEAPON_GOLFCLUB"] = {
		["index"] = "golfclub",
		["name"] = "Taco de Golf",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_GOLFCLUB"
	},
	["WEAPON_HAMMER"] = {
		["index"] = "hammer",
		["name"] = "Martelo",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_HAMMER"
	},
	["WEAPON_MACHETE"] = {
		["index"] = "machete",
		["name"] = "Facão",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_MACHETE"
	},
	["WEAPON_POOLCUE"] = {
		["index"] = "poolcue",
		["name"] = "Taco de Sinuca",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_POOLCUE"
	},
	["WEAPON_STONE_HATCHET"] = {
		["index"] = "stonehatchet",
		["name"] = "Machado de Pedra",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_STONE_HATCHET"
	},
	["WEAPON_WRENCH"] = {
		["index"] = "wrench",
		["name"] = "Chave Inglesa",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_WRENCH"
	},
	["WEAPON_KNUCKLE"] = {
		["index"] = "knuckle",
		["name"] = "Soco Inglês",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_KNUCKLE"
	},
	["WEAPON_FLASHLIGHT"] = {
		["index"] = "flashlight",
		["name"] = "Lanterna",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_FLASHLIGHT"
	},
	["WEAPON_NIGHTSTICK"] = {
		["index"] = "nightstick",
		["name"] = "Cassetete",
		["drop"] = true,
		["type"] = "Armamento",
		
		["weight"] = 0.75,
		["spawName"] = "WEAPON_NIGHTSTICK"
	},

	["WEAPON_FLAREGUN"] = {
		["index"] = "WEAPON_FLAREGUN",
		["name"] = "Flare Gun",
		["drop"] = true,
		["type"] = "Armamento",
		["weight"] = 0.75,
		["spawName"] = "WEAPON_FLAREGUN"
	},
	
	["WEAPON_SNIPERRIFLE"] = {
		["index"] = "WEAPON_SNIPERRIFLE",
		["name"] = "SNIPER",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_SNIPER_AMMO",
		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_SNIPERRIFLE"
	},

	["WEAPON_PISTOL"] = {
		["index"] = "m1911",
		["name"] = "M1911",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_PISTOL"
	},
	["WEAPON_PISTOL_MK2"] = {
		["index"] = "fiveseven",
		["name"] = "FN Five Seven",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.50,
		["spawName"] = "WEAPON_PISTOL_MK2"
	},
	["WEAPON_COMPACTRIFLE"] = {
		["index"] = "akcompact",
		["name"] = "AK Compact",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 2.25,
		["spawName"] = "WEAPON_COMPACTRIFLE"
	},
	["WEAPON_APPISTOL"] = {
		["index"] = "kochvp9",
		["name"] = "Koch Vp9",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_APPISTOL"
	},
	["WEAPON_HEAVYPISTOL"] = {
		["index"] = "atifx45",
		["name"] = "Ati FX45",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.50,
		["spawName"] = "WEAPON_HEAVYPISTOL"
	},

	["WEAPON_MACHINEPISTOL"] = {
		["index"] = "tec9",
		["name"] = "Tec-9",
		["type"] = "Armamento",
		["drop"] = true,
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.75,
		["spawName"] = "WEAPON_MACHINEPISTOL"
	},
	["WEAPON_MICROSMG"] = {
		["index"] = "uzi",
		["name"] = "Uzi",
		["type"] = "Armamento",
		["drop"] = true,
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_MICROSMG"
	},
	["WEAPON_NAILGUN"] = {
		["index"] = "nailgun",
		["name"] = "Arma de Prego",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_NAIL_AMMO",
		
		["vehicle"] = false,
		["weight"] = 1.75,
		["spawName"] = "WEAPON_NAILGUN"
	},
	["WEAPON_MINISMG"] = {
		["index"] = "skorpionv61",
		["name"] = "Skorpion V61",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.75,
		["spawName"] = "WEAPON_MINISMG"
	},
	["WEAPON_SNSPISTOL"] = {
		["index"] = "amt380",
		["name"] = "AMT 380",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.00,
		["spawName"] = "WEAPON_SNSPISTOL"
	},
	["WEAPON_SNSPISTOL_MK2"] = {
		["index"] = "hkp7m10",
		["name"] = "HK P7M10",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_SNSPISTOL_MK2"
	},
	["WEAPON_VINTAGEPISTOL"] = {
		["index"] = "m1922",
		["name"] = "M1922",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_VINTAGEPISTOL"
	},
	["WEAPON_PISTOL50"] = {
		["index"] = "desert",
		["name"] = "Desert Eagle",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.50,
		["spawName"] = "WEAPON_PISTOL50"
	},
	["WEAPON_REVOLVER"] = {
		["index"] = "magnum",
		["name"] = "Magnum 44",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.50,
		["spawName"] = "WEAPON_REVOLVER"
	},
	["WEAPON_COMBATPISTOL"] = {
		["index"] = "glock",
		["name"] = "Glock",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_COMBATPISTOL"
	},
	["WEAPON_CARBINERIFLE"] = {
		["index"] = "m4a1",
		["name"] = "M4A1",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 7.75,
		["spawName"] = "WEAPON_CARBINERIFLE"
	},
	["WEAPON_CARBINERIFLE_MK2"] = {
		["index"] = "m4a4",
		["name"] = "M4A4",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.50,
		["spawName"] = "WEAPON_CARBINERIFLE_MK2"
	},
	["WEAPON_COMBATMG"] = {
		["index"] = "combatmg",
		["name"] = "Combat MG",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.50,
		["spawName"] = "WEAPON_COMBATMG"
	},
	["WEAPON_DOUBLEACTION"] = {
		["index"] = "doubleaction",
		["name"] = "Double Action",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["weight"] = 8.50,
		["spawName"] = "WEAPON_DOUBLEACTION"
	},
	["WEAPON_PIPEBOMB"] = {
		["index"] = "pipebomb",
		["name"] = "Pipe Bomb",
		["drop"] = true,
		["type"] = "Armamento",
		["weight"] = 8.50,
		["spawName"] = "WEAPON_PIPEBOMB"
	},

	["WEAPON_SWITCHBLADE"] = {
		["index"] = "switchblade",
		["name"] = "Switch Blade",
		["drop"] = true,
		["type"] = "Armamento",
		["weight"] = 8.50,
		["spawName"] = "WEAPON_SWITCHBLADE"
	},


	["WEAPON_ADVANCEDRIFLE"] = {
		["index"] = "tar21",
		["name"] = "Tar-21",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["weight"] = 7.75,
		["spawName"] = "WEAPON_ADVANCEDRIFLE"
	},
	["WEAPON_BULLPUPRIFLE"] = {
		["index"] = "qbz95",
		["name"] = "QBZ-95",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 7.75,
		["spawName"] = "WEAPON_BULLPUPRIFLE"
	},
	["WEAPON_BULLPUPRIFLE_MK2"] = {
		["index"] = "l85",
		["name"] = "L85",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 7.75,
		["spawName"] = "WEAPON_BULLPUPRIFLE_MK2"
	},

	["WEAPON_SPECIALCARBINE"] = {
		["index"] = "g36c",
		["name"] = "G36C",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["skins"] = {
			["WEAPON_SPECIALCARBINESKIN1"] = {
				name = "WEAPON_SPECIALCARBINESKIN1"
			},
			
			["WEAPON_SPECIALCARBINESKIN2"] = {
				name = "WEAPON_SPECIALCARBINESKIN2"
			},
			
			["WEAPON_SPECIALCARBINESKIN3"] = {
				name = "WEAPON_SPECIALCARBINESKIN3"
			},
			
			["WEAPON_SPECIALCARBINESKIN4"] = {
				name = "WEAPON_SPECIALCARBINESKIN4"
			},
			
			["WEAPON_SPECIALCARBINESKIN5"] = {
				name = "WEAPON_SPECIALCARBINESKIN5"
			},
			
			["WEAPON_SPECIALCARBINESKIN6"] = {
				name = "WEAPON_SPECIALCARBINESKIN6"
			},

			["WEAPON_SPECIALCARBINESKIN7"] = {
				name = "WEAPON_SPECIALCARBINESKIN7"
			},
		},

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINE"
	},

	["WEAPON_SPECIALCARBINESKIN1"] = {
		["index"] = "G31",
		["name"] = "G36C - SKIN 1",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN1"
	},

	
	["WEAPON_SPECIALCARBINESKIN2"] = {
		["index"] = "G32",
		["name"] = "G36C - SKIN 2",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN2"
	},

	["WEAPON_SPECIALCARBINESKIN3"] = {
		["index"] = "G33",
		["name"] = "G36C - SKIN 3",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN3"
	},
	
	["WEAPON_SPECIALCARBINESKIN4"] = {
		["index"] = "G34",
		["name"] = "G36C - SKIN 4",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN4"
	},

	["WEAPON_SPECIALCARBINESKIN5"] = {
		["index"] = "G35",
		["name"] = "G36C - SKIN 5",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN5"
	},

	["WEAPON_SPECIALCARBINESKIN6"] = {
		["index"] = "G36",
		["name"] = "G36C - SKIN 6",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN6"
	},

	["WEAPON_SPECIALCARBINESKIN7"] = {
		["index"] = "G37",
		["name"] = "G36C - SKIN 7",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINESKIN7"
	},

	["WEAPON_PARAFAL"] = {
		["index"] = "parafal",
		["name"] = "PARA-FAL M964A1",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_PARAFAL"
	},

	["WEAPON_FNFAL"] = {
		["index"] = "fnfal",
		["name"] = "FN L1A1",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_FNFAL"
	},

	["WEAPON_SPECIALCARBINE_MK2"] = {
		["index"] = "sigsauer556",
		["name"] = "Sig Sauer 556",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINE_MK2"
	},
	["WEAPON_PUMPSHOTGUN"] = {
		["index"] = "mossberg590",
		["name"] = "Mossberg 590",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_SHOTGUN",

		["weight"] = 7.25,
		["spawName"] = "WEAPON_PUMPSHOTGUN"
	},
	["WEAPON_PUMPSHOTGUN_MK2"] = {
		["index"] = "mossberg590a1",
		["name"] = "Mossberg 590A1",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_SHOTGUN",

		["weight"] = 7.25,
		["spawName"] = "WEAPON_PUMPSHOTGUN_MK2"
	},
	["WEAPON_MUSKET"] = {
		["index"] = "winchester",
		["name"] = "Winchester 1892",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_SHOTGUN",

		["weight"] = 6.25,
		["spawName"] = "WEAPON_MUSKET"
	},
	["WEAPON_SAWNOFFSHOTGUN"] = {
		["index"] = "mossberg500",
		["name"] = "Mossberg 500",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_SHOTGUN",

		["weight"] = 5.75,
		["spawName"] = "WEAPON_SAWNOFFSHOTGUN"
	},
	["WEAPON_SMG"] = {
		["index"] = "mp5",
		["name"] = "MP5",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["weight"] = 5.25,
		["spawName"] = "WEAPON_SMG"
	},
	["WEAPON_SMG_MK2"] = {
		["index"] = "evo3",
		["name"] = "Evo-3",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["vehicle"] = true,
		["weight"] = 5.25,
		["spawName"] = "WEAPON_SMG_MK2"
	},
	["WEAPON_ASSAULTRIFLE"] = {
		["index"] = "ak103",
		["name"] = "AK-103",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",


		["skins"] = {
			["WEAPON_ASSAULTRIFLESKIN1"] = {
				name = "WEAPON_ASSAULTRIFLESKIN1"
			},

			["WEAPON_ASSAULTRIFLESKIN2"] = {
				name = "WEAPON_ASSAULTRIFLESKIN2"
			},

			["WEAPON_ASSAULTRIFLESKIN3"] = {
				name = "WEAPON_ASSAULTRIFLESKIN3"
			},

			["WEAPON_ASSAULTRIFLESKIN4"] = {
				name = "WEAPON_ASSAULTRIFLESKIN4"
			},

			["WEAPON_ASSAULTRIFLESKIN5"] = {
				name = "WEAPON_ASSAULTRIFLESKIN5"
			},

			["WEAPON_ASSAULTRIFLESKIN6"] = {
				name = "WEAPON_ASSAULTRIFLESKIN6"
			},
			
			["WEAPON_ASSAULTRIFLESKIN7"] = {
				name = "WEAPON_ASSAULTRIFLESKIN7"
			},

			["WEAPON_ASSAULTRIFLESKIN8"] = {
				name = "WEAPON_ASSAULTRIFLESKIN7"
			},

			["WEAPON_ASSAULTRIFLESKIN9"] = {
				name = "WEAPON_ASSAULTRIFLESKIN9"
			},

			["WEAPON_ASSAULTRIFLESKIN10"] = {
				name = "WEAPON_ASSAULTRIFLESKIN10"
			},

			["WEAPON_ASSAULTRIFLESKIN11"] = {
				name = "WEAPON_ASSAULTRIFLESKIN11"
			},

			["WEAPON_ASSAULTRIFLESKIN12"] = {
				name = "WEAPON_ASSAULTRIFLESKIN12"
			},
		},

		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLE"
	},

	["WEAPON_ASSAULTRIFLESKIN1"] = {
		["index"] = "AK1",
		["name"] = "AK-103 SKIN 1",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN1"
	},

	["WEAPON_ASSAULTRIFLESKIN2"] = {
		["index"] = "AK2",
		["name"] = "AK-103 SKIN 2",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN2"
	},

	["WEAPON_ASSAULTRIFLESKIN3"] = {
		["index"] = "AK3",
		["name"] = "AK-103 SKIN 3",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN3"
	},

	["WEAPON_ASSAULTRIFLESKIN4"] = {
		["index"] = "AK4",
		["name"] = "AK-103 SKIN 4",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN4"
	},

	["WEAPON_ASSAULTRIFLESKIN5"] = {
		["index"] = "AK5",
		["name"] = "AK-103 SKIN 5",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN5"
	},

	["WEAPON_ASSAULTRIFLESKIN6"] = {
		["index"] = "AK6",
		["name"] = "AK-103 SKIN 6",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN6"
	},


	["WEAPON_ASSAULTRIFLESKIN7"] = {
		["index"] = "AK7",
		["name"] = "AK-103 SKIN 7",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN7"
	},

	
	["WEAPON_ASSAULTRIFLESKIN8"] = {
		["index"] = "AK8",
		["name"] = "AK-103 SKIN 8",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN8"
	},

	["WEAPON_ASSAULTRIFLESKIN9"] = {
		["index"] = "AK9",
		["name"] = "AK-103 SKIN 9",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN9"
	},

	["WEAPON_ASSAULTRIFLESKIN10"] = {
		["index"] = "AK10",
		["name"] = "AK-103 SKIN 10",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN10"
	},

	["WEAPON_ASSAULTRIFLESKIN11"] = {
		["index"] = "AK11",
		["name"] = "AK-103 SKIN 11",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN11"
	},

	["WEAPON_ASSAULTRIFLESKIN12"] = {
		["index"] = "AK12",
		["name"] = "AK-103 SKIN 12",
		["drop"] = false,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLESKIN12"
	},

	["WEAPON_ASSAULTRIFLE_MK2"] = {
		["index"] = "ak74",
		["name"] = "AK-74",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_RIFLE",

		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLE_MK2"
	},
	["WEAPON_ASSAULTSMG"] = {
		["index"] = "steyraug",
		["name"] = "Steyr AUG",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["weight"] = 5.75,
		["spawName"] = "WEAPON_ASSAULTSMG"
	},
	["WEAPON_GUSENBERG"] = {
		["index"] = "thompson",
		["name"] = "Thompson",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "AMMO_PISTOL",

		["weight"] = 6.25,
		["spawName"] = "WEAPON_GUSENBERG"
	},
	["WEAPON_PETROLCAN"] = {
		["index"] = "gallon",
		["name"] = "Galão",
		["type"] = "Armamento",
		["ammo"] = "WEAPON_PETROLCAN_AMMO",
		["weight"] = 1.25,
		["spawName"] = "WEAPON_PETROLCAN"
	},
	["GADGET_PARACHUTE"] = {
		["index"] = "parachute",
		["name"] = "Paraquedas",
		["type"] = "Usável",
		["weight"] = 2.25,
		["spawName"] = "GADGET_PARACHUTE"
	},
	["WEAPON_STUNGUN"] = {
		["index"] = "stungun",
		["name"] = "Tazer",
		["drop"] = true,
		["type"] = "Armamento",

		["weight"] = 0.75,
		["spawName"] = "WEAPON_STUNGUN"
	},
	["WEAPON_NAIL_AMMO"] = {
		["index"] = "nails",
		["name"] = "Pregos",
		["type"] = "Munição",
		["weight"] = 0.02,
		["spawName"] = "WEAPON_NAIL_AMMO"
	},
	["AMMO_PISTOL"] = {
		["index"] = "pistolammo",
		["drop"] = true,
		["name"] = "Munição de Pistola/Sub",
		["type"] = "Munição",
		["weight"] = 0.02,
		["spawName"] = "AMMO_PISTOL"
	},
	["AMMO_RIFLE"] = {
		["index"] = "rifleammo",
		["drop"] = true,
		["name"] = "Munição de Rifle",
		["type"] = "Munição",
		["weight"] = 0.04,
		["spawName"] = "AMMO_RIFLE"
	},
	["AMMO_SHOTGUN"] = {
		["index"] = "shotgunammo",
		["drop"] = true,
		["name"] = "Munição de Escopeta",
		["type"] = "Munição",
		["weight"] = 0.05,
		["spawName"] = "AMMO_SHOTGUN"
	},
	["WEAPON_MUSKET_AMMO"] = {
		["index"] = "musketammo",
		["drop"] = true,
		["name"] = "Munição de Mosquete",
		["type"] = "Munição",
		["weight"] = 0.05,
		["spawName"] = "WEAPON_MUSKET_AMMO"
	},
	["WEAPON_PETROLCAN_AMMO"] = {
		["index"] = "fuel",
		["drop"] = true,
		["name"] = "Combustível",
		["type"] = "Munição",
		["weight"] = 0.001,
		["spawName"] = "WEAPON_PETROLCAN_AMMO"
	},
	["WEAPON_BRICK"] = {
		["index"] = "brick",
		["name"] = "Tijolo",
		["drop"] = false,
		["type"] = "Throwing",
		["vehicle"] = true,
		["weight"] = 0.50,
		["spawName"] = "WEAPON_BRICK"
	},
	["WEAPON_SNOWBALL"] = {
		["index"] = "snowball",
		["name"] = "Bola de Neve",
		["type"] = "Throwing",
		["vehicle"] = true,
		["weight"] = 0.25,
		["spawName"] = "WEAPON_SNOWBALL"
	},
	["WEAPON_SHOES"] = {
		["index"] = "shoes",
		["name"] = "Tênis",
		["type"] = "Throwing",
		["vehicle"] = true,
		["weight"] = 0.50,
		["spawName"] = "WEAPON_SHOES"
	},
	
	["WEAPON_MOLOTOV"] = {
		["index"] = "molotov",
		["drop"] = true,
		["name"] = "Coquetel Molotov",
		["type"] = "Throwing",
		["vehicle"] = true,
		["weight"] = 0.50,
		["spawName"] = "WEAPON_MOLOTOV",
		["max"] = "3"
	},

	["WEAPON_SMOKEGRENADE"] = {
		["index"] = "smokegrenade",
		["name"] = "Granada de Fumaça",
		["drop"] = true,
		["type"] = "Throwing",
		["vehicle"] = true,
		["weight"] = 0.50,
		["spawName"] = "WEAPON_SMOKEGRENADE",
		["max"] = 3
	},

	["ARMOUR_STANDARD"] = {
		["index"] = "ARMOUR_STANDARD",
		["name"] = "Colete",
		["type"] = "Usável",
		["weight"] = 2.25,
		["max"] = 1,
		["drop"] = true,
		["weight"] = 0.75,
		["spawName"] = "ARMOUR_STANDARD"
	},

	["adrenaline"] = {
		["index"] = "adrenaline",
		["name"] = "Adrenalina",
		["type"] = "Usável",
		["weight"] = 2.25,
		["max"] = 1,
		["drop"] = false,
		["weight"] = 0.75,
		["spawName"] = "adrenaline"
	},



	["ENERGETICO"] = {
		["index"] = "enegetico",
		["name"] = "Energético",
		["type"] = "Usável",
		["weight"] = 2.25,
		["max"] = 25,
		["drop"] = true,
		["weight"] = 0.1,
		["spawName"] = "ENERGETICO"
	},

	["AIRDROP"] = {
		["index"] = "airdrop",
		["name"] = "DUTH - AirDrop",
		["type"] = "Usável",
		["weight"] = 2.25,
		["max"] = 1,
		["drop"] = false,
		["weight"] = 0.1,
		["spawName"] = "AIRDROP"
	},

	["HEALTH_STANDARD"] = {
		["index"] = "HEALTH_STANDARD",
		["name"] = "Bandagem",
		["type"] = "Usável",
		["drop"] = true,
		["weight"] = 0.10,
		["max"] = 3,
		["spawName"] = "HEALTH_STANDARD"
	},

	["attachsFlashlight"] = {
		["index"] = "attachsFlashlight",
		["name"] = "Lanterna Tatica",
		["type"] = "Usável",
		["drop"] = false,
		["weight"] = 1.15,
		["spawName"] = "attachsFlashlight"
	},
	["attachsCrosshair"] = {
		["index"] = "attachsCrosshair",
		["name"] = "Mira Holográfica",
		["type"] = "Usável",
		["drop"] = false,
		["weight"] = 1.15,
		["spawName"] = "attachsCrosshair"
	},
	["attachsSilencer"] = {
		["index"] = "attachsSilencer",
		["name"] = "Silenciador",
		["drop"] = false,
		["type"] = "Usável",
		["weight"] = 1.15,
		["spawName"] = "attachsSilencer"
	},
	["attachsMagazine"] = {
		["index"] = "attachsMagazine",
		["name"] = "Pente Estendido",
		["type"] = "Usável",
		["drop"] = false,
		["weight"] = 1.15,
		["spawName"] = "attachsMagazine"
	},
	["attachsGrip"] = {
		["index"] = "attachsGrip",
		["name"] = "Empunhadura",
		["drop"] = false,
		["type"] = "Usável",
		["weight"] = 1.15,
		["spawName"] = "attachsGrip"
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMBODY
-----------------------------------------------------------------------------------------------------------------------------------------
function itemBody(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMINDEX
-----------------------------------------------------------------------------------------------------------------------------------------
function itemIndex(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["index"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function itemName(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["name"]
	end

	return "Não existe"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMTYPE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemType(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["type"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMMO
-----------------------------------------------------------------------------------------------------------------------------------------
function itemAmmo(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["ammo"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemVehicle(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["vehicle"] or false
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function itemWeight(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["weight"] or 0.0
	end

	return 0.0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMMAXAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function itemMaxAmount(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["max"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMSCAPE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemScape(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["scape"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDESCRIPTION
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDescription(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["desc"] or nil
	end

	return nil
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- itemDrop
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDrop(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["drop"] or false
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDURABILITY
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDurability(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["durability"] or false
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- itemSkins
-----------------------------------------------------------------------------------------------------------------------------------------
function itemSkins(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["skins"] or {}
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMCHARGES
-----------------------------------------------------------------------------------------------------------------------------------------
function itemCharges(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["charges"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMECONOMY
-----------------------------------------------------------------------------------------------------------------------------------------
function itemSpawnName(index)
	for _, item in pairs(itemlist) do 
		if index == item.index then
			return item.spawName
		end
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMBLOCK
-----------------------------------------------------------------------------------------------------------------------------------------
function itemBlock(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["block"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMREPAIR
-----------------------------------------------------------------------------------------------------------------------------------------
function itemRepair(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["repair"] or false
	end

	return false
end