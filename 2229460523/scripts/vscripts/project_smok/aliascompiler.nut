/***************\
* ALIAS METHODS *
\***************/
::AliasCompiler <- {}

/*
::AliasCompiler.Regs <- 
{
    FullReg = @"^(\w+\s+)((\w+\s+)|(\s*;?\s*\w+\s+))*\{(\w+(?:\s+;?\s*|\s*\}|\s*;\s*))((\$\w+(\s*:\s*[\w!@#$&()\\-`.+,/\""<>|*?]+)?(?:\s+;?\s*|\s*\}|\s*;\s*))|([\w!@#$&()\\-`.+,/\""<>|*?]+(?:\s+;?\s*|\s*\}|\s*;\s*)))*"

    AliasKeyReg = @"^(\w+\s+)((\w+\s+)|(\s*;?\s*\w+\s+))*"

    AliasValueReg = @"\{(\w+(?:\s+;?\s*|\s*\}|\s*;\s*))((\$\w+(\s*:\s*[\w!@#$&()\\-`.+,/\""<>|*?]+)?(?:\s+;?\s*|\s*\}|\s*;\s*))|([\w!@#$&()\\-`.+,/\""<>|*?]+(?:\s+;?\s*|\s*\}|\s*;\s*)))*"

    ParamInAliasReg = @"\$\w+(\s*:\s*[\w!@#$&()\\-`.+,/\""<>|*?]+)?(?:\s+;?\s*|\s*\}|\s*;\s*)"
}

::AliasCompiler.TestStrings <-
{
    do_the_work_params = "do_the_work_params axis rotation duration interval direction speed{ent_rotate $axis:y $rotation:180 ; rainbow $duration:30 $interval:0.5 ; ent_push $direction:backward $speed:2000}"
    do_the_work = "do_the_work {ent_rotate y 180 ; rainbow 30 0.5 ; ent_push backward 2000}"
    set_survivor_models = "set_survivor_models mdl {model !bill $mdl ; model !francis $mdl ; model !louis $mdl ; model !zoey $mdl}"
    rotate_y = "rotate_y degrees {ent_rotate y $degrees}"
    alias_1 = "alias_1 {command_name_1}"
    parsed_alias_1 = "parsed_alias_1 {command_name_1 argument_1 argument_2}"
    parametered_alias_1 = "parametered_alias_1 parameter_1 parameter_2 {command_name_1 $parameter_1 $parameter_2}"
    parametered_parsed_alias_1 = "parametered_parsed_alias_1 parameter_1 parameter_2 {command_name_1 $parameter_1:default_value_1 $parameter_2}"
    combined_alias_1 = "combined_alias_1 {command_name_1;command_name_2}"
    combined_parsed_alias_1 = "combined_parsed_alias_1 {command_name_1 default_value_1_1 default_value_1_2 ; command_name_2 default_value_2_1}"
    combined_parametered_alias_1 = "combined_parametered_alias_1 parameter_1_1 parameter_1_2 ; parameter_2_1 {command_name_1 $parameter_1_1 $parameter_1_2; command_name_2 $parameter_2_1}"
    combined_parametered_alias_2 = "combined_parametered_alias_2 parameter_1_1 parameter_1_2 {command_name_1 $parameter_1_1 $parameter_1_2; command_name_2 $parameter_1_1 ; command_name_3 $parameter_1_2}"
    combined_parametered_parsed_alias_1 = "combined_parametered_parsed_alias_1 parameter_1_1 parameter_1_2 ; parameter_2_1 {command_name_1 $parameter_1_1:default_value_1_1 $parameter_1_2:default_value_1_2 ; command_name_2 $parameter_2_1:default_value_2_1}"
}
*/

