local Trigger = require "trigger"

---@alias kill_callback_function fun(mobname: string, reason: string)

---Maps spells/damage types to the line that gets used for a mob kill
---@type table<string, string>
local kill_text_map = {}

---Name of the last mob killed
---@type string
local last_kill = ""

---Callback to be called whenever we parse a mob kill
---@type kill_callback_function|nil
local callback_function = nil

local TRIGGER_PREFIX = "trg_killedby_"
local TRIGGER_PREFIX_LEN = 13

-- Map kill sources to the lines of text that is output, replacing the mob's name with MOBNAME

-- Default (used by: air, earth, light, magic, shadow, sonic)
kill_text_map["generic"] = "MOBNAME is DEAD!!"

-- Weapon damage / damage type
kill_text_map["acid"] = "MOBNAME screams in agony as the acid consumes HIMHER!!"
-- air = generic
kill_text_map["bash"] = "MOBNAME crumbles as HESHE is battered to death!!"
kill_text_map["cold"] = "MOBNAME goes stiff as HESHE is frozen to death!!"
-- earth = generic
kill_text_map["electric"] = "MOBNAME smoulders as the lightning destroys HIMHER!!"
kill_text_map["energy"] = "MOBNAME is destroyed by the blast!!"
kill_text_map["fire"] = "MOBNAME screams as the flames engulf HIMHER!!"
kill_text_map["holy"] = "MOBNAME is damned forever by the holy power!!"
-- light = generic
-- magic = generic
kill_text_map["mental"] = "MOBNAME falls dead as HISHER mind is destroyed!!"
kill_text_map["negative"] = "MOBNAME howls as HISHER last spark of life is drained!!"
kill_text_map["pierce"] = "MOBNAME is slain by a final deadly stab!!"
kill_text_map["slash"] = "MOBNAME is slain by a final deadly slash!!"
-- shadow = generic
-- sonic = generic
kill_text_map["water"] = "MOBNAME is battered to death by the force of the water!"

