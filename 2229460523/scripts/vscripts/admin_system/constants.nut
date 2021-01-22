/*********************\
*  BUILT-IN SETTINGS  *
\*********************/
::Constants <- {}

/************************\
* PATHS USED FOR SETTINGS *
\************************/
::Constants.Directories <-
{
    /// Admins list
    Admins = "admin system/admins.txt"

    /// Script authorization list
    ScriptAuths = "admin system/scriptauths.txt"

    /// Dumbarse list
    Banned = "admin system/banned.txt"

    /// AdminSystem settings list
    Settings = "admin system/settings.txt"

    /// AdminSystem cvar list
    Cvars = "admin system/cvars.txt"

    /// Apocalypse-propageddon custom settings
    ApocalypseSettings = "admin system/apocalypse_settings.txt"

    /// Meteor shower custom settings
    MeteorShowerSettings = "admin system/meteor_shower_settings.txt"

    /// Custom sequences json object
    CustomResponses = "admin system/custom_responses.json"
}

/********************\
*  DEFAULT SETTINGS  *
\********************/
::Constants.Defaults <-
{
    /// Basic Settings
    Basics = 
    {
        RestoreModelsOnJoin = true // Restore model from last chapter

        IgnoreDeletingPlayers = true // Ignore when "kill" or "becomeragdoll" inputs fired by a player on another player

        AllowCustomResponses = true // Allow custom sequences and custom responses

        AllowCustomSharing = true // Allow sharing of packs and grenades by holding R and rightclick

        AllowAutomatedSharing = true // Allow bots to share their packs and grenades

        LastLootThinkState = true // State of the bots thinking about looking for grenades/packs and sharing 

        IgnoreSpeakerClass = true // Ignore entity's class to be considered as a "speaker"

    }
    
    /// Tables of other custom settings
    Tables =
    {
        /// State of putting output messages to chat
        Outputs =
        {
            State = false
        }

        /// Grab-yeet basic settings for each survivor and grab-available classes
        GrabYeet =
        {
            GrabRadiusTolerance = 30

            SurvivorSettings =
            {
                entid="",
                yeetSpeed = 1500.0,
                yeetPitch = -10,
                grabRange = 170,
                grabHeightBelowEyes = 30,
                grabDistMin = 75,
                grabAttachPos = "forward",
                grabByAimedPart = 1
            }

            ValidGrabClasses =
            {
                player = true,
                prop_dynamic = true,
                prop_dynamic_override = true,
                prop_physics = true,
                prop_physics_override = true,
                prop_physics_multiplayer = true,
                prop_vehicle = true,
                prop_car_alarm = true,
                prop_door_rotating = true,
                prop_door_rotating_checkpoint = true
            }
        }

        /// Hat wearing basic settings for each survivor
        Hats = 
        {
            SurvivorSettings =
            {
                entid="",
                wearAttachPos = "eyes",
                wearAbove = 5,
                collisiongroup = 0
            }
        }

        /// Line saving state and basic settings for each survivor
        LineSaving =
        {
            State = true

            SurvivorSettings =
            {
                target="",
                source=""
            }
        }

        /// Speaking loop state and basic settings for each survivor
        Looping = 
        {
            State = false

            SurvivorSettings =
            {
                timername="",
                character="",
                sequence={}
            }
        }

        /// Particles basic settings for each survivor
        Particles =
        {
            State = true

            AttachAtAimedPointState = true
            
            AttachDuration = -1

            SurvivorSettings =
            {
                duration=-1,
                source=""
            }
        }

        /// Prop spawning basic settings for each survivor
        PropSpawn = 
        {
            Type = "all"

            SurvivorSettings =
            {
                dynamic=	
                {
                    spawn_height=0
                },
                physics=
                {
                    spawn_height=0
                },
                ragdoll=
                {
                    spawn_height=0
                }
            }
        }

        /// Explosion basic settings for each survivor
        Explosions =
        {
            SurvivorSettings =
            {
                delay=1
                effect_name="flame_blue"
                dmgmin = 10
                dmgmax = 30
                radiusmin = 300
                radiusmax = 450
                minpushspeed = 2500
                maxpushspeed = 10000
            }
        }

        /// Model keeping state
        ModelPreferences =
        {
            State = true
        }

        /// Apocalypse-propageddon starting state
        Apocalypse =
        {
            State = 0
        }

        /// Meteor shower starting state and default models
        MeteorShower =
        {
            State = 0

            Models =
            {
                _rocks = 
                [
                    "models/props/cs_militia/militiarock02.mdl",
                    "models/props/cs_militia/militiarock03.mdl",
                    "models/props/cs_militia/militiarock05.mdl",
                    "models/props_wasteland/rock_moss01.mdl",
                    "models/props_wasteland/rock_moss02.mdl",
                    "models/props_wasteland/rock_moss03.mdl",
                    "models/props_wasteland/rock_moss04.mdl",
                    "models/props_wasteland/rock_moss05.mdl",
                    "models/props_wasteland/rockcliff07b.mdl"
                ]

                _chunks =
                [
                    "models/props_debris/concrete_chunk02a.mdl",
                    "models/props_debris/concrete_chunk07a.mdl",
                    "models/props_interiors/concretepiller01_dm01_4.mdl",
                    "models/props_unique/zombiebreakwallinterior01_concrete_dm_part03.mdl",
                    "models/props_unique/zombiebreakwallinterior01_concrete_dm_part04.mdl",
                    "models/lostcoast/props_wasteland/rock_coast01e.mdl",
                    "models/lostcoast/props_wasteland/rock_cliff02a.mdl",
                    "models/lostcoast/props_wasteland/rock_cliff02b.mdl",
                    "models/lostcoast/props_wasteland/rock_cliff02c.mdl",
                    "models/lostcoast/props_wasteland/rock_cliff02d.mdl"
                ]

                _custom = []

            }
        }
    }
}

