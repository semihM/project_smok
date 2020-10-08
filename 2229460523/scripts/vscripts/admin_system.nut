//-----------------------------------------------------
printl("Activating Admin System");

/**
 * Admin System by Rayman1103
 */

// Include the VScript Library
IncludeScript("Admin_System/VSLib");
// Include custom settings for unused lines
IncludeScript("Voice_Paths/Survivorlines");
// Include particle names table
IncludeScript("Particle_Names/Particlenames");

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
	SoundName = {}
	AdminsOnly = true
	DisplayMsgs = true
	EnableIdleKick = false
	IdleKickTime = 60
	AdminPassword = ""
	Vars =
	{
		IsBashDisabled = {}
		IsBashLimited = {}
		IsFreezeEnabled = {}
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

		IgnoreDeletingPlayers = true

		AllowCustomResponses = true

		CharacterNames = ["Bill","Francis","Louis","Zoey","Nick","Ellis","Coach","Rochelle"]
		
		CharacterNamesLower = ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

		PrintIndexedNames = function() {foreach(i,name in ::AdminSystem.CharacterNames){Utils.SayToAll(i+"->"+name);}}

		// Chat output state
	    _outputsEnabled = 
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

		// Randomline stuff
		_saveLastLine = 
		{
			bill=true,
			francis=true,
			louis=true,
			zoey=true,
			nick=true,
			coach=true,
			ellis=true,
			rochelle=true
		}

		_savedLine =
		{
			bill=
			{
				target="",
				source=""
			},
			francis=
			{
				target="",
				source=""
			},
			louis=
			{
				target="",
				source=""
			},
			zoey=
			{
				target="",
				source=""
			},
			nick=
			{
				target="",
				source=""
			},
			coach=
			{
				target="",
				source=""
			},
			ellis=
			{
				target="",
				source=""
			},
			rochelle=
			{
				target="",
				source=""
			}
		}

		// Particle stuff
		_saveLastParticle = 
		{
			bill=true,
			francis=true,
			louis=true,
			zoey=true,
			nick=true,
			coach=true,
			ellis=true,
			rochelle=true
		}

		_savedParticle =
		{
			bill=
			{
				duration=30,
				source=""
			},
			francis=
			{
				duration=30,
				source=""
			},
			louis=
			{
				duration=30,
				source=""
			},
			zoey=
			{
				duration=30,
				source=""
			},
			nick=
			{
				duration=30,
				source=""
			},
			coach=
			{
				duration=30,
				source=""
			},
			ellis=
			{
				duration=30,
				source=""
			},
			rochelle=
			{
				duration=30,
				source=""
			}
		}

		// To reduce menu amount
		_preferred_duration =
		{
			bill=30,
			francis=30,
			louis=30,
			zoey=30,
			nick=30,
			coach=30,
			ellis=30,
			rochelle=30
		}

		// Prop spawn_settings
	 	_prop_spawn_settings_menu_type =
		{
			bill="all",
			francis="all",
			louis="all",
			zoey="all",
			nick="all",
			coach="all",
			ellis="all",
			rochelle="all"
		}

		_prop_spawn_settings =
		{
			bill=
			{
				dynamic=	
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			}
			francis=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			louis=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			zoey=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			nick=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			coach=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			ellis=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			},
			rochelle=
			{
				dynamic=
				{
					spawn_height=0
				},
				physics=
				{
					spawn_height=0
				},
				ragdoll=
				{
					spawn_height=0
				}
			}
		}
		
		_looping =
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
		
		_loopingTable =
		{
			bill={timername="",character="",sequence={}},
			francis={timername="",character="",sequence={}},
			louis={timername="",character="",sequence={}},
			zoey={timername="",character="",sequence={}},
			nick={timername="",character="",sequence={}},
			coach={timername="",character="",sequence={}},
			ellis={timername="",character="",sequence={}},
			rochelle={timername="",character="",sequence={}}
		}
	}
	
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

