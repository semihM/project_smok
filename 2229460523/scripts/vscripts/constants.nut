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

    /// Customized default settings
    CustomizedDefaults = "admin system/defaults.txt"

    /// Bot sharing/looting settings
    BotSettings = "admin system/botparams.txt"
}

/*************************\
* TIMER NAMES USED BY CMDS *
\*************************/
::Constants.TimerNames <-
{
    WatchNetProp = "NetPropWatch_"

    Apocalypse = "Propageddon_"

    MeteorShower = "MeteorShower_"

    BotThinkAdder = "BotThinkAdder_"

    BotShareAttemptSlot2 = "BotThinkShareAttemptSlot2_"

    BotShareAttemptSlot3 = "BotThinkShareAttemptSlot3_"

    BotSearchAttemptSlot2 = "BotThinkSearchAttemptSlot2_"
    
    BotSearchAttemptSlot3 = "BotThinkSearchAttemptSlot3_"

    CarPush = "CarPushSingle_"
}

/********************\
*  DEFAULT SETTINGS  *
\********************/
::Constants.ReadDefaultsFile <- function()
{
    local defs = FileToString(::Constants.Directories.CustomizedDefaults);
    local df = {};
    if(defs == null)
    {   // TO-DO find a better way for getting the proper string of the default table
        local defstring = 
@"// >>> This file contains some editable default settings
// >>> The characters // and /// indicate comments starting after them, which are ignored
// >>> This file gets compiled directly within the project_smok, so be careful with the formatting and what is written here!
//		
// >>> Values with comment DON'T CHANGE THIS are expected to stay same, they are critical!
// >>> No key-value pair should be removed if there isn't a comment about saying otherwise!
// >>> Key names should not be changed!
//	-> key-value pair example: RestoreModelsOnJoin = true
//					(key)	       = (value)
//
// >>>Formatting should follow these rules:
// 	1. Every {, [ and "" character should have corresponding closing character: }, ] and "" 
//	2. Anything written after ""//"" characters are ignored
// 	3. Values are case-sensitive: (True and true are not the same!)
//

{
    /// Basic Settings
    Basics = 
    {
        RestoreModelsOnJoin = true 	// Restore model from last chapter
        IgnoreDeletingPlayers = true 	// Ignore when ""kill"" or ""becomeragdoll"" inputs fired by a player on another player
        AllowCustomResponses = true 	// Allow custom sequences and custom responses
        AllowCustomSharing = true 	// Allow sharing of packs and grenades by holding R and rightclick
        AllowAutomatedSharing = true 	// Allow bots to share their packs and grenades
        LastLootThinkState = true 	// State of the bots thinking about looking for grenades/packs and sharing 
        IgnoreSpeakerClass = true 	// Ignore entity's class to be considered as a ""speaker""
    }
    
    /// Tables of other custom settings
    Tables =
    {
        /// Output messages to chat
        Outputs =
        {
            State = false // true: print outputs to chat; false: print outputs to console
        }

        /// Grab-yeet basic settings
        GrabYeet =
        {
            GrabRadiusTolerance = 30 // Radius within the aimed location to grab closest if not aiming at an object  
            SurvivorSettings =  // Default settings for all survivors
            {
                entid="""",                   //  DON'T CHANGE THIS
                yeetSpeed = 1500.0,         // Yeeting speed
                yeetPitch = -10,            // Pitch of the yeeting relative to player, below zero to throw higher
                grabRange = 170,            // Maximum range for grabbing
                grabHeightBelowEyes = 30,   // Used with grabByAimedPart 0, how much lower to hold the object below eyes
                grabDistMin = 75,           // Minimum distance between player and held object while holding
                grabAttachPos = ""forward"",  //  DON'T CHANGE THIS, currently best working attachment point is ""forward""
                grabByAimedPart = 1         // 1: grab object by aimed point, 0: grab object by it's origin (probably gonna get stuck)
            }
            ValidGrabClasses =  // Class names available for grab; remove any class you don't want grabbed, or add if you want (some classes may crash the game) 
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

        /// Hat wearing basic settings
        // Attachment points:
        //[
        //      ""eyes"",""mouth"",""forward"",""survivor_light"",""survivor_neck"",
        //      ""primary"",""L_weapon_bone"",""muzzle_flash"",""armL_T2"",""armR_T2"",""medkit"",
        //      ""bleedout"",""pistol"",""pills"",""spine"",""grenade"",""molotov"",
        //      ""legL"",""legL_B"",""rfoot"",""lfoot"",""thighL"",""weapon_bone""
        //]
        Hats = 
        {
            SurvivorSettings =  // Default settings for all survivors
            {
                entid="""",   		//  DON'T CHANGE THIS
                wearAttachPos = ""eyes"", // Default attachment point, one of the above
                wearAbove = 5,  	// Extra height above the given attachment point
                collisiongroup = 0  	// DON'T CHANGE UNLESS YOU KNOW THE COLLISION GROUP CONSTANTS. Collision group of the hat
            }
        }

        /// Line saving
        LineSaving =
        {
            State = true    	// true: save last spoken random line, false: don't save last random line
            SurvivorSettings =  // Default saved line speaker(target) and line's path(source) for all survivors
            {
                target="""",
                source=""""
            }
        }

        /// Particles basic settings
        Particles =
        {
            State = true    			// true: save last spawned random particle, false: don't save last random particle
            AttachAtAimedPointState = true  	// true: attach particle at aimed location of the object, false: attach it to origin of aimed object
            AttachDuration = -1     		// Preferred attachment duration for attached particle, -1: infinite , any other positive real number works
            SurvivorSettings =  		// Default saved particle settings for all survivors
            {
                duration=-1,    		// Preferred attachment duration for saved particle, -1: infinite, any other positive real number works
                source=""""       		// Particle name
            }
        }

        /// Prop spawning basic settings
        PropSpawn = 
        {
            Type = ""all""    		// DON'T CHANGE THIS, this value updates while using the menus
            SurvivorSettings =  	// Default extra spawn settings for props for all survivors
            {
                dynamic=		// Dynamic class props
                {
                    spawn_height=0  	// Spawn height extra
                },
                physics=    		// Physics classes
                {
                    spawn_height=0
                },
                ragdoll=    		// Ragdoll classes
                {
                    spawn_height=0
                }
            }
        }

        /// Explosion basic settings for each survivor
        Explosions =
        {
            SurvivorSettings =  // Default explosion settings for all survivors
            {
                delay=1,                     // Explosion delay
                effect_name=""flame_blue"",    // Particle to use until explosion
                dmgmin = 10,                 // Minimum damage from explosion
                dmgmax = 30,                 // Maximum damage from explosion
                radiusmin = 300,            // Minimum damage and push radius of explosion
                radiusmax = 450,             // Maximum damage and push radius of explosion
                minpushspeed = 2500,         // Minimum pushing speed of the explosion
                maxpushspeed = 10000         // Maximum pushing speed of the explosion
            }
        }

        /// Model keeping state
        ModelPreferences =
        {
            State = true    // true: restore last model for the next chapter/reset, false: restore original model after the chapter/reset
        }

        /// Apocalypse-propageddon starting state
        Apocalypse =
        {
            State = 0   // State of apocalypse when starting the game; 0: start off, 1: start on
        }

        /// Meteor shower starting state and default models
        MeteorShower =
        {
            State = 0   // State of meteor shower when starting the game; 0: start off, 1: start on
            Models =    // Models used for meteor rocks and chunks, add or remove any models
            {
                _rocks = 
                [
                    ""models/props/cs_militia/militiarock02.mdl"",
                    ""models/props/cs_militia/militiarock03.mdl"",
                    ""models/props/cs_militia/militiarock05.mdl"",
                    ""models/props_wasteland/rock_moss01.mdl"",
                    ""models/props_wasteland/rock_moss02.mdl"",
                    ""models/props_wasteland/rock_moss03.mdl"",
                    ""models/props_wasteland/rock_moss04.mdl"",
                    ""models/props_wasteland/rock_moss05.mdl"",
                    ""models/props_wasteland/rockcliff07b.mdl""
                ]
                _chunks =
                [
                    ""models/props_debris/concrete_chunk02a.mdl"",
                    ""models/props_debris/concrete_chunk07a.mdl"",
                    ""models/props_interiors/concretepiller01_dm01_4.mdl"",
                    ""models/props_unique/zombiebreakwallinterior01_concrete_dm_part03.mdl"",
                    ""models/props_unique/zombiebreakwallinterior01_concrete_dm_part04.mdl"",
                    ""models/lostcoast/props_wasteland/rock_coast01e.mdl"",
                    ""models/lostcoast/props_wasteland/rock_cliff02a.mdl"",
                    ""models/lostcoast/props_wasteland/rock_cliff02b.mdl"",
                    ""models/lostcoast/props_wasteland/rock_cliff02c.mdl"",
                    ""models/lostcoast/props_wasteland/rock_cliff02d.mdl""
                ]
                _custom = []
            }
        }

        // Tank rocks default settings
        TankRock =
        {
            pushenabled = true,                  // true: rock hits launch players, false: no launching
            rockorigin = null,                   // DON'T CHANGE THIS, stores where rock was throw
            rockpushspeed = 900,                 // Speed of rock hit launching players
            raise = 300,                         // Speed (direction normal to ground) to push players up to help launching
            friction = 0.01,                     // Friction scale to help launch effect, causes sliding
            randomized = false,                  // true: random rock models, false: default rock model
            randomized_spawn_prop_after = true   // (Requires randomized=true) true: Keep random model after hit, false: Destroy random model after hit
        }
    }
}";

        StringToFile(::Constants.Directories.CustomizedDefaults, defstring);
        defs = FileToString(::Constants.Directories.CustomizedDefaults);
        df = compilestring("local t="+defs+";return t;")();
        ::Constants.Defaults <- df;
    }
    else
    {
        df = compilestring("local t="+defs+";return t;")();
        ::Constants.Defaults <- df;
    }
    
    ::Constants.Defaults.Settings <- "AdminsOnly = true\nDisplayMsgs = true\nEnableIdleKick = false\nIdleKickTime = 60\nAdminPassword = \"\"";

    ::Constants.Defaults.ValidSurvivorNamesLower <- ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

    ::Constants.Defaults.Tables.Looping <-
    {
        State = false   // "DON'T CHANGE THIS", loops can't be started by changing this state

        SurvivorSettings =  // "DON'T CHANGE THIS", Default settings for all survivors, this table reset after calling the loop
        {
            timername="",   
            character="",   
            sequence={}
        }
    }
}

try
{
    ::Constants.ReadDefaultsFile();
}
catch(e)
{
    printl("[Error] FAILED TO READ DEFAULTS.TXT, USING BACK-UP TABLE. ERROR: "+e);
    ::Constants.Defaults <-
    {
        /// Basic Settings
        Basics = 
        {
            RestoreModelsOnJoin = true 	// Restore model from last chapter
            IgnoreDeletingPlayers = true 	// Ignore when "kill" or "becomeragdoll" inputs fired by a player on another player
            AllowCustomResponses = true 	// Allow custom sequences and custom responses
            AllowCustomSharing = true 	// Allow sharing of packs and grenades by holding R and rightclick
            AllowAutomatedSharing = true 	// Allow bots to share their packs and grenades
            LastLootThinkState = true 	// State of the bots thinking about looking for grenades/packs and sharing 
            IgnoreSpeakerClass = true 	// Ignore entity's class to be considered as a "speaker"
        }

        /// Tables of other custom settings
        Tables =
        {
            /// Output messages to chat
            Outputs =
            {
                State = false // true: print outputs to chat; false: print outputs to console
            }

            /// Grab-yeet basic settings
            GrabYeet =
            {
                GrabRadiusTolerance = 30 // Radius within the aimed location to grab closest if not aiming at an object  
                SurvivorSettings =  // Default settings for all survivors
                {
                    entid="",                   //  DON'T CHANGE THIS
                    yeetSpeed = 1500.0,         // Yeeting speed
                    yeetPitch = -10,            // Pitch of the yeeting relative to player, below zero to throw higher
                    grabRange = 170,            // Maximum range for grabbing
                    grabHeightBelowEyes = 30,   // Used with grabByAimedPart 0, how much lower to hold the object below eyes
                    grabDistMin = 75,           // Minimum distance between player and held object while holding
                    grabAttachPos = "forward",  //  DON'T CHANGE THIS, currently best working attachment point is "forward"
                    grabByAimedPart = 1         // 1: grab object by aimed point, 0: grab object by it's origin (probably gonna get stuck)
                }
                ValidGrabClasses =  // Class names available for grab; remove any class you don't want grabbed, or add if you want (some classes may crash the game) 
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

            /// Hat wearing basic settings
            // Attachment points:
            //[
            //      "eyes","mouth","forward","survivor_light","survivor_neck",
            //      "primary","L_weapon_bone","muzzle_flash","armL_T2","armR_T2","medkit",
            //      "bleedout","pistol","pills","spine","grenade","molotov",
            //      "legL","legL_B","rfoot","lfoot","thighL","weapon_bone"
            //]
            Hats = 
            {
                SurvivorSettings =  // Default settings for all survivors
                {
                    entid="",   		//  DON'T CHANGE THIS
                    wearAttachPos = "eyes", // Default attachment point, one of the above
                    wearAbove = 5,  	// Extra height above the given attachment point
                    collisiongroup = 0  	// DON'T CHANGE UNLESS YOU KNOW THE COLLISION GROUP CONSTANTS. Collision group of the hat
                }
            }

            /// Line saving
            LineSaving =
            {
                State = true    	// true: save last spoken random line, false: don't save last random line
                SurvivorSettings =  // Default saved line speaker(target) and line's path(source) for all survivors
                {
                    target="",
                    source=""
                }
            }

            /// Particles basic settings
            Particles =
            {
                State = true    			// true: save last spawned random particle, false: don't save last random particle
                AttachAtAimedPointState = true  	// true: attach particle at aimed location of the object, false: attach it to origin of aimed object
                AttachDuration = -1     		// Preferred attachment duration for attached particle, -1: infinite , any other positive real number works
                SurvivorSettings =  		// Default saved particle settings for all survivors
                {
                    duration=-1,    		// Preferred attachment duration for saved particle, -1: infinite, any other positive real number works
                    source=""       		// Particle name
                }
            }

            /// Prop spawning basic settings
            PropSpawn = 
            {
                Type = "all"    		// DON'T CHANGE THIS, this value updates while using the menus
                SurvivorSettings =  	// Default extra spawn settings for props for all survivors
                {
                    dynamic=		// Dynamic class props
                    {
                        spawn_height=0  	// Spawn height extra
                    },
                    physics=    		// Physics classes
                    {
                        spawn_height=0
                    },
                    ragdoll=    		// Ragdoll classes
                    {
                        spawn_height=0
                    }
                }
            }

            /// Explosion basic settings for each survivor
            Explosions =
            {
                SurvivorSettings =  // Default explosion settings for all survivors
                {
                    delay=1,                     // Explosion delay
                    effect_name="flame_blue",    // Particle to use until explosion
                    dmgmin = 10,                 // Minimum damage from explosion
                    dmgmax = 30,                 // Maximum damage from explosion
                    radiusmin = 300,            // Minimum damage and push radius of explosion
                    radiusmax = 450,             // Maximum damage and push radius of explosion
                    minpushspeed = 2500,         // Minimum pushing speed of the explosion
                    maxpushspeed = 10000         // Maximum pushing speed of the explosion
                }
            }

            /// Model keeping state
            ModelPreferences =
            {
                State = true    // true: restore last model for the next chapter/reset, false: restore original model after the chapter/reset
            }

            /// Apocalypse-propageddon starting state
            Apocalypse =
            {
                State = 0   // State of apocalypse when starting the game; 0: start off, 1: start on
            }

            /// Meteor shower starting state and default models
            MeteorShower =
            {
                State = 0   // State of meteor shower when starting the game; 0: start off, 1: start on
                Models =    // Models used for meteor rocks and chunks, add or remove any models
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

            // Tank rocks default settings
            TankRock =
            {
                pushenabled = true,                  // true: rock hits launch players, false: no launching
                rockorigin = null,                   // DON'T CHANGE THIS, stores where rock was throw
                rockpushspeed = 900,                 // Speed of rock hit launching players
                raise = 300,                         // Speed (direction normal to ground) to push players up to help launching
                friction = 0.01,                     // Friction scale to help launch effect, causes slidin
                randomized = false,                  // true: random rock models, false: default rock model
                randomized_spawn_prop_after = true   // (Requires randomized=true) true: Keep random model after hit, false: Destroy random model after hit
            }
        }
    }

    ::Constants.Defaults.Settings <- "AdminsOnly = true\nDisplayMsgs = true\nEnableIdleKick = false\nIdleKickTime = 60\nAdminPassword = \"\"";

    ::Constants.Defaults.ValidSurvivorNamesLower <- ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

    ::Constants.Defaults.Tables.Looping <-
    {
        State = false   // "DON'T CHANGE THIS", loops can't be started by changing this state

        SurvivorSettings =  // "DON'T CHANGE THIS", Default settings for all survivors, this table reset after calling the loop
        {
            timername="",   
            character="",   
            sequence={}
        }
    }
}

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
        meteormodelspecific = "models/props_interiors/tv.mdl"	// specific model for meteors
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
        local def = defaults[setting];
        if(setting == "meteormodelspecific")
        {
            def = "\"" + def + "\"";
        }
        metosettings += setting + " = " + def + " // " + comments[setting] + (i != length-1 ? "\r\n" : "");
    }
    return metosettings;
}

::Constants.Defaults.MeteorShowerSettings <- ::Constants.GetMeteorShowerSettings();

/// Bot share/loot settings
/*
 * Returns default bot share/loot settings
 */
::Constants.GetBotShareLootSettingsDefaults <- function()
{
    local tbl = 
    {
        CanSee_Share = 110,						// Maximum radius to look for visible player to share with
        CanSee_Loot = 130,						// Maximum radius to look for visible loot to take
        PathableDist_Loot = 150,				// Maximum radius to look for closeby non-visible loot if nothing visible found
        VisibleDistLimit = 400,					// Maximum radius to walk for a non-visible loot, works with closeby pathable locations if no item is visible
        ShareTimeout = 7,						// Maximum time in seconds to abort share attempt
        ReachTimeout = 6,						// Maximum time in seconds to abort item getting attempt
        BotOriginLootRadius = 250,				// Maximum radius to declare a loot "closeby"
        ClosestPlayerMaxDist = 250,				// Maximum radius to declare a player "closeby"
        SpawnerRadiusAroundClosest = 200,		// Minimum radius to declare a weapon/grenade spawner "closeby"; if target or bot is in radius, no sharing will be done
        MaxRadiusToLetShare = 100,				// Maximum radius to let bot share their loot
        MaxRadiusToTake = 100,					// Maximum radius to let bot take the loot
        MinThinkDelay = 1.3						// Minimum delay between each think cycle
        MaxOffsetThinkDelay = 0.5				// Maximum extra delay to add to MinThinkDelay
        RandomChanceForShare = 0.6,				// Chance of share attempt every think cycle (< MinThinkDelay + MaxOffsetThinkDelay) 
        HoldNewGivenFor = 4,					// Minimum time in seconds to pause sharing for the bot after a new item was given to the them
        ItemShareTimerDelay = 0.5,				// Time in seconds to check sharing attempt status
        ItemReachTimerDelay = 0.5,				// Time in seconds to check looting attempt status
        ChanceRelocateWhenTooFarToGive = 0.4,	// Chance to relocate after unsuccessful sharing attempt
        ChanceRelocateWhenTooFarToGet = 0.25,	// Chance to relocate after unsuccessful looting attempt
        Mask = 33579137,						// DON'T CHANGE THIS, bit mask used while tracing loot -> TRACE_MASK_VISIBLE_AND_NPCS = 33579137
        debug = 0								// Debugging state
    }
    return tbl;
}

/*
 * Returns default bot share/loot setting explanations
 */
::Constants.GetBotShareLootSettingsComments <- function()
{
    local tbl = 
    {
        CanSee_Share = "Maximum radius to look for visible player to share with",
        CanSee_Loot = "Maximum radius to look for visible loot to take",
        PathableDist_Loot = "Maximum radius to look for closeby non-visible loot if nothing visible found",
        VisibleDistLimit = "Maximum radius to walk for a non-visible loot, works with closeby pathable locations if no item is visible",
        ShareTimeout = "Maximum time in seconds to abort share attempt",
        ReachTimeout = "Maximum time in seconds to abort item getting attempt",
        BotOriginLootRadius = "Maximum radius to declare a loot closeby",
        ClosestPlayerMaxDist = "Maximum radius to declare a player closeby",
        SpawnerRadiusAroundClosest = "Minimum radius to declare a weapon/grenade spawner closeby; if target or bot is in radius, no sharing will be done",
        MaxRadiusToLetShare = "Maximum radius to let bot share their loot",
        MaxRadiusToTake = "Maximum radius to let bot take the loot",
        MinThinkDelay = "Minimum delay between each think cycle",
        MaxOffsetThinkDelay = "Maximum extra delay to add to MinThinkDelay",
        RandomChanceForShare = "Chance of share attempt every think cycle (< MinThinkDelay + MaxOffsetThinkDelay)",
        HoldNewGivenFor = "Minimum time in seconds to pause sharing for the bot after a new item was given to the them",
        ItemShareTimerDelay = "Time in seconds to check sharing attempt status",
        ItemReachTimerDelay = "Time in seconds to check looting attempt status",
        ChanceRelocateWhenTooFarToGive = "Chance to relocate after unsuccessful sharing attempt",
        ChanceRelocateWhenTooFarToGet = "Chance to relocate after unsuccessful looting attempt",
        Mask = "DON'T CHANGE THIS, bit mask used while tracing loot -> TRACE_MASK_VISIBLE_AND_NPCS = 33579137",
        debug = "Debugging state"
    }
    return tbl;
}

/*
 * Returns properly aligned bot share/loot settings string formatted as:
 *
 *      setting = default_value // explanation
 *
 */
::Constants.GetBotShareLootSettings <- function()
{
    local comments = ::Constants.GetBotShareLootSettingsComments();
    local settings = 
    [
        "CanSee_Share","CanSee_Loot","PathableDist_Loot",
        "VisibleDistLimit","ShareTimeout","ReachTimeout",
        "BotOriginLootRadius","ClosestPlayerMaxDist","SpawnerRadiusAroundClosest",
        "MaxRadiusToLetShare","MaxRadiusToTake","MinThinkDelay",
        "MaxOffsetThinkDelay","RandomChanceForShare","HoldNewGivenFor",
        "ItemShareTimerDelay","ItemReachTimerDelay","ChanceRelocateWhenTooFarToGive",
        "ChanceRelocateWhenTooFarToGet","Mask","debug"
    ]
    local defaults = ::Constants.GetBotShareLootSettingsDefaults();
    
    local defsettings  = "";
    local length = settings.len();
    local setting = "";
    for(local i = 0; i < length; i++)
    {
        setting = settings[i];
        defsettings += setting + " = " + defaults[setting] + " // " + comments[setting] + (i != length-1 ? "\r\n" : "");
    }
    return defsettings;
}

// ::Constants.Defaults.BotShareLootSettings <- ::Constants.GetBotShareLootSettings();

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