::Quix <- 
{
    Interval = 0.003
    TimerName = "PS_QUIX_TIMER_"
    Table = {}
}

/*
 * @author rhino
 * 
 * @description Create a condition checker that calls a callback function given times at most with given arguments
 *
 * @param name <string> : Name of the condition checker 
 * @param condition <function> : Condition function, first parameter is the check count (incremented by 1 after every check), second parameter is given arguments
 * @param callback <function> : Callback function, first parameter is check count, second parameter is successful condition count (incremented by 1 after every successful @condition call), third parameter is given arguments
 * @param [count <int> = 1] : Maximum amount of successful checks to stop the process
 * @param [cond_params <variable> = null] : Arguments to pass to condition function's 2nd parameter 
 * @param [call_params <variable> = null]: Arguments to pass to callback function's 3rd parameter 
 *
 * @return the created condition checker
 */
::Quix.AddLimited <- function(name,condition,callback,count=1,cond_params=null,call_params=null)
{
    if(name in ::Quix.Table)
    {
        printl(name+" already exists!")
        return
    }

    local e = Utils.CreateEntityWithTable({classname="logic_compare",origin=Vector(0,0,0),angles=QAngle(0,0,0)})
    e.SetName(Quix.TimerName+name)
	e = e.GetBaseEntity()
	
	::Quix.Table[name] <- e.GetName()

    local interval = ::Quix.Interval
	local scp = e.GetScriptScope()
	
    scp["name"] <- name
    scp["index"] <- 0
    scp["count"] <- 0
    scp["condition"] <- condition
	scp["callback"] <- callback

    scp["QUIX"] <- function(...)
    {
		local sc = self.GetScriptScope()
		if(sc["condition"](sc["index"],cond_params))
        {
            sc["count"]++
			sc["callback"](sc["index"],sc["count"],call_params)
        }

        sc["index"]++

        if(sc["count"] == sc["limit"])
        {
            delete ::Quix.Table[sc["name"]]
		    DoEntFire("!self","Kill","",0,null,self)
            return
        }
        else
		    DoEntFire("!self","CallScriptFunction","QUIX",interval,null,self)
    }
    
    if(count < 1)
    {
        count = 1
    }

    scp["limit"] <- count

    DoEntFire("!self","CallScriptFunction","QUIX",interval,null,e)
}

/*
 * @author rhino
 * 
 * @description Create a condition checker that calls a callback function with given arguments until it is removed
 *
 * @param name <string> : Name of the condition checker 
 * @param condition <function> : Condition function, first parameter is the check count (incremented by 1 after every check), second parameter is given arguments
 * @param callback <function> : Callback function, first parameter is check count, second parameter is successful condition count (incremented by 1 after every successful @condition call), third parameter is given arguments
 * @param [cond_params <variable> = null] : Arguments to pass to condition function's 2nd parameter 
 * @param [call_params <variable> = null]: Arguments to pass to callback function's 3rd parameter 
 *
 * @return the created condition checker
 */
::Quix.AddUnlimited <- function(name,condition,callback,cond_params=null,call_params=null)
{
    if(name in ::Quix.Table)
    {
        printl(name+" already exists!")
        return
    }

    local e = Utils.CreateEntityWithTable({classname="logic_compare",origin=Vector(0,0,0),angles=QAngle(0,0,0)})
    e.SetName(Quix.TimerName+name)
	e = e.GetBaseEntity()
	
	::Quix.Table[name] <- e.GetName()

    local interval = ::Quix.Interval
	local scp = e.GetScriptScope()
	
    scp["name"] <- name
    scp["index"] <- 0
    scp["count"] <- 0
    scp["condition"] <- condition
	scp["callback"] <- callback

    scp["QUIX_INF"] <- function(...)
    {
		local sc = self.GetScriptScope()
		if(sc["condition"](sc["index"],cond_params))
        {
            sc["count"]++
			sc["callback"](sc["index"],sc["count"],call_params)
        }

        sc["index"]++
        
        DoEntFire("!self","CallScriptFunction","QUIX_INF",interval,null,self)
    }
    
    DoEntFire("!self","CallScriptFunction","QUIX_INF",interval,null,e)
}

/*
 * @author rhino
 * 
 * @description Create a key listener that calls a callback function with given arguments when a given pressing condition is met
 *
 * @param name <string> : Name of the condition checker 
 * @param button <int> : Button mask
 * @param usage <int> : Usage mask, WHILE_NOT_PRESSED = 0, WHEN_PRESSED = 1, WHILE_PRESSED = 2, WHEN_UNPRESSED = 4
 * @param callback <function> : Callback function, first parameter is the player itself as a VSLib.Player , second parameter is a table about press/unpress timings
 * @param [call_params <variable> = null]: Arguments to pass to callback function's 3rd parameter 
 *
 */
