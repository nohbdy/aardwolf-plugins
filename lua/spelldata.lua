local spelldata = {}

---@class SpellData
---@field id number # The spell number
---@field name string # Spell name
---@field mage number? # Level mage gets the spell
---@field cleric number? # Level cleric gets the spell
---@field thief number? # Level thief gets the spell
---@field warrior number? # Level warrior gets the spell
---@field ranger number? # Level ranger gets the spell
---@field paladin number? # Level paladin gets the spell
---@field psi number? # Level psionicist gets the spell
---@field damage_type number # Damage type, if it's a damage spell
---@field is_spell boolean # true if this is a spell, false if it's a skill
---@field nofail boolean # Whether or not the spell is nofail
---@field subclasses string[] # Array of subclasses that get this spell

---@type table<number, SpellData>
local data = {}

---@type table<string, number>
local name_to_id = {}

spelldata.DamageTypes = {}
spelldata.DamageTypes.None = 0
spelldata.DamageTypes.Acid = 1
spelldata.DamageTypes.Air = 2
spelldata.DamageTypes.Bash = 3
spelldata.DamageTypes.Cold = 4
spelldata.DamageTypes.Earth = 5
spelldata.DamageTypes.Electric = 6
spelldata.DamageTypes.Energy = 7
spelldata.DamageTypes.Fire = 8
spelldata.DamageTypes.Holy = 9
spelldata.DamageTypes.Light = 10
spelldata.DamageTypes.Magic = 11
spelldata.DamageTypes.Mental = 12
spelldata.DamageTypes.Negative = 13
spelldata.DamageTypes.Pierce = 14
spelldata.DamageTypes.Slash = 15
spelldata.DamageTypes.Shadow = 16
spelldata.DamageTypes.Sonic = 17
spelldata.DamageTypes.Water = 18
spelldata.DamageTypes.Poison = 19
spelldata.DamageTypes.Disease = 20
spelldata.DamageTypes.Weapon = 21
spelldata.DamageTypes.Special = 22

---@type table<number, string>
local dtype_to_text = {}

dtype_to_text[spelldata.DamageTypes.None] = "None"
dtype_to_text[spelldata.DamageTypes.Acid] = "Acid"
dtype_to_text[spelldata.DamageTypes.Air] = "Air"
dtype_to_text[spelldata.DamageTypes.Bash] = "Bash"
dtype_to_text[spelldata.DamageTypes.Cold] = "Cold"
dtype_to_text[spelldata.DamageTypes.Disease] = "Disease"
dtype_to_text[spelldata.DamageTypes.Earth] = "Earth"
dtype_to_text[spelldata.DamageTypes.Electric] = "Electric"
dtype_to_text[spelldata.DamageTypes.Energy] = "Energy"
dtype_to_text[spelldata.DamageTypes.Fire] = "Fire"
dtype_to_text[spelldata.DamageTypes.Holy] = "Holy"
dtype_to_text[spelldata.DamageTypes.Light] = "Light"
dtype_to_text[spelldata.DamageTypes.Magic] = "Magic"
dtype_to_text[spelldata.DamageTypes.Mental] = "Mental"
dtype_to_text[spelldata.DamageTypes.Negative] = "Negative"
dtype_to_text[spelldata.DamageTypes.Pierce] = "Pierce"
dtype_to_text[spelldata.DamageTypes.Poison] = "Poison"
dtype_to_text[spelldata.DamageTypes.Shadow] = "Shadow"
dtype_to_text[spelldata.DamageTypes.Slash] = "Slash"
dtype_to_text[spelldata.DamageTypes.Sonic] = "Sonic"
dtype_to_text[spelldata.DamageTypes.Special] = "Special"
dtype_to_text[spelldata.DamageTypes.Water] = "Water"
dtype_to_text[spelldata.DamageTypes.Weapon] = "Weapon"

---Return a string to use for a given damage type
---@param dt number
---@return string
function spelldata.DamageTypeToText(dt)
    if (type(dt) ~= "number") or (dt < 0) or (dt > 22) then
        return "Invalid"
    end

    return dtype_to_text[dt]
end

--#region Helper functions

local function AddSpellData(is_spell, id, name, mage, cleric, thief, warrior, ranger, paladin, psi, nofail, damage_type, subclasses)
    ---@type SpellData
    local d = {}
    d.id = id
    d.name = name
    d.mage = mage
    d.cleric = cleric
    d.thief = thief
    d.warrior = warrior
    d.ranger = ranger
    d.paladin = paladin
    d.psi = psi
    d.is_spell = is_spell
    d.nofail = nofail or false
    d.damage_type = damage_type or spelldata.DamageTypes.None
    d.subclasses = subclasses
    data[id] = d
    name_to_id[string.lower(name)] = id
end

local function AddSpell(id, name, mage, cleric, thief, warrior, ranger, paladin, psi, nofail, damage_type, subclasses)
    AddSpellData(true, id, name, mage, cleric, thief, warrior, ranger, paladin, psi, nofail, damage_type, subclasses)
end

local function AddSkill(id, name, mage, cleric, thief, warrior, ranger, paladin, psi, nofail, damage_type, subclasses)
    AddSpellData(false, id, name, mage, cleric, thief, warrior, ranger, paladin, psi, nofail, damage_type, subclasses)
end
--#endregion