::Constants.Defaults.Settings <- "AdminsOnly = true\nDisplayMsgs = true\nEnableIdleKick = false\nIdleKickTime = 60\nAdminPassword = \"\""

::Constants.Defaults.ValidSurvivorNamesLower <- ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

/****************************\
*  DEFAULT SETTING FUNCTIONS  *
\****************************/
/// Apocalypse event
/*
 * Returns default apocalypse event settings
 */
::Constants.GetApocalypseSettingsDefaults <- function()
{
    local tbl = 
    {
        maxradius = 850				// maximum radius to apply forces
        updatedelay = 1.5			// how often to update entity list in seconds
        mindelay = 0.5				// minimum delay to apply propageddon function
        maxdelay = 2  				// maximum delay to apply propageddon function
        minspeed = 800				// minimum speed
        maxspeed = 24000    		// maximum speed
        dmgmin = 5			    	// minimum damage done to entity
        dmgmax = 100				// maximum damage done to entity
        dmgprob = 0.3				// probability of entity getting damaged
        expmaxradius = 300			// explosion radius maximum
        expdmgmin = 5				// explosion damage minimum
        expdmgmax = 40				// explosion damage maximum
        expprob = 0.015				// probability of explosion
        breakprob = 0.04			// probability of entity being broken
        doorlockprob = 0.02  		// probability of doors getting locked, saferoom doors excluded
        ropebreakprob = 0.05		// probability of a cable or sorts to be broken from its connection point
        entprob = 0.6				// probability of an entity being chosen within the radius
        debug = 0					// Print which entities are effected
    };
    return tbl;
}

/*
 * Returns default apocalypse event setting explanations
 */
::Constants.GetApocalypseSettingsComments <- function()
{
    local tbl = 
    {
        maxradius = "maximum radius to apply forces"
        updatedelay = "how often to update entity list in seconds"
        mindelay = "minimum delay to apply propageddon function"
        maxdelay = "maximum delay to apply propageddon function"
        minspeed = "minimum speed"
        maxspeed = "maximum speed"
        dmgmin = "minimum damage done to entity"
        dmgmax = "maximum damage done to entity"
        dmgprob = "probability of entity getting damaged"
        expmaxradius = "explosion radius maximum"
        expdmgmin = "explosion damage minimum"
        expdmgmax = "explosion damage maximum"
        expprob = "probability of explosion"
        breakprob = "probability of entity being broken"
        doorlockprob = "probability of doors getting locked, saferoom doors excluded"
        ropebreakprob = "probability of a cable or sorts to be broken from its connection point"
        entprob = "probability of an entity being chosen within the radius"
        debug = "Print which entities are effected"
    };
    return tbl;
}