::Quix.AddListener <- function(name,playerID,button,callback,usage=PS_WHEN_PRESSED,overwrite=true)
{
    local uses = split(::Constants.ConstStrLookUp("PS_WH",usage),"|")

    if(name in ::Quix.Table)
    {
        if(!overwrite)
        {
            printl(name+" already exists!")
            return
        }
        else
            ::Quix.ClearTable(name)
    }

    foreach(i,use in uses)
    {
        ::Quix.SetListenerEntity(name,playerID,button,callback,getconsttable()[use])
    }
}

::Quix.ClearTable <- function(name)
{
    foreach(n,e in ::Quix.Table[name])
    {
        if(e.IsValid())
        {
            DoEntFire("!self","Kill","",0,null,e)
        }
    }
    delete ::Quix.Table[name]
}

::Quix.ClearFromTable <- function(name,e_name)
{
    foreach(n,e in ::Quix.Table[name])
    {
        if(e.IsValid() && e.GetName().find(e_name) != null)
        {
            DoEntFire("!self","Kill","",0,null,e)
            if(::Quix.Table[name].len() == 1)
                delete ::Quix.Table[name]
            else
                delete ::Quix.Table[name][n]
            return
        }
    }
}

::Quix.SetListenerEntity <- function(name,playerID,button,callback,usage=PS_WHEN_PRESSED)
{
    local e = Utils.CreateEntityWithTable({classname="logic_compare",origin=Vector(0,0,0),angles=QAngle(0,0,0)})
    
    if(!(name in ::Quix.Table))
    {
        ::Quix.Table[name] <- {}
    }
    e.SetName(Quix.TimerName+name+"_"+::Quix.Table[name].len())
	e = e.GetBaseEntity()

	::Quix.Table[name][e.GetName()] <- e
    
    local interval = ::Quix.Interval
	local scp = e.GetScriptScope()
	
    scp["name"] <- name
    scp["press_time"] <- 0
    scp["unpress_time"] <- 0
    scp["press_count"] <- 0
    scp["press_length"] <- 0
    scp["pressed_last_time"] <- false
    
	scp["callback"] <- callback

    if(usage == PS_WHEN_PRESSED)
    {
        scp["QUIX_WHEN_PRESSED"] <- function(...)
        {
            local sc = self.GetScriptScope()
            local p = Player(playerID)
            if(!p.IsEntityValid())
            {
                ::Quix.ClearFromTable(scp["name"],self.GetName())
                return
            }
            if((p.GetPressedButtons() & button) != 0)
            {
                if(!scp["pressed_last_time"])
                {
                    scp["pressed_last_time"] = true
                    scp["press_count"]++
                    scp["press_time"] = Time()
                    local info = 
                    {
                        press_time  = scp["press_time"]
                        unpress_time  = scp["unpress_time"]
                        press_count = scp["press_count"]
                        press_length = 0
                    }
                    //printl("pressed")
                    sc["callback"](p,info)
                }
            }
            else if(scp["pressed_last_time"])
            {
                scp["unpress_time"] = Time()
                scp["pressed_last_time"] = false
            }
            
            DoEntFire("!self","CallScriptFunction","QUIX_WHEN_PRESSED",interval,null,self)
        }
        
        DoEntFire("!self","CallScriptFunction","QUIX_WHEN_PRESSED",interval,null,e)
    }

    else if(usage == PS_WHILE_PRESSED)
    {
        scp["first_io_skipped"] <- false
        scp["QUIX_WHILE_PRESSED"] <- function(...)
        {
            local sc = self.GetScriptScope()
            local p = Player(playerID)
            if(!p.IsEntityValid())
            {
                ::Quix.ClearFromTable(scp["name"],self.GetName())
                return
            }
            if((p.GetPressedButtons() & button) != 0)
            {
                if(!scp["pressed_last_time"])
                {
                    scp["pressed_last_time"] = true
                    scp["press_count"]++
                    scp["press_time"] = Time()
                }
                local info = 
                {
                    press_time  = scp["press_time"]
                    unpress_time  = scp["unpress_time"]
                    press_count = scp["press_count"]
                    press_length = Time() - scp["press_time"]
                }
                if(scp["first_io_skipped"])
                {
                    //printl("pressing")
                    sc["callback"](p,info)
                }
                else
                {
                    scp["first_io_skipped"] = true
                }
            }
            else if(scp["pressed_last_time"])
            {
                scp["unpress_time"] = Time()
                scp["pressed_last_time"] = false
                scp["first_io_skipped"] = false
            }
            
            DoEntFire("!self","CallScriptFunction","QUIX_WHILE_PRESSED",interval,null,self)
        }
        
        DoEntFire("!self","CallScriptFunction","QUIX_WHILE_PRESSED",interval,null,e)
    }

    else if(usage == PS_WHEN_UNPRESSED)
    {
        scp["QUIX_WHEN_UNPRESSED"] <- function(...)
        {
            local sc = self.GetScriptScope()
            local p = Player(playerID)
            if(!p.IsEntityValid())
            {
                ::Quix.ClearFromTable(scp["name"],self.GetName())
                return
            }

            if((p.GetPressedButtons() & button) != 0)
            {
                if(!scp["pressed_last_time"])
                {
                    scp["pressed_last_time"] = true
                    scp["press_count"]++
                    scp["press_time"] = Time()
                }
            }
            else if(scp["pressed_last_time"])
            {
                scp["unpress_time"] = Time()
                scp["press_length"] = scp["unpress_time"]-scp["press_time"]
                scp["pressed_last_time"] = false
                local info = 
                {
                    press_time  = scp["press_time"]
                    unpress_time  = scp["unpress_time"]
                    press_count = scp["press_count"]
                    press_length = scp["press_length"]
                }
                //printl("unpressed")
                sc["callback"](p,info)
            }
            
            DoEntFire("!self","CallScriptFunction","QUIX_WHEN_UNPRESSED",interval,null,self)
        }
        
        DoEntFire("!self","CallScriptFunction","QUIX_WHEN_UNPRESSED",interval,null,e)
    }

    else if(usage == PS_WHILE_UNPRESSED)
    {
        scp["first_io_skipped"] <- false
        scp["QUIX_WHILE_UNPRESSED"] <- function(...)
        {
            local sc = self.GetScriptScope()
            local p = Player(playerID)
            if(!p.IsEntityValid())
            {
                ::Quix.ClearFromTable(scp["name"],self.GetName())
                return
            }
            if((p.GetPressedButtons() & button) == 0)
            {
                local info = 
                {
                    press_time  = scp["press_time"]
                    unpress_time  = scp["unpress_time"]
                    press_count = scp["press_count"]
                    press_length = scp["press_length"]
                }
                scp["pressed_last_time"] = false
                
                if(scp["first_io_skipped"])
                {
                    //printl("not pressing")
                    sc["callback"](p,info)
                }
                else
                {
                    scp["first_io_skipped"] = true
                }
            }
            else
            {
                scp["first_io_skipped"] = false
                if(!scp["pressed_last_time"])
                {
                    scp["pressed_last_time"] = true
                    scp["press_count"]++
                    scp["unpress_time"] = Time()
                    scp["press_time"] = Time()
                }
                else
                {
                    scp["press_length"] = Time()-scp["press_time"]
                }
            }
            
            DoEntFire("!self","CallScriptFunction","QUIX_WHILE_UNPRESSED",interval,null,self)
        }
        
        DoEntFire("!self","CallScriptFunction","QUIX_WHILE_UNPRESSED",interval,null,e)
    }
}

