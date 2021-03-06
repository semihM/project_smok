//-----------------------------------------------------
Msg("Activating Admin System - ");
error("project_smok\n")

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
// Entity detail tables
IncludeScript("Resource_tables/EntityDetailTables");
// Sound script tables
IncludeScript("Resource_tables/SoundScripts");
::SoundScriptsArray <- Utils.TableToArray(::SoundScripts)
// Material details table
IncludeScript("Resource_tables/MaterialDetails");
// Decal names table
IncludeScript("Resource_tables/DecalPaths");
// Model details table
IncludeScript("Resource_tables/ModelDetails");
::ModelNamesArray <- Utils.TableKeys(::ModelDetails)
::PhysicsAvailableModels <- Utils.TableKeys(Utils.TableFilterByValue(::ModelDetails,@(v) "mass" in v))

// Include the command privileges
IncludeScript("Project_smok/Privileges");
// Include the Message Class
IncludeScript("Project_smok/Messages");
// Include String Constants
IncludeScript("Project_smok/Constants");
// Include Custom Variables
IncludeScript("Project_smok/AdminVars");
// Include Aliasing Compiler
IncludeScript("Project_smok/AliasCompiler");
// Include Spell Checker
IncludeScript("Project_smok/SpellChecker");
// Include Zero-G and GivePhysics Limits
IncludeScript("Project_smok/PhysicsLimits");
// Include the Quix timers
IncludeScript("Project_smok/QuickTimers");
// Include the vehicle scripts
IncludeScript("Project_smok/Vehicles");

error("|")
Msg("-----------------------------------------------")
error("|\n|")
Msg(" project_smok ")
error(::Constants.Version.Number)
Msg(" , Version Date ")
error(format("%s |\n|",::Constants.Version.Date))
Msg("-----------------------------------------------")
error("|\n")

// Messages
::CmdMessages <- ::Messages.BIM.CMD;
::CmdDocs <- ::Messages.BIM.Docs;

// Custom hooks and commands tables
::PS_Hooks <- {}
::PS_Scripts <- {}
::PS_PreviousScriptsNames <- {}

foreach(eventname,tbl in ::VSLib.EasyLogic.Notifications)
{
	::PS_Hooks[eventname] <- {}
}

// Table of all existing classnames
::EntityClassesTable <- {}
foreach(cat,tbls in ::EntityDetailTables)
{
	foreach(cls,detailtbl in tbls)
		::EntityClassesTable[cls] <- true
}

if ( SessionState.ModeName == "coop" || SessionState.ModeName == "realism" || SessionState.ModeName == "survival" || SessionState.ModeName == "versus" || SessionState.ModeName == "scavenge" )
{
	if("SessionOptions" in getroottable())
	{
		if ( "cm_AggressiveSpecials" in ::SessionOptions )
			delete ::SessionOptions.cm_AggressiveSpecials;
		
		if ( "PreferredMobDirection" in ::SessionOptions )
			delete ::SessionOptions.PreferredMobDirection;
	}
	else
		::SessionOptions <- {}
}

Utils.PrecacheCSSWeapons();

Convars.SetValue( "precache_all_survivors", "1" );

if(!("date" in getroottable()))
{
	::date <- function()
	{
		try
		{
			local t = {};
			LocalTime(t);
			return t;
		}
		catch(e)
		{
			printR("[DATE-ERROR] date() failed")
			local d = 
			{
				year = 2021
				month = 1
				day = 1
				hour = 12
				minute = 0
				second = 0
				dayofweek = 1
				dayofyear = 1
				daylightsavings = 0
			}
			return d
		}
	}
}

// The admin list
::AdminSystem <-
{
	UserLevels = {}

	Admins = {}
	ScriptAuths = {}
	HostPlayer = {}

	BannedPlayers = {}
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

if("date" in getroottable())
{
	try
	{
		::AdminSystem.StartTime <- date()
	}
	catch(_err)
	{
		printR("[DATE-ERROR] date() failed")
		::AdminSystem.StartTime <- 
		{
			year = 2021
			month = 1
			day = 1
			hour = 12
			minute = 0
			second = 0
			dayofweek = 1
			dayofyear = 1
			daylightsavings = 0
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.AttachHook <- function(player,args)
{	
	local event = GetArgument(1)
	local hookname = GetArgument(2)
	if(hookname == null)
		return;
	
	if(!(event in PS_Hooks))
	{
		Printer(player,"Unknown event name: "+event);
		return;
	}

	if(!(hookname in PS_Hooks[event]))
	{
		Printer(player,"Unknown hook name: "+hookname);
		return;
	}

	if(hookname in ::VSLib.EasyLogic.Notifications)
	{
		Printer(player,"Hook was already attached: "+hookname);
		return;
	}
	else
	{
		::VSLib.EasyLogic.Notifications[hookname] <- PS_Hooks[hookname]
	}
}

/*
 * @authors rhino
 */
::AdminSystem.DetachHook <- function(player,args)
{	
	local event = GetArgument(1)
	local hookname = GetArgument(2)
	if(hookname == null)
		return;
	
	if(!(event in PS_Hooks))
	{
		Printer(player,"Unknown event name: "+event);
		return;
	}

	if(!(hookname in PS_Hooks[event]))
	{
		Printer(player,"Unknown hook name: "+hookname);
		return;
	}

	if(!(hookname in ::VSLib.EasyLogic.Notifications))
	{
		Printer(player,"Hook was already detached: "+hookname);
		return;
	}
	else
	{
		delete ::VSLib.EasyLogic.Notifications[hookname]
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadCustomHooks <- function()
{
	printl("---------------------------------------------------------")
	local filelist = FileToString(Constants.Directories.CustomHooks);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Hooks] Creating "+Constants.Directories.CustomHooks+" for the first time...")
		StringToFile(Constants.Directories.CustomHooks,Constants.CustomHookListDefaults);
		filelist = FileToString(Constants.Directories.CustomHooks);
	}

	local example = FileToString(Constants.Directories.CustomHooksExample);	// Example
	if(example == null)
	{
		printR("[Custom-Hooks] Creating "+Constants.Directories.CustomHooksExample+" for the first time...")
		StringToFile(Constants.Directories.CustomHooksExample,Constants.CustomHookDefaults);
		example = FileToString(Constants.Directories.CustomHooksExample);
	}

	local filelist = split(filelist, "\r\n");
	local missingfound = false
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/hooks/"+filename+".nut"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		
		compilestring(fileContents)();
	}
	
	local total = 0
	foreach(eventname,funcs in ::PS_Hooks)
	{
		if(!(eventname in ::VSLib.EasyLogic.Notifications))
		{
			printR("[Event-Hook-Unknown] "+eventname+" is unknown! Consider checking given links in the example file!")
		}
		else
		{
			if(typeof funcs != "table")
			{
				printR("[Event-Hook-Error] Event hooks for "+eventname+ " were formatted incorrectly! Format is-> PS_Hooks.On{GameEvent}.{FunctionName}<-function(param_1,param_2,...){}")
			}
			else
			{
				foreach(funcname, func in funcs)
				{
					total += 1
					::VSLib.EasyLogic.Notifications[eventname][funcname] <- func;
				}
			}
		}
	}
	printR("[Custom-Hooks] Found "+::PS_Hooks.len()+" events and a total of "+total+" hooks")
	printl("---------------------------------------------------------")
}

/*
 * @authors rhino
 */
::AdminSystem.LoadCustomScripts <- function()
{
	printl("---------------------------------------------------------")
	local filelist = FileToString(Constants.Directories.CommandScripts);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Scripts] Creating "+Constants.Directories.CommandScripts+" for the first time...")
		StringToFile(Constants.Directories.CommandScripts,Constants.CommandScriptListDefaults);
		filelist = FileToString(Constants.Directories.CommandScripts);
	}

	local example = FileToString(Constants.Directories.CommandScriptsExample);	// Example
	if(example == null)
	{
		printR("[Custom-Scripts] Creating "+Constants.Directories.CommandScriptsExample+" for the first time...")
		StringToFile(Constants.Directories.CommandScriptsExample,Constants.CommandScriptDefaults);
		example = FileToString(Constants.Directories.CommandScriptsExample);
	}

	local filelist = split(filelist, "\r\n");
	local missingfound = false
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/scripts/"+filename+".nut"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		
		compilestring(fileContents)();
	}

	printR("[Custom-Scripts] Reading custom command files...")
	local loaded = {}
	local i = 0
	foreach(cmdname, cmdtable in ::PS_Scripts)
	{	
		if(cmdname in ::AliasCompiler.ForbiddenAliasNames)	// Forbidden named
		{
			printR("[Forbidden-Name] Command name can not be "+cmdname+". Consider changing it!")
			continue;
		}
		if(cmdname in ::ChatTriggers && !(cmdname in ::AliasCompiler.Tables || cmdname in ::PS_PreviousScriptsNames)) // Already a built-in trigger and wasn't custom alias or command
		{
			printR("[Command-Duplicate] Command name can not be "+cmdname+". Consider changing it!")
			continue;
		}
		else
		{
			if(cmdname in ::AliasCompiler.Tables) // Was custom command or alias
			{
				printR("[Command-Reload] "+cmdname+" already exists! Overwriting it...")
			}
			local prv = PS_USER_NONE
			if("MinimumUserLevel" in cmdtable && typeof cmdtable.MinimumUserLevel == "integer")
			{
				prv = cmdtable.MinimumUserLevel
				if(prv < PS_USER_NONE || prv > ::UserLevelNames.len())
				{
					printR("[Command-User-Level-Error] "+cmdname+" command's minimum user level is unknown! Allowing it's use for everyone");
					prv = PS_USER_NONE
				}
			}

			if("Main" in cmdtable && typeof cmdtable.Main == "function")
			{
				i += 1
				loaded[i] <- cmdname
				::ChatTriggers[cmdname] <- cmdtable.Main
				::PrivilegeRequirements[cmdname] <- prv
			}

			if("Help" in cmdtable && typeof cmdtable.Help == "table")
			{
				::ChatTriggerDocs[cmdname] <- @(player,args) Messages.DocCmdPlayer(player,::AliasCompiler.CreateDocsFunction(cmdname,cmdtable.Help,null)[0](player,args))
			}

			::PS_PreviousScriptsNames[cmdname] <- cmdtable
		}
	}

	if(loaded.len() > 0)
		printR("[Custom-Commands] Loaded "+loaded.len()+" custom commands:")
	foreach(i,name in loaded)
	{
		printl("\t["+i+"] "+name)
	}
	printl("---------------------------------------------------------")
}

/*
 * @authors rhino
 */
::AdminSystem.CreateAliasCommandCmd <- function(player,args,text)
{
	
	local alias = GetArgument(1);
	if(alias == null)
		return;

	delete args[0]

	local code = Utils.CombineArray(args," ",1)
	code = strip(code);
	local aliastbl = ::Constants.ValidateAliasTableFromChat(player,alias,code,"ChatTriggers");
	if(aliastbl == null)
		return;
		
	local a = ::AliasCompiler.CreateAlias(alias,aliastbl,"ChatTriggers");

	if(a==null)
		Printer(player,"No alias was created. Check for formatting errors","error")
	else
		Printer(player,"Created an alias named "+a._name+" referring "+a._cmds.len()+" commands")
}

/*
 * @authors rhino
 */
::AdminSystem.ReplaceAliasCommandCmd <- function(player,args,text)
{
	
	local alias = GetArgument(1);
	if(alias == null)
		return;
	
	if(!(alias in ::ChatTriggers && alias in ::AliasCompiler.Tables))
	{
		Printer(player,COLOR_ORANGE+alias+COLOR_DEFAULT+" is not a known alias. Use "+COLOR_OLIVE_GREEN+"!create_alias "+COLOR_DEFAULT+"to create new aliases!")
		return;
	}
	else
	{
		delete ::AliasCompiler.Tables[alias]
		delete ::ChatTriggers[alias]
		delete ::ChatTriggerDocs[alias]
	}

	delete args[0]

	local code = Utils.CombineArray(args," ",1)
	code = strip(code);
	local aliastbl = ::Constants.ValidateAliasTableFromChat(player,alias,code,"ChatTriggers");
	if(aliastbl == null)
		return;

	local a = ::AliasCompiler.CreateAlias(alias,aliastbl,"ChatTriggers");

	if(a==null)
		Printer(player,"No alias was created. Check for formatting errors","error")
	else
		Printer(player,"Replaced the alias named "+a._name+" referring "+a._cmds.len()+" commands")
}

/*
 * @authors rhino
 */
::AdminSystem.LoadAliasedCommands <- function(reload=false)
{
	local filelist = FileToString(Constants.Directories.CommandAliases);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Aliases] Creating "+Constants.Directories.CommandAliases+" for the first time...")
		StringToFile(Constants.Directories.CommandAliases,Constants.CommandAliasesListDefaults);
		filelist = FileToString(Constants.Directories.CommandAliases);
	}

	local example = FileToString(Constants.Directories.CommandAliasesExample);	// Example v100
	if(example == null)
	{
		printR("[Alias-Examples] Creating v1.0.0 examples in "+Constants.Directories.CommandAliasesExample+" for the first time...")
		StringToFile(Constants.Directories.CommandAliasesExample,Constants.CommandAliasesDefaults.v1_0_0);
		example = FileToString(Constants.Directories.CommandAliasesExample);
	}

	// Version based examples
	foreach(vers,count in ::Constants.AliasExampleVersions)
	{	
		local cleanvers = Utils.StringReplace(vers,@"\.","_");
		local pth = Constants.Directories.CommandAliasesExampleVersionBased(cleanvers)
		local ex = FileToString(pth);
		if(ex == null)
		{
			printR("[Alias-Examples] Creating "+count+" new examples from version "+vers+" in "+pth+" for the first time...")
			StringToFile(pth,Constants.CommandAliasesDefaults[cleanvers]);
			ex = FileToString(pth);
		}
	}

	local filelist = split(filelist, "\r\n");
	local missingfound = false
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/aliases/"+filename+".txt"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		local tbl = ::Constants.ValidateAliasTable(fileContents,filename,i==0,reload,"ChatTriggers");
		::AliasCompiler.CreateAliasFromTable(tbl,"ChatTriggers")
	}
	
	printl("---------------------------------------------------------")
	printR("[Custom-Aliases] Aliased commands for this session ("+::AliasCompiler.Tables.len()+")")
	local i = 0;
	foreach(name,al in ::AliasCompiler.Tables)
	{
		i += 1
		printl("\t["+i+"] "+name)
	}
	printl("---------------------------------------------------------")
}

/*
 * @authors rhino
 */
::AdminSystem.LoadLootTables <- function()
{
	local fileContents = FileToString(Constants.Directories.LootTables);
	if(fileContents == null)
	{
		printR("[Loot-Tables] Creating "+Constants.Directories.LootTables+" for the first time...")
		StringToFile(Constants.Directories.LootTables,strip(Constants.LootSourcesLootTablesDefaults));
		fileContents = FileToString(Constants.Directories.LootTables);
	}
	local arr = []
	try
	{
		arr = compilestring("local __tempvar__ =[\n"+strip(fileContents)+"\n];return __tempvar__;")()
	}
	catch(e)
	{
		printR("[Loot-Tables-Error] File format was invalid, using default loots! Error: "+e)
		::AdminSystem.LootSourcesLootTables <- null
		return null;
	}

	if(arr == null || typeof arr != "array")
	{
		printR("[Loot-Tables-Error] File format was invalid, using default loots!")
		::AdminSystem.LootSourcesLootTables <- null
		return null;
	}
	else
	{
		local valid_arr = []
		printR("[Loot-Tables-Checks] Doing loot table checks...")
		foreach(i,tbl in arr)
		{
			if(typeof tbl != "table")
			{
				printR("[Loot-Tables-Error] File should contain tables seperated with commas! Using default loots!")
				::AdminSystem.LootSourcesLootTables <- null
				return null;
			}
			else
			{
				if(!("ent" in tbl))
				{
					printR("[Loot-Tables-Warning] There is a table missing \"ent\" entry, skipping the table")
					continue
				}
				if(!("prob" in tbl))
				{
					printR("[Loot-Tables-Warning] There is a table missing \"prob\" entry, skipping the table")
					continue
				}
				if(!("ammo" in tbl))
				{
					printl("\t[Loot-Tables-Warning] There is a table missing \"ammo\" entry, using 0 ammo")
					tbl.ammo <- 0
				}
				if(!("melee_type" in tbl))
				{
					printl("\t[Loot-Tables-Warning] There is a table missing \"melee_type\" entry, using \"any\" melee_type")
					tbl.melee_type <- null
				}
				valid_arr.append(tbl)
			}
		}
		::AdminSystem.LootSourcesLootTables <- valid_arr
		printR("[Loot-Tables-Checks] Completed checks and loaded the loot tables")
	}
}

/*
 * @authors rhino
 */
::AdminSystem.BindWithQuixCmd <- function(player,args)
{
	
	local target = GetArgument(1)
	local keyv = GetArgument(2)
	local cmd = GetArgument(3)
	if(cmd == null)
		return
	
	if(target == "!self")
	{
		target = player
	}
	else if(target)
	{
		target = Player(target)
		if(!target || !target.IsEntityValid())
			return
	}

	local steamid = target.GetSteamID()
	local keyv = ::Quix.GetKeyConst(keyv,player)

	local timername = ::Quix.FormatName(target,keyv,cmd)
	if(timername in ::Quix.Table)
	{
		Quix.Remove(timername)
	}

	if("CustomBindsTable" in AdminSystem)
	{
		if("all" in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable.all)
			{
				if(::Quix.GetKeyConst(key) != keyv)
					continue
				else
				{
					::Quix.ProcessTable(player,key,keytbl)
				}
			}
		}
		if(steamid in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable[steamid])
			{
				if(::Quix.GetKeyConst(key) != keyv)
					continue
				else
				{
					::Quix.ProcessTable(player,key,keytbl)
				}
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UnbindWithQuixCmd <- function(player,args)
{
	
	local target = GetArgument(1)
	local keyv = GetArgument(2)
	local cmd = GetArgument(3)
	if(cmd == null)
		return
	
	if(target == "!self")
	{
		target = player
	}
	else if(target)
	{
		target = Player(target)
		if(!target || !target.IsEntityValid())
			return
	}

	local steamid = target.GetSteamID()

	local timername = ::Quix.FormatName(target,keyv,cmd)
	if(timername in ::Quix.Table)
	{
		Quix.Remove(timername)
	}
}

function Notifications::OnPlayerConnected::ProcessQuixBinds(player,args)
{
	if(!player || !player.HasPrivilege(PS_USER_ADMIN))
		return;

	local steamid = player.GetSteamID()
	if("CustomBindsTable" in AdminSystem)
	{
		printR("[Binds-Process] Processing binds for "+player.GetName()+format("(%s)",steamid))
		if(steamid in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable[steamid])
			{
				::Quix.ProcessTable(player,key,keytbl)
			}
		}

		if("all" in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable.all)
			{
				::Quix.ProcessTable(player,key,keytbl)
			}
		}
	}
}

function Notifications::OnPlayerLeft::RemoveQuixBinds(player, name, steamID, params)
{
	if(!player || !player.HasPrivilege(PS_USER_ADMIN))
		return;

	if("CustomBindsTable" in AdminSystem)
	{
		if(steamID in AdminSystem.CustomBindsTable)
		{
			printR("[Binds-Removal] Removing personal binds for "+name)
			foreach(key,keytbl in AdminSystem.CustomBindsTable[steamID])
			{
				foreach(func,tbl in keytbl)
				{
					::Quix.Remove(::Quix.FormatName(player,key,func))
				}
			}
		}

		if("all" in AdminSystem.CustomBindsTable)
		{
			printR("[Binds-Removal] Removing global binds for "+name)
			foreach(key,keytbl in AdminSystem.CustomBindsTable.all)
			{
				foreach(func,tbl in keytbl)
				{
					::Quix.Remove(::Quix.FormatName(player,key,func))
				}
			}
		}
	}
}

/*
 * @authors rhino
 */
function Notifications::OnPlayerReplacedBot::ProcessQuixBinds(player,bot,args)
{
	if(!player || !bot || !player.HasPrivilege(PS_USER_ADMIN))
		return;

	local steamid = player.GetSteamID()
	if("CustomBindsTable" in AdminSystem)
	{
		printR("[Binds-Process] Processing binds for "+player.GetName()+format("(%s)",steamid))
		if(steamid in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable[steamid])
			{
				::Quix.ProcessTable(player,key,keytbl)
			}
		}

		if("all" in AdminSystem.CustomBindsTable)
		{
			foreach(key,keytbl in AdminSystem.CustomBindsTable.all)
			{
				::Quix.ProcessTable(player,key,keytbl)
			}
		}
	}
}

/*
 * @authors rhino
 */
function Notifications::OnBotReplacedPlayer::RemoveQuixBinds(player,bot,args)
{
	if(player.HasPrivilege(PS_USER_ADMIN))
	{
		if("CustomBindsTable" in AdminSystem)
		{
			local name = player.GetName()
			local steamID = player.GetSteamID()
			
			if(steamID in AdminSystem.CustomBindsTable)
			{
				printR("[Binds-Removal] Removing personal binds for "+name)
				foreach(key,keytbl in AdminSystem.CustomBindsTable[steamID])
				{
					foreach(func,tbl in keytbl)
					{
						::Quix.Remove(::Quix.FormatName(player,key,func))
					}
				}
			}

			if("all" in AdminSystem.CustomBindsTable)
			{
				printR("[Binds-Removal] Removing global binds for "+name)
				foreach(key,keytbl in AdminSystem.CustomBindsTable.all)
				{
					foreach(func,tbl in keytbl)
					{
						::Quix.Remove(::Quix.FormatName(player,key,func))
					}
				}
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadQuixBinds <- function(reload=false)
{
	local filelist = FileToString(Constants.Directories.CustomBinds);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Binds] Creating "+Constants.Directories.CustomBinds+" for the first time...")
		StringToFile(Constants.Directories.CustomBinds,strip(Constants.CustomBindsListDefaults));
		filelist = FileToString(Constants.Directories.CustomBinds);
	}

	local example = FileToString(Constants.Directories.CustomBindsExample);	// Example v150
	if(example == null)
	{
		printR("[Binds-Examples] Creating v1.5.0 examples in "+Constants.Directories.CustomBindsExample+" for the first time...")
		StringToFile(Constants.Directories.CustomBindsExample,strip(Constants.CustomBindsTableDefaults.v1_5_0));
		example = FileToString(Constants.Directories.CustomBindsExample);
	}

	// Version based examples
	// foreach(vers,count in ::Constants.CustomBindsExampleVersions)
	// {	
	// 	local cleanvers = Utils.StringReplace(vers,@"\.","_");
	// 	local pth = Constants.Directories.CustomBindsExampleVersionBased(cleanvers)
	// 	local ex = FileToString(pth);
	// 	if(ex == null)
	// 	{
	// 		printR("[Binds-Examples] Creating "+count+" new examples from version "+vers+" in "+pth+" for the first time...")
	// 		StringToFile(pth,Constants.CustomBindsTableDefaults[cleanvers]);
	// 		ex = FileToString(pth);
	// 	}
	// }

	if(!("CustomBindsTable" in AdminSystem))
	{
		AdminSystem.CustomBindsTable <- {}
	}

	local filelist = split(filelist, "\r\n");
	
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/binds/"+filename+".nut"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		local tbl = ::Constants.ValidateBindsTable(fileContents,filename,i==0,reload);

		foreach(s_id,keys in tbl)
		{
			if(!(s_id in AdminSystem.CustomBindsTable))
				AdminSystem.CustomBindsTable[s_id] <- {}

			foreach(key,binds in keys)
			{
				if(!(key in AdminSystem.CustomBindsTable[s_id]))
					AdminSystem.CustomBindsTable[s_id][key] <- {}
					
				foreach(k,v in binds)
				{
					AdminSystem.CustomBindsTable[s_id][key][k] <- v
				}
			}
		}
	}

	foreach(steam_id,keys in AdminSystem.CustomBindsTable)
	{
		if(steam_id == "all")
		{
			foreach(surv in Players.AliveSurvivors())
			{
				if (surv.GetSteamID() == "BOT" || !surv.HasPrivilege(PS_USER_ADMIN))
					continue;
									
				foreach(key,keytbl in keys)
				{
					::Quix.ProcessTable(surv,key,keytbl)
				}
			}
		}
		else
		{
			local ent = Utils.GetPlayerFromSteamID(steam_id)
			if(ent)
			{
				foreach(key,keytbl in keys)
				{
					::Quix.ProcessTable(ent,key,keytbl)
				}
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadEntityGroups <- function(reload=false)
{
	local filelist = FileToString(Constants.Directories.CustomProps);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Entity_Groups] Creating "+Constants.Directories.CustomProps+" for the first time...")
		StringToFile(Constants.Directories.CustomProps,strip(Constants.CustomPropsListDefaults));
		filelist = FileToString(Constants.Directories.CustomProps);
	}

	local example = FileToString(Constants.Directories.CustomPropsExample);	// Example v140
	if(example == null)
	{
		printR("[Entity_Groups-Examples] Creating v1.4.0 examples in "+Constants.Directories.CustomPropsExample+" for the first time...")
		StringToFile(Constants.Directories.CustomPropsExample,strip(Constants.CustomPropsDefaults.v1_4_0));
		example = FileToString(Constants.Directories.CustomPropsExample);
	}

	// Version based examples
	foreach(vers,count in ::Constants.EntityGroupsExampleVersions)
	{	
		local cleanvers = Utils.StringReplace(vers,@"\.","_");
		local pth = Constants.Directories.CustomPropsExampleVersionBased(cleanvers)
		local ex = FileToString(pth);
		if(ex == null)
		{
			printR("[Alias-Examples] Creating "+count+" new examples from version "+vers+" in "+pth+" for the first time...")
			StringToFile(pth,Constants.CustomPropsDefaults[cleanvers]);
			ex = FileToString(pth);
		}
	}

	if(!("EntityGroupSpawnRestrictions" in AdminSystem))
	{
		AdminSystem.EntityGroupSpawnRestrictions <- {}
	}

	local filelist = split(filelist, "\r\n");
	local missingfound = false
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/entitygroups/"+filename+".nut"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		local tbls = ::Constants.ValidateEntityGroupsTable(fileContents,filename,i==0,reload);
		if(tbls)
		{
			foreach(name,restr in tbls.restrictions)
			{
				AdminSystem.EntityGroupSpawnRestrictions[name] <- restr
			}
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.AddDisabledCommandCmd <- function(player,args)
{
	local cmd = GetArgument(1);
	if(cmd != null && cmd in ::ChatTriggers && !(cmd in ::VSLib.EasyLogic.DisabledCommands))
	{
		::VSLib.EasyLogic.DisabledCommands[cmd] <- true
		Printer(player,"Disabled command: "+cmd)
	}

}

/*
 * @authors rhino
 */
::AdminSystem.RemoveDisabledCommandCmd <- function(player,args)
{
	local cmd = GetArgument(1);
	if(cmd != null && cmd in ::ChatTriggers && cmd in ::VSLib.EasyLogic.DisabledCommands)
	{
		delete ::VSLib.EasyLogic.DisabledCommands[cmd]
		Printer(player,"Re-enabled command: "+cmd)
	}

}

/*
 * @authors rhino
 */
::AdminSystem.LoadDisabledCommands <- function ()
{
	local fileContents = FileToString(Constants.Directories.DisabledCommands);
	if(fileContents == null)
	{
		printR("[Command-Limits] Creating disabled_commands.txt for the first time...")
		StringToFile(Constants.Directories.DisabledCommands,Constants.DisabledCommandsDefaults);
		fileContents = FileToString(Constants.Directories.DisabledCommands);
	}

	local commands = split(fileContents, "\r\n");
	local missingfound = false
	foreach (i,cmd in commands)
	{	
		cmd = strip(cmd)
		if(cmd.find("//") == 0)
			continue;
		else if(cmd.find("//") != null)
		{
			cmd = strip(split(cmd,"//")[0])
		}

		if(cmd in ::ChatTriggers)
		{
			::VSLib.EasyLogic.DisabledCommands[cmd] <- true
		}
		else if(cmd != "command_name_1" && cmd != "command_name_2")
		{
			if(!missingfound)
			{
				missingfound = true
				printR("[Command-Limits] Found unknown command names in the disabled_commands.txt, consider removing them to save space:")
			}
			printl("\t[Row "+(i+1)+"] "+cmd)
		}
	}
	
	if(::VSLib.EasyLogic.DisabledCommands.len() > 0)
	{	
		printl("---------------------------------------------------------")
		printR("[Command-Limits] Disabled commands for this session ("+::VSLib.EasyLogic.DisabledCommands.len()+"):")
		local i = 0;
		foreach(cmd,_v in ::VSLib.EasyLogic.DisabledCommands)
		{
			i += 1
			printl("\t["+i+"] "+cmd)
		}
		printl("---------------------------------------------------------")
	}
}

/*
 * @authors rhino
 */
::AdminSystem.AddCommandBanCmd <- function(player,args)
{
	local character = GetArgument(1);
	if(character == null)
		return;
	
	local target = Player(character)
	if(target == null || !target.IsEntityValid())
	{
		target = Utils.GetPlayerFromName(character.tolower())
		if(target == null || !target.IsEntityValid())
			return
	}
	if(target.IsServerHost())
	{
		Printer(player,"Can't ban commands for the host!");
		return;
	}
	local banfromall = false
	local cmd = GetArgument(2);
	if(cmd == null)
		banfromall = true

	local duration = GetArgument(3);
	if(duration == null)
		duration = 999999
	else
		duration = duration.tofloat()

	local steamid = target.GetSteamID()
	if(banfromall)
	{
		foreach(cmd,trigger in ::ChatTriggers)
		{
			if(!(cmd in ::VSLib.EasyLogic.TemporaryCmdBanList))
			{
				::VSLib.EasyLogic.TemporaryCmdBanList[cmd] <- {}
			}
			::VSLib.EasyLogic.TemporaryCmdBanList[cmd][steamid] <- Time() + duration
		}
		Printer(player,"Banned "+target.GetCharacterNameLower()+" from using all commands for "+duration+" seconds")
	}
	else
	{
		if(cmd in ::ChatTriggers)
		{
			if(!(cmd in ::VSLib.EasyLogic.TemporaryCmdBanList))
			{
				::VSLib.EasyLogic.TemporaryCmdBanList[cmd] <- {}
			}
			::VSLib.EasyLogic.TemporaryCmdBanList[cmd][steamid] <- Time() + duration
			::VSLib.EasyLogic.TemporaryCmdBanList.command_unban[steamid] <- Time() + duration
			Printer(player,"Banned "+target.GetCharacterNameLower()+" from using "+cmd+" for "+duration+" seconds")
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.RemoveCommandBanCmd <- function(player,args)
{
	local character = GetArgument(1);
	if(character == null)
		return;
	
	local target = Player(character)
	if(target == null || !target.IsEntityValid())
	{
		target = Utils.GetPlayerFromName(character.tolower())
		if(target == null || !target.IsEntityValid())
			return
	}

	local unbanfromall = false
	local cmd = GetArgument(2);
	if(cmd == null)
		unbanfromall = true

	local steamid = target.GetSteamID()
	if(unbanfromall)
	{
		foreach(command,bantbl in ::VSLib.EasyLogic.TemporaryCmdBanList)
		{
			if(steamid in bantbl)
			{
				delete ::VSLib.EasyLogic.TemporaryCmdBanList[command][steamid]
			}
		}
		Printer(player,"Unbanned "+target.GetCharacterNameLower()+" from using all commands")
	}
	else
	{
		if(cmd in ::VSLib.EasyLogic.TemporaryCmdBanList && steamid in ::VSLib.EasyLogic.TemporaryCmdBanList[cmd])
		{
			delete ::VSLib.EasyLogic.TemporaryCmdBanList[cmd][steamid]
			if(steamid in ::VSLib.EasyLogic.TemporaryCmdBanList.command_unban )
				delete ::VSLib.EasyLogic.TemporaryCmdBanList.command_unban[steamid]
				
			Printer(player,"Unbanned "+target.GetCharacterNameLower()+" from using "+cmd)
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.ChangeCmdPrivileges <- function (player, args)
{
	local lvl, cmd = GetArgument(1);
	
	if(!(cmd in ::PrivilegeRequirements) || cmd == "command_privilege")
	{
		Printer(player,"Invalid command name: "+cmd,"error")
		return
	}

	if(!(lvl = ::UserLevelUtils.ValidateLevel(player, GetArgument(2), false, true)))
		return
	
	::PrivilegeRequirements[cmd] <- getconsttable()[lvl]
	::Messages.InformAll("Changed "+cmd+" command's minimum user level to: "+lvl)
}

/*
 * @authors rhino
 */
::AdminSystem.LoadCmdPrivileges <- function ()
{
	local fileContents = FileToString(Constants.Directories.CommandPrivileges);
	if(fileContents == null)
	{
		printR("[Command-Privileges] Creating command_privileges.txt for the first time...")
		StringToFile(Constants.Directories.CommandPrivileges,Constants.CommandPrivilegesDefault + "\r\n\r\n\r\n\r\n\r\n\r\n\r\n");
		fileContents = FileToString(Constants.Directories.CommandPrivileges);
	}
	
	local rows = split(fileContents, "\r\n");
	
	foreach (row in rows)
	{
		row = strip(row)
		if(row.find("//") == 0 || row == "")
			continue
		
		if(row.find("//") != null)
			row = rstrip(Utils.StringReplace(row, "//" + ".*", ""));

		local splt = split(row, "=")
		if(splt.len() != 2)
			continue;
		local command = strip(splt[0])
		local level = strip(splt[1])
		if (!(command in ::PrivilegeRequirements) )
		{
			printl("\t[PRIVILEGE-COMMAND-ERROR] Command: '"+splt[0]+"' is not recognized")
			continue
		}
		if(Utils.GetIDFromArray(::UserLevelNames,level) == -1)
		{
			printl("\t[PRIVILEGE-LEVEL-ERROR] Privilege level: '"+splt[1]+"' is not recognized for command: "+splt[0])
			continue
		}
		
		::PrivilegeRequirements[command] = getconsttable()[level];
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadCommandRestrictions <- function ()
{
	local fileContents = FileToString(Constants.Directories.CommandRestrictions);
	if(fileContents == null)
	{
		printR("[Command-Limits] Creating command_limits.txt for the first time...")
		StringToFile(Constants.Directories.CommandRestrictions,Constants.CommandRestrictionsDefault);
		fileContents = FileToString(Constants.Directories.CommandRestrictions);
	}
	
	local tbl = compilestring("local __tempvar__="+fileContents+";return __tempvar__;")()

	tbl = ::Constants.ValidateCommandRestrictionTable(tbl,fileContents);

	::VSLib.EasyLogic.CommandRestrictions <- tbl
}

::AdminSystem.LoadAdmins <- function (searchForHost = true)
{
	local fileContents = FileToString(Constants.Directories.Admins);
	local admins = split(fileContents, "\r\n");
	
	foreach (admin in admins)
	{
		if( strip(admin) == ::Constants.Deprecate.Admins )
			return
			
		if ( admin.find("//") != null )
		{
			admin = Utils.StringReplace(admin, "//" + ".*", "");
			admin = rstrip(admin);
		}
		if ( admin.find("STEAM_0") != null )
			admin = Utils.StringReplace(admin, "STEAM_0", "STEAM_1");
		if ( admin != "" )
			::AdminSystem.Admins[admin] <- true;
		
		if ( searchForHost == true && AdminSystem.HostPlayer.len() == 0)
		{
			printR("[HOST-DECIDER-LoadAdmins] New host is "+admin)
			AdminSystem.HostPlayer[admin] <- true;
			searchForHost = false;
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.LoadUserLevels <- function (write = true)
{
	local fileContents = FileToString(Constants.Directories.UserLevels);
	local rows = split(fileContents, "\r\n");
	local currhost, currname, currhostname = "";
	local tbl = {}
	foreach (row in rows)
	{
		row = strip(row)
		if(row.find("//") == 0 || row == "")
			continue
		
		if(row.find("//") != null)
		{
			currname = row.slice(row.find("//") + 2)
			row = rstrip(Utils.StringReplace(row, "//" + ".*", ""));
		}
		else
		{
			currname = ""
		}

		local splt = split(row, "=")
		if(splt.len() != 2)
			continue;
		local user = strip(splt[0])
		local level = strip(splt[1])
		if(Utils.GetIDFromArray(::UserLevelNames,level) == -1)
		{
			level = "PS_USER_NONE";
			printR("[USER-LEVEL-ERROR] User level: '"+splt[1]+"' is not recognized for user: "+splt[0])
		}
		
		if ( user.find("STEAM_0") != null )
			user = Utils.StringReplace(user, "STEAM_0", "STEAM_1");

		if ( user != "" )
			::AdminSystem.UserLevels[user] <- level;
			
		if(::AdminSystem.HostPlayer.len() == 0 && level == "PS_USER_HOST")
		{
			printR("[HOST-DECIDER-LoadUserLevels] New host is "+user)
			::AdminSystem.HostPlayer[user] <- true
			currhost = user
			currhostname = currname
		}

		tbl[user] <- [level,currname];
	}

	local contents = Constants.UserLevelExplain
	if(currhost)
	{
		contents += currhost + " = " + ::UserLevelNames[PS_USER_HOST] + " // " + currhostname + "\r\n";
	}
	// Rewrite file to remove repeats
	foreach(sid,lis in tbl)
	{
		if(sid != currhost)
			contents += sid + " = " + ::UserLevelNames[getconsttable()[lis[0]]] + " // " + lis[1] + "\r\n";
	}

	if(write)
	{
		StringToFile(Constants.Directories.UserLevels, contents);
		::AdminSystem.LoadUserLevels(false)
	}
	else
		AdminSystem.LoadCustomSequences();

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
		if ( strip(setting) != "" )
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
::AdminSystem.LoadGhostZombiesSettings <- function ()
{
	local fileContents = FileToString(Constants.Directories.GhostZombiesSettings);
	local settings = split(fileContents, "\r\n");
	
	if(!("_ghost_zombies" in AdminSystem))
		AdminSystem._ghost_zombies <- {};

	foreach (setting in settings)
	{
		if ( strip(setting) != "" )
		{	
			compilestring("AdminSystem._ghost_zombies." + Utils.StringReplace(setting, "=", "<-"))();
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
		if ( strip(setting) != "" )
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
		if ( strip(setting) != "" )
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
						printR("[Meteor-Shower-Error] Failed to load the meteor_shower_settings.txt, delete the file to fix the issue.");
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
::AdminSystem.SaveGhostZombiesSettings <- function ()
{
	local comments = Constants.GetGhostZombiesSettingsComments();
	local newstring = "";
	local length = AdminSystem._ghost_zombies.len()-1;
	local i = 0;
	foreach (setting,val in AdminSystem._ghost_zombies)
	{	
		newstring += setting + " = " + val.tostring() + " // " + comments[setting];

		if(i < length)
			newstring += " \r\n"
	}
	StringToFile(Constants.Directories.GhostZombiesSettings, newstring);
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
	printR("[DEPRECATION-WARNING] 'AdminSystem.IsPrivileged(player,silent)' function has been deprecated! Use 'player.HasPrivilege(PS_USER_ADMIN)' in your functions!")
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) 
		return false;
	
	if ( !(player.HasPrivilege(PS_USER_ADMIN)) )
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

	if ( !(player.HasPrivilege(PS_USER_ADMIN)) )
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
::AdminSystem.HasScriptAuth <- function ( player , silent = false)
{
	printR("[DEPRECATION-WARNING] 'AdminSystem.HasScriptAuth(player,silent)' function has been deprecated! Use 'player.HasPrivilege(PS_USER_SCRIPTER)' in your functions!")
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !(player.HasPrivilege(PS_USER_SCRIPTER)) )
	{
		if ( AdminSystem.DisplayMsgs && !silent)
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
		local speed = 50.0;
		
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
function Notifications::OnRoundStart::RandomSeeding()
{
	try
	{
		local t = date()
		local seed = format("%d%02d%02d%02d%02d",t.month,t.day,t.hour,t.minute,t.second).tointeger();
		srand(seed)
		printR("[RANDOM-SEED] Using random seed: "+seed)
	}
	catch(e)
	{
		printR("[ERROR-RANDOM-SEED] Failed to set random seed: "+e)
	}
}

function Notifications::OnRoundStart::ColorfulVehicles()
{
	if(IsCurrentMapAnOfficialMap() && ::AdminSystem.Vars.ColorfulVehiclesState)
	{
		printR("[ColorfulVehicles] Setting random colors to props...")
		local low = split(::AdminSystem.Vars.ColorfulVehiclesRanges.darkest," ")
		local high = split(::AdminSystem.Vars.ColorfulVehiclesRanges.brightest," ")
		if(low.len() != 3)
		{
			printR("[COLORFUL_VEHICLES-ERROR] Darkest color range format is wrong!")
			return
		}
		if(high.len() != 3)
		{
			printR("[COLORFUL_VEHICLES-ERROR] Brightest color range format is wrong!")
			return
		}
		try
		{
			low = low.map(@(x) x.tointeger())
			high = high.map(@(x) x.tointeger())
		}
		catch(e)
		{
			printR("[COLORFUL_VEHICLES-ERROR] Color range has non-numeric values!")
			return
		}

		local valid_vehicle_classes =
		{
			prop_dynamic = true
			prop_dynamic_override = true
			prop_car_alarm = true
			prop_vehicle = true
			prop_physics_override = true
			prop_physics = true
		}

		local valid_vehicle_models =
		{
			"models/props_vehicles/cara_69sedan.mdl" : true
			"models/props_vehicles/cara_84sedan.mdl" : true
			"models/props_vehicles/cara_95sedan.mdl" : true
			"models/props_vehicles/cara_82hatchback.mdl" : true
			"models/props_vehicles/sailboat.mdl" : true
			"models/lostcoast/props_wasteland/boat_fishing01a.mdl" : true
			"models/props_vehicles/boat_fishing02_static.mdl" : true
			"models/lostcoast/props_wasteland/boat_drydock01a.mdl" : true
			"models/props_urban/boat001.mdl" : true
			"models/props_urban/boat002.mdl" : true
			"models/props_vehicles/boat_ski.mdl" : true
			"models/props_vehicles/boat_smash.mdl" : true
			"models/lostcoast/props_wasteland/boat_wooden01a.mdl" : true
			"models/lostcoast/props_wasteland/boat_wooden02a.mdl" : true
			"models/lostcoast/props_wasteland/boat_wooden03a.mdl" : true
			"models/props_canal/boat001a.mdl" : true
			"models/props_vehicles/train_enginecar.mdl" : true
			"models/props_vehicles/train_engine_military.mdl" : true
			"models/props_vehicles/train_box.mdl" : true
			"models/props_vehicles/train_box_open.mdl" : true
			"models/props_vehicles/train_box_small.mdl" : true
			"models/props_vehicles/train_boxwreck.mdl" : true
			"models/props_vehicles/boxcar_tanktrap_exterior.mdl" : true
			"models/props_vehicles/boxcar_tanktrap_interior.mdl" : true
			"models/props_vehicles/boxcar_tanktrap_door.mdl" : true
			"models/props_vehicles/train_orecar.mdl" : true
			"models/props_vehicles/train_flatcar.mdl" : true
			"models/props_vehicles/train_flatcar_small.mdl" : true
			"models/props_vehicles/train_tank.mdl" : true
			"models/props_vehicles/train_tank_small.mdl" : true
			"models/props_trainstation/train_transporter.mdl" : true
			"models/props_unique/subwaycar_all_onetexture.mdl" : true
			"models/props_vehicles/cara_95sedan_wrecked.mdl" : true
			"models/props_vehicles/cara_82hatchback_wrecked.mdl" : true
			"models/props_vehicles/news_van.mdl" : true
			"models/props_vehicles/van_cab_controls.mdl" : true
			"models/props_vehicles/longnose_truck.mdl" : true
			"models/props_vehicles/flatnose_truck.mdl" : true
			"models/props_vehicles/semi_truck3.mdl" : true
			"models/props_vehicles/pickup_truck_78.mdl" : true
			"models/props_vehicles/pickup_truck_2004.mdl" : true
			"models/props_vehicles/police_car_rural.mdl" : true
			"models/props_vehicles/suv_2001.mdl" : true
			"models/props_vehicles/taxi_cab.mdl" : true
			"models/props_vehicles/police_car_city.mdl" : true
			"models/props_vehicles/front_loader01_rear.mdl" : true
			"models/props_vehicles/front_loader01_front_down.mdl" : true
			"models/props_vehicles/van.mdl" : true
			"models/props_vehicles/van_cab_controls.mdl" : true
			"models/props_vehicles/boat_cabin35ft.mdl" : true
			"models/props_vehicles/boat_trailer35ft.mdl" : true
			"models/props_vehicles/utility_truck.mdl" : true
			"models/props_vehicles/utility_truck_windows.mdl" : true
			"models/props/de_nuke/truck_nuke.mdl" : true
			"models/props_vehicles/radio_generator.mdl" : true
			"models/props_vehicles/generatortrailer01.mdl" : true
			"models/props_vehicles/m119howitzer_01.mdl" : true
			"models/props_vehicles/deliveryvan_armored.mdl" : true
			"models/props_vehicles/floodlight_generator_nolight.mdl" : true
			"models/props_vehicles/airport_baggage_tractor.mdl" : true
			"models/props_vehicles/airport_baggage_cart2.mdl" : true
			"models/props_vehicles/airliner_finale_left.mdl" : true
			"models/props_vehicles/airliner_finale_right.mdl" : true
			"models/props_fairgrounds/bumpercar.mdl" : true
			"models/props_fairgrounds/coaster_car01.mdl" : true
			"models/props_waterfront/tour_bus.mdl" : true
			"models/props_vehicles/helicopter_rescue.mdl" : true
			"models/props_vehicles/racecar_damaged.mdl" : true
			"models/props_vehicles/bus01.mdl" : true
			"models/props_vehicles/bus01_2.mdl" : true
			"models/props_vehicles/church_bus01.mdl" : true
			"models/props_vehicles/c130.mdl" : true
		}

		foreach(classname,st in valid_vehicle_classes)
		{
			foreach(ent in Objects.OfClassname(classname))
			{
				if(ent.GetModel() in valid_vehicle_models)
					ent.SetColor(RandomInt(low[0],high[0]).tostring(),RandomInt(low[1],high[1]).tostring(),RandomInt(low[2],high[2]).tostring(),"255");
			}
		}
	}
}

function Notifications::OnRoundStart::AdminLoadFiles()
{
	// Deprecated
	local adminList = FileToString(Constants.Directories.Admins);
	local scriptauthList = FileToString(Constants.Directories.ScriptAuths);

	local userLevelList = FileToString(Constants.Directories.UserLevels);

	local banList = FileToString(Constants.Directories.Banned);
	local settingList = FileToString(Constants.Directories.Settings);

	local apocsettings = FileToString(Constants.Directories.ApocalypseSettings);
	local gssettings = FileToString(Constants.Directories.GhostZombiesSettings);
	local metosettings = FileToString(Constants.Directories.MeteorShowerSettings);

	local MessageTable = Messages.BIM.Events.OnRoundStart.AdminLoadFiles;

	AdminSystem.LoadCustomScripts()
	AdminSystem.LoadCustomHooks()
	AdminSystem.LoadAliasedCommands()
	AdminSystem.LoadEntityGroups()
	AdminSystem.LoadLootTables()
	AdminSystem.LoadQuixBinds()
	AdminSystem.LoadVehicles()
	
	AdminSystem.LoadDisabledCommands()
	AdminSystem.LoadCommandRestrictions()
	AdminSystem.LoadCmdPrivileges()

	// Deprecated
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

	if ( userLevelList != null )
	{
		MessageTable.LoadUserLevels();
		AdminSystem.LoadUserLevels();
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
	
	if ( gssettings != null )
	{
		MessageTable.LoadGhostZombiesSettings();
		AdminSystem.LoadGhostZombiesSettings();
	}
	else
	{	
		MessageTable.CreateGhostZombiesSettings();
		StringToFile(Constants.Directories.GhostZombiesSettings, Constants.Defaults.GhostZombiesSettings);
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
	IncludeScript("Project_smok/AdminVars");

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
		//printR("[Custom-Fix] Applying fixes to outputs table...");
		AdminSystem.Vars._outputsEnabled.coach <- AdminSystem.Vars._outputsEnabled.Coach;
		delete AdminSystem.Vars._outputsEnabled.Coach;
	}
	if("Coach" in AdminSystem.Vars._saveLastLine)
	{
		//printR("[Custom-Fix] Applying fixes to LastLine table...");
		AdminSystem.Vars._saveLastLine.coach <- AdminSystem.Vars._saveLastLine.Coach;
		delete AdminSystem.Vars._saveLastLine.Coach;
	}
	if("Coach" in AdminSystem.Vars._savedLine)
	{
		//printR("[Custom-Fix] Applying fixes to SavedLine table...");
		AdminSystem.Vars._savedLine.coach <- Utils.TableCopy(AdminSystem.Vars._savedLine.Coach);
		delete AdminSystem.Vars._savedLine.Coach;
	}
	if("Coach" in AdminSystem.Vars._saveLastModel)
	{
		//printR("[Custom-Fix] Applying fixes to LastModel table...");
		AdminSystem.Vars._saveLastModel.coach <- AdminSystem.Vars._saveLastModel.Coach;
		delete AdminSystem.Vars._saveLastModel.Coach;
	}
	if("Coach" in AdminSystem.Vars._savedModel)
	{
		//printR("[Custom-Fix] Applying fixes to SavedModel table...");
		AdminSystem.Vars._savedModel.coach <- Utils.TableCopy(AdminSystem.Vars._savedModel.Coach);
		delete AdminSystem.Vars._savedModel.Coach;
	}
	if("Coach" in AdminSystem.Vars._savedParticle)
	{
		//printR("[Custom-Fix] Applying fixes to SavedParticle table...");
		AdminSystem.Vars._savedParticle.coach <- Utils.TableCopy(AdminSystem.Vars._savedParticle.Coach);
		delete AdminSystem.Vars._savedParticle.Coach;
	}
	if("Coach" in AdminSystem.Vars._saveLastParticle)
	{
		//printR("[Custom-Fix] Applying fixes to LastParticle table...");
		AdminSystem.Vars._saveLastParticle.coach <- AdminSystem.Vars._saveLastParticle.Coach;
		delete AdminSystem.Vars._saveLastParticle.Coach;
	}
	if("Coach" in AdminSystem.Vars._preferred_duration)
	{
		//printR("[Custom-Fix] Applying fixes to preferred_duration table...");
		AdminSystem.Vars._preferred_duration.coach <- AdminSystem.Vars._preferred_duration.Coach;
		delete AdminSystem.Vars._preferred_duration.Coach;
	}
	if("Coach" in AdminSystem.Vars._prop_spawn_settings_menu_type)
	{
		//printR("[Custom-Fix] Applying fixes to prop_spawn_settings_menu_type table...");
		AdminSystem.Vars._prop_spawn_settings_menu_type.coach <- AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
		delete AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
	}
	if("Coach" in AdminSystem.Vars._prop_spawn_settings)
	{
		//printR("[Custom-Fix] Applying fixes to prop_spawn_settings table...");
		AdminSystem.Vars._prop_spawn_settings.coach <- Utils.TableCopy(AdminSystem.Vars._prop_spawn_settings.Coach);
		delete AdminSystem.Vars._prop_spawn_settings.Coach;
	}
	if("Coach" in AdminSystem.Vars._explosion_settings)
	{
		//printR("[Custom-Fix] Applying fixes to explosion_settings table...");
		AdminSystem.Vars._explosion_settings.coach <- Utils.TableCopy(AdminSystem.Vars._explosion_settings.Coach);
		delete AdminSystem.Vars._explosion_settings.Coach;
	}
	if("Coach" in AdminSystem.Vars._heldEntity)
	{
		//printR("[Custom-Fix] Applying fixes to HeldEntity table...");
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
		//printR("[Custom-Fix] Applying fixes to WornHat table...");
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
		//printR("[Custom-Fix] Applying fixes to model preference table...");
		AdminSystem.Vars._modelPreference.coach <- Utils.TableCopy(AdminSystem.Vars._modelPreference.Coach);
		delete AdminSystem.Vars._modelPreference.Coach;
	}
	local skip = false;
	if("Coach" in AdminSystem.Vars._CustomResponseOptions)
	{	
		//printR("[Custom-Fix] Applying fixes to CustomResponse table...");
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
		//printR("[OnRoundStart-Info] No need for fixes in CustomRespose tables");
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
		_grabAvailable = 
		{
			lookup = "boolean"
			blackliststr = ""
		}
		_grabbackupprop =
		{
			lookup = "boolean"
			blackliststr = "classname,modelname"
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
		_saveLastModel = 
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
			blackliststr = "rockorigin,rockpushspeed,raise,friction,mass_scale,rockspawnheight,modelspecific,custommodels,modelpick,modelchangedelay"
		}
		_modelPreference =
		{
			lookup = "boolean"
			blackliststr = "lastmodel,original"
		}
		LootCreationParams =
		{
			lookup = "boolean"
			blackliststr = "explosion_prob,hurt_prob,horde_prob,ambush_prob,LootDuration,NoItemProb,MinItems,MaxItems,SpawnDist,GlowR,GlowG,GlowB,GlowA,GlowRange,BarText,BarSubText"
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
		"IgnoreSpeakerClass",
		"CompileHexAndSpecialsInArguments"
	]

	foreach(key,datatbl in fixdata)
	{
		::AdminSystem.Vars.FixBooleanTable(AdminSystem.Vars,key,datatbl.lookup,datatbl.blackliststr);
	}

	::AdminSystem.Vars.FixBooleanValues(AdminSystem.Vars,basicbools,"boolean");

	// Model keeping between chapters bool
	foreach(ch,ctbl in ::AdminSystem.Vars._modelPreference)
	{
		::AdminSystem.Vars._modelPreference[ch].keeplast = ctbl.keeplast == 1
	}

	// Fix prop spawn settings tables, restores "flags" as "FLAGS"... smart
	foreach(name,cstbl in AdminSystem.Vars._prop_spawn_settings)
	{
		foreach(clsname,vals in cstbl)
		{
			foreach(setting,valtbl in vals)
			{
				if("FLAGS" in valtbl)
				{
					AdminSystem.Vars._prop_spawn_settings[name][clsname][setting].flags <- valtbl.FLAGS
					delete AdminSystem.Vars._prop_spawn_settings[name][clsname][setting].FLAGS
				}
			}
		}
	}
	// Fix model saving tables, restores "model" as "Model"... even smarter
	foreach(name,valtbl in AdminSystem.Vars._savedModel)
	{
		if("Model" in valtbl)
		{
			AdminSystem.Vars._savedModel[name].model <- valtbl.Model
			delete AdminSystem.Vars._savedModel[name].Model
		}
	}

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
		}

		// Tank rock models
		foreach(label,modelarr in AdminSystem.Vars._RockThrow)
		{
			//_rocks
			if((label=="custommodels") && ((typeof modelarr) != "array"))
			{	
				newmodelarray = []
				i = 0;
				while(i.tostring() in modelarr)
				{
					newmodelarray.append(modelarr[i.tostring()]);
					i += 1;
				}

				AdminSystem.Vars._RockThrow.custommodels = Utils.ArrayCopy(newmodelarray);
			}
		}
	}
		
	//}
	//catch(e){printR("[OnRoundStart-AdminLoadFiles] "+e);}
	
	printR("[Custom] Loaded custom responses created by admins");
	
	if(AdminSystem.Vars._ghost_zombies_state == 1)
	{
		::VSLib.Timers.AddTimer(Constants.TimerDelays.RoundStart.GhostZombies,false,Utils.PrintToAllDel,"Ghosts are back!");
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.GhostZombies,AdminSystem._ghost_zombies.timer_delay, true, _GhostZombiesTimer,{});	
	}

	if(AdminSystem.Vars._propageddon_state == 1)
	{
		::VSLib.Timers.AddTimer(Constants.TimerDelays.RoundStart.Apocalypse,false,Utils.PrintToAllDel,"Madness continues...");
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.Apocalypse,AdminSystem._propageddon_args.updatedelay, true, _ApocalypseTimer,{});	
	}

	if(AdminSystem.Vars._meteor_shower_state == 1)
	{
		::VSLib.Timers.AddTimer(Constants.TimerDelays.RoundStart.MeteorShower,false,Utils.PrintToAllDel,"Is it still raining?");
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.MeteorShower,AdminSystem._meteor_shower_args.updatedelay, true, _MeteorTimer,{});	
	}

	if(AdminSystem.Vars.LastLootThinkState)
	{
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.RoundStartBotShareEnable,Constants.TimerDelays.RoundStart.BotShareLoot,false,DelayedBotLootThinkAdder,{});
	}
	else
	{
		printR("[Bot-Thinker] Disabled looting/sharing thinking for bots ");
	}

	//Restore models if necessary
	foreach(survivor in Players.AliveSurvivors())
	{
		AdminSystem.RestoreModels(survivor);
	}
}

::DelayedBotLootThinkAdder <- function(...)
{
	local found = Objects.AnyOfName("think_adder_base_entity")
	if(found != null)
	{
		printR("[Bot-Thinker] Bot looting/sharing thinking already enabled via adder #"+found.GetIndex());
		return;
	}
	local tadd = _CreateLootThinker();
	printR("[Bot-Thinker] Enabled looting/sharing thinking for bots via adder #"+tadd.GetIndex());
}

::AdminSystem.RestoreModels <- function(player)
{
	if(!("Vars" in AdminSystem) || !("RestoreModelsOnJoin" in AdminSystem.Vars))
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

function Notifications::OnPlayerConnected::FixEyeAngles(player,args)
{
	local ang = player.GetEyeAngles()
	player.SetEyeAngles(ang.x,ang.y,0);
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

/*
 * @authors rhino
 */
function Notifications::OnPlayerJoined::UserLevelCheck( player, name, IPAddress, SteamID, params )
{
	local lvls = FileToString(Constants.Directories.UserLevels);
	if ( lvls != null )
		return;
	
	if ( player )
	{
		if ( player.IsBot() || !player.IsServerHost() )
			return;
		
		local users = FileToString(Constants.Directories.UserLevels);
		local steamid = player.GetSteamID();
		if ( steamid == "" || steamid == "BOT" )
			return;
		
		local tbl = {}
		users = ::Constants.UserLevelExplain 
			+ steamid + " = " + ::UserLevelNames[PS_USER_HOST] + " // " + player.GetName() + "\r\n";
		
		local foundHost = false

		// Deprecate admins if exists
		local admins = FileToString(Constants.Directories.Admins);
		if(admins != null)
		{
			AdminSystem.LoadAdmins(false);
			local admin_rows = split(admins, "\r\n")
			local rn = admin_rows.len()
			for(local i = 0; i < rn; i++)
			{
				local row = strip(admin_rows[i]);
				local index = row.find("//")
				if(index != null && index > 0)
				{
					local _steamid = strip(row.slice(0, index))
					local _name = strip(row.slice(index + 2))
					if(i == 0 && AdminSystem.HostPlayer.len() == 0)
					{
						printR("[HOST-DECIDER-OnPlayerJoined] New host is "+_steamid)
						tbl[_steamid] <- [PS_USER_HOST,_name];
						::AdminSystem.HostPlayer[_steamid] <- true
						foundHost = true
					}
					else
						tbl[_steamid] <- [PS_USER_ADMIN,_name];
				}
			}
			StringToFile(Constants.Directories.Admins, ::Constants.Deprecate.Admins);
		}
		
		// Deprecate script auths if exists
		local authList = FileToString(Constants.Directories.ScriptAuths);
		if(authList != null)
		{
			AdminSystem.LoadScriptAuths();
			local auth_rows = split(authList, "\r\n")
			foreach(row in auth_rows)
			{
				row = strip(row);
				local index = row.find("//")
				if(index != null && index > 0)
				{
					local _steamid = strip(row.slice(0, index))
					local _name = strip(row.slice(index + 2))
					if(_steamid in ::AdminSystem.HostPlayer)
						continue;
					tbl[_steamid] <- [PS_USER_SCRIPTER,_name];
				}
			}
			StringToFile(Constants.Directories.ScriptAuths, ::Constants.Deprecate.ScriptAuths);
		}
		
		if(!foundHost)
		{
			printR("[HOST-DECIDER-OnPlayerJoined] New host is "+steamid)
			::AdminSystem.HostPlayer[steamid] <- true
		}

		foreach(sid,lis in tbl)
		{
			if(sid != steamid)
				users += sid + " = " + ::UserLevelNames[lis[0]] + " // " + lis[1] + "\r\n";
		}
		
		StringToFile(Constants.Directories.UserLevels, users + "\r\n\r\n\r\n");
		AdminSystem.LoadUserLevels();
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
		if(typeof botparent == "VSLIB_PLAYER" && botparent.HasPrivilege(PS_USER_ADMIN))
			AdminSystem.LetgoCmd(botparent,null);
		bot.Input("clearparent","",0);
		bot.Input("runscriptcode","_dropit(Entity(self))",0.05)
	}
}

/*
 * @authors rhino
 */
function Notifications::OnBotReplacedPlayer::LetGoHeldPlayer(player,bot,args)
{
	//printl("Player #"+player.GetIndex()+" was replaced with Bot #"+bot.GetIndex())
	
	if(player.HasPrivilege(PS_USER_ADMIN))
		AdminSystem.LetgoCmd(player,null);

	local rag = Objects.AnyOfName(Constants.Targetnames.Ragdoll+player.GetIndex())

	if(rag == null || !rag.IsEntityValid())
		return;
	
	RecoverRagdollInitial(rag);
	
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
	if ( AdminSystem.EnableIdleKick && !player.HasPrivilege(PS_USER_ADMIN) )
		Timers.AddTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring(), AdminSystem.IdleKickTime, false, AdminSystem.KickPlayer, player );
}

function Notifications::OnPlayerReplacedBot::AdminStopIdleKickTimer( player, bot, params )
{
	if ( AdminSystem.EnableIdleKick && !player.HasPrivilege(PS_USER_ADMIN) )
		Timers.RemoveTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring() );
}

function EasyLogic::OnTakeDamage::AdminDamage( damageTable )
{
	if (!damageTable.Victim)
		return;
	
	local attacker = Utils.GetEntityOrPlayer(damageTable.Attacker);
	local victim = Utils.GetEntityOrPlayer(damageTable.Victim);
	local ID = AdminSystem.GetID(victim);
	
	local parent = victim.GetParent()
	if(parent != null)
	{	
		
		// Charger missed charge impact
		if(parent.GetName().find(Constants.Targetnames.Ragdoll) != null
			&& (attacker.GetName().find("charger") != null || attacker.GetModel().find("charger")!=null)
			&& victim.GetNetProp("m_staggerDist").tointeger() != 0
			&& damageTable.DamageDone == 2)
		{
			return true;
		}
	}
	
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
			
			Timers.AddTimer(0.4, false, StopTankMusic);
		}
	}
}

function EasyLogic::OnUserCommand::AdminCommands(player, args, text)
{
	player.GetScriptScope().PS_ONETIME_TARGET <- null;

	local Command = GetArgument(0);

	local cleanBaseCmd = null
	local target = null
	if(Command != null)
	{	
		Command = strip(Command);
		if(Command.find(">") != null)
		{
			local tname = strip(Command.slice(Command.find(">") + 1))
			if(tname == "self" || tname == "!self")
				target = Utils.GetEntityOrPlayer(player.GetBaseEntity());
			else if(tname != "" && ((target = Entity(tname)).IsEntityValid() || ((target = Utils.GetPlayerFromName(tname)) != null)))
				Command = Command.slice(0, Command.find(">"))
			else
				target = null
				
			if(target)
				target = Utils.GetEntityOrPlayer(target.GetBaseEntity())
		}
		cleanBaseCmd = Command in ::ChatTriggers
							? Command
							: Command.tolower() in ::ChatTriggers
								? Command.tolower()
								: null
	}

	// Check restrictions
	if (cleanBaseCmd != null)
	{
		if(!player.IsServerHost())	// Only check for non-host players
		{
			if(cleanBaseCmd in ::PrivilegeRequirements)
			{
				if(!player.HasPrivilege(::PrivilegeRequirements[cleanBaseCmd]))
				{
					::Messages.ThrowPlayer(player,TXTCLR.OG(cleanBaseCmd) + " command requires " + ::UserLevelNames[::PrivilegeRequirements[cleanBaseCmd]] + " privilege or above")
					return false;
				}
			}
			if(cleanBaseCmd in ::VSLib.EasyLogic.DisabledCommands)
			{
				Printer(player,"Host has disabled the "+cleanBaseCmd+" command for this session!")
				return false;
			}

			local steamid = player.GetSteamID()
			if(cleanBaseCmd in ::VSLib.EasyLogic.CommandRestrictions)
			{
				local restrictions = ::VSLib.EasyLogic.CommandRestrictions[cleanBaseCmd]

				// Perma ban
				if(("BanList" in restrictions) && (steamid in restrictions.BanList))
				{
					Printer(player,"Host has banned you from using "+cleanBaseCmd+" command!")
					return false;
				}
				
				// Spam limiter
				if(("CoolDown" in restrictions) && (steamid in restrictions.CoolDown))
				{	
					if(!(cleanBaseCmd in ::VSLib.EasyLogic.CommandCallTimes))
					{
						::VSLib.EasyLogic.CommandCallTimes[cleanBaseCmd] <- {}
					}
					else if((steamid in ::VSLib.EasyLogic.CommandCallTimes[cleanBaseCmd]))
					{
						local timeleft = Time() - ::VSLib.EasyLogic.CommandCallTimes[cleanBaseCmd][steamid];
						if(timeleft < restrictions.CoolDown[steamid])
						{
							Printer(player,"You can't use this command for "+timeleft+" more seconds!")
							return false;
						}
					}
				}
				else if(("CoolDownAll" in restrictions))
				{
					local timeleft = Time() - ::VSLib.EasyLogic.CommandCallTimes[cleanBaseCmd][steamid];
					if(timeleft < restrictions.CoolDownAll)
					{
						Printer(player,"You can't use this command for "+timeleft+" more seconds!")
						return false;
					}
				}
				// Save call time
				::VSLib.EasyLogic.CommandCallTimes[cleanBaseCmd][steamid] <- Time()
			}
			// Temp ban
			if((cleanBaseCmd in ::VSLib.EasyLogic.TemporaryCmdBanList) && (steamid in ::VSLib.EasyLogic.TemporaryCmdBanList[cleanBaseCmd]))
			{
				local banleft = Time() - ::VSLib.EasyLogic.TemporaryCmdBanList[cleanBaseCmd][steamid]
				if(banleft < 0)
				{
					Printer(player,"Host has temporarly banned you from using "+cleanBaseCmd+" command for "+(-banleft)+" more seconds!")
					return false;
				}
				delete ::VSLib.EasyLogic.TemporaryCmdBanList[cleanBaseCmd][steamid]
			}
		}	
	}
	else
	{
		if(Command == null)
			return false;
			
		::SpellChecker.Levenshtein().PrintBestMatches(player.GetBaseEntity(),Command,::ChatTriggers)
		return false;
	}

	if(target)
		player.GetScriptScope().PS_ONETIME_TARGET <- Utils.GetEntityOrPlayer(target);

	switch ( cleanBaseCmd )
	{
		case "command_privilege":
		{
			AdminSystem.ChangeCmdPrivileges(player,args);
			break;
		}
		case "reload_command_privileges":
		{
			AdminSystem.LoadCmdPrivileges();
			break;
		}
		case "reload_vehicles":
		{
			AdminSystem.LoadVehicles(true);
			break;
		}
		case "bind":
		{
			AdminSystem.BindWithQuixCmd(player,args);
			break;
		}
		case "unbind":
		{
			AdminSystem.UnbindWithQuixCmd(player,args);
			break;
		}
		case "reload_binds":
		{
			AdminSystem.LoadQuixBinds(true);
			break;
		}
		case "reload_scripts":
		{
			AdminSystem.LoadCustomScripts();
			break;
		}
		case "reload_hooks":
		{
			AdminSystem.LoadCustomHooks();
			break;
		}
		case "detach_hook":
		{
			AdminSystem.DetachHook(player,args);
			break;
		}
		case "attach_hook":
		{
			AdminSystem.AttachHook(player,args);
			break;
		}
		case "reload_loots":
		{
			AdminSystem.LoadLootTables();
			break;
		}
		case "reload_ent_groups":
		{
			AdminSystem.LoadEntityGroups(true);
			break;
		}
		case "reload_aliases":
		{
			AdminSystem.LoadAliasedCommands(true);
			break;
		}
		case "replace_alias":
		{
			AdminSystem.ReplaceAliasCommandCmd(player,args,text);
		}
		case "create_alias":
		{
			AdminSystem.CreateAliasCommandCmd(player,args,text);
			break;
		}
		case "hex_string":
		{
			local Code = strip(Utils.StringReplace(text, "hex_string,", ""));
			Printer(player,::AdminSystem._GetHexString(Code));
			break;
		}
		case "enum_string":
		{
			local Code = strip(Utils.StringReplace(text, "enum_string,", ""));
			Printer(player,::AdminSystem._GetEnumString(Code));
			break;
		}
		case "out":
		{
			local Code = Utils.StringReplace(text, "out,", "");
			Code = Utils.StringReplace(Code, "'", "\""); //"
			local res = compilestring("local __tempvar__="+Code+";return __tempvar__;")();
			::AdminSystem.out(res,player);
			break;
		}
		case "user_level":
		{
			AdminSystem.ChangeUserLevelCmd( player, args );
			break;
		}
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
		case "pitch":
		{
			AdminSystem.PitchShiftCmd( player, args );
			break;
		}
		case "perma_pitch":
		{
			AdminSystem.PermaPitchShiftCmd( player, args );
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
		case "save_model":
		{
			AdminSystem.Save_modelCmd(player, args);
			break;
		}
		case "random_model_save_state":
		{
			AdminSystem.Randommodel_save_lastCmd(player, args);
			break;
		}
		case "display_saved_model":
		{
			AdminSystem.Display_saved_modelCmd(player, args);
			break;
		}
		case "spawn_model_saved":
		{
			AdminSystem.Spawn_saved_modelCmd(player, args);
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
		case "prop_spawn_setting":
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
		case "help":
		{
			AdminSystem.HelpCmd(player, args);
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
		case "zero_g":
		{
			AdminSystem.ZeroGCmd(player, args);
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
		case "soda_can":
		{
			AdminSystem.SodaCanCmd( player, args );
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
		case "random_decal":
		{
			AdminSystem.RandomDecalCmd( player, args );
			break;
		}
		case "search_decal":
		{
			AdminSystem.SearchDecalCmd( player, args );
			break;
		}
		case "decal":
		{
			AdminSystem.DecalCmd( player, args );
			break;
		}
		case "remove_lights":
		{
			AdminSystem.RemoveLightsCmd( player, args );
			break;
		}
		case "spawn_point_light":
		{
			AdminSystem.SpawnPointLightCmd( player, args );
			break;
		}
		case "point_light":
		{
			AdminSystem.PointLightCmd( player, args );
			break;
		}
		case "point_light_follow":
		{
			AdminSystem.PointLightFollowCmd( player, args );
			break;
		}
		case "particle":
		{
			AdminSystem.ParticleCmd( player, args );
			break;
		}
		case "random_particle":
		{
			AdminSystem.RandomParticleCmd( player, args );
			break;
		}
		case "search_particle":
		{
			AdminSystem.SearchParticleCmd( player, args );
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
		case "set_animation":
		{
			AdminSystem.SetAnimationCmd( player, args );
			break;
		}
		case "search_animation":
		{
			AdminSystem.SearchAnimationCmd( player, args );
			break;
		}
		case "random_animation":
		{
			AdminSystem.RandomAnimationCmd( player, args );
			break;
		}
		case "random_phys_model":
		{
			AdminSystem.RandomPhysModelCmd( player, args );
			break;
		}
		case "random_model":
		{
			AdminSystem.RandomModelCmd( player, args );
			break;
		}
		case "search_model":
		{
			AdminSystem.SearchModelCmd( player, args );
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
		case "remove_fall_cams":
		{
			AdminSystem.RemoveFallCamsCmd( player, args );
			break;
		}
		case "hurt_triggers":
		{
			AdminSystem.HurtTriggersCmd( player, args );
			break;
		}
		case "find_sound_in_scripts":
		{
			AdminSystem.FindSoundInScriptsCmd( player, args );
			break;
		}
		case "search_sound_script_name":
		{
			AdminSystem.SearchSoundCmd( player, args );
			break;
		}
		case "random_sound_script_name":
		{
			AdminSystem.RandomSoundCmd( player, args );
			break;
		}
		case "sound_script_info":
		{
			AdminSystem.SoundInfoCmd( player, args );
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
			local Target = Utils.GetPlayerFromName(GetArgument(1));
			if(::AdminSystem.Vars.CompileHexAndSpecialsInArguments)
			{	
				local Text = ""
				switch(args.len())
				{
					case 1:
						Text = args[0]
						break;
					case 2:
						Text = args[1]
						break;
				}
				
				if ( Entity == "all" )
				{
					foreach(player in Players.All())
					{
						player.Say(Text);
					}
				}
				else
				{
					if ( !Target )
					{
						Say(null, Text, false);
						break;
					}
					Target.Say(Text);
				}
			}
			else
			{
				local Text = text;
				
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
						break;
					}
					
					Text = Utils.StringReplace(Text, "say," + Entity + ",", "");
					Text = Utils.StringReplace(Text, ",", " ");
					Target.Say(Text);
				}
			}
			break;
		}
		case "password":
		{
			if ( AdminSystem.AdminPassword == "" )
				break;
			
			local Password = GetArgument(1);
			
			if ( Password == AdminSystem.AdminPassword )
			{
				local levels = FileToString(Constants.Directories.UserLevels);
				local steamid = player.GetSteamID();
				if ( steamid == "BOT" )
					break;
				if ( (steamid in ::AdminSystem.UserLevels) )
					break;
				if ( levels == null )
					levels = ::Constants.UserLevelExplain + steamid + " = PS_USER_HOST //" + player.GetName();
				else
				{
					levels = ChangeUserLevel(player, steamid, levels)
					if(!levels)	break
				}
				StringToFile(Constants.Directories.UserLevels, levels);
				AdminSystem.LoadUserLevels();
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
		case "show_looting_settings":
		{
			AdminSystem.Show_loot_settingsCmd(player,args);
			break;
		}
		case "looting_setting":
		{
			AdminSystem.Loot_settingCmd(player,args);
			break;
		}
		case "create_loot_sources":
		{
			AdminSystem.CreateLootSourcesCmd(player,args);
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
		case "start_ghost_zombies":
		{
			AdminSystem.StartGhostZombiesCmd(player,args);
			break;
		}
		case "pause_ghost_zombies":
		{
			AdminSystem.PauseGhostZombiesCmd(player,args);
			break;
		}
		case "ghost_zombies_setting":
		{
			AdminSystem.GhostZombiesSettingCmd(player,args);
			break;
		}
		case "show_ghost_zombies_settings":
		{
			AdminSystem.ShowGhostZombiesSettingsCmd(player,args);
			break;
		}
		case "rc_prop":
		{
			AdminSystem.RemoteControlCmd(player,args);
			break;
		}
		case "drive":
			AdminSystem.out(TXTCLR.OG("drive")+" command has been "+TXTCLR.OG("deprecated")+"! Use "+TXTCLR.BG("start_driving")+" and "+TXTCLR.BG("stop_driving")+" instead",player)
		case "start_driving":
		{
			AdminSystem.StartDriveCmd(player,args);
			break;
		}
		case "stop_driving":
		{
			AdminSystem.StopDriveCmd(player,args);
			break;
		}
		case "get_in":
		{
			AdminSystem.GetInAsPassenger(player,args);
			break;
		}
		case "get_out":
		{
			AdminSystem.GetOutAsPassenger(player,args);
			break;
		}
		case "change_passenger_seat_position":
		{
			AdminSystem.ChangePassengerSeatPositionCmd(player,args);
			break;
		}
		case "make_driveable":
		{
			AdminSystem.MakeDriveableCmd(player,args);
			break;
		}
		case "change_drive_direction":
		{
			AdminSystem.ChangeDriveDirectionCmd(player,args);
			break;
		}
		case "change_seat_position":
		{
			AdminSystem.ChangeSeatPositionCmd(player,args);
			break;
		}
		case "set_default_seat_position":
		{
			AdminSystem.SetDefaultSeatPositionCmd(player,args);
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
		case "wiki":
		{
			AdminSystem.WikiCmd(player,args);
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
		case "flag_lookup":
		{
			AdminSystem.FlagLookUpCmd(player,args);
			break;
		}
		case "change_ragdoll_view":
		{
			AdminSystem.ChangeRagdollViewPositionCmd(player,args);
			break;
		}
		case "go_ragdoll":
		{
			AdminSystem.GoRagdollCmd(player,args);
			break;
		}
		case "recover_ragdoll":
		{
			AdminSystem.RecoverRagdollCmd(player,args);
			break;
		}
		case "give_physics":
		{
			AdminSystem.GivePhysicsCmd(player,args);
			break;
		}
		case "command_ban":
		{
			AdminSystem.AddCommandBanCmd(player,args);
			break;
		}
		case "command_unban":
		{
			AdminSystem.RemoveCommandBanCmd(player,args);
			break;
		}
		case "disable_command":
		{
			AdminSystem.AddDisabledCommandCmd(player,args);
			break;
		}
		case "enable_command":
		{
			AdminSystem.RemoveDisabledCommandCmd(player,args);
			break;
		}
		case "switch_hud_element":
		{
			AdminSystem.SwitchHudElement(player,args);
			break;
		}
		case "selfie":
		{
			AdminSystem.SelfieViewCmd(player,args);
			break;
		}
		case "create_camera":
		{
			AdminSystem.CreateCameraCmd(player,args);
			break;
		}
		case "camera_setting":
		{
			AdminSystem.CameraSettingCmd(player,args);
			break;
		}
		case "change_camera":
		{
			AdminSystem.ChangeCameraCmd(player,args);
			break;
		}
		case "last_camera_info":
		{
			AdminSystem.LastCameraInfoCmd(player,args);
			break;
		}
		default:
		{
			if(cleanBaseCmd in ::ChatTriggers)
			{
				::ChatTriggers[cleanBaseCmd](player,args,text);
				break;
			}
			else
			{
				::SpellChecker.PrintBestMatches(player.GetBaseEntity(),Command,::ChatTriggers)
				break;
			}
		}
	}

}

::ChangeUserLevel <- function(player, steamid, levels, lvlname = "PS_USER_ADMIN")
{
	local start;
	if((start = levels.find(steamid)) != -1)
	{
		local first_part = rstrip(levels.slice(0, start))
		local second_part = levels.slice(start)

		local secondpartlines = split(second_part,"\r\n")
		local matching = secondpartlines[0]
		local re = regexp(steamid+@"[\t ]*=[\t ]*(PS_USER_(NONE|BASIC|ADMIN|SCRIPTER|HOST))[\t ]*(//.*)?")
		if(re.match(matching))
		{
			secondpartlines[0] = "\r\n" + steamid + " = "+lvlname+" // " + player.GetName() 
			foreach(lineidx, line in secondpartlines)
			{
				first_part += line + "\r\n"
			}
			levels = first_part + "\r\n\r\n"
		}
		else
		{
			::Messages.ThrowPlayer(player,"Something is wrong with the user_level.txt, let the host know!")
			return;
		}
	}
	else
	{
		levels = rstrip(levels)
		levels += "\r\n" + steamid + " = PS_USER_ADMIN //" + player.GetName() + "\r\n\r\n\r\n";
	}
	return levels
}

/*
 * @authors rhino
 */
::AdminSystem.SwitchHudElement <- function(player,args)
{
	local element = GetArgument(1)
	switch(element)
	{
		case "all":
		{
			player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") ^ (HIDEHUD_WEAPONSELECTION|(1<<6)|HIDEHUD_CHAT|HIDEHUD_CROSSHAIR))
			break;
		}
		case "weapon_selection":
		{
			player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") ^ HIDEHUD_WEAPONSELECTION)
			break;
		}
		case "menu":
		case "healthbars":
		case "healthbar":
		case "health":
		{
			player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") ^ (1<<6))
			if((player.GetNetProp("m_Local.m_iHideHUD") >> 6) % 2 == 0)
				Messages.InformPlayerConsole(player,">>>>>> MENU IS CURRENTLY HIDDEN, TO RESTORE: !switch_hud_element menu  <<<<<<")
			break;
		}
		case "chat":
		{
			player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") ^ HIDEHUD_CHAT)
			break;
		}
		case "crosshair":
		{
			player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") ^ HIDEHUD_CROSSHAIR)
			break;
		}
	}
}

// Utility functions
/*
 * @authors rhino
 */
::PS_UTILS <- {}

::PS_UTILS.map <- function(func, arr)
{
	local n = arr.len()
	local a = array(n)
	for(local i = 0; i < n; i++)
	{
		a[i] = func(arr[i])
	}
	return a
}

::PS_UTILS.filter <- function(func, arr)
{
	local n = arr.len()
	local a = array(0)
	for(local i = 0; i < n; i++)
	{
		if(func(arr[i]))
			a.append(arr[i])
	}
	return a
}

::PS_UTILS.first <- function(func, arr)
{
	local n = arr.len()
	for(local i = 0; i < n; i++)
	{
		if(func(arr[i]))
			return arr[i]
	}
	return null
}

::PS_UTILS.any <- function(func, arr)
{
	local n = arr.len()
	for(local i = 0; i < n; i++)
	{
		if(func(arr[i]))
			return true
	}
	return false
}

::PS_UTILS.all <- function(func, arr)
{
	local n = arr.len()
	for(local i = 0; i < n; i++)
	{
		if(!func(arr[i]))
			return false
	}
	return n > 0
}

/*
 * @authors rhino
 */
::AdminSystem.SelfieViewCmd <- function(player,args)
{
	function CreateSelfieCameraFromPair(player, pair)
	{
		local keyvals =
		{
			classname = "point_viewcontrol"
			origin = player.GetOrigin()
			angles = pair[2]
			spawnflags = 8 + 16
		}
		local cam = Utils.CreateEntityWithTable(keyvals);
		local tindex = cam.GetIndex();
		cam.SetName("PS_VIEWCONTROL_SELFIE>" + pair[0]);
		cam.GetScriptScope()["PS_CAMERA_ATTACH_POS"] <- pair[1];
		cam.GetScriptScope()["PS_CAMERA_ATTACH_ANG"] <- pair[2];
		cam.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"] <- true;

		function AttachChecker(c,a)
		{
			if(a.parent == null || !a.parent.IsEntityValid() || !a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"])
			{
				::Quix.Remove("PS_CAMERA_"+tindex+"_ATTACHER_1")
				a.camera.GetScriptScope()["PS_CAMERA_ATTACH_POS"] = null
				a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ANG"] = null
				a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"] = false
				a.parent = null
				return false
			}
			else
			{
				return true
			}
		}
		function Attacher(c,s,a)
		{
			a.camera.SetOrigin(a.parent.GetOrigin() + GetPositionRelativeToPlayer(player,a.camera.GetScriptScope()["PS_CAMERA_ATTACH_POS"]));
			a.camera.SetAngles(RotateOrientation(player.GetEyeAngles(),QAngle(180,0,180)) - a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ANG"])
		}

		::Printer(player,"Created selfie camera #"+tindex);

		::Quix.AddUnlimited("PS_SELFIECAM_"+tindex+"_ATTACHER_1",
							AttachChecker,
							Attacher,
							{camera=cam,parent=player},
							{camera=cam,parent=player});
							
		return cam
	}

	function ChangeIntoCameraTemp(player, camera, i, interval, keep = false)
	{
		DoEntFire("!self","enable","", i*interval, player.GetBaseEntity(), camera.GetBaseEntity())
		DoEntFire("!self","runscriptcode","self.GetScriptScope().PS_CURRENT_SELFIE_CAM <- Entity("+camera.GetIndex()+")", i*interval, null, player.GetBaseEntity())
		if(!keep)
			DoEntFire("!self","disable","", (i+1)*interval, player.GetBaseEntity(), camera.GetBaseEntity())
	}

	local selfiepairs =
	[
		[0,  Vector(70,20,50),  QAngle(10,20,0)],
		[1,  Vector(50,-25,60), QAngle(-10,20,0)],
		[2,  Vector(40,5,60),   QAngle(-5,20,0)]
	]
	
	local count = GetArgument(1)
	local intervals = GetArgument(2)

	if("PS_CURRENT_SELFIE_CAM" in player.GetScriptScope() 
		&& player.GetScriptScope()["PS_CURRENT_SELFIE_CAM"] != null
		&& player.GetScriptScope()["PS_CURRENT_SELFIE_CAM"].IsEntityValid())
	{
		DoEntFire("!self","disable","", 0, player.GetBaseEntity(), player.GetScriptScope()["PS_CURRENT_SELFIE_CAM"].GetBaseEntity())
		player.GetScriptScope()["PS_CURRENT_SELFIE_CAM"] = null
		
	}
    if(count == "reset")
        return
	player.GetScriptScope()["PS_CURRENT_SELFIE_CAM"] <- null

	local had_cam = "PS_SELFIE_VIEWS" in player.GetScriptScope();
	if(had_cam)
		player.GetScriptScope()["PS_SELFIE_VIEWS"] = PS_UTILS.filter(@(ent) ent != null && ent.IsEntityValid(), player.GetScriptScope()["PS_SELFIE_VIEWS"])
		
	local has_cam = had_cam && player.GetScriptScope()["PS_SELFIE_VIEWS"].len() > 0
	
	if(!count)
		count = 1
	else
		count = (count = count.tointeger()) > 0 ? (count < 4 ? count : selfiepairs.len()) : 1

	if(!intervals)
		intervals = 1
	else
		intervals = intervals.tofloat()

	if(!has_cam)
	{
		player.GetScriptScope()["PS_SELFIE_VIEWS"] <- []
		local pairs = Utils.GetNRandValueFromArray(selfiepairs, count)

		foreach(pair in pairs)
		{
			player.GetScriptScope()["PS_SELFIE_VIEWS"].append(CreateSelfieCameraFromPair(player, pair))
		}
	}
	else if(count > player.GetScriptScope()["PS_SELFIE_VIEWS"].len())
	{
		local total = selfiepairs.len()
		local cams = PS_UTILS.map(@(ent) split(ent.GetName(),">")[1].tointeger(), player.GetScriptScope()["PS_SELFIE_VIEWS"])

		for(local i = 0; i < total; i++)
		{
			if(Utils.GetIDFromArray(cams, i) == -1)
			{
				player.GetScriptScope()["PS_SELFIE_VIEWS"].append(CreateSelfieCameraFromPair(player, selfiepairs[i]))
			}
		}
	}
	
	local camarr = Utils.GetNRandValueFromArray(player.GetScriptScope()["PS_SELFIE_VIEWS"], count)
	if(intervals < 0)
	{
		for(local i = 0; i < count; i++)
		{
			ChangeIntoCameraTemp(player, camarr[i], i, -intervals, i == count - 1)
		}
	}
	else
	{
		for(local i = 0; i < count; i++)
		{
			ChangeIntoCameraTemp(player, camarr[i], i, intervals)
		}
		DoEntFire("!self","runscriptcode","self.GetScriptScope().PS_CURRENT_SELFIE_CAM <- Entity("+camarr[count - 1].GetIndex()+")", count*intervals, null, player.GetBaseEntity())
	}
}
::LastCreatedCameras <- ::AdminSystem.Vars.RepeatValueForSurvivors(-1);

/*
 * @authors rhino
 */
::AdminSystem.CreateCameraCmd <- function(player,args)
{
	
    local angletarget = null
	local keyvals =
	{
		classname = "point_viewcontrol"
		origin = player.GetLookingLocation()
		spawnflags = 24
	}

	local angles = GetArgument(1);
	if(!angles)
		keyvals.angles <- player.GetEyeAngles();
	else if(angles == "!self")
		keyvals.angles <- RotateOrientation(player.GetEyeAngles(),QAngle(180,0,0)) - QAngle(0,0,-180);
	else
		keyvals.angles <- CastCustomSetting(player,["angles","ang|"+angles])

	local followercam = false;
	local follow = GetArgument(2);
	if(follow)
	{
		if(follow == "!self")
			follow = "#" + player.GetIndex()
		else if(follow == "!picker" && player.GetLookingEntity(GRAB_YEET_TRACE_MASK) != null)
            follow = "#" + player.GetLookingEntity(GRAB_YEET_TRACE_MASK).GetIndex()
		keyvals.target <- follow
		followercam = true;
	}

	local cam = Utils.CreateEntityWithTable(keyvals);
	cam.SetName("PS_VIEWCONTROL")
	cam.GetScriptScope()["PS_CAM_FOLLOWS"] <- followercam

	::Messages.InformPlayer(player,CmdMessages.Prop.Success("camera",cam));
	::LastCreatedCameras[player.GetCharacterNameLower()] <- cam.GetIndex()
}

/*
 * @authors rhino
 */
::AdminSystem.LastCameraInfoCmd <- function(player,args)
{
	local camera = null
	if(::LastCreatedCameras[player.GetCharacterNameLower()] == -1)
		::Messages.ThrowPlayer(player,"No cameras found created by you.")
	else if((camera = Entity(::LastCreatedCameras[player.GetCharacterNameLower()])) && camera.IsEntityValid())
		::Messages.InformPlayer(player,TXTCLR.BG("ID: ") + TXTCLR.OG("#" + camera.GetIndex()) + "\n" + TXTCLR.BG("Distance: ") + TXTCLR.OG((player.GetOrigin() - camera.GetOrigin()).Length()));
	else if(::LastCreatedCameras[player.GetCharacterNameLower()] = -1)
		::Messages.WarnPlayer(player,"Last camera created was removed.");
}

/*
 * @authors rhino
 */
::AdminSystem.ChangeCameraCmd <- function(player,args)
{
	local target = GetArgument(1);
	local hascam = "PS_CUSTOM_POINT_VIEWCONTROL" in player.GetScriptScope()	&& player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"] != null;
	if(!target)
	{
		if(hascam)
		{
			DoEntFire("!self","disable","",0,player.GetBaseEntity(), player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"].GetBaseEntity());
			player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"].GetScriptScope()["PS_CURRENT_VIEWER"] <- null
		}
		return;
	}

	if(target == "!last")
	{
		target = ::LastCreatedCameras[player.GetCharacterNameLower()]
	}

	target = Entity(target)
	if(!target || !target.IsEntityValid() || target.GetClassname() != "point_viewcontrol")
		return

	if("PS_CURRENT_VIEWER" in target.GetScriptScope() && target.GetScriptScope()["PS_CURRENT_VIEWER"] != null)
	{
		Messages.ThrowPlayer(player,"This camera is being viewed by '"+player.GetName()+"'. Multiple viewers for a single camera is not currently supported!");
		return;
	}

	if(hascam)
	{
		DoEntFire("!self","disable","",0,player.GetBaseEntity(), player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"].GetBaseEntity());
		player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"].GetScriptScope()["PS_CURRENT_VIEWER"] <- null
	}

	player.GetScriptScope()["PS_CUSTOM_POINT_VIEWCONTROL"] <- target;
	target.GetScriptScope()["PS_CURRENT_VIEWER"] <- player
	DoEntFire("!self","enable","",0.1,player.GetBaseEntity(), target.GetBaseEntity());
}

/*
 * @authors rhino
 */
::AdminSystem.CameraSettingCmd <- function(player,args)
{
	local target = GetArgument(1);
	if(target == "!last")
		target = ::LastCreatedCameras[player.GetCharacterNameLower()]
		
	target = Entity(target)
	if(!target || !target.IsEntityValid() || target.GetClassname() != "point_viewcontrol")
		return

	local setting = GetArgument(2);
	local value = GetArgument(3);
	local value2 = GetArgument(4);
	value2 = value2 == null ? "" : value2;

	switch(setting)
	{
		case "angles":
		case "angle":
		{
			if(value == "!self")
				value = (player.GetEyeAngles() + QAngle(0, 180, 0));
			else
				value = CastCustomSetting(player,["angles","ang|"+value])
			
			if(target.GetParent() != null)
				target.SetLocalAngles(value);
			else
				target.SetAngles(value);
			break;
		}
		case "+angles":
		case "+angle":
		{
			value = CastCustomSetting(player,["angles","ang|"+value])
			
			if(target.GetParent() != null)
				target.SetLocalAngles(target.GetLocalAngles() + value);
			else
				target.SetAngles(target.GetAngles() + value);
			break;
		}
		case "origin":
		{
			if(value == "!self")
				value = player.GetOrigin();
			else
				value = CastCustomSetting(player,["vector","pos|"+value])

			if("PS_CAMERA_ATTACH_POS" in target.GetScriptScope() 
				&& target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] != null)
				{
					target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] = value
				}
			
			if(target.GetParent() != null)
				target.SetLocalOrigin(value);
			else
				target.SetOrigin(value);
			break;
		}
		case "+origin":
		{
			value = CastCustomSetting(player,["vector","pos|"+value])
			if("PS_CAMERA_ATTACH_POS" in target.GetScriptScope() 
				&& target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] != null)
				{
					target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] += value
				}
				
			if(target.GetParent() != null)
				target.SetLocalOrigin(target.GetLocalOrigin() + value);
			else
				target.SetOrigin(target.GetOrigin() + value);
			break;
		}
		case "rorigin":
		{
			value = CastCustomSetting(player,["vector","pos|"+value])
			if("PS_CAMERA_ATTACH_POS" in target.GetScriptScope() 
				&& target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] != null)
				{
					target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] += value
				}
				
			if(target.GetParent() != null)
				target.SetLocalOrigin(target.GetLocalOrigin() + value);
			else
				target.SetOrigin(target.GetOrigin() + GetPositionRelativeToPlayer(player,value))
			break;
		}
		case "detach":
		{
			if(target.GetParent())
			{
				DoEntFire("!self","clearparent","",0,null,target.GetBaseEntity());
				DoEntFire("!self","runscriptcode","self.SetVelocity(Vector(0,0,0))",0.05,null,target.GetBaseEntity());
			}
			
			if(target.GetScriptScope()["PS_CAM_FOLLOWS"])
			{
				::Quix.Remove("PS_CAMERA_"+target.GetIndex()+"_ATTACHER")
				target.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"] = false
			}
			target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] <- null
			break;
		}
		case "attach":
		{
			local parent;
			if(value == "!self")
				parent = player
			else if(value == "!picker")
				parent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
			else
				parent = Entity(value);

			if(!parent || !parent.IsEntityValid())
				return
			
			if(target.GetScriptScope()["PS_CAM_FOLLOWS"])
			{	
				if("PS_CAMERA_ATTACH_POS" in target.GetScriptScope() 
					&& target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] != null)
					{
						Messages.ThrowPlayer(player,"Camera(#"+target.GetIndex()+") is already attached(to #"+target.GetScriptScope()["PS_CAMERA_ATTACH"].GetIndex()+")")
						return
					}
				
				local posvec = target.GetOrigin() - parent.GetOrigin()
				target.GetScriptScope()["PS_CAMERA_ATTACH"] <- parent
				target.GetScriptScope()["PS_CAMERA_ATTACH_POS"] <- posvec
                target.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"] <- true
				local tindex = target.GetIndex()

				if(target.GetNetProp("m_hTarget") != null && Entity(target.GetNetProp("m_hTarget")).GetEntityHandle() == parent.GetEntityHandle())
				{
					if(value2 == "")
						value2 = "forward"

					target.SetNetProp("m_pParent",parent.GetBaseEntity())
					DoEntFire("!self", "setparentattachmentmaintainoffset", value2, 0, null, target.GetBaseEntity());
					break;
				}

				function AttachChecker(c,a)
				{
					if(a.parent == null || !a.parent.IsEntityValid() || !a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"])
					{
						::Quix.Remove("PS_CAMERA_"+tindex+"_ATTACHER")
						a.camera.GetScriptScope()["PS_CAMERA_ATTACH_POS"] = null
                        a.camera.GetScriptScope()["PS_CAMERA_ATTACH_ENABLED"] = false
						a.parent = null
						return false
					}
					else
					{
						return true
					}
				}
				function Attacher(c,s,a)
				{
					a.camera.SetOrigin(a.parent.GetOrigin() + a.camera.GetScriptScope()["PS_CAMERA_ATTACH_POS"]);
				}

				::Quix.AddUnlimited("PS_CAMERA_"+tindex+"_ATTACHER",
									AttachChecker,
									Attacher,
									{camera=target,parent=parent},
									{camera=target,parent=parent});
			}
			else
			{
				if(target.GetParent() != null)
				{
					Messages.ThrowPlayer(player,"Camera(#"+target.GetIndex()+") is already attached(to #"+target.GetParent().GetIndex()+")")
					return
				}
				if(value2 == "")
					DoEntFire("!self","setparent","#"+parent.GetIndex(),0,null,target.GetBaseEntity());
				else
				{
					target.SetNetProp("m_pParent",parent.GetBaseEntity())
					DoEntFire("!self", "setparentattachmentmaintainoffset", value2, 0, null, target.GetBaseEntity());
				}
			}
			break;
		}
	}
}

// Configurations
// !create_camera !self !self
//		!camera_setting #camera attach #player
//		!camera_setting #camera angles 0|0|0
//	 	!camera_setting #camera origin -70|-10|20
/*
 * @authors rhino
 * For debugging in-game
 */
::AdminSystem.out <- function(msg="",target=null,color="\x04")
{
	function printgivenlines(msg,target,color)
	{
		local splt = split(msg,"\n");
		local lines = ::Messages.MessageSplit(splt)
		if(target != null)
		{
			foreach(i,line in lines)
			{
				PrinterSplitDecider(target,color+line,"info");
			}
		}
		else
		{
			foreach(i,line in lines)
			{
				ClientPrint(null,3,color+line);
			}
		}
	}

	if(msg == null)
	{
		if(target != null && (typeof target == "VSLIB_ENTITY" || typeof target == "VSLIB_PLAYER"))
			target = target.GetBaseEntity()

		ClientPrint(target,3,color+"null");
		return;
	}

	local msgtype = typeof msg;
	switch(msgtype)
	{
		case "array":
		case "table":
			msg = Utils.GetTableString(msg,"","",true);
			break;
		case "QAngle":
		case "Vector":
			msg = msg.ToKVString();
			break;
		case "string":
		case "float":
		case "integer":
		case "bool":
			msg = msg.tostring();
			break;
		default:
		{
			if(msgtype == "instance" || msgtype.find("VSLIB") != null)
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
					return;
				}
				catch(e)
				{
					msg = msg.tostring();
				}
			}
			else if(msgtype.tostring().find("project_smok_Message_") != null)
				msg = msg.GetColored();
			else
				msg = msg.tostring();
			break;
		}
	}
	printgivenlines(msg,target,color)
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
	local targetclasses = ["all","special","common","physics",null];
	local target = GetArgument(1);

	if(Utils.GetIDFromArray(targetclasses,target) == -1)
	{
		::SpellChecker.Levenshtein(2,3,"argument value").PrintBestMatches(player.GetBaseEntity(),target,Utils.ArrayToTable(["all","special","common","physics"]))
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
			local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
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
// TO-DO: Ragdolls dont stop 
::FreezePhysics <- function()
{
	if(!("_FrozenPhysics" in AdminSystem))
	{
		AdminSystem._FrozenPhysics <- {}
	}

	local classnames = 
	[
		"prop_physics",
		"prop_physics_multiplayer",
		"prop_car_alarm",
		"prop_vehicle",
		"prop_physics_override",
		"func_physbox",
		"func_physbox_multiplayer",
		"prop_ragdoll",
		"tank_rock"
	]
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
				if(cls == "prop_ragdoll")
				{
					obj.AddFlag(16384+65536)
				}
				else
				{
					obj.AddFlag(FL_FROZEN);
				}
				obj.SetNetProp("m_flFrozen",1.0);
				obj.SetNetProp("m_bSimulatedEveryTick",0);
				obj.SetNetProp("m_bAnimatedEveryTick",0);
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
	local classnames = 
	[
		"prop_physics",
		"prop_physics_multiplayer",
		"prop_car_alarm",
		"prop_vehicle",
		"prop_physics_override",
		"func_physbox",
		"func_physbox_multiplayer",
		"prop_ragdoll",
		"tank_rock"
	]

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
		if(classname == "prop_ragdoll")
		{
			ent.AddFlag(16384+65536)
		}
		else
		{
			ent.AddFlag(FL_FROZEN);
		}
		ent.SetNetProp("m_flFrozen",1.0);
		ent.SetNetProp("m_bSimulatedEveryTick",0);
		ent.SetNetProp("m_bAnimatedEveryTick",0);
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.ResumeTimeCmd <- function(player,args)
{
	local targetclasses = ["all","special","common","physics",null];
	local target = GetArgument(1);

	if(Utils.GetIDFromArray(targetclasses,target) == -1)
	{
		::SpellChecker.Levenshtein(2,3,"argument value").PrintBestMatches(player.GetBaseEntity(),target,Utils.ArrayToTable(["all","special","common","physics"]))
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
			local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
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

	local classnames = 
	[
		"prop_physics",
		"prop_physics_multiplayer",
		"prop_car_alarm",
		"prop_vehicle",
		"prop_physics_override",
		"func_physbox",
		"func_physbox_multiplayer",
		"prop_ragdoll",
		"tank_rock"
	]
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
				
				if(cls == "prop_ragdoll")
				{
					obj.RemoveFlag(16384+65536)
				}
				else
				{
					obj.RemoveFlag(FL_FROZEN);
				}
				obj.SetNetProp("m_flFrozen",0);
				obj.SetNetProp("m_bSimulatedEveryTick",1);
				obj.SetNetProp("m_bAnimatedEveryTick",1);
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
	local classnames = 
	[
		"prop_physics",
		"prop_physics_multiplayer",
		"prop_car_alarm",
		"prop_vehicle",
		"prop_physics_override",
		"func_physbox",
		"func_physbox_multiplayer",
		"prop_ragdoll",
		"tank_rock"
	]

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
		if(classname == "prop_ragdoll")
		{
			ent.RemoveFlag(16384+65536)
		}
		else
		{
			ent.RemoveFlag(FL_FROZEN);
		}
		ent.SetNetProp("m_flFrozen",0);
		ent.SetNetProp("m_bSimulatedEveryTick",1);
		ent.SetNetProp("m_bAnimatedEveryTick",1);
		ent.SetMoveType(tbl.movetype);
		ent.SetOrigin(org);
		ent.Push(tbl.velocity);
		delete AdminSystem._FrozenPhysics[id];
	}
	
}

/*
 * @authors rhino
 */
::GivePhysicsToEntity <- function(ent)
{
	local entclass = ent.GetClassname()
	if(entclass.find("physics") != null || entclass in ::_LetGoDropYeetSpecialClasses) // physics entity
	{
		if( entclass == "prop_physics_multiplayer" || entclass == "prop_physics" || entclass in ::_LetGoDropYeetSpecialClasses)
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
		return ent
	}
	else // non physics, try creating entity with its model
	{
		local new_ent = null;
		local keyvals = 
		{
			classname = RagdollOrPhysicsDecider(ent.GetModel()),
			model = ent.GetModel(),
			origin = ent.GetOrigin(),
			angles = ent.GetAngles(),
		};
		local skin = ent.GetNetProp("m_nSkin");
		local color = ent.GetNetProp("m_clrRender");
		local scale = ent.GetModelScale();

		new_ent = Utils.CreateEntityWithTable(keyvals);

		if(new_ent != null)
		{
			if(keyvals.classname == "prop_ragdoll")
				new_ent.SetNetProp("m_CollisionGroup",1)
			RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
			return new_ent
		}
		else
		{
			local cuniq = UniqueString();

			local oldind = ent.GetIndex()

			local oldname = ent.GetName()
			ent.SetName(ent.GetName()+UniqueString())
			local searchname = ent.GetName()

			local org = ent.GetOrigin()

			local dummyent = Utils.CreateEntityWithTable({classname="prop_dynamic_override",model="models/props_misc/pot-1.mdl",origin=org,angles=QAngle(0,0,0),Solid=6,spawnflags=8,targetname=cuniq})
			dummyent.SetRenderMode(RENDER_NONE);
			dummyent.SetNetProp("m_CollisionGroup",1)
			dummyent.SetNetProp("m_clrRender",color);
			dummyent.SetNetProp("m_nSkin",skin);
			dummyent.SetModelScale(scale);

			AddThinkToEnt(dummyent.GetBaseEntity(),"PostConvertChecker")

			ConvertCheckTable[dummyent.GetName()] <- {oldname=oldname,searchname=searchname,dummytime=Time(),func="_dropit",extra_arg="",angles=ent.GetAngles()}

			local convertername = ::Constants.Targetnames.PhysConverter+cuniq
			local converter = Utils.CreateEntityWithTable({classname="phys_convert",targetname=convertername,target="#"+oldind,spawnflags=3})
			converter.Input("converttarget")
			converter.Input("Kill")

			return searchname
		}
	}
}

/*
 * @authors rhino
 */
::ShortenModelName <- function(mdl)
{
	local mdls = mdl.find("models/")
	if(mdls != null)
	{
		mdl = mdl.slice(mdls+7)
	}
	mdls = mdl.find(".mdl")
	if(mdls != null)
	{
		mdl = mdl.slice(0,mdl.len()-4)
	}
	return mdl
}
::FixShortModelName <- function(mdl)
{
	if(mdl.find("models/") != 0)
		mdl = "models/" + mdl
	if(mdl.find(".mdl") == null)
		mdl = mdl + ".mdl"
	return  mdl
}

::CreateMassCheckerEnt <- function()
{
	local keyvaltable = 
	{	
		classname = "filter_activator_mass_greater"
		origin = Vector(0,0,0)
		spawnflags = 0
		filtermass = getconsttable()["PHYS_MIN_MASS"]
	}
	local mass_checker = Utils.CreateEntityWithTable(keyvaltable)
	mass_checker.SetName("project_smok_mass_checker")

	DoEntFire("!self","AddOutput","OnPass !self,CallScriptFunction,DoCallbacksAfterMassPass,0,-1",0,null,mass_checker.GetBaseEntity())
	DoEntFire("!self","AddOutput","OnFail !self,CallScriptFunction,DoCallbacksAfterMassFail,0,-1",0,null,mass_checker.GetBaseEntity())
	mass_checker.GetScriptScope()["IsFree"] <- true
	mass_checker.GetScriptScope()["DoCallbacksAfterMassPass"] <- function(...)
	{
		local ent = Entity(self.GetScriptScope()["ActivatorID"])
		if(ent.IsEntityValid())
		{
			if(self.GetScriptScope()["PassCallbackArgs"] == null)
			{
				self.GetScriptScope()["PassCallback"](ent)
			}
			else
			{
				self.GetScriptScope()["PassCallback"](self.GetScriptScope()["PassCallbackArgs"])
			}

		}
		self.GetScriptScope()["IsFree"] = true
	}

	mass_checker.GetScriptScope()["DoCallbacksAfterMassFail"] <- function(...)
	{
		local ent = Entity(self.GetScriptScope()["ActivatorID"])
		if(ent.IsEntityValid())
		{
			if(self.GetScriptScope()["KillOnFailure"])
			{
				ent.Kill()
			}
		}
		self.GetScriptScope()["IsFree"] = true
	}
	return mass_checker
}

/*
 * @authors rhino
 */
::CheckPhysicsAvailabilityForModel <- function(modelname,curr_ent,callback,callback_backupargs=null,kill_onfail=false)
{	
	if(modelname == "")
		return false

	modelname = ShortenModelName(modelname).tolower()

	if(modelname in ::ModelDetails)
		return ("mass" in ::ModelDetails[modelname]) || ("totalmass" in ::ModelDetails[modelname])
	else
	{
		local mass_checker = Entity("project_smok_mass_checker")
		if(!mass_checker.IsEntityValid())
		{
			mass_checker = CreateMassCheckerEnt()
		}

		local scope = mass_checker.GetScriptScope()
		if(curr_ent == null)
		{
			if(callback_backupargs != null)
			{
				curr_ent = callback_backupargs.ent
			}
			else
				return false
		}

		if(scope["IsFree"])
		{
			scope["IsFree"] <- false
			scope["ActivatorID"] <- curr_ent.GetIndex()
			scope["KillOnFailure"] <- kill_onfail
			scope["PassCallback"] <- callback
			scope["PassCallbackArgs"] <- callback_backupargs
			DoEntFire("!self","testactivator","",0.1,curr_ent.GetBaseEntity(),mass_checker.GetBaseEntity())
		}
		else
		{
			Timers.AddTimer(0.2,false,DoMassStartProcessCheck,{ActivatorID=curr_ent.GetIndex(),KillOnFailure=kill_onfail,PassCallback=callback,PassCallbackArgs=callback_backupargs})
		}
		
	}
}
::DoMassStartProcessCheck <- function(args)
{
	local mass_checker = Entity("project_smok_mass_checker")
	if(!mass_checker.IsEntityValid())
	{
		mass_checker = CreateMassCheckerEnt()
	}
	local scope = mass_checker.GetScriptScope()
	if(scope["IsFree"])
	{
		scope["IsFree"] <- false
		scope["ActivatorID"] <- args.ActivatorID
		scope["KillOnFailure"] <- args.KillOnFailure
		scope["PassCallback"] <- args.PassCallback
		scope["PassCallbackArgs"] <- args.PassCallbackArgs
		DoEntFire("!self","testactivator","",0.05,Ent(args.ActivatorID),mass_checker.GetBaseEntity())
	}
	else
	{
		Timers.AddTimer(0.15,false,DoMassStartProcessCheck,{ActivatorID=args.ActivatorID,KillOnFailure=args.KillOnFailure,PassCallback=args.PassCallback,PassCallbackArgs=args.PassCallbackArgs})
	}
}

/*
 * @authors rhino
 */
::DoGivePhysicsIter <- function(args={})
{
	::AdminSystem.out("Physics Progress: "+Utils.BuildProgressBar(20.0,((args.total-args.left).tofloat()/args.total.tofloat())*20.0,20.0,"|", ". "))
	local i = 0
	local maxproc = getconsttable()["PHYS_MAX_PROCESS"]
	local maxiter = getconsttable()["PHYS_MAX_ITER"]

	local objs = args.objs
	
	local all_len = objs.len()
	local last_index = 0
	local keepiter = false

	if(all_len == 0)
	{	
		::LongProcessIterAvailability.give_physics = true
		::AdminSystem.out("Physics Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
		return;
	}

	foreach(idx, ent in objs)
	{
		last_index = idx
		if(idx >= maxiter)
		{
			keepiter = true
			break;
		}
		if(!ent.IsEntityValid())
			continue;
		if(ent.GetParent() != null)
			continue; 

		local entclass = ent.GetClassname();
		local entmdl = ent.GetModel().tolower();
		if(entclass == "player")
			continue;

		if(ent.HasBadPhysicsModel())
			continue
		
		if(SessionState.MapName in ::GivePhysicsMapSpecificBans)
		{ 
		  if((ent.GetName() in ::GivePhysicsMapSpecificBans[SessionState.MapName].entities
					&& entclass == ::GivePhysicsMapSpecificBans[SessionState.MapName].entities[ent.GetName()].classname
					&& ent.GetEntityHandle() == Entity(::GivePhysicsMapSpecificBans[SessionState.MapName].entities[ent.GetName()].id).GetEntityHandle()
			)
			||
			(
				entmdl in ::GivePhysicsMapSpecificBans[SessionState.MapName].models 
			)
		  )
		  	continue;
		}

		// Not in table, in the table but disabled
		if(!(entclass in AdminSystem.Vars._grabAvailable))
		{	
			// It's not even a weapon spawn
			if(entclass.find("weapon_") == null)
				continue
				
			if(entclass.find("spawn") == null)
			{
				i += 1
				if(i > maxproc)
				{
					keepiter = true
					break;
				}
				if(ent.GetSpawnFlags() % 2 == 1 && (entclass in {weapon_molotov=1,weapon_pistol=1}))
				{
					ent.SetSpawnFlags(ent.GetSpawnFlags()-1);
				}
				ent.Input("RunScriptCode","_dropit(Entity("+ent.GetIndex()+"))",0);
			}
			continue;
		}
		else if(!AdminSystem.Vars._grabAvailable[entclass])
			continue
		
		if(!::CheckPhysicsAvailabilityForModel(entmdl,ent,GivePhysicsToEntity))
			continue

		i += 1
		if(i > maxproc)
		{
			keepiter = true
			break;
		}

		::GivePhysicsToEntity(ent)
	}

	if(last_index != all_len-1)
	{
		objs = objs.slice(last_index)
	}

	if(keepiter)
	{
		Timers.AddTimer(0.4,false,::DoGivePhysicsIter,{total=args.total,left=objs.len(),objs=objs})
	}
	else
	{	
		::LongProcessIterAvailability.give_physics = true
		::AdminSystem.out("Physics Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
	}
}

/*
 * @authors rhino
 */
::AdminSystem.GivePhysicsCmd <- function(player,args)
{
	
	if(!::LongProcessIterAvailability.zero_g || !::LongProcessIterAvailability.give_physics)
	{
		Printer(player,"You can't use this command while one or both zero_g and give_physics processes are still running!")
		return
	}
	local rad = GetArgument(1);

	if(rad == "!picker")
	{
		local looked = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
		if(looked == null || looked.GetParent() != null)
			return;
		if(looked.GetClassname() == "player")
			return;
		if(looked.GetParent() != null)
			return; 

		local entclass = looked.GetClassname();

		// Not in table, in the table but disabled
		if(!(entclass in AdminSystem.Vars._grabAvailable))
		{	
			// It's not even a weapon spawn
			if(entclass.find("weapon_") == null)
				return

			if(entclass.find("spawn") == null)
			{
				if(looked.GetSpawnFlags() % 2 == 1 && (entclass in {weapon_molotov=1,weapon_pistol=1}))
				{
					looked.SetSpawnFlags(looked.GetSpawnFlags()-1);
				}
				looked.Input("RunScriptCode","_dropit(Entity("+looked.GetIndex()+"))",0);
			}
			return;
		}
		else if(!AdminSystem.Vars._grabAvailable[entclass])
			return
		
		if(looked.HasBadPhysicsModel())
			return
		
		::GivePhysicsToEntity(looked)
	}
	else if(rad == "all")
	{
		::LongProcessIterAvailability.give_physics = false
		local i = 0
		local maxproc = getconsttable()["PHYS_MAX_PROCESS"]
		local maxiter = getconsttable()["PHYS_MAX_ITER"]

		local objs = Utils.TableToArray(Objects.All())
		
		local all_len = objs.len()
		local last_index = 0
		local keepiter = false
		
		foreach(idx, ent in objs)
		{
			last_index = idx
			if(idx >= maxiter)
			{
				keepiter = true
				break;
			}

			if(ent.GetParent() != null)
				continue; 

			local entclass = ent.GetClassname();
			local entmdl = ent.GetModel().tolower();

			if(entclass == "player")
				continue;
			
			if(ent.HasBadPhysicsModel())
				continue
			
			if(SessionState.MapName in ::GivePhysicsMapSpecificBans)
			{ 
				if((ent.GetName() in ::GivePhysicsMapSpecificBans[SessionState.MapName].entities
							&& entclass == ::GivePhysicsMapSpecificBans[SessionState.MapName].entities[ent.GetName()].classname
							&& ent.GetEntityHandle() == Entity(::GivePhysicsMapSpecificBans[SessionState.MapName].entities[ent.GetName()].id).GetEntityHandle()
					)
					||
					(
						entmdl in ::GivePhysicsMapSpecificBans[SessionState.MapName].models 
					)
				)
					continue;
			}
			// Not in table, in the table but disabled
			if(!(entclass in AdminSystem.Vars._grabAvailable))
			{	
				// It's not even a weapon spawn
				if(entclass.find("weapon_") == null)
					continue
					
				if(entclass.find("spawn") == null)
				{
					i += 1
					if(i > maxproc)
					{
						keepiter = true
						break;
					}
					if(ent.GetSpawnFlags() % 2 == 1 && (entclass in {weapon_molotov=1,weapon_pistol=1}))
					{
						ent.SetSpawnFlags(ent.GetSpawnFlags()-1);
					}
					ent.Input("RunScriptCode","_dropit(Entity("+ent.GetIndex()+"))",0);
				}
				continue;
			}
			else if(!AdminSystem.Vars._grabAvailable[entclass])
				continue
			
			if(!::CheckPhysicsAvailabilityForModel(entmdl,ent,GivePhysicsToEntity))
				continue

			i += 1
			if(i > maxproc)
			{
				keepiter = true
				break;
			}

			::GivePhysicsToEntity(ent)
		}

		if(last_index != all_len-1)
		{
			objs = objs.slice(last_index)
		}
		if(keepiter)
		{
			Timers.AddTimer(0.4,false,DoGivePhysicsIter,{total=all_len,left=objs.len(),objs=objs})
		}
		else
		{	
			::LongProcessIterAvailability.give_physics = true
			::AdminSystem.out("Physics Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
		}
	}
	else
	{
		if(rad == null)
			rad = 150;
		else
			rad = rad.tofloat();

		local looked = player.GetLookingLocation();
		foreach(ent in Objects.AroundRadius(looked,rad))
		{
			if(ent.GetParent() != null)
				continue; 
			if(ent.GetClassname() == "player")
				continue;

			local entclass = ent.GetClassname();
	
			// Not in table, in the table but disabled
			if(!(entclass in AdminSystem.Vars._grabAvailable))
			{	
				// It's not even a weapon spawn
				if(entclass.find("weapon_") == null)
					continue
					
				if(entclass.find("spawn") == null)
				{
					if(ent.GetSpawnFlags() % 2 == 1 && (entclass in {weapon_molotov=1,weapon_pistol=1}))
					{
						ent.SetSpawnFlags(ent.GetSpawnFlags()-1);
					}
					ent.Input("RunScriptCode","_dropit(Entity("+ent.GetIndex()+"))",0);
				}
				continue;
			}
			else if(!AdminSystem.Vars._grabAvailable[entclass])
				continue
			
			if(ent.HasBadPhysicsModel())
				continue

			if(!::CheckPhysicsAvailabilityForModel(ent.GetModel(),ent,GivePhysicsToEntity))
				continue

			::GivePhysicsToEntity(ent)	
		}
	}
}

/////////////////////////// 
/// Ragdoll

::AdminSystem.ChangeRagdollViewPositionCmd <- function(player,args)
{
	if(player.HasRagdollPresent())
	{
		local axis = GetArgument(1)
		if(!axis)
			return
		local units = GetArgument(2)
		if(!units)
			return
		units = units.tofloat()
		
		local dir = player.GetEyeAngles()
		local rag = player.GetRagdollEntity()
		switch(axis)
		{
			case "x":
				rag.GetScriptScope()["PS_OWNER_ORIGIN"] <- RotatePosition(Vector(0,0,0),dir,Vector(units,0,0)) + rag.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
			case "y":
				rag.GetScriptScope()["PS_OWNER_ORIGIN"] <- RotatePosition(Vector(0,0,0),dir,Vector(0,units,0)) + rag.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
			case "z":
				rag.GetScriptScope()["PS_OWNER_ORIGIN"] <- RotatePosition(Vector(0,0,0),dir,Vector(0,0,units)) + rag.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
		}
	}
}

::RagParams <-
{
	disableguns = true
	useseq = true
}

::RagdollParams <-
{
	speed = 60
	friction = 0.3
	friction_dur = 0.2
}

::RagdollControls <-
{
	Initialize = function(player,rag,b_ragdoll)
	{
		::Quix.AddUnlimited(Constants.TimerNames.RagdollControl+player.GetIndex(),
							@(c,a) true,
							@(c,s,a) ::RagdollControls.Pusher(a.player,a.player.GetPressedButtons(),b_ragdoll),
							{player=player},
							{player=player});

	}

	Pusher = function(player,mask,b_ragdoll)
	{
		local name = player.GetCharacterNameLower();
		local speed = ::RagdollParams.speed;

		local rag = player.GetRagdollEntity()
		if(!rag)
			return;

        if(b_ragdoll)
		    player.SetLocalOrigin(rag.GetScriptScope()["PS_OWNER_ORIGIN"]);
        else
		    player.SetOrigin(rag.GetOrigin()+rag.GetScriptScope()["PS_OWNER_ORIGIN"]);

		if(mask == 0)
			return;

		local eyeangles = player.GetEyeAngles()
		if(!eyeangles)
			return
            
		local fw = eyeangles.Forward()

		function IsPressing(mask,btn)
		{
			return (mask & btn) != 0
		}

		rag.OverrideFriction(::RagdollParams.friction_dur,::RagdollParams.friction)

		if(IsPressing(mask,BUTTON_FORWARD))
		{
			rag.Push(fw.Scale(speed))
		}
		if(IsPressing(mask,BUTTON_BACK))
		{
			rag.Push(fw.Scale(-speed))
		}

		if(IsPressing(mask,BUTTON_MOVELEFT))
		{
			fw = (eyeangles + QAngle(0,90,0)).Forward()
			rag.Push(fw.Scale(speed))
		}
		if(IsPressing(mask,BUTTON_MOVERIGHT))
		{
			fw = (eyeangles + QAngle(0,-90,0)).Forward()
			rag.Push(fw.Scale(speed))
		}

		if(IsPressing(mask,BUTTON_ATTACK))
		{
			rag.Push(Vector(0,0,speed))
		}
		if(IsPressing(mask,BUTTON_SHOVE))
		{
			rag.Push(Vector(0,0,-speed))
		}
	}
}

::StartRagdolling <- function(args)
{
	local rag, player = args.player
	
	local idx = player.GetIndex();

	local ang = QAngle(0,player.GetEyeAngles().Yaw(),0);
	local org = player.GetOrigin();
	local mdl = player.GetModel()
	local v = player.GetPhysicsVelocity();
	local playerseq = player.GetNetProp("m_nSequence")
	local playercycle = player.GetNetProp("m_flCycle")
	
    local is_ragdoll_mdl = RagdollOrPhysicsDecider(player.GetModel()) == "prop_ragdoll"
	if(is_ragdoll_mdl)
	{
		rag = Utils.SpawnRagdoll(mdl,org,ang,{spawnflags=32772});
		rag.SetRenderMode(RENDER_NONE);
	}
	else
	{
		rag = Utils.SpawnPhysicsMProp(mdl,org,ang);
		if(rag==null)
		{
			Messages.ThrowPlayer(player,"Can't ragdoll as model: "+ShortenModelName(mdl));
			return
		}
		player.SetRenderMode(RENDER_NONE);
	}

	AdminSystem.Vars.IsGodEnabled[idx] <- true;
	AdminSystem.Vars.IsNoclipEnabled[idx] <- false;
	AdminSystem.Vars.IsFreezeEnabled[idx] <- false;

	if(player.GetParent() != null)
	{
		player.Input("clearparent","",0);
		player.Input("RunScriptCode","_dropit(Player(self.GetEntityIndex()))",0.05);
	}
	
	player.Input("disableledgehang","")
	player.SetNetProp("m_flFrozen",1);
	player.SetMoveType(MOVETYPE_NONE);
	player.SetNetProp("m_fEffects",513)

	rag.SetName(Constants.Targetnames.Ragdoll+player.GetIndex());
	rag.GetScriptScope()["PS_RAGDOLL_OWNER"] <- player;

	if(is_ragdoll_mdl)
	{
	    player.Input("setparent","#"+rag.GetIndex() + ",bleedout",0.09)
		rag.GetScriptScope()["PS_OWNER_ORIGIN"] <- Vector(0,0,0)

		player.SetRenderEffects(RENDERFX_RAGDOLL);
		rag.SetNetProp("m_CollisionGroup",2)
		if(RagParams.useseq)
		{
			rag.GetBaseEntity().SetSequence(playerseq)
			//rag.SetNetProp("m_nSequence",playerseq);
			rag.SetNetProp("m_flCycle",playercycle);
		}
		rag.SetNetProp("m_nForceBone",player.GetNetProp("m_nForceBone"))
		//player.Input("runscriptcode","self.SetLocalOrigin(Vector("+localorg.x+","+localorg.y+","+localorg.z+"))",0.14)
	}
    else
    {
		rag.SetNetProp("m_CollisionGroup",0)
		rag.GetBaseEntity().SetSequence(0)
		local coll = rag.GetNetProp("m_Collision")
		local mx = coll.x < coll.y ? ( coll.z < coll.x ? coll.z : coll.x) : ( coll.z < coll.y ? coll.z : coll.y)
		coll = Vector(mx,mx,coll.z)
		local bbox = coll + player.GetNetProp("m_Collision")
		local localorg = RotatePosition(Vector(0,0,0),QAngle(0,180,0),bbox).Scale(1.1);
		// local localorg = Vector(0,0,1250)
		rag.GetScriptScope()["PS_OWNER_ORIGIN"] <- localorg

		player.SetNetProp("m_CollisionGroup",12)
		player.SetNetProp("m_MoveCollide",0)
    }
    
	rag.SetEFlags(EFL_IN_SKYBOX|EFL_HAS_PLAYER_CHILD)

	rag.Push(v);
	player.SetVelocity(Vector(0,0,0))	
	rag.GetScriptScope()["WepBlock"] <- function()
	{
		local ch = self.GetScriptScope()["PS_RAGDOLL_OWNER"];
		if(ch == null || !ch.IsEntityValid())
			return

		if(ch.GetNetProp("m_staggerDist").tostring() != "0")	// Staggered from hunter/charger/boomer
		{
			RecoverRagdollInitial(Entity(self.GetEntityIndex()));
			return;
		}

		ch = ch.GetBaseEntity()

		NetProps.SetPropFloat(ch,"m_TimeForceExternalView", Time()+1);
		NetProps.SetPropFloat(ch,"m_stunTimer.m_duration", 1);
		NetProps.SetPropFloat(ch,"m_stunTimer.m_timestamp", Time()+1);
		
		try
		{
			local w = ch.GetActiveWeapon();
			if (w != null && w.IsValid() && RagParams.disableguns)
			{
				NetProps.SetPropFloat(w,"m_flNextPrimaryAttack", 99999);
				NetProps.SetPropFloat(w,"m_flNextSecondaryAttack", 99999);
			}
		}
		catch(e){}

		DoEntFire("!self","CallScriptFunction","WepBlock",0.06,null,self);
	}

	DoEntFire("!self","CallScriptFunction","WepBlock",0,null,rag.GetBaseEntity());
	
	Printer(player,"Created ragdoll #"+rag.GetIndex());

	::RagdollControls.Initialize(player,rag,is_ragdoll_mdl);
}

::AdminSystem.GoRagdollCmd <- function(player,args)
{
	if(::VSLib.EasyLogic.NextMapContinues)
		return;

	if(RagdollStateCheck(player))
		return;

	if("PS_RAGDOLL_PROCESSING_STATE" in player.GetScriptScope() 
		&& player.GetScriptScope()["PS_RAGDOLL_PROCESSING_STATE"])
		return

    player.GetScriptScope()["PS_RAGDOLL_PROCESSING_STATE"] <- true

	local rag = Objects.AnyOfName(Constants.Targetnames.Ragdoll+player.GetIndex())
	if(rag != null && rag.IsEntityValid())
		RecoverRagdollInitial(rag);
	else
		::StartRagdolling({player=player})
    
    // Prevent spam
    player.Input("runscriptcode","self.GetScriptScope().PS_RAGDOLL_PROCESSING_STATE <- false",0.2)
}

::AdminSystem.RecoverRagdollCmd <- function(player,args)
{
	local rag = player.GetRagdollEntity()

	if(rag == null)
		return;
	
	if("PS_RAGDOLL_PROCESSING_STATE" in player.GetScriptScope() 
		&& player.GetScriptScope()["PS_RAGDOLL_PROCESSING_STATE"])
		return

	RecoverRagdollInitial(rag);
}

::RecoverRagdollInitial <- function(rag)
{
	local player = rag.GetScriptScope()["PS_RAGDOLL_OWNER"]
	if(player == null || !player.IsEntityValid())
		return;
	
	local eyeangles = player.GetEyeAngles()
	player.SetEyeAngles(eyeangles.x,eyeangles.y,0);

	local ragseq = 0
	local ragcycle = 0
	if(RagdollOrPhysicsDecider(rag.GetModel()) == "prop_ragdoll")
	{
		ragseq = rag.GetNetProp("m_nSequence")
		ragcycle = rag.GetNetProp("m_flCycle")
	}

	::Quix.Remove(Constants.TimerNames.RagdollControl+player.GetIndex());

	if(RagParams.useseq)
	{
		player.SetNetProp("m_nSequence",ragseq);
		player.SetNetProp("m_flCycle",ragcycle);
	}
	player.SetNetProp("m_flFrozen",0);
	player.SetNetProp("m_fEffects",0)
	
	player.Input("enableledgehang","")
	AdminSystem.Vars.IsGodEnabled[player.GetIndex()] <- false;

	local v = rag.GetPhysicsVelocity();

	DoEntFire("!self","clearparent","",0,null,player.GetBaseEntity())
	local en = ::AdminSystem._GetEnumString(v.ToKVString()+"_"+rag.GetOrigin().ToKVString());
	
	DoEntFire("!self","RunScriptCode","RecoverRagdollPost("+en+")",0.05,null,player.GetBaseEntity())

	rag.Input("Kill","",0)
}
// TO-DO: Refactor
::RecoverRagdollPost <- function(vec)
{
	local vecs = split(vec,"_")
	local v = split(vecs[0]," ")
	local org = split(vecs[1]," ")

	v = Vector(v[0].tofloat(),v[1].tofloat(),v[2].tofloat())
	org = Vector(org[0].tofloat(),org[1].tofloat(),org[2].tofloat())

	local player = Player(self.GetEntityIndex());
	
	player.SetNetProp("m_stunTimer.m_duration", 0);
	player.SetNetProp("m_stunTimer.m_timestamp", Time());

	local w = self.GetActiveWeapon();
	player.SetNetProp("m_hActiveWeapon", -1);
	if(w != null && w.IsValid())
	{
		self.SwitchToItem(w.GetClassname());
		NetProps.SetPropFloat(w,"m_flNextPrimaryAttack", 0);
		NetProps.SetPropFloat(w,"m_flNextSecondaryAttack", 0);
	}

	player.SetVelocity(Vector(0,0,0))
	player.SetMoveType(MOVETYPE_WALK);
	player.SetRenderEffects(RENDERFX_NONE);
	player.SetRenderMode(RENDER_NORMAL);

	player.SetNetProp("m_TimeForceExternalView", Time());
	player.SetNetProp("m_Local.m_iHideHUD", player.GetNetProp("m_Local.m_iHideHUD") & ~HIDEHUD_WEAPONSELECTION)
	player.SetOrigin(org+Vector(0,0,5))
	player.Push(v);
}
/*************************\
* BOT SHARE/LOOT FUNCTIONS *
\*************************/
/*
 * @authors rhino
 */
::AdminSystem.SetBotShareLootSettings <- function()
{
	::AdminSystem.BotParams <- ::Constants.GetBotShareLootSettingsDefaults();

	::AdminSystem.BotOnSearchOrSharePath <- ::AdminSystem.Vars.RepeatValueForSurvivors(false);

	::AdminSystem.BotBringingItem <- ::AdminSystem.Vars.RepeatValueForSurvivors(false);

	::AdminSystem.BotTemporaryStopState <- ::AdminSystem.Vars.RepeatValueForSurvivors(false);

	local fileContents = FileToString(::Constants.Directories.BotSettings);
	
	if(fileContents == null)
	{
		printR("[Bot-Params] Creating bot share/loot settings file for the first time...");
		StringToFile(::Constants.Directories.BotSettings,::Constants.GetBotShareLootSettings());
		fileContents = FileToString(::Constants.Directories.BotSettings);
	}

	local settings = split(fileContents, "\r\n");

	foreach(setting in settings)
	{
		if ( strip(setting) != "" )
		{
			local code = "AdminSystem.BotParams." + ::Utils.StringReplace(setting, "=", "<-");
			compilestring(code)();
		}
	}
}
::AdminSystem.SetBotShareLootSettings();

::AdminSystem.Update_bots_sharing_preferenceCmd <- function ( player, args )
{
	local newstate = !::AdminSystem.Vars.AllowAutomatedSharing;
	::AdminSystem.Vars.AllowAutomatedSharing = newstate;

	Messages.InformAll(CmdMessages.BotSharingPreference(player.GetCharacterName(),newstate));
}

::_ClearBeingTakenStatus <- function(args)
{
	if(args.item in ::AdminSystem.Vars._currentlyBeingTaken)
		delete ::AdminSystem.Vars._currentlyBeingTaken[args.item];
}

::RemoveCustomThinkTimers <- function(index,searchonly=false)
{
	if(!searchonly)
	{
		if(::Constants.TimerNames.BotShareAttemptSlot2+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot2+index]);
			delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot2+index];
		}
		if(::Constants.TimerNames.BotShareAttemptSlot3+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot3+index]);
			delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot3+index];
		}

		if(::Constants.TimerNames.BotThinkAdder+index in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotThinkAdder+index]);
			delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotThinkAdder+index];
		}
	}

	if(::Constants.TimerNames.BotSearchAttemptSlot2+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotSearchAttemptSlot2+index]);
		delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotSearchAttemptSlot2+index];
	}
	if(::Constants.TimerNames.BotSearchAttemptSlot3+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotSearchAttemptSlot3+index]);
		delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotSearchAttemptSlot3+index];
	}
	
}

::_TakenFailCheckerRemover <- function(args)
{
	if(args.index in ::AdminSystem.Vars._currentlyBeingTaken)
	{
		args.bot.BotReset();
		::RemoveCustomThinkTimers(args.bot.GetIndex(),true);
		::AdminSystem.BotOnSearchOrSharePath[args.bot.GetCharacterNameLower()] = false;
		delete ::AdminSystem.Vars._currentlyBeingTaken[args.index];
	}
}

::_ShareFailCheckerRemover <- function(args)
{
	local index = args.botindex;
	args.bot.BotReset();

	if(::Constants.TimerNames.BotShareAttemptSlot2+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot2+index]);
		delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot2+index];
	}
	if(::Constants.TimerNames.BotShareAttemptSlot3+index in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot3+index]);
		delete ::VSLib.Timers.TimersID[::Constants.TimerNames.BotShareAttemptSlot3+index];
	}

	::AdminSystem.BotOnSearchOrSharePath[args.bot.GetCharacterNameLower()] = false;
	::AdminSystem.BotBringingItem[args.targetname] = false;
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
	local timername = slot == 2 
						? ::Constants.TimerNames.BotSearchAttemptSlot2+botindex
						: ::Constants.TimerNames.BotSearchAttemptSlot3+botindex
	
	if(::Utils.CalculateDistance(args.bot.GetEyePosition(),obj.GetOrigin()) <= ::AdminSystem.BotParams.MaxRadiusToTake && (timername in ::VSLib.Timers.TimersID))
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];
		
		if(bot.IsAlive() && !bot.IsIncapacitated() && !bot.IsHealing())
		{
			::AdminSystem.BotOnSearchOrSharePath[bot.GetCharacterNameLower()] = false;

			if(obj.GetIndex() in ::AdminSystem.Vars._currentlyBeingTaken)
				delete ::AdminSystem.Vars._currentlyBeingTaken[obj.GetIndex()];

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
			}
			bot.BotReset();
		}
	}
	else if(timername in ::VSLib.Timers.TimersID)
	{
		foreach(inf in ::Objects.OfClassnameWithin("inferno",obj.GetOrigin(),275))
		{
			local a = ::Utils.CalculateDistance(obj.GetOrigin(),inf.GetOrigin())
			local b = ::Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
			local f = ::Utils.CalculateDistance(obj.GetOrigin(),bot.GetOrigin())
			local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
			local d = pow((b-temp)*(b+temp),0.5)
			if(d < 125)
			{
				bot.BotReset();
				return;
			}
		}
		foreach(inf in ::Objects.OfClassnameWithin("insect_swarm",obj.GetOrigin(),275))
		{
			local a = ::Utils.CalculateDistance(obj.GetOrigin(),inf.GetOrigin())
			local b = ::Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
			local f = ::Utils.CalculateDistance(obj.GetOrigin(),bot.GetOrigin())
			local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
			local d = pow((b-temp)*(b+temp),0.5)
			if(d < 125)
			{
				bot.BotReset();
				return;
			}
		}

		if((rand().tofloat()/RAND_MAX) <= ::AdminSystem.BotParams.ChanceRelocateWhenTooFarToGet 
			&& !bot.IsInCombat()
			&& bot.IsAlive()
			&& !bot.IsIncapacitated()
			&& !bot.IsHealing()
			&& !bot.IsBeingHealed()
			)
		{
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
	local item = args.item;
	local timername = slot == 2 
						? ::Constants.TimerNames.BotShareAttemptSlot2+botindex
						: ::Constants.TimerNames.BotShareAttemptSlot3+botindex
	if(Utils.CalculateDistance(bot.GetOrigin(),target.GetOrigin()) <= ::AdminSystem.BotParams.MaxRadiusToLetShare 
		&& (timername in ::VSLib.Timers.TimersID) 
		&& !::AdminSystem.BotTemporaryStopState[botname])
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];

		if(bot.IsAlive() && !bot.IsIncapacitated() && !bot.IsHealing())
		{
			if(!target.IsAlive())
			{
				::AdminSystem.BotOnSearchOrSharePath[botname] = false;
				::AdminSystem.BotBringingItem[target.GetCharacterNameLower()] = false;
			}
			else if(!target.IsIncapacitated() && !target.IsHealing() && !target.IsBeingHealed())
			{
				::AdminSystem.BotOnSearchOrSharePath[botname] = false;
				::AdminSystem.BotBringingItem[target.GetCharacterNameLower()] = false;
				
				local spawnertooclose = false;
				
				if(item != null && item.IsEntityValid())
				{
					foreach(spawner in ::Objects.OfClassnameWithin(args.item.GetClassname()+"_spawn",bot.GetOrigin(),100))
					{
						if(spawner.GetNetProp("m_fEffects") == 48 || spawner.GetSpawnFlags() == 10)
						{
							spawnertooclose = true;
							break;
						}
					}

					if(!spawnertooclose && ("slot"+slot in bot.GetHeldItems()) && !("slot"+slot in target.GetHeldItems()))
					{
						bot.Speak(::Utils.GetRandValueFromArray(::Survivorlines.ShareItem[botname]),0.1);
						
						::AdminSystem.Vars._currentlyBeingTaken[args.item.GetIndex()] <- true;
						::Utils.DropThenGive(bot,target,slot,args.item);
						::VSLib.Timers.AddTimer(0.5, false, _ClearBeingTakenStatus,{item=args.item.GetIndex()});
						
						::AdminSystem.BotTemporaryStopState[botname] <- true;
						::VSLib.Timers.AddTimer(::AdminSystem.BotParams.HoldNewGivenFor, false, _TemporaryStopStatusWrapper,{bot=botname});
					}
				}
			}
			bot.BotReset();
		}	
	}
	else if(timername in ::VSLib.Timers.TimersID)
	{
		if(item == null || !item.IsEntityValid())
		{
			bot.BotReset();
		}
		else
		{
			foreach(inf in ::Objects.OfClassnameWithin("inferno",args.item.GetOrigin(),275))
			{
				local a = ::Utils.CalculateDistance(args.item.GetOrigin(),inf.GetOrigin())
				local b = ::Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
				local f = ::Utils.CalculateDistance(args.item.GetOrigin(),bot.GetOrigin())
				local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
				local d = pow((b-temp)*(b+temp),0.5)
				if(d < 125)
				{
					bot.BotReset();
					return;
				}
			}
			foreach(inf in ::Objects.OfClassnameWithin("insect_swarm",args.item.GetOrigin(),275))
			{
				local a = ::Utils.CalculateDistance(args.item.GetOrigin(),inf.GetOrigin())
				local b = ::Utils.CalculateDistance(inf.GetOrigin(),bot.GetOrigin())
				local f = ::Utils.CalculateDistance(args.item.GetOrigin(),bot.GetOrigin())
				local temp = (pow(b,2)-pow(a,2)+pow(f,2))/(2*f)
				local d = pow((b-temp)*(b+temp),0.5)
				if(d < 125)
				{
					bot.BotReset();
					return;
				}
			}
			if((rand().tofloat()/RAND_MAX) <= ::AdminSystem.BotParams.ChanceRelocateWhenTooFarToGive  
				&& !bot.IsInCombat()
				&& bot.IsAlive()
				&& !bot.IsIncapacitated()
				&& !bot.IsHealing()
				&& !bot.IsBeingHealed())
			{
				bot.BotMoveToLocation(target.GetOrigin())
			}
		}
	}
}

::_TemporaryStopStatusWrapper <- function(args)
{
	::AdminSystem.BotTemporaryStopState[args.bot] <- false;
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
	local found = Objects.AnyOfName("think_adder_base_entity")
	if(found != null)
	{
		::AdminSystem._DisableKindnessCmd(player,args);
	}

	local name = player.GetCharacterNameLower();

	local thinkadder = _CreateLootThinker();
	::AdminSystem.Vars.LastLootThinkState = true;
	foreach(survivor,val in ::AdminSystem.BotOnSearchOrSharePath)
	{
		::AdminSystem.BotOnSearchOrSharePath[survivor] = false;
	}

	::Messages.InformAll(CmdMessages.EnableKindness(name,thinkadder));
}

/*
 * @authors rhino
 */
::AdminSystem._DisableKindnessCmd <- function(player,args)
{	
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

	foreach(survivor,val in ::AdminSystem.BotOnSearchOrSharePath)
	{
		::AdminSystem.BotOnSearchOrSharePath[survivor] = false;
		::AdminSystem.BotBringingItem[survivor] = false;
		::AdminSystem.BotTemporaryStopState[survivor] = false;
	}

	foreach(survivor in Players.AliveSurvivors())
	{
		::RemoveCustomThinkTimers(survivor.GetIndex());
	}

	foreach(survivor in Players.DeadSurvivors())
	{
		::RemoveCustomThinkTimers(survivor.GetIndex());
	}

	::AdminSystem.Vars._currentlyBeingTaken <- {};
	::AdminSystem.Vars.LastLootThinkState = false;

	if(!found)
		return;

	::Messages.InformAll(CmdMessages.DisableKindness(name));
}

/*
 * @authors rhino
 */
::_AddSearchThinkToBots <- function()
{
	if(!("AliveSurvivors" in ::Players))
		return;
	foreach(survivor in ::Players.AliveSurvivors())
	{
		if(!(::Constants.TimerNames.BotThinkAdder+survivor.GetIndex() in ::VSLib.Timers.TimersID) && survivor.IsBot())
		{
			Timers.AddTimerByName(::Constants.TimerNames.BotThinkAdder+survivor.GetIndex(),::AdminSystem.BotParams.MinThinkDelay+((rand().tofloat()/RAND_MAX)%::AdminSystem.BotParams.MaxOffsetThinkDelay),true,::_LookForLoot,{index=survivor.GetIndex()})
		}
	}
}

::BotAbilityFunctions <-
{
	InvalidatePaths = function(botname)
	{
		::AdminSystem.BotOnSearchOrSharePath[botname] = false;
		::AdminSystem.BotBringingItem[botname] = false;
	}

	ReachForItem = function(bot,botname,botindex,obj,foundclassslot)
	{
		::AdminSystem.BotOnSearchOrSharePath[botname] = true;
		::AdminSystem.Vars._currentlyBeingTaken[obj.GetIndex()] <- true;
		
		::Timers.AddTimer(::AdminSystem.BotParams.ReachTimeout,false,::_TakenFailCheckerRemover,{index=obj.GetIndex(),bot=bot});
		
		::Timers.AddTimerByName((foundclassslot == 2 
									? ::Constants.TimerNames.BotSearchAttemptSlot2+botindex 
									: ::Constants.TimerNames.BotSearchAttemptSlot3+botindex),
								::AdminSystem.BotParams.ItemReachTimerDelay,
								true,
								::_TryToReachAndGet,
								{bot=bot,obj=obj,slot=foundclassslot,classname=obj.GetClassname().slice(7)})
	}

	AroundPathable = function(pos,rad,closebygrenade_pack,hasgrenade,haspack)
	{
		if(!hasgrenade)	// no grenade
		{
			if(!haspack)	// no grenade, no pack
			{
				foreach(obj in Objects.AroundRadius(pos,rad))
				{
					if(::Utils.GetIDFromArray(::BotsSearchShareItems.grenades,obj.GetClassname()) != -1)
					{
						if(!::Utils.ItemHeldByOther(obj.GetIndex(),2) && obj.GetNetProp("m_fEffects") != 48)
						{
							closebygrenade_pack[obj.GetIndex()] <- 2
						}
					}
					else if(::Utils.GetIDFromArray(::BotsSearchShareItems.packs,obj.GetClassname()) != -1)
					{
						if(!::Utils.ItemHeldByOther(obj.GetIndex(),3))
						{
							closebygrenade_pack[obj.GetIndex()] <- 3
						}
					}
				}
			}
			else	// only missing grenade
			{
				foreach(obj in Objects.AroundRadius(pos,rad))
				{
					if(::Utils.GetIDFromArray(::BotsSearchShareItems.grenades,obj.GetClassname()) != -1)
					{
						if(!::Utils.ItemHeldByOther(obj.GetIndex(),2) && obj.GetNetProp("m_fEffects") != 48)
						{
							closebygrenade_pack[obj.GetIndex()] <- 2
						}
					}
				}
			}
		}
		else	// only missing pack
		{
			foreach(obj in Objects.AroundRadius(pos,rad))
			{
				if(::Utils.GetIDFromArray(::BotsSearchShareItems.packs,obj.GetClassname()) != -1)
				{
					if(!::Utils.ItemHeldByOther(obj.GetIndex(),3))
					{
						closebygrenade_pack[obj.GetIndex()] <- 3
					}
				}
			}
		}
	}

	ShareMain = function(bot,botindex,botname,origin,inHand,inhandclass,slot_no)
	{
		local closest = null;
		local lastdist = null;
		local currdist = null;
		foreach(survivor in ::Players.AliveSurvivors())
		{
			if(survivor.IsBot() || survivor.GetIndex() == botindex)
				continue;

			if(bot.CanSeeLocation(survivor.GetEyePosition(),::AdminSystem.BotParams.CanSee_Share))
			{
				local valid = false;
				local begin = bot.GetEyePosition();
				local finish = survivor.GetEyePosition();
				
				local m_trace = { start = begin, end = finish, ignore = bot.GetBaseEntity(), mask = ::AdminSystem.BotParams.Mask };
				TraceLine(m_trace);

				if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
					continue;
				
				if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
					continue;
				
				if (m_trace.enthit == survivor.GetBaseEntity() || ::Utils.AreVectorsEqual(m_trace.pos, finish))
					valid = true;

				if(!valid)
					continue;
			}
			else
				continue;

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
		}

		if(closest != null)
		{
			if(!::AdminSystem._CurrentlyTradingItems[closest.GetCharacterNameLower()] && !::AdminSystem.BotBringingItem[closest.GetCharacterNameLower()])
			{
				local closestorigin = closest.GetOrigin();

				if(!("slot"+slot_no in closest.GetHeldItems()) && Utils.CalculateDistance(origin,closestorigin) <= ::AdminSystem.BotParams.ClosestPlayerMaxDist)
				{
					local spawnertooclose = false;
					foreach(spawner in Objects.OfClassnameWithin(inhandclass+"_spawn",closestorigin,::AdminSystem.BotParams.SpawnerRadiusAroundClosest))
					{
						if(spawner.GetNetProp("m_fEffects") == 48 || spawner.GetSpawnFlags() == 10)
						{
							spawnertooclose = true;
							break;
						}
					}

					if((!spawnertooclose && bot.IsCalm()) || ((rand().tofloat()/RAND_MAX) <= ::AdminSystem.BotParams.RandomChanceForShare))
					{
						bot.BotMoveToLocation(closestorigin);

						::AdminSystem.BotOnSearchOrSharePath[botname] = true;
						::AdminSystem.BotBringingItem[closest.GetCharacterNameLower()] = true;

						::Timers.AddTimer(::AdminSystem.BotParams.ShareTimeout,false,::_ShareFailCheckerRemover,{bot=bot,botindex=botindex,targetname=closest.GetCharacterNameLower()});
						::Timers.AddTimerByName(::Constants.TimerNames["BotShareAttemptSlot"+slot_no]+botindex,::AdminSystem.BotParams.ItemShareTimerDelay,true,::_TryAndGiveItem,{bot=bot,target=closest,slot=slot_no,item=inHand,classname=inhandclass.slice(7)})

						return true;
					}
				}
			}
		}

		return false;
	}
}

::BotsSearchShareItems <-
{
	grenades = 
	[
		"weapon_molotov","weapon_pipe_bomb",
		"weapon_vomitjar",
		"weapon_molotov_spawn","weapon_pipe_bomb_spawn",
		"weapon_vomitjar_spawn",
	]
	packs = 
	[
		"weapon_first_aid_kit","weapon_first_aid_kit_spawn",
		"weapon_upgradepack_incendiary","weapon_upgradepack_explosive",
		"weapon_defibrillator_spawn","weapon_defibrillator",
		"weapon_upgradepack_incendiary_spawn","weapon_upgradepack_explosive_spawn"
	]
}

/*
 * @authors rhino
 */
::_LookForLoot <- function(arg)
{
	local botindex = arg.index;
	local bot = Player(botindex.tointeger());
	local botname = bot.GetCharacterNameLower();
	if(!bot.IsBot() || !bot.IsAlive())
	{
		::RemoveCustomThinkTimers(botindex);
		::BotAbilityFunctions.InvalidatePaths(botname);
	}
	else if(bot.IsIncapacitated())
	{
		::BotAbilityFunctions.InvalidatePaths(botname);
	}
	else if(!bot.IsInCombat() && !bot.IsHealing() && !bot.IsBeingHealed() && !::AdminSystem.BotOnSearchOrSharePath[botname] && !::AdminSystem._CurrentlyTradingItems[botname])
	{
		local inv = bot.GetHeldItems();
		local origin = bot.GetOrigin();
		local inHand = null;
		local inhandclass = null;
		local alreadygiving = false;
		
		local hasgrenade = ("slot2" in inv);
		local haspack = ("slot3" in inv);
		local share = ::AdminSystem.Vars.AllowAutomatedSharing;
		local temporarlystopped = ::AdminSystem.BotTemporaryStopState[botname];

		if(hasgrenade && share && !temporarlystopped)
		{
			if(!(::Constants.TimerNames.BotShareAttemptSlot2+botindex in ::Timers.TimersID))
			{
				inHand = inv.slot2;
				inhandclass = inHand.GetClassname();

				alreadygiving = ::BotAbilityFunctions.ShareMain(bot,botindex,botname,origin,inHand,inhandclass,2)
			}
			
		}

		if(haspack && !alreadygiving && share && !temporarlystopped)
		{
			if(!(::Constants.TimerNames.BotShareAttemptSlot3+botindex in ::Timers.TimersID))
			{
				inHand = inv.slot3;
				inhandclass = inHand.GetClassname();

				alreadygiving = ::BotAbilityFunctions.ShareMain(bot,botindex,botname,origin,inHand,inhandclass,3)
			}
		}

		if ((!hasgrenade || !haspack) && !alreadygiving)
		{
			local closebygrenade_pack = {};
			local usedorigin = origin;

			::BotAbilityFunctions.AroundPathable(usedorigin,::AdminSystem.BotParams.BotOriginLootRadius,closebygrenade_pack,hasgrenade,haspack)
			
			local randompathable = null
			if(closebygrenade_pack.len() == 0)
			{ 
				randompathable = bot.GetBaseEntity().TryGetPathableLocationWithin(::AdminSystem.BotParams.BotOriginLootRadius) + Vector(0,0,62);

				::BotAbilityFunctions.AroundPathable(randompathable,::AdminSystem.BotParams.PathableDist_Loot,closebygrenade_pack,hasgrenade,haspack)

				if(closebygrenade_pack.len() == 0)
					return;
				else
					usedorigin = randompathable;
			}
			
			local m_trace = null;
			local obj = null;
			local found = false;
			local foundclassslot = null;

			foreach(objindex,slot in closebygrenade_pack)
			{
				if(objindex in ::AdminSystem.Vars._currentlyBeingTaken)
					continue;

				obj = Entity(objindex);

				if(bot.CanSeeLocation(obj.GetOrigin(),::AdminSystem.BotParams.CanSee_Loot))
				{
					local valid = false;
					local begin = bot.GetEyePosition();
					local finish = obj.GetOrigin();
					local m_trace = { start = begin, end = finish, ignore = bot.GetBaseEntity(), mask = ::AdminSystem.BotParams.Mask };
					TraceLine(m_trace);

					if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
					{
						if(::Utils.AreVectorsEqual(m_trace.pos, finish) && obj.GetClassname().find("weapon_vomitjar") != null) // vomitjars are weird
						{
							valid = true;
							foundclassslot = slot;
							found = true;
							break;
						}
						else
						{
							m_trace = { start = begin, end = finish+Vector(0,0,2), ignore = bot.GetBaseEntity(), mask = ::AdminSystem.BotParams.Mask };
							TraceLine(m_trace);
							if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == bot.GetBaseEntity())
							{
								if(::Utils.AreVectorsEqual(m_trace.pos, finish) && obj.GetClassname().find("vomit_jar") != null) // vomitjars are weird
									valid = true;
								else
									continue;
							}
						}
						
					}
					
					if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
						continue;
					
					if (m_trace.enthit == obj.GetBaseEntity() || ::Utils.AreVectorsEqual(m_trace.pos, finish))
						valid = true;

					if(!valid)
						continue;
						
					foundclassslot = slot;
					found = true;
					break;
				}
			}
			
			if(found)
			{
				if(!obj.IsEntityValid())
					return;

				local org = obj.GetOrigin();
				if(::Utils.CalculateDistance(origin,org) <= ::AdminSystem.BotParams.VisibleDistLimit)
				{
					bot.BotMoveToLocation(org)
					::BotAbilityFunctions.ReachForItem(bot,botname,botindex,obj,foundclassslot)
				}
			}
		}
	}
}

// TO-DO: Make optional driving mechanics
::AdminSystem.RemoteControlCmd <- function(player,args)
{
	local target = GetArgument(1)
	if(target == null)
	{
		if(player.IsDrivingRCProp())
		{
			RecoverRCPropControlInitial(player.GetDrivenVehicle());
		}
		return;
	}
	
	if(player.IsDriving() || player.IsPassenger())
		return

	if(::DriverStateCheck(player))
	{
		Messages.ThrowPlayer(player,"You aren't in a condition to be remote controlling right now!")
		return
	}

	local localorg = Vector(0,0,0)
	if(target == "!picker")
	{
		target = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
		if(!target || target.HasDriver())
			return
		
		local clsname = target.GetClassname()
		if(clsname.find("physics") == null && clsname.find("prop_car_alarm") == null)
			return

		local coll = target.GetNetProp("m_Collision")
		local mx = coll.x < coll.y ? ( coll.z < coll.x ? coll.z : coll.x) : ( coll.z < coll.y ? coll.z : coll.y)
		coll = Vector(mx,mx,coll.z)
		local bbox = coll + player.GetNetProp("m_Collision")
		localorg = RotatePosition(Vector(0,0,0),QAngle(0,180,0),bbox).Scale(1.1);

		player.SetDrivenVehicle(target,"PS_RC_CAR_UNIQ",localorg)
	}
	else
	{
		target = Entity(target)
		if(!target || !target.IsEntityValid())
			return
	}
	
	if(target.GetParent() != null)
	{
		target.Input("clearparent","",0);
		target.Input("RunScriptCode","_dropit(Entity(self.GetEntityIndex()))",0.05);
	}

	local idx = player.GetIndex();
	AdminSystem.Vars.IsGodEnabled[idx] <- true;
	AdminSystem.Vars.IsNoclipEnabled[idx] <- false;
	AdminSystem.Vars.IsFreezeEnabled[idx] <- false;

	if(player.GetParent() != null)
	{
		player.Input("clearparent","",0);
		player.Input("RunScriptCode","_dropit(Player(self.GetEntityIndex()))",0.05);
	}
	
	player.Input("disableledgehang","")
	player.SetNetProp("m_flFrozen",1);
	player.SetMoveType(MOVETYPE_NONE);
	player.SetNetProp("m_fEffects",513)

	target.SetName(Constants.Targetnames.RCProp+player.GetIndex());
	
	target.SetNetProp("m_CollisionGroup",0)
	target.GetScriptScope()["PS_OWNER_ORIGIN"] <- localorg

	player.GetScriptScope()["PS_CG_BEFORE_RCPROP"] <- player.GetNetProp("m_CollisionGroup")
	player.SetNetProp("m_CollisionGroup",12)

	player.GetScriptScope()["PS_MC_BEFORE_RCPROP"] <- player.GetNetProp("m_MoveCollide")
	player.SetNetProp("m_MoveCollide",0)

	target.SetEFlags(EFL_IN_SKYBOX|EFL_HAS_PLAYER_CHILD)

	target.Push(player.GetPhysicsVelocity());
	
	player.SetVelocity(Vector(0,0,0))	
	target.GetScriptScope()["PS_RC_PROP_OWNER"] <- player;
	target.GetScriptScope()["PS_RC_PROP_ENABLED"] <- true;
	target.GetScriptScope()["WepBlock"] <- function()
	{
		local ch = self.GetScriptScope()["PS_RC_PROP_OWNER"];
		if(ch == null || !ch.IsEntityValid() || !self.GetScriptScope()["PS_RC_PROP_ENABLED"])
			return

		if(ch.GetNetProp("m_staggerDist").tostring() != "0")	// Staggered from hunter/charger/boomer
		{
			RecoverRagdollInitial(Entity(self.GetEntityIndex()));
			return;
		}

		ch = ch.GetBaseEntity()

		NetProps.SetPropFloat(ch,"m_TimeForceExternalView", Time()+1);
		NetProps.SetPropFloat(ch,"m_stunTimer.m_duration", 1);
		NetProps.SetPropFloat(ch,"m_stunTimer.m_timestamp", Time()+1);
		
		try
		{
			local w = ch.GetActiveWeapon();
			if (w != null && w.IsValid())
			{
				NetProps.SetPropFloat(w,"m_flNextPrimaryAttack", 99999);
				NetProps.SetPropFloat(w,"m_flNextSecondaryAttack", 99999);
			}
		}
		catch(e){}

		DoEntFire("!self","CallScriptFunction","WepBlock",0.06,null,self);
	}

	DoEntFire("!self","CallScriptFunction","WepBlock",0,null,target.GetBaseEntity());
	
	Printer(player,"Remote controlling prop #"+target.GetIndex());

	player.SetRenderMode(RENDER_NONE);
	
	::RCPropControls.Initialize(player,target)
}

::RCPropParams <-
{
	speed = 60
	friction = 0.3
	friction_dur = 0.2
}

::RCPropControls <-
{
	Initialize = function(player,rag)
	{
		::Quix.AddUnlimited(Constants.TimerNames.RCPropControl+player.GetIndex(),
							@(c,a) true,
							@(c,s,a) ::RCPropControls.Pusher(a.player,a.player.GetPressedButtons()),
							{player=player},
							{player=player});

	}

	Pusher = function(player,mask)
	{
		local name = player.GetCharacterNameLower();
		local speed = ::RCPropParams.speed;

		local target = player.GetDrivenVehicle()
		if(!target)
			return;

		player.SetOrigin(target.GetOrigin()+target.GetScriptScope()["PS_OWNER_ORIGIN"]);

		if(mask == 0)
			return;

		local eyeangles = player.GetEyeAngles()
		if(!eyeangles)
			return
            
		local fw = eyeangles.Forward()

		function IsPressing(mask,btn)
		{
			return (mask & btn) != 0
		}

		target.OverrideFriction(::RCPropParams.friction_dur,::RCPropParams.friction)

		if(IsPressing(mask,BUTTON_FORWARD))
		{
			target.Push(fw.Scale(speed))
		}
		if(IsPressing(mask,BUTTON_BACK))
		{
			target.Push(fw.Scale(-speed))
		}

		if(IsPressing(mask,BUTTON_MOVELEFT))
		{
			fw = (eyeangles + QAngle(0,90,0)).Forward()
			target.Push(fw.Scale(speed))
		}
		if(IsPressing(mask,BUTTON_MOVERIGHT))
		{
			fw = (eyeangles + QAngle(0,-90,0)).Forward()
			target.Push(fw.Scale(speed))
		}

		if(IsPressing(mask,BUTTON_ATTACK))
		{
			target.Push(Vector(0,0,speed))
		}
		if(IsPressing(mask,BUTTON_SHOVE))
		{
			target.Push(Vector(0,0,-speed))
		}
	}
}

::RecoverRCPropControlInitial <- function(target)
{
	local player = target.GetScriptScope()["PS_RC_PROP_OWNER"]
	if(player == null || !player.IsEntityValid())
		return;
	
	local eyeangles = player.GetEyeAngles()
	player.SetEyeAngles(eyeangles.x,eyeangles.y,0);

	::Quix.Remove(Constants.TimerNames.RCPropControl+player.GetIndex());

	player.SetNetProp("m_nSequence",0);
	player.SetNetProp("m_flCycle",0);
	player.SetNetProp("m_flFrozen",0);
	player.SetNetProp("m_fEffects",0)
	
	player.Input("enableledgehang","")
	AdminSystem.Vars.IsGodEnabled[player.GetIndex()] <- false;

	local v = target.GetPhysicsVelocity();

	local en = ::AdminSystem._GetEnumString(v.ToKVString()+"_"+target.GetOrigin().ToKVString());
	
	target.GetScriptScope()["PS_RC_PROP_ENABLED"] <- false;
	player.GetScriptScope()["PS_VEHICLE_VALID"] <- false
	if(player.GetScriptScope()["PS_VEHICLE_ENT"] != null && player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope() != null)
	{
		player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVE_ABILITY"] <- false
		player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVER"] <- false
		player.GetScriptScope()["PS_VEHICLE_ENT"] <- null
	}
	DoEntFire("!self","RunScriptCode","RecoverRagdollPost("+en+")",0.05,null,player.GetBaseEntity())
	player.SetNetProp("m_CollisionGroup",player.GetScriptScope()["PS_CG_BEFORE_RCPROP"])
	player.SetNetProp("m_MoveCollide",player.GetScriptScope()["PS_MC_BEFORE_RCPROP"])
}

::AdminSystem.LoadVehicles <- function(reload=false)
{
	local filelist = FileToString(Constants.Directories.CustomVehicle);	// List of files
	if(filelist == null)
	{
		printR("[Custom-Vehicle] Creating "+Constants.Directories.CustomVehicle+" for the first time...")
		StringToFile(Constants.Directories.CustomVehicle,strip(Constants.CustomVehicleListDefaults));
		filelist = FileToString(Constants.Directories.CustomVehicle);
	}

	local example = FileToString(Constants.Directories.CustomVehicleExample);	// Example v150
	if(example == null)
	{
		printR("[Vehicle-Examples] Creating v1.6.0 examples in "+Constants.Directories.CustomVehicleExample+" for the first time...")
		StringToFile(Constants.Directories.CustomVehicleExample,strip(Constants.CustomVehicleDefaults.v1_6_0));
		example = FileToString(Constants.Directories.CustomVehicleExample);
	}

	// Version based examples
	// foreach(vers,count in ::Constants.CustomBindsExampleVersions)
	// {	
	// 	local cleanvers = Utils.StringReplace(vers,@"\.","_");
	// 	local pth = Constants.Directories.CustomBindsExampleVersionBased(cleanvers)
	// 	local ex = FileToString(pth);
	// 	if(ex == null)
	// 	{
	// 		printR("[Binds-Examples] Creating "+count+" new examples from version "+vers+" in "+pth+" for the first time...")
	// 		StringToFile(pth,Constants.CustomBindsTableDefaults[cleanvers]);
	// 		ex = FileToString(pth);
	// 	}
	// }

	local filelist = split(filelist, "\r\n");
	
	foreach (i,filename in filelist)
	{	
		filename = strip(filename)

		if(filename.find("//") == 0)
			continue;
		else if(filename.find("//") != null)
		{
			filename = strip(split(filename,"//")[0])
		}

		filename = "admin system/vehicles/"+filename+".nut"
		local fileContents = FileToString(filename)
		if(fileContents == null)
		{
			continue;
		}
		fileContents = strip(fileContents);
		local tbl = ::Constants.ValidateVehicleTable(fileContents,filename,i==0,reload);

		if(typeof tbl == "table")
		{
			foreach(v_name,v_tbl in tbl)
			{
				local shortmdl = ShortenModelName(v_tbl.MDL)
				::CarTypes[v_name] <- shortmdl
				::DriveableCarModels[shortmdl] <- v_tbl
				::DriveParameters[shortmdl] <- v_tbl.parameters
        		::DefaultDriveableCarCollisionParameters(::DriveableCarModels[shortmdl])
			}
		}
	}
}

::AdminSystem.GetInAsPassenger <- function(player,args)
{
    local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
    if(!ent)
        return

	if(!ent.IsValidPassengerVehicle())
		return

	if(player.HasRagdollPresent())
		return;

	local entmdl = ShortenModelName(ent.GetModel())
	local p_org = DriveableCarModels[entmdl].driver_origin + Vector(0,-35,0)
	
	if(player.IsDriving())
	{
		::DriveMainFunctions.RemoveListeners(player)

		player.GetScriptScope()["PS_VEHICLE_VALID"] <- false
        if(player.GetScriptScope()["PS_VEHICLE_ENT"] != null && player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope() != null)
        {
            player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVE_ABILITY"] <- false
            player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVER"] <- false
            player.GetScriptScope()["PS_VEHICLE_ENT"] <- null
        }
	}
	
	if(!player.SetPassengerVehicle(ent))
		return
	
	local idx = player.GetIndex();
	AdminSystem.Vars.IsGodEnabled[idx] <- true;
	AdminSystem.Vars.IsNoclipEnabled[idx] <- false;
	AdminSystem.Vars.IsFreezeEnabled[idx] <- false;

	player.GetScriptScope()["PS_CG_BEFORE_PASSENGER"] <- player.GetNetProp("m_CollisionGroup")
	player.SetNetProp("m_CollisionGroup",12)

	player.GetScriptScope()["PS_MC_BEFORE_PASSENGER"] <- player.GetNetProp("m_MoveCollide")
	player.SetNetProp("m_MoveCollide",0)

    player.SetMoveType(MOVETYPE_CUSTOM)

	player.SetNetProp("m_stunTimer.m_timestamp",Time()+99999)
	player.SetNetProp("m_stunTimer.m_duration",99999)

	player.SetVelocity(Vector(0,0,0))	
	
	if(ent.GetParent() != null)
	{
		ent.Input("clearparent","",0);
		ent.Input("RunScriptCode","_dropit(Entity(self.GetEntityIndex()))",0.05);
		player.Input("setparent","#"+ent.GetIndex(),0.1)
		player.Input("runscriptcode","self.SetLocalOrigin(Vector("+p_org.x+","+p_org.y+","+p_org.z+"))",0.15)
	}
	else
	{
		player.Input("setparent","#"+ent.GetIndex(),0)
		player.Input("runscriptcode","self.SetLocalOrigin(Vector("+p_org.x+","+p_org.y+","+p_org.z+"))",0.1)
	}
	player.Input("runscriptcode","self.SnapEyeAngles(QAngle(0,0,0))",0.2)
	player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"] <- p_org;

	::DriveMainFunctions.CreateListenersPassenger(player);
}

::AdminSystem.GetOutAsPassenger <- function(player,args)
{
	::GetOutAsPassenger(player)
}

::AdminSystem.ChangePassengerSeatPositionCmd <- function(player,args)
{
	if(player.IsPassenger())
	{
		local axis = GetArgument(1)
		if(!axis)
			return
		local units = GetArgument(2)
		if(!units)
			return
		units = units.tofloat()

		local p_v = player.GetPassengerVehicle()
		local entmdl = ShortenModelName(p_v.GetModel())
		if(!(entmdl in DriveableCarModels))
			return

		local dir = ::DriveParameters[entmdl].driving_direction
		switch(axis)
		{
			case "x":
				player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"] <- RotatePosition(Vector(0,0,0),dir,Vector(units,0,0)) + player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"]
				break
			case "y":
				player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"] <- RotatePosition(Vector(0,0,0),dir,Vector(0,units,0)) + player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"]
				break
			case "z":
				player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"] <- RotatePosition(Vector(0,0,0),dir,Vector(0,0,units)) + player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"]
				break
		}
	}
}

::AdminSystem.StopDriveCmd <- function(player,args)
{
	if(!player.IsDriving() || player.IsDrivingRCProp())
		return

	::DriveMainFunctions.RemoveListeners(player)

	::DriveMainFunctions.RestoreDriver(player)

}

::AdminSystem.StartDriveCmd <- function(player,args)
{
	if(player.IsDriving() || player.IsPassenger())
		return

	if(::DriverStateCheck(player))
	{
		Messages.ThrowPlayer(player,"You aren't in a condition to be driving right now!")
		return
	}

	local car = GetArgument(1)

	if(!car)
		car = "props_vehicles/cara_95sedan"
	
	car = ShortenModelName(car)

	if(car in ::CarTypes)
		car = ::CarTypes[car]

	local new_car = !(car in DriveableCarModels)
	if(!(car in DriveParameters))
	{
		::DriveParameters[car] <- ::DefaultDrivingParameters()
	}
	if(new_car)
	{
		::DriveableCarModels[car] <-
		{
			MDL = FixShortModelName(car)
			driver_origin = Vector(0,0,0)
			getting_out_point = Vector(0,0,0)
		}
		::DefaultDriveableCarCollisionParameters(::DriveableCarModels[car])
	}

	local tbl = ::DriveMainFunctions.CreateVehicle(player,car)
	if(tbl == null)
	{
		Messages.ThrowPlayer(player,CmdMessages.Prop.Failed("physics"+"("+car+")"));
	}

	local parentent = tbl.parentent
	local createdent = tbl.createdent
	
	local bbox = parentent.GetNetProp("m_Collision")

	if(!("driver_origin" in ::DriveableCarModels[car]) || new_car)
		::DriveableCarModels[car].driver_origin <- Vector(0,0,2.0-bbox.z)

	if(!("getting_out_point" in ::DriveableCarModels[car]) || new_car)
		::DriveableCarModels[car].getting_out_point <- bbox 
	
	::PreparePlayerForDriving(player,parentent,car)

	Printer(player,CmdMessages.Prop.SuccessParented("vehicle entity",createdent));
}

::AdminSystem.ChangeDriveDirectionCmd <- function(player,args)
{
	if(!player.IsDriving() || player.IsDrivingRCProp())
		return

	local dirs =
	{
		straight = getconsttable()["DRIVE_DIRECTION_STRAIGHT"]
		reversed = getconsttable()["DRIVE_DIRECTION_REVERSED"]
		left = getconsttable()["DRIVE_DIRECTION_LEFT"]
		right = getconsttable()["DRIVE_DIRECTION_RIGHT"]
	}
	local direction = GetArgument(1)
	if(!(direction in dirs))
	{
		::Printer(player,"Available directions: straight, reversed, left, right")
		return
	}

	::DriveParameters[player.GetDrivenVehicleType()].driving_direction = dirs[direction]
	::AdminSystem.out("Driving direction of "+TXTCLR.BG(player.GetDrivenVehicleType())+" vehicles are now set to: "+TXTCLR.OG(direction))
}

::AdminSystem.ChangeSeatPositionCmd <- function(player,args)
{
	if(!player.IsDriving())
		return

	local axis = GetArgument(1)
	if(!axis)
		return
	local units = GetArgument(2)
	if(!units)
		return
	units = units.tofloat()
	if(player.IsDrivingRCProp())
	{	
		local dir = player.GetEyeAngles()
		local target = player.GetDrivenVehicle()
		switch(axis)
		{
			case "x":
				target.GetScriptScope()["PS_OWNER_ORIGIN"] = RotatePosition(Vector(0,0,0),dir,Vector(units,0,0)) + target.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
			case "y":
				target.GetScriptScope()["PS_OWNER_ORIGIN"] = RotatePosition(Vector(0,0,0),dir,Vector(0,units,0)) + target.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
			case "z":
				target.GetScriptScope()["PS_OWNER_ORIGIN"] = RotatePosition(Vector(0,0,0),dir,Vector(0,0,units)) + target.GetScriptScope()["PS_OWNER_ORIGIN"]
				break
		}
	}
	else
	{
		local dir = ::DriveParameters[player.GetDrivenVehicleType()].driving_direction
		switch(axis)
		{
			case "x":
				player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"] = RotatePosition(Vector(0,0,0),dir,Vector(units,0,0)) + player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"]
				break
			case "y":
				player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"] = RotatePosition(Vector(0,0,0),dir,Vector(0,units,0)) + player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"]
				break
			case "z":
				player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"] = RotatePosition(Vector(0,0,0),dir,Vector(0,0,units)) + player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"]
				break
		}
	}
}

::AdminSystem.SetDefaultSeatPositionCmd <- function(player,args)
{
	if(!player.IsDriving() || player.IsDrivingRCProp())
		return

	::DriveableCarModels[player.GetDrivenVehicleType()].driver_origin = player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"]
	::AdminSystem.out("Driver origin of "+TXTCLR.BG(player.GetDrivenVehicleType())+" vehicles are now set to "+TXTCLR.OG(player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"].ToKVString()))
}

::AdminSystem.MakeDriveableCmd <- function(player,args)
{
	local vehicle = ::ValidateDrivableEntity(player.GetLookingEntity(GRAB_YEET_TRACE_MASK))
	if(typeof vehicle == "string" || vehicle)
	{
		::Timers.AddTimer(0.5,false,::MakeDriveableWrapper,{player=player,vehicle=vehicle})
		return
	}
}

::AdminSystem._GetHexString <- function(str)
{
	local lookuptbl = {}
	local s = ""
	foreach(name,tbl in ::EasyLogic.Escapes)
	{
		lookuptbl[tbl.i] <- tbl.pattern.slice(1,5)
	}
	for(local c=0;c<str.len();c++)
	{
		if(str[c] in lookuptbl)
		{
			s += lookuptbl[str[c]]
		}
		else
		{
			s += str[c].tochar()
		}
	}
	return s;
}

::AdminSystem._GetEnumString <- function(str)
{
	if(str == null)
		return
	local temp = ["0","1","2","3","4","5","6","7","8","9",",","="," ","-","+","_",";",".","^","$","<",">","!","?",":","(",")","[","]","/","\\","@","\""] // "
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
				case ".":
				{
					ch = "p";
					break;
				}
				case "-":
				{
					ch = "d";
					break;
				}
				case "+":
				{
					ch = "add";
					break;
				}
				case "@":
				{
					ch = "at";
					break;
				}
				case "\"": // "
				{
					ch = "q";
					break;
				}
				case "\\":
				{
					ch = "bs";
					break;
				}
				case "/":
				{
					ch = "fs";
					break;
				}
				case "]":
				{
					ch = "sbe";
					break;
				}
				case "[":
				{
					ch = "sbs";
					break;
				}
				case ")":
				{
					ch = "rbe";
					break;
				}
				case "(":
				{
					ch = "rbs";
					break;
				}
				case ":":
				{
					ch = "col";
					break;
				}
				case "?":
				{
					ch = "qm";
					break;
				}
				case "!":
				{
					ch = "em";
					break;
				}
				case ">":
				{
					ch = "gt";
					break;
				}
				case "<":
				{
					ch = "lt";
					break;
				}
				case "$":
				{
					ch = "usd";
					break;
				}
				case "^":
				{
					ch = "xor";
					break;
				}
				case "|":
				{
					ch = "or";
					break;
				}
				case "&":
				{
					ch = "and";
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
	_p = "."
	_c = ","
	_sc = ";"
	_e = "="
	_q = "\"" // "
	_s = " "
	_u = "_"
	_d = "-"
	_add = "+"
	_and = "&"
	_or = "|"
	_xor = "^"
	_usd = "$"
	_lt = "<"
	_gt = ">"
	_em = "!"
	_qm	= "?"
	_col = ":"
	_rbs = "("
	_rbe = ")"
	_sbs = "["
	_sbe = "]"
	_fs = "/"
	_bs = "\\" 
	_at = "@"
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
				Printer(player,varname+" is an "+"\x04"+"array:\n"+Utils.ArrayString(val));
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
					Printer(player,varname+" is an"+"\x04"+"array:\n"+Utils.ArrayString(AdminSystem.Vars[varname]));
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
	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(val == null)
	{
		return
	}

	if(!(setting in AdminSystem._meteor_shower_args))
	{
		::SpellChecker.Levenshtein(5,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem._meteor_shower_args)
		return;
	}
	
	if(setting != "meteormodelspecific")
	{
		try{val = val.tofloat();}catch(e){return;}
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
		local unluckyone = Utils.GetRandValueFromArray(::Players.AliveSurvivors());
		
		if(unluckyone == null)
		{
			return;
		}
		local metargs = AdminSystem._meteor_shower_args;

		::Timers.AddTimer(metargs.mindelay+rand()%metargs.maxdelay, false, _MeteorShower,unluckyone);
	}
	else
	{
		if (Constants.TimerNames.MeteorShower in ::Timers.TimersID)
		{
			::Timers.RemoveTimer(::Timers.TimersID[Constants.TimerNames.MeteorShower]);
			delete ::Timers.TimersID[Constants.TimerNames.MeteorShower];
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
	
	// Spawn base and ceiling calculations
	local ceiling = _FindRandomValidCeilingPoint(surv,metargs.minspawnheight,metargs.maxradius)
	if(ceiling == null)
		return;

	// Create the meteor
	local meteor = _CreateAndPushMeteor(metargs.meteormodelpick,ceiling,minspeed,(metargs.maxspeed - minspeed),true)
	if(meteor == null)
	{
		return;
	}
	
	if((rand().tofloat()/RAND_MAX) < metargs.expprob)
	{
		_AttachExplosionEffects(meteor,ceiling,expdmgmin,(metargs.expdmgmax - expdmgmin),metargs.expmaxradius)
		_AttachDamageOutput(meteor,"RunScriptCode","_MeteorExplosion("+meteor.GetIndex()+")",0,1)
	}

	meteor.AttachParticle("gas_explosion_smoking",maxexplosiondelay-1,null)
	Timers.AddTimer(maxexplosiondelay,false,_MeteorPost,{meteor=meteor,maxexplosiondelay=maxexplosiondelay})
}
::_MeteorPost <- function(args)
{
	if(args.meteor.IsEntityValid())
	{
		args.meteor.Input("Kill","");
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
	if(entmodel == null)
		return;
	local clsname = RagdollOrPhysicsDecider(entmodel);
	local keyvals = 
	{
		targetname = "meteorspawn"
		classname = clsname
		model = entmodel
		origin = ceiling
		angles = QAngle(0,0,0)
		massScale = 10
	}

	local meteor = Utils.CreateEntityWithTable(keyvals);
	if(clsname == "prop_ragdoll")
	{
		meteor.AttachParticle("env_fire_large_smoke",5,ceiling+Vector(0,0,-50))
		meteor.SetNetProp("m_CollisionGroup",2)
	}
	else
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
	local explosion_sound = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = spawnpos});

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
	local meteor = Ent("#"+met)
	meteor.SetVelocity(Vector(0,0,0))

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
				break;
			}
			case "info_particle_system":
			{
				prtc = Ent("#"+child.GetEntityIndex());
				break;
			}
			case "env_explosion":
			{
				explosion = Ent("#"+child.GetEntityIndex());
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

	if(prtc != null && prtc.IsValid())	
		DoEntFire("!self", "Stop", "", 0.0, null, prtc);
}

function Notifications::OnBrokeProp::_DropLootOnBreak(player, prop, params)
{
	if(prop.IsLootable())
	{
		local lparams = ::AdminSystem.Vars.LootCreationParams

		local count = prop.GetScriptScope().PS_LOOT_ItemCount

		local event_state = lparams.events_enabled
		local porg = prop.GetOrigin()
		if(count != 0)
		{	
			local orgs = []
			local fw = Vector(0,prop.GetForwardVector().Scale(lparams.SpawnDist).y,0)
			for(local i=0;i<count;i++)
			{
				orgs.append(porg + RotatePosition(porg,QAngle(0,i*30),fw) + Vector(0,0,7))
			}

			foreach(obj in Objects.AroundRadius(porg,lparams.SpawnDist+15))
			{
				obj.GetScriptScope()["PS_Random_Tracked"] <- true
			}

			local loots = ::VSLib.RandomItemSpawner(orgs,::AdminSystem.LootSourcesLootTables)
			local spawns = loots.SpawnRandomItems(count)

			local enttbl = {}

			local total = spawns.len()
			
			if(total != count)
			{
				foreach(obj in Objects.AroundRadius(porg,lparams.SpawnDist+15))
				{
					if(obj.GetParent() != null || obj.GetName().find("random_spawned_item") != null || ("PS_Random_Tracked" in obj.GetScriptScope() && obj.GetScriptScope()["PS_Random_Tracked"]) )
						continue
						
					obj.GetScriptScope()["PS_Random_Tracked"] <- true
					spawns.append(obj)
				}
				total = spawns.len()
			}

			if(total == 1)
			{
				local clsn = spawns[0].GetClassname()
				if(clsn == "weapon_melee_spawn")
				{
					local emdl = spawns[0].GetModel()
					local i = emdl.find("models/weapons/melee/")
					if(i != null)
						clsn = emdl.slice(21,emdl.find(".mdl"))
				}
                if(player)
                {
                    if(player.IsBot())
                        ::Messages.InformAll(TXTCLR.OG(player.GetCharacterName())+" found a "+TXTCLR.OR(clsn)+"!")
                    else
                        ::Printer(player,"Found a "+TXTCLR.OR(clsn)+"!")
                }
                else
                {
                    ::Messages.InformAll("A "+TXTCLR.OR(clsn)+" was dropped from a prop!")
                }
			}
			else
			{
				for(local i=0;i<total;i++)
				{
					local e = spawns[i]
					local clsn = e.GetClassname()
					if(clsn == "weapon_melee_spawn")
					{
						local emdl = e.GetModel()
						local i = emdl.find("models/weapons/melee/")
						if(i != null)
							clsn = emdl.slice(21,emdl.find(".mdl"))
					}
					_dropit(e)
					if(clsn in enttbl)
						enttbl[clsn]++
					else
						enttbl[clsn] <- 1 
				}
				local st = "" 
				foreach(_clsname,_count in enttbl)
				{
					st += TXTCLR.OR(_clsname) + "(" + TXTCLR.BG("x" + _count) + ") "
				}
                if(player)
                {
                    if(player.IsBot())
                        ::Messages.InformAll(TXTCLR.OG(player.GetCharacterName())+" found "+TXTCLR.OR(total)+" items! "+st)
                    else
                        ::Printer(player,"Found "+TXTCLR.OR(total)+" items! "+st)
                }
                else
                {
                    ::Messages.InformAll(TXTCLR.OR(total)+" items dropped from a prop! "+st)
                }
			}
		}
		else if(player && !player.IsBot())
			::Printer(player,"No items found!")

		if(event_state)
		{
			local ambush_prob = lparams.ambush_prob
			local horde_prob = lparams.horde_prob
			local hurt_prob = lparams.hurt_prob
			local explosion_prob = lparams.explosion_prob

			local events = 
			{
				"ambush" : ambush_prob
				"horde" : horde_prob
				"hurt" : hurt_prob
				"explosion" : explosion_prob
			}

			foreach(e_name,e_prob in events)
			{
				local rnd = rand().tofloat()/RAND_MAX
				if(rnd <= e_prob)
				{
					::TriggerLootRandomEvent(prop,player,e_name)
				}
			}
		}

		prop.Input("SetGlowRange","1")
		prop.Input("StopGlowing","")
		prop.SetName(prop.GetScriptScope()["PS_OldName"])
		prop.GetScriptScope()["PS_LootPlaced"] <- false
		prop.GetScriptScope()["PS_CurrentPointUseEntity"] <- null
	}
}

::AdminSystem.LootCategories <-
{
	cars =
	{
		forbidden_patterns =
		{
			"models/props_vehicles/carparts" : true
			"models/props_vehicles/police_car_lightbar.mdl" : true
			"glass.mdl" : true
			"glass_alarm.mdl" : true
			"windows.mdl" : true
			"outro.mdl" : true
			"collision.mdl" : true
		}
		path_patterns =
		{
			"models/props_vehicles/police_car_city.mdl" : true
			"models/props_vehicles/police_car.mdl" : true
			"models/props_vehicles/police_car_opentrunk.mdl" : true
			"models/props_vehicles/police_car_rural.mdl" : true
			"models/props_vehicles/car" : true
			"models/props_vehicles/taxi" : true
			"models/props_vehicles/racecar.mdl" : true
			"models/props_vehicles/racecar_damaged.mdl" : true
			"models/props_vehicles/pickup_truck" : true
			"models/props_vehicles/truck" : true
			"models/props_vehicles/semi" : true
			"models/props_vehicles/pickup_dually.mdl" : true
			"models/props_vehicles/pickup_4x4.mdl" : true
			"models/props_vehicles/pickup_regcab.mdl" : true
			"models/props_vehicles/flatnose" : true
			"models/props_vehicles/airport_baggage_cart2.mdl" : true
		}
	}
	
	boxes =
	{
		forbidden_patterns =
		{
		}
		path_patterns =
		{
			"models/props_urban/oil_drum001.mdl" : true
			"models/props_urban/pontoon_drum001.mdl" : true
			"models/props_interiors/bookcase_48_96.mdl" : true
			"models/props_interiors/bookcase_64_96.mdl" : true
			"models/props_interiors/bookcasehutch01.mdl" : true
			"models/props/cs_office/bookshelf2.mdl" : true
			"models/props_urban/ashtray_stand001.mdl" : true
			"models/props/cs_assault/box_stack" : true
			"models/props/cs_assault/washer_box.mdl" : true
			"models/props/cs_militia/boxes_frontroom.mdl" : true
			"models/props/cs_militia/boxes_garage_lower.mdl" : true
			"models/props/cs_militia/mailbox01.mdl" : true
			"models/props/cs_office/cardboard_box0" : true
			"models/props/cs_office/file_box.mdl" : true
			"models/props/cs_office/paperbox_pile_01.mdl" : true
			"models/props_junk/cardboard_box0" : true
			"models/props_street/mail_dropbox.mdl" : true
			"models/props_unique/spawn_apartment/boxes_rooftop.mdl" : true
			"models/props_misc/bodybag_0" : true
			"models/props_street/garbage_can" : true
			"models/props_urban/garbage_can00" : true
			"models/props/cs_office/trash_can.mdl" : true
			"models/props/cs_office/trash_can_p.mdl" : true
			"models/props/de_prodigy/ammo_can_0" : true
			"models/props_interiors/trashcan" : true
			"models/props_junk/trashbin" : true
			"models/props_junk/trashcluster01a.mdl" : true
			"models/props_junk/trashdumpster01a.mdl" : true
			"models/props_street/trashbin01.mdl" : true
			"models/props_unique/airport/trash_bin1.mdl" : true
			"models/props_junk/dumpster" : true
			"models/props_junk/metal_paintcan001" : true
			"models/props_trainstation/trashcan_indoor001b.mdl" : true
			"models/props/cs_office/shelves_metal1.mdl" : true
			"models/props/cs_office/shelves_metal2.mdl" : true
			"models/props/cs_office/shelves_metal3.mdl" : true
			"models/props/cs_militia/crate_extralargemill.mdl" : true
			"models/props/de_nuke/crate_small.mdl" : true
			"models/props_crates/static_crate_40.mdl" : true
			"models/props_crates/supply_crate01.mdl" : true
			"models/props_crates/supply_crate02.mdl" : true
			"models/props_junk/wood_crate001a.mdl" : true
			"models/props_junk/wood_crate002a.mdl" : true
			"models/props_equipment/toolchest_01.mdl" : true
			"models/props_urban/plastic_icechest00" : true
			"models/props_debris/paintbucket01" : true
			"models/props_junk/metalbucket0" : true
			"models/props_junk/pooh_bucket_01.mdl" : true
			"models/props_urban/plastic_bucket001.mdl" : true
			"models/props_unique/mopbucket01.mdl" : true
		}
	}
}

::MakeEntityLootable <- function(args)
{
	local obj = args.ent
	local forbidden = args.forbidden
	local allowed = args.allowed
	local mdl = args.mdl
			
	if(obj.IsLootable() || Utils.TableKeyFindSearch(forbidden,mdl) || !Utils.TableKeyFindSearch(allowed,mdl) )
		return
	
	if(obj.HasDrivingAbility() || obj.HasDriver() || obj.HasPassenger())
	{
		return;
	}

	local sc = obj.GetScriptScope()

	sc["PS_OldName"] <- obj.GetName()
	obj.SetName(obj.GetName()+"project_smok_loot"+UniqueString())
	sc["PS_LootPlaced"] <- true
	
	local keyvals = 
	{
		classname = "point_script_use_target",
		model = obj.GetName(), 
		origin = Vector(0,0,0)
	};

	local params = ::AdminSystem.Vars.LootCreationParams
	local duration = params.LootDuration
	if(duration <= 0)
		duration = 1

	local pscr = Utils.CreateEntityWithTable(keyvals,null,false);

	if(!pscr)
	{
		obj.SetName(sc["PS_OldName"])
		sc["PS_LootPlaced"] <- false
		return
	}
	
	local b = pscr.GetBaseEntity()
	local bsrc = pscr.GetScriptScope()
	
	sc["PS_LOOT_ItemCount"] <- rand().tofloat()/RAND_MAX < params.NoItemProb ? 0 : RandomInt(params.MinItems,params.MaxItems)

	bsrc["Duration"] <- duration
	bsrc["FinishLoot"] <- function()
	{
		if(!("LastPlayer" in self.GetScriptScope()))
			return;

		local p = self.GetScriptScope().LastPlayer
		if(p.IsDriving() || p.IsPassenger() || p.HasRagdollPresent())
		{
			::Messages.ThrowPlayer(p,"You can't loot while driving or ragdolling!")
			return;
		}

		self.CanShowBuildPanel( false );

		local lparams = ::AdminSystem.Vars.LootCreationParams

		local c = ::VSLib.Entity(self.GetUseModelName())
		local count = c.GetScriptScope().PS_LOOT_ItemCount

		local event_state = lparams.events_enabled
		local porg = p.GetOrigin()
		if(count != 0)
		{	
			local orgs = []
			local fw = Vector(0,p.GetForwardVector().Scale(lparams.SpawnDist).y,0)
			for(local i=0;i<count;i++)
			{
				orgs.append(porg + RotatePosition(porg,QAngle(0,i*30),fw) + Vector(0,0,7))
			}

			foreach(obj in Objects.AroundRadius(porg,lparams.SpawnDist+15))
			{
				obj.GetScriptScope()["PS_Random_Tracked"] <- true
			}

			local loots = ::VSLib.RandomItemSpawner(orgs,::AdminSystem.LootSourcesLootTables)
			local spawns = loots.SpawnRandomItems(count)

			local enttbl = {}

			local total = spawns.len()
			
			if(total != count)
			{
				foreach(obj in Objects.AroundRadius(porg,lparams.SpawnDist+15))
				{
					if(obj.GetParent() != null || obj.GetName().find("random_spawned_item") != null || ("PS_Random_Tracked" in obj.GetScriptScope() && obj.GetScriptScope()["PS_Random_Tracked"]) )
						continue
						
					obj.GetScriptScope()["PS_Random_Tracked"] <- true
					spawns.append(obj)
				}
				total = spawns.len()
			}

			if(total == 1)
			{
				local clsn = spawns[0].GetClassname()
				if(clsn == "weapon_melee_spawn")
				{
					local emdl = spawns[0].GetModel()
					local i = emdl.find("models/weapons/melee/")
					if(i != null)
						clsn = emdl.slice(21,emdl.find(".mdl"))
				}
				::Printer(p,"Found a "+TXTCLR.OR(clsn)+"!")
			}
			else
			{
				for(local i=0;i<total;i++)
				{
					local e = spawns[i]
					local clsn = e.GetClassname()
					if(clsn == "weapon_melee_spawn")
					{
						local emdl = e.GetModel()
						local i = emdl.find("models/weapons/melee/")
						if(i != null)
							clsn = emdl.slice(21,emdl.find(".mdl"))
					}
					_dropit(e)
					if(clsn in enttbl)
						enttbl[clsn]++
					else
						enttbl[clsn] <- 1 
				}
				local st = "" 
				foreach(_clsname,_count in enttbl)
				{
					st += TXTCLR.OR(_clsname) + "(" + TXTCLR.BG("x" + _count) + ") "
				}
				::Printer(p,"Found "+TXTCLR.OR(total)+" items! "+st)
			}
		}
		else
			::Printer(p,"No items found!")

		if(event_state)
		{
			local ambush_prob = lparams.ambush_prob
			local horde_prob = lparams.horde_prob
			local hurt_prob = lparams.hurt_prob
			local explosion_prob = lparams.explosion_prob

			local events = 
			{
				"ambush" : ambush_prob
				"horde" : horde_prob
				"hurt" : hurt_prob
				"explosion" : explosion_prob
			}

			foreach(e_name,e_prob in events)
			{
				local rnd = rand().tofloat()/RAND_MAX
				if(rnd <= e_prob)
				{
					::TriggerLootRandomEvent(c,p,e_name)
				}
			}
		}

		c.Input("SetGlowRange","1")
		c.Input("StopGlowing","")
		c.SetName(c.GetScriptScope()["PS_OldName"])
		c.GetScriptScope()["PS_LootPlaced"] <- false
		c.GetScriptScope()["PS_CurrentPointUseEntity"] <- null
		DoEntFire("!self","kill","",0,null,self)
	}
	bsrc["Started"] <- function()
	{
		local user = self.GetScriptScope().PlayerUsingMe
		local player = null
		if(user == 0)
			self.StopUse()
		else
		{
			while( player = Entities.FindByClassname( player, "player" ))
			{
				if( player.GetEntityHandle() == user )
				{
					local p = ::VSLib.Player(player)
					if(p.IsDriving() || p.IsPassenger() || p.HasRagdollPresent())
					{
						::Messages.ThrowPlayer(p,"You can't loot while driving or ragdolling!")
						self.StopUse()
						return;
					}
					if(::VSLib.Entity(self.GetUseModelName()).GetParent() != null)
					{
						::Messages.ThrowPlayer(p,"You can't loot a prop that's being grabbed by someone!")
						self.StopUse()
						return;
					}
					self.GetScriptScope()["LastPlayer"] <- p
					return
				}
			}
		}
	}

	b.CanShowBuildPanel(true)
	b.SetProgressBarText(params.BarText)
	b.SetProgressBarSubText(params.BarSubText)
	
	b.SetProgressBarFinishTime(duration)

	b.ConnectOutput("OnUseStarted","Started")
	pscr.Input("AddOutput","OnUseFinished !self,CallScriptFunction,FinishLoot,0,1")
	obj.SetGlowColor(params.GlowR,params.GlowG,params.GlowB,params.GlowA)
	obj.Input("SetGlowRange",params.GlowRange.tostring())
	obj.Input("StartGlowing","")

	sc["PS_CurrentPointUseEntity"] <- pscr
}

::LootingRandomEventParams <-
{
	blood_splatter =
	[
		"screen_blood_splatter",
		"screen_blood_splatter_a",
		"screen_blood_splatter_b",
		"screen_blood_splatter_melee",
		"screen_blood_splatter_melee_b",
		"screen_blood_splatter_melee_blunt"
	]
	screen_blood_min = 4
	screen_blood_max = 7

	blood_spill =
	[
		"blood_bleedout",
		"blood_bleedout_3"
	]
	ground_blood_min = 3
	ground_blood_max = 6

	expradius = 120
	pushspeed = 350
	expdmg_min = 10
	expdmg_max = 20

	cut_count_min = 1
	cut_count_max = 8
	cut_dmg_min = 3
	cut_dmg_max = 5

	horde_alarm_sound = "c5m2.Security_alarm"
	horde_alarm_sound_length = 9
}

::BackUpExplosionSoundScriptNames <- 
[
	"explode_1",
	"explode_2",
	"explode_3",
	"BaseGrenade.Explode"
]

::BackUpPianoKeySoundScriptNames <- 
[
	"Piano.TwangHit0",
	"Piano.TwangHit1",
	"Piano.TwangHit2",
	"Piano.TwangHit3"
]

::GetExplosionSoundScriptName <- function()
{
	return ::IsCurrentMapAnOfficialMap() ? "randomexplosion" : Utils.GetRandValueFromArray(::BackUpExplosionSoundScriptNames)
}

::GetPianoKeySoundScriptName <- function()
{
	return Utils.GetRandValueFromArray(::BackUpPianoKeySoundScriptNames)
}

::IsCurrentMapAnOfficialMap <- function()
{
	switch(SessionState.MapName)
	{
		case "c1m1_hotel":
		case "c1m2_streets":
		case "c1m3_mall":
		case "c1m4_atrium":

		case "c2m1_highway":
		case "c2m2_fairgrounds":
		case "c2m3_coaster":
		case "c2m4_barns":
		case "c2m5_concert":

		case "c3m1_plankcountry":
		case "c3m2_swamp":
		case "c3m3_shantytown":
		case "c3m4_plantation":

		case "c4m1_milltown_a":
		case "c4m2_sugarmill_a":
		case "c4m3_sugarmill_b":
		case "c4m4_milltown_b":
		case "c4m5_milltown_escape":

		case "c5m1_waterfront":
		case "c5m1_waterfront_sndscape":
		case "c5m2_park":
		case "c5m3_cemetery":
		case "c5m4_quarter":
		case "c5m5_bridge":

		case "c6m1_riverbank":
		case "c6m2_bedlam":
		case "c6m3_port":
		
		case "c7m1_docks":
		case "c7m2_barge":
		case "c7m3_port":

		case "c8m1_apartment":
		case "c8m2_subway":
		case "c8m3_sewers":
		case "c8m4_interior":
		case "c8m5_rooftop":

		case "c9m1_alleys":
		case "c9m2_lots":

		case "c10m1_caves":
		case "c10m2_drainage":
		case "c10m3_ranchhouse":
		case "c10m4_mainstreet":
		case "c10m5_houseboat":

		case "c11m1_greenhouse":
		case "c11m2_offices":
		case "c11m3_garage":
		case "c11m4_terminal":
		case "c11m5_runway":

		case "c12m1_hilltop":
		case "c12m2_traintunnel":
		case "c12m3_bridge":
		case "c12m4_barn":
		case "c12m5_cornfield":

		case "c13m1_alpinecreek":
		case "c13m2_southpinestream":
		case "c13m3_memorialbridge":
		case "c13m4_cutthroatcreek":

		case "c14m1_junkyard":
		case "c14m2_lighthouse":
		{
			return true;
		}
	}
	return false;
}

::TriggerLootRandomEvent <- function(loot_ent,looter,event_name)
{
	if(!loot_ent.IsEntityValid())
		return;
	switch(event_name)
	{
		case "explosion":
		{
			local rad = ::LootingRandomEventParams.expradius
			local l_org = loot_ent.GetOrigin()
			local expent = Utils.CreateEntityWithTable({classname = "env_explosion", spawnflags = 0, origin = l_org, iRadiusOverride = rad });
			local expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = l_org});
			
			_explosionPush({ents=_RemoveNonPhysicsFromTable(Objects.AroundRadius(l_org,rad),l_org,rad),pushspeed=::LootingRandomEventParams.pushspeed,origin=l_org,explosion=expent,explosion_sound=expsoundent})
			
            foreach (idx, ent in Objects.AroundRadius(l_org, rad))
            {
                if (ent.GetClassname() == "player")
                {
                    ent.Damage(RandomInt(::LootingRandomEventParams.expdmg_min,::LootingRandomEventParams.expdmg_max))
                }
            }
			if(looter)
			{
				if(!looter.IsBot())
					::Printer(looter,"Somebody really didn't want this one to be looted...")
				else
					::Messages.InformAll(TXTCLR.OG(looter.GetCharacterName())+" triggered an "+TXTCLR.OR("explosive trap")+" while looting!")
			}
			else
			{
				::Messages.InformAll("An "+TXTCLR.OR("explosive trap")+" was triggered during looting!")
			}
			break;
		}
		case "hurt":
		{
			if(!looter)
				return;

			local count = RandomInt(::LootingRandomEventParams.cut_count_min,::LootingRandomEventParams.cut_count_max)
			for(local i=0;i<count;i++)
			{
				Timers.AddTimer(0.1+(i*1.4),false,@(...) looter.Damage(RandomInt(::LootingRandomEventParams.cut_dmg_min,::LootingRandomEventParams.cut_dmg_max)))
			}
			if(!looter.IsBot())
				::Printer(looter,"You cut yourself!")
			else
				::Messages.InformAll(looter.GetCharacterName()+" "+TXTCLR.OR("cut")+" themselves while breaking a prop!")
			break;
		}
		case "horde":
		{
			local snd = LootingRandomEventParams.horde_alarm_sound
			Utils.SpawnZombie( Z_MOB, loot_ent.GetOrigin() );
            local keyvaltable = 
            {	
                classname = "info_target"
                origin = loot_ent.GetOrigin()
                spawnflags = 0
            }
            local soundtemp = Utils.CreateEntityWithTable(keyvaltable);
            soundtemp.SetName("PS_TEMP_LOOT_HORDE_SOUND_"+UniqueString())
            soundtemp.EmitSound(snd)
            soundtemp.Input("RunScriptCode","Entity("+soundtemp.GetIndex()+").StopSound(\""+snd+"\")",::LootingRandomEventParams.horde_alarm_sound_length)   
            soundtemp.Input("Kill","",::LootingRandomEventParams.horde_alarm_sound_length+3.0);
			
			if(looter)
			{
				if(!looter.IsBot())
					::Printer(looter,"Uh oh...")
				else
					::Messages.InformAll(looter.GetCharacterName()+" triggered an "+TXTCLR.OR("alarm")+" while looting!")
			}
			else
			{
				::Messages.InformAll("An "+TXTCLR.OR("alarm")+" was triggered during looting!")
			}
			break;
		}
		case "ambush":
		{
			local typ = Utils.GetRandValueFromArray([Z_JOCKEY,Z_HUNTER])
			Utils.SpawnZombie( typ, loot_ent.GetEyePosition() );

			if(looter)
			{
				if(!looter.IsBot())
					::Printer(looter,"It's a trap!")
				else
					::Messages.InformAll(looter.GetCharacterName()+" triggered a "+TXTCLR.OR((typ == Z_JOCKEY ? "jockey" : "hunter"))+" ambush while looting!")
			}
			else
			{
				::Messages.InformAll("A "+TXTCLR.OR((typ == Z_JOCKEY ? "jockey" : "hunter"))+" was triggered during looting!")
			}
			break;
		}
	}
}

/* 
 * @authors rhino
 */
::AdminSystem.CreateLootSourcesCmd <- function (player,args)
{
	if(!::LongProcessIterAvailability.create_loot_sources)
	{
		Printer(player,"You can't use this command while a create_loot_sources process is still running!")
		return
	}

	local category = GetArgument(1)
	local forbidden = {}
	local allowed = {}

	if(!category || category.tolower() == "all")
	{
		::LongProcessIterAvailability.create_loot_sources = false
		category = "all"
		foreach(tbl in ::AdminSystem.LootCategories)
		{
			Utils.ExtendTable(forbidden,tbl.forbidden_patterns)
			Utils.ExtendTable(allowed,tbl.path_patterns)
		}
	}
	else if(category in ::AdminSystem.LootCategories)
	{
		::LongProcessIterAvailability.create_loot_sources = false
		Utils.ExtendTable(forbidden,::AdminSystem.LootCategories[category].forbidden_patterns)
		Utils.ExtendTable(allowed,::AdminSystem.LootCategories[category].path_patterns)
	}
	else if(category == "!picker")
	{
		local looked = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
		if(!looked)
			return

		local mdl = looked.GetModel()
		local cls = looked.GetClassname()
		if(mdl.find("*") != null)
			return;

		if(cls == "player" || cls == "infected" || cls.find("weapon") != null || cls.find("door") != null)
			return;

		::MakeEntityLootable({ent=looked,forbidden={},allowed={mdl=mdl},mdl=mdl})
		return
	}
	else
	{
		Printer(player,"Unknown category. Current available categories: "+TXTCLR.OG("all")+", "+TXTCLR.OG("cars")+", "+TXTCLR.OG("boxes"),"error")
		return
	}

	local i = 0
	local maxproc = 50
	local maxiter = 150

	local objs = Utils.TableToArray(Objects.All())
	
	local all_len = objs.len()
	local last_index = 0
	local keepiter = false
	
	foreach(idx, ent in objs)
	{
		last_index = idx
		if(idx >= maxiter)
		{
			keepiter = true
			break;
		}

		local mdl = ent.GetModel()
		if(!mdl || mdl == "" || mdl.find("*") != null)
			continue

		i += 1
		if(i > maxproc)
		{
			keepiter = true
			break;
		}

		::MakeEntityLootable({ent=ent,forbidden=forbidden,allowed=allowed,mdl=mdl})
	}

	if(last_index != all_len-1)
	{
		objs = objs.slice(last_index)
	}
	if(keepiter)
	{
		Timers.AddTimer(0.4,false,DoMakeLootIter,{total=all_len,left=objs.len(),objs=objs,forbidden=forbidden,allowed=allowed})
	}
	else
	{	
		::LongProcessIterAvailability.create_loot_sources = true
		::AdminSystem.out("Loot-Source Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
	}
}

::DoMakeLootIter <- function(args={})
{
	::AdminSystem.out("Loot-Source Progress: "+Utils.BuildProgressBar(20.0,((args.total-args.left).tofloat()/args.total.tofloat())*20.0,20.0,"|", ". "))
	local i = 0
	local maxproc = 50
	local maxiter = 150

	local objs = args.objs
	local forbidden = args.forbidden
	local allowed = args.allowed
	
	local all_len = objs.len()
	local last_index = 0
	local keepiter = false

	if(all_len == 0)
	{	
		::LongProcessIterAvailability.create_loot_sources = true
		::AdminSystem.out("Loot-Source Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
		return;
	}

	foreach(idx, ent in objs)
	{
		last_index = idx
		if(idx >= maxiter)
		{
			keepiter = true
			break;
		}

		local mdl = ent.GetModel()
		if(!mdl || mdl == "" || mdl.find("*") != null)
			continue

		i += 1
		if(i > maxproc)
		{
			keepiter = true
			break;
		}

		::MakeEntityLootable({ent=ent,forbidden=forbidden,allowed=allowed,mdl=mdl})
	}
	
	if(last_index != all_len-1)
	{
		objs = objs.slice(last_index)
	}
	if(keepiter)
	{
		Timers.AddTimer(0.4,false,::DoMakeLootIter,{total=args.total,left=objs.len(),objs=objs,forbidden=forbidden,allowed=allowed})
	}
	else
	{	
		::LongProcessIterAvailability.create_loot_sources = true
		::AdminSystem.out("Loot-Source Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
	}
}

/* 
 * @authors rhino
 */
::AdminSystem.Show_loot_settingsCmd <- function (player,args)
{
	
	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Looting Settings:");
		foreach(setting,val in AdminSystem.Vars.LootCreationParams)
		{
			Messages.InformPlayer(player,"\x05"+setting+"\x03"+" -> "+"\x04"+val.tostring()+"\x01"+"\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem.Vars.LootCreationParams)
		{
			printB(player.GetCharacterName(),"[Looting-Setting] "+setting+"->"+val.tostring(),false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}

/* 
 * @authors rhino
 */
::AdminSystem.Loot_settingCmd <- function (player,args)
{
	
	local name = player.GetCharacterName();
	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(val == null)
		return

	if(!(setting in AdminSystem.Vars.LootCreationParams))
	{
		::SpellChecker.Levenshtein(3,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem.Vars.LootCreationParams)
		return;
	}
	
	Printer(player,CmdMessages.Looting.SettingSuccess(setting,AdminSystem.Vars.LootCreationParams[setting],val));

	switch(setting)
	{
		case "BarSubText":
		case "BarText":
			break;
		case "events_enabled":
			val = (val == "true" || val == "True") ? true : false
			break
		default:
			val = val.tofloat()
	}
	AdminSystem.Vars.LootCreationParams[setting] = val;
}

/* @authors rhino
 * Start the meteor shower
 */
::AdminSystem.Start_the_showerCmd <- function (player,args)
{
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
	Messages.WarnPlayer(player,"Meteor shower debugging has been deprecated since v.1.7.3")
	return 
}

/* @authors rhino
 * Start the ghost zombies event
 */
::AdminSystem.StartGhostZombiesCmd <- function (player,args)
{
	if(AdminSystem.Vars._ghost_zombies_state == 0)
	{	
		AdminSystem.LoadGhostZombiesSettings();
		ClientPrint(null,3,"\x04"+Utils.GetRandValueFromArray(CmdMessages.GhostZombiesSettings.StartingMessages));
		AdminSystem.Vars._ghost_zombies_state = 1;
		::VSLib.Timers.AddTimerByName(Constants.TimerNames.GhostZombies,AdminSystem._ghost_zombies.timer_delay, true, _GhostZombiesTimer,{});	
	}
	else
	{	
		AdminSystem.SaveGhostZombiesSettings();
		AdminSystem.PauseGhostZombiesCmd(player,args);
	}
}

/* @authors rhino
 * Pauses the ghost zombies event
 */
::AdminSystem.PauseGhostZombiesCmd <- function (player,args)
{
	if(AdminSystem.Vars._ghost_zombies_state == 1)
	{
		AdminSystem.Vars._ghost_zombies_state = 0;
	}
}

/* @authors rhino
 * Show ghost zombies params
 */
::AdminSystem.ShowGhostZombiesSettingsCmd <- function (player,args)
{
	AdminSystem.LoadGhostZombiesSettings();
	local comments = Constants.GetGhostZombiesSettingsComments();

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterNameLower()])
	{
		Messages.InformPlayer(player,"Ghost zombies settings:");
		foreach(setting,val in AdminSystem._ghost_zombies)
		{
			Messages.InformPlayer(player,"\x05"+setting+"\x03"+" -> "+"\x04"+val.tostring()+"\x01"+" ("+comments[setting]+")\n")
		}
	}
	else
	{
		printB(player.GetCharacterName(),"",false,"",true,false);
		foreach(setting,val in AdminSystem._ghost_zombies)
		{
			printB(player.GetCharacterName(),"[Ghost_Zombies-Setting] "+setting+" ----> "+val.tostring()+" ----> "+comments[setting],false,"",false,false)
		}
		printB(player.GetCharacterName(),"",false,"",false,true,0.1);
	}
}
/*
 * @authors rhino
 */
::AdminSystem.GhostZombiesSettingCmd <- function (player,args)
{
	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(!(setting in AdminSystem._ghost_zombies))
	{
		::SpellChecker.Levenshtein(5,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem._ghost_zombies)
		return;
	}
	
	try{val = val.tofloat();}catch(e){return;}

	local name = player.GetCharacterName();

	Messages.InformAll(CmdMessages.GhostZombiesSettings.Success(name,setting,AdminSystem._ghost_zombies[setting],val));
	
	AdminSystem._ghost_zombies[setting] = val;
	AdminSystem.SaveGhostZombiesSettings();
}

/*
 * @authors rhino
 * Default ghost zombies event settings
 */

::AdminSystem._ghost_zombies <- Constants.GetGhostZombiesSettingsDefaults()

/*
 * @authors rhino
 * Execute each ghost zombies tick
 */
::_GhostZombiesTimer <- function (...)
{	
	if(AdminSystem.Vars._ghost_zombies_state == 1)
	{	
		_GhostZombiesTick()
	}
	else
	{
		if(::Constants.TimerNames.GhostZombies in Timers.TimersID)
		{
			Timers.RemoveTimer(Timers.TimersID[::Constants.TimerNames.GhostZombies])
			delete Timers.TimersID[::Constants.TimerNames.GhostZombies]
		}
		local keeping = ::AdminSystem._ghost_zombies.stay_ghost_after == 1
		local typ = ::AdminSystem._ghost_zombies.zombie_pick_type.tointeger()
		if(!keeping)
		{
			if(typ%2 == 1)
			{
				foreach(ent in Objects.OfClassname("infected"))
				{
					ent.Input("alpha","255")
					ent.SetRenderEffects(0)
				}
			}
			if((typ>>1)%2 == 1)
			{
				foreach(ent in Objects.OfClassname("player"))
				{
					if(ent.GetTeam() != INFECTED)
						continue;

					ent.Input("alpha","255")
					ent.SetRenderEffects(0)
				}
			}
		}

		ClientPrint(null,3,"\x03"+ (keeping ? CmdMessages.GhostZombiesSettings.EndingKept : CmdMessages.GhostZombiesSettings.EndingNoKept) );
	}

}

/*
 * @authors rhino
 * Ghostifier
 */
::_GhostZombiesTick <-function(...)
{
	local typ = ::AdminSystem._ghost_zombies.zombie_pick_type.tointeger()
	if(typ%2 == 1)
	{
		foreach(ent in Objects.OfClassname("infected"))
		{	
			if(rand().tofloat()/RAND_MAX > ::AdminSystem._ghost_zombies.ghost_prob)
				continue
			ent.Input("alpha",RandomInt(::AdminSystem._ghost_zombies.min_alpha,::AdminSystem._ghost_zombies.max_alpha))
			ent.SetRenderEffects(::AdminSystem._ghost_zombies.render_effect)
		}
	}
	if((typ>>1)%2 == 1)
	{
		foreach(ent in Objects.OfClassname("player"))
		{
			if(ent.GetTeam() != INFECTED)
				continue;
					
			if(rand().tofloat()/RAND_MAX > ::AdminSystem._ghost_zombies.ghost_prob)
				continue
			ent.Input("alpha",RandomInt(::AdminSystem._ghost_zombies.min_alpha,::AdminSystem._ghost_zombies.max_alpha))
			ent.SetRenderEffects(::AdminSystem._ghost_zombies.render_effect)
		}
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
				case "prop_physics_override":
				case "prop_car_alarm":
				case "prop_vehicle":
				case "prop_ragdoll":
				case "simple_physics_prop":
				case "prop_fuel_barrel":
				case "func_physbox":
				case "func_physbox_multiplayer":
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
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = ent.GetOrigin()});
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
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = ent.GetOrigin()});
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
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = ent.GetOrigin()});
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
							expsoundent = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = ent.GetOrigin()});
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

/* @authors rhino
 * monkaOMEGA
 */
::AdminSystem.Start_the_apocalypseCmd <- function (player,args)
{
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
	if(AdminSystem.Vars._propageddon_state == 1)
	{
		AdminSystem.Vars._propageddon_state = 0;
	}
}

/* @authors rhino
 * Change how hellish you want the experience to be
 */
::AdminSystem.Apocalypse_settingCmd <- function (player,args)
{
	local setting = GetArgument(1);
	local val = GetArgument(2);
	if(!(setting in AdminSystem._propageddon_args))
	{
		::SpellChecker.Levenshtein(5,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem._propageddon_args)
		return;
	}
	
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

::AdminSystem._propageddon_args <- Constants.GetApocalypseSettingsDefaults()

/* @authors rhino
 * Change debug message reporting state of the apocalypse
 */
::AdminSystem.Apocalypse_debugCmd <- function (player,args)
{
	Messages.WarnPlayer(player,"Apocalypse event debugging has been deprecated since v.1.7.3")
	return 
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

	local character = GetArgument(1);
	if(character==null)
	{return;}

	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

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
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

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

	local character = GetArgument(1);
	if(character==null)
	{character = player.GetCharacterName();}
	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

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
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}
	
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
			{
				Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
				::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
				return;
			}

			if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
			{
				Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character))
				return;
			}

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
			{
				Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
				::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
				return;
			}

			if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
			{
				Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character))
				return;
			}
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
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

	local steamid = player.GetSteamID();

	if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoneFound(character));return;
	}

	if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
	{
		Messages.ThrowPlayer(player,CmdMessages.CustomSequences.NoSeqFound(character,sequencename));return;
	}
	local str = "";
	str += "\nscenes:\n"
	str += Utils.ArrayString(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes)
	str += "\ndelays:\n"
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
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

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
		foreach(admin,val in AdminSystem.UserLevels)
		{
			if(val > PS_USER_BASIC)
				contents += "\n\t\""+admin+"\":\n\t{\n\t\t\"character_name\":\n\t\t{\n\t\t\t\"sequence_name\":\n\t\t\t{\n\t\t\t\t\"scenes\":[\"blank\"],\n\t\t\t\t\"delays\":[0]\n\t\t\t}\n\t\t}\n\t}"; 
		}
		contents += "\n}";
		StringToFile(Constants.Directories.CustomResponses, contents);
	}

	local responsetable = compilestring( "local __tempvar__ = " + contents + "\r\n;return __tempvar__")();
	
	// Check admins
	foreach(admin,val in AdminSystem.UserLevels)
	{	
		if(!(admin in responsetable) && (Utils.GetIDFromArray(::UserLevelNames,val) != -1) && (getconsttable()[val] > PS_USER_BASIC))
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
	
	local character = GetArgument(1);
	if(character==null)
	{return;}
	character = character.tolower();
	
	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{
		Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(character));
		::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),character,Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
		return;
	}

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
	
	local rnum = rand().tofloat()/RAND_MAX
	//::AdminSystem.out(rnum)
	// Add timer to ignore changes during map loading
	if(AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.call_amount == 0
		&& "_inSafeRoom" in ::VSLib.EasyLogic.Cache[ent.GetIndex()] && !::VSLib.EasyLogic.Cache[ent.GetIndex()]._inSafeRoom
		&& "_inSafeSpot" in ::VSLib.EasyLogic.Cache[ent.GetIndex()]
		&& rnum <= AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.prob)
	{
		::VSLib.Timers.AddTimer(0.1, false, _SpeakWhenLeftSaferoomMid, {player=ent,name=name});
	}
	return;
}

::_SpeakWhenLeftSaferoomMid <- function(ent_table)
{
	if(::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()]._inSafeSpot == 0)
		::VSLib.Timers.AddTimer(AdminSystem.Vars._CustomResponse[ent_table.name]._SpeakWhenLeftSaferoom.startdelay, false, _SpeakWhenLeftSaferoomResult, ent_table);
}
/*
 * @authors rhino
 */
::_SpeakWhenLeftSaferoomResult <- function(ent_table)
{
	if(AdminSystem.Vars._CustomResponse[ent_table.name]._SpeakWhenLeftSaferoom.call_amount == 0
		&& "_inSafeRoom" in ::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()] && !::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()]._inSafeRoom
		&& "_inSafeSpot" in ::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()] && ::VSLib.EasyLogic.Cache[ent_table.player.GetIndex()]._inSafeSpot == 0)
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

// Ragdoll
/*
 * @authors rhino
 */
::RagdollStateCheck <- function(player)
{
	return ::VSLib.EasyLogic.NextMapContinues
			|| player.IsIncapacitated()
			|| !player.IsAlive() 
			|| player.IsDead() 
			|| player.IsDying() 
			|| player.IsHangingFromLedge() 
			|| player.IsHealing()
			|| player.IsDriving()
			|| player.IsPassenger()
			//|| player.IsBeingHealed()
			|| player.IsHangingFromTongue() 
			|| player.IsBeingJockeyed() 
			|| player.IsPounceVictim() 
			|| player.IsTongueVictim() 
			|| player.IsCarryVictim() 
			|| player.IsPummelVictim() 
			|| (player.GetIndex() in ::VSLib.EasyLogic.Cache 
				&& "_curAttker" in ::VSLib.EasyLogic.Cache[player.GetIndex()] 
				&& ::VSLib.EasyLogic.Cache[player.GetIndex()]._curAttker != null)
}

function Notifications::OnMapEnd::_RecoverRagdolls()
{
	foreach(obj in Objects.All())
	{
		if(obj.GetName().find(Constants.Targetnames.Ragdoll) != null)
		{
			RecoverRagdollInitial(obj);
		}
	}
}
function Notifications::OnIncapacitatedStart::_RecoverRagdolls(victim,attacker,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
function Notifications::OnDeath::_RecoverRagdolls(victim,attacker,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
//smoker
function Notifications::OnSmokerTongueGrab::_RecoverRagdolls(smoker,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
function Notifications::OnSmokerChokeBegin::_RecoverRagdolls(smoker,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
//hunter
function Notifications::OnHunterPouncedVictim::_RecoverRagdolls(hunter,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
//jockey
function Notifications::OnJockeyRideStart::_RecoverRagdolls(jockey,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
//charger
function Notifications::OnChargerCarryVictim::_RecoverRagdolls(charger,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
function Notifications::OnChargerImpact::_RecoverRagdolls(charger,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
function Notifications::OnChargerPummelBegin::_RecoverRagdolls(charger,victim,args)
{
	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}
function Notifications::OnChargerChargeEnd::_RecoverRagdolls(charger,args)
{
	local victim = ::VSLib.EasyLogic.GetEventPlayer(args, "victim");
	if(victim == null)
		return;

	local rag = victim.GetRagdollEntity()
	if(!rag)
		return;
	
	RecoverRagdollInitial(rag);
}

// Vehicles
/*
 * @authors rhino
 */
::DriverStateCheck <- function(player)
{
	return ::VSLib.EasyLogic.NextMapContinues
			|| player.IsIncapacitated()
			|| !player.IsAlive() 
			|| player.IsDead() 
			|| player.IsDying() 
			|| player.IsHangingFromLedge() 
			|| player.HasRagdollPresent()
			|| player.IsHealing() 
			//|| player.IsBeingHealed()
			|| player.IsHangingFromTongue() 
			|| player.IsBeingJockeyed() 
			|| player.IsPounceVictim()
			|| player.IsTongueVictim() 
			|| player.IsCarryVictim() 
			|| player.IsPummelVictim() 
			|| (player.GetIndex() in ::VSLib.EasyLogic.Cache 
				&& "_curAttker" in ::VSLib.EasyLogic.Cache[player.GetIndex()] 
				&& ::VSLib.EasyLogic.Cache[player.GetIndex()]._curAttker != null)
}

function Notifications::OnBotReplacedPlayer::_GetOutOfTheVehicle(player,bot,args)
{
	::GetOutAsPassenger(player)

	if(!player.IsDriving())
		return

	if(player.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(player.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(player)

		::DriveMainFunctions.RestoreDriver(player)
	}
}

function Notifications::OnPlayerConnected::_GetOutOfTheVehicle(player,args)
{
	::GetOutAsPassenger(player)
	
	if(!player.IsDriving())
		return
		
	if(player.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(player.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(player)

		::DriveMainFunctions.RestoreDriver(player)
	}
}

function Notifications::OnMapEnd::_GetOutOfTheVehicle()
{
	foreach(obj in Players.AliveSurvivors())
	{
		::GetOutAsPassenger(obj)

		if(!obj.IsDriving())
			continue

		if(obj.IsDrivingRCProp())
		{
			::RecoverRCPropControlInitial(obj.GetDrivenVehicle());
		}
		else
		{
			::DriveMainFunctions.RemoveListeners(obj)

			::DriveMainFunctions.RestoreDriver(obj)
		}
	}
}
function Notifications::OnIncapacitatedStart::_GetOutOfTheVehicle(victim,attacker,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
function Notifications::OnDeath::_GetOutOfTheVehicle(victim,attacker,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
//smoker
function Notifications::OnSmokerTongueGrab::_GetOutOfTheVehicle(smoker,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
function Notifications::OnSmokerChokeBegin::_GetOutOfTheVehicle(smoker,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
//hunter
function Notifications::OnHunterPouncedVictim::_GetOutOfTheVehicle(hunter,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
//jockey
function Notifications::OnJockeyRideStart::_GetOutOfTheVehicle(jockey,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
//charger
function Notifications::OnChargerCarryVictim::_GetOutOfTheVehicle(charger,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
function Notifications::OnChargerImpact::_GetOutOfTheVehicle(charger,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
function Notifications::OnChargerPummelBegin::_GetOutOfTheVehicle(charger,victim,args)
{
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
function Notifications::OnChargerChargeEnd::_GetOutOfTheVehicle(charger,args)
{
	local victim = ::VSLib.EasyLogic.GetEventPlayer(args, "victim");
	if(victim == null)
		return;
		
	::GetOutAsPassenger(victim)
	
	if(!victim.IsDriving())
		return

	if(victim.IsDrivingRCProp())
	{
		::RecoverRCPropControlInitial(victim.GetDrivenVehicle());
	}
	else
	{
		::DriveMainFunctions.RemoveListeners(victim)

		::DriveMainFunctions.RestoreDriver(victim)
	}
}
// Perma pitch
/*
 * @authors rhino
 */
function Notifications::OnBotReplacedPlayer::ResetPermaPitch(player,bot,args)
{
	local timername = "PS_PERMA_PITCH_SHIFT_"+player.GetCharacterNameLower()
	if(timername in ::Quix.Table)
	{
		::Quix.Remove(timername);
	}

	local s = player.GetBaseEntity().GetCurrentScene()
	if(s!=null)		
		DoEntFire("!self","PitchShift","1",0,null,s)
}

function Notifications::OnDeath::ResetPermaPitch(victim,attacker,args)
{
	if(!victim.IsSurvivor())
		return
	victim = Player(victim.GetIndex())
	local timername = "PS_PERMA_PITCH_SHIFT_"+victim.GetCharacterNameLower()
	if(timername in ::Quix.Table)
	{
		::Quix.Remove(timername);
	}
}

// Model restoration
/*
 * @authors rhino
 */
function Notifications::OnMapEnd::_RestoreModels()
{
	Utils.ResetModels(null,false);
}

function Notifications::OnPlayerConnected::RestoreModels(player,args)
{
	if(!::VSLib.EasyLogic.NextMapContinues)
		AdminSystem.RestoreModels(player);
}

// TANK ROCKS
/*
 * @authors rhino
 */
function Notifications::OnHurt::_HitByTankRock(player,attacker,args)
{
	if(!("weapon" in args))
		return;
	if(args.weapon != "tank_rock")
		return;
	else if(AdminSystem.Vars._RockThrow.pushenabled)
	{
		if(::VSLib.EasyLogic.Objects.OfClassname("tank_rock").len() != 1)
		{	// TO-DO: Maybe add origin kv to name and get it from there ?
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
		Timers.AddTimer(AdminSystem.Vars._RockThrow.modelchangedelay,false,_findAndChangeRock,{});
		AdminSystem.Vars._RockThrow.rockorigin = player.GetOrigin()+Vector(0,0,AdminSystem.Vars._RockThrow.rockspawnheight);
	}
}

::_findAndChangeRock <- function(args)
{
	switch(AdminSystem.Vars._RockThrow.modelpick)
	{	// TO-DO: Enumerate
		case 0:
		{
			if(AdminSystem.Vars._RockThrow.randomized)
			{
				foreach( rock in ::VSLib.EasyLogic.Objects.OfClassname("tank_rock") )
				{
					if(rock.GetName().find(Constants.Targetnames.TankRock) == null)
					{
						rock.SetName(rock.GetName()+Constants.Targetnames.TankRock);
						rock.SetModel(RandomPick(::ModelPaths.all));
						if(AdminSystem.Vars._RockThrow.spawn_prop_after)
						{
							Timers.AddTimer(0.1,false,_replaceRock,{rock=rock});
						}
					}
				}
			}
			break;
		}
		case 1:
		{
			foreach( rock in ::VSLib.EasyLogic.Objects.OfClassname("tank_rock") )
			{
				if(rock.GetName().find(Constants.Targetnames.TankRock) == null)
				{
					rock.SetName(rock.GetName()+Constants.Targetnames.TankRock);
					rock.SetModel(AdminSystem.Vars._RockThrow.modelspecific);
					if(AdminSystem.Vars._RockThrow.spawn_prop_after)
					{
						Timers.AddTimer(0.1,false,_replaceRock,{rock=rock});
					}
				}
			}
			break;
		}
		case 2:
		{	
			if(AdminSystem.Vars._RockThrow.custommodels.len() == 0)
				break;

			foreach( rock in ::VSLib.EasyLogic.Objects.OfClassname("tank_rock") )
			{
				if(rock.GetName().find(Constants.Targetnames.TankRock) == null)
				{
					rock.SetName(rock.GetName()+Constants.Targetnames.TankRock);
					rock.SetModel(RandomPick(AdminSystem.Vars._RockThrow.custommodels));
					if(AdminSystem.Vars._RockThrow.spawn_prop_after)
					{
						Timers.AddTimer(0.1,false,_replaceRock,{rock=rock});
					}
				}
			}
			break;
		}
		default:
			break;
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
		classname = RagdollOrPhysicsDecider(args.rock.GetModel()),
		model = args.rock.GetModel(),
		origin = args.rock.GetOrigin(),
		angles = args.rock.GetAngles(),
		massScale = AdminSystem.Vars._RockThrow.mass_scale
	};
	local velocity = args.rock.GetVelocity();
	args.rock.SetNetProp("m_CollisionGroup",1)
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
// TO-DO: Extend this for barrels etc
::RagdollOrPhysicsDecider <- function(mdl)
{
	local clsname = "prop_physics_multiplayer"

	foreach(m,_v in RagdollModelBans)
	{	
		if(mdl.find(m) != null)
			return clsname
	}

	if(mdl.find("models/survivors/") != null 
		|| mdl.find("models/infected/") != null 
		|| mdl.find("models/deadbodies/") != null)
	{
		clsname = "prop_ragdoll"
	}
	else
	{
		local rexp = regexp(@"\\(\w+)\.mdl");
		local res = rexp.capture(mdl);
		if(res != null)
		{
			foreach(i,m in res)
			{
				if(mdl.slice(m.begin,m.end) in AdminSystem.ZombieModels)
				{
					clsname = "prop_ragdoll"
					break;
				}

			}
		}
	}
	return clsname;
}
/*
 * @authors rhino
 */
/////////////////////place_holders/////////////////////////
function ChatTriggers::say( player, args, text )
{
}

function ChatTriggers::password( player, args, text )
{
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
//////////////////////ghost_zombies_event////////////////////////////

function ChatTriggers::ghost_zombies_setting( player, args, text )
{
	AdminSystem.GhostZombiesSettingCmd( player, args );
}
					
function ChatTriggers::show_ghost_zombies_settings( player, args, text )
{
	AdminSystem.ShowGhostZombiesSettingsCmd( player, args );
}

function ChatTriggers::start_ghost_zombies( player, args, text )
{
	AdminSystem.StartGhostZombiesCmd( player, args );
}

function ChatTriggers::pause_ghost_zombies( player, args, text )
{
	AdminSystem.PauseGhostZombiesCmd( player, args );
}
/*
 * @authors rhino
 */
///////////////////////script_related//////////////////////////////

function ChatTriggers::out( player, args, text )
{
	if(args.len() == 0)
		return;

	local res = compilestring("local __tempvar__="+Utils.CombineArray(args," ")+";return __tempvar__;")();
	::AdminSystem.out(res,player);
}

function ChatTriggers::enum_string( player, args, text )
{
	Printer(player,::AdminSystem._GetEnumString(strip(Utils.CombineArray(args))));
}

function ChatTriggers::hex_string( player, args, text )
{
	Printer(player,::AdminSystem._GetHexString(strip(Utils.CombineArray(args))));
}

function ChatTriggers::command_privilege( player, args, text )
{
	AdminSystem.ChangeCmdPrivileges(player, args);
}
function ChatTriggers::reload_command_privileges( player, args, text )
{
	AdminSystem.LoadCmdPrivileges();
}

function ChatTriggers::reload_vehicles( player, args, text )
{
	AdminSystem.LoadVehicles(true);
}

function ChatTriggers::create_alias( player, args, text )
{
	
	AdminSystem.CreateAliasCommandCmd(player,args,text);
}

function ChatTriggers::replace_alias( player, args, text )
{
	
	AdminSystem.ReplaceAliasCommandCmd(player,args,text);
}

function ChatTriggers::unbind( player, args, text )
{
	AdminSystem.UnbindWithQuixCmd(player,args);
}

function ChatTriggers::bind( player, args, text )
{
	AdminSystem.BindWithQuixCmd(player,args);
}

function ChatTriggers::reload_binds( player, args, text )
{
	AdminSystem.LoadQuixBinds(true);
}

function ChatTriggers::reload_ent_groups( player, args, text )
{
	AdminSystem.LoadEntityGroups(true);
}

function ChatTriggers::reload_loots( player, args, text )
{
	AdminSystem.LoadLootTables();
}


function ChatTriggers::reload_aliases( player, args, text )
{
	AdminSystem.LoadAliasedCommands(true);
}

function ChatTriggers::reload_scripts( player, args, text )
{
	AdminSystem.LoadCustomScripts();
}

function ChatTriggers::reload_hooks( player, args, text )
{
	AdminSystem.LoadCustomHooks();
}

function ChatTriggers::detach_hook( player, args, text )
{
	AdminSystem.DetachHook(player,args);
}

function ChatTriggers::attach_hook( player, args, text )
{
	AdminSystem.AttachHook(player,args);
}

function ChatTriggers::update_print_output_state(player,args,text)
{
	AdminSystem.Update_print_output_stateCmd(player, args);
}

function ChatTriggers::help(player,args,text)
{
	AdminSystem.HelpCmd(player, args);
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

function ChatTriggers::user_level( player, args, text )
{
	AdminSystem.ChangeUserLevelCmd( player, args );
}

function ChatTriggers::server_exec(player,args,text)
{
	AdminSystem.Server_execCmd(player, args);
}

function ChatTriggers::script( player, args, text )
{
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

function ChatTriggers::prop_spawn_setting(player,args,text)
{
	AdminSystem.Update_prop_spawn_settingCmd(player, args);
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

function ChatTriggers::set_animation( player, args, text )
{
	AdminSystem.SetAnimationCmd( player, args );
}

function ChatTriggers::random_animation( player, args, text )
{
	AdminSystem.RandomAnimationCmd( player, args );
}
					
function ChatTriggers::search_animation( player, args, text )
{
	AdminSystem.SearchAnimationCmd( player, args );
}

function ChatTriggers::random_phys_model( player, args, text )
{
	AdminSystem.RandomPhysModelCmd( player, args );
}

function ChatTriggers::random_model( player, args, text )
{
	AdminSystem.RandomModelCmd( player, args );
}

function ChatTriggers::search_model( player, args, text )
{
	AdminSystem.SearchModelCmd( player, args );
}
	
function ChatTriggers::rc_prop( player, args, text )
{
	AdminSystem.RemoteControlCmd( player, args );
}

function ChatTriggers::drive( player, args, text )
{
	AdminSystem.out(TXTCLR.OG("drive")+" command has been "+TXTCLR.OG("deprecated")+"! Use "+TXTCLR.BG("start_driving")+" and "+TXTCLR.BG("stop_driving")+" instead",player)
	AdminSystem.StartDriveCmd(player,args);
}

function ChatTriggers::start_driving( player, args, text )
{
	AdminSystem.StartDriveCmd( player, args );
}

function ChatTriggers::stop_driving( player, args, text )
{
	AdminSystem.StopDriveCmd( player, args );
}

function ChatTriggers::get_in( player, args, text )
{
	AdminSystem.GetInAsPassenger( player, args );
}

function ChatTriggers::get_out( player, args, text )
{
	AdminSystem.GetOutAsPassenger( player, args );
}

function ChatTriggers::change_passenger_seat_position( player, args, text )
{
	AdminSystem.ChangePassengerSeatPositionCmd( player, args );
}

function ChatTriggers::make_driveable( player, args, text )
{
	AdminSystem.MakeDriveableCmd( player, args );
}

function ChatTriggers::change_drive_direction( player, args, text )
{
	AdminSystem.ChangeDriveDirectionCmd( player, args );
}

function ChatTriggers::change_seat_position( player, args, text )
{
	AdminSystem.ChangeSeatPositionCmd( player, args );
}

function ChatTriggers::set_default_seat_position( player, args, text )
{
	AdminSystem.SetDefaultSeatPositionCmd( player, args );
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

function ChatTriggers::pitch( player, args, text )
{
	AdminSystem.PitchShiftCmd( player, args );
}


function ChatTriggers::perma_pitch( player, args, text )
{
	AdminSystem.PermaPitchShiftCmd( player, args );
}


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

function ChatTriggers::create_loot_sources( player, args, text )
{
	AdminSystem.CreateLootSourcesCmd( player, args );
}

function ChatTriggers::show_looting_settings( player, args, text )
{
	AdminSystem.Show_loot_settingsCmd( player, args );
}

function ChatTriggers::looting_setting( player, args, text )
{
	AdminSystem.Loot_settingCmd( player, args );
}

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
// Camera		
function ChatTriggers::switch_hud_element( player, args, text )
{
	AdminSystem.SwitchHudElement( player, args );
}
function ChatTriggers::selfie( player, args, text )
{
	AdminSystem.SelfieViewCmd( player, args );
}
function ChatTriggers::create_camera( player, args, text )
{
	AdminSystem.CreateCameraCmd( player, args );
}
function ChatTriggers::camera_setting( player, args, text )
{
	AdminSystem.CameraSettingCmd( player, args );
}
function ChatTriggers::change_camera( player, args, text )
{
	AdminSystem.ChangeCameraCmd( player, args );
}
function ChatTriggers::last_camera_info( player, args, text )
{
	AdminSystem.LastCameraInfoCmd( player, args );
}
//

function ChatTriggers::command_ban( player, args, text )
{
	AdminSystem.AddCommandBanCmd( player, args );
}

function ChatTriggers::command_unban( player, args, text )
{
	AdminSystem.RemoveCommandBanCmd( player, args );
}

function ChatTriggers::disable_command( player, args, text )
{
	AdminSystem.AddDisabledCommandCmd( player, args );
}

function ChatTriggers::enable_command( player, args, text )
{
	AdminSystem.RemoveDisabledCommandCmd( player, args );
}

function ChatTriggers::stop_car_alarms( player, args, text )
{
	AdminSystem.StopCarAlarmsCmd( player, args );
}
function ChatTriggers::remove_fall_cams( player, args, text )
{
	AdminSystem.RemoveFallCamsCmd( player, args );
}

function ChatTriggers::hurt_triggers( player, args, text )
{
	AdminSystem.HurtTriggersCmd( player, args );
}

function ChatTriggers::debug_info(player,args,text)
{
	AdminSystem.Debug_infoCmd(player, args);
}

function ChatTriggers::zero_g(player,args,text)
{
	AdminSystem.ZeroGCmd(player, args);
}

function ChatTriggers::stop_time( player, args, text )
{
	AdminSystem.StopTimeCmd( player, args );
}
function ChatTriggers::resume_time( player, args, text )
{
	AdminSystem.ResumeTimeCmd( player, args );
}
					
function ChatTriggers::wiki( player, args, text )
{
	AdminSystem.WikiCmd( player, args );
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

function ChatTriggers::flag_lookup( player, args, text )
{
	AdminSystem.FlagLookUpCmd( player, args );
}

function ChatTriggers::change_ragdoll_view( player, args, text )
{
	AdminSystem.ChangeRagdollViewPositionCmd( player, args );
}

function ChatTriggers::go_ragdoll( player, args, text )
{
	AdminSystem.GoRagdollCmd( player, args );
}
function ChatTriggers::recover_ragdoll( player, args, text )
{
	AdminSystem.RecoverRagdollCmd( player, args );
}

function ChatTriggers::give_physics( player, args, text )
{
	AdminSystem.GivePhysicsCmd( player, args );
}

function ChatTriggers::soda_can( player, args, text )
{
	AdminSystem.SodaCanCmd( player, args );
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

function ChatTriggers::random_decal( player, args, text )
{
	AdminSystem.RandomDecalCmd( player, args );
}

function ChatTriggers::search_decal( player, args, text )
{
	AdminSystem.SearchDecalCmd( player, args );
}

function ChatTriggers::decal( player, args, text )
{
	AdminSystem.DecalCmd( player, args );
}

function ChatTriggers::remove_lights( player, args, text )
{
	AdminSystem.RemoveLightsCmd( player, args );
}

function ChatTriggers::spawn_point_light( player, args, text )
{
	AdminSystem.SpawnPointLightCmd( player, args );
}

function ChatTriggers::point_light( player, args, text )
{
	AdminSystem.PointLightCmd( player, args );
}

function ChatTriggers::point_light_follow( player, args, text )
{
	AdminSystem.PointLightFollowCmd( player, args );
}

function ChatTriggers::particle( player, args, text )
{
	AdminSystem.ParticleCmd( player, args );
}
					
function ChatTriggers::random_particle( player, args, text )
{
	AdminSystem.RandomParticleCmd( player, args );
}
					
function ChatTriggers::search_particle( player, args, text )
{
	AdminSystem.SearchParticleCmd( player, args );
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

function ChatTriggers::spawn_model_saved( player, args, text )
{
	AdminSystem.Spawn_saved_modelCmd( player, args );
}
function ChatTriggers::display_saved_model( player, args, text )
{
	AdminSystem.Display_saved_modelCmd( player, args );
}
function ChatTriggers::random_model_save_state( player, args, text )
{
	AdminSystem.Randommodel_save_lastCmd( player, args );
}
function ChatTriggers::save_model( player, args, text )
{
	AdminSystem.Save_modelCmd( player, args );
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

function ChatTriggers::find_sound_in_scripts( player, args, text )
{
	AdminSystem.FindSoundInScriptsCmd( player, args );
}

function ChatTriggers::search_sound_script_name( player, args, text )
{
	AdminSystem.SearchSoundCmd( player, args );
}

function ChatTriggers::random_sound_script_name( player, args, text )
{
	AdminSystem.RandomSoundCmd( player, args );
}
					
function ChatTriggers::sound_script_info( player, args, text )
{
	AdminSystem.SoundInfoCmd( player, args );
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

foreach(cmdname,cmdtrigger in ::ChatTriggers)
{
	compilestring("::ChatTriggerDocs[\""+cmdname+"\"] <- @(player,args) \""+cmdname+"\" in CmdDocs ? Messages.DocCmdPlayer(player,CmdDocs[\""+cmdname+"\"](player,args)) : null")()
}

::AdminSystem.AdminModeCmd <- function ( player, args )
{
	Messages.WarnPlayer(player, "adminmode command has been deprecated! Use user_level and command_privilege commands to allow players use commands!");
}

::UserLevelUtils <-
{
	GetValidateChangeTarget = function(player, targetname)
	{
		local Target = Utils.GetPlayerFromName(GetArgument(1));
		
		if ( !Target )
			return false;

		if ( Target.IsBot() && Target.IsHumanSpectating() )
			Target = Target.GetHumanSpectator();
		
		if ( Target.HasPrivilege(PS_USER_HOST) )
		{
			if(!player.HasPrivilege(PS_USER_HOST))
				::Messages.ThrowPlayer(player,"Host's user level can't be changed!")
			return false
		}
		local steamid = Target.GetSteamID();
		if ( steamid == "BOT" )
			return false;
		return Target
	}

	ValidateLevel = function(player, lvlname, user = true, allow_alt = false)
	{
		if(Utils.GetIDFromArray(::UserLevelNames,lvlname) == -1)
		{
			local valid = false
			if(allow_alt)
			{
				switch(strip(lvlname.tolower()))
				{
					case "none":
						lvlname = "PS_USER_NONE";
						valid = true;
						break;
					case "basic": 
						lvlname = "PS_USER_BASIC";
						valid = true;
						break;
					case "admin": 
						lvlname = "PS_USER_ADMIN";
						valid = true;
						break;
					case "scripter": 
						lvlname = "PS_USER_SCRIPTER";
						valid = true;
						break;
					case "host": 
						lvlname = "PS_USER_HOST";
						valid = true;
						break;
				}
			}

			if(!valid)
			{
				::Printer(player,"Unknown user level: "+lvlname,"error");
				return false
			}
		}
		
		if(user && lvlname == "PS_USER_HOST")
		{
			if(!player.HasPrivilege(PS_USER_HOST))
				::Messages.ThrowPlayer(player,"Can't give host privilages to other players!")
			return false
		}
		return lvlname
	}

	Finalize = function(player, target, lvlname)
	{
		local levels = FileToString(Constants.Directories.UserLevels);
		if ( levels == null )
			return Messages.ThrowPlayer(player,"user_levels.txt doesn't exist, restart the chapter!!!");
		else
			levels = ChangeUserLevel(target, target.GetSteamID(), levels, lvlname)
		if(!levels)
		{
			::Messages.ThrowPlayer(player,"Failed to change user-level of "+target.GetName()+", check user_level.txt file format!");
			return
		}

		StringToFile(Constants.Directories.UserLevels, levels);
		AdminSystem.LoadUserLevels();

		if ( AdminSystem.DisplayMsgs )
			Messages.BIM.UserLevels.Changed(target.GetName(), lvlname);
	}
}
/*
 * @authors rhino
 */
::AdminSystem.ChangeUserLevelCmd <- function ( player, args )
{	
	local target, lvlname;
	if(!(target = ::UserLevelUtils.GetValidateChangeTarget(player, GetArgument(1)))
		|| !(lvlname = ::UserLevelUtils.ValidateLevel(player, GetArgument(2), false, true)))
		return

	::UserLevelUtils.Finalize(player, target, lvlname);
}

/*
 * @authors rhino
 */
::AdminSystem.AddScriptAuthCmd <- function ( player, args )
{	
	local target, lvlname;
	if(!(target = ::UserLevelUtils.GetValidateChangeTarget(player, GetArgument(1)))
		|| !(lvlname = ::UserLevelUtils.ValidateLevel(player, "PS_USER_SCRIPTER")))
		return

	::UserLevelUtils.Finalize(player, target, lvlname);

	::Printer(player,"Script auth commands are deprecated, use user_level command instead!","warning");
}

/*
 * @authors rhino
 */
::AdminSystem.RemoveScriptAuthCmd <- function ( player, args )
{
	::Printer(player,"Script auth commands are deprecated, use user_level command instead!","error");
}

/*
 * @authors rhino
 */
::AdminSystem.AddAdminCmd <- function ( player, args )
{
	local target, lvlname;
	if(!(target = ::UserLevelUtils.GetValidateChangeTarget(player, GetArgument(1)))
		|| !(lvlname = ::UserLevelUtils.ValidateLevel(player, "PS_USER_ADMIN")))
		return

	::UserLevelUtils.Finalize(player, target, lvlname);

	::Printer(player,"Admin add/remove commands are deprecated, use user_level command instead!","warning");
}

/*
 * @authors rhino
 */
::AdminSystem.RemoveAdminCmd <- function ( player, args )
{
	::Printer(player,"Admin add/remove commands are deprecated, use user_level command instead!","error");
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
	
	if ( player.HasPrivilege(PS_USER_ADMIN) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
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
	
	if ( player.HasPrivilege(PS_USER_ADMIN) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
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
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );

				if(survivor.HasRagdollPresent() || survivor.IsDriving() || survivor.IsPassenger())
					continue

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
			
			if(Target.HasRagdollPresent() || Target.IsDriving() || Target.IsPassenger())
				return

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
		if(player.HasRagdollPresent() || player.IsDriving() || player.IsPassenger())
			return

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

	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if(survivor.HasRagdollPresent() || survivor.IsDriving() || survivor.IsPassenger())
					continue

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
			
			if(Target.HasRagdollPresent() || Target.IsDriving() || Target.IsPassenger())
				return

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
		if(player.HasRagdollPresent() || player.IsDriving() || player.IsPassenger())
			return

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
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );

				if(survivor.HasRagdollPresent() || survivor.IsDriving() || survivor.IsPassenger())
					continue

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
			
			if(Target.HasRagdollPresent() || Target.IsDriving() || Target.IsPassenger())
				return

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
		if(player.HasRagdollPresent() || player.IsDriving() || player.IsPassenger())
			return

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
					::Quix.Remove(survivorID.tostring() + "Fly")
					survivor.Input( "IgnoreFallDamageWithoutReset", 0.1 );
					survivor.Input( "EnableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						Utils.PrintToAllDel("Flying mode has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- true;
					::Quix.AddListener(survivorID.tostring() + "Fly","!"+survivor.GetCharacterNameLower(),BUTTON_JUMP,@(p,tbl) AdminSystem.CalculateFly(p), PS_WHILE_PRESSED)
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
				::Quix.Remove(targetID.tostring() + "Fly")
				Target.Input( "IgnoreFallDamageWithoutReset", 0.1 );
				Target.Input( "EnableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					Utils.PrintToAllDel("Flying mode has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- true;
				::Quix.AddListener(targetID.tostring() + "Fly","!"+Target.GetCharacterNameLower(),BUTTON_JUMP,@(p,tbl) AdminSystem.CalculateFly(p), PS_WHILE_PRESSED)
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
			::Quix.Remove(ID.tostring() + "Fly")
			player.Input( "IgnoreFallDamageWithoutReset", 0.1 );
			player.Input( "EnableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				Utils.PrintToAllDel("%s has disabled flying mode.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- true;
			::Quix.AddListener(ID.tostring() + "Fly","!"+player.GetCharacterNameLower(),BUTTON_JUMP,@(p,tbl) AdminSystem.CalculateFly(p), PS_WHILE_PRESSED)
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
::AdminSystem.RemoveFallCamsCmd <- function ( player, args )
{
	
	local objects = Objects.OfClassname("point_deathfall_camera");
	if(objects.len() != 0)
	{
		foreach(obj in objects)
		{	
			obj.Input("Kill");
		}

		Printer(player,"Removed all death fall cameras");
	}
}

/*
 * @authors rhino
 */
::AdminSystem.HurtTriggersCmd <- function ( player, args )
{
	
	local state = GetArgument(1)
	switch(state)
	{
		case "enable":
		case "Enable":
		case "true":
		case "True":
		case "1":
			state = "Enable"
			break;
		default:
			state = "Disable"
			break;
	}
	local changedany = false

	local objects = Objects.OfClassname("trigger_hurt");
	if(!changedany && objects.len() > 0)
		changedany = true
	foreach(obj in objects)
	{	
		obj.Input(state);
	}

	objects = Objects.OfClassname("point_hurt");
	if(!changedany && objects.len() > 0)
		changedany = true
	foreach(obj in objects)
	{	
		obj.Input(state);
	}

	objects = Objects.OfClassname("trigger_hurt_ghost");
	if(!changedany && objects.len() > 0)
		changedany = true
	foreach(obj in objects)
	{	
		obj.Input(state);
	}

	if(changedany)
		Printer(player,state+"d all hurt triggers");
}

/*
 * @authors rhino
 */
::AdminSystem.CleanupCmd <- function ( player, args )
{
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
	local exp = regexp(@"_\d+(?:_our_particles|_Admin|_singlesimple|_meteorspawn|_spawnedspeaker|_spawnedmic|_vslib_tmp_)")

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
	EyePosition.z += 2;
	g_ModeScript.SpawnMeleeWeapon( Melee, EyePosition, Vector(0,0,90) );
}

::AnimationModelMaps <- 
{
	"survivors/survivor_gambler" : "survivors/anim_gambler"
	"survivors/survivor_mechanic" : "survivors/anim_mechanic"
	"survivors/survivor_coach" : "survivors/anim_coach"
	"survivors/survivor_producer" : "survivors/anim_producer"
	"survivors/survivor_teenangst" : "survivors/anim_teenangst"
	"survivors/survivor_namvet" : "survivors/anim_namvet"
	"survivors/survivor_biker" : "survivors/anim_biker"
	"infected/hunter" : "infected/anim_hunter"
	"infected/hunter_l4d1" : "infected/anim_hunter"
	"infected/boomer" : "infected/anim_boomer"
	"infected/smoker" : "infected/anim_smoker"
	"infected/charger" : "infected/anim_charger"
	"infected/spitter" : "infected/anim_spitter"
	"infected/jockey" : "infected/anim_jockey"
	"infected/hulk" : "infected/anim_hulk"
	"infected/witch" : "infected/anim_witch"
	"infected/witch_bride" : "infected/anim_witch"
}

/*
 * @authors rhino
 */
::AdminSystem.SetAnimationCmd <- function ( player, args )
{
	local ent = null
	local target = GetArgument(2)
	if(target != null && target != "!picker")
	{
		target = Entity(target)
		if(!target.IsEntityValid())
			return
		ent = target
	}
	else if(target == null || target == "!picker")
	{
		ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT)
		if(!ent)
		{	
			// Try to find aimed commentary_dummy 
			local bestDot = 0.95;
			local bestDist = null
			local dist_tol = 0.01

			local org = player.GetOrigin()
			local facing = player.GetEyeAngles().Forward()
			foreach(e in Objects.All())
			{
				if(e.GetClassname() != "commentary_dummy" && e.GetClassname() != "prop_physics_multiplayer")
					continue
				// Make vector to entity
				local distvec = e.GetOrigin() - org;
				local dist = distvec.Length()
				if(bestDist == null)
					bestDist = dist
				distvec = distvec.Scale(1.0/dist)

				local dot =  Utils.VectorDotProduct(facing,distvec);
				if (dot <= bestDot)
				{
					if( bestDot - dot > dist_tol || dist > bestDist)
						continue;
				}
					
				bestDot	= dot;
				ent = e;
			}
			
			if(!ent)
				return;
		}
	}
	
	local mdl = ent.GetModel()
	if(mdl.find("*") != null)
		return;
	
	mdl = ShortenModelName(mdl)
 
	if(mdl in AnimationModelMaps)
		mdl = AnimationModelMaps[mdl]

	ent = ent.GetBaseEntity()

	if(!(mdl in ::ModelDetails) || !("sequences" in ::ModelDetails[mdl]))
		return

	local seq_arr = ::ModelDetails[mdl].sequences

	local seq = GetArgument(1)
	
	if(!seq || seq == "!random")
	{
		seq = Utils.GetRandValueFromArray(seq_arr)
	}
	
	local seq_id = ent.LookupSequence(seq)
	if(seq_id == -1)
	{
		try
		{
			seq_id = seq.tointeger()
			seq = ent.GetSequenceName(seq_id)
			if(seq == "Not Found!")
				return
		}
		catch(e)
		{
			return
		}
	}

	if(ent.GetClassname() == "commentary_dummy")
		ent.SetSequence(seq_id)
	else
		DoEntFire("!self","setanimation",seq,0,null,ent)

	::Printer(player,"Starting animation("+TXTCLR.OG(seq_id)+") named "+TXTCLR.OR(seq)+" on "+TXTCLR.BG("#"+ent.GetEntityIndex()))
}

/*
 * @authors rhino
 */
::AdminSystem.RandomAnimationCmd <- function ( player, args )
{
	local ent = null
	local target = GetArgument(3)
	if(target != null && target != "!picker")
	{
		target = Entity(target)
		if(!target.IsEntityValid())
			return
		ent = target
	}
	else if(target == null || target == "!picker")
	{
		ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT)
		if(!ent)
		{	
			// Try to find aimed commentary_dummy 
			local bestDot = 0.95;
			local bestDist = null
			local dist_tol = 0.01

			local org = player.GetOrigin()
			local facing = player.GetEyeAngles().Forward()
			foreach(e in Objects.All())
			{
				if(e.GetClassname() != "commentary_dummy" && e.GetClassname() != "prop_physics_multiplayer")
					continue
				// Make vector to entity
				local distvec = e.GetOrigin() - org;
				local dist = distvec.Length()
				if(bestDist == null)
					bestDist = dist
				distvec = distvec.Scale(1.0/dist)

				local dot =  Utils.VectorDotProduct(facing,distvec);
				if (dot <= bestDot)
				{
					if( bestDot - dot > dist_tol || dist > bestDist)
						continue;
				}
					
				bestDot	= dot;
				ent = e;
			}
			
			if(!ent)
				return;
		}
	}
	local mdl = ent.GetModel()
	if(mdl.find("*") != null)
		return;
	
	mdl = ShortenModelName(mdl)
 
	if(mdl in AnimationModelMaps)
		mdl = AnimationModelMaps[mdl]

	ent = ent.GetBaseEntity()

	if(!(mdl in ::ModelDetails) || !("sequences" in ::ModelDetails[mdl]))
		return

	local seq_arr = ::ModelDetails[mdl].sequences

	local limit = GetArgument(1)
	local pattern = GetArgument(2)
	if(!limit)
		limit = 1
	else
		limit = limit.tointeger()
		
	if(!pattern)
	{
		if (limit == 1)
			Printer(player,Utils.GetRandValueFromArray(seq_arr))
		else
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(seq_arr,limit)))
	}
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(seq_arr,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(seq_arr,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.SearchAnimationCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	if(!pattern)
		return

	local limit = GetArgument(2)
	local target = GetArgument(3)

	local ent = null
	if(target != null && target != "!picker")
	{
		target = Entity(target)
		if(!target.IsEntityValid())
			return
		ent = target
	}
	else if(target == null || target == "!picker")
	{
		ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT)
		if(!ent)
		{	
			// Try to find aimed commentary_dummy 
			local bestDot = 0.95;
			local bestDist = null
			local dist_tol = 0.01

			local org = player.GetOrigin()
			local facing = player.GetEyeAngles().Forward()
			foreach(e in Objects.All())
			{
				if(e.GetClassname() != "commentary_dummy" && e.GetClassname() != "prop_physics_multiplayer")
					continue
				// Make vector to entity
				local distvec = e.GetOrigin() - org;
				local dist = distvec.Length()
				if(bestDist == null)
					bestDist = dist
				distvec = distvec.Scale(1.0/dist)

				local dot =  Utils.VectorDotProduct(facing,distvec);
				if (dot <= bestDot)
				{
					if( bestDot - dot > dist_tol || dist > bestDist)
						continue;
				}
					
				bestDot	= dot;
				ent = e;
			}
			
			if(!ent)
				return;
		}
	}	
	local mdl = ent.GetModel()
	if(mdl.find("*") != null)
		return;
	
	mdl = ShortenModelName(mdl)
	
	if(mdl in AnimationModelMaps)
		mdl = AnimationModelMaps[mdl]

	ent = ent.GetBaseEntity()

	if(!(mdl in ::ModelDetails) || !("sequences" in ::ModelDetails[mdl]))
		return

	local seq_arr = ::ModelDetails[mdl].sequences

	if(!limit)
		limit = 15
	else if(limit != "all")
		limit = limit.tointeger()
		
	if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.ArraySearchFilterReturnAll(seq_arr,pattern,@(s) s)))
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(seq_arr,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(seq_arr,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.RandomPhysModelCmd <- function ( player, args )
{
	local limit = GetArgument(1)
	local pattern = GetArgument(2)
	if(!limit)
		limit = 1
	else
		limit = limit.tointeger()
		
	if(!pattern)
	{
		if (limit == 1)
			Printer(player,FixShortModelName(Utils.GetRandValueFromArray(::PhysicsAvailableModels)))
		else
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArrayFilter(PhysicsAvailableModels,limit,@(v,c) FixShortModelName(v))))
	}
	else if (limit == 1)
		Printer(player,FixShortModelName(Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::PhysicsAvailableModels,pattern))))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArrayFilter(Utils.ArraySearchFilterReturnAll(::PhysicsAvailableModels,pattern),limit,@(v,c) FixShortModelName(v))))
}

/*
 * @authors rhino
 */
::AdminSystem.RandomModelCmd <- function ( player, args )
{
	local limit = GetArgument(1)
	local pattern = GetArgument(2)
	if(!limit)
		limit = 1
	else
		limit = limit.tointeger()
		
	if(!pattern)
	{
		if (limit == 1)
			Printer(player,FixShortModelName(Utils.GetRandValueFromArray(::ModelNamesArray)))
		else
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArrayFilter(ModelNamesArray,limit,@(v,c) FixShortModelName(v))))
	}
	else if (limit == 1)
		Printer(player,FixShortModelName(Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::ModelNamesArray,pattern))))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArrayFilter(Utils.ArraySearchFilterReturnAll(::ModelNamesArray,pattern,@(s) s ,@(v,c) FixShortModelName(v)),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.SearchModelCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	local limit = GetArgument(2)
	if(!limit)
		limit = 15
	else if(limit != "all")
		limit = limit.tointeger()
		
	if(!pattern)
		return
	else if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.ArraySearchFilterReturnAll(ModelNamesArray,pattern,@(s) s, @(v,c) FixShortModelName(v))))
	else if (limit == 1)
		Printer(player,FixShortModelName(Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(ModelNamesArray,pattern))))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArrayFilter(Utils.ArraySearchFilterReturnAll(ModelNamesArray,pattern,@(s) s ,@(v,c) FixShortModelName(v)),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.ModelCmd <- function ( player, args)
{
	
	if(::VSLib.EasyLogic.NextMapContinues)
		return;
	
	local ent = GetArgument(1);
	
	if(ent == "!picker")
		ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
	else if(ent == "!self")
		ent = player;
	else if(ent.find("#") != null)
	{
		ent = Entity(ent)
	}
	else
	{
		try{ent = Entity(ent)}catch(e){return;}
	}

	if(ent == null)
		return;

	local model = GetArgument(2);
	if(model == null)
		return;

	// TO-DO : temporary fix
	if(model.find("&") != null)
	{
		model = split(model,"&")[0]
	}

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
	
	local ent = GetArgument(1);
	if(ent == "!picker")
		ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
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
	
	if(::VSLib.EasyLogic.NextMapContinues)
		return;
	
	local ent = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
	
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
		
	local name = player.GetCharacterNameLower();

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
	{
		player.SetModel(model);
		AdminSystem.Vars._modelPreference[name].lastmodel = model;
	}

	player.SetNetProp("m_clrRender",ent.GetNetProp("m_clrRender"));

	Printer(player,CmdMessages.Models.ChangeSuccess(ent.GetIndex(),model));
}

/*
 * @authors rhino
 */
::AdminSystem.RandomDecalCmd <- function ( player, args )
{
	local limit = GetArgument(1)
	local pattern = GetArgument(2)
	if(!limit)
		limit = 1
	else
		limit = limit.tointeger()
		
	if(!pattern)
	{
		if (limit == 1)
			Printer(player,Utils.GetRandValueFromArray(::DecalPaths.all))
		else
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(DecalPaths.all,limit)))
	}
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::DecalPaths.all,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(::DecalPaths.all,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.SearchDecalCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	local limit = GetArgument(2)
	if(!limit)
		limit = 15
	else if(limit != "all")
		limit = limit.tointeger()
		
	if(!pattern)
		return
	else if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.ArraySearchFilterReturnAll(::DecalPaths.all,pattern)))
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::DecalPaths.all,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(::DecalPaths.all,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.DecalCmd <- function ( player, args )
{	

	local name = player.GetCharacterNameLower();
	local decal = GetArgument(1);
	if(!decal || decal == "random")
		decal = Utils.GetRandValueFromArray(::DecalPaths.all)
	
	local use_eye_angles = GetArgument(2)

	local keyvals = 
	{
		classname = "infodecal"
		texture = decal
		origin = player.GetLookingLocation()
		angles = use_eye_angles ? player.GetEyeAngles() : QAngle(0,0,0)
	}

	local dec_ent = Utils.CreateEntityWithTable(keyvals)
	if(dec_ent)
	{
		DoEntFire("!self","Activate","",0,null,dec_ent.GetBaseEntity())
		Printer(player,"Created decal: "+decal);
	}
	else
	{
		Printer(player,"Failed to create decal: "+decal)
	}
}

/*
 * @authors rhino
 */
::AdminSystem.RandomParticleCmd <- function ( player, args )
{
	local limit = GetArgument(1)
	local pattern = GetArgument(2)
	if(!limit)
		limit = 1
	else
		limit = limit.tointeger()
		
	if(!pattern)
	{
		if (limit == 1)
			Printer(player,Utils.GetRandValueFromArray(::Particlenames.names))
		else
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(::Particlenames.names,limit)))
	}
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::Particlenames.names,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(::Particlenames.names,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.SearchParticleCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	local limit = GetArgument(2)
	if(!limit)
		limit = 15
	else if(limit != "all")
		limit = limit.tointeger()
		
	if(!pattern)
		return
	else if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.ArraySearchFilterReturnAll(::Particlenames.names,pattern)))
	else if (limit == 1)
		Printer(player,Utils.GetRandValueFromArray(Utils.ArraySearchFilterReturnAll(::Particlenames.names,pattern)))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.ArraySearchFilterReturnAll(::Particlenames.names,pattern),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.ParticleCmd <- function ( player, args )
{	

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

/*
 * @authors rhino
 */
::AdminSystem.RemoveLightsCmd <- function(player,args)
{
	
	local target = GetArgument(1)
	if(!target)
		target = "all"

	if(target == "all")
	{
		foreach(l in Objects.OfClassname("env_projectedtexture"))
		{
			if(l.GetParent() == null)
				l.Kill()
		}
		::Printer(player,"Removed all point light sources")
	}
	else if(target == "!self")
	{
		foreach(l in Objects.OfClassname("env_projectedtexture"))
		{
			if(l.GetParent() == null && l.GetNetProp("m_hTargetEntity") != -1 && l.GetNetProp("m_hTargetEntity").GetEntityHandle() == player.GetEntityHandle())
				l.Kill()
		}
		::Printer(player,"Removed all point light sources targeting you")
	}
	else if(target == "!picker")
	{
		target = player.GetLookingEntity()
		if(!target)
			return

		foreach(l in Objects.OfClassname("env_projectedtexture"))
		{
			if(l.GetParent() == null && l.GetNetProp("m_hTargetEntity") != -1 && l.GetNetProp("m_hTargetEntity").GetEntityHandle() == target.GetEntityHandle())
				l.Kill()
		}
		::Printer(player,"Removed all point light sources targeting "+TXTCLR.BG("#"+target.GetIndex()))
	}
	else
	{
		target = Entity(target)
		if(!target.IsEntityValid())
			return

		foreach(l in Objects.OfClassname("env_projectedtexture"))
		{
			if(l.GetParent() == null && l.GetNetProp("m_hTargetEntity") != -1 && l.GetNetProp("m_hTargetEntity").GetEntityHandle() == target.GetEntityHandle())
				l.Kill()
		}
		::Printer(player,"Removed all point light sources targeting "+TXTCLR.BG("#"+target.GetIndex()))
	}
}

/*
 * @authors rhino
 * TO-DO: Redundant af, clean it up
 */
::AdminSystem.SpawnPointLightCmd <- function(player,args)
{
	local colors =
	{
		white = "255 255 255 200"
		red = "255 0 0 200"
		green = "0 255 0 200"
		blue = "0 0 255 200"
		yellow = "255 255 0 200"
		cyan = "0 255 255 200"
		magenta = "255 0 255 200"
		purple = "128 0 128 200"
		pink = "205 105 180 200"
	}

	local playeridx = player.GetIndex()
	local color = Convars.GetClientConvarValue("ps_preferred_light_color",playeridx)

	if(!color || color == "random" || color == "")
		color = colors[Utils.GetRandValueFromArray(Utils.TableKeys(colors))]
	else
	{	
		if(color in colors)
			color = colors[color]
		else
			color = CastCustomSetting(player,["color","str|"+color])+" 200"
	}
	local EyePosition = player.GetLookingLocation();
	local move_closer = player.GetEyeAngles().Forward().Scale(-2)
	
	local fov = Convars.GetClientConvarValue("ps_preferred_light_fov",playeridx)
	if(!fov || fov == "")
		fov = 90.0
	else if(fov == "random")
	{
		fov = RandomInt(1,179)
	}
	else
	{	
		fov = fov.tofloat()
		if (fov >= 180) // TO-DO: Maybe spawn 2 more facing the other side(no overlapping)
			fov = 179
		else if (fov <= 0)
			fov = 1
	}

	local extra_height = Convars.GetClientConvarValue("ps_preferred_light_raise",playeridx)
	if(!extra_height || extra_height == "")
		extra_height = 0
	else
		extra_height = extra_height.tofloat()

	local kvs =
	{
		classname = "env_projectedtexture"
		origin = EyePosition+move_closer+Vector(0,0,extra_height)
		spawnflags = 1
		enableshadows = 1
		shadowquality = 1

		lightcolor = color
		lightonlytarget = 0
		cameraspace = 0

		nearz = 0.5
		farz = 450.0
		lightfov = fov
	}
	local target = GetArgument(1)
	if(!target)
		kvs.angles <- RotateOrientation(player.GetEyeAngles(),QAngle(180,0,0))
	else
	{
		if(target == "!self")
			target = "#"+playeridx
		else if(target == "!picker")
		{
			local aimed = player.GetLookingEntity()
			if(!aimed)
				return
			target = "#"+aimed.GetIndex()
		}
		else
		{
			local t_ent = Entity(target)
			if(!t_ent.IsEntityValid())
				return
			target = "#"+t_ent.GetIndex()
		}
		kvs.target <- target
	}
	local ent = Utils.CreateEntityWithTable(kvs)
	ent.SetFlags(1)

	DoEntFire("!self","TurnOff","",0,null,ent.GetBaseEntity())
	DoEntFire("!self","TurnOn","",0.3,null,ent.GetBaseEntity())
	
	if(target)
	{
		ent.GetScriptScope()["thinktime"] <- 0
		ent.GetScriptScope()["target"] <- Entity(kvs.target).GetIndex()
		ent.GetScriptScope()["lastorg"] <- Entity(kvs.target).GetOrigin()
		local transitional = Utils.CreateEntityWithTable(kvs)
		transitional.SetFlags(1)

		ent.GetScriptScope()["transit"] <- "#"+transitional.GetIndex()

		DoEntFire("!self","SetParent","#"+ent.GetIndex(),0,null,transitional.GetBaseEntity())
		DoEntFire("!self","TurnOff","",0,null,transitional.GetBaseEntity())
		
		AddThinkToEnt(ent.GetBaseEntity(),"EnvProjectTextureTraceFunc")
	}

	Printer(player,CmdMessages.Prop.Success(format("light <color: %s> <fov: %s>",kvs.lightcolor,kvs.lightfov.tostring()),ent));
}

/*
 * @authors rhino
 */
::AdminSystem.PointLightCmd <- function ( player, args )
{	

	local color = GetArgument(1);
	local colors =
	{
		white = "255 255 255 200"
		red = "255 0 0 200"
		green = "0 255 0 200"
		blue = "0 0 255 200"
		yellow = "255 255 0 200"
		cyan = "0 255 255 200"
		magenta = "255 0 255 200"
		purple = "128 0 128 200"
		pink = "205 105 180 200"
	}
	if(!color || color == "random")
		color = colors[Utils.GetRandValueFromArray(Utils.TableKeys(colors))]
	else
	{	
		if(color in colors)
			color = colors[color]
		else
			color = CastCustomSetting(player,["color","str|"+color])+" 200"
	}
	local EyePosition = player.GetLookingLocation();
	local move_closer = player.GetEyeAngles().Forward().Scale(-2)
	
	local fov = GetArgument(2)
	if(!fov)
		fov = 90.0
	else if(fov == "random")
	{
		fov = RandomInt(1,179)
	}
	else
	{	
		fov = fov.tofloat()
		if (fov >= 180) // TO-DO: Maybe spawn 2 more facing the other side(no overlapping)
			fov = 179
		else if (fov <= 0)
			fov = 1
	}

	local extra_height = GetArgument(3)
	if(!extra_height)
		extra_height = 0
	else
		extra_height = extra_height.tofloat()

	local kvs =
	{
		classname = "env_projectedtexture"
		origin = EyePosition+move_closer+Vector(0,0,extra_height)
		angles = RotateOrientation(player.GetEyeAngles(),QAngle(180,0,0))
		spawnflags = 1
		enableshadows = 1
		shadowquality = 1

		lightcolor = color
		lightonlytarget = 0
		cameraspace = 0

		nearz = 0.5
		farz = 450.0
		lightfov = fov
	}
	local ent = Utils.CreateEntityWithTable(kvs)
	ent.SetFlags(1)
	
	DoEntFire("!self","TurnOff","",0,null,ent.GetBaseEntity())
	DoEntFire("!self","TurnOn","",0.3,null,ent.GetBaseEntity())

	Printer(player,CmdMessages.Prop.Success(format("light <color: %s> <fov: %s>",kvs.lightcolor,kvs.lightfov.tostring()),ent));
}

/*
 * @authors rhino
 */
::AdminSystem.PointLightFollowCmd <- function ( player, args )
{	

	local playeridx = player.GetIndex()
	local color = GetArgument(1);
	local colors =
	{
		white = "255 255 255 200"
		red = "255 0 0 200"
		green = "0 255 0 200"
		blue = "0 0 255 200"
		yellow = "255 255 0 200"
		cyan = "0 255 255 200"
		magenta = "255 0 255 200"
		purple = "128 0 128 200"
		pink = "205 105 180 200"
	}
	if(!color || color == "random")
		color = colors[Utils.GetRandValueFromArray(Utils.TableKeys(colors))]
	else
	{	
		if(color in colors)
			color = colors[color]
		else
			color = CastCustomSetting(player,["color","str|"+color])+" 200"
	}
	local EyePosition = player.GetLookingLocation();
	local move_closer = player.GetEyeAngles().Forward().Scale(-2)
	
	local target = GetArgument(2)
	if(!target || target == "self")
		target = "#"+playeridx

	local targetent = Entity(target)
	if(!targetent.IsEntityValid()) 
		return

	local fov = GetArgument(3)
	if(!fov)
		fov = 90.0
	else if(fov == "random")
	{
		fov = RandomInt(1,179)
	}
	else
	{	
		fov = fov.tofloat()
		if (fov >= 180)
			fov = 179
		else if (fov <= 0)
			fov = 1
	}

	local extra_height = GetArgument(4)
	if(!extra_height)
		extra_height = 0
	else
		extra_height = extra_height.tofloat()

	local kvs =
	{
		classname = "env_projectedtexture"
		origin = EyePosition+move_closer+Vector(0,0,extra_height)
		spawnflags = 1
		enableshadows = 1
		shadowquality = 1

		target = "#"+playeridx
		lightcolor = color
		lightonlytarget = 0
		cameraspace = 0

		nearz = 0.5
		farz = 450.0
		lightfov = fov
	}
	local ent = Utils.CreateEntityWithTable(kvs)
	ent.SetFlags(1)
	
	ent.GetScriptScope()["thinktime"] <- 0
	ent.GetScriptScope()["target"] <- playeridx
	ent.GetScriptScope()["lastorg"] <- player.GetOrigin()
	DoEntFire("!self","TurnOff","",0,null,ent.GetBaseEntity())
	DoEntFire("!self","TurnOn","",0.3,null,ent.GetBaseEntity())


	local transitional = Utils.CreateEntityWithTable(kvs)
	transitional.SetFlags(1)

	ent.GetScriptScope()["transit"] <- "#"+transitional.GetIndex()

	DoEntFire("!self","SetParent","#"+ent.GetIndex(),0,null,transitional.GetBaseEntity())
	DoEntFire("!self","TurnOff","",0,null,transitional.GetBaseEntity())
	
	AddThinkToEnt(ent.GetBaseEntity(),"EnvProjectTextureTraceFunc")

	Printer(player,CmdMessages.Prop.Success(format("light <color: %s> <fov: %s>",kvs.lightcolor,kvs.lightfov.tostring()),ent));
}

::EnvProjectTextureTraceFunc <- function(...)
{
	if(self.GetScriptScope()["thinktime"] == 1)
	{
		if((Ent(self.GetScriptScope()["target"]).GetOrigin()-self.GetScriptScope()["lastorg"]).Length() > 2)
		{
			self.GetScriptScope()["thinktime"] = 0
			self.GetScriptScope()["lastorg"] = Ent(self.GetScriptScope()["target"]).GetOrigin()

			NetProps.SetPropIntArray( self, "m_bState", 0, 0);
			NetProps.SetPropIntArray( Ent(self.GetScriptScope()["transit"]), "m_bState", 1, 0);

			DoEntFire("!self","RunScriptCode","NetProps.SetPropIntArray( self, \"m_bState\", 1, 0)",0.05,null,self)
			DoEntFire(self.GetScriptScope()["transit"],"RunScriptCode","NetProps.SetPropIntArray( self, \"m_bState\", 0, 0)",0.05,null,self)
			//AdminSystem.out("move: "+NetProps.GetPropIntArray( self, "m_bState", 0) + " "+NetProps.GetPropIntArray( Ent(self.GetScriptScope()["transit"]), "m_bState", 0))
		}
		else
		{
			NetProps.SetPropIntArray( self, "m_bState", 1, 0);
			//AdminSystem.out("no move: "+NetProps.GetPropIntArray( self, "m_bState", 0) + " "+NetProps.GetPropIntArray( Ent(self.GetScriptScope()["transit"]), "m_bState", 0))
		}
	}
	else
	{
		NetProps.SetPropIntArray( Ent(self.GetScriptScope()["transit"]), "m_bState", 0, 0);
		NetProps.SetPropIntArray( self, "m_bState", 1, 0);
		self.GetScriptScope()["thinktime"] = self.GetScriptScope()["thinktime"] + 1
		//AdminSystem.out("no think: "+NetProps.GetPropIntArray( self, "m_bState", 0) + " "+NetProps.GetPropIntArray( Ent(self.GetScriptScope()["transit"]), "m_bState", 0))
	}
}

/* @authors rhino
 * Show explosion params
 */
::AdminSystem.Show_explosion_settingsCmd <- function (player,args)
{
	
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
	
	local name = player.GetCharacterName();
	local setting = GetArgument(1);
	local val = GetArgument(2);
	
	if(val == null)
		return

	if(!(setting in AdminSystem.Vars._explosion_settings[name.tolower()]))
	{
		::SpellChecker.Levenshtein(3,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem.Vars._explosion_settings[name.tolower()])
		return;
	}
	
	if(setting != "effect_name")
		{try{val = val.tofloat();}catch(e){return;}}
	else if(val != "no_effect" && Utils.GetIDFromArray(::Particlenames.names,val) == -1)
	{
		Messages.ThrowPlayer(player,CmdMessages.Particles.UnknownParticle(val))
		::SpellChecker.Levenshtein(5,3,"particle name").PrintBestMatches(player.GetBaseEntity(),val,Utils.ArrayToTable(::Particlenames.names))
		return;
	}

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
			case "simple_physics_prop":
			case "prop_physics":
			case "prop_physics_multiplayer":
			case "prop_ragdoll":
			case "func_physbox_multiplayer":
			case "func_physbox":
			case "prop_physics_override":
			case "prop_vehicle":
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
	return tbl
}

/*
 * @authors rhino
 * Create a delayed explosion with a particle effect until exploding
 */
::AdminSystem._AimedExplosionCmd <- function (player,args)
{
	
	local meteorshower = GetArgument(1)
	local name = player.GetCharacterNameLower();
	local aimedlocation = player.GetLookingLocation();
	local argtable = AdminSystem.Vars._explosion_settings[name];

	local explosion_particle = argtable.effect_name;
	local minsp = argtable.minpushspeed
	local maxsp = (argtable.maxpushspeed - minsp)
	local pushspeed = minsp + (rand()%maxsp)
	local delay = argtable.delay;
	local particle = null

	if(explosion_particle != "no_effect")
	{
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
		
		particle = Utils.CreateEntityWithTable(particletable);

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
			aimedlocation=aimedlocation
		});
	}
	else
	{
		local explosion_sound = Utils.CreateEntityWithTable({classname="ambient_generic", message = ::GetExplosionSoundScriptName(), spawnflags = 32, origin = aimedlocation});

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

	tbl.explosion_sound.Input("ToggleSound","",0.033);
	tbl.explosion.Input("Explode","",0.033);
	tbl.explosion_sound.Input("runscriptcode","if(Entity(self).GetParent() != null) Entity(self).GetParent().Input(\"KillHierarchy\") else Entity(self).Kill()",0.066);

	foreach(ent in ents)
	{	
		if (!ent.IsEntityValid() || ent.GetParent() != null)
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
	
	player.SetNetProp("m_clrRender",-1);
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateTankRockPreferenceCmd <- function ( player, args )
{	
	
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
	
	if(AdminSystem.Vars._RockThrow.spawn_prop_after)
	{
		AdminSystem.Vars._RockThrow.spawn_prop_after = false;
		Messages.InformAll(CmdMessages.DisableTankRockPhys());
	}
	else
	{
		AdminSystem.Vars._RockThrow.spawn_prop_after = true;
		Messages.InformAll(CmdMessages.EnableTankRockPhys());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.UpdateJockeyPreferenceCmd <- function ( player, args )
{	
	
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

	// Unit vector perpendecular to player
	local temp = player.GetEyeAngles().Forward();
	eyeforward.x = temp.y;
	eyeforward.y = -temp.x;
	eyeforward.z = 0;
	eyeforward = eyeforward.Scale(1.0/eyeforward.Length());

	local ent = null;
	local startkey = null;

	if(!IsCurrentMapAnOfficialMap())
	{
		local nKeys = 6.0;
		horizontal_space *= 25/nKeys;
		keyvaltable.sounds = 0
		keyvaltable.wait = 0.2

		startkey = Utils.CreateEntityWithTable(keyvaltable);
		
		if(startkey == null)
		{Messages.ThrowPlayer(player,CmdMessages.Piano.Failed());return;}
		
		local entindex = startkey.GetIndex();

		AdminSystem.Vars._spawnedPianoKeys[entindex] <- startkey.GetName();
		startkey.Input("addoutput","OnPressed !self,runscriptcode,Entity(self).EmitSound(GetPianoKeySoundScriptName()),0,-1");

		for(local i = 0; i < nKeys; i++)
		{
			keyvaltable.origin = lookedloc + eyeforward.Scale(horizontal_space*(i+1));
			ent = Utils.CreateEntityWithTable(keyvaltable);
			entindex = ent.GetIndex();
			
			AdminSystem.Vars._spawnedPianoKeys[entindex] <- ent.GetName();
			ent.Input("addoutput","OnPressed !self,runscriptcode,Entity(self).EmitSound(GetPianoKeySoundScriptName()),0,-1");
		}
	}
	else
	{
		startkey = Utils.CreateEntityWithTable(keyvaltable);
		
		if(startkey == null)
		{Messages.ThrowPlayer(player,CmdMessages.Piano.Failed());return;}
		
		local entindex = startkey.GetIndex();

		AdminSystem.Vars._spawnedPianoKeys[entindex] <- startkey.GetName();

		foreach(i,key in keys)
		{	
			keyvaltable.origin = lookedloc + eyeforward.Scale(horizontal_space*(i+1));
			keyvaltable.sounds = key
			ent = Utils.CreateEntityWithTable(keyvaltable);
			entindex = ent.GetIndex();
			
			AdminSystem.Vars._spawnedPianoKeys[entindex] <- ent.GetName();
		}
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

	Printer(player,CmdMessages.Ent.EntityCreate(ent.GetIndex(),ent.GetClassname(),Utils.GetTableString(keyvals)));
	
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
		keyvals =
		{
			classname = cname,
			origin = player.GetLookingLocation(),
			angles = QAngle(0,0,0)
		};
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
				pairsplit[1] = CastCustomSetting(player,pairsplit);
				if(pairsplit[1] == null)
					return;
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

::CastCustomSetting <- function(player,pairs)
{
	local str = split(pairs[1],"|");
	// Three values, Possible position, angle, rgb value
	if(str.len()==4)
	{
		switch(str[0])
		{
			case "ang":
			{
				return QAngle(str[1].tofloat(),str[2].tofloat(),str[3].tofloat());
			}
			case "pos":
			case "vec":
			{
				return Vector(str[1].tofloat(),str[2].tofloat(),str[3].tofloat());
			}
			case "str":
			{
				return str[1]+" "+str[2]+" "+str[3];
			}
			case "flg":
			{
				local flags = 0;
				for(local i=1;i<4;i++)
				{
					if(!(str[i] in getconsttable()))
					{
						Printer(player,COLOR_ORANGE+"[FLAG-MISSING] " + COLOR_OLIVE_GREEN + str[i] + COLOR_DEFAULT + " is unknown!","warning")
						continue;
					}
					flags = flags | getconsttable()[str[i]]
				}
				return flags;
			}
			default:
			{
				Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairs[0]),"error");
				return;
			}
		}
	}
	// Single value
	else if(str.len()==2)
	{
		switch(str[0])
		{
			case "float":
			{
				return str[1].tofloat();
			}
			case "int":
			{
				return str[1].tointeger();
			}
			case "str":
			{
				return str[1];
			}
			case "flg":
			{
				local flags = 0;
				if(str[1] in getconsttable())
				{
					flags = flags | getconsttable()[str[1]]
				}
				else
				{
					Printer(player,COLOR_ORANGE+"[FLAG-MISSING] " + COLOR_OLIVE_GREEN + str[1] + COLOR_DEFAULT + " is unknown!","warning")
				}
				return flags;
			}
			default:
			{
				Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairs[0]),"error");
				return;
			}
		}
	}
	// string with multiple spaces
	else
	{
		if(str.len() == 1)
		{
			return str[0];
		}
		else if(str[0] == "str")
		{
			local s = ""
			for(local i=1;i<str.len();i++)
				s += str[i]+" ";

			return s;
		}  
		else if(str[0] == "flg")
		{
			local flags = 0;
			for(local i=1;i<str.len();i++)
			{
				if(!(str[i] in getconsttable()))
				{
					Printer(player,COLOR_ORANGE+"[FLAG-MISSING] " + COLOR_OLIVE_GREEN + str[i] + COLOR_DEFAULT + " is unknown!","warning")
					continue;
				}
				flags = flags | getconsttable()[str[i]]
			}
			return flags;
		}
		else
		{
			Printer(player,CmdMessages.Ent.TypeUnknown(str[0],pairs[0]),"error");
			return;
		}
		
	}
}

/*
 * @authors rhino
 */
::ApplyAngleSettings <- function(player,_ang,tbl)
{
	local flags = tbl.flags
	local ang = QAngle(_ang.x,_ang.y,_ang.z);

	local extraang = QAngle(0,0,0)
	if(typeof tbl.val == "string")
	{
		local spl = split(tbl.val," ")
		switch(spl.len())
		{
			case 1:
			{
				local v = 0
				try
				{
					v = spl[0].tofloat();
					extraang = QAngle(v,v,v);
				}
				catch(e)
				{
					printR("[Defaults-Error] Formatting of spawn_angles.val in Tables.PropSpawn is wrong, using QAngle(0,0,0) instead...")
				}
				break;
			}
			case 3:
			{
				try
				{
					extraang = QAngle(spl[0].tofloat(),spl[1].tofloat(),spl[2].tofloat())
				}
				catch(e)
				{
					printR("[Defaults-Error] Formatting of spawn_angles.val in Tables.PropSpawn is wrong, using QAngle(0,0,0) instead...")
				}
				break;
			}
			default:
			{
				printR("[Defaults-Error] Formatting of spawn_angles.val in Tables.PropSpawn is wrong, using QAngle(0,0,0) instead...")
				break;
			}
		}
	}
	else if(typeof tbl.val != "QAngle")
	{
		printR("[Defaults-Error] Formatting of spawn_angles in Tables.PropSpawn is wrong, using QAngle(0,0,0) instead...")
	}
	else
	{
		extraang = tbl.val;
	}

	if(flags == ANGLE_NO_ADDITION)
		return ang;

	function HasFlag(flags,flag)
	{
		return (flags & flag) != 0
	}
	function GetRandAngle(min,max)
	{
		min = min.tofloat()
		max = max.tofloat()
		if(max == 0)
		{
			return QAngle(-(rand() % (min - 1)),-(rand() % (min - 1)),-(rand() % (min - 1)))
		}
		return QAngle(min + (rand() % (max - min + 1)),min + (rand() % (max - min + 1)),min + (rand() % (max - min + 1)))
	}

	/// Assignments
	if(HasFlag(flags,ANGLE_USE_VAL))
		ang = extraang;
	if(HasFlag(flags,ANGLE_EYES_EXACT))
		ang = player.GetEyeAngles();
	if(HasFlag(flags,ANGLE_EYES_PITCH))
		ang.x = player.GetEyeAngles().x;
	if(HasFlag(flags,ANGLE_EYES_YAW))
		ang.y = player.GetEyeAngles().y;
	// Random
	if(HasFlag(flags,ANGLE_RANDOM_0_90))
		ang = GetRandAngle(0,90);
	if(HasFlag(flags,ANGLE_RANDOM_90_180))
		ang = GetRandAngle(90,180);
	if(HasFlag(flags,ANGLE_RANDOM_0_180))
		ang = GetRandAngle(0,180);
	if(HasFlag(flags,ANGLE_RANDOM_M90_0))
		ang = GetRandAngle(-90,0);
	if(HasFlag(flags,ANGLE_RANDOM_M180_M90))
		ang = GetRandAngle(-180,-90);
	if(HasFlag(flags,ANGLE_RANDOM_M180_0))
		ang = GetRandAngle(-180,0);
	if(HasFlag(flags,ANGLE_RANDOM_M15_15))
		ang = GetRandAngle(-15,15);
	if(HasFlag(flags,ANGLE_RANDOM_M30_30))
		ang = GetRandAngle(-30,30);
	if(HasFlag(flags,ANGLE_RANDOM_M60_60))
		ang = GetRandAngle(-60,60);
	if(HasFlag(flags,ANGLE_RANDOM_M90_90))
		ang = GetRandAngle(-90,90);
	if(HasFlag(flags,ANGLE_RANDOM_GIVEN))
		ang = GetRandAngle(tbl.min,tbl.max);

	/// Additions
	if(HasFlag(flags,ANGLE_ADD_VAL))
		ang += extraang;
	// Pitch
	if(HasFlag(flags,ANGLE_PULL_UP))
		ang += QAngle(-90,0,0);
	if(HasFlag(flags,ANGLE_PULL_AROUND))
		ang += QAngle(180,0,0);
	if(HasFlag(flags,ANGLE_PULL_DOWN))
		ang += QAngle(90,0,0);
	// Yaw
	if(HasFlag(flags,ANGLE_TURN_RIGHT))
		ang += QAngle(0,-90,0);
	if(HasFlag(flags,ANGLE_TURN_AROUND))
		ang += QAngle(0,180,0);
	if(HasFlag(flags,ANGLE_TURN_LEFT))
		ang += QAngle(0,90,0);
	// Roll
	if(HasFlag(flags,ANGLE_ROLLOVER_RIGHT))
		ang += QAngle(0,0,90);
	if(HasFlag(flags,ANGLE_ROLLOVER))
		ang += QAngle(0,0,180);
	if(HasFlag(flags,ANGLE_ROLLOVER_LEFT))
		ang += QAngle(0,0,-90);
	// Random
	if(HasFlag(flags,ANGLE_ADD_RANDOM_0_45))
		ang += GetRandAngle(0,45);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_45_90))
		ang += GetRandAngle(45,90);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_M45_0))
		ang += GetRandAngle(-45,0);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_M90_M45))
		ang += GetRandAngle(-90,-45);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_M15_15))
		ang += GetRandAngle(-15,15);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_M45_45))
		ang += GetRandAngle(-45,45);
	if(HasFlag(flags,ANGLE_ADD_RANDOM_GIVEN))
		ang += GetRandAngle(tbl.min,tbl.max);
	
	return ang;
}

/*
 * @authors rhino
 */
::ApplyHeightSettings <- function(player,_vec,tbl)
{
	local flags = tbl.flags
	local vec = Vector(_vec.x,_vec.y,_vec.z);
	
	if(flags == HEIGHT_NO_ADDITION)
		return vec;

	function HasFlag(flags,flag)
	{
		return (flags & flag) != 0
	}
	function GetRandHeight(min,max)
	{
		if(max == 0)
		{
			return -(rand() % (min - 1))
		}
		return min + (rand() % (max - min + 1))
	}

	/// Assignments
	if(HasFlag(flags,HEIGHT_EYELEVEL))
		vec.z = player.GetEyePosition().z;
	if(HasFlag(flags,HEIGHT_USE_VAL))
		vec.z = tbl.val;
	// Random
	if(HasFlag(flags,HEIGHT_RANDOM_0_10))
		vec.z = GetRandHeight(0,10);
	if(HasFlag(flags,HEIGHT_RANDOM_0_50))
		vec.z = GetRandHeight(0,50);
	if(HasFlag(flags,HEIGHT_RANDOM_0_100))
		vec.z = GetRandHeight(0,100);
	if(HasFlag(flags,HEIGHT_RANDOM_0_500))
		vec.z = GetRandHeight(0,500);
	if(HasFlag(flags,HEIGHT_RANDOM_M10_0))
		vec.z = GetRandHeight(-10,0);
	if(HasFlag(flags,HEIGHT_RANDOM_M50_0))
		vec.z = GetRandHeight(-50,0);
	if(HasFlag(flags,HEIGHT_RANDOM_M100_0))
		vec.z = GetRandHeight(-100,0);
	if(HasFlag(flags,HEIGHT_RANDOM_M500_0))
		vec.z = GetRandHeight(-500,0);
	if(HasFlag(flags,HEIGHT_RANDOM_M10_10))
		vec.z = GetRandHeight(-10,10);
	if(HasFlag(flags,HEIGHT_RANDOM_M50_50))
		vec.z = GetRandHeight(-50,50);
	if(HasFlag(flags,HEIGHT_RANDOM_M100_100))
		vec.z = GetRandHeight(-100,100);
	if(HasFlag(flags,HEIGHT_RANDOM_M250_250))
		vec.z = GetRandHeight(-250,250);
	if(HasFlag(flags,HEIGHT_RANDOM_M500_500))
		vec.z = GetRandHeight(-500,500);
	if(HasFlag(flags,HEIGHT_RANDOM_GIVEN))
		vec.z = GetRandHeight(tbl.min,tbl.max);
	
	/// Additions
	if(HasFlag(flags,HEIGHT_ADD_VAL))
		vec.z += tbl.val.tofloat();
	//Random
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_0_10))
		vec.z += GetRandHeight(0,10);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_0_50))
		vec.z += GetRandHeight(0,50);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_0_100))
		vec.z += GetRandHeight(0,100);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_0_500))
		vec.z += GetRandHeight(0,500);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M10_0))
		vec.z += GetRandHeight(-10,0);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M50_0))
		vec.z += GetRandHeight(-50,0);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M100_0))
		vec.z += GetRandHeight(-100,0);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M500_0))
		vec.z += GetRandHeight(-500,0);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M10_10))
		vec.z += GetRandHeight(-10,10);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M50_50))
		vec.z += GetRandHeight(-50,50);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M100_100))
		vec.z += GetRandHeight(-100,100);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_M250_250))
		vec.z += GetRandHeight(-250,250);
	if(HasFlag(flags,HEIGHT_ADD_RANDOM_GIVEN))
		vec.z += GetRandHeight(tbl.min,tbl.max);

	/* TO-DO
	if((flags & HEIGHT_TOP_TOUCH) != 0)
		vec = vec
	if((flags & HEIGHT_BOTTOM_TOUCH) != 0)
		vec = vec
	*/

	return vec;
}

/*
 * @authors rhino
 */
::ApplyPropSettingsToTable <- function(player,typename,settings)
{
	local name = player.GetCharacterNameLower();
	local settingstable = AdminSystem.Vars._prop_spawn_settings[name][typename];

	settings.origin = ApplyHeightSettings(player,settings.origin,settingstable["spawn_height"])
	settings.angles = ApplyAngleSettings(player,settings.angles,settingstable["spawn_angles"])

}

::GetPositionRelativeToPlayer <- function(player,pos)
{
	local fwvec = player.GetEyeAngles().Forward();
	local temp = Vector(fwvec.x,fwvec.y,0);

	fwvec.x = -temp.y;
	fwvec.y = temp.x;
	fwvec.z = 0;
	fwvec = fwvec.Scale(pos.y/fwvec.Length());

	return Vector(fwvec.x,fwvec.y,pos.z) + temp.Scale(pos.x/temp.Length()); 
}

::GetSpecialModelOptions <- function(player,MDL,tbl)
{
	local special = MDL.slice(1,MDL.len())
	if(special in ::ModelPaths.special)
	{
		local tblref = ::ModelPaths.special[special]
		local mdlspec = tblref.mdl
		MDL = typeof mdlspec == "array" 
					? Utils.GetRandValueFromArray(mdlspec)
					: mdlspec

		if("origin_offset" in tblref)
			tbl.origin += tblref.origin_offset
		if("angles_offset" in tblref)
			tbl.angles += tblref.angles_offset

		if("mass_scale" in tblref)
			tbl.massScale = tblref.mass_scale

		if("post_spawn" in tblref)
			tbl.post = tblref.post_spawn
		return MDL
	}
	else
	{
		return  g_MapScript.GetEntityGroup( special )
	}
}

::DoPostSpawnSettings <- function(createdent,propsettingname,settings)
{
	foreach(typs,post_table in settings.post)
	{	
		if(typs != "all" 
			&& typs != propsettingname
			&& (typs.find("&") != null 
				&& Utils.GetIDFromArray(split(typs,"&"),propsettingname) == -1))
			continue

		// Inputs
		if("ent_fire" in post_table)
		{
			foreach(inp,opts in post_table.ent_fire)
			{
				DoEntFire(opts.target,inp,opts.params,opts.delay,opts.activator,createdent.GetBaseEntity())
			}
		}

		// Buttons
		// TO-DO: Model bbox errors, movedir not really working; parenting issues
		// 	* Setting and clearing parent to an info_target which is parented by the actual model seem to work with few error messages
		/* 
		if("buttons" in post_table)
		{
			// Multiple buttons using local origin generator function
			if("multiple" in post_table.buttons)
			{
				local buttonstbl = post_table.buttons.multiple
				
				foreach(idx,sound_id in buttonstbl.sounds)
				{
					local keyvaltable = 
					{	
						classname = "func_button"
						origin = Vector(0,0,0)
						movedir = createdent.GetAngles().Forward()
						spawnflags = buttonstbl.spawnflags
						wait = buttonstbl.wait
						sounds = sound_id
					}
					local spawned_button = Utils.CreateEntityWithTable(keyvaltable);

					if(spawned_button != null)
					{
						spawned_button.Input("SetParent","#"+createdent.GetIndex(),0)
						local loc_org = buttonstbl.next_local_origin(createdent,idx)
						spawned_button.Input("RunScriptCode","self.SetLocalOrigin(Vector("+loc_org.x+","+loc_org.y+","+loc_org.z+"))",0.05)
					}
				}
			}
			// Single button using given local origin
			else if("single" in post_table.buttons)
			{
				local buttonstbl = post_table.buttons.single
				
				local keyvaltable = 
				{	
					classname = "func_button"
					origin = Vector(0,0,0)
					movedir = createdent.GetAngles().Forward()
					spawnflags = buttonstbl.spawnflags
					wait = buttonstbl.wait
					sounds = buttonstbl.sounds
				}
				local spawned_button = Utils.CreateEntityWithTable(keyvaltable);
				if(spawned_button != null)
				{
					spawned_button.Input("SetParent","#"+createdent.GetIndex())
					spawned_button.Input("RunScriptCode","self.SetLocalOrigin(Vector("+buttonstbl.local_origin.x+","+buttonstbl.local_origin.y+","+buttonstbl.local_origin.z+"))",0.05)
				}
			}
		}
		*/
	}
}

/*
 * @authors rhino
 */
::AdminSystem.PropCmd <- function ( player, args )
{
	function PostSettingsManualChanges(raise,yaw,tbl,player)
	{
		if(raise != null)
		{
			if(raise.find("|") != null)
			{
				raise = CastCustomSetting(player,["origin_offset",raise])
				tbl.origin = tbl.origin + GetPositionRelativeToPlayer(player,raise);
			}
			else
			{
				try
				{
					raise = raise.tofloat();
				}
				catch(e)
				{
					printl("<"+(typeof raise)+"> type "+raise+" couldnt be parsed as float.");
					raise = 0
				}
				tbl.origin = tbl.origin + Vector(0,0,raise);

			}
		}
		if(yaw != null)
		{
			if(yaw.find("|") != null)
			{
				yaw = CastCustomSetting(player,["angle_offset",yaw])
				tbl.angles = tbl.angles + yaw;
			}
			else
			{
				try
				{
					yaw = yaw.tofloat();
				}
				catch(e)
				{
					printl("<"+(typeof yaw)+"> type "+yaw+" couldnt be parsed as float.");
					yaw = 0
				}
				tbl.angles = tbl.angles + QAngle(0,yaw,0);
			}
		}
	}

	local typename = GetArgument(1);
	if(!typename)
		return;

	local MDL = GetArgument(2);
	local propsettingname = "UNKNOWN"
	if(MDL != null)
	{
		propsettingname = (typename == "physics" || typename == "physicsM") ? "physics"
							: (typename == "ragdoll") ? "ragdoll"
								: "dynamic"
	}
	else
		MDL = typename

	local israndom = false
	if(MDL == "!random")
	{
		israndom = true
		local nonparentedlen = ::ModelNamesArray.len()
		local parentedlen = ::ModelPaths.parented.len()
		if( ( rand() % (nonparentedlen + parentedlen) ) < parentedlen ) // Randomly pick between single or parented
			MDL = RandomPick(::ModelPaths.parented)
		else
		{
			if(propsettingname == "physics")
				MDL = "models/"+RandomPick(::PhysicsAvailableModels)+".mdl"
			else
				MDL = "models/"+RandomPick(::ModelNamesArray)+".mdl"

		}
	}

	local raise = GetArgument(3);
	local raised = raise != null && raise != "0"
	local yaw = GetArgument(4);
	local massScale = GetArgument(5);
	if(massScale == null || ((typeof massScale == "integer" || typeof massScale == "float") && massScale <= 0))
		massScale = 1
	else
		massScale = massScale.tofloat() <= 0 ? 1 : massScale.tofloat()

	local origin = player.GetLookingLocation();
	local angles = QAngle(0,0,0);

	local name = player.GetCharacterNameLower();
	
	local createdent = null;
	local parentfailed = false
	local singlefailed = false
	local is_entitygroup = false

	// +++++++++++++++ SETTINGS START 
	local settings = 
	{
		origin = origin,
		angles = angles,
		massScale = massScale
		post = {}
	}

	// Prop spawn settings
	if(propsettingname != "UNKNOWN")
	{
		ApplyPropSettingsToTable(player,propsettingname,settings);
	}
	// Settings from arguments
	PostSettingsManualChanges(raise,yaw,settings,player);

	// Settings from special model
	if(MDL.find(">") == 0)
	{
		local e_g = GetSpecialModelOptions(player,MDL,settings)
		if(e_g == null) // Unknown ent group
		{
			Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(propsettingname+"("+MDL+")"));
			return;
		}
		else if(typeof e_g == "string") // Known special prop
		{
			if(!GetArgument(2))
			{
				Messages.ThrowPlayer(player,"A prop type has to be specified for "+COLOR_ORANGE+e_g);
				return;
			}
			MDL = e_g
		}
		else	// Known ent group
		{
			MDL = MDL.slice(1,MDL.len())
			local recover_parms = {}
			if(MDL in AdminSystem.EntityGroupSpawnRestrictions && AdminSystem.EntityGroupSpawnRestrictions[MDL])
			{
				if(!player.HasPrivilege(PS_USER_SCRIPTER))
				{
					Printer(player,"You need script authorization to spawn this entity!")
					return;
				}

				foreach(name,val in g_MapScript.GetReplaceParms("",g_MapScript.GetEntityGroup(MDL)))
				{
					if((typeof val == "string") && (val.find("$[") == 0 && val.find("]") == (val.len()-1)))
					{
						recover_parms[name] <- val
						g_MapScript.GetEntityGroup(MDL).ReplaceParmDefaults[name] = ::AliasCompiler.ExpressionCompiler(val,{player=format("Player(%s)",player.GetIndex().tostring())})
					}
				}
			}
			
			local spawnedents = ""
			try
			{
				g_MapScript.SpawnSingleAt( e_g, settings.origin, settings.angles );
				
				local keys = Utils.TableKeys(g_MapScript.UniqueTargetnames)
				local length = g_MapScript.UniqueTargetnames.len()
				local wrotenames = false
				for(local i=0;i<length;i++)
				{
					local ind = Entity(g_MapScript.UniqueTargetnames[keys[i]]).GetIndex()
					if(ind == 0)
						ind = TXTCLR.OR(Entity(g_MapScript.UniqueTargetnames[keys[i]]).GetName())
					else if(ind == -1)	// Custom targetnames
					{
						if(wrotenames)
							continue

						local namesfound = Utils.TableKeySearchFilterReturnAll( g_MapScript.GetEntityGroup(MDL).ReplaceParmDefaults,@"\$targetname")
						local tgkeys = Utils.TableKeys(namesfound)
						local namelength = namesfound.len()
						for(local j=0;j<namelength;j++)
						{
							ind = TXTCLR.OR(namesfound[tgkeys[j]])
							local o = Objects.OfName(namesfound[tgkeys[j]])
							if(o.len() == 1)
							{
								ind += "("+TXTCLR.BG("#"+o[0].GetIndex())+")"
							}
							if(j != namelength - 1 )
								spawnedents += ", "
						}
					}
					else
						ind = TXTCLR.OG("#"+TXTCLR.BG(ind))
						
					spawnedents += ind
					if(i != length - 1 )
						spawnedents += ", "
				}
			}
			catch(e)
			{}

			foreach(name,val in recover_parms)
			{
				g_MapScript.GetEntityGroup(MDL).ReplaceParmDefaults[name] = val
			}

			if(spawnedents.len() != 0)
				Printer(player,CmdMessages.Prop.EntGroupSuccess(MDL,spawnedents));
			else
				Printer(player,CmdMessages.Prop.EntGroupFailure(MDL));
			return
		}
	}
		
	origin = settings.origin
	angles = settings.angles
	massScale = settings.massScale
	// +++++++++++++++ SETTINGS END 

	// Spawning
	if ( typename == "physics" )
	{
		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnPhysicsProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles );
				if(ent != null && ent.IsEntityValid())
				{
					createdent.append(ent);
					ent.SetMoveType(MOVETYPE_NONE);
				}
				else
				{
					if(createdent.len()==0)	// parent failed, try simple physics
					{
						parentfailed = true
						break;
					}
					ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles );
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
			createdent = Utils.SpawnPhysicsProp( FixShortModelName(Utils.CleanColoredString(MDL)), origin, angles );
			if(createdent == null)
				singlefailed = true;
			else if(!raised)
			{
				local bbox = createdent.GetNetProp("m_Collision")
				createdent.SetOrigin(createdent.GetOrigin()+Vector(0,0,0.1-bbox.z))
			}
		}
	}
	else if ( typename == "physicsM" )
	{
		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnPhysicsMProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles, {massScale = massScale} );
				if(ent != null && ent.IsEntityValid())
				{
					createdent.append(ent);
					ent.SetMoveType(MOVETYPE_NONE);
				}
				else
				{
					if(createdent.len()==0)	// parent failed, try simple physics
					{
						parentfailed = true
						break;
					}
					ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles );
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
			createdent = Utils.SpawnPhysicsMProp( FixShortModelName(Utils.CleanColoredString(MDL)), origin, angles, {massScale = massScale} );
			if(createdent == null)
				singlefailed = true;
			else if(!raised)
			{
				local bbox = createdent.GetNetProp("m_Collision")
				createdent.SetOrigin(createdent.GetOrigin()+Vector(0,0,0.1-bbox.z))
			}
		}
	}
	else if ( typename == "ragdoll" )
	{
		if ( MDL == "nick" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_gambler.mdl", origin, angles );
		else if ( MDL == "rochelle" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_producer.mdl", origin, angles );
		else if ( MDL == "coach" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_coach.mdl", origin, angles );
		else if ( MDL == "ellis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_mechanic.mdl", origin, angles );
		else if ( MDL == "bill" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_namvet.mdl", origin, angles );
		else if ( MDL == "zoey" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_teenangst.mdl", origin, angles );
		else if ( MDL == "francis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_biker.mdl", origin, angles );
		else if ( MDL == "louis" )
			createdent = Utils.SpawnRagdoll( "models/survivors/survivor_manager.mdl", origin, angles );
		else if ( MDL == "smoker" )
			createdent = Utils.SpawnRagdoll( "models/infected/smoker.mdl", origin, angles );
		else if ( MDL == "boomer" )
			createdent = Utils.SpawnRagdoll( "models/infected/boomer.mdl", origin, angles );
		else if ( MDL == "boomette" )
			createdent = Utils.SpawnRagdoll( "models/infected/boomette.mdl", origin, angles );
		else if ( MDL == "hunter" )
			createdent = Utils.SpawnRagdoll( "models/infected/hunter.mdl", origin, angles );
		else if ( MDL == "spitter" )
			createdent = Utils.SpawnRagdoll( "models/infected/spitter.mdl", origin, angles );
		else if ( MDL == "jockey" )
			createdent = Utils.SpawnRagdoll( "models/infected/jockey.mdl", origin, angles );
		else if ( MDL == "charger" )
			createdent = Utils.SpawnRagdoll( "models/infected/charger.mdl", origin, angles );
		else if ( MDL == "witch" )
			createdent = Utils.SpawnRagdoll( "models/infected/witch.mdl", origin, angles );
		else if ( MDL == "witch_bride" )
			createdent = Utils.SpawnRagdoll( "models/infected/witch_bride.mdl", origin, angles );
		else if ( MDL == "tank" )
			createdent = Utils.SpawnRagdoll( "models/infected/hulk.mdl", origin, angles );
		else if ( MDL == "tank_dlc3" )
			createdent = Utils.SpawnRagdoll( "models/infected/hulk_dlc3.mdl", origin, angles );
		else
			createdent = Utils.SpawnRagdoll( MDL, origin, angles );
		
		if(createdent != null)
		{
			local bbox = createdent.GetNetProp("m_Collision")
			createdent.SetOrigin(createdent.GetOrigin()+Vector(0,0,0.1-bbox.z))
		}
	}
	else
	{	
		if(MDL.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(MDL,"&"))
			{
				local ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles );
				if(ent != null && ent.IsEntityValid())
					createdent.append(ent);
			}
		}
		else
		{
			createdent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(MDL)), origin, angles );
			if(createdent != null && !raised)
			{
				local bbox = createdent.GetNetProp("m_Collision")
				createdent.SetOrigin(createdent.GetOrigin()+Vector(0,0,0.1-bbox.z))
			}
		}
	}

	// Attempts to create simple physics
	if(createdent == null || createdent == [] || singlefailed || parentfailed)
	{
		if(singlefailed)
		{	
			local args = 
			{
				MDL = MDL
				typename = typename
				origin = origin
				angles = angles
				player = player
				name = name
				israndom = israndom
			}
			if(propsettingname == "physics")
			{
				
				local ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(MDL)), origin, angles );
				if(ent == null)
				{
					Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(typename));
					return;
				}
				args.ent <- ent

				switch(::CheckPhysicsAvailabilityForModel(FixShortModelName(Utils.CleanColoredString(MDL)),ent,DoDummyConversionProcessProp,args,true))
				{
					case false:
						if(AdminSystem.Vars._grabbackupprop.enabled)
						{
							local keyvals = 
							{
								classname = AdminSystem.Vars._grabbackupprop.classname,
								model = AdminSystem.Vars._grabbackupprop.modelname,
								origin = ent.GetOrigin(),
								angles = ent.GetAngles(),
							};
							
							local new_ent = Utils.CreateEntityWithTable(keyvals);
							if(!new_ent || !new_ent.IsEntityValid())
							{
								Printer(player,TXTCLR.OG(MDL)+" can't be used as a physics object! Failed to create the backup prop!")
							}
							else
								Printer(player,CmdMessages.Prop.Success("physicsM",new_ent));
					
						}
						else
						{
							Printer(player,TXTCLR.OG(MDL)+" can't be used as a physics object!")
						}
						ent.Kill()
						break
					case true:
						DoDummyConversionProcessProp(args)
						break;
					case null:
						break;
				}
			}
			else
			{
				local ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(MDL)), origin, angles );
				if(ent == null)
				{
					Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(typename));
					return;
				}
				if(!raised)
				{
					local bbox = ent.GetNetProp("m_Collision")
					ent.SetOrigin(ent.GetOrigin()+Vector(0,0,0.1-bbox.z))
				}
			}
			return
		}
		else if(parentfailed)
		{	
			local mdl = ""
			local mdlsplit = split(MDL,"&")
			if(mdlsplit.len() < 2)
			{
				Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(typename));
				return;
			}
			else
			{
				mdl = mdlsplit[0]
			}
			local ent = Utils.SpawnDynamicProp( FixShortModelName(Utils.CleanColoredString(mdl)), origin, angles );
			if(ent == null)
			{
				Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(typename));
				return;
			}
			local cuniq = UniqueString()
			local oldind = ent.GetIndex()
			local thinker = Utils.CreateEntityWithTable({targetname=cuniq,classname="info_target",origin=origin,angles=angles,spawnflags=0})
			PropFailureFixCheck[thinker.GetName()] <- {id=ent.GetIndex(),thinkstart=Time(),israndom=israndom,pid=player.GetIndex(),character=name,searchname=ent.GetName(),chmdls=mdlsplit.slice(1,mdlsplit.len())}

			local convertername = ::Constants.Targetnames.PhysConverter+cuniq
			local converter = Utils.CreateEntityWithTable({classname="phys_convert",targetname=convertername,target="#"+oldind,spawnflags=3})
			converter.Input("converttarget")
			converter.Input("Kill")
			AddThinkToEnt(thinker.GetBaseEntity(),"PropTryFindSimplePhysParented")
		}
		else
		{
			Messages.ThrowPlayer(player,CmdMessages.Prop.Failed(typename));
		}
		return;
	}

	// Random spawn messages
	if(israndom)
	{
		if(AdminSystem.Vars._saveLastModel[name])
		{
			AdminSystem.Vars._savedModel[name].model = MDL
			AdminSystem.Vars._savedModel[name].classname = typename

			Printer(player,CmdMessages.ModelSaving.Success(typename,MDL));
		}
	}

	// Success messages
	if(typeof createdent == "array")
	{
		local parentent = createdent[0];
		foreach(e in createdent.slice(1,createdent.len()))
		{
			e.Input("setparent","#"+parentent.GetIndex(),0);
		}
		if(typename == "physicsM" || typename == "physics")
		{
			parentent.Input("RunScriptCode","_dropit(Entity("+parentent.GetIndex()+"))",0);
		}

		Printer(player,CmdMessages.Prop.SuccessParented(typename,createdent));
		createdent = parentent
		if(!raised)
		{
			parentent.Input("RunScriptCode","self.SetOrigin(self.GetOrigin() + Vector(0,0,0.1-Entity("+parentent.GetIndex()+").GetNetProp(\"m_Collision\").z ))",0.1);
		}
	}
	else
	{
		Printer(player,CmdMessages.Prop.Success(typename,createdent));
	}
	
	// Post spawn inputs and scripts
	DoPostSpawnSettings(createdent,propsettingname,settings)
}

::DoDummyConversionProcessProp <- function(args)
{
	local MDL = args.MDL
	local typename = args.typename
	local origin = args.origin
	local angles = args.angles
	local player = args.player
	local name = player.GetCharacterNameLower()

	local ent = args.ent
	if(!ent.IsEntityValid())
		return

	local cuniq = UniqueString()
	local oldind = ent.GetIndex()
	local thinker = Utils.CreateEntityWithTable({targetname=cuniq,classname="info_target",origin=origin,angles=angles,spawnflags=0})
	PropFailureFixCheck[thinker.GetName()] <- {id=oldind,thinkstart=Time(),israndom=args.israndom,pid=player.GetIndex(),character=name,searchname=ent.GetName()}

	local convertername = ::Constants.Targetnames.PhysConverter+cuniq
	local converter = Utils.CreateEntityWithTable({classname="phys_convert",targetname=convertername,target="#"+oldind,spawnflags=3})
	converter.Input("converttarget")
	converter.Input("Kill")
	AddThinkToEnt(thinker.GetBaseEntity(),"PropTryFindSimplePhysSingle")
}

::PropFailureFixCheck <- {}
::PropTryFindSimplePhysParented <- function(...)
{
	local thinktime = Time()
	//ClientPrint(null,3,self.GetName())
	local name = self.GetName()
	if(!(name in PropFailureFixCheck))
	{
		AddThinkToEnt(self,null)
		//ClientPrint(null,3,"deleted already")
		Entity(self.GetEntityIndex()).Input("Kill");
		return;
	}
	else
	{
		//ClientPrint(null,3,(thinktime-PropFailureFixCheck[name].thinkstart).tostring())
		if(thinktime-PropFailureFixCheck[name].thinkstart > 0.3)
		{	
			AddThinkToEnt(self,null)
			//ClientPrint(null,3,"too late "+(thinktime-PropFailureFixCheck[name].thinkstart).tostring())
			delete PropFailureFixCheck[name]
			Entity(self.GetEntityIndex()).Input("Kill");
			return;
		}
		else
		{
			foreach(obj in Objects.OfName(PropFailureFixCheck[name].searchname))
			{
				//ClientPrint(null,3,obj.GetOrigin().ToKVString())
				if(obj.GetClassname()=="simple_physics_prop" && (self.GetOrigin()-obj.GetOrigin()).Length()<5)
				{
					AddThinkToEnt(self,null)
					//ClientPrint(null,3,"Found")
					if(PropFailureFixCheck[name].israndom)
					{
						if(AdminSystem.Vars._saveLastModel[PropFailureFixCheck[name].character])
						{
							AdminSystem.Vars._savedModel[PropFailureFixCheck[name].character].model = obj.GetModel()
							AdminSystem.Vars._savedModel[PropFailureFixCheck[name].character].classname = "physicsM"

							Printer(Player(PropFailureFixCheck[name].pid),CmdMessages.ModelSaving.Success("physicsM",obj.GetModel()));
						}
					}
					local createdent = [obj]
					foreach(mdl in PropFailureFixCheck[name].chmdls)
					{
						local ch = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), obj.GetOrigin(), obj.GetAngles() );
						if(ch != null && ch.IsEntityValid())
							createdent.append(ch);
					}

					foreach(e in createdent.slice(1,createdent.len()))
					{
						e.Input("setparent","#"+obj.GetIndex(),0);
					}

					Printer(Player(PropFailureFixCheck[name].pid),CmdMessages.Prop.SuccessParented("physicsM",createdent));
					obj.SetNetProp("m_CollisionGroup",0)
					obj.Input("RunScriptCode","_dropit(Entity("+obj.GetIndex()+"))",0);
					
					local bbox = obj.GetNetProp("m_Collision")
					obj.SetOrigin(obj.GetOrigin()+Vector(0,0,0.1-bbox.z))

					delete PropFailureFixCheck[name]
					Entity(self.GetEntityIndex()).Input("Kill");	
					return;
				}
			}
		}	
	}
	
}
::PropTryFindSimplePhysSingle <- function(...)
{
	local thinktime = Time()
	//ClientPrint(null,3,self.GetName())
	local name = self.GetName()
	if(!(name in PropFailureFixCheck))
	{
		AddThinkToEnt(self,null)
		//ClientPrint(null,3,"deleted already")
		Entity(self.GetEntityIndex()).Input("Kill");
		return;
	}
	//ClientPrint(null,3,(thinktime-PropFailureFixCheck[name].thinkstart).tostring())
	if(thinktime-PropFailureFixCheck[name].thinkstart > 0.3)
	{
		AddThinkToEnt(self,null)
		//ClientPrint(null,3,"too late "+(thinktime-PropFailureFixCheck[name].thinkstart).tostring())
		delete PropFailureFixCheck[name]
		Entity(self.GetEntityIndex()).Input("Kill");	
		return;
	}
	else
	{
		foreach(obj in Objects.OfName(PropFailureFixCheck[name].searchname))
		{
			AddThinkToEnt(self,null)	
			//ClientPrint(null,3,obj.GetOrigin().ToKVString())
			if(obj.GetClassname()=="simple_physics_prop" && (self.GetOrigin()-obj.GetOrigin()).Length()<5)
			{
				//ClientPrint(null,3,"Found")
				if(PropFailureFixCheck[name].israndom)
				{
					if(AdminSystem.Vars._saveLastModel[PropFailureFixCheck[name].character])
					{
						AdminSystem.Vars._savedModel[PropFailureFixCheck[name].character].model = obj.GetModel()
						AdminSystem.Vars._savedModel[PropFailureFixCheck[name].character].classname = "physicsM"

						Printer(Player(PropFailureFixCheck[name].pid),CmdMessages.ModelSaving.Success("physicsM",obj.GetModel()));
					}
				}
				Printer(Player(PropFailureFixCheck[name].pid),CmdMessages.Prop.Success("physicsM",obj));
				obj.SetNetProp("m_CollisionGroup",0)
				obj.Input("RunScriptCode","_dropit(Entity("+obj.GetIndex()+"))",0);

				delete PropFailureFixCheck[name]
				Entity(self.GetEntityIndex()).Input("Kill");
				return;
			}
		}
	}
}

::AdminSystem.DoorCmd <- function ( player, args )
{
	local name = player.GetCharacterNameLower();
	local DoorModel = GetArgument(1);
	local origin = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);
	local ent = null;
	local raise = GetArgument(2);
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
		ent = Utils.SpawnDoor("models/props_downtown/door_interior_112_01.mdl", origin, GroundPosition);
	else
	{
		origin.z += raise;
		
		if(DoorModel.find("&") != null)
		{
			ent = []
			local mdls = split(DoorModel,"&");
			local d = Utils.SpawnDoor(Utils.CleanColoredString(mdls[0]), origin, GroundPosition);

			if(d != null && d.IsEntityValid())
				ent.append(d);
			else
			{
				Printer(player,CmdMessages.Prop.FailureDoor(mdls[0]));
				return;
			}

			foreach(mdl in mdls.slice(1,mdls.len()))
			{
				d = Utils.SpawnDynamicProp(Utils.CleanColoredString(mdl), origin, GroundPosition);
				if(d != null && d.IsEntityValid())
					ent.append(d);
			}
		}
		else
		{
			if ( DoorModel == "saferoom" || DoorModel == "checkpoint" )
				ent = Utils.SpawnDoor("models/props_doors/checkpoint_door_02.mdl", origin, GroundPosition);
			else
				ent = Utils.SpawnDoor(Utils.CleanColoredString(DoorModel), origin, GroundPosition);
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
	Utils.BroadcastClientCommand(Utils.CombineArray(args));
}

::AdminSystem.ConsoleCmd <- function ( player, args )
{
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
	local Entnameid = GetArgument(1);
	local Action = GetArgument(2);
	local Value = GetArgument(3);
	local Value2 = GetArgument(4);
	local Value3 = GetArgument(5);
	local Entity = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if(!Action)
		return

	local act = strip(Action.tolower())
	if(act == "addoutput" || act == "runscriptcode" || act == "runscriptfile")
	{
		if(!player.HasPrivilege(PS_USER_SCRIPTER))
		{
			Messages.ThrowPlayer(player,"You need PS_USER_SCRIPTER privilege to fire '"+act+"' input on entities!")
			return;
		}	
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
			if (Entity.GetClassname() == "player" && act == "kill" && Entity.GetSteamID() !="BOT" && AdminSystem.Vars.IgnoreDeletingPlayers)
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to kick player:"+Entity.GetName());
				return;
			}
			else if (Entity.GetClassname() == "player" && act == "becomeragdoll")
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to make player ragdoll:"+Entity.GetName());
				return;
			}
			else if(Entity.GetClassname() == "prop_ragdoll" && Entity.GetName().find(Constants.Targetnames.Ragdoll) != null && act == "kill")
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to kill player ragdoll:"+Entity.GetName());
				return;
			}
			else if(Entity.HasDriver() && act == "kill")
			{
				printl(player.GetCharacterNameLower()+"->Ignore attempt to kill player vehicle:"+Entity.GetName());
				return;
			}
			else
			{
				foreach(s in Players.All())
				{
					if(s.IsPassenger())
					{
						if(Entity.GetEntityHandle() == s.GetPassengerVehicle().GetEntityHandle())
						{
							printl(player.GetCharacterNameLower()+"->Ignore attempt to kill player vehicle with passengers:"+Entity.GetName());
							return
						}
					}
				}
				if(act == "kill")
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

	local entlooked = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
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
		entlooked.Input("sleep","",0)

		if(entlooked.GetParent() == null)
		{
			newAngle = entlooked.GetAngles();
			
			if( axis == "x" )
			{	
				newAngle.x += val;
			}
			else if ( axis == "z")
			{
				newAngle.z += val;
			}
			else
			{
				newAngle.y += val;
			}
			
			local org = entlooked.GetOrigin()
			entlooked.Input("RunScriptCode",format("self.SetAngles(QAngle(%s,%s,%s))",newAngle.x.tostring(),newAngle.y.tostring(),newAngle.z.tostring()),0)
		}
		else
		{
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
		}
		Printer(player,CmdMessages.Force.RotateSuccess(entlooked.GetIndex(),newAngle));
	}
}

/*
 * Pushes the looked entity in the given direction
 * Directions are relative to the eyes of the player
 * TO-DO: Update mask to pick ragdolls
 * @authors rhino
 */
::AdminSystem.EntPushCmd <- function ( player, args )
{	

	local scalefactor = GetArgument(1);
	local direction = GetArgument(2);
	local pitchofeye = GetArgument(3);

	if(scalefactor == null)
	{
		scalefactor = 500;
	}
	else
	{
		scalefactor = scalefactor.tofloat();
	}

	if(direction == null)
	{
		direction = "forward";
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

	local entlooked = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
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
		direction = "forward";
	}

	if(pitchofeye == null)
	{
		pitchofeye = 0;
	}
	else
	{
		pitchofeye = pitchofeye.tofloat()*-1;
	}

	local entlooked = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
	
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

		local move_vec = Vector(0,0,0)

		if(direction == "backward")
		{	
			move_vec.x = -units
		}
		else if(direction == "left")
		{	
			move_vec.y = units
		}
		else if(direction == "right")
		{
			move_vec.y = -units
		}
		else if(direction == "up")
		{
			move_vec.z = units
		}
		else if(direction == "down")
		{
			move_vec.z = -units
		}
		else
		{
			move_vec.x = units
		}

		entlooked.SetLocalOrigin(entlooked.GetLocalOrigin()+move_vec)
		
		Printer(player,CmdMessages.Force.MoveSuccess(entlooked.GetIndex(),units,direction,0));
	}
	else if(entlooked)
	{	
		if(entlooked.GetParent() == null)
		{
			local move_vec = Vector(0,0,0)

			if(direction == "backward")
			{	
				move_vec.x = -units
			}
			else if(direction == "left")
			{	
				move_vec.y = units
			}
			else if(direction == "right")
			{
				move_vec.y = -units
			}
			else if(direction == "up")
			{
				move_vec.z = units
			}
			else if(direction == "down")
			{
				move_vec.z = -units
			}
			else
			{
				move_vec.x = units
			}

			entlooked.SetOrigin(entlooked.GetOrigin()+GetPositionRelativeToPlayer(player,move_vec))
		}
		else
		{
			local move_vec = Vector(0,0,0)

			if(direction == "backward")
			{	
				move_vec.x = -units
			}
			else if(direction == "left")
			{	
				move_vec.y = units
			}
			else if(direction == "right")
			{
				move_vec.y = -units
			}
			else if(direction == "up")
			{
				move_vec.z = units
			}
			else if(direction == "down")
			{
				move_vec.z = -units
			}
			else
			{
				move_vec.x = units
			}

			entlooked.SetLocalOrigin(entlooked.GetLocalOrigin()+move_vec)
		}

		Printer(player,CmdMessages.Force.MoveSuccess(entlooked.GetIndex(),units,direction,pitchofeye));
		
	}
}

/*
 * @authors rhino
 */
::AdminSystem.EntSpinCmd <- function ( player, args )
{	

	local scalefactor = GetArgument(1);
	local direction = GetArgument(2);

	if(scalefactor == null)
	{
		scalefactor = 500;
	}
	else
	{
		scalefactor = scalefactor.tofloat();
	}

	if(direction == null)
	{
		direction = "forward";
	}

	local entlooked = player.GetLookingEntity(TRACE_MASK_VISIBLE_AND_NPCS|TRACE_MASK_SHOT);
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
	if ( Sound )
	{
		if(Sound == "!random")
		{
			Sound = Utils.GetRandValueFromArray(::SoundScriptsArray).script
			Printer(player,"Playing random sound: "+Sound)
		}
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
				if(Ent == "!random")
				{
					Ent = Utils.GetRandValueFromArray(::SoundScriptsArray).script
					Printer(player,"Playing random sound: "+Ent)
				}
				player.PlaySound(Ent);
				AdminSystem.SoundName[ID] <- Ent;
			}
		}
	}
}

/*
 * @authors rhino
 * TO-DO: Maybe add spell checker
 */
::AdminSystem.SoundInfoCmd <- function ( player, args )
{
	local sname = GetArgument(1)
	if(!sname)
		return
	else if(!(sname in ::SoundScripts))
	{
		Printer(player,TXTCLR.OR(sname)+" is not a known sound script name!")
		return;
	}

	local tbl = ::SoundScripts[sname]
	local s = TXTCLR.BG(sname)+" details:\n"

	if("caption" in tbl)
		s += TXTCLR.OR("Caption/Comment: ")+TXTCLR.OG(tbl.caption)+"\n"
	if("volume" in tbl)
		s += TXTCLR.OR("Volume: ")+TXTCLR.OG(tbl.volume)+"\n"	
	if("soundlevel" in tbl)
		s += TXTCLR.OR("Sound Level: ")+TXTCLR.OG(tbl.soundlevel)+"\n"		
	if("wave" in tbl)
		s += TXTCLR.OR("Sound File: ")+TXTCLR.OG(tbl.wave)+"\n"	
	if("rndwave" in tbl)
	{
		s += TXTCLR.OR("Sound Files Random Pick:\n")	
		foreach(i,warr in tbl.rndwave)
		{
			s += "    "+TXTCLR.OG(warr[1])+"\n"	
		}
	}

	Printer(player,s)
}

/*
 * @authors rhino
 */
::AdminSystem.SearchSoundCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	local limit = GetArgument(2)
	if(!limit)
		limit = 25
	else if(limit != "all")
		limit = limit.tointeger()
		
	if(!pattern)
		return
	else if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.TableKeys(Utils.TableKeySearchFilterReturnAll(::SoundScripts,pattern))))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.TableKeys(Utils.TableKeySearchFilterReturnAll(::SoundScripts,pattern)),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.RandomSoundCmd <- function ( player, args )
{
	local pattern = GetArgument(1)
	local limit = GetArgument(2)
	if(!limit)
		limit = 10
	else
		limit = limit.tointeger()

	if(!pattern)
		ClientPrint(player.GetBaseEntity(),3,Utils.GetRandValueFromArray(::SoundScriptsArray).script)
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.TableKeys(Utils.TableKeySearchFilterReturnAll(::SoundScripts,pattern)),limit)))
}

/*
 * @authors rhino
 */
::AdminSystem.FindSoundInScriptsCmd <- function ( player, args )
{
	local file = GetArgument(1)
	if(!file)
		return

	local limit = GetArgument(2)
	local pattern = GetArgument(3)

	if(!limit)
		limit = 10
	else if(limit != "all")
		limit = limit.tointeger()

	function filter(val)
	{
		if("rndwave" in val)
		{
			foreach(i,ar in val.rndwave)
			{
				if(ar[1].find(file) != null)
					return true
			}
			return false
		}
		else if("wave" in val)
		{
			return val.wave.find(file) != null
		}
		return false
	}

	if(!pattern)
	{
		if(limit != "all")
			Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.TableKeys(Utils.TableFilterByValue(::SoundScripts,filter)),limit)))
		else
			Printer(player,Utils.ArrayString(Utils.TableKeys(Utils.TableFilterByValue(::SoundScripts,filter))))
	}
	else if(limit == "all")
		Printer(player,Utils.ArrayString(Utils.TableKeys(Utils.TableFilterByValue(Utils.TableKeySearchFilterReturnAll(::SoundScripts,pattern),filter))))
	else
		Printer(player,Utils.ArrayString(Utils.GetNRandValueFromArray(Utils.TableKeys(Utils.TableFilterByValue(Utils.TableKeySearchFilterReturnAll(::SoundScripts,pattern),filter)),limit)))
}

::AdminSystem.UseCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Entity = GetArgument(2);
	local LookingEntity = player.GetLookingEntity();
	local ent = null;
	local Target = Utils.GetPlayerFromName(GetArgument(1));
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

::AdminSystem.PitchShiftCmd <- function(player,args)
{
	local b = player.GetBaseEntity()
	DoEntFire("!self","PitchShift",GetArgument(1) ? GetArgument(1) : "1",0,null,b.GetCurrentScene())
}

::AdminSystem.PermaPitchShiftCmd <- function(player,args)
{
	local timername = "PS_PERMA_PITCH_SHIFT_"+player.GetCharacterNameLower()
	local p = GetArgument(1)
	if(timername in ::Quix.Table)
	{
		::Quix.Remove(timername);
	}

	if(p == null || p == "1" || p == "1.0")
	{
		local s = player.GetBaseEntity().GetCurrentScene()
		if(s!=null)		
			DoEntFire("!self","PitchShift","1",0,null,s)
	}
	else
	{
		local b = player.GetBaseEntity()
		local function Condition(count,params)
		{
			local s = params.player.GetCurrentScene()
			if(s==null)
				return false
			s.ValidateScriptScope()
			if("PS_PITCH_SHIFTED_VAL" in s.GetScriptScope()) // && s.GetScriptScope()["PS_PITCH_SHIFTED_VAL"] == params.shift)
				return false

			s.GetScriptScope()["PS_PITCH_SHIFTED_VAL"] <- params.shift
			return true
		}
		local function Callback(count,success,params)
		{
			DoEntFire("!self","PitchShift",params.shift,0,null,params.player.GetCurrentScene())
		}
		::Quix.AddUnlimited(timername,Condition,Callback,{player=b,shift=p},{player=b,shift=p})
	}

}

::AdminSystem.SpeakCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Scene = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));
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
	local LookingEntity = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	local Target = Utils.GetPlayerFromName(GetArgument(1));
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
	local entlooked = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if(entlooked == null)	
		return;

	////////////////////////////////////

	local t = intervals*(-7.0);
	local last_t = 0.0;
	local clr = entlooked.GetNetProp("m_clrRender");
	//::AdminSystem.out("start:"+clr);
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
			//::AdminSystem.out("dur:"+(last_t+intervals*7.0+0.4));
			Timers.AddTimer(last_t+intervals+0.4, false, ColorResetWrap, {ent=entlooked,clr=clr});
		}
	}

	color_seq();	// Loop starter

	Printer(player,CmdMessages.RainbowSuccess(duration,intervals,entlooked.GetIndex()));
}
::ColorResetWrap <- function(args)
{
	//::AdminSystem.out("curr:"+args.ent.GetNetProp("m_clrRender"));
	args.ent.SetNetProp("m_clrRender",args.clr);
}
/*
 * @authors rhino
 */
::AdminSystem.HelpCmd <- function(player, args)
{
	local cmd = GetArgument(1);
	if(cmd == null)
		cmd = "help"

	if(cmd in CmdDocs)
		Messages.DocCmdPlayer(player,CmdDocs[cmd](player,args))
	else
		Messages.ThrowPlayer(player,cmd+" is not a known command!")
}

/*
 * @authors rhino
 */
::AdminSystem.Update_print_output_stateCmd <- function(player, args)
{	

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

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._saveLastLine[name];
	AdminSystem.Vars._saveLastLine[name] = newstate;

	Printer(player,CmdMessages.LineSaving.State(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Randommodel_save_lastCmd <- function(player, args)
{	

	local name = player.GetCharacterNameLower();
	local newstate = !AdminSystem.Vars._saveLastModel[name];
	AdminSystem.Vars._saveLastModel[name] = newstate;

	Printer(player,CmdMessages.ModelSaving.State(newstate));
}

/*
 * @authors rhino
 */
::AdminSystem.Save_lineCmd <- function(player, args)
{	
	
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
::AdminSystem.Save_modelCmd <- function(player, args)
{	
	
	local name = player.GetCharacterNameLower();
	local classname = GetArgument(1);
	local model = GetArgument(2);
	if (model == null)
	{
		return;
	}
	
	AdminSystem.Vars._savedModel[name].classname = classname;
	AdminSystem.Vars._savedModel[name].model = model;

	Printer(player,CmdMessages.ModelSaving.Success(classname,model));
}
/*
 * @authors rhino
 */
::AdminSystem.Speak_savedCmd <- function(player, args)
{	
	
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
::AdminSystem.Spawn_saved_modelCmd <- function(player, args)
{	
	
	local name = player.GetCharacterNameLower();
	local classname = AdminSystem.Vars._savedModel[name].classname;
	local model = AdminSystem.Vars._savedModel[name].model;
	local createdent = null
	if (model != "")
	{
		local ent = null
		local settings = 
		{
			origin = player.GetLookingLocation(),
			angles = QAngle(0,0,0)
		}
		local spawner = function(a,b,c){return null;}
		
		if(classname.find("physics") != null)
		{
			ApplyPropSettingsToTable(player,"physics",settings);
			spawner = Utils.SpawnPhysicsMProp
		}
		else if(classname == "ragdoll")
		{
			ApplyPropSettingsToTable(player,"ragdoll",settings);
			spawner = Utils.SpawnRagdoll
		}
		else
		{
			ApplyPropSettingsToTable(player,"dynamic",settings);
			spawner = Utils.SpawnDynamicProp
		}

		if(model.find("&") != null)
		{
			createdent = []
			foreach(mdl in split(model,"&"))
			{
				local ent = spawner( Utils.CleanColoredString(mdl), settings.origin, settings.angles );
				if(ent != null && ent.IsEntityValid())
				{
					createdent.append(ent);
					ent.SetMoveType(MOVETYPE_NONE);
				}
				else
				{
					ent = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), settings.origin, settings.angles );
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
			createdent = spawner( Utils.CleanColoredString(model), settings.origin, settings.angles );
		}

		if(typeof createdent == "array")
		{
			if(createdent.len() == 0)
			{
				Printer(player,CmdMessages.ModelSaving.FailureSpawn(classname,model));
				return;
			}
			else if(createdent.len() == 1)
			{
				createdent = createdent[0]
				if(classname.find("physics") != null)
				{
					createdent.SetMoveType(MOVETYPE_VPHYSICS);
				}
				Printer(player,CmdMessages.ModelSaving.SpawnSaved(createdent.GetIndex(),classname,model));
			}
			else
			{
				local parentent = createdent[0];
				foreach(e in createdent.slice(1,createdent.len()))
				{
					e.Input("setparent","#"+parentent.GetIndex(),0);
				}
				if(classname.find("physics") != null)
				{
					parentent.SetMoveType(MOVETYPE_VPHYSICS);
				}

				Printer(player,CmdMessages.Prop.SuccessParented(classname,createdent));
			}
		}
		else
		{
			if(createdent == null)
				Printer(player,CmdMessages.ModelSaving.FailureSpawn(classname,model));
			else
				Printer(player,CmdMessages.ModelSaving.SpawnSaved(createdent.GetIndex(),classname,model));
		}
	}
	else
	{
		Messages.ThrowPlayer(player,CmdMessages.ModelSaving.NoneSaved(name));
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.Display_saved_lineCmd <- function(player, args)
{	
	
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
::AdminSystem.Display_saved_modelCmd <- function(player, args)
{	
	
	local name = player.GetCharacterNameLower();
	if (AdminSystem.Vars._saveLastModel[name])
	{	
		local tbl = 
		{
			classname = AdminSystem.Vars._savedModel[name].classname
			modelname = AdminSystem.Vars._savedModel[name].model
		}

		if (tbl.modelname != "")
		{
			Printer(player,CmdMessages.ModelSaving.Information(tbl));
		}
		else
		{
			Messages.ThrowPlayer(player,CmdMessages.ModelSaving.NoneSaved(name));
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
		
		printB(playername,"================physics_debug(of aimed object)=================",true,"debug",false,false);
		AdminSystem._Clientbroadcast(playername,"physics_debug_entity #"+ent.GetIndex(),1,false);
		if(svcheatsval==1.0)
		{
			printB(playername,"==================ent_dump====================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"ent_dump #"+ent.GetIndex(),1,false);
		}

		printB(playername,"",false,"",false,true,0.5);
	}
	else
	{
		if(player != null)
			printB(playername,"",false,"",true,false,0);
		::AdminSystem.out("=================basic==================",player);
		::AdminSystem.out("Name"+"\x05"+"-> "+"\x03"+ ent.GetName(),player);
		::AdminSystem.out("Index"+"\x05"+"-> "+"\x03"+ ent.GetIndex(),player);
		::AdminSystem.out("Class"+"\x05"+"-> "+"\x03"+ ent.GetClassname(),player);
		::AdminSystem.out("Parent #"+"\x05"+"-> "+"\x03"+ (ent.GetParent() == null ? "No parent" : ent.GetParent().GetIndex()),player);
		::AdminSystem.out("Model"+"\x05"+"-> "+"\x03" + ent.GetModel(),player);
		::AdminSystem.out("Scale"+"\x05"+"-> "+"\x03" + ent.GetModelScale(),player);

		::AdminSystem.out("=================flags===================",player);
		::AdminSystem.out("SpawnFlags"+"\x05"+"-> "+"\x03"+ ent.GetSpawnFlags(),player);
		::AdminSystem.out("Effects"+"\x05"+"-> "+"\x03"+ ent.GetNetProp("m_fEffects"),player);
		::AdminSystem.out("Flags"+"\x05"+"-> "+"\x03"+ ent.GetFlags() +" | EFlags-> " + ent.GetEFlags()+" | Sense flags-> "+ ent.GetSenseFlags(),player);

		::AdminSystem.out("===============positional=================",player);
		::AdminSystem.out("Location"+"\x05"+"-> "+"\x03"+ent.GetLocation().ToKVString(),player);
		::AdminSystem.out("Angles"+"\x05"+"-> "+"\x03" + ent.GetAngles().ToKVString(),player);

		if(ent.GetClassname() == "player")
		{
			::AdminSystem.out("Looking at"+"\x05"+"-> "+"\x03"+ent.GetLookingLocation().ToKVString(),player);
			::AdminSystem.out("Eye Position"+"\x05"+"-> "+"\x03"+ent.GetEyePosition().ToKVString(),player);
			::AdminSystem.out("Eye angles"+"\x05"+"-> "+"\x03"+ent.GetEyeAngles().ToKVString(),player);
		}
		
		if(player != null)
		{
			printB(playername,"================physics_debug=================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"physics_debug_entity #"+ent.GetIndex(),1,false);

			if(svcheatsval==1.0)
			{
				printB(playername,"=================ent_dump==================",true,"debug",false,false);
				AdminSystem._Clientbroadcast(playername,"ent_dump #"+ent.GetIndex(),1,false);
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
		printB(playername,"Looked location-> "+(player.GetLookingLocation() ? player.GetLookingLocation().ToKVString(): "UNKNOWN"),true,"debug",false,false);
		printB(playername,"Eye location-> "+(player.GetEyePosition() ? player.GetEyePosition().ToKVString(): "UNKNOWN"),true,"debug",false,false);
		printB(playername,"Eye angles-> "+(player.GetEyeAngles() ? player.GetEyeAngles().ToKVString(): "UNKNOWN"),true,"debug",false,false);
		printB(playername,"================player_stats===============",true,"debug",false,false);
		foreach(key,value in player.GetStats())
		{
			printB(playername,"[Stats] "+key+" -> "+value.tostring(),true,"debug",false,false);
		}

		if(svcheatsval==1.0)
		{	
			printB(playername,"=================dumpplayer===================",true,"debug",false,false);
			AdminSystem._Clientbroadcast(playername,"cl_dumpplayer #"+player.GetIndex().tostring(),1,false);
		}

		printB(playername,"",false,"",false,true,0.5);
	}
	else
	{
		::AdminSystem.out("==================basic====================",player);
		::AdminSystem.out("Name"+"\x05"+"-> "+"\x03"+ player.GetName(),player);
		::AdminSystem.out("Index"+"\x05"+"-> "+"\x03"+ player.GetIndex(),player);
		::AdminSystem.out("Team"+"\x05"+"-> "+"\x03"+ player.GetTeam(),player);
		::AdminSystem.out("Parent"+"\x05"+"-> #"+"\x03"+  (player.GetParent() == null ? "No parent" : player.GetParent().GetIndex()),player);
		::AdminSystem.out("Model"+"\x05"+"-> "+"\x03"+ player.GetModel(),player);
		::AdminSystem.out("Scale"+"\x05"+"-> "+"\x03"+ player.GetModelScale(),player);

		::AdminSystem.out("==================flags====================",player);
		::AdminSystem.out("SpawnFlags"+"\x05"+"-> "+"\x03"+ player.GetSpawnFlags(),player);
		::AdminSystem.out("Effects"+"\x05"+"-> "+"\x03"+ player.GetNetProp("m_fEffects"),player);
		::AdminSystem.out("Flags"+"\x05"+"-> "+"\x03"+ player.GetFlags() +" | EFlags-> " + player.GetEFlags()+" | Sense flags-> "+ player.GetSenseFlags(),player);

		::AdminSystem.out("===============positional==================",player);
		::AdminSystem.out("Player location"+"\x05"+"-> "+"\x03"+player.GetPosition().ToKVString(),player);
		::AdminSystem.out("Player angles"+"\x05"+"-> "+"\x03" + player.GetAngles().ToKVString(),player);
		::AdminSystem.out("Looked location"+"\x05"+"-> "+"\x03"+(player.GetLookingLocation() ? player.GetLookingLocation().ToKVString(): "UNKNOWN"),player);
		::AdminSystem.out("Eye location"+"\x05"+"-> "+"\x03"+(player.GetEyePosition() ? player.GetEyePosition().ToKVString(): "UNKNOWN"),player);
		::AdminSystem.out("Eye angles"+"\x05"+"-> "+"\x03"+(player.GetEyeAngles() ? player.GetEyeAngles().ToKVString(): "UNKNOWN"),player);
		/*
		::AdminSystem.out(playername,"=================player_stats===================");
		foreach(key,value in player.GetStats())
		{
			::AdminSystem.out(playername,"[Stats] "+key+" -> "+value.tostring());
		}
		*/
	}
}
/*
 * @authors rhino
 */
::AdminSystem.Debug_infoCmd <- function(player, args)
{	

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
	local aimed = player.GetLookingLocation();
	local radius = GetArgument(1);
	radius = radius == null ? 50 : radius.tofloat();
	
	local objtable = VSLib.EasyLogic.Objects.AroundRadius(aimed,radius);
	if(objtable == null)
	{
		Printer(player,CmdMessages.Debug.EntsAroundNone(radius,aimed.ToKVString()));
	}
	else
	{
		local str = CmdMessages.Debug.EntsAroundStart(radius);
		foreach(obj in objtable)
		{
			if(!obj.IsEntityValid())
			{
				continue;
			}
			str += CmdMessages.Debug.EntsAroundValid(obj);
		}

		Printer(player,str);
	}
}

/*
 * @authors rhino
 */
::AdminSystem.WikiCmd <- function(player,args)
{
	local classname = GetArgument(1)
	if(classname == null)
		return
	if(classname == "!picker")
	{
		local looked = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
		if(looked==null)
			return;
		else
			classname = looked.GetClassname()
	}
	else if(classname.find("#") == 0)
	{
		local ent = Entity(classname)
		if(!ent.IsEntityValid())
			return;
		else
			classname = ent.GetClassname()
	}

	local category = classname.find("_") != null ? split(classname,"_")[0] : classname

	if(!(classname in ::EntityClassesTable))	// Wrong classname
	{
		local categoryfound = (category in ::EntityDetailTables);

		if(categoryfound)	// Category did exist, ask closest match
		{
			::SpellChecker.Levenshtein(5,3,"class name").PrintBestMatches(player.GetBaseEntity(),classname,::EntityDetailTables[category])
			return;
		}
		else	// All wrong
		{
			local closest_category = ::SpellChecker.Levenshtein(5,1,"class name").GetBestMatch(category,::EntityDetailTables)
			if(closest_category == null)	// No close matches
			{
				Printer(player,"Unknown classname "+COLOR_ORANGE+classname)
				return;
			}
			else // Ask closest category's closest match
			{
				::SpellChecker.Levenshtein(5,3,"class name").PrintBestMatches(player.GetBaseEntity(),classname,::EntityDetailTables[closest_category])
				return;
			}
		}
	}

	local entitytbl = ::EntityDetailTables[category][classname];

	local header = GetArgument(2)	// link, description, flags, keyvals, inputs, outputs
	local printall = header == null
	local s = ""
	local exp = regexp(@"^[0-9]+\]\)$");
	switch(header)
	{
		case null:
		case "Link":
		case "link":
		case "Site":
		case "site":
		{
			Printer(player,COLOR_ORANGE+"Link: "+COLOR_DEFAULT+entitytbl.link)
			if(!printall)
				break;
		}
		case "Description":
		case "description":
		case "Desc":
		case "desc":
		case "Info":
		case "info":
		{
			Printer(player,entitytbl.description)
			if(!printall)
				break;
		}
		case "Flags":
		case "flags":
		{
			Printer(player,COLOR_ORANGE+"Flags"+COLOR_DEFAULT+" ("+COLOR_BRIGHT_GREEN+entitytbl.flags.len()+COLOR_DEFAULT+"):")
			if(entitytbl.flagnotes != "")
				Printer(player,COLOR_BRIGHT_GREEN+"Notes"+COLOR_DEFAULT+": "+COLOR_DEFAULT+entitytbl.flagnotes)
			local flaglist = []
			for(local i=0;i<31;i++)
			{
				if((1<<i).tostring() in entitytbl.flags)
					flaglist.append((1<<i).tostring())
			}

			s = ""
			foreach(i,flag in flaglist)
			{
				local ftbl = entitytbl.flags[flag]
				s += "\t"+COLOR_ORANGE+flag+COLOR_DEFAULT+": "+COLOR_OLIVE_GREEN+ftbl.description
				if(ftbl.notes != "")
					s += "." + TXTCLR.BG("[" + TXTCLR.OR("Note",COLOR_BRIGHT_GREEN) + "]") + ": " + ftbl.notes
				s += "\n"
			}
			Printer(player,s)
			if(!printall)
				break;
		}
		case "Keyvals":
		case "keyvals":
		case "Keyvalues":
		case "keyvalues":
		{
			Printer(player,TXTCLR.OR("Keyvalues")+" ("+TXTCLR.BG(entitytbl.keyvalues.len())+"):")
			if(entitytbl.keyvalnotes != "")
				Printer(player,TXTCLR.OR("Notes")+": "+entitytbl.keyvalnotes)

			s = ""
			foreach(key,val in entitytbl.keyvalues)
			{
				s += "\t" + TXTCLR.OR(key) + " <" + TXTCLR.OG(val.typename) + "> (" + TXTCLR.OG(val.shortinfo) + ")"
				s += "\r\t" + TXTCLR.OR("Details") + ": " + val.description + val.notes + ". " + val.extra

				if(val.typename == "choices" && val.choices.len() > 0)
				{	
					s += TXTCLR.BG("\r\tChoice") + ":"
					foreach(k,v in val.choices)
					{
						s += TXTCLR.OG("\r\t\t"+k) + ":" + TXTCLR.BG(v)
					}
				}
				s += "\n"
			}
			Printer(player,s)
			if(!printall)
				break;
		}
		case "Inputs":
		case "inputs":
		{
			Printer(player,TXTCLR.OR("Inputs")+" ("+TXTCLR.BG(entitytbl.inputs.len())+"):")
			if(entitytbl.inputnotes != "")
				Printer(player,TXTCLR.OR("Notes")+": "+entitytbl.inputnotes)
			
			s = ""
			foreach(key,val in entitytbl.inputs)
			{
				if(val.typename == "UNKNOWN_VAL_TYPE" || val.typename == "!FGD" || exp.capture(val.typename) != null)
					s += "\t"+TXTCLR.OR(key)+": "+Utils.StringReplace(val.description,";",".")+Utils.StringReplace(val.notes,";",".")
				else
					s += "\t"+TXTCLR.OR(key)+" <"+TXTCLR.OG(val.typename)+">: "+Utils.StringReplace(val.description,";",".")+Utils.StringReplace(val.notes,";",".")
				
				if(val.extra != "No extra short-information given" && val.extra != "")
					s += TXTCLR.BG("\r\t\t Extra")+": "+Utils.StringReplace(val.extra,";",".")

				if(val.typename == "choices" && val.choices.len() > 0)
				{	
					s += TXTCLR.BG("\r\tChoice") + ":"
					foreach(k,v in val.choices)
					{
						s += TXTCLR.OG("\r\t\t"+k) + ":" + TXTCLR.BG(v)
					}
				}
				s += "\n"
			}
			Printer(player,s)
			if(!printall)
				break;
		}
		case "Outputs":
		case "outputs":
		{
			Printer(player,TXTCLR.OR("Outputs")+" ("+TXTCLR.BG(entitytbl.outputs.len())+"):")
			if(entitytbl.outputnotes != "")
				Printer(player,TXTCLR.OR("Notes")+": "+entitytbl.outputnotes)
				
			s = ""
			foreach(key,val in entitytbl.outputs)
			{
				s += "\t"+TXTCLR.OR(key)+": "+Utils.StringReplace(val.description,";",".")+Utils.StringReplace(val.notes,";",".")
				if(val.extra != "No extra short-information given" && val.extra != "")
					s += TXTCLR.BG("\r\t\t Extra")+": "+Utils.StringReplace(val.extra,";",".")
				s += "\n"
			}
			Printer(player,s)
			if(!printall)
				break;
		}
		default:
		{
			if(printall)
				break;
			::SpellChecker.Levenshtein(3,2,"header name").PrintBestMatches(player.GetBaseEntity(),header,{outputs=1,inputs=1,keyvalues=1,keyvals=1,flags=1,info=1,desc=1,description=1,link=1,site=1})
		}
	}
}
/*
 * @authors rhino
 * wnet {netprop} {interval} {target}
 * wnet &{handlename}&{max_depth} {interval} {target}
 */
::AdminSystem.WatchNetPropCmd <- function(player,args)
{
	
	local entlooked = GetArgument(3) ? GetArgument(3) 
									 : player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if(entlooked == null)
	{	
		Printer(player,CmdMessages.Debug.WatchNoEntity())
		return;
	}

	if(typeof entlooked == "string")
	{
		entlooked = Entity(entlooked)
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			Printer(player,CmdMessages.Debug.WatchNoEntity())
			return;
		}
	}

	local netprop = GetArgument(1);
	if(netprop == null)
	{
		return;
	}
	
	local checksec = GetArgument(2) == null 
						? 1 
						: GetArgument(2).tofloat();
					
	if(checksec < 0.1)
	{
		Printer(player,CmdMessages.Debug.WatchIntervalFailure());
		return;
	}	

	// Script handle name in the table
	if(netprop[0].tochar() == "&")
	{
		local handlename = null
		local depth = null
		
		netprop = split(netprop,"&")
		if(netprop.len() != 2)
		{
			handlename = netprop[0]
			depth = 99
		}
		else
		{
			handlename = netprop[0]
			depth = netprop[1].tointeger()
		}

		if(!(handlename in ::NetPropTables))
		{
			Printer(player,CmdMessages.Debug.WatchUnknownHandle(handlename))
			return;
		}

		foreach(member,tbl in ::NetPropTables[handlename])
		{
			if(tbl.depth > depth)
				continue;
			
			if(!entlooked.HasNetProp(member))
			{
				Printer(player,CmdMessages.Debug.WatchWrongTableEntry(member))
			}
			else
			{
				local lastval = entlooked.GetNetProp(member);
				local argtable =
				{
					handlename=handlename
					player=player,
					checksec=checksec,
					ent=entlooked,
					netprop=member,
					lastval=lastval,
					timername=Constants.TimerNames.WatchNetPropScriptHandle,
					timersep = ">"
				}
				Printer(player,CmdMessages.Debug.WatchCurrentValue(entlooked.GetIndex(),handlename,member,lastval));

				::VSLib.Timers.AddTimerByName(Constants.TimerNames.WatchNetPropScriptHandle+member+">"+entlooked.GetIndex(),checksec,true,WatchNetPropMain,argtable)
			}
		}
		return;
	}

	if(!entlooked.HasNetProp(netprop))
	{
		Printer(player,CmdMessages.Debug.WatchDoesntHaveNetProp(netprop,entlooked.GetIndex(),entlooked.GetClassname()));
		return;
	}

	local lastval = entlooked.GetNetProp(netprop);
	local argtable =
	{
		handlename=""
		player = player,
		checksec = checksec,
		ent = entlooked,
		netprop = netprop,
		lastval = lastval,
		timername = Constants.TimerNames.WatchNetProp,
		timersep = "_"
	}
	Printer(player,CmdMessages.Debug.WatchCurrentValue(entlooked.GetIndex(),"",netprop,lastval));

	::VSLib.Timers.AddTimerByName(Constants.TimerNames.WatchNetProp+netprop+"_"+entlooked.GetIndex(),checksec,true,WatchNetPropMain,argtable)
}

::WatchNetPropMain <- function(args)
{
	
	if(args.ent == null || !args.ent.IsEntityValid() || !args.player.IsEntityValid())
	{
		return;
	}

	local ind = args.ent.GetIndex();

	local currentval = args.ent.GetNetProp(args.netprop);

	local changed = false;
	switch(typeof currentval)
	{
		case "string":
		case "float":
		case "integer":
		case "bool":
			{
				if(currentval != args.lastval)
				{
					changed = true;
					Printer(args.player,CmdMessages.Debug.WatchCurrentValue(ind,args.handlename,args.netprop,currentval));
					args.lastval = currentval;
				}
				break;
			}
		case "QAngle":
		case "Vector":
			{
				if((currentval-args.lastval).Length() >= 0.0001)
				{
					changed = true;
					Printer(args.player,CmdMessages.Debug.WatchCurrentValue(ind,args.handlename,args.netprop,currentval.ToKVString()));
					args.lastval = currentval;
				}
				break;
			}
		case "array":
			{
				if(currentval == null || currentval.len() != args.lastval.len())
				{
					changed = true;
					Printer(args.player,CmdMessages.Debug.WatchCurrentValue(ind,args.handlename,args.netprop,currentval));
					args.lastval = currentval;
				}
				else
				{
					for(local i=0;i<currentval.len();i++)
					{
						if(currentval[i] != args.lastval[i])
						{
							changed = true;
							Printer(args.player,CmdMessages.Debug.WatchCurrentValue(ind,args.handlename,args.netprop,currentval));
							args.lastval = currentval;
							break;
						}
					}
				}
				break;
			}
		default:
			{
				if(currentval != args.lastval)
				{
					changed = true;
					Printer(args.player,CmdMessages.Debug.WatchCurrentValue(ind,args.handlename,args.netprop,currentval));
					args.lastval = currentval;
				}
				break;
			}
	}
	if(changed)
	{
		local timername = args.timername+args.netprop+args.timersep+ind;
		if(timername in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
			delete ::VSLib.Timers.TimersID[timername];

			::VSLib.Timers.AddTimerByName(timername,args.checksec,true,WatchNetPropMain,args)
		}
	}

}

::TryRemoveWNetTimers <- function(args)
{
	local ind = args.entlooked.GetIndex();
	local l = Constants.TimerNames.WatchNetPropScriptHandle.len()
	foreach(timername,i in ::VSLib.Timers.TimersID)
	{
		if(timername.find(Constants.TimerNames.WatchNetPropScriptHandle) != null 
			&& timername.find(">") != null
			&& split(timername,">")[1].tointeger() == ind)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
			delete ::VSLib.Timers.TimersID[timername];

			local netpropname = split(timername,">")[0]
			netpropname = netpropname.slice(l,netpropname.len())
			
			Printer(args.player,CmdMessages.Debug.WatchRemove(ind,netpropname))
		}
	}
}

/*
 * @authors rhino
 */
::AdminSystem.StopWatchNetPropCmd <- function(player,args)
{
	
	local entlooked = GetArgument(2) ? GetArgument(2) 
									 : player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if(entlooked == null)
	{	
		Printer(player,CmdMessages.Debug.WatchNoEntity())
		return;
	}

	if(typeof entlooked == "string")
	{
		entlooked = Entity(entlooked)
		if(entlooked == null || !entlooked.IsEntityValid())
		{
			Printer(player,CmdMessages.Debug.WatchNoEntity())
			return;
		}
	}

	local netprop = GetArgument(1)
	if(netprop == null)
	{
		return;
	}

	if(netprop.find("&") != null)
	{
		local handlename = null
		
		netprop = split(netprop,"&")
		handlename = netprop[0]

		if(!(handlename in ::NetPropTables))
		{
			Printer(player,CmdMessages.Debug.WatchUnknownHandle(handlename))
			return;
		}
		
		// TO-DO : Find a reliable way
		local trytimes = 7
		local intv = 0.5
		for(local i=0;i<trytimes;i++)
		{
			::VSLib.Timers.AddTimer(0.1 + intv * i,false,TryRemoveWNetTimers,{player=player,entlooked=entlooked})
		}
		return;
	}
	else
	{
		if(!entlooked.HasNetProp(netprop))
		{
			Printer(player,CmdMessages.Debug.WatchDoesntHaveNetProp(netprop,entlooked.GetIndex(),entlooked.GetClassname()));
			return;
		}
	}

	local ind = entlooked.GetIndex();
	local timername = Constants.TimerNames.WatchNetProp+netprop+"_"+ind;

	if(timername in ::VSLib.Timers.TimersID)
	{
		::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[timername]);
		delete ::VSLib.Timers.TimersID[timername];

		Printer(player,CmdMessages.Debug.WatchRemove(ind,netprop))
	}
	else
	{
		Printer(player,CmdMessages.Debug.WatchNothingToRemove(ind,netprop))
	}
}

/*
 * @authors rhino
 */
::AdminSystem.FlagLookUpCmd <- function(player,args)
{
	
	local prefix = GetArgument(1);
	local val = GetArgument(2);

	if(prefix == null)
		return;

	if(val != null)
	{
		try
		{
			val = val.tointeger()
		}
		catch(e)
		{
			Printer(player,CmdMessages.Debug.FlagLookupFailure(val))
			return;
		}
	}

	Printer(player,CmdMessages.Debug.FlagLookupSuccess(Constants.ConstStrLookUp(prefix,val)))
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
		printR("[Client-broadcast]Executing client command on "+client_character+"->"+command);	
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
		AdminSystem._Clientbroadcast(character,"echo ....vvvvvvvvvvvvvvvvvvvv...COMMAND OUTPUT BELOW...vvvvvvvvvvvvvvvvvvvv....",1,!reporttohost);

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
		AdminSystem._Clientbroadcast(character,"echo ....^^^^^^^^^^^^^^^^^^^^...COMMAND OUTPUT ABOVE...^^^^^^^^^^^^^^^^^^^^....",1,!reporttohost,delay_end_msg);

	if(reporttohost && msgtype!="debug" && !(Utils.GetPlayerFromName(character).GetSteamID() in ::AdminSystem.HostPlayer))
		printR("[Broadcast] Printed to "+character+" ("+msgtype+"):"+message);
}

/*
 * @authors rhino
 * Execute commands in host's client
 */
::AdminSystem.Server_execCmd <- function(player, args)
{	
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
	if(linesource == "!random" || linesource == "random")
	{
		linesource = Utils.GetRandValueFromArray(AdminSystem.Vars.CharacterNamesLower);
		while(linesource == "" || linesource == "survivor")
			linesource = Utils.GetRandValueFromArray(AdminSystem.Vars.CharacterNamesLower);
	}
	else if(linesource == "self" || linesource == "!self")
		linesource = null

	// Speaker selection
	switch(targetname)
	{
		case "!random":
		case "random":
		{	
			targetname = Utils.GetRandValueFromArray(Players.AliveSurvivors()).GetCharacterNameLower();
			speaker = Utils.GetPlayerFromName(targetname);
			break;
		}
		case "!self":
		case "self":
		{
			targetname = name;
			speaker = player;
			break;
		}
		case "!picker":
		case "picker":
		{
			targetname = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);

			if(targetname == null){return;}
			if(targetname.GetClassname() != "player"){return;}
		
			targetname = targetname.GetCharacterNameLower();
			speaker = Utils.GetPlayerFromName(targetname);
			break;
		}
		default:
		{
			if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,targetname) == -1)
			{
				Messages.ThrowPlayer(player,Messages.BIM.NotACharacter(GetArgument(1)));
				::SpellChecker.Levenshtein(3,3,"character name").PrintBestMatches(player.GetBaseEntity(),GetArgument(1),Utils.ArrayToTable(AdminSystem.Vars.CharacterNamesLower.slice(0,8)))
				return;
			}
			else
				speaker = Player("!"+targetname);
			break;
		}
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
	
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
	
	local name = player.GetCharacterNameLower();	
	local red = GetArgument(1);
	local green = GetArgument(2);
	local blue = GetArgument(3);
	local alpha = GetArgument(4);
	if (blue==null)
		return;

	if (alpha==null)
		alpha = 255.0;

	if(red == "!random")
		red = RandomInt(0,255).tostring()
	if(green == "!random")
		green = RandomInt(0,255).tostring()
	if(blue == "!random")
		blue = RandomInt(0,255).tostring()
	if(alpha == "!random")
		alpha = RandomInt(0,255).tostring()

	ent.SetColor(red,green,blue,alpha);

	Printer(player,CmdMessages.Color(red,green,blue,alpha,ent.GetIndex()));
}

/*
 * @authors rhino
 */
::AdminSystem.SetkeyvalCmd <- function ( player, args )
{
	
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
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
	local name = player.GetCharacterNameLower();
	local typename = GetArgument(1);
	local setting = GetArgument(2);
	local valorflag = GetArgument(3);
	local val = GetArgument(4);
	if (val != null)
	{	
		if(typename=="ptr")
		{
			typename = AdminSystem.Vars._prop_spawn_settings_menu_type[name];
		}
		
		val = CastCustomSetting(player,["val",val]);
		if(valorflag[0].tochar() == "+") // Add flags or bitwise operation with a value
		{
			valorflag = valorflag.slice(1,valorflag.len());
			if(typename=="all")
			{
				AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag] | val;
				AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag] | val;
				AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag] | val;
			}
			else
				AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag] | val;

		}
		else if(valorflag[0].tochar() == "-")	// Remove flags or bitwise operation with a value
		{
			valorflag = valorflag.slice(1,valorflag.len());
			if(typename=="all")
			{
				AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag] & ~val;
				AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag] & ~val;
				AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag] & ~val;
			}
			else
				AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag] = AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag] & ~val;

		}
		else
		{
			if(typename=="all")
			{
				AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag] = val;
				AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag] = val;
				AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag] = val;
			}
			else
				AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag] = val;

		}
		if(typename=="all")
		{
			Printer(player,CmdMessages.Prop.SettingSuccess("physics",setting,valorflag,AdminSystem.Vars._prop_spawn_settings[name]["physics"][setting][valorflag]));
			Printer(player,CmdMessages.Prop.SettingSuccess("dynamic",setting,valorflag,AdminSystem.Vars._prop_spawn_settings[name]["dynamic"][setting][valorflag]));
			Printer(player,CmdMessages.Prop.SettingSuccess("ragdoll",setting,valorflag,AdminSystem.Vars._prop_spawn_settings[name]["ragdoll"][setting][valorflag]));
		}
		else
		{
			Printer(player,CmdMessages.Prop.SettingSuccess(typename,setting,valorflag,AdminSystem.Vars._prop_spawn_settings[name][typename][setting][valorflag]));
		}
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
	
	local name = player.GetCharacterNameLower();
	local infostr = "";
	local typename = GetArgument(1);

	if(typename == null || typename == "all")
	{
		infostr += CmdMessages.PropSpawn.Start(name);
		foreach(typename,setting_val in AdminSystem.Vars._prop_spawn_settings[name])
		{
			infostr += CmdMessages.PropSpawn.Type(typename);
			foreach(setting,val in setting_val)
			{
				infostr += CmdMessages.PropSpawn.Details(setting,val);
			}
		}
	}
	else 
	{	
		if(typename == "ptr")
			typename = AdminSystem.Vars._prop_spawn_settings_menu_type[name];

		infostr += CmdMessages.PropSpawn.Start(name) + CmdMessages.PropSpawn.Type(typename);
		foreach(setting,val in AdminSystem.Vars._prop_spawn_settings[name][typename])
		{
			infostr += CmdMessages.PropSpawn.Details(setting,val);
		}
	}
	Printer(player,infostr);
}

/*
 * @authors rhino
 */
::AdminSystem.Save_particleCmd <- function(player, args)
{	
	
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
	
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
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
	
	local name = player.GetCharacterNameLower();
	if (AdminSystem.Vars._saveLastParticle[name])
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
		Messages.ThrowPlayer(player,CmdMessages.Particles.NoneSaved());
	}
}

/*
 * @authors rhino
 */
::AdminSystem.Attach_particle_savedCmd <- function ( player, args )
{
	
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
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
	local name = player.GetCharacterNameLower()
	local entid = AdminSystem.Vars._wornHat[name].entid;
	if(entid == "")
		return;

	local ent = Entity(entid);
	local colgroup = AdminSystem.Vars._wornHat[name].collisiongroup;

	if(!ent.IsEntityValid())
		return;
	
	AdminSystem.Vars._wornHat[name].entid = "";
	ent.SetNetProp("m_CollisionGroup",colgroup);

	_LetGoAndDropOrYeet(ent,name,"_dropit")
	
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
	
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if( ent == null)
		return;

	if (!ent.IsEntityValid())
		return;
	
	if(ent.GetParent() != null)
		return; 

	if(Utils.CalculateDistance(ent.GetOrigin(),player.GetEyePosition()) > 250)
		return;

	local entclass = ent.GetClassname();

	if(entclass == "player" || entclass == "witch")
		return;
	// Not in table, in the table but disabled
	if(!(entclass in AdminSystem.Vars._grabAvailable))
	{	
		// It's not even a weapon spawn
		if(entclass.find("weapon_") == null)
			return
	}
	else if(!AdminSystem.Vars._grabAvailable[entclass])
		return

	if(ent.HasBadPhysicsModel())
		return

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
	ent.SetNetProp("m_pParent",player.GetBaseEntity())	// Hack
	DoEntFire("!self", "setparentattachmentmaintainoffset", pos, 0, null, ent.GetBaseEntity());
	ent.SetOrigin(player.GetEyePosition()+vec+survivorfw);
	ent.SetAngles(RotateOrientation(player.GetEyeAngles(),QAngle(HatParameters.pitch,HatParameters.yaw,HatParameters.roll)))	
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
	local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	if(ent == null)
		return;

  	ent.SetForwardVector(player.GetForwardVector());
}

/*
 * @authors rhino
 * Attach the targeted entity around players arms, make it look and move like player is holding it
 */
::AdminSystem.GrabCmd <- function ( player, args )
{
	local ent = null
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
	
	if(player.IsDriving() || player.IsPassenger())
	{
		::Messages.ThrowPlayer(player,"You can't grab things while you are driving!")
		return
	}

	ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK);
	local lookedpoint = player.GetLookingLocation(GRAB_YEET_TRACE_MASK);
	local entind = null;
	local objtable = null;
	local entclass = null;
	local entmodel = null;
	local taken = null;
	local closestgrabbed = false;
	local player_has_parent = player.GetParent() != null
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

				if(obj.GetIndex() == player.GetIndex())
					continue;

				entclass = obj.GetClassname();	
				entmodel = obj.GetModel();

				// Not in table, in the table but disabled
				if(!(entclass in AdminSystem.Vars._grabAvailable))
				{	
					// It's not even a weapon spawn
					if(entclass.find("weapon_") == null)
						continue
				}
				else if(!AdminSystem.Vars._grabAvailable[entclass])
					continue
				
				if(obj.HasBadPhysicsModel())
					continue

				entind = obj.GetIndex().tostring();

				if(entclass == "player")
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
		
		// Not in table, in the table but disabled
		if(!(entclass in AdminSystem.Vars._grabAvailable))
		{	
			// It's not even a weapon spawn
			if(entclass.find("weapon_") == null)
				return
		}
		else if(!AdminSystem.Vars._grabAvailable[entclass])
			return
		
		if(ent.HasBadPhysicsModel())
			return	

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
        
        // Hack: Helps getting rid of delay
        ent.SetNetProp("m_pParent",player.GetBaseEntity())
		DoEntFire("!self", "setparentattachmentmaintainoffset", tbl_heldEnt.grabAttachPos, 0, null, ent.GetBaseEntity());
		AdminSystem.Vars._heldEntity[player.GetCharacterNameLower()].entid = entind;
	}
	
}

/*
 * @authors rhino
 * Drops the entity held by player
 */
::AdminSystem.LetgoCmd <- function ( player, args )
{
	local name = player.GetCharacterNameLower();

	if(AdminSystem.Vars._heldEntity[name].entid == "")
		return;

	local baseent = Ent("#"+AdminSystem.Vars._heldEntity[name].entid);
	if(baseent == null)
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}

	local ent = ::VSLib.Entity(baseent);
	
	local entclass = null;

	if(!ent.IsEntityValid())
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}
	
	if(ent.GetParent() == null)
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}
	else
	{
		_LetGoAndDropOrYeet(ent,name,"_dropit")
	}

}

/*
 * @authors rhino
 * YEET
 */
::AdminSystem.YeetCmd <- function ( player, args )
{
	
	local name = player.GetCharacterNameLower();
	if(AdminSystem.Vars._heldEntity[name].entid == "")
		return;
	
	local baseent = Ent("#"+AdminSystem.Vars._heldEntity[name].entid);
	if(baseent == null)
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}
	
	local ent = ::VSLib.Entity(baseent);
	local entclass = null;
	if(!ent.IsEntityValid())
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}

	if(ent.GetParent() == null)
	{
		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}
	else
	{
		_LetGoAndDropOrYeet(ent,name,"_yeetit",",Player("+player.GetIndex()+")")
	}

}

::_LetGoDropYeetSpecialClasses <-
{
	prop_fuel_barrel = true
	prop_car_alarm = true
}

::_LetGoAndDropOrYeet <- function(ent,name,func,extra_arg="")
{
	
	ent.Input("ClearParent","",0);
	local entclass = ent.GetClassname();

	if(entclass == "player")
	{
		ent.SetMoveType(MOVETYPE_WALK);
		ent.Input("RunScriptCode",func+"(Entity("+ent.GetIndex()+")"+extra_arg+")",0.033);
	}
	else if(entclass.find("weapon_") != null) // a weapon spawner or a weapon
	{
		if(entclass.find("spawn") == null)
		{
			if(ent.GetSpawnFlags() % 2 == 1 && (entclass in {weapon_molotov=1,weapon_pistol=1}))
			{
				ent.SetSpawnFlags(ent.GetSpawnFlags()-1);
			}
			ent.Input("RunScriptCode",func+"(Entity("+ent.GetIndex()+")"+extra_arg+")",0.033);
		}
	}
	else if(entclass.find("physics") != null || entclass in ::_LetGoDropYeetSpecialClasses) // physics entity
	{
		if( entclass == "prop_physics_multiplayer" || entclass == "prop_physics" || entclass in ::_LetGoDropYeetSpecialClasses)
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
		ent.Input("RunScriptCode",func+"(Entity("+ent.GetIndex()+")"+extra_arg+")",0.033);
	}
	else // non physics, try creating entity with its model
	{
		local new_ent = null;
		local keyvals = 
		{
			classname = RagdollOrPhysicsDecider(ent.GetModel()),
			model = ent.GetModel(),
			origin = ent.GetOrigin(),
			angles = ent.GetAngles(),
		};
		
		new_ent = Utils.CreateEntityWithTable(keyvals);
		
		if(new_ent != null)
		{
			if(keyvals.classname == "prop_ragdoll")
				new_ent.SetNetProp("m_CollisionGroup",1)

			local skin = ent.GetNetProp("m_nSkin");
			local color = ent.GetNetProp("m_clrRender");
			local scale = ent.GetModelScale();
			RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
			new_ent.Input("RunScriptCode",func+"(Entity("+new_ent.GetIndex()+")"+extra_arg+")",0.033);
		}
		else
		{
			if(keyvals.classname.find("physics") != null)
			{	
				switch(::CheckPhysicsAvailabilityForModel(keyvals.model,null,DoDummyConversionProcess,{ent=ent,func=func,extra_arg=extra_arg}))
				{
					case false:
						if(AdminSystem.Vars._grabbackupprop.enabled)
						{
							local keyvals = 
							{
								classname = AdminSystem.Vars._grabbackupprop.classname,
								model = AdminSystem.Vars._grabbackupprop.modelname,
								origin = ent.GetOrigin(),
								angles = ent.GetAngles(),
							};
							
							local new_ent = Utils.CreateEntityWithTable(keyvals);
							if(!new_ent || !new_ent.IsEntityValid())
							{
								Printer(Player("!"+name),TXTCLR.OG(new_ent.GetModel())+" can't be used as a physics object! Failed to create the backup prop!")
							}
							else
							{
								if(keyvals.classname == "prop_ragdoll")
									new_ent.SetNetProp("m_CollisionGroup",1)

								local skin = ent.GetNetProp("m_nSkin");
								local color = ent.GetNetProp("m_clrRender");
								local scale = ent.GetModelScale();
								RecreateHierarchy(ent,new_ent,{color=color,skin=skin,scale=scale,name=ent.GetName()});
								new_ent.Input("RunScriptCode",func+"(Entity("+new_ent.GetIndex()+")"+extra_arg+")",0.033);
								Printer(Player("!"+name),CmdMessages.Prop.Success("physicsM",new_ent));
								ent.Kill()
							}
						}
						else
						{
							Printer(Player("!"+name),TXTCLR.OG(ent.GetModel())+" can't be used as a physics object!")
						}
						break
					case true:
						DoDummyConversionProcess({ent=ent,func=func,extra_arg=extra_arg})
						break;
					case null:
						break;
				}
			}
			else
			{
				Printer(Player("!"+name),TXTCLR.OG(keyvals.model)+" can't be used as a ragdoll/physics object!")
			}
		}

		AdminSystem.Vars._heldEntity[name].entid = "";
		return;
	}

	AdminSystem.Vars._heldEntity[name].entid = "";
}

::DoDummyConversionProcess <- function(args)
{
	local ent = args.ent
	local func = args.func
	local extra_arg = args.extra_arg
	local skin = ent.GetNetProp("m_nSkin");
	local color = ent.GetNetProp("m_clrRender");
	local scale = ent.GetModelScale();

	local cuniq = UniqueString();

	local oldind = ent.GetIndex()

	local oldname = ent.GetName()
	ent.SetName(ent.GetName()+UniqueString())
	local searchname = ent.GetName()

	local org = ent.GetOrigin()

	local dummyent = Utils.CreateEntityWithTable({classname="prop_dynamic_override",model="models/props_misc/pot-1.mdl",origin=org,angles=QAngle(0,0,0),Solid=6,spawnflags=8,targetname=cuniq})
	dummyent.SetRenderMode(RENDER_NONE);
	dummyent.SetNetProp("m_CollisionGroup",1)
	dummyent.SetNetProp("m_clrRender",color);
	dummyent.SetNetProp("m_nSkin",skin);
	dummyent.SetModelScale(scale);

	AddThinkToEnt(dummyent.GetBaseEntity(),"PostConvertChecker")

	ConvertCheckTable[dummyent.GetName()] <- {oldname=oldname,searchname=searchname,dummytime=Time(),func=func,extra_arg=extra_arg,angles=ent.GetAngles()}

	local convertername = ::Constants.Targetnames.PhysConverter+cuniq
	local converter = Utils.CreateEntityWithTable({classname="phys_convert",targetname=convertername,target="#"+oldind,spawnflags=3})
	converter.Input("converttarget")
	converter.Input("Kill")
}

::ConvertCheckTable <- {}

::PostConvertChecker<-function(...)
{
	local name = self.GetName()
	if(!(name in ConvertCheckTable))
		return;

	if("Done" in self.GetScriptScope())
	{
		local res = self.GetScriptScope()["Done"]

		local ent = Entity(self.GetEntityIndex())
		ent.Input("Kill")
		
		return;
	}

	local thinktime = Time()
	//ClientPrint(null,3,(thinktime-ConvertCheckTable[name].dummytime).tostring())
	local searchname = ConvertCheckTable[name].searchname
	if(thinktime-ConvertCheckTable[name].dummytime > 0.3)
	{
		self.GetScriptScope()["Done"] <- false
		AddThinkToEnt(self,null);
		local ent = Entity(self.GetEntityIndex())
		ent.Input("Kill")
		if(AdminSystem.Vars._grabbackupprop.enabled)
		{
			local keyvals = 
			{
				classname = AdminSystem.Vars._grabbackupprop.classname,
				model = AdminSystem.Vars._grabbackupprop.modelname,
				origin = ent.GetOrigin(),
				angles = ent.GetAngles(),
			};
			
			local new_ent = Utils.CreateEntityWithTable(keyvals);
			new_ent.Input("RunScriptCode",ConvertCheckTable[name].func+"(Entity("+new_ent.GetIndex()+")"+ConvertCheckTable[name].extra_arg+")",0);
		}

		if(name in ConvertCheckTable)
			delete ConvertCheckTable[name]
		return;
	}
	foreach(obj in Objects.OfName(searchname))
	{
		if(obj.GetClassname() == "simple_physics_prop")
		{
			self.GetScriptScope()["Done"] <- true
			AddThinkToEnt(self,null);
			local ent = Entity(self.GetEntityIndex())
			local skin = ent.GetNetProp("m_nSkin");
			local color = ent.GetNetProp("m_clrRender");
			local scale = ent.GetModelScale();

			obj.SetOrigin(self.GetOrigin())
			obj.SetNetProp("m_CollisionGroup",0)
			obj.SetNetProp("m_clrRender",color);
			obj.SetNetProp("m_nSkin",skin);
			obj.SetModelScale(scale);
			obj.SetName(ConvertCheckTable[name].oldname)
			obj.Input("RunScriptCode",ConvertCheckTable[name].func+"(Entity("+obj.GetIndex()+")"+ConvertCheckTable[name].extra_arg+")",0);
			obj.Input("RunScriptCode","self.SetAngles(ConvertCheckTable[\""+name+"\"].angles)",0.1);
			return;
		}
	}
}

::_dropit <- function(ent)
{
	local movetype;
	switch(ent.GetClassname()) 
	{
		case "player": movetype = MOVETYPE_WALK; break;
		case "witch": movetype = MOVETYPE_ZOMBIE_DEFAULT; break;
		default: movetype = MOVETYPE_VPHYSICS; break;
	} 

	local a=ent.GetOrigin();
	if(ent.GetBaseEntity() != null && "ResetSequence" in ent.GetBaseEntity())
	{
		local seq = ent.GetBaseEntity().GetSequence()
		ent.GetBaseEntity().ResetSequence(seq);
		/*
		ent.GetBaseEntity().SetSequence(0);
		DoEntFire("!self","runscriptcode","self.SetSequence("+seq+")",0.1,null,ent.GetBaseEntity());*/
	}
	//ent.Input("wake","",0);
	ent.SetMoveType(movetype);
	ent.SetOrigin(a);
	ent.SetVelocity(Vector(0,0,0));
	if(ent.GetParent() != null)
	{
		DoEntFire("!self","clearparent","",0,null,ent.GetBaseEntity())
		DoEntFire("!self","runscriptcode","self.ApplyAbsVelocityImpulse(Vector(0,0,1))",0.04,null,ent.GetBaseEntity())
		return false
	}
	else
		ent.Push(Vector(0,0,1))
	return true;
}
::_yeetit <- function(ent,p)
{	
	local fwvec = RotateOrientation(p.GetEyeAngles(),QAngle(AdminSystem.Vars._heldEntity[p.GetCharacterNameLower()].yeetPitch,0,0)).Forward();
	fwvec = fwvec.Scale(AdminSystem.Vars._heldEntity[p.GetCharacterNameLower()].yeetSpeed/fwvec.Length());
	if(_dropit(ent))
	{
		ent.Push(fwvec)
	}
	else
	{
		DoEntFire("!self","runscriptcode","self.ApplyAbsVelocityImpulse(Vector("+fwvec.x+","+fwvec.y+","+fwvec.z+"))",0.05,null,ent.GetBaseEntity())
	}
}
::deltimer <- function(name)
{
	::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID[name]);
	delete ::VSLib.Timers.TimersID[name];
}

::RecreateHierarchy <- function(oldparent,newparent,other,killold=true)
{
	// Create a copy of the old hierarchy
	local firstchild = oldparent.FirstMoveChild();
	while(firstchild != null)
	{
		// Parent the new child
		local locorg = firstchild.GetLocalOrigin();
		local locang = firstchild.GetLocalAngles();

		firstchild.Input("clearparent","",0);
		firstchild.Input("setparent","#"+newparent.GetIndex(),0.03);
		firstchild.Input("runscriptcode","self.SetLocalOrigin(Vector("+locorg.x+","+locorg.y+","+locorg.z+"))",0.1);
		firstchild.Input("runscriptcode","self.SetLocalAngles(QAngle("+locang.x+","+locang.y+","+locang.z+"))",0.1);
		
		// Move the next child in the same level
		firstchild = firstchild.NextMovePeer();
	}

	// Remove old hierarchy
	if(killold)
		oldparent.KillDelayed(0.1);

	newparent.SetName(other.name);
	newparent.SetNetProp("m_clrRender",other.color);
	newparent.SetNetProp("m_nSkin",other.skin);
	newparent.SetModelScale(other.scale);
}


/*
 * @authors rhino
 */
::AdminSystem.SodaCanCmd <- function(player,args)
{
	
	local pscr = null;
	local looked = player.GetLookingLocation()
	local keyvals = 
	{
		targetname = ::Constants.Targetnames.SodaCan + UniqueString()
		classname = "prop_dynamic_override",
		origin=looked,
		angles=QAngle(0,0,0),
		massScale=1,
		Solid="6",
		spawnflags=8,
		post={}
	}

	local MDL = ">soda_can"
	local e_g = GetSpecialModelOptions(player,MDL,keyvals)
	if(typeof e_g == "string")
	{
		MDL = e_g
		keyvals.model <- MDL
	}
	else
	{
		Printer(player,"Something went wrong...");
		return
	}

	local can = Utils.CreateEntityWithTable(keyvals);
	if(!can)
	{
		Printer(player,"Something went wrong...");
		return
	}
	local cuniq = UniqueString()
	local oldind = can.GetIndex()
	local thinker = Utils.CreateEntityWithTable({targetname=cuniq,classname="info_target",origin=keyvals.origin,angles=keyvals.angles,spawnflags=0})
	PropFailureFixCheck[thinker.GetName()] <- {id=can.GetIndex(),thinkstart=Time(),israndom=false,pid=player.GetIndex(),character=player.GetCharacterNameLower(),searchname=can.GetName()}

	local convertername = ::Constants.Targetnames.PhysConverter+cuniq
	local converter = Utils.CreateEntityWithTable({classname="phys_convert",targetname=convertername,target="#"+oldind,spawnflags=3})
	converter.Input("converttarget")
	converter.Input("Kill")
	AddThinkToEnt(thinker.GetBaseEntity(),"PropTryFindSimplePhysSingle")


	keyvals = 
	{
		classname = "point_script_use_target",
		model = can.GetName(), 
		origin = Vector(0,0,0)
	};

	local restorehp = GetArgument(1) ? GetArgument(1).tofloat() : 5

	local duration = GetArgument(2) ? GetArgument(2).tofloat() : 1
	if(duration < 0)
		duration = 1

	::VSLib.Timers.AddTimer(0.5,false,CreateUseTargetDelayed,{keyvals=keyvals,restorehp=restorehp,duration=duration})
}

::CreateUseTargetDelayed <- function(args)
{
	local keyvals = args.keyvals
	local restorehp = args.restorehp
	local duration = args.duration
	
	local pscr = Utils.CreateEntityWithTable(keyvals,null,false);

	if(!pscr)
		return

	local names = ["Coca-cola","Red Bull","Sprite","Fanta","Pepsi","Dr. Pepper","Gatorade","7-Up"]
	local b = pscr.GetBaseEntity()
	local bsrc = pscr.GetScriptScope()

	bsrc["RestoreHealth"] <- restorehp
	bsrc["Duration"] <- duration
	bsrc["FinishDrink"] <- function()
	{
		self.CanShowBuildPanel( false );

		local p = self.GetScriptScope().LastPlayer
		local c = ::VSLib.Entity(self.GetUseModelName())

		c.Kill()
		DoEntFire("!self","kill","",0,null,self)

		local newhp = p.GetHealth() + self.GetScriptScope().RestoreHealth
		if (newhp > p.GetMaxHealth())
			newhp = p.GetMaxHealth()

		p.SetHealth(newhp);
	}
	bsrc["Started"] <- function()
	{
		local user = self.GetScriptScope().PlayerUsingMe
		local player = null
		if(user == 0)
			self.StopUse()
		else
		{
			while( player = Entities.FindByClassname( player, "player" ))
			{
				if( player.GetEntityHandle() == user )
				{
					self.GetScriptScope()["LastPlayer"] <- ::VSLib.Player(player)
					return
				}
			}
		}
	}

	b.CanShowBuildPanel(true)
	b.SetProgressBarText(Utils.GetRandValueFromArray(names))
	b.SetProgressBarSubText("Drink to restore "+restorehp+" HP!")
	
	b.SetProgressBarFinishTime(duration)

	b.ConnectOutput("OnUseStarted","Started")
	pscr.Input("AddOutput","OnUseFinished !self,CallScriptFunction,FinishDrink,0,1")
}

/*
 * @authors rhino
 */
::AdminSystem.FireExtinguisherCmd <- function(player,args)
{
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
	local enumstr = ::AdminSystem._GetEnumString(ptc.GetIndex()+"__"+steam_sound.GetIndex());

	ent.Input("addoutput","OnTakeDamage !self,RunScriptCode,Fire_Ex_OnTakeDamage(" + enumstr + "),0,1",0.1);
	
	AddThinkToEnt(steam_sound.GetBaseEntity(),"Fire_Ex_ReAttach");

	// TO-DO: Add a phys_motor to create rotating motion from steam 

	Printer(player,CmdMessages.FireEx.Success(entind,ptc.GetIndex(),steam_sound.GetIndex()));
}

::Fire_Ex_ReAttach <- function()
{
	local ind = self.GetEntityIndex();
	local s = Entity(ind);
	local baseind = s.GetName();
	if(!s.IsEntityValid() || baseind.find("projectSmokFireExSound_") == null)
	{
		//::AdminSystem.out("steam and parent name invalid...")
		AddThinkToEnt(self,null);
		return true;
	}

	baseind = split(baseind,"_")[1].tointeger();
	//::AdminSystem.out(baseind);

	if(!Entity(baseind).IsEntityValid())
	{
		//::AdminSystem.out("parent invalid...")
		if(s.GetParent() == null)
		{
			AddThinkToEnt(self,null);
			return true;
		}
		s.SetName("projectSmokFireExSound_"+s.GetParent().GetIndex());
	}
	else if(s.GetParent() == null)
	{
		//::AdminSystem.out("no parent...")
		return true;
	}
	else if(s.GetParent().GetIndex() == baseind)
	{
		//::AdminSystem.out("same parent");
		return true;
	}

	//::AdminSystem.out("parent changed...")
	local p = Objects.AnyOfName("projectSmokFireExParticle_"+baseind);
	if(p == null)
	{
		//::AdminSystem.out("no particle child found...")
		AddThinkToEnt(self,null);
		return true;
	}

	p.SetName("projectSmokFireExParticle_"+s.GetParent().GetIndex());

	//::AdminSystem.out("Validated children...")

	local newparent = s.GetParent();

	//::AdminSystem.out("Reattaching outputs to " + "\x03" + "#"+newparent.GetIndex())
	
	newparent.Input("addoutput","OnTakeDamage !self,RunScriptCode,Fire_Ex_OnTakeDamage(" + ::AdminSystem._GetEnumString(p.GetIndex()+"__"+s.GetIndex()) + "),0,1",0.1);
	
	return true;

}

::Fire_Ex_OriginWrap <- function(args){args.ent.SetLocalOrigin(Vector(3,-1,10));}

::Fire_Ex_OnTakeDamage <- function(inds)
{
	//::AdminSystem.out("Took damage! " + inds)
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
	
	if(setting == "entid")
		return;

	if(!(setting in AdminSystem.Vars._heldEntity[name.tolower()]))
	{
		::SpellChecker.Levenshtein(3,3,"setting").PrintBestMatches(player.GetBaseEntity(),setting,AdminSystem.Vars._heldEntity[name.tolower()])
		return;
	}

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
		Messages.ThrowPlayer(player,CmdMessages.GrabYeet.UnknownAttachmentPoint(val));
		::SpellChecker.Levenshtein(5,4,"character name").PrintBestMatches(player.GetBaseEntity(),val,Utils.ArrayToTable(attachment_names))
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
	local oldval = Convars.GetFloat("sv_cheats");
	Convars.SetValue("sv_cheats",(1-oldval).tointeger());

	//printl(player.GetCharacterName() +" Updated sv_cheats:"+(1-oldval).tointeger());
}

/*
 * @authors rhino
 */
::AdminSystem.Update_custom_response_preferenceCmd <- function ( player, args )
{
	local newstate = !::AdminSystem.Vars.AllowCustomResponses;
	::AdminSystem.Vars.AllowCustomResponses = newstate;

	Messages.InformAll(player.GetCharacterName()+( newstate ? "\x03"+" enabled"+"\x01":"\x04"+" disabled"+"\x01") + " custom responses");
}

/*
 * @authors rhino
 */
::AdminSystem.Update_custom_sharing_preferenceCmd <- function ( player, args )
{
	local newstate = !::AdminSystem.Vars.AllowCustomSharing;
	::AdminSystem.Vars.AllowCustomSharing = newstate;

	Messages.InformAll(player.GetCharacterName()+( newstate ? "\x03"+" enabled"+"\x01":"\x04"+" disabled"+"\x01")+" custom sharing");
}

::LongProcessIterAvailability <-
{
	zero_g = true
	give_physics = true
	create_loot_sources = true
}

/*
 * @authors rhino
 */
::AdminSystem.ZeroGCmd <- function ( player, args )
{
	if(!::LongProcessIterAvailability.zero_g || !::LongProcessIterAvailability.give_physics)
	{
		Printer(player,"You can't use this command while one or both zero_g and give_physics processes are still running!")
		return
	}
	local targets = GetArgument(1);
	
	if(targets == null || targets == "!picker")
	{
		local ent = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)

		if(!::ZeroGValidate(ent))
			return

		if(!::CheckPhysicsAvailabilityForModel(ent.GetModel(),ent,GetRidOfGravity))
			return

		GetRidOfGravity(ent)
	}
	else if(targets == "all")
	{
		::LongProcessIterAvailability.zero_g = false
		local i = 0
		local maxproc = getconsttable()["ZG_MAX_PROCESS"]
		local maxiter = getconsttable()["ZG_MAX_ITER"]

		local objs = Utils.TableToArray(Objects.All())
		
		local all_len = objs.len()
		local last_index = 0
		local keepiter = false
		
		foreach(idx, ent in objs)
		{
			last_index = idx
			if(idx >= maxiter)
			{
				keepiter = true
				break;
			}

			if(!::ZeroGValidate(ent))
				continue

			if(!::CheckPhysicsAvailabilityForModel(ent.GetModel(),ent,GetRidOfGravity))
				continue

			i += 1
			if(i > maxproc)
			{
				keepiter = true
				break;
			}
			GetRidOfGravity(ent)
		}

		if(last_index != all_len-1)
		{
			objs = objs.slice(last_index)
		}
		if(keepiter)
		{
			Timers.AddTimer(0.4,false,DoZeroGIter,{total=all_len,left=objs.len(),objs=objs})
		}
		else
		{	
			::LongProcessIterAvailability.zero_g = true
			::AdminSystem.out("Zero-G Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
		}
	}
	else
	{
		local ent = Entity(targets)

		if(!::ZeroGValidate(ent))
			return
		
		if(!::CheckPhysicsAvailabilityForModel(ent.GetModel(),ent,GetRidOfGravity))
			return

		GetRidOfGravity(ent)
	}
}

::ZeroGValidate <- function(ent)
{
	if(ent == null || !ent.IsEntityValid())
		return false

	local entcls = ent.GetClassname()

	if( !ent.IsEntityValid()
		|| ent.GetParent() != null
		|| !(entcls in ::ZeroGClassTable && ::ZeroGClassTable[entcls] && entcls.find("weapon") != 0))
		return false

	if(entcls.find("_spawn") != null)
		return false
		
	if(ent.HasBadPhysicsModel())
		return false

	if(SessionState.MapName in ::ZeroGMapSpecificBans
		&& 
		  ((
				ent.GetName() in ::ZeroGMapSpecificBans[SessionState.MapName].entities
					&& entcls == ::ZeroGMapSpecificBans[SessionState.MapName].entities[ent.GetName()].classname
					&& ent.GetEntityHandle() == Entity(::ZeroGMapSpecificBans[SessionState.MapName].entities[ent.GetName()].id).GetEntityHandle()
			)
			||
			(
				ent.GetModel().tolower() in ::ZeroGMapSpecificBans[SessionState.MapName].models 
			)
		  )
		)
		return false

	return true
}

::ZeroGClassTable <- 
{
	prop_car_alarm = true
	prop_physics = true
	prop_physics_multiplayer = true
	prop_physics_override = true
	func_physbox = true
	simple_physics_prop = true
	prop_fuel_barrel = true
}

::GetRidOfGravity <- function(e)
{
	local kvs = 
	{
		classname="item_sodacan"
		origin=Vector(0,0,0)
	}
	
	local tt = Utils.CreateEntityWithTable(kvs);
	local t = Utils.CreateEntityWithTable(kvs);
	t.SetRenderMode(RENDER_NONE)
	tt.SetRenderMode(RENDER_NONE)
	
	local ev = e.GetPhysicsVelocity()
	local ei = e.GetIndex()
	local tb = t.GetBaseEntity()

	e.SetMoveType(0)
	e.SetVelocity(Vector(0,0,0))

	DoEntFire("!self","setparent","#"+ei,0,null,tb)
	DoEntFire("#"+ei,"setparent","#"+tt.GetIndex(),0.05,null,tb)
	DoEntFire("#"+ei,"runscriptcode","self.ApplyAbsVelocityImpulse(Vector(0,0,-0.05))",0.1,null,tb)
	DoEntFire("#"+ei,"clearparent","",0.1,null,tb)
	DoEntFire("!self","runscriptcode","_dropit(Entity("+ei+"))",0.15,null,tb)
	DoEntFire("!self","clearparent","",0.2,null,tb)
	DoEntFire("#"+ei,"runscriptcode","self.ApplyAbsVelocityImpulse(Entity("+ei+").GetPhysicsVelocity().Scale(-1))",0.25,null,tb)
	DoEntFire("#"+ei,"runscriptcode","self.ApplyAbsVelocityImpulse(Vector("+ev.x+","+ev.y+","+ev.z+").Scale(0.6))",0.3,null,tb)
	DoEntFire("#"+ei,"runscriptcode","self.SetVelocity(Vector(0,0,0))",0.3,null,tb)

	DoEntFire("!self","kill","",0.5,null,tb)
}

::DoZeroGIter <- function(args={})
{
	::AdminSystem.out("Zero-G Progress: "+Utils.BuildProgressBar(20.0,((args.total-args.left).tofloat()/args.total.tofloat())*20.0,20.0,"|", ". "))
	local i = 0
	local maxproc = getconsttable()["ZG_MAX_PROCESS"]
	local maxiter = getconsttable()["ZG_MAX_ITER"]

	local kvs = 
	{
		classname="item_sodacan"
		origin=Vector(0,0,0)
	}

	local objs = args.objs
	
	local all_len = objs.len()
	local last_index = 0
	local keepiter = false

	if(all_len == 0)
	{	
		::LongProcessIterAvailability.zero_g = true
		::AdminSystem.out("Zero-G Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
		return;
	}

	foreach(idx, ent in objs)
	{
		last_index = idx
		if(idx >= maxiter)
		{
			keepiter = true
			break;
		}

		if(!::ZeroGValidate(ent))
			continue

		if(!::CheckPhysicsAvailabilityForModel(ent.GetModel(),ent,GetRidOfGravity))
			continue

		i += 1
		if(i > maxproc)
		{
			keepiter = true
			break;
		}
		
		::GetRidOfGravity(ent)
	}
	
	if(last_index != all_len-1)
	{
		objs = objs.slice(last_index)
	}

	if(keepiter)
	{
		Timers.AddTimer(0.4,false,::DoZeroGIter,{total=args.total,left=objs.len(),objs=objs})
	}
	else
	{	
		::LongProcessIterAvailability.zero_g = true
		::AdminSystem.out("Zero-G Progress: "+Utils.BuildProgressBar(20.0,20.0,20.0,"|", ". "))
	}
}

::AdminSystem.GravityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));
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
	EyePosition.z += 16;
	DropFire( EyePosition );
}

::AdminSystem.DropSpitCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();
	EyePosition.z += 16;
	DropSpit( EyePosition );
}

::AdminSystem.DirectorCmd <- function ( player, args )
{
	local Command = GetArgument(1);
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
	if ( Command == "start" )
		Utils.StartFinale();
	else if ( Command == "rescue" )
		Utils.TriggerRescue();
}

::AdminSystem.RestartCmd <- function ( player, args )
{
	
	Utils.TriggerStage( STAGE_RESULTS, 0 );
}

::AdminSystem.LimitCmd <- function ( player, args )
{
	local Infected = GetArgument(1);
	local Value = GetArgument(2);
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
	
	Utils.RollStatsCrawl();
}

::AdminSystem.AlarmCarCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	GroundPosition.y = EyeAngles.y;
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
