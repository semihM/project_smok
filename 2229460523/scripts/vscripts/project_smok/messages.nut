/***********************\
*  MESSAGE HELPER TABLE  *
\***********************/
::Messages <- {};

/*********************\
*  MESSAGE TYPE ENUM  *
\*********************/
::Messages.MessageType <-
{
    BASE = "project_smok_Message_Base"
    ERROR = "project_smok_Message_Error"
    WARNING = "project_smok_Message_Warning"
    INFO = "project_smok_Message_Info"
    DOCS = "project_smok_Message_Docs"
}

/*********************\
*  BUILT-IN MESSAGES  *
\*********************/
::Messages.SetBIM <- function(tbl)
{
    local t = 
    {
        // Event messages
        Events = 
        {
            OnRoundStart =
            {
                AdminLoadFiles =
                {
                    LoadAdmins = function()
                    {
                        printl("[Admins] Loading admin list...");
                    }
                    LoadScriptAuths = function()
                    {
                        printl("[Script-auth] Loading script authorization list...");
                    }
                    LoadBanned = function()
                    {
                        printl("[Banned] Loading ban list...");
                    }
                    LoadSettings = function()
                    {
                        printl("[Settings] Loading settings...");
                    }
                    CreateSettings = function()
                    {
                        printl("[Settings] Creating the settings file for the first time...");
                    }
                    LoadApocalypseSettings = function()
                    {
                        printl("[Apocalypse-Settings] Loading apocalypse settings...");
                    }
                    CreateApocalypseSettings = function()
                    {
                        printl("[Apocalypse-Settings] Creating the setting file for the first time...");
                    }
                    LoadMeteorShowerSettings = function()
                    {
                        printl("[Meteor_Shower-Settings] Loading meteor shower settings...");
                    }
                    CreateMeteorShowerSettings = function()
                    {
                        printl("[Meteor_Shower-Settings] Creating the setting file for the first time...");
                    }
                    CreateVars = function()
                    {
                        printl("[Vars] Creating new vars table...");
                    }
                    RestoreVars = function()
                    {
                        printl("[Vars] Restoring existing vars table...");
                    }
                    EnableSpecAndOther = function()
                    {
                        printl("[Spectators] Enabling commands for spectator admins...");
                    }
                }
            }
            
            OnPlayerConnected =
            {
                RestoreModels =
                {
                    RestoringLast = function(name,mdl)
                    {
                        printl("[Models] Restoring last model of " + name + " to " + mdl)
                    }
                    RestoringOrg = function(name)
                    {
                        printl("[Models] Restoring original model of " + name);
                    }
                }
            }

            OnPlayerJoined =
            {
                AdminBanCheck =
                {
                    BannedMessage = function()
                    {
                        return " You are banned from this server for being a dumbarse";
                    }
                }
            }

        }

        //// Basic
        // Checks
        IsPrivileged = 
        {
            NoAccess = function(player)
            {
                ::VSLib.Utils.PrintToAllDel("You ain't got no access to admin commands " + player.GetName() + "(" + player.GetSteamID() + ")!");
            }
        }
        IsAdmin = 
        {
            NoAccess = function(player)
            {
                ::VSLib.Utils.PrintToAllDel("Sorry " + player.GetName() + "(" + player.GetSteamID() + "), only admins have access to this command!");
            }
        }

        //Admin
        AdminMode =
        {
            Enabled = function()
            {
                ::VSLib.Utils.PrintToAllDel("Admin mode enabled, only Admins have access to Admin commands.");
            }

            Disabled = function()
            {
                ::VSLib.Utils.PrintToAllDel("Admin mode disabled, everyone has access to Admin commands.");
            }
        }
        Admin =
        {
            HostOnlyRemoval = function()
            {
                ::VSLib.Utils.PrintToAllDel("Sorry, only the host can remove Admins.");
            }
            AlreadyAdmin = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s is already an Admin.", name);
            }
            Add = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been given Admin control.", name);
            }
            Remove = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s has lost Admin control.", name);
            }
        }

        //Script Auth
        HasScriptAuth = 
        {
            NoAccess = function(player)
            {
                ::VSLib.Utils.PrintToAllDel("Sorry " + player.GetName() + "(" + player.GetSteamID() + "), script authorization is required for this command!");
            }
        }
        ScriptAuth =
        {
            HostOnly = function()
            {
                ::VSLib.Utils.PrintToAllDel("Sorry, only the host can give/take away script authorization.");
            }
            AlreadyAuthed = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s already has script authorization.", name);
            }
            AlreadyNone = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s already doesn't have script authorization.", name);
            }
            Given = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been given script authorization.", name);
            }
            Taken = function(name)
            {
                ::VSLib.Utils.PrintToAllDel("%s has lost their script authorization.", name);
            }
        }

        //Kick
        KickPlayer = 
        {
            NoAdminKick = function()
            {
                ::VSLib.Utils.PrintToAllDel("Sorry, you can't kick an Admin.");
            }
            Idle = function(player)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been kicked for being idle too long.", player.GetName());
            }
            KickedMessage = function()
            {
                return " You've been kicked for being idle too long";
            }
            ChatKickedMessageReasoned = function(name,kicker,Reason)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been kicked by %s due to %s.", name, kicker, Reason);
            }
            ChatKickedMessage = function(name,kicker)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been kicked by %s.", name, kicker);
            }
        }

        //Ban
        BanPlayer =
        {
            NoAdminBan = function()
            {
                ::VSLib.Utils.PrintToAllDel("Sorry, you can't ban an Admin.");
            }
            ChatBannedMessageReasoned = function(name,kicker,Reason)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been banned by %s due to %s.", name, kicker, Reason);
            }
            ChatBannedMessage = function(name,kicker)
            {
                ::VSLib.Utils.PrintToAllDel("%s has been banned by %s.", name, kicker);
            }
        }

        // Generic
        NotACharacter = function(name)
        {
            return name + " is not a character name";
        }
        NoTraceHits = function()
        {
            return "No looked entity found";
        }

        //// Special messages
        CMD = 
        {
            // Basic settings
            BotSharingPreference = function(name,newstate)
            {
                return name + " set bot sharing preference to " + ( newstate ? COLOR_BRIGHT_GREEN + "Enabled" + COLOR_DEFAULT:COLOR_ORANGE + "Disabled" + COLOR_DEFAULT);
            }
            EnableKindness = function(name,thinkadder)
            {
                return name + " " + COLOR_OLIVE_GREEN + "->" + COLOR_BRIGHT_GREEN + "Enabled" + COLOR_DEFAULT + " bot kindness adder(" + COLOR_BRIGHT_GREEN + "#" + thinkadder.GetIndex() + COLOR_DEFAULT + ") named " + thinkadder.GetName();
            }
            DisableKindness = function(name)
            {
                return name + " " + COLOR_OLIVE_GREEN + "->" + COLOR_ORANGE + " Disabled" + COLOR_DEFAULT + " bot kindness adders";
            }

            EnableTankRockPush = function()
            {
                return "Tank rock's push effect is now " + COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT;
            }
            DisableTankRockPush = function()
            {
                return "Tank rock's push effect is now " + COLOR_ORANGE + "disabled" + COLOR_DEFAULT;
            }
            EnableTankRockRandomModel = function()
            {
                return "Tank rock's random models are now " + COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT;
            }
            DisableTankRockRandomModel = function()
            {
                return "Tank rock's random models are now " + COLOR_ORANGE + "disabled" + COLOR_DEFAULT;
            }
            EnableTankRockPhys = function()
            {
                return "Tank rock's using physics is now " + COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT;
            }
            DisableTankRockPhys = function()
            {
                return "Tank rock's using physics is now " + COLOR_ORANGE + "disabled" + COLOR_DEFAULT;
            }

            EnableJockeys = function()
            {
                return "Little bastards are back...";
            }
            DisableJockeys = function()
            {
                return "Be gone vile man, be gone from me!";
            }

            EnableModelKeeping = function()
            {
                return "Last model is going to be kept for the next chapter.";
            }
            DisableModelKeeping = function()
            {
                return "Last model won't be kept for the next chapter.";
            }

            OutputState = function(newstate)
            {
                return "Outputs will be printed to " + ( newstate ? COLOR_BRIGHT_GREEN + "chat":COLOR_ORANGE + "console");
            }

            TimeScale =  
            {
                ScaleTooSmall = function()
                {
                    return "You can't enter a value less than 0.1!";
                }
                ScaleTooHigh = function()
                {
                    return "You can't enter a value more than 10.0!";
                }

                Success = function(sc)
                {
                    return "Changed timescale to " + sc;
                }
            }

            Blocker =
            {
                Success = function(state,other)
                {
                    return state + "d env_player_blocker entities" + (other !=null ? ", including env_physics_blocker and similar ones": " ");
                }
            }

            // Other
            GrabYeet =
            {
                UnknownAttachmentPoint = function(val)
                {
                    return "No attachment point named " + COLOR_ORANGE + val + COLOR_DEFAULT + " was found.";
                }

                SettingSuccess = function(setting,oldval,newval)
                {
                    return "Changed yeeting setting " + setting + " from " + oldval + " to " + newval.tostring();
                }
            }

            DummyEntity =
            {
                Success = function(ent,mdl)
                {
                    return "Created dummy " + COLOR_BRIGHT_GREEN + "#" + ent.GetIndex() + COLOR_DEFAULT + " with model " + mdl;
                }
            }

            EntFire =
            {
                Success = function(act,val,id)
                {
                    return "Firing input (" +  act + ")" + (val == "" ? " " : " with params (" + COLOR_ORANGE + val + COLOR_DEFAULT + ") ") + "for entity " + COLOR_BRIGHT_GREEN + "#" + id;
                }
                Failure = function()
                {
                    return "Couldn't find an object to fire input of";
                }
            }

            KeyVal =
            {
                Success = function(key,val,id)
                {
                    return "Changed " + COLOR_OLIVE_GREEN + key + COLOR_DEFAULT + " value of " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " to " + val;
                }
            }

            Ladders =
            {
                Cache = function()
                {
                    printl("[Cache] Caching ladder teams...");
                }

                Reset = function()
                {
                    return "Resetting ladder teams";
                }

                Change = function(team)
                {
                    return "Changed ladder teams to " + COLOR_BRIGHT_GREEN + team.tostring();
                }
            }

            MeteorShowerSettings = 
            {
                StartingMessages = ["How is the weather ?","Free shower ?!","What is that noise ?"]

                ModelQuotesMissing = function()
                {
                    return "Model name should be given in quotes. Example" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " \"models/props_interiors/tv.mdl\"";
                }
                ModelQuotesFormat = function()
                {
                    return "Bad string format. Quotes have to be closed. Example" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " \"models/props_interiors/tv.mdl\"";
                }
                ModelCharacterOutsideQuotes = function()
                {
                    return "Bad string format. Model name should be given in quotes. Example" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " \"models/props_interiors/tv.mdl\"";
                }
                Success = function(name,setting,old,new)
                {
                    return name + " " + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " Changed meteor shower setting " + COLOR_ORANGE + setting + COLOR_DEFAULT + " from " + COLOR_OLIVE_GREEN + old + COLOR_DEFAULT + " to " + COLOR_BRIGHT_GREEN + new;
                }
            }

            ApocalypseSettings = 
            {
                StartingMessages = ["Something doesn't feel right...","Real apocalypse is only just starting...","Who is locking these doors?...","monkaOMEGA...","Shhh... Do you hear that ?"]

                Extras = [" or has it ?",""," only for a while...",""]

                Ending = "Apocalypse has been postponed..."

                Success = function(name,setting,old,new)
                {
                    return name + " " + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " Changed apocalypse setting " + COLOR_ORANGE + setting + COLOR_DEFAULT + " from " + COLOR_OLIVE_GREEN + old + COLOR_DEFAULT + " to " + COLOR_BRIGHT_GREEN + new;
                }
            }

            CustomSequences =
            {
                //Generic
                NoSeqFound = function(character,seq_name)
                {
                    return "No custom sequence found for " + character + " named " + seq_name;
                }
                NoneFound = function(character)
                {
                    return "No custom sequences created for " + character;
                }
                InfoString = function(character,sequencename,msg)
                {
                    return "Sequence info " + character + "." + sequencename + msg;
                }
                
                //Create
                CreateFormat = "Arguments should be follow the format" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " character sequence_name scene1 delay1 scene2 delay2 ..."
                
                SkipDuplicate = function(sequencename,charname)
                {
                    return "Skipping creating sequence " + sequencename + " for " + charname + ", sequence already exists!";
                }

                CreateForAll = function(sequencename)
                {
                    return "Created sequence for all characters named " + sequencename;
                }

                AlreadyExists = function(sequencename,character)
                {
                    return "Sequence " + sequencename + " already exists for " + character + "!";
                }

                CreateSuccess = function(character,sequencename)
                {
                    return "Created sequence for " + character + " named " + sequencename;
                }
                
                //Delete
                DeleteSuccess = function(character,sequencename)
                {
                    return "Deleted custom response for " + character + " named " + sequencename;
                }

                //Edit
                EditFormat = "Setting should be in format scene>new_name OR delay>x"
                
                NoSceneFound = function(scene)
                {
                    return "No scene named " + scene + " was found";
                }
                EditSuccess = function(character,sequencename,setting,index,old,new)
                {
                    return "Changed " + character + "." + sequencename + "." + setting + "s[" + index + "] from \n " + old + " to " + new.tostring();
                }

                //File
                FileMissing = function(path)
                {
                    return path + " file is missing, changes will only be applied for current session/chapter!";
                }
                CreatingFile = function()
                {
                    printl("[Custom] Creating custom response file for the first time...");
                }
                AddingMissingAdminTables = function(admin)
                {
                    printl("[Custom] Creating default response table for new admin -> " + admin);
                }
            }

            Loops =
            {
                ValidFormats = "Arguments should be in one of the following formats" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " \n1){character} >{sequence} {length} \n2){character} {line} {length} "
            
                AlreadyLooping = function(character)
                {
                    return character + " is already in a talking loop.";
                }

                ShorterLength = function(blanksec,character,sequencename,looplength)
                {
                    return "Sequence length is at least " + COLOR_OLIVE_GREEN + (blanksec*-1).tostring() + COLOR_DEFAULT + " seconds shorter than sequence. " + character + " " + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + sequencename + " " + looplength;
                }

                Start = function(character,seq)
                {
                    return COLOR_BRIGHT_GREEN + "Started" + COLOR_DEFAULT + " loop for " + character + " named " + seq;
                }
                Stop = function(character)
                {
                    return COLOR_ORANGE + "Stopped" + COLOR_DEFAULT + " loop for " + character;
                }
            }
            
            RandomLine = 
            {
                SaveAndSpeak = function(randomline_path,targetname)
                {
                    return "Saving line " + randomline_path + " for " + targetname;
                }
            }

            ModelSaving = 
            {
                State = function(newstate)
                {
                    return "Random model saving is now " + ( newstate ? COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT:COLOR_ORANGE + "disabled" + COLOR_DEFAULT);
                }

                Success = function(classname,modelname)
                {
                    return "Saved model " + COLOR_OLIVE_GREEN + modelname + COLOR_DEFAULT + " as " + COLOR_ORANGE + classname;
                }

                NoneSaved = function(name)
                {
                    return "No saved model was found for " + COLOR_ORANGE + name;
                }

                SpawnSaved = function(id,classname,modelname)
                {
                    return "Spawned "+ COLOR_BRIGHT_GREEN + "#" + id + COLOR_ORANGE + " " + classname + COLOR_DEFAULT + ", model->" + COLOR_OLIVE_GREEN + modelname;
                }
                FailureSpawn = function(classname,modelname)
                {
                    return "Couldn't spawn model " + COLOR_OLIVE_GREEN + modelname + COLOR_DEFAULT + " as " + COLOR_ORANGE + classname;
                }

                Information = function(mdltbl)
                {
                    return "Class" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + mdltbl.classname + ", Model" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + mdltbl.modelname;
                }
            }

            LineSaving =
            {    
                State = function(newstate)
                {
                    return "Random line saving is now " + ( newstate ? COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT:COLOR_ORANGE + "disabled" + COLOR_DEFAULT);
                }

                Success = function(targetname,linesource)
                {
                    return "Saved line " + linesource + " for " + targetname;
                }
                
                NoneSaved = function(name)
                {
                    return "No saved line was found for " + name;
                }

                MakeSpeak = function(targetname,randomline_path)
                {
                    return "Making " + targetname + " speak saved line " + randomline_path;
                }

                Information = function(lineinfo)
                {
                    return "Speaker" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + lineinfo.target + ", Line" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + lineinfo.source;
                }
            }

            CustomSpeak =
            {
                TestSuccess = function(character,scene_name,trimend)
                {
                    return character + " speaking " + scene_name + " for " + trimend + " seconds";
                }
                
                Success = function(character,seq_name)
                {
                    return character + " speaking sequence " + seq_name;
                }
            }

            Models = 
            {
                ChangeSuccess = function(ind,mdl)
                {
                    return "Changed model of " + COLOR_BRIGHT_GREEN + "#" + ind + COLOR_DEFAULT + " to " + mdl;
                }

                ScaleChangeSuccess = function(ind,mdl)
                {
                    return "Changed model scale of " + COLOR_BRIGHT_GREEN + "#" + ind + COLOR_DEFAULT + " to " + mdl;
                }

                RestoredOrgSelf = function()
                {
                    return "Restored original model";
                } 
                RestoredOrgOther = function(name)
                {
                    return "Restored original model for " + name;
                } 
            }

            Particles = 
            {
                UnknownParticle = function(name)
                {
                    return "No particle named " + name + " was found.";
                }
                SpawnSuccess = function(particle,eyeposition)
                {
                    return "Spawned " + particle + " at " + eyeposition.x + "," + eyeposition.y + "," + eyeposition.z;
                }
                SpawnSavedSuccess = function(particle,eyeposition)
                {
                    return "Spawned saved " + particle + " at " + eyeposition.x + "," + eyeposition.y + "," + eyeposition.z;
                }
                
                AttachSuccess = function(particle,particleID,target,duration)
                {
                    return "Attached " + particle + " (" + COLOR_BRIGHT_GREEN + "#" + particleID + COLOR_DEFAULT + ") to " + COLOR_BRIGHT_GREEN + "#" + target + COLOR_DEFAULT + " for " + duration + " seconds";
                }
                AttachSavedSuccess = function(particle,particleID,target,duration)
                {
                    return "Attached saved " + particle + " (" + COLOR_BRIGHT_GREEN + "#" + particleID + COLOR_DEFAULT + ") to " + COLOR_BRIGHT_GREEN + "#" + target + COLOR_DEFAULT + " for " + duration + " seconds";
                }
                AttachmentPoint = function(newstate)
                {
                    return "Particles will be attached to " + ( newstate ? " aimed point.":" aimed object's origin.")
                }
                AttachmentDuration = function(old,new)
                {
                    return "Updated attachment duration from " + old + " to " + new;
                }

                SaveSuccess = function(source,duration)
                {
                    return "Saved particle " + source + " with duration " + duration + " seconds";
                }
                SaveState = function(newstate)
                {
                    return "Random particle saving is now " + ( newstate ? COLOR_BRIGHT_GREEN + "enabled" + COLOR_DEFAULT:COLOR_ORANGE + "disabled" + COLOR_DEFAULT);
                }

                NoneSaved = function()
                {
                    return "No saved particle was found";
                }

                Information = function(tbl)
                {
                    return "Name" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + tbl.source + "\nDuration" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + tbl.duration;
                }
            }

            Explosions =
            {
                SettingSuccess = function(setting,old,new)
                {
                    return "Changed explosion setting " + setting + " from " + old + " to " + new;
                }

                FailedParticle = function()
                {
                    printl("[Explosion-Warning] Could not create info_particle_system entity.");
                }

                FireworkLength = function()
                {
                    return "[Explosion-Warning] Fireworks disappear after 7 seconds"
                }
            }

            MicSpeaker =
            {
                //Mic
                MicEffects = function()
                {
                    return "Available mic effects" + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " no_effect,standard,very_small,small,tiny,loud,loud_echo";
                }
                MicKeyValsInvalid = function()
                {
                    return "Failed to create a mic with given values.";
                }
                MicrophoneSuccess = function(micent)
                {
                    return "Created a microphone(" + COLOR_BRIGHT_GREEN + "#" + micent.GetIndex() + COLOR_DEFAULT + ") named " + micent.GetName();
                }

                //Speaker
                SpeakerIDInvalid = function()
                {
                    return "Invalid speaker index. Use " + COLOR_BRIGHT_GREEN + "!display_mics_speakers" + COLOR_DEFAULT + " to see spawned speakers";
                }
                SpeakerKeyValsInvalid = function()
                {
                    return "Failed to create a speaker with given values.";
                }
                SpeakerClassInvalid = function()
                {
                    return "Speaker's should be a " + COLOR_ORANGE + "\"info_target\"" + COLOR_DEFAULT + " class entity";
                }
                SpeakerSuccess = function(speakerent)
                {
                    return "Created a speaker " + COLOR_BRIGHT_GREEN + "#" + speakerent.GetIndex() + COLOR_DEFAULT + " named " + speakerent.GetName();
                }

                //Connection
                ClassesInvalid = function()
                {
                    return "Speaker's class should be \"info_target\", mic's class should be \"env_microphone\"";
                }
                ConnectSuccess = function(speakerid,micid)
                {
                    return "Connected speaker " + COLOR_BRIGHT_GREEN + "#" + speakerid + COLOR_DEFAULT + " to mic " + COLOR_BRIGHT_GREEN + "#" + micid;
                }

                //Information
                MicInfo = function(id,pos,dist)
                {
                    return "Mic " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " at (" + pos.x.tointeger() + " " + pos.y.tointeger() + " " + pos.z.tointeger() + "), distance " + COLOR_ORANGE + dist.tofloat().tointeger() + COLOR_DEFAULT + " units";
                }
                SpeakerInfo = function(id,pos,dist)
                {
                    return "Speaker " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " at (" + pos.x.tointeger() + " " + pos.y.tointeger() + " " + pos.z.tointeger() + "), distance " + COLOR_ORANGE + dist.tofloat().tointeger() + COLOR_DEFAULT + " units";
                }
                NoneFound = function()
                {
                    return "No mic or speaker found";
                }
            }

            Piano =
            {
                Failed = function()
                {
                    return "Couldn't spawn piano keys";
                }
                Success = function(startkey)
                {
                    return "Spawned piano keys starting with " + COLOR_BRIGHT_GREEN + "#" + startkey.GetIndex() + COLOR_DEFAULT + " at " + startkey.GetLocation();
                }
                Remove = function()
                {
                    return "Deleted all piano keys";
                }
            }

            Prop =
            {
                Failed = function(classname)
                {
                    return "Couldn't create " + classname;
                }

                Success = function(classname,ent)
                {
                    return "Created " + classname + " entity " + COLOR_BRIGHT_GREEN + "#" + ent.GetIndex();
                }

                SuccessParented = function(classname,ents)
                {
                    local childrenents = "";
                    foreach(i,ent in ents.slice(1,ents.len()))
                    {
                        childrenents = COLOR_BRIGHT_GREEN + "#" + ent.GetIndex() + COLOR_DEFAULT;
                        if(i != ents.len() - 2)
                        {
                            childrenents += ", ";
                        }
                    }
                    return "Created " + classname + " parent entity " + COLOR_BRIGHT_GREEN + "#" + ents[0].GetIndex() + COLOR_DEFAULT + " with children:\n" + childrenents;
                }

                SuccessDoor = function(ent)
                {
                    return "Created a door (" + COLOR_BRIGHT_GREEN + "#" + ent.GetIndex() + COLOR_DEFAULT + ") named " + ent.GetName();
                }
                FailureDoor = function(mdl)
                {
                    return "Failed to create a door with model-> " + COLOR_ORANGE + mdl;
                }

                SettingSuccess = function(typ,setting,vf,val)
                {
                    return "Updated " + COLOR_ORANGE + typ + COLOR_DEFAULT + " spawn setting " + COLOR_OLIVE_GREEN + setting + COLOR_ORANGE + "." + COLOR_OLIVE_GREEN + vf + COLOR_DEFAULT  + " to " + COLOR_ORANGE + val;
                }
                
            }

            FireEx = 
            {
                Success = function(e,p,s)
                {
                    return "Fire Extinguisher " + COLOR_BRIGHT_GREEN + "#" + e + COLOR_DEFAULT + ", particle " + COLOR_BRIGHT_GREEN + "#" + p + COLOR_DEFAULT + ", sound " + COLOR_BRIGHT_GREEN + "#" + s;
                }
            }

            Ent =
            {
                EntityCreate = function(id,classname,pos,ang,keyvals)
                {
                    return "Created entity(" + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + ") with table-> \n" + keyvals;
                }

                Failure = function()
                {
                    return "Failed to create an entity";
                }
                
                Success = function(classname,id,keyvals)
                {
                    return "Created " + classname + " entity(" + COLOR_BRIGHT_GREEN + "#" + id  + COLOR_DEFAULT +  ") with table:\n" +  keyvals;
                }

                TypeUnknown = function(typ,key)
                {
                    return "Unrecognized type <" + typ + "> for key-> " + key;
                }
            }

            PropSpawn =
            {
                Start = function(name)
                {
                    return "Prop spawn settings for " + COLOR_OLIVE_GREEN + name + COLOR_DEFAULT + ":\n";
                }
                Type = function(typename)
                {
                    return "Type <" + COLOR_ORANGE + typename + COLOR_DEFAULT + ">\n";
                }
                Details = function(setting,val)
                {
                    switch(typeof val)
                    {
                        case "table":
                        {  
                            return "\t" + COLOR_ORANGE + setting + COLOR_OLIVE_GREEN + " -> " + COLOR_BRIGHT_GREEN + ::VSLib.Utils.GetTableString(val) + COLOR_DEFAULT + "\n";
                        }
                        case "array":
                        {  
                            return "\t" + COLOR_ORANGE + setting + COLOR_OLIVE_GREEN + " -> " + COLOR_BRIGHT_GREEN + ::VSLib.Utils.ArrayString(val)  + COLOR_DEFAULT + "\n";
                        }
                        default:
                        {
                            return "\t" + COLOR_ORANGE + setting + COLOR_OLIVE_GREEN + " -> " + COLOR_BRIGHT_GREEN + val + COLOR_DEFAULT + "\n";
                        }
                    }
                }
            }

            Force =
            {
                TeleportSuccess = function(id,to)
                {
                    return "Teleported " + COLOR_BRIGHT_GREEN + id + COLOR_DEFAULT + " to " + to;
                }

                PushSuccess = function(id,scalefactor,direction,pitchofeye)
                {
                    return "Pushing " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " with scale->" + scalefactor + ", direction->" + direction + ", pitch->" + pitchofeye;
                }

                MoveSuccess = function(id,units,direction,pitchofeye)
                {
                    return "Moving " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " " + units + " units " + direction + ", pitch->" + pitchofeye;
                }

                SpinSuccess = function(id,scalefactor,direction)
                {
                    return "Spinning " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " with scale->" + scalefactor + ", direction->" + direction;
                }

                RotateSuccess = function(id,newangles)
                {
                    return "Rotated " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + ", new angles->" + newangles.ToKVString();
                }
            }

            RainbowSuccess = function(duration,intervals,id)
            {
                return "Applying rainbow effect to " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " for " + duration + " seconds, " + intervals + " each color";
            }

            Color = function(r,g,b,a,id)
            {
                return "Changed color of " + COLOR_BRIGHT_GREEN + "#" + id + COLOR_DEFAULT + " to rgba(" + r + "," + g + "," + b + "," + a + ")";
            }

            Debug = 
            {
                FlagLookupFailure = function(val)
                {
                    return COLOR_ORANGE + val + COLOR_DEFAULT + " value couldn't be parsed as " + COLOR_OLIVE_GREEN + " integer";
                }
                FlagLookupSuccess = function(flags)
                {
                    if(flags == "")
                    {
                        return COLOR_ORANGE + " No flags found " + COLOR_DEFAULT + "matching the given value.";
                    }
                    return COLOR_BRIGHT_GREEN + "Found"+ COLOR_ORANGE +": " + COLOR_DEFAULT + flags;
                }

                EntsAroundNone = function(radius,org)
                {
                    return "No entities within radius of " + COLOR_ORANGE + radius + COLOR_DEFAULT + " around " + COLOR_BRIGHT_GREEN + org;
                }

                EntsAroundStart = function(radius)
                {
                    return "Entity " + COLOR_BRIGHT_GREEN + "#" + COLOR_DEFAULT + " and " + COLOR_OLIVE_GREEN + "class" + COLOR_DEFAULT + " within " + COLOR_ORANGE + radius + COLOR_DEFAULT + " units" + "\n";
                }
                EntsAroundValid = function(obj)
                {
                    return COLOR_BRIGHT_GREEN + "#" + obj.GetIndex() + COLOR_DEFAULT + ", " + COLOR_OLIVE_GREEN + obj.GetClassname() + (obj.GetParent() == null ? "" : ", "+COLOR_ORANGE+"Parented!") + COLOR_DEFAULT + "\n";
                }

                WatchIntervalFailure = function()
                {
                    return "Watch rate too high, minimum interval length is " + COLOR_ORANGE + "0.1" + COLOR_DEFAULT + "seconds!";
                } 
                WatchNoEntity = function()
                {
                    return "No entity to watch";
                } 
                WatchUnknownHandle = function(handlename)
                {
                    return handlename+" is not a known script handle name";
                }
                WatchWrongTableEntry = function(member)
                {
                    return "Skipping " + COLOR_ORANGE + member;
                }
                WatchDoesntHaveNetProp = function(netprop,index,classname)
                {
                    return COLOR_ORANGE + netprop + COLOR_DEFAULT + " doesn't exist for " + COLOR_BRIGHT_GREEN + "#" + index + COLOR_DEFAULT + ", " + COLOR_OLIVE_GREEN + classname;
                }

                WatchCurrentValue = function(index,handlename,member,val)
                {
                    if(handlename == "")
                        return COLOR_BRIGHT_GREEN + "#" + index + " " + COLOR_ORANGE + member + COLOR_DEFAULT + " -> " + COLOR_OLIVE_GREEN + val;
                    return COLOR_BRIGHT_GREEN + "#" + index + " " + COLOR_ORANGE + handlename + COLOR_DEFAULT + "." + COLOR_BRIGHT_GREEN + member + COLOR_DEFAULT + " -> " + COLOR_OLIVE_GREEN + val;
                }
                
                WatchNothingToRemove = function(index,member)
                {
                    return "No watch timer found for "+ COLOR_BRIGHT_GREEN + "#" + index + " " + COLOR_ORANGE + member;
                }
                WatchRemove = function(index,member)
                {
                    return "Removed watch for "+ COLOR_BRIGHT_GREEN + "#" + index + " " + COLOR_ORANGE + member;
                }

            }
        }

        Docs = 
        {
            prop = function(player,args)
            {
                local cmd = CMDDocs(
                    "prop",
                    [
                        CMDParam("classname","Class name of the prop"),
                        CMDParam("model_path","Model path(s), use model1&model2&... format to spawn multiple props parented by model1"),
                        CMDParam("extra_height","Extra spawn height",true,"spawn at aimed point"),
                        CMDParam("yaw_rotation","Rotation around Z axis(yaw) in degrees",true,"spawn with default angles"),
                        CMDParam("mass_scale","Scale factor of mass, used with physicsM classname",true,"default mass value")
                    ],
                    "Spawn a prop or multiple props parented by a prop of given class using given model(s) and settings if any"
                    )
                return cmd.Describe();
            }
            help = function(player,args)
            {
                local cmd = CMDDocs(
                    "help",
                    [
                        CMDParam("command_name","Command name",true,"help command")
                    ],
                    "Get the documentation written for a given command"
                    )
                return cmd.Describe();
            }
            loop = function(player,args)
            {   
                local cmd = CMDDocs(
                    "loop",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("scene_or_sequence","Scene name or >Sequence name"),
                        CMDParam("loop_length","positive real number")
                    ],
                    "Start looping given scene or sequence repeating every loop_length seconds"
                    )
                return cmd.Describe();
            }
            loop_stop = function(player,args)
            {
                local cmd = CMDDocs(
                    "loop_stop",
                    [
                        CMDParam("character","Character name",true,"uses player")
                    ],
                    "Stop looping for given character"
                    )
                return cmd.Describe();
            }
            speak_test = function(player,args)
            {
                local cmd = CMDDocs(
                    "speak_test",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("scene","Scene name"),
                        CMDParam("duration","positive real number",true,"speak the whole scene")
                    ],
                    "Speak given scene for given duration in seconds"
                    )
                return cmd.Describe();
            }
            speak_custom = function(player,args)
            {
                local cmd = CMDDocs(
                    "speak_custom",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("sequence","Sequence name")
                    ],
                    "Speak a custom sequence created for given character by player"
                    )
                return cmd.Describe();
            }
            show_custom_sequences = function(player,args)
            {
                local cmd = CMDDocs(
                    "show_custom_sequences",
                    [
                        CMDParam("character","Character name",true,"all characters")
                    ],
                    "Show custom sequences created for given character or all characters by player"
                    )
                return cmd.Describe();
            }
            seq_info = function(player,args)
            {
                local cmd = CMDDocs(
                    "seq_info",
                    [
                        [
                            CMDParam("character","Character name"),
                            CMDParam("sequence","Sequence name")
                        ],
                        [
                            CMDParam("sequence","Sequence name defined for player")
                        ],
                    ],
                    "Show information about given custom sequence of given character"
                    )
                return cmd.Describe();
            }
            seq_edit = function(player,args)
            {
                local cmd = CMDDocs(
                    "seq_edit",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("sequence","Sequence name"),
                        CMDParam("scene_or_index","Scene name or >scene index"),
                        CMDParam("scene_or_delay","scene>new_scene_name or delay>new_delay")
                    ],
                    "Edit a custom sequence's scene or delay"
                    )
                return cmd.Describe();
            }
            create_seq = function(player,args)
            {
                local cmd = CMDDocs(
                    "create_seq",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("name","Sequence name"),
                        CMDParam("scene_x","Scene name"),
                        CMDParam("delay_x","Start time of scene_x"),
                        CMDParam("...","Repeat 3. and 4. parameters")
                    ],
                    "Create a custom sequence for a character"
                    )
                return cmd.Describe();
            }
            delete_seq = function(player,args)
            {
                local cmd = CMDDocs(
                    "delete_seq",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("name","Sequence name")
                    ],
                    "Delete a custom sequence of a character"
                    )
                return cmd.Describe();
            }
            start_the_shower = function(player,args)
            {
                local cmd = CMDDocs(
                    "start_the_shower",
                    [],
                    "Start(or stop if already started) the meteor shower!"
                    )
                return cmd.Describe();
            }
            pause_the_shower = function(player,args)
            {
                local cmd = CMDDocs(
                    "pause_the_shower",
                    [],
                    "Stop the meteor shower!"
                    )
                return cmd.Describe();
            }
            show_meteor_shower_settings = function(player,args)
            {
                local cmd = CMDDocs(
                    "show_meteor_shower_settings",
                    [],
                    "Show current meteor shower event settings"
                    )
                return cmd.Describe();
            }
            meteor_shower_setting = function(player,args)
            {
                local cmd = CMDDocs(
                    "meteor_shower_setting",
                    [
                        CMDParam("setting","Setting name"),
                        CMDParam("value","New value")
                    ],
                    "Change a meteor shower event setting. Check show_meteor_shower_settings command"
                    )
                return cmd.Describe();
            }
            meteor_shower_debug = function(player,args)
            {
                local cmd = CMDDocs(
                    "meteor_shower_debug",
                    [],
                    "Change debug messages of meteor shower event"
                    )
                return cmd.Describe();
            }
            start_the_apocalypse = function(player,args)
            {
                local cmd = CMDDocs(
                    "start_the_apocalypse",
                    [],
                    "Start(or stop if already started) the apocalypse propageddon!"
                    )
                return cmd.Describe();
            }
            pause_the_apocalypse = function(player,args)
            {
                local cmd = CMDDocs(
                    "pause_the_apocalypse",
                    [],
                    "Stop the apocalypse propageddon!"
                    )
                return cmd.Describe();
            }
            show_apocalypse_settings = function(player,args)
            {
                local cmd = CMDDocs(
                    "show_apocalypse_settings",
                    [],
                    "Show current apocalypse propageddon event settings"
                    )
                return cmd.Describe();
            }
            apocalypse_setting = function(player,args)
            {
                local cmd = CMDDocs(
                    "apocalypse_setting",
                    [
                        CMDParam("setting","Setting name"),
                        CMDParam("value","New value")
                    ],
                    "Change a apocalypse propageddon event setting. Check show_apocalypse_settings command"
                    )
                return cmd.Describe();
            }
            apocalypse_debug = function(player,args)
            {
                local cmd = CMDDocs(
                    "apocalypse_debug",
                    [],
                    "Change debug messages of apocalypse propageddon event"
                    )
                return cmd.Describe();
            }
            update_print_output_state = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_print_output_state",
                    [],
                    "Change output message target between chat/console"
                    )
                return cmd.Describe();
            }
            attach_to_targeted_position = function(player,args)
            {
                local cmd = CMDDocs(
                    "attach_to_targeted_position",
                    [],
                    "Change attachment position for particles between aimed point and origin of the object"
                    )
                return cmd.Describe();
            }
            randomparticle_save_state = function(player,args)
            {
                local cmd = CMDDocs(
                    "randomparticle_save_state",
                    [],
                    "Change state of saving the last randomly spawned particle"
                    )
                return cmd.Describe();
            }
            update_attachment_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_attachment_preference",
                    [
                        CMDParam("duration","Attachment duration in seconds",true,"30 seconds")
                    ],
                    "Change duration of attaching particles to objects, -1 = infinite duration"
                    )
                return cmd.Describe();
            }
            display_saved_particle = function(player,args)
            {
                local cmd = CMDDocs(
                    "display_saved_particle",
                    [],
                    "Show currently saved particle information"
                    )
                return cmd.Describe();
            }
            admin_var = function(player,args)
            {
                local cmd = CMDDocs(
                    "admin_var",
                    [
                        CMDParam("var_name","Variable name"),
                        CMDParam("new_value","New value to be compiled",true,"Print current value")
                    ],
                    "Get/Create/Change a AdminSystem.Vars value"
                    )
                return cmd.Describe();
            }
            add_script_auth = function(player,args)
            {
                local cmd = CMDDocs(
                    "add_script_auth",
                    [
                        CMDParam("character","Character name of the player")
                    ],
                    "Give a player authority to execute scripts"
                    )
                return cmd.Describe();
            }
            remove_script_auth = function(player,args)
            {
                local cmd = CMDDocs(
                    "remove_script_auth",
                    [
                        CMDParam("character","Character name of the player")
                    ],
                    "Take away a player's authority to execute scripts"
                    )
                return cmd.Describe();
            }
            server_exec = function(player,args)
            {
                local cmd = CMDDocs(
                    "server_exec",
                    [
                        CMDParam("command","Command name"),
                        CMDParam("argument_1","Argument 1",true,"empty"),
                        CMDParam("argument_2","Argument 2",true,"empty"),
                        CMDParam("argument_3","Argument 3",true,"empty"),
                        CMDParam("argument_4","Argument 4",true,"empty")
                    ],
                    "Execute a command on the server console with given arguments"
                    )
                return cmd.Describe();
            }
            script = function(player,args)
            {
                local cmd = CMDDocs(
                    "script",
                    [
                        CMDParam("code","Squirrel code to compile and execute")
                    ],
                    "Execute scripts on the global scope"
                    )
                return cmd.Describe();
            }
            setkeyval = function(player,args)
            {
                local cmd = CMDDocs(
                    "setkeyval",
                    [
                        CMDParam("key","Key name"),
                        CMDParam("value","New value")
                    ],
                    "Change the value of a key present in aimed object"
                    )
                return cmd.Describe();
            }
            update_svcheats = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_svcheats",
                    [],
                    "Change the sv_cheats cvar of the server between 0 and 1"
                    )
                return cmd.Describe();
            }
            prop_spawn_setting = function(player,args)
            {
                local cmd = CMDDocs(
                    "prop_spawn_setting",
                    [
                        CMDParam("class_name","Class: physics|dynamic|ragdoll|all|ptr(last class menu visited)"),
                        CMDParam("setting","Setting name"),
                        CMDParam("sub_setting","Actual setting name:\n\t  Possible values: val|flags|min|max\n\t  Prefixes:\n\t\t Set: (no prefix), example-> flags\n\t\t Add: + , example-> +flags\n\t\t Remove: - , example-> -flags"),
                        CMDParam("value","Value to set/add/remove. Can be casted following the format: cast_type|val_1|val_2|...\n\t Single-value casts->int|float|flg\n\t Multi-value casts->str|ang|pos|flg\n\t Casting examples:\n\t\tAs vector -> pos|x|y|z\n\t\tAs angle -> ang|pitch|yaw|roll\n\t\tAs spaced text -> str|word_1|word_2|...\n\t\tAs flags -> flg|flag_1|flag_2|...")
                    ],
                    "Update a prop spawn setting of given class. Check display_prop_spawn_settings command"
                    )
                return cmd.Describe();
            }
            update_prop_spawn_menu_type = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_prop_spawn_menu_type",
                    [
                        CMDParam("class_name","Class: physics|dynamic|ragdoll|all")
                    ],
                    "Used to store which prop spawn menu player used last. Uses ptr as class_name with prop_spawn_setting command"
                    )
                return cmd.Describe();
            }
            display_prop_spawn_settings = function(player,args)
            {
                local cmd = CMDDocs(
                    "display_prop_spawn_settings",
                    [
                        CMDParam("class_name","Class: physics|dynamic|ragdoll|all",true,"assumes \"all\"")
                    ],
                    "Show prop spawn settings of a class or all classes"
                    )
                return cmd.Describe();
            }
            update_custom_response_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_custom_response_preference",
                    [],
                    "Enable/disable custom responses"
                    )
                return cmd.Describe();
            }
            update_custom_sharing_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_custom_sharing_preference",
                    [],
                    "Enable/disable custom sharing of grenades and packs"
                    )
                return cmd.Describe();
            }
            explosion = function(player,args)
            {
                local cmd = CMDDocs(
                    "explosion",
                    [
                        CMDParam("option","Options: meteor(drop a meteor)",true,"only a delayed explosion")
                    ],
                    "Create a delayed explosion"
                    )
                return cmd.Describe();
            }
            show_explosion_settings = function(player,args)
            {
                local cmd = CMDDocs(
                    "show_explosion_settings",
                    [],
                    "Show current explosion settings"
                    )
                return cmd.Describe();
            }
            explosion_setting = function(player,args)
            {
                local cmd = CMDDocs(
                    "explosion_setting",
                    [
                        CMDParam("setting","Setting to change"),
                        CMDParam("value","New value")
                    ],
                    "Change an explosion settings. Check show_explosion_settings command"
                    )
                return cmd.Describe();
            }
            update_jockey_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_jockey_preference",
                    [],
                    "Enable/disable jockeys"
                    )
                return cmd.Describe();
            }
            update_tank_rock_launch_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_tank_rock_launch_preference",
                    [],
                    "Enable/disable tank rocks' launch effect"
                    )
                return cmd.Describe();
            }
            update_tank_rock_random_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_tank_rock_random_preference",
                    [],
                    "Enable/disable using random models for tank rocks"
                    )
                return cmd.Describe();
            }
            update_tank_rock_respawn_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_tank_rock_respawn_preference",
                    [],
                    "Enable/disable keeping random models for tank rocks after they are thrown"
                    )
                return cmd.Describe();
            }
            update_model_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_model_preference",
                    [],
                    "Enable/disable keeping last player model between chapters/resets"
                    )
                return cmd.Describe();
            }
            restore_model = function(player,args)
            {
                local cmd = CMDDocs(
                    "restore_model",
                    [
                        CMDParam("character","Character name or !picker",true,"uses player")
                    ],
                    "Restore the original model of a player"
                    )
                return cmd.Describe();
            }
            random_model = function(player,args)
            {
                local cmd = CMDDocs(
                    "random_model",
                    [],
                    "Prints out a random model path to chat only visible to caller"
                    )
                return cmd.Describe();
            }
            drive = function(player,args)
            {
                local cmd = CMDDocs(
                    "drive",
                    [],
                    "Start(or stop if driving) to drive aimed object"
                    )
                return cmd.Describe();
            }
            kind_bots = function(player,args)
            {
                local cmd = CMDDocs(
                    "kind_bots",
                    [],
                    "Add a think adder entity which enables bots' to start looting and sharing grenades and packs"
                    )
                return cmd.Describe();
            }
            selfish_bots = function(player,args)
            {
                local cmd = CMDDocs(
                    "selfish_bots",
                    [],
                    "Remove the existing think adders to disable bots' looting and sharing grenades and packs"
                    )
                return cmd.Describe();
            }
            update_bots_sharing_preference = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_bots_sharing_preference",
                    [],
                    "Enable/disable sharing ability of bots for packs and grenades"
                    )
                return cmd.Describe();
            }
            piano_keys = function(player,args)
            {
                local cmd = CMDDocs(
                    "piano_keys",
                    [],
                    "Spawn 25 piano keys at aimed point, placing all 25 to the right"
                    )
                return cmd.Describe();
            }
            remove_piano_keys = function(player,args)
            {
                local cmd = CMDDocs(
                    "remove_piano_keys",
                    [],
                    "Remove all spawned piano keys"
                    )
                return cmd.Describe();
            }
            display_mics_speakers = function(player,args)
            {
                local cmd = CMDDocs(
                    "display_mics_speakers",
                    [],
                    "Display all microphones and speakers and their current distances to player"
                    )
                return cmd.Describe();
            }
            speaker2mic = function(player,args)
            {
                local cmd = CMDDocs(
                    "speaker2mic",
                    [
                        CMDParam("speaker_ID_or_NAME","Speaker #id or name"),
                        CMDParam("mic_ID_or_NAME","Microphone #id or name")
                    ],
                    "Connect a speaker to a microphone"
                    )
                return cmd.Describe();
            }
            speaker = function(player,args)
            {
                local cmd = CMDDocs(
                    "speaker",
                    [],
                    "Create an entity to be used as a speaker"
                    )
                return cmd.Describe();
            }
            microphone = function(player,args)
            {
                local cmd = CMDDocs(
                    "microphone",
                    [
                        CMDParam("effect","Effects: standard|no_effect|tiny|small|very_small|loud|loud_echo",true,"standard"),
                        CMDParam("max_range","Max listening range",true,"120 unit radius"),
                        CMDParam("speaker_ID_or_NAME","Speaker #id or name to connect",true,"can be connected later")
                    ],
                    "Create a microphone entity"
                    )
                return cmd.Describe();
            }
            randomline = function(player,args)
            {
                local cmd = CMDDocs(
                    "randomline",
                    [
                        CMDParam("speaker_character","Speaker: Character name|random",true,"uses player"),
                        CMDParam("line_source_character","Lines from: Character name|random",true,"speaker_character's own lines")
                    ],
                    "Speak or make a character speak a randomline from the source given"
                    )
                return cmd.Describe();
            }
            randomline_save_last = function(player,args)
            {
                local cmd = CMDDocs(
                    "randomline_save_last",
                    [],
                    "Enable/disable saving last randomly spoken line"
                    )
                return cmd.Describe();
            }
            speak_saved = function(player,args)
            {
                local cmd = CMDDocs(
                    "speak_saved",
                    [],
                    "Speak last saved line"
                    )
                return cmd.Describe();
            }
            display_saved_line = function(player,args)
            {
                local cmd = CMDDocs(
                    "display_saved_line",
                    [],
                    "Display last saved line"
                    )
                return cmd.Describe();
            }
            save_line = function(player,args)
            {
                local cmd = CMDDocs(
                    "save_line",
                    [
                        CMDParam("speaker_character","Speaker, character name"),
                        CMDParam("scene","Scene to be spoken by speaker_character")
                    ],
                    "Save given line to be spoken by given character"
                    )
                return cmd.Describe();
            }
            save_particle = function(player,args)
            {
                local cmd = CMDDocs(
                    "save_particle",
                    [
                        CMDParam("particle_effect","Effect name"),
                        CMDParam("duration","Delay to kill the particle, -1 for infinite",true,"uses player's preferred duration")
                    ],
                    "Save given particle to be spawned for given duration"
                    )
                return cmd.Describe();
            }
            ent = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent",
                    [
                        CMDParam("class_name","Class name for entity"),
                        CMDParam("keyvals","Key-values formatted as key_1>cast|value_1&key_2>cast|value_2...\n\t Single-value casts->int|float|flg\n\t Multi-value casts->str|ang|pos|flg\n\t ",true,"uses aimed point as origin")
                    ],
                    "Create an entity of given class with given key-value pairs"
                    )
                return cmd.Describe();
            }
            entcvar = function(player,args)
            {
                local cmd = CMDDocs(
                    "entcvar",
                    [
                        CMDParam("entity","Object #id, name or !picker (aimed object) or !self (player)"),
                        CMDParam("cvar","Console variable name"),
                        CMDParam("value","New value for the cvar",true,"prints the current value")
                    ],
                    "Get or set a cvar of an entity"
                    )
                return cmd.Describe();
            }
            ent_rotate = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent_rotate",
                    [
                        CMDParam("axis","Rotation axis: x|y|z"),
                        CMDParam("rotation","Rotation in degrees"),
                        CMDParam("use_local","Any value: rotate grabbed object or worn hat",true,"rotates aimed object")
                    ],
                    "Rotate an object along some axis given amount"
                    )
                return cmd.Describe();
            }
            ladder_team = function(player,args)
            {
                local cmd = CMDDocs(
                    "ladder_team",
                    [
                        CMDParam("team","New team for all ladders: all|spectator|survivor|infected|l4d1\nUse 'reset' to reset back to original.")
                    ],
                    "Change/reset which team(s) can use the ladders"
                    )
                return cmd.Describe();
            }
            invisible_walls = function(player,args)
            {
                local cmd = CMDDocs(
                    "invisible_walls",
                    [
                        CMDParam("state","New state for the invisible blockers: enable|disable",true,"disables"),
                        CMDParam("try_all","Apply to all blockers",true,"only enables/disables clipping blocks")
                    ],
                    "Enable/disable most if not all the invisible walls. Some of them can't be changed."
                    )
                return cmd.Describe();
            }
            ent_push = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent_push",
                    [
                        CMDParam("strength","Push strength/speed, walking speed is 220",true,"uses 500"),
                        CMDParam("direction","Direction relative to player: forward|backward|left|right|up|down",true,"uses forward"),
                        CMDParam("pitch","Pitch angle in degrees, positive value to push higher",true,"no extra pitch")
                    ],
                    "Push an object to given direction by applying an impulse with given strength"
                    )
                return cmd.Describe();
            }
            ent_move = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent_move",
                    [
                        CMDParam("units","How many units to move",true,"uses 1"),
                        CMDParam("direction","Direction relative to player: forward|backward|left|right|up|down",true,"uses forward"),
                        CMDParam("pitch","Pitch angle in degrees, positive value to push higher",true,"no extra pitch"),
                        CMDParam("use_local","Any value: move grabbed object or worn hat",true,"moves aimed object")
                    ],
                    "Move an object to given direction by teleporting"
                    )
                return cmd.Describe();
            }
            ent_spin = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent_spin",
                    [
                        CMDParam("strength","Spin strength/speed, walking speed is 220",true,"uses 500"),
                        CMDParam("direction","Direction relative to player: forward|backward|left|right|up|down",true,"uses forward")
                    ],
                    "Spin an object by applying an angular impulse in given direction and strength. Assume three finger rule, this vector is the thumb"
                    )
                return cmd.Describe();
            }
            ent_teleport = function(player,args)
            {
                local cmd = CMDDocs(
                    "ent_teleport",
                    [
                        CMDParam("object","Object's #id or name")
                    ],
                    "Teleport an object to aimed point"
                    )
                return cmd.Describe();
            }
            rainbow = function(player,args)
            {
                local cmd = CMDDocs(
                    "rainbow",
                    [
                        CMDParam("duration","Total duration",true,"uses 12 seconds"),
                        CMDParam("interval","Duration of each color",true,"uses 0.15 second intervals")
                    ],
                    "Apply rainbow effect to aimed object"
                    )
                return cmd.Describe();
            }
            color = function(player,args)
            {
                local cmd = CMDDocs(
                    "color",
                    [
                        CMDParam("r","Red 0-255"),
                        CMDParam("g","Green 0-255"),
                        CMDParam("b","Blue 0-255"),
                        CMDParam("a","Alpha 0-255, 0: invisible")
                    ],
                    "Change 32-bit color of the aimed object"
                    )
                return cmd.Describe();
            }
            model = function(player,args)
            {
                local cmd = CMDDocs(
                    "model",
                    [
                        CMDParam("object","Object #id or name or !picker (aimed object) or !self (player)"),
                        CMDParam("model","New model's path")
                    ],
                    "Change the model of given object"
                    )
                return cmd.Describe();
            }
            model_scale = function(player,args)
            {
                local cmd = CMDDocs(
                    "model_scale",
                    [
                        CMDParam("object","Object #id or name or !picker (aimed object) or !self (player)"),
                        CMDParam("model_scale","New model scale")
                    ],
                    "Change the model scale of given object, non-player objects may not scale"
                    )
                return cmd.Describe();
            }
            disguise = function(player,args)
            {
                local cmd = CMDDocs(
                    "disguise",
                    [],
                    "Change player's model to aimed object's model"
                    )
                return cmd.Describe();
            }
            attach_particle = function(player,args)
            {
                local cmd = CMDDocs(
                    "attach_particle",
                    [
                        CMDParam("particle","Particle name|random"),
                        CMDParam("duration","Duration of the spawned particle, -1 for infinite",true,"uses preferred duration of player")
                    ],
                    "Attach given particle for given duration to aimed object"
                    )
                return cmd.Describe();
            }
            spawn_particle_saved = function(player,args)
            {
                local cmd = CMDDocs(
                    "spawn_particle_saved",
                    [],
                    "Spawn saved particle at aimed point"
                    )
                return cmd.Describe();
            }
            attach_particle_saved = function(player,args)
            {
                local cmd = CMDDocs(
                    "attach_particle_saved",
                    [],
                    "Attach saved particle at aimed object. Attachment point can be updated attach_to_targeted_position command"
                    )
                return cmd.Describe();
            }
            hat_position = function(player,args)
            {
                local cmd = CMDDocs(
                    "hat_position",
                    [
                        CMDParam("attachment_point","An attachment point of aimed object")
                    ],
                    "Update which attachment point the hat is worn at. Some points: eyes|mouth|survivor_neck"
                    )
                return cmd.Describe();
            }
            update_aimed_ent_direction = function(player,args)
            {
                local cmd = CMDDocs(
                    "update_aimed_ent_direction",
                    [],
                    "Make aimed object face the exact same direction as player's"
                    )
                return cmd.Describe();
            }
            take_off_hat = function(player,args)
            {
                local cmd = CMDDocs(
                    "take_off_hat",
                    [],
                    "Take off worn hat and place it at aimed point"
                    )
                return cmd.Describe();
            }
            wear_hat = function(player,args)
            {
                local cmd = CMDDocs(
                    "wear_hat",
                    [
                        CMDParam("extra_height","Height to add to player's preference",true,"no extra height")
                    ],
                    "Wear aimed object as a hat"
                    )
                return cmd.Describe();
            }
            grab = function(player,args)
            {
                local cmd = CMDDocs(
                    "grab",
                    [],
                    "Grab aimed object"
                    )
                return cmd.Describe();
            }
            letgo = function(player,args)
            {
                local cmd = CMDDocs(
                    "letgo",
                    [],
                    "Letgo off the held object"
                    )
                return cmd.Describe();
            }
            yeet = function(player,args)
            {
                local cmd = CMDDocs(
                    "yeet",
                    [],
                    "Yeet the held object"
                    )
                return cmd.Describe();
            }
            show_yeet_settings = function(player,args)
            {
                local cmd = CMDDocs(
                    "show_yeet_settings",
                    [],
                    "Show player's yeeting settings"
                    )
                return cmd.Describe();
            }
            yeet_setting = function(player,args)
            {
                local cmd = CMDDocs(
                    "yeet_setting",
                    [
                        CMDParam("setting","Setting name"),
                        CMDParam("value","New value")
                    ],
                    "Change a setting of yeeting. Check show_yeet_settings command"
                    )
                return cmd.Describe();
            }
            change_grab_method = function(player,args)
            {
                local cmd = CMDDocs(
                    "change_grab_method",
                    [],
                    "Change grabbing method between grabbing by aimed point and grabbing by object's center"
                    )
                return cmd.Describe();
            }
            stop_car_alarms = function(player,args)
            {
                local cmd = CMDDocs(
                    "stop_car_alarms",
                    [],
                    "Stop all the car alarms currently ringing"
                    )
                return cmd.Describe();
            }
            remove_fall_cams = function(player,args)
            {
                local cmd = CMDDocs(
                    "remove_fall_cams",
                    [],
                    "Remove all fall following cameras. Example: No mercy rooftop falling cameras"
                    )
                return cmd.Describe();
            }
            hurt_triggers = function(player,args)
            {
                local cmd = CMDDocs(
                    "hurt_triggers",
                    [
                        CMDParam("state","Enable or Disable")
                    ],
                    "Enable/disable all hurt triggers in the map"
                    )
                return cmd.Describe();
            }
            debug_info = function(player,args)
            {
                local cmd = CMDDocs(
                    "debug_info",
                    [
                        CMDParam("options","Options: player(get player information)",true,"uses aimed object")
                    ],
                    "Prints detailed information about an object"
                    )
                return cmd.Describe();
            }
            stop_time = function(player,args)
            {
                local cmd = CMDDocs(
                    "stop_time",
                    [
                        CMDParam("targets","Targets: all|special|common|physics",true,"freezes aimed object")
                    ],
                    "Freeze objects in time"
                    )
                return cmd.Describe();
            }
            resume_time = function(player,args)
            {
                local cmd = CMDDocs(
                    "resume_time",
                    [
                        CMDParam("targets","Targets: all|special|common|physics",true,"unfreezes aimed object")
                    ],
                    "Unfreeze objects in time which were frozen with stop_time command"
                    )
                return cmd.Describe();
            }
            ents_around = function(player,args)
            {
                local cmd = CMDDocs(
                    "ents_around",
                    [
                        CMDParam("radius","Radius to search for objects",true,"uses 50 unit radius")
                    ],
                    "Prints objects' #id, class and parent status within given radius of aimed point"
                    )
                return cmd.Describe();
            }
            wnet = function(player,args)
            {
                local cmd = CMDDocs(
                    "wnet",
                    [
                        [
                            CMDParam("netprop","Network property name"),
                            CMDParam("intervals","Checking interval in seconds",true,"checks every second"),
                            CMDParam("object","Object's #id or name",true,"uses aimed object")
                        ],
                        [
                            CMDParam("baseclass_n_depth","&base_classname&max_depth . &max_depth is optional, & symbols are required"),
                            CMDParam("intervals","Checking interval in seconds",true,"checks every second"),
                            CMDParam("object","Object's #id or name",true,"uses aimed object")
                        ]
                    ],
                    "Watch network properties of an object, get informed as they update"
                    )
                return cmd.Describe();
            }
            stop_wnet = function(player,args)
            {
                local cmd = CMDDocs(
                    "stop_wnet",
                    [
                        [
                            CMDParam("netprop","Network property name"),
                            CMDParam("object","Object's #id or name",true,"uses aimed object")
                        ],
                        [
                            CMDParam("baseclass","&base_classname"),
                            CMDParam("object","Object's #id or name",true,"uses aimed object")
                        ]
                    ],
                    "Stop watching network properties of an object"
                    )
                return cmd.Describe();
            }
            flag_lookup = function(player,args)
            {
                local cmd = CMDDocs(
                    "flag_lookup",
                    [
                        CMDParam("prefix","Flag/Constant prefix"),
                        CMDParam("value","Value to match flags with",true,"prints all flags/constants starting with given prefix")
                    ],
                    "Lookup flags starting with a prefix or get flags representing given value starting with given prefix"
                    )
                return cmd.Describe();
            }
            go_ragdoll = function(player,args)
            {
                local cmd = CMDDocs(
                    "go_ragdoll",
                    [],
                    "Start ragdolling with controls"
                    )
                return cmd.Describe();
            }
            recover_ragdoll = function(player,args)
            {
                local cmd = CMDDocs(
                    "recover_ragdoll",
                    [],
                    "Recover from ragdolling"
                    )
                return cmd.Describe();
            }
            give_physics = function(player,args)
            {
                local cmd = CMDDocs(
                    "give_physics",
                    [
                        CMDParam("radius","Radius to select objects within or !picker (aimed object)",true,"uses 150 units radius")
                    ],
                    "Give physics abilities to objects"
                    )
                return cmd.Describe();
            }
            fire_ex = function(player,args)
            {
                local cmd = CMDDocs(
                    "fire_ex",
                    [
                        CMDParam("physics_class","physicsM: Create with physics, else no physics",true,"spawns non-physics")
                    ],
                    "Spawn a fire extinguisher which has steam effect and sound when shot"
                    )
                return cmd.Describe();
            }
            particle = function(player,args)
            {
                local cmd = CMDDocs(
                    "particle",
                    [
                        CMDParam("effect_name","Particle effect name|random")
                    ],
                    "Spawn a particle effect at aimed point"
                    )
                return cmd.Describe();
            }
            spawn_model_saved = function(player,args)
            {
                local cmd = CMDDocs(
                    "spawn_model_saved",
                    [],
                    "Spawn a prop with saved model and class"
                    )
                return cmd.Describe();
            }
            display_saved_model = function(player,args)
            {
                local cmd = CMDDocs(
                    "display_saved_model",
                    [],
                    "Display saved model and class information"
                    )
                return cmd.Describe();
            }
            random_model_save_state = function(player,args)
            {
                local cmd = CMDDocs(
                    "random_model_save_state",
                    [],
                    "Enable/disable saving last randomly spawned prop's model and class"
                    )
                return cmd.Describe();
            }
            save_model = function(player,args)
            {
                local cmd = CMDDocs(
                    "save_model",
                    [
                        CMDParam("class_name","Class name: physics|dynamic|ragdoll"),
                        CMDParam("model","Model path to use")
                    ],
                    "Save a prop with given class and model"
                    )
                return cmd.Describe();
            }
            say = function(player,args)
            {
                local cmd = CMDDocs(
                    "say",
                    [
                        [
                            CMDParam("target","Character name|all"),
                            CMDParam("text","Text to make target say")
                        ],
                        [
                            CMDParam("text","Text to make yourself say")
                        ]
                    ],
                    "Print given text as if it was said by given player(s)/yourself\nUse hex characters for non-alphabetical characters while using from console"
                    )
                return cmd.Describe();
            }
            out = function(player,args)
            {
                local cmd = CMDDocs(
                    "out",
                    [
                        CMDParam("expression","Expression to compile and print the result of")
                    ],
                    "Compile given expression and print it's output if there is any"
                    )
                return cmd.Describe();
            }
            hex_string = function(player,args)
            {
                local cmd = CMDDocs(
                    "hex_string",
                    [
                        CMDParam("text","Text to use")
                    ],
                    "Replace problematic characters in given text with their hex values.\nExample: \"a,b;c d\" will return \"a\\x2C\\x3Bc\\x20d\" which can be used as an argument later"
                    )
                return cmd.Describe();
            }
            enum_string = function(player,args)
            {
                local cmd = CMDDocs(
                    "enum_string",
                    [
                        CMDParam("text","Text to get enumerated form of.")
                    ],
                    "Get an enumerated form of given text for runtime compilation use. This expression can be used with $[expression] format to create arguments that wouldn't be possible otherwise\nExample: \"a,b;c d\" will return \"__.a+__._c+__.b+__._sc+__.c+__._s+__._d\" which can be used as an argument within $[expression] format from the console or chat"
                    )
                return cmd.Describe();
            }
            create_alias = function(player,args)
            {
                local cmd = CMDDocs(
                    "create_alias",
                    [
                        CMDParam("alias_name","Name of the alias"),
                        CMDParam("table_contents","Alias parameters,commands and other options following the table format.\nExample:\n Parameters={param_1=\"default_value\"},Commands={command_name={arg_1=\"$param_1\",arg_2=\"value to pass\",arg_3=\"$[expression]\"}}")
                    ],
                    "Create an alias for existing commands/aliases with custom parameters and other settings\nCheck out the configuration files for more info..."
                    )
                return cmd.Describe();
            }
            replace_alias = function(player,args)
            {
                local cmd = CMDDocs(
                    "replace_alias",
                    [
                        CMDParam("alias_name","Name of the existing alias"),
                        CMDParam("table_contents","New alias parameters,commands and other options following the table format")
                    ],
                    "Replace an existing alias. Check ?create_alias"
                    )
                return cmd.Describe();
            }
            reload_aliases = function(player,args)
            {
                local cmd = CMDDocs(
                    "reload_aliases",
                    [],
                    "Reload custom alias files in the configuration folders"
                    )
                return cmd.Describe();
            }
            reload_scripts = function(player,args)
            {
                local cmd = CMDDocs(
                    "reload_scripts",
                    [],
                    "Reload custom script files in the configuration folders"
                    )
                return cmd.Describe();
            }
            reload_hooks = function(player,args)
            {
                local cmd = CMDDocs(
                    "reload_hooks",
                    [],
                    "Reload custom hook files in the configuration folders"
                    )
                return cmd.Describe();
            }
            detach_hook = function(player,args)
            {
                local cmd = CMDDocs(
                    "detach_hook",
                    [
                        CMDParam("event_name","Name of the event"),
                        CMDParam("hook_name","Name of the hook to detach")
                    ],
                    "Detach a custom hook of an event"
                    )
                return cmd.Describe();
            }
            attach_hook = function(player,args)
            {
                local cmd = CMDDocs(
                    "attach_hook",
                    [
                        CMDParam("event_name","Name of the event"),
                        CMDParam("hook_name","Name of the hook to re-attach")
                    ],
                    "Re-attach a custom hook of an event back"
                    )
                return cmd.Describe();
            }
            command_ban = function(player,args)
            {
                local cmd = CMDDocs(
                    "command_ban",
                    [
                        [
                            CMDParam("character","Character name"),
                            CMDParam("cmd","Command name to ban until you unban",true,"Bans from all commands")
                        ],
                        [
                            CMDParam("character","Character name"),
                            CMDParam("cmd","Command name to ban"),
                            CMDParam("duration","Ban duration")
                        ]
                    ],
                    "Temporarly ban the use of a command for a player or everyone"
                    )
                return cmd.Describe();
            }
            command_unban = function(player,args)
            {
                local cmd = CMDDocs(
                    "command_unban",
                    [
                        CMDParam("character","Character name"),
                        CMDParam("cmd","Command name to unban",true,"Unbans from all commands")
                    ],
                    "Unban the use of a command for a player or everyone"
                    )
                return cmd.Describe();
            }
            disable_command = function(player,args)
            {
                local cmd = CMDDocs(
                    "disable_command",
                    [
                        CMDParam("cmd","Command name to disable for everyone")
                    ],
                    "Disable a command for everyone"
                    )
                return cmd.Describe();
            }
            enable_command = function(player,args)
            {
                local cmd = CMDDocs(
                    "enable_command",
                    [
                        CMDParam("cmd","Command name to re-enable for everyone")
                    ],
                    "Re-enable a command for everyone"
                    )
                return cmd.Describe();
            }
        }
    }

    tbl.BIM <- t;
}