/*
 * Returns properly aligned apocalypse settings string formatted as:
 *
 *      setting = default_value // explanation
 *
 */
::Constants.GetApocalypseSettings <- function()
{
    local comments = ::Constants.GetApocalypseSettingsComments();
    local settings = 
    [
        "maxradius","updatedelay","mindelay",
        "maxdelay","minspeed","maxspeed",
        "dmgmin","dmgmax","dmgprob",
        "expmaxradius","expdmgmin","expdmgmax",
        "expprob","breakprob","doorlockprob",
        "ropebreakprob","entprob","debug"
    ]
    local defaults = ::Constants.GetApocalypseSettingsDefaults();
    
    local apocsettings  = "";
    local length = settings.len();
    local setting = "";
    for(local i = 0; i < length; i++)
    {
        setting = settings[i];
        apocsettings += setting + " = " + defaults[setting] + " // " + comments[setting] + (i != length-1 ? "\r\n" : "");
    }
    return apocsettings;
}

::Constants.Defaults.ApocalypseSettings <- ::Constants.GetApocalypseSettings();

/// Meteor shower event
/*
 * Returns default meteor shower event settings
 */
::Constants.GetMeteorShowerSettingsDefaults <- function()
{
    local tbl = 
    {
        maxradius = 900		        // maximum radius to pick a random meteor attack point
        minspawnheight = 550		// minimum spawn height for meteors
        updatedelay = 2				// how often to create a meteor
        mindelay = 0.5				// minimum extra delay to apply each spawn tick
        maxdelay = 1  				// maximum extra delay to apply each spawn tick
        maxexplosiondelay = 10		// maximum lifetime for a meteor, if meteor is still valid after this delay, it explodes
        minspeed = 1500				// minimum meteor speed
        maxspeed = 7000    			// maximum speed
        expmaxradius = 300			// maximum explosion radius caused by the meteor
        expdmgmin = 3				// minimum explosion damage caused to closeby entities
        expdmgmax = 20				// maximum explosion damage caused to closeby entities
        expprob = 0.9				// probability of the meteor exploding
        scatterprob = 0.55			// probability of the meteor scattering into smaller pieces after hitting the ground
        minscatterchunk = 4			// minimum amount of smaller chunks created if scattering probably was met
        maxscatterchunk = 15		// maximum amount of smaller chunks created
        meteormodelspecific = ""	// specific model for meteors
        meteormodelpick = 0			// enumerated: RANDOM_ROCK = 0, RANDOM_CUSTOM = 1, FIRST_CUSTOM = 2, LAST_CUSTOM = 3, SPECIFIC = 4
        debug = 0					// Print meteor spawn and hit points, explosions, scatters and breaks
    };
    return tbl;
}

/*
 * Returns default meteor shower event setting explanations
 */
::Constants.GetMeteorShowerSettingsComments <- function()
{
    local tbl = 
    {
        maxradius = "maximum radius to pick a random meteor attack point"
        minspawnheight = "minimum spawn height for meteors"
        updatedelay = "how often to create a meteor"
        mindelay = "minimum extra delay to apply each spawn tick"
        maxdelay = "maximum extra delay to apply each spawn tick"
        maxexplosiondelay = "maximum lifetime for a meteor, if meteor is still valid after this delay, it explodes"
        minspeed = "minimum meteor speed"
        maxspeed =   "maximum speed"
        expmaxradius = "maximum explosion radius caused by the meteor"
        expdmgmin = "minimum explosion damage caused to closeby entities"
        expdmgmax = "maximum explosion damage caused to closeby entities"
        expprob = "probability of the meteor exploding"
        scatterprob = "probability of the meteor scattering into smaller pieces after hitting the ground"
        minscatterchunk = "minimum amount of smaller chunks created if scattering probably was met"
        maxscatterchunk = "maximum amount of smaller chunks created"
        meteormodelspecific = "specific model for meteors"
        meteormodelpick = "0 = random rock, 1 = random custom, 2 = first custom, 3 = last custom, 4 = given specific"
        debug = "print meteor spawn and hit points, explosions, scatters and breaks"
    };
    return tbl;
}

