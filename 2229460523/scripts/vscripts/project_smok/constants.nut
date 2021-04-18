/*********************\
*  BUILT-IN SETTINGS  *
\*********************/
::Constants <- 
{
	Version = 
	{
		Number = "v1.5.0"
		Date = "18.04.2021"
		Source = "https://github.com/semihM/project_smok"
	}

	AliasExampleVersions =
	{
		"v1.1.0" : 1
	}

	EntityGroupsExampleVersions =
	{

	}
}

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
	
    /// Ghost zombies custom settings
    GhostZombiesSettings = "admin system/ghost_zombies_settings.txt"

    /// Custom sequences json object
    CustomResponses = "admin system/custom_responses.json"

    /// Customized default settings
    CustomizedDefaults = "admin system/defaults.txt"
	CustomizedPropSpawnDefaults = "admin system/prop_defaults.txt"

    CustomizedDefaultsBadFormat= "admin system/defaults_bad_format.txt"
    CustomizedPropSpawnDefaultsBadFormat= "admin system/prop_defaults_bad_format.txt"

    /// Bot sharing/looting settings
    BotSettings = "admin system/botparams.txt"

    /// Command restrictions
    CommandRestrictions = "admin system/command_limits.txt"
    CommandRestrictionsBadFormat = "admin system/command_limits_bad_format.txt"
	
    DisabledCommands = "admin system/disabled_commands.txt"

	/// Command aliasing
	CommandAliases = "admin system/aliases/file_list.txt"
	CommandAliasesExample = "admin system/aliases/example_alias_file.txt"
	CommandAliasesExampleVersionBased = @(v) "admin system/aliases/example_alias_file_"+v+".txt"
	
	/// Custom commands
	CommandScripts = "admin system/scripts/file_list.txt"
	CommandScriptsExample = "admin system/scripts/example_command_file.nut"

	/// Custom hooks
	CustomHooks = "admin system/hooks/file_list.txt"
	CustomHooksExample = "admin system/hooks/example_hook_file.nut"

	/// Special props
	CustomProps = "admin system/entitygroups/file_list.txt"
	CustomPropsExample = "admin system/entitygroups/example_entity_file.nut"
	CustomPropsExampleVersionBased = @(v) "admin system/entitygroups/example_entity_file_"+v+".nut"

	/// Loot tables
	LootTables = "admin system/loot_tables.txt"

	/// Custom binds
	CustomBinds = "admin system/binds/file_list.txt"
	CustomBindsExample = "admin system/binds/example_bind_file.nut"
	//CustomBindsExampleVersionBased = @(v) "admin system/binds/example_bind_file_"+v+".nut"
}

/**************************\
* ENTITY NAMES USED BY CMDS *
\**************************/
::Constants.Targetnames <-
{
	Ragdoll = "project_smok_ragdoll_"

	TankRock = "project_smok_tank_rock_"

	PhysConverter = "project_smok_phys_converter"

	SodaCan = "project_smok_soda_can_"
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

	GhostZombies = "GhostZombies_"

    MeteorShower = "MeteorShower_"

    BotThinkAdder = "BotThinkAdder_"

    BotShareAttemptSlot2 = "BotThinkShareAttemptSlot2_"

    BotShareAttemptSlot3 = "BotThinkShareAttemptSlot3_"

    BotSearchAttemptSlot2 = "BotThinkSearchAttemptSlot2_"
    
    BotSearchAttemptSlot3 = "BotThinkSearchAttemptSlot3_"

    CarPush = "CarPushSingle_"

	RagdollControl = "RagdollControl_"
}

/*************\
* TIMER DELAYS *
\*************/
::Constants.TimerDelays <-
{
    RoundStart =
	{
		Apocalypse = 7

		GhostZombies = 8

		MeteorShower = 9 

		BotShareLoot = 15
	}
}
::Constants.CustomHookExampleFunction_1 <- "::PS_Hooks.OnPlayerConnected.VeryCoolHook <- function(player,args)\n{\n\t// Tell a welcome message to a connected non-admin player\n\t// Check admin status, in this case make sure it's quiet=true so no other message will be displayed \n\tif(!AdminSystem.IsPrivileged(player,true))	\n\t\t::Messages.InformPlayer(player,\"Welcome! This is a modded server and the admins are very reasonable people :) Enjoy the madness!\") \n}"

::Constants.CustomHookExampleFunction_2 <- "::PS_Hooks.OnPlayerConnected.AnotherCoolHook <- function(player,args)\n{\n\t// Tell everyone a semi-colored message when an admin is connected\n\t// Check admin status, in this case make sure it's quiet=true so no other message will be displayed \n\tif(AdminSystem.IsPrivileged(player,true))\n\t\t::Messages.InformAll(COLOR_ORANGE + player.GetName() + COLOR_DEFAULT + \" is here to smok- some boomers!\");	\n}"

::Constants.CustomHookListDefaults <-
@"// This file contains the files names of the custom hooks to make sure they get read
// Add file names of the hook files below as shown (without // characters at the begining) to include them!

// Characters // indicate comments starting after them, which are ignored
// To include the ""example_hook_file.nut"" remove the // characters at the beginning of the line!
// !!!!!!!!!!!!!!
// IT IS NOT RECOMMENDED TO USE THE EXAMPLE FILE FOR NEW HOOKS 
// !!!!!!!!!!!!!!

//example_hook_file // This will make project_smok look for ""example_hook_file.nut"" and read it if it exists! Write any additional files below this line..."

::Constants.CustomHookDefaults <-
@"// All files in this directory will be read as strings and then get compiled, so be careful with the formatting!
// Follow this example's format for hooking new functions to game events
// Check out the game event names that can be used: 
//		1. In source code (these names should be used as a hook's base): https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut#L194
//		2. More detailed (these names can't be referred directly, but their representative names can be found in the link above ): https://wiki.alliedmods.net/Left_4_dead_2_events
//
// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the VSLib library, check out: https://l4d2scripters.github.io/vslib/docs/index.html
// !!!!!!!!!!!!!!
// MAKE SURE FILE SIZE IS LESS THAN 16.5 KB 
// !!!!!!!!!!!!!!
//
// All the global tables and methods can be accessed via these files, but it is NOT recommended to update them
// It is recommended to create 1 game event with multiple hooks per file
//
// Some useful global tables:
//      1. ::VSLib.Utils
//          o Basic common manipulation methods for all data types
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/utils.nut
//
//      2. ::VSLib.Timers
//          o Adding and managing timers for concurrent execution
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/timer.nut
//
//      3. ::VSLib.EasyLogic
//          o Easier handling of game events
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut
//
//      4. ::AdminSystem
//          o Managing player restrictions, storing session variables and reading/writing configuration files
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system.nut
//
//      5. ::Messages
//          o Message printing methods for printing to a player's or to everybody's chat(s) or console(s)
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/project_smok/messages.nut
//          o File in the link above includes most of the messages displayed by the addon, you can update them in these script files if you want, but be careful with formatting 
//
// Commonly used entity classes:
//      1. Ent
//          o Allows you to access to a game entity with given index, name or a similar reference. Same class as the game's script scope allows for entities, only has some basic methods
//          o Only used with script function of which the game presents
//          o https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/scriptedmode.nut#L467
//      2. Entity
//          o Has most of the Ent class's methods and hundreds more for easier use. Can be used as the main entity reference class.
//          o Used with all the VSLib methods and other custom classes, stores it's base class reference as an attribute named ""_ent""
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/entity.nut
//      3. Player
//          o Extends Entity class, has more methods which can used for a player entity
//          o Used with all the VSLib methods and other custom classes
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/player.nut
//
// Steps to create a new hook for a game event:
// 		1. Name the file however you like
// 		2. Include it's name in the ""file_list.txt"" to make the project_smok is aware of it's existance
//		3. Write the actual hook following the example format given in this file!
//
// Example for hooking a function called VeryCoolHook to OnPlayerConnected event, which is called when a player completes connecting process to the game and takes 2 arguments:
//		1. Create a file named ""my_hooks.nut""
//		2. Open up the ""file_list.txt"" and add ""my_hooks""
//		3. Write hooks following the format below"+ "\n"
+::Constants.CustomHookExampleFunction_1 + "\n"
+::Constants.CustomHookExampleFunction_2

::Constants.CustomScriptExampleFunction <- "::PS_Scripts.CommandName.Main <- function(player,args,text)\n{\n\t// Adding restrictions\n\t// -> Only allow admins (this is already checked in most cases, but better to check twice)\n\tif(!AdminSystem.IsPrivileged(player))\n\t\treturn;\n\t// -> Only allow admins with script authorizations\n\tif(!AdminSystem.HasScriptAuth(player))\n\t\treturn;\n\n\t// Accessing arguments easily\n\tlocal argument_1 = GetArgument(1)	// This is same as args[0], but it is fail-safe, returns null if no argument is passed\n\tlocal argument_2 = GetArgument(2)	// But GetArgument method uses a copy of arguments stored in ::VSLib.EasyLogic.LastArgs, which only gets updated when the command is called from chat/console\n\tlocal argument_3 = GetArgument(3)	// If you expect the command to be called within a compilestring function, make sure to check args in here too!\n\t// ...\n\n\t// Do null checks if you need\n\tif(argument_1 == null)\n\t\treturn;\n\tif(argument_2 == null)\n\t\targument_2 = \"default value for argument 2\";\n\n\t// Write the rest of the instructions however you like!\n\n\t// At the end, print out a message for the player(s) if needed, prints to wherever the given player has his output state set to\n\t::Printer(player,\"Put the message here!\")\n\n\t// Check out some example functions in the source code: https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system.nut \n}"