::Messages.SetBIM(::Messages);

/**********************\
*  MESSAGING FUNCTIONS  *
\**********************/
/// Information Message
/*
 * Player's chat
 */
::Messages.InformPlayer <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Info({_player=player,_msg=func}).SayToPlayerChat(true))
        {
            printl("Couldn't send information message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Info({_player=player,_func=func,_args=args,_msg=msg}).SayToPlayerChat(true))
        {
            printl("Couldn't send information message to " + player);
        }
    }
}
/*
 * Player's console
 */
::Messages.InformPlayerConsole <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Info({_player=player,_msg=func}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send information message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Info({_player=player,_func=func,_args=args,_msg=msg}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send information message to " + player);
        }
    }
}
/*
 * Everyone's chat
 */
::Messages.InformAll <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Info({_msg=func}).SayToAllChat(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Info({_func=func,_args=args,_msg=msg}).SayToAllChat(true);
    }
}
/*
 * Everyone's console
 */
::Messages.InformAllConsole <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Info({_msg=func}).PrintToAllConsole(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Info({_func=func,_args=args,_msg=msg}).PrintToAllConsole(true);
    }
}

/// Warning Message
/*
 * Player's chat
 */
::Messages.WarnPlayer <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Warning({_player=player,_msg=func}).SayToPlayerChat(true))
        {
            printl("Couldn't send warning message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Warning({_player=player,_func=func,_args=args,_msg=msg}).SayToPlayerChat(true))
        {
            printl("Couldn't send warning message to " + player);
        }
    }
}
/*
 * Player's console
 */
