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
	CustomizedPropSpawnDefaults = "admin system/prop_defaults.txt"

    CustomizedDefaultsBadFormat= "admin system/defaults_BAD_FORMAT.txt"
    CustomizedPropSpawnDefaultsBadFormat= "admin system/prop_defaults_BAD_FORMAT.txt"

    /// Bot sharing/looting settings
    BotSettings = "admin system/botparams.txt"
}

/*************************\
* TIMER NAMES USED BY CMDS *
\*************************/
::Constants.TimerNames <-
{
	RoundStartBotShareEnable = "RoundStartBotThinkShareLoot"
	
    WatchNetProp = "NetPropWatch_"

    WatchNetPropScriptHandle = "NetPropWatchScriptHandle_"

    Apocalypse = "Propageddon_"

    MeteorShower = "MeteorShower_"

    BotThinkAdder = "BotThinkAdder_"

    BotShareAttemptSlot2 = "BotThinkShareAttemptSlot2_"

    BotShareAttemptSlot3 = "BotThinkShareAttemptSlot3_"

    BotSearchAttemptSlot2 = "BotThinkSearchAttemptSlot2_"
    
    BotSearchAttemptSlot3 = "BotThinkSearchAttemptSlot3_"

    CarPush = "CarPushSingle_"
}

/*************\
* TIMER DELAYS *
\*************/
::Constants.TimerDelays <-
{
    RoundStart =
	{
		Apocalypse = 7
	
		MeteorShower = 9

		BotShareLoot = 15
	}
}

