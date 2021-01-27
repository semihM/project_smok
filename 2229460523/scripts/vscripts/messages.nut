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
}

/* This bit started causing issues... might be multiple includes or wrong scopes
getconsttable()["COLOR_DEFAULT"] <- "\x01";
getconsttable()["COLOR_BRIGHT_GREEN"] <- "\x03";
getconsttable()["COLOR_ORANGE"] <- "\x04";
getconsttable()["COLOR_OLIVE_GREEN"] <- "\x05";
*/

/*********************\
*  BUILT-IN MESSAGES  *
\*********************/
::Messages.SetBIM <- function(tbl)
{
    local COLOR_DEFAULT = "\x01";
    local COLOR_BRIGHT_GREEN = "\x03";
    local COLOR_ORANGE = "\x04";
    local COLOR_OLIVE_GREEN = "\x05";

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
                    return name + " " + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " Changed meteor shower setting " + setting + " from " + old + " to " + new;
                }
            }

            ApocalypseSettings = 
            {
                StartingMessages = ["Something doesn't feel right...","Real apocalypse is only just starting...","Who is locking these doors?...","monkaOMEGA...","Shhh... Do you hear that ?"]

                Extras = [" or has it ?",""," only for a while...",""]

                Ending = "Apocalypse has been postponed..."

                Success = function(name,setting,old,new)
                {
                    return name + " " + COLOR_BRIGHT_GREEN + "->" + COLOR_DEFAULT + " Changed apocalypse setting " + setting + " from " + old + " to " + val;
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

                FireworkLength = "[Explosion-Warning] Fireworks disappear after 7 seconds"
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
                    return "Created " + classname + " entity(" + COLOR_BRIGHT_GREEN + "#" + ent.GetIndex() + COLOR_DEFAULT + ") named " + ent.GetName();
                }

                SuccessDoor = function(ent)
                {
                    return "Created a door (" + COLOR_BRIGHT_GREEN + "#" + ent.GetIndex() + COLOR_DEFAULT + ") named " + ent.GetName();
                }

                SettingSuccess = function(name,typ,setting,val)
                {
                    printl(name  + " Updated prop(" + typ + ") setting " + setting + " to " + val);
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
        }
    }

    tbl.BIM <- t;
}

::Messages.SetBIM(::Messages);

/**************************\
*  COMMAND HELPER MESSAGES  *
\**************************/
::Messages.SetCMDHelper <- function(tbl)
{
    local t = 
    {

    }

    tbl.CMDHelper <- t;
}

::Messages.SetCMDHelper(::Messages);

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

            _player = Messages.IdxAndTypeCheck(tbl,"_player","string") ? tbl._player : "";

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
                + (toPlayer && _player != "" ? _player + " -> " 
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
        local COLOR_DEFAULT = "\x01";
        local COLOR_BRIGHT_GREEN = "\x03";
        local COLOR_ORANGE = "\x04";
        local COLOR_OLIVE_GREEN = "\x05";
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
                        + (toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_ORANGE + " -> " 
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
                        + (toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_OLIVE_GREEN + " -> " 
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
                        + (toPlayer && _player != "" ? COLOR_DEFAULT + _player + COLOR_BRIGHT_GREEN + " -> " 
                                    : "")
                        + (_func == "" ? "" 
                                       : COLOR_BRIGHT_GREEN + _func + " ") 
                        + (argstr == "" ? ""
                                        : COLOR_OLIVE_GREEN + argstr + " ") 
                        + COLOR_DEFAULT + _msg;
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
                        colored ? GetColored() : Get());
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
                        colored ? GetColored() : Get());
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