::Messages.WarnPlayerConsole <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Warning({_player=player,_msg=func}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send warning message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Warning({_player=player,_func=func,_args=args,_msg=msg}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send warning message to " + player);
        }
    }
}
/*
 * Everyone's chat
 */
::Messages.WarnAll <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Warning({_msg=func}).SayToAllChat(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Warning({_func=func,_args=args,_msg=msg}).SayToAllChat(true);
    }
}
/*
 * Everyone's console
 */
::Messages.WarnAllConsole <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Warning({_msg=func}).PrintToAllConsole(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Warning({_func=func,_args=args,_msg=msg}).PrintToAllConsole(true);
    }
}

/// Error Message
/*
 * Player's chat
 */
::Messages.ThrowPlayer <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Error({_player=player,_msg=func}).SayToPlayerChat(true))
        {
            printl("Couldn't send error message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Error({_player=player,_func=func,_args=args,_msg=msg}).SayToPlayerChat(true))
        {
            printl("Couldn't send error message to " + player);
        }
    }
}
/*
 * Player's console
 */
::Messages.ThrowPlayerConsole <- function(player,func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        if(!Messages.Error({_player=player,_msg=func}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send error message to " + player);
        }
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        if(!Messages.Error({_player=player,_func=func,_args=args,_msg=msg}).PrintToPlayerConsole(true))
        {
            printl("Couldn't send error message to " + player);
        }
    }
}
/*
 * Everyone's chat
 */