/********************\
*  DEFAULT SETTINGS  *
\********************/
::Constants.DefaultsDetailed <-
{
    FormattingIntro =  @"// >>> This file contains some editable default settings
// >>> The characters // and /// indicate comments starting after them, which are ignored
// >>> This file gets compiled directly within the project_smok, so be careful with the formatting and what is written here!
// >>> Errors and fixes done by the add-on will be reported to console, so check the console if you've made a change and wheter it caused a fix to be used
//
// >>> Values with comment DON'T CHANGE THIS are expected to stay same, they are critical!
// >>> No key-value pair should be removed if there isn't a comment about saying otherwise!
// >>> Format follows ""key = value"" pairings. Example pair: RestoreModelsOnJoin = true
// !!!!!!!
// >>> FILE SIZE SHOULD NOT EXCEED 16.5 KB, OR FILE WILL NOT BE READ
// !!!!!!!
// >>>Formatting should follow these rules:
//	1. Key names should not be changed!
//	2. Every {, [ and "" character should have corresponding closing character: }, ] and "" 
//	3. Anything written after ""//"" characters are ignored
//	4. Values are case-sensitive: (True and true are not the same!)
//"

    Basics =
    {
        Title = "\t/// Basic Settings"

        RestoreModelsOnJoin =
        {
            Value = true
            Comment = "// true: Allow keeping models unchanged between chapters/resets, false: Don't allow restoring original model between chapters/resets"
        }
        IgnoreDeletingPlayers = 	
        {
            Value = true
            Comment = "// true: Ignore \"kill\" or \"becomeragdoll\" inputs fired by a player on another player, false: (NOT RECOMMENDED) Allow kicking players with \"kill\" and \"becomeragdoll\" inputs"
        }
        AllowCustomResponses = 	
        {
            Value = true
            Comment = "// true: Custom responses allowed(round start talks, shoving response etc.), false: Disable custom responses"
        }
        AllowCustomSharing =  	
        {
            Value = true
            Comment = "// true: Allow sharing of packs and grenades by holding R and rightclick, false: Don't allow sharing grenades and packs for players"
        }
        AllowAutomatedSharing = 	
        {
            Value = true
            Comment = "// true: Allow bots to share their packs and grenades for bots, false: Don't allow bots sharing the packs/grenades they pick up"
        }
        LastLootThinkState = 	
        {
            Value = true
            Comment = "// true: Make bots start looking for grenades and packs at the round start, false: Use default bot abilities and stop them from looting and sharing"
        }
        IgnoreSpeakerClass = 	
        {
            Value = true
            Comment = "// true: Use any object as a \"speaker\" for a microphone, false: Force entity's class to be \"info_target\" to be used as a \"speaker\""
        }
    }

    Tables =
    {
        Title = "\t/// Tables of other custom settings"

        Outputs =
        {
            Title = "\t\t/// Output messages to chat"
            State =
            {
                Value = false
                Comment = "// true: print outputs to chat; false: print outputs to console"
            }
        }
        
        GrabYeet =
        {
            Title = "\t\t/// Grab-yeet basic settings"
            
            GrabRadiusTolerance = 
            {
                Value = 30
                Comment =  "// Radius around the aimed location to grab closest if not aiming at an object"
            }
            
            SurvivorSettings =
            {
                Value =
                {
                    entid="",                   //  DON'T CHANGE THIS
                    yeetSpeed = 1500.0,         // Yeeting speed
                    yeetPitch = -10,            // Pitch of the yeeting relative to player, below zero to throw higher
                    grabRange = 170,            // Maximum range for grabbing
                    grabHeightBelowEyes = 30,   // Used with grabByAimedPart 0, how much lower to hold the object below eyes
                    grabDistMin = 75,           // Minimum distance between player and held object while holding
                    grabAttachPos = "forward",  //  DON'T CHANGE THIS, currently best working attachment point is ""forward""
                    grabByAimedPart = 1         // 1: grab object by aimed point, 0: grab object by it's origin (probably gonna get stuck)
                }
                ValueComments =
                {
                    entid = "// DON'T CHANGE THIS, gets updated with index of the object being held"
                    yeetSpeed = "// Yeeting speed"
                    yeetPitch = "// Pitch of the yeeting relative to player, below zero to throw higher"
                    grabRange =  "// Maximum range for grabbing"
                    grabHeightBelowEyes = "// Used with grabByAimedPart 0, how much lower to hold the object below eyes"
                    grabDistMin = "// Minimum distance between player and held object while holding"
                    grabAttachPos = "// DON'T CHANGE THIS, currently best working attachment point is \"forward\""
                    grabByAimedPart = "// 1: grab object by aimed point, 0: grab object by it's origin (probably gonna get stuck)"
                }
                Comment = "// Default settings for all survivors"
            }

            ValidGrabClasses =  
            {
                Value = 
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
                    prop_door_rotating_checkpoint = true,
					commentary_dummy = true
                }
                Comment = "// Class names available for grab; remove any class you don't want grabbed, or add if you want (some classes may crash the game)"
            }
        }

        
        Hats = 
        {   
            Title = @"		/// Hat wearing basic settings
		// Attachment points:
		//[
		//      ""eyes"",""mouth"",""forward"",""survivor_light"",""survivor_neck"",
		//      ""primary"",""L_weapon_bone"",""muzzle_flash"",""armL_T2"",""armR_T2"",""medkit"",
		//      ""bleedout"",""pistol"",""pills"",""spine"",""grenade"",""molotov"",
		//      ""legL"",""legL_B"",""rfoot"",""lfoot"",""thighL"",""weapon_bone""
		//]"
            SurvivorSettings =  
            {
                Value =
                {
                    entid="",   		//  DON'T CHANGE THIS
                    wearAttachPos = "eyes", // Default attachment point, one of the above
                    wearAbove = 5,  	// Extra height above the given attachment point
                    collisiongroup = 0  	// DON'T CHANGE UNLESS YOU KNOW THE COLLISION GROUP CONSTANTS. Collision group of the hat
                }
                ValueComments =
                {
                    entid = "// DON'T CHANGE THIS"
                    wearAttachPos = "// Default attachment point, one of the above"
                    wearAbove = "// Extra height above the given attachment point"
                    collisiongroup = "// Collision group of the hat, check m_CollisionGroup netprops of the objects"
                }
                Comment = "// Default settings for all survivors"
            }
        }

        
        LineSaving =
        {
            Title = "\t\t/// Line saving"
            State = 
            {
                Value = true
                Comment = "// true: save last spoken random line, false: don't save last random line"
            }    	
            SurvivorSettings =  
            {
                Value = 
                {
                    target="",
                    source=""
                }
                ValueComments =
                {
                    target = "// Speaker character name lowercase, example: bill"
                    source = "// Voice line path or name, example: scenes/biker/hurrah01"
                }
                Comment = "// Default saved line speaker(target) and line's path(source) for all survivors"
            }
        }

        Particles =
        {
            Title = "\t\t/// Particles basic settings"
            State = 
            {
                Value = true
            	Comment = "// true: save last spawned random particle, false: don't save last random particle"
            }
            AttachAtAimedPointState =
            {
                Value = true
            	Comment = "// true: attach particle at aimed location of the object, false: attach it to origin of aimed object"
            }   	
            AttachDuration =
            {
                Value = -1 
            	Comment = "// Preferred attachment duration for attached particle, -1: infinite , any other positive real number works"
            }      		
            SurvivorSettings =
            {
                Value =     		
                {
                    duration=-1,    		// Preferred attachment duration for saved particle, -1: infinite, any other positive real number works
                    source=""       		// Particle name
                }
                ValueComments =
                {
                    duration = "// Preferred attachment duration for saved particle, -1: infinite, any other positive real number works"   		
                    source = "// Particle name"       		
                }
            	Comment = "// Default saved particle settings for all survivors"
            }
        }

        
        PropSpawn = 
        {
            Title = "\t\t/// Prop spawning basic settings"
            Type = 
            {
                Value = "all"
                Comment = "// DON'T CHANGE THIS, this value updates while using the menus"  
            }		
            SurvivorSettings =  	
            {
                Value =
                {
                    dynamic=		// Dynamic class props
                    {
                        Value = 
                        {
                            spawn_height=
                            {
                                Value = 
                                {
                                    val = 0
									min = 500
									max = 800
                                    flags = HEIGHT_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Height to use with given flags"
									min = "// Minimum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
                                    flags = @"// Flags to use with the values in this table, can be combined with ""|"" character.
						// Flags and explanations:
						// 	HEIGHT_NO_ADDITION		No changes, ignore all flags, origin at aimed point
						// 	HEIGHT_EYELEVEL		Origin raised to eye height
						// 	HEIGHT_USE_VAL		Use whatever height is given in ""val""
						// 	HEIGHT_ADD_VAL		Add whatever height is given in ""val""
						// 	HEIGHT_RANDOM_0_10		Use random height ranged [0,10]
						// 	HEIGHT_RANDOM_0_50		Use random height ranged [0,50]
						// 	HEIGHT_RANDOM_0_100		Use random height ranged [0,100]
						// 	HEIGHT_RANDOM_0_500		Use random height ranged [0,500]
						// 	HEIGHT_RANDOM_M10_0		Use random height ranged [-10,0]
						// 	HEIGHT_RANDOM_M50_0		Use random height ranged [-50,0]
						// 	HEIGHT_RANDOM_M100_0		Use random height ranged [-100,0]
						// 	HEIGHT_RANDOM_M500_0		Use random height ranged [-500,0]
						// 	HEIGHT_RANDOM_M10_10		Use random height ranged [-10,10]
						// 	HEIGHT_RANDOM_M50_50		Use random height ranged [-50,50]
						// 	HEIGHT_RANDOM_M100_100		Use random height ranged [-100,100]
						// 	HEIGHT_RANDOM_M250_250		Use random height ranged [-250,250]
						// 	HEIGHT_RANDOM_M500_500		Use random height ranged [-500,500]
						// 	HEIGHT_RANDOM_GIVEN		Use random height ranged [min,max], ""min"" and ""val"" from this table
						// 	HEIGHT_ADD_RANDOM_0_10		Add random height ranged [0,10]
						// 	HEIGHT_ADD_RANDOM_0_50		Add random height ranged [0,50]
						// 	HEIGHT_ADD_RANDOM_0_100		Add random height ranged [0,100]
						// 	HEIGHT_ADD_RANDOM_0_500		Add random height ranged [0,500]
						// 	HEIGHT_ADD_RANDOM_M10_0		Add random height ranged [-10,0]
						// 	HEIGHT_ADD_RANDOM_M50_0		Add random height ranged [-50,0]
						// 	HEIGHT_ADD_RANDOM_M100_0		Add random height ranged [-100,0]
						// 	HEIGHT_ADD_RANDOM_M500_0		Add random height ranged [-500,0]
						// 	HEIGHT_ADD_RANDOM_M10_10		Add random height ranged [-10,10]
						// 	HEIGHT_ADD_RANDOM_M50_50		Add random height ranged [-50,50]
						// 	HEIGHT_ADD_RANDOM_M100_100		Add random height ranged [-100,100]
						// 	HEIGHT_ADD_RANDOM_M250_250		Add random height ranged [-250,250]
						// 	HEIGHT_ADD_RANDOM_GIVEN		Add random height ranged [min,max], ""min"" and ""val"" from this table
						//
						// Example flag for spawning props above eyelevel ""val"" units:
						// 		flags = HEIGHT_EYELEVEL|HEIGHT_ADD_VAL"
                                }
                                Comment = "// Spawn height"
                            }

                            spawn_angles=
                            {
                                Value = 
                                {
                                    val = "0 0 0"
									min = -45
									max = 45
                                    flags = ANGLE_EYES_YAW|ANGLE_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Angles to use with given flags. Formatted as \"Pitch Yaw Roll\" in degrees"
									min = "// Minimum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
                                    flags = @"// Flags to use with the values in this table, can be combined with ""|"" character.
						// Flags and explanations:
						// 	ANGLE_NO_ADDITION		No changes, ignore all flags, QAngle(0,0,0) = ""0 0 0""
						// 	ANGLE_USE_VAL		Use whatever angle is given in ""val""
						// 	ANGLE_EYES_EXACT		Use exact eye angles of the player
						// 	ANGLE_EYES_PITCH		Use pitch of player's eyes
						// 	ANGLE_EYES_YAW		Use yaw of player's eyes, DEFAULT
						// 	ANGLE_ADD_VAL		Add whatever angle is given in ""val""
						// 	ANGLE_PULL_UP		Add 90 degrees pitch
						// 	ANGLE_PULL_AROUND		Add 180 degrees pitch
						// 	ANGLE_PULL_DOWN		Add -90 degrees pitch
						// 	ANGLE_TURN_RIGHT		Add 90 degrees yaw
						// 	ANGLE_TURN_AROUND		Add 180 degrees yaw
						// 	ANGLE_TURN_LEFT		Add -90 degrees yaw
						// 	ANGLE_ROLLOVER_RIGHT		Add 90 degrees roll
						// 	ANGLE_ROLLOVER		Add 180 degrees roll
						// 	ANGLE_ROLLOVER_LEFT		Add -90 degrees roll
						// 	ANGLE_RANDOM_0_90		Use random filled angle ranged [0,90]
						// 	ANGLE_RANDOM_90_180		Use random filled angle ranged [90,180]
						// 	ANGLE_RANDOM_0_180		Use random filled angle ranged [0,180]
						// 	ANGLE_RANDOM_M90_0		Use random filled angle ranged [-90,0]
						// 	ANGLE_RANDOM_M180_M90		Use random filled angle ranged [-180,-90]
						// 	ANGLE_RANDOM_M180_0		Use random filled angle ranged [-180,0]
						// 	ANGLE_RANDOM_M15_15		Use random filled angle ranged [-15,15]
						// 	ANGLE_RANDOM_M30_30		Use random filled angle ranged [-30,30]
						// 	ANGLE_RANDOM_M60_60		Use random filled angle ranged [-60,60]
						// 	ANGLE_RANDOM_M90_90		Use random filled angle ranged [-90,90]
						// 	ANGLE_RANDOM_GIVEN		Use random filled angle ranged [min,max], ""min"" and ""val"" from this table
						// 	ANGLE_ADD_RANDOM_0_45		Add random filled angle ranged [0,45]
						// 	ANGLE_ADD_RANDOM_45_90		Add random filled angle ranged [45,90]
						// 	ANGLE_ADD_RANDOM_M45_0		Add random filled angle ranged [-45,0]
						// 	ANGLE_ADD_RANDOM_M90_M45		Add random filled angle ranged [-90,-45]
						// 	ANGLE_ADD_RANDOM_M15_15		Add random filled angle ranged [-15,15]
						// 	ANGLE_ADD_RANDOM_M45_45		Add random filled angle ranged [-45,45]
						// 	ANGLE_ADD_RANDOM_GIVEN		Add random filled angle ranged [min,max], ""min"" and ""val"" from this table
						// 
						// Example flag for spawning props facing left of the direction player is facing, rolled over:
						// 		flags = ANGLE_EYES_EXACT|ANGLE_TURN_LEFT|ANGLE_ROLLOVER
						// Example above doesn't use value given in ""val"", but same thing can be created different ways, for example
						// 		val = ""0 -90 180""
						// 		flags = ANGLE_EYES_EXACT|ANGLE_ADD_VAL
						// Some of the flags can overwrite each other(Ones that aren't additive), lowest in this list gets used.
						// Example of ANGLE_USE_VAL flag using ""val"" angle but getting overwritten with ANGLE_EYES_EXACT flag to use player eye angles:
						// 		flags = ANGLE_USE_VAL|ANGLE_EYES_EXACT"
                                }
                                Comment = "// Spawn angles"
                            }
                        }
                    },
                    physics=    		// Physics classes
                    {
                        Value = 
                        {
                            spawn_height=
                            {
                                Value = 
                                {
                                    val = 1
									min = 500
									max = 800
                                    flags = HEIGHT_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Height to use with given flags"
									min = "// Minimum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
                                    flags = "// Flags to use with the values in this table, can be combined with \"|\" character. Check explanations above"
                                }
                                Comment = "// Spawn height"
                            }

                            spawn_angles=
                            {
                                Value = 
                                {
                                    val = "0 0 0"
									min = -45
									max = 45
                                    flags = ANGLE_EYES_YAW|ANGLE_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Angles to use with given flags. Formatted as \"Pitch Yaw Roll\" in degrees"
									min = "// Minimum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
                                    flags = "// Flags to use with the values in this table, can be combined with \"|\" character. Check explanations above"
                                }
                                Comment = "// Spawn angles"
                            }
                        }
                    },
                    ragdoll=    		// Ragdoll classes
                    {
                        Value = 
                        {
                            spawn_height=
                            {
                                Value = 
                                {
                                    val = 2
									min = 500
									max = 800
                                    flags = HEIGHT_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Height to use with given flags"
									min = "// Minimum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: HEIGHT_RANDOM_GIVEN and HEIGHT_ADD_RANDOM_GIVEN"
                                    flags = "// Flags to use with the values in this table, can be combined with \"|\" character. Check explanations above"
                                }
                                Comment = "// Spawn height"
                            }

                            spawn_angles=
                            {
                                Value = 
                                {
                                    val = "0 180 0"
									min = -45
									max = 45
                                    flags = ANGLE_EYES_YAW|ANGLE_ADD_VAL
                                }
                                ValueComments =
                                {
                                    val = "// Angles to use with given flags. Formatted as \"Pitch Yaw Roll\" in degrees"
									min = "// Minimum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
									max = "// Maximum value for random numbers range to use with flags: ANGLE_RANDOM_GIVEN and ANGLE_ADD_RANDOM_GIVEN"
                                    flags = "// Flags to use with the values in this table, can be combined with \"|\" character. Check explanations above"
                                }
                                Comment = "// Spawn angles"
                            }
                        }
                    },
                }
                ValueComments =
                {
                    dynamic = "// Dynamic class props, objects which cant move but be animated"	
                    
                    physics = "// Physics class props, objects with physics simulation enabled"		
                   
                    ragdoll = "// Ragdoll class props, all ragdoll objects"		  
                }
                Comment = "// Default extra spawn settings for props for all survivors"
            }
        }

        Explosions =
        {
			Title = "\t\t/// Explosion basic settings for each survivor"
            SurvivorSettings =
			{
				Value = 
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
				ValueComments =
				{
					delay = "// Explosion delay"
					effect_name = "// Particle to use until explosion"
					dmgmin = "// Minimum damage from explosion"
					dmgmax = "// Maximum damage from explosion"
					radiusmin = "// Minimum damage and push radius of explosion"
					radiusmax =  "// Maximum damage and push radius of explosion"
					minpushspeed = "// Minimum pushing speed of the explosion"
					maxpushspeed = "// Maximum pushing speed of the explosion"
				}
				Comment = "// Default explosion settings for all survivors"
			} 
        }

        
        ModelPreferences =
        {
			Title = "\t\t/// Model keeping state for all players, value gets repeated for all characters"
            State = 
			{
				Value = true
				Comment = "// true: restore last model for the next chapter/reset, false: restore original model after the chapter/reset"
			}
        }

        
        Apocalypse =
        {
			Title = "\t\t/// Apocalypse-propageddon starting state"
            State =
			{
				Value = 0
				Comment = "// State of apocalypse when starting the game; 0: start off, 1: start on"
			}   
        }

        
        MeteorShower =
        {
			Title = "\t\t/// Meteor shower starting state and default models"
            State =
			{
				Value = 0
				Comment = "// State of meteor shower when starting the game; 0: start off, 1: start on"
			}  
            Models =    
            {
				Value = 
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
				ValueComments =
				{
					_rocks = "// Default meteor models to pick randomly from"
					_chunks = "// Default smaller meteor chunk models"
					_custom = "// List of custom model paths to use with meteor shower setting \"meteormodelpick\" values 1 = RANDOM_CUSTOM , 2 = FIRST_CUSTOM and 3 = LAST_CUSTOM"
				}
                Comment = "// Models used for meteor rocks and chunks, add or remove any models"
            }
        }

        
        TankRock =
        {
			Title = "\t\t/// Tank rocks default settings"
			Value =
			{
				pushenabled = true,                  // true: rock hits launch players, false: no launching
				rockorigin = "",                   // DON'T CHANGE THIS, stores where rock was throw
				rockpushspeed = 900,                 // Speed of rock hit launching players
				raise = 300,                         // Speed (direction normal to ground) to push players up to help launching
				friction = 0.01,                     // Friction scale to help launch effect, causes sliding
				randomized = false,                  // true: random rock models, false: default rock model, used with modelpick = 0
				mass_scale = 8,						 // Scale of mass to apply to random models
				rockspawnheight = 50				 // Additional height to add to rock's spawn point, equal to height from ground
				spawn_prop_after = true,   			// true: Keep rock after hit(EXCEPT DEFAULT ROCK), false: Destroy rock after hit
				modelspecific = "models/survivors/survivor_coach.mdl"	// Specific model name to use for rocks, used with modelpick = 1
				custommodels = []					// List of models to pick from randomly, used with modelpick = 2
				modelpick = 0						// 0: Use randomized if enabled otherwise default rock model, 1: Use given model in modelspecific, 2: Pick random models from custommodels list
				modelchangedelay = 2.3				// BE CAREFUL CHANGING THIS VALUE, time in seconds to wait after rock spawns to change it's model
			}
            ValueComments =
			{
				pushenabled = "// true: rock hits launch players, false: no launching"
				rockorigin = "// DON'T CHANGE THIS, stores where rock was throw"
				rockpushspeed = "// Speed of rock hit launching players"
				raise = "// Speed (direction normal to ground) to push players up to help launching"
				friction = "// Friction scale to help launch effect, causes sliding"
				randomized = "// true: random rock models, false: default rock model"
				mass_scale = "// Scale of mass to apply to random models"
				rockspawnheight = "// Additional height to add to rock's spawn point, equal to height from ground"
				spawn_prop_after =  "// true: Keep rock after hit(EXCEPT DEFAULT ROCK), false: Destroy rock after hit"
				modelspecific = "// Specific model name to use for rocks, used with modelpick = 1"	
				custommodels = "// List of models to pick from randomly, used with modelpick = 2"	
				modelpick = "// 0: Use randomized if enabled otherwise default rock model, 1: Use given model in modelspecific, 2: Pick random models from custommodels list"	
				modelchangedelay = "// BE CAREFUL CHANGING THIS VALUE, time in seconds to wait after rock spawns to change it's model"	
			}
        }
    }
}