/*****************\
* UTILITY METHODS *
\*****************/
::AliasCompiler.CreateDocsFunction <- function(cmdname,helptbl,params=null)
{
    local docstring = ""
    if("docs" in helptbl)
        docstring = helptbl.docs

    local paramarr = [];
    local paramreg = regexp(@"(param_\d+)");
    if(params != null)
    {
        foreach(key,info in helptbl)
        {
            if(paramreg.match(key) && key in params)
            {   
                local pinfo = null
                local pno = key.slice(paramreg.search(key).end - 1).tointeger()
                if(typeof info == "table")
                {
                    local name = key
                    local docs = "Unknown..."

                    if("docs" in info)
                        docs = info.docs
                    if("name" in info)
                        name = info.name

                    if("when_null" in info)
                        pinfo = CMDParam(name,docs,true,info.when_null)
                    else if(params[key] != null)
                        pinfo = CMDParam(name,docs,true,params[key])
                    else
                        pinfo = CMDParam(key,info)
                }
                else
                {
                    if(params[key] != null)
                        pinfo = CMDParam(key,info,true,params[key])
                    else
                        pinfo = CMDParam(key,info)
                }

                if(paramarr.len() < pno)
                    paramarr.resize(pno);

                paramarr[pno - 1] = pinfo
            }
        }
    }
    else
    {
        foreach(key,info in helptbl)
        {
            if(paramreg.match(key))
            {  
                local pinfo = null
                local pno = key.slice(paramreg.search(key).end - 1).tointeger()

                local name = key
                local docs = "Unknown..."

                if("docs" in info)
                    docs = info.docs
                if("name" in info)
                    name = info.name

                if("when_null" in info)
                    pinfo = CMDParam(name,docs,true,info.when_null)
                else
                    pinfo = CMDParam(key,info)
                    
                if(paramarr.len() < pno)
                    paramarr.resize(pno);

                paramarr[pno - 1] = pinfo
            }
        }
    }
    local t = {}
    t[0] <- function(player,args)
    {
        local cmd = CMDDocs(
            cmdname,
            paramarr,
            docstring
            )
        return cmd.Describe();
    }
    
    return t;
}
/**************\
* ALIAS TABLES *
\**************/
::AliasCompiler.Tables <- {}

/*************\
* ALIAS CLASS *
\*************/
class ::AliasCompiler.Alias
{
    constructor(name,tbl,triggertblname)
    {   
        _name = name
        _triggertable = triggertblname

        if("Commands" in tbl)
            _cmds = tbl.Commands
        else
            _cmds = {}
            
        if("Parameters" in tbl)
            _params = tbl.Parameters
        else
            _params = {}
            
        if("Help" in tbl)
        {
            _help = ::AliasCompiler.CreateDocsFunction(_name,tbl.Help,_params)[0]
        }
        else
            _help = {}

        if("MinimumUserLevel" in tbl)
            _userlevel = tbl.MinimumUserLevel
            
    }

    function _type()
    {
        return "project_smok_Alias"
    }

    _name = null
    _triggertable = null
    _cmds = null
    _params = null
    _help = null
    _userlevel = PS_USER_NONE
    // Deprecated
    _hostOnly = null
    _authOnly = null
}

::AliasCompiler.Evaluate <-
{
    NEVER = 0,
    AT_START = 1,
    EVERY_CALL = 2
}

::AliasCompiler.CommandOptionsOrder <-
[ "start_delay", "repeat", "delay_between", "specific_target", "skip_expression"]

::AliasCompiler.CommandOptions <-
{
    repeat = 
    {
        default_value = 1
        expected_type = "integer"
        evaluate = AliasCompiler.Evaluate.AT_START
        minvalue = 1
    }
    delay_between = 
    {
        default_value = 0.1
        expected_type = "float"
        evaluate = AliasCompiler.Evaluate.EVERY_CALL
        minvalue = 0.1
    }
    start_delay = 
    {
        default_value = 0
        expected_type = "float"
        evaluate = AliasCompiler.Evaluate.AT_START
        minvalue = 0
    }
    specific_target = 
    {
        default_value = ""
        expected_type = "string"
        evaluate = AliasCompiler.Evaluate.EVERY_CALL
        minvalue = ""
    }
    skip_expression = 
    {
        default_value = "$[false]"
        expected_type = "boolean"
        evaluate = AliasCompiler.Evaluate.EVERY_CALL
        minvalue = ""
    }
}

