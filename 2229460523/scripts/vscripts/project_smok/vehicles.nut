if(!("DriveParameters" in getroottable()))
{
    ::DefaultDriveableCarCollisionParameters <- function(tbl)
    {
        tbl.vehicle_collision <- 0
        tbl.player_collision <- 12
        tbl.player_movecollide <- 0
        tbl.player_movetype <- MOVETYPE_CUSTOM
    }

    ::MakeDrivableVehicleParams <-
    {
        car_start_duration = 1.0
        GlowR = 70
        GlowG = 180
        GlowB = 205
        GlowA = 255
        GlowRange = 250
    }

    ::DefaultDrivingParameters <- function(...)
    {
        local tbl = 
        {
            forward_push = 43.0
            nitrous_factor = 1.6
            back_push = -25.0
            downforce = -0.1

            speed_max = 850.0
            turn_factor = 0.82

            turn_yaw = 3.3
            turn_pitch = 0.1

            friction = 0.08
            turn_friction = 0.2
            turn_friction_nothrottle = 0.23

            driving_direction = DRIVE_DIRECTION_STRAIGHT
        }
        return tbl
    }

    ::CarTypes <-
    {
        "sedan1" : "props_vehicles/cara_95sedan"
        "sedan2" : "props_vehicles/cara_84sedan"
        "sedan3" : "props_vehicles/cara_69sedan"
        "hatchback" : "props_vehicles/cara_82hatchback"
    }

    ::DriveParameters <- {}

    ::DriveableCarModels <- 
    {
        "props_vehicles/cara_95sedan" :
        {
            MDL = "models/props_vehicles/cara_95sedan.mdl&models/props_vehicles/cara_95sedan_glass.mdl"
            driver_origin = Vector(-2.799910,18.221106,-10.000000)
            getting_out_point = Vector(-2.799910,68.221106,0.000000)
        }
        "props_vehicles/cara_69sedan" :
        {
            MDL = "models/props_vehicles/cara_69sedan.mdl&models/props_vehicles/cara_69sedan_glass.mdl"
            driver_origin = Vector(-2.799910,18.221106,-10.000000)
            getting_out_point = Vector(-2.799910,68.221106,0.000000)
        }
        "props_vehicles/cara_84sedan" :
        {
            MDL = "models/props_vehicles/cara_84sedan.mdl&models/props_vehicles/cara_84sedan_glass.mdl"
            driver_origin = Vector(-2.799910,18.221106,-10.000000)
            getting_out_point = Vector(-2.799910,68.221106,0.000000)
        }
        "props_vehicles/cara_82hatchback" :
        {
            MDL = "models/props_vehicles/cara_82hatchback.mdl&models/props_vehicles/cara_82hatchback_glass.mdl"
            driver_origin = Vector(-2.799910,18.221106,-10.000000)
            getting_out_point = Vector(-2.799910,68.221106,0.000000)
        }
    }


    foreach(carmdl,tbl in ::DriveableCarModels)
    {
        ::DefaultDriveableCarCollisionParameters(::DriveableCarModels[carmdl])
        ::DriveParameters[carmdl] <- ::DefaultDrivingParameters()
    }
}