::Messages.ThrowAll <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Error({_msg=func}).SayToAllChat(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Error({_func=func,_args=args,_msg=msg}).SayToAllChat(true);
    }
}
/*
 * Everyone's console
 */
::Messages.ThrowAllConsole <- function(func,args=null,msg=null)
{
    if(args == null && msg == null)
    {
        Messages.Error({_msg=func}).PrintToAllConsole(true);
    }
    else
    {
        args = args == null ? [] : args
        msg = msg == null ? "" : msg
        Messages.Error({_func=func,_args=args,_msg=msg}).PrintToAllConsole(true);
    }
}
/// Docs
/*
 * Player's chat
 */
::Messages.DocCmdPlayer <- function(player,msg)
{   
    if(typeof msg == "array")
    {
        foreach(i,line in msg)
        { 
            if(!Messages.Docs({_player=player,_msg=line}).SayToPlayerChat(true))
            {
                printl("Couldn't send documentation message to " + player);
            }
        }
    }
    else if(!Messages.Docs({_player=player,_msg=msg}).SayToPlayerChat(true))
    {
        printl("Couldn't send documentation message to " + player);
    }
}

/// Utility
/*
 * Check table index and assert type
 */
::Messages.IdxAndTypeCheck <- function(tbl,idx,typ) 
{
    return idx in tbl && (typeof (tbl[idx])) == typ;
}