::AliasCompiler.SpecialReferencePatterns <-
{
    repeat_id = @"(\$repeat_id)"
    repeat_id_replace = @"\$repeat_id"

    repeats_left = @"(\$repeats_left)"
    repeats_left_replace = @"\$repeats_left"

    last_call_time = @"(\$last_call_time)"
    last_call_time_replace = @"\$last_call_time"
	
    caller_ent = @"(\$caller_ent)"
    caller_ent_replace = @"\$caller_ent"

    caller_id = @"(\$caller_id)"
    caller_id_replace = @"\$caller_id"

    caller_char = @"(\$caller_char)"
    caller_char_replace = @"\$caller_char"

    caller_name = @"(\$caller_name)"
    caller_name_replace = @"\$caller_name"

    caller_target = @"(\$caller_target)"
    caller_target_replace = @"\$caller_target"
    
    specific_target = @"(\$specific_target)"
    specific_target_replace = @"\$specific_target"
}

::AliasCompiler.CompileExpressionPattern <- @"(?:^\$\[(.*)\]$)"

::AliasCompiler.ForbiddenAliasNames <-
{
    command_name_1 = true
    command_name_2 = true
    basic_alias_1 = true
    basic_alias_2 = true
    advanced_alias_1 = true
    advanced_alias_2 = true
}

::AliasCompiler.CommandOptionConstrain <- function(opts,apply_to_repeat=true)
{
    foreach(opt,c in ::AliasCompiler.CommandOptions)
    {
        if(opt in opts)
        {   
            if(opt == "repeat" && !apply_to_repeat)
            {
                opts.repeat = opts.repeat.tofloat();
                continue;
            }
            opts[opt] = ::AliasCompiler.OptionValueFinalize(opts[opt],opt)
        }
        else
        {
            opts[opt] <- c.default_value
        }
    }
}

::AliasCompiler.AliasTrigger <- function(player,args,text)
{   
    local alias = null
    local name = ""
    local triggertable = null

    // UserCommand
    if(-1 in ::VSLib.EasyLogic.LastArgs)
    {
        name = ::VSLib.EasyLogic.LastArgs[-1]
    }
    // ChatTriggers
    else
    {
        name = ::VSLib.EasyLogic.LastCmd
    }

    if(name in ::AliasCompiler.Tables)
    {
        alias = ::AliasCompiler.Tables[name]
        triggertable = getroottable()[alias._triggertable]

        local parameters = {}
        local param_pattern = @"(?:param_)(\d+)";
        // Has parameters
        if(alias._params.len() > 0 && ::VSLib.Utils.TableKeyMatch(alias._params,param_pattern))
        {
            ::AliasCompiler.CreateParameterTable(alias,parameters,param_pattern,args)
        }
        
        if(alias._cmds.len() > 0)
        {
            local areg = regexp(@"(?:arg_)(\d+)")

            foreach(cmdname,options in alias._cmds)
            {   
                if(!(cmdname in triggertable))
                {
                    ClientPrint(player.GetBaseEntity(),3,"Command "+cmdname+ " is not a known command! Skipping it...")
                    continue;
                }
                else if(!(::VSLib.EasyLogic.CheckCommandAvailability(player,cmdname,false)))
                {
                    continue;
                }
                local cmdargs = {}
                local req_cmp_arg = {}
                local req_cmp_opt = {}
                local opts = ::VSLib.Utils.TableCopy(options)
                // Missing defaults
                foreach(optn,otbl in ::AliasCompiler.CommandOptions)
                {
                    if(!(optn in opts))
                    {
                        opts[optn] <- ::AliasCompiler.CommandOptions[optn].default_value
                    }
                }

                local argopts = {}
                local basicopts = {}
                foreach(opt,cmdval in opts)
                {
                    local argcapture = areg.capture(opt)
                    if(argcapture != null && argcapture.len() == 2)  // Argument
                    {   
                        argopts[opt] <- [argcapture,cmdval]
                    }
                    else if(opt in ::AliasCompiler.CommandOptions)  // Option
                    {
                        basicopts[opt] <- cmdval
                    }
                }

                foreach(idx,opname in ::AliasCompiler.CommandOptionsOrder)
                {
                    if(opname in basicopts)
                    {
                        ::AliasCompiler.EvaluateCommandOption(basicopts[opname],opname,opts,req_cmp_opt,parameters,player)
                    }
                }

                foreach(argn,ls in argopts)
                {
                    ::AliasCompiler.EvaluateCommandArgument(ls[0],ls[1],cmdargs,argn,req_cmp_arg,parameters)
                }
                
                ::AliasCompiler.CommandCallStarter(triggertable[cmdname],player,cmdargs,req_cmp_arg,text,opts,req_cmp_opt)
            }
        }
    }
}