::Constants.CommandScriptListDefaults <-
@"// This file contains the files names of the custom commands to make sure they get read
// Add file names of the command files below as shown (without // characters at the begining) to include them!

// Characters // indicate comments starting after them, which are ignored
// To include the ""example_command_file.nut"" remove the // characters at the beginning of the line!
// !!!!!!!!!!!!!!
// IT IS NOT RECOMMENDED TO USE THE EXAMPLE FILES FOR NEW COMMANDS 
// !!!!!!!!!!!!!!

//example_command_file // This will make project_smok look for ""example_command_file.nut"" and read it if it exists! Write any additional files below this line..."

::Constants.CommandScriptDefaults <-
@"// All files in this directory will be read as strings and then get compiled, so be careful with the formatting!
// Follow this example's format for creating new commands and documentation for them

// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the VSLib library, check out: https://l4d2scripters.github.io/vslib/docs/index.html
// !!!!!!!!!!!!!!
// MAKE SURE FILE SIZE IS LESS THAN 16.5 KB 
// !!!!!!!!!!!!!!
//
// All the global tables and methods can be accessed via these files, but it is NOT recommended to update them
// It is recommended to create 1 new command per file
//
// Some useful global tables:
//      1. ::VSLib.Utils
//          o Basic common manipulation methods for all data types
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/utils.nut
//
//      2. ::VSLib.Timers
//          o Adding and managing timers for concurrent execution
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/timer.nut
//
//      3. ::VSLib.EasyLogic
//          o Easier handling of game events
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut
//
//      4. ::AdminSystem
//          o Managing player restrictions, storing session variables and reading/writing configuration files
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system.nut
//
//      5. ::Messages
//          o Message printing methods for printing to a player's or to everybody's chat(s) or console(s)
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/project_smok/messages.nut
//          o File in the link above includes most of the messages displayed by the addon, you can update them in these script files if you want, but be careful with formatting 
//
// Commonly used entity classes:
//      1. Ent
//          o Allows you to access to a game entity with given index, name or a similar reference. Same class as the game's script scope allows for entities, only has some basic methods
//          o Only used with script function of which the game presents
//          o https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/scriptedmode.nut#L467
//      2. Entity
//          o Has most of the Ent class's methods and hundreds more for easier use. Can be used as the main entity reference class.
//          o Used with all the VSLib methods and other custom classes, stores it's base class reference as an attribute named ""_ent""
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/entity.nut
//      3. Player
//          o Extends Entity class, has more methods which can used for a player entity
//          o Used with all the VSLib methods and other custom classes
//          o https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/admin_system/vslib/player.nut
//
// Steps to create a new command:
// 		1. Name the file however you like
// 		2. Include it's name in the ""file_list.txt"" to make the project_smok is aware of it's existance
//		3. Decide for a command name(in these steps MyCommand is used)
//		4. Prepare the command following the example format given in this file!
//			o Initialize the table: ::PS_Scripts.MyCommand <- {}
//			o Write documentation: ::PS_Scripts.MyCommand.Help <- {}
//			o Write the actual function: ::PS_Scripts.MyCommand.Main <- function(player,args,text){}
//		5. Command is ready to use via !MyCommand,/MyCommand,?MyCommand or scripted_user_func MyCommand
//
// ----BELOW HERE IS HOW THE SCRIPTS SHOULD BE CREATED----

// Commands should be created under PS_Scripts table

// -> Initialize a table using the name of your command
// -> If ""CommandName"" already exists, this will overwrite it!
::PS_Scripts.CommandName <- {}

// Create some documentation for your command
// -> This information can be accessed in-game using ?CommandName in chat 
::PS_Scripts.CommandName.Help <- 
{
    docs = ""Write an explanation for this command""
    param_1 = 
    {
        name = ""first parameter's name""
        docs = ""what is expected as an argument""
        when_null = ""what happens if no argument is passed""
    }
    // ... follow this format to create documents for xth parameter param_x and so on ... 
}

// Create the function you want called when the command is called named ""Main""
// This function will get 3 arguments passed to it:
//      1. Caller player as VSLib.Player object
//      2. Arguments in a table with integer keys and string/null values
//      3. Text used while calling this function as string if further manipulation needed" + "\n"
+ ::Constants.CustomScriptExampleFunction

::Constants.CommandAliasesListDefaults <-
@"// This file contains the files names of the alias tables to make sure they get read
// Add file names of the alias table files below as shown (without // characters at the begining) to include them!

// Characters // indicate comments starting after them, which are ignored
// To include the ""example_alias_file.txt"" remove the // characters at the beginning of the line!
// !!!!!!!!!!!!!!
// IT IS NOT RECOMMENDED TO USE THE EXAMPLE FILES FOR NEW ALIASES
// !!!!!!!!!!!!!!

//example_alias_file // This will make project_smok look for ""example_alias_file.txt"" and read it if it exists! Write any additional files below this line..."

