# project_smok
 - Repository for the workshop item [project_smok](https://steamcommunity.com/sharedfiles/filedetails/?id=2229460523) of L4D2
 
 - Following documentation is for the **new and updated commands**. Commands that aren't included in this documentation can be found in the [Admin System Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=213591107). Be aware that **some of the commands that are not documented may behave differently** than the guide. 

## Forums

- If you have encountered a bug or had add-on confliction issues, please [report it here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089552207/)

- If you have any suggestions, please [write them here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089554499/)

- If you are having trouble with the add-on or have any questions, please [ask here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089567424/)

## Development
 - If you'd like to contribute to the development of **project_smok** contact [rhino](http://steamcommunity.com/profiles/76561198095804696)
---
# Documentation Contents
- [**Downloading and Installing**](#downloading-and-installing)

- [**Bot Abilites and Trading**](#bot-abilites-and-trading)

- [**Commands**](#commands)

    - [**Using commands**](#using-commands)
    		
        - [**Using via menu**](#via-the-menu)
 
        - [**Using via console**](#via-the-console)
		
        - [**Using via chat triggers**](#via-chat-triggers)

    - [**Creating new commands**](#creating-new-commands)
    		
        **o** [**Using aliases**](#using-aliases)
        
 	    - [**Alias Variables and Expressions**](#alias-variables-and-expressions)
 	    
 	    - [**Alias Options**](#alias-options)
 	    
 	    - [**Alias File Format**](#alias-file-format)
 	    
        **o** [**Using scripts**](#using-scripts)
 	    
 	    - [**Script Options**](#script-options)
 	    
 	    - [**Script File Format**](#script-file-format)
 	    
    - [**Character limitations**](#character-limitations)
    		
        - [**Chat limitations**](#using-aliases)
 
        - [**Console limitations**](#using-scripts)

        - [**Runtime character compilation**](#runtime-character-compilation)
    
- [**Command Categories**](#command-categories)

    - [**Entities/Objects**](#entities)

    - [**Random voice lines**](#random-and-saved-voices)

    - [**Sound scripts**](#sound-scripts)
    
    - [**Particle effects**](#particle-effects)

    - [**Custom sequences of voice lines**](#custom-sequences)

    - [**Apocalypse event**](#apocalypse-event)

    - [**Ghost zombies event**](#ghost-zombies-event)

    - [**Meteor shower event**](#meteor-shower-event)

    - [**Freezing objects**](#freezing-objects)

    - [**Piano keys**](#piano)

    - [**Microphones and speakers**](#microphones-and-speakers)

    - [**Explosions**](#explosions)

    - [**Ragdolling**](#ragdoll)

    - [**Driving**](#driving)
    
    - [**Texture commands**](#texture-commands)
    
    - [**Animation commands**](#animation-commands)
  
    - [**Looting commands**](#looting-commands)
    
    - [**Experimental commands**](#experimental-commands)
    
    - [**Other commands**](#other)

    - [**Debugging, scripting and setting related**](#debugging-scripting-and-settings-related)

    - [**Custom Script Related**](#custom-script-related)

- [**Binds**](#binds)

    - [**Binds File Format**](#binds-file-format)   

- [**Entity groups**](#entity-groups)

    - [**Entity Groups File Format**](#entity-groups-file-format) 
    
    - [**Creating Entity Groups**](#creating-entity-groups) 
     
    - [**Importing Entity Groups**](#importing-entity-groups)  
    
- [**Hooks**](#hooks)

    - [**Hook File Format**](#hook-file-format)    	
    	
- [**Extra**](#extra)

    - [**Configuration files**](#changing-settings-adding-custom-responses-without-launching-the-game)

        - [**Basic configuration structure**](#basic-configuration-structure)
        
        - [**Configuration files extra notes**](#extra-notes)
        
    - [**Detailed Tables**](#detailed-tables)
        
    - [**Discussions**](#forums)
    
- [**Other Links**](#other-links)

---

# Downloading and Installing 
 - Download **Left 4 Dead 2 Authoring Tools** *(Steam>Library>Tools)*
 
 - Download the **.zip** archive and extract the **project_smok-master** folder **OR** clone the **master** branch into a folder
 
 - Locate the folder named "_**2229460523**_" in the extracted or cloned folders
 
 - Locate the _**vpk.exe**_ in the relative path _**"..\Steam\steamapps\common\Left 4 Dead 2\bin\"**_
 
 - Drag and drop the **folder** named "_**2229460523**_" **onto** the _**vpk.exe**_ . This will create the _**2229460523.vpk**_ file
 
 - Put ( or replace the original if already exists ) the created _**2229460523.vpk**_ file into the relative path _**..\Steam\steamapps\common\Left 4 Dead 2\left4dead2\addons\workshop**_
 
 - Launch the game and make sure the add-on is checked
---
 
# Bot Abilites and Trading
 - There are some new abilities given to bots and players. These abilities can be **tweaked** and/or **turned off**, [check out the configuration files](#basic-configuration-structure) 
     1. Bots can now _look for_ **grenades** and **any kind of packs**, if they have a **grenade or a pack** while the closest player to them **doesn't**, they will **share** their items with that player. 
     
     2. Players can **take away** a bot's grenades and packs (whichever player doesn't have) by **holding the reload button (R) and shoving with a weapon** the bot
     
     3. Players can **exchange** their grenades and packs with a bot while holding the grenade or the pack
  
     4. Players can **give** each other grenades and packs by **holding the reload button (R) and shoving** with the grenade or the pack
---

# Commands
  ---
  ## Using commands
   ### Via the menu:
   1. Bind the menu to an unused key, for example **"k"**:

       <code>bind k "show_menu Menu"</code>
    
   2. Open up the menu in-game by pressing the key bound in the previous step and use number keys to go through the categorized sub-menus
    
   - **Example:** To make your character say a randomline originated by them, use the following key sequence: **k 6 4 1 1 1**
   
   ---      
   ### Via the console:
   - **To enable the console**: [Main Menu -> Options -> Keyboard/Mouse -> Enable the "Allow Developer Console" option](https://left4dead.fandom.com/wiki/Console_commands#:~:text=it%20can%20be%20activated,pressing%20the%20tilde%20(~)%20key.)
   - Use **"scripted_user_func"** command, add the actual command name and seperate it and it's arguments with **"," commas**
     
       <code>scripted_user_func command,argument_1,argument_2,...</code>
 
      + **Example:** Make Ellis say **"Humans 4, zombies nothin'!"**, using **speak** command with *ellis* and *hurrah21* arguments 
 
      <code>scripted_user_func speak,ellis,hurrah21</code>
       
   - **Example:** Bind the **"randomline"** command to key **"j"** for making your survivor say a random line from Francis
     
       <code>bind j "scripted_user_func randomline,self,francis"</code>
       
   ---
   ### Via chat triggers:
   #### *Visible* execution trigger = **"!"**:
   + Used for calling commands and showing the call to other players
            
        <code>!command argument_1 argument_2 ...</code>
       
   + **Example:** Make Ellis say **"Humans 4, zombies nothin'!"
         
        <code>!speak ellis hurrah21</code>
            
   ---  
   #### *Hidden* execution trigger = **"/"**:
   + Used for calling commands and hiding the call from other players, but keeping it in your chatbox
            
        <code>/command argument_1 argument_2 ...</code>
       
   + **Example:** Spawn a snake toy prop
         
        <code>/prop physicsM models/props_fairgrounds/snake.mdl</code>
            
   ---  
   #### *Documentation* trigger = **"?"**:
   + Used for printing built-in documentations of commands, call and the documentation print is only visible to caller
         
        <code>?command</code> 
            
   + **_Warning_**: Some commands may not have any documentation
       
   + **Example(from chat):** Get information about how _randomline_ command can be used
         
        <code>?randomline</code>

   + **Example(from console):** Get information about how *ent_push* command can be used
         
        <code>scripted_user_func help,ent_push</code>
            
   ---  
   #### *Command search* trigger = **"?*"**:
   + Used for listing existing commands which matches with given pattern
   
   + [Regular expressions](http://squirrel-lang.org/squirreldoc/stdlib/stdstringlib.html#the-regexp-class) can be used as the _pattern_
         
        <code>?*pattern</code>
       
   + **Example:** Get list of commands which have the word _random_ in them
         
        <code>?*random</code>
       
   + **Example:** Get list of commands which start with letter _g_
         
        <code>?*^g</code>
       
   + **Example:** Get list of commands which have _ent_ or _prop_ words in them
         
        <code>?*ent|prop</code>
  ---

  ## Creating new commands
  
  ### Using aliases
   - Existing commands can be combined together in many ways to create new commands or aliases.
   
   #### Steps to create aliases in configuration files
   
   1. Head to **admin system/aliases/** folder
   
   2. Create a new **.txt** file, name it to your liking
   
   3. Add the file name, without extension, to **./file_list.txt** file
   
   4. Inspect the **./example_alias_file.txt** for example aliases and formatting rules
   
   5. Write your alias table following the format present in the examples
   
   6. Launch the game and check your console if the alias is loaded
   
   7. Start testing the new alias!
   
      - You can reload the alias files using the **[reload_aliases command](#reload_aliases)**. This allows an easier way to test the aliases and check for formatting mistakes
   
   #### Alias Variables and Expressions
   - There are a lot of variables available for use as command options and arguments. 
   
   Variable | Data Type | Description
   ------------ | ------------- | -------------
   $[_expression_] | _*variable*_ | Evaluate the _expression_ and use the value returned, replace _expression_ with legal expressions.
   $param_{x} | _*string, null or variable*_ | Value of {x}th parameter, replace {x} with parameter number. Data type may _vary_ since arguments are compilable via **$[expression]** format
   $repeat_id | _*integer*_ | Total number of repeats current command has, starts from 1
   $repeats_left | _*integer*_ | Number of calls left after the current call
   $last_call_time | _*float*_ | Time() value stored from the previous call	                                                                                                
   $caller_ent | _*VSLib.Player*_ | command's caller as a **VSLib.Player** object
   $caller_id | _*integer*_ | command caller's entity index as an integer
   $caller_char | _*string*_ | command caller's character name, first letter capitalized
   $caller_name | _*string*_ | command caller's in-game name
   $caller_target | _*VSLib.Entity or null*_ | entity the command caller is aiming at as a **VSLib.Entity** object or **null**
   
   #### Alias Options
   - There are 5 options available for aliases, none of them are required to initialize an alias.
   
   Option | Data Type | Description
   ------------ | ------------- | -------------
   HostOnly | _*bool*_ | _*true*_: Only allow host to use the alias; _*false*_: Allow everyone to use the alias 
   ScriptAuthOnly | _*bool*_ | _*true*_: Only allow admins with script authorization to use the alias; _*false*_: Allow everyone to use the alias
   Help | _*table*_ | Documentation table of the alias, [check the example](#alias-file-format) 
   Parameters | _*table*_ | Parameters table of the alias, uses **param_{x}** format for **{x}th** parameter
   Commands | _*table*_ | Commands table of the alias, uses **arg_{x}** format for **{x}th** argument in command tables. Has options for repetation, [check the example](#alias-file-format)
   
   #### Alias File Format
   - Following is an example alias file content including an alias called **my_alias_1** documented, referring to **2** commands and is only available for script authorized admins. Syntax follows the Squirrel Language table data type, but the file should be saved as a text **(.txt)** file at the end.
   + **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments 
```nut 
{
	// Alias name
	my_alias_1 =
	{	
		// Restrict to server host
		HostOnly = false 
		
		// Restrict to admins with script authorization
		ScriptAuthOnly = true 
		
		// Documentation for this alias
		Help =
		{
			// Alias information
			docs = "Details of what this alias does"
			
			// Parameter 1 detailed information
			param_1 = 
			{
				// Parameter name
				name = "name_for_parameter"
				
				// Parameter explanation
				docs = "Short explanation"
				
				// Default value explanation
				when_null = "What happens when nothing passed"
			}

			// Parameter 2 short information
			param_2 = "Basic short information about parameter 2"

		}
		
		// Parameters to use with my_alias_1
		Parameters =
		{
			// Parameter 1 with "default_value_1" as default value
			param_1 = "default_value_1"	
			
			// Parameter 2 Empty string as default value
			param_2 = ""			
			
			// Parameter 3 null as default value
			param_3 = null			
			
			// ... param_x = "default_value_x" // Parameter x
		}
		
		// Commands to call
		Commands =
		{
			// Call command_1 with the following arguments
			command_1 =	
			{
				// Use param_1 as first argument
				arg_1 = "$param_1"
				
				// Evaluate an expression as an argument
				arg_2 = "$[22.0/7]"	
				
				// Use conditional expressions combined with parameters
				arg_3 = "$[$param_2.len() > 2 ? \"Longer than 2 characters!\" : \"Shorter than or equal to 2 characters\"]" 
				
				// Use null if param_3 was null
				arg_4 = "$param_3"	
				
				// Use "null" if param_3 was null
				arg_5 = "$[\"$param_3\"]" 
			}
			
			// Call command_2 with the following options and arguments
			command_2 =	
			{
				// Wait 3 seconds to call this command
				start_delay = 3
				
				// Repeat this command 5 times
				repeat = 5
				
				// Evaluate an expression to decide the delay between repeats
				//  -> Example: 4 second waiting after odd numbered repeats, 8 for even numbered ones
				delay_between = "$[$repeat_id % 2 == 1 ? 4 : 8]"
				
				// Use command's caller's character name
				arg_1 = "$caller_char"	
				
				// Use how long has it been since the last call
				arg_2 = "$[Time() - $last_call_time]" 
				
				// Use a method named as a parameter from caller's class and add another parameter to it
				arg_3 = "$[$caller_ent.$param_1() + $param_2]"	
				
				// Use aimed entity, if there is a valid aimed object: use it's origin vector; else: use null
				arg_4 = "$[$caller_target ? $caller_target.GetOrigin() : null]"	
			}
		}
	}
}
```
   
   #### Commands to create or replace aliases for a single game session
   1. Start a game
   
   2. Check your console to see the loaded alias names
   
   3. Create or replace an alias:
   
      - Create a new alias with **[create_alias command](#create_alias)**
     
      - Replace an existing alias with **[replace_alias command](#replace_alias)**
   
   4. Check out the output message if the execution was successful
  ---
  
  ### Using scripts
   - New commands can be created by following the steps below:
   
   1. Head to **admin system/scripts/** folder
   
   2. Create a new **.nut** Squirrel-lang script file, name it to your liking
   
   3. Add the file name, without extension, to **./file_list.txt** file
   
   4. Inspect the **./example_script_file.nut** for an example command and the formatting rules
   
   5. Write your own command following the format present in the example
     
		 1) Decide for a name
  	 
		 2) Initialize a table with the decided name
     
		 3) Add documentations under a table named **Help**
     
		 4) Add the actual command function, taking 3 parameters, as a function named **Main** 
    
   6. Launch the game and check if the new command was registered
    
   7. Start testing the new command!
   
      - You can reload the script files using the **[reload_scripts command](#reload_scripts)**. This allows an easier way to test the commands and check for formatting mistakes
  
  #### Script Options
   - There are 2 options available for scripts, neither of them are required to initialize a command.
   
   Option | Data Type | Description
   ------------ | ------------- | -------------
   Help | _*table*_ | Documentation table of the command, [check the example](#script-file-format) 
   Main | _*function*_ | A function which takes **3** arguments, [check the example](#script-file-format)  
   
   #### Script File Format
   - Following is an example script file content for creating a command called **my_command_1**. Commands are read from the **::PS_Scripts** table, so they should initialized under this table.
   + **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments  
```nut
// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the VSLib library, check out: https://l4d2scripters.github.io/vslib/docs/index.html
// Some methods of VSLib may behave differently, make sure to check out the source code for those: https://github.com/semihM/project_smok/tree/master/2229460523/scripts/vscripts/admin_system/vslib
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

// Initialize a table using the name of your command
// -> If "my_command_1" already exists, this will overwrite it!
::PS_Scripts.my_command_1 <- {}

// Documentation for the command under the Help table
// -> This information can be accessed in-game using:
//	?my_command_1
//	!help my_command_1
::PS_Scripts.my_command_1.Help <- 
{
    // Information about the command
    docs = "Write an explanation for this command"
    
    // Information about the parameters
    // -> The right-hand-side HAVE TO be a table containing name and docs entries
    // -> when_null is not a required entry, but in absence documentation will think this parameter requires an argument passed!
    param_1 = 
    {
        name = "first parameter's name"
        docs = "what is expected as an argument"
        when_null = "what happens if no argument is passed"
    }
    // ... follow this format to create documents for xth parameter param_x ... 
}   

// Main function which is called when the command is triggered
// -> The function HAVE TO have 3 parameters:
// 	1. Caller as VSLib.Player
// 	2. Arguments in a table with integer keys and string, null or variable values
// 	3. The chat or console message caused this call, as a string
::PS_Scripts.my_command_1.Main <- function(player,args,text)
{
	// Adding restrictions
	// -> Only allow admins
	if(!AdminSystem.IsPrivileged(player))
		return;
		
	// -> Only allow admins with script authorizations
	if(!AdminSystem.HasScriptAuth(player))
		return;

	// Accessing arguments easily
	// This is same as args[0], but it is fail-safe, returns null if no argument is passed
	// But GetArgument method uses a copy of arguments stored in ::VSLib.EasyLogic.LastArgs, which only gets updated when the command is called from chat/console
	// If you expect the command to be called within a compilestring function, make sure to check args in here too!
	local argument_1 = GetArgument(1)	
	local argument_2 = GetArgument(2)	
	local argument_3 = GetArgument(3)	
	// ...

	// Write the rest of the instructions here...
	
	// At the end, print out a message for the player(s) if needed, prints to wherever the given player has his output state set to
	::Printer(player,"Put the message here!")
}
```

---
## Character limitations
- There are certain limitations of the game by default which can prevent certain commands or formats not work as intended. These limitations are generally about usage of special characters and length of the messages/commands sent.

### Chat limitations
   - Maximum message length: **127**

   - Sometimes problematic with commands which needs to compile the sent message when there are semi-colons **;** in the message

   - Not sanitized well: **";command_name** will try to execute the *command_name* in console, it will work if *command_name* has a *user* flag defined

### Console limitations
   - Maximum command length: **255**

   - Very limited with command formats, makes a lot of assumptions: **" "** to seperate arguments, **";"** to end the current command etc.

   - Characters which are not allowed to be use as commonly intended: **" "**, **"'"**, **"""**, **";"**, **":"**, **","**, **"("**, **")"**, **"{"**, **"}"**

### Runtime character compilation
   - To get around the character limitations, there are some runtime compilation tricks available. These tricks can be used from both console and chat, but they require caller to have [script authorization](#add_script_auth)

      #### Using hex values
      + Replace the special characters **in arguments** with their respective hex values. Currently available replacements

         Character in quotes | Name | Char Value | Hex Value
         ------------ | ------------- | ------------- | -------------
         " " | space      | 32 | \x20
         """ | double quotation mark     | 34 | \x22
         "'" | single quotation mark      | 39 | \x27
         "(" | round bracket open      | 40 | \x28
         ")" | round bracket close      | 41 | \x29
         "," | comma      | 44 | \x2C
         ":" | colon      | 58 | \x3A
         ";" | semi-colon      | 59 | \x3B
         "{" | open brace      | 123 | \x7B
         "}" | close brace      | 125 | \x7D

      + Using these values will result in shorter maximum command lengths, since a single character gets replaced with 4.

      + All hex values assumed to be in range **[\x01-\xFF]**. But only the ones mentioned above get replaced!

      + This process is made easier using [hex_string command](#hex_string) in chat.

      + **Example**: Make console print "console hates these characters,so use hex values!"

         - **Normal attempt:** scripted_user_func say,console hates these characters, so use "hex" values!
            + **Result**: Prints "_console_"

         - **Hex attempt:** console\x20hates\x20these\x20characters\x2C\x20so\x20use\x20\x22hex\x22\x20values!
            + **Result**: Prints "_console hates these characters,so use "hex" values!_"

      #### Using special evaluation format
      + Use **$[expression]** format to evaluate an expression and use the returned value as the argument. This allows calling any function, doing arithmetic calculations and any other evaluation method that can be used.

      + Argument should start with **"$["** and end with **"]"** for them to be taken as a compilable argument

      + The expression gets evaluated **after** hex values get replaced
 
      + Since everything in the _expression_ will be evaluated as it is, there are some restrictions:

         - To use strings, you still have to use quotation marks. 
            + **Wrong**: _$[hello it is a me]_ will throw an error since compiler will try to look for variables named as the words used.

            + **Right**: _$["hello it is a me"]_ can be used from the chat, _$[\x22hello\x20it\x20is\x20a\x20me\x22] can be used from the console

         - Strings can be turned into enumerated values to be used as arguments. Check out [enum_string command](#enum_string)
            + This is **only** more effective than using hex values when there are shorter string manipulations.
               - **Example**: Inserting a comma and a space (**'+", "+'**) between 2 other strings:

                  + **Hex values**: **"+\x22\x2C\x20\x22+"**, with length of **18** characters
                  
                  + **Enumerated**: **"+\_\_.\_c+\_\_.\_s+"** with length of **13** characters

            + **Example**: to use **"very cool, argument"** as an argument, *$[\_\_.v+\_\_.e+\_\_.r+\_\_.y+\_\_.\_s+\_\_.c+\_\_.o+\_\_.o+\_\_.l+\_\_.\_c+\_\_.\_s+\_\_.a+\_\_.r+\_\_.g+\_\_.u+\_\_.m+\_\_.e+\_\_.n+\_\_.t]* can be used, which is retrieved with the **enum_string** command

      + **Example**: Spawn a microphone at aimed point which will have the exact hearing radius as the distance from Nick to the microphone ( using Player("!nick").GetLookingDistance() )
         
         - **From console**: scripted_user_func microphone,standard,$[Player\x28\x22!nick\x22\x29\x2EGetLookingDistance\x28\x29]

         - **From chat**: !microphone standard $[Player("!nick").GetLookingDistance()]

      + **Example**: Apply rainbow effect to aimed object, for 33 seconds if Bill's health is higher than 50, otherwise 99 seconds
         
         - **From console**: scripted_user_func rainbow,$[Player\x28\x22!bill\x22\x29.GetHealth\x28\x29>50?33\x3A99]

         - **From chat**: !rainbow $[Player("!bill").GetHealth()>50?33:99]

## Command Categories
---
### Entities

#### **prop**
-  Create a prop of the given type with given model

   Chat Syntax | (!,/,?)prop *type model_path origin_offset angles mass_scale*
   ------------- | -------------

   Console Syntax | scripted_user_func *prop,type,model_path,origin_offset,angles,mass_scale* 
   ------------- | -------------
    
   Menu Sequence | _6->1->1_ AND _6->1->2_ 
   ------------- | -------------

```cpp
       //Overloads:
       // {type} should be one of (physicsM: physics object, dynamic: non-physics object, ragdoll: ragdolling models)
       // {type} also accepts classname "physics", but this class is less flexable than "physicsM" and doesn't work with most models
       // {model_path} follows the formats:
	   //   - "models/props_{category}/{name}.mdl" for a specific model
	   //	- "!random" for a random model
	   //	- ">{custom_name}" for a customized prop. Available ones: heli, rescue_heli, c130, pickup_loaded, cargo_ship, soda_can 
	   //
       // Multiple models can be given, seperated with "&" character, to create parented props ( parented by first model )
       // Use search_model and random_model commands to look for model names
       prop {type: (physicsM, dynamic, ragdoll)} {model_path | !random | >custom_name} {origin_offset:(pos|{x_offset}|{y_offset}|{z_offset}, z_offset)} {angles:(ang|{pitch}|{yaw}|{roll}, yaw)} {massScale}
       prop {type: (physicsM, dynamic, ragdoll)} {model_path | !random | >custom_name} // origin_offset = 0, angles = 0, massScale = 1

       // Example: Create a flower barrel with physics
       prop physicsM models/props_foliage/flower_barrel.mdl
       
       // Example: Create a BurgerTank sign without physics
       prop dynamic models/props_signs/burgersign.mdl
       
       // Example: Create a random object with physics
       prop physicsM !random
       
       // Example: Create a physics prop car with its windows attached(parented by the car), model origins will match
       prop physicsM models/props_vehicles/cara_69sedan.mdl&models/props_vehicles/cara_69sedan_glass.mdl

       // Example: Create a ragdoll of coach, 125 inches above aimed point, upside down
       prop ragdoll models/survivors/survivor_coach.mdl 125 ang|180|0|0

       // Example: Create a helicopter, using it's custom settings 
       prop dynamic >heli
```
---
#### **ent**
-  Create an entity of the given class with given key-values

   Chat Syntax | (!,/,?)ent *classname key_1>val_1&key_2>val_2...*
   ------------- | -------------

   Console Syntax | scripted_user_func *ent,classname,key_1>val_1&key_2>val_2...* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_ 
   ------------- | -------------

```cpp
       //Overloads:
       // Class names and their keys and possible values can be
       //      found through the Valve Developer Wikis and Hammer World Editor
       // value accepts following formats:
       //     For single values (int, float, str, flg) :
       //           value = {type:(int,float,flg)}|single_value
       //
       //     For multi-values (angle, position(vector), array(spaced values), flags) :
       //           value = {type:(ang,pos,str,flg)}|val1|val2|val3
       ent {classname} {key1}>{value1}&{key2}>{value2}...
       
       // Example (dynamic prop with Gift model with color rgb(90,30,60) and angles Pitch,Yaw,Roll->(-30,10,0) ): 
       ent prop_dynamic model>models\items\l4d_gift.mdl&rendercolor>str|90|30|60&angles>ang|-30|10|0
```
---
#### **search_model**
- Search all models with a pattern or a keyword and print one or more names.

   Chat Syntax | (!,/,?)search_model *pattern limit*
   ------------- | -------------

   Console Syntax | scripted_user_func *search_model,pattern,limit*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp 
        // Overloads:
	// {pattern} allows regular expressions
	// {limit} positive integer or "all"
	// Models searched DO NOT have the "models/" prefix and ".mdl" suffix
        search_model {pattern} {limit}
        search_model {pattern}  // limit = 15
        
        // Example print maximum 3 model names with the word "bus" in them
        search_model bus 3
	
        // Example print maximum 15 model names with the word "bus" in them
        search_model furniture
	
        // Example print all model names starting with "props_junk/trash"
        search_model ^props_junk/trash all
```
---
#### **random_model**
- Print random model names with or without a pattern or a keyword and print one or more names. Works similar to **search_model**

   Chat Syntax | (!,/,?)random_model *limit pattern*
   ------------- | -------------

   Console Syntax | scripted_user_func *random_model,limit,pattern*
   ------------- | -------------
    
   Menu Sequence | _6->1->4_
   ------------- | -------------

```cpp 
        // Overloads:
	// {limit} positive integer or "all"
	// {pattern} allows regular expressions
	// Models searched DO NOT have the "models/" prefix and ".mdl" suffix
        random_model {limit} {pattern} 
        random_model {limit}  // pattern = no pattern
        random_model // limit = 1, pattern = no pattern
        
        // Example print a random model name
        random_model
	
        // Example print all model names with the word "mannequin" in them
        random_model all mannequin
```
---
#### **random_phys_model**
- Print random physics model names with or without a pattern or a keyword and print one or more names. Works similar to **random_model**

   Chat Syntax | (!,/,?)random_phys_model *limit pattern*
   ------------- | -------------

   Console Syntax | scripted_user_func *random_phys_model,limit,pattern*
   ------------- | -------------
    
   Menu Sequence | _6->1->5_
   ------------- | -------------

```cpp 
        // Overloads:
	// {limit} positive integer or "all"
	// {pattern} allows regular expressions
	// Models searched DO NOT have the "models/" prefix and ".mdl" suffix
        random_phys_model {limit} {pattern} 
        random_phys_model {limit}  // pattern = no pattern
        random_phys_model // limit = 1, pattern = no pattern
```
---
#### **save_model**
- Save a model with a class to be spawn a prop easily

   Chat Syntax | (!,/,?)save_model *classname modelpath*
   ------------- | -------------

   Console Syntax | scripted_user_func *save_model,classname,modelpath*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp 
        // Overloads:
        save_model {classname : (physics,ragdoll,dynamic)} {modelpath}
        
        // Example (save physics prop with tv model
        save_model physics models/props_interiors/tv.mdl
```
---
#### **random_model_save_state**
- Update the state of saving the last randomly spawned prop

   Chat Syntax | (!,/,?)random_model_save_state
   ------------- | -------------

   Console Syntax | scripted_user_func *random_model_save_state*
   ------------- | -------------
    
   Menu Sequence | _6->1->3->1_
   ------------- | -------------

---
#### **spawn_model_saved**
- Spawn a prop with saved model and class 

   Chat Syntax | (!,/,?)spawn_model_saved
   ------------- | -------------

   Console Syntax | scripted_user_func *spawn_model_saved*
   ------------- | -------------
    
   Menu Sequence | _6->2_
   ------------- | -------------

---
#### **display_saved_model**
- Display the saved model information if there is any

   Chat Syntax | (!,/,?)display_saved_model
   ------------- | -------------

   Console Syntax | scripted_user_func *display_saved_model*
   ------------- | -------------
    
   Menu Sequence | _6->1->3->2_
   ------------- | -------------

---
#### **ent_rotate**
- Rotate the targeted entity

   Chat Syntax | (!,/,?)ent_rotate *axis degrees*
   ------------- | -------------

   Console Syntax | scripted_user_func *ent_rotate,axis,degrees*
   ------------- | -------------
    
   Menu Sequence | _6->3->5->4_
   ------------- | -------------

```cpp 
        //Overloads:
        ent_rotate {axis : (x,y,z)} {val : degrees}
        ent_rotate {val : degrees}   // axis = y
```
---
#### **ent_push**
- Push the targeted entity in given direction

   Chat Syntax | (!,/,?)ent_push *speed direction pitch*
   ------------- | -------------

   Console Syntax | scripted_user_func *ent_push,speed,direction,pitch*
   ------------- | -------------
    
   Menu Sequence | _6->3->5->1_ AND _6->3->5->2_
   ------------- | -------------
```cpp 
      //Overloads:
      ent_push {scale} {direction: (forward,backward,left,up,right,left,random)} {pitch: degrees}
      ent_push   // scale = 10 , direction = forward , pitch = 0
```
---
#### **ent_move**
- Move(by teleporting) the targeted entity in given direction

   Chat Syntax | (!,/,?)ent_move *scale direction*
   ------------- | -------------

   Console Syntax | scripted_user_func *ent_move,scale,direction* 
   ------------- | -------------
    
   Menu Sequence | _6->3->5->5_
   ------------- | -------------
```cpp 
      //Overloads:
      // Forward and Backward directions are relative to eye pitch
      // Up and Down directions are relative to ground
      ent_move {scale} {direction: (forward,backward,left,up,right,left)}
```
---
#### **ent_teleport**
- Teleport the entity with the given name/ID to aimed location ("#" should be while using ID)

   Chat Syntax | (!,/,?)ent_teleport *ID_OR_NAME*
   ------------- | -------------

   Console Syntax | scripted_user_func *ent_teleport,ID_OR_NAME* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
      //Overloads:
      ent_teleport {entity_name}
      ent_teleport #{entity_ID}
```
---
#### **rainbow**
- Apply rainbow effect to targeted entity 
   Chat Syntax | (!,/,?)rainbow *total_duration each_color_duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *rainbow,_total_duration,each_color_duration* 
   ------------- | -------------
    
   Menu Sequence | _6->3->4->1_
   ------------- | -------------
```cpp 
       //Overloads: Assert (total_duration/color_duration) <= 2000
       rainbow {total_duration<=300.0} {color_duration>=0.05}  
       rainbow {total_duration<=300.0} 
```
---
#### **grab**
- Grabs aimed entity, also lets go if player is grabbing an entity

   Chat Syntax | (!,/,?)grab
   ------------- | -------------

   Console Syntax | scripted_user_func *grab* 
   ------------- | -------------
    
   Menu Sequence | _6->3->7->1_
   ------------- | -------------
---    
#### **letgo**
- Drops the held entity

   Chat Syntax | (!,/,?)letgo
   ------------- | -------------

   Console Syntax | scripted_user_func *letgo* 
   ------------- | -------------
    
   Menu Sequence | _USE 6->3->7->1_
   ------------- | -------------
---    
#### **yeet**
- YEEEEEET

   Chat Syntax | (!,/,?)yeet
   ------------- | -------------

   Console Syntax | scripted_user_func *yeet* 
   ------------- | -------------
    
   Menu Sequence | _6->3->7->2_
   ------------- | -------------
---    
#### **show_yeet_settings**
- Shows grabbing settings in console

   Chat Syntax | (!,/,?)show_yeet_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_yeet_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->3->7->4_
   ------------- | -------------
    
    Setting | Default Value | Description
    ------------ | ------------- | -------------
    grabRange | 170      | maximum range for grabbing an entity
    grabDistMin | 75      | how far away to hold the entity
    grabHeightBelowEyes | 30      | how far below eye-level to hold the entity, below zero mean above eye-level
    yeetSpeed | 1500      | speed of yeeting
    yeetPitch | -10      | pitch of yeeting, below zero means aiming higher
    grabByAimedPart | 1      | 1: grab by aimed location , 0: grab by entity's center
    grabAttachPos | "forward"      | survivor attachment point to attach entity to
    entid | ""      | held entity's ID , can't be changed with **yeet_setting**

---
#### **yeet_setting**
- Change a grabbing setting

   Chat Syntax | (!,/,?)yeet_setting *setting_name value*
   ------------- | -------------

   Console Syntax | scripted_user_func *yeet_setting,setting_name,value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->3->7->5_
   ------------- | -------------
    
```cpp 
       //Overloads:
       // Check setting names with "show_yeet_settings"
       // "entid" setting cant be changed, because held entity's index is stored in this setting
       yeet_setting {setting_name} {new_value}  
       
       // Example: Change grabbing range to 400 ( pretty long arms )
       yeet_setting grabRange 400
       
       // Example: Change how far entity is gonna be held by player to 100 units
       yeet_setting grabDistMin 100
       
       // Example: Change how high below eye-level to hold the entity to -30 units ( negative values for above eye level )
       // default is 30, which means 30 units BELOW eye-level
       // -30 will make the entity held above player's head
       yeet_setting grabHeightBelowEyes -30
```
---
#### **change_grab_method**
- Change grabbing method between "Grab by aimed point" and "Grab by center"(basically hug the entity, some entity cause player to get stuck)

   Chat Syntax | (!,/,?)change_grab_method
   ------------- | -------------

   Console Syntax | scripted_user_func *change_grab_method* 
   ------------- | -------------
    
   Menu Sequence | _6->3->7->6_
   ------------- | -------------
 
---
#### **model**
- Change the model of an entity

   Chat Syntax | (!,/,?)model *target* *model_path*
   ------------- | -------------

   Console Syntax | scripted_user_func *model,target,model_path* 
   ------------- | -------------
    
   Menu Sequence | _6->9->6->1_ AND _6->9->6->2_
   ------------- | -------------
    
```cpp 
       //Overloads:
       model {target:(!self,!picker,#{ID},{Name}) } {model_path | !random}  
       
       // Example: Change your model to a TV
       model !self models/props_interiors/tv.mdl
       
       // Example: Change targeted object's model to a random model
       model !picker !random

       // Example: Change entity at index 54's model to a vending machine
       model #54 models/props/cs_office/vending_machine.mdl
```
---
#### **model_scale**
- Change the model scale of an entity, only works with a few of the models

   Chat Syntax | (!,/,?)model_scale *target* *scale*
   ------------- | -------------

   Console Syntax | scripted_user_func *model,target,scale* 
   ------------- | -------------
    
   Menu Sequence | _6->9->6->3_ AND _6->9->6->4_
   ------------- | -------------
    
```cpp 
       //Overloads:
       model_scale {target:(!self,!picker,#{ID},{Name}) } {scale}  
       
       // Example: Make yourself 2 times bigger ( if possible )
       model_scale !self 2
       
```
---
#### **disguise**
- Disguise as targeted object (change your model to it's model)

   Chat Syntax | (!,/,?)disguise
   ------------- | -------------

   Console Syntax | scripted_user_func *disguise* 
   ------------- | -------------
    
   Menu Sequence | _6->9->6->5_
   ------------- | -------------

---
#### **restore_model**
- Restore the original model of a player

   Chat Syntax | (!,/,?)restore_model *target*
   ------------- | -------------

   Console Syntax | scripted_user_func *restore_model,target* 
   ------------- | -------------
    
   Menu Sequence | _6->9->6->7_
   ------------- | -------------
```cpp
       //Overloads:
       restore_model {target:character | !picker}
       restore_model              // target = yourself
       
       //Example: Restore the model of targeted player
       restore_model !picker
       //Example: Restore the model of Bill
       restore_model bill
       //Example: Restore the model of your player
       restore_model
```
---
#### **prop_spawn_setting**
- Update default settings used for spawning props of a certain class. Check **prop_defaults.txt** for details

   Chat Syntax | (!,/,?)prop_spawn_setting *classname,setting,subsetting,newvalue*
   ------------- | -------------

   Console Syntax | scripted_user_func *prop_spawn_setting,classname,setting,subsetting,newvalue* 
   ------------- | -------------
    
   Menu Sequence | _6->9->3_
   ------------- | -------------
```cpp
       //Overloads:
       prop_spawn_setting {classname:(physics,dynamic,ragdoll,all)} {setting:(spawn_height,spawn_angles)} {AddRemoveSet:(+,-, )}{subsetting:(flags,val,min,max)} {cast:(flg,int,float,str, )}{newval}
       
       //Example: Add random value to spawn height between [-250,250] for dynamic props
       prop_spawn_setting dynamic spawn_height +flags flg|HEIGHT_ADD_RANDOM_M250_250
       
       //Example: Remove the previous random value addition to spawn height between [-250,250] for dynamic props
       prop_spawn_setting dynamic spawn_height -flags flg|HEIGHT_ADD_RANDOM_M250_250
       
       //Example: Spawn all props at eye level height
       prop_spawn_setting all spawn_height flags flg|HEIGHT_EYELEVEL
       
       //Example: Spawn dynamic props rolled over
       prop_spawn_setting dynamic spawn_angles +flags flg|ANGLE_ROLLOVER
       
       //Example: Spawn dynamic props with exact eye angles of the player, then turn it around
       prop_spawn_setting dynamic spawn_angles flags flg|ANGLE_EYES_EXACT|ANGLE_TURN_AROUND
       
       //Example: Set value to be used if needed with spawn angle to "0 -30 0", meaning a 30 degree turn to right for physics props
       prop_spawn_setting physics spawn_angles val str|0|-30|0
       
       //Example: Use the value given in the previous example as an addition to eye angles' yaw, resulting all physics props to spawn facing slighty right of the player
       prop_spawn_setting physics spawn_angles flags flg|ANGLE_EYES_YAW|ANGLE_ADD_VAL
       
       //Example: Use random angles using range [min,max], by default it is [-45,45], to get pitch yaw roll values 
       prop_spawn_setting dynamic spawn_angles flags flg|ANGLE_RANDOM_GIVEN
```
---
### Random and saved voices

#### **randomline**
- Speak a line. Last line gets saved by default, use **randomline_save_last** to change state

   Chat Syntax | (!,/,?)randomline *speaker line_source* 
   ------------- | -------------

   Console Syntax | scripted_user_func *randomline,speaker,line_source*  
   ------------- | -------------
    
   Menu Sequence | _6->4->1_ , _6->4->2_ , _6->4->3_ , _6->4->4_ , _6->4->5_ AND _6->4->6_ 
   ------------- | -------------
```cpp
       //Overloads:
       randomline {speaker: survivor | random} {line_source: line_owner | random}
       randomline {speaker: survivor | random}             // line_source = speaker
       randomline              // speaker = self , line_source = self
       
       // Example: Make Louis speak a randomline from Nick
       randomline louis nick
       
       // Example: Make Coach speak a randomline from himself
       randomline coach
```
---
#### **pitch**
- Change the pitch(talking speed) of voice line currently being spoken

   Chat Syntax | (!,/,?)pitch *speed*
   ------------- | -------------

   Console Syntax | scripted_user_func *pitch,speed*  
   ------------- | -------------
    
   Menu Sequence | _6->5->5->1, 6->5->5->2, 6->5->5->3, 6->5->5->4 AND 6->5->5->6_
   ------------- | -------------
```cpp 
       //Overloads:
       // speed: Talking speed, default is 1.0
       pitch {speed: float}
```
---
#### **randomline_save_last**
- Change state of saving the last random line spoken

   Chat Syntax | (!,/,?)randomline_save_last 
   ------------- | -------------

   Console Syntax | scripted_user_func *randomline_save_last*  
   ------------- | -------------
    
   Menu Sequence | _6->4->7->1_
   ------------- | -------------
   
---
#### **save_line**
- Save the given speaker and line path

   Chat Syntax | (!,/,?)save_line *speaker path_to_line* 
   ------------- | -------------

   Console Syntax | scripted_user_func *save_line,speaker,path_to_line* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       save_line {speaker: survivor} {line_source: path_to_line}
       
       // Example: Save the line scenes/namvet/c6dlc3openingdoor01.vcd by Bill to be spoken by Zoey
       save_line zoey scenes/namvet/c6dlc3openingdoor01.vcd
```
---
#### **display_saved_line**
- Display saved line information 

   Chat Syntax | (!,/,?)display_saved_line 
   ------------- | -------------

   Console Syntax | scripted_user_func *display_saved_line*  
   ------------- | -------------
    
   Menu Sequence | _6->4->7->2_
   ------------- | -------------
   
---
#### **speak_saved**
- Speak the saved line
   Chat Syntax | (!,/,?)speak_saved 
   ------------- | -------------

   Console Syntax | scripted_user_func *speak_saved*  
   ------------- | -------------
    
   Menu Sequence | _6->5->5_
   ------------- | -------------

---
### Particle effects

#### **particle**
- Spawn a particle. Last random particle is saved by default, use **randomparticle_save_state** to change it.

   Chat Syntax | (!,/,?)particle *particle_name* 
   ------------- | -------------

   Console Syntax | scripted_user_func *particle,particle_name*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->1_ AND _6->3->6->2_
   ------------- | -------------
```cpp 
       //Overloads:
       particle {name: particle_name | random}
```
---
#### **search_particle**
- Search particle effects with a pattern or a keyword 

   Chat Syntax | (!,/,?)search_particle *pattern limit*
   ------------- | -------------

   Console Syntax | scripted_user_func *search_particle,pattern,limit* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       search_particle {pattern} {limit}
       search_particle {pattern} // limit = 15
       
       // Example: Print 5 decal names with the word "fire" in them
       search_particle fire 5 
```
---
#### **random_particle**
- Print random particle effects with or without a pattern or a keyword 

   Chat Syntax | (!,/,?)random_particle *limit pattern*
   ------------- | -------------

   Console Syntax | scripted_user_func *random_particle,limit,pattern* 
   ------------- | -------------
    
   Menu Sequence | _6->3->6->7->5_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       random_particle {limit} {pattern}
       random_particle {limit} // pattern = no pattern
       random_particle  // limit = 1 , pattern = no pattern
       
       // Example: Print 3 random particle names
       random_particle 3 
```
---
#### **spawn_particle_saved**
- Spawn the saved particle

   Chat Syntax | (!,/,?)attach_particle *particle_name duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *attach_particle,particle_name,duration*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->3_
   ------------- | -------------
    
---
#### **attach_particle**
- Attach a particle to targeted entity. Last random particles are saved by default, use **randomparticle_save_state** to change it.

   Chat Syntax | (!,/,?)attach_particle *particle_name duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *attach_particle,particle_name,duration*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->4_ AND _6->3->6->5_
   ------------- | -------------
```cpp
       //Overloads:
       // duration: -1 for infinite duration
       attach_particle {name: particle_name | random} {duration: seconds}
       attach_particle {name: particle_name | random}    // duration = preferred_duration
```
---
#### **attach_particle_saved**
- Attach the saved particle to targeted entity

   Chat Syntax | (!,/,?)attach_particle_saved
   ------------- | -------------

   Console Syntax | scripted_user_func *attach_particle_saved*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->6_
   ------------- | -------------
---
#### **update_attachment_preference**
- Change preferred attachment duration

   Chat Syntax | (!,/,?)update_attachment_preference *duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *update_attachment_preference,duration*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->7->1_
   ------------- | -------------
```cpp 
       //Overloads:
       update_attachment_preference {duration: seconds}
```
---
#### **attach_to_targeted_position**
- Change attachment position of particles between **aimed point** and **base** of the entity

   Chat Syntax | (!,/,?)attach_to_targeted_position 
   ------------- | -------------

   Console Syntax | scripted_user_func *attach_to_targeted_position*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->7->2_
   ------------- | -------------

---
#### **randomparticle_save_state**
- Change state of saving the last randomly spawned particle

   Chat Syntax | (!,/,?)randomparticle_save_state 
   ------------- | -------------

   Console Syntax | scripted_user_func *randomparticle_save_state*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->7->3_
   ------------- | -------------

---
#### **display_saved_particle**
- Display information about saved particle

   Chat Syntax | (!,/,?)display_saved_particle
   ------------- | -------------

   Console Syntax | scripted_user_func *display_saved_particle*  
   ------------- | -------------
    
   Menu Sequence | _6->3->6->7->4_
   ------------- | -------------
---
#### **save_particle**
- Save the given particle

   Chat Syntax | (!,/,?)save_particle *particle_name duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *save_particle,particle_name,duration* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
       //Overloads:
       save_particle {name: particle_name} {duration: seconds}
       save_particle {name: particle_name} // duration = preferred_duration
```
---
### Sound scripts

#### **sound**
- Play a sound script or a file on players or objects

   Chat Syntax | (!,/,?)sound *sound target,soundname* 
   ------------- | -------------

   Console Syntax | scripted_user_func *sound,target,soundname*  
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_ 
   ------------- | -------------
```cpp
       //Overloads:
       sound {target: (object_reference) | all} {soundname: (stop,off) | sound_script_name | sound_file_name}
       
       // Example: Play HulkZombie.Breathe sound for everyone ( tank breathe )
       sound all HulkZombie.Breathe
       
       // Example: Stop last sound played for everyone
       sound all stop
```
---
#### **sound_script_info**
- Get information about a sound script

   Chat Syntax | (!,/,?)sound_script_info *script_name* 
   ------------- | -------------

   Console Syntax | scripted_user_func *sound_script_info,script_name*  
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
       //Overloads:
       sound_script_info {script_name}
``` 
---
#### **random_sound_script_name**
- Get one or more random sound script name(s) using patterns/keywords

   Chat Syntax | (!,/,?)random_sound_script_name *pattern limit* 
   ------------- | -------------

   Console Syntax | scripted_user_func *random_sound_script_name,pattern,limit*  
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
       //Overloads:
       // pattern: Regular expression or keyword to include in script name
       // limit: Maximum amount of names to return if pattern was used or "all"
       random_sound_script_name {pattern} {limit: (all) | number}
       random_sound_script_name {pattern} // limit = 10
       random_sound_script_name // pattern = completely random, limit = 1
       
       // Example: Get a random script name
       random_sound_script_name
       
       // Example: Get a random script name starting with Gambler or gambler, maximum 3
       random_sound_script_name ^[Gg]ambler 3
``` 
---
#### **search_sound_script_name**
- Get one or more sound script name(s) using patterns/keywords, works similar to **random_sound_script_name** but requires a pattern

   Chat Syntax | (!,/,?)search_sound_script_name *pattern limit* 
   ------------- | -------------

   Console Syntax | scripted_user_func *search_sound_script_name,pattern,limit*  
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
       //Overloads:
       // pattern: Regular expression or keyword to include in script name
       // limit: Maximum amount of names to return if pattern was used or "all"
       search_sound_script_name {pattern} {limit: (all) | number}
       search_sound_script_name {pattern} // limit = 25
       search_sound_script_name // pattern = completely random, limit = 1
       
       // Example: Get all script names including the word MissionStart
       search_sound_script_name MissionStart all
       
       // Example: Get 2 script names of starting with Wood_Box
       search_sound_script_name ^Wood_Box 2
``` 
---
#### **find_sound_in_scripts**
- Get one or more sound script name(s) searching over **sound file names** inside scripts

   Chat Syntax | (!,/,?)find_sound_in_scripts *file limit pattern* 
   ------------- | -------------

   Console Syntax | scripted_user_func *find_sound_in_scripts,file,limit,pattern*  
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp 
       //Overloads:
       // file: Keyword to include in sound file names or the full file name
       // limit: Maximum amount of names to return if pattern was used or "all"
       // pattern: Regular expression or keyword to include in script name
       find_sound_in_scripts {file: file_name | keyword_in_file} {limit: (all) | number} {pattern} 
       find_sound_in_scripts {file: file_name | keyword_in_file} {limit: (all) | number} // pattern = any word
       find_sound_in_scripts {file: file_name | keyword_in_file} // pattern = any word, limit = 10
       
       // Example: Get all script names which has a sound file with "_punch" word in it
       find_sound_in_scripts _punch all
       
       // Example: Get all script names of Ellis which has a sound file with "Hurrah" or "hurrah" word in it
       find_sound_in_scripts Hurrah all ^[Mm]echanic
``` 
---
### Custom sequences

#### **speak_test**
- Speak given line for given time

   Chat Syntax | (!,/,?)speak_test *speaker line duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *speak_test,speaker,line,duration* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       speak_test {speaker: character} {line: name_or_path} {duration: seconds}
       speak_test {speaker: character} {line: name_or_path} // duration = line_length
```
---
#### **create_seq**
- Create and save a sequence of lines with given delays

   Chat Syntax | (!,/,?)create_seq *speaker sequence_name line_1 delay_1 line_2 delay_2...*
   ------------- | -------------

   Console Syntax | scripted_user_func *create_seq,speaker,sequence_name,line_1,delay_1,line_2,delay_2...* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // speaker is the character name to speak the sequence when called
       // name is the custom name for the sequence
       // line_{x} are the line names/paths to be used after delay_{x} seconds
       // lines and their delays HAVE TO be given in pairs

       create_seq {speaker} {name} {line_1} {delay_1} {line_2} {delay_2} ...(>2)
       
       // Note: speaker is decided while creating a sequence, but a speaker can speak lines from different people
       
       // Example: Create a custom sequence named "shootboy1" for coach to say "My name is Coach, and I know how to shoot a- Boooy!" with
       // nameellis07: "Booooooy!"
       // worldc1m1b122: "My name is Coach, and I know how to shoot a gun" : 2.85 seconds cuts the "gun" part 
       // We want to hear just the 2.85 seconds of worldc1m1b122, so we add the delay to the line AFTER worldc1m1b122
       create_seq coach shootboy1 worldc1m1b122 0 nameellis07 2.85
       
       // Being more specific with line paths helps making survivors talk other's lines
       // For example following "shootboy2" sequence will be spoken by Louis if Coach is not present
       create_seq coach shootboy2 scenes/coach/worldc1m1b122 0 scenes/coach/nameellis07 2.85
       
       // Example: Create a custom sequence named "yo" for francis to say a line "Yo" from ellis with
       // taunt07: "Yo, who is your daddy!"
       // blank: This is a blank sound file, can be used to cut the previously talked line!
       // We want to hear just the "Yo" part, so 0.5 second delay for "blank" is good enough
       create_seq francis yo scenes/mechanic/taunt07 0 blank 0.5
       
       // Example: Create a custom sequence named "gothit1" for every character to say 
       //    their own friendlyfire02 and 2 seconds after friendlyfire03 line
       create_seq all gothit1 friendlyfire02 0 friendlyfire03 2
       
```
---
#### **speak_custom**
- Execute a saved custom sequence

   Chat Syntax | (!,/,?)speak_custom *speaker sequence*
   ------------- | -------------

   Console Syntax | scripted_user_func *speak_custom,speaker,sequence* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       speak_custom {speaker: character} {sequence}
       
       // Example: Speak the custom sequence of coach named "shootboy2" from the previous examples
       speak_custom coach shootboy2
```
---
#### **delete_seq**
- Delete a saved custom sequence

   Chat Syntax | (!,/,?)delete_seq *speaker sequence*
   ------------- | -------------

   Console Syntax | scripted_user_func *delete_seq,speaker,sequence* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       delete_seq {speaker: character} {sequence}
       
       // Example: Delete the sequence "shootboy1" from coach
       delete_seq coach shootboy1
```
---
#### **show_custom_sequences**
- Print out the saved custom sequences to console

   Chat Syntax | (!,/,?)show_custom_sequences *speaker*
   ------------- | -------------

   Console Syntax | scripted_user_func *show_custom_sequences,speaker* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       show_custom_sequences {speaker: character}
       show_custom_sequences  // speaker = all_characters
```
---
#### **loop**
- Start a loop of sequences and lines (">" is needed before sequence names)
   Chat Syntax | (!,/,?)loop *character sequence_or_line loop_length*
   ------------- | -------------

   Console Syntax | scripted_user_func *loop,character,sequence_or_line,loop_length* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
        //Overloads:
        loop {character} {line:name/path} {loop_length:seconds}
        loop {character} >{sequence:name} {loop_length:seconds}  // Add > before sequence name !
        
        // Example: Loop line "ledgehangfall03" for nick repeating every second
        loop nick ledgehangfall03 1
        
        // Example: Loop custom sequence named "yo" for francis repeating every 0.7 seconds
        loop francis >yo 0.7
```
---
#### **loop_stop**
- Stop looping for given character

   Chat Syntax | (!,/,?)loop_stop *character*
   ------------- | -------------

   Console Syntax | scripted_user_func *loop_stop,character* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       loop_stop {character}
       loop_stop    // character = self
       
       // Example: Stop nick's looping
       loop_stop nick
```
---
#### **seq_info**
- Get scene and delay info about a custom sequence
   Chat Syntax | (!,/,?)seq_info *character sequence*
   ------------- | -------------

   Console Syntax | scripted_user_func *seq_info,character,sequence* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       seq_info {character} {sequence}
```
---
#### **seq_edit**
- Edit custom sequences ( ">" is needed if indices are used !)
   Chat Syntax | (!,/,?)seq_edit *character sequence scene_or_index setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *seq_edit,character,sequence,scene_or_index,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       seq_edit {character} {sequence} {scene} {setting: (scene> , delay>)}{new_value}
       seq_edit {character} {sequence} >{scene_index} {setting: (scene> , delay>)}{new_value}
       
       //Example: Change first scene's name to hurrah01 in test_seq sequence for Nick
       seq_edit Nick test_seq >0 scene>hurrah01

       //Example: Change delay of first occurence of line warnboomer02 in mySeq to 3 seconds for Louis
       seq_edit Louis mySeq warnboomer02 delay>3
```
---
### Apocalypse event

#### **start_the_apocalypse**
- Uh oh

   Chat Syntax | (!,/,?)start_the_apocalypse
   ------------- | -------------

   Console Syntax | scripted_user_func *start_the_apocalypse* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->1->1_
   ------------- | -------------

---
#### **pause_the_apocalypse**
- Let the world have a break from the madness

   Chat Syntax | (!,/,?)pause_the_apocalypse
   ------------- | -------------

   Console Syntax | scripted_user_func *pause_the_apocalypse* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->1->1_
   ------------- | -------------

---
#### **show_apocalypse_settings**
-  Show apocalypse event's settings and values. Probabilities normalized: (0 = 0% , 1 = 100%)

   Chat Syntax | (!,/,?)show_apocalypse_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_apocalypse_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->1->2_
   ------------- | -------------

    Setting | Default Value | Description
    ------------ | ------------- | -------------
    maxradius | 850      | maximum radius to apply forces
    updatedelay | 1.5    | how often to update entity list in seconds
    mindelay | 0.5       | minimum delay to apply effects if entity is chosen
    maxdelay | 2         | maximum delay to apply effects if entity is chosen
    minspeed | 800       | minimum speed of pushed entities
    maxspeed | 24000     | maximum speed of pushed entities
    dmgmin | 5           | minimum damage done to entity
    dmgmax | 100         | maximum damage done to entity
    dmgprob | 0.3        | probability of entity getting damaged
    expmaxradius | 300   | explosion radius maximum
    expdmgmin | 5        | explosion damage minimum
    expdmgmax | 40       | explosion damage maximum
    expprob | 0.015      | probability of explosion 
    breakprob | 0.04     | probability of entity being broken
    doorlockprob | 0.02  | probability of doors getting locked, saferoom doors excluded
    ropebreakprob | 0.05 | probability of a cable or sorts to be broken from its connection point
    entprob | 0.6        | probability of an entity being chosen within the "maxradius" around a randomly chosen survivor
    debug | 0            | Print which entities are effected (0 = off , 1 = on) 

--- 
#### **apocalypse_setting**
- Change apocalypse event settings, updates **apocalypse_settings.txt** file

   Chat Syntax | (!,/,?)apocalypse_setting *setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *apocalypse_setting,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->9->9->1->3_
   ------------- | -------------

```cpp
       //Overloads:
       // Check out the settings and their values with show_apocalypse_settings
       apocalypse_setting {setting} {new_value: float/integer}
       
       // Example: Change the delay between each entity list update to 3 seconds
       // This delay means how often a list of props around players are taken to apply probabilistic effects afterwards
       // Default is 1.5 seconds
       apocalypse_setting updatedelay 3
```
---
### Ghost zombies event

#### **start_ghost_zombies**
- Zombies AS ghosts ?!

   Chat Syntax | (!,/,?)start_ghost_zombies
   ------------- | -------------

   Console Syntax | scripted_user_func *start_ghost_zombies* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->3->1_
   ------------- | -------------

---
#### **pause_ghost_zombies**
- Get rid of the ghosts

   Chat Syntax | (!,/,?)pause_ghost_zombies
   ------------- | -------------

   Console Syntax | scripted_user_func *pause_ghost_zombies* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->3->1_
   ------------- | -------------

---
#### **show_ghost_zombies_settings**
-  Show ghost zombies event's settings and values. Probabilities normalized: (0 = 0% , 1 = 100%)

   Chat Syntax | (!,/,?)show_ghost_zombies_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_ghost_zombies_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->3->2_
   ------------- | -------------

    Setting | Default Value | Description
    ------------ | ------------- | ------------- 
    min_alpha | 40    | Minimum alpha value
    max_alpha | 80      | Maximum alpha value
    timer_delay | 1       | Interval length in seconds to try ghostifying zombies
    ghost_prob | 0.75         | Probability of zombie turning into ghost, tested every timer_delay seconds
    stay_ghost_after | 0       | 1: Keep the ghost effect after the event is turned off, 0: Remove the ghost effect when even turns off
    render_effect | 1     | Ghost effect, integer in the interval [0,24], check flags with !flag_lookup RENDERFX_
    zombie_pick_type | 3       | 3: Ghostify common and special infected zombies, 2: Special infected only, 1: Common zombies only 

--- 
#### **ghost_zombies_setting**
- Change ghost zombies event settings, updates **ghost_zombies_settings.txt** file

   Chat Syntax | (!,/,?)ghost_zombies_setting *setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *ghost_zombies_setting,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->9->9->3->3_
   ------------- | -------------

```cpp
       //Overloads:
       // Check out the settings and their values with show_ghost_zombies_settings
       ghost_zombies_setting {setting} {new_value: float/integer}
       
       // Example: Change the zombie pick type to special infected only
       ghost_zombies_setting zombie_pick_type 2
       
       // Example(Script auth only): Change ghost effect to RENDERFX_PULSE_FAST
       // Using $[RENDERFX_PULSE_FAST] is same as using 2
       ghost_zombies_setting zombie_pick_type $[RENDERFX_PULSE_FAST]
```
---
### Meteor Shower event

#### **start_the_shower**
- Not the greatest shower you'll have

   Chat Syntax | (!,/,?)start_the_shower
   ------------- | -------------

   Console Syntax | scripted_user_func *start_the_shower* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->2->1_
   ------------- | -------------

---
#### **pause_the_shower**
- Take a break

   Chat Syntax | (!,/,?)pause_the_shower
   ------------- | -------------

   Console Syntax | scripted_user_func *pause_the_shower* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->2->1_
   ------------- | -------------

---
#### **show_meteor_shower_settings**
- Show meteor shower event's settings and values. Probabilities normalized: (0 = 0% , 1 = 100%)

   Chat Syntax | (!,/,?)show_meteor_shower_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_meteor_shower_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->2->2_
   ------------- | -------------

    Setting | Default Value | Description
    ------------ | ------------- | -------------
    maxradius | 900		     | maximum radius to pick a random meteor attack point
    minspawnheight | 550		| minimum spawn height for meteors
    updatedelay | 2				| how often to create a meteor
    mindelay | 0.5				| minimum extra delay to apply each spawn tick
    maxdelay | 1  				| maximum extra delay to apply each spawn tick
    maxexplosiondelay | 10		| maximum lifetime for a meteor, if meteor is still valid after this delay, it explodes
    minspeed | 1500				| minimum meteor speed
    maxspeed | 7000    			| maximum speed
    expmaxradius | 300			| maximum explosion radius caused by the meteor
    expdmgmin | 3			 | minimum explosion damage caused to closeby entities
    expdmgmax | 20				| maximum explosion damage caused to closeby entities
    expprob | 0.9				| probability of the meteor exploding
    scatterprob | 0.55			| probability of the meteor scattering into smaller pieces after hitting the ground
    minscatterchunk | 4			| minimum amount of smaller chunks created if scattering probably was met
    maxscatterchunk | 15		| maximum amount of smaller chunks created
    meteormodelspecific | "models/props_interiors/tv.mdl"	| specific model for meteors
    meteormodelpick | 0			| enumerated: RANDOM_ROCK = 0, RANDOM_CUSTOM = 1, FIRST_CUSTOM = 2, LAST_CUSTOM = 3, SPECIFIC = 4
    debug | 0					| Print meteor spawn and hit points, explosions, scatters and breaks

--- 
#### **meteor_shower_setting**
- Change apocalypse event settings, updates **meteor_shower_settings.txt** file

   Chat Syntax | (!,/,?)meteor_shower_setting *setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *meteor_shower_setting,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->9->9->2->3_
   ------------- | -------------

```cpp
       //Overloads:
       // Check out the settings and their values with show_meteor_shower_settings
       meteor_shower_setting {setting} {new_value: float/integer}
       
       // Example: Change "specific" meteor model to TV model and then change meteor model picking method to "specific"
       // Model paths are required to be given in quotes ("") when using chat
       meteor_shower_setting meteormodelspecific "models/props_interiors/tv.mdl"
       meteor_shower_setting meteormodelpick 4
```
---
### Freezing Objects

#### **stop_time**
- Freezes all currently spawned zombies and objects in time

   Chat Syntax | (!,/,?)stop_time *target_type*
   ------------- | -------------

   Console Syntax | scripted_user_func *stop_time,target_type* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->1 AND 6->3->9->1->9_
   ------------- | -------------

```cpp
       //Overloads: 
       stop_time {target_type:(all,common,special,physics, )}
       stop_time          // target_type: aimed object
       
       // Example: Freeze common infected, special infected and physics objects
       stop_time all
       
       // Example: Freeze object aimed at
       stop_time
```
---
#### **resume_time**
- Resumes time for objects

   Chat Syntax | (!,/,?)resume_time *target_type*
   ------------- | -------------

   Console Syntax | scripted_user_func *resume_time,target_type* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->1 AND 6->3->9->1->9_
   ------------- | -------------

```cpp
       //Overloads: 
       resume_time {target_type:(all,common,special,physics, )}
       resume_time          // target_type: aimed object
       
       // Example: Unfreeze frozen special infected
       resume_time special
       
       // Example: Unfreeze object aimed at
       resume_time
```
---
### Piano

#### **piano_keys**
- Place 25 piano keys starting at looked location placing them to the right

   Chat Syntax | (!,/,?)piano_keys
   ------------- | -------------

   Console Syntax | scripted_user_func *piano_keys* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->6->1_
   ------------- | -------------

---
#### **remove_piano_keys**
- Removes all piano key spawns

   Chat Syntax | (!,/,?)remove_piano_keys
   ------------- | -------------

   Console Syntax | scripted_user_func *remove_piano_keys* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->6->2_
   ------------- | -------------
---
### Microphones and speakers

#### **microphone**
- Create an entity to be used as microphone, check console for its index and name 

   Chat Syntax | (!,/,?)microphone *effect hearing_range speaker_to_connect*
   ------------- | -------------

   Console Syntax | scripted_user_func *microphone,effect,hearing_range,speaker_to_connect* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->4->1_
   ------------- | -------------
```cpp
       //Overloads:
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} {hearing_range} {connected_speaker}
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} {hearing_range} // speaker can be connected later
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} // hearing_range = 120
       microphone         // effect = standard, hearing_range = 120
    
```
---
#### **speaker**
- Creates an entity to be used as a speaker, check console for its index and name

   Chat Syntax | (!,/,?)speaker
   ------------- | -------------

   Console Syntax | scripted_user_func *speaker* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->4->2_
   ------------- | -------------
---
#### **display_mics_speakers**
- Get index,name and distance information about spawned mics and speakers

   Chat Syntax | (!,/,?)display_mics_speakers
   ------------- | -------------

   Console Syntax | scripted_user_func *display_mics_speakers* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->4->3_
   ------------- | -------------

---
#### **speaker2mic**
- Connect a speaker to a microphone ( "#" is needed before indices !)

   Chat Syntax | (!,/,?)speaker2mic *speaker_ID_OR_NAME microphone_ID_OR_NAME*
   ------------- | -------------

   Console Syntax | scripted_user_func *speaker2mic,speaker_ID_OR_NAME,microphone_ID_OR_NAME* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->9->9->4->4_
   ------------- | -------------
```cpp
       //Overloads:
       // These ID's and names can be found from the console summary or with display_mics_speakers command
       // ID's need to be specified with a # before the number
       speaker2mic #{speakerID} #{micID}
       speaker2mic {speaker_name} {mic_name} 
     
       // Example: Connect speaker at index 33 to microphone named "myMic"
       speaker2mic #33 myMic
```
---
### Explosions

#### **explosion**
- Create a delayed explosion or a meteor strike at aimed location, with a particle effect until explosion

   Chat Syntax | (!,/,?)explosion _option_
   ------------- | -------------

   Console Syntax | scripted_user_func *explosion,option* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->5->1 AND 6->9->9->5->2_
   ------------- | -------------

```cpp
       //Overloads:
       // If option is "meteor" a delayed meteor strike is called
       explosion {option:(meteor)} 
       explosion   // Creates a normal delayed explosion
       
       // Example: Create a delayed meteor strike at aimed location
       explosion meteor
```
---
#### **show_explosion_settings**
- Show current *explosion* command settings in console

   Chat Syntax | (!,/,?)show_explosion_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_explosion_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->5->3_
   ------------- | -------------

    Setting | Default Value | Description
    ------------ | ------------- | -------------
    delay | 1 | delay for explosion in seconds
    effect_name | "flame_blue" | [particle effect name](https://developer.valvesoftware.com/wiki/Talk:List_of_L4D2_Particles) to spawn until explosion. **"no_effect"** to disable particle effects 
    radiusmin | 300 | explosion's minimum radius to damage and push entities in
    radiusmax | 450 | explosion's maximum radius to damage and push entities in
    dmgmin | 10 | minimum damage to give entities in the radius
    dmgmax | 30 | maximum damage to give entities in the radius
    minpushspeed | 2500 | minimum speed an explosion can push an entity away 
    maxpushspeed | 10000 | maximum speed an explosion can push an entity away 

---
#### **explosion_setting**
- Update *explosion* command settings

   Chat Syntax | (!,/,?)explosion_setting *setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *explosion_setting,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->9->9->5->5_
   ------------- | -------------

```cpp
       //Overloads:
       // Check out the settings and their values with show_explosion_settings
       explosion_setting {setting} {new_value}
       
       // Example: Change delay from 1s to 5s
       explosion_setting delay 5
```
---
### Ragdoll

#### **go_ragdoll**
- Start ragdolling with controls, hold **mouse1** to ascend, **mouse2** to descend. 

   Chat Syntax | (!,/,?)go_ragdoll
   ------------- | -------------

   Console Syntax | scripted_user_func *go_ragdoll* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->2->1_
   ------------- | -------------

---
#### **recover_ragdoll**
- Recover your ragdoll 

   Chat Syntax | (!,/,?)recover_ragdoll
   ------------- | -------------

   Console Syntax | scripted_user_func *recover_ragdoll* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->2->2_
   ------------- | -------------

---
### Driving

#### **start_driving**
- Start driving a built-in vehicle, a custom vehicle or a prop with the given model. Movement: WASD; Aim forward: MOUSE2; N2O: SHIFT; BOUNCE: SPACE

   Chat Syntax | (!,/,?)start_driving *vehicle_type*
   ------------- | -------------

   Console Syntax | scripted_user_func *start_driving,vehicle_type* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->\[3,4,5,6\]_
   ------------- | -------------
  
```cpp
       //Overloads:
       //  vehicle_type: You can use model path names instead of this; if possible it will spawn a prop with the model
       start_driving {vehicle_type:(sedan1,sedan2,sedan3,hatchback, )}
       start_driving   // vehicle_type = sedan1
       
       // Example: Start driving the built-in vehicle type sedan2
       start_driving sedan2
       
       // Example: Start driving a bathtub!
       start_driving props_furniture/bathtub1
```
---
#### **stop_driving**
- Stop driving your current car

   Chat Syntax | (!,/,?)stop_driving
   ------------- | -------------

   Console Syntax | scripted_user_func *stop_driving* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->2_
   ------------- | -------------

---
#### **make_driveable**
- Try and make aimed object driveable. 

   Chat Syntax | (!,/,?)make_driveable
   ------------- | -------------

   Console Syntax | scripted_user_func *make_driveable* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->7_
   ------------- | -------------

---
#### **change_seat_position**
- Change your seat position while driving

   Chat Syntax | (!,/,?)change_seat_position *axis,units*
   ------------- | -------------

   Console Syntax | scripted_user_func *change_seat_position,axis,units* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->8->\[2,3,4,5,6,7\]_
   ------------- | -------------
  
```cpp
       //Overloads:
       change_seat_position {axis:(x,y,z)} {units:inches}
       
       // Example: Move your seat 10 inches down
       change_seat_position z -10
```  
---
#### **set_default_seat_position**
- Change the default driver seat location of currently driven vehicle to your current seat position

   Chat Syntax | (!,/,?)set_default_seat_position
   ------------- | -------------

   Console Syntax | scripted_user_func *set_default_seat_position* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->8->8_
   ------------- | -------------
   
---
#### **change_drive_direction**
- Change the driving direction of currently driven vehicle type. This helps with models with weird angles

   Chat Syntax | (!,/,?)change_drive_direction *direction*
   ------------- | -------------

   Console Syntax | scripted_user_func *change_drive_direction,direction* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1->8->1->\[1,2,3,4\]_
   ------------- | -------------

```cpp
       //Overloads:
       change_drive_direction {direction:(straight,reversed,left,right)}
       
       // Example: Make the "left face" of the vehicle "forward" direction
       change_drive_direction left
```    
---
#### **get_in**
- Get into the aimed vehicle as a passenger if possible. 

   Chat Syntax | (!,/,?)get_in
   ------------- | -------------

   Console Syntax | scripted_user_func *get_in* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->2->1_
   ------------- | -------------
 
---
#### **get_out**
- Get out of the current vehicle you are a passenger of.

   Chat Syntax | (!,/,?)get_out
   ------------- | -------------

   Console Syntax | scripted_user_func *get_out* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->2->2_
   ------------- | -------------
                   
---
#### **change_passenger_seat_position**
- Change your seat position as a passenger

   Chat Syntax | (!,/,?)change_passenger_seat_position *axis,units*
   ------------- | -------------

   Console Syntax | scripted_user_func *change_passenger_seat_position,axis,units* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->2->\[3,4,5,6,7,8\]_
   ------------- | -------------
  
```cpp
       //Overloads:
       change_passenger_seat_position {axis:(x,y,z)} {units:inches}
       
       // Example: Move your seat 20 inches right
       change_passenger_seat_position y -20
```  
---
#### **reload_vehicles**
- Reload vehicle table files from *admin system/vehicles/* directory

   Chat Syntax | (!,/,?)reload_vehicles
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_vehicles* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
   
---
### Texture Commands

#### **decal**
- Place a decal(texture) at aimed point

   Chat Syntax | (!,/,?)decal *decal_path*
   ------------- | -------------

   Console Syntax | scripted_user_func *decal,decal_path* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->2->1 AND 6->3->9->2->2_
   ------------- | -------------

```cpp
       //Overloads:
       decal {decal_path: ({path_name} | random }
       decal   // decal_path = random
       
       // Example: Place a random decal at aimed point
       decal 
       
       // Example: Place a decal named "Decals/bloodstain_002"
       decal Decals/bloodstain_002
```
---
#### **search_decal**
- Search decal names with a pattern or a keyword 

   Chat Syntax | (!,/,?)search_decal *pattern limit*
   ------------- | -------------

   Console Syntax | scripted_user_func *search_decal,pattern,limit* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       search_decal {pattern} {limit}
       search_decal {pattern} // limit = 15
       
       // Example: Print 5 decal names with the word "blood" in them
       search_decal blood 5 
```
---
#### **random_decal**
- Print random decal names with or without a pattern or a keyword 

   Chat Syntax | (!,/,?)random_decal *limit pattern*
   ------------- | -------------

   Console Syntax | scripted_user_func *random_decal,limit,pattern* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->2->3_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       random_decal {limit} {pattern}
       random_decal {limit} // pattern = no pattern
       random_decal  // limit = 1 , pattern = no pattern
       
       // Example: Print maximum 5 decal names which has the words "Shell" or "shell" in them
       random_decal 5 [Ss]hell 
```
---
### Animation Commands

#### **set_animation**
- Start a animation or a sequence on the aimed object or the given target 

   Chat Syntax | (!,/,?)set_animation *sequence_name_or_id targetname*
   ------------- | -------------

   Console Syntax | scripted_user_func *set_animation,sequence_name_or_id,targetname* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->3->1_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       // {sequence_name_or_id}: If given value wasn't a valid sequence name, value is assumed to be a sequence index. If both fail, execution stops
       set_animation {sequence_name_or_id: ({sequence_id} | {sequence_name} | !random } {targetname}
       set_animation {sequence_name_or_id} // targetname = !picker
       set_animation   // sequence_name_or_id = !random, targetname = !picker
       
       // Example: Start a random sequence on aimed object
       set_animation 
       
       // Example: Start the sequence 24 of aimed object
       set_animation 24
       
       // Example: Start the sequence named "crouchwalk_rifle" on #42
       set_animation crouchwalk_rifle #42
```
---
#### **search_animation**
- Search animation names of aimed object or given target with a pattern or a keyword 

   Chat Syntax | (!,/,?)search_animation *pattern limit targetname*
   ------------- | -------------

   Console Syntax | scripted_user_func *search_animation,pattern,limit,targetname* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       search_animation {pattern} {limit} {targetname: (#{ID} | {targetname} | !picker }
       search_animation {pattern} {limit}   // targetname = !picker 
       search_animation {pattern} // limit = 15 , targetname = !picker 
       
       // Example: Print all sequence names of aimed object with the word "walk" in them
       search_animation walk all 
```
---
#### **random_animation**
- Print random animation names of aimed object or given target with or without a pattern or a keyword 

   Chat Syntax | (!,/,?)random_animation *limit pattern targetname*
   ------------- | -------------

   Console Syntax | scripted_user_func *random_animation,limit,pattern,targetname* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads:
       // {pattern}: Regular expression or keyword
       random_animation {limit} {pattern} {targetname: (#{ID} | {targetname} | !picker }
       random_animation {limit} {pattern}   // targetname = !picker 
       random_animation {limit} // pattern = no pattern , targetname = !picker 
       random_animation  // limit = 1 , pattern = no pattern , targetname = !picker 
       
       // Example: Print maximum 4 sequence names of #66 which has the words "heal" or "Heal" in them
       random_animation 4 [Hh]eal #66 
```
---
### Looting Commands

#### **create_loot_sources**
- Make props lootable, dropping items when they are used

   Chat Syntax | (!,/,?)create_loot_sources *category*
   ------------- | -------------

   Console Syntax | scripted_user_func *create_loot_sources,category* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->4_
   ------------- | -------------
```cpp
       //Overloads:
       // category: cars = All vehicles
       //           boxes = All box-like props
       //           all = All vehicles and box-like props
       //           !picker = Aimed object. Players, zombies, doors, weapons and some other props are not permitted
       create_loot_sources {category: (cars, boxes, all, !picker)}
       create_loot_sources   //  category = all
       
       //Example: Make cars lootable
       create_loot_sources cars

       //Example: Make cars and boxes/cans lootable
       create_loot_sources

       //Example: Make aimed object lootable
       create_loot_sources !picker
```
---
#### **show_looting_settings**
- Show current *create_loot_sources* command settings in console

   Chat Syntax | (!,/,?)show_looting_settings
   ------------- | -------------

   Console Syntax | scripted_user_func *show_looting_settings* 
   ------------- | -------------
    
   Menu Sequence | _6->3->9->4->5_
   ------------- | -------------

    Setting | Default Value | Description
    ------------ | ------------- | -------------
    LootDuration | 2.5 | How long it should take to loot a prop in seconds
    NoItemProb | 0.35 | Probability of the prop having no loot, 0 = 0% , 1 = 100%
    MinItems | 1 | Minimum amount of items to drop when the prop is looted
    MaxItems | 2 | Maximum amount of items to drop when the prop is looted
    BarText | "Lootable Prop" | Big text to display for the looting bar
    BarSubText | "There might be something valuable in here!" | Sub text to display for the looting bar
    GlowRange | 180 | Range to start glowing for players
    GlowR | 255 | Red value of glowing color of lootable props
    GlowG | 80 | Green value of glowing color of lootable props
    GlowB | 255 | Blue value of glowing color of lootable props
    GlowA | 255 | Alpha value of glowing color of lootable props
    events_enabled | true | true: Enable random events upon looting, false: no random events
    hurt_prob | 0.1 | Probability of getting hurt once or several times
    ambush_prob | 0.05 | Probability of a special zombie ambush
    explosion_prob | 0.05 | Probability of explosion
    horde_prob | 0.07 | Probability of calling a horde

---
#### **looting_setting**
- Update *create_loot_sources* command settings

   Chat Syntax | (!,/,?)looting_setting *setting new_value*
   ------------- | -------------

   Console Syntax | scripted_user_func *looting_setting,setting,new_value* 
   ------------- | -------------
    
   Menu Sequence | _Command hinted at 6->3->9->4->6_
   ------------- | -------------

```cpp
       //Overloads:
       // Check out the settings and their values with show_looting_settings
       looting_setting {setting} {new_value}
       
       // Example: Change maximum amount of drops from looting from 2 to 4
       looting_setting MaxItems 4
```
---
#### **reload_loots**
- Reload loot tables from **admin system/loot_tables.txt**

   Chat Syntax | (!,/,?)reload_loots
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_loots*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
   
---
### Experimental Commands

#### **wear_hat**
- _Wear_ aimed object like a hat

   Chat Syntax | (!,/,?)wear_hat extra_height
   ------------- | -------------

   Console Syntax | scripted_user_func *wear_hat,extra_height* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->1->1_
   ------------- | -------------

```cpp
       //Overloads:
       wear_hat {extra_height}
       wear_hat     // Default height is eye-level
       
       //Example: Wear aimed object like a hat, 10 units above eye-level
       wear_hat 10
```
---
#### **take_off_hat**
- Take off currently worn hat and drop it at aimed point

   Chat Syntax | (!,/,?)take_off_hat
   ------------- | -------------

   Console Syntax | scripted_user_func *take_off_hat* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->1->2_
   ------------- | -------------

---
#### **hat_position**
- Change hat position to given attachment point name

   Chat Syntax | (!,/,?)hat_position *attachment_point*
   ------------- | -------------

   Console Syntax | scripted_user_func *hat_position,attachment_point*
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->1->3 , 6->9->9->9->1->4 AND 6->9->9->9->1->5_
   ------------- | -------------

```cpp
       //Overloads
       hat_position {attachment_point:(eyes, mouth, survivor_neck, ...)}
```
---
#### **point_light**
- Create a point light source pointing at objects at the moment of spawning

   Chat Syntax | (!,/,?)point_light *light_color light_fov extra_height*
   ------------- | -------------

   Console Syntax | scripted_user_func *point_light,light_color,light_fov,extra_height*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads
       point_light {light_color: ( red,green,blue,yellow,cyan,magenta,pink,purple,white | random | {red}|{green}|{blue} )} {light_fov: degrees_between_0_180 | random} {extra_height}
       point_light {light_color} {light_fov}  // extra_height = 0
       point_light {light_color}  // light_fov = 90.0 , extra_height = 0
       point_light   // light_color = random , light_fov = 90.0 , extra_height = 0
       
       // Example: Create a pink light with fov of 120
       point_light pink 120
       
       // Example: Create a light with rgb : (200,80,150) , random fov, spawn it 10 inches above aimed point
       point_light 200|80|150 random 10
```
---
#### **point_light_follow**
- Create a point light source pointing at objects all times.

   Chat Syntax | (!,/,?)point_light_follow *light_color target light_fov extra_height*
   ------------- | -------------

   Console Syntax | scripted_user_func *point_light_follow,light_color,target,light_fov,extra_height*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads
       // {light_color} {light_fov} {extra_height} works same as point_light
       point_light_follow {light_color} {target: (#{ID} | {targetname} | self)} {light_fov} {extra_height}
       point_light_follow {light_color} {target} {light_fov}  // extra_height = 0
       point_light_follow {light_color}  // target = self , light_fov = 90.0 , extra_height = 0
       point_light_follow   // light_color = random , target = self , light_fov = 90.0 , extra_height = 0
       
       // Example: Create a red light pointing at you from the aimed point
       point_light_follow red
       
       // Example: Create a light with rgb : (30,150,170) , 50 degrees fov, aiming at #555 spawn it 5 inches above aimed point
       point_light_follow 30|150|170 #555 50 5
```
---
#### **spawn_point_light**
- Create a point light source pointing at objects using console variables. Works similar to **point_light** when used with no arguments, **point_light_follow** if a target is given.

   Chat Syntax | (!,/,?)spawn_point_light *target*
   ------------- | -------------

   Console Syntax | scripted_user_func *spawn_point_light,target*
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->7->1->variable->1, 6->9->9->9->7->1->variable->2 AND 6->9->9->9->7->1->variable->3_
   ------------- | -------------

```cpp
       //Overloads
       // {light_color} is taken from console variable:  ps_preferred_light_color (if not defined: random)
       // {light_fov} is taken from console variable:  ps_preferred_light_fov (if not defined: 90.0)
       // {extra_height} is taken from console variable: ps_preferred_light_raise (if not defined: 0)
       spawn_point_light {target: (#{ID} | {targetname} | !self | !picker)}
       spawn_point_light   // target = no target(only aims at you at spawn)
       
       // Example: Create a point light using current console variables
       spawn_point_light
       
       // Example: Create a point light using current console variables, pointing at you all times
       spawn_point_light !self
       
       // Example: Create a point light using current console variables, pointing at aimed object all times
       spawn_point_light !picker
```
---
#### **remove_lights**
- Remove certain spawned point light sources.

   Chat Syntax | (!,/,?)remove_lights *target*
   ------------- | -------------

   Console Syntax | scripted_user_func *remove_lights,target*
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->7->1->variable->4_
   ------------- | -------------

```cpp
       //Overloads
       remove_lights {target: (#{ID} | {targetname} | !self | !picker | all)}
       remove_lights  // target = all
       
       // Example: Remove all lights aiming at you
       remove_lights !self
```
---
### Other

#### **give_physics**
- Enable physics on object(s) around a radius or of which aimed at

   Chat Syntax | (!,/,?)give_physics *radius*
   ------------- | -------------

   Console Syntax | scripted_user_func *give_physics,radius*
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->4_
   ------------- | -------------

```cpp
       //Overloads
       give_physics {radius:positive_number|!picker|all}
       give_physics     // radius = 150 units
       
       // Example (give physics to aimed object (if possible))
       give_physics !picker
       
       // Example (give physics to objects within 500 units around aimed point)
       give_physics 500
       
       // Example (give physics to all the objects in the map)
       give_physics all
```
---
#### **zero_g**
- Disable gravitational forces on objects

   Chat Syntax | (!,/,?)zero_g *targets*
   ------------- | -------------

   Console Syntax | scripted_user_func *zero_g,targets*
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->5_
   ------------- | -------------

```cpp
       //Overloads
       zero_g {targets:all|!picker}
       zero_g     // targets = !picker (aimed object)
       
       // Example: Make all physics objects have zero gravity
       zero_g all
       
```
---
#### **invisible_walls**
- Enable/Disable **most if not all** of the invisible walls around. Some of them can not be disabled.

   Chat Syntax | (!,/,?)invisible_walls *state apply_to_all*
   ------------- | -------------

   Console Syntax | scripted_user_func *invisible_walls,state,apply_to_all* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->6_
   ------------- | -------------
```cpp
       //Overloads:
       invisible_walls {state: (disable, enable)} {apply_to_all_possible_walls}
       
       //Example: Try disabling all invisible walls/clips
       invisible_walls disable all
```
---
#### **ladder_team**
- Change the teams of ladders

   Chat Syntax | (!,/,?)ladder_team *team*
   ------------- | -------------

   Console Syntax | scripted_user_func *ladder_team,team* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->7_
   ------------- | -------------
```cpp
       //Overloads:
       // "reset" to reset ladders back to their default teams
       ladder_team {team : (all,survivor,infected,spectator,l4d1) | reset}
    
```
---
#### **stop_car_alarms**
- Stops all car alarms playing

   Chat Syntax | (!,/,?)stop_car_alarms
   ------------- | -------------

   Console Syntax | scripted_user_func *stop_car_alarms* 
   ------------- | -------------
    
   Menu Sequence | _6->9->5->1_
   ------------- | -------------
 
---
#### **remove_fall_cams**
- Remove falling follower cameras which lock movement and view. Example: Views on the No Mercy rooftop while falling

   Chat Syntax | (!,/,?)remove_fall_cams
   ------------- | -------------

   Console Syntax | scripted_user_func *remove_fall_cams* 
   ------------- | -------------
    
   Menu Sequence | _6->9->5->2_
   ------------- | -------------
 
---
#### **hurt_triggers**
- Remove falling follower cameras which lock movement and view. Example: Views on the No Mercy rooftop while falling

   Chat Syntax | (!,/,?)hurt_triggers *state*
   ------------- | -------------

   Console Syntax | scripted_user_func *hurt_triggers,state* 
   ------------- | -------------
    
   Menu Sequence | _6->9->5->3 and 6->9->5->4_
   ------------- | -------------

```cpp
       //Overloads:
       hurt_triggers {state:(enable,disable)}
       hurt_triggers     // state = disable
       
       //Example: Re-enable hurt triggers in the map
       hurt_triggers enable
``` 
---
#### **soda_can**
- Spawn a drinkable soda which recovers health for players

   Chat Syntax | (!,/,?)soda_can *recover*
   ------------- | -------------

   Console Syntax | scripted_user_func *soda_can,recover*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads
       soda_can {recover:health_amount}
       soda_can     // recover = 5
       
       // Example: Spawn a drink which restores 15HP when a player uses it
       soda_can 15
```
---
#### **update_aimed_ent_direction**
- Make aimed object face the same way as you

   Chat Syntax | (!,/,?)update_aimed_ent_direction
   ------------- | -------------

   Console Syntax | scripted_user_func *update_aimed_ent_direction* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->1->6->3_
   ------------- | -------------

---
### Debugging, scripting and settings related

#### **help**
- Print out the built-in documentation for given command if it there is any.

   Chat Syntax | (!,/,?)help *command_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *help,command_name*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // Result will only be visible to caller
       help {command_name}

       // Example: Get documentation of command "ent"
       help ent
    
```
---
#### **script**
- Compiles given string. Requires script authorization and is a very dangerous command since gives access to everything in the global scope

   Chat Syntax | (!,/,?)script *code*
   ------------- | -------------

   Console Syntax | scripted_user_func *script,code*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       script {code}

       // Example: Fire "kill" input on entity #123
       script Entity(123).Input("Kill") 
    
```
---
#### **out**
- Compiles given string and prints the output. Output only visible to caller. Works same as **script** command

   Chat Syntax | (!,/,?)out *code*
   ------------- | -------------

   Console Syntax | scripted_user_func *out,code*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // Printing style depends on the result returned by the compiled code
       // If code returns an object, basic information of it gets printed
       // If code returns a table, everything in the table gets printed with correct indentation
       out {code}

       // Example: Get the tables of aliases available
       out ::AliasCompiler.Tables

       // Example: Get basic information about player at index 1
       out Player(1)
    
```
---
#### **wiki**
- Print sections from entity class wikis, using headers: link, description, flags, keyvalues, inputs, outputs. Gets updated with every minor update. 

   Chat Syntax | (!,/,?)wiki *classname_OR_reference header*
   ------------- | -------------

   Console Syntax | scripted_user_func *wiki,classname_OR_reference,header*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // classname_OR_reference = Class name|!picker (aimed object's class)|#idx (object at index idx's class)
       // header = 
       //   Wiki page link : link|Link|site|Site
       //   Description sections: info|Info|desc|Desc|description|Description
       //   Flags : flags|Flags
       //   Key-Value pairs : keyvals|Keyvals|keyvalues|Keyvalues
       //   Inputs : inputs|Inputs
       //   Outputs : outputs|Outputs
       // Not giving a header prints all the sections, which floods the console/chat with the entire wiki data
       wiki {classname_OR_reference} {header:(one of the headers mentioned above)} 
       wiki {classname_OR_reference}  // header = Prints all sections
      
       // Example: Print the flags of prop_physics_multiplayer class
       wiki prop_physics_multiplayer flags

       // Example: Print the inputs of aimed object's class
       wiki !picker inputs

       // Example: Print all the description available about entity at index 33's class
       wiki #33 desc

       // Example: Print all the data available about env_microphone class
       wiki env_microphone
    
```
---
#### **update_print_output_state**
- Display output messages in chat or in console. Almost all of the messages in chat are only visible to the player.

   Chat Syntax | (!,/,?)update_print_output_state
   ------------- | -------------

   Console Syntax | scripted_user_func *update_print_output_state*
   ------------- | -------------
    
   Menu Sequence | _6->9->4->6_
   ------------- | -------------
    
---
#### **add_script_auth**
- Give authorization to an admin to use commands which can compile texts, and to use runtime compilable arguments

   Chat Syntax | (!,/,?)add_script_auth *character*
   ------------- | -------------

   Console Syntax | scripted_user_func *add_script_auth,character*
   ------------- | -------------
    
   Menu Sequence | _6->9->2->1_
   ------------- | -------------
```cpp
       //Overloads:
       // ONLY THE HOST can give script authority to others
       add_script_auth {character}
    
```
---
#### **remove_script_auth**
- Take away the authorization from admin to use "script" command

   Chat Syntax | (!,/,?)remove_script_auth *character*
   ------------- | -------------

   Console Syntax | scripted_user_func *remove_script_auth,character*
   ------------- | -------------
    
   Menu Sequence | _6->9->2->2_
   ------------- | -------------
```cpp
       //Overloads:
       // Host's script authority can not be taken away
       remove_script_auth {character}
    
```
---
#### **disable_command**
- Disable a command for the current game session (doesn't stop the host from using the command)

   Chat Syntax | (!,/,?)disable_command *command_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *disable_command,command_name*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       disable_command {command_name}

       //Example: Disable "explosion" command for everyone except the host
       disable_command explosion
```
---
#### **enable_command**
- Re-enable a command for the current game session

   Chat Syntax | (!,/,?)enable_command *command_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *enable_command,command_name*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       enable_command {command_name}

       //Example: Enable the "explosion" command back for everyone
       enable_command explosion
```
---
#### **command_ban**
- Ban a command's usage for an admin, can be used to ban all commands too. Ban's are bound to steamid of the target player and any remaining ban gets reset after closing the server.

   Chat Syntax | (!,/,?)command_ban *character command_name duration*
   ------------- | -------------

   Console Syntax | scripted_user_func *command_ban,command_name,duration*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // Host can not be banned from commands
       command_ban {character} {command_name} {duration:seconds}
       command_ban {character} {command_name} // duration = 999999 seconds
       command_ban {character}  // command_name = all commands, duration = 999999 seconds

       //Example: Ban grab command for admin playing as bill for 30 seconds
       command_ban !bill grab 30

       //Example: Ban all commands for admin playing as player at index 3 until you unban them
       command_ban #3
```
---
#### **command_unban**
- Unban a command's usage for an admin

   Chat Syntax | (!,/,?)command_unban *character command_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *command_unban,command_name*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       command_unban {character} {command_name}
       command_unban {character}  // command_name = all commands

       //Example: Unban grab command for admin playing as bill
       command_unban !bill grab

       //Example: Unban #2 player from all their command bans
       command_unban #2
```
---
#### **hex_string**
- Get a "argument-ready" version of given text, which can be used as an argument later

   Chat Syntax | (!,/,?)hex_string *text*
   ------------- | -------------

   Console Syntax | scripted_user_func *hex_string,text*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // text should be given as how you would want it to be used as, no pre-change needed
       hex_string {text}

       // Example: Get hex-fixed version of the text Entity("#123").GetName()+"_add_this" to be used later within $[expression] format
       //   It will return: Entity\x28\x22#123\x22\x29.GetName\x28\x29+\x22_add_this\x22
       hex_string Entity("#123").GetName()+"_add_this"

       // Example: Get hex-fixed version of the text 'my,very;illegal:string isn't;so'bad' to be used later as an argument
       //   It will return: my\x2Cvery\x3Billegal\x3Astring\x20isn\x27t\x3Bso\x27bad
       hex_string my,very;illegal:string isn't;so'bad
```
---
#### **enum_string**
- Get a "evaluation-ready" version of given text, which can be used in _$[expression]_ later. **hex_string** is generally more preferable in most cases over this command.

   Chat Syntax | (!,/,?)enum_string *text*
   ------------- | -------------

   Console Syntax | scripted_user_func *enum_string,text*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // text should be given as how you would want it to be used as, no pre-change needed
       enum_string {text}

       // Example: Get enumerated version of the text "dis one; dat one, r:g:b"
       //   It will return: __.d+__.i+__.s+__._s+__.o+__.n+__.e+__._sc+__._s+__.d+__.a+__.t+__._s+__.o+__.n+__.e+__._c+__._s+__.r+__._col+__.g+__._col+__.b
       enum_string dis one; dat one, r:g:b
```
---
#### **ents_around**
- Get entity indices and classes around the aimed point

   Chat Syntax | (!,/,?)ents_around *radius*
   ------------- | -------------

   Console Syntax | scripted_user_func *ents_around,radius*
   ------------- | -------------
    
   Menu Sequence | _6->9->4->7_
   ------------- | -------------
```cpp
       //Overloads:
       ents_around {radius}
       ents_around        // radius:50
    
```
---
#### **wnet**
- Add a watch to a netprop of an entity or all netprops defined under given class, checks netprop of the given entity and only show a message when it changes

   Chat Syntax | (!,/,?)wnet *netprop_or_baseclass,check_rate,NAME_OR_ID*
   ------------- | -------------

   Console Syntax | scripted_user_func *wnet,netprop_or_baseclass,check_rate,NAME_OR_ID*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // netprop_name is the netprop member name
       // check_rate is the time in seconds to check the netprop value
       // NAME_OR_ID is the name or the index of the entity to watch
       // Information is printed at wherever player is using as output state
       wnet {netprop_name} {check_rate:seconds} {NAME_OR_ID}
       wnet {netprop_name} {check_rate:seconds}       // NAME_OR_ID = aimed entity
       wnet {netprop_name}    // check_rate = 1 second , NAME_OR_ID = aimed entity
       
       // Example: Watch m_clrRender netprop of the entity at index 82, check every half a second
       wnet m_clrRender 0.5 #82

       // Example: Watch movetype netprop of the aimed entity, check every 2 seconds
       wnet movetype 2
       
       //Overloads:
       // Use "&" to watch all the members defined under a class (which are defined in the NetPropTables table)
       wnet &{baseclass}&{depth:integer} {check_rate:seconds} {NAME_OR_ID}
       
       // Example: Watch netprop members at less than depth 4 defined under CBaseEntity for the entity #99 every second
       wnet &CBaseEntity&4 1 #99

       // Example: Watch all CBaseAnimating members of the aimed object every half a second
       wnet &CBaseAnimating 0.5
```
---
#### **stop_wnet**
- Stop watching a netprop or class members of an entity

   Chat Syntax | (!,/,?)stop_wnet *netprop_name,NAME_OR_ID*
   ------------- | -------------

   Console Syntax | scripted_user_func *stop_wnet,netprop_name,NAME_OR_ID*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // netprop_name is the netprop member name
       // NAME_OR_ID is the name or the index of the entity to watch
       stop_wnet {netprop_name} {NAME_OR_ID}
       stop_wnet {netprop_name}      // NAME_OR_ID = aimed entity
    
       // Example: Stop watching m_fEffects netprop of entity named myEntity999
       stop_wnet m_fEffects myEntity999

       // Example: Stop watching m_vecOrigin netprop of aimed entity
       stop_wnet m_vecOrigin
       
       //Overloads:
       // Use "&" to use base class names
       stop_wnet &{baseclass} {NAME_OR_ID}
    
       // Example: Stop watching CBaseAnimating members of object at index 22
       stop_wnet &CBaseAnimating #22

```
---
#### **update_custom_response_preference**
- Enable/Disable custom responses

   Chat Syntax | (!,/,?)update_custom_response_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_custom_response_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->1_
   ------------- | -------------

---
#### **update_tank_rock_launch_preference**
- Enable/Disable push effect when hit by a tank's rock(only works if only 1 rock was present)

   Chat Syntax | (!,/,?)update_tank_rock_launch_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_tank_rock_launch_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->2->1_
   ------------- | -------------

---
#### **update_tank_rock_random_preference**
- Enable/Disable random models for tank's rocks

   Chat Syntax | (!,/,?)update_tank_rock_random_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_tank_rock_random_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->2->2_
   ------------- | -------------

---
#### **update_tank_rock_spawn_preference**
- Enable/Disable spawning tank's rocks as physics objects (which wont be destroyed on hit)

   Chat Syntax | (!,/,?)update_tank_rock_spawn_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_tank_rock_spawn_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->2->3_
   ------------- | -------------

---
#### **update_jockey_preference**
- Get rid of or bring back the little jockey bastards

   Chat Syntax | (!,/,?)update_jockey_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_jockey_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->3_
   ------------- | -------------

---
#### **update_model_preference**
- Enable/Disable wheter to keep last model used for survivors between chapters

   Chat Syntax | (!,/,?)update_model_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_model_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->4_
   ------------- | -------------
    
---
#### **update_custom_sharing_preference**
- Enable/Disable sharing grenades and packs by holding reload "R" button

   Chat Syntax | (!,/,?)update_custom_sharing_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_custom_sharing_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->5_
   ------------- | -------------
    
---
#### **update_bots_sharing_preference**
- Enable/Disable automatic sharing grenades and packs for bots

   Chat Syntax | (!,/,?)update_bots_sharing_preference
   ------------- | -------------

   Console Syntax | scripted_user_func *update_bots_sharing_preference*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->6->1_
   ------------- | -------------
    
---
#### **kind_bots**
- Enable ability for bots to look for and share grenades and packs

   Chat Syntax | (!,/,?)kind_bots
   ------------- | -------------

   Console Syntax | scripted_user_func *kind_bots*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->6->2_
   ------------- | -------------
    
---
#### **selfish_bots**
- Disable ability for bots to look for and share grenades and packs

   Chat Syntax | (!,/,?)selfish_bots
   ------------- | -------------

   Console Syntax | scripted_user_func *selfish_bots*
   ------------- | -------------
    
   Menu Sequence | _6->9->1->6->3_
   ------------- | -------------

---
#### **debug_info**
- Dump information about objects

   Chat Syntax | (!,/,?)debug_info *get_player_info*
   ------------- | -------------

   Console Syntax | scripted_user_func *debug_info,get_player_info*
   ------------- | -------------
    
   Menu Sequence | _6->9->4->4_ AND _6->9->4->5_
   ------------- | -------------
```cpp
       //Overloads:
       debug_info player      // Show information about whoever calls this function
       debug_info             // Show information about targeted object
       
       // Example: Get information about your player's current state
       debug_info player
```
---
#### **flag_lookup**
- Check what flags/constants are defined with a given prefix or check what flags/constants correspond to a given integer value

   Chat Syntax | (!,/,?)flag_lookup *prefix,value*
   ------------- | -------------

   Console Syntax | scripted_user_func *flag_lookup,prefix,value*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       flag_lookup {prefix} {value:integer}      // Get flags with bitwise OR "|" equal to given value, starting with given prefix in their name 
       flag_lookup {prefix}             // Show all flags bitwise OR'd starting with given prefix in their names
       
       // Example: Get corresponding flags to value 44 using HEIGHT_ flags
       flag_lookup HEIGHT_ 44
       
       // Example: Get all flags starting with prefix ANGLE_ADD
       flag_lookup ANGLE_ADD
```
---
### Custom Script Related

#### **create_alias**
- Create an alias for existing commands. Only usable by players with script authorization

   Chat Syntax | (!,/,?)create_alias *table_contents*
   ------------- | -------------

   Console Syntax | scripted_user_func *create_alias,table_contents*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       // table_contents: Single line table without { at start and } at end
       create_alias {table_contents}

       // Example: Create a new alias named golden_grab, which renders aimed object yellow and grab it after
       create_alias golden_grab Commands={color={arg_1="255",arg_2="255",arg_3="0"},grab={}}
       
       // Example: Create a new alias named talk_thrice, which will make your character speak 3 random lines, 8 seconds of each
       create_alias talk_thrice Commands={randomline={repeat=3,delay_between=8}}

       // Example: Create a new alias named check_velocity, which will print current speed of Player(1), using the first parameter as repeat count, second as interval length to check
       // -> Make first parameter as repeat amount, if nothing given: repeats 5 times
       // -> Make second parameter as delay between repeats, if nothing given: waits 1 second
       // Unfortunately this would be too long to send from chat so it HAS to be sent from the console, but there is another problem. Console doesn't allow many of the characters present in this line
       // So you will have to use hex_string command from chat twice and combine resulting string to get a valid argument
       // When the characters are replaced, we are left with the following command to be used in console:
       // scripted_user_func create_alias,check_speed,Parameters=\x7Bparam_1=\x223\x22\x2Cparam_2=\x225\x22\x7D\x2CCommands=\x7Bout=\x7Barg_1=\x22Player\x281\x29\x2EGetPhysicsVelocity\x28\x29\x22\x2Crepeat=\x22$param_1\x22\x2Cdelay_between=\x22$param_2\x22\x7D\x7D
       create_alias check_velocity Parameters={param_1="5",param_2="1"},Commands={out={arg_1="Player(1).GetPhysicsVelocity()",repeat="$param_1",delay_between="$param_2"}}
    
```
---
#### **replace_alias**
- Replace an existing alias, check create_alias command's format.

   Chat Syntax | (!,/,?)replace_alias *table_contents*
   ------------- | -------------

   Console Syntax | scripted_user_func *replace_alias,table_contents*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
   
---
#### **reload_aliases**
- Reload custom alias files from **admin system/aliases/**

   Chat Syntax | (!,/,?)reload_aliases
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_aliases*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
     
---
#### **reload_scripts**
- Reload custom script files from **admin system/scripts/**

   Chat Syntax | (!,/,?)reload_scripts
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_scripts*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
   
---
#### **reload_ent_groups**
- Reload custom entity group tables from **admin system/entitygroups/**

   Chat Syntax | (!,/,?)reload_ent_groups
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_ent_groups*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
   
---
#### **detach_hook**
- Detach a custom hook function from an event

   Chat Syntax | (!,/,?)detach_hook *event,hook*
   ------------- | -------------

   Console Syntax | scripted_user_func *detach_hook,event,hook*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       detach_hook {event} {hook}

       // Example: Detach the MyHookName function of OnPlayerShoved event
       detach_hook OnPlayerShoved MyHookName
```
---
#### **attach_hook**
- Attach a custom hook function from an event back

   Chat Syntax | (!,/,?)attach_hook *event,hook*
   ------------- | -------------

   Console Syntax | scripted_user_func *attach_hook,event,hook*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------
```cpp
       //Overloads:
       attach_hook {event} {hook}

       // Example: Re-attach the MyHookName function to OnPlayerShoved event
       // -> You can't change a hook's event while re-attaching
       attach_hook OnPlayerShoved MyHookName
```
---
#### **reload_hooks**
- Reload custom hook files from **admin system/hooks/**

   Chat Syntax | (!,/,?)reload_hooks
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_hooks*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

--- 
#### **reload_binds**
- Reload bind table files from **admin system/binds/**

   Chat Syntax | (!,/,?)reload_binds
   ------------- | -------------

   Console Syntax | scripted_user_func *reload_binds*
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

--- 
#### **bind**
- Re-bind a unbound command/function

   Chat Syntax | (!,/,?)bind *target key_name cmd_func_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *bind,target,key_name,cmd_func_name* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads
       bind {target:(!self,#{ID},{Name})} {keyname:(FORWARD,BACK,LEFT,RIGHT,ATTACK,ZOOM,SHOVE,RELOAD,JUMP,WALK,DUCK,USE,SCORE,ALT1,ALT2)} {cmd_func_name}
       
       // Example: Re-bind grab command bound in ALT1 for yourself
       bind !self ALT1 !grab
       
       // Example: Re-bind foo_func function bound in ATTACK (mouse1) for the admin playing as Bill
       bind !bill ATTACK foo_func
```
---
#### **unbind**
- Unbind a command/function bound to a key via *admin system/binds* tables

   Chat Syntax | (!,/,?)unbind *target key_name cmd_func_name*
   ------------- | -------------

   Console Syntax | scripted_user_func *unbind,target,key_name,cmd_func_name* 
   ------------- | -------------
    
   Menu Sequence | _Not in the menu_
   ------------- | -------------

```cpp
       //Overloads
       unbind {target:(!self,#{ID},{Name})} {keyname:(FORWARD,BACK,LEFT,RIGHT,ATTACK,ZOOM,SHOVE,RELOAD,JUMP,WALK,DUCK,USE,SCORE,ALT1,ALT2)} {cmd_func_name}
       
       // Example: Unbind grab command bound in ALT1 for yourself
       unbind !self ALT1 !grab
       
       // Example: Unbind foo_func function bound in ATTACK (mouse1) for the admin playing as Bill
       unbind !bill ATTACK foo_func
```  
---

## Binds
- project_smok allows you to bind commands and your own functions to general keys.
   + Available keys:
      - Movement keys: **FORWARD**, **BACK**, **LEFT**, **RIGHT**, **WALK**, **JUMP**, **DUCK** 
      - Attack keys: **ATTACK**, **ZOOM**, **SHOVE**, **RELOAD**
      - Other keys: **USE**, **SCORE**, **ALT1**, **ALT2**
   
   + Available binding usage types:
      - Single calls: **PS_WHEN_PRESSED** , **PS_WHEN_UNPRESSED**
      - Continious calls: **PS_WHILE_PRESSED**, **PS_WHILE_UNPRESSED**

   + Follow the example file in **admin system/bind/** directory to start writing your own binds!
   
   + When a key is bound, the key is checked every **~33ms**(~30 times a second) and fire if conditions are met

   + Binds are quite reliable and consistent most of the time, but it is **NOT RECOMMENDED** to spam them.

 #### Binds File Format
   - Following is an example format for creating a bind.
   + **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments 
	
```nut
// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the VSLib library, check out: https://l4d2scripters.github.io/vslib/docs/index.html
// Some methods of VSLib may behave differently, make sure to check out the source code for those: https://github.com/semihM/project_smok/tree/master/2229460523/scripts/vscripts/admin_system/vslib

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
// Start by finding the admin's steam id, use admins.txt or check https://steamidfinder.com/ 
// You can use "all" instead of a steam ID to create the binds inside for all admins
"STEAM_1:X:XXXXXX":
{
	// Use a key name given above (FORWARD, ATTACK, USE, etc.)
	"KEY_NAME":
	{
		// Add "!" before the command names to bind them
		"!command_name":
		{
			// Decide how its gonna be used with "Usage" key
			//		PS_WHEN_PRESSED = Calls once everytime this button gets pressed
			//		PS_WHEN_UNPRESSED = Calls once everytime this button gets unpressed; use this with caution
			//		PS_WHILE_PRESSED = Keeps calling while this button is pressed; SKIPS the first press input to let PS_WHEN_PRESSED work
			//		PS_WHILE_UNPRESSED = Keeps calling while this button is not pressed; SKIPS the first unpress input to let PS_WHEN_UNPRESSED work
			//		0 = Disables this bind (Constants above has values 1,2,4,8 respectively)
			Usage = PS_WHEN_PRESSED

			// Pass arguments with "Arguments" key
			//    This will be same as: !command_name arg_1 arg_2 ...
			Arguments =
			{
				arg_1 = "argument_1"
				arg_2 = "argument_2"  
				// Follow "arg_X" format for Xth argument
			}
		}

		// If you want to create a custom function, use its name directly
		"my_function_name":
		{
			// Decide how its gonna be used with "Usage" key
			// 		o You can combine the usages with "|" operator
			Usage = PS_WHEN_PRESSED | PS_WHEN_UNPRESSED

			// Create the function which takes 2 parameters:
			//		1. player : Player's entity as VSLib.Player object
			//		2. press_info: A table containing:
			//			o usage_type : Use this value to differentiate the combined "Usage" values, compare it to each usage value you used to understand which call was fired
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

				// If you have combined "Usage" values, use something similar to expression below
				switch(usage_type)
				{
					case PS_WHEN_PRESSED:
						// Write instructions for "pressing" event
						break;

					case PS_WHEN_UNPRESSED:
						// Write instructions for "unpressing" event
						break;
				}

				// If you don't have combined usage values, just write the rest of the instructions here
			}
		}
	}
}
```
   ---
   - Following is a working example bind. This bind:
      + Gets bound for all admins once they join the game
      + Is bound to the **ZOOM** key
      + Calls **grab** command when **ZOOM** is pressed
      + Calls **message_me** custom function when **ZOOM** is pressed and unpressed
      + Calls **yeet** command when **ZOOM** is unpressed
```nut
"all":
{
	"ZOOM":
	{
		"!grab":
		{
			Usage = PS_WHEN_PRESSED
			Arguments = {}
		}

		"!yeet":
		{
			Usage = PS_WHEN_UNPRESSED
			Arguments = {}
		}
      
		"message_me":
		{
			Usage = PS_WHEN_PRESSED | PS_WHEN_UNPRESSED

			Function = function(player, press_info)
			{
				local usage_type = press_info.usage_type
				local press_time = press_info.press_time
				local unpress_time = press_info.unpress_time
				local count = press_info.press_count
				local duration = press_info.press_length

				switch(usage_type)
				{
					case PS_WHEN_PRESSED:
						::Printer(player,"Pressed ZOOM key! Total press count: " + count)
						break;

					case PS_WHEN_UNPRESSED:
						::Printer(player,"Have pressed for " + duration + " seconds!")
						break;
				}

			}
		}
	}
}
```

## Entity Groups
   - Following is an example file content for creating an entity group called **ExampleGnome**, which glows green and has a customized name depending on whoever spawns it.
   - Entity groups can be spawned with [prop](#prop) command
   + **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments 
    
 #### Entity Groups File Format
  - For more examples, download **L4D2 Authoring Tools** and check out the directory *"Left 4 Dead 2\sdk_content\scripting\scripts\vscripts\entitygroups"*
```nut
// The name declared here will be used with the commands
ExampleGnome =
{
	// Required Interface functions
	// - These following functions are REQUIRED to register an entity group
	// - Add references of entities which has a model/sound in this
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return precacheModels
	}

	// - Add references of entities here to spawn them 
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.gnome,
		]
		return spawnEnts
	}

	// - This function has to return a reference to the table below
	function GetEntityGroup()
	{
		return EntityGroup
	}

	// Table of entities that make up this group
	EntityGroup =
	{
		// Entities to spawn
		SpawnTables =
		{
			// Name of the this entity's table, refer to this on the functions above
			// "targetname" is used to name the spawned entity
			gnome = 
			{
				// Key value pairs for this entity
				SpawnInfo =
				{
					classname = "$classname"
					angles = Vector( 0, 180, 0 )
					glowcolor = "56 150 58"
					glowrange = "0"
					glowrangemin = "0"
					glowstate = "3"
					massScale = "5"
					model = "models/props_junk/gnome.mdl"
					spawnflags = "0"
					targetname = "$targetname"	// Keep the replacing parameter named same(especially for targetname)!
					origin = Vector( -6, 8, 11 )
				}
			}
		} // SpawnTables
		// Add a table named ReplaceParmDefaults to change values in key-value pairs
		// Use $[expression] format to evaluate expressions for every single spawn call
		//  - If $[expression] is used in an entity group, it will require SCRIPT AUTHORIZATION for players to use this entity group
		//	- With the $[expression] format, you can access to some external variables:
		//		1. To get the command caller player as VSLib.Player use "player" variable
		//		2. To get the table of arguments used with the command use "GetArgument(idx)" for idx'th argument
		ReplaceParmDefaults =
		{
			"$classname" : "prop_physics_multiplayer"
			// By default, any parameter name starting with "$targetname" is taken as a targetname while printing messages, so be reasonable while naming the parameters!
			"$targetname" : "$[\"gnome_spawned_by_\"+player.GetCharacterNameLower()]"	
		}
	} // EntityGroup
} // ExampleGnome
```
   
#### Creating Entity Groups
   - To create an entity group *from scratch*, follow these steps:
      1. Decide for a name for the entity group
      2. Create a table for the chosen name
      3. Add the required *GetPrecacheList*, *GetSpawnList*, *GetEntityGroup* functions to the table 
      4. Add a table called *EntityGroup* to store entity spawn tables and replaceable values, this name can be changed but it's reference has to be return from *GetEntityGroup* function
      5. Add a table called *SpawnTables* inside *EntityGroup* table
      6. Add tables of entities you want spawned inside *SpawnTables* table, these table names should be referred in *GetSpawnList* function
      7. Add a table inside of each entity table named *SpawnInfo* storing key-value pairs for the entity
      8. If you want to have dynamic values:
           + Use **"$my_variable_name"** format as values for key-value pairs
           + Add a table named *ReplaceParmDefaults* inside *EntityGroup* table
           + Use the following format to replace a parameter with a static value
           
           <code> **"$my_variable_name"** : "value_to_use" </code>
	   
           + Use the following format to replace a parameter with an expression which gets evaluated every spawn call
           
           <code> **"$my_variable_name"** : "$[expression]" </code>
	   
           + With **$\[expression\]** format, caller can be accessed with variable name **player** and arguments of the command call can be accessed with **GetArgument(n)** function for *n'th* argument
	   
      9. Entity group is ready for spawning! You can use [prop](#prop) command to spawn it.
      10. You can use [reload_ent_groups](#reload_ent_groups) command to reload the entity group files in-game 

   - **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments 

#### Importing Entity Groups
 - Importing an entity group that was auto-generated requires only **3 steps** after putting the file into the *admin system/entitygroups/* folder:
      1. Remove the line with the "RegisterEntityGroup" function call, this call is done internally later
      2. Replace "<-" with "=" after the entity group name
      3. Entity group file is ready to be imported! Just add the file name to **file_list.txt**
  
## Hooks
- project_smok allows you to hook your own functions to game events.
   + Available game event names can be found [here](https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut#L194)
   
   + Details of the game events can be found [here](https://wiki.alliedmods.net/Left_4_dead_2_events)
   
   + Make sure to use the event names present in the **Notifications** table present in the [first link](https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut#L194)

   + Follow the example file in **admin system/hooks/** directory to start writing your own functions for game events!
   
 #### Hook File Format
   - Following is an example file content for hooking **2** functions named **VeryCoolHook** and **AnotherCoolHook** to game event **OnPlayerConnected**, which are called after a player finishes their connection process. **PS_Hooks** table have to be used as the main table for hooking functions.
   + **WARNING**: While copy-pasting the examples, it will most likely fail while compiling. Some solutions:
      - Remove the comments around and inside the table, anything after **"//"** inclusively, may be the cause of "expected identifier" error messages
      - Re-write the example with better indentation OR no indentation OR single line without comments 
	
```nut
// If you are a beginner to Squirrel scripting language, check out: http://squirrel-lang.org/squirreldoc/
// If you don't know how to use the VSLib library, check out: https://l4d2scripters.github.io/vslib/docs/index.html
// Some methods of VSLib may behave differently, make sure to check out the source code for those: https://github.com/semihM/project_smok/tree/master/2229460523/scripts/vscripts/admin_system/vslib

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

// Before writing the function, do a simple CTRL+F search, find the game event and how many parameters are passed to hooks in https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut
// General format: 
//	::PS_Hooks.GameEvent.UniqueHookFunctionName <- function(GameEventParameters){}

// OnPlayerConnected event passes 2 arguments, so the hook must have 2 parameters
// -> This function will display new non-admin players a welcome message
::PS_Hooks.OnPlayerConnected.VeryCoolHook <- function(player,args)
{
	// Check admin status, in this case make sure second parameter(quiet) is true, so no other message will be displayed 
	if(!AdminSystem.IsPrivileged(player,true))	
		::Messages.InformPlayer(player,"Welcome! This is a modded server and the admins are very reasonable people :) Enjoy the madness!") 
}

// -> This function will display everyone a message telling an admin has connected 
::PS_Hooks.OnPlayerConnected.AnotherCoolHook <- function(player,args)
{
	// Check admin status, in this case make sure second parameter(quiet) is true, so no other message will be displayed
	// -> Player's name will be colored orange, rest will be white
	if(AdminSystem.IsPrivileged(player,true))
		::Messages.InformAll(COLOR_ORANGE + player.GetName() + COLOR_DEFAULT + " is here to smok- some boomers!");	
} 
```

## Extra

### Changing settings, adding custom responses without launching the game
---
#### Basic configuration structure
- AdminSystem configuration files are stored in the **"..\Left 4 Dead 2\left4dead2\ems\admin system"** directory.

- This directory contains:
   + **_aliases_** : Custom alias files folder
      - **_file\_list.txt_**: List of file names to read as custom alias tables

      - **_example\_alias\_file.txt_**: An example file containing information about how to create aliases, version v1.0.0 
      
      - **_example\_alias\_file\_v{Major}\_{Minor}\_{Patch}.txt_**: File containing examples using new features from version v{Major}.{Minor}.{Patch}

   + **_binds_** : Custom bind tables files folder
      - **_file\_list.txt_**: List of file names to read as custom bind tables

      - **_example\_bind\_file.nut_**: An example file containing information about how to create binds

   + **_entitygroups_** : Custom alias files folder
      - **_file\_list.txt_**: List of file names to read as custom entity group tables

      - **_example\_entity\_file.txt_**: An example file containing information about how to create entity groups, version v1.4.0 
      
   + **_hooks_** : Custom hook files folder
      - **_file\_list.txt_**: List of file names to read as custom hook functions

      - **_example\_hook\_file.nut_**: An example file containing information about how to create hooks

   + **_scripts_** : Custom script/command files folder
      - **_file\_list.txt_**: List of file names to read as custom commands

      - **_example\_script\_file.nut_**: An example file containing information about how to create commands

   + **_vehicles_** : Custom vehicle tables files folder
      - **_file\_list.txt_**: List of file names to read as custom vehicle tables

      - **_example\_vehicle\_file.nut_**: An example file containing information about how to create vehicle tables
      
   + **_admins.txt_** : Admins

   + **_apocalypse\_settings.txt_** : Apocalypse event custom settings

   + **_banned.txt_** : Banned players (only if theres any)

   + **_botparams.txt_** : Bots' sharing/looting parameters

   + **_command\_limits_.txt_** : Restrictions to apply to admins for certain commands

   + **_custom\_responses.json_** : Custom responses, doesn't include built-in ones

   + **_defaults.txt_** : Default settings and parameters

   + **_disabled\_commands_.txt_** : List of command names to disable 

   + **_ghost\_zombies\_settings.txt_** : Ghost zombies event custom settings

   + **_loot\_tables.txt_** : Loot tables used while making props lootable
   
   + **_meteor\_shower\_settings.txt_** : Meteor shower event custom settings

   + **_prop\_defaults.txt_** : Default prop spawning settings

   + **_settings.txt_** : Admin system settings

   + **_scriptauths.txt_** : Script authorizations

- These files can all be edited manually with any text editor.
   + [VS Code](https://code.visualstudio.com/) is recommended for editing, especially for the **.nut** Squirrel scripting language files. Helpful add-ons:
      - [Squirrel Language Highlighting](https://marketplace.visualstudio.com/items?itemName=monkeygroover.vscode-squirrel-lang)
      - [Visual Studio IntelliCode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode)

- File sizes are restricted to **16.5 KB maximum**. If a file bigger than **16.5 KB** was tried to read, it will prevent the add-on from loading properly!

- If an issue occurs while reading the file, it will be printed in **red** in the console. Removing the file can help solve reading issues by letting the addon re-creating the file again in the next reset.

- **IMPORTANT**: These **file_list.txt** files has a character (may be invisible) at the end of them which will prevent anything written after it from being read. To solve this issue:
   + **Solution 1**: Before you start a new line at the end of the file, remove the last character (may appear as an error character or a space) of the last line
   + **Solution 2**: Remove the contents of the file, write the file names after cleaning  

#### Extra Notes
- **"custom_responses.json"** file can be opened with a text editor and new custom sequences can be defined  for each admin's steam ID with the example format given in the file.

- **"defaults.txt"** file contains most of the customizable settings in the **project_smok**. Follow the instructions given in the file to start editing!

- **"prop_defaults.txt"** file contains prop spawning settings tables and flag explanations. Follow the instructions given in the file to start editing!

- **"botparams.txt"** file contains the parameters used for bots' sharing and looting abilities. Probabilistic values are normalized between 0 and 1.

- **"apocalypse_settings.txt"** file contains the settings to use for the _apocalypse_ event. Probabilistic values are normalized between 0 and 1.

- **"ghost_zombies_settings.txt"** file contains the settings to use for the _ghost zombies_ event. Probabilistic values are normalized between 0 and 1.

- **"meteor_shower_settings.txt"** file contains the settings to use for the _meteor shower_ event. Probabilistic values are normalized between 0 and 1.

- **entitygroups/** folder can be used to easily import entity group tables. Follow the instructions in the example file: **_entitygroups/example\_entity\_file.txt_**

---
### Detailed Tables
---
- There are currently **5** big tables containing detailed information about the objects in the game.
  + **_NetPropTables_ : Contains network property members and their basic information for every base class defined.** 
     - **Example:** Access to render color member information of props:
       ```cpp
       ::NetPropTables.CBaseEntity.m_clrRender
       ```
     
  + **_EntityDetailTables_ : Contains most if not all the information on every entity class wiki page there is categorized under basic headers:(Description,Flags,KeyValues,Inputs,Outputs).**
     - **Example:** Access to flags of prop_ragdoll class:
       ```cpp
       ::EntityDetailTables.prop.prop_ragdoll.flags
       ```
     - **Example(Using _wiki_ command):** Print key-value pairs of prop_dynamic class:
     
       Chat Syntax | (!,/,?)wiki *prop_dynamic keyvals*
       ------------- | -------------

       Console Syntax | scripted_user_func *wiki,prop_dynamic,keyvals*
       ------------- | -------------
  
  + **_SoundScripts_ : Contains all built-in sound script tables, only includes used ones.** 
     - **Example:** Get **Zombat3_Intro_Fairgrounds** event details: 
       ```cpp
       ::SoundScipts["Event.Zombat3_Intro_Fairgrounds"]
       ```
     
  + **_ModelDetails_ : Contains all built-in model data. Includes sequences defined for models** 
     - **Example:** Get **props_vehicles/bus01** model details: 
       ```cpp
       ::ModelDetails["props_vehicles/bus01"]
       ```
       
     - **Example:** Get **props_vehicles/c130** model sequence names(Some models may not have this property): 
       ```cpp
       ::ModelDetails["props_vehicles/c130"].sequences
       ```  
       
  + **_MaterialDetails_ : Contains all built-in material tables** 
     - **Example:** Get **lighthouse/river01** material table: 
       ```cpp
       ::MaterialDetails["lighthouse/river01"]
       ```
---
## Other Links

- [Admin System](https://steamcommunity.com/sharedfiles/filedetails/?id=214630948)
- [Admin Menu 2.0](https://steamcommunity.com/sharedfiles/filedetails/?id=1229957234)
- [VSLib](https://l4d2scripters.github.io/vslib/docs/index.html)
- [Squirrel Scripting Language](http://squirrel-lang.org/squirreldoc/)
- [Valve Wiki](https://developer.valvesoftware.com/wiki/Main_Page)