::AliasCompiler.CreateParameterTable <- function(alias,parameters,param_pattern,args)
{
    local preg = regexp(param_pattern)
    foreach(p,defval in alias._params)
    {   
        local capture = preg.capture(p)
        if(capture != null)
        {   
            if(capture.len() == 2)
            {
                local pno = p.slice(capture[1].begin,capture[1].end).tointeger() - 1;
                if(pno in args)
                {
                    parameters[pno] <- args[pno]
                }
                else
                {
                    parameters[pno] <- defval
                }
            }
        }
    }
}

::AliasCompiler.EvaluateCommandArgument <- function(argcapture,cmdval,cmdargs,argname,req_cmp_arg,parameters)
{
    local argno = argname.slice(argcapture[1].begin,argcapture[1].end).tointeger() - 1;
    
    if(cmdval != null)  // Has reference or default value
    {
        cmdval = strip(cmdval.tostring())

        cmdval = ::AliasCompiler.ParamReferenceReplacer(cmdval,parameters)
        if(cmdval != null)
        {
            local matched = false;
            foreach(refname,pattern in ::AliasCompiler.SpecialReferencePatterns)
            {
                local special_capture = regexp(pattern).capture(cmdval)

                if(special_capture != null && special_capture.len() == 2) // Has a special reference
                {
                    req_cmp_arg[argno] <- cmdval
                    matched = true
                    break;
                }
            }

            if(!matched) // Ready to compile
                cmdval = ::AliasCompiler.ExpressionCompiler(cmdval) 
        }
    }

    cmdargs[argno] <- cmdval
}