-- Skills and spells
kill_text_map["abomination"] = "MOBNAME is slain by an abomination from the depths of HISHER own fears! HESHE is DEAD!"
kill_text_map["acid blast"] = "MOBNAME almost dissolves as HESHE is slain by the blast of acid. HESHE is DEAD!"
-- acid stream = same as acid weapon damage
kill_text_map["acid wave"] = "MOBNAME's skin bubbles and blisters as the onslaught of acid finishes HIMHER!! HESHE is DEAD!"
-- acidic touch = same as acid weapon damage
-- agitation = same as negative weapon damage
kill_text_map["air dart"] = "The air dart blows the last shred of life from MOBNAME!! HESHE is DEAD!"
kill_text_map["air skewer"] = "MOBNAME is transfixed by the skewer of air! HESHE is DEAD!"
-- angel breath = generic/default message
kill_text_map["angelfire"] = "MOBNAME is cleansed by the fire of angels! HESHE is DEAD!"
kill_text_map["assault"] = "With viciousness and a wicked blade, MOBNAME is slain! HESHE is DEAD!"
kill_text_map["backstab"] = "MOBNAME lets out a final rasp as HISHER vital organs are pierced. HESHE is DEAD!"
kill_text_map["balefire"] = "Heat sears MOBNAME as the fireball slams into HIMHER!! HESHE is DEAD!"
kill_text_map["ballistic attack"] = "A lethal kinetic missile slams into MOBNAME and finishes HIMHER!! HESHE is DEAD!"
kill_text_map["banshee wail"] = "The pitch of the shrieking makes MOBNAME's brain explode!! HESHE is DEAD!"
kill_text_map["bash skill"] = "The body slam smashes into MOBNAME destroying HISHER internal organs. HESHE is DEAD!"
kill_text_map["black root"] = "The power of the root finds a vital spot on MOBNAME. Death is swift! HESHE is DEAD!"
kill_text_map["blades of light"] = "The blades dice MOBNAME's body like a salad!! HESHE is DEAD!"
kill_text_map["blazing fury"] = "MOBNAME's corpse shimmers as HESHE explodes with light. HESHE is DEAD!"
kill_text_map["blight"] = "MOBNAME turns to ice as HESHE is torn apart piece by piece! HESHE is DEAD!"
kill_text_map["bodycheck"] = "MOBNAME is crushed by the fury of the bodycheck. HESHE is DEAD!"
kill_text_map["burning hands"] = "A finger-spread fan of fire fries MOBNAME where HESHE stands! HESHE is DEAD!"
-- cause decay == same as kspray
kill_text_map["cause critical"] = "MOBNAME turns a ghastly shade of grey as life is extinguished!! HESHE is DEAD!"
kill_text_map["cause light"] = "The lightest touch of god extinguishes life from MOBNAME. HESHE is DEAD!"
kill_text_map["cause serious"] = "A serious look of terror crosses MOBNAME's face. HESHE is DEAD!"
kill_text_map["caustic rain"] = "Searing acid rain falls directly on MOBNAME killing HIMHER instantly! HESHE is DEAD!"
kill_text_map["chill touch"] = "MOBNAME suddenly turns to solid ice and shatters, spraying red ice everywhere! HESHE is DEAD!"
kill_text_map["circle"] = "The final deadly circle turns MOBNAME into food for the worms! HESHE is DEAD!"
kill_text_map["cleave"] = "The awesome blow strikes right through MOBNAME's shield into the flesh! HESHE is DEAD!"
kill_text_map["cobra bane"] = "As venom brings death, MOBNAME's face holds a passing look of terror as realization dawns. HESHE is DEAD!"
kill_text_map["colour spray"] = "A dancing pattern of light renders MOBNAME lifeless!! HESHE is DEAD!"
kill_text_map["condemn"] = "MOBNAME is condemned to rot for eternity! (well, a few ticks really, but..) HESHE is DEAD!"
kill_text_map["cone of cold"] = "The blood of MOBNAME is completely frozen by the cone of cold!! HESHE is DEAD!"
-- control flames = generic fire damage
kill_text_map["counterstrike"] = "MOBNAME is shattered by the stunning counter strike!! HESHE is DEAD!"
kill_text_map["cyclone"] = "MOBNAME's body is wracked by the force of the cyclone!! HESHE is DEAD!"
kill_text_map["damnation"] = "MOBNAME is sent straight to hell by the damning force! HESHE is DEAD!"
-- death field = generic negative damage
-- demonfire = generic negative damage
kill_text_map["desolation"] = "MOBNAME feels so desolate that life itself leaves HISHER wrecked form! HESHE is DEAD!"
-- detonate = generic energy damage
kill_text_map["dirt kicking"] = "A large rock embeds itself in MOBNAME's brain, resulting in death!! HESHE is DEAD!"
kill_text_map["dispel evil"] = "MOBNAME's foul presence is removed from this realm by the power of light!! HESHE is DEAD!"
kill_text_map["dispel good"] = "MOBNAME's saintly presence is removed by the dark powers of shadow!! HESHE is DEAD!"
kill_text_map["earth maw"] = "The earth pummels MOBNAME into the ground! HESHE is DEAD!"
kill_text_map["earth shroud"] = "A wall of rock rises up around MOBNAME and crushes the life out of HIMHER!! HESHE is DEAD!"
kill_text_map["earthen hammer"] = "MOBNAME is smashed into tiny fragments by the blast of earth! HESHE is DEAD!"
kill_text_map["earthquake"] = "MOBNAME has been crushed by the power of the earthquake! HESHE is DEAD!"
kill_text_map["ego whip"] = "MOBNAME's ego is whipped so badly that HESHE just decides to die! HESHE is DEAD!"
kill_text_map["engulf"] = "MOBNAME is completely engulfed in flame as HESHE is consumed!! HESHE is DEAD!"
kill_text_map["exorcise"] = "MOBNAME is exorcised by the attack, forever! HESHE is DEAD!"
kill_text_map["extinguish"] = "MOBNAME is choked under the intense pressure! HESHE is DEAD!"
kill_text_map["finger of death"] = "With a final dark incantation, the life is blasted out of MOBNAME! HESHE is DEAD!"
kill_text_map["fire blast"] = "A dazzling blast of fire completely engulfs MOBNAME!! HESHE is DEAD!"
kill_text_map["fire breath"] = "MOBNAME is engulfed by a blazing inferno of fiery death!! HESHE is DEAD!"
kill_text_map["fire rain"] = "MOBNAME's body is incinerated by the fiery rain! HESHE is DEAD!"
kill_text_map["fire storm"] = "A dazzling storm of fire completely engulfs MOBNAME!! HESHE is DEAD!"
-- fireball = same as balefire
kill_text_map["flame arrow"] = "A flaming spear of fire blasts MOBNAME out of existence!! HESHE is DEAD!"
kill_text_map["flamestrike"] = "A pillar of fire rains down on MOBNAME, slaying HIMHER with purifying heat!! HESHE is DEAD!"
kill_text_map["flaming sphere"] = "MOBNAME drops as the intense heat fries HIMHER! HESHE is DEAD!"
kill_text_map["force bolt"] = "MOBNAME glows momentarily then falls to the floor, DEAD! HESHE is DEAD!"
kill_text_map["forestfire"] = "Burning debris appears all around and homes in on MOBNAME! HESHE is DEAD!"
kill_text_map["flare"] = "The intense light burns right through MOBNAME!! HESHE is DEAD!"
kill_text_map["gouge"] = "MOBNAME quivers briefly as HISHER internals are gouged out. HESHE is DEAD!"
kill_text_map["green death"] = "The fire in MOBNAME's eyes dies as the mist invades HISHER lungs. HESHE is DEAD!"
kill_text_map["ground strike"] = "The earth rises up and squeezes the life from MOBNAME!! HESHE is DEAD!"
-- hand of justice = generic holy damage
kill_text_map["harm"] = "The power of the gods turns MOBNAME into nothing more than a twisted bulk!! HESHE is DEAD!"
kill_text_map["holy arrow"] = "MOBNAME is pierced through as the holy arrow slams into HIMHER!! HESHE is DEAD!"
kill_text_map["holy fury"] = "The blast of holy might brings MOBNAME down! HESHE is DEAD!"
kill_text_map["holy rain"] = "The holy rain purges MOBNAME of all evil, permanently! HESHE is DEAD!"
kill_text_map["holy strike"] = "MOBNAME's sins are purged, forever!! HESHE is DEAD!"
kill_text_map["hydroblast"] = "MOBNAME goes down clutching HISHER throat for air! HESHE is DEAD!"
kill_text_map["ice bolt"] = "The bolt of ice goes straight through MOBNAME, pinning HIMHER to the ground! HESHE is DEAD!"
kill_text_map["ice cloud"] = "MOBNAME is frozen and shattered by the deadly cloud of frost!! HESHE is DEAD!"
kill_text_map["ice daggers"] = "MOBNAME is pierced through by tiny slivers of ice. HESHE is DEAD!"
kill_text_map["ice storm"] = "Tendrils of freezing icy magic whip the life from MOBNAME!! HESHE is DEAD!"
kill_text_map["immolate"] = "MOBNAME is disintegrated by the dense shroud of flames! HESHE is DEAD!"
kill_text_map["infernal voice"] = "MOBNAME is completely overwhelmed by holy voices!! HESHE is DEAD!"
kill_text_map["inflict pain"] = "MOBNAME says 'Damn!! I just KNEW I should have stayed in bed today!' HESHE is DEAD!"
kill_text_map["kick"] = "MOBNAME crumples as the last remaining breath is kicked out of HIMHER. HESHE is DEAD!"
-- kobold stench = same as kspray
kill_text_map["kspray"] = "MOBNAME's disease removes MOBNAME from this world!!"
kill_text_map["lash"] = "MOBNAME can take no more and dies from the final lashing. HESHE is DEAD!"
kill_text_map["light arrow"] = "MOBNAME is skewered as the arrow of light slams into HIMHER!! HESHE is DEAD!"
kill_text_map["lighting bolt"] = "The introduction of 50,000 volts to MOBNAME has a devastating effect!! HESHE is DEAD!"
-- lightning strike = same as lightning weapon damage
kill_text_map["magic missile"] = "Magical bolts tear into MOBNAME rendering HIMHER lifeless!! HESHE is DEAD!"
kill_text_map["major swarm"] = "MOBNAME screams as thousands of tearing teeth flay HISHER body!! HESHE is DEAD!"
kill_text_map["marbu jet"] = "MOBNAME's brain is destroyed as poison enters HISHER skull. HESHE is DEAD!"
kill_text_map["miasma"] = "MOBNAME's body is wracked with pain as HESHE drops to the ground! HESHE is DEAD!"
kill_text_map["mind freeze"] = "MOBNAME falls to the ground limply as HISHER brain stops working! HESHE is DEAD!"
kill_text_map["mind thrust"] = "MOBNAME's mind is destroyed by the sheer force of will!! HESHE is DEAD!"
kill_text_map["minor swarm"] = "MOBNAME goes down under a thousand tiny insect bites!! HESHE is DEAD!"
kill_text_map["moonbeam"] = "MOBNAME is brutally slain by the forces of darkness! HESHE is DEAD!"
kill_text_map["nerve shock"] = "MOBNAME's body writhes as HISHER nerves cease to function! HESHE is DEAD!"
kill_text_map["neural burn"] = "MOBNAME goes completely still as HISHER brain is melted! HESHE is DEAD!"
kill_text_map["neural overload"] = "MOBNAME starts to sound like Ivar as HISHER brain explodes! HESHE is DEAD!"
kill_text_map["nightmare touch"] = "MOBNAME is slain by HISHER own worst nightmare, a pissed off adventurer with a big weapon! HESHE is DEAD!"
kill_text_map["nova"] = "You shield your eyes as the intense light slays MOBNAME! HESHE is DEAD!"
kill_text_map["pillar of fire"] = "Pillars of fire rain down on MOBNAME! HESHE is DEAD!"
-- prismatic spray = default/generic damage
kill_text_map["project force"] = "The mind force crushes MOBNAME into a bloody pulp! HESHE is DEAD!"
-- psionic blast = basic energy damage message
kill_text_map["psychic crush"] = "MOBNAME's brain explodes from HISHER ears!! HESHE is DEAD!"
-- psychic drain = same as psychic crush
kill_text_map["purgatory"] = "MOBNAME's soul is damned to eternal purgatory! HESHE is DEAD!"
kill_text_map["purge"] = "MOBNAME is purged by holy force! HESHE is DEAD!"
kill_text_map["rainbow"] = "A cascade of color explodes MOBNAME into a thousand motes of light. HESHE is DEAD!"
kill_text_map["raven scourge"] = "The acidic venom flays MOBNAME's skin from HISHER bones. HESHE is DEAD!"
-- raw flesh = generic negative damage
kill_text_map["repentance"] = "MOBNAME repents and sacrifices itself for absolution! HESHE is DEAD!"
kill_text_map["rune of ix"] = "A rune of IX burns through the soul of MOBNAME! HESHE is DEAD!"
-- sap = same as bash weapon damage
kill_text_map["scorch"] = "MOBNAME starts to disintegrate as HESHE is melted by the blast! HESHE is DEAD!"
kill_text_map["scourge"] = "MOBNAME's form is completely destroyed by plague!! HESHE is DEAD!"
kill_text_map["shard of ice"] = "MOBNAME turns blue as HESHE is perforated by the shard of ice! HESHE is DEAD!"
kill_text_map["shock aura"] = "The life is shocked out of MOBNAME. HESHE is DEAD!"
kill_text_map["shocking grasp"] = "MOBNAME's heart is stopped by searing electricity through HISHER body!! HESHE is DEAD!"
-- soften = generic negative damage
kill_text_map["solar flare"] = "The blast of energy rips a hole right through MOBNAME!! HESHE is DEAD!"
kill_text_map["soul rip"] = "The blast of energy tears apart the soul of MOBNAME!! HESHE is DEAD!"
kill_text_map["soulburn"] = "MOBNAME's soul is utterly destroyed by the blast! HESHE is DEAD!"
kill_text_map["spasm"] = "MOBNAME's body creaks loudly and slams to the ground HARD! HESHE is DEAD!"
kill_text_map["spear of odin"] = "MOBNAME is burnt to a crisp by Odin's spear! HESHE is DEAD!"
kill_text_map["spiral"] = "Multiple slashes to the body end the life of MOBNAME! HESHE is DEAD!"
kill_text_map["spirit bolt"] = "The bolt tears into MOBNAME, bringing HIMHER down hard!! HESHE is DEAD!"
kill_text_map["spirit strike"] = "The force of the spirits purges MOBNAME from this world! HESHE is DEAD!"
-- spiritual disruption = same as spiritual force
kill_text_map["spiritual force"] = "MOBNAME's spirit doesn't need this crap and leaves to find another body! HESHE is DEAD!"
kill_text_map["spunch"] = "The mighty force behind the shield punch shatters MOBNAME!! HESHE is DEAD!"
kill_text_map["starburst"] = "MOBNAME is destroyed by the tiny starbursts! HESHE is DEAD!"
kill_text_map["stomp"] = "The last shred of life is stomped out of MOBNAME! HESHE is DEAD!"
kill_text_map["stun"] = "The sudden violent blow to the head destroys MOBNAME! HESHE is DEAD!"
kill_text_map["sweep"] = "The impact of the fall shatters MOBNAME's body! HESHE is DEAD!"
kill_text_map["talon"] = "MOBNAME gurgles as razor sharp talons cut away HISHER last piece of life. HESHE is DEAD!"
-- telekinesis = generic bash damage
kill_text_map["teleport behind"] = "MOBNAME stares with lifeless surprise after the last fatal backstab!! HESHE is DEAD!"
kill_text_map["tempest"] = "MOBNAME is utterly smashed by the force of the blast!! HESHE is DEAD!"
kill_text_map["torment"] = "MOBNAME's tormented and empty corpse falls to the floor! HESHE is DEAD!"
kill_text_map["tornado"] = "The tornado rips into MOBNAME and then slams HIMHER down like a rag doll! HESHE is DEAD!"
kill_text_map["toxic cloud"] = "MOBNAME gasps for air and falls to the ground clutching HISHER throat! HESHE is DEAD!"
kill_text_map["trauma"] = "MOBNAME is completely traumatized and falls to the floor gasping! HESHE is DEAD!"
kill_text_map["trip"] = "The trip causes MOBNAME to break HISHER skull on the ground! HESHE is DEAD!"
kill_text_map["ultrablast"] = "MOBNAME screams as HESHE is engulfed by the atomic force!! HESHE is DEAD!"
kill_text_map["uppercut"] = "The battered corpse of MOBNAME falls to the floor lifeless. HESHE is DEAD!"
kill_text_map["vampiric touch"] = "Blood explodes from MOBNAME's every orifice!! HESHE is DEAD!"
kill_text_map["vengeance"] = "The ultimate revenge is taken against MOBNAME! HESHE is DEAD!"
kill_text_map["warcry"] = "The sonic fury of the warcry bursts MOBNAME's brains!! HESHE is DEAD!"
kill_text_map["whirlwind"] = "The force of the whirlwind completely overwhelms MOBNAME's body!! HESHE is DEAD!"
kill_text_map["white flame"] = "The white-hot flame sears the life from MOBNAME!! HESHE is DEAD!"
kill_text_map["wind blast"] = "The force of the blast finished off MOBNAME! HESHE is DEAD!"
kill_text_map["winds of reckoning"] = "MOBNAME answers to the winds of reckoning! HESHE is DEAD!"
kill_text_map["wither"] = "With the snapping of brittle bone, MOBNAME is completely withered!! HESHE is DEAD!"
-- wrath of god = generic lighting damage