--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell(   3,               "Acid blast",  62, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Acid, { "Elementalist", "Enchanter", "Sorcerer" })
AddSpell( 317,                   "Absorb",  48,  38, nil, nil, nil, nil, nil, false)
AddSpell( 404,              "Abomination", nil, nil, nil, nil, nil, 157, nil,  true, spelldata.DamageTypes.Mental)
AddSpell( 258,               "Accelerate", nil, nil, nil, nil, nil, nil,  31, false)
AddSpell( 320,              "Acid stream", 184, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Acid)
AddSpell(  83,                "Acid wave", 126, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Acid)
AddSpell( 200,             "Acidic touch", nil, nil, nil, nil, nil, nil,  55,  true, spelldata.DamageTypes.Acid)
AddSpell( 249,                "Acidproof", 119, 127, nil, nil, nil, nil, 117, false)
AddSpell(  97,       "Adrenaline control", nil, nil, nil, nil, nil, nil,  13, false)
AddSkill( 496,               "Aggrandize", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  98,                "Agitation", nil, nil, nil, nil, nil, nil,  15,  true, spelldata.DamageTypes.Negative)
AddSpell( 155,                      "Aid", nil,  15, nil, nil, nil,  13, nil, false)
AddSkill( 338,                      "Aim", nil, nil, 115,  22, 125,  38, nil, false)
AddSpell( 465,                 "Air dart", nil, nil, nil, nil,   5, nil, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 592,               "Air skewer", 175, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Air, { "Elementalist" })
AddSkill( 547,                   "Ambush", nil, nil, nil, nil,  37, nil, nil, false, spelldata.DamageTypes.None, { "Hunter" })
AddSpell( 600,                  "Amnesia", nil, nil, nil, nil, nil, nil,  89, false, spelldata.DamageTypes.None, { "Mentalist" })
AddSpell( 190,             "Angel breath", nil,  44, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Magic)
AddSpell( 373,                "Angelfire", nil,  88, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Magic)
AddSpell( 138,        "Animal friendship", nil, nil, nil, nil,  20, nil, nil, false)
AddSpell( 293,           "Animate object", nil, nil, nil, nil, nil, nil,  57, false)
AddSkill( 488,                   "Anoint", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 167,          "Antimagic shell", 114, nil, nil, nil, nil, nil, nil, false)
AddSkill( 608,                   "Apathy", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 406,               "Apocalypse", nil, nil, nil, nil, nil, 189, nil,  true, spelldata.DamageTypes.Shadow, { "Guardian", "Knight", "Avenger" })
AddSkill( 583,                  "Archery", nil, nil, nil, nil,   5, nil, nil, false, spelldata.DamageTypes.None, { "Hunter" })
AddSpell(   4,                    "Armor", nil,   5, nil, nil, nil, nil, nil, false)
AddSkill( 285,              "Assassinate", nil, nil, 155, nil, nil, nil, nil, false, spelldata.DamageTypes.None, { "Bandit" })
AddSkill( 272,                  "Assault", nil, nil, nil,  88, nil, nil, nil,  true, spelldata.DamageTypes.Slash)
AddSpell( 532,        "Augmented healing", nil,  59, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.None, { "Priest" })
AddSpell(  99,               "Aura sight", nil, nil, nil, nil, nil, nil,  48, false)
AddSpell( 168,                "Avoidance",  15, nil, nil, nil, nil, nil, nil, false)
AddSpell( 426,                "Awakening", 124, nil, nil, nil, nil, nil, nil, false)
AddSkill( 501,                "Awareness", nil, nil, nil, nil, nil,  66, nil, false)
AddSpell( 100,                      "Awe", nil, nil, nil, nil, nil, nil,  21, false)
AddSkill( 607,                     "Awol", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 201,                      "Axe", nil, nil, nil,   2,   1, nil, nil, false)
AddSkill( 209,                 "Backstab", nil, nil,  23, nil, nil, nil, nil, false, spelldata.DamageTypes.Weapon)
AddSpell( 231,                 "Balefire", 137, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell( 101,         "Ballistic attack", nil, nil, nil, nil, nil, nil,   1,  true, spelldata.DamageTypes.Bash)
AddSkill( 289,            "Balor spittle", nil, nil, 150, nil, nil, nil, nil, false, spelldata.DamageTypes.Poison, { "Venomist" })
AddSpell( 169,               "Banishment", 188, nil, nil, nil, nil, nil, nil, false)
AddSpell( 170,             "Banshee wail",  16, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Sonic)
AddSpell( 139,                 "Barkskin", nil, nil, nil, nil,  11, nil, nil, false)
AddSkill( 210,                     "Bash", nil, nil, nil,  11, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSkill( 256,                 "Bashdoor", nil, nil, nil,  26, nil, nil, nil, false)
AddSkill( 616,          "Battle training", nil, nil, nil,   7, nil, nil, nil, false, spelldata.DamageTypes.None, { "Soldier" })
AddSkill( 463,              "Battlefaith", nil, nil, nil, nil, nil, nil, nil, false) -- special
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 534,     "Beacon of homecoming", nil, nil, nil, nil, nil, nil,  14, false, spelldata.DamageTypes.None, { "Navigator" })
AddSpell( 536,          "Beacon of light", nil, nil, nil, nil, nil, nil,  36, false, spelldata.DamageTypes.None, { "Navigator" })
AddSkill( 211,                  "Berserk", nil, nil, nil,  58,  68, nil, nil, false)
AddSpell( 102,              "Biofeedback", nil, nil, nil, nil, nil, nil,  51, false)
AddSpell(  90,              "Black lotus", nil, nil, nil, nil, nil, nil, nil,  true)
AddSkill( 280,               "Black root", nil, nil,  30, nil, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSkill( 476,                "Blackrose", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 328,          "Blades of light", nil, nil, nil, nil, nil, 178, nil, false, spelldata.DamageTypes.Slash)
AddSpell( 549,             "Blast undead", nil, nil, nil, nil, nil, nil, 121,  true, spelldata.DamageTypes.Special, { "Necromancer" })
AddSpell( 473,             "Blazing fury", nil, nil, nil, nil, nil, 169, nil,  true, spelldata.DamageTypes.Light)
AddSpell(   5,                    "Bless", nil,   7, nil, nil, nil,   6, nil, false)
AddSpell( 188,             "Bless weapon", nil,  19, nil, nil, nil, nil, nil, false)
AddSpell(   6,                "Blindness",  27,  10, nil, nil, nil, nil, nil, false)
AddSpell( 368,                   "Blight", nil,  81, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSkill( 597,            "Blindfighting", nil, nil,  22, nil, nil, nil, nil, false, spelldata.DamageTypes.None, { "Ninja" })
AddSkill( 260,                    "Blink",   1, nil, nil, nil, nil, nil, nil, false)
AddSkill( 257,                "Blockexit", nil, nil, nil,  29, nil, nil, nil, false)
AddSpell( 171,                     "Blur",   9, nil, nil, nil, nil, nil, nil, false)
AddSkill( 451,                "Bodycheck", nil, nil, nil, 151, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSkill( 582,                      "Bow", nil, nil, nil, nil,   1, nil, nil, false)
AddSkill( 302,                     "Brew", nil,  55, nil, nil, nil, nil, nil, false)
AddSpell(   7,            "Burning hands",   9, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSkill( 279,              "Burnt marbu", nil, nil,  15, nil, nil, nil, nil,  true, spelldata.DamageTypes.Poison)
AddSkill( 239,                  "Butcher", nil, nil, nil, 121, 143, nil, nil, false)
AddSkill( 603,                   "Bypass", nil, nil, nil, nil, nil, nil,   1, false, spelldata.DamageTypes.None, { "Navigator" })
AddSpell(   8,           "Call lightning", nil, nil, nil, nil,  99, nil, nil, false, spelldata.DamageTypes.Electric, { "Shaman", "Hunter", "Crafter" })
AddSpell( 435,              "Calculation", nil, nil, nil, nil, nil, nil,  61, false)
AddSpell( 156,          "Call upon faith", nil, nil, nil, nil, nil,  30, nil, false, spelldata.DamageTypes.None, { "Guardian", "Knight", "Avenger" })
AddSkill( 459,               "Camouflage", nil, nil, nil, nil,  11, nil, nil, false)
AddSkill( 246,                     "Camp", 169, 167, 149, 149, 139, 141, 151, false)
AddSpell(  10,             "Cancellation",  40,  35, nil, nil, nil,  65, nil, false)
AddSkill( 266,              "Cannibalize", nil, nil, nil, nil, nil, nil,   6, false)
AddSpell(  11,           "Cause critical", nil,  40, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell( 294,              "Cause decay", nil, nil, nil, nil, nil, nil,  49,  true, spelldata.DamageTypes.Disease)
AddSpell(  12,              "Cause light", nil,   1, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell(  13,            "Cause serious", nil,  17, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell( 376,             "Caustic rain", nil, 136, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Water)
AddSpell( 103,          "Cell adjustment", nil, nil, nil, nil, nil, nil,  11, false)
AddSkill( 556,           "Cell potential", nil, nil,   9, nil, nil, nil, nil, false, spelldata.DamageTypes.None, { "Venomist" })
AddSkill( 104,          "Chameleon power", nil, nil, nil, nil, nil, nil,  30, false)
AddSpell( 157,       "Champions strength", nil, nil, nil, nil, nil,  71, nil, false)
AddSpell(  14,               "Change sex", nil, nil, nil, nil, nil, nil, nil, false)
AddSpell( 437,           "Channel energy", nil, nil, nil, nil, nil, nil,  81, false)
AddSpell( 334,             "Chaos portal", 192, nil, nil, nil, nil, nil, 182, false)
AddSkill( 267,                   "Charge", nil, nil, nil, nil, nil,  73, nil, false, spelldata.DamageTypes.None, { "Knight" })
AddSpell( 182,      "Chariot of sustarre", nil,  96, nil, nil, nil, nil, nil, false)
AddSpell(  15,             "Charm person",  44,  14,  67, nil, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell(  16,              "Chill touch",   4, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Cold)
AddSkill( 505,             "Choreography", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 291,                   "Circle", nil, nil,   9, nil, nil, nil, nil,  true, spelldata.DamageTypes.Pierce)
AddSkill( 494,              "Clandestine", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 158,                "Cleansing", nil, nil, nil, nil, nil,  47, nil, false)
AddSkill( 325,                   "Cleave", nil, nil, nil, 165, nil, nil, nil,  true, spelldata.DamageTypes.Slash)
AddSkill( 284,               "Cobra bane", nil, nil,  63, nil, nil, nil, nil,  true, spelldata.DamageTypes.Poison)
AddSpell(  17,             "Colour spray",  29, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Light)
AddSpell( 520,           "Combat empathy", nil, nil, nil, nil, nil, nil,   9, false, nil, { "Mentalist"})
AddSpell( 105,              "Combat mind", nil, nil, nil, nil, nil, nil,  53, false, nil, { "Mentalist", "Necromancer", "Navigator" })
AddSpell( 183,                  "Command", nil,  17, nil, nil, nil, nil, nil, false)
AddSkill( 474,            "Comprehension", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 439,              "Compression", nil, nil, nil, nil, nil, nil, 103, false)
AddSpell( 413,                  "Conceal", nil, nil,  26, nil, nil, nil, nil, false)
AddSpell( 396,                  "Condemn", nil, nil, nil, nil, nil,  35, nil,  true, spelldata.DamageTypes.Shadow)
AddSpell( 172,             "Cone of cold",  69, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Cold)
AddSpell( 149,        "Conjure elemental",  80,  68, nil, nil, nil, nil, nil, false)
AddSkill( 510,                 "Conspire", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  18,          "Continual light",   5,   9, nil, nil,   6, nil, nil, false)
AddSpell( 107,           "Control flames", nil, nil, nil, nil, nil, nil,  34,  true, spelldata.DamageTypes.Fire)
AddSkill( 621,               "Conviction", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 327,           "Counter strike", nil, nil, nil, 137, 164, 157, nil, false)
AddSpell(  20,              "Create food", nil,  10, nil, nil, nil, nil, nil, false)
AddSpell( 159,       "Create holy symbol", nil, nil, nil, nil, nil,  57, nil, false)
AddSpell( 417,          "Create poultice", nil, 170, 174, nil, 182, nil, nil, false)
AddSpell( 108,             "Create sound", nil, nil, nil, nil, nil, nil,  31, false)
AddSpell(  22,             "Create water", nil,  11, nil, nil, nil, nil, nil, false)
AddSpell( 507,          "Creators wisdom", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  23,           "Cure blindness", 201,   6, 201, 201, 201,  23, 201, false)
AddSpell(  24,            "Cure critical", nil,  40, nil, nil, nil,  53, nil,  true)
AddSpell(  25,             "Cure disease", nil,  30, nil, nil,  43, nil, nil, false)
AddSpell( 340,            "Cure epidemic", nil, 106, nil, nil, 104, nil, nil, false)
AddSpell(  26,               "Cure light", nil,   3, nil, nil,   8,   5, nil,  true)
AddSpell(  27,              "Cure poison", nil,  24, nil, nil,  23,  37, nil, false)
AddSpell(  28,             "Cure serious", nil,  20, nil, nil, nil, nil, nil,  true)
AddSpell( 467,            "Cure weakness", nil,  13, nil, nil, nil, nil, nil, false)
AddSpell(  29,                    "Curse", nil,  21, nil, nil, nil, nil, nil, false)
AddSpell( 189,               "Curse item", nil,  31, nil, nil, nil, nil, nil, false)
AddSpell( 578,           "Curse of sloth",  99, nil, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.None, { "Sorcerer" })
AddSpell( 386,                  "Cyclone", nil, nil, nil, nil, 105, nil, nil, false, spelldata.DamageTypes.Air)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSkill( 466,                     "Daes", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 202,                   "Dagger",   1, nil,   1,   4,   5, nil,  10, false)
AddSpell( 402,                "Damnation", nil, nil, nil, nil, nil, 131, nil,  true, spelldata.DamageTypes.Negative)
AddSpell( 194,          "Dampening field", nil, nil, nil, nil, nil, nil,  34, false)
AddSpell( 140,                 "Darkness", nil, nil, nil, nil,   7, nil, nil, false)
AddSkill( 290,               "Death blow", nil, nil, nil, 180, nil, nil, nil, false, nil, { "Barbarian", "Soldier", "Blacksmith" })
AddSpell( 109,              "Death field", nil, nil, nil, nil, nil, nil,  99, false, spelldata.DamageTypes.Negative)
AddSkill( 571,                  "Deceive", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  30,                "Demonfire", nil,  88, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Negative)
AddSkill( 617,                "Demonform", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 613,               "Demoralize", nil, nil, nil, nil, nil, nil,  69, false, nil, { "Mentalist" })
AddSpell( 567,              "Desecration", nil,  23, nil, nil, nil, nil, nil, false, nil, { "Harmer" })
AddSpell( 362,               "Desolation", nil, nil, nil, nil, nil, nil, 179,  true, spelldata.DamageTypes.Mental, { "Mentalist", "Necromancer", "Navigator" })
AddSpell(  31,              "Detect evil", nil,  16, nil, nil, nil,   4,  15, false)
AddSpell(  32,              "Detect good", nil,  16, nil, nil, nil,   4,  12, false)
AddSpell(  33,            "Detect hidden",  19,  13,  27, nil, nil, nil, nil, false)
AddSpell(  34,             "Detect invis",   6,   4,  28, nil, nil, nil, nil, false)
AddSpell(  35,             "Detect magic",   6,   4,  26, nil, nil,   8, nil, false)
AddSpell(  36,            "Detect poison", nil,  22,  16, nil,  10, nil, nil, false)
AddSpell( 540,            "Detect undead", nil, nil, nil, nil, nil, nil,  42, false, nil, { "Necromancer" })
AddSpell( 110,                 "Detonate", nil, nil, nil, nil, nil, nil,  86,  true, spelldata.DamageTypes.Energy)
AddSkill( 212,             "Dirt kicking", nil, nil,  25,  17, nil, nil, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 213,                   "Disarm", nil, nil, nil,  46,  46,  41, nil, false)
AddSpell(  65,                  "Disease", nil,  72, nil, nil, nil, nil, nil, false)
AddSpell( 111,             "Disintegrate", nil, nil, nil, nil, nil, nil, 167, false)
AddSpell(  37,              "Dispel evil", nil,  46, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Holy)
AddSpell( 184,              "Dispel good", nil,  46, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Shadow)
AddSpell(  38,             "Dispel magic",  30,  29, nil, nil, nil,  64, nil, false)
AddSpell( 112,             "Displacement", nil, nil, nil, nil, nil, nil,  32, false)
AddSpell( 412,                  "Disrupt", 136, 131, nil, nil, nil, nil, 130, false)
AddSpell( 238,                 "Dissolve", nil,   9,  11, nil,  12, nil, nil, false)
AddSpell( 160,             "Divine faith", nil, nil, nil, nil, nil,  34, nil, false, nil, { "Guardian", "Knight", "Avenger" })
AddSpell( 430,         "Divine swiftness", nil,  62, nil, nil, nil, nil, nil, false)
AddSkill( 332,                 "Divining", nil, nil, nil, nil,  55, nil, nil, false)
AddSkill( 214,                    "Dodge",   1,   1,   1,   1,   1,   1,   1, false)
AddSpell( 113,               "Domination", nil, nil, nil, nil, nil, nil,  33, false)
AddSpell( 295,                  "Doorway", nil, nil, nil, nil, nil, nil,  27, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSkill( 224,               "Dual wield", 201, 201,  29,  32,  25,  35, 201, false)
AddSpell( 141,               "Dust devil", nil, nil, nil, nil,  19, nil, nil, false)
AddSpell(  39,               "Earthquake", nil, nil, nil, nil,  29, nil, nil, false, spelldata.DamageTypes.Earth)
AddSpell( 527,              "Earth focus", nil, nil, nil, nil, nil, nil, nil, false) -- Removed from the game
AddSpell( 380,                "Earth maw", nil, nil, nil, nil,  11, nil, nil,  true, spelldata.DamageTypes.Earth)
AddSpell( 387,             "Earth shroud", nil, nil, nil, nil, 118, nil, nil,  true, spelldata.DamageTypes.Earth)
AddSpell( 591,           "Earthen hammer", 180, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Earth, { "Elementalist" })
AddSpell( 114,         "Ectoplasmic form", nil, nil, nil, nil, nil, nil,  50, false)
AddSpell( 115,                 "Ego whip", nil, nil, nil, nil, nil, nil,  12, false, spelldata.DamageTypes.Mental)
AddSpell( 322,                "Ego boost", nil, 119, nil, nil, nil, nil, 104, false)
AddSpell( 526,          "Elemental focus",  20, nil, nil, nil, nil, nil, nil, false, nil, { "Elementalist" })
AddSpell( 530,           "Elemental ward",  40, nil, nil, nil, nil, nil, nil, false, nil, { "Elementalist" })
AddSpell(  40,            "Enchant armor",  53, nil, nil, nil, nil, nil, nil, false)
AddSpell(  41,           "Enchant weapon",  50, nil, nil, nil, nil, nil, nil, false)
AddSpell( 575,         "Enchanters focus", 121, nil, nil, nil, nil, nil, nil, false, nil, { "Enchanter" })
AddSpell( 440,              "Energy ball", nil, nil, nil, nil,  36, nil, nil, false, nil, { "Crafter", "Hunter", "Shaman" })
AddSpell( 116,       "Energy containment", nil, nil, nil, nil, nil, nil,  41, false)
AddSpell( 252,            "Energy shield", nil, nil, nil, nil, nil, 124, 120, false)
AddSpell( 375,                   "Engulf", nil, 112, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSkill( 287,        "Enhanced backstab", nil, nil,  70, nil, nil, nil, nil, false, spelldata.DamageTypes.Weapon, { "Bandit", "Ninja", "Venomist" })
AddSkill( 215,          "Enhanced damage", 201, 201,  14,   6,  21,  19, 201, false)
AddSpell( 118,        "Enhanced strength", nil, nil, nil, nil, nil, nil,  10, false)
AddSpell( 424,            "Enlightenment", nil,  31, nil, nil, nil, nil, nil, false)
AddSkill( 523,                   "Enrage", nil, nil, nil,  23, nil, nil, nil, false, nil, { "Barbarian" })
AddSkill( 521,                   "Entrap", nil, nil, 130, nil, nil, nil, nil, false, nil, { "Bandit" })
AddSkill( 216,                  "Envenom", nil, nil,  36, nil, nil, nil, nil, false)
AddSkill( 500,              "Equilibrium", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 392,                 "Eruption", nil, nil, nil, nil, 187, nil, nil,  true, spelldata.DamageTypes.Earth, { "Crafter", "Hunter", "Shaman" })
AddSkill( 509,                 "Espresso", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 492,               "Exaltation", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 369,                 "Exorcise", nil, 124, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Holy)
AddSkill( 419,                   "Exotic",   1,   1,   1,   1,   1,   1,   1, false)
AddSpell( 374,               "Extinguish", nil, 101, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Water)
AddSpell( 543,         "Eye of discovery", nil,  63, nil, nil, nil, nil, nil, false, nil, { "Oracle" })
AddSpell( 542,           "Eye of passage", nil,  14, nil, nil, nil, nil, nil, false, nil, { "Oracle" })
AddSpell( 557,           "Eye of warning", nil,  39, nil, nil, nil, nil, nil, false, nil, { "Oracle" })
AddSkill( 304,             "Fast healing",  40, nil,  60,  35,  45,  45, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSkill( 471,                     "Fate", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 562,                    "Fence", nil, nil,  31, nil, nil, nil, nil, false, nil, { "Bandit" })
AddSkill( 243,             "Fifth attack", nil, nil, nil, 101, nil, nil, nil, false, nil, { "Barbarian", "Soldier", "Blacksmith" })
AddSpell(  95,          "Finger of death", nil, 182, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Mental)
AddSkill(   1,                     "Fire",  63,  62,  56,  34,  41,  43,  61, false)
AddSpell( 379,               "Fire blast", nil,  75, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell(  84,              "Fire breath", 107, nil, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Fire)
AddSpell( 528,               "Fire focus", nil, nil, nil, nil, nil, nil, nil, false) -- Remove from the game
AddSpell( 453,                "Fire rain", nil, nil, nil, nil, 117, nil, nil, false, spelldata.DamageTypes.Fire)
AddSpell( 148,               "Fire storm", nil, nil, nil, nil,  44, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell(  45,                 "Fireball",  38, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell(  46,                "Fireproof", nil,  62, nil, nil, nil, nil, nil, false)
AddSkill( 203,                    "Flail", nil,   5, nil,   7, nil,   1,  11, false)
AddSpell( 173,              "Flame arrow",  58, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell( 142,              "Flame blade", nil, nil, nil, nil,   7, nil, nil, false)
AddSpell(  47,              "Flamestrike", nil,  54, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell( 346,           "Flaming sphere",  76, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSkill( 570,                    "Flank", nil, nil, nil,  41, nil, nil, nil, false, nil, { "Soldier" })
AddSkill( 586,                     "Flay", nil, nil, nil, nil, nil,  81, nil,  true, spelldata.DamageTypes.Weapon, { "Avenger" })
AddSpell( 119,              "Flesh armor", nil, nil, nil, nil, nil, nil,  37, false)
AddSpell(  48,                      "Fly",  36, nil, nil, nil, nil, nil, nil, false)
AddSpell( 576,           "Focused vision", nil,   5, nil, nil, nil, nil, nil, false, nil, { "Oracle" })
AddSkill( 225,                   "Forage", nil, nil, nil, nil,  14, nil, nil, false)
AddSpell( 348,               "Force bolt",  94, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell( 390,               "Forestfire", nil, nil, nil, nil, 162, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSkill( 262,                  "Forging", nil, nil, nil, nil, nil, nil, nil, false) -- strange skill that no one can use
AddSkill( 276,                "Fortitude", nil, nil, nil,  24, nil, nil, nil, false, nil, { "Barbarian", "Soldier", "Blacksmith" })
AddSkill( 275,            "Fourth attack", nil, nil, nil,  65, nil, nil, nil, false)
AddSpell(  49,                   "Frenzy", nil,  57, nil, nil, nil, nil, nil, false)
AddSpell( 518,            "Gaias revenge", nil, nil, nil, nil,  10, nil, nil, false, nil, { "Crafter", "Hunter", "Shaman" })
AddSpell( 552,              "Gaias focus", nil, nil, nil, nil,  56, nil, nil, false, nil, { "Shaman" })
AddSpell( 624,              "Gaias totem", nil, nil, nil, nil,  56, nil, nil, false, nil, { "Shaman" })
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell(  50,                     "Gate",  70,  64, 201, 201, 201, 201, 201, false)
AddSpell(  51,           "Giant strength", nil,  23, nil, nil, nil, nil, nil, false)
AddSkill( 489,                     "Gift", nil, nil, nil, nil, nil, nil, nil, false) -- Special
AddSpell( 394,                    "Glare", nil, nil, nil, nil, nil,  14, nil,  true, spelldata.DamageTypes.Light)
AddSpell( 174, "Globe of invulnerability", 177, nil, nil, nil, nil, nil, 126, false)
AddSkill( 485,                    "Gloom", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 425,            "Godly embrace", nil,  34, nil, nil, nil, nil, nil, false)
AddSpell( 143,                "Goodberry", nil, nil, nil, nil,   5, nil, nil, false)
AddSpell( 533,                      "Gos", nil, nil, nil, nil, nil, nil, nil, false) -- strange skill that no one that use
AddSkill( 450,                    "Gouge", nil, nil, nil, 121, nil, nil, nil, false, spelldata.DamageTypes.Pierce)
AddSkill( 271,                     "Grab", nil, nil, nil,  55, nil, nil, nil, false)
AddSkill( 288,              "Green death", nil, nil,  88, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSpell( 335,                "Grey aura", 142, 144, nil, nil, nil, 102, nil, false)
AddSpell( 382,            "Ground strike", nil, nil, nil, nil,  52, nil, nil,  true, spelldata.DamageTypes.Earth)
AddSkill( 305,                   "Haggle", nil, nil,   5, nil, nil, nil, nil, false)
AddSpell( 162,           "Hallowed light", nil, nil, nil, nil, nil,   3, nil, false)
AddSkill( 589,                   "Hammer", nil, nil, nil,   1, nil, nil, nil, false, nil, { "Blacksmith" })
AddSkill( 590,              "Hammerforge", nil, nil, nil,   1, nil, nil, nil, false, nil, { "Blacksmith" })
AddSkill( 449,           "Hammering blow", nil, nil, nil, 178, nil, nil, nil, false, spelldata.DamageTypes.Bash, { "Barbarian", "Soldier", "Blacksmith" })
AddSkill( 614,              "Hammerswing", nil, nil, nil,  51, nil, nil, nil, false, nil, { "Blacksmith" })
AddSpell( 163,          "Hand of justice", nil, nil, nil, nil, nil,  73, nil, false, spelldata.DamageTypes.Holy)
AddSkill( 217,             "Hand to hand", nil, nil,  10,   1,  32,  33, nil, false)
AddSpell( 422,              "Harden body",  32, nil, nil, nil, nil, nil, nil, false)
AddSpell(  52,                     "Harm", nil,  59, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell(  53,                    "Haste",  35,  25, nil, nil, nil, nil, nil, false)
AddSpell( 568,                    "Haven", nil, 130, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSkill( 448,                 "Headbutt", nil, nil, nil, 112, nil, nil, nil, false, spelldata.DamageTypes.Bash)
AddSpell(  54,                     "Heal", nil,  60, nil, nil, nil, nil, nil,  true)
AddSpell( 502,            "Healing touch", nil, 136, nil, nil, nil, nil, nil,  true, nil, { "Priest", "Oracle", "Harmer" })
AddSpell( 152,              "Heat shield", nil, nil, nil, nil,  85, nil, nil, false)
AddSpell( 161,         "Heavenly balance", nil, nil, nil, nil, nil, 189, nil,  true, spelldata.DamageTypes.Light, { "Guardian", "Knight", "Avenger" })
AddSpell( 574,         "Heavenly smiting", nil,  51, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Holy, { "Priest" })
AddSkill( 120,          "Heighten senses", nil, nil, nil, nil, nil, nil,  20, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSkill( 330,            "Herbal remedy", nil, 103, 101, nil, nil, nil, nil, false)
AddSpell( 579,           "Hex of entropy", 146, nil, nil, nil, nil, nil, nil, false, nil, { "Sorcerer" })
AddSpell( 580,        "Hex of misfortune", 171, nil, nil, nil, nil, nil, nil, false, nil, { "Sorcerer" })
AddSkill( 306,                     "Hide", nil, nil,   9, nil, nil, nil, nil, false)
AddSpell( 164,                "Holy aura", nil, nil, nil, nil, nil,  80, nil, false)
AddSpell( 454,               "Holy arrow", nil, nil, nil, nil, nil,  89, nil,  true, spelldata.DamageTypes.Holy)
AddSpell( 393,                "Holy fury", nil, nil, nil, nil, nil,   9, nil,  true, spelldata.DamageTypes.Holy)
AddSkill( 516,        "Holy intervention", nil, nil, nil, nil, nil,   7, nil, false)
AddSpell( 255,              "Holy mirror", 131, 129, nil, nil, nil, 146, 142, false)
AddSkill( 619,          "Holy preference", nil,  21, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSpell( 364,                "Holy rain", nil,  11, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Water)
AddSkill( 618,            "Holy reprisal", nil, nil, nil, nil, nil,  11, nil, false, nil, { "Avenger" })
AddSkill( 261,                "Holy rift", nil,   1, nil, nil, nil, nil, nil, false)
AddSpell( 569,              "Holy shield", nil, 121, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSpell( 472,              "Holy strike", nil, nil, nil, nil, nil, 141, nil,  true, spelldata.DamageTypes.Holy)
AddSpell( 165,                "Holy word", 160, nil, nil, nil, nil, 151, nil, false, spelldata.DamageTypes.Holy)
AddSpell( 535,               "Homecoming", nil, nil, nil, nil, nil, nil,  14, false, nil, { "Navigator" })
AddSkill( 481,                   "Houyou", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 602,                 "Humility", nil,   9, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSkill( 301,                     "Hunt", 201, 201,  42,  68,  20, 201, 201, false)
AddSpell( 513,               "Huntmaster", nil, nil, nil, nil,  25, nil, nil, false, nil, { "Hunter" })
AddSkill( 281,              "Hydra blood", nil, nil,  51, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSpell( 385,               "Hydroblast", nil, nil, nil, nil,  96, nil, nil,  true, spelldata.DamageTypes.Water)
AddSpell( 389,                 "Ice bolt", nil, nil, nil, nil, 147, nil, nil,  true, spelldata.DamageTypes.Cold)
AddSpell(  85,                "Ice cloud",  92, nil, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Cold)
AddSpell( 593,              "Ice daggers", 185, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Water, { "Elementalist" })
AddSpell( 150,                "Ice storm", nil, nil, nil, nil,  59, nil, nil, false, spelldata.DamageTypes.Cold)
AddSpell(  56,                 "Identify",  22, nil, nil, nil, nil, nil, nil, false)
AddSpell( 336,               "Illuminate", nil, 125, nil, nil, nil, 111, nil, false)
AddSkill( 464,                    "Imbue", nil, nil, nil, nil, nil, nil, nil, false) -- no one can use...
AddSpell( 361,                 "Immolate", 191, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire, { "Elementalist", "Enchanter", "Sorcerer" })
AddSpell( 106,       "Incomplete healing", nil, nil, nil, nil, nil, nil, 190, false)
AddSpell(  91,      "Indestructible aura", nil,  48, nil, nil, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 121,         "Inertial barrier", nil, nil, nil, nil, nil, nil,  26, false)
AddSpell( 397,           "Infernal voice", nil, nil, nil, nil, nil,  46, nil,  true, spelldata.DamageTypes.Sonic)
AddSpell( 122,             "Inflict pain", nil, nil, nil, nil, nil, nil,  21,  true, spelldata.DamageTypes.Mental)
AddSkill( 524,                 "Insanity", nil, nil, nil, 104, nil, nil, nil, false, nil, { "Barbarian" })
AddSkill( 462,              "Inspiration", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 123,       "Intellect fortress", nil, nil, nil, nil, nil, nil,  46, false)
AddSkill( 594,                   "Intent", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 587,              "Interrogate", nil, nil, nil, nil, nil,  12, nil, false, nil, { "Avenger" })
AddSkill( 483,             "Intervention", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 274,               "Intimidate", nil, nil, nil,  29, nil, nil, nil, false)
AddSpell(  58,                    "Invis",  25, nil, nil, nil, nil, nil, nil, false)
AddSkill( 596,                 "Ironfist", nil, nil, nil,  39, nil, nil, nil, false, nil, { "Barbarian" })
AddSkill( 218,                     "Kick", nil, nil,   7,   1,   1,   1, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 595,           "Knife fighting", nil, nil,  33, nil, nil, nil, nil, false, nil, { "Bandit", "Ninja", "Venomist" })
AddSpell( 411,                    "Knock",  23, nil, nil, nil, nil, nil,  38, false)
AddSpell(  59,           "Know alignment", nil,  18, nil, nil, nil, nil, nil, false)
AddSkill( 457,             "Kobold spray", nil, nil,  99, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSkill( 278,            "Kobold stench", nil, nil,   1, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease, { "Bandit", "Ninja", "Venomist" })
AddSkill( 585,                     "Lash", nil, nil, nil, nil, nil,   6, nil, false, spelldata.DamageTypes.Weapon, { "Avenger" })
AddSkill( 228,                "Lay hands", nil, nil, nil, nil, nil,   1, nil, false)
AddSpell( 124,              "Lend health", nil, nil, nil, nil, nil, nil,   9, false)
AddSpell( 125,               "Levitation", nil, nil, nil, nil, nil, nil,  22, false)
AddSpell( 331,              "Light arrow", nil,  93, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Light)
AddSpell(  60,           "Lightning bolt",  52, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Electric)
AddSpell( 232,         "Lightning strike", 156, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Electric)
AddSpell( 259,               "Lightspeed", 140, 141, nil, nil, nil, nil, 149, false)
AddSpell( 185,       "Line of protection", nil,  83, nil, nil, nil, nil, nil, false)
AddSkill( 610,                     "Link", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  61,            "Locate object",  59, 201, 201, 201, 201, 201, 201, false)
AddSpell( 151,            "Locate animal", 201, 201, 201, 201,  75, 201, 201, false)
AddSpell( 240,            "Locate corpse", 201, 109, 201, 201, 117, 114, 113, false)
AddSkill( 307,                     "Lore", nil, nil,  20,  42,  35, nil, nil, false)
AddSkill( 204,                     "Mace", nil,   1,  10,   5, nil,   6,   5, false)
AddSpell(  62,            "Magic missile",   1, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSpell( 423,             "Magic circle", nil,  19, nil, nil, nil, nil, nil, false)
AddSpell( 428,             "Magical rush",  41, nil, nil, nil, nil, nil, nil, false)
AddSpell( 175,           "Major creation",  78, nil, nil, nil, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 192,              "Major swarm", nil,  50, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSkill( 475,                 "Mandrake", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 458,                "Marbu jet", nil, nil, 131, nil, nil, nil, nil,  true, spelldata.DamageTypes.Poison)
AddSkill( 308,               "Meditation",  22,  15,  53, nil,  48,  14,   8, false)
AddSpell( 233,                "Megablast", nil, nil, nil, nil, nil, nil, 136,  true, spelldata.DamageTypes.Energy)
AddSpell( 611,           "Mental balance", nil, nil, nil, nil, nil, nil,  23, false, nil, { "Mentalist", "Necromancer", "Navigator" })
AddSpell( 126,           "Mental barrier", nil, nil, nil, nil, nil, nil,   3, false)
AddSpell( 545,              "Merge chaos", nil, nil, nil, nil, 201, nil, nil, false, nil, { "Crafter" })
AddSpell( 351,                   "Miasma", 167, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Acid, { "Elementalist", "Enchanter", "Sorcerer" })
AddSpell( 353,              "Mind freeze", nil, nil, nil, nil, nil, nil,  31,  true, spelldata.DamageTypes.Cold)
AddSpell( 197,           "Mind over body", nil, nil, nil, nil, nil, nil,  19, false)
AddSpell( 127,              "Mind thrust", nil, nil, nil, nil, nil, nil,   7,  true, spelldata.DamageTypes.Mental)
AddSkill( 622,                 "Mindflay", nil, nil, nil, nil, nil, nil,  25, false, nil, { "Mentalist" })
AddSpell( 176,           "Minor creation",  32, nil, nil, nil, nil, nil, nil, false)
AddSpell( 191,              "Minor swarm", nil,  24, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSpell( 408,                  "Miracle", nil, 149, nil, nil, nil, 154, nil, false)
AddSkill( 515,             "Misdirection", nil, nil,   3, nil, nil, nil, nil, false)
AddSkill( 324,                "Mist form", 100, 100, nil, nil, nil, nil, nil, false)
AddSpell( 456,                "Mobshield", nil, nil, nil, nil, nil, nil, nil, false) -- Removed from the game
AddSpell( 144,                 "Moonbeam", nil, nil, nil, nil,  18, nil, nil,  true, spelldata.DamageTypes.Light)
AddSpell( 421,             "Mystic might",  21, nil, nil, nil, nil, nil, nil, false)
AddSkill( 606,                   "Napalm", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 445,            "Natures touch", nil, nil, nil, nil,  27, nil, nil, false)
AddSkill( 537,                 "Navigate", nil, nil, nil, nil, nil, nil,  36, false, nil, { "Navigator" })
AddSpell( 539,                "Necrocide", nil, nil, nil, nil, nil, nil, 185,  true, spelldata.DamageTypes.Special, { "Necromancer" })
AddSpell( 195,                 "Negation", nil, nil, nil, nil, nil, nil,  39, false)
AddSpell( 355,              "Nerve shock", nil, nil, nil, nil, nil, nil,  39,  true, spelldata.DamageTypes.Acid)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 354,              "Neural burn", nil, nil, nil, nil, nil, nil,  60,  true, spelldata.DamageTypes.Mental)
AddSpell( 360,          "Neural overload", nil, nil, nil, nil, nil, nil, 151,  true, spelldata.DamageTypes.Mental)
AddSpell(  96,                    "Nexus", nil, nil, nil, nil, nil, nil,  75, false)
AddSpell(  57,             "Night vision",   8, nil, nil, nil,  28, nil, nil, false)
AddSpell( 359,          "Nightmare touch", nil, nil, nil, nil, nil, nil, 124,  true, spelldata.DamageTypes.Negative)
AddSkill( 554,           "Nimble cunning", nil, nil,   6, nil, nil, nil, nil, false, nil, { "Bandit", "Ninja" })
AddSkill( 495,                  "Nirvana", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 349,                     "Nova", 145, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Light)
AddSkill( 598,           "Necrotic touch", nil, nil,  87, nil, nil, nil, nil, false, spelldata.DamageTypes.Poison, { "Venomist" })
AddSkill( 479,                     "Oath", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 296,              "Object read", nil, nil, nil, nil, nil, nil,  24, false)
AddSpell(   9,                   "Pacify", nil,  35, nil, nil, nil,  49, nil, false)
AddSpell( 323,                    "Panic", nil, nil, nil, nil, 135, 137, 139, false)
AddSkill( 219,                    "Parry", nil, nil, nil,   1, nil, nil, nil, false)
AddSpell( 443,            "Party harmony", nil, nil, nil, nil, nil, nil, 158, false)
AddSpell( 446,               "Party heal", nil,  79, nil, nil, nil, nil, nil, false)
AddSpell( 414,          "Party sanctuary", nil, 121, nil, nil, nil, nil, nil, false, nil, { "Priest", "Oracle", "Harmer" })
AddSpell( 444,             "Party shield", nil, nil, nil, nil, nil, nil, 173, false)
AddSpell(  64,                "Pass door", nil, nil,  48, nil, nil, nil, nil, false)
AddSkill( 226,       "Pass without trace", nil, nil, nil, nil,  26, nil, nil, false)
AddSkill( 538,              "Pathfinding", nil, nil, nil, nil,  47, nil, nil, false, nil, { "Hunter" })
AddSkill( 309,                     "Peek", nil, nil,  30, nil, nil, nil, nil, false)
AddSpell( 427,               "Perception",  51, nil, nil, nil, nil, nil, nil, false)
AddSpell( 577,                  "Petrify",  32, nil, nil, nil, nil, nil, nil, false, nil, { "Sorcerer" })
AddSkill( 310,                "Pick lock", nil, nil,  12, nil, nil, nil, nil, false)
AddSkill( 555,                "Pilferage", nil, nil,  10, nil, nil, nil, nil, false, nil, { "Bandit" })
AddSpell( 399,           "Pillar of fire", nil, nil, nil, nil, nil,  78, nil,  true, spelldata.DamageTypes.Fire)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell(  66,                   "Poison",  21, nil, nil, nil, nil, nil, nil, false)
AddSkill( 205,                  "Polearm", nil, nil, nil, nil, nil, nil, nil, false)
AddSpell(  92,                   "Portal",  90, nil, nil,   7,  13,  10, nil, false)
AddSkill( 292,                 "Poultice", nil, nil,  19, nil, nil, nil, nil, false)
AddSkill( 277,               "Power grip", nil, nil, nil,  63, nil, nil, nil, false)
AddSpell( 434,           "Power of faith", nil, nil, nil, nil, nil, 119, nil, false)
AddSpell( 525,         "Power projection",  13, nil, nil, nil, nil, nil, nil, false, nil, { "Sorcerer" })
AddSpell( 564,      "Pray for absolution", nil,  99, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSpell( 565,       "Pray for damnation", nil,  99, nil, nil, nil, nil, nil, false, nil, { "Harmer" })
AddSpell( 429,        "Prayer of fortune", nil,  42, nil, nil, nil, nil, nil, false)
AddSkill( 615,                "Precision", nil, nil, nil,  59, nil, nil, nil, false, nil, { "Soldier" })
AddSkill( 491,                 "Preserve", nil, nil, nil, nil,  36, nil, nil, false)
AddSkill( 490,                    "Pride", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 177,          "Prismatic spray",  34, nil, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Light)
AddSpell(  67,          "Protection evil", nil,   5, nil, nil, nil,  16,   9, false)
AddSpell(  68,          "Protection good", nil,   5, nil, nil,  16,   9,  16, false)
AddSpell( 297,       "Probability travel", nil, nil, nil, nil, nil, nil,  47, false)
AddSpell( 128,            "Project force", nil, nil, nil, nil, nil, nil,  65,  true, spelldata.DamageTypes.Mental)
AddSkill( 477,                 "Prophecy", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 420,       "Protection neutral", nil, nil, nil, nil, nil, nil, nil, false) -- no one can use this, sad :(
AddSpell( 129,            "Psionic blast", nil, nil, nil, nil, nil, nil,  74,  true, spelldata.DamageTypes.Energy)
AddSpell( 130,            "Psychic crush", nil, nil, nil, nil, nil, nil,  43,  true, spelldata.DamageTypes.Negative)
AddSpell( 131,            "Psychic drain", nil, nil, nil, nil, nil, nil,   9, false, spelldata.DamageTypes.Mental)
AddSpell( 132,          "Psychic healing", nil, nil, nil, nil, nil, nil,  15,  true)
AddSpell( 356,                "Psychosis", nil, nil, nil, nil, nil, nil, 108,  true, spelldata.DamageTypes.Mental)
AddSpell( 433,               "Pure faith", nil,  90, nil, nil, nil, nil, nil, false, nil, { "Priest", "Oracle", "Harmer" })
AddSpell( 405,                "Purgatory", nil, nil, nil, nil, nil, 163, nil,  true, spelldata.DamageTypes.Cold)
AddSpell( 370,                    "Purge", nil, 137, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Holy)
AddSpell( 337,                   "Purify", nil,  85,  91, nil, nil,  87,  91, false)
AddSkill( 270,                     "Push", nil, nil, nil,  39, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 234,                "Pyromania", nil, nil, nil, nil, nil, nil, 164,  true, spelldata.DamageTypes.Energy, { "Mentalist", "Necromancer", "Navigator" })
AddSkill( 499,                       "Qi", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 601,                "Quickstab", nil, nil,  56, nil, nil, nil, nil, false, nil, { "Ninja" })
AddSkill( 486,                     "Rage", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 145,                  "Rainbow", nil, nil, nil, nil,  80, nil, nil,  true, spelldata.DamageTypes.Light)
AddSpell( 432,                    "Rally", nil,  77, nil, nil, nil, nil, nil, false, nil, { "Priest", "Oracle", "Harmer" })
AddSkill( 286,            "Raven scourge", nil, nil,  75, nil, nil, nil, nil,  true, spelldata.DamageTypes.Disease)
AddSpell( 137,                "Raw flesh", nil, nil, nil, nil, nil, nil,  81, false, spelldata.DamageTypes.Negative)
AddSkill( 522,                   "Reborn", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 316,                   "Recall",   1,   1,   1,   1,   1,   1,   1, false)
AddSpell( 193,                 "Recharge", nil,  56, nil, nil, nil, nil, nil, false)
AddSkill( 407,                    "Recon", nil, nil, nil, 119, 114, nil, nil, false)
AddSkill( 497,               "Redemption", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  69,                  "Refresh", nil,   9,  24, nil,  12, nil, nil,  true)
AddSpell( 146,             "Regeneration", nil, 179, nil, nil, nil, nil, nil,  true, nil, { "Priest", "Oracle", "Harmer" })
AddSpell( 553,                 "Rehallow", nil,  28, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSkill( 263,                "Reinforce", nil, nil, nil,  53, nil, nil, nil, false)
AddSpell( 416,               "Rejuvenate", nil, 153, 137, nil, 141, nil, nil,  true)
AddSpell(  70,             "Remove curse", nil,  34, nil, nil, nil, nil, nil, false)
AddSpell( 503,                    "Renew", nil, 108, nil, nil, nil, nil, nil,  true)
AddSpell( 400,               "Repentance", nil, nil, nil, nil, nil, 106, nil,  true, spelldata.DamageTypes.Holy)
AddSkill( 220,                   "Rescue", nil, nil, nil,  12,  15,  15, nil, false)
AddSkill( 546,                   "Reskin", nil, nil, nil, nil,  72, nil, nil, false, nil, { "Crafter" })
AddSpell( 415,                 "Resonate", nil, nil, nil, nil, nil, nil, 145, false)
AddSpell( 504,             "Restore life", nil, 164, nil, nil, nil, nil, nil,  true)
AddSpell( 181,             "Resurrection", nil,  26, nil, nil, nil, nil, nil, false)
AddSkill( 241,                  "Retreat", nil, nil, 142, 116, 121, 118, nil, false)
AddSpell( 247,            "Reverse align", nil, 139, nil, nil, nil, nil, nil, false)
AddSpell(  44,                   "Reveal", nil,  27, nil, nil, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 431,               "Revelation", nil,  71, nil, nil, nil, nil, nil, false)
AddSpell( 551,          "Righteous anger", nil, nil, nil, nil, nil,  17, nil, false, nil, { "Avenger" })
AddSpell(  43,               "Rune of ix",  11,   8, nil, nil,  17, nil, nil, false, spelldata.DamageTypes.Energy)
AddSpell( 573,           "Sacrifice life", nil,  34, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSkill( 566,                "Safeguard", nil, nil, nil, nil, nil,  20, nil, false, nil, { "Guardian" })
AddSpell(  71,                "Sanctuary", 201,  45, 201, 201, 201,  55, 201, false)
AddSkill( 273,                      "Sap", nil, nil, nil,  50, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSkill( 300,                    "Scalp", nil, nil, nil,  60, nil, nil, nil,  true, spelldata.DamageTypes.Slash)
AddSpell( 350,                   "Scorch", 119, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSkill( 283,          "Scorpion strike", nil, nil,  11, nil, nil, nil, nil, false, nil, { "Ninja", "Venomist" })
AddSpell( 398,                  "Scourge", nil, nil, nil, nil, nil,  62, nil,  true, spelldata.DamageTypes.Disease)
AddSkill( 343,                    "Scout", nil, nil, nil, nil, 177, nil, nil, false)
AddSkill( 303,                   "Scribe",  53, nil, nil, nil, nil, nil, nil, false)
AddSkill( 313,                  "Scrolls",   2,   7,  29, 201, 201, 201,  12, false)
AddSpell( 236,                     "Scry",  47,  51, nil, nil, nil, nil,  54, false)
AddSkill( 222,            "Second attack", 201, 201,  18,   8,   9,  12, 201, false)
AddSkill( 244,       "Second attack dual", nil, nil, 134, 124, 118, 129, nil, false)
AddSpell( 442,             "Self harmony", nil, nil, nil, nil, nil, nil, 141, false)
AddSpell( 612,                "Sense age", nil, nil, nil, nil, nil, nil,   9, false, nil, { "Mentalist" })
AddSpell( 235,              "Sense anger",  26,  32,  29, nil,  34,  32,  28, false)
AddSpell( 548,             "Sense danger", nil,  33, nil, nil, nil, nil, nil, false, nil, { "Oracle" })
AddSpell( 455,               "Sense life", nil, nil, nil, nil,  21, nil, nil, false)
AddSpell( 572,                 "Serenity", nil, 157, nil, nil, nil, nil, nil, false, nil, { "Priest" })
AddSkill( 133,              "Shadow form", nil, nil, nil, nil, nil, nil,  29, false)
AddSpell( 352,             "Shard of ice", 103, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Cold)
AddSpell( 438,          "Share intellect", nil, nil, nil, nil, nil, nil,  97, false)
AddSpell( 134,           "Share strength", nil, nil, nil, nil, nil, nil,  17, false)
AddSpell( 436,             "Share wisdom", nil, nil, nil, nil, nil, nil,  70, false)
AddSkill( 264,                  "Sharpen", nil, nil, nil,  44, nil, nil, nil, false)
AddSpell(  72,                   "Shield",   3, nil, nil, nil, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSkill( 206,             "Shield block", nil, nil, nil,  13, nil, nil, nil, false, nil, { "Barbarian", "Soldier", "Blacksmith" })
AddSpell( 508,  "Shiftys sleight of hand", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  87,               "Shock aura", 113, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Electric)
AddSpell(  73,           "Shocking grasp",  24, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Electric)
AddSpell( 250,               "Shockproof", 127, nil, nil, nil, 129, 132, nil, false)
AddSkill( 599,              "Shoplifting", nil, nil,  45, nil, nil, nil, nil, false, nil, { "Bandit" })
AddSkill( 604,                   "Shroud", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 517,             "Sixth attack", nil, nil, nil, 131, nil, nil, nil, false, nil, { "Barbarian", "Soldier", "Blacksmith" })
AddSkill( 227,                     "Skin", nil, nil, nil, nil,  35, nil, nil, false)
AddSpell(  74,                    "Sleep",   7, nil, nil, nil, nil, nil, nil, false)
AddSkill( 282,                     "Slit", nil, nil,  77, nil, nil, nil, nil, false)
AddSpell(  75,                     "Slow", nil, nil, nil, nil, nil, nil,  57, false, nil, { "Mentalist" })
AddSkill( 469,                   "Sluagh", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 311,                    "Sneak", nil, nil,  13, nil, nil, nil, nil, false)
AddSpell( 298,                   "Soften", nil, nil, nil, nil, nil, nil,  29, false, spelldata.DamageTypes.Negative)
AddSpell( 339,                 "Solidify", 134, nil, nil, nil, nil, nil, 136, false)
AddSpell( 384,              "Solar flare", nil, nil, nil, nil,  70, nil, nil,  true, spelldata.DamageTypes.Energy)
AddSpell( 395,                 "Soul rip", nil, nil, nil, nil, nil,  23, nil,  true, spelldata.DamageTypes.Mental)
AddSpell( 363,                 "Soulburn", nil,   5, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell( 358,                    "Spasm", nil, nil, nil, nil, nil, nil, 117,  true, spelldata.DamageTypes.Bash)
AddSkill( 207,                    "Spear",   1, nil, nil,  10,  11,  11, nil, false)
AddSpell( 541,            "Spear of odin", 191, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Electric, { "Sorcerer" })
AddSkill( 318,                   "Spiral", nil, nil, 181, nil, nil, nil, nil,  true, spelldata.DamageTypes.Weapon, { "Bandit", "Ninja", "Venomist" })
AddSpell( 484,            "Spirit shield", nil, nil, nil, nil, nil,  43, nil, false)
AddSpell( 365,              "Spirit bolt", nil,  37, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Special)
AddSkill( 418,              "Spirit form", nil, nil, nil, nil, nil, nil, nil, false) -- no one can use this
AddSpell( 401,            "Spirit strike", nil, nil, nil, nil, nil, 118, nil,  true, spelldata.DamageTypes.Energy)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell(  94,          "Spiritual armor", nil, nil, nil, nil, nil,  50, nil, false)
AddSpell( 377,     "Spiritual disruption", nil, 156, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Energy)
AddSpell( 186,                    "Spook",   9, nil, nil, nil, nil, nil, nil, false)
AddSkill( 265,                   "Spunch", nil, nil, nil,  79, nil,  85, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 341,                      "Spy", nil, nil, 162, nil, nil, nil, nil, false)
AddSkill( 558,                    "Stalk", nil, nil,  35, nil, nil, nil, nil, false, nil, { "Ninja" })
AddSpell( 372,                "Starburst", nil, 170, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Light)
AddSkill( 314,                   "Staves",   3,   3, 201, 201, 201,  39,   3, false)
AddSkill( 312,                    "Steal", nil, nil,  18, nil, nil, nil, nil, false)
AddSkill( 559,                  "Stealth", nil, nil,  79, nil, nil, nil, nil, false, nil, { "Ninja" })
AddSkill( 452,                    "Stomp", nil, nil, nil, 137, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSpell(  76,               "Stone skin",  60, nil, nil, nil, nil, nil, nil, false)
AddSkill( 329,                 "Strangle", nil, nil, 115, nil, nil, nil, nil, false)
AddSpell( 550,            "Strike undead", nil, nil, nil, nil, nil, nil,  44,  true, spelldata.DamageTypes.Special, { "Necromancer" })
AddSkill( 268,                     "Stun", nil, nil, nil,  27, nil, nil, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 470,                   "Stupor", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 487,                  "Sumadji", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell(  77,                   "Summon", 201,  36, 201, 201, 201, 201, 201, false)
AddSpell( 584,             "Summon death", nil, nil, nil, nil, nil, nil,  47, false, nil, { "Necromancer" })
AddSpell( 514,              "Summon life", nil, nil, nil, nil,  14, nil, nil, false, nil, { "Shaman" })
AddSpell( 147,                   "Sunray", nil, nil, nil, nil, nil, nil, nil, false) -- Removed from the game
AddSpell( 531,       "Suppressed healing", nil,  51, nil, nil, nil, nil, nil, false, nil, { "Harmer" })
AddSkill( 342,                   "Survey", nil, nil, 152, 133, 137, 149, nil, false)
AddSpell( 321,               "Sustenance",  84, nil, nil, nil,  62, nil, nil, false)
AddSkill( 326,                    "Sweep", nil, nil, 145, nil, nil, nil, nil,  true, spelldata.DamageTypes.Pierce)
AddSkill(   2,                    "Sword", nil, nil, nil,   1,   2,   2, nil, false)
AddSpell(  93,   "Sword of righteousness", nil, nil, nil, nil, nil,  92, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 347,                    "Talon",  85, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Pierce)
AddSkill( 319,                     "Tame", nil, nil, nil, nil, 101, nil, nil, false, nil, { "Crafter", "Hunter", "Shaman" })
AddSkill( 493,                    "Taunt", nil, nil, nil, nil, nil, nil, nil, false) -- Removed from the game
AddSpell( 196,              "Telekinesis", nil, nil, nil, nil, nil, nil,  25, false, spelldata.DamageTypes.Bash)
AddSpell(  78,                 "Teleport",  64, nil, nil, nil, nil, nil, nil, false)
AddSpell(  79,          "Teleport behind",  46, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Magic)
AddSkill( 581,                "Tempering", nil, nil, nil,  15, nil, nil, nil, false, nil, { "Blacksmith" })
AddSpell( 391,                  "Tempest", nil, nil, nil, nil, 173, nil, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 460,                "Terminate", nil, nil, nil, nil, nil,  68, nil, false, spelldata.DamageTypes.Holy, { "Guardian", "Knight", "Avenger" })
AddSpell( 519,            "Test of faith", nil, nil, nil, nil, nil,   3, nil, false, nil, { "Guardian", "Knight", "Avenger" })
AddSkill( 223,             "Third attack", 201, 201,  46,  37,  36,  40, 201, false)
AddSkill( 245,        "Third attack dual", nil, nil, 169, 157, 153, 165, nil, false)
AddSpell( 135,           "Thought shield", nil, nil, nil, nil, nil, nil,  18, false)
AddSkill( 198,               "Time shift", nil, nil, nil, nil, nil, nil,   1, false)
AddSpell( 544,             "Timeshifting", nil, nil, nil, nil, nil, nil,  25, false, nil, { "Navigator" })
AddSpell( 367,                  "Torment", nil,  65, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Negative)
AddSpell( 388,                  "Tornado", nil, nil, nil, nil, 131, nil, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 588,          "Tortured vision", nil, nil, nil, nil, nil, 148, nil, false, nil, { "Avenger" })
AddSpell( 512,              "Totem force", nil, nil, nil, nil,  88, nil, nil, false, nil, { "Shaman" })
AddSpell( 511,           "Totem guidance", nil, nil, nil, nil,  42, nil, nil, false, nil, { "Shaman" })
AddSpell(  86,              "Toxic cloud", 175, nil, nil, nil, nil, nil, nil, false, spelldata.DamageTypes.Poison)
AddSpell( 254,         "Toxic resistance", nil, 159, 156, nil, 170, nil, nil, false)
AddSkill( 468,                "Transcend", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 409,              "Translocate", 129, nil, nil, nil, nil, nil, 122, false)
AddSpell( 153,     "Transport via plants", nil, nil, nil, nil,  50, nil, nil, false)
AddSpell( 357,                   "Trauma", nil, nil, nil, nil, nil, nil,  94,  true, spelldata.DamageTypes.Mental)
AddSkill( 269,             "Treat wounds", nil, nil, nil,  16, nil, nil, nil, false)
AddSkill( 482,                 "Trickery", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 221,                     "Trip", nil, nil,  34,  39, nil, nil, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 345,                   "Trophy", nil, nil, nil, 142, nil, nil, nil, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 178,              "True seeing",  55,  66, nil, nil, nil,  75,  66, false)
AddSpell( 136,               "Ultrablast", nil, nil, nil, nil, nil, nil,  73, false, spelldata.DamageTypes.Mental)
AddSpell( 333,     "Underwater breathing",   7,   8,   4, nil,  13, nil,   4, false)
AddSkill( 620,        "Unholy preference", nil,  21, nil, nil, nil, nil, nil, false, nil, { "Harmer" })
AddSkill( 605,                    "Unify", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 242,           "Unlawful entry", nil, nil, 111, nil, nil, nil, nil, false)
AddSkill( 447,                 "Uppercut", nil, nil, nil, 101, nil, nil, nil,  true, spelldata.DamageTypes.Bash)
AddSpell( 248,                "Vaccinate", nil, 116, 119, nil, nil, nil, nil, false)
AddSpell( 506,           "Valgards might", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 179,           "Vampiric touch",  42, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Negative)
AddSkill( 623,                     "Veil", nil, nil,  18, nil, nil, nil, nil, false, nil, { "Ninja" })
AddSkill( 478,                   "Velvet", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSkill( 480,                 "Vendetta", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 371,                "Vengeance", nil, 147, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Light)
AddSpell(  80,            "Ventriloquate",  31, nil, nil, nil, nil, nil, nil, false)
AddSkill( 410,                 "Vitality", nil, nil,  32,  38,  38, nil, nil, false)
AddSpell( 378,             "Voice of god", nil, 189, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Sonic, { "Priest", "Oracle", "Harmer" })
AddSkill( 609,                   "Volley", nil, nil, nil, nil,  29, nil, nil, false, nil, { "Hunter" })
AddSkill( 315,                    "Wands",   3,   4, 201, 201,  39, 201,   3, false)
AddSkill( 229,                   "Warcry", nil, nil, nil, nil, nil,  51, nil, false, spelldata.DamageTypes.Bash)
AddSkill( 230,                 "Warhorse", nil, nil, nil, nil, nil,  25, nil, false)
AddSpell( 253,                   "Warmth", 106, 101, nil, nil, 145, nil, 133, false)
AddSpell( 529,              "Water focus", nil, nil, nil, nil, nil, nil, nil, false) -- Removed from the game
AddSkill( 344,                  "Wayfind", 152, 155, nil, nil, nil, nil, 158, false)
AddSpell(  81,                   "Weaken",  17, nil, nil, nil, nil, nil, nil, false)
AddSpell( 237,                      "Web",  51,  45,  46, nil, nil, nil,  47, false)
AddSkill( 208,                     "Whip",   5,  10,   3,   9,  18,   1,   1, false)
--         ID                        Name  Mag  Clr  Thi  War  Ran  Pal  Psi nofail                damtype  subclasses
AddSpell( 383,                "Whirlwind", nil, nil, nil, nil,  61, nil, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 366,              "White flame", nil,  33, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Fire)
AddSpell( 251,                "Willpower", nil, nil, nil, nil, nil, nil, 101, false, nil, { "Mentalist", "Necromancer", "Navigator" })
AddSpell( 381,               "Wind blast", nil, nil, nil, nil,  30, nil, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 403,       "Winds of reckoning", nil, nil, nil, nil, nil, 148, nil,  true, spelldata.DamageTypes.Air)
AddSpell( 187,                   "Wither",  31, nil, nil, nil, nil, nil, nil,  true, spelldata.DamageTypes.Negative)
AddSpell( 154,             "Wolf spirits", nil, nil, nil, nil,  76, nil, nil, false, nil, { "Crafter", "Hunter", "Shaman" })
AddSpell(  82,           "Word of recall",  18,  17, nil, nil, nil, nil,  17, false)
AddSpell( 180,              "Wraith form",  97, nil, nil, nil, nil, nil, nil, false, nil, { "Elementalist", "Enchanter", "Sorcerer" })
AddSpell( 166,             "Wrath of god", nil, nil, nil, nil, nil,  97, nil, false, spelldata.DamageTypes.Electric)
AddSpell( 299,                   "Wrench", nil, nil, nil, nil, nil, nil,  63, false)
AddSkill( 498,               "Xochimiqui", nil, nil, nil, nil, nil, nil, nil, false) -- special
AddSpell( 563,                  "Zombify", nil, nil, nil, nil, nil, nil,  52, false, spelldata.DamageTypes.Shadow, { "Necromancer" })

--[=[ Output from `slist` on 11/24/2021

3,acid blast,1,0,0,-1,1
317,absorb,2,0,0,-1,1
404,abomination,1,0,0,-1,1
258,accelerate,3,0,0,-1,1
320,acid stream,1,0,0,-1,1
83,acid wave,1,0,0,-1,1
200,acidic touch,1,0,0,-1,1
249,acidproof,2,0,0,-1,1
97,adrenaline control,3,0,0,-1,1
496,aggrandize,0,0,0,-1,2
98,agitation,1,0,0,-1,1
155,aid,2,0,0,-1,1
338,aim,1,0,95,-1,2
465,air dart,1,0,0,-1,1
592,air skewer,1,0,0,-1,1
547,ambush,0,0,0,5,2
600,amnesia,5,0,0,49,1
190,angel breath,1,0,0,-1,1
373,angelfire,1,0,0,-1,1
138,animal friendship,1,0,0,-1,1
293,animate object,4,0,0,-1,1
488,anoint,0,0,0,-1,2
167,antimagic shell,3,0,0,-1,1
608,apathy,0,0,0,-1,2
406,apocalypse,1,0,0,-1,1
583,archery,0,0,100,45,2
4,armor,2,0,0,-1,1
285,assassinate,0,0,0,10,2
272,assault,0,0,0,-1,2
532,augmented healing,2,0,0,0,1
99,aura sight,2,0,0,-1,1
168,avoidance,3,0,0,-1,1
426,awakening,3,0,0,-1,1
501,awareness,3,0,0,-1,2
100,awe,0,0,0,-1,1
607,awol,3,0,0,53,2
201,axe,0,0,100,-1,2
5,bless,2,0,0,-1,1
209,backstab,0,0,100,12,2
231,balefire,1,0,0,-1,1
101,ballistic attack,1,0,0,-1,1
289,balor spittle,0,0,0,11,2
169,banishment,1,0,0,-1,1
170,banshee wail,1,0,0,-1,1
139,barkskin,2,0,0,-1,1
210,bash,0,0,0,-1,2
256,bashdoor,0,0,0,-1,2
616,battle training,0,0,0,-1,2
463,battlefaith,0,0,0,-1,2
534,beacon of homecoming,0,0,0,23,1
536,beacon of light,0,0,0,23,1
211,berserk,3,0,0,-1,2
102,biofeedback,3,0,0,-1,1
90,black lotus,2,0,0,-1,1
280,black root,0,0,1,-1,2
476,blackrose,0,0,0,-1,2
328,blades of light,1,0,0,-1,1
549,blast undead,1,0,0,-1,1
473,blazing fury,1,0,0,-1,1
188,bless weapon,4,0,0,-1,1
6,blindness,1,0,0,-1,1
368,blight,1,0,0,-1,1
597,blindfighting,3,0,0,-1,2
260,blink,0,0,0,-1,2
257,blockexit,0,0,0,-1,2
171,blur,2,0,0,-1,1
451,bodycheck,1,0,0,-1,2
582,bow,0,0,100,-1,2
302,brew,0,0,0,-1,2
7,burning hands,1,0,0,-1,1
279,burnt marbu,0,0,1,-1,2
239,butcher,0,0,0,-1,2
603,bypass,0,0,0,-1,2
8,call lightning,0,0,0,-1,1
435,calculation,3,0,0,-1,1
156,call upon faith,3,0,0,-1,1
459,camouflage,0,0,0,-1,2
246,camp,0,0,0,-1,2
10,cancellation,2,0,0,-1,1
266,cannibalize,3,0,0,-1,2
11,cause critical,1,0,0,-1,1
294,cause decay,1,0,0,-1,1
12,cause light,1,0,0,-1,1
13,cause serious,1,0,0,-1,1
376,caustic rain,1,0,0,-1,1
103,cell adjustment,3,0,0,-1,1
556,cell potential,3,0,0,-1,2
104,chameleon power,3,0,0,-1,2
157,champions strength,2,0,0,-1,1
14,change sex,2,0,0,-1,1
437,channel energy,3,0,0,-1,1
334,chaos portal,4,0,0,-1,1
267,charge,0,0,0,-1,2
182,chariot of sustarre,0,0,0,-1,1
15,charm person,1,0,1,-1,1
16,chill touch,1,0,0,-1,1
505,choreography,0,0,0,-1,2
291,circle,0,0,1,-1,2
494,clandestine,0,0,0,-1,2
158,cleansing,2,0,0,-1,1
325,cleave,0,0,0,-1,2
284,cobra bane,0,0,95,-1,2
17,colour spray,1,0,0,-1,1
520,combat empathy,3,0,0,7,1
105,combat mind,2,0,0,-1,1
183,command,0,0,0,-1,1
474,comprehension,0,0,0,-1,2
439,compression,3,0,0,-1,1
413,conceal,4,0,1,-1,1
396,condemn,1,0,0,-1,1
172,cone of cold,1,0,0,-1,1
149,conjure elemental,0,0,0,-1,1
510,conspire,0,0,0,-1,2
18,continual light,0,0,0,-1,1
107,control flames,1,0,0,-1,1
621,conviction,0,0,0,-1,2
327,counter strike,0,0,0,-1,2
20,create food,3,0,0,-1,1
159,create holy symbol,0,0,0,-1,1
417,create poultice,2,0,0,-1,1
108,create sound,0,0,0,-1,1
22,create water,0,0,0,-1,1
507,creators wisdom,2,0,0,-1,1
23,cure blindness,2,0,0,-1,1
24,cure critical,2,0,0,-1,1
25,cure disease,2,0,0,-1,1
340,cure epidemic,0,0,0,-1,1
26,cure light,2,0,0,-1,1
27,cure poison,2,0,0,-1,1
28,cure serious,2,0,0,-1,1
467,cure weakness,2,0,0,-1,1
29,curse,1,0,0,-1,1
189,curse item,4,0,0,-1,1
578,curse of sloth,1,0,0,1,1
386,cyclone,1,0,0,-1,1
466,daes,0,0,0,-1,2
202,dagger,0,0,100,-1,2
402,damnation,1,0,0,-1,1
194,dampening field,1,0,0,-1,1
140,darkness,2,0,0,-1,1
290,death blow,0,0,0,-1,2
109,death field,0,0,0,-1,1
571,deceive,0,0,0,-1,2
30,demonfire,1,0,0,-1,1
617,demonform,0,0,0,-1,2
613,demoralize,1,0,0,56,1
567,desecration,3,0,0,31,1
362,desolation,1,0,0,-1,1
31,detect evil,3,0,0,-1,1
32,detect good,3,0,0,-1,1
33,detect hidden,3,0,95,-1,1
34,detect invis,3,0,100,-1,1
35,detect magic,3,0,95,-1,1
36,detect poison,4,0,1,-1,1
540,detect undead,3,0,0,-1,1
110,detonate,1,0,0,-1,1
212,dirt kicking,0,0,1,-1,2
213,disarm,0,0,0,-1,2
65,disease,1,0,0,-1,1
111,disintegrate,1,0,0,-1,1
37,dispel evil,1,0,0,-1,1
184,dispel good,1,0,0,-1,1
38,dispel magic,1,0,0,-1,1
112,displacement,3,0,0,-1,1
412,disrupt,0,0,0,-1,1
238,dissolve,2,0,95,-1,1
160,divine faith,2,0,0,-1,1
430,divine swiftness,2,0,0,-1,1
332,divining,0,0,0,-1,2
214,dodge,0,0,95,-1,2
113,domination,1,0,0,-1,1
295,doorway,0,0,0,-1,1
224,dual wield,0,0,98,-1,2
141,dust devil,0,0,0,-1,1
39,earthquake,0,0,0,-1,1
527,earth focus,3,0,0,3,1
380,earth maw,1,0,0,-1,1
387,earth shroud,1,0,0,-1,1
591,earthen hammer,1,0,0,-1,1
114,ectoplasmic form,3,0,0,-1,1
115,ego whip,1,0,0,-1,1
322,ego boost,2,0,0,-1,1
526,elemental focus,3,0,0,3,1
530,elemental ward,3,0,0,55,1
40,enchant armor,4,0,0,-1,1
41,enchant weapon,4,0,0,-1,1
575,enchanters focus,3,0,0,0,1
440,energy ball,3,0,0,-1,1
116,energy containment,3,0,0,-1,1
252,energy shield,2,0,0,-1,1
375,engulf,1,0,0,-1,1
287,enhanced backstab,0,0,100,-1,2
215,enhanced damage,0,0,100,-1,2
118,enhanced strength,3,0,0,-1,1
424,enlightenment,2,0,0,-1,1
523,enrage,3,0,0,4,2
521,entrap,0,0,1,5,2
216,envenom,0,0,1,-1,2
500,equilibrium,0,0,0,-1,2
392,eruption,1,0,0,-1,1
509,espresso,0,0,0,-1,2
492,exaltation,0,0,0,-1,2
369,exorcise,1,0,0,-1,1
419,exotic,0,0,100,-1,2
374,extinguish,1,0,0,-1,1
543,eye of discovery,2,0,0,24,1
542,eye of passage,0,0,0,-1,1
557,eye of warning,2,0,0,27,1
304,fast healing,0,0,95,-1,2
471,fate,0,0,0,-1,2
562,fence,0,0,97,-1,2
243,fifth attack,0,0,0,-1,2
95,finger of death,1,0,0,-1,1
1,fire,0,0,1,-1,2
379,fire blast,1,0,0,-1,1
84,fire breath,0,0,0,-1,1
528,fire focus,3,0,0,3,1
453,fire rain,0,0,0,-1,1
148,fire storm,1,0,0,-1,1
45,fireball,1,0,0,-1,1
46,fireproof,4,0,0,-1,1
203,flail,0,0,100,-1,2
173,flame arrow,1,0,0,-1,1
142,flame blade,0,0,0,-1,1
47,flamestrike,1,0,0,-1,1
346,flaming sphere,1,0,0,-1,1
570,flank,0,0,0,32,2
586,flay,0,0,0,42,2
119,flesh armor,3,0,0,-1,1
48,fly,2,0,0,-1,1
576,focused vision,3,0,0,38,1
225,forage,0,0,0,-1,2
348,force bolt,1,0,0,-1,1
390,forestfire,1,0,0,-1,1
262,forging,0,0,0,-1,2
276,fortitude,0,0,0,-1,2
275,fourth attack,0,0,0,-1,2
49,frenzy,2,0,0,-1,1
518,gaias revenge,3,0,0,-1,1
552,gaias focus,3,0,0,-1,1
624,gaias totem,3,0,0,65,1
50,gate,0,0,0,-1,1
51,giant strength,2,0,0,-1,1
489,gift,0,0,0,-1,2
394,glare,1,0,0,-1,1
174,globe of invulnerability,3,0,0,-1,1
485,gloom,0,0,0,-1,2
425,godly embrace,3,0,0,-1,1
143,goodberry,0,0,0,-1,1
533,gos,4,0,0,-1,1
450,gouge,1,0,0,-1,2
271,grab,0,0,0,-1,2
288,green death,0,0,1,-1,2
335,grey aura,2,0,0,-1,1
382,ground strike,1,0,0,-1,1
305,haggle,0,0,95,-1,2
162,hallowed light,0,0,0,-1,1
589,hammer,0,0,0,-1,2
590,hammerforge,0,0,0,-1,2
449,hammering blow,1,0,0,-1,2
614,hammerswing,0,0,0,-1,2
163,hand of justice,0,0,0,-1,1
217,hand to hand,0,0,95,-1,2
422,harden body,2,0,0,-1,1
52,harm,1,0,0,-1,1
53,haste,2,0,0,-1,1
568,haven,0,0,0,34,1
448,headbutt,1,0,0,-1,2
54,heal,2,0,0,-1,1
502,healing touch,2,0,0,-1,1
152,heat shield,2,0,0,-1,1
161,heavenly balance,1,0,0,-1,1
574,heavenly smiting,0,0,0,37,1
120,heighten senses,3,0,0,-1,2
330,herbal remedy,0,0,95,-1,2
579,hex of entropy,1,0,0,40,1
580,hex of misfortune,1,0,0,40,1
306,hide,3,0,95,-1,2
164,holy aura,3,0,0,-1,1
454,holy arrow,1,0,0,-1,1
393,holy fury,1,0,0,-1,1
516,holy intervention,0,0,0,-1,2
255,holy mirror,2,0,0,-1,1
619,holy preference,3,0,0,-1,2
364,holy rain,1,0,0,-1,1
618,holy reprisal,0,0,0,-1,2
261,holy rift,0,0,0,-1,2
569,holy shield,0,0,0,33,1
472,holy strike,1,0,0,-1,1
165,holy word,1,0,0,-1,1
535,homecoming,0,0,0,-1,1
481,houyou,0,0,0,-1,2
602,humility,3,0,0,52,1
301,hunt,0,0,95,-1,2
513,huntmaster,3,0,0,15,1
281,hydra blood,0,0,1,-1,2
385,hydroblast,1,0,0,-1,1
389,ice bolt,1,0,0,-1,1
85,ice cloud,0,0,0,-1,1
593,ice daggers,1,0,0,-1,1
150,ice storm,0,0,0,-1,1
56,identify,4,0,0,-1,1
336,illuminate,4,0,0,-1,1
464,imbue,0,0,0,-1,2
361,immolate,1,0,0,-1,1
106,incomplete healing,2,0,0,-1,1
91,indestructible aura,2,0,0,-1,1
121,inertial barrier,0,0,0,-1,1
397,infernal voice,1,0,0,-1,1
122,inflict pain,1,0,0,-1,1
524,insanity,3,0,0,-1,2
462,inspiration,0,0,0,-1,2
123,intellect fortress,3,0,0,-1,1
594,intent,0,0,0,-1,2
587,interrogate,0,0,0,43,2
483,intervention,0,0,0,-1,2
274,intimidate,0,0,100,-1,2
58,invis,2,0,0,-1,1
596,ironfist,3,0,0,46,2
218,kick,1,0,95,-1,2
595,knife fighting,0,0,95,-1,2
411,knock,0,0,0,-1,1
59,know alignment,0,0,0,-1,1
457,kobold spray,0,0,96,-1,2
278,kobold stench,0,0,1,-1,2
585,lash,1,0,0,-1,2
228,lay hands,0,0,0,-1,2
124,lend health,2,0,0,-1,1
125,levitation,2,0,0,-1,1
331,light arrow,1,0,0,-1,1
60,lightning bolt,1,0,0,-1,1
232,lightning strike,1,0,0,-1,1
259,lightspeed,2,0,0,-1,1
185,line of protection,3,0,0,-1,1
610,link,0,0,0,-1,2
61,locate object,0,0,0,-1,1
151,locate animal,0,0,0,-1,1
240,locate corpse,0,0,0,-1,1
307,lore,0,0,1,-1,2
204,mace,0,0,100,-1,2
62,magic missile,1,0,0,-1,1
423,magic circle,2,0,0,-1,1
428,magical rush,3,0,0,-1,1
175,major creation,0,0,0,-1,1
192,major swarm,1,0,0,-1,1
475,mandrake,0,0,0,-1,2
458,marbu jet,0,0,1,-1,2
308,meditation,0,0,95,-1,2
233,megablast,1,0,0,-1,1
611,mental balance,3,0,0,-1,1
126,mental barrier,3,0,0,-1,1
545,merge chaos,0,0,0,-1,1
351,miasma,1,0,0,-1,1
353,mind freeze,1,0,0,-1,1
197,mind over body,3,0,0,-1,1
127,mind thrust,1,0,0,-1,1
622,mindflay,0,0,0,63,2
176,minor creation,0,0,0,-1,1
191,minor swarm,1,0,0,-1,1
408,miracle,2,0,0,-1,1
515,misdirection,0,0,97,-1,2
324,mist form,0,0,0,-1,2
456,mobshield,2,0,0,-1,1
144,moonbeam,1,0,0,-1,1
421,mystic might,3,0,0,-1,1
606,napalm,0,0,0,-1,2
445,natures touch,2,0,0,-1,1
537,navigate,0,0,0,23,2
539,necrocide,1,0,0,-1,1
195,negation,2,0,0,-1,1
355,nerve shock,1,0,0,-1,1
354,neural burn,1,0,0,-1,1
360,neural overload,1,0,0,-1,1
96,nexus,0,0,0,-1,1
57,night vision,2,0,100,-1,1
359,nightmare touch,1,0,0,-1,1
554,nimble cunning,3,0,95,-1,2
495,nirvana,0,0,0,-1,2
349,nova,1,0,0,-1,1
598,necrotic touch,0,0,0,48,2
479,oath,0,0,0,-1,2
296,object read,4,0,0,-1,1
64,pass door,3,0,1,-1,1
9,pacify,0,0,0,-1,1
323,panic,0,0,0,-1,1
219,parry,0,0,0,-1,2
443,party harmony,2,0,0,-1,1
446,party heal,0,0,0,-1,1
414,party sanctuary,0,0,0,-1,1
444,party shield,2,0,0,-1,1
226,pass without trace,3,0,0,-1,2
538,pathfinding,0,0,0,-1,2
309,peek,0,0,95,-1,2
427,perception,3,0,0,-1,1
577,petrify,1,0,0,39,1
310,pick lock,0,0,95,-1,2
555,pilferage,0,0,100,-1,2
399,pillar of fire,1,0,0,-1,1
66,poison,1,0,0,-1,1
205,polearm,0,0,100,-1,2
92,portal,0,0,0,-1,1
292,poultice,0,0,1,-1,2
277,power grip,0,0,0,-1,2
434,power of faith,3,0,0,-1,1
525,power projection,3,0,0,2,1
564,pray for absolution,3,0,0,-1,1
565,pray for damnation,3,0,0,-1,1
429,prayer of fortune,2,0,0,-1,1
615,precision,3,0,0,58,2
491,preserve,0,0,0,-1,2
490,pride,0,0,0,-1,2
177,prismatic spray,1,0,0,-1,1
67,protection evil,3,0,0,-1,1
68,protection good,3,0,0,-1,1
297,probability travel,3,0,0,-1,1
128,project force,1,0,0,-1,1
477,prophecy,0,0,0,-1,2
420,protection neutral,0,0,0,-1,2
129,psionic blast,1,0,0,-1,1
130,psychic crush,1,0,0,-1,1
131,psychic drain,1,0,0,-1,1
132,psychic healing,3,0,0,-1,1
356,psychosis,1,0,0,-1,1
433,pure faith,3,0,0,-1,1
405,purgatory,1,0,0,-1,1
370,purge,0,0,0,-1,1
337,purify,4,0,1,-1,1
270,push,0,0,0,-1,2
234,pyromania,1,0,0,-1,1
499,qi,0,0,0,-1,2
601,quickstab,3,0,0,50,2
486,rage,0,0,0,-1,2
145,rainbow,1,0,0,-1,1
432,rally,2,0,0,-1,1
286,raven scourge,0,0,95,-1,2
137,raw flesh,1,0,0,-1,1
522,reborn,0,0,0,-1,2
316,recall,0,0,95,-1,2
193,recharge,4,0,0,-1,1
407,recon,0,0,0,-1,2
497,redemption,0,0,0,-1,2
69,refresh,2,0,95,-1,1
146,regeneration,2,0,0,-1,1
553,rehallow,4,0,0,-1,1
263,reinforce,0,0,0,-1,2
416,rejuvenate,2,0,95,-1,1
70,remove curse,2,0,0,-1,1
503,renew,2,0,0,-1,1
400,repentance,1,0,0,-1,1
220,rescue,0,0,0,-1,2
0,reserved,0,0,0,-1,2
546,reskin,0,0,0,-1,2
415,resonate,4,0,0,-1,1
504,restore life,2,0,0,-1,1
181,resurrection,0,0,0,-1,1
241,retreat,0,0,95,-1,2
247,reverse align,1,0,0,-1,1
44,reveal,0,0,0,-1,1
431,revelation,2,0,0,-1,1
551,righteous anger,3,0,0,26,1
43,rune of ix,1,0,0,-1,1
573,sacrifice life,0,0,0,36,1
566,safeguard,0,0,0,30,2
71,sanctuary,2,0,0,-1,1
273,sap,0,0,0,-1,2
300,scalp,0,0,0,-1,2
350,scorch,1,0,0,-1,1
283,scorpion strike,0,0,0,-1,2
398,scourge,1,0,0,-1,1
343,scout,0,0,0,-1,2
303,scribe,0,0,0,-1,2
313,scrolls,0,0,1,-1,2
236,scry,0,0,0,-1,1
222,second attack,0,0,99,-1,2
244,second attack dual,0,0,95,-1,2
442,self harmony,3,0,0,-1,1
612,sense age,3,0,0,38,1
235,sense anger,3,365,96,-1,1
548,sense danger,3,0,0,-1,1
455,sense life,3,0,0,-1,1
572,serenity,3,0,0,35,1
72,shield,2,0,0,-1,1
133,shadow form,3,0,0,-1,2
352,shard of ice,1,0,0,-1,1
438,share intellect,2,0,0,-1,1
134,share strength,2,0,0,-1,1
436,share wisdom,2,0,0,-1,1
264,sharpen,0,0,0,-1,2
206,shield block,0,0,0,-1,2
508,shiftys sleight of hand,2,0,0,-1,1
87,shock aura,1,0,0,-1,1
73,shocking grasp,1,0,0,-1,1
250,shockproof,2,0,0,-1,1
599,shoplifting,0,0,95,-1,2
604,shroud,0,0,0,-1,2
517,sixth attack,0,0,0,-1,2
227,skin,0,0,0,-1,2
74,sleep,1,0,0,-1,1
282,slit,0,0,95,-1,2
75,slow,1,0,0,6,1
469,sluagh,0,0,0,-1,2
311,sneak,3,2191,95,-1,2
298,soften,1,0,0,-1,1
339,solidify,4,0,0,-1,1
384,solar flare,1,0,0,-1,1
395,soul rip,1,0,0,-1,1
363,soulburn,1,0,0,-1,1
358,spasm,1,0,0,-1,1
207,spear,0,0,100,-1,2
541,spear of odin,1,0,0,-1,1
318,spiral,0,0,0,-1,2
484,spirit shield,3,0,0,-1,1
365,spirit bolt,1,0,0,-1,1
418,spirit form,0,0,0,-1,2
401,spirit strike,1,0,0,-1,1
94,spiritual armor,2,0,0,-1,1
377,spiritual disruption,1,0,0,-1,1
186,spook,1,0,0,-1,1
265,spunch,0,0,0,-1,2
341,spy,0,0,0,-1,2
558,stalk,3,0,0,28,2
372,starburst,1,0,0,-1,1
314,staves,0,0,0,-1,2
312,steal,0,0,95,-1,2
559,stealth,3,0,0,28,2
452,stomp,1,0,0,-1,2
76,stone skin,3,0,0,-1,1
329,strangle,0,0,95,51,2
550,strike undead,1,0,0,-1,1
268,stun,0,0,0,-1,2
470,stupor,0,0,0,-1,2
487,sumadji,0,0,0,-1,2
77,summon,0,0,0,-1,1
584,summon death,0,0,0,13,1
514,summon life,0,0,0,13,1
147,sunray,1,0,0,-1,1
531,suppressed healing,1,0,0,1,1
342,survey,0,0,0,-1,2
321,sustenance,2,0,0,-1,1
326,sweep,0,0,1,-1,2
2,sword,0,0,100,-1,2
93,sword of righteousness,0,0,0,-1,1
347,talon,1,0,0,-1,1
319,tame,0,0,0,-1,2
493,taunt,0,0,0,-1,2
196,telekinesis,1,0,0,-1,1
78,teleport,3,0,0,-1,1
79,teleport behind,1,0,0,-1,1
581,tempering,0,0,0,41,2
391,tempest,1,0,0,-1,1
460,terminate,1,0,0,-1,1
461,terminate2,1,0,0,-1,2
519,test of faith,3,0,0,-1,1
223,third attack,0,0,95,-1,2
245,third attack dual,0,0,0,-1,2
135,thought shield,3,0,0,-1,1
198,time shift,0,0,0,-1,2
544,timeshifting,3,0,0,-1,1
367,torment,1,0,0,-1,1
388,tornado,1,0,0,-1,1
588,tortured vision,1,0,0,44,1
512,totem force,3,0,0,16,1
511,totem guidance,3,0,0,16,1
86,toxic cloud,0,0,0,-1,1
254,toxic resistance,2,0,0,-1,1
468,transcend,0,0,0,-1,2
409,translocate,3,0,0,-1,1
153,transport via plants,0,0,0,-1,1
357,trauma,1,0,0,-1,1
269,treat wounds,0,0,0,-1,2
482,trickery,0,0,0,-1,2
221,trip,0,0,1,-1,2
345,trophy,0,0,0,-1,2
178,true seeing,3,0,0,-1,1
136,ultrablast,0,0,0,-1,1
333,underwater breathing,2,634,96,-1,1
620,unholy preference,3,0,0,-1,2
605,unify,0,0,0,-1,2
242,unlawful entry,0,0,1,-1,1
447,uppercut,1,0,0,-1,2
248,vaccinate,2,64,95,-1,1
506,valgards might,2,0,0,-1,1
179,vampiric touch,1,0,0,-1,1
623,veil,3,0,0,64,2
478,velvet,0,0,0,-1,2
480,vendetta,0,0,0,-1,2
371,vengeance,1,0,0,-1,1
80,ventriloquate,0,0,0,-1,1
410,vitality,0,0,96,-1,2
378,voice of god,1,0,0,-1,1
609,volley,3,0,0,54,2
315,wands,0,0,0,-1,2
229,warcry,0,0,0,-1,2
230,warhorse,0,0,0,-1,2
253,warmth,2,0,0,-1,1
529,water focus,3,0,0,3,1
344,wayfind,0,0,0,-1,2
81,weaken,1,0,0,-1,1
237,web,1,0,1,-1,1
208,whip,0,0,100,-1,2
383,whirlwind,1,0,0,-1,1
366,white flame,1,0,0,-1,1
251,willpower,2,0,0,-1,1
381,wind blast,1,0,0,-1,1
403,winds of reckoning,1,0,0,-1,1
187,wither,1,0,0,-1,1
154,wolf spirits,3,0,0,-1,1
82,word of recall,3,0,0,-1,1
180,wraith form,3,0,0,-1,1
166,wrath of god,0,0,0,-1,1
299,wrench,0,0,0,-1,1
498,xochimiqui,0,0,0,-1,2
563,zombify,1,0,0,47,1
{/spellheaders}
{recoveries}
0,Augmentation,0
1,Suppression,0
2,Projection,0
3,Elemental,0
4,Rage,0
5,Trapping,0
6,Slow,0
7,Empathy,0
8,Faith,0
9,Gaia,0
10,Assassinate,0
11,Balor,0
12,Backstab,0
13,Summoning,0
15,Huntmaster,0
16,Totem Aid,0
18,Shielding Timeout,0
23,Beacons,0
24,Discovery,0
25,Time Control,0
26,Vengeance,0
27,Oracle Sight,0
28,Stealth,0
30,Safeguard,0
31,Desecration,0
32,Combat Tactics,0
33,Shielding,0
34,Haven,0
35,Serenity,0
36,Sacrifice,0
37,Smiting,0
38,Focus,0
39,Petrify,0
40,Hex,0
41,Tempering,0
42,Whipmaster,0
43,Interrogation,0
44,Illusion,0
45,Archery,0
46,Ironfist,0
47,Necromancy,0
48,Advanced Poisons,0
49,Mind Control,0
50,Quickstab,0
51,Strangle,0
52,Humility,0
53,AWOL,0
54,Volley,0
55,Warding,0
56,Demoralize,0
58,Precision,0
63,Mindflay,0
64,Veil,0
65,Create Totem,0
]=]

--- Retrieve spell data by spell number
---@param sn number # Spell number of the desired spell
---@return SpellData
function spelldata.GetSpellByNumber(sn)
    return data[sn]
end

--- Retrieve spell data by full spell name
---@param name string # Full spell name
---@return SpellData
function spelldata.GetSpellByName(name)
    local sn = name_to_id[string.lower(name)]
    return data[sn]
end

--- Retrieve spell data by partial name match
---@param name string # String we're attempting to match
---@return SpellData?
function spelldata.MatchSpell(name)
    local lowername = string.lower(name)
    local namelen = string.len(name)

    if namelen < 1 then return nil end  -- Provided text can't be an empty string

    for spellname, id in pairs(name_to_id) do
        -- Attempt to match the beginning of each spell's name with the provided text
        if string.sub(spellname, 1, namelen) == lowername then
            return data[id]
        end
    end

    return nil
end

return spelldata