::AdminSystem.LoadAdmins <- function ()
{
	local fileContents = FileToString("admin system/admins.txt");
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

::AdminSystem.LoadBanned <- function ()
{
	local fileContents = FileToString("admin system/banned.txt");
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
			value = Utils.StringReplace( value, "\"", "" );
			local command = Utils.StringReplace( cvar, value, "" );
			command = Utils.StringReplace( command, " ", "" );
			command = Utils.StringReplace( command, "\"", "" );
			
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
	local fileContents = FileToString("admin system/settings.txt");
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

::AdminSystem.IsPrivileged <- function ( player )
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !AdminSystem.AdminsOnly )
		AdminSystem.Vars.AllowAdminsOnly = false;
	
	if ( !(steamid in ::AdminSystem.Admins) && AdminSystem.Vars.AllowAdminsOnly )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("You ain't got no access to admin commands "+player.GetName()+"("+player.GetSteamID()+")!");
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
			Utils.SayToAllDel("Sorry, only Admins have access to this command.");
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
		Utils.SayToAllDel("%s has been kicked for being idle too long.", player.GetName());
	SendToServerConsole( "kickid " + steamid + " You've been kicked for being idle too long" );
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
	local adminList = FileToString("admin system/admins.txt");
	local banList = FileToString("admin system/banned.txt");
	local settingList = FileToString("admin system/settings.txt");
	
	if ( adminList != null )
	{
		printf("[Admins] Loading admin list...");
		AdminSystem.LoadAdmins();
	}
	if ( banList != null )
	{
		printf("[Banned] Loading ban list...");
		AdminSystem.LoadBanned();
	}
	if ( settingList != null )
	{
		printf("[Settings] Loading settings...");
		AdminSystem.LoadSettings();
	}
	else
	{
		settingList = "AdminsOnly = true\nDisplayMsgs = true\nEnableIdleKick = false\nIdleKickTime = 60\nAdminPassword = \"\"";
		StringToFile("admin system/settings.txt", settingList);
	}

	RestoreTable( "admin_variable_data", ::AdminSystem.Vars );
	
	if (::AdminSystem.Vars == null)
	{
		::AdminSystem.Vars <-
		{
			IsBashDisabled = {}
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

			IgnoreDeletingPlayers = true

			AllowCustomResponses = true

			CharacterNames = ["Bill","Francis","Louis","Zoey","Nick","Ellis","Coach","Rochelle"]
			
			CharacterNamesLower = ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

			PrintIndexedNames = function() {foreach(i,name in ::AdminSystem.CharacterNames){Utils.SayToAll(i+"->"+name);}}

			// Chat output state
			_outputsEnabled = 
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

			// Randomline stuff
			_saveLastLine = 
			{
				bill=true,
				francis=true,
				louis=true,
				zoey=true,
				nick=true,
				coach=true,
				ellis=true,
				rochelle=true
			}

			_savedLine =
			{
				bill=
				{
					target="",
					source=""
				},
				francis=
				{
					target="",
					source=""
				},
				louis=
				{
					target="",
					source=""
				},
				zoey=
				{
					target="",
					source=""
				},
				nick=
				{
					target="",
					source=""
				},
				coach=
				{
					target="",
					source=""
				},
				ellis=
				{
					target="",
					source=""
				},
				rochelle=
				{
					target="",
					source=""
				}
			}

			// Particle stuff
			_saveLastParticle = 
			{
				bill=true,
				francis=true,
				louis=true,
				zoey=true,
				nick=true,
				coach=true,
				ellis=true,
				rochelle=true
			}

			_savedParticle =
			{
				bill=
				{
					duration=30,
					source=""
				},
				francis=
				{
					duration=30,
					source=""
				},
				louis=
				{
					duration=30,
					source=""
				},
				zoey=
				{
					duration=30,
					source=""
				},
				nick=
				{
					duration=30,
					source=""
				},
				coach=
				{
					duration=30,
					source=""
				},
				ellis=
				{
					duration=30,
					source=""
				},
				rochelle=
				{
					duration=30,
					source=""
				}
			}

			// To reduce menu amount
			_preferred_duration =
			{
				bill=30,
				francis=30,
				louis=30,
				zoey=30,
				nick=30,
				coach=30,
				ellis=30,
				rochelle=30
			}

			// Prop spawn_settings
			_prop_spawn_settings_menu_type =
			{
				bill="all",
				francis="all",
				louis="all",
				zoey="all",
				nick="all",
				coach="all",
				ellis="all",
				rochelle="all"
			}

			_prop_spawn_settings =
			{
				bill=
				{
					dynamic=	
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				}
				francis=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				louis=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				zoey=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				nick=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				coach=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				ellis=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				},
				rochelle=
				{
					dynamic=
					{
						spawn_height=0
					},
					physics=
					{
						spawn_height=0
					},
					ragdoll=
					{
						spawn_height=0
					}
				}
			}

			_looping =
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

			_loopingTable =
			{
				bill={timername="",character="",sequence={}},
				francis={timername="",character="",sequence={}},
				louis={timername="",character="",sequence={}},
				zoey={timername="",character="",sequence={}},
				nick={timername="",character="",sequence={}},
				coach={timername="",character="",sequence={}},
				ellis={timername="",character="",sequence={}},
				rochelle={timername="",character="",sequence={}}
			}

			_propageddon_state = 0

			_propageddon_args =
			{
				maxradius = 850				// maximum radius to apply forces
				updaterate = 0.7			// how often to update entity list in seconds
				mindelay = 0.5				// minimum delay to apply the velocity vector
				maxdelayoffset = 2.5   		// maximum delay to apply the velocity vector
				minspeed = 800				// minimum speed
				maxspeed = 20000    		// maximum speed
				phys_dmgmin = 5			    // minimum damage done to physics and door objects
				phys_dmgmax = 100			// maximum damage done to physics and door objects
				dmgprob = 0.3				// probability of entity getting damaged
				entprob = 0.65				// probability of an entity being chosen within the radius
				debug = 1					// Print which entities are effected
			}
		}
	}
	else
	{
		if ( AdminSystem.Vars.DirectorDisabled )
			Utils.StopDirector();

		
		AdminSystem.Vars.CharacterNames = ["Bill","Francis","Louis","Zoey","Nick","Ellis","Coach","Rochelle"]
			
		AdminSystem.Vars.CharacterNamesLower = ["bill","francis","louis","zoey","nick","ellis","coach","rochelle"]

		AdminSystem.Vars.PrintIndexedNames = function() {foreach(i,name in ::AdminSystem.CharacterNames){Utils.SayToAll(i+"->"+name);}}

		AdminSystem.Vars._looping =
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
		
		AdminSystem.Vars._loopingTable =
		{
			bill={timername="",character="",sequence={}},
			francis={timername="",character="",sequence={}},
			louis={timername="",character="",sequence={}},
			zoey={timername="",character="",sequence={}},
			nick={timername="",character="",sequence={}},
			coach={timername="",character="",sequence={}},
			ellis={timername="",character="",sequence={}},
			rochelle={timername="",character="",sequence={}}
		}
		printl("[Custom-Loop] Stopped all custom loops");
	}
	
	foreach(name,optiontable in AdminSystem.Vars._CustomResponseOptions)
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
					AdminSystem.Vars._CustomResponse[name][event][setting] = value;
				}
			}
			
		}
	}
	printl("[Custom] Loaded default custom responses");
	printl("[Custom] Loading admin custom responses...")
	// Fixes for tables
	try
	{	
		// Have to do this because squirrel is fuckin stupid and restores "coach" as "Coach"
		if("Coach" in AdminSystem.Vars._outputsEnabled)
		{
			printl("[Custom-Fix] Applying fixes to outputs table...");
			AdminSystem.Vars._outputsEnabled.coach <- AdminSystem.Vars._outputsEnabled.Coach;
			delete AdminSystem.Vars._outputsEnabled.Coach;
		}
		if("Coach" in AdminSystem.Vars._saveLastLine)
		{
			printl("[Custom-Fix] Applying fixes to LastLine table...");
			AdminSystem.Vars._saveLastLine.coach <- AdminSystem.Vars._saveLastLine.Coach;
			delete AdminSystem.Vars._saveLastLine.Coach;
		}
		if("Coach" in AdminSystem.Vars._savedLine)
		{
			printl("[Custom-Fix] Applying fixes to SavedLine table...");
			AdminSystem.Vars._savedLine.coach <- Utils.TableCopy(AdminSystem.Vars._savedLine.Coach);
			delete AdminSystem.Vars._savedLine.Coach;
		}
		if("Coach" in AdminSystem.Vars._savedParticle)
		{
			printl("[Custom-Fix] Applying fixes to SavedParticle table...");
			AdminSystem.Vars._savedParticle.coach <- Utils.TableCopy(AdminSystem.Vars._savedParticle.Coach);
			delete AdminSystem.Vars._savedParticle.Coach;
		}
		if("Coach" in AdminSystem.Vars._saveLastParticle)
		{
			printl("[Custom-Fix] Applying fixes to LastParticle table...");
			AdminSystem.Vars._saveLastParticle.coach <- AdminSystem.Vars._saveLastParticle.Coach;
			delete AdminSystem.Vars._saveLastParticle.Coach;
		}
		if("Coach" in AdminSystem.Vars._preferred_duration)
		{
			printl("[Custom-Fix] Applying fixes to preferred_duration table...");
			AdminSystem.Vars._preferred_duration.coach <- AdminSystem.Vars._preferred_duration.Coach;
			delete AdminSystem.Vars._preferred_duration.Coach;
		}
		if("Coach" in AdminSystem.Vars._prop_spawn_settings_menu_type)
		{
			printl("[Custom-Fix] Applying fixes to prop_spawn_settings_menu_type table...");
			AdminSystem.Vars._prop_spawn_settings_menu_type.coach <- AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
			delete AdminSystem.Vars._prop_spawn_settings_menu_type.Coach;
		}
		if("Coach" in AdminSystem.Vars._prop_spawn_settings)
		{
			printl("[Custom-Fix] Applying fixes to prop_spawn_settings table...");
			AdminSystem.Vars._prop_spawn_settings.coach <- Utils.TableCopy(AdminSystem.Vars._prop_spawn_settings.Coach);
			delete AdminSystem.Vars._prop_spawn_settings.Coach;
		}
		if("Coach" in AdminSystem.Vars._CustomResponseOptions)
		{	
			printl("[Custom-Fix] Applying fixes to CustomResponse table...");
			AdminSystem.Vars._CustomResponseOptions.coach <- Utils.TableCopy(AdminSystem.Vars._CustomResponseOptions.Coach);
			delete AdminSystem.Vars._CustomResponseOptions.Coach;
			AdminSystem.Vars._CustomResponse.coach <- Utils.TableCopy(AdminSystem.Vars._CustomResponse.Coach);
			delete AdminSystem.Vars._CustomResponse.Coach;
		}
		else
		{	
			// Apply options created by admins
			AdminSystem.LoadCustomSequences();
			throw("No need for fixes in CustomRespose tables");
		}
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
		
	}
	catch(e){printl("[Custom-Warning] OnRoundStart reported: "+e);}
	
	printl("[Custom] Loaded custom responses created by admins");

	if(AdminSystem.Vars._propageddon_state == 1)
	{
		::VSLib.Timers.AddTimer(3,false,Utils.SayToAll,"Madness continues...");
		::VSLib.Timers.AddTimerByName("propageddon",AdminSystem.Vars._propageddon_args.updaterate, true, _ApocalypseTimer,{});	
	}
}

function Notifications::OnModeStart::AdminLoadFiles( gamemode )
{
	local cvarList = FileToString("admin system/cvars.txt");
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
			SendToServerConsole( "kickid " + steamid + " You're banned from this server" );
	}
}

function Notifications::OnPlayerJoined::AdminCheck( player, name, IPAddress, SteamID, params )
{
	local adminList = FileToString("admin system/admins.txt");
	if ( adminList != null )
		return;
	
	if ( player )
	{
		if ( player.IsBot() || !player.IsServerHost() )
			return;
		
		local admins = FileToString("admin system/admins.txt");
		local steamid = player.GetSteamID();
		if ( steamid == "" || steamid == "BOT" )
			return;
		admins = steamid + " //" + player.GetName();
		StringToFile("admin system/admins.txt", admins);
		AdminSystem.LoadAdmins();
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
		case "ent_fire":
		{
			AdminSystem.EntFireCmd( player, args );
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
				local admins = FileToString("admin system/admins.txt");
				local steamid = player.GetSteamID();
				if ( steamid == "BOT" )
					return;
				if ( (steamid in ::AdminSystem.Admins) )
					return;
				if ( admins == null )
					admins = steamid + " //" + player.GetName();
				else
					admins += "\r\n" + steamid + " //" + player.GetName();
				StringToFile("admin system/admins.txt", admins);
				AdminSystem.LoadAdmins();
			}
			
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
		default:
			break;
	}
}


/////////////////////////////////////////////////////////////////
/*
 * Custom responses
 *
 * @authors rhino
 */
enum SCENES
{
	ORDERED = 0
	SHUFFLED = 1
	RANDOM = 2
}

/*
 * @authors rhino
 */
::_CustomResponseBase <- function(_enabled,_prob,_startdelay,_userandom,_randomlinepaths,_lineamount,_mindelay,_offsetdelay,_order,_sequence) 
{	
	local restable = 
	{
		call_amount = 0
		lastspoken = []
		enabled = _enabled
		prob = _prob
		startdelay = _startdelay
		userandom = _userandom
		randomlinepaths = _randomlinepaths
		lineamount = _lineamount
		mindelay = _mindelay
		offsetdelay = _offsetdelay
		order = _order
		sequence = _sequence
	}
	return restable
}

/*
 * @authors rhino
 */
