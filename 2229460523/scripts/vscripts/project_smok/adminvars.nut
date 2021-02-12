::AdminVars <- 
{
    // Old stuff
    IsBashDisabled = {}
    IsFreezeEnabled = {}
    IsBashLimited = {}
    IsNoclipEnabled = {}
    IsFlyingEnabled = {}
    IsGodEnabled = {}
    IsInfiniteAmmoEnabled = {}
    IsUnlimitedAmmoEnabled = {}
    IsInfiniteExplosiveAmmoEnabled = {}
    IsInfiniteIncendiaryAmmoEnabled = {}
    IsInfiniteLaserSightsEnabled = {}
    EnabledGodInfected = false
    EnabledGodSI = false
    DirectorDisabled = false
    AllowAdminsOnly = true
}

/*
 * Utility functions
 */
// Repeat same call and copy resulting table for valid survivor names
::AdminVars.RepeatFuncForSurvivors <- function(func,...)
{
    local res = {}
    
    // No arguments
    if(vargv.len() == 0)
    {
        foreach(name in ::Constants.Defaults.ValidSurvivorNamesLower)
        {
            res[name] <- ::VSLib.Utils.TableCopy(func());
        }
    }
    // Use respective names
    else if(vargv.len() == 1 && vargv[0] == "!self")
    {
        foreach(name in ::Constants.Defaults.ValidSurvivorNamesLower)
        {
            res[name] <- ::VSLib.Utils.TableCopy(func(name));
        }
    }
    else
    {
        // TO-DO : maybe write some stuff here
    }
    return res;
}

// Repeat same table for valid survivor names
::AdminVars.RepeatTableForSurvivors <- function(tbl)
{
    local res = {}
    foreach(name in ::Constants.Defaults.ValidSurvivorNamesLower)
    {
        res[name] <- ::VSLib.Utils.TableCopy(tbl);
    }
    return res;
}

// Repeat same value for valid survivor names
::AdminVars.RepeatValueForSurvivors <- function(val)
{
    local res = {}
    foreach(name in ::Constants.Defaults.ValidSurvivorNamesLower)
    {
        res[name] <- val;
    }
    return res;
}

// Fix incorrect restoration values
::AdminVars.FixBooleanTable <- function(tbl,index,lookup,blacklistkeys="")
{
    if(lookup == "boolean")
    {
        foreach(key,val in tbl[index])
        {
            if(blacklistkeys.find(key) != null)
                continue;

            switch(val)
            {
                case 0:
                    tbl[index][key] = false;break;
                case 1:
                    tbl[index][key] = true;break;
            }
            
        }
    }
}

// Fix given list of boolean values
::AdminVars.FixBooleanValues <- function(tbl,lis,lookup)
{
    if(lookup == "boolean")
    {
        foreach(val in lis)
        {
            switch(tbl[val])
            {
                case 0:
                    tbl[val] = false;break;
                case 1:
                    tbl[val] = true;break;
            }
            
        }
    }
}

/*
 * Default settings setters
 */

// Basic settings
::AdminVars.SetBasicSettings <- function(tbl)
{
    foreach(setting,val in ::Constants.Defaults.Basics)
    {
        tbl[setting] <- val;
    }
}

// Chat output state
::AdminVars.SetDefaultOutputSettings <- function(tbl)
{
    tbl._outputsEnabled <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.Outputs.State);
}

// Parameters for grabbing, letting go, yeeting entities
::AdminVars.SetDefaultGrabYeetSettings <- function(tbl)
{
    tbl._grabRadiusTolerance <- ::Constants.Defaults.Tables.GrabYeet.GrabRadiusTolerance;

    tbl._grabbackupprop <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.GrabYeet.BackUpProp);

    tbl._grabAvailable <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.GrabYeet.ValidGrabClasses);

    tbl._heldEntity <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.GrabYeet.SurvivorSettings);
}

// Hat stuff
::AdminVars.SetDefaultHatSettings <- function(tbl)
{
    tbl._wornHat <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.Hats.SurvivorSettings);
}

// Randomline stuff
::AdminVars.SetDefaultLineSaveSettings <- function(tbl)
{
    tbl._saveLastLine <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.LineSaving.State);

    tbl._savedLine <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.LineSaving.SurvivorSettings);
}

// Random model
::AdminVars.SetDefaultModelSaveSettings <- function(tbl)
{
    tbl._saveLastModel <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.ModelSaving.State);

    tbl._savedModel <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.ModelSaving.SurvivorSettings);
}

// Particle stuff
::AdminVars.SetDefaultParticleSettings <- function(tbl)
{
    tbl._saveLastParticle <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.Particles.State);

    tbl._savedParticle <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.Particles.SurvivorSettings);

    tbl._attachTargetedLocation <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.Particles.AttachAtAimedPointState);

    tbl._preferred_duration <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.Particles.AttachDuration);
}

