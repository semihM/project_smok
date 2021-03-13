# project_smok
 - Repository for the workshop item [project_smok](https://steamcommunity.com/sharedfiles/filedetails/?id=2229460523) of L4D2
 
 - Following documentation is for the **new and updated commands**. Commands that aren't included in this documentation can be found in the [Admin System Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=213591107). Be aware that **some of the commands that are not documented may behave differently** than the guide. 

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

    - [**Other commands**](#other)

    - [**Debugging, scripting and setting related**](#debugging-scripting-and-settings-related)

    - [**Custom Script Related**](#custom-script-related)

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
   $caller_ent | _*VSLib.Player*_ | command's caller as a VSLib.Player object
   $caller_id | _*integer*_ | command caller's entity index as an integer
   $caller_char | _*string*_ | command caller's character name, first letter capitalized
   $caller_name | _*string*_ | command caller's in-game name
   $caller_target | _*VSLib.Entity*_ | entity the command caller is aiming at as an VSLib.Entity object, uses an invalid entity if nothing is looked at 
   
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
			docs = "Calls target_entity's (or caller's if null) method_name named method with cs_args string"
			
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
				
				// Use aimed entity, if it's valid: use it's origin vector; else: use null
				arg_4 = "$[$caller_target.IsEntityValid() ? $caller_target.GetOrigin() : null]"	
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

   Chat Syntax | (!,/,?)prop *type model_path*
   ------------- | -------------

   Console Syntax | scripted_user_func *prop,type,model_path* 
   ------------- | -------------
    
   Menu Sequence | _6->1->1_ AND _6->1->2_ 
   ------------- | -------------

```cpp
       //Overloads:
       // {type} should be one of (physicsM: physics object, dynamic: non-physics object, ragdoll: ragdolling models)
       // {type} also accepts classname "physics", but this class is less flexable than "physicsM" and doesn't work with most models
       // {model_path} follows this format in general: models/props_{category}/{name}.mdl OR !random for a random model
       // Multiple models can be given, seperated with "&" character, to create parented props ( parented by first model )
       // To check out all possible models: Left 4 Dead 2 Authoring Tools>Hammer World Editor>CTRL+N>CTRL+SHIFT+M>Search all models
       prop {type: (physicsM, dynamic, ragdoll)} {model_path | !random} {extra_height} {yaw:degrees} {massScale}
       prop {type: (physicsM, dynamic, ragdoll)} {model_path | !random} // extra_height = 0, yaw = 0, massScale = 1

       // Example: Create a flower barrel with physics
       prop physicsM models/props_foliage/flower_barrel.mdl
       
       // Example: Create a BurgerTank sign without physics
       prop dynamic models/props_signs/burgersign.mdl
       
       // Example: Create a random object with physics
       prop physicsM !random
       
       // Example: Create a physics prop car with its windows attached(parented by the car), model origins will match
       prop physicsM models/props_vehicles/cara_69sedan.mdl&models/props_vehicles/cara_69sedan_glass.mdl

       // Example: Create a ragdoll of coach
       prop ragdoll models/survivors/survivor_coach.mdl
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
    
   Menu Sequence | _6->5_
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
    
   Menu Sequence | _6->3->9->2 AND 6->3->9->2->9_
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
    
   Menu Sequence | _6->3->9->2 AND 6->3->9->2->9_
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
    
   Menu Sequence | _6->9->9->9->5->1_
   ------------- | -------------

---
#### **remove_piano_keys**
- Removes all piano key spawns

   Chat Syntax | (!,/,?)remove_piano_keys
   ------------- | -------------

   Console Syntax | scripted_user_func *remove_piano_keys* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->5->2_
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
### Other

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
- Change teams of ladders

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
#### **drive**
- (**EXPERIMENTAL**)"Drive" targeted car/object or stop driving. **Hold left-click** to keep aiming forward, **DO NOT** jump while moving

   Chat Syntax | (!,/,?)drive
   ------------- | -------------

   Console Syntax | scripted_user_func *drive* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->3->1_
   ------------- | -------------

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
#### **update_aimed_ent_direction**
- Make aimed object face the same way as you

   Chat Syntax | (!,/,?)update_aimed_ent_direction
   ------------- | -------------

   Console Syntax | scripted_user_func *update_aimed_ent_direction* 
   ------------- | -------------
    
   Menu Sequence | _6->9->9->9->1->6->3_
   ------------- | -------------

---
#### **random_model**
- Prints a random model name to chat, only visible to caller

   Chat Syntax | (!,/,?)random_model
   ------------- | -------------

   Console Syntax | scripted_user_func *random_model* 
   ------------- | -------------
    
   Menu Sequence | _6->9->3->9->1_
   ------------- | -------------
                             
---
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
       give_physics {radius:positive_number|!picker}
       give_physics     // radius = 150 units
       
       // Example (give physics to aimed object (if possible))
       give_physics !picker
       
       // Example (give physics to objects within 500 units around aimed point)
       give_physics 500
```
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

## Hooks
- project_smok allows you to hook your own functions to game events.
   + Available game event names can be found [here](https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut#L194)
   
   + Details of the game events can be found [here](https://wiki.alliedmods.net/Left_4_dead_2_events)
   
   + Make sure to use the event names present in the **Notifications** table present in the [first link](https://github.com/semihM/project_smok/blob/c3f631100a80913c6ad5f49fe74a24a772a03f40/2229460523/scripts/vscripts/admin_system/vslib/easylogic.nut#L194)

   + Follow the example file in **admin system/hooks/** directory to start writing your own functions for game events!
   
 #### Hook File Format
   - Following is an example file content for hooking **2** functions named **VeryCoolHook** and **AnotherCoolHook** to game event **OnPlayerConnected**, which are called after a player finishes their connection process. **PS_Hooks** table have to be used as the main table for hooking functions.
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
	// Tell everyone a semi-colored message when an admin is connected
	// Check admin status, in this case make sure second parameter(quiet) is true, so no other message will be displayed 
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
      - 
      - **_example\_alias\_file\_v{Major}\_{Minor}\_{Patch}.txt_**: An example file containing examples with new features from version v{Major}.{Minor}.{Patch}

   + **_hooks_** : Custom hook files folder
      - **_file\_list.txt_**: List of file names to read as custom hook functions

      - **_example\_hook\_file.nut_**: An example file containing information about how to create hooks

   + **_scripts_** : Custom script/command files folder
      - **_file\_list.txt_**: List of file names to read as custom commands

      - **_example\_script\_file.nut_**: An example file containing information about how to create commands

   + **_admins.txt_** : Admins

   + **_apocalypse\_settings.txt_** : Apocalypse event custom settings

   + **_banned.txt_** : Banned players (only if theres any)

   + **_botparams.txt_** : Bots' sharing/looting parameters

   + **_command\_limits_.txt_** : Restrictions to apply to admins for certain commands

   + **_custom\_responses.json_** : Custom responses, doesn't include built-in ones

   + **_defaults.txt_** : Default settings and parameters

   + **_disabled\_commands_.txt_** : List of command names to disable 

   + **_ghost\_zombies\_settings.txt_** : Ghost zombies event custom settings
   
   + **_meteor\_shower\_settings.txt_** : Meteor shower event custom settings

   + **_prop\_defaults.txt_** : Default prop spawning settings

   + **_settings.txt_** : Admin system settings

   + **_scriptauths.txt_** : Script authorizations

- These files can all be edited manually with any text editor.
   + [VS Code](https://code.visualstudio.com/) is recommended for editing, especially for the **.nut** Squirrel scripting language files. Helpful add-ons:
      - [Squirrel Language Highlighting](https://marketplace.visualstudio.com/items?itemName=monkeygroover.vscode-squirrel-lang)
      - [Visual Studio IntelliCode](https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode)

- File sizes are restricted to **16.5 KB maximum**

- If an issue occurs while reading the file, it will be printed in **red** in the console. Removing the file can help solve reading issues by letting the addon re-creating the file again in the next reset.


#### Extra Notes
- **"custom_responses.json"** file can be opened with a text editor and new custom sequences can be defined  for each admin's steam ID with the example format given in the file.

- **"defaults.txt"** file contains most of the customizable settings in the **project_smok**. Follow the instructions given in the file to start editing!

- **"prop_defaults.txt"** file contains prop spawning settings tables and flag explanations. Follow the instructions given in the file to start editing!

- **"botparams.txt"** file contains the parameters used for bots' sharing and looting abilities. Probabilistic values are normalized between 0 and 1.

- **"apocalypse_settings.txt"** file contains the settings to use for the _apocalypse_ event. Probabilistic values are normalized between 0 and 1.

- **"ghost_zombies_settings.txt"** file contains the settings to use for the _ghost zombies_ event. Probabilistic values are normalized between 0 and 1.
- 
- **"meteor_shower_settings.txt"** file contains the settings to use for the _meteor shower_ event. Probabilistic values are normalized between 0 and 1.

---
### Detailed Tables
---
- There are currently **2** big tables containing detailed information about the objects in the game.
  + **_NetPropTables_ : Contains network property members and their basic information for every base class defined.** 
     - **Example:** access to render color member information of props: _NetPropTables.CBaseEntity.m_clrRender_
  
  + **_EntityDetailTables_ : Contains most if not all the information on every entity class wiki page there is categorized under basic headers:(Description,Flags,KeyValues,Inputs,Outputs).**
     - **Example:** access to flags of prop_ragdoll class: _EntityDetailTables.prop.prop_ragdoll.flags_
     - **Example(Using _wiki_ command):** print key-value pairs of prop_dynamic class: *!wiki prop_dynamic keyvals* 
  
---
### Forums
---
- If you have encountered a bug, please [report it here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089552207/)

- If you have any suggestions, please [write them here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089554499/)

- If you are having trouble with the add-on or have any questions, please [ask here](https://steamcommunity.com/workshop/filedetails/discussion/2229460523/2965021152089567424/)
---
## Other Links

- [Admin System](https://steamcommunity.com/sharedfiles/filedetails/?id=214630948)
- [Admin Menu 2.0](https://steamcommunity.com/sharedfiles/filedetails/?id=1229957234)
- [VSLib](https://l4d2scripters.github.io/vslib/docs/index.html)
- [Squirrel Scripting Language](http://squirrel-lang.org/squirreldoc/)
- [Valve Wiki](https://developer.valvesoftware.com/wiki/Main_Page)