::AdminSystem.Vars._CustomResponse <-
{
	bill = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.bill,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.bill,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	francis = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.francis,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})

		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.francis,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	louis = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.louis,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.louis,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	zoey = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.zoey,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.zoey,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	nick = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.nick,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.nick,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	ellis = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.ellis,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.ellis,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	coach = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.coach,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.coach,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}

	rochelle = 
	{
		_SpeakWhenShoved = _CustomResponseBase(true,0.66,0.1,true,::Survivorlines.FriendlyFire.rochelle,1,0.3,2.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenLeftSaferoom = _CustomResponseBase(false,0.8,2.5,false,null,1,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
		
		_SpeakWhenUsedAdrenaline = _CustomResponseBase(true,0.95,1.0,true,::Survivorlines.Excited.rochelle,5,1.0,3.0,SCENES.ORDERED,{def={scenes=[],delays=[]}})
	}
}

/*
 * @authors rhino
 */
::AdminSystem.Vars._CustomResponseOptions <-
{	
	bill = {}
	
	francis = 
	{
		_SpeakWhenLeftSaferoom = 
		{
			enabled = true
			sequence =
			{
				smokboomer1=
				{   // "Well hell, let's all- Smok- Booooomer!"
					scenes=["warnboomer03.vcd","warnsmoker03.vcd","followme08.vcd"]
					delays=[2.45,1.7,0]
				}
			}
		}
	}

	louis = {}

	zoey = {}

	nick = {}	
	
	ellis = 
	{
		_SpeakWhenLeftSaferoom = 
		{
			enabled = true
			sequence =
			{	
				ilovecrack1=
				{   // "Man I hate them zombies but I loooooove- Crack!"
					scenes=["meleeresponse08.vcd","boomerjar17.vcd"]
					delays=[2.55,0]
				}
			}
		}
	}

	coach = {}

	rochelle = {}
}

/*
 * @authors rhino
 * View or Update vars in AdminSystem.Vars (BE CAREFUL WITH THIS!)
 */
::AdminSystem.Admin_varCmd <- function (player,args)
{
	if (!AdminSystem.IsPrivileged( player ))
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
			{Utils.SayToAll("Cant find key: "+key+" in "+currpath+", creating one...");val[key] <- null;return;}
		}
		local newval = GetArgument(2);
		if(newval == null)
		{	
			if(typeof val == "table")
			{
				Utils.SayToAll(varname+" is a table... Printed in console");
				Utils.PrintTable(val);
				return;
			}
			else if(typeof val == "array")
			{
				Utils.SayToAll(varname+" is "+Utils.ArrayString(val));
				return;
			}
			else
			{
				Utils.SayToAll(varname+" is "+val);return;	
			}
		}
		else
		{
			Utils.SayToAll("Executing: AdminSystem.Vars."+varname+"="+newval);
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
					Utils.SayToAll(varname+" is a table... Printed in console");
					Utils.PrintTable(AdminSystem.Vars[varname]);
					return;
				}
				else if(typeof AdminSystem.Vars[varname] == "array")
				{
					Utils.SayToAll(varname+" is "+Utils.ArrayString(AdminSystem.Vars[varname]));
					return;
				}
				else
				{
					Utils.SayToAll(varname+" is "+AdminSystem.Vars[varname]);return;	
				}
			}
			else
			{
				Utils.SayToAll("Executing: AdminSystem.Vars."+varname+"="+newval);
				compilestring("AdminSystem.Vars."+varname+"="+newval)();
			}
		}
		else
		{Utils.SayToAll("Cant find key: "+key+" in AdminSystem.Vars, creating one...");AdminSystem.Vars[varname] <- null;return;}
	}
}


::AdminSystem.Vars._propageddon_state <- 0;

::AdminSystem.Vars._propageddon_args <-
{
	maxradius = 850				// maximum radius to apply forces
	updaterate = 0.7			// how often to update entity list in seconds
	mindelay = 0.5				// minimum delay to apply propageddon function
	maxdelayoffset = 2.5  		// maximum delay to apply propageddon function
	minspeed = 800				// minimum speed
	maxspeed = 24000    		// maximum speed
	phys_dmgmin = 5			    // minimum damage done to entity
	phys_dmgmax = 100			// maximum damage done to entity
	dmgprob = 0.3				// probability of entity getting damaged
	entprob = 0.65				// probability of an entity being chosen within the radius
	debug = 1					// Print which entities are effected
}

/*
 * @authors rhino
 * Execute each apocalypse tick
 */
::_ApocalypseTimer <- function (...)
{	
	if(AdminSystem.Vars._propageddon_state == 1)
	{	
		local unluckyone = null;
		foreach(survivor in Players.AliveSurvivors())
		{
			if((rand().tofloat()/RAND_MAX) < 0.25)
			{
				unluckyone = survivor;
				break;
			}
		}
		if(unluckyone != null)
		{
			local apocargs = AdminSystem.Vars._propageddon_args;
			local entites = VSLib.EasyLogic.Objects.AroundRadius(unluckyone.GetPosition(),apocargs.maxradius);

			::VSLib.Timers.AddTimer(apocargs.mindelay+rand()%apocargs.maxdelayoffset, false, _Propageddon,entites);
		}
	}
	else
	{
		if ("propageddon" in ::VSLib.Timers.TimersID)
		{
			::VSLib.Timers.RemoveTimer(::VSLib.Timers.TimersID["propageddon"]);
			delete ::VSLib.Timers.TimersID["propageddon"];
		}
		local endmsg = "Apocalypse has been postponed..."+(((rand()%4) == 1)?" or has it ?":" ");
		Utils.SayToAll(endmsg);
	}

}

/* @authors rhino
 * Apply forces to random entites from the table
 */