// Prop spawn settings
::AdminVars.SetDefaultPropSpawnSettings <- function(tbl)
{
    tbl._prop_spawn_settings_menu_type <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.PropSpawn.Type);

    tbl._prop_spawn_settings <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.PropSpawn.SurvivorSettings);
}

// Looping stuff
::AdminVars.SetDefaultLoopingSettings <- function(tbl)
{
    tbl._looping <- AdminVars.RepeatValueForSurvivors(::Constants.Defaults.Tables.Looping.State);

    tbl._loopingTable <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.Looping.SurvivorSettings);
}

// Explosion stuff
::AdminVars.SetDefaultExplosionSettings <- function(tbl)
{
    tbl._explosion_settings <- AdminVars.RepeatTableForSurvivors(::Constants.Defaults.Tables.Explosions.SurvivorSettings);
}

// Model storage
::AdminVars.SetDefaultModelSettings <- function(tbl)
{
    tbl._modelPreference <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.ModelPreferences.SurvivorSettings);
}

// Custom Responses
::AdminVars.SetDefaultCustomResponseTables <- function(tbl)
{
    tbl._CustomResponse <- AdminVars.RepeatFuncForSurvivors(::Constants.Defaults.Tables.CustomResponses.SurvivorSettings,"!self");

    tbl._CustomResponseOptions <- AdminVars.RepeatFuncForSurvivors(::Constants.Defaults.Tables.CustomResponses.BIResponses,"!self");

}

// Apocalypse-propageddon
::AdminVars.SetDefaultApocalypseSettings <- function(tbl)
{
    tbl._propageddon_state <- ::Constants.Defaults.Tables.Apocalypse.State;
}

// Meteor Shower
::AdminVars.SetDefaultMeteorShowerSettings <- function(tbl)
{
    tbl._meteor_shower_state <- ::Constants.Defaults.Tables.MeteorShower.State;

    tbl._meteor_models <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.MeteorShower.Models);
}

// Trading related
::AdminVars.SetDefaultTradingSettings <- function(tbl)
{
    tbl._currentlyBeingTaken <- {};
}

// Piano related
::AdminVars.SetDefaultPianoSettings <- function(tbl)
{
	tbl._spawnedPianoKeys <- {};
}

// Character name arrays, non-survivors included
::AdminVars.SetDefaultCharNames <- function(tbl)
{
    tbl.CharacterNames <- ["Bill","Francis","Louis","Zoey","Nick","Ellis","Coach","Rochelle","","survivor"];
    tbl.CharacterNamesLower <- ["bill","francis","louis","zoey","nick","ellis","coach","rochelle","","survivor"];
}

// Enable built-in custom responses
::AdminVars.EnableCustomResponses <- function(tbl)
{
	foreach(name,optiontable in tbl._CustomResponseOptions)
	{
		foreach(event,settings in optiontable)
		{
			if(event.find("STEAM")!=null)
			{
				continue;
			}
			else
			{
				foreach(setting,value in settings)
				{
					tbl._CustomResponse[name][event][setting] = value;
				}
			}
		}
	}
}

::AdminVars.SetDefaultTankRockSettings <- function(tbl)
{
    tbl._RockThrow <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.TankRock);
}

// Enable stuff for spectators and others
::AdminVars.EnableCommandsForSpecsAndOthers <- function(tbl,basetbl=null)
{
    foreach(spec in {spectator = "", extrasurvivor = "survivor"})
	{
        //Outputs
		tbl._outputsEnabled[spec] <- ::Constants.Defaults.Tables.Outputs.State;

        //Loops
		tbl._loopingTable[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.Looping.SurvivorSettings)
		
		tbl._looping[spec] <- ::Constants.Defaults.Tables.Looping.State;
		
        //Particles
		tbl._savedParticle[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.Particles.SurvivorSettings)
		
		tbl._saveLastParticle[spec] <- ::Constants.Defaults.Tables.Particles.State;
		
		tbl._preferred_duration[spec] <- ::Constants.Defaults.Tables.Particles.AttachDuration;

		tbl._attachTargetedLocation[spec] <- ::Constants.Defaults.Tables.Particles.AttachAtAimedPointState;

        //Random model
		tbl._savedModel[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.ModelSaving.SurvivorSettings)
		
		tbl._saveLastModel[spec] <- ::Constants.Defaults.Tables.ModelSaving.State;

        //Lines
		tbl._savedLine[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.LineSaving.SurvivorSettings)
		
		tbl._saveLastLine[spec] <- ::Constants.Defaults.Tables.LineSaving.State;

        //Hats
		tbl._wornHat[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.Hats.SurvivorSettings)
		
        //Grab-yeet
		tbl._heldEntity[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.GrabYeet.SurvivorSettings)

        //Explosions
		tbl._explosion_settings[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.Explosions.SurvivorSettings)
		
        //Prop spawns
		tbl._prop_spawn_settings[spec] <- ::VSLib.Utils.TableCopy(::Constants.Defaults.Tables.PropSpawn.SurvivorSettings)

		tbl._prop_spawn_settings_menu_type[spec] <- ::Constants.Defaults.Tables.PropSpawn.Type;

        //Model prefs
		tbl._modelPreference[spec] <- 
        {
            keeplast = ::Constants.Defaults.Tables.ModelPreferences.State,
            lastmodel = ::Constants.Defaults.Tables.ModelPreferences.SurvivorSettings.bill
            original = ::Constants.Defaults.Tables.ModelPreferences.SurvivorSettings.bill
        }
		
        //Custom responses
		tbl._CustomResponseOptions[spec] <- {};
		tbl._CustomResponse[spec] <- ::Constants.GetCustomResponseDefaultTableFor(null);

        //Others
        if(basetbl != null)
        {
            basetbl._CarControl[spec] <- 
            {
                keymask = 0
                forward = Vector(0,0,0)
                speed = 575.0
                reversescale = -0.12
                speedscale = 3
                overridefriction = 0.03
                turnpertick = 8
                listenerid = -1
            };
            basetbl._RagdollControl[spec] <- 
            {
                keymask = 0
                speed = 250.0
                overridefriction = 0.3
                frictionduration = 1
                listenerid = -1
            }

            basetbl._CurrentlyTradingItems[spec] <- false;

            basetbl.BotBringingItem[spec] <- false;
            basetbl.BotOnSearchOrSharePath[spec] <- false;
            basetbl.BotTemporaryStopState[spec] <- false;
        }
	}
}

