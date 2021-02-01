//-----------------------------------------------------
printl("Activating Admin System");

/**
 * Admin System by Rayman1103
 * Other authors : rhino
 */


// Include the VScript Library
IncludeScript("Admin_System/VSLib");

/// Include resource tables
IncludeScript("Resource_tables/Survivorlines");
// Particle names table
IncludeScript("Resource_tables/Particlenames");
// Model paths tables
IncludeScript("Resource_tables/Modelpaths");
// Netprop tables
IncludeScript("Resource_tables/Netproptables");

// Include the Message Class
IncludeScript("Messages");
// Include String Constants
IncludeScript("Constants");
// Include Custom Variables
IncludeScript("AdminVars");

::CmdMessages <- ::Messages.BIM.CMD;

if ( SessionState.ModeName == "coop" || SessionState.ModeName == "realism" || SessionState.ModeName == "survival" || SessionState.ModeName == "versus" || SessionState.ModeName == "scavenge" )
{
	if ( "cm_AggressiveSpecials" in SessionOptions )
		delete SessionOptions.cm_AggressiveSpecials;
	
	if ( "PreferredMobDirection" in SessionOptions )
		delete SessionOptions.PreferredMobDirection;
}

Utils.PrecacheCSSWeapons();

Convars.SetValue( "precache_all_survivors", "1" );

// The admin list
::AdminSystem <-
{
	Admins = {}
	BannedPlayers = {}
	HostPlayer = {}
	ScriptAuths = {}
	SoundName = {}
	AdminsOnly = true
	DisplayMsgs = true
	EnableIdleKick = false
	IdleKickTime = 60
	AdminPassword = ""
	Vars = Utils.TableCopy(::AdminVars)
	ZombieModels =
	[
		"common_female_tankTop_jeans",
		"common_female_tankTop_jeans_rain",
		"common_female_tshirt_skirt",
		"common_female_tshirt_skirt_swamp",
		"common_female_formal",
		"common_male_dressShirt_jeans",
		"common_male_polo_jeans",
		"common_male_tankTop_jeans",
		"common_male_tankTop_jeans_rain",
		"common_male_tankTop_jeans_swamp",
		"common_male_tankTop_overalls",
		"common_male_tankTop_overalls_rain",
		"common_male_tankTop_overalls_swamp",
		"common_male_tshirt_cargos",
		"common_male_tshirt_cargos_swamp",
		"common_male_formal",
		"common_male_biker",
		"common_male_ceda",
		"common_male_mud",
		"common_male_roadcrew",
		"common_male_roadcrew_rain",
		"common_male_fallen_survivor",
		"common_male_riot",
		"common_male_clown",
		"common_male_jimmy",
		"common_patient_male01_l4d2",
		"common_female_nurse01",
		"common_female_rural01",
		"common_female01",
		"common_male_baggagehandler_01",
		"common_male_pilot",
		"common_male_rural01",
		"common_male_suit",
		"common_male01",
		"common_military_male01",
		//"common_patient_male01"
		"common_police_male01",
		"common_surgeon_male01",
		"common_tsaagent_male01",
		"common_worker_male01"
		//"common_female_tankTop_jeans_swamp"
	]

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
		local spltlen = splt.len();
		if(spltlen > 1)	// New-lines
		{
			for(local i=0;i<spltlen;i++)
			{
				local mlen = splt[i].len();
				local ms = (mlen.tofloat() / 255.1).tointeger() + 1;
				if(mlen > 255)	// Too long line
				{
					for(local j=0;j<ms;j++)	// Slice into new lines
					{
						local offset = 255*j;
						local len = (j == ms-1) ? mlen%255 : 255;
						PrinterSplitDecider(player,splt[i].slice(offset,offset + len),messager);
					}
				}
				else	// Valid length line
				{
					PrinterSplitDecider(player,splt[i],messager);
				}
			}
		}
		else	// Valid length message
		{
			PrinterSplitDecider(player,msg,messager);
		}
	}
	else
	{
		msg = Utils.CleanColoredString(msg);
		messager = messager == null ? "info" : "error";

		if(splt.len() > 1)
		{
			// Do first part seperately, same process as above
			local mlen = splt[0].len();
			local ms = (mlen.tofloat() / 255.1).tointeger() + 1;
			if(mlen > 255)
			{
				printB(charname,charname+" -> ",true,messager,true,false);
				for(local j=0;j<ms;j++)
				{
					local offset = 255*j;
					local len = (j == ms-1) ? mlen%255 : 255;
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
				ms = (mlen.tofloat() / 255.1).tointeger() + 1;
				if(mlen > 255)
				{
					for(local j=0;j<ms;j++)
					{
						local offset = 255*j;
						local len = (j == ms-1) ? mlen%255 : 255;
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

::AdminSystem.LoadAdmins <- function ()
{
	local fileContents = FileToString(Constants.Directories.Admins);
	local admins = split(fileContents, "\r\n");
	local searchForHost = true;
	
	foreach (admin in admins)
	{
		if ( admin.find("//") != null )
		{
			admin = Utils.StringReplace(admin, "//" + ".*", "");
			admin = rstrip(admin);
		}
		if ( admin.find("STEAM_0") != null )
			admin = Utils.StringReplace(admin, "STEAM_0", "STEAM_1");
		if ( admin != "" )
			::AdminSystem.Admins[admin] <- true;
		
		if ( searchForHost == true )
		{
			AdminSystem.HostPlayer[admin] <- true;
			searchForHost = false;
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadScriptAuths <- function ()
{
	local fileContents = FileToString(Constants.Directories.ScriptAuths);
	local auths = split(fileContents, "\r\n");
	
	foreach (auth in auths)
	{
		if ( auth.find("//") != null )
		{
			auth = Utils.StringReplace(auth, "//" + ".*", "");
			auth = rstrip(auth);
		}
		if ( auth.find("STEAM_0") != null )
			auth = Utils.StringReplace(auth, "STEAM_0", "STEAM_1");
		if ( auth != "" )
			::AdminSystem.ScriptAuths[auth] <- true;
		
	}
}

::AdminSystem.LoadBanned <- function ()
{
	local fileContents = FileToString(Constants.Directories.Banned);
	local banned = split(fileContents, "\r\n");
	
	foreach (ban in banned)
	{
		if ( ban.find("//") != null )
		{
			ban = Utils.StringReplace(ban, "//" + ".*", "");
			ban = rstrip(ban);
		}
		if ( ban.find("STEAM_0") != null )
			ban = Utils.StringReplace(ban, "STEAM_0", "STEAM_1");
		if ( ban != "" )
			::AdminSystem.BannedPlayers[ban] <- true;
	}
}

::AdminSystem.LoadCvars <- function ( file )
{
	local fileContents = FileToString("admin system/" + file);
	local cvars = split(fileContents, "\r\n");
	
	foreach (cvar in cvars)
	{
		if ( cvar.find("//") != null )
		{
			cvar = Utils.StringReplace(cvar, "//" + ".*", "");
			cvar = rstrip(cvar);
		}
		if ( cvar != "" )
		{
			local value = cvar.slice( cvar.find(" ") );
			value = Utils.StringReplace( value, " ", "" );
			value = Utils.StringReplace( value, "\"", "" ); //"
			local command = Utils.StringReplace( cvar, value, "" );
			command = Utils.StringReplace( command, " ", "" );
			command = Utils.StringReplace( command, "\"", "" ); //"
			
			if ( cvar.find("scripted_user_func") == null )
				Convars.SetValue( command, value );
		}
	}
}

::AdminSystem.LoadScriptedCvars <- function ( file )
{
	local fileContents = FileToString("admin system/" + file);
	local cvars = split(fileContents, "\r\n");
	
	foreach (cvar in cvars)
	{
		if ( cvar.find("//") != null )
		{
			cvar = Utils.StringReplace(cvar, "//" + ".*", "");
			cvar = rstrip(cvar);
		}
		if ( cvar != "" )
		{
			if ( cvar.find("scripted_user_func") != null )
				SendToServerConsole( cvar );
		}
	}
}

::AdminSystem.LoadSettings <- function ()
{
	local fileContents = FileToString(Constants.Directories.Settings);
	local settings = split(fileContents, "\r\n");
	
	foreach (setting in settings)
	{
		if ( setting.find("//") != null )
		{
			setting = Utils.StringReplace(setting, "//" + ".*", "");
			setting = rstrip(setting);
		}
		if ( setting != "" )
		{
			//setting = Utils.StringReplace(setting, "=", "<-");
			local compiledscript = compilestring("AdminSystem." + setting);
			compiledscript();
		}
	}
}

/*
 * @authors rhino
 * TO-DO: Replace compilestring
 */
::AdminSystem.LoadApocalypseSettings <- function ()
{
	local fileContents = FileToString(Constants.Directories.ApocalypseSettings);
	local settings = split(fileContents, "\r\n");
	
	if(!("_propageddon_args" in AdminSystem))
		AdminSystem._propageddon_args <- {};

	foreach (setting in settings)
	{
		if ( setting != "" )
		{	
			compilestring("AdminSystem._propageddon_args." + Utils.StringReplace(setting, "=", "<-"))();
		}
	}
}

/*
 * @authors rhino
 * TO-DO: Replace compilestring
 */
::AdminSystem.LoadShowerSettings <- function (recursive=false)
{
	local fileContents = FileToString(Constants.Directories.MeteorShowerSettings);
	local settings = split(fileContents, "\r\n");
	
	if(!("_meteor_shower_args" in AdminSystem))
		AdminSystem._meteor_shower_args <- {};

	foreach (setting in settings)
	{
		if ( setting != "" )
		{	
			if(setting.find("meteormodelspecific") != null)
			{
				try
				{
					compilestring("AdminSystem._meteor_shower_args." + Utils.StringReplace(setting, "=", "<-"))();
				}
				catch(e)
				{
					AdminSystem._meteor_shower_args.meteormodelspecific <- Constants.GetMeteorShowerSettingsDefaults().meteormodelspecific;
					if(!recursive)
					{
						AdminSystem.SaveShowerSettings();
						AdminSystem.LoadShowerSettings(true);
						return;
					}
					else
					{
						printl("[Meteor-Shower-Error] Failed to load the meteor_shower_settings.txt, delete the file to fix the issue.");
						AdminSystem._meteor_shower_args <- Constants.GetMeteorShowerSettingsDefaults();
						return;
					}
				}
			}
			else
			{
				compilestring("AdminSystem._meteor_shower_args." + Utils.StringReplace(setting, "=", "<-"))();
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.SaveApocalypseSettings <- function ()
{
	local comments = Constants.GetApocalypseSettingsComments();
	local newstring = "";
	local length = AdminSystem._propageddon_args.len()-1;
	local i = 0;
	foreach (setting,val in AdminSystem._propageddon_args)
	{	
		newstring += setting + " = " + val.tostring() + " // " + comments[setting];

		if(i < length)
			newstring += " \r\n"
	}
	StringToFile(Constants.Directories.ApocalypseSettings, newstring);
}

/*
 * @authors rhino
 */
::AdminSystem.SaveShowerSettings <- function ()
{
	local comments = Constants.GetMeteorShowerSettingsComments();
	local newstring = "";
	local length = AdminSystem._meteor_shower_args.len()-1;
	local i = 0;
	foreach (setting,val in AdminSystem._meteor_shower_args)
	{	
		if(setting == "meteormodelspecific")
		{
			if(val.tostring() == "")
				val = "\""+Constants.GetMeteorShowerSettingsDefaults().meteormodelspecific+"\""
			else
				val = "\""+val+"\""
			newstring += setting + " = " + val.tostring() + " // " + comments[setting];
		}
		else
		{
			if(val.tostring() == "")
				val = "\"\""
			newstring += setting + " = " + val.tostring() + " // " + comments[setting];
		}
		if(i < length)
			newstring += " \r\n"
	}
	StringToFile(Constants.Directories.MeteorShowerSettings, newstring);
}

::AdminSystem.IsPrivileged <- function ( player, silent = false)
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !AdminSystem.AdminsOnly )
		AdminSystem.Vars.AllowAdminsOnly = false;
	
	if ( !(steamid in ::AdminSystem.Admins) && AdminSystem.Vars.AllowAdminsOnly )
	{
		if ( AdminSystem.DisplayMsgs && !silent )
			Messages.BIM.IsPrivileged.NoAccess(player);
		return false;
	}

	return true;
}

::AdminSystem.IsAdmin <- function ( player )
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !(steamid in ::AdminSystem.Admins) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.IsAdmin.NoAccess(player);
		return false;
	}

	return true;
}

/*
 * @authors rhino
 */
::AdminSystem.HasScriptAuth <- function ( player )
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !(steamid in ::AdminSystem.ScriptAuths) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.HasScriptAuth.NoAccess(player);
		return false;
	}

	return true;
}

::AdminSystem.GetID <- function ( player )
{
	if (!player || !("IsPlayerEntityValid" in player))
		return;
	else if (!player.IsPlayerEntityValid())
		return;
	
	local ID = player.GetSteamID();
	if ( ID == "BOT" )
	{
		if ( player.IsSurvivor() )
			ID = player.GetCharacterName();
	}
	
	return ID;
}

::AdminSystem.KickPlayer <- function( player )
{
	local steamid = player.GetSteamID();

	Timers.RemoveTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring() );
	if ( AdminSystem.DisplayMsgs )
		Messages.BIM.KickPlayer.Idle(player);
	SendToServerConsole( "kickid " + steamid + Messages.BIM.KickPlayer.KickedMessage() );
}

::AdminSystem.CalculateFly <- function ( player )
{
	if ( !player.IsEntityValid() )
		return false;
	
	if ( player.IsPressingJump() )
	{
		local vel = player.GetVelocity();
		local maxSpeed = 400.0;
		local speed = 200.0;
		
		if ( (vel.z + speed) > maxSpeed )
			vel.z = maxSpeed;
		else
			vel.z += speed;
		
		player.SetVelocity(vel);
	}
}

function EasyLogic::OnShutdown::AdminSaveData( reason, nextmap )
{
	if ( reason > 0 && reason < 4 )
	{	
		foreach(character,customs in AdminSystem.Vars._CustomResponse) // Reset call_amounts
		{
			foreach(event,restable in customs)
			{
				restable.call_amount = 0;
			}
		}
		SaveTable( "admin_variable_data", ::AdminSystem.Vars );
	}
	
}

function Notifications::OnRoundStart::AdminLoadFiles()
{
	local adminList = FileToString(Constants.Directories.Admins);
	local scriptauthList = FileToString(Constants.Directories.ScriptAuths);
	local banList = FileToString(Constants.Directories.Banned);
	local settingList = FileToString(Constants.Directories.Settings);
	local apocsettings = FileToString(Constants.Directories.ApocalypseSettings);
	local metosettings = FileToString(Constants.Directories.MeteorShowerSettings);

	local MessageTable = Messages.BIM.Events.OnRoundStart.AdminLoadFiles;

	if ( adminList != null )
	{
		MessageTable.LoadAdmins();
		AdminSystem.LoadAdmins();
	}
	if ( scriptauthList != null )
	{
		MessageTable.LoadScriptAuths();
		AdminSystem.LoadScriptAuths();
	}
	if ( banList != null )
	{
		MessageTable.LoadBanned();
		AdminSystem.LoadBanned();
	}
	if ( settingList != null )
	{
		MessageTable.LoadSettings();
		AdminSystem.LoadSettings();
	}
	else
	{
		MessageTable.CreateSettings();
		StringToFile(Constants.Directories.Settings, Constants.Defaults.Settings);
	}

	if ( apocsettings != null )
	{
		MessageTable.LoadApocalypseSettings();
		AdminSystem.LoadApocalypseSettings();
	}
	else
	{	
		MessageTable.CreateApocalypseSettings();
		StringToFile(Constants.Directories.ApocalypseSettings, Constants.Defaults.ApocalypseSettings);
	}

	if ( metosettings != null )
	{
		MessageTable.LoadMeteorShowerSettings();
		AdminSystem.LoadShowerSettings();
	}
	else
	{	
		MessageTable.CreateMeteorShowerSettings();
		StringToFile(Constants.Directories.MeteorShowerSettings, Constants.Defaults.MeteorShowerSettings);
	}

	RestoreTable( "admin_variable_data", ::AdminSystem.Vars );
	IncludeScript("AdminVars");

	if (::AdminSystem.Vars == null)
	{
		MessageTable.CreateVars();
		::AdminSystem.Vars <- Utils.TableCopy(::AdminVars);
	}
	else
	{
		if ( AdminSystem.Vars.DirectorDisabled )
			Utils.StopDirector();
		
		MessageTable.RestoreVars();
		
		::AdminVars.FixRestoredTableFunctions(::AdminSystem.Vars,::AdminVars);

		::AdminSystem.Vars.SetDefaultCharNames(::AdminSystem.Vars);

		::AdminSystem.Vars.SetDefaultLoopingSettings(::AdminSystem.Vars);

		::AdminSystem.Vars.SetDefaultPianoSettings(::AdminSystem.Vars);

		// Remove ladder teams table
		if(("_ladderteams" in AdminSystem.Vars))
			delete ::AdminSystem.Vars._ladderteams;
	}
	
	::AdminSystem.Vars.EnableCustomResponses(::AdminSystem.Vars);
	
	MessageTable.EnableSpecAndOther();

	::AdminSystem.Vars.EnableCommandsForSpecsAndOthers(::AdminSystem.Vars,::AdminSystem);

	// Fixes for tables
	//try
	//{	
	// Have to do this because squirrel is restoring "coach" as "Coach"
	if("Coach" in AdminSystem.Vars._outputsEnabled)
	{
		//printl("[Custom-Fix] Applying fixes to outputs table...");
		AdminSystem.Vars._outputsEnabled.coach <- AdminSystem.Vars._outputsEnabled.Coach;
		delete AdminSystem.Vars._outputsEnabled.Coach;
	}
	if("Coach" in AdminSystem.Vars._saveLastLine)
	{
		//printl("[Custom-Fix] Applying fixes to LastLine table...");
		AdminSystem.Vars._saveLastLine.coach <- AdminSystem.Vars._saveLastLine.Coach;
		delete AdminSystem.Vars._saveLastLine.Coach;
	}
	if("Coach" in AdminSystem.Vars._savedLine)
	{
		//printl("[Custom-Fix] Applying fixes to SavedLine table...");
		AdminSystem.Vars._savedLine.coach <- Utils.TableCopy(AdminSystem.Vars._savedLine.Coach);
		delete AdminSystem.Vars._savedLine.Coach;
	}
	if("Coach" in AdminSystem.Vars._savedParticle)
	{
		//printl("[Custom-Fix] Applying fixes to SavedParticle table...");
		AdminSystem.Vars._savedParticle.coach <- Utils.TableCopy(AdminSystem.Vars._savedParticle.Coach);
		delete AdminSystem.Vars._savedParticle.Coach;
	}
	if("Coach" in AdminSystem.Vars._saveLastParticle)
	{
		//printl("[Custom-Fix] Applying fixes to LastParticle table...");
		AdminSystem.Vars._saveLastParticle.coach <- AdminSystem.Vars._saveLastParticle.Coach;
		delete AdminSystem.Vars._saveLastParticle.Coach;
	}
	if("Coach" in AdminSystem.Vars._preferred_duration)
	{
		//printl("[Custom-Fix] Applying fixes to preferred_duration table...");
		AdminSystem.Vars._preferred_duration.coach <- AdminSystem.Vars._preferred_duration.Coach;
		delete AdminSystem.Vars._preferred_duration.Coach;
	}
	if("Coach" in AdminSystem.Vars._prop_spawn_settings_menu_type)
	{
		//printl("[Custom-Fix] Applying fixes to prop_spawn_settings_menu_type table...");
		AdminSystem.Vars._prop_spawn_settings_menu_type.coach <- AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
		delete AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
	}
	if("Coach" in AdminSystem.Vars._prop_spawn_settings)
	{
		//printl("[Custom-Fix] Applying fixes to prop_spawn_settings table...");
		AdminSystem.Vars._prop_spawn_settings.coach <- Utils.TableCopy(AdminSystem.Vars._prop_spawn_settings.Coach);
		delete AdminSystem.Vars._prop_spawn_settings.Coach;
	}
	if("Coach" in AdminSystem.Vars._explosion_settings)
	{
		//printl("[Custom-Fix] Applying fixes to explosion_settings table...");
		AdminSystem.Vars._explosion_settings.coach <- Utils.TableCopy(AdminSystem.Vars._explosion_settings.Coach);
		delete AdminSystem.Vars._explosion_settings.Coach;
	}
	if("Coach" in AdminSystem.Vars._heldEntity)
	{
		//printl("[Custom-Fix] Applying fixes to HeldEntity table...");
		AdminSystem.Vars._heldEntity.coach <- Utils.TableCopy(AdminSystem.Vars._heldEntity.Coach);
		delete AdminSystem.Vars._heldEntity.Coach;
		AdminSystem.Vars._heldEntity.bill.entid = "";
		AdminSystem.Vars._heldEntity.francis.entid = "";
		AdminSystem.Vars._heldEntity.louis.entid = "";
		AdminSystem.Vars._heldEntity.zoey.entid = "";
		AdminSystem.Vars._heldEntity.nick.entid = "";
		AdminSystem.Vars._heldEntity.ellis.entid = "";
		AdminSystem.Vars._heldEntity.coach.entid = "";
		AdminSystem.Vars._heldEntity.rochelle.entid = "";
	}
	if("Coach" in AdminSystem.Vars._wornHat)
	{
		//printl("[Custom-Fix] Applying fixes to WornHat table...");
		AdminSystem.Vars._wornHat.coach <- Utils.TableCopy(AdminSystem.Vars._wornHat.Coach);
		delete AdminSystem.Vars._wornHat.Coach;
		AdminSystem.Vars._wornHat.bill.entid = "";
		AdminSystem.Vars._wornHat.francis.entid = "";
		AdminSystem.Vars._wornHat.louis.entid = "";
		AdminSystem.Vars._wornHat.zoey.entid = "";
		AdminSystem.Vars._wornHat.nick.entid = "";
		AdminSystem.Vars._wornHat.ellis.entid = "";
		AdminSystem.Vars._wornHat.coach.entid = "";
		AdminSystem.Vars._wornHat.rochelle.entid = "";
	}
	if("Coach" in AdminSystem.Vars._modelPreference)
	{
		//printl("[Custom-Fix] Applying fixes to model preference table...");
		AdminSystem.Vars._modelPreference.coach <- Utils.TableCopy(AdminSystem.Vars._modelPreference.Coach);
		delete AdminSystem.Vars._modelPreference.Coach;
	}
	local skip = false;
	if("Coach" in AdminSystem.Vars._CustomResponseOptions)
	{	
		//printl("[Custom-Fix] Applying fixes to CustomResponse table...");
		AdminSystem.Vars._CustomResponseOptions.coach <- Utils.TableCopy(AdminSystem.Vars._CustomResponseOptions.Coach);
		delete AdminSystem.Vars._CustomResponseOptions.Coach;
		AdminSystem.Vars._CustomResponse.coach <- Utils.TableCopy(AdminSystem.Vars._CustomResponse.Coach);
		delete AdminSystem.Vars._CustomResponse.Coach;
	}
	else
	{	
		// Apply options created by admins
		AdminSystem.LoadCustomSequences();
		//throw("No need for fixes in CustomRespose tables");
		//printl("[OnRoundStart-Info] No need for fixes in CustomRespose tables");
		skip = true;
	}

	// Fix incorrectly restored booleans
	local fixdata = 
	{
		_outputsEnabled = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_saveLastParticle = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_saveLastLine = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_attachTargetedLocation = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_looping = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_RockThrow = 
		{
			lookup = "boolean"
			blackliststr = "rockorigin,rockpushspeed,raise,friction"
		}
	}
	
	local basicbools = 
	[
		"RestoreModelsOnJoin",
		"IgnoreDeletingPlayers",
		"AllowCustomResponses",
		"AllowCustomSharing",
		"AllowAutomatedSharing",
		"LastLootThinkState",
		"IgnoreSpeakerClass"
	]

	foreach(key,datatbl in fixdata)
	{
		::AdminSystem.Vars.FixBooleanTable(AdminSystem.Vars,key,datatbl.lookup,datatbl.blackliststr);
	}

	::AdminSystem.Vars.FixBooleanValues(AdminSystem.Vars,basicbools,"boolean");

	::AdminSystem.Vars._RockThrow.rockorigin = null;

	// Fix custom responses table
	if(!skip)
	{
		///////////////////////////////////////////////
		/* RestoreTable is also bad
		* Have to manually update : sequence, lastspoken, randomlinepaths 
		*/

		local newsequence = {scenes=[],delays=[]};
		local newlastspoken = [];
		local newrandomlinepaths = [];
		local i = 0;

		// BASE
		foreach(charname,restable in AdminSystem.Vars._CustomResponse)
		{
			foreach(eventname,basetable in restable)
			{	
				//Sequence
				foreach(seqname,seqtable in basetable.sequence)
				{	
					if( (typeof seqtable.scenes) != "table")
					{
						continue; // It's already fixed, check next one
					}
					newsequence = {scenes=[],delays=[]}
					i = 0;
					while(i.tostring() in seqtable.scenes)
					{	
						newsequence.scenes.append(seqtable.scenes[i.tostring()]);
						newsequence.delays.append(seqtable.delays[i.tostring()]);
						i += 1;
					}

					AdminSystem.Vars._CustomResponse[charname][eventname].sequence[seqname] = Utils.TableCopy(newsequence);
				}
				
				//Lastspoken
				if("lastspoken" in basetable)
				{	
					if((typeof basetable.lastspoken) == "table")
					{
						newlastspoken = []
						i = 0;
						while(i.tostring() in basetable.lastspoken)
						{
							newlastspoken.append(basetable.lastspoken[i.tostring()]);
							i += 1;
						}
						AdminSystem.Vars._CustomResponse[charname][eventname].lastspoken = Utils.ArrayCopy(newlastspoken);
					}
				}
				
				//randomlinepaths
				if("randomlinepaths" in basetable)
				{	
					if((typeof basetable.randomlinepaths) == "table")
					{
						newrandomlinepaths = []
						i = 0;
						while(i.tostring() in basetable.randomlinepaths)
						{
							newrandomlinepaths.append(basetable.randomlinepaths[i.tostring()]);
							i += 1;
						}
						AdminSystem.Vars._CustomResponse[charname][eventname].randomlinepaths = Utils.ArrayCopy(newrandomlinepaths);
					}
				}
			}
		}

		// DEFAULT OPTIONS
		foreach(charname,restable in AdminSystem.Vars._CustomResponseOptions)
		{
			foreach(eventname,basetable in restable)
			{	
				//Sequence
				foreach(seqname,seqtable in basetable.sequence)
				{	
					if( (typeof seqtable.scenes) != "table")
					{
						continue; // It's already fixed, check next one
					}
					newsequence = {scenes=[],delays=[]}
					i = 0;
					while(i.tostring() in seqtable.scenes)
					{	
						newsequence.scenes.append(seqtable.scenes[i.tostring()]);
						newsequence.delays.append(seqtable.delays[i.tostring()]);
						i += 1;
					}
					
					AdminSystem.Vars._CustomResponseOptions[charname][eventname].sequence[seqname] = Utils.TableCopy(newsequence);
				}
				
				//randomlinepaths
				if(("randomlinepaths" in basetable) && ((typeof basetable.randomlinepaths) != "table"))
				{	
					newrandomlinepaths = []
					i = 0;
					while(i.tostring() in basetable.randomlinepaths)
					{
						newrandomlinepaths.append(basetable.randomlinepaths[i.tostring()]);
						i += 1;
					}

					AdminSystem.Vars._CustomResponseOptions[charname][eventname].randomlinepaths = Utils.ArrayCopy(newrandomlinepaths);
				}
				
			}
		}

		local newmodelarray = null

		// Meteor models
		foreach(label,modelarr in AdminSystem.Vars._meteor_models)
		{
			//_rocks
			if((label=="_rocks") && ((typeof modelarr) != "array"))
			{	
				newmodelarray = []
				i = 0;
				while(i.tostring() in modelarr)
				{
					newmodelarray.append(modelarr[i.tostring()]);
					i += 1;
				}

				AdminSystem.Vars._meteor_models._rocks = Utils.ArrayCopy(newmodelarray);
			}
			//_chunks
			else if((label=="_chunks") && ((typeof modelarr) != "array"))
			{	
				newmodelarray = []
				i = 0;
				while(i.tostring() in modelarr)
				{
					newmodelarray.append(modelarr[i.tostring()]);
					i += 1;
				}

				AdminSystem.Vars._meteor_models._chunks = Utils.ArrayCopy(newmodelarray);
			}
			//_custom
			else if((label=="_custom") && ((typeof modelarr) != "array"))
			{	
				newmodelarray = []
				i = 0;
				while(i.tostring() in modelarr)
				{
					newmodelarray.append(modelarr[i.tostring()]);
					i += 1;
				}

				AdminSystem.Vars._meteor_models._custom = Utils.ArrayCopy(newmodelarray);
			}
			else
				throw("No need for meteor shower model array fixes, "+label+" "+(typeof modelarr))
		}
	
	}
		
	//}
	//catch(e){printl("[OnRoundStart-AdminLoadFiles] "+e);}
	
	printl("[Custom] Loaded custom responses created by admins");

	if(AdminSystem.Vars._propageddon_state == 1)
	{
		::VSLib.Timers.AddTimer(3,false,Utils.PrintToAllDel,"Madness continues...");
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.Apocalypse,AdminSystem._propageddon_args.updatedelay, true, _ApocalypseTimer,{});	
	}

	if(AdminSystem.Vars._meteor_shower_state == 1)
	{
		::VSLib.Timers.AddTimer(3.2,false,Utils.PrintToAllDel,"Is it still raining?");
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.MeteorShower,AdminSystem._meteor_shower_args.updatedelay, true, _MeteorTimer,{});	
	}

	if(AdminSystem.Vars.LastLootThinkState)
	{
		::VSLib.Timers.AddTimer(8,false,DelayedBotLootThinkAdder,{});
	}
	else
	{
		printl("[Bot-Thinker] Disabled looting/sharing thinking for bots ");
	}

	//Restore models if necessary
	foreach(survivor in Players.AliveSurvivors())
	{
		AdminSystem.RestoreModels(survivor);
	}
}

::DelayedBotLootThinkAdder <- function(...)
{
	local tadd = _CreateLootThinker();
	printl("[Bot-Thinker] Enabled looting/sharing thinking for bots via adder #"+tadd.GetIndex());
}

::AdminSystem.RestoreModels <- function(player)
{
	if(!("Vars" in AdminSystem))
		return;
	if(!("RestoreModelsOnJoin" in AdminSystem.Vars))
		return;

	if(AdminSystem.Vars.RestoreModelsOnJoin)
	{
		local name = player.GetCharacterNameLower();
		if(name == "" || name == "survivor")
			return;

		if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,name)==-1)
			return;

		local tbl = AdminSystem.Vars._modelPreference[name];
		if(tbl.keeplast)
		{
			player.SetModel(tbl.lastmodel)
			Messages.BIM.Events.OnPlayerConnected.RestoreModels.RestoringLast(player.GetCharacterName(),tbl.lastmodel);
		}
		else
		{
			player.SetModel(tbl.original)
			Messages.BIM.Events.OnPlayerConnected.RestoreModels.RestoringOrg(player.GetCharacterName());
		}
	}
}

function Notifications::OnPlayerConnected::RestoreModels(player,args)
{
	if(!::VSLib.EasyLogic.NextMapContinues)
		AdminSystem.RestoreModels(player);
}

function Notifications::OnModeStart::AdminLoadFiles( gamemode )
{
	local cvarList = FileToString(Constants.Directories.Cvars);
	local baseCvarList = FileToString("admin system/" + gamemode + "_cvars.txt");
	local modeCvarList = FileToString("admin system/" + SessionState.ModeName + "_cvars.txt");
	
	if ( modeCvarList != null )
	{
		printf("[Cvars] Loading %s convars...", SessionState.ModeName);
		AdminSystem.LoadCvars(SessionState.ModeName + "_cvars.txt");
		AdminSystem.LoadScriptedCvars(SessionState.ModeName + "_cvars.txt");
	}
	else
	{
		if ( baseCvarList != null )
		{
			printf("[Cvars] Loading %s convars...", gamemode);
			AdminSystem.LoadCvars(gamemode + "_cvars.txt");
			AdminSystem.LoadScriptedCvars(gamemode + "_cvars.txt");
		}
		else
		{
			if ( cvarList != null )
			{
				printf("[Cvars] Loading convars...");
				AdminSystem.LoadCvars("cvars.txt");
				AdminSystem.LoadScriptedCvars("cvars.txt");
			}
		}
	}
}

function Notifications::OnPlayerJoined::AdminBanCheck( player, name, IPAddress, SteamID, params )
{
	if ( player )
	{
		local steamid = player.GetSteamID();
		
		if ( (steamid in ::AdminSystem.BannedPlayers) )
			SendToServerConsole( "kickid " + steamid + Messages.BIM.Events.OnPlayerJoined.AdminBanCheck.BannedMessage() );
	}
}

function Notifications::OnPlayerJoined::AdminCheck( player, name, IPAddress, SteamID, params )
{
	local adminList = FileToString(Constants.Directories.Admins);
	if ( adminList != null )
		return;
	
	if ( player )
	{
		if ( player.IsBot() || !player.IsServerHost() )
			return;
		
		local admins = FileToString(Constants.Directories.Admins);
		local steamid = player.GetSteamID();
		if ( steamid == "" || steamid == "BOT" )
			return;
		admins = steamid + " //" + player.GetName();
		StringToFile(Constants.Directories.Admins, admins);
		AdminSystem.LoadAdmins();
	}
}

/*
 * @authors rhino
 */
function Notifications::OnPlayerJoined::ScriptAuthCheck( player, name, IPAddress, SteamID, params )
{
	local authList = FileToString(Constants.Directories.ScriptAuths);
	if ( authList != null )
		return;
	
	if ( player )
	{
		if ( player.IsBot() || !player.IsServerHost() )
			return;
		
		local auths = FileToString(Constants.Directories.ScriptAuths);
		local steamid = player.GetSteamID();
		if ( steamid == "" || steamid == "BOT" )
			return;
		auths = steamid + " //" + player.GetName();
		StringToFile(Constants.Directories.ScriptAuths, auths);
		AdminSystem.LoadScriptAuths();
	}
}

function Notifications::OnWeaponFire::AdminGiveUpgradeAmmo( player, classname, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if (((ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])) || (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID]))
	{
		if ( "slot0" in PlayerInv )
		{
			local wep = PlayerInv["slot0"];
			if ( wep.GetClassname() == classname )
			{
				if ( wep.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") > 0 )
					wep.SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", wep.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") + 1 );
			}
		}
	}
	if ((ID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteAmmoEnabled[ID]))
	{
		local wep = player.GetActiveWeapon();
		wep.SetNetProp( "m_iClip1", wep.GetNetPropInt("m_iClip1") + 1 );
	}
}

function Notifications::OnWeaponReload::AdminGiveUpgradeAmmo( player, manual, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if (((ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])) || (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID]))
	{
		if ( "slot0" in PlayerInv )
		{
			local wep = PlayerInv["slot0"];
			if ( wep.GetClassname() == player.GetActiveWeapon().GetClassname() )
				player.SetPrimaryAmmo( player.GetMaxPrimaryAmmo() + (wep.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") * 2) );
		}
	}
	if ((ID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled) && (::AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID]))
	{
		player.GiveAmmo( 999 );
	}
}

function Notifications::OnItemPickup::AdminGiveUpgrade( player, classname, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if ( "slot0" in PlayerInv )
	{
		if ( PlayerInv["slot0"].GetClassname() == classname )
		{
			if (ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled && ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			else if (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled && ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			if (ID in ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled && ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_LASER_SIGHT );
				player.Input( "CancelCurrentScene" );
			}
		}
	}
}

function Notifications::OnUse::AdminGiveUpgrade( player, target, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if ( "slot0" in PlayerInv )
	{
		if ( PlayerInv["slot0"].GetClassname() == target.GetClassname() )
		{
			if (ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled && ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			else if (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled && ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			if (ID in ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled && ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_LASER_SIGHT );
				player.Input( "CancelCurrentScene" );
			}
		}
	}
}

/*
 * @authors rhino
 */
function Notifications::OnPlayerReplacedBot::LetGoHeldPlayer(player,bot,args)
{
	//printl("Bot #"+bot.GetIndex()+" was replaced with Player #"+player.GetIndex())
	local botparent = bot.GetParent();
	if(botparent != null)
	{
		if(AdminSystem.IsPrivileged(botparent,true))
			AdminSystem.LetgoCmd(botparent,null);
		bot.Input("ClearParent","",0);
		_dropit(bot);
	}
}

/*
 * @authors rhino
 */
function Notifications::OnBotReplacedPlayer::LetGoHeldPlayer(player,bot,args)
{
	//printl("Player #"+player.GetIndex()+" was replaced with Bot #"+bot.GetIndex())
	
	if(AdminSystem.IsPrivileged(player,true))
		AdminSystem.LetgoCmd(player,null);

	foreach(survivor in Players.AliveSurvivors())
	{
		if(AdminSystem.Vars._heldEntity[survivor.GetCharacterNameLower()].entid == player.GetIndex().tostring())
		{
			AdminSystem.LetgoCmd(survivor,null);
		}
	}
}

function Notifications::OnBotReplacedPlayer::AdminStartIdleKickTimer( player, bot, params )
{
	if ( AdminSystem.EnableIdleKick && !(player.GetSteamID() in ::AdminSystem.Admins) )
		Timers.AddTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring(), AdminSystem.IdleKickTime, false, AdminSystem.KickPlayer, player );
}

function Notifications::OnPlayerReplacedBot::AdminStopIdleKickTimer( player, bot, params )
{
	if ( AdminSystem.EnableIdleKick && !(player.GetSteamID() in ::AdminSystem.Admins) )
		Timers.RemoveTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring() );
}

function EasyLogic::OnTakeDamage::AdminDamage( damageTable )
{
	if (!damageTable.Victim)
		return;
	
	local attacker = Utils.GetEntityOrPlayer(damageTable.Attacker);
	local victim = Utils.GetEntityOrPlayer(damageTable.Victim);
	local ID = AdminSystem.GetID(victim);
	
	if (ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID])
		return false; // return 0 damage
	if ( AdminSystem.Vars.EnabledGodInfected )
	{
		if ( victim.GetType() != Z_SURVIVOR )
			return false;
	}
	if ( AdminSystem.Vars.EnabledGodSI )
	{
		if ( victim.GetType() != Z_SURVIVOR && victim.GetType() != Z_COMMON && victim.GetType() != Z_WITCH )
			return false;
	}
	
	if(victim.GetIndex() in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[victim.GetIndex()])
	{
		//printl("Ignoring damage for just unfrozen SI.")
		return false;
	}
	return true;
}

function EasyLogic::OnBash::AdminBash(attacker, victim)
{
	local ID = AdminSystem.GetID( attacker );
	
	if (ID in ::AdminSystem.Vars.IsBashDisabled && ::AdminSystem.Vars.IsBashDisabled[ID])
	{
		return ALLOW_BASH_NONE;
	}
	else if (ID in ::AdminSystem.Vars.IsBashLimited && ::AdminSystem.Vars.IsBashLimited[ID])
	{
		return ALLOW_BASH_PUSHONLY;
	}
}

// Stops the Tank music from playing over the Dark Carnival finale music
if ( ( SessionState.MapName == "c2m5_concert" ) && ( SessionState.ModeName == "coop" || SessionState.ModeName == "realism" || SessionState.ModeName == "versus" ) )
{
	function Notifications::OnSpawn::AdminDCTankMusicFix( player, params )
	{
		if ( !Utils.HasFinaleStarted() )
			return;
		
		if ( ( !player.IsSurvivor() ) && ( player.GetType() == Z_TANK ) )
		{
			function StopTankMusic( args )
			{
				local world = Entity("worldspawn");
				if ( world )
					world.StopSound("Event.Tank");
			}
			
			Timers.AddTimer(0.1, false, StopTankMusic);
		}
	}
}

function EasyLogic::OnUserCommand::AdminCommands(player, args, text)
{
	local Command = GetArgument(0);
	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	switch ( Command )
	{
		case "adminmode":
		{
			AdminSystem.AdminModeCmd( player, args );
			break;
		}
		case "add_script_auth":
		{
			AdminSystem.AddScriptAuthCmd( player, args );
			break;
		}
		case "remove_script_auth":
		{
			AdminSystem.RemoveScriptAuthCmd( player, args );
			break;
		}
		case "add_admin":
		{
			AdminSystem.AddAdminCmd( player, args );
			break;
		}
		case "remove_admin":
		{
			AdminSystem.RemoveAdminCmd( player, args );
			break;
		}
		case "give":
		{
			AdminSystem.GiveCmd( player, args );
			break;
		}
		case "remove":
		{
			AdminSystem.RemoveCmd( player, args );
			break;
		}
		case "drop":
		{
			AdminSystem.DropCmd( player, args );
			break;
		}
		case "use":
		{
			AdminSystem.UseCmd( player, args );
			break;
		}
		case "speak":
		{
			AdminSystem.SpeakCmd( player, args );
			break;
		}
		case "upgrade_add":
		{
			AdminSystem.UpgradeAddCmd( player, args );
			break;
		}
		case "upgrade_remove":
		{
			AdminSystem.UpgradeRemoveCmd( player, args );
			break;
		}
		case "adrenaline":
		{
			AdminSystem.AdrenalineCmd( player, args );
			break;
		}
		case "ammo":
		{
			AdminSystem.AmmoCmd( player, args );
			break;
		}
		case "warp":
		{
			AdminSystem.WarpCmd( player, args );
			break;
		}
		case "warp_here":
		{
			AdminSystem.WarpHereCmd( player, args );
			break;
		}
		case "warp_saferoom":
		{
			AdminSystem.WarpSaferoomCmd( player, args );
			break;
		}
		case "move":
		{
			AdminSystem.MoveCmd( player, args );
			break;
		}
		case "chase":
		{
			AdminSystem.ChaseCmd( player, args );
			break;
		}
		case "incap":
		{
			AdminSystem.IncapCmd( player, args );
			break;
		}
		case "kill":
		{
			AdminSystem.KillCmd( player, args );
			break;
		}
		case "hurt":
		{
			AdminSystem.HurtCmd( player, args );
			break;
		}
		case "revivecount":
		{
			AdminSystem.ReviveCountCmd( player, args );
			break;
		}
		case "revive":
		{
			AdminSystem.ReviveCmd( player, args );
			break;
		}
		case "defib":
		{
			AdminSystem.DefibCmd( player, args );
			break;
		}
		case "rescue":
		{
			AdminSystem.RescueCmd( player, args );
			break;
		}
		case "respawn":
		{
			AdminSystem.RespawnCmd( player, args );
			break;
		}
		case "extinguish":
		{
			AdminSystem.ExtinguishCmd( player, args );
			break;
		}
		case "ignite":
		{
			AdminSystem.IgniteCmd( player, args );
			break;
		}
		case "vomit":
		{
			AdminSystem.VomitCmd( player, args );
			break;
		}
		case "stagger":
		{
			AdminSystem.StaggerCmd( player, args );
			break;
		}
		case "health":
		{
			AdminSystem.HealthCmd( player, args );
			break;
		}
		case "max_health":
		{
			AdminSystem.MaxHealthCmd( player, args );
			break;
		}
		case "friction":
		{
			AdminSystem.FrictionCmd( player, args );
			break;
		}
		case "gravity":
		{
			AdminSystem.GravityCmd( player, args );
			break;
		}
		case "color":
		{
			AdminSystem.ColorCmd(player, args);
			break;
		}
		case "setkeyval":
		{
			AdminSystem.SetkeyvalCmd(player, args);
			break;
		}
		case "attach_particle":
		{
			AdminSystem.Attach_particleCmd(player, args);
			break;
		}
		case "attach_to_targeted_position":
		{
			AdminSystem.Attach_to_targeted_positionCmd(player, args);
			break;
		}
		case "randomparticle_save_state":
		{
			AdminSystem.Randomparticle_save_stateCmd(player, args);
			break;
		}
		case "update_attachment_preference":
		{
			AdminSystem.Update_attachment_preferenceCmd(player, args);
			break;
		}
		case "display_saved_particle":
		{
			AdminSystem.Display_saved_particleCmd(player, args);
			break;
		}
		case "spawn_particle_saved":
		{
			AdminSystem.Spawn_particle_savedCmd(player, args);
			break;
		}
		case "attach_particle_saved":
		{
			AdminSystem.Attach_particle_savedCmd(player, args);
			break;
		}
		case "hat_position":
		{
			AdminSystem._HatPosition(player, args);
			break;
		}
		case "update_aimed_ent_direction":
		{
			AdminSystem.UpdateAimedEntityDirection(player, args);
			break;
		}
		case "wear_hat":
		{
			AdminSystem._WearHatCmd(player, args);
			break;
		}
		case "take_off_hat":
		{
			AdminSystem._TakeOffHatCmd(player, args);
			break;
		}
		case "update_svcheats":
		{
			AdminSystem.Update_svcheatsCmd(player, args);
			break;
		}
		case "update_prop_spawn_setting":
		{
			AdminSystem.Update_prop_spawn_settingCmd(player, args);
			break;
		}
		case "update_prop_spawn_menu_type":
		{
			AdminSystem.Update_prop_spawn_menu_typeCmd(player, args);
			break;
		}
		case "display_prop_spawn_settings":
		{
			AdminSystem.Display_prop_spawn_settingsCmd(player, args);
			break;
		}
		case "rainbow":
		{
			AdminSystem.RainbowCmd(player, args);
			break;
		}
		case "randomline":
		{
			AdminSystem.RandomlineCmd(player, args);
			break;
		}
		case "update_print_output_state":
		{
			AdminSystem.Update_print_output_stateCmd(player, args);
			break;
		}
		case "randomline_save_last":
		{
			AdminSystem.Randomline_save_lastCmd(player, args);
			break;
		}
		case "speak_saved":
		{
			AdminSystem.Speak_savedCmd(player, args);
			break;
		}
		case "display_saved_line":
		{
			AdminSystem.Display_saved_lineCmd(player, args);
			break;
		}
		case "debug_info":
		{
			AdminSystem.Debug_infoCmd(player, args);
			break;
		}
		case "server_exec":
		{
			AdminSystem.Server_execCmd(player, args);
			break;
		}
		case "save_line":
		{
			AdminSystem.Save_lineCmd(player, args);
			break;
		}
		case "save_particle":
		{
			AdminSystem.Save_particleCmd(player, args);
			break;
		}
		case "update_custom_response_preference":
		{
			AdminSystem.Update_custom_response_preferenceCmd(player, args);
			break;
		}
		case "update_custom_sharing_preference":
		{
			AdminSystem.Update_custom_sharing_preferenceCmd(player, args);
			break;
		}
		case "velocity":
		{
			AdminSystem.VelocityCmd( player, args );
			break;
		}
		case "drop_fire":
		{
			AdminSystem.DropFireCmd( player, args );
			break;
		}
		case "drop_spit":
		{
			AdminSystem.DropSpitCmd( player, args );
			break;
		}
		case "cvar":
		{
			AdminSystem.CvarCmd( player, args );
			break;
		}
		case "entcvar":
		{
			AdminSystem.EntCvarCmd( player, args );
			break;
		}
		case "ent_fire":
		{
			AdminSystem.EntFireCmd( player, args );
			break;
		}
		case "ent_teleport":
		{
			AdminSystem.EntTeleportCmd( player, args );
			break;
		}
		case "ent_rotate":
		{
			AdminSystem.EntRotateCmd(player,args);
			break;
		}
		case "ent_push":
		{
			AdminSystem.EntPushCmd(player,args);
			break;
		}
		case "ent_move":
		{
			AdminSystem.EntMoveCmd(player,args);
			break;
		}
		case "ent_spin":
		{
			AdminSystem.EntSpinCmd(player,args);
			break;
		}
		case "entity":
		{
			AdminSystem.EntityCmd( player, args );
			break;
		}
		case "ent":
		{
			AdminSystem.EntityWithTableCmd( player, args );
			break;
		}
		case "survivor":
		{
			AdminSystem.SurvivorCmd( player, args );
			break;
		}
		case "l4d1_survivor":
		{
			AdminSystem.L4D1SurvivorCmd( player, args );
			break;
		}
		case "barrel":
		{
			AdminSystem.BarrelCmd( player, args );
			break;
		}
		case "gascan":
		{
			AdminSystem.GascanCmd( player, args );
			break;
		}
		case "propanetank":
		{
			AdminSystem.PropaneTankCmd( player, args );
			break;
		}
		case "oxygentank":
		{
			AdminSystem.OxygenTankCmd( player, args );
			break;
		}
		case "fireworkcrate":
		{
			AdminSystem.FireworkCrateCmd( player, args );
			break;
		}
		case "weapon":
		{
			AdminSystem.WeaponCmd( player, args );
			break;
		}
		case "minigun":
		{
			AdminSystem.MinigunCmd( player, args );
			break;
		}
		case "fire_extinguisher":
		case "fire_ex":
		{
			AdminSystem.FireExtinguisherCmd( player, args );
			break;
		}
		case "spawn_ammo":
		{
			AdminSystem.SpawnAmmoCmd( player, args );
			break;
		}
		case "melee":
		{
			AdminSystem.MeleeCmd( player, args );
			break;
		}
		case "particle":
		{
			AdminSystem.ParticleCmd( player, args );
			break;
		}
		case "explosion_setting":
		{
			AdminSystem.Explosion_settingCmd( player, args );
			break;
		}
		case "show_explosion_settings":
		{
			AdminSystem.Show_explosion_settingsCmd( player, args );
			break;
		}
		case "explosion":
		{
			AdminSystem._AimedExplosionCmd( player, args );
			break;
		}
		case "microphone":
		{
			AdminSystem.MicrophoneCmd( player, args );
			break;
		}
		case "speaker":
		{
			AdminSystem.SpeakerCmd( player, args );
			break;
		}
		case "speaker2mic":
		{
			AdminSystem.Speaker2micCmd( player, args );
			break;
		}
		case "display_mics_speakers":
		{
			AdminSystem.Display_mics_speakersCmd( player, args );
			break;
		}
		case "piano_keys":
		{
			AdminSystem.Piano_keysCmd( player, args );
			break;
		}
		case "remove_piano_keys":
		{
			AdminSystem.Remove_piano_keysCmd( player, args );
			break;
		}
		case "grab":
		{
			AdminSystem.GrabCmd( player, args );
			break;
		}
		case "letgo":
		{
			AdminSystem.LetgoCmd( player, args );
			break;
		}
		case "yeet":
		{
			AdminSystem.YeetCmd( player, args );
			break;
		}
		case "show_yeet_settings":
		{
			AdminSystem.ShowYeetSettingsCmd( player, args );
			break;
		}
		case "yeet_setting":
		{
			AdminSystem.YeetSettingCmd( player, args );
			break;
		}
		case "change_grab_method":
		{
			AdminSystem.GrabMethodCmd( player, args );
			break;
		}
		case "random_model":
		{
			AdminSystem.RandomModelCmd( player, args );
			break;
		}
		case "model":
		{
			AdminSystem.ModelCmd( player, args );
			break;
		}
		case "model_scale":
		{
			AdminSystem.ModelScaleCmd( player, args );
			break;
		}
		case "disguise":
		{
			AdminSystem.DisguiseCmd( player, args );
			break;
		}
		case "update_model_preference":
		{
			AdminSystem.UpdateModelPreferenceCmd( player, args );
			break;
		}
		case "update_jockey_preference":
		{
			AdminSystem.UpdateJockeyPreferenceCmd( player, args );
			break;
		}
		case "update_tank_rock_launch_preference":
		{
			AdminSystem.UpdateTankRockPreferenceCmd( player, args );
			break;
		}
		case "update_tank_rock_random_preference":
		{
			AdminSystem.UpdateTankRockRandomPreferenceCmd( player, args );
			break;
		}
		case "update_tank_rock_respawn_preference":
		{
			AdminSystem.UpdateTankRockSpawnAfterPreferenceCmd( player, args );
			break;
		}
		case "restore_model":
		{
			AdminSystem.RestoreModelCmd( player, args );
			break;
		}
		case "timescale":
		{
			AdminSystem.TimescaleCmd( player, args );
			break;
		}
		case "god":
		{
			AdminSystem.GodCmd( player, args );
			break;
		}
		case "bash":
		{
			AdminSystem.BashCmd( player, args );
			break;
		}
		case "freeze":
		{
			AdminSystem.FreezeCmd( player, args );
			break;
		}
		case "noclip":
		{
			AdminSystem.NoclipCmd( player, args );
			break;
		}
		case "speed":
		{
			AdminSystem.SpeedCmd( player, args );
			break;
		}
		case "fly":
		{
			AdminSystem.FlyCmd( player, args );
			break;
		}
		case "client":
		{
			AdminSystem.ClientCmd( player, args );
			break;
		}
		case "console":
		{
			AdminSystem.ConsoleCmd( player, args );
			break;
		}
		case "script":
		{	
			if(!(player.GetSteamID() in ::AdminSystem.ScriptAuths))
			{
				Messages.ThrowAll(Messages.BIM.HasScriptAuth.NoAccess(player));
				return;
			}
			local Code = Utils.StringReplace(text, "script,", "");
			Code = Utils.StringReplace(Code, "'", "\""); //"
			local compiledscript = compilestring(Code);

			compiledscript();
			
			break;
		}
		case "kick":
		{
			AdminSystem.KickCmd( player, args );
			break;
		}
		case "ban":
		{
			AdminSystem.BanCmd( player, args );
			break;
		}
		case "zombie":
		{
			AdminSystem.ZombieCmd( player, args );
			break;
		}
		case "z_spawn":
		{
			AdminSystem.ZSpawnCmd( player, args );
			break;
		}
		case "cleanup":
		{
			AdminSystem.CleanupCmd( player, args );
			break;
		}
		case "stop_car_alarms":
		{
			AdminSystem.StopCarAlarmsCmd( player, args );
			break;
		}
		case "sound":
		{
			AdminSystem.SoundCmd( player, args );
			break;
		}
		case "director":
		{
			AdminSystem.DirectorCmd( player, args );
			break;
		}
		case "finale":
		{
			AdminSystem.FinaleCmd( player, args );
			break;
		}
		case "restart":
		{
			AdminSystem.RestartCmd( player, args );
			break;
		}
		case "limit":
		{
			AdminSystem.LimitCmd( player, args );
			break;
		}
		case "infinite_ammo":
		{
			AdminSystem.InfiniteAmmoCmd( player, args );
			break;
		}
		case "unlimited_ammo":
		{
			AdminSystem.UnlimitedAmmoCmd( player, args );
			break;
		}
		case "infinite_upgrade":
		{
			AdminSystem.InfiniteUpgradeCmd( player, args );
			break;
		}
		case "netprop":
		{
			AdminSystem.NetPropCmd( player, args );
			break;
		}
		case "door":
		{
			AdminSystem.DoorCmd( player, args );
			break;
		}
		case "prop":
		{
			AdminSystem.PropCmd( player, args );
			break;
		}
		case "dummy":
		{
			AdminSystem.DummyCmd( player, args );
			break;
		}
		case "exec":
		{
			AdminSystem.ExecCmd( player, args );
			break;
		}
		case "endgame":
		{
			AdminSystem.EndGameCmd( player, args );
			break;
		}
		case "alarmcar":
		{
			AdminSystem.AlarmCarCmd( player, args );
			break;
		}
		case "gun":
		{
			AdminSystem.GunCmd( player, args );
			break;
		}
		case "resource":
		{
			if ( Director.GetGameMode() == "holdout" )
			{
				AdminSystem.ResourceCmd( player, args );
			}
			
			break;
		}
		case "say":
		{
			local Entity = GetArgument(1);
			local Text = text;
			local Target = Utils.GetPlayerFromName(GetArgument(1));
			
			if ( Entity == "all" )
			{
				foreach(player in Players.All())
				{
					Text = Utils.StringReplace(Text, "say,all,", "");
					Text = Utils.StringReplace(Text, ",", " ");
					player.Say(Text);
				}
			}
			else
			{
				if ( !Target )
				{
					Text = Utils.StringReplace(Text, "say,", "");
					Text = Utils.StringReplace(Text, ",", " ");
					Say(null, Text, false);
					return;
				}
				
				Text = Utils.StringReplace(Text, "say," + Entity + ",", "");
				Text = Utils.StringReplace(Text, ",", " ");
				Target.Say(Text);
			}
			
			break;
		}
		case "password":
		{
			if ( AdminSystem.AdminPassword == "" )
				return;
			
			local Password = GetArgument(1);
			
			if ( Password == AdminSystem.AdminPassword )
			{
				local admins = FileToString(Constants.Directories.Admins);
				local steamid = player.GetSteamID();
				if ( steamid == "BOT" )
					return;
				if ( (steamid in ::AdminSystem.Admins) )
					return;
				if ( admins == null )
					admins = steamid + " //" + player.GetName();
				else
					admins += "\r\n" + steamid + " //" + player.GetName();
				StringToFile(Constants.Directories.Admins, admins);
				AdminSystem.LoadAdmins();
			}
			
			break;
		
		}
		case "ladder_team":
		{
			AdminSystem.Ladder_teamCmd( player, args );
			break;
		}
		case "invisible_walls":
		{
			AdminSystem.BlockerStateCmd( player, args );
			break;
		}
		case "admin_var":
		{
			AdminSystem.Admin_varCmd( player, args );
			break;
		}
		case "loop":
		{
			AdminSystem.Speak_loopCmd( player, args );
			break;
		}
		case "loop_stop":
		{
			AdminSystem.Speak_loop_stopCmd( player, args );
			break;
		}
		case "speak_test":
		{
			AdminSystem.Speak_testCmd( player, args );
			break;
		}
		case "speak_custom":
		{
			AdminSystem.Speak_customCmd( player, args );
			break;
		}
		case "show_custom_sequences":
		{
			AdminSystem.Show_custom_sequencesCmd( player, args );
			break;
		}
		case "seq_info":
		{
			AdminSystem.Sequence_infoCmd( player, args );
			break;
		}
		case "seq_edit":
		{
			AdminSystem.Sequence_editCmd( player, args );
			break;
		}
		case "create_seq":
		{
			AdminSystem.CreateSequenceCmd( player, args );
			break;
		}
		case "delete_seq":
		{
			AdminSystem.DeleteSequenceCmd( player, args );
			break;
		}
		case "start_the_shower":
		{
			AdminSystem.Start_the_showerCmd(player,args);
			break;
		}
		case "pause_the_shower":
		{
			AdminSystem.Pause_the_showerCmd(player,args);
			break;
		}
		case "meteor_shower_debug":
		{
			AdminSystem.Meteor_shower_debugCmd(player,args);
			break;
		}
		case "meteor_shower_setting":
		{
			AdminSystem.Meteor_shower_settingCmd(player,args);
			break;
		}
		case "show_meteor_shower_settings":
		{
			AdminSystem.Show_meteor_shower_settingsCmd(player,args);
			break;
		}
		case "start_the_apocalypse":
		{
			AdminSystem.Start_the_apocalypseCmd(player,args);
			break;
		}
		case "pause_the_apocalypse":
		{
			AdminSystem.Pause_the_apocalypseCmd(player,args);
			break;
		}
		case "apocalypse_debug":
		{
			AdminSystem.Apocalypse_debugCmd(player,args);
			break;
		}
		case "apocalypse_setting":
		{
			AdminSystem.Apocalypse_settingCmd(player,args);
			break;
		}
		case "show_apocalypse_settings":
		{
			AdminSystem.Show_apocalypse_settingsCmd(player,args);
			break;
		}
		case "create_listener":
		{
			AdminSystem._CreateKeyListenerCmd(player,args);
			break;
		}
		case "stop_listener":
		{
			AdminSystem._StopKeyListenerCmd(player,args);
			break;
		}
		case "drive":
		{
			AdminSystem.DriveCmd(player,args);
			break;
		}
		case "kind_bots":
		{
			AdminSystem._EnableKindnessCmd(player,args);
			break;
		}
		case "selfish_bots":
		{
			AdminSystem._DisableKindnessCmd(player,args);
			break;
		}
		case "update_bots_sharing_preference":
		{
			AdminSystem.Update_bots_sharing_preferenceCmd(player,args);
			break;
		}
		case "stop_time":
		{
			AdminSystem.StopTimeCmd(player,args);
			break;
		}
		case "resume_time":
		{
			AdminSystem.ResumeTimeCmd(player,args);
			break;
		}
		case "ents_around":
		{
			AdminSystem.EntitiesAroundCmd(player,args);
			break;
		}
		case "wnet":
		{
			AdminSystem.WatchNetPropCmd(player,args);
			break;
		}
		case "stop_wnet":
		{
			AdminSystem.StopWatchNetPropCmd(player,args);
			break;
		}
		default:
			break;
	}
}

// TO-DO: Write a library for handling binary and hex, because squirrel is fucking stupid :)
::dec2bin <- function(val,bits=32)
{
	local b = "";
	while(val > 0)
	{
		b = (val % 2) + b;
		val = (val/2).tointeger();
	}
	local missing = bits-b.len();
	for(local i=0;i<missing;i++)
	{
		b = "0" + b;
	}

	return b; 
}

::dec2hex <- function(val,bits=32)
{
	local b = "";
	local letters = ["A","B","C","D","E","F"];
	while(val > 0)
	{
		local m = (val % 16);
		if( m >= 10 )
		{
			m = letters[m % 10];
		}
		b = m + b;
		val = (val/16).tointeger();
	}
	local missing = (bits/4).tointeger()-b.len();
	for(local i=0;i<missing;i++)
	{
		b = "0" + b;
	}

	return "0x"+b; 
}

::hex2rgba <- function(hexstring)
{
	if((typeof hexstring) != "string")
	{
		return;
	}

	local rgba = hexstring.slice(2,10); // aabbggrr
	local lis = 
	[
		compilestring("return 0x"+rgba.slice(6,8))(),
		compilestring("return 0x"+rgba.slice(4,6))(),
		compilestring("return 0x"+rgba.slice(2,4))(),
		compilestring("return 0x"+rgba.slice(0,2))()
	];
	return lis;
}

::dec2rgba <- function(val,bits=32)
{
	return hex2rgba(dec2hex(val,bits));
}

/*
 *
 */
::draw <- function(start,end,color=Vector(255,0,0))
{
	DebugDrawLine_vCol(start,end,color,false,3);
}

/*
 * @authors rhino
 * For debugging in-game
 */
::out <- function(msg="",target=null,color="\x04")
{
	local msgtype = typeof msg;
	if(target != null)
	{
		if(msg == null)
			return;
		else if(msgtype == "table")
			Utils.PrintTable(msg);
		else if(msgtype == "array")
			ClientPrint(target.GetBaseEntity(),3,color+Utils.ArrayString(msg));
		else if(msgtype == "QAngle" || msgtype == "Vector")
			ClientPrint(target.GetBaseEntity(),3,color+msg.ToKVString());
		else if(msgtype == "string" || msgtype == "float" || msgtype == "integer" || msgtype == "bool")
			ClientPrint(target.GetBaseEntity(),3,color+msg.tostring());
		else if(msgtype == "instance" || msgtype.find("VSLIB") != null)
		{
			try
			{
				if(msg.GetClassname() == "player")
				{
					EntInfo(Player(msg.GetBaseIndex()),target,false,0.0);
				}
				else
				{
					EntInfo(msg,target,false,0.0);
				}
			}
			catch(e)
			{
				ClientPrint(target,3,color+msg.tostring());
			}
		}
		else if(msgtype.tostring().find("project_smok_Message_") != null)
			ClientPrint(target.GetBaseEntity(),3,msg.GetColored());
		else
			ClientPrint(target.GetBaseEntity(),3,color+msg.tostring());
	}
	else
	{
		if(msg == null)
			return;
		else if(msgtype == "table")
			Utils.PrintTable(msg);
		else if(msgtype == "array")
			ClientPrint(null,3,color+Utils.ArrayString(msg));
		else if(msgtype == "QAngle" || msgtype == "Vector")
			ClientPrint(null,3,color+msg.ToKVString());
		else if(msgtype == "string" || msgtype == "float" || msgtype == "integer" || msgtype == "bool")
			ClientPrint(null,3,color+msg.tostring());
		else if(msgtype == "instance" || msgtype.find("VSLIB") != null)
		{
			try
			{
				if(msg.GetClassname() == "player")
				{
					EntInfo(Player(msg.GetBaseIndex()),null,false,0.0);
				}
				else
				{
					EntInfo(msg,null,false,0.0);
				}
			}
			catch(e)
			{
				ClientPrint(null,3,color+msg.tostring());
			}
		}
		else if(msgtype.tostring().find("project_smok_Message_") != null)
			ClientPrint(null,3,msg.GetColored());
		else
			ClientPrint(null,3,color+msg.tostring());
	}
}

// Freezing objects
::AdminSystem._FrozenSI <- {}
::AdminSystem._FrozenInfected <- {}
::AdminSystem._FrozenPhysics <- {}

/*
 * @authors rhino
 */
::AdminSystem.StopTimeCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local targetclasses = ["all","special","common","physics",null];
	local target = GetArgument(1);

	if(Utils.GetIDFromArray(targetclasses,target) == -1)
	{
		printl("Invalid argument->"+target);
		return;
	}

	switch(target)
	{
		case "all":
		{
			FreezeSI();
			FreezeInfected();
			FreezePhysics();
			break;
		}
		case "special":
		{
			FreezeSI();
			break;
		}
		case "common":
		{
			FreezeInfected();
			break;
		}
		case "physics":
		{
			FreezePhysics();
			break;
		}
		default:
		{
			local ent = player.GetLookingEntity()
			if(ent == null || !ent.IsEntityValid() || ent.GetParent() != null)
			{
				return;
			}
			FreezeAimed(ent);
		}
	}
}

::FreezeSI <- function()
{
	if(!("_FrozenSI" in AdminSystem))
	{
		AdminSystem._FrozenSI <- {}
	}
	
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if(libObj.GetMoveType() == MOVETYPE_NONE || libObj.GetParent() != null)
			{
				continue;
			}
			if (libObj.GetTeam() == INFECTED )
			{
				libObj.AddFlag(FL_FROZEN)
				//DoEntFire("!self","setcommentarystatuemode","1",0,null,ent)
				libObj.SetNetPropFloat("m_flFrozen",1);
				AdminSystem._FrozenSI[libObj.GetIndex()] <-
				{
					model = libObj.GetModel()
					movetype = libObj.GetMoveType()
				};
				libObj.SetMoveType(MOVETYPE_NONE);
				AdminSystem.Vars.IsGodEnabled[libObj.GetIndex()] <- true;
			}
		}
	}
	while (ent = Entities.FindByClassname(ent, "witch"))
	{
		if (ent.IsValid())
		{
			local libObj = Entity(ent);
			if(libObj.GetMoveType() == MOVETYPE_NONE || libObj.GetParent() != null)
			{
				continue;
			}

			libObj.AddFlag(FL_FROZEN)
			//DoEntFire("!self","setcommentarystatuemode","1",0,null,ent)
			libObj.SetNetPropFloat("m_flFrozen",1);
			AdminSystem._FrozenSI[libObj.GetIndex()] <-
			{
				model = libObj.GetModel()
				movetype = libObj.GetMoveType()
			};
			libObj.SetMoveType(MOVETYPE_NONE);
			AdminSystem.Vars.IsGodEnabled[libObj.GetIndex()] <- true;
		}
	}
}

::FreezeInfected <- function()
{
	if(!("_FrozenInfected" in AdminSystem))
	{
		AdminSystem._FrozenInfected <- {}
	}
	
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "infected"))
	{
		if (ent.IsValid())
		{
			local obj = ::VSLib.Entity(ent);
			if(obj.GetMoveType() == MOVETYPE_NONE || obj.GetParent() != null)
			{
				continue;
			}
			obj.AddFlag(FL_FROZEN);
			obj.SetNetProp("m_flFrozen",1.0);
			obj.SetNetProp("m_bSimulatedEveryTick",0);
			obj.SetNetProp("m_bAnimatedEveryTick",0);
			obj.SetVelocity(Vector(0,0,0));
			AdminSystem._FrozenInfected[obj.GetIndex()] <- 
			{
				model = obj.GetModel()
				health = obj.GetHealth()
				movetype = obj.GetMoveType()
			};
			//obj.SetMoveType(MOVETYPE_NONE);
		}
	}
}

::FreezePhysics <- function()
{
	if(!("_FrozenPhysics" in AdminSystem))
	{
		AdminSystem._FrozenPhysics <- {}
	}

	local classnames = ["prop_physics", "prop_physics_multiplayer" , "prop_car_alarm", "prop_vehicle", "prop_physics_override", "func_physbox", "func_physbox_multiplayer", "prop_ragdoll"]
	foreach(cls in classnames)
	{
		local ent = null;
		while (ent = Entities.FindByClassname(ent, cls))
		{
			if (ent.IsValid())
			{
				local obj = ::VSLib.Entity(ent);
				if(obj.GetMoveType() == MOVETYPE_NONE || obj.GetParent() != null)
				{
					continue;
				}
				AdminSystem._FrozenPhysics[obj.GetIndex()] <- 
				{
					movetype = obj.GetMoveType()
					velocity = obj.GetPhysicsVelocity()
					classname = obj.GetClassname()
					model = obj.GetModel()
					health = obj.GetHealth()
				}
				obj.SetMoveType(MOVETYPE_NONE);
			}
		}
	}
}

::FreezeAimed <- function(ent)
{
	if(ent == null 
		|| !ent.IsEntityValid() 
		|| ent.GetMoveType() == MOVETYPE_NONE
		|| ent.GetParent() != null)
	{
		return;
	}
	local id = ent.GetIndex();
	local classname = ent.GetClassname();
	local classnames = ["prop_physics", "prop_physics_multiplayer" , "prop_car_alarm", "prop_vehicle", "prop_physics_override", "func_physbox", "func_physbox_multiplayer", "prop_ragdoll"]

	// SI
	if(classname == "player" 
	   && "_FrozenSI" in AdminSystem
	   && ent.GetTeam() == INFECTED)
	{
		ent.AddFlag(FL_FROZEN)
		//DoEntFire("!self","setcommentarystatuemode","1",0,null,ent.GetBaseEntity())
		ent.SetNetPropFloat("m_flFrozen",1);
		AdminSystem._FrozenSI[id] <-
		{
			model = ent.GetModel()
			movetype = ent.GetMoveType()
		};
		ent.SetMoveType(MOVETYPE_NONE);
		AdminSystem.Vars.IsGodEnabled[id] <- true;
	
	} // Witch
	else if(classname == "witch" 		
	   && "_FrozenSI" in AdminSystem)
	{
		ent.AddFlag(FL_FROZEN)
		//DoEntFire("!self","setcommentarystatuemode","1",0,null,ent.GetBaseEntity())
		ent.SetNetPropFloat("m_flFrozen",1);
		AdminSystem._FrozenSI[id] <-
		{
			model = ent.GetModel()
			movetype = ent.GetMoveType()
		};
		ent.SetMoveType(MOVETYPE_NONE);
		AdminSystem.Vars.IsGodEnabled[id] <- true;
	
	} // Common
	else if(classname == "infected"
			&& "_FrozenInfected" in AdminSystem)
	{
		ent.AddFlag(FL_FROZEN);
		ent.SetNetProp("m_flFrozen",1.0);
		ent.SetNetProp("m_bSimulatedEveryTick",0);
		ent.SetNetProp("m_bAnimatedEveryTick",0);
		ent.SetVelocity(Vector(0,0,0));
		AdminSystem._FrozenInfected[id] <- 
		{
			model = ent.GetModel()
			health = ent.GetHealth()
			movetype = ent.GetMoveType()
		};
		//ent.SetMoveType(MOVETYPE_NONE);
	} // Phys
	else if(Utils.GetIDFromArray(classnames,classname) != -1
			&& "_FrozenPhysics" in AdminSystem)
	{
		AdminSystem._FrozenPhysics[id] <- 
		{
			movetype = ent.GetMoveType()
			velocity = ent.GetPhysicsVelocity()
			classname = ent.GetClassname()
			model = ent.GetModel()
			health = ent.GetHealth()
		}
		ent.SetMoveType(MOVETYPE_NONE);
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.ResumeTimeCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local targetclasses = ["all","special","common","physics",null];
	local target = GetArgument(1);

	if(Utils.GetIDFromArray(targetclasses,target) == -1)
	{
		printl("Invalid argument->"+target);
		return;
	}

	switch(target)
	{
		case "all":
		{
			UnfreezeSI();
			UnfreezeInfected();
			UnfreezePhysics();
			break;
		}
		case "special":
		{
			UnfreezeSI();
			break;
		}
		case "common":
		{
			UnfreezeInfected();
			break;
		}
		case "physics":
		{
			UnfreezePhysics();
			break;
		}
		default:
		{
			local ent = player.GetLookingEntity()
			if(ent == null || !ent.IsEntityValid())
			{
				return;
			}
			UnfreezeAimed(ent);
		}
	}
}

::UnfreezeSI <- function()
{
	if(!("_FrozenSI" in AdminSystem))
		return;

	local ent = null;
	foreach(id,tbl in AdminSystem._FrozenSI)
	{
		ent = Ent(id);
		if(ent == null)
		{
			continue;
		}
		if (ent.IsValid())
		{
			if(ent.GetClassname() != "player")
			{
				if(ent.GetClassname() == "witch")
				{
					local libObj = Entity(ent);
					libObj.SetMoveType(tbl.movetype);
					libObj.RemoveFlag(FL_FROZEN);
					libObj.SetNetPropFloat("m_flFrozen",0);

					DoEntFire("!self","RunScriptCode","delete AdminSystem.Vars.IsGodEnabled["+libObj.GetIndex()+"]",0,null,ent);
				}
				continue;
			}
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == INFECTED ) // && tbl.model == libObj.GetModel())
			{
				//local org = libObj.GetOrigin();
				libObj.SetMoveType(tbl.movetype);
				libObj.RemoveFlag(FL_FROZEN);
				libObj.SetNetPropFloat("m_flFrozen",0);
				
				//libObj.SetOrigin(org);
				//AdminSystem.Vars.IsGodEnabled[libObj.GetIndex()] <- true;
				//DoEntFire("!self","setcommentarystatuemode","0",0,null,ent)
				//DoEntFire("!self","sethealth",tbl.health.tostring(),0,null,ent)
				DoEntFire("!self","RunScriptCode","delete AdminSystem.Vars.IsGodEnabled["+libObj.GetIndex()+"]",0,null,ent);
				//libObj.SetHealth(tbl.health);
			}
		}
	}
	AdminSystem._FrozenSI <- {}
}

::UnfreezeInfected <- function()
{
	if(!("_FrozenInfected" in AdminSystem))
		return;

	local ent = null;
	foreach(id,tbl in AdminSystem._FrozenInfected)
	{
		ent = Ent(id);
		if(ent == null)
		{
			continue;
		}
		if (ent.IsValid())
		{
			local obj = ::VSLib.Entity(ent);
			if(obj.GetClassname() != "infected"  ) // || obj.GetModel() != tbl.model)
			{
				continue;
			}
			obj.RemoveFlag(FL_FROZEN);
			obj.SetNetProp("m_flFrozen",0.0);
			obj.SetNetProp("m_bSimulatedEveryTick",1);
			obj.SetNetProp("m_bAnimatedEveryTick",1);
			//obj.SetMoveType(tbl.movetype);
			/*
			local org = obj.GetOrigin();
			
			if(tbl.model == obj.GetModel())
			{
				obj.SetHealth(tbl.health);
				obj.RemoveFlag(FL_FROZEN);
				obj.SetOrigin(org);
			}
			*/
		}
	}
	AdminSystem._FrozenInfected <- {}
}

::UnfreezePhysics <- function()
{
	if(!("_FrozenPhysics" in AdminSystem))
		return;

	local classnames = ["prop_physics", "prop_physics_multiplayer" , "prop_car_alarm", "prop_vehicle", "prop_physics_override", "func_physbox", "func_physbox_multiplayer", "prop_ragdoll"]
	foreach(cls in classnames)
	{
		local ent = null;
		foreach(id,tbl in AdminSystem._FrozenPhysics)
		{
			ent = Ent(id);
			if(ent == null)
			{
				continue;
			}
			if (ent.IsValid())
			{
				local obj = ::VSLib.Entity(ent);
				if(obj.GetClassname() != tbl.classname || obj.GetMoveType() != MOVETYPE_NONE || obj.GetParent() != null ) // || obj.GetModel() != tbl.model)
				{
					continue;
				}
				local org = obj.GetOrigin();
				obj.SetMoveType(tbl.movetype);
				obj.SetOrigin(org);
				obj.Push(tbl.velocity);
				/*
				if(obj.GetModel() == tbl.model)
				{

					obj.SetHealth(tbl.health);
					obj.SetMoveType(tbl.movetype);

					obj.SetOrigin(org);
					obj.SetVelocity(tbl.velocity);
				}
				*/
			}
		}
	}
	AdminSystem._FrozenPhysics <- {}
}

::UnfreezeAimed <- function(ent)
{
	if(ent == null || !ent.IsEntityValid())
	{
		return;
	}
	local id = ent.GetIndex();
	local classname = ent.GetClassname();
	if( (ent.GetMoveType() != MOVETYPE_NONE && classname != "infected") || ent.GetParent() != null )
	{
		if("_FrozenPhysics" in AdminSystem && (id in AdminSystem._FrozenPhysics))
		{
			delete AdminSystem._FrozenPhysics[id];
		}
		else if("_FrozenSI" in AdminSystem && (id in AdminSystem._FrozenSI))
		{
			delete AdminSystem._FrozenSI[id];
		}
		else if("_FrozenInfected" in AdminSystem && (id in AdminSystem._FrozenInfected))
		{
			delete AdminSystem._FrozenInfected[id];
		}
		return;
	}
	local classnames = ["prop_physics", "prop_physics_multiplayer" , "prop_car_alarm", "prop_vehicle", "prop_physics_override", "func_physbox", "func_physbox_multiplayer", "prop_ragdoll"]

	if(classname == "player" 
	   && "_FrozenSI" in AdminSystem
	   && ent.GetTeam() == INFECTED
	   && (id in AdminSystem._FrozenSI))
	{
		local tbl = AdminSystem._FrozenSI[id];
		//local org = ent.GetOrigin();
		ent.SetMoveType(tbl.movetype);
		ent.RemoveFlag(FL_FROZEN);
		ent.SetNetPropFloat("m_flFrozen",0);

		//ent.SetOrigin(org);
		//AdminSystem.Vars.IsGodEnabled[id] <- true;
		//DoEntFire("!self","setcommentarystatuemode","0",0,null,ent.GetBaseEntity())
		//DoEntFire("!self","sethealth",tbl.health.tostring(),0.05,null,ent.GetBaseEntity())
		DoEntFire("!self","RunScriptCode","delete AdminSystem.Vars.IsGodEnabled["+id+"]",0,null,ent.GetBaseEntity());
		//ent.SetHealth(tbl.health);
		delete AdminSystem._FrozenSI[id];	
	}
	else if(classname == "witch" 		
	   && "_FrozenSI" in AdminSystem
	   && (id in AdminSystem._FrozenSI))
	{
		local tbl = AdminSystem._FrozenSI[id];
		ent.SetMoveType(tbl.movetype);
		ent.RemoveFlag(FL_FROZEN);
		ent.SetNetPropFloat("m_flFrozen",0);

		DoEntFire("!self","RunScriptCode","delete AdminSystem.Vars.IsGodEnabled["+id+"]",0,null,ent.GetBaseEntity());

		delete AdminSystem._FrozenSI[id];
	
	}
	else if(classname == "infected"
			&& "_FrozenInfected" in AdminSystem
			&& (id in AdminSystem._FrozenInfected))
	{
		if(ent.GetClassname() != "infected"  ) // || ent.GetModel() != tbl.model)
		{
			return;
		}
		local tbl = AdminSystem._FrozenInfected[id];
		//ent.SetMoveType(tbl.movetype);
		ent.RemoveFlag(FL_FROZEN);
		ent.SetNetProp("m_flFrozen",0.0);
		ent.SetNetProp("m_bSimulatedEveryTick",1);
		ent.SetNetProp("m_bAnimatedEveryTick",1);
		delete AdminSystem._FrozenInfected[id];
	}
	else if(Utils.GetIDFromArray(classnames,classname) != -1
			&& "_FrozenPhysics" in AdminSystem
			&& (id in AdminSystem._FrozenPhysics))
	{
		local tbl = AdminSystem._FrozenPhysics[id];
		if(ent.GetClassname() != tbl.classname ) // || ent.GetModel() != tbl.model)
		{
			return;
		}
		local org = ent.GetOrigin();
		ent.SetMoveType(tbl.movetype);
		ent.SetOrigin(org);
		ent.Push(tbl.velocity);
		delete AdminSystem._FrozenPhysics[id];
	}
	
}

/*************************\
* BOT SHARE/LOOT FUNCTIONS *
\*************************/
/*
 * @authors rhino
 */
::AdminSystem.SetBotShareLootSettings <- function()
{
	::AdminSystem.BotParams <- Constants.GetBotShareLootSettingsDefaults();

	::AdminSystem.BotOnSearchOrSharePath <- AdminSystem.Vars.RepeatValueForSurvivors(false);

	::AdminSystem.BotBringingItem <- AdminSystem.Vars.RepeatValueForSurvivors(false);

	::AdminSystem.BotTemporaryStopState <- AdminSystem.Vars.RepeatValueForSurvivors(false);

	local fileContents = FileToString(Constants.Directories.BotSettings);
	
	if(fileContents == null)
	{
		printl("[Bot-Params] Creating bot share/loot settings file for the first time...");
		StringToFile(Constants.Directories.BotSettings,Constants.GetBotShareLootSettings());
		fileContents = FileToString(Constants.Directories.BotSettings);
	}

	local settings = split(fileContents, "\r\n");

	foreach(setting in settings)
	{
		if ( setting != "" )
		{
			local code = "AdminSystem.BotParams." + Utils.StringReplace(setting, "=", "<-");
			compilestring(code)();
		}
	}
}
::AdminSystem.SetBotShareLootSettings();

::AdminSystem.Update_bots_sharing_preferenceCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local newstate = !::AdminSystem.Vars.AllowAutomatedSharing;
	::AdminSystem.Vars.AllowAutomatedSharing = newstate;

	Messages.InformAll(CmdMessages.BotSharingPreference(player.GetCharacterName(),newstate));
}

::_ClearBeingTakenStatus <- function(args)
{
	if(args.item in AdminSystem.Vars._currentlyBeingTaken)
		delete AdminSystem.Vars._currentlyBeingTaken[args.item];
}

::RemoveCustomThinkTimers <- function(index,searchonly=false)
{
	if(!searchonly)
	{
		if(Constants.TimerNames.BotShareAttemptSlot2+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot2+index]);
			delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot2+index];
		}
		if(Constants.TimerNames.BotShareAttemptSlot3+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot3+index]);
			delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot3+index];
		}

		if(Constants.TimerNames.BotThinkAdder+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotThinkAdder+index]);
			delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotThinkAdder+index];
		}
	}

	if(Constants.TimerNames.BotSearchAttemptSlot2+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotSearchAttemptSlot2+index]);
		delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotSearchAttemptSlot2+index];
	}
	if(Constants.TimerNames.BotSearchAttemptSlot3+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotSearchAttemptSlot3+index]);
		delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotSearchAttemptSlot3+index];
	}
	
}

::_TakenFailCheckerRemover <- function(args)
{
	if(args.index in AdminSystem.Vars._currentlyBeingTaken)
	{
		args.bot.BotReset();
		RemoveCustomThinkTimers(args.bot.GetIndex(),true);
		AdminSystem.BotOnSearchOrSharePath[args.bot.GetCharacterNameLower()] = false;
		delete AdminSystem.Vars._currentlyBeingTaken[args.index];
	}
}

::_ShareFailCheckerRemover <- function(args)
{
	local index = args.botindex;
	args.bot.BotReset();

	if(Constants.TimerNames.BotShareAttemptSlot2+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot2+index]);
		delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot2+index];
	}
	if(Constants.TimerNames.BotShareAttemptSlot3+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot3+index]);
		delete ::VSLib.Timers.TimersID[Constants.TimerNames.BotShareAttemptSlot3+index];
	}

	AdminSystem.BotOnSearchOrSharePath[args.bot.GetCharacterNameLower()] = false;
	AdminSystem.BotBringingItem[args.targetname] = false;
}

/*
 * @authors rhino
 */
::_TryToReachAndGet <- function(args)
{
	if(::VSLib.EasyLogic.NextMapContinues)
		return;

	local obj = args.obj;

	if(!args.obj.IsEntityValid())
		return;
		
	local bot = args.bot;
	local botindex = bot.GetIndex();
	local slot = args.slot;
	local debug = AdminSystem.BotParams.debug;
	local timername = slot == 2 
						? Constants.TimerNames.BotSearchAttemptSlot2+botindex
						: Constants.TimerNames.BotSearchAttemptSlot3+botindex
	
	if(Utils.CalculateDistance(args.bot.GetEyePosition(),obj.GetOrigin()) <= AdminSystem.BotParams.MaxRadiusToTake && (timername in ::VSLib.Timers.TimersID))
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];
		
		if(!bot.IsAlive())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is dead")
		}
		else if(bot.IsIncapacitated())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is incapped")
		}
		else if(bot.IsHealing())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is healing")
		}
		else
		{
			AdminSystem.BotOnSearchOrSharePath[bot.GetCharacterNameLower()] = false;

			if(obj.GetIndex() in AdminSystem.Vars._currentlyBeingTaken)
				delete AdminSystem.Vars._currentlyBeingTaken[obj.GetIndex()];

			if(!("slot"+slot in args.bot.GetHeldItems()))
			{
				if(obj.GetClassname().find("_spawn") != null)
				{
					if(obj.GetNetProp("m_fEffects") == 48)
					{
						bot.BotReset();
						return;
					}
				}
				DoEntFire("!self","use","",0,bot.GetBaseEntity(),obj.GetBaseEntity());
				if(debug == 1)
					ClientPrint(null,3,"\x03"+bot.GetIndex()+" taking #"+obj.GetIndex());
			}
			else
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"Inventory changed during search")
			}
			bot.BotReset();
		}
	}
	else if(timername in ::VSLib.Timers.TimersID)
	{
		foreach(inf in Objects.OfClassnameWithin("inferno",obj.GetOrigin(),275))
		{
			//out("Found inferno")
			//DebugDrawText(inf.GetOrigin()+Vector(0,0,25),"INFERNO",false,5);
			local a = Utils.CalculateDistance(obj.GetOrigin(),inf.GetOrigin())
			local b = Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
			local f = Utils.CalculateDistance(obj.GetOrigin(),bot.GetOrigin())
			local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
			local d = pow((b-temp)*(b+temp),0.5)
			if(d < 125)
			{
				bot.BotReset();
				//out("Inferno too close: "+d);
				return;
			}
		}
		foreach(inf in Objects.OfClassnameWithin("insect_swarm",obj.GetOrigin(),275))
		{
			//out("Found spit")
			//DebugDrawText(inf.GetOrigin()+Vector(0,0,25),"SPIT",false,5);
			local a = Utils.CalculateDistance(obj.GetOrigin(),inf.GetOrigin())
			local b = Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
			local f = Utils.CalculateDistance(obj.GetOrigin(),bot.GetOrigin())
			local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
			local d = pow((b-temp)*(b+temp),0.5)
			if(d < 125)
			{
				bot.BotReset();
				//out("Spit too close: "+d);
				return;
			}
		}

		if((rand().tofloat()/RAND_MAX) <= AdminSystem.BotParams.ChanceRelocateWhenTooFarToGet 
			&& !bot.IsInCombat()
			&& bot.IsAlive()
			&& !bot.IsIncapacitated()
			&& !bot.IsHealing()
			&& !bot.IsBeingHealed()
			)
		{
			//out("No inferno and trying to relocate");
			bot.BotMoveToLocation(obj.GetOrigin())
		}
	}
}

/*
 * @authors rhino
 */
::_TryAndGiveItem <- function(args)
{
	if(::VSLib.EasyLogic.NextMapContinues)
		return;

	local bot = args.bot;
	local botindex = bot.GetIndex();
	local botname = bot.GetCharacterNameLower();
	local target = args.target;
	local slot = args.slot;
	local debug = AdminSystem.BotParams.debug;
	local item = args.item;
	local timername = slot == 2 
						? Constants.TimerNames.BotShareAttemptSlot2+botindex
						: Constants.TimerNames.BotShareAttemptSlot3+botindex
	if(Utils.CalculateDistance(bot.GetOrigin(),target.GetOrigin()) <= AdminSystem.BotParams.MaxRadiusToLetShare 
		&& (timername in ::VSLib.Timers.TimersID) 
		&& !AdminSystem.BotTemporaryStopState[botname])
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];

		if(!bot.IsAlive())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is dead")
		}
		else if(bot.IsIncapacitated())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is incapped")
		}
		else if(bot.IsHealing())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"#" + botindex + " bot is healing")
		}
		else
		{
			if(!target.IsAlive())
			{
				AdminSystem.BotOnSearchOrSharePath[botname] = false;
				AdminSystem.BotBringingItem[target.GetCharacterNameLower()] = false;
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"#" + target.GetIndex() + " target is dead")
			}
			else if(target.IsIncapacitated())
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"#" + target.GetIndex() + " target is incapped")
			}
			else if(target.IsBeingHealed() || target.IsHealing())
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"#" + target.GetIndex() + " target is healing or getting healed")
			}
			else
			{
				AdminSystem.BotOnSearchOrSharePath[botname] = false;
				AdminSystem.BotBringingItem[target.GetCharacterNameLower()] = false;
				
				local spawnertooclose = false;
				
				if(item != null && item.IsEntityValid())
				{
					foreach(spawner in Objects.OfClassnameWithin(args.item.GetClassname()+"_spawn",bot.GetOrigin(),100))
					{
						if(spawner.GetNetProp("m_fEffects") == 48 || spawner.GetSpawnFlags() == 10)
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"#"+botindex+" Can't give, spawner too close #"+spawner.GetIndex());
							spawnertooclose = true;
							break;
						}
					}

					if(spawnertooclose)
					{

					}
					else if(("slot"+slot in bot.GetHeldItems()) && !("slot"+slot in target.GetHeldItems()))
					{
						if(debug == 1)
							ClientPrint(null,3,"\x03"+"#"+botindex+" gave "+args.classname+" to "+target.GetIndex());
						bot.Speak(Utils.GetRandValueFromArray(::Survivorlines.ShareItem[botname]),0.1);
						
						AdminSystem.Vars._currentlyBeingTaken[args.item.GetIndex()] <- true;
						Utils.DropThenGive(bot,target,slot,args.item);
						::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=args.item.GetIndex()});
						
						AdminSystem.BotTemporaryStopState[botname] <- true;
						::VSLib.Timers.AddTimer(AdminSystem.BotParams.HoldNewGivenFor, false, _TemporaryStopStatusWrapper,{bot=botname});
					}
					else
					{
						if(debug == 1)
							ClientPrint(null,3,"\x04"+"Inventories changed")
					}
				}
				else
				{
					if(debug == 1)
						ClientPrint(null,3,"\x04"+"Inventories changed")
				}
				
			}
			bot.BotReset();
		}	
	}
	else if(timername in ::VSLib.Timers.TimersID)
	{
		if(item == null || !item.IsEntityValid())
		{
			if(debug == 1)
				ClientPrint(null,3,"\x04"+"Inventories changed")
			bot.BotReset();
		}
		else
		{
			foreach(inf in Objects.OfClassnameWithin("inferno",args.item.GetOrigin(),275))
			{
				//out("Found inferno")
				//DebugDrawText(inf.GetOrigin()+Vector(0,0,25),"INFERNO",false,5);
				local a = Utils.CalculateDistance(args.item.GetOrigin(),inf.GetOrigin())
				local b = Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
				local f = Utils.CalculateDistance(args.item.GetOrigin(),bot.GetOrigin())
				local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
				local d = pow((b-temp)*(b+temp),0.5)
				if(d < 125)
				{
					bot.BotReset();
					//out("Inferno too close: "+d);
					return;
				}
			}
			foreach(inf in Objects.OfClassnameWithin("insect_swarm",args.item.GetOrigin(),275))
			{
				//out("Found spit")
				//DebugDrawText(inf.GetOrigin()+Vector(0,0,25),"SPIT",false,5);
				local a = Utils.CalculateDistance(args.item.GetOrigin(),inf.GetOrigin())
				local b = Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
				local f = Utils.CalculateDistance(args.item.GetOrigin(),bot.GetOrigin())
				local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
				local d = pow((b-temp)*(b+temp),0.5)
				if(d < 125)
				{
					bot.BotReset();
					//out("Spit too close: "+d);
					return;
				}
			}
			if((rand().tofloat()/RAND_MAX) <= AdminSystem.BotParams.ChanceRelocateWhenTooFarToGive  
				&& !bot.IsInCombat()
				&& bot.IsAlive()
				&& !bot.IsIncapacitated()
				&& !bot.IsHealing()
				&& !bot.IsBeingHealed())
			{
				//out("No inferno and trying to relocate");
				bot.BotMoveToLocation(target.GetOrigin())
			}
		}
	}
}

::_TemporaryStopStatusWrapper <- function(args)
{
	AdminSystem.BotTemporaryStopState[args.bot] <- false;
}

/*
 * @authors rhino
 */
::_CreateLootThinker <-function()
{
	local keyvaltable = 
	{	
		classname = "info_target"
		origin = Vector(0,0,0)
		spawnflags = 0
	}

	local thinkadder = Utils.CreateEntityWithTable(keyvaltable);
	thinkadder.SetName("think_adder_base_entity");

	AddThinkToEnt(thinkadder.GetBaseEntity(),"_AddSearchThinkToBots");
	return thinkadder;
}

/*
 * @authors rhino
 */
::AdminSystem._EnableKindnessCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local found = Objects.AnyOfName("think_adder_base_entity")
	if(found != null)
	{
		AdminSystem._DisableKindnessCmd(player,args);
	}

	local name = player.GetCharacterNameLower();

	local thinkadder = _CreateLootThinker();
	AdminSystem.Vars.LastLootThinkState = true;
	foreach(survivor,val in AdminSystem.BotOnSearchOrSharePath)
	{
		AdminSystem.BotOnSearchOrSharePath[survivor] = false;
	}

	Messages.InformAll(CmdMessages.EnableKindness(name,thinkadder));
}

/*
 * @authors rhino
 */
::AdminSystem._DisableKindnessCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local ent = null
	local found = false
	while (ent = Entities.FindByName(ent, "think_adder_base_entity"))
	{
		if (ent.IsValid())
		{
			AddThinkToEnt(ent,null);
			DoEntFire("!self", "Kill", "", 0.1, null, ent);
			found = true;
		}
	}

	foreach(survivor,val in AdminSystem.BotOnSearchOrSharePath)
	{
		AdminSystem.BotOnSearchOrSharePath[survivor] = false;
		AdminSystem.BotBringingItem[survivor] = false;
		AdminSystem.BotTemporaryStopState[survivor] = false;
	}

	foreach(survivor in Players.AliveSurvivors())
	{
		RemoveCustomThinkTimers(survivor.GetIndex());
	}

	foreach(survivor in Players.DeadSurvivors())
	{
		RemoveCustomThinkTimers(survivor.GetIndex());
	}

	AdminSystem.Vars._currentlyBeingTaken <- {};
	AdminSystem.Vars.LastLootThinkState = false;

	if(!found)
		return;

	Messages.InformAll(CmdMessages.DisableKindness(name));
}

/*
 * @authors rhino
 */
::_AddSearchThinkToBots <- function()
{
	if(!("AliveSurvivors" in Players))
		return;
	foreach(survivor in Players.AliveSurvivors())
	{
		if(!(Constants.TimerNames.BotThinkAdder+survivor.GetIndex() in ::VSLib.Timers.TimersID) && survivor.IsBot())
		{
			Timers.AddTimerByName(Constants.TimerNames.BotThinkAdder+survivor.GetIndex(),AdminSystem.BotParams.MinThinkDelay+((rand().tofloat()/RAND_MAX)%AdminSystem.BotParams.MaxOffsetThinkDelay),true,_LookForLoot,{index=survivor.GetIndex()})
		}
	}
}

/*
 * @authors rhino
 */
::_LookForLoot <- function(arg)
{
	local botindex = arg.index;
	local bot = Player(botindex.tointeger());
	local botname = bot.GetCharacterNameLower();
	local debug = AdminSystem.BotParams.debug;
	if(!bot.IsBot())
	{
		if(debug == 1)
			ClientPrint(null,3,"\x04"+"#" + botindex + " is not a bot")
		RemoveCustomThinkTimers(botindex);
		AdminSystem.BotOnSearchOrSharePath[botname] = false;
		return;
	}
	else if(!bot.IsAlive())
	{
		if(debug == 1)
			ClientPrint(null,3,"\x04"+"#" + botindex + " bot is dead")

		RemoveCustomThinkTimers(botindex);
		AdminSystem.BotOnSearchOrSharePath[botname] = false;
	}
	else if(bot.IsIncapacitated())
	{
		if(debug == 1)
			ClientPrint(null,3,"\x04"+"#" + botindex + " bot is incapped")
	}
	else if(bot.IsInCombat())
	{
		if(debug == 1)
			ClientPrint(null,3,"\x04"+"#" + botindex + " bot is in combat")
	}
	else if(bot.IsHealing() || bot.IsBeingHealed())
	{
		if(debug == 1)
			ClientPrint(null,3,"\x04"+"#" + botindex + " bot is healing or getting healed")
	}
	else if(!AdminSystem.BotOnSearchOrSharePath[botname] && !AdminSystem._CurrentlyTradingItems[botname])
	{
		local inv = bot.GetHeldItems();
		local origin = bot.GetOrigin();
		local inHand = null;
		local inhandclass = null;
		local alreadygiving = false;
		
		local hasgrenade = ("slot2" in inv);
		local haspack = ("slot3" in inv);
		local share = AdminSystem.Vars.AllowAutomatedSharing;
		local temporarlystopped = AdminSystem.BotTemporaryStopState[botname];

		// TRY SHARING EITHER GRENADE OR THE PACK, OR JUST SEARCH FOR NEW ONE
		if(hasgrenade && share && !temporarlystopped)
		{
			if(Constants.TimerNames.BotShareAttemptSlot2+botindex in ::VSLib.Timers.TimersID)
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"Already trying to give the grenade");
			}
			else
			{
				inHand = inv.slot2;
				inhandclass = inHand.GetClassname();

				local closest = null;
				local lastdist = null;
				local currdist = null;
				foreach(survivor in Players.AliveSurvivors())
				{
					if(survivor.GetIndex() == botindex)
						continue;

					if(survivor.IsBot())
						continue;

					if(bot.CanSeeLocation(survivor.GetEyePosition(),AdminSystem.BotParams.CanSee_Share))
					{
						local valid = false;
						local begin = bot.GetEyePosition();
						local finish = survivor.GetEyePosition();
						
						local m_trace = { start = begin, end = finish, ignore = bot.GetBaseEntity(), mask = AdminSystem.BotParams.Mask };
						TraceLine(m_trace);

						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,5),Vector(255,0,0),false,3);
						if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
							continue;
						
						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,10),Vector(255,255,0),false,3);
						if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
							continue;
						
						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,15),Vector(0,255,255),false,3);
						if (m_trace.enthit == survivor.GetBaseEntity() || ::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish))
							valid = true;

						if(!valid)
							continue;
						
						if(debug == 1)
						{
							DebugDrawLine_vCol(begin,finish+Vector(0,0,15),Vector(0,0,255),false,3);
							ClientPrint(null,3,"\x05"+"#"+botindex+" Can see and no trace hits #"+survivor.GetIndex());
						}
					}
					else
					{
						if(debug == 1)
						{
							DebugDrawLine_vCol(bot.GetEyePosition(),survivor.GetEyePosition(),Vector(0,255,0),false,3);
							ClientPrint(null,3,"\x04"+"#"+botindex+" Can't see #"+survivor.GetIndex());
						}
						continue;
					}

					if(!survivor.IsBot() && !survivor.IsBeingHealed() && !survivor.IsHealing() && survivor.IsAlive() && !survivor.IsIncapacitated())
					{
						if(closest != null)
						{
							currdist = Utils.CalculateDistance(survivor.GetOrigin(),origin);
							if(lastdist > currdist)
							{
								closest = survivor;
								lastdist = currdist;
							}
						}
						else
						{
							closest = survivor;
							lastdist = Utils.CalculateDistance(survivor.GetOrigin(),origin);
						}
					}
					else
					{
						if(debug == 1)
							ClientPrint(null,3,"\x04"+"#"+botindex+"Not valid #"+survivor.GetIndex());
					}
				}

				if(closest != null)
				{
					if(!AdminSystem._CurrentlyTradingItems[closest.GetCharacterNameLower()] && !AdminSystem.BotBringingItem[closest.GetCharacterNameLower()])
					{
						local closestorigin = closest.GetOrigin();
						if("slot2" in closest.GetHeldItems())
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"Friend already has grenade");
						}
						else if(Utils.CalculateDistance(origin,closestorigin) <= AdminSystem.BotParams.ClosestPlayerMaxDist)
						{
							local spawnertooclose = false;
							foreach(spawner in Objects.OfClassnameWithin(inhandclass+"_spawn",closestorigin,AdminSystem.BotParams.SpawnerRadiusAroundClosest))
							{
								if(spawner.GetNetProp("m_fEffects") == 48 || spawner.GetSpawnFlags() == 10)
								{
									if(debug == 1)
										ClientPrint(null,3,"\x04"+"Spawner too close #"+spawner.GetIndex());
									spawnertooclose = true;
									break;
								}
							}

							if(spawnertooclose)
							{

							}
							else if(bot.IsCalm())
							{
								if(debug == 1)
									ClientPrint(null,3,"\x03"+"#"+botindex+" is calm and kind enough to share");
								bot.BotMoveToLocation(closestorigin);

								AdminSystem.BotOnSearchOrSharePath[botname] = true;
								AdminSystem.BotBringingItem[closest.GetCharacterNameLower()] = true;
								alreadygiving = true;

								Timers.AddTimer(AdminSystem.BotParams.ShareTimeout,false,_ShareFailCheckerRemover,{bot=bot,botindex=botindex,targetname=closest.GetCharacterNameLower()});
								Timers.AddTimerByName(Constants.TimerNames.BotShareAttemptSlot2+botindex,AdminSystem.BotParams.ItemShareTimerDelay,true,_TryAndGiveItem,{bot=bot,target=closest,slot=2,item=inHand,classname=inhandclass.slice(7)})
							}
							else if((rand().tofloat()/RAND_MAX) <= AdminSystem.BotParams.RandomChanceForShare)
							{
								if(debug == 1)
									ClientPrint(null,3,"\x03"+"#"+botindex+" "+AdminSystem.BotParams.RandomChanceForShare*100+"% probability hit");
								bot.BotMoveToLocation(closestorigin);

								AdminSystem.BotOnSearchOrSharePath[botname] = true;
								AdminSystem.BotBringingItem[closest.GetCharacterNameLower()] = true;
								alreadygiving = true;
								
								Timers.AddTimer(AdminSystem.BotParams.ShareTimeout,false,_ShareFailCheckerRemover,{bot=bot,botindex=botindex,targetname=closest.GetCharacterNameLower()});
								Timers.AddTimerByName(Constants.TimerNames.BotShareAttemptSlot2+botindex,AdminSystem.BotParams.ItemShareTimerDelay,true,_TryAndGiveItem,{bot=bot,target=closest,slot=2,item=inHand,classname=inhandclass.slice(7)})
							}
						}
					}
					
				}
				else
				{
					if(debug == 1)
						ClientPrint(null,3,"\x04"+"No valid close friend found");
				}
			}
			
		}

		if(haspack && !alreadygiving && share && !temporarlystopped)
		{
			if(Constants.TimerNames.BotShareAttemptSlot3+botindex in ::VSLib.Timers.TimersID)
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"Already trying to give a pack");
			}
			else
			{
				inHand = inv.slot3;
				inhandclass = inHand.GetClassname();

				local closest = null;
				local lastdist = null;
				local currdist = null;
				foreach(survivor in Players.AliveSurvivors())
				{
					if(survivor.GetIndex() == botindex)
						continue;

					if(survivor.IsBot())
						continue;
						
					if(bot.CanSeeLocation(survivor.GetEyePosition(),AdminSystem.BotParams.CanSee_Share))
					{
						local valid = false;
						local begin = bot.GetEyePosition();
						local finish = survivor.GetEyePosition();
						
						local m_trace = { start = begin, end = finish, ignore = bot.GetBaseEntity(), mask = AdminSystem.BotParams.Mask };
						TraceLine(m_trace);
						
						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,5),Vector(255,0,0),false,3);
						if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
							continue;
						
						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,10),Vector(255,255,0),false,3);
						if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
							continue;
						
						if(debug == 1)
							DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,15),Vector(0,255,255),false,3);
						if (m_trace.enthit == survivor.GetBaseEntity() || ::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish))
							valid = true;

						if(!valid)
							continue;
						
						if(debug == 1)
						{
							DebugDrawLine_vCol(begin,finish+Vector(0,0,15),Vector(0,0,255),false,3);
							ClientPrint(null,3,"\x05"+"#"+botindex+" Can see and no trace hits #"+survivor.GetIndex());
						}
					}
					else
					{
						if(debug == 1)
						{
							DebugDrawLine_vCol(bot.GetEyePosition(),survivor.GetEyePosition(),Vector(0,255,0),false,3);
							ClientPrint(null,3,"\x04"+"#"+botindex+" Can't see #"+survivor.GetIndex());
						}
						continue;
					}

					if(!survivor.IsBot() && !survivor.IsBeingHealed() && !survivor.IsHealing() && survivor.IsAlive() && !survivor.IsIncapacitated())
					{
						if(closest != null)
						{
							currdist = Utils.CalculateDistance(survivor.GetOrigin(),origin);
							if(lastdist > currdist)
							{
								closest = survivor;
								lastdist = currdist;
							}
						}
						else
						{
							closest = survivor;
							lastdist = Utils.CalculateDistance(survivor.GetOrigin(),origin);
						}
					}
					else
					{
						if(debug == 1)
							ClientPrint(null,3,"\x04"+"#"+botindex+" Not valid #"+survivor.GetIndex());
					}
				}

				if(closest != null)
				{
					if(debug == 1)
						ClientPrint(null,3,"\x05"+"Closest #"+closest.GetIndex());
					if(!AdminSystem._CurrentlyTradingItems[closest.GetCharacterNameLower()] && !AdminSystem.BotBringingItem[closest.GetCharacterNameLower()])
					{
						local closestorigin = closest.GetOrigin();
						if("slot3" in closest.GetHeldItems())
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"Friend already has a pack");
						}
						else if(Utils.CalculateDistance(origin,closestorigin) <= AdminSystem.BotParams.ClosestPlayerMaxDist)
						{
							local packspawnertooclose = false;
							foreach(spawner in Objects.OfClassnameWithin(inhandclass+"_spawn",closestorigin,AdminSystem.BotParams.SpawnerRadiusAroundClosest))
							{
								if(spawner.GetNetProp("m_fEffects") == 48 || spawner.GetSpawnFlags() == 10 )
								{
									if(debug == 1)
										ClientPrint(null,3,"\x04"+"Spawner too close #"+spawner.GetIndex());
									packspawnertooclose = true;
									break;
								}
							}
							
							if(packspawnertooclose)
							{

							}
							else if(bot.IsCalm())
							{
								if(debug == 1)
									ClientPrint(null,3,"\x03"+"#"+botindex+" is calm and kind enough to share");
								bot.BotMoveToLocation(closestorigin);

								AdminSystem.BotOnSearchOrSharePath[botname] = true;
								AdminSystem.BotBringingItem[closest.GetCharacterNameLower()] = true;
								alreadygiving = true;

								Timers.AddTimer(AdminSystem.BotParams.ShareTimeout,false,_ShareFailCheckerRemover,{bot=bot,botindex=botindex,targetname=closest.GetCharacterNameLower()});
								Timers.AddTimerByName(Constants.TimerNames.BotShareAttemptSlot3+botindex,AdminSystem.BotParams.ItemShareTimerDelay,true,_TryAndGiveItem,{bot=bot,target=closest,slot=3,item=inHand,classname=inhandclass.slice(7)})
							}
							else if((rand().tofloat()/RAND_MAX) <= AdminSystem.BotParams.RandomChanceForShare)
							{
								if(debug == 1)
									ClientPrint(null,3,"\x03"+"#"+botindex+" "+AdminSystem.BotParams.RandomChanceForShare*100+"% probability hit");
								bot.BotMoveToLocation(closestorigin);
								
								AdminSystem.BotOnSearchOrSharePath[botname] = true;
								AdminSystem.BotBringingItem[closest.GetCharacterNameLower()] = true;
								alreadygiving = true;

								Timers.AddTimer(AdminSystem.BotParams.ShareTimeout,false,_ShareFailCheckerRemover,{bot=bot,botindex=botindex,targetname=closest.GetCharacterNameLower()});
								Timers.AddTimerByName(Constants.TimerNames.BotShareAttemptSlot3+botindex,AdminSystem.BotParams.ItemShareTimerDelay,true,_TryAndGiveItem,{bot=bot,target=closest,slot=3,item=inHand,classname=inhandclass.slice(7)})
							}
						}
					}
				}
				else
				{
					if(debug == 1)
						ClientPrint(null,3,"\x04"+"No close friend found");
				}
			}
		}

		if ((!hasgrenade || !haspack) && !alreadygiving)
		{
			if(debug == 1)
				ClientPrint(null,3,"\x05"+"#"+botindex+" looking for items");

			// Search for closeby stuff
			local sharable_grenade = 
			[
				"weapon_molotov","weapon_pipe_bomb",
				"weapon_vomitjar",
				"weapon_molotov_spawn","weapon_pipe_bomb_spawn",
				"weapon_vomitjar_spawn",
			]
			local sharable_packs = 
			[
				"weapon_first_aid_kit","weapon_first_aid_kit_spawn",
				"weapon_upgradepack_incendiary","weapon_upgradepack_explosive",
				"weapon_defibrillator_spawn","weapon_defibrillator",
				"weapon_upgradepack_incendiary_spawn","weapon_upgradepack_explosive_spawn"
			]

			local closebygrenade_pack = {};
			local usedorigin = bot.GetOrigin();
			foreach(obj in Objects.AroundRadius(usedorigin,AdminSystem.BotParams.BotOriginLootRadius))
			{
				if(Utils.GetIDFromArray(sharable_grenade,obj.GetClassname()) != -1)
				{
					if(!Utils.ItemHeldByOther(obj.GetIndex(),2) && !hasgrenade && obj.GetNetProp("m_fEffects") != 48)
					{
						if(debug == 1)
							ClientPrint(null,3,"\x05"+"Closeby #"+obj.GetIndex());
						closebygrenade_pack[obj.GetIndex()] <- 2
					}
					else
					{
						if(debug == 1)
							ClientPrint(null,3,"\x04"+"Item #"+obj.GetIndex()+" ungrabbable->"+"byother:"+Utils.ItemHeldByOther(obj.GetIndex(),2)+", noslot:"+hasgrenade+", effect:"+obj.GetNetProp("m_fEffects"));
					}
				}
				else if(Utils.GetIDFromArray(sharable_packs,obj.GetClassname()) != -1)
				{
					if(!Utils.ItemHeldByOther(obj.GetIndex(),3) && !haspack)
					{
						if(debug == 1)
							ClientPrint(null,3,"\x05"+"Closeby #"+obj.GetIndex());
						closebygrenade_pack[obj.GetIndex()] <- 3
					}
					else
					{
						if(debug == 1)
							ClientPrint(null,3,"\x04"+"Item #"+obj.GetIndex()+" ungrabbable->"+"byother:"+Utils.ItemHeldByOther(obj.GetIndex(),3)+", noslot:"+haspack);
					}
				}
			}

			local randompathable = null
			if(closebygrenade_pack.len() == 0)
			{ 
				randompathable = bot.GetBaseEntity().TryGetPathableLocationWithin(AdminSystem.BotParams.BotOriginLootRadius);
				//eye level
				randompathable.z += 62;

				if(debug == 1)
					DebugDrawText(randompathable,"USING RANDOM PATH",false,4);

				foreach(obj in Objects.AroundRadius(randompathable,AdminSystem.BotParams.PathableDist_Loot))
				{
					if(Utils.GetIDFromArray(sharable_grenade,obj.GetClassname()) != -1)
					{
						if(!Utils.ItemHeldByOther(obj.GetIndex(),2) && !hasgrenade && obj.GetNetProp("m_fEffects") != 48)
						{
							if(debug == 1)
								ClientPrint(null,3,"\x05"+"Closeby #"+obj.GetIndex());
							closebygrenade_pack[obj.GetIndex()] <- 2
						}
						else
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"Item #"+obj.GetIndex()+" ungrabbable->"+"byother:"+Utils.ItemHeldByOther(obj.GetIndex(),2)+", noslot:"+hasgrenade+", effect:"+obj.GetNetProp("m_fEffects"));
						}
					}
					else if(Utils.GetIDFromArray(sharable_packs,obj.GetClassname()) != -1)
					{
						if(!Utils.ItemHeldByOther(obj.GetIndex(),3) && !haspack)
						{
							if(debug == 1)
								ClientPrint(null,3,"\x05"+"Closeby #"+obj.GetIndex());
							closebygrenade_pack[obj.GetIndex()] <- 3
						}
						else
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"Item #"+obj.GetIndex()+" ungrabbable->"+"byother:"+Utils.ItemHeldByOther(obj.GetIndex(),3)+", noslot:"+haspack);
						}
					}
				}

				if(closebygrenade_pack.len() == 0)
				{
					if(debug == 1)
						ClientPrint(null,3,"\x04"+"Nothing closeby");
					return;
				}
				else
				{
					usedorigin = randompathable;
				}
			}
			else
			{
				if(debug == 1)
					DebugDrawText(usedorigin,"USING BOT ORIGIN",false,4);
			}
			

			local m_trace = null;
			local obj = null;
			local found = false;
			local foundclassslot = null;

			foreach(objindex,slot in closebygrenade_pack)
			{
				if(objindex in AdminSystem.Vars._currentlyBeingTaken)
					continue;

				obj = Entity(objindex);

				if(bot.CanSeeLocation(obj.GetOrigin(),AdminSystem.BotParams.CanSee_Loot))
				{
					local valid = false;
					local begin = bot.GetEyePosition();
					local finish = obj.GetOrigin();
					local m_trace = { start = begin, end = finish, ignore = bot.GetBaseEntity(), mask = AdminSystem.BotParams.Mask };
					TraceLine(m_trace);
					
					if(debug == 1)
					{
						DebugDrawLine_vCol(begin,m_trace.pos,Vector(255,0,0),false,3);
						Utils.PrintTable(m_trace);
					}

					if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
					{
						if(::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish) && obj.GetClassname().find("weapon_vomitjar") != null) // vomitjars are weird
						{
							valid = true;
							if(debug == 1)
							{
								DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,15),Vector(0,255,0),false,3);
								ClientPrint(null,3,"\x05"+"#"+botindex+" Visible closeby "+obj.GetClassname()+" #"+objindex);
								DebugDrawText(obj.GetOrigin()+Vector(0,0,25),"VISIBLE ITEM",false,5);
							}
								
							foundclassslot = slot;
							found = true;
							break;
						}
						else
						{
							if(debug == 1)
								ClientPrint(null,3,"\x04"+"Trace failed, trying a bit higher");
							m_trace = { start = begin, end = finish+Vector(0,0,2), ignore = bot.GetBaseEntity(), mask = AdminSystem.BotParams.Mask };
							TraceLine(m_trace);
							if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
							{
								if(::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish) && obj.GetClassname().find("vomit_jar") != null) // vomitjars are weird
									valid = true;
								else
									continue;
							}
						}
						
					}
					
					if(debug == 1)
						DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,5),Vector(255,255,0),false,3);
					if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
						continue;
					
					if(debug == 1)
						DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,10),Vector(0,255,255),false,3);
					if (m_trace.enthit == obj.GetBaseEntity() || ::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish))
						valid = true;

					if(!valid)
						continue;

					if(debug == 1)
					{
						DebugDrawLine_vCol(begin,m_trace.pos+Vector(0,0,15),Vector(0,255,0),false,3);
						ClientPrint(null,3,"\x05"+"#"+botindex+" Visible closeby "+obj.GetClassname()+" #"+objindex);
						DebugDrawText(obj.GetOrigin()+Vector(0,0,25),"VISIBLE ITEM",false,5);
					}
						
					foundclassslot = slot;
					found = true;
					break;
				}

				if(debug == 1)
					DebugDrawText(obj.GetOrigin(),"FOUND ITEM",false,5);
			}
			
			if(!found)
			{
				if(debug == 1)
					ClientPrint(null,3,"\x04"+"#"+botindex+" No visible closeby items");
			}
			else
			{
				if(!obj.IsEntityValid())
					return;

				local org = obj.GetOrigin();
				if(Utils.CalculateDistance(origin,org) > AdminSystem.BotParams.VisibleDistLimit)
				{
					if(debug == 1)
						ClientPrint(null,3,"\x04"+"Visible #"+obj.GetIndex()+" is too far");
				}
				else
				{
					bot.BotMoveToLocation(org)

					AdminSystem.BotOnSearchOrSharePath[botname] = true;
					AdminSystem.Vars._currentlyBeingTaken[obj.GetIndex()] <- true;
					
					Timers.AddTimer(AdminSystem.BotParams.ReachTimeout,false,_TakenFailCheckerRemover,{index=obj.GetIndex(),bot=bot});
					
					Timers.AddTimerByName((foundclassslot == 2 
												? Constants.TimerNames.BotSearchAttemptSlot2+botindex 
												: Constants.TimerNames.BotSearchAttemptSlot3+botindex),
											AdminSystem.BotParams.ItemReachTimerDelay,
											true,
											_TryToReachAndGet,
											{bot=bot,obj=obj,slot=foundclassslot,classname=obj.GetClassname().slice(7)})
				}
			}
		}
		else
		{
			if(debug == 1)
			{
				ClientPrint(null,3,"\x04"+"#"+botindex+" not searching-> grenade:"+hasgrenade+", pack:"+haspack+", onpath:"+alreadygiving);
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.DriveCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(::VSLib.EasyLogic.NextMapContinues)
		return;

	local name = player.GetCharacterNameLower();
	if(AdminSystem._CarControl[name].listenerid != -1)
	{
		AdminSystem._StopKeyListenerCmd(player,args)

		local currentmodel = player.GetModel();
		Utils.ResetModels(name);

		local fw = player.GetForwardVector()
		fw = fw.Scale(AdminSystem.Vars._heldEntity[name].grabDistMin/fw.Length())
		local replica = Utils.CreateEntityWithTable(
			{
				classname="prop_physics_multiplayer",
				origin=player.GetOrigin()+fw,
				model=currentmodel,
				angles=QAngle(0,0,0)
			})
		printl("New replica #"+replica.GetIndex())
		return;
	}

	local lookedent = player.GetLookingEntity()

	if(lookedent == null)
		return;
	else if(lookedent.GetParent() != null)
		return; 
	else if(Utils.CalculateDistance(player.GetOrigin(),player.GetLookingLocation())>100)
		return;
	
	lookedent.Kill();
	
	AdminSystem._CreateKeyListenerCmd(player,args);
}

/*
 * @authors rhino
 */
::AdminSystem._Pusher <- function(args)
{
	local ent = args.ent;
	local name = ent.GetCharacterNameLower();
	local tbl = AdminSystem._CarControl[name]
	local speed = tbl.speed;
	local pushvec = tbl.forward.Scale(speed);
	local mask = tbl.keymask;
	local turnangle = tbl.turnpertick;

	if(mask == 0)
		return;
	
	if((mask == 16) || (mask == 28) || (mask == 31))
		return;
	
	// FORWARD+BACKWARD OR NONE
	if((mask % 2 == 1 && (mask>>1) % 2 == 1) || (mask % 2 == 0 && (mask>>1) % 2 == 0))
	{
		ent.Push(ent.GetPhysicsVelocity().Scale(tbl.reversescale));
		if((mask>>4) % 2 == 1)
			ent.SetForwardVector(pushvec);
		return;
	}

	ent.OverrideFriction(2.5,tbl.overridefriction)
	// CANCEL LEFT+RIGHT
	if((mask>>2) % 2 == 1 && (mask>>3) % 2 == 1)
	{
		if((mask>>4) % 2 == 1)
			ent.SetForwardVector(pushvec);

		if((mask>>1) % 2 == 1) // BACKWARD
		{
			pushvec = pushvec.Scale(-1);
			ent.Push(pushvec);
		}
		else  // FORWARD
		{
			ent.Push(pushvec);
		}
	}
	else
	{
		// LEFT
		if((mask>>2) % 2 == 1)
		{
			ent.Push(ent.GetPhysicsVelocity().Scale(tbl.reversescale));
			if((mask>>1) % 2 == 1) // BACKWARD LEFT
			{
				pushvec = pushvec.Scale(-1);
				pushvec = RotatePosition(Vector(0,0,0),QAngle(0,-turnangle,0),pushvec);
				if((mask>>4) % 2 == 1)
					ent.SetForwardVector(pushvec.Scale(-1));
				AdminSystem._CarControl[name].forward = pushvec.Scale(-1/speed);
			}
			else
			{
				pushvec = RotatePosition(Vector(0,0,0),QAngle(0,turnangle,0),pushvec);
				if((mask>>4) % 2 == 1)
					ent.SetForwardVector(pushvec);
				AdminSystem._CarControl[name].forward = pushvec.Scale(1/speed);
			}
			
			ent.Push(pushvec);
		}
		// RIGHT
		else if((mask>>3) % 2 == 1)
		{	
			ent.Push(ent.GetPhysicsVelocity().Scale(tbl.reversescale));
			if((mask>>1) % 2 == 1) // BACKWARD RIGHT
			{
				pushvec = pushvec.Scale(-1);
				pushvec = RotatePosition(Vector(0,0,0),QAngle(0,turnangle,0),pushvec);
				if((mask>>4) % 2 == 1)
					ent.SetForwardVector(pushvec.Scale(-1))
				AdminSystem._CarControl[name].forward = pushvec.Scale(-1/speed)
			}
			else
			{
				pushvec = RotatePosition(Vector(0,0,0),QAngle(0,-turnangle,0),pushvec);
				if((mask>>4) % 2 == 1)
					ent.SetForwardVector(pushvec)
				AdminSystem._CarControl[name].forward = pushvec.Scale(1/speed)
			}
			
			ent.Push(pushvec);
		}
		else if((mask>>1) % 2 == 1) // BACKWARD
		{
			pushvec = pushvec.Scale(-1);
			ent.Push(pushvec);
		}
		else // FORWARD
		{
			ent.Push(pushvec);
		}
		
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem._KeyMasker <- function(arg)
{
	local spl = split(arg,"__")
	local ind = spl[0].tointeger();
	local key = spl[1].tointeger();

	local ent = VSLib.Player(ind.tointeger());
	local name = ent.GetCharacterNameLower();
	local currmask = AdminSystem._CarControl[name].keymask;

	AdminSystem._CarControl[name].keymask = currmask ^ key;

}

::AdminSystem._CarControl <- ::AdminVars.RepeatTableForSurvivors(
	{
		keymask = 0
		forward = Vector(0,0,0)
		speed = 400.0
		reversescale = -4
		speedscale = 2.75
		overridefriction = 0.05
		turnpertick = 7
		listenerid = -1
	}
);

	
::AdminSystem._StopKeyListenerCmd <- function(ent,args)
{
	if (!AdminSystem.IsPrivileged( ent ))
		return;

	local name = ent.GetCharacterNameLower()
	if (Constants.TimerNames.CarPush+name in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.CarPush+name]);
		delete ::VSLib.Timers.TimersID[Constants.TimerNames.CarPush+name];

		local id = AdminSystem._CarControl[name].listenerid;

		Ent(id).Kill();
		AdminSystem._CarControl[name].forward = Vector(0,0,0)
		AdminSystem._CarControl[name].keymask = 0
		AdminSystem._CarControl[name].listenerid = -1

		::VSLib.Timers.AddTimer(1, false, _SetCarControl,{ent=ent,grav=1,speedscale=1.0});

	}
}

::AdminSystem._CreateKeyListenerCmd <- function(ent,args)
{
	if (!AdminSystem.IsPrivileged( ent ))
		return;

	local forIndex = ent.GetIndex();

	local keyvals = 
	{
		classname = "game_ui"
		FieldOfView = -1
		origin = ent.GetOrigin()
		spawnflags = 64
	}

	local listener = Utils.CreateEntityWithTable(keyvals);
	listener.SetName("listener_"+ent.GetCharacterNameLower()+UniqueString())
	listener.SetFlags(64)

	ClientPrint(null,3,"\x04"+forIndex+"->Created listener(#"+listener.GetIndex()+") named "+listener.GetName());

	listener.Input("addoutput",__.FP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_FORWARD)+"),0,-1",0,null)
	listener.Input("addoutput",__.FU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_FORWARD)+"),0,-1",0,null)
	listener.Input("addoutput",__.BP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_BACKWARD)+"),0,-1",0,null)
	listener.Input("addoutput",__.BU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_BACKWARD)+"),0,-1",0,null)
	listener.Input("addoutput",__.LP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_LEFT)+"),0,-1",0,null)
	listener.Input("addoutput",__.LU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_LEFT)+"),0,-1",0,null)
	listener.Input("addoutput",__.RP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_RIGHT)+"),0,-1",0,null)
	listener.Input("addoutput",__.RU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_RIGHT)+"),0,-1",0,null)

	listener.Input("addoutput",__.aP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_ATK)+"),0,-1",0,null)
	listener.Input("addoutput",__.aU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_ATK)+"),0,-1",0,null)
	listener.Input("addoutput",__.AP+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_ATK2)+"),0,-1",0,null)
	listener.Input("addoutput",__.AU+" !self,RunScriptCode,AdminSystem._KeyMasker("+_GetEnumString(forIndex+"__"+BTN_ATK2)+"),0,-1",0,null)

	listener.Input("activate","",0.1,ent.GetBaseEntity())

	local name = ent.GetCharacterNameLower();
	local forward = ent.GetAngles().Forward();
	forward = forward.Scale(1/forward.Length())

	AdminSystem._CarControl[name].forward = forward;
	AdminSystem._CarControl[name].listenerid = listener.GetIndex();
	
	::VSLib.Timers.AddTimer(0.1, false, _SetCarControl,{ent=ent,grav=5,speedscale=AdminSystem._CarControl[name].speedscale});
	::VSLib.Timers.AddTimerByName(Constants.TimerNames.CarPush+name,0.1, true, AdminSystem._Pusher,{ent=ent});
}

::_SetCarControl <- function(args)
{
	args.ent.SetGravity(args.grav);
	args.ent.SetNetProp("m_flLaggedMovementValue",args.speedscale)
}

::_GetEnumString <- function(str)
{
	local temp = ["0","1","2","3","4","5","6","7","8","9",",","="," ","_",";","\""] // "
	local res = ""
	local ch = ""
	for(local i=0;i<str.len();i++)
	{
		if(i != str.len()-1)
			ch = str.slice(i,i+1)
		else
			ch = str.slice(i)

		if(Utils.GetIDFromArray(temp,ch)==-1)
			res = res + "__." + ch;
		else
		{
			switch(ch)
			{
				case ",":
				{
					ch = "c";
					break;
				}
				case "=":
				{
					ch = "e";
					break;
				}
				case " ":
				{
					ch = "s";
					break;
				}
				case "_":
				{
					ch = "u";
					break;
				}
				case ";":
				{
					ch = "sc";
					break;
				}
				case "\"": // "
				{
					ch = "q";
					break;
				}
				default:
					break;
			}
			res = res + "__._" + ch;
		}
		
		if(i != str.len()-1)
			res += "+";
	}
	return res;
}

getconsttable()["BTN_FORWARD"] <- 1;
getconsttable()["BTN_BACKWARD"] <- 1<<1;
getconsttable()["BTN_LEFT"] <- 1<<2;
getconsttable()["BTN_RIGHT"] <- 1<<3;
getconsttable()["BTN_ATK"] <- 1<<4;
getconsttable()["BTN_ATK2"] <- 1<<5;

// KEYS AS STRINGS
enum __
{
	_1 = "1"
	_2 = "2"
	_3 = "3"
	_4 = "4"
	_5 = "5"
	_6 = "6"
	_7 = "7"
	_8 = "8"
	_9 = "9"
	_0 = "0"
	////SPECIALS
	_c = ","
	_sc = ";"
	_e = "="
	_q = "\"" // "
	_s = " "
	_u = "_"
	////LETTERS
	//LOWERCASE
	a = "a"
	b = "b"
	c = "c"
	d = "d"
	e = "e"
	f = "f"
	g = "g"
	h = "h"
	i = "i"
	j = "j"
	k = "k"
	l = "l"
	m = "m"
	n = "n"
	o = "o"
	p = "p"
	r = "r"
	s = "s"
	t = "t"
	u = "u"
	v = "v"
	y = "y"
	z = "z"
	x = "x"
	w = "w"
	q = "q"
	//UPPERCASE
	A = "A"
	B = "B"
	C = "C"
	D = "D"
	E = "E"
	F = "F"
	G = "G"
	H = "H"
	I = "I"
	J = "J"
	K = "K"
	L = "L"
	M = "M"
	N = "N"
	O = "O"
	P = "P"
	R = "R"
	S = "S"
	T = "T"
	U = "U"
	V = "V"
	Y = "Y"
	Z = "Z"
	X = "X"
	W = "W"
	Q = "Q"
	////LISTENER
	ON = "PlayerOn"
	OF = "PlayerOff"
	//ATTACK
	aP = "PressedAttack"
	aU = "UnpressedAttack"
	AP = "PressedAttack2"
	AU = "UnpressedAttack2"
	//DIRECTIONAL
	LP = "PressedMoveLeft"
	LU = "UnpressedMoveLeft"
	RP = "PressedMoveRight"
	RU = "UnpressedMoveRight"
	FP = "PressedForward"
	FU = "UnpressedForward"
	BP = "PressedBack"
	BU = "UnpressedBack"
}

/* ******************DANGEROUS FUNCTION*******************
 * RESTRICTED TO: Host and ScriptAuth
 * @authors rhino
 * View or Update vars in AdminSystem.Vars (BE CAREFUL WITH THIS!)
 */
::AdminSystem.Admin_varCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ) &&  !(player.GetSteamID() in ::AdminSystem.ScriptAuths))
		return;

	local varname = GetArgument(1); 
	if(varname == null)
		return;

	if(varname.find(".") != null)
	{
		local var_array = split(varname,".");;
		local val = AdminSystem.Vars;
		local currpath = "AdminSystem.Vars";
		foreach(key in var_array)
		{
			if(key in val)
			{val = val[key];currpath += "."+key;}
			else
			{Printer(player,"\x04"+"Cant find key: "+key+" in "+currpath+", creating one...");val[key] <- null;return;}
		}
		local newval = GetArgument(2);
		if(newval == null)
		{	
			if(typeof val == "table")
			{
				Printer(player,varname+" is a "+ "\x04" + "table:\n"+Utils.GetTableString(val));
				return;
			}
			else if(typeof val == "array")
			{
				Printer(player,varname+" is "+"\x04"+Utils.ArrayString(val));
				return;
			}
			else
			{
				Printer(player,varname+" is "+"\x04"+val);return;	
			}
		}
		else
		{
			Printer(player,"\x04"+"Executing: AdminSystem.Vars."+varname+"="+newval);
			compilestring("AdminSystem.Vars."+varname+"="+newval)();
		}
	}
	else
	{
		if(varname in AdminSystem.Vars)
		{
			local newval = GetArgument(2);
			if(newval == null)
			{	
				if(typeof AdminSystem.Vars[varname] == "table")
				{
					Printer(player,varname+" is a "+"\x04"+"table:\n"+Utils.GetTableString(AdminSystem.Vars[varname]));
					return;
				}
				else if(typeof AdminSystem.Vars[varname] == "array")
				{
					Printer(player,varname+" is "+"\x04"+Utils.ArrayString(AdminSystem.Vars[varname]));
					return;
				}
				else
				{
					Printer(player,varname+" is "+"\x04"+AdminSystem.Vars[varname]);return;	
				}
			}
			else
			{
				Printer(player,"\x04"+"Executing: AdminSystem.Vars."+varname+"="+newval);
				compilestring("AdminSystem.Vars."+varname+"="+newval)();
			}
		}
		else
		{Printer(player,"\x04"+"Cant find key: "+varname+" in AdminSystem.Vars, creating one...");AdminSystem.Vars[varname] <- null;return;}
	}
}

/*
 * @authors: rhino
 */
::AdminSystem.BlockerStateCmd <- function (player,arg)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local state = GetArgument(1);
	local applytoPhysicsBlocker = GetArgument(2);

	if(state == null || state == "disable" || state == "Disable")
		state = "Disable"
	else
		state = "Enable"

	if(applytoPhysicsBlocker != null)
	{
		foreach(obj in ::VSLib.EasyLogic.Objects.OfClassname("env_physics_blocker"))
		{	
			obj.Input(state);
		}
		foreach(obj in ::VSLib.EasyLogic.Objects.OfClassname("func_playerinfected_clip"))
		{	
			obj.Input(state);
		}
		foreach(obj in ::VSLib.EasyLogic.Objects.OfClassname("func_playerghostinfected_clip"))
		{	
			obj.Input(state);
		}
	}

	foreach(obj in ::VSLib.EasyLogic.Objects.OfClassname("env_player_blocker"))
	{	
		obj.Input(state);
	}

	Messages.InformAll(CmdMessages.Blocker.Success(state,applytoPhysicsBlocker));
}

/*
 * @authors: rhino
 */
::AdminSystem.Ladder_teamCmd <- function (player,arg)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local team = GetArgument(1);
	if(team==null)
		return;

	local teamtable =
	{	
		all = UNKNOWN
		spectator = SPECTATORS
		survivor = SURVIVORS
		infected = INFECTED
		l4d1 = L4D1_SURVIVORS
	}

	// Reset teams back to defaults
	if(team == "reset")	
	{	
		// No cache found, no reset needed
		if(!("_ladderteams" in AdminSystem.Vars))
			return;

		// Reset teams
		foreach(ldr in ::VSLib.EasyLogic.Objects.OfClassname("func_simpleladder"))
		{	
			ldr.Input("setteam",AdminSystem.Vars._ladderteams[ldr.GetIndex()]);
		}

		Messages.InformAll(CmdMessages.Ladders.Reset());
		return;
	}

	// Set new team to all ladders
	if(!(team in teamtable))
		return;

	team = teamtable[team].tostring();
	
	// Cache if first time then change teams
	if(!("_ladderteams" in AdminSystem.Vars))
	{	
		AdminSystem.Vars._ladderteams <- {};
		foreach(ldr in ::VSLib.EasyLogic.Objects.OfClassname("func_simpleladder"))
		{	
			AdminSystem.Vars._ladderteams[ldr.GetIndex()] <- ldr.GetTeam().tostring();
			ldr.Input("setteam",team)
		}
		CmdMessages.Ladders.Cache();
	}
	else
	{
		foreach(ldr in ::VSLib.EasyLogic.Objects.OfClassname("func_simpleladder"))
		{
			ldr.Input("setteam",team)
		}
	}

	switch(team.tointeger())
	{
		case UNKNOWN:
			team = "all"
			break;
		case SPECTATORS:
			team = "spectators"
			break;
		case SURVIVORS:
			team = "survivors"
			break;
		case INFECTED:
			team = "infected"
			break;
		case L4D1_SURVIVORS:
			team = "l4d1 survivors"
			break;
		default:
			team = "unknown";
			break;
	}

	Messages.InformAll(CmdMessages.Ladders.Change(team));
}

//////////////////////////////////////////////////////////
/*
 * @authors rhino
 * Default meteor event settings
 */

::AdminSystem._meteor_model_pick <- 
{
	RANDOM_ROCK = 0
	RANDOM_CUSTOM = 1
	FIRST_CUSTOM = 2
	LAST_CUSTOM = 3
	SPECIFIC = 4
}

::AdminSystem._meteor_shower_args <- Constants.GetMeteorShowerSettingsDefaults()

/* @authors rhino
 * Change meteor shower settings
 */
::AdminSystem.Meteor_shower_settingCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(!(setting in AdminSystem._meteor_shower_args))
		return;
	
	if(setting != "meteormodelspecific")
	{
		try{val = val.tofloat();}catch(e){return;}
	}
	else
	{	
		// TO-DO figure out the escape char checks
		/*
		if(val.find("\"") == null) // "
		{
			Messages.ThrowPlayer(player,CmdMessages.MeteorShowerSettings.ModelQuotesMissing());
			return;
		}
		else if(split(val,"\"").len() != 3) // "
		{
			Messages.ThrowPlayer(player,CmdMessages.MeteorShowerSettings.ModelQuotesFormat());
			return;
		}
		else
		{
			local s =  split(val,"\""); //"
			if(s[0] != "" || s[2] != "")
			{
				Messages.ThrowPlayer(player,CmdMessages.MeteorShowerSettings.ModelCharacterOutsideQuotes());
				return;
			}
		}
		*/
	}
	local name = player.GetCharacterName();

	Messages.InformAll(CmdMessages.MeteorShowerSettings.Success(name,setting,AdminSystem._meteor_shower_args[setting],val));
	
	AdminSystem._meteor_shower_args[setting] = val;
	AdminSystem.SaveShowerSettings();
}

/* @authors rhino
 * Show meteor shower settings
 */
::AdminSystem.Show_meteor_shower_settingsCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	AdminSystem.LoadShowerSettings();

	local comments = Constants.GetMeteorShowerSettingsComments();

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Meteor Shower Settings:");
		foreach(setting,val in AdminSystem._meteor_shower_args)
		{
			Messages.InformPlayer(player,"\x05" + setting + "\x03" + " -> " + "\x04" + val.tostring() + "\x01" + " (" + comments[setting] + ")\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem._meteor_shower_args)
		{
			printB(player.GetCharacterName(),"[Meteor_Shower-Setting] "+setting+" ----> "+val.tostring()+" ----> "+comments[setting],false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}

/*
 * @authors rhino
 * Execute each meteor tick
 */
::_MeteorTimer <- function (...)
{	
	if(AdminSystem.Vars._meteor_shower_state == 1)
	{	
		local unluckyone = Utils.GetRandValueFromArray(Players.AliveSurvivors());
		
		if(unluckyone == null)
		{
			return;
		}
		local metargs = AdminSystem._meteor_shower_args;

		::VSLib.Timers.AddTimer(metargs.mindelay+rand()%metargs.maxdelay, false, _MeteorShower,unluckyone);
	}
	else
	{
		if (Constants.TimerNames.MeteorShower in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.MeteorShower]);
			delete ::VSLib.Timers.TimersID[Constants.TimerNames.MeteorShower];
		}
		local endmsg = "Meteor shields are back up!";
		ClientPrint(null,3,"\x03"+endmsg);
	}

}

/* 
 * @authors rhino
 * Create a meteor and apply settings and probabilities given
 */
::_MeteorShower <- function (surv)
{	
	surv = surv.GetBaseEntity();

	local metargs = AdminSystem._meteor_shower_args;
	local maxexplosiondelay = metargs.maxexplosiondelay

	local minspeed = metargs.minspeed;
		
	local expdmgmin = metargs.expdmgmin;	
	
	local debug = metargs.debug;

	// Spawn base and ceiling calculations
	local ceiling = _FindRandomValidCeilingPoint(surv,metargs.minspawnheight,metargs.maxradius)
	if(ceiling == null)
		return;

	if(debug == 1)
	{
		DebugDrawText(ceiling,"***------CEILING FOUND------***",false,5);
		ClientPrint(null,DirectorScript.HUD_PRINTTALK,"\x04"+"Spawned meteor at: "+ceiling.x+","+ceiling.y+","+ceiling.z)
	}

	// Create the meteor
	local meteor = _CreateAndPushMeteor(metargs.meteormodelpick,ceiling,minspeed,(metargs.maxspeed - minspeed),true)
	
	if((rand().tofloat()/RAND_MAX) < metargs.expprob)
	{
		_AttachExplosionEffects(meteor,ceiling,expdmgmin,(metargs.expdmgmax - expdmgmin),metargs.expmaxradius)
		_AttachDamageOutput(meteor,"RunScriptCode","_MeteorExplosion("+meteor.GetIndex()+")",0,1)
	}
	else
	{
		meteor.AttachParticle("gas_explosion_smoking",maxexplosiondelay-0.5,null)
		meteor.Input("Kill","",maxexplosiondelay);
	}
}

/*
 * @authors rhino
 * Finds a random navigatable point with at least "minheight" height ceiling within given radius "maxdist" around survivor "surv"
 */
::_FindRandomValidCeilingPoint <- function(surv,minheight,maxdist)
{
	local spawnbase = surv.TryGetPathableLocationWithin(maxdist);
	local ceiling = Utils.GetLocationAbove(spawnbase,null,100);

	local lastheight = Utils.CalculateDistance(spawnbase,ceiling);

	while(lastheight < minheight && maxdist > 0)
	{
		spawnbase = surv.TryGetPathableLocationWithin(maxdist);
		ceiling = Utils.GetLocationAbove(spawnbase,null,100);

		lastheight = Utils.CalculateDistance(spawnbase,ceiling); // Try same distance again first
		maxdist -= 20;
	}

	if(lastheight < minheight)
		return;
	
	return ceiling;
}

/*
 * @authors rhino
 * Creates and pushes a meteor with given arguments
 */
::_CreateAndPushMeteor <- function(modelpick,ceiling,minspeed,maxspeed,pushrandom=true)
{
	local pushvec = null;
	local entmodel = null;

	// Select a model
	switch(modelpick)
	{
		case AdminSystem._meteor_model_pick.RANDOM_ROCK:
		{
			entmodel = Utils.GetRandValueFromArray(AdminSystem.Vars._meteor_models._rocks)
			break;
		}
		case AdminSystem._meteor_model_pick.RANDOM_CUSTOM:
		{
			entmodel = Utils.GetRandValueFromArray(AdminSystem.Vars._meteor_models._custom)
			break;
		}
		case AdminSystem._meteor_model_pick.FIRST_CUSTOM:
		{
			if(AdminSystem.Vars._meteor_models._custom.len() < 1)
			{
				return;
			}
			entmodel = AdminSystem.Vars._meteor_models._custom[0];
			break;
		}
		case AdminSystem._meteor_model_pick.LAST_CUSTOM:
		{
			if(AdminSystem.Vars._meteor_models._custom.len() < 1)
			{
				return;
			}
			entmodel = AdminSystem.Vars._meteor_models._custom[AdminSystem.Vars._meteor_models._custom.len()-1]
			break;
		}
		case AdminSystem._meteor_model_pick.SPECIFIC:
		{
			entmodel = AdminSystem._meteor_shower_args.meteormodelspecific;
			break;
		}
	}

	local keyvals = 
	{
		targetname = "meteorspawn"
		classname = "prop_physics_multiplayer"
		model = entmodel
		origin = ceiling
		angles = QAngle(0,0,0)
		massScale = 10
	}

	local meteor = Utils.CreateEntityWithTable(keyvals);
	meteor.AttachParticle("env_fire_large_smoke",-1,null)

	if(pushrandom)
		pushvec = QAngle(rand()%360,rand()%360,rand()%360).Forward();
	else
		pushvec = Vector(0,0,-1)

	pushvec = pushvec.Scale((minspeed+rand()%maxspeed).tofloat()/pushvec.Length())
	meteor.Push(pushvec);

	return meteor;
}

/*
 * @authors rhino
 * Attaches explosion and explosion sound to entity
 */
::_AttachExplosionEffects <- function(meteor,spawnpos,expdmgmin,expdmgmax,expmaxradius)
{
	local explosion_table =
	{
		classname = "env_explosion",
		spawnflags = 0, 
		origin = spawnpos, 
		iMagnitude = expdmgmin+(rand()%expdmgmax), 
		iRadiusOverride = rand()%expmaxradius
	}
	local explosion = Utils.CreateEntityWithTable(explosion_table);
	local explosion_sound = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = spawnpos});

	meteor.AttachOther(explosion,false,0,null);
	meteor.AttachOther(explosion_sound,false,0,null);
}

::_AttachDamageOutput <- function(meteor,input,val,delay,repeat)
{	
	//meteor.SetDamageFilter(DMG_FALL|DMG_CRUSH|DMG_STUMBLE)
	meteor.Input("addoutput","OnTakeDamage !self,"+input+","+val+","+delay+","+repeat,0,null)
}

/* 
 * @authors rhino
 * Trigger effects of meteor's child entities
 */
::_MeteorExplosion <- function(met)
{
	local argtable = AdminSystem._meteor_shower_args;
	local debugstr = "";

	if(argtable.debug == 1)
		debugstr += "\x05"+"0:"+"\x03"+"meteor #"+met
	
	local meteor = Ent("#"+met)

	local prtc = null
	local explosion = null
	local explosionsnd = null

	local child = meteor.FirstMoveChild()
	for(local i=1;i<4;i++)
	{
		if(child == null)
			break;

		switch(child.GetClassname())
		{
			case "ambient_generic":
			{
				explosionsnd = Ent("#"+child.GetEntityIndex());
				if(argtable.debug == 1)
					debugstr += "\x05"+", "+i+":"+"\x03"+"expsound #"+child.GetEntityIndex()
				break;
			}
			case "info_particle_system":
			{
				prtc = Ent("#"+child.GetEntityIndex());
				if(argtable.debug == 1)
					debugstr += "\x05"+", "+i+":"+"\x03"+"particle #"+child.GetEntityIndex()
				break;
			}
			case "env_explosion":
			{
				explosion = Ent("#"+child.GetEntityIndex());
				if(argtable.debug == 1)
					debugstr += "\x05"+", "+i+":"+"\x03"+"exp #"+child.GetEntityIndex()
				break;
			}
			default:
				break;
		}
		child = child.NextMovePeer();
	}

	local minspeed = argtable.minspeed;
	local maxspeed = (argtable.maxspeed - minspeed);
	local metorigin = meteor.GetOrigin()

	local closebyents = VSLib.EasyLogic.Objects.AroundRadius(metorigin,argtable.expmaxradius);
	_RemoveNonPhysicsFromTable(closebyents,metorigin,argtable.expmaxradius);

	if((rand().tofloat()/RAND_MAX) < argtable.scatterprob)
	{
		local chunkamount = RandomInt(argtable.minscatterchunk,argtable.maxscatterchunk);
		local models = AdminSystem.Vars._meteor_models._chunks
		local keyvals = 
		{
			model = ""
			classname = "prop_physics_multiplayer"
			origin = metorigin
			angles = QAngle(0,0,0)
		}
		local chunk = null;
		for(local i=0;i<chunkamount;i++)
		{
			keyvals.model = Utils.GetRandValueFromArray(models)
			keyvals.origin.x = metorigin.x + RandomInt(-20,20)
			keyvals.origin.y = metorigin.y + RandomInt(-20,20)
			keyvals.origin.z = metorigin.z + RandomInt(0,25)

			chunk = Utils.CreateEntityWithTable(keyvals)
			if(chunk == null)
				continue

			chunk.AttachParticle("burning_wood_02",9,null)
			chunk.KillDelayed(10)

			closebyents[chunk.GetIndex()] <- chunk
		}
	}		

	::VSLib.Timers.AddTimer(0.1,
							false,
							_explosionPush,
							{
								explosion_sound = VSLib.Entity(explosionsnd),
								explosion = VSLib.Entity(explosion),
								ents = closebyents,
								pushspeed = minspeed+rand()%maxspeed,
								origin = metorigin
							})
		
	DoEntFire("!self", "Stop", "", 0.0, null, prtc);
	DoEntFire("!self", "Kill", "", 0.3, null, meteor);

	if(argtable.debug == 1)
		ClientPrint(null,3,debugstr);
}


/* @authors rhino
 * Start the meteor shower
 */
::AdminSystem.Start_the_showerCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	if(AdminSystem.Vars._meteor_shower_state == 0)
	{	
		AdminSystem.LoadShowerSettings();
		ClientPrint(null,3,"\x04"+Utils.GetRandValueFromArray(CmdMessages.MeteorShowerSettings.StartingMessages));
		AdminSystem.Vars._meteor_shower_state = 1;
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.MeteorShower,AdminSystem._meteor_shower_args.updatedelay, true, _MeteorTimer,{});	
	}
	else
	{	
		AdminSystem.SaveShowerSettings();
		AdminSystem.Pause_the_showerCmd(player,args);
	}
}

/* @authors rhino
 * Pauses the meteor shower
 */
::AdminSystem.Pause_the_showerCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	if(AdminSystem.Vars._meteor_shower_state == 1)
	{
		AdminSystem.Vars._meteor_shower_state = 0;
	}
}

/* @authors rhino
 * Change debug message reporting state of the meteor shower
 */
::AdminSystem.Meteor_shower_debugCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ) || !player.IsServerHost())
		return;

	AdminSystem._meteor_shower_args.debug = 1 - AdminSystem._meteor_shower_args.debug;
	
	Printer(player,"[Meteor_Shower-Debug] Meteor shower debug state :"+( AdminSystem._meteor_shower_args.debug == 1 ? " Enabled":" Disabled"));
	AdminSystem.SaveShowerSettings();
}

/*
 * @authors rhino
 * Default apocalypse event settings
 */

::AdminSystem._propageddon_args <- Constants.GetApocalypseSettingsDefaults()

/* @authors rhino
 * Change how hellish you want the experience to be
 */
::AdminSystem.Apocalypse_settingCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(!(setting in AdminSystem._propageddon_args))
		return;
	
	try{val = val.tofloat();}catch(e){return;}

	local name = player.GetCharacterName();

	Messages.InformAll(CmdMessages.ApocalypseSettings.Success(name,setting,AdminSystem._propageddon_args[setting],val));
	
	AdminSystem._propageddon_args[setting] = val;
	AdminSystem.SaveApocalypseSettings();
}

/* @authors rhino
 * Show apocalypse params
 */
::AdminSystem.Show_apocalypse_settingsCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	AdminSystem.LoadApocalypseSettings();
	local comments = Constants.GetApocalypseSettingsComments();

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Apocalypse Settings:");
		foreach(setting,val in AdminSystem._propageddon_args)
		{
			Messages.InformPlayer(player,"\x05"+setting+"\x03"+" -> "+"\x04"+val.tostring()+"\x01"+" ("+comments[setting]+")\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem._propageddon_args)
		{
			printB(player.GetCharacterName(),"[Apocalypse-Setting] "+setting+" ----> "+val.tostring()+" ----> "+comments[setting],false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}

/*
 * @authors rhino
 * Execute each apocalypse tick
 */
::_ApocalypseTimer <- function (...)
{	
	if(AdminSystem.Vars._propageddon_state == 1)
	{	
		local unluckyone = Utils.GetRandValueFromArray(Players.AliveSurvivors());
		
		if(unluckyone == null)
		{
			return;
		}
		local apocargs = AdminSystem._propageddon_args;
		local entities = VSLib.EasyLogic.Objects.AroundRadius(unluckyone.GetPosition(),apocargs.maxradius);
		local validents = {}
		foreach(id,ent in entities)
		{
			if(ent.GetParent() == null)
			{
				validents[id] <- ent;
			}
		}
		::VSLib.Timers.AddTimer(apocargs.mindelay+rand()%apocargs.maxdelay, false, _Propageddon,validents);
	}
	else
	{
		if (Constants.TimerNames.Apocalypse in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[Constants.TimerNames.Apocalypse]);
			delete ::VSLib.Timers.TimersID[Constants.TimerNames.Apocalypse];
		}

		ClientPrint(null,3,"\x03"
							+ CmdMessages.ApocalypseSettings.Ending 
							+ (Utils.GetRandValueFromArray(CmdMessages.ApocalypseSettings.Extras)));
	}

}

/* @authors rhino
 * Apply forces to random entities from the table
 */
::_Propageddon <- function (enttbl)
{	
	local apocargs = AdminSystem._propageddon_args;

	local prob = apocargs.entprob;
	local dmgprob = apocargs.dmgprob;
	local breakprob = apocargs.breakprob;
	local doorlockprob = apocargs.doorlockprob;
	local ropebreakprob = apocargs.ropebreakprob;				
	local expprob = apocargs.expprob;

	local minspeed = apocargs.minspeed;
	local maxspeed = (apocargs.maxspeed - minspeed);

	local mindmg = apocargs.dmgmin;
	local maxdmg = (apocargs.dmgmax - mindmg);

	local expmaxradius = apocargs.expmaxradius;			
	local expdmgmin = apocargs.expdmgmin;			
	local expdmgmax = (apocargs.expdmgmax - expdmgmin);	

	local pushvec = null;
	local entclass = null;
	local entindex = null;
	local entmodel = null;
	local expent = null;
	local expsoundent = null;

	local pushedents = {};
	local brokenents = {};
	local useddoors = {};
	local lockeddoors = {};
	local damagedents = {};
	local animatedents = {};
	local explosions = {};

	local debug = apocargs.debug;

	if(debug == 1)
	{
		foreach(id,ent in enttbl)
		{	
			if((rand().tofloat()/RAND_MAX) < prob )
			{	
				if(!ent.IsEntityValid())
				{
					continue;
				}

				entclass = ent.GetClassname();
				entmodel = ent.GetModel();
				entindex = ent.GetIndex();

				// Anything with physics
				if(entclass == "prop_physics" || entclass == "prop_physics_multiplayer"  || entclass == "prop_car_alarm" || entclass == "prop_vehicle" || entclass == "prop_physics_override" || entclass == "func_physbox" ||  entclass == "func_physbox_multiplayer" || entclass == "prop_ragdoll" )
				{ 	
					//Damage
					if((rand().tofloat()/RAND_MAX) < dmgprob)
					{
						if(ent.GetHealth() > 0)
						{
							ent.Hurt(mindmg+rand()%maxdmg);
							damagedents[entindex] <- entclass+", "+entmodel;
						}
					}

					//Explosion
					if((rand().tofloat()/RAND_MAX) < expprob)
					{
						if(ent.GetHealth() > 0)
						{	
							expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
							expsoundent.Input("ToggleSound","",0.2);
							expent.Input("Explode","",0.25);
							expsoundent.Input("Kill","",3.0);
							explosions[entindex] <- entclass+", "+entmodel;
						}
					}
					
					//Break
					if(entmodel.find("forklift") != null)
					{
						if((rand().tofloat()/RAND_MAX) < breakprob)
						{
							ent.Break();
							brokenents[entindex] <- entclass+", "+entmodel;
						}
					}

					//Push
					pushvec = QAngle(rand()%360,rand()%360,rand()%360).Forward();
					pushvec = pushvec.Scale((minspeed+rand()%maxspeed).tofloat()/pushvec.Length())
					
					ent.Push(pushvec);
					
					pushedents[entindex] <- entclass+", "+entmodel;
				}
				else if(entclass == "func_breakable" || entclass == "func_breakable_surf" || entclass == "prop_wall_breakable" ) //Any breakable surface
				{	
					//Damage
					if((rand().tofloat()/RAND_MAX) < dmgprob)
					{	
						if(ent.GetHealth() > 0)
						{
							ent.Hurt(mindmg+rand()%maxdmg);
							damagedents[entindex] <- entclass+", "+entmodel;
						}
					}
					
					//Explosion
					if((rand().tofloat()/RAND_MAX) < expprob)
					{
						if(ent.GetHealth() > 0)
						{	
							expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
							expsoundent.Input("ToggleSound","",0.2);
							expent.Input("Explode","",0.25);
							expsoundent.Input("Kill","",3.0);
							explosions[entindex] <- entclass+", "+entmodel;
						}
					}

					//Break
					if((rand().tofloat()/RAND_MAX) < breakprob)
					{
						ent.Break();
						brokenents[entindex] <- entclass+", "+entmodel;
					}
				}
				else if(entclass == "move_rope" || entclass == "keyframe_rope")		//Cables and ropes
				{	
					//Explosion
					if((rand().tofloat()/RAND_MAX) < expprob)
					{
						if(ent.GetHealth() > 0)
						{	
							expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
							expsoundent.Input("ToggleSound","",0.2);
							expent.Input("Explode","",0.25);
							expsoundent.Input("Kill","",3.0);
							explosions[entindex] <- entclass+", "+entmodel;
						}
					}

					//Break
					if((rand().tofloat()/RAND_MAX) < ropebreakprob)
					{
						ent.Break();
						brokenents[entindex] <- entclass+", "+entmodel;
					}	
				}
				else if(entclass == "prop_door_rotating" || entclass == "func_door" || entclass == "func_door_rotating" || entclass == "func_rotating") //Any door except saferoom's
				{	//Damage
					if((rand().tofloat()/RAND_MAX) < dmgprob)
					{
						if(ent.GetHealth() > 0)
						{
							ent.Hurt(mindmg+rand()%maxdmg);
							damagedents[entindex] <- entclass+", "+entmodel;
						}
					}
					
					//Explosion
					if((rand().tofloat()/RAND_MAX) < expprob)
					{
						if(ent.GetHealth() > 0)
						{	
							expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
							expsoundent.Input("ToggleSound","",0.2);
							expent.Input("Explode","",0.25);
							expsoundent.Input("Kill","",3.0);
							explosions[entindex] <- entclass+", "+entmodel;
						}
					}

					//Close and Lock
					if((rand().tofloat()/RAND_MAX) < doorlockprob)
					{	
						ent.Input("close","");
						ent.Input("lock","",0.5);
						lockeddoors[entindex] <- entclass+", "+entmodel;
					}
					else //Open or Close
					{
						ent.Input("toggle","");
						useddoors[entindex] <- entclass+", "+entmodel;
					}
				}
				else if(entclass == "prop_door_rotating_checkpoint")	//Saferoom door
				{	
					//Open or Close	
					ent.Input("toggle","");
					useddoors[entindex] <- entclass+", "+entmodel;
				}
				else if(entclass == "prop_health_cabinet")	//Health cabinet
				{	
					//Open or Close animation
					if((rand().tofloat()/RAND_MAX) < 0.5)
						ent.Input("setanimation","idle");	
					else
						ent.Input("setanimation","open");

					animatedents[entindex] <- entclass+", "+entmodel;
				}
			}
		}

		printl("---------------------------------------------");
		if(pushedents.len() != 0)
			{printl("PUSHED\n");Utils.PrintTable(pushedents);}

		if(brokenents.len() != 0)
			{printl("BROKEN\n");Utils.PrintTable(brokenents);}

		if(useddoors.len() != 0)
			{printl("OPENED/CLOSED\n");Utils.PrintTable(useddoors);}

		if(lockeddoors.len() != 0)
			{printl("LOCKED\n");Utils.PrintTable(lockeddoors);}

		if(damagedents.len() != 0)
			{printl("DAMAGED\n");Utils.PrintTable(damagedents);}

		if(explosions.len() != 0)
			{printl("EXPLODED\n");Utils.PrintTable(explosions);}

	}
	else
	{
		foreach(id,ent in enttbl)
		{	
			if((rand().tofloat()/RAND_MAX) < prob )
			{	
				if(!ent.IsEntityValid())
				{
					continue;
				}

				entclass = ent.GetClassname();
				entmodel = ent.GetModel();

				switch(entclass)
				{
					// Anything with physics
					case "prop_physics":
					case "prop_physics_multiplayer":
					case "prop_car_alarm":
					case "prop_vehicle":
					case "prop_physics_override":
					case "func_physbox":
					case "func_physbox_multiplayer":
					case "prop_ragdoll":
					{ 	
						//Damage
						if((rand().tofloat()/RAND_MAX) < dmgprob)
						{
							if(ent.GetHealth() > 0)
							{
								ent.Hurt(mindmg+rand()%maxdmg);
							}
						}

						//Explosion
						if((rand().tofloat()/RAND_MAX) < expprob)
						{
							if(ent.GetHealth() > 0)
							{	
								expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
								expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
								expsoundent.Input("ToggleSound","",0.2);
								expent.Input("Explode","",0.25);
								expsoundent.Input("Kill","",3.0);
							}
						}
						
						//Break
						if(entmodel.find("forklift") != null)
						{
							if((rand().tofloat()/RAND_MAX) < breakprob)
							{
								ent.Break();
							}
						}

						//Push
						pushvec = QAngle(rand()%360,rand()%360,rand()%360).Forward();
						pushvec = pushvec.Scale((minspeed+rand()%maxspeed).tofloat()/pushvec.Length())
						
						ent.Push(pushvec);
						break;
					}

					//Any breakable surface
					case "func_breakable":
					case "func_breakable_surf":
					case "prop_wall_breakable":
					{	
						//Damage
						if((rand().tofloat()/RAND_MAX) < dmgprob)
						{	
							if(ent.GetHealth() > 0)
							{
								ent.Hurt(mindmg+rand()%maxdmg);
							}
						}
						
						//Explosion
						if((rand().tofloat()/RAND_MAX) < expprob)
						{
							if(ent.GetHealth() > 0)
							{	
								expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
								expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
								expsoundent.Input("ToggleSound","",0.2);
								expent.Input("Explode","",0.25);
								expsoundent.Input("Kill","",3.0);
							}
						}

						//Break
						if((rand().tofloat()/RAND_MAX) < breakprob)
						{
							ent.Break();
						}
						break;
					}

					//Cables and ropes
					case "move_rope":
					case "keyframe_rope":
					{	
						//Explosion
						if((rand().tofloat()/RAND_MAX) < expprob)
						{
							if(ent.GetHealth() > 0)
							{	
								expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
								expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
								expsoundent.Input("ToggleSound","",0.2);
								expent.Input("Explode","",0.25);
								expsoundent.Input("Kill","",3.0);
							}
						}

						//Break
						if((rand().tofloat()/RAND_MAX) < ropebreakprob)
						{
							ent.Break();
						}
						break;
					}

					//Any door except saferoom's
					case "prop_door_rotating":
					case "func_door":
					case "func_door_rotating":
					case "func_rotating":
					{	
						//Damage
						if((rand().tofloat()/RAND_MAX) < dmgprob)
						{
							if(ent.GetHealth() > 0)
							{
								ent.Hurt(mindmg+rand()%maxdmg);
							}
						}
						
						//Explosion
						if((rand().tofloat()/RAND_MAX) < expprob)
						{
							if(ent.GetHealth() > 0)
							{	
								expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = ent.GetOrigin(), iMagnitude = expdmgmin+(rand()%expdmgmax), iRadiusOverride = rand()%expmaxradius });
								expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = ent.GetOrigin()});
								expsoundent.Input("ToggleSound","",0.2);
								expent.Input("Explode","",0.25);
								expsoundent.Input("Kill","",3.0);
							}
						}

						//Close and Lock
						if((rand().tofloat()/RAND_MAX) < doorlockprob)
						{	
							ent.Input("close","");
							ent.Input("lock","",0.5);
						}
						else //Open or Close
						{
							ent.Input("toggle","");
						}
						break;
					}

					//Saferoom door
					case "prop_door_rotating_checkpoint":
					{	
						//Open or Close	
						ent.Input("toggle","");
						break;
					}
					
					//Health cabinet
					case "prop_health_cabinet":	
					{	
						//Open or Close animation
						if((rand().tofloat()/RAND_MAX) < 0.5)
							ent.Input("setanimation","idle");	
						else
							ent.Input("setanimation","open");
						break;
					}
				}
			}
		}
	}
	
} 

/* @authors rhino
 * monkaOMEGA
 */
::AdminSystem.Start_the_apocalypseCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	if(AdminSystem.Vars._propageddon_state == 0)
	{	
		AdminSystem.LoadApocalypseSettings();
		ClientPrint(null,3,"\x04"+Utils.GetRandValueFromArray(CmdMessages.ApocalypseSettings.StartingMessages));
		AdminSystem.Vars._propageddon_state = 1;
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.Apocalypse,AdminSystem._propageddon_args.updatedelay, true, _ApocalypseTimer,{});	
	}
	else
	{	
		AdminSystem.SaveApocalypseSettings();
		AdminSystem.Pause_the_apocalypseCmd(player,args);
	}
}

/* @authors rhino
 * Pauses the apocalypse... or does it ?
 */
::AdminSystem.Pause_the_apocalypseCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	if(AdminSystem.Vars._propageddon_state == 1)
	{
		AdminSystem.Vars._propageddon_state = 0;
	}
}

/* @authors rhino
 * Change debug message reporting state of the apocalypse
 */
::AdminSystem.Apocalypse_debugCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ) || !player.IsServerHost())
		return;

	AdminSystem._propageddon_args.debug = 1 - AdminSystem._propageddon_args.debug;

	Printer(player,"[Apocalypse-Debug] Apocalypse debug state :"+( AdminSystem._propageddon_args.debug == 1 ? " Enabled":" Disabled"));
	AdminSystem.SaveApocalypseSettings();
}

/*
 * @authors rhino
 * Speak the given line for given length
 * @param character = Speaker
 * @param scene_name = Scene name
 * @param trimend = How long to speak, null to speak all *
 * Example:
 *			!speak_test zoey warnboomer01 0.5		//Zoey speaks first 0.5 seconds of warnboomer01
 */
::AdminSystem.Speak_testCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local character = GetArgument(1);
	if(character==null)
	{return;}

	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	local scene_name = GetArgument(2);
	if(scene_name==null)
	{return;}

	local trimend = GetArgument(3)
	if(trimend==null)
	{
		trimend = "full_duration"; // make it play after the blank == play it full
		_SceneSequencer(Utils.GetPlayerFromName(character),{scenes=[scene_name],delays=[0]});
	}
	else
	{
		trimend = trimend.tofloat();
		_SceneSequencer(Utils.GetPlayerFromName(character),{scenes=["blank",scene_name],delays=[trimend,0.15]});
	}

	Printer(player,CmdMessages.CustomSpeak.TestSuccess(character,scene_name,trimend));
}

/*
 * @authors rhino
 * Speak the given custom sequence
 * @param character = Speaker
 * @param seq_name = Custom sequence name *
 * Example:
 *			!speak_custom bill mysequence	// Bill speaks his mysequence
 */
::AdminSystem.Speak_customCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local character = GetArgument(1);
	local seq_name = GetArgument(2);
	if(character==null)
	{return;}

	// Single arguments == character = self , seq_name = arg1
	if(seq_name==null)
	{
		seq_name = character;
		character = player.GetCharacterNameLower();
	}
	else
	{
		character = character.tolower();
	}

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	try
	{
		_SceneSequencer(Utils.GetPlayerFromName(character),AdminSystem.Vars._CustomResponseOptions[character][player.GetSteamID()].sequence[seq_name]);
	}
	catch(e)
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,seq_name));
		return;
	}

	Printer(player,CmdMessages.CustomSpeak.Success(character,seq_name));
}


/*
 * @authors rhino
 */
::_TimedLooper <- function(argtable)
{
	if(AdminSystem.Vars._looping[argtable.character])
	{	
		_SceneSequencer(Utils.GetPlayerFromName(argtable.character),argtable.sequence);
	}
	else
	{
		if (argtable.timername in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[argtable.timername]);
			delete ::VSLib.Timers.TimersID[argtable.timername];
		}

		_SceneSequencer(Utils.GetPlayerFromName(argtable.character),{scenes=["blank"],delays=[0]}); // Interrupt the last spoken line
	}
}

/*
 * @authors rhino
 * Stops the looping character
 */
::AdminSystem.Speak_loop_stopCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local character = GetArgument(1);
	if(character==null)
	{character = player.GetCharacterName();}
	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	if(AdminSystem.Vars._looping[character])
	{
		Printer(player,CmdMessages.Loops.Stop(character));
		AdminSystem.Vars._looping[character] = false;
	}
	
}

/*
 * @authors rhino
 * Start speaking given lines with given delays in a loop
 * TO USE SEQUENCE NAMES ADD ">" TO BEGINNING 
 * Argument format:  character sequence|line loop_length
 *
 * Example:
 *			!loop nick >mysequence 10	// Speak nick's custom sequence mysequence every 10 seconds 
 *			!loop coach battlecry02 5	// Speak coach's battlecry02 every 5 seconds 
 */
::AdminSystem.Speak_loopCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	local arguments = ::VSLib.EasyLogic.LastArgs;
	local arglen = arguments.len();

	if(-1 in arguments)
	{arglen -= 1;}
	else// called from chat
	{
		if(arglen < 2)
		{
			Messages.ThrowPlayer(player,CmdMessages.Loops.ValidFormats);return;
		}
	}
	local steamid = player.GetSteamID();
	
	local character = arguments[0];
	if(character==null)
	{return;}
	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}
	
	//Return if already in a loop
	if(AdminSystem.Vars._looping[character])
	{Messages.ThrowPlayer(player,CmdMessages.Loops.AlreadyLooping(character));return;}

	local sequencename = arguments[1];
	local looplength = arguments[2].tofloat();
	
	// Decide if a sequence or a scene was given
	if(sequencename.find(">") != null) // Sequence
	{	
		sequencename = split(sequencename,">")[0];
		
		if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
		{Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;}
		else
		{
			if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
			{Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,sequencename));return;}

			local seqtable = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename];
			local blanksec = looplength-Utils.ArrayMax(seqtable.delays);
			// Loop length is shorter
			if(blanksec<0)
			{Messages.WarnPlayer(player,CmdMessages.Loops.ShorterLength(blanksec,player.GetCharacterName(),sequencename,looplength));}
			
			AdminSystem.Vars._looping[character] = true;
			
			//First loop base
			local loopseq = {scenes=[],delays=[]};
			if(blanksec<0)
			{
				foreach(i,delay in seqtable.delays)
				{
					if(delay.tofloat()<looplength) // Filter out scenes after blanktime
					{
						loopseq.scenes.append(seqtable.scenes[i]);
						loopseq.delays.append(delay);
					}
				}
			}
			else
			{
				loopseq = Utils.TableCopy(seqtable);
			}
			loopseq.scenes.append("blank");
			loopseq.delays.append(looplength);
			//First loop call
			_SceneSequencer(Utils.GetPlayerFromName(character),loopseq)

			AdminSystem.Vars._loopingTable[character].timername = player.GetCharacterName()+"_"+character+"_"+sequencename;
			AdminSystem.Vars._loopingTable[character].character = character;
			AdminSystem.Vars._loopingTable[character].sequence = loopseq;

			//On repeat rest of the calls
			::VSLib.Timers.AddTimerByName(AdminSystem.Vars._loopingTable[character].timername,looplength+0.1, true, _TimedLooper,AdminSystem.Vars._loopingTable[character]);
		
		}
	}
	else	// Scene
	{	
		AdminSystem.Vars._looping[character] = true;
		
		AdminSystem.Vars._loopingTable[character].timername = player.GetCharacterName()+"_"+character+"_"+sequencename;
		AdminSystem.Vars._loopingTable[character].character = character;
		AdminSystem.Vars._loopingTable[character].sequence = {scenes=[sequencename],delays=[0]};

		_SceneSequencer(Utils.GetPlayerFromName(character),{scenes=[sequencename],delays=[0]})
		::VSLib.Timers.AddTimerByName(AdminSystem.Vars._loopingTable[character].timername,looplength+0.1, true, _TimedLooper,AdminSystem.Vars._loopingTable[character]);
	}

	Printer(player,CmdMessages.Loops.Start(character,sequencename));

}

/*
 * @authors rhino
 * Show saved custom sequences for given character
 * @param character = Speaker, null | all for saved sequences for all characters
 */
::AdminSystem.Show_custom_sequencesCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local character = GetArgument(1);
	local seqnames = "";
	local steamid = player.GetSteamID();
	if(AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		if(character == null || character == "all")
		{
			ClientPrint(player.GetBaseEntity(),3,"\x03"+"-----------------");

			foreach(charname in AdminSystem.Vars.CharacterNamesLower)
			{	
				if(charname == "" || charname == "survivor")
					continue;

				seqnames += charname + "("
				if(steamid in AdminSystem.Vars._CustomResponseOptions[charname])
				{
					ClientPrint(player.GetBaseEntity(),3,"\x04"+charname+":");

					foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[charname][steamid].sequence)
					{
						ClientPrint(player.GetBaseEntity(),3,"\x05"+seq_name);
					}

					ClientPrint(player.GetBaseEntity(),3,"\x04"+"-----------------");
				}
			}

			ClientPrint(player.GetBaseEntity(),3,"\x03"+"-----------------");
		}
		else
		{
			ClientPrint(player.GetBaseEntity(),3,"\x03"+"-----------------");

			character = character.tolower();
			if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
			{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

			if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
			{Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;}

			ClientPrint(player.GetBaseEntity(),3,"\x04"+character+":");

			foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence)
			{
				ClientPrint(player.GetBaseEntity(),3,"\x05"+seq_name);
				seqnames += seq_name + " ";
			}

			ClientPrint(player.GetBaseEntity(),3,"\x04"+"-----------------");
		}
	}
	else
	{
		if(character == null || character == "all")
		{
			printB(player.GetCharacterName(),"-----------------",false,"",true,false);

			foreach(charname in AdminSystem.Vars.CharacterNamesLower)
			{	
				if(charname == "" || charname == "survivor")
					continue;

				seqnames += charname + "("
				if(steamid in AdminSystem.Vars._CustomResponseOptions[charname])
				{
					printB(player.GetCharacterName(),charname+"->",false,"info",false,false);

					foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[charname][steamid].sequence)
					{
						printB(player.GetCharacterName(),seq_name,false,"info",false,false);
					}

					printB(player.GetCharacterName(),"-----------------",false,"",false,false);
				}
			}

			printB(player.GetCharacterName(),"-----------------",false,"",false,true);
		}
		else
		{
			printB(player.GetCharacterName(),"-----------------",false,"",true,false);

			character = character.tolower();
			if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
			{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

			if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
			{Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;}

			printB(player.GetCharacterName(),character+"->",false,"info",true,false);

			foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence)
			{
				printB(player.GetCharacterName(),seq_name,false,"info",false,false);
				seqnames += seq_name + " ";
			}

			printB(player.GetCharacterName(),"-----------------",false,"info",false,true);
		}
	}
	
}

/*
 * @authors rhino
 * Show scenes and delays from a saved sequence *
 * Example:
 *			!seq_info nick mysequence
 */
::AdminSystem.Sequence_infoCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local character = GetArgument(1);
	if(character==null)
	{return;}

	local sequencename = GetArgument(2);
	if(sequencename==null)
	{
		sequencename = character;
		character = player.GetCharacterNameLower();
	}
	else
	{
		character = character.tolower();
	}

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	local str = "\n";
	local steamid = player.GetSteamID();

	if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;
	}

	if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,sequencename));return;
	}
	
	str += Utils.ArrayString(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes)
	str += "\n"
	str += Utils.ArrayString(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays)

	Printer(player,CmdMessages.CustomSequences.InfoString(character,sequencename,str));
}

/*
 * @authors rhino
 * Show scenes and delays from a saved sequence
 * @param character = character
 * @param sequencename = sequence name
 * @param scene = scene name OR index,  use ">x" for scene at index x
 * @param setting = format this as "scene>new_scene" OR "delay>x"
 *
 * Example:
 *			!seq_edit nick mysequence >1 delay>4				// Change scene at index 1's delay to 4 seconds
 *			!seq_edit nick mysequence hurrah01 scene>hurrah02   // Change first appearence of hurrah1 to hurrah2
 */
::AdminSystem.Sequence_editCmd <- function (player,args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local character = GetArgument(1);
	if(character==null)
	{return;}

	local sequencename = GetArgument(2);
	if(sequencename==null)
	{return;}
	
	local scene = GetArgument(3);
	local setting = GetArgument(4);
	
	character = character.tolower();
	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	local steamid = player.GetSteamID();
	
	if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;
	}

	if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,sequencename));return;
	}
	
	local scene_index = -1;
	local oldvalue = "";

	// Which scene
	if(scene.find(">") != null) // index is given
	{
		scene_index = split(scene,">")[0].tointeger();
	}
	else
	{
		scene_index = Utils.GetIDFromArray(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes,scene);
	}

	local newval = null;
	// Change which one
	if(scene_index != -1)
	{	
		if(setting.find(">") != null)
		{	
			setting = split(setting,">");
			if(setting.len() != 2)
			{
				Messages.ThrowPlayer(player,CmdMessages.CustomSequences.EditFormat);return;
			}

			newval = setting[1];
			setting = setting[0];

			if(setting == "scene")
			{
				oldvalue = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes[scene_index];
				AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes[scene_index] = newval;
			}
			else if(setting == "delay")
			{
				oldvalue = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays[scene_index];
				AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays[scene_index] = newval;
			}
			else
			{
				Messages.ThrowPlayer(player,CmdMessages.CustomSequences.EditFormat);return;
			}
		}
		else
		{
			Messages.ThrowPlayer(player,CmdMessages.CustomSequences.EditFormat);return;
		}
		
	}
	else
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSceneFound(scene));return;
	}

	// Output messages
	Printer(player,CmdMessages.CustomSequences.EditSuccess(character,sequencename,setting,scene_index,oldvalue,newval));

	// Save to custom file
	local contents = FileToString(Constants.Directories.CustomResponses);
	if(contents == null)
	{Messages.WarnAll(CmdMessages.CustomSequences.FileMissing(Constants.Directories.CustomResponses));return;}

	local responsetable = compilestring( "return " + contents )();

	if (setting == "scene")
	{
		responsetable[steamid][character][sequencename].scenes[scene_index] = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes[scene_index];
	}
	else
	{
		responsetable[steamid][character][sequencename].delays[scene_index] = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays[scene_index];
	}

	StringToFile(Constants.Directories.CustomResponses, Utils.SceneTableToString(responsetable));
	AdminSystem.LoadCustomSequences();
}

/*
 * @authors rhino
 * Load sequences from custom_responses.json
 */
::AdminSystem.LoadCustomSequences <- function (...)
{
	local contents = FileToString(Constants.Directories.CustomResponses);
	// First time
	if(contents == null)
	{	
		CmdMessages.CustomSequences.CreatingFile();
		contents = "{";
		foreach(admin,val in AdminSystem.Admins)
		{
			if(val)
				contents += "\n\t\""+admin+"\":\n\t{\n\t\t\"character_name\":\n\t\t{\n\t\t\t\"sequence_name\":\n\t\t\t{\n\t\t\t\t\"scenes\":[\"blank\"],\n\t\t\t\t\"delays\":[0]\n\t\t\t}\n\t\t}\n\t}"; 
		}
		contents += "\n}";
		StringToFile(Constants.Directories.CustomResponses, contents);
	}

	local responsetable = compilestring( "return " + contents )();

	// Check admins
	foreach(admin,val in AdminSystem.Admins)
	{	
		if(!(admin in responsetable))
		{
			CmdMessages.CustomSequences.AddingMissingAdminTables(admin);
			responsetable[admin] <- {character_name={sequence_name={scenes=["blank"],delays=[0]}}};
		}
	}

	foreach(steamid,chartable in responsetable)
	{	
		foreach(character,customs in chartable)
		{	
			if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1 || character == "" || character == "survivor"){continue;} // Ignore wrong character names

			// Add steamid to each character
			foreach(charname in AdminSystem.Vars.CharacterNamesLower)
			{
				if(charname == "" || charname == "survivor")
					continue;
				if(!(steamid in AdminSystem.Vars._CustomResponseOptions[charname]))
					AdminSystem.Vars._CustomResponseOptions[charname][steamid] <- {enabled=true,sequence={}}
			}

			// Add custom sequences
			foreach(seq_name,seqtable in customs)
			{	
				AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[seq_name] <- {scenes=seqtable.scenes,delays=seqtable.delays}
			}
		}
		
	}
	StringToFile(Constants.Directories.CustomResponses, Utils.SceneTableToString(responsetable));
}

/*
 * @authors rhino
 * @param character = character name | all
 * @param sequencename = name for the sequence
 * Rest of the parameters should be given as: ... scene1 delay1 scene2 delay2 ...
 */
::AdminSystem.CreateSequenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local arguments = ::VSLib.EasyLogic.LastArgs;
	local arglen = arguments.len();
	
	if(-1 in arguments)
	{arglen -= 1;}
	else// called from chat
	{
		if(arglen % 2 || arglen<4)
		{
			Messages.ThrowPlayer(player,CmdMessages.CustomSequences.CreateFormat);return;
		}
	}
	
	local contents = FileToString(Constants.Directories.CustomResponses);

	// Somehow response file wasn't created
	if(contents == null)
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.FileMissing(Constants.Directories.CustomResponses));
		return;
	}

	local steamid = player.GetSteamID();
	local responsetable = compilestring( "return " + contents )();

	local character = arguments[0];
	if(character==null)
	{return;}
	character = character.tolower();
	
	if(character != "all" && Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1 )
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	local sequencename = arguments[1];

	if(character == "all")
	{
		foreach(charname in AdminSystem.Vars.CharacterNamesLower)
		{
			if(charname == "" || charname == "survivor")
				continue;

			if(!(charname in responsetable[steamid]))
			{
				responsetable[steamid][charname] <- {};
			}

			if(sequencename in responsetable[steamid][charname])
			{
				Messages.WarnPlayer(player,CmdMessages.CustomSequences.SkipDuplicate(sequencename,charname));continue;
			}
			else
			{
				responsetable[steamid][charname][sequencename] <- {scenes=[],delays=[]}
			}	

			local i = 2
			while(i<arglen)
			{
				responsetable[steamid][charname][sequencename].scenes.append(arguments[i]);
				responsetable[steamid][charname][sequencename].delays.append(arguments[i+1]);
				i+=2;
			}
		}

		Printer(player,CmdMessages.CustomSequences.CreateForAll(sequencename));
	}
	else
	{
		if(!(character in responsetable[steamid]))
		{
			responsetable[steamid][character] <- {};
		}

		if(sequencename in responsetable[steamid][character])
		{
			Messages.ThrowPlayer(player,CmdMessages.CustomSequences.AlreadyExists(sequencename,character));return;
		}
		else
		{
			responsetable[steamid][character][sequencename] <- {scenes=[],delays=[]}
		}	

		local i = 2
		while(i<arglen)
		{
			responsetable[steamid][character][sequencename].scenes.append(arguments[i]);
			responsetable[steamid][character][sequencename].delays.append(arguments[i+1]);
			i+=2;
		}
		
		Printer(player,CmdMessages.CustomSequences.CreateSuccess(character,sequencename));
		
	}

	StringToFile(Constants.Directories.CustomResponses, Utils.SceneTableToString(responsetable));
	AdminSystem.LoadCustomSequences();
}

/*
 * @authors rhino
 */
::AdminSystem.DeleteSequenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local character = GetArgument(1);
	if(character==null)
	{return;}
	character = character.tolower();
	
	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));return;}

	local sequencename = GetArgument(2);
	local contents = FileToString(Constants.Directories.CustomResponses);

	// Somehow response file wasn't created
	if(contents == null)
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.FileMissing(Constants.Directories.CustomResponses));
		return;
	}

	local responsetable = compilestring( "return " + contents )();
	local found = false;
	local steamid = player.GetSteamID();
	
	if(!(character in responsetable[steamid]))
	{Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;}

	if(sequencename in responsetable[steamid][character])
	{	
		Printer(player,CmdMessages.CustomSequences.DeleteSuccess(character,sequencename));
		delete responsetable[steamid][character][sequencename];
		
		if(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence)
			delete AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename];
	}
	else
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,sequencename));return;
	}

	StringToFile(Constants.Directories.CustomResponses, Utils.SceneTableToString(responsetable));
	AdminSystem.LoadCustomSequences();
}

/////////////////////////////////////////////////////////////////
/*
 * @authors rhino
 * @param scene_delay_table = {scenes = [],
 *							   delays = []}
 */
::_SceneSequencer <- function(player,scene_delay_table)
{
	foreach(i,scene in scene_delay_table.scenes)
	{
		player.Speak(scene,scene_delay_table.delays[i]);
	}
}

/*
 * @authors rhino
 * @param optiontable = AdminSystem.Vars._CustomResponseOptions[{EventName}][player.GetCharacterNameLower()]
 */
::_SceneDecider <- function(player,optiontable)
{	
	switch(optiontable.order)
	{
		case SCENES.ORDERED: // ordered
		{	
			local prev_total_delay = 0;
			local scenes = [];

			foreach(seqname,seq in optiontable.sequence)
			{
				_SceneSequencer(player,{scenes=seq.scenes,delays=Utils.ArrayAdd(seq.delays,prev_total_delay)});

				scenes.extend(seq.scenes);

				prev_total_delay += Utils.ArrayMax(seq.delays);
				prev_total_delay += optiontable.mindelay + rand()%optiontable.offsetdelay	// Add delay between each sequence
			}
			optiontable.lastspoken = scenes;
			break;
		}
		case SCENES.SHUFFLED: // shuffled
		{
			local prev_total_delay = 0;
			local scenes = [];
			local picked_seq = {scenes=[],delays=[]};
			
			local seq_copy = Utils.TableCopy(optiontable.sequence);

			// TODO : Find a better way instead of looping twice
			local seq_names = []
			foreach(seqname,seq in optiontable.sequence)
			{
				seq_names.append(seqname);
			}

			foreach(seqname,seq in optiontable.sequence)
			{	
				picked_seq = optiontable.sequence[Utils.GetRandValueFromArray(seq_names,true)];
				_SceneSequencer(player,{scenes=picked_seq.scenes,delays=Utils.ArrayAdd(picked_seq.delays,prev_total_delay)});

				scenes.extend(picked_seq.scenes);

				prev_total_delay += Utils.ArrayMax(picked_seq.delays);
				prev_total_delay += optiontable.mindelay + rand()%optiontable.offsetdelay	// Add delay between each sequence
			}
			optiontable.lastspoken = scenes;
			break;
		}
		case SCENES.RANDOM:	// random pick
		{	
			local seq_names = []
			foreach(seqname,seq in optiontable.sequence)
			{
				seq_names.append(seqname);
			}
			seq_names = Utils.GetRandValueFromArray(seq_names);

			local randseq = optiontable.sequence[seq_names];
			_SceneSequencer(player,randseq);

			optiontable.lastspoken = [seq_names];
			break;
		}
	}
}

::AdminSystem._CurrentlyTradingItems <-
{
	bill=false,
	francis=false,
	louis=false,
	zoey=false,
	nick=false,
	coach=false,
	ellis=false,
	rochelle=false
}

::_TradingStatusWrapper <- function(args)
{
	if(args.player1 != null)
		AdminSystem._CurrentlyTradingItems[args.player1.GetCharacterNameLower()] = false;
	if(args.player2 != null)
		AdminSystem._CurrentlyTradingItems[args.player2.GetCharacterNameLower()] = false;
}

::TradeType <-
{
	DONATION = 0,
	EXCHANGE = 1
}
/////////////////////////////////////////////////////////////////
/*
 * Speak a friendly fire line when shoved with given options in AdminSystem.Vars._CustomResponseOptions
 * Or trade items
 * @authors rhino
 */
function Notifications::OnPlayerShoved::_SpeakWhenShovedCondition(target,attacker,args=null)
{
	local targetname = target.GetCharacterNameLower();
	// Bot was trying to heal with a non-medkit, drop the pack
	if(attacker.IsBot() && !target.IsBot())
	{
		if(!AdminSystem.Vars.AllowCustomSharing)
			return;

		if(AdminSystem._CurrentlyTradingItems[targetname] || AdminSystem._CurrentlyTradingItems[attacker.GetCharacterNameLower()])
			return;

		AdminSystem._CurrentlyTradingItems[targetname] = true;
		AdminSystem._CurrentlyTradingItems[attacker.GetCharacterNameLower()] = true;

		local inHand = attacker.GetActiveWeapon();
		local inhandclass = inHand.GetClassname();
		local sharable_packs = 
		[
			"weapon_defibrillator",
			"weapon_upgradepack_incendiary","weapon_upgradepack_explosive"
		]
		if(Utils.GetIDFromArray(sharable_packs,inhandclass)!=-1)
		{
			AdminSystem.Vars._currentlyBeingTaken[inHand.GetIndex()] <- true;

			if(!("slot3" in target.GetHeldItems()))
			{
				Utils.DropThenGive(attacker,target,3,inHand);
				::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=inHand.GetIndex()});
			}
			else
			{
				attacker.Drop(3);
				::VSLib.Timers.AddTimer(10, false, _ClearBeingTakenStatus,{item=inHand.GetIndex()}); // Newly dropped, disable picking it up for a while
			}
			
		}

		::VSLib.Timers.AddTimer(0.1, false, _TradingStatusWrapper,{player1=target,player2=attacker});
		return;
	}

	local traded = false;
	if(attacker.IsPressingReload())
	{
		if(!target.IsSurvivor())
			return;
			
		if(!AdminSystem.Vars.AllowCustomSharing)
			return;

		if(AdminSystem._CurrentlyTradingItems[targetname] || AdminSystem._CurrentlyTradingItems[attacker.GetCharacterNameLower()])
			return;

		AdminSystem._CurrentlyTradingItems[targetname] = true;
		AdminSystem._CurrentlyTradingItems[attacker.GetCharacterNameLower()] = true;

		local sharable_grenade = 
		[
			"weapon_molotov","weapon_pipe_bomb",
			"weapon_vomitjar",
		]
		local sharable_packs = 
		[
			"weapon_first_aid_kit","weapon_defibrillator",
			"weapon_upgradepack_incendiary","weapon_upgradepack_explosive"
		]

		local inHand = attacker.GetActiveWeapon();
		local inhandclass = inHand.GetClassname();
		local targetinv = target.GetHeldItems();
		local atkinv = attacker.GetHeldItems()

		if(Utils.GetIDFromArray(sharable_grenade,inhandclass)!=-1) // Give grenades
		{
			if(!("slot2" in targetinv))
			{
				AdminSystem.Vars._currentlyBeingTaken[inHand.GetIndex()] <- true;
				Utils.DropThenGive(attacker,target,2,inHand);
				traded = true;
				TradePostTimerSet({typ=TradeType.DONATION,targetname=targetname,itemID=inHand.GetIndex()});
			}
			else if(target.IsBot())
			{
				AdminSystem.Vars._currentlyBeingTaken[atkinv.slot2.GetIndex()] <- true;
				AdminSystem.Vars._currentlyBeingTaken[targetinv.slot2.GetIndex()] <- true;

				Utils.ExchangeItems(attacker,target,2,
				 					atkinv.slot2,
									targetinv.slot2);
				traded = true;
				TradePostTimerSet({typ=TradeType.EXCHANGE,targetname=targetname,targetitem=targetinv.slot2.GetIndex(),atckitem=atkinv.slot2.GetIndex()});
			}
		}
		else if(Utils.GetIDFromArray(sharable_packs,inhandclass)!=-1) // Give packs
		{
			if(!("slot3" in targetinv))
			{
				AdminSystem.Vars._currentlyBeingTaken[inHand.GetIndex()] <- true;
				Utils.DropThenGive(attacker,target,3,inHand);
				traded = true;
				TradePostTimerSet({typ=TradeType.DONATION,targetname=targetname,itemID=inHand.GetIndex()});
			}
			else if(target.IsBot())
			{
				AdminSystem.Vars._currentlyBeingTaken[atkinv.slot3.GetIndex()] <- true;
				AdminSystem.Vars._currentlyBeingTaken[targetinv.slot3.GetIndex()] <- true;

				Utils.ExchangeItems(attacker,target,3,
				 					atkinv.slot3,
									targetinv.slot3);
				traded = true;
				TradePostTimerSet({typ=TradeType.EXCHANGE,targetname=targetname,targetitem=targetinv.slot3.GetIndex(),atckitem=atkinv.slot3.GetIndex()});
			}
		}
		else if(target.IsBot()) // Take grenades and packs from bot
		{
			if("slot2" in targetinv)
			{
				inHand = targetinv.slot2;
				inhandclass = inHand.GetClassname();
				if(!("slot2" in atkinv))
				{
					AdminSystem.Vars._currentlyBeingTaken[inHand.GetIndex()] <- true;
					Utils.DropThenGive(target,attacker,2,inHand);
					traded = true;
					::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=inHand.GetIndex()});
				}
			}
			
			if("slot3" in targetinv)
			{
				inHand = targetinv.slot3;
				inhandclass = inHand.GetClassname();
				if(!("slot3" in atkinv))
				{
					AdminSystem.Vars._currentlyBeingTaken[inHand.GetIndex()] <- true;
					Utils.DropThenGive(target,attacker,3,inHand);
					traded = true;
					::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=inHand.GetIndex()});
				}
			}
		}
		::VSLib.Timers.AddTimer(0.1, false, _TradingStatusWrapper,{player1=target,player2=attacker});
	}

	if(!AdminSystem.Vars.AllowCustomResponses || traded)
		return;

	if(targetname == "") // Was special infected
	{return;}
	
	if(!AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.enabled)
	{return;}

	if((rand().tofloat()/RAND_MAX) <= AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.prob)
		::VSLib.Timers.AddTimer(AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.startdelay, false, _SpeakWhenShovedResult,{targetname=targetname,target=target,attacker=attacker});
	
}

/*
 * @authors rhino
 */
::_SpeakWhenShovedResult <- function(ents)
{
	local targetname = ents.targetname;
	
	// Random line
	if(AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.userandom)
	{
		local line = Utils.GetRandValueFromArray(::Survivorlines.FriendlyFire[targetname]);

		ents.target.Speak(line);
		AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.lastspoken = [line];
		//printl(ents.attacker.GetCharacterName()+" is bullying "+targetname+": "+line);
	}
	else // Speak from given sequences
	{	
		_SceneDecider(ents.target,AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved);
	}
	AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.call_amount += 1;
}

/*
 * @authors rhino
 */
::TradePostTimerSet <- function(args)
{
	switch(args.typ)
	{
		case TradeType.EXCHANGE:
		{
			AdminSystem.BotTemporaryStopState[args.targetname] <- true;

			::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=args.targetitem});
			::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=args.atckitem});
			::VSLib.Timers.AddTimer(AdminSystem.BotParams.HoldNewGivenFor, false, _TemporaryStopStatusWrapper,{bot=args.targetname});
			break;
		}	
		case TradeType.DONATION:
		{
			AdminSystem.BotTemporaryStopState[args.targetname] <- true;
			::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=args.itemID});
			::VSLib.Timers.AddTimer(AdminSystem.BotParams.HoldNewGivenFor, false, _TemporaryStopStatusWrapper,{bot=args.targetname});
			break;
		}
	}
}
/////////////////////////////////////////////////////////////////
/*
 * Sequences to speak for each player upon leaving saferoom with given options in AdminSystem.Vars._CustomResponse
 *
 * @authors rhino
 */
function Notifications::OnLeaveSaferoom::_SpeakWhenLeftSaferoomCondition(ent,args=null)
{
	if(ent.GetName() == "" || !::AdminSystem.Vars.AllowCustomResponses)
		return;
	
	local name = ent.GetCharacterNameLower();
	if(name == "")
		return;
		
	if(!AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.enabled)
		return;	
	
	// Add timer to ignore changes during map loading
	if((rand().tofloat()/RAND_MAX) <= AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.prob && AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.call_amount == 0)
		::VSLib.Timers.AddTimer(AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.startdelay, false, _SpeakWhenLeftSaferoomResult, {player=ent,name=name});
	return;
}

/*
 * @authors rhino
 */
::_SpeakWhenLeftSaferoomResult <- function(ent_table)
{
	if(!::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()]._inSafeRoom && AdminSystem.Vars._CustomResponse[ent_table.name]._SpeakWhenLeftSaferoom.call_amount == 0)
	{	
		_SceneDecider(ent_table.player,AdminSystem.Vars._CustomResponse[ent_table.name]._SpeakWhenLeftSaferoom);
		printl(ent_table.name+" spoken: LeftSafeRoom");
		AdminSystem.Vars._CustomResponse[ent_table.name]._SpeakWhenLeftSaferoom.call_amount += 1;
	}
}

/////////////////////////////////////////////////////////////////
/*
 * Speak an excited line with given options in AdminSystem.Vars._CustomResponse
 *
 * @authors rhino
 */
function Notifications::OnAdrenalineUsed::_SpeakWhenUsedAdrenalineCondition(ent,args=null)
{
	if(!AdminSystem.Vars.AllowCustomResponses)
		return;

	local name = ent.GetCharacterNameLower();
	if((rand().tofloat()/RAND_MAX) <= AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.prob)
		::VSLib.Timers.AddTimer(AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.startdelay, false, _SpeakWhenUsedAdrenalineResult,ent);
}

/*
 * @authors rhino
 */
::_SpeakWhenUsedAdrenalineResult <- function(ent)
{
	local name = ent.GetCharacterNameLower();
	
	if(AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.userandom)
	{
		local scenes = [];
		local delays = [];
		local prev_delay = 0;
		local mindelay = AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.mindelay;
		local offsetdelay = AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.offsetdelay;
		for (local i = 0 ;i < AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.lineamount; i++)
		{
			scenes.append(Utils.GetRandValueFromArray(::Survivorlines.Excited[name]));
			prev_delay += mindelay + rand()%offsetdelay;
			delays.append(prev_delay);
		}
		_SceneSequencer(ent,{scenes=scenes,delays=delays});
		
		AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.lastspoken = scenes
	}
	else
	{
		_SceneDecider(ent,AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline);
	}
	printl(name+" has gone crazy after using an adrenaline shot!");
	AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.call_amount += 1;
}

/*
 * @authors rhino
 */
function Notifications::OnHealStart::_TradeMedPack(target,healer,args)
{
	if(!AdminSystem.Vars.AllowCustomSharing)
		return;
	
	else if(healer.IsPressingReload())
	{
		if(AdminSystem._CurrentlyTradingItems[target.GetCharacterNameLower()] || AdminSystem._CurrentlyTradingItems[healer.GetCharacterNameLower()])
			return;
			
		AdminSystem._CurrentlyTradingItems[target.GetCharacterNameLower()] = true;
		AdminSystem._CurrentlyTradingItems[healer.GetCharacterNameLower()] = true;

		local targetinv = target.GetHeldItems();

		if(!("slot3" in targetinv))
		{
			local item = healer.GetActiveWeapon();
			healer.Drop(3);
			item.Input("Use","",0.1,target);
		}
		else if(target.IsBot())
		{
			Utils.ExchangeItems(target,healer,3,
								target.GetHeldItems().slot3,
								healer.GetHeldItems().slot3);
		}
		::VSLib.Timers.AddTimer(0.2, false, _TradingStatusWrapper,{player1=target,player2=healer});
	}
}

function Notifications::OnHurt::_HitByTankRock(player,attacker,args)
{
	if(!("weapon" in args))
		return;
	if(args.weapon != "tank_rock")
		return;
	else
	{
		if(AdminSystem.Vars._RockThrow.pushenabled)
		{
			if(::VSLib.EasyLogic.Objects.OfClassname("tank_rock").len() != 1)
			{
				//printl("Too many rocks, not pushing")
				return;
			}
			local pushvec = player.GetEyePosition() - AdminSystem.Vars._RockThrow.rockorigin ;
			pushvec = pushvec.Scale( AdminSystem.Vars._RockThrow.rockpushspeed / pushvec.Length());
			
			Timers.AddTimer(0.1,false,_pushPlayer,
			{
				player=player,
				pushvec=pushvec,
				raise=AdminSystem.Vars._RockThrow.raise,
				friction=AdminSystem.Vars._RockThrow.friction
			})	
		}
	}
}

::_pushPlayer <- function(args)
{
	args.player.OverrideFriction(1,args.friction);
	args.player.Push(Vector(0,0,args.raise));
	args.player.Push(args.pushvec);
}

function Notifications::OnAbilityUsed::_TankRockSpawning(player,ability,args)
{
	if(ability != "ability_throw")
		return;
	else
	{
		Timers.AddTimer(2.25,false,_findAndChangeRock,{});
		AdminSystem.Vars._RockThrow.rockorigin = player.GetOrigin()+Vector(0,0,45);
	}
}

::_findAndChangeRock <- function(args)
{
	if(AdminSystem.Vars._RockThrow.randomized)
	{
		foreach( rock in ::VSLib.EasyLogic.Objects.OfClassname("tank_rock") )
		{
			if(rock.GetName().find("_randomized") == null)
			{
				rock.SetName(rock.GetName()+"_randomized");
				rock.SetModel(RandomPick(::ModelPaths.all));
				if(AdminSystem.Vars._RockThrow.randomized_spawn_prop_after)
				{
					Timers.AddTimer(0.1,false,_replaceRock,{rock=rock});
				}
			}
		}
	}
}

::_replaceRock <- function(args)
{
	if(!args.rock.IsEntityValid())
		return;
	if(args.rock.GetClassname() != "tank_rock")
		return;
	local keyvals = 
	{
		classname = "prop_physics_multiplayer",
		model = args.rock.GetModel(),
		origin = args.rock.GetOrigin(),
		angles = args.rock.GetAngles(),
		massscale = 10.0
	};
	local velocity = args.rock.GetVelocity();
	args.rock.Kill();
	local newent = Utils.CreateEntityWithTable(keyvals);

	if(newent==null)
		return

	newent.Push(velocity.Scale(2));
}

::RandomPick <- function(arr)
{
	return Utils.GetRandValueFromArray(arr);
}

/*
 * @authors rhino
 */
/////////////////////custom_sequence/////////////////////////
function ChatTriggers::loop( player, args, text )
{
	AdminSystem.Speak_loopCmd( player, args );
}

function ChatTriggers::loop_stop( player, args, text )
{
	AdminSystem.Speak_loop_stopCmd( player, args );
}

function ChatTriggers::speak_test( player, args, text )
{
	AdminSystem.Speak_testCmd( player, args );
}

function ChatTriggers::speak_custom( player, args, text )
{
	AdminSystem.Speak_customCmd( player, args );
}

function ChatTriggers::show_custom_sequences( player, args, text )
{
	AdminSystem.Show_custom_sequencesCmd( player, args );
}

function ChatTriggers::seq_info( player, args, text )
{
	AdminSystem.Sequence_infoCmd( player, args );
}

function ChatTriggers::seq_edit( player, args, text )
{
	AdminSystem.Sequence_editCmd( player, args );
}

function ChatTriggers::create_seq( player, args, text )
{
	AdminSystem.CreateSequenceCmd( player, args );
}

function ChatTriggers::delete_seq( player, args, text )
{
	AdminSystem.DeleteSequenceCmd( player, args );
}

/*
 * @authors rhino
 */
//////////////////////meteor_shower_event////////////////////////////

function ChatTriggers::start_the_shower( player, args, text )
{
	AdminSystem.Start_the_showerCmd( player, args );
}

function ChatTriggers::pause_the_shower( player, args, text )
{
	AdminSystem.Pause_the_showerCmd( player, args );
}

function ChatTriggers::show_meteor_shower_settings( player, args, text )
{
	AdminSystem.Show_meteor_shower_settingsCmd( player, args );
}

function ChatTriggers::meteor_shower_setting( player, args, text )
{
	AdminSystem.Meteor_shower_settingCmd( player, args );
}

function ChatTriggers::meteor_shower_debug( player, args, text )
{
	AdminSystem.Meteor_shower_debugCmd( player, args );
}

/*
 * @authors rhino
 */
//////////////////////apocalypse_event////////////////////////////

function ChatTriggers::start_the_apocalypse( player, args, text )
{
	AdminSystem.Start_the_apocalypseCmd( player, args );
}

function ChatTriggers::pause_the_apocalypse( player, args, text )
{
	AdminSystem.Pause_the_apocalypseCmd( player, args );
}

function ChatTriggers::apocalypse_debug( player, args, text )
{
	AdminSystem.Apocalypse_debugCmd( player, args );
}

function ChatTriggers::show_apocalypse_settings( player, args, text )
{
	AdminSystem.Show_apocalypse_settingsCmd( player, args );
}

function ChatTriggers::apocalypse_setting( player, args, text )
{
	AdminSystem.Apocalypse_settingCmd( player, args );
}

/*
 * @authors rhino
 */
///////////////////////script_related//////////////////////////////

function ChatTriggers::update_print_output_state(player,args,text)
{
	AdminSystem.Update_print_output_stateCmd(player, args);
}

function ChatTriggers::attach_to_targeted_position(player,args,text)
{
	AdminSystem.Attach_to_targeted_positionCmd(player, args);
}

function ChatTriggers::randomparticle_save_state(player,args,text)
{
	AdminSystem.Randomparticle_save_stateCmd(player, args);
}

function ChatTriggers::update_attachment_preference(player,args,text)
{
	AdminSystem.Update_attachment_preferenceCmd(player, args);
}

function ChatTriggers::display_saved_particle(player,args,text)
{
	AdminSystem.Display_saved_particleCmd(player, args);
}

function ChatTriggers::admin_var( player, args, text )
{
	AdminSystem.Admin_varCmd( player, args );
}

function ChatTriggers::add_script_auth( player, args, text )
{
	AdminSystem.AddScriptAuthCmd( player, args );
}

function ChatTriggers::remove_script_auth( player, args, text )
{
	AdminSystem.RemoveScriptAuthCmd( player, args );
}

function ChatTriggers::server_exec(player,args,text)
{
	AdminSystem.Server_execCmd(player, args);
}

function ChatTriggers::script( player, args, text )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	if(!(player.GetSteamID() in ::AdminSystem.ScriptAuths))
	{
		Messages.ThrowAll(Messages.BIM.HasScriptAuth.NoAccess(player));return;
	}
	local compiledscript = compilestring(Utils.CombineArray(args));
	compiledscript();
}

function ChatTriggers::setkeyval(player,args,text)
{
	AdminSystem.SetkeyvalCmd(player, args);
}

function ChatTriggers::update_svcheats(player,args,text)
{
	AdminSystem.Update_svcheatsCmd(player, args);
}

function ChatTriggers::update_prop_spawn_setting(player,args,text)
{
	AdminSystem.Update_prop_spawn_settingCmd(player, args);
}

function ChatTriggers::update_prop_spawn_menu_type(player,args,text)
{
	AdminSystem.Update_prop_spawn_menu_typeCmd(player, args);
}

function ChatTriggers::display_prop_spawn_settings(player,args,text)
{
	AdminSystem.Display_prop_spawn_settingsCmd(player, args);
}

function ChatTriggers::update_custom_response_preference(player,args,text)
{
	AdminSystem.Update_custom_response_preferenceCmd(player, args);
}

function ChatTriggers::update_custom_sharing_preference(player,args,text)
{
	AdminSystem.Update_custom_sharing_preferenceCmd(player, args);
}

function ChatTriggers::explosion( player, args, text )
{
	AdminSystem._AimedExplosionCmd( player, args );
}

function ChatTriggers::show_explosion_settings( player, args, text )
{
	AdminSystem.Show_explosion_settingsCmd( player, args );
}

function ChatTriggers::explosion_setting( player, args, text )
{
	AdminSystem.Explosion_settingCmd( player, args );
}

function ChatTriggers::update_jockey_preference( player, args, text )
{
	AdminSystem.UpdateJockeyPreferenceCmd( player, args );
}

function ChatTriggers::update_tank_rock_launch_preference( player, args, text )
{
	AdminSystem.UpdateTankRockPreferenceCmd( player, args );
}

function ChatTriggers::update_tank_rock_random_preference( player, args, text )
{
	AdminSystem.UpdateTankRockRandomPreferenceCmd( player, args );
}

function ChatTriggers::update_tank_rock_respawn_preference( player, args, text )
{
	AdminSystem.UpdateTankRockSpawnAfterPreferenceCmd( player, args );
}

function ChatTriggers::update_model_preference( player, args, text )
{
	AdminSystem.UpdateModelPreferenceCmd( player, args );
}

function ChatTriggers::restore_model( player, args, text )
{
	AdminSystem.RestoreModelCmd( player, args );
}

function ChatTriggers::random_model( player, args, text )
{
	AdminSystem.RandomModelCmd( player, args );
}

function ChatTriggers::create_listener( player, args, text )
{
	AdminSystem._CreateKeyListenerCmd( player, args );
}

function ChatTriggers::stop_listener( player, args, text )
{
	AdminSystem._StopKeyListenerCmd( player, args );
}

function ChatTriggers::drive( player, args, text )
{
	AdminSystem.DriveCmd( player, args );
}

function ChatTriggers::kind_bots( player, args, text )
{
	AdminSystem._EnableKindnessCmd( player, args );
}

function ChatTriggers::selfish_bots( player, args, text )
{
	AdminSystem._DisableKindnessCmd( player, args );
}

function ChatTriggers::update_bots_sharing_preference( player, args, text )
{
	AdminSystem.Update_bots_sharing_preferenceCmd( player, args );
}

/*
 * @authors rhino
 */
////////////////////piano_and_mic_stuff/////////////////////////

function ChatTriggers::piano_keys( player, args, text )
{
	AdminSystem.Piano_keysCmd( player, args );
}

function ChatTriggers::remove_piano_keys( player, args, text )
{
	AdminSystem.Remove_piano_keysCmd( player, args );
}

function ChatTriggers::display_mics_speakers( player, args, text )
{
	AdminSystem.Display_mics_speakersCmd( player, args );
}

function ChatTriggers::speaker2mic( player, args, text )
{
	AdminSystem.Speaker2micCmd( player, args );
}

function ChatTriggers::speaker( player, args, text )
{
	AdminSystem.SpeakerCmd( player, args );
}

function ChatTriggers::microphone( player, args, text )
{
	AdminSystem.MicrophoneCmd( player, args );
}

/*
 * @authors rhino
 */
////////////////////////vocal_stuff//////////////////////////////

function ChatTriggers::randomline(player,args,text)
{
	AdminSystem.RandomlineCmd(player, args);
}

function ChatTriggers::randomline_save_last(player,args,text)
{
	AdminSystem.Randomline_save_lastCmd(player, args);
}

function ChatTriggers::speak_saved(player,args,text)
{
	AdminSystem.Speak_savedCmd(player, args);
}

function ChatTriggers::display_saved_line(player,args,text)
{
	AdminSystem.Display_saved_lineCmd(player, args);
}

function ChatTriggers::save_line(player,args,text)
{
	AdminSystem.Save_lineCmd(player, args);
}

function ChatTriggers::save_particle(player,args,text)
{
	AdminSystem.Save_particleCmd(player, args);
}

/*
 * @authors rhino
 */
////////////////////////entity_stuff/////////////////////////////

function ChatTriggers::ent( player, args, text )
{
	AdminSystem.EntityWithTableCmd( player, args );
}

function ChatTriggers::entcvar( player, args, text )
{
	AdminSystem.EntCvarCmd( player, args );
}

function ChatTriggers::ent_rotate( player, args, text )
{
	AdminSystem.EntRotateCmd( player, args );
}

function ChatTriggers::ladder_team( player, args, text )
{
	AdminSystem.Ladder_teamCmd( player, args );
}

function ChatTriggers::invisible_walls( player, args, text )
{
	AdminSystem.BlockerStateCmd( player, args );
}

function ChatTriggers::ent_push( player, args, text )
{
	AdminSystem.EntPushCmd( player, args );
}

function ChatTriggers::ent_move( player, args, text )
{
	AdminSystem.EntMoveCmd( player, args );
}

function ChatTriggers::ent_spin( player, args, text )
{
	AdminSystem.EntSpinCmd( player, args );
}

function ChatTriggers::ent_teleport( player, args, text )
{
	AdminSystem.EntTeleportCmd( player, args );
}

function ChatTriggers::rainbow(player,args,text)
{
	AdminSystem.RainbowCmd(player, args);
}

function ChatTriggers::color(player,args,text)
{
	AdminSystem.ColorCmd(player, args);
}

function ChatTriggers::model(player,args,text)
{
	AdminSystem.ModelCmd(player, args);
}

function ChatTriggers::model_scale(player,args,text)
{
	AdminSystem.ModelScaleCmd(player, args);
}

function ChatTriggers::disguise(player,args,text)
{
	AdminSystem.DisguiseCmd(player, args);
}

function ChatTriggers::attach_particle(player,args,text)
{
	AdminSystem.Attach_particleCmd(player, args);
}

function ChatTriggers::spawn_particle_saved(player,args,text)
{
	AdminSystem.Spawn_particle_savedCmd(player, args);
}

function ChatTriggers::attach_particle_saved(player,args,text)
{
	AdminSystem.Attach_particle_savedCmd(player, args);
}

function ChatTriggers::hat_position(player,args,text)
{
	AdminSystem._HatPosition(player, args);
}
function ChatTriggers::update_aimed_ent_direction(player,args,text)
{
	AdminSystem.UpdateAimedEntityDirection(player, args);
}
function ChatTriggers::take_off_hat(player,args,text)
{
	AdminSystem._TakeOffHatCmd(player, args);
}
function ChatTriggers::wear_hat(player,args,text)
{
	AdminSystem._WearHatCmd(player, args);
}

function ChatTriggers::grab(player,args,text)
{
	AdminSystem.GrabCmd(player, args);
}
function ChatTriggers::letgo(player,args,text)
{
	AdminSystem.LetgoCmd(player, args);
}
function ChatTriggers::yeet(player,args,text)
{
	AdminSystem.YeetCmd(player, args);
}
function ChatTriggers::show_yeet_settings(player,args,text)
{
	AdminSystem.ShowYeetSettingsCmd(player, args);
}
function ChatTriggers::yeet_setting(player,args,text)
{
	AdminSystem.YeetSettingCmd(player, args);
}
function ChatTriggers::change_grab_method(player,args,text)
{
	AdminSystem.GrabMethodCmd(player, args);
}
function ChatTriggers::stop_car_alarms( player, args, text )
{
	AdminSystem.StopCarAlarmsCmd( player, args );
}

function ChatTriggers::debug_info(player,args,text)
{
	AdminSystem.Debug_infoCmd(player, args);
}

function ChatTriggers::stop_time( player, args, text )
{
	AdminSystem.StopTimeCmd( player, args );
}
function ChatTriggers::resume_time( player, args, text )
{
	AdminSystem.ResumeTimeCmd( player, args );
}

function ChatTriggers::ents_around( player, args, text )
{
	AdminSystem.EntitiesAroundCmd( player, args );
}
function ChatTriggers::wnet( player, args, text )
{
	AdminSystem.WatchNetPropCmd( player, args );
}
function ChatTriggers::stop_wnet( player, args, text )
{
	AdminSystem.StopWatchNetPropCmd( player, args );
}

function ChatTriggers::fire_ex( player, args, text )
{
	AdminSystem.FireExtinguisherCmd( player, args );
}
function ChatTriggers::fire_extinguisher( player, args, text )
{
	AdminSystem.FireExtinguisherCmd( player, args );
}
/////////////////////////others/////////////////////////////

function ChatTriggers::adminmode( player, args, text )
{
	AdminSystem.AdminModeCmd( player, args );
}

function ChatTriggers::add_admin( player, args, text )
{
	AdminSystem.AddAdminCmd( player, args );
}

function ChatTriggers::remove_admin( player, args, text )
{
	AdminSystem.RemoveAdminCmd( player, args );
}

function ChatTriggers::kick( player, args, text )
{
	AdminSystem.KickCmd( player, args );
}

function ChatTriggers::ban( player, args, text )
{
	AdminSystem.BanCmd( player, args );
}

function ChatTriggers::god( player, args, text )
{
	AdminSystem.GodCmd( player, args );
}

function ChatTriggers::bash( player, args, text )
{
	AdminSystem.BashCmd( player, args );
}

function ChatTriggers::freeze( player, args, text )
{
	AdminSystem.FreezeCmd( player, args );
}

function ChatTriggers::noclip( player, args, text )
{
	AdminSystem.NoclipCmd( player, args );
}

function ChatTriggers::speed( player, args, text )
{
	AdminSystem.SpeedCmd( player, args );
}

function ChatTriggers::fly( player, args, text )
{
	AdminSystem.FlyCmd( player, args );
}

function ChatTriggers::infinite_ammo( player, args, text )
{
	AdminSystem.InfiniteAmmoCmd( player, args );
}

function ChatTriggers::unlimited_ammo( player, args, text )
{
	AdminSystem.UnlimitedAmmoCmd( player, args );
}

function ChatTriggers::infinite_upgrade( player, args, text )
{
	AdminSystem.InfiniteUpgradeCmd( player, args );
}

function ChatTriggers::cleanup( player, args, text )
{
	AdminSystem.CleanupCmd( player, args );
}

function ChatTriggers::adrenaline( player, args, text )
{
	AdminSystem.AdrenalineCmd( player, args );
}

function ChatTriggers::move( player, args, text )
{
	AdminSystem.MoveCmd( player, args );
}

function ChatTriggers::chase( player, args, text )
{
	AdminSystem.ChaseCmd( player, args );
}

function ChatTriggers::health( player, args, text )
{
	AdminSystem.HealthCmd( player, args );
}

function ChatTriggers::max_health( player, args, text )
{
	AdminSystem.MaxHealthCmd( player, args );
}

function ChatTriggers::melee( player, args, text )
{
	AdminSystem.MeleeCmd( player, args );
}

function ChatTriggers::particle( player, args, text )
{
	AdminSystem.ParticleCmd( player, args );
}

function ChatTriggers::barrel( player, args, text )
{
	AdminSystem.BarrelCmd( player, args );
}

function ChatTriggers::gascan( player, args, text )
{
	AdminSystem.GascanCmd( player, args );
}

function ChatTriggers::propanetank( player, args, text )
{
	AdminSystem.PropaneTankCmd( player, args );
}

function ChatTriggers::oxygentank( player, args, text )
{
	AdminSystem.OxygenTankCmd( player, args );
}

function ChatTriggers::fireworkcrate( player, args, text )
{
	AdminSystem.FireworkCrateCmd( player, args );
}

function ChatTriggers::minigun( player, args, text )
{
	AdminSystem.MinigunCmd( player, args );
}

function ChatTriggers::weapon( player, args, text )
{
	AdminSystem.WeaponCmd( player, args );
}

function ChatTriggers::spawn_ammo( player, args, text )
{
	AdminSystem.SpawnAmmoCmd( player, args );
}

function ChatTriggers::dummy( player, args, text )
{
	AdminSystem.DummyCmd( player, args );
}

function ChatTriggers::entity( player, args, text )
{
	AdminSystem.EntityCmd( player, args );
}

function ChatTriggers::prop( player, args, text )
{
	AdminSystem.PropCmd( player, args );
}

function ChatTriggers::door( player, args, text )
{
	AdminSystem.DoorCmd( player, args );
}

function ChatTriggers::survivor( player, args, text )
{
	AdminSystem.SurvivorCmd( player, args );
}

function ChatTriggers::l4d1_survivor( player, args, text )
{
	AdminSystem.L4D1SurvivorCmd( player, args );
}

function ChatTriggers::client( player, args, text )
{
	AdminSystem.ClientCmd( player, args );
}

function ChatTriggers::console( player, args, text )
{
	AdminSystem.ConsoleCmd( player, args );
}

function ChatTriggers::cvar( player, args, text )
{
	AdminSystem.CvarCmd( player, args );
}

function ChatTriggers::ent_fire( player, args, text )
{
	AdminSystem.EntFireCmd( player, args );
}

function ChatTriggers::timescale( player, args, text )
{
	AdminSystem.TimescaleCmd( player, args );
}

function ChatTriggers::sound( player, args, text )
{
	AdminSystem.SoundCmd( player, args );
}

function ChatTriggers::give( player, args, text )
{
	AdminSystem.GiveCmd( player, args );
}

function ChatTriggers::remove( player, args, text )
{
	AdminSystem.RemoveCmd( player, args );
}

function ChatTriggers::drop( player, args, text )
{
	AdminSystem.DropCmd( player, args );
}

function ChatTriggers::use( player, args, text )
{
	AdminSystem.UseCmd( player, args );
}

function ChatTriggers::speak( player, args, text )
{
	AdminSystem.SpeakCmd( player, args );
}

function ChatTriggers::revivecount( player, args, text )
{
	AdminSystem.ReviveCountCmd( player, args );
}

function ChatTriggers::revive( player, args, text )
{
	AdminSystem.ReviveCmd( player, args );
}

function ChatTriggers::defib( player, args, text )
{
	AdminSystem.DefibCmd( player, args );
}

function ChatTriggers::rescue( player, args, text )
{
	AdminSystem.RescueCmd( player, args );
}

function ChatTriggers::incap( player, args, text )
{
	AdminSystem.IncapCmd( player, args );
}

function ChatTriggers::kill( player, args, text )
{
	AdminSystem.KillCmd( player, args );
}

function ChatTriggers::hurt( player, args, text )
{
	AdminSystem.HurtCmd( player, args );
}

function ChatTriggers::respawn( player, args, text )
{
	AdminSystem.RespawnCmd( player, args );
}

function ChatTriggers::extinguish( player, args, text )
{
	AdminSystem.ExtinguishCmd( player, args );
}

function ChatTriggers::ignite( player, args, text )
{
	AdminSystem.IgniteCmd( player, args );
}

function ChatTriggers::vomit( player, args, text )
{
	AdminSystem.VomitCmd( player, args );
}

function ChatTriggers::stagger( player, args, text )
{
	AdminSystem.StaggerCmd( player, args );
}

function ChatTriggers::warp( player, args, text )
{
	AdminSystem.WarpCmd( player, args );
}

function ChatTriggers::warp_here( player, args, text )
{
	AdminSystem.WarpHereCmd( player, args );
}

function ChatTriggers::warp_saferoom( player, args, text )
{
	AdminSystem.WarpSaferoomCmd( player, args );
}

function ChatTriggers::ammo( player, args, text )
{
	AdminSystem.AmmoCmd( player, args );
}

function ChatTriggers::upgrade_add( player, args, text )
{
	AdminSystem.UpgradeAddCmd( player, args );
}

function ChatTriggers::upgrade_remove( player, args, text )
{
	AdminSystem.UpgradeRemoveCmd( player, args );
}

function ChatTriggers::netprop( player, args, text )
{
	AdminSystem.NetPropCmd( player, args );
}

function ChatTriggers::friction( player, args, text )
{
	AdminSystem.FrictionCmd( player, args );
}

function ChatTriggers::gravity( player, args, text )
{
	AdminSystem.GravityCmd( player, args );
}

function ChatTriggers::velocity( player, args, text )
{
	AdminSystem.VelocityCmd( player, args );
}

function ChatTriggers::drop_fire( player, args, text )
{
	AdminSystem.DropFireCmd( player, args );
}

function ChatTriggers::drop_spit( player, args, text )
{
	AdminSystem.DropSpitCmd( player, args );
}

function ChatTriggers::director( player, args, text )
{
	AdminSystem.DirectorCmd( player, args );
}

function ChatTriggers::finale( player, args, text )
{
	AdminSystem.FinaleCmd( player, args );
}

function ChatTriggers::restart( player, args, text )
{
	AdminSystem.RestartCmd( player, args );
}

function ChatTriggers::limit( player, args, text )
{
	AdminSystem.LimitCmd( player, args );
}

function ChatTriggers::zombie( player, args, text )
{
	AdminSystem.ZombieCmd( player, args );
}

function ChatTriggers::z_spawn( player, args, text )
{
	AdminSystem.ZSpawnCmd( player, args );
}

function ChatTriggers::exec( player, args, text )
{
	AdminSystem.ExecCmd( player, args );
}

function ChatTriggers::endgame( player, args, text )
{
	AdminSystem.EndGameCmd( player, args );
}

function ChatTriggers::alarmcar( player, args, text )
{
	AdminSystem.AlarmCarCmd( player, args );
}

function ChatTriggers::gun( player, args, text )
{
	AdminSystem.GunCmd( player, args );
}

if ( Director.GetGameMode() == "holdout" )
{
	function ChatTriggers::resource( player, args, text )
	{
		AdminSystem.ResourceCmd( player, args );
	}
}

::AdminSystem.AdminModeCmd <- function ( player, args )
{
	local AdminsOnly = GetArgument(1);

	if (!AdminSystem.IsAdmin( player ))
		return;
	
	if ( !AdminSystem.Vars.AllowAdminsOnly && (AdminsOnly == "enable" || AdminsOnly == "true" || AdminsOnly == "on") )
	{
		AdminSystem.Vars.AllowAdminsOnly = true;
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.AdminMode.Enabled();
	}
	else if ( AdminSystem.Vars.AllowAdminsOnly && (AdminsOnly == "disable" || AdminsOnly == "false" || AdminsOnly == "off") )
	{
		AdminSystem.Vars.AllowAdminsOnly = false;
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.AdminMode.Disabled();
	}
}

/*
 * @authors rhino
 */
::AdminSystem.AddScriptAuthCmd <- function ( player, args )
{	
	if(!(player.GetSteamID() in ::AdminSystem.HostPlayer))
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.ScriptAuth.HostOnly();
		return;
	}

	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if ( !Target )
		return;

	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local authList = FileToString(Constants.Directories.ScriptAuths);
	if ( authList != null )
	{
		if (!AdminSystem.HasScriptAuth( player ))
			return;
	}
	
	local auths = FileToString(Constants.Directories.ScriptAuths);
	local steamid = Target.GetSteamID();
	if ( steamid == "BOT" )
		return;
	if ( (steamid in ::AdminSystem.ScriptAuths) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.ScriptAuth.AlreadyAuthed(Target.GetName());
		return;
	}
	if ( auths == null )
		auths = steamid + " //" + Target.GetName();
	else
		auths += "\r\n" + steamid + " //" + Target.GetName();
	if ( AdminSystem.DisplayMsgs )
		Messages.BIM.ScriptAuth.Given(Target.GetName());

	StringToFile(Constants.Directories.ScriptAuths, auths);
	AdminSystem.LoadScriptAuths();
}

/*
 * @authors rhino
 */
::AdminSystem.RemoveScriptAuthCmd <- function ( player, args )
{
	if(!(player.GetSteamID() in ::AdminSystem.HostPlayer))
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.ScriptAuth.HostOnly();
		return;
	}

	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if (!Target || !AdminSystem.HasScriptAuth( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local auths = FileToString(Constants.Directories.ScriptAuths);
	local steamid = Target.GetSteamID();

	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
		return;
	
	if ( !(steamid in ::AdminSystem.ScriptAuths))
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.ScriptAuth.AlreadyNone(Target.GetName());
		return;
	}

	if ( auths == null )
		return;

	auths = Utils.StringReplace(auths, steamid, "");
	::AdminSystem.ScriptAuths = {};
	if ( AdminSystem.DisplayMsgs )
		Messages.BIM.ScriptAuth.Taken(Target.GetName());
	StringToFile(Constants.Directories.ScriptAuths, auths);
	AdminSystem.LoadScriptAuths();	
}

::AdminSystem.AddAdminCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if ( !Target )
		return;

	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local adminList = FileToString(Constants.Directories.Admins);
	if ( adminList != null )
	{
		if (!AdminSystem.IsAdmin( player ))
			return;
	}
	
	local admins = FileToString(Constants.Directories.Admins);
	local steamid = Target.GetSteamID();
	if ( steamid == "BOT" )
		return;
	if ( (steamid in ::AdminSystem.Admins) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.Admin.AlreadyAdmin(Target.GetName());
		return;
	}
	if ( admins == null )
		admins = steamid + " //" + Target.GetName();
	else
		admins += "\r\n" + steamid + " //" + Target.GetName();
	if ( AdminSystem.DisplayMsgs )
			Messages.BIM.Admin.Add(Target.GetName());
	StringToFile(Constants.Directories.Admins, admins);
	AdminSystem.LoadAdmins();
	AdminSystem.LoadCustomSequences();
}

::AdminSystem.RemoveAdminCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if (!Target || !AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local admins = FileToString(Constants.Directories.Admins);
	local steamid = Target.GetSteamID();

	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.Admin.HostOnlyRemoval();
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( admins == null )
		return;
	admins = Utils.StringReplace(admins, steamid, "");
	::AdminSystem.Admins = {};
	if ( AdminSystem.DisplayMsgs )
		Messages.BIM.Admin.Remove(Target.GetName());
	StringToFile(Constants.Directories.Admins, admins);
	AdminSystem.LoadAdmins();
}

::AdminSystem.KickCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Reason = GetArgument(2);
	
	if (!Target || !AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local steamid = Target.GetSteamID();
	
	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.KickPlayer.NoAdminKick();
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( Reason && steamid != "BOT" )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.KickPlayer.ChatKickedMessageReasoned(Target.GetName(), player.GetName(), Reason);
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.KickPlayer.ChatKickedMessage(Target.GetName(), player.GetName());
		if ( steamid == "BOT" )
			SendToServerConsole( "kick " + Target.GetName() );
		else
			SendToServerConsole( "kickid " + steamid );
	}
}

::AdminSystem.BanCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Reason = GetArgument(2);
	local BanPlayer = null;

	if (!AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local bannedPlayers = FileToString(Constants.Directories.Banned);
	local steamid = Target.GetSteamID();
	
	if ( !steamid || steamid == "BOT" )
		return;
	
	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.BanPlayer.NoAdminBan();
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( bannedPlayers == null )
		bannedPlayers = steamid + " //" + Target.GetName();
	else
		bannedPlayers += "\r\n" + steamid + " //" + Target.GetName();
	
	StringToFile(Constants.Directories.Banned, bannedPlayers);
	if ( Reason )
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.BanPlayer.ChatBannedMessageReasoned(Target.GetName(), player.GetName(),Reason);
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.BanPlayer.ChatBannedMessage(Target.GetName(), player.GetName());
		SendToServerConsole( "kickid " + steamid );
	}
	AdminSystem.LoadBanned();
}

::AdminSystem.GodCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[survivorID] )
				{
					AdminSystem.Vars.IsGodEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("God mode has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsGodEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("God mode has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Type == "infected" )
		{
			if ( AdminSystem.Vars.EnabledGodInfected )
			{
				AdminSystem.Vars.EnabledGodInfected = false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode disabled for Infected.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodInfected = true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode enabled for Infected.");
			}
		}
		else if ( Type == "si" )
		{
			if ( AdminSystem.Vars.EnabledGodSI )
			{
				AdminSystem.Vars.EnabledGodSI = false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode disabled for SI.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodSI = true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode enabled for SI.");
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[targetID] )
			{
				AdminSystem.Vars.IsGodEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsGodEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("God mode has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled god mode.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled god mode.", player.GetName());
		}
	}
}

::AdminSystem.BashCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "enable" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashDisabled[survivorID] <- false;
					AdminSystem.Vars.IsBashLimited[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Bash has been enabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashDisabled[targetID] <- false;
				AdminSystem.Vars.IsBashLimited[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Bash has been enabled on %s.", Target.GetName());
			}
		}
		else if ( Type == "disable" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashLimited[survivorID] <- false;
					AdminSystem.Vars.IsBashDisabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Bash has been disabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashLimited[targetID] <- false;
				AdminSystem.Vars.IsBashDisabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Bash has been disabled on %s.", Target.GetName());
			}
		}
		else if ( Type == "pushonly" || Type == "limit" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashDisabled[survivorID] <- false;
					AdminSystem.Vars.IsBashLimited[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Bash has been limited on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashDisabled[targetID] <- false;
				AdminSystem.Vars.IsBashLimited[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Bash has been limited on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( Survivor == "enable" )
		{
			AdminSystem.Vars.IsBashDisabled[ID] <- false;
			AdminSystem.Vars.IsBashLimited[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("Bash has been enabled on %s.", player.GetName());
		}
		else if ( Survivor == "disable" )
		{
			AdminSystem.Vars.IsBashLimited[ID] <- false;
			AdminSystem.Vars.IsBashDisabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("Bash has been disabled on %s.", player.GetName());
		}
		else if ( Survivor == "pushonly" || Survivor == "limit" )
		{
			AdminSystem.Vars.IsBashDisabled[ID] <- false;
			AdminSystem.Vars.IsBashLimited[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("Bash has been limited on %s.", player.GetName());
		}
	}
}

::AdminSystem.FreezeCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[survivorID] )
				{
					survivor.RemoveFlag(FL_FROZEN);
					AdminSystem.Vars.IsFreezeEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("%s has been thawed.", survivor.GetName());
				}
				else
				{
					survivor.AddFlag(FL_FROZEN);
					AdminSystem.Vars.IsFreezeEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("%s has been frozen.", survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[targetID] )
			{
				Target.RemoveFlag(FL_FROZEN);
				AdminSystem.Vars.IsFreezeEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("%s has been thawed.", Target.GetName());
			}
			else
			{
				Target.AddFlag(FL_FROZEN);
				AdminSystem.Vars.IsFreezeEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("%s has been frozen.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[ID] )
		{
			player.RemoveFlag(FL_FROZEN);
			AdminSystem.Vars.IsFreezeEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has been thawed.", player.GetName());
		}
		else
		{
			player.AddFlag(FL_FROZEN);
			AdminSystem.Vars.IsFreezeEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has been frozen.", player.GetName());
		}
	}
}

::AdminSystem.NoclipCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[survivorID] )
				{
					survivor.SetNetProp("movetype", 2);
					AdminSystem.Vars.IsNoclipEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Noclip has been disabled on %s.", survivor.GetName());
				}
				else
				{
					survivor.SetNetProp("movetype", 8);
					AdminSystem.Vars.IsNoclipEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Noclip has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[targetID] )
			{
				Target.SetNetProp("movetype", 2);
				AdminSystem.Vars.IsNoclipEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Noclip has been disabled on %s.", Target.GetName());
			}
			else
			{
				Target.SetNetProp("movetype", 8);
				AdminSystem.Vars.IsNoclipEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Noclip has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[ID] )
		{
			player.SetNetProp("movetype", 2);
			AdminSystem.Vars.IsNoclipEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled Noclip.", player.GetName());
		}
		else
		{
			player.SetNetProp("movetype", 8);
			AdminSystem.Vars.IsNoclipEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled Noclip.", player.GetName());
		}
	}
}

::AdminSystem.SpeedCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Value = GetArgument(2);
	local LookingPlayer = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Value )
		Value = Value.tofloat();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingPlayer != null && LookingPlayer.GetClassname() == "player" )
			LookingPlayer.SetNetProp("m_flLaggedMovementValue", Value);
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else
		{
			if ( Value )
			{
				if ( !Target )
					return;
				
				Target.SetNetProp("m_flLaggedMovementValue", Value);
			}
			else
				player.SetNetProp("m_flLaggedMovementValue", Survivor.tofloat());
		}
	}
}

::AdminSystem.FlyCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[survivorID] )
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- false;
					Timers.RemoveTimerByName ( survivorID.tostring() + "Fly" );
					survivor.Input( "IgnoreFallDamageWithoutReset", 0.1 );
					survivor.Input( "EnableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Flying mode has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- true;
					Timers.AddTimerByName( survivorID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, survivor );
					survivor.Input( "IgnoreFallDamageWithoutReset", 999999 );
					survivor.Input( "DisableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Flying mode has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[targetID] )
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- false;
				Timers.RemoveTimerByName ( targetID.tostring() + "Fly" );
				Target.Input( "IgnoreFallDamageWithoutReset", 0.1 );
				Target.Input( "EnableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Flying mode has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- true;
				Timers.AddTimerByName( targetID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, Target );
				Target.Input( "IgnoreFallDamageWithoutReset", 999999 );
				Target.Input( "DisableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Flying mode has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[ID] )
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- false;
			Timers.RemoveTimerByName ( ID.tostring() + "Fly" );
			player.Input( "IgnoreFallDamageWithoutReset", 0.1 );
			player.Input( "EnableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled flying mode.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- true;
			Timers.AddTimerByName( ID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, player );
			player.Input( "IgnoreFallDamageWithoutReset", 999999 );
			player.Input( "DisableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled flying mode.", player.GetName());
		}
	}
}

::AdminSystem.InfiniteAmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] )
			{
				AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite ammo has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite ammo has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled infinite ammo.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled infinite ammo.", player.GetName());
		}
	}
}

::AdminSystem.UnlimitedAmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] )
			{
				AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Unlimited ammo has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Unlimited ammo has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled unlimited ammo.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled unlimited ammo.", player.GetName());
		}
	}
}

::AdminSystem.InfiniteUpgradeCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "incendiary_ammo" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite incendiary ammo has been enabled on %s.", Target.GetName());
			}
		}
		else if ( Type == "explosive_ammo" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite explosive ammo has been enabled on %s.", Target.GetName());
			}
		}
		else if ( Type == "laser_sight" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteLaserSightsEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_LASER_SIGHT );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite laser sights has been enabled on %s.", Target.GetName());
			}
		}
		else if ( Type == "stop" || Type == "off" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteLaserSightsEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Infinite upgrade ammo has been disabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( Survivor == "incendiary_ammo" )
		{
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled infinite incendiary ammo.", player.GetName());
		}
		else if ( Survivor == "explosive_ammo" )
		{
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled infinite explosive ammo.", player.GetName());
		}
		else if ( Survivor == "laser_sight" )
		{
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_LASER_SIGHT );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has enabled infinite laser sights.", player.GetName());
		}
		else if ( Survivor == "stop" || Survivor == "off" )
		{
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled infinite upgrade ammo.", player.GetName());
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.StopCarAlarmsCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local objects = ::VSLib.EasyLogic.Objects.OfClassname("ambient_generic");
	if(objects != null)
	{
		local found = false;
		foreach(obj in objects)
		{	
			if(obj.GetName().find("caralarm") != null)
			{
				found = true;
				obj.Input("stopsound");
			}
		}

		if(found)
		{
			Printer(player,"Stopped all car alarms");
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.CleanupCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local killmodels = 
	[
		"models/props_industrial/barrel_fuel_parta.mdl",
		"models/props_industrial/barrel_fuel_partb.mdl"
	]

	local parented = {}
	foreach(name,tbl in AdminSystem.Vars._heldEntity)
	{
		local tbl2 = AdminSystem.Vars._wornHat[name]

		if(tbl.entid != "")
		{
			parented[tbl.entid.tointeger()] <- tbl.entid.tointeger()
		}

		if(tbl2.entid != "")
		{
			parented[tbl2.entid.tointeger()] <- tbl2.entid.tointeger()
		}
	}

	local exp = regexp(@"_\d+(?:_our_particles|_singlesimple)")

	foreach(ent in Objects.All())
	{
		if(ent.GetIndex() in parented)
			continue
		
		if(exp.capture(ent.GetName()) != null || Utils.GetIDFromArray(killmodels,ent.GetModel()) != -1)
			ent.Kill()
	}
}

::AdminSystem.AdrenalineCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Duration = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Duration )
	{
		Duration = Duration.tointeger();
	
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.GiveAdrenaline(Duration);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.GiveAdrenaline(Duration);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.GiveAdrenaline(Duration);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.GiveAdrenaline(Duration);
		}
	}
	else
	{
		Duration = Survivor.tointeger();
		player.GiveAdrenaline(Duration);
	}
}

::AdminSystem.MoveCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
	{
		Entity = Entity.tolower();
	
		if ( Entity == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( survivor.IsBot() )
					survivor.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( survivor.IsBot() )
					survivor.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
			{
				if ( boomer.IsBot() )
					boomer.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
			{
				if ( charger.IsBot() )
					charger.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "infected" || Entity == "common" )
		{
			foreach(infected in Objects.OfClassname("infected"))
				infected.BotMoveToLocation(EyePosition);
		}
		else if ( Entity == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
			{
				if ( hunter.IsBot() )
					hunter.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
			{
				if ( jockey.IsBot() )
					jockey.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
			{
				if ( smoker.IsBot() )
					smoker.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
			{
				if ( spitter.IsBot() )
					spitter.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
			{
				if ( tank.IsBot() )
					tank.BotMoveToLocation(EyePosition);
			}
		}
		else
		{
			if ( !Target )
				return;
			
			if ( Target.IsBot() )
				Target.BotMoveToLocation(EyePosition);
		}
	}
	else
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( survivor.IsBot() )
				survivor.BotMoveToLocation(EyePosition);
		}
	}
}

::AdminSystem.ChaseCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local InfectedChase = null;
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	function RemoveInfectedChase()
	{
		while( ( InfectedChase = Entities.FindByName( InfectedChase, "admin_chase" ) ) != null )
		{
			DoEntFire( "!self", "Kill", "", 0, null, InfectedChase );
		}
	}

	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			RemoveInfectedChase();
			foreach ( survivor in Players.AliveSurvivors() )
				local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", survivor.GetLocation());
			chase.Input("Enable");
		}
		else if ( Survivor == "stop" || Survivor == "off" )
		{
			RemoveInfectedChase();
		}
		else
		{
			if ( !Target )
				return;
			
			RemoveInfectedChase();
			local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", Target.GetLocation());
			Target.AttachOther(chase, true);
			chase.Input("Enable");
		}
	}
	else
	{
		RemoveInfectedChase();
		local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", EyePosition);
		chase.Input("Enable");
	}
}

::AdminSystem.HealthCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Type )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				survivor.SwitchHealth(Type);
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				survivor.SwitchHealth(Type);
			}
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SwitchHealth(Type);
		}
	}
	else
	{
		player.SwitchHealth(Survivor);
	}
}

::AdminSystem.MaxHealthCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			survivor.Input( "AddOutput", "max_health " + Amount );
			survivor.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			survivor.Input( "AddOutput", "max_health " + Amount );
			survivor.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
		{
			boomer.Input( "AddOutput", "max_health " + Amount );
			boomer.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
		{
			charger.Input( "AddOutput", "max_health " + Amount );
			charger.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
		{
			infected.Input( "AddOutput", "max_health " + Amount );
			infected.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
		{
			hunter.Input( "AddOutput", "max_health " + Amount );
			hunter.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
		{
			jockey.Input( "AddOutput", "max_health " + Amount );
			jockey.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
		{
			smoker.Input( "AddOutput", "max_health " + Amount );
			smoker.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
		{
			spitter.Input( "AddOutput", "max_health " + Amount );
			spitter.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
		{
			tank.Input( "AddOutput", "max_health " + Amount );
			tank.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
		{
			witch.Input( "AddOutput", "max_health " + Amount );
			witch.Input( "AddOutput", "health " + Amount );
		}
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.Input( "AddOutput", "max_health " + Amount );
			Target.Input( "AddOutput", "health " + Amount );
		}
		else
		{
			player.Input( "AddOutput", "max_health " + Entity );
			player.Input( "AddOutput", "health " + Entity );
		}
	}
}

::AdminSystem.MeleeCmd <- function ( player, args )
{
	local Melee = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 2;
	g_ModeScript.SpawnMeleeWeapon( Melee, EyePosition, Vector(0,0,90) );
}

/*
 * @authors rhino
 */
::AdminSystem.RandomModelCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	ClientPrint(player.GetBaseEntity(),3,"\x05"+RandomPick(::ModelPaths.all));
}

/*
 * @authors rhino
 */
::AdminSystem.ModelCmd <- function ( player, args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(::VSLib.EasyLogic.NextMapContinues)
		return;

	local ent = GetArgument(1);
	
	if(ent == "!picker")
		ent = player.GetLookingEntity();
	else if(ent == "!self")
		ent = player;
	else if(ent.find("#") != null)
	{
		ent = VSLib.Entity(Ent(ent))
	}
	else
	{
		try{ent = VSLib.Entity(Ent(ent))}catch(e){return;}
	}

	if(ent == null)
		return;

	local model = GetArgument(2);
	if(model == null)
		return;

	if(model == "!random")
		model = RandomPick(::ModelPaths.all);

	if(model.find("models/") == null)
	{
		if(model.find("*")==null)
			return;
		
		model = split(model,"*")
		if(model.len() != 1)
			return;

		try{model = model[0].tointeger()}catch(e){return;}

		ent.SetModelIndex(model);
		model = "*"+model.tostring();
	}
	else
	{
		ent.SetModel(model);
		AdminSystem.Vars._modelPreference[player.GetCharacterNameLower()].lastmodel = model;
	}

	local name = player.GetCharacterNameLower();
	
	Printer(player,CmdMessages.Models.ChangeSuccess(ent.GetIndex(),model));
	
}

/*
 * @authors rhino
 */
::AdminSystem.ModelScaleCmd <- function ( player, args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = GetArgument(1);
	if(ent == "!picker")
		ent = player.GetLookingEntity();
	else if(ent == "!self")
		ent = player;
	else if(ent.find("#") != null)
	{
		ent = VSLib.Entity(Ent(ent))
	}
	else
	{
		try{ent = VSLib.Entity(Ent(ent))}catch(e){return;}
	}

	if(ent == null)
		return;

	local scale = GetArgument(2);
	if(scale == null)
		return;

	try{scale = scale.tofloat()}catch(e){return;}

	local name = player.GetCharacterNameLower();
	
	ent.SetModelScale(scale);

	Printer(player,CmdMessages.Models.ScaleChangeSuccess(ent.GetIndex(),scale));
}

/*
 * @authors rhino
 */
::AdminSystem.DisguiseCmd <- function ( player, args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(::VSLib.EasyLogic.NextMapContinues)
		return;
	
	local ent = player.GetLookingEntity();
	
	if(ent == null)
	{
		foreach(e in Objects.AroundRadius(player.GetLookingLocation(),1))
		{
			ent = e;
			break;
		}

		if(ent == null)
			return;
	}
	
	local model = ent.GetModel();
	if(model == null)
		return;

	if(model.find("models/") == null)
	{
		if(model.find("*")==null)
			return;
		
		model = split(model,"*")
		if(model.len() != 1)
			return;

		try{model = model.tointeger()}catch(e){return;}

		player.SetModelIndex(model);
	}
	else
		player.SetModel(model);

	local name = player.GetCharacterNameLower();

	Printer(player,CmdMessages.Models.ChangeSuccess(ent.GetIndex(),model));
}

/*
 * @authors rhino
 */
::AdminSystem.ParticleCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local Particle = GetArgument(1);
	if (Particle == "random")
	{
		Particle = Utils.GetRandValueFromArray(::Particlenames.names);
		if(AdminSystem.Vars._saveLastParticle[name])
		{
			AdminSystem.Vars._savedParticle[name].source = Particle;
		}
	}

	local EyePosition = player.GetLookingLocation();
	
	g_ModeScript.CreateParticleSystemAt( null, EyePosition, Particle, true );

	Printer(player,CmdMessages.Particles.SpawnSuccess(Particle,EyePosition));
}

/* @authors rhino
 * Show explosion params
 */
::AdminSystem.Show_explosion_settingsCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Explosion Settings:");
		foreach(setting,val in AdminSystem.Vars._explosion_settings[player.GetCharacterNameLower()])
		{
			Messages.InformPlayer(player,"\x05"+setting+"\x03"+" -> "+"\x04"+val.tostring()+"\x01"+"\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem.Vars._explosion_settings[player.GetCharacterNameLower()])
		{
			printB(player.GetCharacterName(),"[Explosion-Setting] "+setting+"->"+val.tostring(),false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}

/* @authors rhino
 * Change arguments of the delayed explosion
 */
::AdminSystem.Explosion_settingCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName();
	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(!(setting in AdminSystem.Vars._explosion_settings[name.tolower()]))
		return;
	
	if(setting != "effect_name")
		{try{val = val.tofloat();}catch(e){return;}}
	else if(Utils.GetIDFromArray(::Particlenames.names,val) == -1)
		{Messages.ThrowPlayer(player,CmdMessages.Particles.UnknownParticle(val));return;}

	Printer(player,CmdMessages.Explosions.SettingSuccess(setting,AdminSystem.Vars._explosion_settings[name.tolower()][setting],val));

	AdminSystem.Vars._explosion_settings[name.tolower()][setting] = val;
}

/*
 * @authors rhino
 */
::_RemoveNonPhysicsFromTable <- function(tbl,pos,radius)
{
	foreach(id,entity in VSLib.EasyLogic.Objects.AroundRadius(pos,radius))
	{
		switch(entity.GetClassname())
		{
			case "prop_physics":
			{
				break;
			}
			case "prop_physics_multiplayer":
			{
				break;
			}
			case "prop_ragdoll":
			{
				break;
			}
			case "func_physbox_multiplayer":
			{
				break;
			}
			case "func_physbox":
			{
				break;
			}
			case "prop_physics_override":
			{
				break;
			}
			case "prop_vehicle":
			{
				break;
			}
			case "prop_car_alarm":
			{
				break;
			}
			default:
			{
				delete tbl[id];
			}
		}
	}
}

/*
 * @authors rhino
 * Create a delayed explosion with a particle effect until exploding
 */
::AdminSystem._AimedExplosionCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local meteorshower = GetArgument(1)
	local name = player.GetCharacterNameLower();
	local aimedlocation = player.GetLookingLocation();
	local argtable = AdminSystem.Vars._explosion_settings[name];

	local explosion_particle = argtable.effect_name;
	local uniqname = "vslib_tmp_" + UniqueString();
	local particletable = 
	{ 
		classname = "info_particle_system",
		targetname = uniqname,
		origin = aimedlocation,
		angles = QAngle(-90,0,0),
		start_active = true,
		effect_name = explosion_particle 
	};
	
	local particle = Utils.CreateEntityWithTable(particletable);
	local minsp = argtable.minpushspeed
	local maxsp = (argtable.maxpushspeed - minsp)
	local pushspeed = minsp + (rand()%maxsp)
	local delay = argtable.delay;

	if (!particle)
	{
		CmdMessages.Explosions.FailedParticle();
		return;
	}
	
	if(explosion_particle=="fireworks_sparkshower_01" || explosion_particle=="fireworks_sparkshower_01b" || explosion_particle=="fireworks_sparkshower_01c")
	{
		particle.SetAngles(-90,0,0);
		particle.SetOrigin(Vector(aimedlocation.x,aimedlocation.y,aimedlocation.z+5.0));
		if(delay>7)
			{printB(player.GetCharacterName(),CmdMessages.Explosions.FireworkLength(),false,"");particle.KillDelayed(7);}
		else
			particle.KillDelayed(delay);
		
		DoEntFire("!self", "Start", "", 0, null, particle);
	}
	else
	{
		if(explosion_particle=="flame_blue")
			particle.SetAngles(-70,30,-30);
		else if(explosion_particle=="fireworks_sparkshower_01e")
			{particle.SetAngles(-90,0,0);particle.SetOrigin(Vector(aimedlocation.x,aimedlocation.y,aimedlocation.z+5.0));}

		particle.KillDelayed(delay);
		DoEntFire("!self", "Start", "", 0, null, particle);
	}

	if(meteorshower == "meteor")
	{
		local ceiling = Utils.GetLocationAbove(aimedlocation,null,120)

		Timers.AddTimer(delay, false, _MeteorFallCreateWrapper, 
		{
			ceiling=ceiling,
			minsp=minsp,
			maxsp=maxsp,
			dmgmin=argtable.dmgmin,
			dmgmax=argtable.dmgmax,
			radiusmax=argtable.radiusmax,
			aimedlocation=aimedlocation,
			particle=particle,
			explosion_particle=explosion_particle
			name=name
		});

	}
	else
	{
		local explosion_sound = Utils.CreateEntityWithTable({classname="ambient_generic", message = "randomexplosion", spawnflags = 32, origin = aimedlocation});

		local explosion_table =
		{
			classname = "env_explosion",
			spawnflags = 0, 
			origin = aimedlocation, 
			iMagnitude = argtable.dmgmin+(rand()%(argtable.dmgmax-argtable.dmgmin)), 
			iRadiusOverride = argtable.radiusmin+(rand()%(argtable.radiusmax-argtable.radiusmin))
		}

		local explosion = Utils.CreateEntityWithTable(explosion_table);
		
		local closebyents = VSLib.EasyLogic.Objects.AroundRadius(aimedlocation,argtable.radiusmax);
		_RemoveNonPhysicsFromTable(closebyents,aimedlocation,argtable.radiusmax);
		
		Timers.AddTimer(delay, false, _explosionPush, {explosion_sound=explosion_sound,explosion=explosion,ents=closebyents,pushspeed=pushspeed,origin=aimedlocation});

		//printl(name+"-> Created explosion with particle(#"+particle.GetIndex()+") "+explosion_particle+"  at "+aimedlocation);
	}
}

/*
 * @authors rhino
 * Wrapper for creating delayed meteors
 */
::_MeteorFallCreateWrapper <- function(args)
{
	local meteor = _CreateAndPushMeteor(AdminSystem._meteor_shower_args.meteormodelpick,
											args.ceiling,
											args.minsp,
											args.maxsp,
											false)
		
	_AttachExplosionEffects(meteor,
							args.ceiling,
							args.dmgmin,
							(args.dmgmax - args.dmgmin),
							args.radiusmax
							)
	

	if(Utils.CalculateDistance(args.ceiling,args.aimedlocation) < 150 || args.aimedlocation.z-args.ceiling.z > 0)
	{
		Timers.AddTimer(0.1, false, _MeteorExplosionWrapper, {index=meteor.GetIndex()});
	}
	else
	{
		_AttachDamageOutput(meteor,"RunScriptCode","_MeteorExplosion("+meteor.GetIndex()+")",0,1)
	}
		
	//printl(args.name+"-> Created meteor fall explosion with meteor(#"+meteor.GetIndex()+") particle(#"+args.particle.GetIndex()+") "+args.explosion_particle+"  at "+args.aimedlocation);

}

::_MeteorExplosionWrapper <- function(arg)
{
	_MeteorExplosion(arg.index)
}

/*
 * @authors rhino
 * Push entities away from an explosion with custom parameters
 */
::_explosionPush <- function(tbl)
{
	local ents = tbl.ents;
	local pushspeed = tbl.pushspeed
	local exporigin = tbl.origin;

	local distvec = null;
	local dist = null;

	tbl.explosion_sound.Input("ToggleSound","",0.1);
	tbl.explosion.Input("Explode","",0.1);
	tbl.explosion_sound.Input("Kill","",0.25);

	foreach(ent in ents)
	{	
		if (ent.GetOrigin() == null || !ent.GetOrigin())
			continue;

		distvec = ent.GetOrigin()-exporigin;
		dist = distvec.Length();
		distvec = distvec.Scale(pushspeed/dist);
		ent.Push(distvec); 
	}
}

/*
 * @authors rhino
 */
::AdminSystem.RestoreModelCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local target = GetArgument(1);
	local name = player.GetCharacterNameLower();
	if(target != null)
	{
		if(target == "!picker")
			target = player.GetLookingEntity();
		else
		{
			try{target = Utils.GetPlayerFromName(target);}catch(e){return;}
		}

		if(target == null)
			return
		else if(target.GetClassname() != "player")
			return
		
		Utils.ResetModels(target.GetCharacterName());

		Printer(player,CmdMessages.Models.RestoredOrgOther(target.GetCharacterName()));
	}
	else
	{
		Utils.ResetModels(name);

		Printer(player,CmdMessages.Models.RestoredOrgSelf());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateTankRockPreferenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(AdminSystem.Vars._RockThrow.pushenabled)
	{
		AdminSystem.Vars._RockThrow.pushenabled = false;
		Messages.InformAll(CmdMessages.DisableTankRockPush());
	}
	else
	{
		AdminSystem.Vars._RockThrow.pushenabled = true;
		Messages.InformAll(CmdMessages.EnableTankRockPush());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateTankRockRandomPreferenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(AdminSystem.Vars._RockThrow.randomized)
	{
		AdminSystem.Vars._RockThrow.randomized = false;
		Messages.InformAll(CmdMessages.DisableTankRockRandomModel());
	}
	else
	{
		AdminSystem.Vars._RockThrow.randomized = true;
		Messages.InformAll(CmdMessages.EnableTankRockRandomModel());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateTankRockSpawnAfterPreferenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(AdminSystem.Vars._RockThrow.randomized_spawn_prop_after)
	{
		AdminSystem.Vars._RockThrow.randomized_spawn_prop_after = false;
		Messages.InformAll(CmdMessages.DisableTankRockPhys());
	}
	else
	{
		AdminSystem.Vars._RockThrow.randomized_spawn_prop_after = true;
		Messages.InformAll(CmdMessages.EnableTankRockPhys());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateJockeyPreferenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if(Convars.GetStr("z_jockey_limit") == "0")
	{
		Convars.SetValue("z_jockey_limit","1");
		SessionOptions.JockeyLimit <- "1";
		Messages.InformAll(CmdMessages.EnableJockeys());
	}
	else
	{
		Convars.SetValue("z_jockey_limit","0");
		SessionOptions.JockeyLimit <- "0";
		Messages.InformAll(CmdMessages.DisableJockeys());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateModelPreferenceCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	local name = player.GetCharacterNameLower();

	if(AdminSystem.Vars._modelPreference[name].keeplast)
	{
		AdminSystem.Vars._modelPreference[name].keeplast = false;
		Printer(player,CmdMessages.DisableModelKeeping());
	}
	else
	{
		AdminSystem.Vars._modelPreference[name].keeplast = true;
		Printer(player,CmdMessages.EnableModelKeeping());
	}
}

/*
 * @authors rhino
 * Spawn a microphone
 *
 * Example ( Spawn a standard microphone with 100 units range and connect it to speaker #123 ):
 * 		!microphone standard 100 #123
 */
::MicEffects <-
{
	standard = "0"
	no_effect = "50"
	very_small = "56"
	small = "58"
	tiny = "59"
	loud = "55"
	loud_echo = "57"
}

::AdminSystem.MicrophoneCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();

	local effect = GetArgument(1);
	if(effect == null)
		effect = "standard"

	if(!(effect in MicEffects))
	{
		Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.MicEffects());return;
	}
	else
	{
		effect = MicEffects[effect];
	}
	local maxrange = GetArgument(2);
	local speakerIDorName = GetArgument(3);
	local speaker = null;

	if(maxrange == null)
	{
		maxrange = 120;
	}
	else
	{	
		maxrange = maxrange.tofloat();

		if(speakerIDorName != null)
		{
			speaker = Ent(speakerIDorName);

			if (speaker == null)
			{
				Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.SpeakerIDInvalid());return;
			}

			if(speaker.GetClassname() != "info_target" && !AdminSystem.Vars.IgnoreSpeakerClass)
			{
				Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.SpeakerClassInvalid());return;
			}
		}
	}
	
	local keyvaltable = 
	{	
		classname = "env_microphone"
		origin = player.GetLookingLocation()
		spawnflags = 47
		MaxRange = maxrange
		Sensitivity = 1
		SmoothFactor = 0
		speaker_dsp_preset = effect
		targetname = "spawnedmic"
	}
	
	if(speaker != null)
		keyvaltable.SpeakerName <- speaker.GetName();


	local micent = Utils.CreateEntityWithTable(keyvaltable);

	if(micent == null)
	{Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.MicKeyValsInvalid());return;}

	Printer(player,CmdMessages.MicSpeaker.MicrophoneSuccess(micent));
}

/*
 * @authors rhino
 * Spawn a speaker to connect to a microphone
 */
::AdminSystem.SpeakerCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	
	local keyvaltable = 
	{	
		classname = "info_target"
		origin = player.GetLookingLocation()
		spawnflags = 0
		targetname = "spawnedspeaker"
	}

	local speakerent = Utils.CreateEntityWithTable(keyvaltable);

	if(speakerent == null)
	{Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.SpeakerKeyValsInvalid());return;}

	Printer(player,CmdMessages.MicSpeaker.SpeakerSuccess(speakerent));
}

/*
 * @authors rhino
 * Connect a speaker to a mic
 */
::AdminSystem.Speaker2micCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();

	local speaker = GetArgument(1);
	local mic = GetArgument(2);

	if(speaker == null || mic == null)
		return;
	
	speaker = Ent(speaker);
	mic = Ent(mic);
	
	if(speaker == null || mic == null)
		return;
	
	if((speaker.GetClassname() != "info_target" && !AdminSystem.Vars.IgnoreSpeakerClass) || mic.GetClassname() != "env_microphone")
	{
		Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.ClassesInvalid());return;
	}

	DoEntFire("!self","SetSpeakerName",speaker.GetName(),0,null,mic);

	Printer(player,CmdMessages.MicSpeaker.ConnectSuccess(speaker.GetEntityIndex(),mic.GetEntityIndex()));
}

/*
 * @authors rhino
 * Display all mics' and speakers' IDs and how far away they are from the player
 */
::AdminSystem.Display_mics_speakersCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local pos = player.GetPosition();
	local dist = null;
	local entorigin = null;
	local foundany = false;
	local outputenabled = AdminSystem.Vars._outputsEnabled[name];

	if(!outputenabled)
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
	}

	foreach(mic in ::VSLib.EasyLogic.Objects.OfClassname("env_microphone"))
	{	
		if(mic.GetName().find("spawnedmic") != null)
		{	
			foundany = true;
			entorigin = mic.GetOrigin();
			if(outputenabled)
			{
				Messages.InformPlayer(player,CmdMessages.MicSpeaker.MicInfo(mic.GetIndex(),entorigin,Utils.CalculateDistance(entorigin,pos)));
			}
			else
			{
				printB(player.GetCharacterName(),CmdMessages.MicSpeaker.MicInfo(mic.GetIndex(),entorigin,Utils.CalculateDistance(entorigin,pos)),false,"info",false,false);
			}
			
		}
	}

	foreach(speaker in ::VSLib.EasyLogic.Objects.OfClassname("info_target"))
	{
		if(speaker.GetName().find("spawnedspeaker") != null)
		{
			foundany = true;
			entorigin = speaker.GetOrigin();
			if(outputenabled)
			{
				Messages.InformPlayer(player,CmdMessages.MicSpeaker.SpeakerInfo(speaker.GetIndex(),entorigin,Utils.CalculateDistance(entorigin,pos)));
			}
			else
			{
				printB(player.GetCharacterName(),CmdMessages.MicSpeaker.SpeakerInfo(speaker.GetIndex(),entorigin,Utils.CalculateDistance(entorigin,pos)),false,"info",false,false);
			}
		}	
	}

	if(!foundany)
	{
		if(outputenabled)
		{
			Messages.ThrowPlayer(player,CmdMessages.MicSpeaker.NoneFound());
		}
		else
		{
			printB(player.GetCharacterName(),CmdMessages.MicSpeaker.NoneFound(),false,"info",false,false);
		}
	}

	if(!outputenabled)
	{
		printB(player.GetCharacterName(),"",false,"",false,true,0.3);
	}
}

/*
 * @authors rhino
 * Remove all spawned piano keys
 */
::AdminSystem.Remove_piano_keysCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local entfound = null;

	foreach(index,name in Utils.TableCopy(AdminSystem.Vars._spawnedPianoKeys))
	{	
		entfound = Entities.FindByName(null, name)

		if(entfound != null)
			entfound.Kill();

		delete AdminSystem.Vars._spawnedPianoKeys[index];
	}

	Printer(player,CmdMessages.Piano.Remove());
}

/*
 * @authors rhino
 * Spawn 25 piano keys perpendecular to the player, spawns them to the right of the look location
 */
::AdminSystem.Piano_keysCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();

	local lookedloc = player.GetLookingLocation();
	local eyeforward= player.GetEyeAngles().Forward();
	
	local keys = [44,1,2,3,5,6,7,8,9,15,16,17,18,19,20,31,33,34,35,36,41,42,45,46]
	local horizontal_space = 70.0/25;

	local keyvaltable = 
	{	
		classname = "func_button"
		origin = lookedloc
		movedir = Vector(0,0,0)
		spawnflags = 1025
		wait = 0.01
		sounds = 43
	}

	local startkey = Utils.CreateEntityWithTable(keyvaltable);
	
	if(startkey == null)
	{Messages.ThrowPlayer(player,CmdMessages.Piano.Failed());return;}
	
	local entindex = startkey.GetIndex();

	//printl("43(#"+entindex+") pos:"+lookedloc);
	AdminSystem.Vars._spawnedPianoKeys[entindex] <- startkey.GetName();

	local ent = null;
	local temp = player.GetEyeAngles().Forward();

	// Unit vector perpendecular to player
	eyeforward.x = temp.y;
	eyeforward.y = -temp.x;
	eyeforward.z = 0;
	eyeforward = eyeforward.Scale(1.0/eyeforward.Length());

	foreach(i,key in keys)
	{	
		keyvaltable.origin = lookedloc + eyeforward.Scale(horizontal_space*(i+1));
		keyvaltable.sounds = key
		ent = Utils.CreateEntityWithTable(keyvaltable);
		entindex = ent.GetIndex();
		//printl(key.tostring()+"(#"+entindex+") pos:"+keyvaltable.origin);
		AdminSystem.Vars._spawnedPianoKeys[entindex] <- ent.GetName();
	}
	
	Printer(player,CmdMessages.Piano.Success(startkey));
}

::AdminSystem.BarrelCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.SpawnFuelBarrel(EyePosition);
	}
}

::AdminSystem.GascanCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/gascan001a.mdl" });
	}
}

::AdminSystem.PropaneTankCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/propanecanister001a.mdl" });
	}
}

::AdminSystem.OxygenTankCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_equipment/oxygentank01.mdl" });
	}
}

::AdminSystem.FireworkCrateCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/explosive_box001.mdl" });
	}
}

::AdminSystem.MinigunCmd <- function ( player, args )
{
	local Minigun = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	
	if ( Minigun == "l4d1" )
		Utils.SpawnL4D1Minigun(EyePosition, GroundPosition);
	else
		Utils.SpawnMinigun(EyePosition, GroundPosition);
}

::AdminSystem.WeaponCmd <- function ( player, args )
{
	local Weapon = GetArgument(1);
	local Count = GetArgument(2);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,90);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Count )
		Count = Count.tointeger();
	else
		Count = 4;
	
	if ( Weapon.find("_spawn") == null )
		Weapon = Weapon + "_spawn";
	
	GroundPosition.y = EyeAngles.y;
	GroundPosition.y += 90;
	EyePosition.z += 2;
	
	Utils.SpawnWeapon(Weapon, Count, 999999, EyePosition, GroundPosition);
}

::AdminSystem.SpawnAmmoCmd <- function ( player, args )
{
	local AmmoModel = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !AmmoModel )
		Utils.SpawnAmmo("models/props/terror/ammo_stack.mdl", EyePosition);
	else
	{
		if ( AmmoModel == "coffee" || AmmoModel == "coffeecan" )
			Utils.SpawnAmmo("models/props_unique/spawn_apartment/coffeeammo.mdl", EyePosition);
		else
			Utils.SpawnAmmo(AmmoModel, EyePosition);
	}
}

::AdminSystem.DummyCmd <- function ( player, args )
{
	local MDL = GetArgument(1);
	local Weapons = GetArgument(2);
	local Animation = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	GroundPosition.y += 180;
	local ent = null;
	if ( MDL == "nick" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_gambler.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "rochelle" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_producer.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "coach" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_coach.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "ellis" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_mechanic.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "bill" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_namvet.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "zoey" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_teenangst.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "francis" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_biker.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "louis" )
		ent = Utils.SpawnCommentaryDummy( "models/survivors/survivor_manager.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "smoker" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/smoker.mdl", "weapon_claw", "smoker_cough", EyePosition, GroundPosition );
	else if ( MDL == "boomer" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/boomer.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "boomette" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/boomette.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "hunter" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/hunter.mdl", "weapon_claw", "Idle_Standing_01", EyePosition, GroundPosition );
	else if ( MDL == "spitter" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/spitter.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "jockey" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/jockey.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "charger" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/charger.mdl", "weapon_claw", "Idle_Upper_KNIFE", EyePosition, GroundPosition );
	else if ( MDL == "witch" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/witch.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "witch_bride" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/witch_bride.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "tank" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/hulk.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else if ( MDL == "tank_dlc3" )
		ent = Utils.SpawnCommentaryDummy( "models/infected/hulk_dlc3.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else
		ent = Utils.SpawnCommentaryDummy(MDL, Weapons, Animation, EyePosition);

	if(ent == null)
		return;
	
	Printer(player,CmdMessages.DummyEntity.Success(ent,MDL));
}

/*
 * @authors rhino
 */
::AdminSystem.EntityCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local classname = GetArgument(1);
	local pos = GetArgument(2);
	if(pos == null)
		pos = player.GetLookingLocation();

	local ang = GetArgument(3);
	if(ang == null)
		ang = QAngle(0,0,0)

	local keyvals = GetArgument(4);
	if(keyvals == null)
		keyvals = {}

	local ent = Utils.CreateEntity(classname,pos,ang,keyvals);

	Printer(player,CmdMessages.Ent.EntityCreate(ent.GetIndex(),Utils.GetTableString(keyvals)));
	
}

/**
 * Creates entity with given class and table of key-value pairs 
 *
 * @param classname Class name of the entity
 * @param keyvals Key-value pairs in the format: "key1>val1&key2>TYPE|val2.1|val2.2|val2.3&key3>TYPE|val3&..."
 * 3 arguments for value: TYPE = {ang,pos,str} -> QAngle(val2.1.tofloat(),val2.2.tofloat(),val2.3.tofloat())
 * 												| Vector(val2.1.tofloat(),val2.2.tofloat(),val2.3.tofloat())
 * 												| "val2.1 val2.2 val2.3"
 * 1 argument for value: TYPE = {float,int,str} -> val3.tofloat() | val3.tointeger() | val3
 * @return void
 *	
 * Example(dynamic prop with Gift model with color rgb(90,30,60) and angles -30 pitch, 10 yaw, 0 roll):
 * 		ent prop_dynamic model>models\items\l4d_gift.mdl&rendercolor>str|90|30|60&angles>ang|-30|10|0
 * @authors rhino
 */
::AdminSystem.EntityWithTableCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local cname = GetArgument(1);
	if(cname == "prop_dynamic")
	{
		cname = "prop_dynamic_override";
	}
	//local baseEnt = Utils.CreateEntity(cname,Vector(0,0,0),QAngle(0,0,0),{model="models/props_industrial/wire_spool_01.mdl"});
	local keyvals = GetArgument(2);
	local name = player.GetCharacterNameLower();

	local pairsplit = [null,null];
	local found = false;

	// Keys to be applied after spawning
	local spawnflags = null;
	local effects = null;
	local targetname = null;

	if(keyvals == null)
	{
		keyvals = {};
	}
	else
	{
		keyvals = Utils.CleanColoredString(keyvals);
		local kvpairs = split(keyvals,"&");

		keyvals = 
		{
			classname = cname,
			origin = player.GetLookingLocation(),
			angles = QAngle(0,0,0)
		};
		
		if(cname == "prop_dynamic_override")
		{
			keyvals["Solid"] <- "6";
			keyvals["spawnflags"] <- "8";
			keyvals["StartDisabled"] <- "false";
		}

		foreach(pair in kvpairs)
		{	
			found = false;
			pairsplit = split(pair,">");

			if(pairsplit.len()!=2)
			{
				printB(player.GetCharacterName(),name+" ->Invalid entity key value pair-> ",true,"error",true,false);
				foreach(i,v in pairsplit)
				{
					printB(player.GetCharacterName(),(i+1)+"-> "+v,true,"error",false,false);
				}
				printB(player.GetCharacterName(),"",false,"",false,true);
				return;
			}
			// Manually type casting
			if(pairsplit[1].find("|") != null)
			{	
				local str = split(pairsplit[1],"|");

				// Three values, Possible position, angle, rgb value
				if(str.len()==4)
				{
					if(str[0] == "ang")
					{
						pairsplit[1] = QAngle(str[1].tofloat(),str[2].tofloat(),str[3].tofloat());
					}
					else if(str[0]=="pos")
					{
						pairsplit[1] = Vector(str[1].tofloat(),str[2].tofloat(),str[3].tofloat());
					}
					else if(str[0]=="str")
					{
						pairsplit[1] = str[1]+" "+str[2]+" "+str[3];
					}
					else
					{
						Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairsplit[0]),"error");
						return;
					}
				}
				// Single value
				else if(str.len()==2)
				{
					if(str[0] == "float")
					{
						pairsplit[1] = str[1].tofloat();
					}
					else if(str[0]=="int")
					{
						pairsplit[1] = str[1].tointeger();
					}
					else if(str[0]=="str")
					{
						pairsplit[1] = str[1];
					}
					else
					{
						Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairsplit[0]),"error");
						return;
					}
				}
				// string with multiple spaces
				else
				{
					if(str[0]=="str")
					{
						pairsplit[1] = ""
						for(local i=1;i<str.len();i++)
							pairsplit[1] += str[i]+" ";
						
					}
					else if(str.len() == 1)
					{
						pairsplit[1] = str[0]
					}
					else
					{
						Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairsplit[0]),"error");
						return;
					}
				}
			}
			// Store to apply after spawn
			if(pairsplit[0]=="spawnflags")
			{
				spawnflags = pairsplit[1];
			}
			else if(pairsplit[0]=="effects")
			{
				effects = pairsplit[1];
			}
			else if(pairsplit[0]=="targetname")
			{
				targetname = pairsplit[1];
			}

			if(pairsplit[0] in keyvals)
			{
				keyvals[pairsplit[0]] = pairsplit[1];
			}
			else
			{
				keyvals[pairsplit[0]] <- pairsplit[1];
			}
		}
	}

	local newEntity = Utils.CreateEntityWithTable(keyvals);
	if (newEntity == null)
	{
		Printer(player,CmdMessages.Ent.Failure(),"error");
		return;
	}
	
	// Apply flags, effects and name after spawning
	if(spawnflags!=null)
	{
		newEntity.SetFlags(spawnflags);
	}

	if(effects!=null)
	{
		newEntity.SetEffects(effects);
	}

	if(targetname!=null)
	{
		newEntity.SetName(targetname);
	}

	keyvals["targetname"] <- newEntity.GetName();
	
	Printer(player,CmdMessages.Ent.Success(cname,newEntity.GetIndex(), Utils.GetTableString(keyvals)));

}

/*
 * @authors rhino
 */
::AdminSystem.PropCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local Entity = GetArgument(1);
	local MDL = GetArgument(2);
	if(MDL == "!random")
		MDL = RandomPick(::ModelPaths.all)

	local raise = GetArgument(3);
	local yaw = GetArgument(4);
	local massScale = GetArgument(5);

	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	local name = player.GetCharacterNameLower();
	
	local propspawnsettings = AdminSystem.Vars._prop_spawn_settings[name];

	GroundPosition.y = EyeAngles.y;

	local createdent = null;

	if(yaw)
	{
		try{yaw = yaw.tofloat();}
		catch(e){printl((typeof yaw)+" couldnt be parsed as float.");return;}
		GroundPosition = GroundPosition + QAngle(0,yaw,0);
	}

	if ( Entity == "physics" )
	{	
		// +++++++++++++++ SETTINGS START 
		local settings = propspawnsettings["physics"];
		// Spawn height
		local spawn_height = settings["spawn_height"];
		if (spawn_height == "top_touch")
		{
			// TO DO
		}
		else if (spawn_height == "bottom_touch")
		{
			// TO DO
		}
		else
		{	
			EyePosition.z += spawn_height.tofloat();
		}
		// +++++++++++++++ SETTINGS END 

		if ( raise != null )
		{
			EyePosition.z += raise.tofloat();
			createdent = Utils.SpawnPhysicsProp( MDL, EyePosition, GroundPosition );
		}
		else
		{
			EyePosition.z += 0.5;
		}
		
		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnPhysicsProp( Utils.CleanColoredString(mdl), EyePosition, GroundPosition );
				if(ent != null && ent.IsEntityValid())
				{
					createdent.append(ent);
					ent.SetMoveType(MOVETYPE_NONE);
				}
				else
				{
					ent = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), EyePosition, GroundPosition );
					if(ent != null && ent.IsEntityValid())
					{
						createdent.append(ent);
						ent.SetMoveType(MOVETYPE_NONE);
					}
				}
			}
		}
		else
		{
			createdent = Utils.SpawnPhysicsProp( Utils.CleanColoredString(MDL), EyePosition, GroundPosition );
		}
	}
	else if ( Entity == "physicsM" )
	{
		// +++++++++++++++ SETTINGS START 
		local settings = propspawnsettings["physics"];
		// Spawn height
		local spawn_height = settings["spawn_height"];
		if (spawn_height == "top_touch")
		{
			// TO DO
		}
		else if (spawn_height == "bottom_touch")
		{
			// TO DO
		}
		else
		{	
			EyePosition.z += spawn_height.tofloat();
		}
		// +++++++++++++++ SETTINGS END

		if ( raise != null )
		{
			EyePosition.z += raise.tofloat();
		}
		else
		{
			EyePosition.z += 0.5;
		}

		if(massScale)
		{
			try{massScale = massScale.tofloat();}
			catch(e){printl((typeof massScale)+" couldnt be parsed as float.");return;}
		}

		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnPhysicsMProp( Utils.CleanColoredString(mdl), EyePosition, GroundPosition, {massScale = massScale} );
				if(ent != null && ent.IsEntityValid())
				{
					createdent.append(ent);
					ent.SetMoveType(MOVETYPE_NONE);
				}
				else
				{
					ent = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), EyePosition, GroundPosition );
					if(ent != null && ent.IsEntityValid())
					{
						createdent.append(ent);
						ent.SetMoveType(MOVETYPE_NONE);
					}
				}
			}
		}
		else
		{
			createdent = Utils.SpawnPhysicsMProp( Utils.CleanColoredString(MDL), EyePosition, GroundPosition, {massScale = massScale} );
		}
	}
	else if ( Entity == "ragdoll" )
	{
		// +++++++++++++++ SETTINGS START 
		local settings = propspawnsettings["ragdoll"];
		// Spawn height
		local spawn_height = settings["spawn_height"];
		if (spawn_height == "top_touch")
		{
			// TO DO
		}
		else if (spawn_height == "bottom_touch")
		{
			// TO DO
		}
		else
		{	
			EyePosition.z += spawn_height.tofloat();
		}
		// +++++++++++++++ SETTINGS END 

		EyePosition.z += 2;
		GroundPosition.y += 180;
		if ( MDL == "nick" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_gambler.mdl", EyePosition, GroundPosition );
		else if ( MDL == "rochelle" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_producer.mdl", EyePosition, GroundPosition );
		else if ( MDL == "coach" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_coach.mdl", EyePosition, GroundPosition );
		else if ( MDL == "ellis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_mechanic.mdl", EyePosition, GroundPosition );
		else if ( MDL == "bill" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_namvet.mdl", EyePosition, GroundPosition );
		else if ( MDL == "zoey" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_teenangst.mdl", EyePosition, GroundPosition );
		else if ( MDL == "francis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_biker.mdl", EyePosition, GroundPosition );
		else if ( MDL == "louis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_manager.mdl", EyePosition, GroundPosition );
		else if ( MDL == "smoker" )
			createdent = Utils.SpawnRagdoll( "models/infected/smoker.mdl", EyePosition, GroundPosition );
		else if ( MDL == "boomer" )
			createdent = Utils.SpawnRagdoll( "models/infected/boomer.mdl", EyePosition, GroundPosition );
		else if ( MDL == "boomette" )
			createdent = Utils.SpawnRagdoll( "models/infected/boomette.mdl", EyePosition, GroundPosition );
		else if ( MDL == "hunter" )
			createdent = Utils.SpawnRagdoll( "models/infected/hunter.mdl", EyePosition, GroundPosition );
		else if ( MDL == "spitter" )
			createdent = Utils.SpawnRagdoll( "models/infected/spitter.mdl", EyePosition, GroundPosition );
		else if ( MDL == "jockey" )
			createdent = Utils.SpawnRagdoll( "models/infected/jockey.mdl", EyePosition, GroundPosition );
		else if ( MDL == "charger" )
			createdent = Utils.SpawnRagdoll( "models/infected/charger.mdl", EyePosition, GroundPosition );
		else if ( MDL == "witch" )
			createdent = Utils.SpawnRagdoll( "models/infected/witch.mdl", EyePosition, GroundPosition );
		else if ( MDL == "witch_bride" )
			createdent = Utils.SpawnRagdoll( "models/infected/witch_bride.mdl", EyePosition, GroundPosition );
		else if ( MDL == "tank" )
			createdent = Utils.SpawnRagdoll( "models/infected/hulk.mdl", EyePosition, GroundPosition );
		else if ( MDL == "tank_dlc3" )
			createdent = Utils.SpawnRagdoll( "models/infected/hulk_dlc3.mdl", EyePosition, GroundPosition );
		else
			createdent = Utils.SpawnRagdoll( MDL, EyePosition, GroundPosition );
	}
	else
	{	
		// +++++++++++++++ SETTINGS START 
		local settings = propspawnsettings["dynamic"];
		// Spawn height
		local spawn_height = settings["spawn_height"];
		if (spawn_height == "top_touch")
		{
			// TO DO
		}
		else if (spawn_height == "bottom_touch")
		{
			// TO DO
		}
		else
		{	
			EyePosition.z += spawn_height.tofloat();
		}
		// +++++++++++++++ SETTINGS END 
		
		if ( raise )
		{
			EyePosition.z += raise.tofloat();
		}
	
		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), EyePosition, GroundPosition );
				if(ent != null && ent.IsEntityValid())
					createdent.append(ent);
			}
		}
		else
		{
			createdent = Utils.SpawnDynamicProp( Utils.CleanColoredString(MDL), EyePosition, GroundPosition );
		}
	}

	if(createdent == null || createdent == [])
	{
		Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(Entity));return;
	}

	if(typeof createdent == "array")
	{
		local parentent = createdent[0];
		foreach(e in createdent.slice(1,createdent.len()))
		{
			e.Input("setparent","#"+parentent.GetIndex(),0);
		}
		if(Entity == "physicsM" || Entity == "physics")
		{
			parentent.SetMoveType(MOVETYPE_VPHYSICS);
		}

		Printer(player,CmdMessages.Prop.SuccessParented(Entity,createdent));
	}
	else
	{
		Printer(player,CmdMessages.Prop.Success(Entity,createdent));
	}
}

::AdminSystem.DoorCmd <- function ( player, args )
{
	local name = player.GetCharacterNameLower();
	local DoorModel = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);
	local ent = null;
	local raise = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	
	if(raise)
	{
		raise = raise.tofloat();
	}
	else
	{
		raise = 52;
	}

	if ( !DoorModel )
		ent = Utils.SpawnDoor("models/props_downtown/door_interior_112_01.mdl", EyePosition, GroundPosition);
	else
	{
		EyePosition.z += raise;
		
		if(DoorModel.find("&") != null)
		{
			ent = []
			local mdls = split(DoorModel,"&");
			local d = Utils.SpawnDoor(Utils.CleanColoredString(mdls[0]), EyePosition, GroundPosition);

			if(d != null && d.IsEntityValid())
				ent.append(d);
			else
			{
				Printer(player,CmdMessages.Prop.FailureDoor(mdls[0]));
				return;
			}

			foreach(mdl in mdls.slice(1,mdls.len()))
			{
				d = Utils.SpawnDynamicProp(Utils.CleanColoredString(mdl), EyePosition, GroundPosition);
				if(d != null && d.IsEntityValid())
					ent.append(d);
			}
		}
		else
		{
			if ( DoorModel == "saferoom" || DoorModel == "checkpoint" )
				ent = Utils.SpawnDoor("models/props_doors/checkpoint_door_02.mdl", EyePosition, GroundPosition);
			else
				ent = Utils.SpawnDoor(Utils.CleanColoredString(DoorModel), EyePosition, GroundPosition);
		}
	}
	
	if(typeof ent == "array")
	{
		local parentent = ent[0];
		foreach(e in ent.slice(1,ent.len()))
		{
			e.Input("setparent","#"+parentent.GetIndex(),0);
		}

		Printer(player,CmdMessages.Prop.SuccessParented("door",ent));
	}
	else
	{
		Printer(player,CmdMessages.Prop.SuccessDoor(ent));
	}
}

::AdminSystem.GiveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
			LookingSurvivor.Give(Weapon);
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Give(Weapon);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Give(Weapon);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Give(Weapon);
		}
		else
		{
			if ( Weapon )
			{
				if ( !Target )
					return;
				
				Target.Give(Weapon);
			}
			else
				player.Give(Survivor);
		}
	}
}

::AdminSystem.RemoveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			if ( Weapon >= "0" && Weapon <= "5" )
				LookingSurvivor.DropWeaponSlot(Weapon.tointeger());
			else
				LookingSurvivor.Remove(Weapon);
		}
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else
		{
			if ( Weapon )
			{
				if ( !Target )
					return;
				
				if ( Weapon >= "0" && Weapon <= "5" )
					Target.DropWeaponSlot(Weapon.tointeger());
				else
					Target.Remove(Weapon);
			}
			else
			{
				if ( Survivor >= "0" && Survivor <= "5" )
					player.DropWeaponSlot(Survivor.tointeger());
				else
					player.Remove(Survivor);
			}
		}
	}
}

::AdminSystem.DropCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Weapon )
	{
		if ( Weapon >= "0" && Weapon <= "5" )
			Weapon = Weapon.tointeger();
	}
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			if ( Weapon )
				LookingSurvivor.Drop(Weapon);
			else
				LookingSurvivor.Drop();
		}
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( Weapon )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( Weapon )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				if ( Weapon )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else
		{
			if ( Weapon )
			{
				if ( !Target )
					return;
				
				Target.Drop(Weapon);
			}
			else
			{
				if ( Survivor )
				{
					if ( Target )
						Target.Drop();
					else
					{
						if ( Survivor >= "0" && Survivor <= "5" )
							player.Drop(Survivor.tointeger());
						else
							player.Drop(Survivor);
					}
				}
				else
					player.Drop();
			}
		}
	}
}

::AdminSystem.SurvivorCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	else
	{
		Utils.SpawnSurvivor(null, EyePosition);
		return;
	}
	
	function FakeZoeyResponses( args )
	{
		local zoey = Utils.GetPlayerFromName("Survivor");
		if (!zoey)
			return;
		
		zoey.Input("AddContext", "who:TeenGirl:0");
	}
	
	if ( Survivor == "bill" )
		Utils.SpawnSurvivor(BILL, EyePosition);
	else if ( Survivor == "zoey" )
	{
		Utils.SpawnSurvivor(ZOEY, EyePosition, QAngle( 0, 0, 0 ), 9);
		Timers.AddTimer(0.1, false, FakeZoeyResponses);
	}
	else if ( Survivor == "francis" )
		Utils.SpawnSurvivor(FRANCIS, EyePosition);
	else if ( Survivor == "louis" )
		Utils.SpawnSurvivor(LOUIS, EyePosition);
	else if ( Survivor == "all" )
	{
		Utils.SpawnSurvivor(BILL, EyePosition);
		Utils.SpawnSurvivor(ZOEY, EyePosition, QAngle( 0, 0, 0 ), 9);
		Utils.SpawnSurvivor(FRANCIS, EyePosition);
		Utils.SpawnSurvivor(LOUIS, EyePosition);
		Timers.AddTimer(0.1, false, FakeZoeyResponses);
	}
}

::AdminSystem.L4D1SurvivorCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "bill" )
		Utils.SpawnL4D1Survivor(BILL, EyePosition);
	else if ( Survivor == "zoey" )
		Utils.SpawnL4D1Survivor(ZOEY, EyePosition);
	else if ( Survivor == "francis" )
		Utils.SpawnL4D1Survivor(FRANCIS, EyePosition);
	else if ( Survivor == "louis" )
		Utils.SpawnL4D1Survivor(LOUIS, EyePosition);
	else if ( Survivor == "all" )
	{
		Utils.SpawnL4D1Survivor(BILL, EyePosition);
		Utils.SpawnL4D1Survivor(ZOEY, EyePosition);
		Utils.SpawnL4D1Survivor(FRANCIS, EyePosition);
		Utils.SpawnL4D1Survivor(LOUIS, EyePosition);
	}
}

::AdminSystem.ClientCmd <- function ( player, args )
{
	local Command = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.BroadcastClientCommand(Utils.CombineArray(args));
}

::AdminSystem.ConsoleCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local Command = GetArgument(1);
	local Value = GetArgument(2);

	SendToServerConsole(Utils.CombineArray(args));
}

/*
 * @authors rhino
 * Get or set convar of server
 */
::AdminSystem.CvarCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ) || !AdminSystem.HasScriptAuth(player))
		return;

	local Cvar = GetArgument(1);
	local Value = GetArgument(2);
	
	if(Cvar == null)
		return;

	local oldval = "unknown";
	try
	{
		oldval = Convars.GetFloat(Cvar);
	}
	catch(err1)
	{
		try
		{
			oldval = Convars.GetStr(Cvar);
		}
		catch(err2)
		{
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Failed to get "+Cvar,true,"error",true,false);
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->err1 "+err1,true,"error",false,false);
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->err2 "+err2,true,"error",false,true);
			return;
		}
	}
	// TO-DO printer
	if(Value == null)
	{
		if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
		{
			ClientPrint(null,3,"\x04"+player.GetCharacterNameLower()+"->Current value of "+Cvar+" is "+oldval);
		}
		else
		{
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Current value of "+Cvar+" is "+oldval,true,"info",true,true);
		}
		return;
	}

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		ClientPrint(null,3,"\x04"+player.GetCharacterNameLower()+"->Changed "+Cvar+" from "+oldval+" to "+Value);
	}
	else
	{
		printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Changed "+Cvar+" from "+oldval+" to "+Value,true,"info",true,true);
	}

	if ( Cvar && Value )
		Convars.SetValue( Cvar, Value );
	
}

/*
 * @authors rhino
 * Get or set convar of an entity
 */
::AdminSystem.EntCvarCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ) || !AdminSystem.HasScriptAuth(player))
		return;
	
	local ent = GetArgument(1);
	local Cvar = GetArgument(2);
	local Value = GetArgument(3);
	
	if(ent == null || Cvar == null)
		return;

	if(ent == "!picker")
		ent = player.GetLookingEntity().GetBaseEntity();
	else if(ent == "!self")
		ent = player.GetBaseEntity();
	else if(Ent(ent))
		ent = Ent(ent);
	else
		return;

	local oldval = "unknown";
	local index = null;
	try
	{	
		index = ent.GetEntityIndex().tointeger();
		oldval = Convars.GetClientConvarValue(Cvar,index);
		
		if(oldval == null || oldval == "")
			throw("Couldn't get as client convar");
	}
	catch(err1)
	{
		printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Failed to get "+Cvar+" of ent(#"+index+")",true,"error",true,false);
		printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->err1 "+err1,true,"error",false,true);
		return;
	}
	
	// TO-DO printer
	if(Value == null)
	{
		if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
		{
			ClientPrint(null,3,"\x04"+player.GetCharacterNameLower()+"->Current value of "+Cvar+" on ent(#"+index+") is "+oldval);
		}
		else
		{
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Current value  of "+Cvar+" on ent(#"+index+") is "+oldval,true,"info",true,true);
		}
		return;
	}

	local playername = player.GetCharacterName();
	try
	{
		AdminSystem._Clientbroadcast(playername,Cvar+" "+Value,1,false);

		if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
		{
			ClientPrint(null,3,"\x04"+player.GetCharacterNameLower()+"->Attempting to change "+Cvar+" of ent(#"+index+") from "+oldval+" to "+Value);
		}
		else
		{
			printB(player.GetCharacterName(),player.GetCharacterNameLower()+"->Attempting to change "+Cvar+" of ent(#"+index+") from "+oldval+" to "+Value,true,"info",true,true);
		}
	}
	catch(err1)
	{	
		printB(playername,"==================debug======================",true,"debug",true,false);
		printB(playername,"Name-> "+ ent.GetName(),true,"debug",false,false);
		printB(playername,"Index-> "+ ent.GetEntityIndex(),true,"debug",false,false);
		printB(playername,"Parent-> "+ ent.GetMoveParent(),true,"debug",false,false);

		ent = ::VSLib.Entity(ent);

		printB(playername,"==================flags======================",true,"debug",false,false);
		printB(playername,"SpawnFlags-> "+ ent.GetNetProp( "m_spawnflags" ),true,"debug",false,false);
		printB(playername,"Flags-> "+ ent.GetNetProp( "m_fFlags" ) +"| EFlags-> " + ent.GetNetProp( "m_iEFlags" )+"| Sense flags-> "+ ent.GetSenseFlags(),true,"debug",false,false);

		printB(playername,"==================errors=====================",true,"debug",false,false);

		printB(playername,playername.tolower()+"->Failed to change "+Cvar+" of ent(#"+index+") from "+oldval+" to "+Value,true,"error",false,false);
		printB(playername,playername.tolower()+"->err1 "+err1,true,"error",false,true);
	}
	
}

/*
 * @authors rhino
 * Teleport the entity from the given index to aimed location
 */
::AdminSystem.EntTeleportCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local id = GetArgument(1);
	local ent = Ent(id);

	if(ent != null)
		ent.SetOrigin(player.GetLookingLocation());
	else
		return;

	local name = player.GetCharacterName();

	Printer(player,CmdMessages.Force.TeleportSuccess(id,player.GetLookingLocation()));
}

::AdminSystem.EntFireCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local Entnameid = GetArgument(1);
	local Action = GetArgument(2);
	local Value = GetArgument(3);
	local Value2 = GetArgument(4);
	local Value3 = GetArgument(5);
	local Entity = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if(Action.tolower() == "addoutput")
	{
		if(!AdminSystem.HasScriptAuth(player))
			return;
	}

	local val = "";
	if (Value && Value2 && Value3)
		val = Value + " " + Value2 + " " + Value3;
	else if (Value && Value2)
		val = Value + " " + Value2;
	else if (Value)
		val = Value;
	
	if ( Entnameid == "!picker" )
	{
		if ( Entity )
		{
			if (Entity.GetClassname() == "player" && Action == "kill" && Entity.GetSteamID() !="BOT" && AdminSystem.Vars.IgnoreDeletingPlayers)
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to kick player:"+Entity.GetName());
				return;
			}
			else if (Entity.GetClassname() == "player" && Action == "becomeragdoll")
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to make player ragdoll:"+Entity.GetName());
				return;
			}
			else
			{
				if(Action == "kill")
				{
					foreach(tbl in AdminSystem.Vars._heldEntity)
					{
						if(tbl.entid == Entity.GetIndex().tostring())
						{
							printl(player.GetCharacterNameLower()+"->Ignore attempt to kill entity #"+Entity.GetIndex().tostring()+" held by a player");
							return;
						}
					}
					
					foreach(tbl in AdminSystem.Vars._wornHat)
					{
						if(tbl.entid.tostring() == Entity.GetIndex().tostring())
						{
							printl(player.GetCharacterNameLower()+"->Ignore attempt to kill hat entity #"+Entity.GetIndex().tostring()+" worn by a player");
							return;
						}
					}
				}
				Entity.Input( Action, val );
			}
		}
	}
	else if ( Entnameid == "!self" )
	{
		Entity = player;
		player.Input( Action, val );
	}
	else
	{	
		if(Entnameid.find("#") != null || Entnameid.find("_") != null)
		{
			Entity = ::VSLib.Entity(Ent(Entnameid))
			Entity.Input( Action, val );
		}
		else if ( Target )
		{
			printl("Applied ent_fire to self:"+player.GetCharacterName());
			Target.Input( Action, val );
		}
		else
			g_MapScript.EntFire( Entnameid, Action, val );
	}

	Printer(player,
			Entity == null ? CmdMessages.EntFire.Failure()
						   : CmdMessages.EntFire.Success(Action,val,Entity.GetIndex())
			);
}

/*
 * @authors rhino
 */
::AdminSystem.EntRotateCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local axis = GetArgument(1);
	local val = GetArgument(2);
	local uselocal = GetArgument(3);

	if(axis == null)
		return;
	if(val == null)
	{
		val = axis; axis = "y";
	}
	val = val.tofloat();

	local entlooked = player.GetLookingEntity();
	local newAngle = null;

	if(uselocal != null)
	{
		local name = player.GetCharacterNameLower();
		if(AdminSystem.Vars._heldEntity[name].entid == "" && AdminSystem.Vars._wornHat[name].entid == "")
			return;

		entlooked = Entity("#"+AdminSystem.Vars._heldEntity[name].entid);
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			if(AdminSystem.Vars._wornHat[name].entid != "")
				entlooked = Entity("#"+AdminSystem.Vars._wornHat[name].entid);
			else
				return;
		}
		//entlooked.Input("sleep","",0)
		newAngle = entlooked.GetLocalAngles();
		if( axis == "x" )
		{	
			newAngle.x += val;
			entlooked.SetLocalAngles(newAngle);
		}
		else if ( axis == "z")
		{
			newAngle.z += val;
			entlooked.SetLocalAngles(newAngle);
		}
		else
		{
			newAngle.y += val;
			entlooked.SetLocalAngles(newAngle);
		}

		Printer(player,CmdMessages.Force.RotateSuccess(entlooked.GetIndex(),newAngle));
	}
	else if(entlooked)
	{	
		//entlooked.Input("sleep","",0)
		newAngle = entlooked.GetLocalAngles();
		if(entlooked.GetParent() == null)
		{
			if( axis == "x" )
			{	
				newAngle.x += val;
				entlooked.SetLocalAngles(newAngle);
				entlooked.SetForwardVector(newAngle.Forward());
			}
			else if ( axis == "z")
			{
				newAngle.z += val;
				entlooked.SetLocalAngles(newAngle);
				if(entlooked.GetClassname().find("physics") == null)
					entlooked.SetForwardVector(newAngle.Forward());
			}
			else
			{
				newAngle.y += val;
				entlooked.SetLocalAngles(newAngle);
				entlooked.SetForwardVector(newAngle.Forward());	
			}
		}
		else
		{
			if( axis == "x" )
			{	
				newAngle.x += val;
				entlooked.SetLocalAngles(newAngle);
			}
			else if ( axis == "z")
			{
				newAngle.z += val;
				entlooked.SetLocalAngles(newAngle);
			}
			else
			{
				newAngle.y += val;
				entlooked.SetLocalAngles(newAngle);
			}
		}
		
		Printer(player,CmdMessages.Force.RotateSuccess(entlooked.GetIndex(),newAngle));
	}
}

/*
 * Pushes the looked entity in the given direction
 * Directions are relative to the eyes of the player
 *
 * @authors rhino
 */
::AdminSystem.EntPushCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local scalefactor = GetArgument(1);
	local direction = GetArgument(2);
	local pitchofeye = GetArgument(3);

	if(scalefactor == null)
	{
		scalefactor = 10;
	}
	else
	{
		scalefactor = scalefactor.tofloat();
	}

	if(direction == null)
	{
		direction == "forward";
	}

	if(pitchofeye == null)
	{
		pitchofeye = 0;
	}
	else
	{
		if(direction != "random")
			pitchofeye = pitchofeye.tofloat()*-1;
	}

	local entlooked = player.GetLookingEntity();
	if(entlooked)
	{	
		if(entlooked.GetParent() != null)
		{
			printl(player.GetCharacterNameLower()+"->Ignore attempt to push parented entity #"+entlooked.GetIndex().tostring()+", parent #"+entlooked.GetParent().GetIndex());
			return;
		}

		local newangs = null
		if(direction == "random" )
			newangs = QAngle(rand()%360,rand()%360,rand()%360);
		else
			newangs = QAngle(pitchofeye,0,0);
			
		local fwvec = RotateOrientation(player.GetEyeAngles(),newangs).Forward();
		local temp = Vector(fwvec.x,fwvec.y,fwvec.z);

		if(direction == "backward")
		{	
			fwvec.z *= -1;
			fwvec.y *= -1;
			fwvec.x *= -1;
		}
		else if(direction == "left")
		{	
			fwvec.x = -temp.y;
			fwvec.y = temp.x;
			fwvec.z = 0;
		}
		else if(direction == "right")
		{
			fwvec.x = temp.y;
			fwvec.y = -temp.x;
			fwvec.z = 0;
		}
		else if(direction == "up")
		{
			fwvec.z = 1;
			fwvec.y = 0;
			fwvec.x = 0;
		}
		else if(direction == "down")
		{
			fwvec.z = -1;
			fwvec.y = 0;
			fwvec.x = 0;
		}
			
		fwvec = fwvec.Scale(scalefactor.tofloat()/fwvec.Length());

		entlooked.Push(fwvec);
		
		Printer(player,CmdMessages.Force.PushSuccess(entlooked.GetIndex(),scalefactor,direction,pitchofeye));
	}
}

/*
 * @authors rhino
 */
::AdminSystem.EntMoveCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local units = GetArgument(1);
	local direction = GetArgument(2);
	local pitchofeye = GetArgument(3);
	local uselocal = GetArgument(4);

	if(units == null)
	{
		units = 1;
	}
	else
	{
		units = units.tofloat();
	}

	if(direction == null)
	{
		direction == "forward";
	}

	if(pitchofeye == null)
	{
		pitchofeye = 0;
	}
	else
	{
		pitchofeye = pitchofeye.tofloat()*-1;
	}

	local entlooked = player.GetLookingEntity();
	
	if(uselocal != null)
	{
		if(AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid == "" && AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].entid == "")
			return;

		entlooked = Entity("#"+AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid);
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			if(AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].entid != "")
				entlooked = Entity("#"+AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].entid);
			else
				return;
		}
		local fwvec =  entlooked.GetLocalOrigin();
		local entpos = entlooked.GetLocalOrigin();
		if(direction == "backward")
		{	
			fwvec.z *= -1;
			fwvec.y *= -1;
			fwvec.x *= -1;
		}
		else if(direction == "left")
		{	
			fwvec.x = -entpos.y;
			fwvec.y = entpos.x;
			fwvec.z = 0;
		}
		else if(direction == "right")
		{
			fwvec.x = entpos.y;
			fwvec.y = -entpos.x;
			fwvec.z = 0;
		}
		else if(direction == "up")
		{
			fwvec.z = units;
			fwvec.y = 0;
			fwvec.x = 0;
		}
		else if(direction == "down")
		{
			fwvec.z = -units;
			fwvec.y = 0;
			fwvec.x = 0;
		}
		
		fwvec = fwvec.Scale(units/fwvec.Length());
		entlooked.SetLocalOrigin(Vector(entpos.x+fwvec.x,entpos.y+fwvec.y,entpos.z+fwvec.z));
		Printer(player,CmdMessages.Force.MoveSuccess(entlooked.GetIndex(),units,direction,pitchofeye));
	}
	else if(entlooked)
	{	
		if(entlooked.GetParent() != null)
		{
			local fwvec = RotateOrientation(player.GetEyeAngles(),QAngle(pitchofeye,0,0)).Forward();
			local temp = Vector(fwvec.x,fwvec.y,0);

			local entpos = entlooked.GetLocalOrigin();

			if(direction == "backward")
			{	
				fwvec.z *= -1;
				fwvec.y *= -1;
				fwvec.x *= -1;
			}
			else if(direction == "left")
			{	
				fwvec.x = -temp.y;
				fwvec.y = temp.x;
				fwvec.z = 0;
			}
			else if(direction == "right")
			{
				fwvec.x = temp.y;
				fwvec.y = -temp.x;
				fwvec.z = 0;
			}
			else if(direction == "up")
			{
				fwvec.z = units;
				fwvec.y = 0;
				fwvec.x = 0;
			}
			else if(direction == "down")
			{
				fwvec.z = -units;
				fwvec.y = 0;
				fwvec.x = 0;
			}
			
			fwvec = fwvec.Scale(units/fwvec.Length());
			
			entlooked.SetLocalOrigin(Vector(entpos.x+fwvec.x,entpos.y+fwvec.y,entpos.z+fwvec.z));
		}
		else
		{
			local fwvec = RotateOrientation(player.GetEyeAngles(),QAngle(pitchofeye,0,0)).Forward();
			local temp = Vector(fwvec.x,fwvec.y,0);

			local entpos = entlooked.GetPosition();

			if(direction == "backward")
			{	
				fwvec.z *= -1;
				fwvec.y *= -1;
				fwvec.x *= -1;
			}
			else if(direction == "left")
			{	
				fwvec.x = -temp.y;
				fwvec.y = temp.x;
				fwvec.z = 0;
			}
			else if(direction == "right")
			{
				fwvec.x = temp.y;
				fwvec.y = -temp.x;
				fwvec.z = 0;
			}
			else if(direction == "up")
			{
				fwvec.z = units;
				fwvec.y = 0;
				fwvec.x = 0;
			}
			else if(direction == "down")
			{
				fwvec.z = -units;
				fwvec.y = 0;
				fwvec.x = 0;
			}
			
			fwvec = fwvec.Scale(units/fwvec.Length());
			
			entlooked.SetOrigin(Vector(entpos.x+fwvec.x,entpos.y+fwvec.y,entpos.z+fwvec.z));
		}

		Printer(player,CmdMessages.Force.MoveSuccess(entlooked.GetIndex(),units,direction,pitchofeye));
		
	}
}

/*
 * @authors rhino
 */
::AdminSystem.EntSpinCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local scalefactor = GetArgument(1);
	local direction = GetArgument(2);

	if(scalefactor == null)
	{
		scalefactor = 10;
	}
	else
	{
		scalefactor = scalefactor.tofloat();
	}

	if(direction == null)
	{
		direction == "forward";
	}

	local entlooked = player.GetLookingEntity();
	if(entlooked)
	{	
		if(entlooked.GetParent() != null)
		{
			printl(player.GetCharacterNameLower()+"->Ignore attempt to spin parented entity #"+entlooked.GetIndex().tostring()+", parent #"+entlooked.GetParent().GetIndex());
			return;
		}

		local fwvec = player.GetEyeAngles().Forward();
		local temp = Vector(fwvec.x,fwvec.y,fwvec.z);

		if(direction == "backward")
		{	
			fwvec.z *= -1;
			fwvec.y *= -1;
			fwvec.x *= -1;
		}
		else if(direction == "left")
		{	
			fwvec.x = -temp.y;
			fwvec.y = temp.x;
			fwvec.z = 0;
		}
		else if(direction == "right")
		{
			fwvec.x = temp.y;
			fwvec.y = -temp.x;
			fwvec.z = 0;
		}
		else if(direction == "up")
		{
			fwvec.z = 1;
			fwvec.y = 0;
			fwvec.x = 0;
		}
		else if(direction == "down")
		{
			fwvec.z = -1;
			fwvec.y = 0;
			fwvec.x = 0;
		}
			
		fwvec = fwvec.Scale(scalefactor/fwvec.Length());

		entlooked.Spin(fwvec);

		Printer(player,CmdMessages.Force.SpinSuccess(entlooked.GetIndex(),scalefactor,direction));
	}
}

::AdminSystem.TimescaleCmd <- function ( player, args )
{
	local DesiredTimeScale = GetArgument(1);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( DesiredTimeScale == "slow" )
	{
		Utils.ResumeTime();
		Utils.SlowTime(0.5, 2.0, 1.0, 2.0, false);
	}
	else if ( DesiredTimeScale == "fast" )
	{
		Utils.ResumeTime();
		Utils.SlowTime(1.5, 2.0, 1.0, 2.0, false);
	}
	else if ( DesiredTimeScale == "normal" || DesiredTimeScale == "resume" )
		Utils.ResumeTime();
	else
	{
		DesiredTimeScale = DesiredTimeScale.tofloat();
		if ( DesiredTimeScale < 0.1 )
		{
			if ( AdminSystem.DisplayMsgs )
				Messages.ThrowPlayer(player,CmdMessages.TimeScale.ScaleTooSmall());
			return;
		}
		else if ( DesiredTimeScale > 10.0 )
		{
			if ( AdminSystem.DisplayMsgs )
				Messages.ThrowPlayer(player,CmdMessages.TimeScale.ScaleTooHigh());
			return;
		}
		Utils.ResumeTime();
		Utils.SlowTime(DesiredTimeScale, 2.0, 1.0, 2.0, false);
	}

	Messages.InformAll(CmdMessages.TimeScale.Success(GetArgument(1)));
}

::AdminSystem.SoundCmd <- function ( player, args )
{
	local Ent = GetArgument(1);
	local Sound = GetArgument(2);
	local Name = GetArgument(3);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Sound )
	{
		if ( Ent == "all" )
		{
			foreach(survivor in Players.Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( Sound == "stop" || Sound == "off" )
				{
					if ( (survivorID in ::AdminSystem.SoundName) )
					{
						if ( Name )
							survivor.StopSound(Name);
						else
							survivor.StopSound(AdminSystem.SoundName[survivorID]);
					}
				}
				else
				{
					survivor.PlaySound(Sound);
					AdminSystem.SoundName[survivorID] <- Sound;
				}
			}
		}
		else if ( Ent == "stop" || Ent == "off" )
			player.StopSound(Sound);
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( Sound == "stop" || Sound == "off" )
			{
				if ( (targetID in ::AdminSystem.SoundName) )
				{
					if ( Name )
						Target.StopSound(Name);
					else
						Target.StopSound(AdminSystem.SoundName[targetID]);
				}
			}
			else
			{
				Target.PlaySound(Sound);
				AdminSystem.SoundName[targetID] <- Sound;
			}
		}
	}
	else
	{
		if ( Ent.find(".wav") != null || Ent.find(".mp3") != null )
			Utils.PlaySound(Ent);
		else
		{
			if ( Ent == "stop" || Ent == "off" )
			{
				if ( (ID in ::AdminSystem.SoundName) )
					player.StopSound(AdminSystem.SoundName[ID]);
			}
			else
			{
				player.PlaySound(Ent);
				AdminSystem.SoundName[ID] <- Ent;
			}
		}
	}
}

::AdminSystem.UseCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Entity = GetArgument(2);
	local LookingEntity = player.GetLookingEntity();
	local ent = null;
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Entity )
	{
		Entity = Entity.tolower();
		
		ent = Entities.FindByName( null, Entity );
		
		if ( !ent )
			ent = Entities.FindByClassname( null, Entity );
		
		if ( !ent )
			return;
		
		ent = ::VSLib.Entity(ent);
		
		foreach(survivor in Players.AliveSurvivors())
		{
			local t = survivor.GetHeldItems();
	
			if (t)
			{
				foreach (item in t)
				{
					if ( item.GetEntityHandle() == ent.GetEntityHandle() )
					{
						printl("Survivor holding entity, returning...");
						return;
					}
				}
			}
		}
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Use(ent);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Use(ent);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Use(ent);
		}
		else
		{
			if ( Survivor )
			{
				if ( !Target )
					return;
				
				Target.Use(ent);
			}
			else
				player.Use(ent);
		}
	}
	else
	{
		if ( Survivor )
		{
			ent = Entities.FindByName( null, Survivor );
			
			if ( !ent )
				ent = Entities.FindByClassname( null, Survivor );
		}
		
		if ( ent )
		{
			player.Use(::VSLib.Entity(ent));
		}
		else
		{
			if ( !LookingEntity )
				return;
			
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.Use(LookingEntity);
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.Use(LookingEntity);
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.Use(LookingEntity);
			}
			else
			{
				if ( Survivor )
				{
					if ( !Target )
						return;
					
					Target.Use(LookingEntity);
				}
				else
					player.Use(LookingEntity);
			}
		}
	}
}

::AdminSystem.SpeakCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Scene = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
			LookingSurvivor.Speak(Scene);
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Speak(Scene);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Speak(Scene);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Speak(Scene);
		}
		else
		{
			if ( Scene )
			{
				Target.Speak(Scene);
			}
			else
				player.Speak(Survivor);
		}
	}
}

::AdminSystem.ReviveCountCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ReviveCount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( ReviveCount )
		ReviveCount = ReviveCount.tointeger();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetReviveCount(ReviveCount);
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetReviveCount(ReviveCount);
	}
	else
	{
		if ( ReviveCount )
		{
			if ( !Target )
				return;
			
			Target.SetReviveCount(ReviveCount);
		}
		else
			player.SetReviveCount(Survivor.tointeger());
	}
}

::AdminSystem.ReviveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Revive();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Revive();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Revive();
		}
		else
			player.Revive();
	}
}

::AdminSystem.DefibCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
			survivor.Defib();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
			survivor.Defib();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Defib();
		}
		else
			player.Defib();
	}
}

::AdminSystem.RescueCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
			survivor.Rescue();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
			survivor.Rescue();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Rescue();
		}
		else
			player.Rescue();
	}
}

::AdminSystem.IncapCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.SetHealthBuffer(0);
				survivor.Input( "SetHealth", "0" );
			}
		}
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.SetHealthBuffer(0);
				survivor.Input( "SetHealth", "0" );
			}
		}
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( Target );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				Target.SetHealthBuffer(0);
				Target.Input( "SetHealth", "0" );
			}
		}
		else
		{
			local ID = AdminSystem.GetID( player );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			player.SetHealthBuffer(0);
			player.Input( "SetHealth", "0" );
		}
	}
}

::AdminSystem.KillCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.Kill();
			}
		}
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.Kill();
			}
		}
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
		{
			local ID = AdminSystem.GetID( boomer );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			boomer.Kill();
		}
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
		{
			local ID = AdminSystem.GetID( charger );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			charger.Kill();
		}
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
		{
			local ID = AdminSystem.GetID( infected );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			infected.Kill();
		}
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
		{
			local ID = AdminSystem.GetID( hunter );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			hunter.Kill();
		}
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
		{
			local ID = AdminSystem.GetID( jockey );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			jockey.Kill();
		}
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
		{
			local ID = AdminSystem.GetID( smoker );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			smoker.Kill();
		}
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
		{
			local ID = AdminSystem.GetID( spitter );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			spitter.Kill();
		}
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
		{
			local ID = AdminSystem.GetID( tank );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			tank.Kill();
		}
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
		{
			local ID = AdminSystem.GetID( witch );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			witch.Kill();
		}
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( Target );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				Target.Kill();
			}
		}
		else
		{
			if ( player.GetTeam() == SURVIVORS )
			{
				if ( Convars.GetFloat("god") == 0 )
				{
					local ID = AdminSystem.GetID( player );
					if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
						AdminSystem.Vars.IsGodEnabled[ID] <- false;
					player.Kill();
				}
			}
			else
			{
				local ID = AdminSystem.GetID( player );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				player.Kill();
			}
		}
	}
}

::AdminSystem.HurtCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Entity = Entity.tointeger();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Damage(Amount);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Damage(Amount);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Damage(Amount);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Damage(Amount);
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Damage(Amount);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Damage(Amount);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Damage(Amount);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Damage(Amount);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Damage(Amount);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Damage(Amount);
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Damage(Amount);
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.Damage(Amount);
		}
		else
		{
			player.Damage(Entity);
		}
	}
}

::AdminSystem.RespawnCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Location = player.GetLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
		{
			local SurvivorSpawnPos = survivor.GetSpawnLocation();
			
			survivor.Defib();
			if ( player.IsAlive() )
				survivor.SetLocation(Location);
			else
				survivor.SetLocation(SurvivorSpawnPos);
		}
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
		{
			local SurvivorSpawnPos = survivor.GetSpawnLocation();
			
			survivor.Defib();
			if ( player.IsAlive() )
				survivor.SetLocation(Location);
			else
				survivor.SetLocation(SurvivorSpawnPos);
		}
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			if ( !Target.IsAlive() )
			{
				Target.Defib();
				if ( player.IsAlive() )
					Target.SetLocation(Location);
				else
					Target.SetLocation(Target.GetSpawnLocation());
			}
		}
		else
		{
			if ( !player.IsAlive() )
			{
				local SpawnPos = player.GetSpawnLocation();
				player.Defib();
				player.SetLocation(SpawnPos);
			}
		}
	}
}

::AdminSystem.ExtinguishCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Extinguish();
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Extinguish();
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Extinguish();
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Extinguish();
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Extinguish();
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Extinguish();
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Extinguish();
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Extinguish();
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Extinguish();
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Extinguish();
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Extinguish();
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			Target.Extinguish();
		}
		else
			player.Extinguish();
	}
}

::AdminSystem.IgniteCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Input( "IgniteLifeTime", "999999" );
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			Target.Input( "IgniteLifeTime", "999999" );
		}
		else
			player.Input( "IgniteLifeTime", "999999" );
	}
}

::AdminSystem.VomitCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Vomit();
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Vomit();
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Vomit();
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.Vomit();
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.Vomit();
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.Vomit();
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.Vomit();
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.Vomit();
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.Vomit();
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.Vomit();
		}
		else
		{
			if ( !Target )
				return;
			
			Target.Vomit();
		}
	}
	else
	{
		player.Vomit();
	}
}

::AdminSystem.StaggerCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Away = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Away )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.StaggerAwayFromEntity(player);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.StaggerAwayFromEntity(player);
		}
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Stagger();
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Stagger();
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.Stagger();
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.Stagger();
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.Stagger();
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.Stagger();
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.Stagger();
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.Stagger();
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.Stagger();
		}
		else
		{
			if ( Survivor )
			{
				if ( !Target )
					return;
				
				Target.Stagger();
			}
			else
				player.Stagger();
		}
	}
}

::AdminSystem.WarpCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local OtherSurvivor = GetArgument(2);
	local Location = player.GetLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Target2 = Utils.GetPlayerFromName(GetArgument(2));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( OtherSurvivor )
		{
			OtherSurvivor = OtherSurvivor.tolower();
			
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else
			{
				if ( !Target || !Target2 )
					return;
				
				Target.SetLocation(Target2.GetLocation());
			}
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "boomer" )
			{
				foreach(boomer in Players.OfType(Z_BOOMER))
					boomer.SetLocation(Location);
			}
			else if ( Survivor == "charger" )
			{
				foreach(charger in Players.OfType(Z_CHARGER))
					charger.SetLocation(Location);
			}
			else if ( Survivor == "hunter" )
			{
				foreach(hunter in Players.OfType(Z_HUNTER))
					hunter.SetLocation(Location);
			}
			else if ( Survivor == "jockey" )
			{
				foreach(jockey in Players.OfType(Z_JOCKEY))
					jockey.SetLocation(Location);
			}
			else if ( Survivor == "smoker" )
			{
				foreach(smoker in Players.OfType(Z_SMOKER))
					smoker.SetLocation(Location);
			}
			else if ( Survivor == "spitter" )
			{
				foreach(spitter in Players.OfType(Z_SPITTER))
					spitter.SetLocation(Location);
			}
			else if ( Survivor == "tank" )
			{
				foreach(tank in Players.OfType(Z_TANK))
					tank.SetLocation(Location);
			}
			else
			{
				if ( !Target )
					return;
				
				Target.SetLocation(Location);
			}
		}
	}
	else
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetLocation(Location);
	}
}

::AdminSystem.WarpHereCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.SetLocation(EyePosition);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.SetLocation(EyePosition);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.SetLocation(EyePosition);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.SetLocation(EyePosition);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.SetLocation(EyePosition);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.SetLocation(EyePosition);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.SetLocation(EyePosition);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SetLocation(EyePosition);
		}
	}
	else
	{
		player.SetLocation(EyePosition);
	}
}

::AdminSystem.WarpSaferoomCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Saferoom = Utils.GetSaferoomLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Saferoom == null )
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.SetLocation(Saferoom);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.SetLocation(Saferoom);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.SetLocation(Saferoom);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.SetLocation(Saferoom);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.SetLocation(Saferoom);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.SetLocation(Saferoom);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.SetLocation(Saferoom);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SetLocation(Saferoom);
		}
	}
	else
	{
		player.SetLocation(Saferoom);
	}
}

::AdminSystem.AmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Amount )
		Amount = Amount.tointeger();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.GiveAmmo(Amount);
	}
	else if ( Survivor == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.GiveAmmo(Amount);
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.GiveAmmo(Amount);
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.GiveAmmo(Amount);
		}
		else
			player.GiveAmmo(Survivor.tointeger());
	}
}

::AdminSystem.UpgradeAddCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Upgrade = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Upgrade )
		Upgrade = Upgrade.tolower();
	
	if ( Upgrade == "laser_sight" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
		}
	}
	else if ( Upgrade == "explosive_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
		}
	}
	else if ( Upgrade == "incendiary_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
		}
	}
	else
	{
		if ( Survivor == "laser_sight" )
		{
			player.GiveUpgrade( UPGRADE_LASER_SIGHT );
		}
		else if ( Survivor == "explosive_ammo" )
		{
			player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
		}
		else if ( Survivor == "incendiary_ammo" )
		{
			player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
		}
		else
		{
			if ( AdminSystem.DisplayMsgs )
				Messages.ThrowPlayer(player,"Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
		}
	}
}

::AdminSystem.UpgradeRemoveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Upgrade = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Upgrade )
		Upgrade = Upgrade.tolower();
	
	if ( Upgrade == "laser_sight" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
		}
	}
	else if ( Upgrade == "explosive_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
		}
	}
	else if ( Upgrade == "incendiary_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
		}
	}
	else
	{
		if ( Survivor == "laser_sight" )
		{
			player.RemoveUpgrade( UPGRADE_LASER_SIGHT );
		}
		else if ( Survivor == "explosive_ammo" )
		{
			player.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
		}
		else if ( Survivor == "incendiary_ammo" )
		{
			player.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
		}
		else
		{
			if ( AdminSystem.DisplayMsgs )
				Messages.ThrowPlayer(player,"Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
		}
	}
}

::AdminSystem.NetPropCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Property = GetArgument(2);
	local Value = GetArgument(3);
	local LookingEntity = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Value )
	{
		if ( Value.tolower() == "true" )
			Value = 1;
		else if ( Value.tolower() == "false" )
			Value = 0;
		
		if ( Entity == "!picker" )
		{
			if ( LookingEntity != null )
			{
				if ( LookingEntity.GetNetPropType( Property ) == "integer" )
					Value = Value.tointeger();
				else if ( LookingEntity.GetNetPropType( Property ) == "float" )
					Value = Value.tofloat();
				
				LookingEntity.SetNetProp( Property, Value );
			}
			else
				return;
		}
		else
		{
			if ( Entity == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else if ( Entity == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else if ( Entity == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else
			{
				if ( !Target )
					return;
				
				if ( Target.GetNetPropType( Property ) == "integer" )
					Value = Value.tointeger();
				else if ( Target.GetNetPropType( Property ) == "float" )
					Value = Value.tofloat();
				
				Target.SetNetProp( Property, Value );
			}
		}
	}
	else
	{
		if ( Property.tolower() == "true" )
			Property = 1;
		else if ( Property.tolower() == "false" )
			Property = 0;
		
		if ( player.GetNetPropType( Entity ) == "integer" )
			Property = Property.tointeger();
		else if ( player.GetNetPropType( Entity ) == "float" )
			Property = Property.tofloat();
		
		player.SetNetProp( Entity, Property );
	}
}

::AdminSystem.FrictionCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Value )
		Value = Value.tofloat();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetFriction(Value);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetFriction(Value);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetFriction(Value);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetFriction(Value);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetFriction(Value);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetFriction(Value);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetFriction(Value);
	}
	else
	{
		if ( Value )
		{
			if ( !Target )
				return;
			
			Target.SetFriction(Value);
		}
		else
			player.SetFriction(Entity.tofloat());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.RainbowCmd <- function(player, args)
{	
	//// ARGUMENT CHECKS
	if (!AdminSystem.IsPrivileged( player ))
		return;

	// ARG 1 = duration
	local duration = GetArgument(1);
	if(duration == null)
		duration = 12.0;
	else
		duration = duration.tofloat();

	if(duration < 0.0 || duration > 300.0)	
		return;	// too long duration
	
	// ARG 2 = intervals
	local intervals = GetArgument(2);
	if(intervals == null)
		intervals = 0.15;
	else
		intervals = intervals.tofloat();

	if(intervals < 0.05 || intervals > duration)
		return; // too frequent changes

	if(duration/intervals > 2000)	
		return;	// too many changes

	// ARG 3 = !picker
	local entlooked = player.GetLookingEntity();
	if(entlooked == null)	
		return;

	////////////////////////////////////

	local t = intervals*(-7.0);
	local last_t = 0.0;
	local clr = entlooked.GetNetProp("m_clrRender");
	//out("start:"+clr);
	function color_seq()
	{
		entlooked.InputColor(255, 0, 0,t+intervals);
		entlooked.InputColor(255, 127, 0,t+intervals*2.0);
		entlooked.InputColor(255,255, 0,t+intervals*3.0);
		entlooked.InputColor(0, 255, 0,t+intervals*4.0);
		entlooked.InputColor(0, 0, 255,t+intervals*5.0);
		entlooked.InputColor(46, 43, 95,t+intervals*6.0);
		last_t = t+intervals*7.0;
		entlooked.InputColor(139, 0, 255,last_t);

		if(t<duration)
		{
			t+=intervals*7.0;
			color_seq();
		}
		else
		{
			//out("dur:"+(last_t+intervals*7.0+0.4));
			Timers.AddTimer(last_t+intervals*7.0+0.4, false, ColorResetWrap, {ent=entlooked,clr=clr});
		}
	}

	color_seq();	// Loop starter

	Printer(player,CmdMessages.RainbowSuccess(duration,intervals,entlooked.GetIndex()));
}
::ColorResetWrap <- function(args)
{
	//out("curr:"+args.ent.GetNetProp("m_clrRender"));
	args.ent.SetNetProp("m_clrRender",args.clr);
}
/*
 * @authors rhino
 */
::AdminSystem.Update_print_output_stateCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._outputsEnabled[name];
	AdminSystem.Vars._outputsEnabled[name] = newstate;

	Messages.InformPlayer(player,CmdMessages.OutputState(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Randomline_save_lastCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._saveLastLine[name];
	AdminSystem.Vars._saveLastLine[name] = newstate;

	Printer(player,CmdMessages.LineSaving.State(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Save_lineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local targetname = GetArgument(1);
	local linesource = GetArgument(2);
	if ( linesource == null)
	{
		return;
	}
	
	AdminSystem.Vars._savedLine[name].target = targetname;
	AdminSystem.Vars._savedLine[name].source = linesource;

	Printer(player,CmdMessages.LineSaving.Success(targetname,linesource));
}

/*
 * @authors rhino
 */
::AdminSystem.Speak_savedCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local lineinfo = AdminSystem.Vars._savedLine[name];
	if (lineinfo.target != "")
	{
		Utils.GetPlayerFromName(lineinfo.target).Speak(lineinfo.source);

		Printer(player,CmdMessages.LineSaving.MakeSpeak(lineinfo.target,lineinfo.source));
	}
	else
	{
		Messages.ThrowPlayer(player,CmdMessages.LineSaving.NoneSaved(name));
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.Display_saved_lineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	if (AdminSystem.Vars._saveLastLine[name])
	{	
		local lineinfo = AdminSystem.Vars._savedLine[name];
		if (lineinfo.target != "")
		{
			Printer(player,CmdMessages.LineSaving.Information(lineinfo));
		}
		else
		{
			Messages.ThrowPlayer(player,CmdMessages.LineSaving.NoneSaved(name));
		}
	}
	
}

/*
 * @authors rhino
 */
::_OutputTest <- function(msg=null)
{
	if(msg == null)
		ClientPrint(null,3,"\x5"+"Output connected!");
	else
		ClientPrint(null,3,"\x5"+msg.tostring());
}

/*
 * @authors rhino
 */
::_PrintIndexedNames <- function()
{
	foreach(i,name in ::AdminSystem.Vars.CharacterNames)
	{
		if(name == "" || name == "survivor")
			continue;
		ClientPrint(null,3,"\x3"+"AdminSystem.Vars.CharacterNames"+"["+i+"]"+"\x4"+"->"+"\x3"+name);
	}
}

::EntInfo <- function(ent, player, toconsole = false, svcheatsval = 0.0)
{
	local playername = (player == null) ? null : player.GetCharacterName();

	if(toconsole && playername != null)
	{
		printB(playername,"==================basic======================",true,"",true,false);
		printB(playername,"Name-> "+ ent.GetName(),true,"debug",false,false);
		printB(playername,"Index-> "+ ent.GetIndex(),true,"debug",false,false);
		printB(playername,"Class-> "+ ent.GetClassname(),true,"debug",false,false);
		printB(playername,"Parent->  #"+  (ent.GetParent() == null ? "No parent" : ent.GetParent().GetIndex()),true,"debug",false,false);
		printB(playername,"Model-> " + ent.GetModel(),true,"debug",false,false);
		printB(playername,"Scale-> " + ent.GetModelScale(),true,"debug",false,false);

		printB(playername,"==================flags======================",true,"debug",false,false);
		printB(playername,"SpawnFlags-> "+ ent.GetSpawnFlags(),true,"debug",false,false);
		printB(playername,"Effects-> "+ ent.GetNetProp("m_fEffects"),true,"debug",false,false);
		printB(playername,"Flags-> "+ ent.GetFlags() +" | EFlags-> " + ent.GetEFlags()+" | Sense flags-> "+ ent.GetSenseFlags(),true,"debug",false,false);

		printB(playername,"===============positional==================",true,"debug",false,false);
		printB(playername,"Location-> "+ent.GetLocation().ToKVString(),true,"debug",false,false);
		printB(playername,"Angles-> " + ent.GetAngles().ToKVString(),true,"debug",false,false);
		if(ent.GetClassname() == "player")
		{
			printB(playername,"Looking at"+"\x05"+"-> "+"\x03"+ent.GetLookingLocation().ToKVString(),true,"debug",false,false);
			printB(playername,"Eye Position"+"\x05"+"-> "+"\x03"+ent.GetEyePosition().ToKVString(),true,"debug",false,false);
			printB(playername,"Eye angles"+"\x05"+"-> "+"\x03"+ent.GetEyeAngles().ToKVString(),true,"debug",false,false);
		}
		
		printB(playername,"================physics_debug=================",true,"debug",false,false);
		AdminSystem._Clientbroadcast(playername,"physics_debug_entity",1,false);
		if(svcheatsval==1.0)
		{
			printB(playername,"==================ent_dump====================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"ent_dump !picker",1,false);
			AdminSystem._Clientbroadcast(playername,"ent_script_dump",1,false);
		}

		printB(playername,"",false,"",false,true,0.5);
	}
	else
	{
		if(player != null)
			printB(playername,"",false,"",true,false,0);
		out("=================basic==================",player);
		out("Name"+"\x05"+"-> "+"\x03"+ ent.GetName(),player);
		out("Index"+"\x05"+"-> "+"\x03"+ ent.GetIndex(),player);
		out("Class"+"\x05"+"-> "+"\x03"+ ent.GetClassname(),player);
		out("Parent #"+"\x05"+"-> "+"\x03"+ (ent.GetParent() == null ? "No parent" : ent.GetParent().GetIndex()),player);
		out("Model"+"\x05"+"-> "+"\x03" + ent.GetModel(),player);
		out("Scale"+"\x05"+"-> "+"\x03" + ent.GetModelScale(),player);

		out("=================flags===================",player);
		out("SpawnFlags"+"\x05"+"-> "+"\x03"+ ent.GetSpawnFlags(),player);
		out("Effects"+"\x05"+"-> "+"\x03"+ ent.GetNetProp("m_fEffects"),player);
		out("Flags"+"\x05"+"-> "+"\x03"+ ent.GetFlags() +" | EFlags-> " + ent.GetEFlags()+" | Sense flags-> "+ ent.GetSenseFlags(),player);

		out("===============positional=================",player);
		out("Location"+"\x05"+"-> "+"\x03"+ent.GetLocation().ToKVString(),player);
		out("Angles"+"\x05"+"-> "+"\x03" + ent.GetAngles().ToKVString(),player);

		if(ent.GetClassname() == "player")
		{
			out("Looking at"+"\x05"+"-> "+"\x03"+ent.GetLookingLocation().ToKVString(),player);
			out("Eye Position"+"\x05"+"-> "+"\x03"+ent.GetEyePosition().ToKVString(),player);
			out("Eye angles"+"\x05"+"-> "+"\x03"+ent.GetEyeAngles().ToKVString(),player);
		}
		
		if(player != null)
		{
			printB(playername,"================physics_debug=================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"physics_debug_entity",1,false);

			if(svcheatsval==1.0)
			{
				printB(playername,"=================ent_dump==================",true,"debug",false,false);
				AdminSystem._Clientbroadcast(playername,"ent_dump !picker",1,false);
				AdminSystem._Clientbroadcast(playername,"ent_script_dump",1,false);
			}
			printB(playername,"",false,"",false,true,0.5);
		}
			

	}
}

::PlayerInfo <- function(player, toconsole = false, svcheatsval = 0.0)
{
	local playername = player.GetCharacterName();

	if(toconsole)
	{
		printB(playername,"==================basic====================",true,"",true,false);
		printB(playername,"Name-> "+ player.GetName(),true,"debug",false,false);
		printB(playername,"Index-> "+ player.GetIndex(),true,"debug",false,false);
		printB(playername,"Team-> "+ player.GetTeam(),true,"debug",false,false);
		printB(playername,"Parent->  #"+  (player.GetParent() == null ? "No parent" : player.GetParent().GetIndex()),true,"debug",false,false);
		printB(playername,"Model-> " + player.GetModel(),true,"debug",false,false);
		printB(playername,"Scale-> " + player.GetModelScale(),true,"debug",false,false);

		printB(playername,"==================flags====================",true,"debug",false,false);
		printB(playername,"SpawnFlags-> "+ player.GetSpawnFlags(),true,"debug",false,false);
		printB(playername,"Effects-> "+ player.GetNetProp("m_fEffects"),true,"debug",false,false);
		printB(playername,"Flags-> "+ player.GetFlags() +" | EFlags-> " + player.GetEFlags()+" | Sense flags-> "+ player.GetSenseFlags(),true,"debug",false,false);

		printB(playername,"===============positional==================",true,"debug",false,false);
		printB(playername,"Player location-> "+player.GetPosition().ToKVString(),true,"debug",false,false);
		printB(playername,"Player angles-> "+player.GetAngles().ToKVString(),true,"debug",false,false);
		printB(playername,"Looked location-> "+player.GetLookingLocation().ToKVString(),true,"debug",false,false);
		printB(playername,"Eye location-> "+player.GetEyePosition().ToKVString(),true,"debug",false,false);
		printB(playername,"Eye angles-> "+player.GetEyeAngles().ToKVString(),true,"debug",false,false);
		printB(playername,"================player_stats===============",true,"debug",false,false);
		foreach(key,value in player.GetStats())
		{
			printB(playername,"[Stats] "+key+" -> "+value.tostring(),true,"debug",false,false);
		}

		if(svcheatsval==1.0)
		{	
			printB(playername,"=================dumpplayer===================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"cl_dumpplayer "+player.GetIndex().tostring(),1,false);
		}

		printB(playername,"",false,"",false,true,0.5);
	}
	else
	{
		out("==================basic====================",player);
		out("Name"+"\x05"+"-> "+"\x03"+ player.GetName(),player);
		out("Index"+"\x05"+"-> "+"\x03"+ player.GetIndex(),player);
		out("Team"+"\x05"+"-> "+"\x03"+ player.GetTeam(),player);
		out("Parent"+"\x05"+"-> #"+"\x03"+  (player.GetParent() == null ? "No parent" : player.GetParent().GetIndex()),player);
		out("Model"+"\x05"+"-> "+"\x03"+ player.GetModel(),player);
		out("Scale"+"\x05"+"-> "+"\x03"+ player.GetModelScale(),player);

		out("==================flags====================",player);
		out("SpawnFlags"+"\x05"+"-> "+"\x03"+ player.GetSpawnFlags(),player);
		out("Effects"+"\x05"+"-> "+"\x03"+ player.GetNetProp("m_fEffects"),player);
		out("Flags"+"\x05"+"-> "+"\x03"+ player.GetFlags() +" | EFlags-> " + player.GetEFlags()+" | Sense flags-> "+ player.GetSenseFlags(),player);

		out("===============positional==================",player);
		out("Player location"+"\x05"+"-> "+"\x03"+player.GetPosition().ToKVString(),player);
		out("Player angles"+"\x05"+"-> "+"\x03" + player.GetAngles().ToKVString(),player);
		out("Looked location"+"\x05"+"-> "+"\x03"+player.GetLookingLocation().ToKVString(),player);
		out("Eye location"+"\x05"+"-> "+"\x03"+player.GetEyePosition().ToKVString(),player);
		out("Eye angles"+"\x05"+"-> "+"\x03"+player.GetEyeAngles().ToKVString(),player);
		/*
		out(playername,"=================player_stats===================");
		foreach(key,value in player.GetStats())
		{
			out(playername,"[Stats] "+key+" -> "+value.tostring());
		}
		*/
	}
}
/*
 * @authors rhino
 */
::AdminSystem.Debug_infoCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	/*	Some dumping commands:
			blackbox_dump  : vcd and wav info
	*/
	local arg = GetArgument(1);

	local playername = player.GetCharacterName();
	local svcheatsval = Convars.GetFloat("sv_cheats");
	
	if(arg == null)
	{	
		local ent = player.GetLookingEntity();
		if (ent == null)
		{
			Printer(player,Messages.BIM.NoTraceHits(),"error");
			return;
		}
		
		EntInfo(ent,player,!AdminSystem.Vars._outputsEnabled[playername.tolower()],svcheatsval)
	}
	else if(arg == "player")
	{
		PlayerInfo(player,!AdminSystem.Vars._outputsEnabled[playername.tolower()],svcheatsval)
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.EntitiesAroundCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local aimed = player.GetLookingLocation();
	local radius = GetArgument(1);
	radius = radius == null ? 50 : radius.tofloat();
	
	local objtable = VSLib.EasyLogic.Objects.AroundRadius(aimed,radius);
	if(objtable == null)
	{
		Printer(player,"No entities within radius of "+radius+" around "+aimed.ToKVString());
	}
	else
	{
		local str = "Entity " + "\x03" + "#" + "\x01" + " and " + "\x05" + "class" + "\x01" + " within " + "\x04" + radius + " units \x01" + "\n";
		foreach(obj in objtable)
		{
			if(!obj.IsEntityValid())
			{
				continue;
			}
			str += "\x03" + "#" + obj.GetIndex() + "\x01" + ", " + "\x05" + obj.GetClassname() + (obj.GetParent() == null ? "" : ", "+"\x04"+"Parented!") +"\x01" + "\n"
		}

		Printer(player,str);
	}
}

/*
 * @authors rhino
 */
::AdminSystem.WatchNetPropCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local entlooked = player.GetLookingEntity() == null 
						? GetArgument(3) 
						: player.GetLookingEntity();
	if(entlooked == null)
	{	
		Printer(player,"No entity to watch")
		return;
	}

	if(typeof entlooked == "string")
	{
		entlooked = Entity(entlooked)
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			Printer(player,"No entity to watch")
			return;
		}
	}

	local netprop = GetArgument(1);
	if(netprop == null)
	{
		return;
	}
	
	if(!entlooked.HasNetProp(netprop))
	{
		Printer(player,"Netprop "+"\x04"+netprop+"\x01"+" doesn't exist for " + "\x03" +"#"+entlooked.GetIndex()+"\x01"+", "+"\x03"+entlooked.GetClassname());
		return;
	}

	local checksec = GetArgument(2) == null 
						? 1 
						: GetArgument(2).tofloat();
					
	if(checksec < 0.1)
	{
		Printer(player,"Watch rate too high, minimum interval length is 0.1 seconds!");
		return;
	}	

	local lastval = entlooked.GetNetProp(netprop);
	Printer(player,"\x03"+"#"+entlooked.GetIndex()+"\x01"+" "+ netprop + " -> "+ lastval);

	::VSLib.Timers.AddTimerByName(Constants.TimerNames.WatchNetProp+netprop+"_"+entlooked.GetIndex(),checksec,false,WatchNetPropMain,{player=player,checksec=checksec,player=player,ent=entlooked,netprop=netprop,lastval=lastval})
}

::WatchNetPropMain <- function(args)
{
	
	if(args.ent == null || !args.ent.IsEntityValid() || !args.player.IsEntityValid())
	{
		return;
	}

	local ind = args.ent.GetIndex();

	local currentval = args.ent.GetNetProp(args.netprop);
	if(currentval != args.lastval)
	{
		Printer(args.player,"\x03"+"#"+ind+"\x01"+" "+ args.netprop + " -> "+ currentval);
		args.lastval = currentval;
	}

	::VSLib.Timers.AddTimerByName(Constants.TimerNames.WatchNetProp+args.netprop+"_"+ind,args.checksec,false,WatchNetPropMain,args)
}

/*
 * @authors rhino
 */
::AdminSystem.StopWatchNetPropCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local entlooked = player.GetLookingEntity() == null 
						? GetArgument(2) 
						: player.GetLookingEntity();
	if(entlooked == null)
	{	
		Printer(player,"No entity to watch")
		return;
	}

	if(typeof entlooked == "string")
	{
		entlooked = Entity(entlooked)
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			Printer(player,"No entity to watch")
			return;
		}
	}

	local netprop = GetArgument(1)
	if(netprop == null)
	{
		return;
	}
	
	if(!entlooked.HasNetProp(netprop))
	{
		Printer(player,"Netprop "+"\x04"+netprop+"\x01"+" doesn't exist for " + "\x03" +"#"+entlooked.GetIndex()+"\x01"+", "+"\x03"+entlooked.GetClassname());
		return;
	}

	local ind = entlooked.GetIndex();
	local timername = Constants.TimerNames.WatchNetProp+netprop+"_"+ind;

	if(timername in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];
		Printer(player,"Removed watch for "+"\x03"+"#"+ind+" "+"\x04"+netprop)
	}
	else
	{
		Printer(player,"No watch timer found for "+"\x03"+"#"+ind+" "+"\x04"+netprop);
	}
}

/* ******************DANGEROUS FUNCTION*******************
 * @authors rhino
 * Execute commands in other's client
 */
::AdminSystem._Clientbroadcast <- function(client_character,command,kill=1,report2host=true,delay=0)
{	
	
	local client_ent = Utils.GetPlayerFromName(client_character)
	local target_is_host = (client_ent.GetSteamID() in ::AdminSystem.HostPlayer);
	
	local point_clientcommand = Utils.CreateEntityWithTable({classname = "point_clientcommand", origin = Vector(0,0,0) });
	
	// VSLib::Entity::Input(input, value = "", delay = 0, activator = null)
	// Same as : ent_fire #ID Addoutput "OnUser1 #ID,Command,params,0.1,-1" 
	point_clientcommand.Input("Addoutput","OnUser1 #"+point_clientcommand.GetIndex()+",Command,"+command+",0,1",0,null);
	point_clientcommand.Input("FireUser1","",delay,client_ent);

	if(kill.tointeger() != 0)
		point_clientcommand.Input("Kill","",delay.tofloat()+0.5);	// Kill it afterwards

	if(report2host && !target_is_host)
		printl("[Client-broadcast]Executing client command on "+client_character+"->"+command);	
}

/*
 * @authors rhino
 * Broadcast a message to given character's console
 */
::printB <- function(character,message,reporttohost=true,msgtype="info",startmsg=true,endmsg=true,delay_end_msg=0)
{
	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character.tolower())==-1)
	{ClientPrint(null,3,"\x04"+Messages.BIM.NotACharacter(character));return;}

	if(startmsg)
		AdminSystem._Clientbroadcast(character,"echo -----------------SCRIPT_REPORT_START-------------------",1,!reporttohost);

	// Replace bad characters
	message = Utils.StringReplace(Utils.StringReplace(message,","," "),":"," ");

	// Actual message
	if(msgtype=="info")
		AdminSystem._Clientbroadcast(character,"echo [Info]"+message,1,!reporttohost);
	else if(msgtype=="error")
		AdminSystem._Clientbroadcast(character,"echo [Error]"+message,1,!reporttohost);
	else if(msgtype=="debug")
		AdminSystem._Clientbroadcast(character,"echo [Debug]"+message,1,false);
	else	
		AdminSystem._Clientbroadcast(character,"echo "+message,1,!reporttohost);

	if(endmsg)
		AdminSystem._Clientbroadcast(character,"echo ------------------SCRIPT_REPORT_END--------------------",1,!reporttohost,delay_end_msg);

	if(reporttohost && msgtype!="debug" && !(Utils.GetPlayerFromName(character).GetSteamID() in ::AdminSystem.HostPlayer))
		printl("[Broadcast] printB for "+character+" with "+msgtype+" message:"+message);
}

/*
 * @authors rhino
 * Execute commands in host's client
 */
::AdminSystem.Server_execCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	local cmd = GetArgument(1);
	local arg1 = GetArgument(2);
	local arg2 = GetArgument(3);
	local arg3 = GetArgument(4);
	local arg4 = GetArgument(5);
	if(arg4 == null){arg4="";}
	if(arg3 == null){arg3="";}
	if(arg2 == null){arg2="";}
	if(arg1 == null){arg1="";}
	local command = cmd+" "+arg1+" "+arg2+" "+arg3+" "+arg4;
	printl(player.GetCharacterNameLower()+"->Executing command->"+command);	
	SendToServerConsole(command);
}

/*
 * @authors rhino
 */
::AdminSystem.RandomlineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local targetname = GetArgument(1);
	local linesource = GetArgument(2);
	local randomline_path = "";
	local speaker = null;
	
	if(targetname==null)
	{
		targetname = name;
	}
	else
	{
		targetname = targetname.tolower();
	}

	// Line source is random
	if(linesource == "random")
	{
		linesource = Utils.GetRandValueFromArray(AdminSystem.Vars.CharacterNamesLower);
		while(linesource == "" || linesource == "survivor")
			linesource = Utils.GetRandValueFromArray(AdminSystem.Vars.CharacterNamesLower);
	}

	// Speaker selection
	if(targetname == "random")
	{	
		targetname = Utils.GetRandValueFromArray(Players.AliveSurvivors()).GetCharacterNameLower();
		speaker = Utils.GetPlayerFromName(targetname);
	}
	else if(targetname == "self")
	{
		targetname = name;
		speaker = player;
	}
	else if(targetname == "picker")
	{
		targetname = player.GetLookingEntity();

		if(targetname == null){return;}
		if(targetname.GetClassname() != "player"){return;}
	
		targetname = targetname.GetCharacterNameLower();
		speaker = Utils.GetPlayerFromName(targetname);
	}
	else if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,targetname) == -1)
	{
		Printer(player,Messages.BIM.NotACharacter(GetArgument(1)),"error");
	}
	else
	{
		speaker = Player("!"+targetname);
	}

	if(speaker==null)
	{
		speaker = Utils.GetPlayerFromName(Utils.GetRandValueFromArray(Players.AliveSurvivors()).GetCharacterNameLower());
	}

	randomline_path = (linesource == null) ? Utils.GetRandValueFromArray(::Survivorlines.Paths[targetname]) : Utils.GetRandValueFromArray(::Survivorlines.Paths[linesource.tolower()]);
	speaker.Speak(randomline_path);

	//Output messages
	if (AdminSystem.Vars._outputsEnabled[name])
	{	
		if (AdminSystem.Vars._saveLastLine[name])
		{
			if(AdminSystem.Vars._savedLine[name].target != targetname
			   || AdminSystem.Vars._savedLine[name].source != randomline_path)
			{
				AdminSystem.Vars._savedLine[name].target = targetname;
				AdminSystem.Vars._savedLine[name].source = randomline_path;
				Messages.InformPlayer(player,CmdMessages.RandomLine.SaveAndSpeak(randomline_path,targetname));
			}
			else
			{
				Messages.InformPlayer(player,CmdMessages.LineSaving.MakeSpeak(targetname,randomline_path));
			}
		}
		else
		{
			Messages.InformPlayer(player,CmdMessages.LineSaving.MakeSpeak(targetname,randomline_path));
		}
	}
	else
	{	
		if (AdminSystem.Vars._saveLastLine[name])
		{
			if(AdminSystem.Vars._savedLine[name].target != targetname
			   || AdminSystem.Vars._savedLine[name].source != randomline_path)
			{
				AdminSystem.Vars._savedLine[name].target = targetname;
				AdminSystem.Vars._savedLine[name].source = randomline_path;
				printB(player.GetCharacterName(),CmdMessages.RandomLine.SaveAndSpeak(randomline_path,targetname),true,"info",true,true);
			}
			else
			{
				printB(player.GetCharacterName(),CmdMessages.LineSaving.MakeSpeak(targetname,randomline_path),true,"info",true,true);
			}
		}
		else
		{
			printB(player.GetCharacterName(),CmdMessages.LineSaving.MakeSpeak(targetname,randomline_path),true,"info",true,true);
		}
		
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.ColorCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = player.GetLookingEntity();
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
	
	local name = player.GetCharacterNameLower();	
	local red = GetArgument(1);
	local green = GetArgument(2);
	local blue = GetArgument(3);
	local alpha = GetArgument(4);
	if (red==null)
		return;

	if (alpha==null)
		alpha = 255.0;

	ent.SetColor(red,green,blue,alpha);

	Printer(player,CmdMessages.Color(red,green,blue,alpha,ent.GetIndex()));
}

/*
 * @authors rhino
 */
::AdminSystem.SetkeyvalCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = player.GetLookingEntity();
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
	
	local name = player.GetCharacterNameLower();	
	local key = GetArgument(1);
	local val = GetArgument(2);
	
	if(key == "effects")
		ent.SetEffects(val);
	else if(key == "spawnflags")
		ent.SetFlags(val);
	else
		ent.SetKeyValue(key,val);
		
	Printer(player,CmdMessages.KeyVal.Success(key,val,ent.GetIndex()));
}

/*
 * Update prop spawn settings
 * Argument 1 = "ptr" to use _prop_spawn_settings_menu_type of player
 *
 * @authors rhino
 */
::AdminSystem.Update_prop_spawn_settingCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local typename = GetArgument(1);
	local setting = GetArgument(2);
	local val = GetArgument(3);
	if (typename != null && setting != null && val != null)
	{	
		if(typename=="ptr")
		{
			typename = AdminSystem.Vars._prop_spawn_settings_menu_type[name];
		}

		if(typename=="all")
		{
			AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting] = val;
			AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting] = val;
			AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting] = val;
		}
		else
			AdminSystem.Vars._prop_spawn_settings[name][typename][setting] = val;

		CmdMessages.Prop.SettingSuccess(name,typename,setting,val);
	}
	else
	{	
		return;
	}
}

/*
 * Prop type for menu to apply settings to
 *
 * @authors rhino
 */
::AdminSystem.Update_prop_spawn_menu_typeCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local typename = GetArgument(1);
	if (typename != null)
	{	
		AdminSystem.Vars._prop_spawn_settings_menu_type[name] = typename;
		//printl(name +" Updated prop menu type :"+typename);
	}
	else
	{	
		return;
	}
}

/*
 * @authors rhino
 */
::AdminSystem.Display_prop_spawn_settingsCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local infostr = "";
	local typename = GetArgument(1);

	if(typename == null || typename == "all")
	{
		infostr += "\nProp spawn settings for: "+name+"\n";
		foreach(typename,setting_val in AdminSystem.Vars._prop_spawn_settings[name])
		{
			infostr += "Type("+typename+"):\n";
			foreach(setting,val in setting_val)
			{
				infostr += " 	 " + setting + ": " + val + "\n";
			}
		}
	}
	else 
	{	
		if(typename == "ptr")
			typename = AdminSystem.Vars._prop_spawn_settings_menu_type[name];

		infostr += "\nProp spawn settings for: "+name+"\n";
		infostr += "Type("+typename+"):\n";
		foreach(setting,val in AdminSystem.Vars._prop_spawn_settings[name][typename])
		{
			infostr += " 	 " + setting + ": " + val + "\n";
		}
	}
	Printer(player,infostr);
}

/*
 * @authors rhino
 */
::AdminSystem.Save_particleCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local source = GetArgument(1);
	local duration = GetArgument(2);
	if ( duration == null)
	{
		duration = AdminSystem.Vars._preferred_duration[name];
	}
	
	AdminSystem.Vars._savedParticle[name].source = source;
	AdminSystem.Vars._savedParticle[name].duration = duration;
	
	Printer(player,CmdMessages.Particles.SaveSuccess(source,duration));
}

/*
 * @authors rhino
 */
::AdminSystem.Attach_particleCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = player.GetLookingEntity();
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;

	local name = player.GetCharacterNameLower();
	local particle = GetArgument(1);
	local duration = GetArgument(2);
	if (duration == null)
	{
		duration = AdminSystem.Vars._preferred_duration[name];
	}
	
	if (particle == "random")
	{	
		particle = Utils.GetRandValueFromArray(::Particlenames.names);
		if(AdminSystem.Vars._saveLastParticle[name])
		{
			AdminSystem.Vars._savedParticle[name].duration = duration;
			AdminSystem.Vars._savedParticle[name].source = particle;
		}
	}

	local attachpos = null;
	if(AdminSystem.Vars._attachTargetedLocation[name])
		attachpos = player.GetLookingLocation();

	local createdent = ent.AttachParticle(particle, duration, attachpos);

	if(duration == -1.0)
		duration = "infinite"

	Printer(player,CmdMessages.Particles.AttachSuccess(particle,createdent.GetIndex(),ent.GetIndex(),duration));
}

/*
 * @authors rhino
 */
::AdminSystem.Attach_to_targeted_positionCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._attachTargetedLocation[name];
	AdminSystem.Vars._attachTargetedLocation[name] = newstate;

	Printer(player,CmdMessages.Particles.AttachmentPoint(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Randomparticle_save_stateCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._saveLastParticle[name];
	AdminSystem.Vars._saveLastParticle[name] = newstate;

	Printer(player,CmdMessages.Particles.SaveState(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Update_attachment_preferenceCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	local duration = GetArgument(1);
	if (duration == null)
	{
		duration = 30;
	}
	else
	{
		duration = duration.tofloat();
	}

	Printer(player,CmdMessages.Particles.AttachmentDuration(AdminSystem.Vars._preferred_duration[name],duration));

	AdminSystem.Vars._preferred_duration[name] = duration;
}

/*
 * @authors rhino
 */
::AdminSystem.Display_saved_particleCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	if (AdminSystem.Vars._saveLastLine[name])
	{	
		local particleinfo = AdminSystem.Vars._savedParticle[name];
		if (particleinfo.source != "")
		{
			Printer(player,CmdMessages.Particles.Information(particleinfo));
		}
		else
		{
			Messages.ThrowPlayer(player,CmdMessages.Particles.NoneSaved());
		}
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.Spawn_particle_savedCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterNameLower();
	local particleinfo = AdminSystem.Vars._savedParticle[name];
	if (particleinfo.source != "")
	{
		local EyePosition = player.GetLookingLocation();
		g_ModeScript.CreateParticleSystemAt( null, EyePosition, particleinfo.source, true );

		Printer(player,CmdMessages.Particles.SpawnSavedSuccess(particleinfo.source,EyePosition));
	}
	else
	{
		Messages.ThrowPlayer(player,"No saved particle was found");
	}
}

/*
 * @authors rhino
 */
::AdminSystem.Attach_particle_savedCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = player.GetLookingEntity();
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
		
	local name = player.GetCharacterNameLower();
	local particleinfo = AdminSystem.Vars._savedParticle[name];
	if (particleinfo.source != "")
	{	
		local attachpos = null;
		if(AdminSystem.Vars._attachTargetedLocation[name])
			attachpos = player.GetLookingLocation();

		local ptc = ent.AttachParticle(particleinfo.source, particleinfo.duration, attachpos)

		if(ptc != null)
		{
			Printer(player,CmdMessages.Particles.AttachSavedSuccess(particleinfo.source,ptc.GetIndex(),ent.GetIndex(),particleinfo.duration));
		}
	}
	else
	{
		Messages.ThrowPlayer(player,CmdMessages.Particles.NoneSaved());
	}
}

/*
 * @authors rhino
 */
::AdminSystem._TakeOffHatCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local entid = AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].entid;
	if(entid == "")
		return;

	local ent = Entity(entid);
	local colgroup = AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].collisiongroup;

	if(!ent.IsEntityValid())
		return;
	
	AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].entid = "";
	ent.SetNetProp("m_CollisionGroup",colgroup);

	ent.Input("ClearParent","",0);
	local entclass = ent.GetClassname();
	
	if(entclass.find("weapon_") != null) // a weapon spawner entity
	{
	}
	else if(entclass.find("physics") != null || entclass == "prop_car_alarm") // physics entity
	{
		if( entclass == "prop_physics_multiplayer" || entclass == "prop_physics")
		{	
			local flags = ent.GetFlags();
			local effects = ent.GetNetProp("m_fEffects")

			if((flags% 2) == 1)	// Disable start asleep flag
				ent.SetFlags(flags-1)

			flags = ent.GetFlags();
			
			if((flags>>3) % 2 == 1)	// Disable motion disabled flag
				ent.SetFlags(flags-8)
			
			ent.Input("EnableMotion","",0);
			ent.SetEffects(effects);
		}
		ent.Input("RunScriptCode","_dropit(Entity("+entid+"))",0);
	}
	else // non physics, try creating entity with its model
	{
		local new_ent = null;
		local keyvals = 
		{
			classname = "prop_physics_multiplayer",
			model = ent.GetModel(),
			origin = ent.GetOrigin(),
			angles = ent.GetAngles(),
		};
		local skin = ent.GetNetProp("m_nSkin");
		local color = ent.GetNetProp("m_clrRender");
		local scale = ent.GetModelScale();

		new_ent = Utils.CreateEntityWithTable(keyvals);

		if(new_ent == null)
		{
			ent.KillHierarchy();
			//printB(player.GetCharacterName(),"Failed to create new entity after letting go the held item",true,"error",true,true)
			
			keyvals["classname"] = "prop_physics_multiplayer"
			keyvals["model"] = "models/items/l4d_gift.mdl"
			new_ent = Utils.CreateEntityWithTable(keyvals);
		}
		else
		{
			RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
		}
	}
	

	if(entclass.find("weapon_") != null) // a weapon spawner entity
	{
		//printB(player.GetCharacterName(),"Took off the hat entity (spawner) #"+entid,true,"info",true,true)
	}
	else
	{
		//printB(player.GetCharacterName(),"Took off the hat entity #"+entid,true,"info",true,true)
	}
	ent.Input("RunScriptCode","originWrap(Entity("+ent.GetIndex()+"),Player("+player.GetIndex()+"))",0.1);
}

::originWrap <- function(ent,player)
{
	local looked = player.GetLookingLocation();

	if(Utils.CalculateDistance(looked,player.GetOrigin()) > 200)
	{
		local fw = player.GetEyeAngles().Forward();
		fw = fw.Scale(200/fw.Length());
		ent.SetOrigin(fw+player.GetEyePosition());
	}
	else
	{
		ent.SetOrigin(looked);
	}
}

/*
 * @authors rhino
 */
::AdminSystem._WearHatCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local ent = player.GetLookingEntity();
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
	
	if(ent.GetParent() != null)
		return; 

	if(Utils.CalculateDistance(ent.GetOrigin(),player.GetEyePosition()) > 250)
		return;

	local entclass = ent.GetClassname();

	if(entclass == "player")
		return;

	if(!(entclass in AdminSystem.Vars._grabAvailable) && (entclass.find("weapon_") == null))
		return;

	if((ent.GetModel().find("_glass") != null || entclass.find("_glass") != null) 
		&& (entclass.find("_car") != null || entclass.find("car_") != null || entclass.find("vehicle") != null || entclass.find("dynamic") != null || entclass.find("prop_physics") == null))
		{return;}

	if((entclass.find("props_vehicles") != null)) // Vehicle glasses ignored
		return;

	if(ent.GetModel().find("*") != null)
		return;

	local ind = ent.GetIndex();

	local name = player.GetCharacterNameLower();
	if(AdminSystem.Vars._wornHat[name].entid != "")
	{
		AdminSystem._TakeOffHatCmd(player,args);
	}

	local pos = AdminSystem.Vars._wornHat[name].wearAttachPos;
	local posextra = 0;
	AdminSystem.Vars._wornHat[name].entid = ind;
	AdminSystem.Vars._wornHat[name].collisiongroup = ent.GetNetProp("m_CollisionGroup");
	if(pos == "mouth")
		posextra = HatParameters.mouth_extra;
	else if(pos == "survivor_neck")
		posextra = HatParameters.neck_extra;

	local vec = GetArgument(1)==null ? Vector(0,0,AdminSystem.Vars._wornHat[name].wearAbove + posextra) : Vector(0,0,AdminSystem.Vars._wornHat[name].wearAbove + GetArgument(1).tofloat() + posextra)
	local survivorfw = player.GetEyeAngles().Forward();
	survivorfw = survivorfw.Scale(HatParameters.forward_scale/survivorfw.Length()) + Vector(0,0,HatParameters.forward_raise);

	//ent.SetForwardVector(player.GetForwardVector());
	
	ent.SetNetProp("m_CollisionGroup",1);
	ent.Input("setparent","#"+player.GetIndex(),0);
	ent.SetOrigin(player.GetEyePosition()+vec+survivorfw);
	ent.SetAngles(RotateOrientation(player.GetEyeAngles(),QAngle(HatParameters.pitch,HatParameters.yaw,HatParameters.roll)))	
	ent.Input("setparentattachmentmaintainoffset",pos,0.1);
}

::HatParameters <- 
{
	mouth_extra = -6,
	neck_extra = -10,
	forward_scale = 4,
	forward_raise = 4,
	pitch = 10,
	yaw = 0,
	roll = 0
}

/*
 * @authors rhino
 */
::AdminSystem._HatPosition <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	local pos = GetArgument(1);
	if(pos == null)
		return;

	AdminSystem.Vars._wornHat[player.GetCharacterNameLower()].wearAttachPos = pos;
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateAimedEntityDirection <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	local ent = player.GetLookingEntity();
	if(ent == null)
		return;

  	ent.SetForwardVector(player.GetForwardVector());
}

::AdminSystem._GrabControl <-
{
	bill = 
	{
		keymask = 0
		listenerid = -1
	}
	francis = 
	{
		keymask = 0
		listenerid = -1
	}
	louis = 
	{
		keymask = 0
		listenerid = -1
	}
	zoey = 
	{
		keymask = 0
		listenerid = -1
	}
	nick = 
	{
		keymask = 0
		listenerid = -1
	}
	ellis = 
	{
		keymask = 0
		listenerid = -1
	}
	coach = 
	{
		keymask = 0
		listenerid = -1
	}
	rochelle = 
	{
		keymask = 0
		listenerid = -1
	}
}

/*
 * @authors rhino
 */
::AdminSystem._AngleUpdater <- function(args)
{
	local player = args.player;
	local name = player.GetCharacterNameLower();
	local tbl = AdminSystem._GrabControl[name]
	local mask = tbl.keymask;

	local held = AdminSystem.Vars._heldEntity[name].entid;
	local ent = null;
	if(held == "")
	{
		if (name+"_item_rotate1" in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[name+"_item_rotate1"]);
			delete ::VSLib.Timers.TimersID[name+"_item_rotate1"];

			Ent(AdminSystem._GrabControl[name].listenerid).Kill();
			AdminSystem._GrabControl[name].keymask = 0
			AdminSystem._GrabControl[name].listenerid = -1
		}
		return;
	}
	else
	{
		ent = Entity(held.tointeger());
	}

	local angles = ent.GetAngles();
	ClientPrint(null,3,"\x03"+mask+" : "+angles.Pitch()+","+angles.Yaw()+","+angles.Roll());

	if(mask == 0)
		return;

	local pitchDown = (mask % 2)*3;
	local pitchUp = ((mask>>1) % 2)*3;
	local yawRight = ((mask>>2) % 2)*3;
	local yawLeft = ((mask>>3) % 2)*3;
	local rollClockwise = yawRight;
	local rollAntiClockwise = yawLeft;

	// Pitch, yaw
	if(player.IsPressingWalk())
	{
		Entity(AdminSystem._GrabControl[name].listenerid).SetFlags(32);

		ent.SetAngles(RotateOrientation(ent.GetAngles(),QAngle(pitchUp-pitchDown,yawRight-yawLeft,0)));	

	}
	// Roll
	else if(player.IsPressingReload())
	{
		Entity(AdminSystem._GrabControl[name].listenerid).SetFlags(32);

		ent.SetAngles(RotateOrientation(ent.GetAngles(),QAngle(0,0,yawRight-yawLeft)));	
	}
	else
	{
		Entity(AdminSystem._GrabControl[name].listenerid).SetFlags(0);
		AdminSystem._GrabControl[name].keymask = 0;
	}
}

/*
 * @authors rhino
 */
::AdminSystem._GrabKeyMasker <- function(arg)
{
	local spl = split(arg,"__")
	local ind = spl[0].tointeger();
	local key = spl[1].tointeger();

	local ent = VSLib.Player(ind.tointeger());
	local name = ent.GetCharacterNameLower();
	local currmask = AdminSystem._GrabControl[name].keymask;

	if((ent.IsPressingReload() || ent.IsPressingWalk()) && (ent.IsPressingReload() != ent.IsPressingWalk()))
	{
		AdminSystem._GrabControl[name].keymask = currmask ^ key;
	}
	else
	{
		AdminSystem._GrabControl[name].keymask = 0;
	}
	ClientPrint(null,3,"\x04"+AdminSystem._GrabControl[name].keymask);

}

/*
 * @authors rhino
 * Attach the targeted entity around players arms, make it look and move like player is holding it
 * TO-DO : Instead of skipping parented entities, check if their parents are close enough and grab by the parent entity
 */
::AdminSystem.GrabCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local ent = null
	if(args != null)
	{
		if((typeof args) == "table" )
		{
			if(("_fromlistener" in args))
			{
				ent = args._fromlistener;
				local playerEyeLoc = player.GetEyePosition();
				local angles = player.GetEyeAngles();
				local newanglesF = QAngle(0,angles.Yaw(),angles.Roll()).Forward();
				local holdingLoc = playerEyeLoc + newanglesF.Scale(100/newanglesF.Length());
				holdingLoc.z = playerEyeLoc.z - 40;
				ent.SetOrigin(holdingLoc);
				local entind = ent.GetIndex().tostring();
				player.AttachOther(ent,false,0,null);
				//player.SetAttachmentPoint(ent,tbl_heldEnt.grabAttachPos,true,0.1);

				//printB(player.GetCharacterName(),"Grabbed #"+entind,true,"info",true,true)

				AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = entind;
				return;
			}
		}
	}
	local tbl_heldEnt = AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()];
	local baseent = null;
	if(tbl_heldEnt.entid != "")	// Already holding something, validate it
	{
		baseent = Ent("#"+tbl_heldEnt.entid);
		if(baseent == null)						// it doesnt exist, remove it
		{
			AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
			return;
		}

		if(!VSLib.Entity(baseent).IsEntityValid())		// invalid entity, remove it
		{
			AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
			return;
		}

		// Player still is the parent
		if(VSLib.Entity(baseent).GetParent() != null) // Let go when grab pressed another time
		{
			AdminSystem.LetgoCmd(player,args);
			return;
		}
		// 
	}

	ent = player.GetLookingEntity();
	local lookedpoint = player.GetLookingLocation(33579137);
	local entind = null;
	local objtable = null;
	local entclass = null;
	local entmodel = null;
	local taken = null;
	local closestgrabbed = false;
	// TO-DO use masks instead
	if(ent == null)
	{
		objtable = VSLib.EasyLogic.Objects.AroundRadius(lookedpoint,AdminSystem.Vars._grabRadiusTolerance);	// Get entities within radius
		if(objtable != null)
		{
			foreach(obj in objtable)	// Loop through
			{	
				taken = false;		// Store state of the entity being held by someone else

				if(obj.GetParent() != null) // Parented objects can't be parented by others
					continue;

				entclass = obj.GetClassname();	
				entmodel = obj.GetModel();

				if(!(entclass in AdminSystem.Vars._grabAvailable) && (entclass.find("weapon_") == null) )	// Validate class name
					continue;
				
				if((entmodel.find("_glass") != null || entclass.find("_glass") != null) 
					&& (entclass.find("_car") != null || entclass.find("car_") != null || entclass.find("vehicle") != null || entclass.find("dynamic") != null || entclass.find("prop_physics") == null))
					{continue;}
				
				if(entmodel.find("*") != null)
					continue;

				if((entmodel.find("hybridphysx") != null)) // Animation props etc ignored
					continue;

				if(obj.GetIndex() == player.GetIndex())
					continue;
				
				entind = obj.GetIndex().tostring();

				if(obj.GetClassname() == "player")
				{
					local notvalid = false;
					foreach(survivor in Players.AliveSurvivors())
					{
						if(AdminSystem.Vars._heldEntity[survivor.GetCharacterNameLower()].entid == entind || AdminSystem.Vars._heldEntity[survivor.GetCharacterNameLower()].entid == player.GetIndex().tostring())
						{
							notvalid = true;
							break;
						}
					}
					if(notvalid)
						continue;
				}
				
				foreach(survivor in Players.AliveSurvivors())
				{
					foreach(helditem in survivor.GetHeldItems())
					{
						if(entind == helditem.GetIndex().tostring())
						{
							taken = true;
							break;
						}
					}
					
					if(taken)		// Skip to next if its an item in somebody's inventory
						break;
				}
				
				if(taken)		// Skip to next if already held
					continue;

				ent = obj;		// Available object, select and break out of the loop
				closestgrabbed = true;
				
				break;
			}

			if(ent == null)	// No acceptable object was found
				return;
		}
		else	// No entities withing given radius
			return;
	}
	else if(ent.GetIndex() == player.GetIndex())
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}
	else if(ent.GetParent() != null) // Parented objects can't be parented by others
	{
		return;
	}
	else	// Found entity with default masking
	{
		entclass = ent.GetClassname();
		if(entclass == "player")
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if(AdminSystem.Vars._heldEntity[survivor.GetCharacterNameLower()].entid == ent.GetIndex() || AdminSystem.Vars._heldEntity[survivor.GetCharacterNameLower()].entid == player.GetIndex())
				{
					return;
				}
			}
		}
		entmodel = ent.GetModel();
		if(!(entclass in AdminSystem.Vars._grabAvailable) && (entclass.find("weapon_") == null))
			return;
		if((entmodel.find("_glass") != null || entclass.find("_glass") != null) 
			&& (entclass.find("_car") != null || entclass.find("car_") != null || entclass.find("vehicle") != null || entclass.find("dynamic") != null || entclass.find("prop_physics") == null))
			{return;}
		
		if(entmodel.find("*") != null)
			return;

		entind = ent.GetIndex().tostring();
	}

	local playerEyeLoc = player.GetEyePosition();

	local entity_dist = Utils.CalculateDistance(playerEyeLoc,lookedpoint);

	if(entity_dist < tbl_heldEnt.grabRange)
	{
		local grabdist = tbl_heldEnt.grabDistMin
		// THIS METHOD TELEPORTS ENTITY CLOSER TO PLAYER
		// BUT SINCE IT DOES IT VIA ENTITY ORIGIN AND SOME MODELS
		// HAVE THEIR ORIGIN ODDLY PLACED, PLAYER COULD GET STUCK IN
		// THE ENTITY
		if(tbl_heldEnt.grabByAimedPart.tointeger() != 1)
		{
			local angles = player.GetEyeAngles();
			local newanglesF = QAngle(0,angles.Yaw(),angles.Roll()).Forward();
			local holdingLoc = playerEyeLoc + newanglesF.Scale(grabdist/newanglesF.Length());
			holdingLoc.z = player.GetEyePosition().z - tbl_heldEnt.grabHeightBelowEyes;

			if(player.GetModel().find("survivor") == null)
				holdingLoc = holdingLoc + Vector(0,0,60)
			ent.SetOrigin(holdingLoc);
		}
		else
		{
			local moveback = entity_dist-grabdist;
			local fwvec = player.GetEyeAngles().Forward();
			local entpos = ent.GetPosition();
			fwvec.z *= -1;
			fwvec.y *= -1;
			fwvec.x *= -1;
			fwvec = fwvec.Scale(moveback/fwvec.Length());
			
			if(player.GetModel().find("survivor") == null)
				fwvec = fwvec + Vector(0,0,60)
			ent.SetOrigin(Vector(entpos.x+fwvec.x,entpos.y+fwvec.y,entpos.z+fwvec.z));

		}

		player.AttachOther(ent,false,0,null);
		player.SetAttachmentPoint(ent,tbl_heldEnt.grabAttachPos,true,0.1);
		
		/*
		if(closestgrabbed)
			printB(player.GetCharacterName(),"Grabbing closest prop at targeted location #"+entind+" "+entclass+" "+entmodel,true,"info",true,true);
		else
			printB(player.GetCharacterName(),"Grabbed #"+entind,true,"info",true,true)
		*/

		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = entind;

		/*
		local keyvals = 
		{
			classname = "game_ui"
			FieldOfView = -1
			origin = player.GetOrigin()
			spawnflags = 0
		}

		local name = player.GetCharacterNameLower();
		local listener = Utils.CreateEntityWithTable(keyvals);
		listener.SetName("grab_listener_"+player.GetCharacterNameLower()+UniqueString())
		listener.SetFlags(0)

		local forIndex = player.GetIndex();
		
		ClientPrint(null,3,"\x04"+forIndex+"->Created grab listener(#"+listener.GetIndex()+") named "+listener.GetName());

		listener.Input("addoutput",__.FP+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_FORWARD)+"),0,-1",0,null)
		listener.Input("addoutput",__.FU+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_FORWARD)+"),0,-1",0,null)
		listener.Input("addoutput",__.BP+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_BACKWARD)+"),0,-1",0,null)
		listener.Input("addoutput",__.BU+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_BACKWARD)+"),0,-1",0,null)
		listener.Input("addoutput",__.LP+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_LEFT)+"),0,-1",0,null)
		listener.Input("addoutput",__.LU+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_LEFT)+"),0,-1",0,null)
		listener.Input("addoutput",__.RP+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_RIGHT)+"),0,-1",0,null)
		listener.Input("addoutput",__.RU+" !self,RunScriptCode,AdminSystem._GrabKeyMasker("+_GetEnumString(forIndex+"__"+BTN_RIGHT)+"),0,-1",0,null)

		listener.Input("activate","",0.1,player.GetBaseEntity())

		AdminSystem._GrabControl[name].listenerid = listener.GetIndex();

		::VSLib.Timers.AddTimerByName(name+"_item_rotate1",0.1, true, AdminSystem._AngleUpdater,{player=player});
		*/
	}
	
}

/*
 * @authors rhino
 * Drops the entity held by player
 */
::AdminSystem.LetgoCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	/*
	if (name+"_item_rotate1" in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[name+"_item_rotate1"]);
		delete ::VSLib.Timers.TimersID[name+"_item_rotate1"];

		local id = AdminSystem._GrabControl[name].listenerid;

		Ent(id).Kill();
		AdminSystem._GrabControl[name].keymask = 0
		AdminSystem._GrabControl[name].listenerid = -1
	}
	*/
	if(AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid == "")
		return;

	local baseent = Ent("#"+AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid);
	if(baseent == null)
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}

	local ent = ::VSLib.Entity(baseent);
	
	local entclass = null;

	if(!ent.IsEntityValid())
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}
	
	if(ent.GetParent() == null)
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}
	else
	{
		ent.Input("ClearParent","",0);
		entclass = ent.GetClassname();
	
		if(entclass == "player")
		{
			ent.SetMoveType(MOVETYPE_WALK);
			ent.Input("RunScriptCode","_dropit(Entity("+ent.GetIndex()+"))",0);
		}
		else if(entclass.find("weapon_") != null) // a weapon spawner 
		{
		}
		else if(entclass.find("physics") != null || entclass == "prop_car_alarm") // physics entity
		{
			if( entclass == "prop_physics_multiplayer" || entclass == "prop_physics")
			{	
				local flags = ent.GetFlags();
				local effects = ent.GetNetProp("m_fEffects")

				if((flags% 2) == 1)	// Disable start asleep flag
					ent.SetFlags(flags-1)

				flags = ent.GetFlags();
				
				if((flags>>3) % 2 == 1)	// Disable motion disabled flag
					ent.SetFlags(flags-8)
				
				ent.Input("EnableMotion","",0);
				ent.SetEffects(effects);
			}
			ent.Input("RunScriptCode","_dropit(Entity("+ent.GetIndex()+"))",0);
		}
		else // non physics, try creating entity with its model
		{
			local new_ent = null;
			local keyvals = 
			{
				classname = "prop_physics_multiplayer",
				model = ent.GetModel(),
				origin = ent.GetOrigin(),
				angles = ent.GetAngles(),
			};
			local skin = ent.GetNetProp("m_nSkin");
			local color = ent.GetNetProp("m_clrRender");
			local scale = ent.GetModelScale();

			new_ent = Utils.CreateEntityWithTable(keyvals);

			if(new_ent == null)
			{
				ent.Kill();
				//printB(player.GetCharacterName(),"Failed to create new entity after letting go the held item",true,"error",true,true)
				
				keyvals["classname"] = "prop_physics_multiplayer"
				keyvals["model"] = "models/items/l4d_gift.mdl"
				new_ent = Utils.CreateEntityWithTable(keyvals);
			}
			else
			{
				RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
			}

			AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
			return;
		}

		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
	}

	if(entclass.find("weapon_") != null) // a weapon spawner entity
	{
		//printB(player.GetCharacterName(),"Let go the held entity spawner #"+ent.GetIndex(),true,"info",true,true)
		return;
	}

	//printB(player.GetCharacterName(),"Let go the held entity #"+ent.GetIndex(),true,"info",true,true)

}

/*
 * @authors rhino
 * YEET
 */
::AdminSystem.YeetCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterNameLower();
	/*
	if (name+"_item_rotate1" in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[name+"_item_rotate1"]);
		delete ::VSLib.Timers.TimersID[name+"_item_rotate1"];

		local id = AdminSystem._GrabControl[name].listenerid;

		Ent(id).Kill();
		AdminSystem._GrabControl[name].keymask = 0
		AdminSystem._GrabControl[name].listenerid = -1
	}
	*/
	if(AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid == "")
		return;
	
	local baseent = Ent("#"+AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid);
	if(baseent == null)
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}
	
	local ent = ::VSLib.Entity(baseent);
	local entclass = null;
	if(!ent.IsEntityValid())
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}

	if(ent.GetParent() == null)
	{
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
		return;
	}
	else
	{
		ent.Input("ClearParent","",0);
		entclass = ent.GetClassname();
	
		if(entclass == "player")
		{
			ent.SetMoveType(MOVETYPE_WALK);
			ent.Input("RunScriptCode","_yeetit(Entity("+ent.GetIndex()+"), Player("+player.GetIndex()+"))",0);
		}
		else if(entclass.find("weapon_") != null) // a weapon spawner entity
		{
		}
		else if(entclass.find("physics") != null || entclass == "prop_car_alarm") // physics entity
		{
			if( entclass == "prop_physics_multiplayer" || entclass == "prop_physics")
			{	
				local flags = ent.GetFlags();
				local effects = ent.GetNetProp("m_fEffects")

				if((flags% 2) == 1)	// Disable start asleep flag
					ent.SetFlags(flags-1)

				flags = ent.GetFlags();
				
				if((flags>>3) % 2 == 1)	// Disable motion disabled flag
					ent.SetFlags(flags-8)
				
				ent.Input("EnableMotion","",0);
				ent.SetEffects(effects);
			}
			ent.Input("RunScriptCode","_yeetit(Entity("+ent.GetIndex()+"), Player("+player.GetIndex()+"))",0);
		}
		else // non physics, try creating entity with its model
		{
			local new_ent = null;
			local keyvals = 
			{
				classname = "prop_physics_multiplayer",
				model = ent.GetModel(),
				origin = ent.GetOrigin(),
				angles = ent.GetAngles(),
			};
			local skin = ent.GetNetProp("m_nSkin");
			local color = ent.GetNetProp("m_clrRender");
			local scale = ent.GetModelScale();

			new_ent = Utils.CreateEntityWithTable(keyvals);

			if(new_ent == null)
			{
				ent.Kill();
				//printB(player.GetCharacterName(),"Failed to create new entity after letting go the held item",true,"error",true,true)
				
				keyvals["classname"] = "prop_physics_multiplayer"
				keyvals["model"] = "models/items/l4d_gift.mdl"
				new_ent = Utils.CreateEntityWithTable(keyvals);
			}
			else
			{
				RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
			}
			
			new_ent.Input("RunScriptCode","_yeetit(Entity("+new_ent.GetIndex()+"), Player("+player.GetIndex()+"))",0);
			AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
			return;
		}

		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = "";
	}
	
	if(entclass.find("weapon_") != null) // a weapon spawner entity
	{
		//printB(player.GetCharacterName(),"Let go the held entity spawner #"+ent.GetIndex(),true,"info",true,true)
		return;
	}

	//printB(player.GetCharacterName(),"YEEEEETED the held entity #"+ent.GetIndex(),true,"info",true,true)

}

::_dropit <- function(ent)
{
	local movetype = ent.GetClassname() == "player" ? MOVETYPE_WALK : MOVETYPE_VPHYSICS
	local a=ent.GetOrigin();
	ent.GetBaseEntity().SetSequence(0);
	//ent.Input("wake","",0);
	ent.SetMoveType(movetype);
	ent.SetOrigin(a);
	ent.SetVelocity(Vector(0,0,0));
}

::_yeetit <- function(ent,p)
{
	_dropit(ent);
	local fwvec = RotateOrientation(p.GetEyeAngles(),QAngle(AdminSystem.Vars._heldEntity[p.GetCharacterNameLower()].yeetPitch,0,0)).Forward();
	fwvec = fwvec.Scale(AdminSystem.Vars._heldEntity[p.GetCharacterNameLower()].yeetSpeed/fwvec.Length());
	ent.Push(fwvec);
}

::deltimer <- function(name)
{
	::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[name]);
	delete ::VSLib.Timers.TimersID[name];
}

// TO-DO: Dynamic->Physics objects' children entities' local origins get offset a bit
::RecreateHierarchy <- function(oldparent,newparent,other)
{
	//newparent.SetMoveType(MOVETYPE_NONE);
	//oldparent.SetMoveType(MOVETYPE_NONE);
	// Create a copy of the old hierarchy
	local firstchild = oldparent.FirstMoveChild();
	while(firstchild != null)
	{
		local next = firstchild.NextMovePeer();

		// Parent the new child
		local locorg = firstchild.GetLocalOrigin();
		local locang = firstchild.GetLocalAngles();
		//out(locorg);
		firstchild.Input("clearparent","",0);
		firstchild.Input("setparent","#"+newparent.GetIndex(),0);
		firstchild.SetLocalOrigin(locorg);
		firstchild.SetLocalAngles(locang);
		
		//out(firstchild.GetLocalOrigin());
		// Move the next child in the same level
		firstchild = next;
	}

	// Remove old hierarchy
	oldparent.KillDelayed(0.1);

	//newparent.SetMoveType(MOVETYPE_VPHYSICS);
	newparent.SetName(other.name);
	newparent.SetNetProp("m_clrRender",other.color);
	newparent.SetNetProp("m_nSkin",other.skin);
	newparent.SetModelScale(other.scale);
}

/*
 * @authors rhino
 */
::AdminSystem.FireExtinguisherCmd <- function(player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local typ = GetArgument(1);

	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	local name = player.GetCharacterNameLower();
	
	GroundPosition.y = EyeAngles.y;

	// fire_ex prop
	local ent = typ == "physicsM" 
		? Utils.SpawnPhysicsMProp( "models/props/cs_office/fire_extinguisher.mdl", EyePosition, GroundPosition )
		: Utils.SpawnDynamicProp( "models/props/cs_office/fire_extinguisher.mdl", EyePosition, GroundPosition );
		
	local entind = ent.GetIndex();
	ent.SetName("projectSmokFireExBase_"+entind);
	
	// particle
	local ptc = ent.AttachParticle( "steam_long" , -1, ent.GetOrigin(), false);

	ptc.SetName("projectSmokFireExParticle_"+entind);
	::VSLib.Timers.AddTimer(0.1,false,Fire_Ex_OriginWrap,{ent=ptc});
	
	// steam
	local steam_sound = Utils.CreateEntityWithTable({classname="ambient_generic", message = "fex_steam", spawnflags = 48, origin = ent.GetOrigin()});
	ent.AttachOther(steam_sound,false,0,null);

	steam_sound.SetName("projectSmokFireExSound_"+entind);
	::VSLib.Timers.AddTimer(0.1,false,Fire_Ex_OriginWrap,{ent=steam_sound});

	// outputs
	local enumstr = _GetEnumString(ptc.GetIndex()+"__"+steam_sound.GetIndex());

	ent.Input("addoutput","OnTakeDamage !self,RunScriptCode,Fire_Ex_OnTakeDamage(" + enumstr + "),0,1",0.1);
	
	AddThinkToEnt(steam_sound.GetBaseEntity(),"Fire_Ex_ReAttach");

	// TO-DO: Add a phys_motor to create rotating motion from steam 

	Printer(player,CmdMessages.FireEx.Success(entind,ptc.GetIndex(),steam_sound.GetIndex()));
}

// TO-DO : Sound can still get stuck, find a fix
::Fire_Ex_ReAttach <- function()
{
	local ind = self.GetEntityIndex();
	local s = Entity(ind);
	local baseind = s.GetName();
	if(!s.IsEntityValid() || baseind.find("projectSmokFireExSound_") == null)
	{
		//out("steam and parent name invalid...")
		AddThinkToEnt(self,null);
		return true;
	}

	baseind = split(baseind,"_")[1].tointeger();
	//out(baseind);

	if(!Entity(baseind).IsEntityValid())
	{
		//out("parent invalid...")
		if(s.GetParent() == null)
		{
			AddThinkToEnt(self,null);
			return true;
		}
		s.SetName("projectSmokFireExSound_"+s.GetParent().GetIndex());
	}
	else if(s.GetParent() == null)
	{
		//out("no parent...")
		return true;
	}
	else if(s.GetParent().GetIndex() == baseind)
	{
		//out("same parent");
		return true;
	}

	//out("parent changed...")
	local p = Objects.AnyOfName("projectSmokFireExParticle_"+baseind);
	if(p == null)
	{
		//out("no particle child found...")
		AddThinkToEnt(self,null);
		return true;
	}

	p.SetName("projectSmokFireExParticle_"+s.GetParent().GetIndex());

	//out("Validated children...")

	local newparent = s.GetParent();

	//out("Reattaching outputs to " + "\x03" + "#"+newparent.GetIndex())
	
	newparent.Input("addoutput","OnTakeDamage !self,RunScriptCode,Fire_Ex_OnTakeDamage(" + _GetEnumString(p.GetIndex()+"__"+s.GetIndex()) + "),0,1",0.1);
	
	return true;

}

::Fire_Ex_OriginWrap <- function(args){args.ent.SetLocalOrigin(Vector(3,-1,10));}

::Fire_Ex_OnTakeDamage <- function(inds)
{
	//out("Took damage! " + inds)
	foreach(ind in split(inds,"__"))
	{
		local ch = Entity("#"+ind);
		if(ch.GetParent() == null || !ch.GetParent().IsEntityValid())
		{
			return;
		}

		if(ch.GetClassname() == "ambient_generic" && ch.GetName().find("projectSmokFireExSound_") != null)
		{
			ch.Input("ToggleSound");
			AddThinkToEnt(ch.GetBaseEntity(),null);
			//ch.KillDelayed(3);
			ch.SetName("projectSmokFireExSoundUSED");
			::VSLib.Timers.AddTimer(3,false,FireExKiller,{ent=ch});
		}
		else if(ch.GetClassname() == "info_particle_system" && ch.GetName().find("projectSmokFireExParticle_") != null)
		{
			ch.Input("Start");
			//ch.KillDelayed(3);
			ch.SetName("projectSmokFireExParticleUSED");
			::VSLib.Timers.AddTimer(3,false,FireExKiller,{ent=ch});
		}
	}
}

::FireExKiller <- function(args)
{
	local p = args.ent;
	if(p.IsEntityValid())
	{
		if(p.GetClassname() == "info_particle_system")
		{
			p.Input("Stop");
		}
		else if(p.GetClassname() == "ambient_generic")
		{
			p.Input("StopSound");
		}
		p.Input("Kill");
	}
}

/* @authors rhino
 * Show grabbing and throwing settings
		entid="",
		yeetSpeed = 1500.0,
		yeetPitch = -10,
		grabRange = 170,
		grabHeightBelowEyes = 30,
		grabDistMin = 75,
		grabAttachPos = "forward",
		grabByAimedPart = 1
 */
::AdminSystem.ShowYeetSettingsCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Yeeting Settings:");
		foreach(setting,val in AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()])
		{
			Messages.InformPlayer(player,"\x05"+setting+"\x03"+" -> "+"\x04"+val.tostring()+"\x01"+"\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()])
		{
			printB(player.GetCharacterName(),"[YEET-Setting] "+setting+" -> "+val.tostring(),false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}

/* @authors rhino
 * Update grabByAimedPart setting state
 */
::AdminSystem.GrabMethodCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName();
	local val = AdminSystem.Vars._heldEntity[name.tolower()].grabByAimedPart;
	AdminSystem.Vars._heldEntity[name.tolower()].grabByAimedPart = (1-val).tointeger();

	Printer(player,"Set grab method to "+(val==1 ? "'grab by center'":"'grab by aimed location'"));
}

/* @authors rhino
 * Change grabbing and throwing settings
 */
::AdminSystem.YeetSettingCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName();
	local setting = GetArgument(1);
	local val = GetArgument(2);
	local attachment_names = 
	["eyes","mouth","forward","survivor_light","survivor_neck",
	"primary","L_weapon_bone","muzzle_flash","armL_T2","armR_T2","medkit",
	"bleedout","pistol","pills","spine","grenade","molotov",
	"legL","legL_B","rfoot","lfoot","thighL","weapon_bone"
	]

	local oldval = null;
	
	if(!(setting in AdminSystem.Vars._heldEntity[name.tolower()]) || setting == "entid")
		return;

	oldval = AdminSystem.Vars._heldEntity[name.tolower()][setting].tostring();
	
	if(setting == "grabByAimedPart")
	{
		{try{val = val.tointeger();}catch(e){return;}}
		if(val != 0 || val != 1)
		{
			Messages.ThrowPlayer(player,"'grabByAimedPart' setting can only be 0 or 1");
			return;
		}
		AdminSystem.Vars._heldEntity[name.tolower()].grabByAimedPart = val;

	}

	else if(setting != "grabAttachPos")
	{
		try{val = val.tofloat();}catch(e){return;}

		AdminSystem.Vars._heldEntity[name.tolower()][setting] = val;
	}

	else if(Utils.GetIDFromArray(attachment_names,val) == -1)
	{
		Messages.ThrowPlayer(player,CmdMessages.GrabYeet.SettingSuccess(val));
		ClientPrint(player.GetBaseEntity(),3,"\x04"+"Available attachment point names:"+Utils.ArrayString(attachment_names));
		return;
	}
	else
		AdminSystem.Vars._heldEntity[name.tolower()].grabAttachPos = val;

	Printer(player,CmdMessages.GrabYeet.SettingSuccess(setting,oldval,val));
}

/*
 * @authors rhino
 */
::AdminSystem.Update_svcheatsCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local oldval = Convars.GetFloat("sv_cheats");
	Convars.SetValue("sv_cheats",(1-oldval).tointeger());

	//printl(player.GetCharacterName() +" Updated sv_cheats:"+(1-oldval).tointeger());
}

/*
 * @authors rhino
 */
::AdminSystem.Update_custom_response_preferenceCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local newstate = !::AdminSystem.Vars.AllowCustomResponses;
	::AdminSystem.Vars.AllowCustomResponses = newstate;

	Messages.InformAll(player.GetCharacterName()+( newstate ? "\x03"+" enabled"+"\x01":"\x04"+" disabled"+"\x01") + " custom responses");
}

/*
 * @authors rhino
 */
::AdminSystem.Update_custom_sharing_preferenceCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local newstate = !::AdminSystem.Vars.AllowCustomSharing;
	::AdminSystem.Vars.AllowCustomSharing = newstate;

	Messages.InformAll(player.GetCharacterName()+( newstate ? "\x03"+" enabled"+"\x01":"\x04"+" disabled"+"\x01")+" custom sharing");
}

::AdminSystem.GravityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Value )
		Value = Value.tofloat();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetGravity(Value);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetGravity(Value);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetGravity(Value);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetGravity(Value);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetGravity(Value);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetGravity(Value);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetGravity(Value);
	}
	else
	{
		if ( Value )
		{
			if ( !Target )
				return;
			
			Target.SetGravity(Value);
		}
		else
			player.SetGravity(Entity.tofloat());
	}
}

::AdminSystem.VelocityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Value2 = GetArgument(3);
	local Value3 = GetArgument(4);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	local val = null;
	if ( Value3 )
		val = Vector( Value.tofloat(), Value2.tofloat(), Value3.tofloat());
	else
		val = Vector( Entity.tofloat(), Value.tofloat(), Value2.tofloat());
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetVelocity(val);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetVelocity(val);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetVelocity(val);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetVelocity(val);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetVelocity(val);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetVelocity(val);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetVelocity(val);
	}
	else
	{
		if ( Value3 )
		{
			if ( !Target )
				return;
			
			Target.SetVelocity(val);
		}
		else
			player.SetVelocity(val);
	}
}

::AdminSystem.DropFireCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 16;
	DropFire( EyePosition );
}

::AdminSystem.DropSpitCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 16;
	DropSpit( EyePosition );
}

::AdminSystem.DirectorCmd <- function ( player, args )
{
	local Command = GetArgument(1);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !AdminSystem.Vars.DirectorDisabled && (Command == "stop" || Command == "off" || Command == "disable") )
	{
		AdminSystem.Vars.DirectorDisabled = true;
		Utils.StopDirector();
		foreach(si in Players.Infected())
		{
			if ( si.IsBot() )
				si.Input( "Kill" );
			else
				si.Input( "SetHealth", "0" );
		}
		foreach(infected in Objects.OfClassname("infected"))
			infected.Input( "Kill" );
		foreach(witch in Objects.OfClassname("witch"))
			witch.Input( "Kill" );
		if ( AdminSystem.DisplayMsgs )
			Utils.PrintToAllDel("Disabled Director");
	}
	else if ( AdminSystem.Vars.DirectorDisabled && (Command == "start" || Command == "on" || Command == "enable") )
	{
		AdminSystem.Vars.DirectorDisabled = false;
		Utils.StartDirector();
		if ( AdminSystem.DisplayMsgs )
			Utils.PrintToAllDel("Enabled Director");
	}
}

::AdminSystem.FinaleCmd <- function ( player, args )
{
	local Command = GetArgument(1);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Command == "start" )
		Utils.StartFinale();
	else if ( Command == "rescue" )
		Utils.TriggerRescue();
}

::AdminSystem.RestartCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.TriggerStage( STAGE_RESULTS, 0 );
}

::AdminSystem.LimitCmd <- function ( player, args )
{
	local Infected = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Infected = Infected.tolower();
	Value = Value.tointeger();
	
	if ( Infected == "common" || Infected == "infected" )
	{
		SessionOptions.cm_CommonLimit <- Value;
		SessionOptions.CommonLimit <- Value;
	}
	else if ( Infected == "maxspecials" )
	{
		SessionOptions.cm_MaxSpecials <- Value;
		SessionOptions.MaxSpecials <- Value;
	}
	else if ( Infected == "dominator" )
		SessionOptions.cm_DominatorLimit <- Value;
	else if ( Infected == "smoker" )
		SessionOptions.SmokerLimit <- Value;
	else if ( Infected == "boomer" )
		SessionOptions.BoomerLimit <- Value;
	else if ( Infected == "hunter" )
		SessionOptions.HunterLimit <- Value;
	else if ( Infected == "spitter" )
		SessionOptions.SpitterLimit <- Value;
	else if ( Infected == "jockey" )
		SessionOptions.JockeyLimit <- Value;
	else if ( Infected == "charger" )
		SessionOptions.ChargerLimit <- Value;
	else if ( Infected == "witch" )
	{
		SessionOptions.WitchLimit <- Value;
		SessionOptions.cm_WitchLimit <- Value;
	}
	else if ( Infected == "tank" )
	{
		SessionOptions.TankLimit <- Value;
		SessionOptions.cm_TankLimit <- Value;
	}
}

::AdminSystem.ZombieCmd <- function ( player, args )
{
	local ZombieModel = GetArgument(1);
	local Amount = GetArgument(2);
	local Auto = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local MaxDist = 2400;
	local MinDist = 1200;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !ZombieModel )
		return;
	
	if ( Amount )
	{
		if ( Amount == "auto" )
		{
			Amount = 1;
			Auto = true;
		}
		else
			Amount = Amount.tointeger();
	}
	else
		Amount = 1;
	
	for ( local i = 0; i < Amount; i++ )
	{
		if ( ZombieModel == "ceda" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_ceda", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_ceda", EyePosition);
		}
		else if ( ZombieModel == "mud" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_mud", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_mud", EyePosition);
		}
		else if ( ZombieModel == "roadcrew" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_roadcrew", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_roadcrew", EyePosition);
		}
		else if ( ZombieModel == "roadcrew_rain" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_roadcrew_rain", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_roadcrew_rain", EyePosition);
		}
		else if ( ZombieModel == "fallen_survivor" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_fallen_survivor", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_fallen_survivor", EyePosition);
		}
		else if ( ZombieModel == "riot" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_riot", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_riot", EyePosition);
		}
		else if ( ZombieModel == "clown" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_clown", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_clown", EyePosition);
		}
		else if ( ZombieModel == "jimmy" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_jimmy", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_jimmy", EyePosition);
		}
		else if ( ZombieModel == "random" )
		{
			local randZombie = Utils.GetRandValueFromArray(AdminSystem.ZombieModels);
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, randZombie, MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie(randZombie, EyePosition);
		}
		else
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, ZombieModel, MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie(ZombieModel, EyePosition);
		}
	}
}

::AdminSystem.ZSpawnCmd <- function ( player, args )
{
	local InfectedType = GetArgument(1);
	local Amount = GetArgument(2);
	local Auto = GetArgument(3);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Amount )
	{
		if ( Amount == "auto" )
		{
			Amount = 1;
			Auto = true;
		}
		else
			Amount = Amount.tointeger();
	}
	else
		Amount = 1;
	
	if ( AdminSystem.Vars.DirectorDisabled )
	{
		SessionOptions.cm_DominatorLimit <- 99;
		SessionOptions.cm_MaxSpecials <- 99;
		SessionOptions.MaxSpecials <- 99;
		//SessionOptions.cm_CommonLimit <- 99;
		//SessionOptions.CommonLimit <- 99;
		SessionOptions.SmokerLimit <- 99;
		SessionOptions.BoomerLimit <- 99;
		SessionOptions.HunterLimit <- 99;
		SessionOptions.SpitterLimit <- 99;
		SessionOptions.JockeyLimit <- 99;
		SessionOptions.ChargerLimit <- 99;
		SessionOptions.WitchLimit <- 99;
		SessionOptions.cm_WitchLimit <- 99;
		SessionOptions.TankLimit <- 99;
		SessionOptions.cm_TankLimit <- 99;
	}
	
	for ( local i = 0; i < Amount; i++ )
	{
		if ( InfectedType == "common" || InfectedType == "infected" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_COMMON );
			else
				Utils.SpawnZombie( Z_COMMON, EyePosition );
		}
		else if ( InfectedType == "smoker" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_SMOKER );
			else
				Utils.SpawnZombie( Z_SMOKER, EyePosition );
		}
		else if ( InfectedType == "boomer" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_BOOMER );
			else
				Utils.SpawnZombie( Z_BOOMER, EyePosition );
		}
		else if ( InfectedType == "leaker" )
		{
			if ( Auto )
				Utils.SpawnLeaker();
			else
				Utils.SpawnLeaker( EyePosition );
		}
		else if ( InfectedType == "hunter" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_HUNTER );
			else
				Utils.SpawnZombie( Z_HUNTER, EyePosition );
		}
		else if ( InfectedType == "spitter" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_SPITTER );
			else
				Utils.SpawnZombie( Z_SPITTER, EyePosition );
		}
		else if ( InfectedType == "jockey" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_JOCKEY );
			else
				Utils.SpawnZombie( Z_JOCKEY, EyePosition );
		}
		else if ( InfectedType == "charger" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_CHARGER );
			else
				Utils.SpawnZombie( Z_CHARGER, EyePosition );
		}
		else if ( InfectedType == "witch" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_WITCH );
			else
				Utils.SpawnZombie( Z_WITCH, EyePosition );
		}
		else if ( InfectedType == "tank" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_TANK );
			else
				Utils.SpawnZombie( Z_TANK, EyePosition );
		}
		else if ( InfectedType == "mob" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_MOB );
			else
				Utils.SpawnZombie( Z_MOB, EyePosition );
		}
		else if ( InfectedType == "witch_bride" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_WITCH_BRIDE );
			else
				Utils.SpawnZombie( Z_WITCH_BRIDE, EyePosition );
		}
		else if ( InfectedType == "random" )
		{
			local random_spawn = RandomInt( 0, 9 );
			
			if ( random_spawn == 9 )
				random_spawn = 11;
			
			if ( Auto )
				Utils.SpawnZombie( random_spawn );
			else
				Utils.SpawnZombie( random_spawn, EyePosition );
		}
	}
	
	if ( AdminSystem.Vars.DirectorDisabled )
	{
		SessionOptions.cm_DominatorLimit <- 0;
		SessionOptions.cm_MaxSpecials <- 0;
		SessionOptions.MaxSpecials <- 0;
		//SessionOptions.cm_CommonLimit <- 0;
		//SessionOptions.CommonLimit <- 0;
		SessionOptions.SmokerLimit <- 0;
		SessionOptions.BoomerLimit <- 0;
		SessionOptions.HunterLimit <- 0;
		SessionOptions.SpitterLimit <- 0;
		SessionOptions.JockeyLimit <- 0;
		SessionOptions.ChargerLimit <- 0;
		SessionOptions.WitchLimit <- 0;
		SessionOptions.cm_WitchLimit <- 0;
		SessionOptions.TankLimit <- 0;
		SessionOptions.cm_TankLimit <- 0;
	}
}

::AdminSystem.ExecCmd <- function ( player, args )
{
	local File = GetArgument(1);
	local fileContents = null;

	if ( File.find(".") != null )
		fileContents = FileToString("admin system/" + File);
	else
		fileContents = FileToString("admin system/" + File + ".txt");
	
	if ( !fileContents )
		return;
	
	local file = split(fileContents, "\r\n");
	
	foreach (cmd in file)
	{
		if ( cmd.find("//") != null )
		{
			cmd = Utils.StringReplace(cmd, "//" + ".*", "");
			cmd = rstrip(cmd);
		}
		if ( cmd != "" )
		{
			if ( cmd.find("scripted_user_func") != null )
				SendToServerConsole( cmd );
			else
			{
				local value = cmd.slice( cmd.find(" ") );
				value = Utils.StringReplace( value, " ", "" );
				value = Utils.StringReplace( value, "\"", "" );
				local command = Utils.StringReplace( cmd, value, "" );
				command = Utils.StringReplace( command, " ", "" );
				command = Utils.StringReplace( command, "\"", "" );
				
				if ( cmd.find("scripted_user_func") == null )
					Convars.SetValue( command, value );
			}
		}
	}
}

::AdminSystem.EndGameCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.RollStatsCrawl();
}

::AdminSystem.AlarmCarCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	GroundPosition.y = EyeAngles.y;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	IncludeScript("Admin_System/entitygroups/admin_alarmcar_group", g_MapScript);
	
	local alarmcarEntityGroup = g_MapScript.GetEntityGroup( "AlarmCar" );
	g_MapScript.SpawnSingleAt( alarmcarEntityGroup, EyePosition + Vector(0,0,100), GroundPosition );
}

::AdminSystem.GunCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	GroundPosition.y = EyeAngles.y;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type == "rifle" )
	{
		IncludeScript("Admin_System/entitygroups/auto_rifle_group", g_MapScript);
		
		local autoRifleEntityGroup = g_MapScript.GetEntityGroup( "AutoRifle" );
		g_MapScript.SpawnSingleAt( autoRifleEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
	else if ( Type == "hunting_rifle" )
	{
		IncludeScript("Admin_System/entitygroups/auto_hunting_rifle_group", g_MapScript);
		
		local autoHuntingRifleEntityGroup = g_MapScript.GetEntityGroup( "AutoHuntingRifle" );
		g_MapScript.SpawnSingleAt( autoHuntingRifleEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
	else if ( Type == "autoshotgun" )
	{
		IncludeScript("Admin_System/entitygroups/auto_autoshotgun_group", g_MapScript);
		
		local autoAutoShotgunEntityGroup = g_MapScript.GetEntityGroup( "AutoAutoShotgun" );
		g_MapScript.SpawnSingleAt( autoAutoShotgunEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
}

::AdminSystem.ResourceCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;
	
	for ( local i = 0; i < Amount; i++ )
	{
		local coinEntityGroup = g_MapScript.GetEntityGroup( "PlaceableResource" );
		g_MapScript.SpawnSingleAt( coinEntityGroup, EyePosition + Vector(0,0,16) , QAngle( 0,0,0) );
	}
}