::Constants.CommandAliasesDefaults <-
{
	v1_0_0 =
@"// This file contains aliases for the commands present in project_smok add-on
// For detailed documentation check out: https://github.com/semihM/project_smok#user-content-using-aliases
//
// Characters // indicate the start of a comment, which are ignored while reading the file
// Creating aliases lets players use commands in a way that isn't possible or ideal otherwise
// Aliases allow:
//	1. Calling multiple commands or other alliases with a single command
//	2. Using custom parameters and default values for all commands
//	3. Repeating and delaying
// !!!!! IT IS POSSIBLE TO CREATE INFINITE LOOPS BY REFERRING ALIASES TO EACH OTHER, BE CAREFUL !!!!!!
// Alias names CAN NOT:
//	1. Have special characters(except underscore _) or spaces in it
//	2. Start with a number 
// 	3. Be same as an existing command or alias
//	4. Be same as the example alias names (basic_alias_1, basic_alias_2, advanced_alias_1, advanced_alias_2)
// !!!!!!!
// >>> FILE SIZE SHOULD NOT EXCEED 16.5 KB, OR FILE WILL NOT BE READ
// !!!!!!!
// If the file size is bigger than 16.5 KB:
// 		1. Create a new file named however you like
//		2. Add the file name to ""file_list.txt"" to make sure project_smok knows it exists
// 		3. Follow the format present in this file, don't forget to write the { and } characters at the begining and the end
{	
	// BASIC
	//  o Create a table with the alias name you want, and include which commands are called with which values in this table
	//  o From chat:  !basic_alias_1 OR /basic_alias_1
	//  o From console:  scripted_user_func basic_alias_1
	//  o Result will be same as calling ""!command_name_1"" and ""!command_name_2 first_arg second_arg""
	basic_alias_1 =
	{
		Commands =
		{	
			// Call command_name_1 without arguments
			command_name_1 = {}
			// Call command_name_2 with given arguments, values should be given in quotes """"
			command_name_2 = 
			{
				arg_1 = ""first_arg""		// First argument
				arg_2 = ""second_arg""		// Seconds argument ...
				// ... follow the naming format arg_x for xth argument
			}
		}
	}
	//  o From chat:  !basic_alias_2 OR /basic_alias_2 
	//  o From console:  scripted_user_func basic_alias_2 
	//  o Result can't be replicated because there is a null argument
	basic_alias_2 =
	{
		// Write the commands or other alliases you want aliased in a table called Commands
		// Add as many commands as you'd like, commands can be delayed and repeated and all of their arguments can be parameterized

		Commands =
		{	
			// Call command_name_1 with given arguments, values HAVE TO BE given in quotes """" (unless they are null)
			// Creating aliases allows skipping (using nulls) arguments, but using this can result in the command not working as intended
			command_name_1 = 
			{
				arg_1 = ""first_arg""		// First argument
				arg_2 = ""second_arg""		// Seconds argument ...
				// ... follow the naming format arg_x for xth argument
				arg_4 = ""forth_arg""		// If argument is desired to be null, it can be skipped
			}
		}
	}
	// ADVANCED:
	//  o Aliases can have parameters and default values for their parameters
	//  o Commands can be delayed and repeated
	//  o Check out the table for explanations, some of the calls this table allows(in chat):
	//	->Use with default values (same as ""!command_name_1 400 default_value_1 25.0 #599 repeat_1"")
	// 		!advanced_alias_1
	//
	//	->Use different arguments (same as !command_name_1 400 my_value 25.0 #611 repeat_1 third_as_sixth)
	//		!advanced_alias_1 my_value 111 third_as_sixth
	advanced_alias_1 =
	{
		// Restrict the usage of this alias
		ScriptAuthOnly = false	// true: Player needs to have script authorization, false: All admins can use

		HostOnly = false	// true: Only host can use(overrides ScriptAuthOnly), false: All admins can use

		// Write any parameters you want the alias command to have under a table named Parameters
		// Arguments to these parameters are read from the chat/console when you call the advanced_alias_1 command
		// Default value should be given in quotes ""default_val"", unless it is null
		Parameters =
		{
			param_1 = ""default_value_1""	// If no argument is passed, ""default_value_1"" is used as param_1 value
			param_2 = ""99""			// Add as many parameters as you'd like following the naming format ""param_x"" for xth parameter
			param_3 = null			// Parameter with no default value
		}
		
		// Add information about this alias and it's parameters to keep it maintainable
		Help =
		{
			docs = ""Information about this alias""
			param_1 = ""Short information about the first parameter""
			param_2 = ""Short information about the second parameter""
			// ... follow the format: param_x = ""xth parameter information""
		}
		
		// Add the commands or other alliases in a table called Commands
		// Parameters can be referred with $param_x format for xth parameter
		// Expressions can be given in $[expression] format to be evaluated every command call
		// $[expression] and parameter references can be used with both options and arguments
		Commands =
		{
			command_name_1 =	// Create a table for the commands you add
			{	
				/// Options for calling the command
				// Time in seconds to delay the start of this commands call, have to be >= 0, gets evaluated once at start
				start_delay = 0		

				// Times to repeat this command every delay_between seconds; have to be >= 1, gets evaluated once at start
				// Repeat number of every call is named as repeat_id. This value incements by 1 after every call, can be referred with $repeat_id directly or within $[expression] blocks
				repeat = 1	

				// Waiting duration in seconds between repeats, have to be >= 0.1, gets re-evaluated after every call
				// This delay is generally inconsistant, 0.1 second delay may generally end up being a 0.2 second delay
				delay_between = 0.1	

				/// Arguments
				// Expressions given here gets re-evaluated every call
				arg_1 = ""400""		// If you don't want an argument to be referring to a parameter, just write the value you'd like it to have
				arg_2 = ""$param_1""	// Example parameter reference
				arg_3 = ""$[10 * 2.5]""	// Example expression which will always evaluate to 25.0
				arg_4 = ""$[\""#\"" + ($param_2 + 500)]""	// If you need to use quotes inside quotes, they have to be escaped (add \ before each one inside), this example will result in #599 when param_2 is 99
				arg_5 = ""$[\""repeat_\"" + $repeat_id]""	// This value will change every repeat: repeat_1, repeat_2, repeat_3 ...
				arg_6 = ""$param_3""	// If param_3 value was null, arg_6 will be null 

				/// Reference patterns summary
				/// 		Format		   |			Description
				// -----------------------------------------------------------------
				//		$param_x		xth parameter's value
				//	   	$repeat_id		current call number, increments by 1 after every call, don't use it with ""repeat""
				//		$repeats_left		amount of repeats left, don't use it with ""repeat""
				//		$last_call_time		Time() value stored from last call, can be used to check the accuracy of delay_between, don't use it with ""repeat""
				//		$[expression]		result of given expression evaluated, follows Squirrel-lang format but allows references given above
				//
				/// How References Are Replaced
				// 		o Consider expression: ""$[($repeat_id % 2) + $param_1]"" and param_1 given as 5, repeat given as 4
				//		o In each command call this expression will evaluate as following:
				//				$repeat_id  |  		  $param_1  |				  result
				// 			------------------------------------------------------------------------------
				//					 1			  5			  (1 % 2) + 5 = 6
				//					 2			  5			  (2 % 2) + 5 = 5
				//					 3			  5			  (3 % 2) + 5 = 6
				//					 4			  5			  (4 % 2) + 5 = 5
			}	
		}
	}
}"

	v1_1_0 = @"// Examples present in this file includes new features introduced in v1.1.0
// For detailed documentation check out: https://github.com/semihM/project_smok#user-content-using-aliases
//
// Characters // indicate the start of a comment, which are ignored while reading the file
// --------------------------------------------------
// New variables		|		Variable definition
// --------------------------------------------------
//		$caller_ent		command's caller as a VSLib.Player object
//		$caller_id		command caller's entity index as an integer
//		$caller_char		command caller's character name, first letter capitalized
//		$caller_name		command caller's in-game name
//		$caller_target		entity the command caller is aiming at as an VSLib.Entity object, uses an invalid entity if nothing is looked at 
// --------------------------------------------------
// Example: Print the result of param_1's method name given in param_2 called with param_3 arguments
// !advanced_alias_2  -> Print your angles 10 times checked every 0.5 seconds
// !advanced_alias_2 Player(2) IsPressingButton BUTTON_ATTACK  -> Print wheter player 2 is shooting 10 times checked every 0.5 seconds
{
	advanced_alias_2 =
	{
		Parameters =
		{
			param_1 = null		// Used as null argument
			param_2 = ""GetAngles""
			param_3 = """"		// Used as empty string argument
		}
		
		// More detailed docs for ?advanced_alias_2
		Help =
		{
			docs = ""Calls target_entity's (or caller's if null) method_name named method with cs_args string""
			// Parameter documentations can be detailed as follows:
			//	name = parameter name
			//	docs = parameter description
			//	when_null = what happens if no argument passed
			param_1 = 
			{
				name = ""target_entity""
				docs = ""Target entity in a compilable format, example(entity at index 69) -> Entity(69)""
				when_null = ""uses caller's entity""
			}
			param_2 = 
			{
				name = ""method_name""
				docs = ""Name of the method to call of target_entity""
				when_null = ""uses GetAngles method""
			}
			param_3 = 
			{
				name = ""cs_args""
				docs = ""Comma seperated arguments to use with method_name""
				when_null = ""uses empty string""
			}
		}
		
		Commands =
		{
			out =	// Use ""out"" command to print results
			{	
				// Check every half a second for 10 times 
				repeat = 10	
				delay_between = 0.5	

				// Check if target_entity got an argument passed to it, if not: use caller player via $caller_ent
				// Since ""out"" command evaluates the expression, it's given in quotes, therefore it won't be evaluated while the $variable values get replaced
				// A pseudo look to arg_1's expression
				// if $param_1 is not null then:
				//     do $param_1.$param_2($param_3)
				// else 
				//     do $caller_ent.$param_2($param_3)
				arg_1 = ""$[\""$param_1 ? $param_1.$param_2($param_3) : $caller_ent.$param_2($param_3)\""]""
			}	
		}
	}
}"
}

::Constants.CustomPropsListDefaults <-
@"// This file contains the files names of the entity group tables to make sure they get read
// Add file names of the entity group table files below as shown (without // characters at the begining) to include them!

// Characters // indicate comments starting after them, which are ignored
// To include the ""example_entity_file.nut"" remove the // characters at the beginning of the line!
// !!!!!!!!!!!!!!
// IT IS NOT RECOMMENDED TO USE THE EXAMPLE FILES FOR NEW SPECIAL PROPS
// !!!!!!!!!!!!!!

//example_entity_file // This will make project_smok look for ""example_entity_file.nut"" and read it if it exists! Write any additional files below this line..."+ "\n\r"

::Constants.CustomPropsDefaults <-
{
	v1_4_0 =
@"// This file contains entity group tables to be registered in the games
// Examples present in this file includes new features introduced in v1.4.0
//
// These entity groups are used with the ""prop"" command.
//		- Example(from chat): Spawn the ExampleGnome present in this file
//			!prop >ExampleGnome
//
// For more examples, download L4D2 Authoring Tools and check out the directory: ""Left 4 Dead 2\sdk_content\scripting\scripts\vscripts\entitygroups""
// If you wish to use those examples:
//		1. Remove the line with the ""RegisterEntityGroup"" function call, this call is done internally later.
//		2. Replace ""<-"" with ""="" after the entity group name	
//
// Characters // indicate the start of a comment, which are ignored while reading the file
// !!!!!!!
// >>> FILE SIZE SHOULD NOT EXCEED 16.5 KB, OR FILE WILL NOT BE READ
// !!!!!!!
// If the file size is bigger than 16.5 KB:
// 		1. Create a new file named however you like
//		2. Add the file name to ""file_list.txt"" to make sure project_smok knows it exists
//		3. Follow the example formats, don't forget to write the { and } characters at the begining and the end

// The name declared here will be used with the commands
ExampleGnome =
{
	//-------------------------------------------------------
	// Required Interface functions
	// - These following functions are REQUIRED to register an entity group
	//-------------------------------------------------------
	// - Add references of entities which has a model in this
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	// - Add references of entities here to spawn them 
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	// - Don't change this, although make sure it exists
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		// Entities to spawn
		SpawnTables =
		{
			// Name of the this entity's table, refer to this on the functions above
			// ""targetname"" is used to name the spawned entity
			gnome = 
			{
				// Key value pairs for this entity
				SpawnInfo =
				{
					classname = ""$classname""
					angles = Vector( 0, 180, 0 )
					glowcolor = ""56 150 58""
					glowrange = ""0""
					glowrangemin = ""0""
					glowstate = ""3""
					massScale = ""5""
					model = ""models/props_junk/gnome.mdl""
					spawnflags = ""0""
					targetname = ""$targetname""	// Keep the replacing parameter named same(especially for targetname)!
					origin = Vector( -6, 8, 11 )
				}
			}
		} // SpawnTables
		// Add a table named ReplaceParmDefaults to change values in key-value pairs
		// Use $[expression] format to evaluate expressions for every single spawn call
		//  - If $[expression] is used in an entity group, it will require SCRIPT AUTHORIZATION for players to use this entity group
		//	- With the $[expression] format, you can access to some external variables:
		//		1. To get the command caller player as VSLib.Player use ""player"" variable
		//		2. To get the table of arguments used with the command use ""GetArgument(idx)"" for idx'th argument
		ReplaceParmDefaults =
		{
			""$classname"" : ""prop_physics_multiplayer""
			// By default, any parameter name starting with ""$targetname"" is taken as a targetname while printing messages, so be reasonable while naming the parameters!
			""$targetname"" : ""$[\""gnome_spawned_by_\""+player.GetCharacterNameLower()]""	
		}
	} // EntityGroup
} // ExampleGnome
"
}

::Constants.ValidateAliasTableFromChat <- function(player,als,code,triggertbl)
{
	local tbl = null
	try
	{
		tbl = compilestring("local __tempvar__ ={"+strip(code)+"};return __tempvar__;")()
	}
	catch(e)
	{
		ClientPrint(player.GetBaseEntity(),3,"Table format was invalid, no alias created! Error: "+e)
		return null;
	}

	if(tbl == null || typeof tbl != "table")
	{
		ClientPrint(player.GetBaseEntity(),3,"Table format was invalid, no alias created!")
		return null;
	}
	else
	{	
		if(als in ::AliasCompiler.ForbiddenAliasNames)
			return null

		if((als in getroottable()[triggertbl] || als in ::AliasCompiler.Tables))
		{
			ClientPrint(player.GetBaseEntity(),3,COLOR_ORANGE+als+COLOR_DEFAULT+" is already a known alias. Use "+COLOR_OLIVE_GREEN+" !replace_alias"+COLOR_DEFAULT+" if you want to replace an existing alias!")
			return null
		}
		else
		{
			if("Commands" in tbl)
			{
				if(typeof tbl.Commands != "table")
				{
					ClientPrint(player.GetBaseEntity(),3,"Commands present in the table should be a table, formatted as: Commands = { \"command_name\" : {} }")
					tbl.Commands <- {}
				}
			}
			if("Parameters" in tbl)
			{
				if(typeof tbl.Parameters != "table")
				{
					ClientPrint(player.GetBaseEntity(),3,"Parameters present in the table should be a table, formatted as: Parameters = { \"param_x\" : \"default_value_x\" }")
					tbl.Parameters <- {}
				}
			}
			if("ScriptAuthOnly" in tbl)
			{
				if(typeof tbl.ScriptAuthOnly != "bool")
				{
					ClientPrint(player.GetBaseEntity(),3,"ScriptAuthOnly present in the table should be true or false, formatted as: ScriptAuthOnly = requires_script_auth")
					tbl.ScriptAuthOnly <- false
				}
			}
			if("HostOnly" in tbl)
			{
				if(typeof tbl.HostOnly != "bool")
				{
					ClientPrint(player.GetBaseEntity(),3,"HostOnly present in the table should be true or false, formatted as: HostOnly = host_only")
					tbl.HostOnly <- false
				}
			}
		}
			
		return tbl;
	}
}
::Constants.ValidateAliasTable <- function(fileContents,filename,first=false,reload=false,triggertbl="ChatTriggers")
{
	local news = {}
	local tbl = null
	try
	{
		tbl = compilestring("local __tempvar__="+strip(fileContents)+";return __tempvar__;")()
	}
	catch(e){printl("[Alias-Compile-Error] Failed to compile "+filename+". Error: "+e)}

	if(tbl == null || typeof tbl != "table")
	{
		local badformat = filename.slice(0,filename.find(".txt"))+"_bad_format.txt";
		printl("[Alias-Error] "+filename+" was formatted incorrectly, check {} and \"\" characters!")
		printl("[Alias-Error] Keeping incorrectly formatted file named as "+badformat+" and replacing it with the v1.0.0 examples...")

		StringToFile(badformat,fileContents);

		StringToFile(filename,Constants.CommandAliasesDefaults.v1_0_0);

		fileContents = FileToString(filename);
		return compilestring("local __tempvar__="+strip(fileContents)+";return __tempvar__;")()
	}
	else
	{	
		if(tbl.len() != 0)
		{	
			local deletes = []
			local issuesfound = false
			if(first)
				printl("[Alias-Checks] Doing alias table checks...")

			foreach(als,valtbl in tbl)
			{
				if(als in ::AliasCompiler.ForbiddenAliasNames)
					continue

				if((als in getroottable()[triggertbl]))
				{
					if(reload)
					{
						news[als] <- valtbl
					}
					else
					{
						printl("[Alias-Duplicate] "+als+" is already created! Consider removing the duplicate one.")
						deletes.append(als)
						issuesfound = true
						continue;
					}
				}
				else
				{
					news[als] <- valtbl
				}

				if("Commands" in valtbl)
				{
					if(typeof valtbl.Commands != "table")
					{
						printl("\t["+als+"-Error] Commands present in the table should be a table, formatted as: Commands = { \"command_name\" : {} }")
						tbl[als].Commands <- {}
						issuesfound = true
					}
				}
				if("Parameters" in valtbl)
				{
					if(typeof valtbl.Parameters != "table")
					{
						printl("\t["+als+"-Error] Parameters present in the table should be a table, formatted as: Parameters = { \"param_x\" : \"default_value_x\" }")
						tbl[als].Parameters <- {}
						issuesfound = true
					}
				}
				if("Help" in valtbl)
				{
					if(typeof valtbl.Help != "table")
					{
						printl("\t["+als+"-Error] Help present in the table should be a table, formatted as: Help = { \"docs\" : \"Short alias information\", \"param_x\" : \"Short parameter information\" }")
						tbl[als].Help <- {}
						issuesfound = true
					}
				}
				if("ScriptAuthOnly" in valtbl)
				{
					if(typeof valtbl.ScriptAuthOnly != "bool")
					{
						printl("\t["+als+"-Error] ScriptAuthOnly present in the table should be true or false, formatted as: ScriptAuthOnly = requires_script_auth")
						tbl[als].ScriptAuthOnly <- false
						issuesfound = true
					}
				}
				if("HostOnly" in valtbl)
				{
					if(typeof valtbl.HostOnly != "bool")
					{
						printl("\t["+als+"-Error] HostOnly present in the table should be true or false, formatted as: HostOnly = host_only")
						tbl[als].HostOnly <- false
						issuesfound = true
					}
				}
			}
			foreach(i,a in deletes)
			{
				delete tbl[a]
			}
			
			if(issuesfound)
				printl("[Alias-Checks] Applied fixes to current session, consider checking "+filename+" file to correct the mistakes.")
			else
				printl("[Alias-Checks] No issues found for "+filename)
			
			if(news.len() > 0)
			{	
				if(reload)
					printl("[Alias-Table] New aliases after reloading "+filename+" ("+news.len()+"):")
				else
					printl("[Alias-Table] Aliases loaded from "+filename+" ("+news.len()+"):")

				foreach(al,vl in news)
				{
					printl("\t[*] "+al)
				}
			}
			else 
			{
				if(reload)
					printl("[Alias-Table] No new valid aliases were loaded from "+filename)
				else
					printl("[Alias-Table] No valid aliases were loaded from "+filename)
			}

		}
		return tbl;
	}
}

::Constants.ValidateEntityGroupsTable <- function(fileContents,filename,first=false,reload=false)
{
	local news = {}
	local tbl = null
	try
	{
		tbl = compilestring("local __tempvar__=\n{"+strip(fileContents)+"\n}\n;return __tempvar__;")()
	}
	catch(e){printl("[Entity_Group-Compile-Error] Failed to compile "+filename+". Error: "+e)}

	if(tbl == null || typeof tbl != "table")
	{
		local badformat = filename.slice(0,filename.find(".nut"))+"_bad_format.nut";
		printl("[Entity_Group-Error] "+filename+" was formatted incorrectly, check {} and \"\" characters!")
		printl("[Entity_Group-Error] Keeping incorrectly formatted file named as "+badformat+" and replacing it with the v1.4.0 examples...")

		StringToFile(badformat,fileContents);

		StringToFile(filename,Constants.CustomPropsDefaults.v1_4_0);

		fileContents = FileToString(filename);
		return null
	}
	else
	{	
		if(tbl.len() != 0)
		{	
			local deletes = []
			if(first)
				printl("[Entity_Group-Checks] Doing entity group table checks...")

			foreach(EG_name,main_tbl in tbl)
			{
				if(!("GetPrecacheList" in main_tbl))
				{
					printl("[Entity_Group-Error] GetPrecacheList is missing in "+EG_name+" group... skipping")
					deletes.append(EG_name)
					continue;
				}
				if(!("GetSpawnList" in main_tbl))
				{
					printl("[Entity_Group-Error] GetSpawnList is missing in "+EG_name+" group... skipping")
					deletes.append(EG_name)
					continue;
				}
				if(!("GetEntityGroup" in main_tbl))
				{
					printl("[Entity_Group-Error] GetEntityGroup is missing in "+EG_name+" group... skipping")
					deletes.append(EG_name)
					continue;
				}
				if(!("EntityGroup" in main_tbl))
				{
					printl("[Entity_Group-Error] EntityGroup is missing in "+EG_name+" group... skipping")
					deletes.append(EG_name)
					continue;
				}
				else
				{
					if(!("SpawnTables" in main_tbl.EntityGroup))
					{
						printl("[Entity_Group-Error] EntityGroup.SpawnTables is missing in "+EG_name+" group... skipping")
						deletes.append(EG_name)
						continue;
					}
					
					if("ReplaceParmDefaults" in main_tbl.EntityGroup)
					{
						foreach(name,val in main_tbl.EntityGroup.ReplaceParmDefaults)
						{
							if((typeof val == "string") && (val.find("$[") == 0 && val.find("]") == (val.len()-1)))
							{
								news[EG_name] <- true
								break;
							}
						}
					}
					else
					{
						news[EG_name] <- false
					}

					g_MapScript.RegisterEntityGroup( EG_name, main_tbl )
					g_MapScript[EG_name] <- main_tbl

					if(g_MapScript.GetEntityGroup( EG_name ) == null)
					{
						printl("[Entity_Group-Error] Failed to register "+EG_name)
						deletes.append(EG_name)
						delete news[EG_name]
					}
				}
			}

			if(deletes.len() > 0)
			{
				foreach(i,name in deletes)
				{
					if(name in tbl)
						delete tbl[name]
				}
			}
			if(news.len() > 0)
			{	
				if(reload)
					printl("[Entity_Group-Table] New aliases after reloading "+filename+" ("+news.len()+"):")
				else
					printl("[Entity_Group-Table] Entity groups registered from "+filename+" ("+news.len()+"):")

				foreach(al,vl in news)
				{
					printl("\t[*] "+al)
				}
			}
			else 
			{
				if(reload)
					printl("[Entity_Group-Table] No new valid entity groups were loaded from "+filename)
				else
					printl("[Entity_Group-Table] No valid entity groups were registered from "+filename)
			}

		}

		return {groups=tbl,restrictions=news};
	}
}

::Constants.DisabledCommandsDefaults <-
@"// This file contains names of the commands you want disabled
// Characters // indicate the start of a comment, which are ignored while reading the file
// Examples given for disabling command_name_1 and command_name_2 commands

command_name_1 //Add names of the commands below these examples
command_name_2 //Take notes by adding // after the command name if needed"


::Constants.CommandRestrictionsDefault <- 
@"// This file contains restrictions to be applied to desired commands
// Characters // indicate the start of a comment, which are ignored while reading the file
// Follow the example ""command_name_1"" table's format to add new commands
{
	command_name_1 =
	{
		// SteamIDs of banned player for using ""command_name_1"" command
		// Doesn't need to be written if there's no bans needed
		// To ban everyone from using this command, place it into the ""disabled_commands.txt""
		BanList =
		{
				""STEAM_1:X:XXXXXX"" : true 	// Add player's SteamID to left hand side, right hand side value doesn't matter but needs to be legal. Check https://steamidfinder.com/ for SteamIDs
		}

		// SteamIDs of players who need to wait given time in seconds after using the command to use it again
		// Doesn't need to be written if there's no cooldowns needed
		CoolDown =	
		{
				""STEAM_1:X:XXXXXX"" : 3 	// Add player's SteamID to left hand side and waiting duration in second to right hand side.
		}
			
		// Cooldown time in seconds apply to everyone, if player's SteamID is in CoolDown table, this value is ignored for them
		// If not written, assumed to be 0 seconds
		CoolDownAll = 0
	}
}"

::Constants.CustomBindsListDefaults <-
@"// This file contains the files names of the key bind tables to make sure they get read
// Add file names of the key bind table files below as shown (without // characters at the begining) to include them!

// Characters // indicate comments starting after them, which are ignored
// To include the ""example_bind_file.nut"" remove the // characters at the beginning of the line!
// !!!!!!!!!!!!!!
// IT IS NOT RECOMMENDED TO USE THE EXAMPLE FILES FOR NEW BINDS
// !!!!!!!!!!!!!!

//example_bind_file // This will make project_smok look for ""example_bind_file.nut"" and read it if it exists! Write any additional files below this line..."

::Constants.CustomBindsTableDefaults <-
{
	v1_5_0 =
@"// This file contains commands and functions to bind to most used game keys
// Examples present in this file includes new features introduced in v1.5.0
// Keys are checked every ~33ms, meaning roughly every frame of a ~30fps game, the keys are checked if they are/were pressed.
// Available keys:
//		o MOVEMENT KEYS: 
//			+ FORWARD
//			+ BACK
//			+ LEFT
//			+ RIGHT
//			+ JUMP
//			+ DUCK
//			+ WALK
//		o COMBAT KEYS:
//			+ ATTACK
//			+ SHOVE
//			+ ZOOM
//			+ RELOAD
//		o MISCELLANEOUS KEYS:
//			+ USE
//			+ SCORE
//			+ ALT1
//			+ ALT2
// Characters // indicate the start of a comment, which are ignored while reading the file
// Binds are unique to STEAM IDs, so each admin can have their own binds
// Check out the examples below to see how it works
//
// Start by finding the admin's steam id, use admins.txt or check https://steamidfinder.com/ 
// You can use ""all"" instead of a steam ID to create the binds inside for all admins
""STEAM_1:X:XXXXXX"":
{
	// Use a key name given above (FORWARD, ATTACK, USE, etc.)
	""KEY_NAME_HERE"":
	{
		// Add ""!"" before the command names to bind them
		""!command_name"":
		{
			// Decide how its gonna be used with ""Usage"" key
			//		PS_WHEN_PRESSED = Calls once everytime this button gets pressed
			//		PS_WHEN_UNPRESSED = Calls once everytime this button gets unpressed; use this with caution
			//		PS_WHILE_PRESSED = Keeps calling while this button is pressed; SKIPS the first press input to let PS_WHEN_PRESSED work
			//		PS_WHILE_UNPRESSED = Keeps calling while this button is not pressed; SKIPS the first unpress input to let PS_WHEN_UNPRESSED work
			//		0 = Disables this bind (Constants above has values 1,2,4,8 respectively)
			Usage = PS_WHEN_PRESSED

			// Pass arguments with ""Arguments"" key
			Arguments =
			{
				arg_1 = ""argument_1""
				arg_2 = ""argument_2""  
				// Follow ""arg_X"" format for Xth argument
			}
		}

		// If you want to create a custom function, use its name directly
		""my_function_name"":
		{
			// Decide how its gonna be used with ""Usage"" key
			// 		o You can combine the usages with ""|"" operator
			Usage = PS_WHEN_PRESSED | PS_WHEN_UNPRESSED

			// Create the function which takes 2 parameters:
			//		1. player : Player's entity as VSLib.Player object
			//		2. press_info: A table containing:
			//			o usage_type : Use this value to differentiate the combined ""Usage"" values, compare it to each usage value you used to understand which call was fired
			//			o press_time : Time() value when this button was last pressed.
			//			o unpress_time : Time() value when this button was last unpressed.
			//			o press_count: How many times this button was pressed since this bind was bound, starts from 1, increments after releasing the key
			//			o press_length: How long last pressing duration was in seconds. Until first press-unpress, it will be 0
			Function = function(player, press_info)
			{
				local usage_type = press_info.usage_type
				local press_time = press_info.press_time
				local unpress_time = press_info.unpress_time
				local count = press_info.press_count
				local duration = press_info.press_length

				// If you have combined ""Usage"" values, use something similar to expression below
				switch(usage_type)
				{
					case PS_WHEN_PRESSED:
						// Write instructions for ""pressing"" event
						break;
					case PS_WHEN_UNPRESSED:
						// Write instructions for ""unpressing"" event
						break;
				}

				// If you don't have combined usage values, just write the rest of the instructions here
			}
		}
	}
}"
}

::Constants.ValidateBindsTable <- function(fileContents,filename,first=false,reload=false)
{
	local news = {}
	local tbl = null
	try
	{
		tbl = compilestring("local __tempvar__=\n{"+strip(fileContents)+"\n}\n;return __tempvar__;")()
	}
	catch(e){printl("[Binds-Compile-Error] Failed to compile "+filename+". Error: "+e)}

	if(tbl == null || typeof tbl != "table")
	{
		local badformat = filename.slice(0,filename.find(".nut"))+"_bad_format.nut";
		printl("[Binds-Error] "+filename+" was formatted incorrectly, check {} and \"\" characters!")
		printl("[Binds-Error] Keeping incorrectly formatted file named as "+badformat+" and replacing it with the v1.5.0 examples...")

		StringToFile(badformat,fileContents);

		StringToFile(filename,Constants.CustomBindsTableDefaults.v1_5_0);

		fileContents = FileToString(filename);
		return null
	}
	else
	{	
		if(tbl.len() != 0)
		{	
			if(first)
				printl("[Binds-Checks] Doing bind table checks...")

			foreach(steamID,keystbl in Utils.TableCopy(tbl))
			{
				news[steamID] <- {}
				foreach(keyname,binds in keystbl)
				{
					local keyval = 0
					local valid = true
					if(keyname.find("|") != null)
					{
						foreach(i,key in split(keyname,"|"))
						{
							if(!("BUTTON_"+key in getconsttable()))
							{
								printl("[Binds-Key-Error] Key name "+key+" is unknown... skipping")
								valid = false
								break;
							}
							keyval = getconsttable()["BUTTON_"+key] | keyval
						}
						if(!valid)
						{
							delete tbl[steamID][keyname]
							continue;
						}
					}
					else if(!("BUTTON_"+keyname in getconsttable()))
					{
						printl("[Binds-Key-Error] Key name "+keyname+" is unknown... skipping")
						delete tbl[steamID][keyname]
						continue
					}
					else
						keyval = getconsttable()["BUTTON_"+keyname] | keyval
					
					foreach(funcname,deftbl in binds)
					{
						if(funcname.find("!") == 0)
						{
							local func_real_name = funcname.slice(1) 
							if(!(func_real_name in ::ChatTriggers))
							{
								printl("[Binds-Command-Error] Command name "+func_real_name+" is unknown... skipping")
								delete tbl[steamID][keyname][funcname]
								continue
							}
							else
							{
								if(!("Usage" in deftbl))
								{
									printl("[Binds-Command-Warning] Command usage for "+func_real_name+" is unknown... using PS_WHEN_PRESSED")
									tbl[steamID][keyname][funcname].Usage <- PS_WHEN_PRESSED
								}
								else if(typeof deftbl.Usage != "integer")
								{
									printl("[Binds-Command-Warning] Command usage for "+func_real_name+" is not a known constant! Using PS_WHEN_PRESSED instead...")
									tbl[steamID][keyname][funcname].Usage = PS_WHEN_PRESSED
								}

								if(!("Arguments" in deftbl))
								{
									printl("[Binds-Command-Warning] Command arguments table for "+func_real_name+" is unknown... using empty arguments table")
									tbl[steamID][keyname][funcname].Arguments <- {}
								}
								else if(typeof deftbl.Arguments != "table")
								{
									printl("[Binds-Command-Warning] Command arguments table for "+func_real_name+" is not a table! Using empty arguments table instead...")
									tbl[steamID][keyname][funcname].Arguments = {}
								}

								tbl[steamID][keyname][funcname].Arguments = Utils.TableKeySearchFilterReturnAll(tbl[steamID][keyname][funcname].Arguments,@"arg_\d+",@(k,c) c-1)
							}
						}
						else
						{
							if(!("Usage" in deftbl))
							{
								printl("[Binds-Function-Warning] Function usage for "+funcname+" is unknown... using PS_WHEN_PRESSED")
								tbl[steamID][keyname][funcname].Usage <- PS_WHEN_PRESSED
							}
							else if(typeof deftbl.Usage != "integer")
							{
								printl("[Binds-Function-Warning] Function usage for "+funcname+" is not a known constant! Using PS_WHEN_PRESSED instead...")
								tbl[steamID][keyname][funcname].Usage = PS_WHEN_PRESSED
							}

							if(!("Function" in deftbl))
							{
								printl("[Binds-Function-Error] Function key for "+funcname+" is unknown... skipping the function")
								delete tbl[steamID][keyname][funcname]
							}
							else if(typeof deftbl.Function != "function")
							{
								printl("[Binds-Function-Error] Function key for "+funcname+" is not a function! Skipping it...")
								delete tbl[steamID][keyname][funcname]
							}
						}

						if(tbl[steamID][keyname].len() != 0)
						{
							news[steamID][keyname] <- []
							foreach(foo,vals in tbl[steamID][keyname])
							{
								news[steamID][keyname].append(foo+": "+::Constants.ConstStrLookUp("PS_WH",vals.Usage))
							}
						}
						else
						{
							delete tbl[steamID][keyname]
						}
					}

					if(tbl[steamID].len() == 0)
					{
						delete tbl[steamID]
					}
				}
			}

			if(news.len() > 0)
			{	
				if(reload)
					printl("[Binds-Table] New binds after reloading "+filename+":")
				else
					printl("[Binds-Table] Valid binds found in "+filename+":")

				foreach(steamid,keyns in news)
				{
					printl("\t[*] "+steamid+ " ("+keyns.len()+" keys): ")
					foreach(keyn,cmds in keyns)
					{
						printl("\t\t[*] "+keyn+ " : "+cmds.len()+" functions/commands")
						foreach(_i,fstr in cmds)
						{
							printl("\t\t\t[*] "+fstr)
						}
					}
				}
			}
			else 
			{
				if(reload)
					printl("[Binds-Table] No new valid binds were loaded from "+filename)
				else
					printl("[Binds-Table] No valid binds were registered from "+filename)
			}

		}

		return tbl;
	}
}

::Constants.LootSourcesLootTablesDefaults <-
@"// This file contains loot types, probabilities and settings used with !create_loot_sources command
// Characters // indicate the start of a comment, which are ignored while reading the file
// DO NOT REMOVE ANY COMMA("","") CHARACTERS
// IF YOU ADD ANY TABLES, MAKE SURE TABLE BEFORE THAT HAS A COMMA AT THE END
//
// Current loots are weapons, grenades, packs and pills/adrenaline shots
//   ent: Class name of the loot
//   prob: Probability values below are not normalized, they are relative to total value of the ""prob"" from all the tables in this file.
//		+ This means if sum is 200, table with prob = 10 has 10/200 = 5% probabilty of being chosen
//   ammo: Ammo beside the full clip
//   melee_type: Melee name to use with ""weapon_melee_spawn""

{
	ent = ""weapon_rifle""			
	prob = 10		
	ammo = 50	
	melee_type = null	
},
{
	ent = ""weapon_shotgun_spas""	
	prob = 10		
	ammo = 10	
	melee_type = null	
},
{
	ent = ""weapon_sniper_military""	
	prob = 10		
	ammo = 15	
	melee_type = null	
},
{
	ent = ""weapon_rifle_ak47""		
	prob = 10		
	ammo = 40	
	melee_type = null	
},
{
	ent = ""weapon_autoshotgun""		
	prob = 10		
	ammo = 10	
	melee_type = null	
},
{
	ent = ""weapon_rifle_desert""	
	prob = 10		
	ammo = 60	
	melee_type = null	
},
{
	ent = ""weapon_hunting_rifle""	
	prob = 15		
	ammo = 15	
	melee_type = null	
},
{
	ent = ""weapon_rifle_m60""		
	prob = 2		
	ammo = 50	
	melee_type = null	
},
{
	ent = ""weapon_grenade_launcher""	
	prob = 2	
	ammo = 50	
	melee_type = null	
},
{
	ent = ""weapon_smg_silenced""	
	prob = 20		
	ammo = 50	
	melee_type = null	
},
{
	ent = ""weapon_smg""				
	prob = 20		
	ammo = 50	
	melee_type = null	
},
{
	ent = ""weapon_shotgun_chrome""	
	prob = 20		
	ammo = 10	
	melee_type = null	
},
{
	ent = ""weapon_pumpshotgun""		
	prob = 20		
	ammo = 10	
	melee_type = null	
},
{
	ent = ""weapon_pistol_magnum""	
	prob = 5		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_pistol""			
	prob = 10		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_adrenaline"" 		
	prob = 10		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_pain_pills"" 		
	prob = 20		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_vomitjar"" 		
	prob = 3		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_molotov"" 		
	prob = 10		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_pipe_bomb"" 		
	prob = 10		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_first_aid_kit"" 	
	prob = 1		
	ammo = null	
	melee_type = null	
},

// Note: These items don't retain their entities when spawned, and cannot be tracked.
{
	ent = ""weapon_melee_spawn""		
	prob = 10		
	ammo = null	
	melee_type = ""any""	
},
{
	ent = ""upgrade_spawn"" 			
	prob = 3		
	ammo = null	
	melee_type = null	
},
// Laser sight
{
	ent = ""weapon_upgradepack_explosive"" 		
	prob = 5		
	ammo = null	
	melee_type = null	
},
{
	ent = ""weapon_upgradepack_incendiary"" 		
	prob = 7		
	ammo = null	
	melee_type = null	
}"

/********************\
*  DEFAULT SETTINGS  *
\********************/
::Constants.GetEscapeHelpString <- function()
{
	local s="\n\t\t";
	foreach(sname,infotbl in ::VSLib.EasyLogic.Escapes)
	{
		if("explain" in infotbl)
			s += format("//\t\t -> %s gets replaced with a constant which is %s \n\t\t",infotbl.pattern.slice(1,5),infotbl.explain);
		else
			s += format("//\t\t -> %s gets replaced with \"%s\"\n\t\t",infotbl.pattern.slice(1,5),infotbl.i.tochar());
	}
	s += @"//		Example: scripted_user_func say,all,console\x20hates\x20these\x20characters\x2C\x20so\x20use\x20\x22hex\x22\x20values!"+"\n\t\t"
	s += @"//		Result: Makes everyone say ""console hates these characters,so use ""hex"" values!"" to chat"+"\n\t\t"
	return s;
}

::Constants.DefaultsDetailed <-
{
    FormattingIntro =  
@"// >>> This file contains some editable default settings
// >>> The characters // and /// indicate comments starting after them, which are ignored
// >>> This file gets compiled directly within the project_smok, so be careful with the formatting and what is written here!
// >>> Errors and fixes done by the add-on will be reported to console, so check the console if you've made a change and wheter it caused a fix to be used
//
// >>> Values with comment DON'T CHANGE THIS are expected to stay same, they are critical and will generally be changing during the game!
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
		CompileHexAndSpecialsInArguments =
		{
			Value = true
			Comment = "// true: Try to compile all arguments before using, false: Use arguments as is\n\t\t// When this setting is true:\n\t\t//\t o Offers a somewhat complex way of getting around chat and console limitations\n\t\t//\t o Allows $[expression] format for arguments, example: $[2*3] will be replaced with 6\n\t\t//\t o Allows usage of \"__\" enum class for special characters, example: $[__._q+__.h+__.i+__._em+__._q] will be replaced with \"hi!\"\n\t\t//\t\t o Check !enum_string command for this!\n\t\t//\t o Allows a few common hex characters:" + ::Constants.GetEscapeHelpString()
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
            
			BackUpProp =
			{
				Value =
				{
					enabled = false
					modelname = "models/items/l4d_gift.mdl"
					classname = "prop_physics_multiplayer"
				}
				ValueComments =
				{
					enabled = "// true: Spawn backup prop upon failure, false: Keep the held object as is"
					modelname = "// Backup prop model path"
					classname = "// Backup prop class name"
				}
				Comment = "// Backup prop to use in case physics covnersion weren't successful"
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
					commentary_dummy = true,
					prop_fuel_barrel = true,
					simple_physics_prop = true
                }
                Comment = @"
			// Class names available for grab, format: ""class_name = is_enabled""
			// >>> To enable/disable classes, change value on the right side to true/false
			// >>> To add new classes, add a new key-value pair following the format described above: my_class_name = true
			// Classes written here by defaults can't be removed, they will get re-written if they are removed 
			// Class names SHOULD NOT be repeated, when repeated, latest pair will overwrite the previous one(s) and dupes will be removed after any fix gets applied
			// Weapons and their spawners are enabled by default (weapon_ suffix and _spawn prefix), you can disable any of them by adding them here:
			// 		Example: Disable grabbing the ammo spawners
			//			weapon_ammo_spawn = false" 
            }
        }
		
		LootSources =
		{
			Title = "\t\t/// Lootable prop parameters, used with create_loot_sources command"
			Value =
			{
				LootDuration = 2.5

				NoItemProb = 0.35
				MinItems = 1
				MaxItems = 2
				SpawnDist = 10

				GlowR = 255
				GlowG = 80
				GlowB = 255
				GlowA = 255
				GlowRange = 180

				BarText = "Lootable Prop"
				BarSubText = "There might be something valuable in here!"

				events_enabled = true

				explosion_prob = 0.05
				hurt_prob = 0.1
				horde_prob = 0.07
				ambush_prob = 0.05
			}

            ValueComments =
			{
				LootDuration = "// How long it should take to loot a prop in seconds"

				NoItemProb = "// Probability of the prop having no loot, 0 = 0% , 1 = 100%"
				MinItems = "// Minimum amount of items to drop when the prop is looted"
				MaxItems = "// Maximum amount of items to drop when the prop is looted"
				SpawnDist = "// Spawning distance of the loots to looter player, loots spawn around the player"

				GlowR = "// Red value of glowing color of lootable props"
				GlowG = "// Green value of glowing color of lootable props"
				GlowB = "// Blue value of glowing color of lootable props"
				GlowA = "// Alpha value of glowing color of lootable props"
				GlowRange = "// Range to start glowing for players "

				BarText = "// Big text to display for the looting bar"
				BarSubText = "// Sub text to display for the looting bar"
				
				events_enabled = "// true: Enable random events upon looting, false: no random events"
				explosion_prob = "// Probability of explosion"
				hurt_prob = "// Probability of getting hurt once or several times"
				horde_prob = "// Probability of calling a horde"
				ambush_prob = "// Probability of a special zombie ambush"
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

        ModelSaving =
        {
            Title = "\t\t/// Model saving"
            State = 
            {
                Value = true
                Comment = "// true: save last randomly spawned prop's class and model, false: don't save last random model"
            }    	
            SurvivorSettings =  
            {
                Value = 
                {
                    classname="",
                    model=""
                }
                ValueComments =
                {
                    classname = "// Class name of the prop to use the model, example: \"prop_dynamic\""
                    model = "// Model path, example: \"models/props_interiors/tv.mdl\""
                }
                Comment = "// Default saved model and classname for all survivors to spawn a prop"
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
					effect_name = "// Particle to use until explosion, use \"no_effect\" for no particle effects"
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
			Title = "\t\t/// Player models' keeping state for all players, value gets repeated for all characters"
            State = 
			{
				Value = true
				Comment = "// true: restore last player model for the next chapter/reset, false: restore original player model after the chapter/reset"
			}
        }

        
        GhostZombies =
        {
			Title = "\t\t/// Ghost zombies event starting state"
            State =
			{
				Value = 0
				Comment = "// State of ghost zombies when starting the game; 0: start off, 1: start on"
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
// TO-DO: Shorten these, mostly repetitive
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
::__StringifyLootSourcesSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.LootSources;

		local s = ""
		foreach(setting,val in maintbl.Value)
		{
			s += "\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.ValueComments[setting] + "\n\r"
		}

		return s;
	}
	else
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.LootSources;
		local maintblref = tblref.Tables.LootSources

		local s = ""
		foreach(setting,val in maintbl.Value)
		{	
			s += "\t\t\t" + setting + " = " + ((typeof maintblref[setting] == "string") ? "\""+maintblref[setting]+"\"": maintblref[setting]) + "\t" + maintbl.ValueComments[setting] + "\n\r"
		}

		return s;
	}
}
::__StringifyGrabYeetSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local s = ""
		local maintbl = ::Constants.DefaultsDetailed.Tables.GrabYeet;

		s += __SingleValWithComment(maintbl,"GrabRadiusTolerance") + "\n\r";
		
		s += "\t\t\tBackUpProp = " + maintbl.BackUpProp.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.BackUpProp.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof val == "string") ? "\""+val+"\"": val) + "\t" + maintbl.BackUpProp.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

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
		
		s += "\t\t\tBackUpProp = " + maintbl.BackUpProp.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.BackUpProp.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.BackUpProp[setting] == "string") ? "\""+maintblref.BackUpProp[setting]+"\"": maintblref.BackUpProp[setting]) + "\t" + maintbl.BackUpProp.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		s += "\t\t\tSurvivorSettings = " + maintbl.SurvivorSettings.Comment + "\n\r\t\t\t{\n\r"
		foreach(setting,val in maintbl.SurvivorSettings.Value)
		{
			s += "\t\t\t\t" + setting + " = " + ((typeof maintblref.SurvivorSettings[setting] == "string") ? "\""+maintblref.SurvivorSettings[setting]+"\"": maintblref.SurvivorSettings[setting]) + "\t" + maintbl.SurvivorSettings.ValueComments[setting] + "\n\r"
		}
		s += "\t\t\t}\n\r"

		local customizedtbl = ::VSLib.Utils.TableCopy(maintbl.ValidGrabClasses.Value)
		foreach(cls,val in maintblref.ValidGrabClasses)
		{
			if(cls in customizedtbl)
				customizedtbl[cls] = val
			else
				customizedtbl[cls] <- val
		}
		s += "\t\t\tValidGrabClasses = " + maintbl.ValidGrabClasses.Comment + "\n\r\t\t\t{\n\r"
		foreach(cls,val in customizedtbl)
		{
			s += "\t\t\t\t" + cls + " = "+(val ? "true" : "false")+"\n\r"
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
::__StringifyModelSavingSettings <- function(tblref=null)
{
	if(tblref == null)
	{
		local maintbl = ::Constants.DefaultsDetailed.Tables.ModelSaving;

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
		local maintbl = ::Constants.DefaultsDetailed.Tables.ModelSaving;
		local maintblref = tblref.Tables.ModelSaving

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
::__StringifyGhostZombiesSettings <- function(tblref=null)
{
    if(tblref == null)
	{
	    return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.GhostZombies,"State");
    }
	return __SingleValWithComment(::Constants.DefaultsDetailed.Tables.GhostZombies,"State",tblref.Tables.GhostZombies);
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

		+ Constants.DefaultsDetailed.Tables.LootSources.Title + "\n\r\t\t"
		+ "LootSources =\n\r\t\t{\n\r"
		+ __StringifyLootSourcesSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.Hats.Title + "\n\r\t\t"
		+ "Hats =\n\r\t\t{\n\r"
		+ __StringifyHatsSettings(tbl)
		+ "\n\r\t\t}\n\r"

		+ Constants.DefaultsDetailed.Tables.ModelSaving.Title + "\n\r\t\t"
		+ "ModelSaving =\n\r\t\t{\n\r"
		+ __StringifyModelSavingSettings(tbl)
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
		
		+ Constants.DefaultsDetailed.Tables.GhostZombies.Title + "\n\r\t\t"
		+ "GhostZombies =\n\r\t\t{\n\r"
		+ __StringifyGhostZombiesSettings(tbl)
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

		props = compilestring("local __tempvar__="+ps+";return __tempvar__;")();
		
		if(propsavetofile)
		{
			StringToFile(::Constants.Directories.CustomizedPropSpawnDefaults, ps);
		}
	}

    local tbl = compilestring("local __tempvar__="+s+";return __tempvar__;")();

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

			if(!ValidateTbl(tbl.Tables.GrabYeet,"BackUpProp"))
			{
				fixapplied.append("Re-create default Tables.GrabYeet.BackUpProp")
				tbl.Tables.GrabYeet.BackUpProp <- correcttbl.Tables.GrabYeet.BackUpProp
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.GrabYeet.BackUpProp)
				{
					if(!ValidateTbl(tbl.Tables.GrabYeet.BackUpProp,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.GrabYeet.BackUpProp,correcttbl.Tables.GrabYeet.BackUpProp,setting))
					{
						fixapplied.append("Use default Tables.GrabYeet.BackUpProp."+setting)
						tbl.Tables.GrabYeet.BackUpProp[setting] <- correcttbl.Tables.GrabYeet.BackUpProp[setting]
					}
				}
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
			else
			{
				foreach(setting,val in correcttbl.Tables.GrabYeet.ValidGrabClasses)
				{
					if(!ValidateTbl(tbl.Tables.GrabYeet.ValidGrabClasses,setting,"bool"))
					{
						fixapplied.append("Use default Tables.GrabYeet.ValidGrabClasses."+setting)
						tbl.Tables.GrabYeet.ValidGrabClasses[setting] <- correcttbl.Tables.GrabYeet.ValidGrabClasses[setting]
					}
				}
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
		
		// Model saving
		if(!ValidateTbl(tbl.Tables,"ModelSaving"))
		{
			fixapplied.append("Re-create default Tables.ModelSaving")
			tbl.Tables.ModelSaving <- correcttbl.Tables.ModelSaving
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.ModelSaving,"State","bool"))
			{
				fixapplied.append("Re-create default Tables.ModelSaving.State")
				tbl.Tables.ModelSaving.State <- correcttbl.Tables.ModelSaving.State
			}

			if(!ValidateTbl(tbl.Tables.ModelSaving,"SurvivorSettings"))
			{
				fixapplied.append("Re-create default Tables.ModelSaving.SurvivorSettings")
				tbl.Tables.ModelSaving.SurvivorSettings <- correcttbl.Tables.ModelSaving.SurvivorSettings
			}
			else
			{
				foreach(setting,val in correcttbl.Tables.ModelSaving.SurvivorSettings)
				{
					if(!ValidateTbl(tbl.Tables.ModelSaving.SurvivorSettings,setting,false) 
					|| !ValidateSimilarTyp(tbl.Tables.ModelSaving.SurvivorSettings,correcttbl.Tables.ModelSaving.SurvivorSettings,setting))
					{
						fixapplied.append("Use default Tables.ModelSaving.SurvivorSettings."+setting)
						tbl.Tables.ModelSaving.SurvivorSettings[setting] <- correcttbl.Tables.ModelSaving.SurvivorSettings[setting]
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
		
		// Ghost zombies
		if(!ValidateTbl(tbl.Tables,"GhostZombies"))
		{
			fixapplied.append("Re-create default Tables.GhostZombies")
			tbl.Tables.GhostZombies <- correcttbl.Tables.GhostZombies
		}
		else
		{
			if(!ValidateTbl(tbl.Tables.GhostZombies,"State","integer|float"))
			{
				fixapplied.append("Re-create default Tables.GhostZombies.State")
				tbl.Tables.GhostZombies.State <- correcttbl.Tables.GhostZombies.State
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
		
		// Loot sources
		if(!ValidateTbl(tbl.Tables,"LootSources"))
		{
			fixapplied.append("Re-create default Tables.LootSources")
			tbl.Tables.LootSources <- correcttbl.Tables.LootSources
		}
		else
		{
			foreach(setting,val in correcttbl.Tables.LootSources)
			{
				if(!ValidateTbl(tbl.Tables.LootSources,setting,false) 
				|| !ValidateSimilarTyp(tbl.Tables.LootSources,correcttbl.Tables.LootSources,setting))
				{
					fixapplied.append("Use default Tables.LootSources."+setting)
					tbl.Tables.LootSources[setting] <- correcttbl.Tables.LootSources[setting]
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
		printl("[Default-Fix-List] Defaults table has had the following fixes applied:")
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
        df = compilestring("local __tempvar__="+defs+";return __tempvar__;")();

    	propdefs = FileToString(::Constants.Directories.CustomizedPropSpawnDefaults);
		props = compilestring("local __tempvar__="+propdefs+";return __tempvar__;")();
		
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
        	df = compilestring("local __tempvar__="+defs+";return __tempvar__;")();
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
			props = compilestring("local __tempvar__="+propdefs+";return __tempvar__;")();
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

::Constants.ValidateCommandRestrictionTable <- function(tbl,fileContents)
{
	if(typeof tbl != "table")
	{
		printl("[Commands-Error] command_limits.txt was formatted entirely wrong, do NOT remove { and } characters at the start and the end of the file!...")
		printl("[Commands-Error] Keeping incorrectly formatted file named differently and replacing it with the default one...")

		StringToFile(Constants.Directories.CommandRestrictionsBadFormat,fileContents);

		StringToFile(Constants.Directories.CommandRestrictions,Constants.CommandRestrictionsDefault);

		fileContents = FileToString(Constants.Directories.CommandRestrictions);
		return compilestring("local __tempvar__="+fileContents+";return __tempvar__;")()
	}
	else
	{
		if(tbl.len() != 0)
		{	
			local issuesfound = false
			printl("[Command-Checks] Doing command limit table checks...")
			foreach(cmd,valtbl in tbl)
			{
				if(cmd == "command_name_1" || cmd == "command_name_2")
					continue

				if(!(cmd in ::ChatTriggers))
				{
					printl("\t[Commands-Missing] "+cmd+" is not a known command! Consider checking the name or removing it to save space.")
					issuesfound = true
				}
				else
				{
					if("BanList" in valtbl)
					{
						if(typeof valtbl.BanList != "table")
						{
							printl("\t["+cmd+"-Error] BanList present in the table should be a table, formatted as: BanList = { \"steamid\" : true }")
							tbl[cmd].Banlist <- {}
							issuesfound = true
						}
					}
					if("CoolDown" in valtbl)
					{
						if(typeof valtbl.CoolDown != "table")
						{
							printl("\t["+cmd+"-Error] CoolDown present in the table should be a table, formatted as: CoolDown = { \"steamid\" : cooldown_duration }")
							tbl[cmd].CoolDown <- {}
							issuesfound = true
						}
					}
					if("CoolDownAll" in valtbl)
					{
						if((typeof valtbl.CoolDownAll != "integer" && typeof valtbl.CoolDownAll != "float") || valtbl.CoolDownAll < 0)
						{
							printl("\t["+cmd+"-Error] CoolDownAll present in the table should be a real positive number, formatted as: CoolDownAll = cooldown_duration")
							tbl[cmd].CoolDownAll <- 0
							issuesfound = true
						}
					}
				}
			}
			if(issuesfound)
				printl("[Command-Checks] Applied fixes to current session, consider checking command_limits.txt file to correct the mistakes.")
			else
				printl("[Command-Checks] No issues found for command restrictions.")
		}
		return tbl;
	}
}

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

/// Ghost zombies event
/*
 * Returns default ghost zombies event settings
 */
::Constants.GetGhostZombiesSettingsDefaults <- function()
{
    local tbl = 
    {
		min_alpha = 40
		max_alpha = 80
		ghost_prob = 0.75
		timer_delay = 1
		render_effect = RENDERFX_PULSE_SLOW
		stay_ghost_after = 0
		zombie_pick_type = 3
	};
    return tbl;
}
/*
 * Returns default ghost zombies event setting explanations
 */
::Constants.GetGhostZombiesSettingsComments <- function()
{
    local tbl = 
    {
		min_alpha = "Minimum alpha value"
		max_alpha = "Maximum alpha value"
		ghost_prob = "Probability of zombie turning into ghost, tested every timer_delay seconds"
		timer_delay = "Interval length in seconds to try ghostifying zombies"
		render_effect = "Ghost effect, integer in the interval [0,24], check flags with !flag_lookup RENDERFX_"
		stay_ghost_after = "1: Keep the ghost effect after the event is turned off, 0: Remove the ghost effect when even turns off"
		zombie_pick_type = "3: Ghostify common and special zombies, 2: Special zombies only, 1: Common zombies only"
	}
    return tbl;
}

/*
 * Returns properly aligned ghost zombies settings string formatted as:
 *
 *      setting = default_value // explanation
 *
 */
::Constants.GetGhostZombiesSettings <- function()
{
    local comments = ::Constants.GetGhostZombiesSettingsComments();
    local settings = 
    [
        "min_alpha","max_alpha","ghost_prob",
        "timer_delay","render_effect","stay_ghost_after",
		"zombie_pick_type"
    ]
    local defaults = ::Constants.GetGhostZombiesSettingsDefaults();
    
    local gssettings  = "";
    local length = settings.len();
    local setting = "";
    for(local i = 0; i < length; i++)
    {
        setting = settings[i];
        gssettings += setting + " = " + defaults[setting] + " // " + comments[setting] + (i != length-1 ? "\r\n" : "");
    }
    return gssettings;
}

::Constants.Defaults.GhostZombiesSettings <- ::Constants.GetGhostZombiesSettings();

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
                prob = 0.08
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
                prob = 0.2
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
                prob = 0.08
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
                prob = 0.2
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