::DriveMainFunctions <-
{
    CreateVehicle = function(player,car)
    {
        local MDL = ::DriveableCarModels[car].MDL
        local v_collision = ::DriveableCarModels[car].vehicle_collision

        local origin = player.GetOrigin()+Vector(0,0,10)
        local angles = QAngle(0,player.GetEyeAngles().y,0)
        
        local createdent = []

        foreach(mdl in split(MDL,"&"))
        {
            local ent = Utils.SpawnPhysicsMProp( Utils.CleanColoredString(mdl), origin, angles );
            if(ent != null && ent.IsEntityValid())
            {
                createdent.append(ent);
                ent.SetMoveType(MOVETYPE_NONE);
                ent.SetNetProp("m_CollisionGroup",v_collision)
            }
            else
            {
                if(createdent.len()==0)	// parent failed
                    return null

                ent = Utils.SpawnDynamicProp( Utils.CleanColoredString(mdl), origin, angles );
                if(ent != null && ent.IsEntityValid())
                {
                    createdent.append(ent);
                    ent.SetMoveType(MOVETYPE_NONE);
                    ent.SetNetProp("m_CollisionGroup",v_collision)
                }
            }
        }

        local parentent = createdent[0];
        foreach(e in createdent.slice(1,createdent.len()))
        {
            e.Input("setparent","#"+parentent.GetIndex(),0);
			e.SetNetProp("m_CollisionGroup",10)
        }
        parentent.Input("RunScriptCode","_dropit(Entity("+parentent.GetIndex()+"))",0);
        
        parentent.InputColor(RandomInt(122,255),RandomInt(122,255),RandomInt(122,255),0)

        local tbl = {parentent=parentent,createdent=createdent}
        return tbl
    }

    Initialize = function(player,vehicle,cartype)
    {
        local v_tbl = ::DriveableCarModels[cartype]
        local driver_origin = v_tbl.driver_origin

        player.SetNetProp("m_CollisionGroup",v_tbl.player_collision)
        player.SetNetProp("m_MoveCollide",v_tbl.player_movecollide)
        player.SetMoveType(v_tbl.player_movetype)

        player.SetNetProp("m_stunTimer.m_timestamp",Time()+99999)
        player.SetNetProp("m_stunTimer.m_duration",99999)

        player.Input("setparent","#"+vehicle.GetIndex())
        player.Input("runscriptcode","self.SetLocalOrigin(Vector("+driver_origin.x+","+driver_origin.y+","+driver_origin.z+"))",0.1)
        
		player.SetDrivenVehicle(vehicle,cartype,driver_origin)

	    player.Input("runscriptcode","self.SnapEyeAngles(QAngle(0,0,0))",0.08)
    }

    CreateListeners = function(player)
    {
        local pID = player.GetIndex()
		local cname = player.GetCharacterNameLower()
        local car = player.GetScriptScope()["PS_VEHICLE_TYPE"]

        ::Quix.AddListener("DRIVE_BUTTON_FORWARD_"+cname+"_"+car,
                            pID,
                            BUTTON_FORWARD,
                            ::DriveDirectiFunctions.forward,
                            PS_WHEN_PRESSED|PS_WHILE_PRESSED)
        
        ::Quix.AddListener("DRIVE_BUTTON_BACK_"+cname+"_"+car,
                            pID,
                            BUTTON_BACK,
                            ::DriveDirectiFunctions.back,
                            PS_WHEN_PRESSED|PS_WHILE_PRESSED)
        
        ::Quix.AddListener("DRIVE_BUTTON_LEFT_"+cname+"_"+car,
                            pID,
                            BUTTON_MOVELEFT,
                            ::DriveDirectiFunctions.left,
                            PS_WHEN_PRESSED|PS_WHILE_PRESSED)
        
        ::Quix.AddListener("DRIVE_BUTTON_RIGHT_"+cname+"_"+car,
                            pID,
                            BUTTON_MOVERIGHT,
                            ::DriveDirectiFunctions.right,
                            PS_WHEN_PRESSED|PS_WHILE_PRESSED)
        
        ::Quix.AddListener("DRIVE_ORIGIN_KEEP_"+cname+"_"+car,
                            pID,
                            0,
                            ::DriveDirectiFunctions.origin_keep,
                            PS_WHILE_UNPRESSED)
        
        ::Quix.AddListener("DRIVE_LOOKAHEAD_"+cname+"_"+car,
                            pID,
                            BUTTON_SHOVE,
                            ::DriveDirectiFunctions.look_ahead,
                            PS_WHEN_PRESSED|PS_WHILE_PRESSED)
        
        ::Quix.AddListener("DRIVE_N2O_"+cname+"_"+car,
                            pID,
                            BUTTON_WALK,
                            ::DriveDirectiFunctions.nitrous_state,
                            PS_WHEN_PRESSED|PS_WHEN_UNPRESSED)
        
        ::Quix.AddListener("DRIVE_JUMP_"+cname+"_"+car,
                            pID,
                            BUTTON_JUMP,
                            ::DriveDirectiFunctions.jump,
                            PS_WHEN_PRESSED)
    }

	CreateListenersPassenger = function(player)
	{
		::Quix.AddListener("PASSENGER_ORIGIN_KEEP_"+player.GetCharacterNameLower()+"_"+player.GetScriptScope()["PS_VEHICLE_TYPE"],
							player.GetIndex(),
							0,
							::PassengerDirectiFunctions.origin_keep,
							PS_WHILE_UNPRESSED)
	}

	RemoveListeners = function(player)
	{
        if(player.GetScriptScope() == null)
            return
    
		local cname = player.GetCharacterNameLower()
        local car = player.GetScriptScope()["PS_VEHICLE_TYPE"]
		::Quix.Remove("DRIVE_BUTTON_FORWARD_"+cname+"_"+car)
		::Quix.Remove("DRIVE_BUTTON_BACK_"+cname+"_"+car)
		::Quix.Remove("DRIVE_BUTTON_LEFT_"+cname+"_"+car)
		::Quix.Remove("DRIVE_BUTTON_RIGHT_"+cname+"_"+car)
		::Quix.Remove("DRIVE_ORIGIN_KEEP_"+cname+"_"+car)
		::Quix.Remove("DRIVE_LOOKAHEAD_"+cname+"_"+car)
		::Quix.Remove("DRIVE_N2O_"+cname+"_"+car)
		::Quix.Remove("DRIVE_JUMP_"+cname+"_"+car)
	}

	RemoveListenersPassenger = function(player)
	{
        if(player.GetScriptScope() == null)
            return
    
		::Quix.Remove("PASSENGER_ORIGIN_KEEP_"+player.GetCharacterNameLower()+"_"+player.GetScriptScope()["PS_VEHICLE_TYPE"])
	}

    RestoreDriver = function(player)
    {
        player.GetScriptScope()["PS_VEHICLE_VALID"] <- false
        if(player.GetScriptScope()["PS_VEHICLE_ENT"] != null && player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope() != null)
        {
            player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVE_ABILITY"] <- false
            player.GetScriptScope()["PS_VEHICLE_ENT"].GetScriptScope()["PS_HAS_DRIVER"] <- false
            player.GetScriptScope()["PS_VEHICLE_ENT"] <- null
        }
        player.SetNetProp("m_stunTimer.m_timestamp",Time()+0.5)
        player.SetNetProp("m_stunTimer.m_duration",0.5)
		if(player.GetScriptScope()["PS_VEHICLE_TYPE"] in ::DriveableCarModels)
        	player.SetLocalOrigin(::DriveableCarModels[player.GetScriptScope()["PS_VEHICLE_TYPE"]].getting_out_point)
        player.Input("clearparent",0.05)
        player.Input("RunScriptCode","_dropit(Player("+player.GetIndex()+"))",0.1);
        player.Input("RunScriptCode","Player("+player.GetIndex()+").SetNetProp(\"m_CollisionGroup\",5)",0.15);
        player.SetMoveType(MOVETYPE_WALK);
    }

	GoForward = function(player,vehicle,carparams)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.friction,0.5)
		if(vehicle.GetPhysicsVelocity().Length() < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale(carparams.forward_push*(vehicle.GetScriptScope()["N2O_STATE"] ? carparams.nitrous_factor : 1.0))+Vector(0,0,vehicle.GetPhysicsVelocity().Length()*carparams.downforce))
		}
	}

	GoBackward = function(player,vehicle,carparams)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.friction,0.5)
		if(vehicle.GetPhysicsVelocity().Length() < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale(carparams.back_push)+Vector(0,0,vehicle.GetPhysicsVelocity().Length()*carparams.downforce))
		}
	}

	TurnLeftForward = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.turn_friction,0.5)
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local speed = vehicle.GetPhysicsVelocity().Length()
		vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*-1*(speed/carparams.speed_max),yaw*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
		if(speed < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor+(vehicle.GetScriptScope()["N2O_STATE"] ? carparams.nitrous_factor*carparams.forward_push : carparams.forward_push))))
		}
        else
        {
            vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( speed*carparams.turn_factor ))
        }

	}

	TurnLeftBackward = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.turn_friction,0.5)
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local speed = vehicle.GetPhysicsVelocity().Length()
		vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*(speed/carparams.speed_max),yaw*-1*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
		if(speed < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)*-1))
		}
	}

	TurnLeftFree = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local movedir = vehicle.GetPhysicsVelocity()
		local speed = movedir.Length()
		local vehicledir = RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector())
		local angbetween = (acos((movedir.x*vehicledir.x + movedir.y*vehicledir.y + movedir.z*vehicledir.z)/speed)*(180/PI)) % 180
		
        vehicle.OverrideFriction(carparams.turn_friction_nothrottle,0.5)
		if(angbetween > 90.0)
		{
			vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*-1*(speed/carparams.speed_max),yaw*-1*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
			if(speed < carparams.speed_max)
			{
				vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)*-1))
			}
		}
		else
		{
			vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*(speed/carparams.speed_max),yaw*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
			if(speed < carparams.speed_max)
			{
				vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)))
			}
		}
	}

	TurnRightForward = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.turn_friction,0.5)
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local speed = vehicle.GetPhysicsVelocity().Length()
		vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*-1*(speed/carparams.speed_max),yaw*-1*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
		
		if(speed < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale((speed*carparams.turn_factor+(vehicle.GetScriptScope()["N2O_STATE"] ? carparams.nitrous_factor*carparams.forward_push : carparams.forward_push))))
		}
        else
        {
            vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( speed*carparams.turn_factor ))
        }
	}

	TurnRightBackward = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
        vehicle.OverrideFriction(carparams.turn_friction,0.5)
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local speed = vehicle.GetPhysicsVelocity().Length()
		vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*(speed/carparams.speed_max),yaw*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
		if(speed < carparams.speed_max)
		{
			vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)*-1))
		}
	}

	TurnRightFree = function(vehicle,carparams,steer_duration)
	{
		if(vehicle.GetParent() != null)
			return
		local yaw = carparams.turn_yaw + carparams.turn_yaw * (steer_duration >= 1.0 ? 1.0 : steer_duration )
		local movedir = vehicle.GetPhysicsVelocity()
		local speed = movedir.Length()
		local vehicledir = RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector())
		local angbetween = (acos((movedir.x*vehicledir.x + movedir.y*vehicledir.y + movedir.z*vehicledir.z)/speed)*(180/PI)) % 180
		
        vehicle.OverrideFriction(carparams.turn_friction_nothrottle,0.5)
		if(angbetween > 90.0)
		{
			vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*(speed/carparams.speed_max),yaw*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
			if(speed < carparams.speed_max)
			{
				vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)*-1))
			}
		}
		else
		{
			vehicle.SetForwardVector(RotatePosition(Vector(0,0,0),QAngle(carparams.turn_pitch*-1*(speed/carparams.speed_max),yaw*-1*(speed/carparams.speed_max),0),vehicle.GetForwardVector()))
			if(speed < carparams.speed_max)
			{
				vehicle.Push(RotatePosition(Vector(0,0,0),carparams.driving_direction,vehicle.GetForwardVector()).Scale( (speed*carparams.turn_factor)))
			}
		}
	}
}