/********************************\
*  STRINGIFYING DEFAULT SETTINGS  *
\********************************/
::__SingleValWithComment <- function(tbl,key,tblref=null)
{
	if(tblref == null)
	{
		return "\t\t\t" + key + " = " + ((typeof tbl[key].Value  == "string") ? "\""+tbl[key].Value +"\"": tbl[key].Value )
			+ "\t" + tbl[key].Comment
	}
	return "\t\t\t" + key + " = " + ((typeof tblref[key] == "string") ? "\""+tblref[key]+"\"": tblref[key])
		+ "\t" + tbl[key].Comment
}
::__StringifyBasicSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local s = ""
		foreach(key,val in ::Constants.DefaultsDetailed.Basics)
		{
			if(key == "Title")
				continue;

			s += "\t\t" + key + " = " + val.Value + "\t" + val.Comment + "\n\r"
		}
		return s;
	}
	else
	{
		local s = ""
		foreach(key,val in ::Constants.DefaultsDetailed.Basics)
		{
			if(key == "Title")
				continue;

			s += "\t\t" + key + " = " + tblref.Basics[key] + "\t" + val.Comment + "\n\r"
		}
		return s;
	}
}
::__StringifyOutputSettings <- function(tblref=null)
{
    if(tblref == null)
	{
	    return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.Outputs,"State");
    }
    return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.Outputs,"State",tblref.Tables.Outputs);
}
::__StringifyGrabYeetSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local s = ""
		local maintbl = ::Constants.DefaultsDetailed.Tables.GrabYeet;

		s += __SingleValWithComment(maintbl,"GrabRadiusTolerance") + "\n\r";
		
		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		s += "\t\t\tValidGrabClasses = " + maintbl.ValidGrabClasses.Comment + "\n\r\t\t\t{\n\r"
		foreach(cls,val in maintbl.ValidGrabClasses.Value)
		{
			s += "\t\t\t\t" + cls + " = true\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local s = ""
		local maintbl = ::Constants.DefaultsDetailed.Tables.GrabYeet;
		local maintblref = tblref.Tables.GrabYeet

		s += __SingleValWithComment(maintbl,"GrabRadiusTolerance",maintblref) + "\n\r";
		
		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.SurvivorSettings[setting] == "string") ? "\""+maintblref.SurvivorSettings[setting]+"\"": maintblref.SurvivorSettings[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		s += "\t\t\tValidGrabClasses = " + maintbl.ValidGrabClasses.Comment + "\n\r\t\t\t{\n\r"
		foreach(cls,val in maintblref.ValidGrabClasses)
		{
			s += "\t\t\t\t" + cls + " = true\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}
::__StringifyHatsSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local s = ""
		local maintbl = ::Constants.DefaultsDetailed.Tables.Hats;

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local s = ""
		local maintbl = ::Constants.DefaultsDetailed.Tables.Hats;
		local maintblref = tblref.Tables.Hats

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.SurvivorSettings[setting] == "string") ? "\""+maintblref.SurvivorSettings[setting]+"\"": maintblref.SurvivorSettings[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}
::__StringifyLineSavingSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.LineSaving;

		local s = __SingleValWithComment(maintbl,"State") + "\n\r";

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.LineSaving;
		local maintblref = tblref.Tables.LineSaving

		local s = __SingleValWithComment(maintbl,"State",maintblref) + "\n\r";

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.SurvivorSettings[setting] == "string") ? "\""+maintblref.SurvivorSettings[setting]+"\"": maintblref.SurvivorSettings[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}
::__StringifyParticlesSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.Particles;

		local s = __SingleValWithComment(maintbl,"State") + "\n\r"
			+ __SingleValWithComment(maintbl,"AttachAtAimedPointState") + "\n\r"
			+ __SingleValWithComment(maintbl,"AttachDuration") + "\n\r";

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.Particles;
		local maintblref = tblref.Tables.Particles;

		local s = __SingleValWithComment(maintbl,"State",maintblref) + "\n\r"
			+ __SingleValWithComment(maintbl,"AttachAtAimedPointState",maintblref) + "\n\r"
			+ __SingleValWithComment(maintbl,"AttachDuration",maintblref) + "\n\r";

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.SurvivorSettings[setting] == "string") ? "\""+maintblref.SurvivorSettings[setting]+"\"": maintblref.SurvivorSettings[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}
::__StringifyExplosionsSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.Explosions;

		local s = "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.Explosions;
		local maintblref = tblref.Tables.Explosions.SurvivorSettings

		local s = "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref[setting] == "string") ? "\""+maintblref[setting]+"\"": maintblref[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}