/**********************\
*  MESSAGE BASE CLASS  *
\**********************/
class ::Messages.Message
{
    constructor(tbl,tag="")
    {
        if(tbl != null && (typeof tbl) == "table")
        {
            _tag = Messages.IdxAndTypeCheck(tbl,"_tag","string") ? (tag == "" ? tbl._tag : tag ) : tag;

            _player = Messages.IdxAndTypeCheck(tbl,"_player","string") ? tbl._player : (Messages.IdxAndTypeCheck(tbl,"_player","VSLIB_PLAYER") ? tbl._player.GetCharacterNameLower() : "");

            _func = Messages.IdxAndTypeCheck(tbl,"_func","string") ? tbl._func : "";

            _args = Messages.IdxAndTypeCheck(tbl,"_args","array") ? tbl._args : [];

            _msg = Messages.IdxAndTypeCheck(tbl,"_msg","string") ? tbl._msg : "";
        }
    }

	function _typeof()
	{
		return Messages.MessageType.BASE;
	}
	
	function _cmp(other)
	{
        // TO-DO add comparisons
        return false;
    }

    _tag = null;
    _player = null;
    _func = null;
    _args = null;
    _msg = null;
    static _type = Messages.MessageType.BASE;
  
    /******************************\
    *  MESSAGE BASE CLASS METHODS  *
    \******************************/

