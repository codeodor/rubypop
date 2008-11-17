module Logic
	def ^(condition)
		[self, condition]
	end	
end

#modify the symbol class to include the ^ operation
class Symbol
	include Logic
end
#modify the array class to include the ^ operation
class Array
	include Logic
end
#modify the string class to include the ^ operation
class String
	include Logic
end
	
# the pop module  
module RubyPOP 
	#constants to use to store hash for precondition and effect 
	#(only for purposes of keeping the DSL looking close to the original)
	PRECOND = :precondition
	EFFECT = :effect	
	
	#store the start-state conditions
	def Init(conditions)
		@start_state = conditions
	end
	alias init Init
	
	# store actions defined by the user 
	def Action(name, precondition_effect)
		action= ["name" => name, 
		            "precondition" => precondition_effect[PRECOND], 
			    "effect" => precondition_effect[EFFECT]]
		@actions = [] if !@actions
		@actions = @actions + action 
	end
	alias action Action
	
	#store the goal defined by the user
	def Goal(conditions)
		@goal = conditions
		@open_preconditions = @goal
	end
	alias goal Goal
	
	def PlanName(name)
		@plan_name = name
	end
	
	def output_actions
		@actions.each do |x|
			puts			
			puts "name: " + x["name"].to_s
			puts "precondition: " + x["precondition"].to_s
			puts "effect: " + x["effect"].to_s
		end
	end
	
	def clear 
		@actions = []
		@goal = nil
		@open_preconditions = nil
		@plan_name = nil
	end	
	
	# when the user enters a function, turn it into an action
	def method_missing(method_id, *args)
		symbol_name = "#{method_id}("
		args.each { |arg| symbol_name += arg.to_s + "," }
		symbol_name[0,symbol_name.length-1] + ")"
	end
	
	def print_plan 
		puts "One possible plan for #{@plan_name}: " 
		puts get_plan
	end
	
	def get_plan
		return sanitize_plan(make_plan)
	end 
	
	private 
	def find_action_for(cond)
		@actions.each do |action|
			if action["effect"].class == Array
				action["effect"].each { |effect| return action if effect.to_s == cond.to_s	}
			else 
				return action if action["effect"].to_s == cond.to_s	
			end
		end
		return nil
	end
	
	def remove_preconditions_matching_start_state
		@open_preconditions.each do |cond|
			@open_preconditions.delete(cond) if @start_state.index(cond)
		end
	end
	
	#if there were some actions that duplicated precondition, it will cause a loop in plan.  
	#this function cleans that up by analyzing the current state and removing unnecessary actions
	#a better implementation might make a graph of the actions and check that before putting them in
	def sanitize_plan(plan)
		current_state = []
		#should be examining the effects individually, since it may end up choosing two with the same effect
		#but not currently doing so
		plan.each { |action| current_state.push(action) if !current_state.index(action) }
		return current_state
	end
			
	def make_plan
		action_plan = []
		fail = false
		while (@open_preconditions.size > 0 && !fail)
			#randomize the open_preconditions and actions to show order doesn't matter
			@open_preconditions=@open_preconditions.sort_by { rand }
			#@actions = @actions.sort_by { rand }   #---- causes bugs right now
			
			#find an action that solves it the first open precondition
			attempted_precondition = @open_preconditions.shift
			action_to_take = find_action_for attempted_precondition
			
			if (action_to_take != nil)
				add_preconditions_for action_to_take
				remove_preconditions_fulfilled_by action_to_take
				#add the action to the plan
				action_plan.push(action_to_take["name"])
			else
				#put the precondition back on the open_preconditions, since it wasn't fulfilled by an action
				fail = true if @open_preconditions.size == 0
				@open_preconditions.push attempted_precondition 
				remove_preconditions_matching_start_state
				fail = false if @open_preconditions.size == 0
			end
		end
		if @open_preconditions.size > 0 || fail
			puts "There appears to be no plan that satisfies the problem."
			puts "Open preconditions: " 
			puts @open_preconditions
			action_plan = []
		end
		sanitize_plan(action_plan.reverse)
	end
	
	#add the preconditions for this action if they don't already exist
	def add_preconditions_for(action)
		preconditions = action["precondition"]
		if preconditions.class == Array
			preconditions.each { |precondition| @open_preconditions.push(precondition) if (precondition != nil && !@open_preconditions.index(precondition)) }
		else
			@open_preconditions.push(preconditions) if (preconditions != nil && !@open_preconditions.index(preconditions))  
		end
	end
	
	# remove any open preconditions which the action fulfilled
	def remove_preconditions_fulfilled_by action
		action["effect"].each do |effect|
			@open_preconditions.each { |precon| @open_preconditions.delete(precon) if precon.to_s == effect.to_s }
		end
	end
		
end