::AliasCompiler.EvaluateCommandOption <- function(cmdval,opt,opts,req_cmp_opt,parameters,player)
{
    if(cmdval != null && typeof cmdval == "string")  // Has reference or default value
    {
        cmdval = strip(cmdval)

        cmdval = ::AliasCompiler.ParamReferenceReplacer(cmdval,parameters)
        if(cmdval != null)
        {
            local matched = false;
            foreach(refname,pattern in ::AliasCompiler.SpecialReferencePatterns)
            {
                local special_capture = regexp(pattern).capture(cmdval)

                if(special_capture != null && special_capture.len() == 2) // Has a special reference
                {
                    switch(::AliasCompiler.CommandOptions[opt].evaluate)
                    {
                        case ::AliasCompiler.Evaluate.EVERY_CALL:
                            req_cmp_opt[opt] <- cmdval
                        case ::AliasCompiler.Evaluate.AT_START:
                        {
                            local lookuptbl = 
                            {
                                repeat_id = 1,
                                last_call_time = Time()
                                caller_ent = player
                                caller_id = player.GetIndex()
                                caller_char = player.GetCharacterName()
                                caller_name = player.GetName()
                                caller_target = player.GetLookingEntity(GRAB_YEET_TRACE_MASK, true)
                                specific_target = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
                            }
                            if(opt != "repeat")
                            {
                                lookuptbl.repeats_left <- opts.repeat-1
                            }
                            cmdval = 
                            ::AliasCompiler.OptionValueFinalize(
                                ::AliasCompiler.ExpressionCompiler(
                                    ::AliasCompiler.SpecialReferenceReplacer(
                                        cmdval,lookuptbl
                                    )
                                ),
                                opt
                            )
                            break;
                        }
                        default:
                        {
                            cmdval = ::AliasCompiler.CommandOptions[opt].default_value
                            break;
                        }
                    }
                    matched = true
                    break;
                }
            }

            if(!matched) // Ready to compile
            {
                cmdval = ::AliasCompiler.ExpressionCompiler(cmdval)
                cmdval = ::AliasCompiler.OptionValueFinalize(cmdval,opt);
            }
        }
    }
    
    opts[opt] <- cmdval
}

::AliasCompiler.OptionValueFinalize <- function(cmdval,opt)
{
    try
    {
        switch(AliasCompiler.CommandOptions[opt].expected_type)
        {
            case "integer":
            {
                cmdval = cmdval.tointeger();
                break;
            }
            case "float":
            {
                cmdval = cmdval.tofloat();
                break;
            }
            case "string":
            {
                return (cmdval = cmdval.tostring());
            }
            case "boolean":
            {
                return (cmdval = ((cmdval != "false" && cmdval) ? true : false));
            }
        }
    }
    catch(e)
    {
        return AliasCompiler.CommandOptions[opt].default_value
    }
    return cmdval < AliasCompiler.CommandOptions[opt].minvalue ? AliasCompiler.CommandOptions[opt].default_value : cmdval
}

::AliasCompiler.AliasRepeater <- function(args)
{
    if(args.repeats_left >= 1)
    {
        args.repeats_left--
        
        if(args.repeat_id != 1)
        {
            local lookuptbl = 
            {
                last_call_time = args.last_call_time,
                repeat_id = args.repeat_id,
                repeats_left = args.repeats_left,
                caller_id = args.caller_id,
                caller_char = args.caller_char,
                caller_name = args.caller_name,
                caller_ent = args.caller_ent,
                caller_target = args.caller_target,
                specific_target = args.specific_target
            }

            args.last_call_time = Time()
            
            if(args.req_cmp_opt.len() > 0)
            {
                ::AliasCompiler.SpecialReferenceCompiler(args.opts,args.req_cmp_opt,lookuptbl)
            }
            
            ::AliasCompiler.CommandOptionConstrain(args.opts,false)
            ::AliasCompiler.SetSpecificTarget(args.caller_ent, args.opts.specific_target)

            // TO-DO put into func
            args.specific_target = args.caller_ent.GetLookingEntity(GRAB_YEET_TRACE_MASK)
            lookuptbl.specific_target = args.specific_target;
            
            if(args.req_cmp_arg.len() > 0)
            {
                ::AliasCompiler.SpecialReferenceCompiler(args.cmdargs,args.req_cmp_arg,lookuptbl)
            }

        }
        
        if(!args.opts.skip_expression)
        {
            ::AliasCompiler.CommandCall(args.func,args.player,args.cmdargs,args.text)
        }

        args.repeat_id++

        ::VSLib.Timers.AddTimer(args.opts.delay_between,false,::AliasCompiler.AliasRepeater,args)
    }
}

