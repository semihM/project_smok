# project_smok
Repository for the workshop item [project_smok](https://steamcommunity.com/sharedfiles/filedetails/?id=2229460523) of L4D2

## Commands
 - **ent** : Create an entity of the given class with given key-values
 
```cpp
       //Overloads:
       // Class names and their keys and possible values can be
       //      found through the Hammer World Editor
       // value accepts following formats:
       //     For single values (int,float,str) :
       //           value = single_value
       //     For multi-values (angle,position,array) :
       //           value = {type:(ang,pos,str)}|val1|val2|val3
       ent {class} {key1}->{value1}&{key2}->{value2}...
       
       // Example (dynamic prop with Gift model with color rgb(90,30,60) ): 
       ent prop_dynamic model->models\items\l4d_gift.mdl&rendercolor->str|90|30|60
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
      ent_push {scale} {direction: (forward,backward,left,up,...)} {pitch: degrees}
      ent_push   // scale = 10 , direction = forward , pitch = 0
```

- **rainbow** : Apply rainbow effect to targeted entity
```cpp 
       //Overloads: Assert (total_duration/color_duration) <= 2000
       rainbow {total_duration<=300.0} {color_duration>=0.05}  
       rainbow {total_duration<=300.0} 
```

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

- **debug_info** : Dump information about targeted entity to the console

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
       delete_seq {speaker: character} {name: saved_name} 
```

- **speak_custom** : Execute a saved custom sequence
```cpp
       //Overloads:
       speak_custom {speaker: character} {name: saved_name} 
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


- **start_the_apocalypse** : Uh oh

- **pause_the_apocalypse** : Let the world have a break from the madness

- **ladder_team** : Change teams of ladders
```cpp
       //Overloads:
       // "reset" to reset ladders back to their default teams
       ladder_team {team : (all,survivor,infected,spectator,l4d1) | reset}
    
```

- **piano_keys** : Place 25 piano keys starting at looked location placing them to the right

- **remove_piano_keys** : Removes all piano key spawns

- **and more...**
