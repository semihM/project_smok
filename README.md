# project_smok
Repository for the workshop item [project_smok](https://steamcommunity.com/sharedfiles/filedetails/?id=2229460523) of L4D2

## Commands

### Entities

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

### Random and saved voices

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

### Particle effects

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

### Custom sequences

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
```

- **delete_seq** : Delete a saved custom sequence
```cpp
       //Overloads:
       delete_seq {speaker: character} {sequence} 
```

- **speak_custom** : Execute a saved custom sequence
```cpp
       //Overloads:
       speak_custom {speaker: character} {sequence} 
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
```

- **loop_stop** : Stop looping for given character
```cpp
       //Overloads:
       loop_stop {character}
       loop_stop    // character = self
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

### Apocalypse event

- **start_the_apocalypse** : Uh oh

- **pause_the_apocalypse** : Let the world have a break from the madness

- **show_apocalypse_settings** : Show apocalypse event's settings and values

- **apocalypse_setting** : Change apocalypse event settings
```cpp
       //Overloads:
       // Check out the settings and their values with show_apocalypse_settings
       apocalypse_setting {setting : (entprob,dmgprob,maxradius,minspeed,maxspeed,...)} {new_value: float/integer}
```

### Piano

- **piano_keys** : Place 25 piano keys starting at looked location placing them to the right

- **remove_piano_keys** : Removes all piano key spawns

### Other

- **ladder_team** : Change teams of ladders
```cpp
       //Overloads:
       // "reset" to reset ladders back to their default teams
       ladder_team {team : (all,survivor,infected,spectator,l4d1) | reset}
    
```

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
    
```

- **display_mics_speakers** : Get information about the spawned microphones and speakers

- **explosion** : Create a delayed explosion at aimed location, with a particle effect until explosion

### Debug and script related 

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

### Changing settings, adding custom responses without launching the game

- AdminSystem keeps its configuration files in the **"..\Left 4 Dead 2\left4dead2\ems\admin system"** directory.

- This directory contains **configurations(settings.txt)**, **admins(admins.txt)**, **banned players(banned.txt)**, **script authorizations(scriptauths.txt)** and **custom responses(custom_responses.json)**. Which can all be edited manually (Be careful while formatting! Keep a differently named copy before changing anything!)

- **"custom_responses.json"** file can be opened with a text editor and new custom sequences can be defined  for each admin's steam ID with the example format given in the file.

- **apocalypse_settings.txt** file contains the settings to use for apocalypse event.

### Bug reports

- Before creating an issue, please contact to the [developer](http://steamcommunity.com/profiles/76561198095804696)
