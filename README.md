# project_smok
 - Repository for the workshop item [project_smok](https://steamcommunity.com/sharedfiles/filedetails/?id=2229460523) of L4D2
 
 - Following documentation is for the **new and updated commands**. Commands that aren't included in this documentation can be found in the [Admin System Guide](https://steamcommunity.com/sharedfiles/filedetails/?id=213591107). Be aware that **some of the commands that are not documented may behave differently** than the guide. 
 
## Commands
 - Commands can be used:
   + #### Via the menu:
     + To start using the menu:
       + Bind the menu to an unused key, for example **"k"**:
     
         <code>bind k "show_menu Menu"</code>
     
       + Open up the menu in-game by pressing the key bound in the previous step and use number keys to go throught the categorized sub-menus
       
       + **Example:** To make your character say a randomline originated by them, use the following key sequence: **k 6 4 1 1 1**
         
 
   + #### Via chat:
     + Add **"!"** before the command and  seperate arguments with **" " space character**
     + Chat has a **character limit**, in some cases its better to use the console
     
       <code>!command argument_1 argument_2 ...</code>
      
     + **Example:** Make Ellis say **"Humans 4, zombies nothin'!"**
 
       <code>!speak ellis hurrah21</code>
 
   + #### Via console:
     + Add **"scripted_user_func "** before the command and seperate it and arguments with **"," commas**
     + Allows pretty much unlimited amount of characters in a command
     + This option **restricts usage of some special characters** such as : **quotation marks " | commas , | equals signs = **
     
       <code>scripted_user_func command,argument_1,argument_2,...</code>
 
     + **Example:** Make Ellis say **"Humans 4, zombies nothin'!"**
 
       <code>scripted_user_func speak,ellis,hurrah21</code>
       
     + **Example:** Bind the **"randomline"** command to key **"j"** for making your survivor say a random line from Francis
     
       <code>bind j "scripted_user_func randomline,self,francis"</code>
---
### Entities
---
 - **ent** : Create an entity of the given class with given key-values
 
```cpp
       //Overloads:
       // Class names and their keys and possible values can be
       //      found through the Valve Developer Wikis and Hammer World Editor
       // value accepts following formats:
       //     For single values (int,float,str) :
       //           value = single_value
       //     For multi-values (angle,position,array) :
       //           value = {type:(ang,pos,str)}|val1|val2|val3
       ent {class} {key1}>{value1}&{key2}>{value2}...
       
       // Example (dynamic prop with Gift model with color rgb(90,30,60) and angles Pitch,Yaw,Roll->(-30,10,0) ): 
       ent prop_dynamic model>models\items\l4d_gift.mdl&rendercolor>str|90|30|60&angles>ang|-30|10|0
```
- **ent_rotate** : Rotate the targeted entity.
```cpp 
        //Overloads:
        ent_rotate {axis : (x,y,z)} {val : degrees}
        ent_rotate {val : degrees}   // axis = y
```

- **ent_push** : Push the targeted entity in given direction
```cpp 
      //Overloads:
      ent_push {scale} {direction: (forward,backward,left,up,right,left,random)} {pitch: degrees}
      ent_push   // scale = 10 , direction = forward , pitch = 0
```

- **ent_teleport** : Teleport the entity with the given name/ID to aimed location
```cpp 
      //Overloads:
      ent_teleport {entity_name}
      ent_teleport #{entity_ID}
```

- **rainbow** : Apply rainbow effect to targeted entity
```cpp 
       //Overloads: Assert (total_duration/color_duration) <= 2000
       rainbow {total_duration<=300.0} {color_duration>=0.05}  
       rainbow {total_duration<=300.0} 
```

- **grab** : Grabs aimed entity, also lets go if player is grabbing an entity

- **letgo** : Drops the held entity

- **yeet** : YEEEEEET

- **show_yeet_settings** : Shows grabbing settings in console

- **change_grab_method** : Change grabbing method between "Grab by aimed point" and "Grab by center"(basically hug the entity, some entity cause player to get stuck)

- **yeet_setting** : Change a grabbing setting
```cpp 
       //Overloads:
       // Check setting names with "show_yeet_settings"
       // "entid" setting cant be changed, because held entity's index is stored in this setting
       yeet_setting {setting} {new_value}  
       
       // Example: Change grabbing range to 400 ( pretty long arms )
       yeet_setting grabRange 400
       
       // Example: Change how far entity is gonna be held by player to 100 units
       yeet_setting grabDistMin 100
       
       // Example: Change how high below eye-level to hold the entity to -30 units ( negative values for above eye level )
       // default is 30, which means 30 units BELOW eye-level
       // -30 will make the entity held above player's head
       yeet_setting grabHeightBelowEyes -30
```

- **cleanup_car_alarms** : Remove all alarm cars and their annoying alarms

---
### Random and saved voices
---
- **randomline** : Speak a line 
```cpp
       //Overloads:
       randomline {speaker: survivor | random} {line_source: line_owner | random}
       randomline {speaker: survivor | random}             // line_source = speaker
       randomline              // speaker = self , line_source = self
```

- **save_line** : Save the given speaker and line path
```cpp
       //Overloads:
       save_line {speaker: survivor} {line_source: path_to_line}
```

- **speak_saved** : Speak the saved line
---
### Particle effects
---
- **particle** : Spawn a particle
```cpp 
       //Overloads:
       particle {name: particle_name | random}
```

- **attach_particle** : Attach a particle to targeted entity
```cpp
       //Overloads:
       attach_particle {name: particle_name | random} {duration: seconds}
       attach_particle {name: particle_name | random}    // duration = preferred_duration
```

- **update_attachment_preference** : Change preferred attachment duration
```cpp 
       //Overloads:
       update_attachment_preference {duration: seconds}
```

- **save_particle** : Save the given particle
```cpp 
       //Overloads:
       save_particle {name: particle_name} {duration: seconds}
       save_particle {name: particle_name} // duration = preferred_duration
``` 

- **spawn_particle_saved** : Spawn the saved particle

- **attach_particle_saved** : Attach the saved particle to targeted entity
---
### Custom sequences
---
- **speak_test** : Speak given line for given time
```cpp
       //Overloads:
       speak_test {speaker: character} {line: name_or_path} {duration: seconds}
       speak_test {speaker: character} {line: name_or_path} // duration = line_length
```

- **create_seq** : Create and save a sequence of lines with given delays
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

- **speak_custom** : Execute a saved custom sequence
```cpp
       //Overloads:
       speak_custom {speaker: character} {sequence}
       
       // Example: Speak the custom sequence of coach named "shootboy2" from the previous examples
       speak_custom coach shootboy2
```

- **delete_seq** : Delete a saved custom sequence
```cpp
       //Overloads:
       delete_seq {speaker: character} {sequence}
       
       // Example: Delete the sequence "shootboy1" from coach
       delete_seq coach shootboy1
```


- **show_custom_sequences** : Print out the saved custom sequences to console
```cpp
       //Overloads:
       show_custom_sequences {speaker: character}
       show_custom_sequences  // speaker = all_characters
```

- **loop** : Start a loop of sequences and lines 
```cpp
        //Overloads:
        loop {character} {line:name/path} {loop_length:seconds}
        loop {character} >{sequence:name} {loop_length:seconds}  // Add > before sequence name !
        
        // Example: Loop line "ledgehangfall03" for nick repeating every second
        loop nick ledgehangfall03 1
        
        // Example: Loop custom sequence named "yo" for francis repeating every 0.7 seconds
        loop francis >yo 0.7
```

- **loop_stop** : Stop looping for given character
```cpp
       //Overloads:
       loop_stop {character}
       loop_stop    // character = self
       
       // Example: Stop nick's looping
       loop_stop nick
```

- **seq_info** : Get scene and delay info about a custom sequence
```cpp
       //Overloads:
       seq_info {character} {sequence}
```

- **seq_edit** : Edit custom sequences
```cpp
       //Overloads:
       seq_edit {character} {sequence} {scene} {setting: (scene> , delay>)}{new_value}
       seq_edit {character} {sequence} >{scene_index} {setting: (scene> , delay>)}{new_value}
       
       //Example: Change first scene's name to hurrah01 in test_seq sequence for Nick
       seq_edit Nick test_seq >0 scene>hurrah01
```
---
### Apocalypse event
---
- **start_the_apocalypse** : Uh oh

- **pause_the_apocalypse** : Let the world have a break from the madness

- **show_apocalypse_settings** : Show apocalypse event's settings and values. Probabilities normalized: (0 = 0% , 1 = 100%)

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
expprob | 0.022      | probability of explosion 
breakprob | 0.04     | probability of entity being broken
doorlockprob | 0.02  | probability of doors getting locked, saferoom doors excluded
ropebreakprob | 0.05 | probability of a cable or sorts to be broken from its connection point
entprob | 0.6        | probability of an entity being chosen within the "maxradius" around a randomly chosen survivor
debug | 0            | Print which entities are effected (0 = off , 1 = on) 
   
- **apocalypse_setting** : Change apocalypse event settings
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
### Piano
---
- **piano_keys** : Place 25 piano keys starting at looked location placing them to the right

- **remove_piano_keys** : Removes all piano key spawns
---
### Microphones and speakers
---
- **microphone** : Create an entity to be used as microphone 
```cpp
       //Overloads:
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} {hearing_range} {connected_speaker}
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} {hearing_range} // speaker can be connected later
       microphone {effect:(standard,no_effect,very_small,small,tiny,loud,loud_echo} // hearing_range = 120
       microphone         // effect = standard, hearing_range = 120
    
```

- **speaker** : Creates an entity to be used as a speaker

- **speaker2mic** : Connect a speaker to a microphone
```cpp
       //Overloads:
       // These ID's and names can be found from the console summary or with display_mics_speakers command
       // ID's need to be specified with a # before the number
       speaker2mic #{speakerID} #{micID}
       speaker2mic {speaker_name} {mic_name} 
     
       // Example: Connect speaker at index 33 to microphone named "myMic"
       speaker2mic #33 myMic
```

- **display_mics_speakers** : Get information about the spawned microphones and speakers
---
### Explosions
---
- **explosion** : Create a delayed explosion at aimed location, with a particle effect until explosion

- **show_explosion_settings** : Show current *explosion* command settings in console

Setting | Default Value | Description
------------ | ------------- | -------------
delay | 1 | delay for explosion in seconds
effect_name | "flame_blue" | [particle effect name](https://github.com/semihM/project_smok/blob/master/2229460523/scripts/vscripts/particle_names/particlenames.nut) to spawn until explosion. 
radiusmin | 300 | explosion's minimum radius to damage and push entities in
radiusmax | 450 | explosion's maximum radius to damage and push entities in
dmgmin | 10 | minimum damage to give entities in the radius
dmgmax | 30 | maximum damage to give entities in the radius
maxpushspeed | 10000 | maximum speed an explosion can push and entity away 

- **explosion_setting** : Update *explosion* command settings
```cpp
       //Overloads:
       // Check out the settings and their values with show_explosion_settings
       explosion_setting {setting} {new_value}
       
       // Example: Change delay from 1s to 5s
       explosion_setting delay 5
```
---
### Other
---
- **ladder_team** : Change teams of ladders
```cpp
       //Overloads:
       // "reset" to reset ladders back to their default teams
       ladder_team {team : (all,survivor,infected,spectator,l4d1) | reset}
    
```

- **invisible_walls** : Enable/Disable **most** if not all of the invisible walls around. Some of them can not be disabled.
```cpp
       //Overloads:
       invisible_walls {state: (disable, enable)} {apply_to_all_possible_walls}
       
       //Example: Try disabling all invisible walls/clips
       invisible_walls disable all
```
---
### Debug and script related 
---
- **debug_info** : Dump information about objects
```cpp
       //Overloads:
       debug_info player      // Show information about whoever calls this function
       debug_info             // Show information about targeted object
    
```

- **add_script_auth** : Give authorization to an admin to use "script" command
```cpp
       //Overloads:
       // ONLY THE HOST can give script authority to others
       add_script_auth {character}
    
```

- **remove_script_auth** : Take away the authorization from admin to use "script" command
```cpp
       //Overloads:
       // Host's script authority can not be taken away
       remove_script_auth {character}
    
```
- **and more...**

## Extra
---
### Changing settings, adding custom responses without launching the game
---
- AdminSystem keeps its configuration files in the **"..\Left 4 Dead 2\left4dead2\ems\admin system"** directory.

- This directory contains **configurations(settings.txt)**, **admins(admins.txt)**, **banned players(banned.txt)**, **script authorizations(scriptauths.txt)** and **custom responses(custom_responses.json)**. Which can all be edited manually (Be careful while formatting! Keep a differently named copy before changing anything!)

- **"custom_responses.json"** file can be opened with a text editor and new custom sequences can be defined  for each admin's steam ID with the example format given in the file.

- **apocalypse_settings.txt** file contains the settings to use for apocalypse event.
---
### Bug reports
---
- Before creating an issue, please contact to the [developer](http://steamcommunity.com/profiles/76561198095804696)
---
### Links
---
- [Admin System](https://steamcommunity.com/sharedfiles/filedetails/?id=214630948)
- [Admin Menu 2.0](https://steamcommunity.com/sharedfiles/filedetails/?id=1229957234)
- [VSLib](https://l4d2scripters.github.io/vslib/docs/index.html)