::__StringifyModelPreferencesSettings <- function(tblref=null)
{
    if(tblref == null)
	{
	    return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.ModelPreferences,"State");
    }
	return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.ModelPreferences,"State",tblref.Tables.ModelPreferences);
}
::__StringifyApocalypseSettings <- function(tblref=null)
{
    if(tblref == null)
	{
	    return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.Apocalypse,"State");
    }
	return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.Apocalypse,"State",tblref.Tables.Apocalypse);
}
::__StringifyMeteorShowerSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.MeteorShower;
		
		local s = __SingleValWithComment(maintbl,"State") + "\n\r";

		s += "\t\t\tModels = " + maintbl.Models.Comment + "\n\r\t\t\t{\n\r"
		foreach(typ,modellist in maintbl.Models.Value)
		{
            s += "\t\t\t\t" + maintbl.Models.ValueComments[typ] + "\n\r"
			s += "\t\t\t\t" + typ 
			if(modellist.len() == 0)
				s += " = []\n\r"
			else
			{
                s += " = \n\r\t\t\t\t[\n\r"
				local len = modellist.len()
				for(local i=0;i<len;i++)
				{
					s += "\t\t\t\t\t\"" + modellist[i] + "\""
                    if(i != len-1)
                        s += ","
                    s += "\n\r"
				}
				s += "\t\t\t\t]\n\r"
			}
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.MeteorShower;
		local maintblref = tblref.Tables.MeteorShower
		
		local s = __SingleValWithComment(maintbl,"State",maintblref) + "\n\r";

		s += "\t\t\tModels = " + maintbl.Models.Comment + "\n\r\t\t\t{\n\r"
		foreach(typ,_v in maintbl.Models.Value)
		{
			local modellist = maintblref.Models[typ]
            s += "\t\t\t\t" + maintbl.Models.ValueComments[typ] + "\n\r"
			s += "\t\t\t\t" + typ
			if(modellist.len() == 0)
				s += " = []\n\r"
			else
			{
                s += " = \n\r\t\t\t\t[\n\r"
                local len = modellist.len()
				for(local i=0;i<len;i++)
				{
					s += "\t\t\t\t\t\"" + modellist[i] + "\""
                    if(i != len-1)
                        s += ","
                    s += "\n\r"
				}
				s += "\t\t\t\t]\n\r"
			}
		}
		s += "\t\t\t}\n\r"
        
		return s;
	}
}
::__StringifyTankRockSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.TankRock;

		local s = ""
		foreach(setting,val in maintbl.Value)
		{
			if(typeof val == "array")
			{
				s += "\t\t\t" + setting 
				if(val.len() == 0)
					s += " = []\n\r"
				else
				{
					s += " = \n\r\t\t\t\t[\n\r"
					local len = val.len()
					for(local i=0;i<len;i++)
					{
						s += "\t\t\t\t\t\"" + val[i] + "\""
						if(i != len-1)
							s += ","
						s += "\n\r"
					}
					s += "\t\t\t\t]\n\r"
				}
			}
			else
			{
				s += "\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.ValueComments[setting] + "\n\r"
			}
		}

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.TankRock;
		local maintblref = tblref.Tables.TankRock

		local s = ""
		foreach(setting,val in maintbl.Value)
		{	
			if(typeof maintblref[setting] == "array")
			{
				s += "\t\t\t" + setting 
				if(maintblref[setting].len() == 0)
					s += " = []\n\r"
				else
				{
					s += " = \n\r\t\t\t\t[\n\r"
					local len = maintblref[setting].len()
					for(local i=0;i<len;i++)
					{
						s += "\t\t\t\t\t\"" + maintblref[setting][i] + "\""
						if(i != len-1)
							s += ","
						s += "\n\r"
					}
					s += "\t\t\t\t]\n\r"
				}
			}
			else
			{
				s += "\t\t\t" + setting + " = " + ((typeof maintblref[setting] == "string") ? "\""+maintblref[setting]+"\"": maintblref[setting]) + "\t" + maintbl.ValueComments[setting] + "\n\r"
			}
			
		}

		return s;
	}
}