    /// Property Methods
    /*
     *
     */
    /// Formatting Methods
    /*
     * Get formatted message string
     */
    function Get(toPlayer=true)
    {
        return _tag + " " 
                + (!toPlayer && _player != "" ? _player + " -> " 
                            : "")
                + _func  + " "
                + ::VSLib.Utils.ArrayString(_args,true) + " " 
                + _msg;
    }
    /*
     * Get colored and formatted message string
     */
    function GetColored(toPlayer=true)
    {
        local argstr = ::VSLib.Utils.ArrayString(_args,true);
        switch(typeof this)
        {
            case Messages.MessageType.BASE:
            {
                return Get(toPlayer);
            }
            case Messages.MessageType.ERROR:
            {
                return COLOR_ORANGE + _tag + " " 
                        + (!toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_ORANGE + " -> " 
                                    : "")
                        + (_func == "" ? "" 
                                       : COLOR_BRIGHT_GREEN + _func + " ") 
                        + (argstr == "" ? ""
                                        : COLOR_OLIVE_GREEN + argstr + " ")
                        + COLOR_DEFAULT + _msg;
            }
            case Messages.MessageType.WARNING:
            {
                return COLOR_OLIVE_GREEN + _tag + " " 
                        + (!toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_OLIVE_GREEN + " -> " 
                                    : "")
                        + (_func == "" ? "" 
                                       : COLOR_BRIGHT_GREEN + _func + " ") 
                        + (argstr == "" ? ""
                                        : COLOR_ORANGE + argstr + " ")
                        + COLOR_DEFAULT + _msg;
            }
            case Messages.MessageType.INFO:
            {
                return COLOR_BRIGHT_GREEN + _tag + " "
                        + (!toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_BRIGHT_GREEN + " -> " 
                                    : "")
                        + (_func == "" ? "" 
                                       : COLOR_BRIGHT_GREEN + _func + " ") 
                        + (argstr == "" ? ""
                                        : COLOR_OLIVE_GREEN + argstr + " ") 
                        + COLOR_DEFAULT + _msg;
            }
            case Messages.MessageType.DOCS:
            {
                return _tag + " " + _msg;
            }
        }
    }