::_Propageddon <- function (enttbl)
{	
	local apocargs = AdminSystem.Vars._propageddon_args;
	local prob = apocargs.entprob;
	local dmgprob = apocargs.dmgprob;
	local minspeed = apocargs.minspeed;
	local maxspeed = (apocargs.maxspeed - minspeed);
	local mindmg = apocargs.phys_dmgmin;
	local maxdmg = (apocargs.phys_dmgmax - mindmg);
	local pushvec = null;
	local entclass = null;
	local pushedents = [];
	local brokenents = [];
	local useddoors = [];
	local debug = apocargs.debug;
	
	foreach(id,ent in enttbl)
	{	
		if((rand().tofloat()/RAND_MAX) < prob)
		{	
			entclass = ent.GetClassname();
			if(entclass == "prop_physics" || entclass == "prop_physics_multiplayer" || entclass == "func_physbox" || entclass == "prop_car_alarm")
			{ 	
				if((rand().tofloat()/RAND_MAX) < dmgprob)
					ent.Hurt(mindmg+rand()%maxdmg);

				pushvec = QAngle(rand()%360,rand()%360,rand()%360).Forward();
				pushvec = pushvec.Scale((minspeed+rand()%maxspeed).tofloat()/pushvec.Length())
				pushedents.append(ent.GetIndex())
				ent.Push(pushvec);
			}
			else if(entclass == "func_breakable" || entclass == "func_breakable_surf")
			{	
				if((rand().tofloat()/RAND_MAX) < dmgprob)
					ent.Hurt(mindmg+rand()%maxdmg);

				ent.Break();
				brokenents.append(ent.GetIndex())
			}
			else if(entclass == "prop_door_rotating" || entclass == "prop_door_rotating_checkpoint")
			{		
				if((rand().tofloat()/RAND_MAX) < dmgprob)
					ent.Hurt(mindmg+rand()%maxdmg);

				ent.Input("use","");
				useddoors.append(ent.GetIndex())
			}
		}
	}

	if(debug == 1)
	{
		if(pushedents.len() != 0)
			printl("PUSHED\n"+Utils.ArrayString(pushedents));

		if(brokenents.len() != 0)
			printl("BROKEN\n"+Utils.ArrayString(brokenents));

		if(useddoors.len() != 0)
			printl("OPENED\n"+Utils.ArrayString(useddoors));
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
		Utils.SayToAll("Something doesn't feel right...");
		AdminSystem.Vars._propageddon_state = 1;
		::VSLib.Timers.AddTimerByName("propageddon",AdminSystem.Vars._propageddon_args.updaterate, true, _ApocalypseTimer,{});	
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
	{Utils.SayToAll(character+" is not a character name");return;}

	local scene_name = GetArgument(2);
	if(scene_name==null)
	{return;}

	local trimend = GetArgument(3)
	if(trimend==null)
	{
		trimend = 0.1; // make it play after the blank == play it full
	}
	else
	{trimend = trimend.tofloat();}
	
	_SceneSequencer(Utils.GetPlayerFromName(character),{scenes=["blank",scene_name],delays=[trimend,0.15]});

	printl(player.GetCharacterName()+" ->Speak test "+character+" "+scene_name+" "+trimend);
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
		character = player.GetCharacterName().tolower();
	}
	else
	{
		character = character.tolower();
	}

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Utils.SayToAll(character+" is not a character name");return;}

	try
	{
		_SceneSequencer(Utils.GetPlayerFromName(character),AdminSystem.Vars._CustomResponseOptions[character][player.GetSteamID()].sequence[seq_name]);
	}
	catch(e)
	{
		Utils.SayToAll("No custom sequence found for "+character+" named:"+seq_name);return;
	}
	printl(player.GetCharacterName()+" ->Speak custom "+character+" "+seq_name);
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
	{Utils.SayToAll(character+" is not a character name");return;}

	if(AdminSystem.Vars._looping[character])
	{
		printl(player.GetCharacterName()+" ->Stopped loop for "+character);
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
			Utils.SayToAll(player.GetCharacterName()+"->Arguments should be in one of the following formats: \n1){character} >{sequence} {length} \n2){character} {line} {length} ");return;
		}
	}
 	local steamid = player.GetSteamID();
	
	local character = arguments[0];
	if(character==null)
	{return;}
	character = character.tolower();

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Utils.SayToAll(character+" is not a character name");return;}
	
	//Return if already in a loop
	if(AdminSystem.Vars._looping[character])
	{Utils.SayToAll(character+" is already in a talking loop.");return;}

	local sequencename = arguments[1];
	local looplength = arguments[2].tofloat();
	
	// Decide if a sequence or a scene was given
	if(sequencename.find(">") != null) // Sequence
	{	
		sequencename = split(sequencename,">")[0];
		
		if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
		{Utils.SayToAll(player.GetCharacterName()+" -> No custom responses created for "+character);return;}
		else
		{
			if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
			{Utils.SayToAll(player.GetCharacterName()+" ->"+sequencename+" doesn't exist for "+character);return;}

			local seqtable = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename];
			local blanksec = looplength-Utils.ArrayMax(seqtable.delays);
			// Loop length is shorter
			if(blanksec<0)
			{printl("[Loop-Warning] length is "+blanksec*-1+"seconds shorter than sequence: "+player.GetCharacterName()+" ->"+sequencename+" "+looplength);}
			
			AdminSystem.Vars._looping[character] = true;
			
			//First loop base
			local loopseq = {scenes=[],delays=[]};
			if(blanksec<0)
			{
				foreach(i,delay in seqtable.delays)
				{
					if(delay<looplength) // Filter out scenes after blanktime
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
	printl(player.GetCharacterName()+" ->Started loop for "+character+" named "+sequencename);

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
	if(character == null || character == "all")
	{
		foreach(charname in AdminSystem.Vars.CharacterNamesLower)
		{	
			seqnames += charname + ":("
			if(steamid in AdminSystem.Vars._CustomResponseOptions[charname])
			{
				foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[charname][steamid].sequence)
				{
					seqnames += seq_name + ", ";
				}
			}
			seqnames += ") \n";
		}
		character = "all characters";
	}
	else
	{	
		character = character.tolower();
		if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
		{Utils.SayToAll(character+" is not a character name");return;}

		if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
		{
			Utils.SayToAll("No custom sequence found for "+character);return;
		}
		foreach(seq_name,seqtable in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence)
		{
			seqnames += seq_name + ", ";
		}
	}
	
	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterName().tolower()])
	{Utils.SayToAll(player.GetCharacterName()+" -> Saved custom responses for "+character+": "+seqnames);}
	else
	{printl(player.GetCharacterName()+" -> Saved custom responses for "+character+": "+seqnames);}
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
		character = player.GetCharacterName().tolower();
	}
	else
	{
		character = character.tolower();
	}

	if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1)
	{Utils.SayToAll(character+" is not a character name");return;}

	local str = "\n";
	local steamid = player.GetSteamID();

	if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
	{
		Utils.SayToAll("No custom sequence found for "+character);return;
	}

	if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
	{
		Utils.SayToAll("No custom sequence found for "+character+" named "+sequencename);return;
	}
	
	str += Utils.ArrayString(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes)
	str += "\n"
	str += Utils.ArrayString(AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays)

	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterName().tolower()])
	{Utils.SayToAll(player.GetCharacterName()+" -> Sequence info "+character+"."+sequencename+str);}
	else
	{printl(player.GetCharacterName()+" -> Sequence info "+character+"."+sequencename+str);}
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
	{Utils.SayToAll(character+" is not a character name");return;}

	local steamid = player.GetSteamID();
	
	if(!(steamid in AdminSystem.Vars._CustomResponseOptions[character]))
	{
		Utils.SayToAll("No custom sequence found for "+character);return;
	}

	if(!(sequencename in AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence))
	{
		Utils.SayToAll("No custom sequence found for "+character+" named "+sequencename);return;
	}
	
	local scene_index = -1;
	local oldvalue = "";

	printl(character+" "+sequencename+" "+scene+" "+setting);
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
				Utils.SayToAll("Setting should be in format scene>new_name OR delay>x");return;
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
				Utils.SayToAll("Setting should be in format scene>new_name OR delay>x");return;
			}
		}
		else
		{
			Utils.SayToAll("Setting should be in format scene>new_name OR delay>x");return;
		}
		
	}
	else
	{
		Utils.SayToAll("No scene named "+scene+" was found");return;
	}

	// Output messages
	if (AdminSystem.Vars._outputsEnabled[player.GetCharacterName().tolower()])
	{Utils.SayToAll(player.GetCharacterName()+" -> Changed "+character+"."+sequencename+"."+setting+"s["+scene_index+"]:\n "+oldvalue+"->"+newval.tostring());}
	else
	{printl(player.GetCharacterName()+" -> Sequence info "+character+"."+sequencename+"."+setting+"s["+scene_index+"]: "+oldvalue+"->"+newval.tostring());}
	
	// Save to custom file
	local contents = FileToString("admin system/custom_responses.json");
	if(contents == null)
	{Utils.SayToAll("custom_responses.json file is missing, changes will only be applied for current session cache!");return;}

	local responsetable = compilestring( "return " + contents )();

	if (setting == "scene")
	{
		responsetable[steamid][character][sequencename].scenes[scene_index] = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].scenes[scene_index];
	}
	else
	{
		responsetable[steamid][character][sequencename].delays[scene_index] = AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[sequencename].delays[scene_index];
	}

	StringToFile("admin system/custom_responses.json", Utils.SceneTableToString(responsetable));
	AdminSystem.LoadCustomSequences();
}

/*
 * @authors rhino
 * Load sequences from custom_responses.json
 */
::AdminSystem.LoadCustomSequences <- function (...)
{
	local contents = FileToString("admin system/custom_responses.json");
	// First time
	if(contents == null)
	{	
		printl("[Custom] Creating custom response file for the first time...");
		contents = "{";
		foreach(admin,val in AdminSystem.Admins)
		{
			if(val)
				contents += "\n\t\""+admin+"\":\n\t{\n\t\t\"character_name\":\n\t\t{\n\t\t\t\"sequence_name\":\n\t\t\t{\n\t\t\t\t\"scenes\":[\"blank\"],\n\t\t\t\t\"delays\":[0]\n\t\t\t}\n\t\t}\n\t}"; 
		}
		contents += "\n}";
		StringToFile("admin system/custom_responses.json", contents);
	}

	local responsetable = compilestring( "return " + contents )();

	// Check admins
	foreach(admin,val in AdminSystem.Admins)
	{	
		if(!(admin in responsetable))
		{
			printl("[Custom] Creating default response table for new admin: "+admin);
			responsetable[admin] <- {character_name={sequence_name={scenes=["blank"],delays=[0]}}};
		}
	}

	foreach(steamid,chartable in responsetable)
	{	
		foreach(character,customs in chartable)
		{	
			if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1){continue;} // Ignore wrong character names

			// Add steamid to each character
			foreach(charname in AdminSystem.Vars.CharacterNamesLower)
				AdminSystem.Vars._CustomResponseOptions[charname][steamid] <- {enabled=true,sequence={}}

			// Add custom sequences
			foreach(seq_name,seqtable in customs)
			{	
				AdminSystem.Vars._CustomResponseOptions[character][steamid].sequence[seq_name] <- {scenes=seqtable.scenes,delays=seqtable.delays}
			}
		}
		
	}
}

