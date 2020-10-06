IncludeScript("Voice_paths/paths/biker.nut");
IncludeScript("Voice_paths/paths/namvet.nut");
IncludeScript("Voice_paths/paths/manager.nut");
IncludeScript("Voice_paths/paths/teengirl.nut");
IncludeScript("Voice_paths/paths/gambler.nut");
IncludeScript("Voice_paths/paths/mechanic.nut");
IncludeScript("Voice_paths/paths/coach.nut");
IncludeScript("Voice_paths/paths/producer.nut");

::Survivorlines <- {
    Paths = {
        bill = ::Namvet.bill,
        francis = ::Biker.francis,
        louis = ::Manager.louis,
        zoey = ::Teengirl.zoey,
        nick = ::Gambler.nick,
        ellis = ::Mechanic.ellis,
        coach = ::Coach.coach,
        rochelle = ::Producer.rochelle
    }
    
    FriendlyFire =
    {		
		nick =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07",
					"friendlyfire08","friendlyfire09",
					"friendlyfire10", "friendlyfire11",
					"friendlyfire12", "friendlyfire13",
					"friendlyfire14", "friendlyfire15", 
					"friendlyfire16", "friendlyfire17",
					"friendlyfire18", "friendlyfire19",
					"friendlyfire20", "friendlyfire21",
					"friendlyfire22", "friendlyfire23", 
					"friendlyfire24", "friendlyfire25",
					"friendlyfire26", "friendlyfire27",
					"friendlyfire28", "friendlyfire29",
					"friendlyfire30", "friendlyfire31",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03"
				]
		
		coach =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07",
					"friendlyfire08","friendlyfire09",
					"friendlyfire10", "friendlyfire11",
					"friendlyfire12", "friendlyfire13",
					"friendlyfire14", "friendlyfire15", 
					"friendlyfire16", "friendlyfire17",
					"friendlyfire18", "friendlyfire19",
					"friendlyfire20", "friendlyfire21",
					"friendlyfire22", "friendlyfire23", 
					"friendlyfire24", "friendlyfire25",
					"friendlyfire26", "friendlyfire27",
					"friendlyfire28", "friendlyfire29",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03","teamkillaccident04",
					"teamkillaccident05","teamkillaccident06",
					"teamkillaccident07","teamkillaccident08"
					
				]
		
		ellis =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07",
					"friendlyfire08","friendlyfire09",
					"friendlyfire10", "friendlyfire11",
					"friendlyfire12", "friendlyfire13",
					"friendlyfire14", "friendlyfire15", 
					"friendlyfire16", "friendlyfire17",
					"friendlyfire18", "friendlyfire19",
					"friendlyfire20", "friendlyfire21",
					"friendlyfire22", "friendlyfire23", 
					"friendlyfire24", "friendlyfire25",
					"friendlyfire26", "friendlyfire27",
					"friendlyfire28", "friendlyfire29",
					"friendlyfire30", "friendlyfire31",
					"friendlyfire32", "friendlyfire33",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03","teamkillaccident04",
					"teamkillaccident05"
				]
		
		rochelle =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07",
					"friendlyfire08","friendlyfire09",
					"friendlyfire10", "friendlyfire11",
					"friendlyfire12", "friendlyfire13",
					"friendlyfire14", "friendlyfire15", 
					"friendlyfire16", "friendlyfire17",
					"friendlyfire18", "friendlyfire19",
					"friendlyfire20", "friendlyfire21",
					"friendlyfire22", "friendlyfire23", 
					"friendlyfire24", "friendlyfire25",
					"friendlyfire26",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03","teamkillaccident04"
				]
		
		francis =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07","friendlyfire08",
					"friendlyfire09","friendlyfire10",
					"friendlyfire11","friendlyfire12",
				    "friendlyfire13","friendlyfire14", 
					"friendlyfire15","friendlyfire16",
					"friendlyfire18", "friendlyfire19",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03","teamkillaccident04",
					"teamkillaccident05","teamkillaccident06",
					"teamkillonpurpose09"
				]
		
		louis =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07","friendlyfire08",
					"friendlyfire09","friendlyfire10",
					"friendlyfire11","friendlyfire12",
				    "friendlyfire13","friendlyfire14",
					"teamkillaccident01","teamkillaccident02",
					"teamkillaccident03","teamkillaccident04",
					"manager_friendlyfirebill06",
				]
					
		bill =
				[
					"friendlyfire01","friendlyfire02",
					"friendlyfire03","friendlyfire04",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07","friendlyfire08",
					"friendlyfire09","friendlyfire10",
					"friendlyfire11","friendlyfire12",
				    "friendlyfire13","friendlyfire14", 
					"friendlyfire15","friendlyfire16",
					"friendlyfire17","teamkillaccident01",
					"teamkillaccident02","teamkillaccident03",
					"teamkillaccident04"
				]
		
		zoey =
				[
					"friendlyfire02","friendlyfire03",
					"friendlyfire05","friendlyfire06",
					"friendlyfire07","friendlyfire08",
					"friendlyfire10", "friendlyfire11",
					"friendlyfire12", "friendlyfire13",
					"friendlyfire14", "friendlyfire17",
					"friendlyfire18", "friendlyfire19",
					"friendlyfire22", "friendlyfire23", 
					"friendlyfire24","teamkillaccident03",
					"teamkillaccident05","teamkillaccident06",
					"teamkillaccident08"
				]
		}
		
		Excited = 
		{		
			nick =
			[
				"battlecry01",
				"battlecry02",
				"battlecry03",
				"battlecry04"
			]
		
			coach =
			[
				"battlecry01",
				"battlecry02",
				"battlecry03",
				"battlecry04",
				"battlecry05",
				"battlecry06",
				"battlecry07",
				"battlecry08",
				"battlecry09"
			]
		
			ellis =
			[
				"battlecry01",
				"battlecry02",
				"battlecry03",
				"battlecry04"
			]
		
			rochelle =
			[
				"battlecry01",
				"battlecry02"
			]
			
			francis =
			[
				"taunt01",
				"taunt02",
				"taunt03",
				"taunt04",
				"taunt05",
				"taunt06",
				"taunt07",
				"taunt08",
				"taunt09",
				"taunt10"
			]
		
			louis =
			[
				"taunt03",
				"taunt04",
				"taunt05",
				"taunt06",
				"taunt07",
				"taunt08",
				"taunt09",
				"taunt10"
			]
					
			bill =
			[
				"taunt01",
				"taunt02"
			]

			zoey =
			[
				"taunt02",
				"taunt13",
				"taunt18",
				"taunt19",
				"taunt20",
				"taunt21",
				"taunt24",
				"taunt25",
				"taunt26",
				"taunt28",
				"taunt29",
				"taunt30",
				"taunt31",
				"taunt34",
				"taunt35",
				"taunt39"
			]
		}
	
}