    /// Print Methods
    /*
     * Print message to player's console
     */
    function PrintToPlayerConsole(colored=true)
    {
        local player = ::VSLib.Utils.GetPlayerFromName(_player);
        if(player)
        {
            ClientPrint(player.GetBaseEntity(),
                        2,
                        colored ? GetColored(true) : Get(true));
            return true;
        }
        else
        {
            return false;
        }
    }
    /*
     * Print message to all client's consoles
     */
    function PrintToAllConsole(colored=true)
    {
        ClientPrint(null,
                    2,
                    colored ? GetColored(false) : Get(false));
    }
    /*
     * Print message to player's chat window
     */
    function SayToPlayerChat(colored=true)
    {
        local player = ::VSLib.Utils.GetPlayerFromName(_player);
        if(player)
        {
            ClientPrint(player.GetBaseEntity(),
                        3,
                        colored ? GetColored(true) : Get(true));
            return true;
        }
        else
        {
            return false;
        }
    }
    /*
     * Print message to everybody's chat windows
     */
    function SayToAllChat(colored=true)
    {
        ClientPrint(null,
                    3,
                    colored ? GetColored(false) : Get(false));
    }
}

/*****************\
*  ERROR MESSAGE  *
\*****************/
class ::Messages.Error extends ::Messages.Message
{
    constructor(tbl)
    {
        if(tbl != null && (typeof tbl) == "table")
        {
            base.constructor(tbl,"[ERROR]");
        }
    }