--[=[
    STILL NEED SUBCLASS SPECIFIC:
    mindflay   (mentalist)
    strike undead (necromancer)
    hammerswing (blacksmith)
    heavenly smiting (priest)
    zombify (necromancer)
    terminate (paladin)
    flay (avenger)
    necrotic touch (venomist)
    call lightning (ranger)
    blast undead (necromancer)
    hammering blow (blacksmith)
    spiral (thief)
    necrocide (necromancer)
    eruption (ranger)
    apocalypse (paladin)
    heavenly balance (paladin)
    voice of god (cleric)

    archery maybe? (ranger)
    charge ? (knight)
]=]

local lib = {}

---Returns the name of the last mob killed
---@return string
function lib.last_kill()
    return last_kill
end

local function process_kill(name, line, wildcards)
    local reason = string.gsub(string.sub(name, TRIGGER_PREFIX_LEN + 1), "_", " ")  -- Remove prefix from trigger name and convert _ to spaces for the original damage source
    last_kill = wildcards.mob or ""

    if (callback_function ~= nil) then
        callback_function(last_kill, reason)
    end
end

local function create_triggers(omit_from_output)
    local omit = false
    if (omit_from_output ~= nil) then omit = (omit_from_output and true or false) end

    for reason, text in pairs(kill_text_map) do
        -- Turn the text into a valid regular expression
        local regex = text
        regex = string.gsub(regex, [[(\\|\^|\$|\.|\||\?|\*|\+|\(|\)|\[|\]|\{)]], [[\%1]]) -- Escape special characters: \ ^ $ . \ | ? * + ( ) [ ] {
        regex = string.gsub(regex, "MOBNAME", "(?<mob>.*)", 1)
        regex = string.gsub(regex, "MOBNAME", "(.*)")
        regex = string.gsub(regex, "HISHER", "(His|his|Her|her|Its|its)")
        regex = string.gsub(regex, "HIMHER", "(Him|him|Her|her|It|it)")
        regex = string.gsub(regex, "HESHE", "(He|he|She|she|It|it)")
        regex = "^" .. regex .. "$" -- Only match full lines

        local trigger_name = TRIGGER_PREFIX .. string.gsub(reason, " ", "_")
        Trigger.new(trigger_name, "KilledBy", regex, { omit_from_output = omit, enabled = true, keep_evaluating = true }, process_kill)
    end
end

---Initialize kill_lib triggers
---@param callback kill_callback_function? # Optional callback function called whenever we process a mob kill
---@param omit_from_output boolean? # Whether or not we should omit kill text from the output
function lib.init(callback, omit_from_output)
    callback_function = callback
    create_triggers(omit_from_output)
end

return lib