::AliasCompiler.CommandCall <- function(func,player,cmdargs,text)
{
    if("LastArgs" in ::VSLib.EasyLogic)
    {
        local lastargscopy = clone ::VSLib.EasyLogic.LastArgs
        // Set temporary last args
        ::VSLib.EasyLogic.LastArgs <- cmdargs
        // Call the command
        func(player,cmdargs,text)

        ::VSLib.EasyLogic.LastArgs = lastargscopy
    }
    else
    {
        // Set temporary last args
        ::VSLib.EasyLogic.LastArgs <- cmdargs
        // Call the command
        func(player,cmdargs,text)

        delete ::VSLib.EasyLogic.LastArgs
    }
}

::AliasCompiler.SetSpecificTarget <- function(player, targetname)
{
    local target;

    if(targetname == "self" || targetname == "!self")
        target = Utils.GetEntityOrPlayer(player.GetBaseEntity());
    
    if(target != null 
        || (targetname != "" && ((target = Entity(targetname)).IsEntityValid() || (target = Utils.GetPlayerFromName(targetname)) != null)))
        target = Utils.GetEntityOrPlayer(target.GetBaseEntity());
    else
        target = null

    player.GetScriptScope().PS_ONETIME_TARGET <- target
}

::AliasCompiler.CommandCallWrapper <- function(args)
{   
    if(args.opts.repeat >= 1)
    {
        ::AliasCompiler.AliasRepeater(
            {
                func = args.func,
                player = args.player,
                cmdargs = args.cmdargs,
                req_cmp_arg = args.req_cmp_arg,
                text = args.text,
                opts = args.opts,
                req_cmp_opt = args.req_cmp_opt,
                repeats_left = args.lookuptbl.repeats_left,
                repeat_id = args.lookuptbl.repeat_id,
                last_call_time = args.lookuptbl.last_call_time,
                caller_id = args.lookuptbl.caller_id,
                caller_char = args.lookuptbl.caller_char,
                caller_name = args.lookuptbl.caller_name,
                caller_ent = args.lookuptbl.caller_ent,
                caller_target = args.lookuptbl.caller_target
                specific_target = args.lookuptbl.specific_target
            })
    }
}

::AliasCompiler.CommandCallStarter <- function(func,player,cmdargs,req_cmp_arg,text,opts,req_cmp_opt)
{   
    ::AliasCompiler.SetSpecificTarget(player, opts.specific_target)

    local lookuptbl = 
    {
        last_call_time = Time(),
        repeat_id = 1,
        repeats_left = opts.repeat
        caller_id = player.GetIndex()
        caller_char = player.GetCharacterName()
        caller_name = player.GetName()
        caller_ent = player
        caller_target = player.GetLookingEntity(GRAB_YEET_TRACE_MASK, true)
        specific_target = player.GetLookingEntity(GRAB_YEET_TRACE_MASK)
    }

    if(req_cmp_opt.len() > 0)
    {   
        ::AliasCompiler.SpecialReferenceCompiler(opts,req_cmp_opt,lookuptbl)
    }

    ::AliasCompiler.CommandOptionConstrain(opts)

    if(req_cmp_arg.len() > 0)
    {   
        ::AliasCompiler.SpecialReferenceCompiler(cmdargs,req_cmp_arg,lookuptbl)
    }

    if(opts.start_delay == 0)
    {
        ::AliasCompiler.CommandCallWrapper(
            {
                func=func,
                player=player,
                cmdargs=cmdargs,
                req_cmp_arg=req_cmp_arg,
                text=text,
                opts=opts,
                req_cmp_opt=req_cmp_opt,
                lookuptbl=lookuptbl
            }
        )
    }
    else
    {
        ::VSLib.Timers.AddTimer(opts.start_delay,false,::AliasCompiler.CommandCallWrapper,
            {
                func=func,
                player=player,
                cmdargs=cmdargs,
                req_cmp_arg=req_cmp_arg,
                text=text,
                opts=opts,
                req_cmp_opt=req_cmp_opt,
                lookuptbl=lookuptbl
            }
        )
    }
}