::__StringifyPropSpawnSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.PropSpawn;

		local s = __SingleValWithComment(maintbl,"Type") + "\n\r"

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(clsname,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + clsname + " = " + maintbl.SurvivorSettings.ValueComments[clsname] + "\n\r\t\t\t\t{\n\r"
			foreach(setting,valtbl in val.Value)
			{
				local prefix = setting == "spawn_height" ? "HEIGHT_" : "ANGLE_"
				s += "\t\t\t\t\t" + setting + " = " + valtbl.Comment 
					+ "\n\r\t\t\t\t\t{\n\r\t\t\t\t\t\tval = " + ((typeof valtbl.Value.val == "string") ? "\""+valtbl.Value.val+"\"": valtbl.Value.val) + "\t" + valtbl.ValueComments.val 
					+ "\n\r\t\t\t\t\t\tmin = " + valtbl.Value.min + "\t" + valtbl.ValueComments.min
					+ "\n\r\t\t\t\t\t\tmax = " + valtbl.Value.max + "\t" + valtbl.ValueComments.max
					+ "\n\r\t\t\t\t\t\t" + valtbl.ValueComments.flags + "\n\r\t\t\t\t\t\tflags = " + ::Constants.ConstStrLookUp(prefix,valtbl.Value.flags)
                    + "\n\r\t\t\t\t\t}\n\r"
			}
            s += "\t\t\t\t}\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.PropSpawn;
		local maintblref = tblref.Tables.PropSpawn;

		local s = __SingleValWithComment(maintbl,"Type",maintblref) + "\n\r"

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(clsname,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + clsname + " = " + maintbl.SurvivorSettings.ValueComments[clsname] + "\n\r\t\t\t\t{\n\r"
			foreach(setting,valtbl in val.Value)
			{
				local tref = maintblref.SurvivorSettings[clsname][setting]
				local prefix = setting == "spawn_height" ? "HEIGHT_" : "ANGLE_"
				s += "\t\t\t\t\t" + setting + " = " + valtbl.Comment 
					+ "\n\r\t\t\t\t\t{\n\r\t\t\t\t\t\tval = " + ((typeof tref.val == "string") ? "\""+tref.val+"\"": tref.val) + "\t" + valtbl.ValueComments.val 
					+ "\n\r\t\t\t\t\t\tmin = " + tref.min + "\t" + valtbl.ValueComments.min
					+ "\n\r\t\t\t\t\t\tmax = " + tref.max + "\t" + valtbl.ValueComments.max
					+ "\n\r\t\t\t\t\t\t" + valtbl.ValueComments.flags + "\n\r\t\t\t\t\t\tflags = " + ::Constants.ConstStrLookUp(prefix,tref.flags)
                    + "\n\r\t\t\t\t\t}\n\r"
			}
            s += "\t\t\t\t}\n\r"
		}
		s += "\t\t\t}\n\r"

		return s;
	}
}

::Constants.ConstStrLookUp <- function(prefix,val)
{
	local plen = prefix.len()
	local res = ""

	if(val == null)
	{
		foreach(key,c in getconsttable())
		{
			if(key.len() <= plen)
				continue;
			if(key.slice(0,plen) == prefix)
			{
				if(res.len() > 0)
					res += "|"
				res += key
			}
		}
	}
	else
	{
		foreach(key,c in getconsttable())
		{
			if(key.len() <= plen)
				continue;
			
			if(key.slice(0,plen) == prefix && ((val & c) != 0))
			{
				if(res.len() > 0)
					res += "|"
				res += key
			}
		}
	}
	return res
}

