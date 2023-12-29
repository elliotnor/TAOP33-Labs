#-------------------------------------------------------------------------------
# Kapaciterade Lokaliseringsproblemet
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
using JuMP, HiGHS, Printf, GLPK
#-------------------------------------------------------------------------------
avdelare = repeat('-',60)


#-------------------------------------------------------------------------------
# Input data file
#-------------------------------------------------------------------------------
include("floc3.jl")
e = 100
#-------------------------------------------------------------------------------
# m						
# n
# s[i]
# d[j]
# f[i]
# c[i,j]						
#-------------------------------------------------------------------------------

 
#-------------------------------------------------------------------------------
# The model saved with name LOKAL
#-------------------------------------------------------------------------------
LOKAL = Model(GLPK.Optimizer)
set_optimizer_attribute(LOKAL, "msg_lev", GLPK.GLP_MSG_ON)

#----------------------------------------------------------------
# Define variables
#----------------------------------------------------------------
#@variable(LOKAL, c[1:m, 1:n] >= 0, Int)
#@variable(LOKAL, f[1:m] >= 0, Int)

@variable(LOKAL, x[1:m, 1:n] >= 0, Int)
@variable(LOKAL, y[1:m] >= 0, Bin)

#----------------------------------------------------------------


#----------------------------------------------------------------
# Add Objective function
#----------------------------------------------------------------
@objective(LOKAL, Min, sum((c[i,j]*x[i,j]) for i in 1:m, j in 1:n) + sum((e*f[i]*y[i]) for i in 1:m))
#----------------------------------------------------------------


#----------------------------------------------------------------
# Add Constraints
#----------------------------------------------------------------
@constraint(LOKAL, con1[i in 1:m], sum(x[i,j] for j in 1:n) <= s[i]*y[i])
@constraint(LOKAL, con2[j in 1:n], sum(x[i,j] for i in 1:m) == d[j])
#@constraint(LOKAL, con3[i in 1:m, j in 1:n], x[i,j] <= d[j]*y[i])


#----------------------------------------------------------------


#-------------------------------------------------------------------------------
# Solve the optimization problem
#-------------------------------------------------------------------------------
println(avdelare)
println("\n\n\n>>> SOLVING LOKAL PROBLEM <<<\n")
solution = optimize!(LOKAL)
println("\n Time: $(solve_time(LOKAL))")
println(avdelare)

#-------------------------------------------------------------------------------
# Print the objective function value and solution
#-------------------------------------------------------------------------------

status = termination_status(LOKAL)
isopt = cmp(string(status),"OPTIMAL")
isinfeas = cmp(string(status),"INFEASIBLE")
istime = cmp(string(status),"TIME_LIMIT")


#------------------------------------------------------------------------------------------
# In the following, the objective function value and the opened facilitities (y[i]=1).
# If you have another name for variable "y", change y[i] to your variable in the following.
#------------------------------------------------------------------------------------------

if isopt == 0
	println("\n>>> OPTIMAL SOLUTION <<<\n")
    println("Optimal objective value: ", round(objective_value(LOKAL),digits=3))
    println("\nOpened facilities:\n")
	for i in 1:m
		if round(value(y[i]),digits=3) > 0
			@printf("%s =   %s \n", name(y[i]), round(value(y[i]),digits=3) )
		end
	end
elseif istime == 0
	println("\n>>> Time limit reached <<<\n")
    println("Best found objective value: ", round(objective_value(LOKAL),digits=3))
	println("Relative gap: %", round(100*relative_gap(LOKAL),digits=3))
    println("\nOpened facilities:\n")
	for i in 1:m
		if round(value(y[i]),digits=3) > 0
			@printf("%s =   %s \n", name(y[i]), round(value(y[i]),digits=3) )
		end
	end
elseif isinfeas==0
    println("Model infeasible")

end

println(avdelare)
#-------------------------------------------------------------------------------