	function _typeof()
	{
		return Messages.MessageType.ERROR;
	}
}

/*******************\
*  WARNING MESSAGE  *
\*******************/
class ::Messages.Warning extends ::Messages.Message
{
    constructor(tbl)
    {
        if(tbl != null && (typeof tbl) == "table")
        {
            base.constructor(tbl,"[WARNING]")
        }
    }

	function _typeof()
	{
		return Messages.MessageType.WARNING;
	}
}

/**********************\
*  INFORMATION MESSAGE  *
\**********************/
class ::Messages.Info extends ::Messages.Message
{
    constructor(tbl)
    {
        if(tbl != null && (typeof tbl) == "table")
        {
            base.constructor(tbl,"[INFO]");
        }
    }

	function _typeof()
	{
		return Messages.MessageType.INFO;
	}
}

/************************\
*  DOCUMENTATION MESSAGE  *
\************************/
class ::Messages.Docs extends ::Messages.Message
{
    constructor(tbl)
    {
        if(tbl != null && (typeof tbl) == "table")
        {
            base.constructor(tbl,COLOR_BRIGHT_GREEN+"["+COLOR_ORANGE+"DOCS"+COLOR_BRIGHT_GREEN+"]");
        }
    }

	function _typeof()
	{
		return Messages.MessageType.DOCS;
	}
}


/***********************\
*  DOCS RELATED CLASSES  *
\***********************/

class ::CMDParam
{
    constructor(name,expected="",nullable=false,defaultval="")
    {
        _name = name;

        _expected = expected;

        _nullable = nullable;

        _default = defaultval;

    }

	function _typeof()
	{
		return "Parameter";
	}
	
	function _cmp(other)
	{
        return other._name == _name;
    }
    
    _name = null;
    _expected = null;
    _nullable = null;
    _default = null;
    static _type = "Parameter";

    function Describe()
    {
        if(_nullable)
        {
            return COLOR_ORANGE + _name + COLOR_DEFAULT + ": " + COLOR_OLIVE_GREEN + _expected + COLOR_DEFAULT + "(" + COLOR_BRIGHT_GREEN + "if nothing given: " + COLOR_OLIVE_GREEN + _default + COLOR_DEFAULT + ")"
        }
        return COLOR_ORANGE + _name + COLOR_DEFAULT + ": " + COLOR_OLIVE_GREEN + _expected
    }
}

class ::CMDDocs
{
    constructor(name,params=[],description="")
    {
        _name = name;

        _params = params;

        _desc = description;
    }

	function _typeof()
	{
		return "Documentation";
	}
	
	function _cmp(other)
	{
        return other._name == _name;
    }

    _name = null;
    _params = null;
    _desc = null;
    static _type = "Documentation";

    function Describe()
    {
        local paramstr = ""
        local len = _params.len()
        if(len != 0)
        {
            paramstr += COLOR_ORANGE+"Parameters"+COLOR_DEFAULT+":\n"
        }
        foreach(i,p in _params)
        {
            if(typeof p == "array")
            {   
                local formatparam = COLOR_BRIGHT_GREEN + "Format " + (i+1) + COLOR_DEFAULT + "\n"
                foreach(j,formatp in p)
                {
                    formatparam += "\t " + COLOR_OLIVE_GREEN + (j+1) + "." + COLOR_DEFAULT + formatp.Describe() + "\n"
                }
                paramstr += formatparam 
                if(i != len - 1)
                    paramstr += "\n"
            }
            else
            {
                paramstr += " " + COLOR_OLIVE_GREEN + (i+1) + "." + COLOR_DEFAULT + p.Describe() + "\n"
            }
        }
        paramstr = COLOR_BRIGHT_GREEN + _name + COLOR_DEFAULT + ":\n" 
                    + COLOR_ORANGE + ">>> " + COLOR_DEFAULT + _desc + "\n" 
                    + paramstr

        local splt = split(paramstr,"\n")
        return ::Messages.MessageSplit(splt)
    }
}

::Messages.MessageSplit <- function(splt)
{
    local result = []
    local spltlen = splt.len();
    if(spltlen == 0)
    {
        return [""]
    }
    if(spltlen > 1)	// New-lines
    {
        for(local i=0;i<spltlen;i++)
        {
            local mlen = splt[i].len();
            local ms = (mlen.tofloat() / (PRINTER_CHAR_LIMIT+0.1)).tointeger() + 1;
            if(mlen > PRINTER_CHAR_LIMIT)	// Too long line
            {
                for(local j=0;j<ms;j++)	// Slice into new lines
                {
                    local offset = PRINTER_CHAR_LIMIT*j;
                    local len = (j == ms-1) ? mlen%PRINTER_CHAR_LIMIT : PRINTER_CHAR_LIMIT;
                    result.append(splt[i].slice(offset,offset + len));
                }
            }
            else	// Valid length line
            {
                result.append(splt[i]);
            }
        }
    }
    else	// Single line, may be too long
    {   
        local mlen = splt[0].len();
        local ms = (mlen.tofloat() / (PRINTER_CHAR_LIMIT+0.1)).tointeger() + 1;
        if(mlen > PRINTER_CHAR_LIMIT)	// Too long line
        {
            for(local j=0;j<ms;j++)	// Slice into new lines
            {
                local offset = PRINTER_CHAR_LIMIT*j;
                local len = (j == ms-1) ? mlen%PRINTER_CHAR_LIMIT : PRINTER_CHAR_LIMIT;
                result.append(splt[0].slice(offset,offset + len))
            }
        }
        else	// Valid length line
        {
            result.append(splt[0]);
        }
    }
    return result;
}

::PrinterSplitDecider <- function(player,splt,messager)
{
	switch(messager)
	{
		case "warning":
		case "warn":
			Messages.WarnPlayer(player,splt);break;
		case "error":
		case "throw":
			Messages.ThrowPlayer(player,splt);break;
		default:
			Messages.InformPlayer(player,splt);break;
	}
}

/*
 * @authors rhino
 */
::Printer <- function(player,msg,messager=null)
{
	local splt = split(msg,"\n");
	local charname = player.GetCharacterName();
	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		local lines = ::Messages.MessageSplit(splt)
		foreach(i,line in lines)
		{
			PrinterSplitDecider(player,line,messager);
		}
	}
	else	// Using echo allows much longer messages (TO-DO: limit unknown)
	{
		msg = Utils.CleanColoredString(msg);
		messager = messager == null ? "info" : "error";

		if(splt.len() > 1)
		{
			// Do first part seperately, same process as above
			local mlen = splt[0].len();
			local ms = (mlen.tofloat() / (PRINTER_CHAR_LIMIT+0.1)).tointeger() + 1;
			if(mlen > PRINTER_CHAR_LIMIT)
			{
				printB(charname,charname+" -> ",true,messager,true,false);
				for(local j=0;j<ms;j++)
				{
					local offset = PRINTER_CHAR_LIMIT*j;
					local len = (j == ms-1) ? mlen%PRINTER_CHAR_LIMIT : PRINTER_CHAR_LIMIT;
					printB(charname,splt[0].slice(offset,offset + len),true,messager,false,false);
				}
			}
			else
			{
				printB(charname,charname+" -> "+splt[0],true,messager,true,false);
			}
			
			for(local i=1;i<splt.len();i++)
			{
				mlen = splt[i].len();
				ms = (mlen.tofloat() / (PRINTER_CHAR_LIMIT+0.1)).tointeger() + 1;
				if(mlen > PRINTER_CHAR_LIMIT)
				{
					for(local j=0;j<ms;j++)
					{
						local offset = PRINTER_CHAR_LIMIT*j;
						local len = (j == ms-1) ? mlen%PRINTER_CHAR_LIMIT : PRINTER_CHAR_LIMIT;
						printB(charname,splt[i].slice(offset,offset + len),true,"",false,false);
					}
				}
				else
				{
					printB(charname,splt[i],true,"",false,false);
				}
			}
			printB(charname,"",false,"",false,true,0.5);
		}
		else
		{
			printB(charname,charname+" -> "+msg,true,messager,true,true);
		}
	}
}