/*
 * Returns properly aligned meteor shower settings string formatted as:
 *
 *      setting = default_value // explanation
 *
 */
::Constants.GetMeteorShowerSettings <- function()
{
    local comments = ::Constants.GetMeteorShowerSettingsComments();
    local settings = 
    [
        "maxradius","minspawnheight","updatedelay",
        "mindelay","maxdelay","maxexplosiondelay",
        "minspeed","maxspeed",
        "expmaxradius","expdmgmin","expdmgmax",
        "expprob","scatterprob","minscatterchunk",
        "maxscatterchunk","meteormodelspecific","meteormodelpick",
        "debug"
    ]
    local defaults = ::Constants.GetMeteorShowerSettingsDefaults();
    
    local metosettings  = "";
    local length = settings.len();
    local setting = "";
    for(local i = 0; i < length; i++)
    {
        setting = settings[i];
        metosettings += setting + " = " + defaults[setting] + " // " + comments[setting] + (i != length-1 ? "\r\n" : "");
    }
    return metosettings;
}

::Constants.Defaults.MeteorShowerSettings <- ::Constants.GetMeteorShowerSettings();

/// Models
/*
 * Returns the default model preference table
 */
::Constants.GetDefaultModelPreferences <- function()
{
    local tbl =
    {
        bill=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_namvet.mdl"
            original = "models/survivors/survivor_namvet.mdl"
        }
        francis=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_biker.mdl"
            original = "models/survivors/survivor_biker.mdl"
        }
        louis=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_manager.mdl"
            original = "models/survivors/survivor_manager.mdl"
        }
        zoey=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_teenangst.mdl"
            original = "models/survivors/survivor_teenangst.mdl"
        }
        nick=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_gambler.mdl"
            original = "models/survivors/survivor_gambler.mdl"
        }
        ellis=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_mechanic.mdl"
            original = "models/survivors/survivor_mechanic.mdl"
        }
        coach=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_coach.mdl"
            original = "models/survivors/survivor_coach.mdl"
        }
        rochelle=
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State
            lastmodel = "models/survivors/survivor_producer.mdl"
            original = "models/survivors/survivor_producer.mdl"
        }
    }
    return tbl;
}

::Constants.Defaults.Tables.ModelPreferences.SurvivorSettings <- ::Constants.GetDefaultModelPreferences();

/// Custom sequences
 
/*********************\
*  SEQUENCE ORDERING  *
\*********************/
::SCENES <-
{
	ORDERED = 0
	SHUFFLED = 1
	RANDOM = 2
}

/********************\
*  CUSTOM SEQUENCES  *
\********************/
::Constants.Defaults.Tables.CustomResponses <- {}

/*
 * Returns the default custom sequence table for given survivor
 */