/*
 * @authors rhino
 * @param charachter = character name | all
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
			Utils.SayToAll(player.GetCharacterName()+"->Arguments should be follow the format: character sequence_name scene1 delay1 scene2 delay2 ...");return;
		}
	}
	
	local contents = FileToString("admin system/custom_responses.json");

	// Somehow response file wasn't created
	if(contents == null)
	{
		Utils.SayToAll("No custom respose file found.");
		return;
	}

	local steamid = player.GetSteamID();
	local responsetable = compilestring( "return " + contents )();

	local character = arguments[0];
	if(character==null)
	{return;}
	character = character.tolower();
	
	if(character != "all" && Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,character)==-1 )
	{Utils.SayToAll(character+" is not a character name");return;}

	local sequencename = arguments[1];

	if(character == "all")
	{
		foreach(charname in AdminSystem.Vars.CharacterNamesLower)
		{
			
			if(!(charname in responsetable[steamid]))
			{
				responsetable[steamid][charname] <- {};
			}

			if(sequencename in responsetable[steamid][charname])
			{
				Utils.SayToAll("Skipping creating sequence "+sequencename+" for "+charname+": Sequence already exists!");continue;
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
		printl(player.GetCharacterName()+" ->Created sequence for all characters named "+sequencename);
	}
	else
	{
		if(!(character in responsetable[steamid]))
		{
			responsetable[steamid][character] <- {};
		}

		if(sequencename in responsetable[steamid][character])
		{
			Utils.SayToAll("Sequence "+sequencename+" already exists for "+character+"!");return;
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
		
		printl(player.GetCharacterName()+" ->Created sequence for "+character+" named "+sequencename);

	}

	StringToFile("admin system/custom_responses.json", Utils.SceneTableToString(responsetable));
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
	{Utils.SayToAll(character+" is not a character name");return;}

	local sequencename = GetArgument(2);
	local contents = FileToString("admin system/custom_responses.json");

	// Somehow response file wasn't created
	if(contents == null)
	{
		Utils.SayToAll("No custom respose file found.");
		return;
	}

	local responsetable = compilestring( "return " + contents )();
	local found = false;
	local steamid = player.GetSteamID();
	
	if(!(character in responsetable[steamid]))
	{Utils.SayToAll("No custom responses found for "+character);return;}

	if(sequencename in responsetable[steamid][character])
	{	
		Utils.SayToAll("Deleted custom response for "+character+": "+sequencename+"");
		delete responsetable[steamid][character][sequencename];
	}
	else
	{
		Utils.SayToAll("No custom response found for "+character+" named: "+sequencename+"");return;
	}

	StringToFile("admin system/custom_responses.json", Utils.SceneTableToString(responsetable));
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
 * @param optiontable = AdminSystem.Vars._CustomResponseOptions[{EventName}][player.GetCharacterName().tolower()]
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

				prev_total_delay += Utils.ArraySum(seq.delays);
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

				prev_total_delay += Utils.ArraySum(picked_seq.delays);
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

/////////////////////////////////////////////////////////////////
/*
 * Speak a friendly fire line when shoved with given options in AdminSystem.Vars._CustomResponseOptions
 *
 * @authors rhino
 */
function Notifications::OnPlayerShoved::_SpeakWhenShovedCondition(target,attacker,args=null)
{
	if(!AdminSystem.Vars.AllowCustomResponses)
		return;

	local targetname = target.GetCharacterName().tolower();

	if(targetname == "") // Was special infected
	{return;}
	
	if(!AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.enabled)
	{return;}

	if(rand().tofloat()/RAND_MAX <= AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.prob)
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
		printl(ents.attacker.GetCharacterName()+" is bullying "+targetname+": "+line);
	}
	else // Speak from given sequences
	{	
		_SceneDecider(ents.target,AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved);
	}
	AdminSystem.Vars._CustomResponse[targetname]._SpeakWhenShoved.call_amount += 1;
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
	
	local name = ent.GetCharacterName().tolower();
	if(name == "")
		return;
		
	if(!AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.enabled)
		return;	
	
	// Add timer to ignore changes during map loading
	if(rand().tofloat()/RAND_MAX <= AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.prob && AdminSystem.Vars._CustomResponse[name]._SpeakWhenLeftSaferoom.call_amount == 0)
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

	local name = ent.GetCharacterName().tolower();
	if(rand().tofloat()/RAND_MAX <= AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.prob)
		::VSLib.Timers.AddTimer(AdminSystem.Vars._CustomResponse[name]._SpeakWhenUsedAdrenaline.startdelay, false, _SpeakWhenUsedAdrenalineResult,ent);
}

/*
 * @authors rhino
 */