/*
 * @authors rhino
 *
 * @description Format a timer name for given player,key and function/command
 */
::Quix.FormatName <- function(player,key,func)
{
    if(func.find("!") == 0)
    {
        return player.GetSteamID() + "_" + key + "_" + func.slice(1) + "_CMD"
    }
    else
    {
        return player.GetSteamID() + "_" + key + "_" + func + "_FOO"
    }
}

::Quix.GetKeyConst <- function(keyname,safe=null)
{
    local keyval = 0
    if(safe)
    {
        foreach(i,key in split(keyname,"|"))
        {
            if(!("BUTTON_"+key in getconsttable()))
            {
                ::Printer(safe,"Key name "+key+" is unknown.","error")
                return null;
            }
            keyval = getconsttable()["BUTTON_"+key] | keyval
        }
    }
    else
    {
        foreach(i,key in split(keyname,"|"))
        {
            keyval = getconsttable()["BUTTON_"+key] | keyval
        }
    }
    return keyval
}

/*
 * @authors rhino
 *
 * @description Add a quix listener for given key mask with each function/command in the given table for given player
 *
 * @param player <VSLib.Player> : Player to process the table for
 * @param key <string> : Key mask as string 
 * @param keytbl <table> : Command and function tables of the key
 */
::Quix.ProcessTable <- function(player,key,keytbl)
{
	local keyval = ::Quix.GetKeyConst(key)
    local pID = player.GetIndex()
	foreach(funcname,tbl in keytbl)
	{
		if(funcname.find("!") == 0)
		{
            local timername = ::Quix.FormatName(player,key,funcname)
            local args = tbl.Arguments
            local trigger = ::ChatTriggers[funcname.slice(1)]
            ::Quix.AddListener(timername,
                                pID,
                                keyval,
                                @(p,t) ::AliasCompiler.CommandCall(trigger,p,args,""),
                                tbl.Usage)
		}
		else
		{
            local timername = ::Quix.FormatName(player,key,funcname)
            ::Quix.AddListener(timername,pID,keyval,tbl.Function,tbl.Usage)
		}
	}
}

/*
 * @author rhino
 * 
 * @description Remove an existing quix timer
 *
 * @param name <string> : Name of the condition checker 
 */
::Quix.Remove <- function(name)
{
    if(name in ::Quix.Table)
    {
        foreach(obj in ::Quix.Table[name])
		    DoEntFire("!self","Kill","",0,null,obj)
		delete ::Quix.Table[name]
    }
	else
        printl(name+" doesn't exists!")

}