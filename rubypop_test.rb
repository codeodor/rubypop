require 'rubypop'
include RubyPOP
###################################################
PlanName("Put on Shoes")
Goal(:RightShoeOn ^ :LeftShoeOn)

Action(:RightShoe, EFFECT => :RightShoeOn, PRECOND => :RightSockOn)
Action(:RightSock, EFFECT => :RightSockOn)
Action(:LeftShoe, EFFECT => :LeftShoeOn, PRECOND => :LeftSockOn)
Action(:LeftSock, EFFECT => :LeftSockOn)

print_plan
clear
puts

###################################################
PlanName("Change Tire")
Init(At(:Flat,:Axle) ^ At(:Spare,:Trunk))
Goal(At(:Spare,:Axle))

Action(Remove(:Spare,:Trunk), 
         PRECOND => At(:Spare,:Trunk), 
	 EFFECT => NotAt(:Spare,:Trunk) ^ At(:Spare,:Ground))
Action(Remove(:Flat,:Axle), 
         PRECOND => At(:Flat,:Axle), 
	 EFFECT => NotAt(:Flat,:Axle) ^ At(:Flat,:Ground))
Action(PutOn(:Spare,:Axle), 
         PRECOND => At(:Spare,:Ground) ^ NotAt(:Flat,:Axle), 
	 EFFECT => NotAt(:Spare,:Ground) ^ At(:Spare,:Axle))
Action(:LeaveOvernight, 
	  EFFECT => NotAt(:Spare, :Ground) ^ NotAt(:Spare,:Axle) ^ NotAt(:Spare,:Trunk) ^ NotAt(:Flat,:Ground) ^ NotAt(:Flat,:Axle))

print_plan
clear
puts

###################################################
PlanName("Watch Fulham beat Chelsea")
Init(Asleep(:Sam))
Goal(In(:Sam,:Pub) ^ Watching(:Sam,:FulhamBeatChelsea))
Action(WakeUp(:Sam),
	 PRECOND => Asleep(:Sam),
	 EFFECT => Awake(:Sam))
Action(Bathe(:Sam),
	 PRECOND => Awake(:Sam),
	 EFFECT => Clean(:Sam))
Action(Shower(:Sam),
	 PRECOND => Awake(:Sam),
	 EFFECT => Clean(:Sam))
Action(Dress(:Sam),
	 PRECOND => Clean(:Sam),
	 EFFECT => Dressed(:Sam))
Action(Work(:Sam),
	 PRECOND => Clean(:Sam) ^ Dressed(:Sam),
	 EFFECT => IsAbleToGoToPub(:Sam))
Action(GoToPub(:Sam),
	 PRECOND => IsAbleToGoToPub(:Sam),
	 EFFECT => In(:Sam,:Pub))
Action(Watch(:Sam,:Fulham),
	 PRECOND => In(:Sam,:Pub),
	 EFFECT => Watching(:Sam,:FulhamBeatChelsea))
print_plan