// Add functions to restored table
::AdminVars.FixRestoredTableFunctions <- function(tbl,ref)
{
    tbl.SetDefaultApocalypseSettings <- ref.SetDefaultApocalypseSettings;
    tbl.SetDefaultMeteorShowerSettings <- ref.SetDefaultMeteorShowerSettings;

    tbl.SetBasicSettings <- ref.SetBasicSettings;
    tbl.SetDefaultOutputSettings <- ref.SetDefaultOutputSettings;
    tbl.SetDefaultCharNames <- ref.SetDefaultCharNames;

    tbl.SetDefaultLineSaveSettings <- ref.SetDefaultLineSaveSettings;
    tbl.SetDefaultCustomResponseTables <- ref.SetDefaultCustomResponseTables;
    tbl.SetDefaultLoopingSettings <- ref.SetDefaultLoopingSettings;

    tbl.SetDefaultParticleSettings <- ref.SetDefaultParticleSettings;
    tbl.SetDefaultExplosionSettings <- ref.SetDefaultExplosionSettings;

    tbl.SetDefaultGrabYeetSettings <- ref.SetDefaultGrabYeetSettings;

    tbl.SetDefaultModelSaveSettings <- ref.SetDefaultModelSaveSettings;

    tbl.SetDefaultHatSettings <- ref.SetDefaultHatSettings;
    tbl.SetDefaultModelSettings <- ref.SetDefaultModelSettings;

    tbl.SetDefaultPianoSettings <- ref.SetDefaultPianoSettings;
    tbl.SetDefaultPropSpawnSettings <- ref.SetDefaultPropSpawnSettings;
    tbl.SetDefaultTradingSettings <- ref.SetDefaultTradingSettings;

    tbl.EnableCustomResponses <- ref.EnableCustomResponses;
    tbl.EnableCommandsForSpecsAndOthers <- ref.EnableCommandsForSpecsAndOthers;

    tbl.FixBooleanTable <- ref.FixBooleanTable;
    tbl.FixBooleanValues <- ref.FixBooleanValues;
}

/*
 * CALLS TO SETTERS
 */

::AdminVars.SetDefaultApocalypseSettings(::AdminVars);
::AdminVars.SetDefaultMeteorShowerSettings(::AdminVars);

::AdminVars.SetBasicSettings(::AdminVars);
::AdminVars.SetDefaultOutputSettings(::AdminVars);
::AdminVars.SetDefaultCharNames(::AdminVars);

::AdminVars.SetDefaultLineSaveSettings(::AdminVars);
::AdminVars.SetDefaultCustomResponseTables(::AdminVars);
::AdminVars.SetDefaultLoopingSettings(::AdminVars);

::AdminVars.SetDefaultParticleSettings(::AdminVars);
::AdminVars.SetDefaultExplosionSettings(::AdminVars);

::AdminVars.SetDefaultGrabYeetSettings(::AdminVars);

::AdminVars.SetDefaultModelSaveSettings(::AdminVars);

::AdminVars.SetDefaultHatSettings(::AdminVars);
::AdminVars.SetDefaultModelSettings(::AdminVars);
::AdminVars.SetDefaultTankRockSettings(::AdminVars);

::AdminVars.SetDefaultPianoSettings(::AdminVars);
::AdminVars.SetDefaultPropSpawnSettings(::AdminVars);
::AdminVars.SetDefaultTradingSettings(::AdminVars);

::AdminVars.EnableCustomResponses(::AdminVars);
::AdminVars.EnableCommandsForSpecsAndOthers(::AdminVars);