::_SpeakWhenUsedAdrenalineResult <- function(ent)
{
	local name = ent.GetCharacterName().tolower();
	
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

/////////////////////////////////////////////////////////////////
function ChatTriggers::admin_var( player, args, text )
{
	AdminSystem.Admin_varCmd( player, args );
}
/////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////
function ChatTriggers::start_the_apocalypse( player, args, text )
{
	AdminSystem.Start_the_apocalypseCmd( player, args );
}
function ChatTriggers::pause_the_apocalypse( player, args, text )
{
	AdminSystem.Pause_the_apocalypseCmd( player, args );
}
/////////////////////////////////////////////////////////////////

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

function ChatTriggers::ent( player, args, text )
{
	AdminSystem.EntityWithTableCmd( player, args );
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

function ChatTriggers::ent_rotate( player, args, text )
{
	AdminSystem.EntRotateCmd( player, args );
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

function ChatTriggers::script( player, args, text )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local compiledscript = compilestring(Utils.CombineArray(args));
	compiledscript();
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

function ChatTriggers::setkeyval(player,args,text)
{
	AdminSystem.SetkeyvalCmd(player, args);
}

function ChatTriggers::color(player,args,text)
{
	AdminSystem.ColorCmd(player, args);
}

function ChatTriggers::attach_particle(player,args,text)
{
	AdminSystem.Attach_particleCmd(player, args);
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

function ChatTriggers::spawn_particle_saved(player,args,text)
{
	AdminSystem.Spawn_particle_savedCmd(player, args);
}

function ChatTriggers::attach_particle_saved(player,args,text)
{
	AdminSystem.Attach_particle_savedCmd(player, args);
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

function ChatTriggers::rainbow(player,args,text)
{
	AdminSystem.RainbowCmd(player, args);
}

function ChatTriggers::randomline(player,args,text)
{
	AdminSystem.RandomlineCmd(player, args);
}

function ChatTriggers::update_print_output_state(player,args,text)
{
	AdminSystem.Update_print_output_stateCmd(player, args);
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

function ChatTriggers::debug_info(player,args,text)
{
	AdminSystem.Debug_infoCmd(player, args);
}

function ChatTriggers::server_exec(player,args,text)
{
	AdminSystem.Server_execCmd(player, args);
}

function ChatTriggers::save_line(player,args,text)
{
	AdminSystem.Save_lineCmd(player, args);
}

function ChatTriggers::save_particle(player,args,text)
{
	AdminSystem.Save_particleCmd(player, args);
}

function ChatTriggers::update_custom_response_preference(player,args,text)
{
	AdminSystem.Update_custom_response_preferenceCmd(player, args);
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
			Utils.SayToAllDel("Admin mode enabled, only Admins have access to Admin commands.");
	}
	else if ( AdminSystem.Vars.AllowAdminsOnly && (AdminsOnly == "disable" || AdminsOnly == "false" || AdminsOnly == "off") )
	{
		AdminSystem.Vars.AllowAdminsOnly = false;
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("Admin mode disabled, everyone has access to Admin commands.");
	}
}

::AdminSystem.AddAdminCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if ( !Target )
		return;

	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local adminList = FileToString("admin system/admins.txt");
	if ( adminList != null )
	{
		if (!AdminSystem.IsAdmin( player ))
			return;
	}
	
	local admins = FileToString("admin system/admins.txt");
	local steamid = Target.GetSteamID();
	if ( steamid == "BOT" )
		return;
	if ( (steamid in ::AdminSystem.Admins) )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("%s is already an Admin.", Target.GetName());
		return;
	}
	if ( admins == null )
		admins = steamid + " //" + Target.GetName();
	else
		admins += "\r\n" + steamid + " //" + Target.GetName();
	if ( AdminSystem.DisplayMsgs )
		Utils.SayToAllDel("%s has been given Admin control.", Target.GetName());
	StringToFile("admin system/admins.txt", admins);
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
	
	local admins = FileToString("admin system/admins.txt");
	local steamid = Target.GetSteamID();

	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("Sorry, only the host can remove Admins.");
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
		Utils.SayToAllDel("%s has lost Admin control.", Target.GetName());
	StringToFile("admin system/admins.txt", admins);
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
			Utils.SayToAllDel("Sorry, you can't kick an Admin.");
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( Reason && steamid != "BOT" )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("%s has been kicked by %s due to %s.", Target.GetName(), player.GetName(), Reason);
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("%s has been kicked by %s.", Target.GetName(), player.GetName());
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
	
	local bannedPlayers = FileToString("admin system/banned.txt");
	local steamid = Target.GetSteamID();
	
	if ( !steamid || steamid == "BOT" )
		return;
	
	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("Sorry, you can't ban an Admin.");
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
	
	StringToFile("admin system/banned.txt", bannedPlayers);
	if ( Reason )
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("%s has been banned by %s due to %s.", Target.GetName(), player.GetName(), Reason);
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("%s has been banned by %s.", Target.GetName(), player.GetName());
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
						Utils.SayToAllDel("God mode has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsGodEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("God mode has been enabled on %s.", survivor.GetName());
				}
			}
		}
		else if ( Type == "infected" )
		{
			if ( AdminSystem.Vars.EnabledGodInfected )
			{
				AdminSystem.Vars.EnabledGodInfected = false;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("God mode disabled for Infected.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodInfected = true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("God mode enabled for Infected.");
			}
		}
		else if ( Type == "si" )
		{
			if ( AdminSystem.Vars.EnabledGodSI )
			{
				AdminSystem.Vars.EnabledGodSI = false;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("God mode disabled for SI.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodSI = true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("God mode enabled for SI.");
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
					Utils.SayToAllDel("God mode has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsGodEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("God mode has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has disabled god mode.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled god mode.", player.GetName());
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
						Utils.SayToAllDel("Bash has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Bash has been enabled on %s.", Target.GetName());
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
						Utils.SayToAllDel("Bash has been disabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Bash has been disabled on %s.", Target.GetName());
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
						Utils.SayToAllDel("Bash has been limited on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Bash has been limited on %s.", Target.GetName());
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
				Utils.SayToAllDel("Bash has been enabled on %s.", player.GetName());
		}
		else if ( Survivor == "disable" )
		{
			AdminSystem.Vars.IsBashLimited[ID] <- false;
			AdminSystem.Vars.IsBashDisabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("Bash has been disabled on %s.", player.GetName());
		}
		else if ( Survivor == "pushonly" || Survivor == "limit" )
		{
			AdminSystem.Vars.IsBashDisabled[ID] <- false;
			AdminSystem.Vars.IsBashLimited[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("Bash has been limited on %s.", player.GetName());
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
						Utils.SayToAllDel("%s has been thawed.", survivor.GetName());
				}
				else
				{
					survivor.AddFlag(FL_FROZEN);
					AdminSystem.Vars.IsFreezeEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("%s has been frozen.", survivor.GetName());
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
					Utils.SayToAllDel("%s has been thawed.", Target.GetName());
			}
			else
			{
				Target.AddFlag(FL_FROZEN);
				AdminSystem.Vars.IsFreezeEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("%s has been frozen.", Target.GetName());
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
				Utils.SayToAllDel("%s has been thawed.", player.GetName());
		}
		else
		{
			player.AddFlag(FL_FROZEN);
			AdminSystem.Vars.IsFreezeEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has been frozen.", player.GetName());
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
						Utils.SayToAllDel("Noclip has been disabled on %s.", survivor.GetName());
				}
				else
				{
					survivor.SetNetProp("movetype", 8);
					AdminSystem.Vars.IsNoclipEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Noclip has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Noclip has been disabled on %s.", Target.GetName());
			}
			else
			{
				Target.SetNetProp("movetype", 8);
				AdminSystem.Vars.IsNoclipEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("Noclip has been enabled on %s.", Target.GetName());
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
				Utils.SayToAllDel("%s has disabled Noclip.", player.GetName());
		}
		else
		{
			player.SetNetProp("movetype", 8);
			AdminSystem.Vars.IsNoclipEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled Noclip.", player.GetName());
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
						Utils.SayToAllDel("Flying mode has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- true;
					Timers.AddTimerByName( survivorID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, survivor );
					survivor.Input( "IgnoreFallDamageWithoutReset", 999999 );
					survivor.Input( "DisableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Flying mode has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Flying mode has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- true;
				Timers.AddTimerByName( targetID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, Target );
				Target.Input( "IgnoreFallDamageWithoutReset", 999999 );
				Target.Input( "DisableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("Flying mode has been enabled on %s.", Target.GetName());
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
				Utils.SayToAllDel("%s has disabled flying mode.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- true;
			Timers.AddTimerByName( ID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, player );
			player.Input( "IgnoreFallDamageWithoutReset", 999999 );
			player.Input( "DisableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled flying mode.", player.GetName());
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
						Utils.SayToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Infinite ammo has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Infinite ammo has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("Infinite ammo has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has disabled infinite ammo.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled infinite ammo.", player.GetName());
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
						Utils.SayToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Unlimited ammo has been disabled on %s.", survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						Utils.SayToAllDel("Unlimited ammo has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Unlimited ammo has been disabled on %s.", Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					Utils.SayToAllDel("Unlimited ammo has been enabled on %s.", Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has disabled unlimited ammo.", player.GetName());
		}
		else
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled unlimited ammo.", player.GetName());
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
						Utils.SayToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite incendiary ammo has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Infinite incendiary ammo has been enabled on %s.", Target.GetName());
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
						Utils.SayToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite explosive ammo has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Infinite explosive ammo has been enabled on %s.", Target.GetName());
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
						Utils.SayToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite laser sights has been enabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Infinite laser sights has been enabled on %s.", Target.GetName());
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
						Utils.SayToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
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
						Utils.SayToAllDel("Infinite upgrade ammo has been disabled on %s.", survivor.GetName());
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
					Utils.SayToAllDel("Infinite upgrade ammo has been disabled on %s.", Target.GetName());
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
				Utils.SayToAllDel("%s has enabled infinite incendiary ammo.", player.GetName());
		}
		else if ( Survivor == "explosive_ammo" )
		{
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled infinite explosive ammo.", player.GetName());
		}
		else if ( Survivor == "laser_sight" )
		{
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_LASER_SIGHT );
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has enabled infinite laser sights.", player.GetName());
		}
		else if ( Survivor == "stop" || Survivor == "off" )
		{
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("%s has disabled infinite upgrade ammo.", player.GetName());
		}
	}
}

::AdminSystem.CleanupCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	foreach(fuelparta in Objects.OfModel("models/props_industrial/barrel_fuel_parta.mdl"))
		fuelparta.Kill();
	foreach(fuelpartb in Objects.OfModel("models/props_industrial/barrel_fuel_partb.mdl"))
		fuelpartb.Kill();
	foreach( particle_system in Objects.OfName("_*_our_particles") )
		particle_system.Kill();
	foreach( entity in Objects.OfName("_*_singlesimple") )
		entity.Kill();
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
::AdminSystem.ParticleCmd <- function ( player, args )
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
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
	if (AdminSystem.Vars._outputsEnabled[name])
	{Utils.SayToAll(name+"->Spawned particle:"+Particle+" at:"+EyePosition.x+","+EyePosition.y+","+EyePosition.z);}
	else
	{printl(name+"->Spawned particle:"+Particle+" at:"+EyePosition.x+","+EyePosition.y+","+EyePosition.z);}
	
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
	
	if ( MDL == "nick" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_gambler.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "rochelle" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_producer.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "coach" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_coach.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "ellis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_mechanic.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "bill" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_namvet.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "zoey" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_teenangst.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "francis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_biker.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "louis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_manager.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "smoker" )
		Utils.SpawnCommentaryDummy( "models/infected/smoker.mdl", "weapon_claw", "smoker_cough", EyePosition, GroundPosition );
	else if ( MDL == "boomer" )
		Utils.SpawnCommentaryDummy( "models/infected/boomer.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "boomette" )
		Utils.SpawnCommentaryDummy( "models/infected/boomette.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "hunter" )
		Utils.SpawnCommentaryDummy( "models/infected/hunter.mdl", "weapon_claw", "Idle_Standing_01", EyePosition, GroundPosition );
	else if ( MDL == "spitter" )
		Utils.SpawnCommentaryDummy( "models/infected/spitter.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "jockey" )
		Utils.SpawnCommentaryDummy( "models/infected/jockey.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "charger" )
		Utils.SpawnCommentaryDummy( "models/infected/charger.mdl", "weapon_claw", "Idle_Upper_KNIFE", EyePosition, GroundPosition );
	else if ( MDL == "witch" )
		Utils.SpawnCommentaryDummy( "models/infected/witch.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "witch_bride" )
		Utils.SpawnCommentaryDummy( "models/infected/witch_bride.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "tank" )
		Utils.SpawnCommentaryDummy( "models/infected/hulk.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else if ( MDL == "tank_dlc3" )
		Utils.SpawnCommentaryDummy( "models/infected/hulk_dlc3.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else
		Utils.SpawnCommentaryDummy(MDL, Weapons, Animation, EyePosition);
}

/*
 * @authors rhino
 */
::AdminSystem.EntityCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
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

	printl(name+" ->Created entity("+classname+"):\nposition = "+pos+"\nangles = "+ang+"\nkeyvals = ");
	Utils.PrintTable(keyvals);
	
	local ent = Utils.CreateEntity(classname,pos,ang,keyvals);

}

/**
 * Creates entity with given class and table of key-value pairs 
 *
 * @param classname Class name of the entity
 * @param keyvals Key-value pairs in the format: "key1->val1&key2->TYPE|val2.1|val2.2|val2.3&key3->TYPE|val3&..."
 * 3 arguments for value: TYPE = {ang,pos,str} -> QAngle(val2.1.tofloat(),val2.2.tofloat(),val2.3.tofloat())
 * 												| Vector(val2.1.tofloat(),val2.2.tofloat(),val2.3.tofloat())
 * 												| "val2.1 val2.2 val2.3"
 * 1 argument for value: TYPE = {float,int,str} -> val3.tofloat() | val3.tointeger() | val3
 * @return void
 *
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
	local name = player.GetCharacterName().tolower();

	local pairsplit = [null,null];
	local found = false;

	local spawnflags = null;
	local effects = null;

	if(keyvals == null)
	{
		keyvals = {};
	}
	else
	{
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
			pairsplit = split(pair,"->");

			if(pairsplit.len()!=2)
			{
				printl(name+" ->Invalid entity key value pair: ");
				foreach(i,v in pairsplit)
				{
					printl((i+1)+": "+v);
				}
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
						printl(name+" -> Unrecognized TYPE("+str[0]+") for Key:"+pairsplit[0]);
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
						printl(name+" -> Unrecognized TYPE("+str[0]+") for Key:"+pairsplit[0]);
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

	printl(name+" ->Created "+cname+" entity named "+newEntity.GetName()+" with table:");
	Utils.PrintTable(keyvals);

	// Apply flags and effects after spawning
	// TO DO : DOESNT WORK
	if(spawnflags!=null)
	{
		newEntity.SetSpawnFlags(spawnflags);
	}

	if(effects!=null)
	{
		newEntity.SetEffects(effects);
	}

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
	local raise = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	local name = player.GetCharacterName().tolower();
	
	local propspawnsettings = AdminSystem.Vars._prop_spawn_settings[name];

	GroundPosition.y = EyeAngles.y;

	local createdent = null;

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
			createdent = Utils.SpawnPhysicsProp( MDL, EyePosition, GroundPosition );
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
			createdent = Utils.SpawnPhysicsMProp( MDL, EyePosition, GroundPosition );
		}
		else
		{
			EyePosition.z += 0.5;
			createdent = Utils.SpawnPhysicsMProp( MDL, EyePosition, GroundPosition );
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
			createdent = Utils.SpawnDynamicProp( MDL, EyePosition, GroundPosition );
		}
		else
		{
			createdent = Utils.SpawnDynamicProp( MDL, EyePosition, GroundPosition );
		}
	}
	printl(name+" ->Created "+Entity+" entity named "+createdent.GetName());
}

::AdminSystem.DoorCmd <- function ( player, args )
{
	local name = player.GetCharacterName().tolower();
	local DoorModel = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);
	local ent = null;
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	
	if ( !DoorModel )
		ent = Utils.SpawnDoor("models/props_downtown/door_interior_112_01.mdl", EyePosition, GroundPosition);
	else
	{
		EyePosition.z += 52;
		if ( DoorModel == "saferoom" || DoorModel == "checkpoint" )
			ent = Utils.SpawnDoor("models/props_doors/checkpoint_door_02.mdl", EyePosition, GroundPosition);
		else
			ent = Utils.SpawnDoor(DoorModel, EyePosition, GroundPosition);
	}

	printl(name+" ->Created a Door entity named "+ent.GetName());
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
	local Command = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	SendToServerConsole(Utils.CombineArray(args));
}

::AdminSystem.CvarCmd <- function ( player, args )
{
	local Cvar = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Cvar && Value )
		Convars.SetValue( Cvar, Value );
}

::AdminSystem.EntFireCmd <- function ( player, args )
{
	local Ent = GetArgument(1);
	local Action = GetArgument(2);
	local Value = GetArgument(3);
	local Value2 = GetArgument(4);
	local Value3 = GetArgument(5);
	local Entity = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local val = "";
	if (Value && Value2 && Value3)
		val = Value + " " + Value2 + " " + Value3;
	else if (Value && Value2)
		val = Value + " " + Value2;
	else if (Value)
		val = Value;
	
	if ( Ent == "!picker" )
	{
		if ( Entity )
		{
			if (Entity.GetClassname() == "player" && Action == "kill" && Entity.GetSteamID() !="BOT" && AdminSystem.Vars.IgnoreDeletingPlayers)
			{
				printl(player.GetCharacterName().tolower()+"->Ignore attemp to kick player:"+Entity.GetName());
				return;
			}
			Entity.Input( Action, val );
		}
	}
	else if ( Ent == "!self" )
	{
		player.Input( Action, val );
	}
	else
	{
		if ( Target )
		{
			Target.Input( Action, val );
		}
		else
			g_MapScript.EntFire( Ent, Action, val );
	}
	printl(player.GetCharacterName().tolower()+"->scripted_user_func ent_fire,"+(Entity == null ? Ent : Entity.GetName())+","+Action+","+val);

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
	
	if(axis == null)
		return;
	if(val == null)
	{
		val = axis; axis = "y";
	}
	local entlooked = player.GetLookingEntity();

	if(entlooked)
	{	
		val = val.tofloat();
		local newAngle = entlooked.GetAngles();

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

		entlooked.SetAngles(newAngle);
		entlooked.SetForwardVector(newAngle.Forward());
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
		pitchofeye = pitchofeye.tofloat()*-1;
	}

	local entlooked = player.GetLookingEntity();
	if(entlooked)
	{	
		local fwvec = RotateOrientation(player.GetEyeAngles(),QAngle(pitchofeye,0,0)).Forward();
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

		entlooked.Push(fwvec);
		printl(player.GetCharacterName().tolower()+"->Push("+scalefactor+","+direction+","+pitchofeye+"), Entity index: "+entlooked.GetIndex());
		
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
	if(entlooked)
	{	
		local fwvec = RotateOrientation(player.GetEyeAngles(),QAngle(pitchofeye,0,0)).Forward();
		local temp = Vector(fwvec.x,fwvec.y,0);

		fwvec = fwvec.Scale(units/fwvec.Length());
		temp = temp.Scale(units/temp.Length());

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
			
		entlooked.SetOrigin(Vector(entpos.x+fwvec.x,entpos.y+fwvec.y,entpos.z+fwvec.z));

		printl(player.GetCharacterName().tolower()+" ->Move("+units+","+direction+","+pitchofeye+"), Entity index: "+entlooked.GetIndex());
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
		printl(player.GetCharacterName().tolower()+"->Spin("+scalefactor+","+direction+"), Entity index: "+entlooked.GetIndex());
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
				Utils.SayToAllDel("You can't enter a value less than 0.1!");
			return;
		}
		else if ( DesiredTimeScale > 10.0 )
		{
			if ( AdminSystem.DisplayMsgs )
				Utils.SayToAllDel("You can't enter a value more than 10.0!");
			return;
		}
		Utils.ResumeTime();
		Utils.SlowTime(DesiredTimeScale, 2.0, 1.0, 2.0, false);
	}
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
				Utils.SayToAll("Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
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
				Utils.SayToAll("Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
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
			entlooked.InputColor(255, 255, 255,last_t+intervals);
		}
	}

	color_seq();	// Loop starter

	printl(player.GetCharacterName().tolower()+"->Rainbow("+duration+","+intervals+"), Entity index: "+entlooked.GetIndex());
}

/*
 * @authors rhino
 */
::AdminSystem.Update_print_output_stateCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
	local newstate = !AdminSystem.Vars._outputsEnabled[name];
	AdminSystem.Vars._outputsEnabled[name] = newstate;

	Utils.SayToAll("Printing output state for "+name+":"+( newstate ? " Enabled":" Disabled"));
	
}

/*
 * @authors rhino
 */
::AdminSystem.Randomline_save_lastCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
	local newstate = !AdminSystem.Vars._saveLastLine[name];
	AdminSystem.Vars._saveLastLine[name] = newstate;

	Utils.SayToAll("Random line saving for "+name+" is"+( newstate ? " Enabled":" Disabled"));
	
}

/*
 * @authors rhino
 */
::AdminSystem.Save_lineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName().tolower();
	local targetname = GetArgument(1);
	local linesource = GetArgument(2);
	if ( linesource == null)
	{
		return;
	}
	
	AdminSystem.Vars._savedLine[name].target = targetname;
	AdminSystem.Vars._savedLine[name].source = linesource;

	if (AdminSystem.Vars._outputsEnabled[name])
	{
		Utils.SayToAll("Saved for "+name+" ->scripted_user_func speak,"+targetname+","+linesource);
	}
	else
	{
		printl("Saved for "+name+" ->scripted_user_func speak,"+targetname+","+linesource);
	}
}

/*
 * @authors rhino
 */
::AdminSystem.Speak_savedCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName().tolower();
	local lineinfo = AdminSystem.Vars._savedLine[name];
	if (lineinfo.target != "")
	{
		Utils.GetPlayerFromName(lineinfo.target).Speak(lineinfo.source);

		if (AdminSystem.Vars._outputsEnabled[name])
		{
			Utils.SayToAll(name+" ->scripted_user_func speak,"+lineinfo.target+","+lineinfo.source);
		}
		else
		{
			printl(name+" ->scripted_user_func speak,"+lineinfo.target+","+lineinfo.source);
		}
	}
	else
	{
		printl("No saved line was found for "+name);
	}
	
}

/*
 * @authors rhino
 */
::AdminSystem.Display_saved_lineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName().tolower();
	if (AdminSystem.Vars._saveLastLine[name])
	{	
		local lineinfo = AdminSystem.Vars._savedLine[name];
		if (lineinfo.target != "")
		{
			Utils.SayToAll(name+" ->scripted_user_func speak,"+lineinfo.target+","+lineinfo.source);
		}
		else
		{
			Utils.SayToAll("No saved line was found for "+name);
		}
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

	if(arg == null)
	{	
		local ent = player.GetLookingEntity();
		if (ent == null)
		{
			printl("No entity found");
			return;
		}
		
		printl("+++++++++++++++++++debug_info++++++++++++++++++++");
		SendToServerConsole("echo Name: "+ ent.GetName() + ", Global name: "+ ent.GetGlobalName() + ";echo Index: "+ ent.GetIndex() + ", Base index: "+ ent.GetBaseIndex() + ";echo Type: "+ ent.GetType() + ";echo Parent: "+ ent.GetParent() +";echo Scale: " + ent.GetModelScale()+";echo ==================flags======================");
		SendToServerConsole("echo SpawnFlags: "+ ent.GetSpawnFlags() +";echo Flags: "+ ent.GetFlags() +";echo EFlags: " + ent.GetEFlags()+";echo Sense flags: "+ ent.GetSenseFlags());
		SendToServerConsole("echo ================positional====================");
		SendToServerConsole("echo Location(Origin): "+ent.GetLocation() +";echo Angles: " + ent.GetAngles());
		SendToServerConsole("echo ================physics_debug=================;physics_debug_entity");
		SendToServerConsole("echo ==================ent_dump====================;ent_dump !picker");
		SendToServerConsole("ent_script_dump");
			
	}
	else if(arg == "player")
	{
		printl("+++++++++++++++++++Positional++++++++++++++++++++");
		SendToServerConsole("echo Looked location: "+player.GetLookingLocation());
		SendToServerConsole("echo Eye angles: "+player.GetEyeAngles());
		SendToServerConsole("echo Player position: "+player.GetPosition());
		//SendToServerConsole("cl_dumpplayer 1"); // client only
	}
}

/*
 * @authors rhino
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
	printl(player.GetCharacterName().tolower()+"->Executing command:"+command);	
	SendToServerConsole(command);
}

/*
 * @authors rhino
 */
::AdminSystem.RandomlineCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
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
	}

	// Speaker selection
	if(targetname == "random")
	{
		targetname = Utils.GetRandValueFromArray(AdminSystem.Vars.CharacterNamesLower);
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
	
		targetname = targetname.GetCharacterName().tolower();
		speaker = Utils.GetPlayerFromName(targetname);
	}
	else if(Utils.GetIDFromArray(AdminSystem.Vars.CharacterNamesLower,targetname) == -1)
	{
		printl(GetArgument(1)+" is not a character name");return;
	}
	else
	{
		speaker = Utils.GetPlayerFromName(targetname);
	}

	if(speaker==null){printl(name+" ->No person found as speaker");return;}

	randomline_path = (linesource == null) ? Utils.GetRandValueFromArray(::Survivorlines.Paths[targetname]) : Utils.GetRandValueFromArray(::Survivorlines.Paths[linesource.tolower()]);
	speaker.Speak(randomline_path);
	
	//Output messages
	if (AdminSystem.Vars._outputsEnabled[name])
	{	
		if (AdminSystem.Vars._saveLastLine[name])
		{
			AdminSystem.Vars._savedLine[name].target = targetname;
			AdminSystem.Vars._savedLine[name].source = randomline_path;
			Utils.SayToAll("Saved for "+name+" ->scripted_user_func speak,"+targetname+","+randomline_path);
		}
		else
		{
			Utils.SayToAll(name+" ->scripted_user_func speak,"+targetname+","+randomline_path);
		}
	}
	else
	{	
		if (AdminSystem.Vars._saveLastLine[name])
		{
			AdminSystem.Vars._savedLine[name].target = targetname;
			AdminSystem.Vars._savedLine[name].source = randomline_path;
			printl("Saved for "+name+" ->scripted_user_func speak,"+targetname+","+randomline_path);
		}
		else
		{
			printl(name+" ->scripted_user_func speak,"+targetname+","+randomline_path);
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
	
	local name = player.GetCharacterName().tolower();	
	local red = GetArgument(1);
	local green = GetArgument(2);
	local blue = GetArgument(3);
	local alpha = GetArgument(4);
	if (red==null)
		return;

	if (alpha==null)
		alpha = 1.0;

	ent.SetColor(red,green,blue,alpha);
	if (AdminSystem.Vars._outputsEnabled[name])
	{Utils.SayToAll(name+"->Changed color:("+red+","+green+","+blue+","+alpha+") of "+ent.GetName());}
	else
	{printl(name+"-> Changed color:("+red+","+green+","+blue+","+alpha+") of "+ent.GetName());}

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
	
	local name = player.GetCharacterName().tolower();	
	local key = GetArgument(1);
	local val = GetArgument(2);
	
	ent.SetKeyValue(key,val);
	if (AdminSystem.Vars._outputsEnabled[name])
	{Utils.SayToAll(name+"->Changed key:"+key+" value to:"+val+" of "+ent.GetName());}
	else
	{printl(name+" ->Changed key:"+key+" value to:"+val+" of "+ent.GetName());}

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

	local name = player.GetCharacterName().tolower();
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

		printl(name +" Updated prop("+typename+") setting "+setting+" to: "+val);
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

	local name = player.GetCharacterName().tolower();
	local typename = GetArgument(1);
	if (typename != null)
	{	
		AdminSystem.Vars._prop_spawn_settings_menu_type[name] = typename;
		printl(name +" Updated prop menu type :"+typename);
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
	
	local name = player.GetCharacterName().tolower();
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
	Utils.SayToAll(infostr);
}

/*
 * @authors rhino
 */
::AdminSystem.Save_particleCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName().tolower();
	local source = GetArgument(1);
	local duration = GetArgument(2);
	if ( duration == null)
	{
		duration = AdminSystem.Vars._preferred_duration[name];
	}
	
	AdminSystem.Vars._savedParticle[name].source = source;
	AdminSystem.Vars._savedParticle[name].duration = duration;

	if (AdminSystem.Vars._outputsEnabled[name])
	{
		Utils.SayToAll("Saved for "+name+" ->scripted_user_func attach_particle,"+source+","+duration);
	}
	else
	{
		printl("Saved for "+name+" ->scripted_user_func attach_particle,"+source+","+duration);
	}
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

	local name = player.GetCharacterName().tolower();
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

	ent.AttachParticle(particle, duration);
	if (AdminSystem.Vars._outputsEnabled[name])
	{Utils.SayToAll(name+"->Attached particle("+duration+" sec):"+particle+" to:"+ent.GetName());}
	else
	{printl(name+" ->Attached particle("+duration+" sec):"+particle+" to:"+ent.GetName());}

	
}

/*
 * @authors rhino
 */
::AdminSystem.Randomparticle_save_stateCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
	local newstate = !AdminSystem.Vars._saveLastParticle[name];
	AdminSystem.Vars._saveLastParticle[name] = newstate;

	Utils.SayToAll("Random particle saving for "+name+" is"+( newstate ? " Enabled":" Disabled"));
}

/*
 * @authors rhino
 */
::AdminSystem.Update_attachment_preferenceCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;

	local name = player.GetCharacterName().tolower();
	local duration = GetArgument(1);
	if (duration == null)
	{
		duration = 30;
	}
	else
	{
		duration = duration.tofloat();
	}
	AdminSystem.Vars._preferred_duration[name] = duration;
	printl(name +" Updated attachment duration:"+duration);

}

/*
 * @authors rhino
 */
::AdminSystem.Display_saved_particleCmd <- function(player, args)
{	
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local name = player.GetCharacterName().tolower();
	if (AdminSystem.Vars._saveLastLine[name])
	{	
		local particleinfo = AdminSystem.Vars._savedParticle[name];
		if (particleinfo.source != "")
		{
			Utils.SayToAll(name+" ->scripted_user_func particle,"+particleinfo.source);
		}
		else
		{
			Utils.SayToAll("No saved particle was found for "+name);
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
	
	local name = player.GetCharacterName().tolower();
	local particleinfo = AdminSystem.Vars._savedParticle[name];
	if (particleinfo.source != "")
	{
		local EyePosition = player.GetLookingLocation();
		g_ModeScript.CreateParticleSystemAt( null, EyePosition, particleinfo.source, true );

		if (AdminSystem.Vars._outputsEnabled[name])
		{
			Utils.SayToAll(name+" ->scripted_user_func particle,"+particleinfo.source);
		}
		else
		{
			printl(name+" ->scripted_user_func particle,"+particleinfo.source);
		}
	}
	else
	{
		printl("No saved particle was found for "+name);
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
		
	local name = player.GetCharacterName().tolower();
	local particleinfo = AdminSystem.Vars._savedParticle[name];
	if (particleinfo.source != "")
	{
		ent.AttachParticle(particleinfo.source, particleinfo.duration)

		if (AdminSystem.Vars._outputsEnabled[name])
		{
			Utils.SayToAll(name+" ->scripted_user_func attach_particle,"+particleinfo.source+","+particleinfo.duration);
		}
		else
		{
			printl(name+" ->scripted_user_func attach_particle,"+particleinfo.source+","+particleinfo.duration);
		}
	}
	else
	{
		printl("No saved particle was found for "+name);
	}
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

	printl(player.GetCharacterName() +" Updated sv_cheats:"+(1-oldval).tointeger());

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

	Utils.SayToAll(player.GetCharacterName()+" set custom responses to:"+( newstate ? " Enabled":" Disabled"));
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
			Utils.SayToAllDel("Disabled Director");
	}
	else if ( AdminSystem.Vars.DirectorDisabled && (Command == "start" || Command == "on" || Command == "enable") )
	{
		AdminSystem.Vars.DirectorDisabled = false;
		Utils.StartDirector();
		if ( AdminSystem.DisplayMsgs )
			Utils.SayToAllDel("Enabled Director");
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