::Constants.GetCustomResponseDefaultTableFor <- function(survivor)
{
    local tbl = {}
    if(survivor == null)
    {
        tbl =
        {
            _SpeakWhenShoved = 
            {
                call_amount = 0
                lastspoken = []
                enabled = false
                prob = 0.5
                startdelay = 0.1
                userandom = true
                randomlinepaths = null
                lineamount = 1
                mindelay = 0.3
                offsetdelay = 2.0
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
            _SpeakWhenLeftSaferoom =
            {
                call_amount = 0
                lastspoken = []
                enabled = false
                prob = 0.15
                startdelay = 2.5
                userandom = false
                randomlinepaths = null
                lineamount = 1
                mindelay = 1.0
                offsetdelay = 3.0
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
            _SpeakWhenUsedAdrenaline =
            {
                call_amount = 0
                lastspoken = []
                enabled = false
                prob = 0.9
                startdelay = 1.0
                userandom = true
                randomlinepaths = null
                lineamount = 6
                mindelay = 1.5
                offsetdelay = 4.5
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
        }
    }
    else
    {
        tbl =
        {
            _SpeakWhenShoved = 
            {
                call_amount = 0
                lastspoken = []
                enabled = true
                prob = 0.5
                startdelay = 0.1
                userandom = true
                randomlinepaths = ::Survivorlines.FriendlyFire[survivor]
                lineamount = 1
                mindelay = 0.3
                offsetdelay = 2.0
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
            _SpeakWhenLeftSaferoom =
            {
                call_amount = 0
                lastspoken = []
                enabled = false
                prob = 0.15
                startdelay = 2.5
                userandom = false
                randomlinepaths = null
                lineamount = 1
                mindelay = 1.0
                offsetdelay = 3.0
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
            _SpeakWhenUsedAdrenaline =
            {
                call_amount = 0
                lastspoken = []
                enabled = true
                prob = 0.9
                startdelay = 1.0
                userandom = true
                randomlinepaths = ::Survivorlines.Excited[survivor]
                lineamount = 6
                mindelay = 1.5
                offsetdelay = 4.5
                order = SCENES.ORDERED
                sequence = {def={scenes=[],delays=[]}}
            }
        }
    }
    return tbl;
}

::Constants.Defaults.Tables.CustomResponses.SurvivorSettings <- function(survivor)
{
    return ::Constants.GetCustomResponseDefaultTableFor(survivor);
}

/*
 * Return the built-in custom sequence table
 */
::Constants.GetBIResponses <- function()
{
    local tbl =
    {
        francis = 
        {
            _SpeakWhenLeftSaferoom = 
            {
                enabled = true
                prob = 0.15
                order = SCENES.RANDOM
                sequence =
                {
                    smokboomer1=
                    {   // "Well hell, let's all- Smok- Booooomer!"
                        scenes=["followme08.vcd","warnsmoker03.vcd","warnboomer03.vcd"]
                        delays=[0, 1.7, 2.45 ]
                    }

                    hateboomerbill1=
                    {   // "If there's one thing I hate more than vampires, it's- Boomer- Bill"
                        scenes=["dlc2canadahate02.vcd","warnboomer01.vcd","namebill01.vcd"]
                        delays=[0, 3.3, 4]
                    }

                    signsayshateboomerbill1=
                    {   // "This sign says, "I hate- Bill!" "
                        scenes=["dlc2bulletinboard01.vcd","namebill02.vcd"]
                        delays=[0, 1.85]
                    }

                    lookingforwardtosmokbill1=
                    {   // "I was getting tired of being cooped up, looking forward to- Smok- Boomer- Bill!"
                        scenes=["c6dlc3intro28.vcd","warnsmoker03.vcd","warnboomer02.vcd","namebill02.vcd"]
                        delays=[0, 3.4, 4.1, 4.7]
                    }

                    signsaysdead=
                    {   // "This sign says, -"...Dead"- AAAAAAAAAAAAAAAAAAA
                        scenes=["dlc2bulletinboard01.vcd","killconfirmation05.vcd","fall02.vcd"]
                        delays=[0, 1.1, 2.2]
                    }

                    hatelouis1=
                    {   // "If there's one thing I hate more than vampires, it's- Louis"
                        scenes=["dlc2canadahate02.vcd","namelouis01.vcd"]
                        delays=[0, 3.3]
                    }

                    louislookshit1=
                    {   // "Louis you look like shit!"
                        scenes=["generic30.vcd"]
                        delays=[0]
                    }
                }
            }
        }
        
        ellis = 
        {
            _SpeakWhenLeftSaferoom = 
            {
                enabled = true
                prob = 0.1
                order = SCENES.RANDOM
                sequence =
                {	
                    ilovecrack1=
                    {   // "Man I hate them zombies but I loooooove- Crack!"
                        scenes=["meleeresponse08.vcd","boomerjar17.vcd"]
                        delays=[2.55,0]
                    }
                }
            }
        }
    }
    return tbl;
}

::Constants.Defaults.Tables.CustomResponses.BIResponses <- function(survivor)
{
    local resp = ::Constants.GetBIResponses();
    if(survivor in resp)
    {
        return resp[survivor];
    }
    else
    {
        local tbl = {};
        return tbl;
    }
}