::PassengerDirectiFunctions <-
{
	origin_keep = function(player,t_tbl)
	{
		local vehicle = player.GetPassengerVehicle()
		if(vehicle == false || !vehicle.IsEntityValid())
		{
			::GetOutAsPassenger(player)
		}
		else
		{	
			player.SetLocalOrigin(player.GetScriptScope()["PS_VEHICLE_PASSENGER_OFFSET"])
        	player.SetMoveType(MOVETYPE_CUSTOM)
		}
	}
}
::DriveDirectiFunctions <-
{
	jump = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else if(vehicle.GetParent() == null)
		{	
			vehicle.Push(RotatePosition(Vector(0,0,0),QAngle(RandomInt(-10,10),RandomInt(-10,10),RandomInt(-10,10)),Vector(0,0,300)))
		}
	}
	origin_keep = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else
		{	
			player.SetLocalOrigin(player.GetScriptScope()["PS_VEHICLE_DRIVER_OFFSET"])
        	player.SetMoveType(::DriveableCarModels[player.GetScriptScope()["PS_VEHICLE_TYPE"]].player_movetype)
		}
	}
	look_ahead = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else
		{
			Ent(player.GetIndex()).SnapEyeAngles(::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]].driving_direction)
		}
	}
	nitrous_state = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else
		{	
			switch(t_tbl.usage_type)
			{
				case PS_WHEN_PRESSED:
					vehicle.GetScriptScope()["N2O_STATE"] <- true
					break;
				case PS_WHEN_UNPRESSED:
					vehicle.GetScriptScope()["N2O_STATE"] <- false
					break;
			}
		}
	}
	forward = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else if(((player.GetPressedButtons() & (BUTTON_BACK)) == 0) && (vehicle.GetParent() == null))
		{   
			::DriveMainFunctions.GoForward(player,vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]])
		}
	}
	back = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else if((player.GetPressedButtons() & (BUTTON_FORWARD)) == 0)
		{
			::DriveMainFunctions.GoBackward(player,vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]])
		}
	}
	left = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(vehicle == null || !vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else if((player.GetPressedButtons() & BUTTON_MOVERIGHT) == 0)
		{
			if((player.GetPressedButtons() & BUTTON_BACK) != 0)
			{
				::DriveMainFunctions.TurnLeftBackward(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
			else if((player.GetPressedButtons() & BUTTON_FORWARD) != 0) 
			{
				::DriveMainFunctions.TurnLeftForward(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
			else
			{
				::DriveMainFunctions.TurnLeftFree(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
		}
	}
	right = function(player,t_tbl)
	{
		if(!player.GetScriptScope()["PS_VEHICLE_VALID"])
			return

		local vehicle = player.GetScriptScope()["PS_VEHICLE_ENT"]
		if(!vehicle.IsEntityValid())
		{
			::DriveMainFunctions.RemoveListeners(player)
			::DriveMainFunctions.RestoreDriver(player)
		}
		else if((player.GetPressedButtons() & BUTTON_MOVELEFT) == 0)
		{
			if((player.GetPressedButtons() & BUTTON_BACK) != 0)
			{
				::DriveMainFunctions.TurnRightBackward(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
			else if((player.GetPressedButtons() & BUTTON_FORWARD) != 0) 
			{
				::DriveMainFunctions.TurnRightForward(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
			else
			{
				::DriveMainFunctions.TurnRightFree(vehicle,::DriveParameters[player.GetScriptScope()["PS_VEHICLE_TYPE"]],t_tbl.press_length)
			}
		}
	}
}

::PreparePlayerForDriving <- function(player,vehicle,cartype)
{
    ::DriveMainFunctions.Initialize(player,vehicle,cartype)

    ::DriveMainFunctions.CreateListeners(player)

	::DriveDirectiFunctions.look_ahead(player,null)
}

::ValidateDrivableEntity <- function(ent)
{
	if(ent == null || ent.HasDrivingAbility() || ent.HasDriver() || ent.GetParent() != null)
		return false;

	local entclass = ent.GetClassname();

	if(entclass == "player" || entclass.find("door") != null)
		return false;

	if(!(entclass in AdminSystem.Vars._grabAvailable) || !AdminSystem.Vars._grabAvailable[entclass])
		return false
	
	local entmdl = ent.GetModel();

	if(ent.HasBadPhysicsModel() || (entmdl.find("_glass.mdl") != null))
		return false;

	if(!ent.HasKnownModel())
		return ::GivePhysicsToEntity(ent)

	if(!ent.HasMassDefined())
		return false;
	
	return ::GivePhysicsToEntity(ent)
}

::MakeDriveableWrapper <- function(args)
{
	local player = args.player
	local vehicle = args.vehicle
	if(typeof vehicle == "string")
	{
		vehicle = Entity(vehicle)
	}
	
	if(!vehicle || !vehicle.IsEntityValid())
		return

	if(vehicle.IsLootable())
	{
		vehicle.RemoveLootAbility()
	}

    local bbox = vehicle.GetNetProp("m_Collision")

	local fullmdl = vehicle.GetModel()
	local entmdl = ShortenModelName(fullmdl)

	if(!(entmdl in DriveParameters))
	{
		::DriveParameters[entmdl] <- ::DefaultDrivingParameters()
	}
	if(!(entmdl in DriveableCarModels))
	{
		::DriveableCarModels[entmdl] <-
		{
			MDL = fullmdl
			driver_origin = Vector(0,0,2.0-bbox.z)
			getting_out_point = bbox
		}
		::DefaultDriveableCarCollisionParameters(::DriveableCarModels[entmdl])
	}

	local cname = player.GetCharacterNameLower()

	local sc = vehicle.GetScriptScope()

	sc["PS_OldName"] <- vehicle.GetName()
	vehicle.SetName("PS_DRIVABLE_VEHICLE_"+cname+UniqueString())
	sc["PS_HAS_DRIVE_ABILITY"] <- true
	sc["PS_HAS_DRIVER"] <- false
	
	local keyvals = 
	{
		classname = "point_script_use_target",
		model = vehicle.GetName(), 
		origin = Vector(0,0,0)
	};

	local params = ::MakeDrivableVehicleParams
	local duration = params.car_start_duration
	if(duration <= 0)
		duration = 1

	local pscr = Utils.CreateEntityWithTable(keyvals,null,false);

	if(!pscr)
	{
		vehicle.SetName(sc["PS_OldName"])
		sc["PS_HAS_DRIVE_ABILITY"] <- false
		return
	}
	pscr.SetName("PS_DRIVE_ADDER"+UniqueString())
	local b = pscr.GetBaseEntity()
	local bsrc = pscr.GetScriptScope()

	bsrc["Duration"] <- duration
	bsrc["FinishStartProcess"] <- function()
	{
		if(!("LastPlayer" in self.GetScriptScope()))
			return;
			
		local player = self.GetScriptScope().LastPlayer
		
		if(!player.HasPrivilege(PS_USER_ADMIN))
			return

		if(player.IsDriving())
			return

		if(::DriverStateCheck(player))
		{
			Messages.ThrowPlayer(player,"You aren't in a condition to be driving right now!")
			return
		}
		self.CanShowBuildPanel( false );

		local vehicle = ::VSLib.Entity(self.GetUseModelName())

		vehicle.Input("SetGlowRange","1")
		vehicle.Input("StopGlowing","")

		if(vehicle.GetModel() != null)
		{
			if(player.HasDrivenBefore())
				::DriveMainFunctions.RemoveListeners(player)
				
			if(player.IsPassenger())
				player.GetScriptScope()["PS_IN_PASSENGER_CAR"] = null
			
			if(vehicle.GetParent() != null)
			{
				vehicle.Input("clearparent","",0);
				vehicle.Input("RunScriptCode","_dropit(Entity(self.GetEntityIndex()))",0.05);
			}

	        Timers.AddTimer(0.1,false,@(...) ::PreparePlayerForDriving(player,vehicle,ShortenModelName(vehicle.GetModel())),null)
        }

		DoEntFire("!self","kill","",0,null,self)
	}
	bsrc["Started"] <- function()
	{
		local user = self.GetScriptScope().PlayerUsingMe
		local player = null
		if(user == 0 || ("PS_HAS_DRIVER" in self.GetScriptScope() && self.GetScriptScope()["PS_HAS_DRIVER"]))
			self.StopUse()
		else
		{
			while( player = Entities.FindByClassname( player, "player" ))
			{
				if( player.GetEntityHandle() == user )
				{
					local p = ::VSLib.Player(player)
					if(!p.HasPrivilege(PS_USER_ADMIN))
					{
						self.StopUse()
						Messages.ThrowPlayer(p,"Sorry, only admins can drive vehicles!")
						Messages.InformPlayer(p,"You can use '!get_in' and '!get_out' commands to get into driveable vehicles as a passenger")
						Messages.InformPlayer(p,"As a passenger you can use '!change_passenger_seat_position {axis:x,y,z} {units}' command format to move your seat\r as a passenger")
					}
					else
					{
						self.GetScriptScope()["LastPlayer"] <- p
					}
					return
				}
			}
		}
	}

	b.CanShowBuildPanel(true)
	b.SetProgressBarText("Drivable vehicle")
	b.SetProgressBarSubText("Hold USE button for "+duration+" seconds to start driving!")
	
	b.SetProgressBarFinishTime(duration)

	b.ConnectOutput("OnUseStarted","Started")
	pscr.Input("AddOutput","OnUseFinished !self,CallScriptFunction,FinishStartProcess,0,1")
	vehicle.SetGlowColor(params.GlowR,params.GlowG,params.GlowB,params.GlowA)
	vehicle.Input("SetGlowRange",params.GlowRange.tostring())
	vehicle.Input("StartGlowing","")
	vehicle.GetScriptScope()["PS_CurrentPointUseEntity"] <- pscr

	local ch = vehicle.FirstMoveChild()
	while(ch)
	{
		ch.SetNetProp("m_CollisionGroup",10)
		ch = ch.NextMovePeer()
	}
}

::GetOutAsPassenger <- function(player)
{
	if(player.IsPassenger())
	{
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
		
		AdminSystem.Vars.IsGodEnabled[player.GetIndex()] <- false;
		local corner = player.GetScriptScope()["PS_IN_PASSENGER_CAR"].GetNetProp("m_Collision")

		player.SetNetProp("m_CollisionGroup",player.GetScriptScope()["PS_CG_BEFORE_PASSENGER"])
		player.SetNetProp("m_MoveCollide",player.GetScriptScope()["PS_MC_BEFORE_PASSENGER"])

		player.GetScriptScope()["PS_IN_PASSENGER_CAR"] <- null
		player.SetNetProp("m_stunTimer.m_timestamp",Time()+0.5)
		player.SetNetProp("m_stunTimer.m_duration",0.5)
		player.Input("runscriptcode","self.SetLocalOrigin(Vector("+corner.x+","+corner.y+","+corner.z+"))",0)
		player.Input("clearparent",0.1)
		player.Input("RunScriptCode","_dropit(Player("+player.GetIndex()+"))",0.15);
		player.Input("RunScriptCode","Player("+player.GetIndex()+").SetNetProp(\"m_CollisionGroup\",5)",0.2);
		player.SetMoveType(MOVETYPE_WALK);

		::DriveMainFunctions.RemoveListenersPassenger(player)
	}
}