::Constants.GetFullDefaultTable <- function(tbl=null,defsavetofile=false,propsavetofile=false,skippropdef=false)
{
	local s = Constants.DefaultsDetailed.FormattingIntro + "\n\r{\n\r"
    s +=
		Constants.DefaultsDetailed.Basics.Title +"\n\r\t"
		+ "Basics =\n\r\t{\n\r"
		+ __StringifyBasicSettings(tbl) 
		+ "\n\r\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Title +"\n\r\t"
		+ "Tables =\n\r\t{\n\r"

		+ Constants.DefaultsDetailed.Tables.Outputs.Title + "\n\r\t\t"
		+ "Outputs =\n\r\t\t{\n\r"
		+ __StringifyOutputSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.GrabYeet.Title + "\n\r\t\t"
		+ "GrabYeet =\n\r\t\t{\n\r"
		+ __StringifyGrabYeetSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Hats.Title + "\n\r\t\t"
		+ "Hats =\n\r\t\t{\n\r"
		+ __StringifyHatsSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.LineSaving.Title + "\n\r\t\t"
		+ "LineSaving =\n\r\t\t{\n\r"
		+ __StringifyLineSavingSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Particles.Title + "\n\r\t\t"
		+ "Particles =\n\r\t\t{\n\r"
		+ __StringifyParticlesSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Explosions.Title + "\n\r\t\t"
		+ "Explosions =\n\r\t\t{\n\r"
		+ __StringifyExplosionsSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.ModelPreferences.Title + "\n\r\t\t"
		+ "ModelPreferences =\n\r\t\t{\n\r"
		+ __StringifyModelPreferencesSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Apocalypse.Title + "\n\r\t\t"
		+ "Apocalypse =\n\r\t\t{\n\r"
		+ __StringifyApocalypseSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.MeteorShower.Title + "\n\r\t\t"
		+ "MeteorShower =\n\r\t\t{\n\r"
		+ __StringifyMeteorShowerSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.TankRock.Title + "\n\r\t\t"
		+ "TankRock =\n\r\t\t{\n\r"
		+ __StringifyTankRockSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ "\t}\n\r}";

	local ps = ""
	local props = ""

	if(!skippropdef)
	{
		ps = Constants.DefaultsDetailed.FormattingIntro + "\n\r{\n\r"
			+ Constants.DefaultsDetailed.Tables.Title +"\n\r\t"
			+ "Tables =\n\r\t{\n\r"
			+ Constants.DefaultsDetailed.Tables.PropSpawn.Title + "\n\r\t\t"
			+ "PropSpawn =\n\r\t\t{\n\r"
			+ __StringifyPropSpawnSettings(tbl)
			+ "\n\r\t\t}\n\r"
			+ "\t}\n\r}";

		props = compilestring("local t="+ps+";return t;")();
		
		if(propsavetofile)
		{
			StringToFile(::Constants.Directories.CustomizedPropSpawnDefaults, ps);
		}
	}

    local tbl = compilestring("local t="+s+";return t;")();

    if(defsavetofile)
    {
        StringToFile(::Constants.Directories.CustomizedDefaults, s);
    }

	if(!skippropdef)
	{
		tbl.Tables.PropSpawn <- props.Tables.PropSpawn;
	}
	return tbl;
}

