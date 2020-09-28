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
        "bill" : ::Namvet.bill,
        "francis" : ::Biker.francis,
        "louis" : ::Manager.louis,
        "zoey" : ::Teengirl.zoey,
        "nick" : ::Gambler.nick,
        "ellis" : ::Mechanic.ellis,
        "coach" : ::Coach.coach,
        "rochelle" : ::Producer.rochelle
    }
}