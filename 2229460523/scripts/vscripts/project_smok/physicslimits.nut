::RagdollModelBans <-
{
	"infected/common_male_parachutist" : true
	"deadbodies/parachutist" : true
	"deadbodies/dead_male_legs_01" : true
	"infected/common_shadertest" : true
	"deadbodies/deepswamp/" : true
}

::ZeroGMapSpecificBans <- 
{
	"c5m1_waterfront":
	{
		models = 
		{
		}

		entities =
		{
			"tug_boat_intro":
			{
				id = 532
				classname = "prop_dynamic"
			}
		}
	}

	"c5m3_cemetery" :
	{
		models =
		{
		}

		entities =
		{
			"destruction_car_phys" :
			{
				id = 1433
				classname = "prop_physics"

			} 
		}
	}

	"c5m5_bridge" :
	{
		models =
		{
			"models/props/cs_office/light_shopb.mdl" : true
		}

		entities =
		{
			"heli_rescue" :
			{
				id = 404
				classname = "prop_dynamic"
			} 
		}
	}

	"c14m2_lighthouse":
	{
		models = 
		{
		}

		entities =
		{
			"model_boat":
			{
				id = 68
				classname = "prop_dynamic"
			}
		}
	}
}

::GivePhysicsMapSpecificBans <- 
{
	"c5m1_waterfront":
	{
		models = 
		{
			"models/props_vehicles/boat_rescue_tug_sunshine.mdl" : true
		}

		entities =
		{
			"tug_boat_intro":
			{
				id = 532
				classname = "prop_dynamic"
			}
		}
	}
	
	"c5m5_bridge" :
	{
		models =
		{
			"models/props/cs_office/light_shopb.mdl" : true
		}

		entities =
		{
		}
	}

	"c14m2_lighthouse":
	{
		models = 
		{
		}

		entities =
		{
			"model_boat":
			{
				id = 68
				classname = "prop_dynamic"
			}
		}
	}
}