// TO-DO : Report what changes were made
::Constants.ValidateDefaultsTable <- function(tbl)
{
	function ValidateTbl(tbl,key,typ="table")
	{
		if(!(key in tbl) || tbl[key] == null)
			return false;

		if(typ == false)
			return true;

		if(typ.find("|") != null)
		{
			local typs = split(typ,"|");
			local keytyp = typeof tbl[key]
			local state = false
			foreach(i,t in typs)
			{
				state = (state || (keytyp == t));
			}
			return state;
		}

		return (typeof tbl[key]) == typ;
	}

	function ValidateSimilarTyp(tbl,org,key,arrtyp="string")
	{
		local given = typeof tbl[key]
		local typ = typeof org[key]
		switch(typ)
		{
			case "integer":
			case "float":
			{
				return (given == "integer") || (given == "float")
			}
			case "array":
			{	
				if(given != "array")
				{
					return false;
				}
				local cleanarr = []
				local len = tbl[key].len();
				for(local i=0;i<len;i++)
				{	
					if(typeof tbl[key][i] != arrtyp)	// Remove wrong types in array
					{
						continue; 
					}
					cleanarr.append(tbl[key][i]);
				}
				local res = cleanarr.len() == tbl[key].len();
				tbl[key] <- cleanarr;
				return res;
			}
			default:
			{
				return given == typ
			}
		}
	}

	local fixapplied = [];

	local correcttbl = ::Constants.GetFullDefaultTable(null,false,false,true)
	
	// Basics
	if(!ValidateTbl(tbl,"Basics"))
	{
		fixapplied.append("Re-create all default Basics")
		tbl.Basics <- correcttbl.Basics
	}
	else
	{
		foreach(setting,val in correcttbl.Basics)
		{
			if(!ValidateTbl(tbl.Basics,setting,"bool"))
			{
				fixapplied.append("Use default Basics."+setting)
				tbl.Basics[setting] <- correcttbl.Basics[setting]
			}
		}
	}

	// Tables
	if(!ValidateTbl(tbl,"Tables"))
	{
		fixapplied.append("Re-create all default Tables")
		tbl.Tables <- correcttbl.Tables
	}
	else
	{
		// Outputs
		if(!ValidateTbl(tbl.Tables,"Outputs"))
		{
			fixapplied.append("Re-create default Tables.Outputs")
			tbl.Tables.Outputs <- correcttbl.Tables.Outputs
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.Outputs,"State","bool"))
			{
				fixapplied.append("Tables.Outputs.State")
				tbl.Tables.Outputs.State <- correcttbl.Tables.Outputs.State
			}
		}

		// Grab-yeet
		if(!ValidateTbl(tbl.Tables,"GrabYeet"))
		{
			fixapplied.append("Re-create default Tables.GrabYeet")
			tbl.Tables.GrabYeet <- correcttbl.Tables.GrabYeet
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.GrabYeet,"GrabRadiusTolerance","integer|float"))
			{
				fixapplied.append("Re-create default Tables.GrabYeet.GrabRadiusTolerance")
				tbl.Tables.GrabYeet.GrabRadiusTolerance <- correcttbl.Tables.GrabYeet.GrabRadiusTolerance
			}

			if(!ValidateTbl(tbl.Tables.GrabYeet,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.GrabYeet.SurvivorSettings")
				tbl.Tables.GrabYeet.SurvivorSettings <- correcttbl.Tables.GrabYeet.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.GrabYeet.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.GrabYeet.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.GrabYeet.SurvivorSettings,correcttbl.Tables.GrabYeet.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.GrabYeet.SurvivorSettings."+setting)
						tbl.Tables.GrabYeet.SurvivorSettings[setting] <- correcttbl.Tables.GrabYeet.SurvivorSettings[setting]
					}
				}
			}

			if(!ValidateTbl(tbl.Tables.GrabYeet,"ValidGrabClasses"))
			{
				fixapplied.append("Re-create default Tables.GrabYeet.ValidGrabClasses")
				tbl.Tables.GrabYeet.ValidGrabClasses <- correcttbl.Tables.GrabYeet.ValidGrabClasses
			}
		}

		// Hats
		if(!ValidateTbl(tbl.Tables,"Hats"))
		{
			fixapplied.append("Re-create default Tables.Hats")
			tbl.Tables.Hats <- correcttbl.Tables.Hats
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.Hats,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.Hats.SurvivorSettings")
				tbl.Tables.Hats.SurvivorSettings <- correcttbl.Tables.Hats.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.Hats.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.Hats.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.Hats.SurvivorSettings,correcttbl.Tables.Hats.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.Hats.SurvivorSettings."+setting)
						tbl.Tables.Hats.SurvivorSettings[setting] <- correcttbl.Tables.Hats.SurvivorSettings[setting]
					}
				}
			}
		}
		
		// Line saving
		if(!ValidateTbl(tbl.Tables,"LineSaving"))
		{
			fixapplied.append("Re-create default Tables.LineSaving")
			tbl.Tables.LineSaving <- correcttbl.Tables.LineSaving
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.LineSaving,"State","bool"))
			{
				fixapplied.append("Re-create default Tables.LineSaving.State")
				tbl.Tables.LineSaving.State <- correcttbl.Tables.LineSaving.State
			}

			if(!ValidateTbl(tbl.Tables.LineSaving,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.LineSaving.SurvivorSettings")
				tbl.Tables.LineSaving.SurvivorSettings <- correcttbl.Tables.LineSaving.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.LineSaving.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.LineSaving.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.LineSaving.SurvivorSettings,correcttbl.Tables.LineSaving.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.LineSaving.SurvivorSettings."+setting)
						tbl.Tables.LineSaving.SurvivorSettings[setting] <- correcttbl.Tables.LineSaving.SurvivorSettings[setting]
					}
				}
			}
		}

		// Particles
		if(!ValidateTbl(tbl.Tables,"Particles"))
		{
			fixapplied.append("Re-create default Tables.Particles")
			tbl.Tables.Particles <- correcttbl.Tables.Particles
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.Particles,"State","bool"))
			{
				fixapplied.append("Re-create default Tables.Particles.State")
				tbl.Tables.Particles.State <- correcttbl.Tables.Particles.State
			}

			if(!ValidateTbl(tbl.Tables.Particles,"AttachAtAimedPointState","bool"))
			{
				fixapplied.append("Re-create default Tables.Particles.AttachAtAimedPointState")
				tbl.Tables.Particles.AttachAtAimedPointState <- correcttbl.Tables.Particles.AttachAtAimedPointState
			}
			
			if(!ValidateTbl(tbl.Tables.Particles,"AttachDuration","integer|float"))
			{
				fixapplied.append("Re-create default Tables.Particles.AttachDuration")
				tbl.Tables.Particles.AttachDuration <- correcttbl.Tables.Particles.AttachDuration
			}

			if(!ValidateTbl(tbl.Tables.Particles,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.Particles.SurvivorSettings")
				tbl.Tables.Particles.SurvivorSettings <- correcttbl.Tables.Particles.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.Particles.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.Particles.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.Particles.SurvivorSettings,correcttbl.Tables.Particles.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.Particles.SurvivorSettings."+setting)
						tbl.Tables.Particles.SurvivorSettings[setting] <- correcttbl.Tables.Particles.SurvivorSettings[setting]
					}
				}
			}
		}

		// Explosions
		if(!ValidateTbl(tbl.Tables,"Explosions"))
		{
			fixapplied.append("Re-create default Tables.Explosions")
			tbl.Tables.Explosions <- correcttbl.Tables.Explosions
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.Explosions,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.Explosions.SurvivorSettings")
				tbl.Tables.Explosions.SurvivorSettings <- correcttbl.Tables.Explosions.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.Explosions.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.Explosions.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.Explosions.SurvivorSettings,correcttbl.Tables.Explosions.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.Explosions.SurvivorSettings."+setting)
						tbl.Tables.Explosions.SurvivorSettings[setting] <- correcttbl.Tables.Explosions.SurvivorSettings[setting]
					}
				}
			}
		}

		// Model Preferences
		if(!ValidateTbl(tbl.Tables,"ModelPreferences"))
		{
			fixapplied.append("Re-create default Tables.ModelPreferences")
			tbl.Tables.ModelPreferences <- correcttbl.Tables.ModelPreferences
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.ModelPreferences,"State","bool"))
			{
				fixapplied.append("Re-create default Tables.ModelPreferences.State")
				tbl.Tables.ModelPreferences.State <- correcttbl.Tables.ModelPreferences.State
			}
		}

		// Apocalypse
		if(!ValidateTbl(tbl.Tables,"Apocalypse"))
		{
			fixapplied.append("Re-create default Tables.Apocalypse")
			tbl.Tables.Apocalypse <- correcttbl.Tables.Apocalypse
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.Apocalypse,"State","integer|float"))
			{
				fixapplied.append("Re-create default Tables.Apocalypse.State")
				tbl.Tables.Apocalypse.State <- correcttbl.Tables.Apocalypse.State
			}
		}

		// Meteor shower
		if(!ValidateTbl(tbl.Tables,"MeteorShower"))
		{
			fixapplied.append("Re-create default Tables.MeteorShower")
			tbl.Tables.MeteorShower <- correcttbl.Tables.MeteorShower
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.MeteorShower,"State","integer|float"))
			{
				fixapplied.append("Re-create default Tables.MeteorShower.State")
				tbl.Tables.MeteorShower.State <- correcttbl.Tables.MeteorShower.State
			}

			if(!ValidateTbl(tbl.Tables.MeteorShower,"Models"))
			{
				fixapplied.append("Re-create default Tables.MeteorShower.Models")
				tbl.Tables.MeteorShower.Models <- correcttbl.Tables.MeteorShower.Models
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.MeteorShower.Models)
				{
					if(!ValidateTbl(tbl.Tables.MeteorShower.Models,setting,"array"))
					{
						fixapplied.append("Re-create default Tables.MeteorShower.Models."+setting)
						tbl.Tables.MeteorShower.Models[setting] <- correcttbl.Tables.MeteorShower.Models[setting]
					}
					else
					{
						local validmodels = []
						foreach(i,mdl in tbl.Tables.MeteorShower.Models[setting])
						{
							if(typeof mdl != "string")
							{
								fixapplied.append("Tables.MeteorShower.Models."+setting+"["+i+"] invalid model-> "+mdl)
							}
							else
							{
								validmodels.append(mdl)
							}
						}

						tbl.Tables.MeteorShower.Models[setting] <- validmodels;
					}
				}
			}
		}

		// Tank rocks
		if(!ValidateTbl(tbl.Tables,"TankRock"))
		{
			fixapplied.append("Re-create default Tables.TankRock")
			tbl.Tables.TankRock <- correcttbl.Tables.TankRock
		}
		else
		{
			foreach(setting,val in correcttbl.Tables.TankRock)
			{
				if(!ValidateTbl(tbl.Tables.TankRock,setting,false) 
				|| !ValidateSimilarTyp(tbl.Tables.TankRock,correcttbl.Tables.TankRock,setting))
				{
					fixapplied.append("Use default Tables.TankRock."+setting)
					tbl.Tables.TankRock[setting] <- correcttbl.Tables.TankRock[setting]
				}
			}
		}
	}

	// Remove old PropSpawn table
	if(ValidateTbl(tbl.Tables,"PropSpawn"))
	{
		fixapplied.append("Remove old Tables.PropSpawn")
		delete tbl.Tables.PropSpawn
	}

	if(fixapplied.len() != 0)
	{
		tbl = ::Constants.GetFullDefaultTable(tbl,true,false,true)
	}


	if(fixapplied.len() != 0)
	{
		printl("---------------------------------------------------------")
		printl("[Default-Fix-List] Defaults table fixed following values:")
		foreach(i,fix in fixapplied)
		{
			printl("\t[*] "+fix)
		}
		printl("---------------------------------------------------------")
	}

	::Constants.Defaults <- tbl;

	return fixapplied.len() == 0;
}
::Constants.ValidatePropDefaultsTable <- function(tbl)
{
	function ValidateTbl(tbl,key,typ="table")
	{
		if(!(key in tbl) || tbl[key] == null)
			return false;

		if(typ == false)
			return true;

		if(typ.find("|") != null)
		{
			local typs = split(typ,"|");
			local keytyp = typeof tbl[key]
			local state = false
			foreach(i,t in typs)
			{
				state = (state || (keytyp == t));
			}
			return state;
		}

		return (typeof tbl[key]) == typ;
	}

	function ValidateSimilarTyp(tbl,org,key)
	{
		local given = typeof tbl[key]
		local typ = typeof org[key]
		switch(typ)
		{
			case "integer":
			case "float":
			{
				return (given == "integer") || (given == "float")
			}
			default:
			{
				return given == typ
			}
		}
	}

	local correcttbl = ::Constants.GetFullDefaultTable().Tables.PropSpawn
	local fixapplied = []

	// Tables
	if(!ValidateTbl(tbl,"Tables"))
	{
		fixapplied.append("Re-create all default Tables")
		tbl.Tables <- {}
		tbl.Tables.PropSpawn <- correcttbl
	}
	else
	{
		if(!ValidateTbl(tbl.Tables,"PropSpawn"))
		{
			fixapplied.append("Re-create default Tables.PropSpawn")
			tbl.Tables.PropSpawn <- correcttbl
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.PropSpawn,"Type","string"))
			{
				fixapplied.append("Re-create default Tables.PropSpawn.Type")
				tbl.Tables.PropSpawn.Type <- correcttbl.Type
			}

			if(!ValidateTbl(tbl.Tables.PropSpawn,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.PropSpawn.SurvivorSettings")
				tbl.Tables.PropSpawn.SurvivorSettings <- correcttbl.SurvivorSettings
			}
			else
			{
				foreach(clsname,settings in correcttbl.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.PropSpawn.SurvivorSettings,clsname))
					{
						fixapplied.append("Re-create default Tables.PropSpawn.SurvivorSettings."+clsname)
						tbl.Tables.PropSpawn.SurvivorSettings[clsname] <- correcttbl.SurvivorSettings[clsname]
					}
					else
					{
						foreach(setting,valtbl in settings)
						{
							if(!ValidateTbl(tbl.Tables.PropSpawn.SurvivorSettings[clsname],setting))
							{
								fixapplied.append("Re-create default Tables.PropSpawn.SurvivorSettings."+clsname+"."+setting)
								tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting] <- correcttbl.SurvivorSettings[clsname][setting]
							}
							else
							{
								foreach(s,v in valtbl)
								{
									if(s == "min" || s == "max")
									{
										if(!ValidateTbl(tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting],s,"integer|float"))
										{
											fixapplied.append("Use default Tables.PropSpawn.SurvivorSettings."+clsname+"."+setting+"."+s)
											tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting][s] <- correcttbl.SurvivorSettings[clsname][setting][s]
										}
									}
									else
									{
										if(!ValidateTbl(tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting],s,false)
											|| !ValidateSimilarTyp(tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting],correcttbl.SurvivorSettings[clsname][setting],s))
										{
											fixapplied.append("Use default Tables.PropSpawn.SurvivorSettings."+clsname+"."+setting+"."+s)
											tbl.Tables.PropSpawn.SurvivorSettings[clsname][setting][s] <- correcttbl.SurvivorSettings[clsname][setting][s]
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if(fixapplied.len() != 0)
	{
		tbl = ::Constants.GetFullDefaultTable(tbl,false,true)
	}

	if(fixapplied.len() != 0)
	{
		printl("---------------------------------------------------------")
		printl("[Default-PropSpawn-Fix-List] PropSpawn table fixed following values:")
		foreach(i,fix in fixapplied)
		{
			printl("\t[*] "+fix)
		}
		printl("---------------------------------------------------------")
	}

	::Constants.Defaults.Tables.PropSpawn <- tbl.Tables.PropSpawn;

	return fixapplied.len() == 0;
}

::Constants.ReadDefaultsFile <- function()
{
    local defs = FileToString(::Constants.Directories.CustomizedDefaults);
    local propdefs = FileToString(::Constants.Directories.CustomizedPropSpawnDefaults);
    local df = {};
	local props = {}
    if(defs == null || propdefs == null)
    {  
		if(defs == null)
		{
			printl("[Defaults] Creating defaults.txt for the first time...");
		}
		else
		{
			printl("[Defaults] Creating prop_defaults.txt for the first time...");
		}

        ::Constants.GetFullDefaultTable(null,defs==null,propdefs==null)

        defs = FileToString(::Constants.Directories.CustomizedDefaults);
        df = compilestring("local t="+defs+";return t;")();

    	propdefs = FileToString(::Constants.Directories.CustomizedPropSpawnDefaults);
		props = compilestring("local t="+propdefs+";return t;")();
		
		df.Tables.PropSpawn <- props.Tables.PropSpawn;

		::Constants.Defaults <- df;
    }
    else
    {
		df = null
		props = null
		local err = ""
		local perr = ""
		try
		{
        	df = compilestring("local t="+defs+";return t;")();
		}
		catch(e)
		{
			// Keep old bad formatted one just in case
			StringToFile(::Constants.Directories.CustomizedDefaultsBadFormat, defs)
			df = null
			err = e
		}

		try
		{
			props = compilestring("local t="+propdefs+";return t;")();
		}
		catch(e2)
		{
			// Keep old bad formatted one just in case
			StringToFile(::Constants.Directories.CustomizedPropSpawnDefaultsBadFormat, propdefs)
			props = null
			perr = e2
		}

		if(df == null || typeof df != "table")
		{
			printl("[Defaults-Error] File defaults.txt is formatted completely wrong, recreating the file...")
			printl("\t[Warning] Keeping incorrectly formatted file named in "+::Constants.Directories.CustomizedDefaultsBadFormat)
			if(err != "")
				printl("\t\t[Error] "+err)

			::Constants.Defaults <- ::Constants.GetFullDefaultTable(null,true);
		}
        else if(!::Constants.ValidateDefaultsTable(df))
        {
			printl("[Defaults-Fix] File defaults.txt had missing or incorrect values, fixed the errors");
        }
		else
		{
			printl("[Defaults] Applying default settings...")
		}
			
		if(props == null || typeof props != "table")
		{
			printl("[Defaults-Error] File prop_defaults.txt is formatted completely wrong, recreating the file...")
			printl("\t[Warning] Keeping incorrectly formatted file named in "+::Constants.Directories.CustomizedPropSpawnDefaultsBadFormat)
			if(perr != "")
				printl("\t\t[Error] "+perr)
			
			::Constants.Defaults.Tables.PropSpawn <- ::Constants.GetFullDefaultTable(null,false,true).Tables.PropSpawn;
		}
        else if(!::Constants.ValidatePropDefaultsTable(props))
        {
			printl("[Defaults-Fix] File prop_defaults.txt had missing or incorrect values, fixed the errors");
        }
		else
		{
			printl("[Defaults] Applying default prop spawn settings...")
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

::Constants.ReadDefaultsFile();

if(!("Defaults" in ::Constants))
{
    printl("[Defaults-Error] FAILED TO READ DEFAULTS.TXT, USING BACK-UP TABLE. CONSIDER CHECKING THE FORMAT OR REMOVING THE FILE");
    
	::Constants.Defaults <- ::Constants.GetFullDefaultTable();

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