::AliasCompiler.SpecialReferenceCompiler <- function(tbl,req_cmp,lookuptbl)
{
    foreach(opt,exp in req_cmp)
    {
        tbl[opt] <- ::AliasCompiler.ExpressionCompiler(::AliasCompiler.SpecialReferenceReplacer(exp,lookuptbl))
    }
}

::AliasCompiler.SpecialReferenceReplacer <- function(cmdval,lookuptbl)
{
    foreach(refname,current in lookuptbl)
    {
        local special_reg = regexp(AliasCompiler.SpecialReferencePatterns[refname])
        local special_capture = special_reg.capture(cmdval)
        while(special_capture != null)  // Replace references
        {
            if(special_capture.len() == 2)   
            {
                cmdval = ::VSLib.Utils.StringReplace(cmdval,AliasCompiler.SpecialReferencePatterns[refname+"_replace"],current,true)
                special_capture = special_reg.capture(cmdval)
            }
            else
                break;
        }
    }
    return cmdval;
}

::AliasCompiler.ParamReferenceReplacer <- function(cmdval,parameters)
{
    local prefreg = regexp(@"(\$param_\d+)")
    local prefcapture = prefreg.capture(cmdval)
    local first_cap = true;
    while(prefcapture != null)  // Replace references
    {
        if(prefcapture.len() == 2)   
        {
            local paramref = cmdval.slice(prefcapture[1].begin,prefcapture[1].end)
            local paramID = split(paramref,"_")[1].tointeger() - 1
            if(paramID in parameters)
            {
                if(parameters[paramID] == null && strip(cmdval) == "$param_"+(paramID+1) && first_cap)
                    return null
                else
                {
                    cmdval = ::VSLib.Utils.StringReplace(cmdval,@"\$param_"+(paramID+1),parameters[paramID],true)
                    first_cap = false
                }
            }

            prefcapture = prefreg.capture(cmdval)
        }
        else
            break;
    }
    return cmdval;
}

::AliasCompiler.ExpressionCompiler <- function(cmdval,optionals=null)
{
    local compreg = regexp(::AliasCompiler.CompileExpressionPattern)
    local compcapture = compreg.capture(cmdval) 
    if(compcapture != null) // Has stuff to compile
    {
        if(compcapture.len() == 2)   // arg_x = $[exp]
        {   
            local compile_part = cmdval.slice(compcapture[1].begin,compcapture[1].end)
            if(optionals != null)
            {
                local cstr = ""
                foreach(opt,val in optionals)
                {
                    cstr += "local "+opt+" = "+val + ";\n"
                }
                cmdval = compilestring(cstr+"local __tempvar__ ="+compile_part+";return __tempvar__;")()
            }
            else
            {
                cmdval = compilestring("local __tempvar__ ="+compile_part+";return __tempvar__;")()
                cmdval = cmdval == null ? cmdval : (""+cmdval)
            }
        }
    }
    return cmdval;
}

::AliasCompiler.CreateAliasFromTable <- function(tbl,triggertbl)
{
    foreach(alias,aliastbl in tbl)
    {
        ::AliasCompiler.CreateAlias(alias,aliastbl,triggertbl);
    }
}

::AliasCompiler.CreateAlias <- function(alias,aliastbl,triggertbl,docs="ChatTriggerDocs")
{
    if(alias in ::AliasCompiler.ForbiddenAliasNames)
        return null;

    local a = ::AliasCompiler.Alias(alias,aliastbl,triggertbl)

    getroottable()[triggertbl][alias] <- ::AliasCompiler.AliasTrigger
    getroottable()[docs][alias] <- @(player,args) typeof a._help == "function"
					? Messages.DocCmdPlayer(player,a._help(player,args))
					: null

    ::AliasCompiler.Tables[alias] <- a
    ::PrivilegeRequirements[alias] <- a._userlevel

    return a;
}