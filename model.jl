using JuMP
using Plots
using Distributions
using Random
import HiGHS
import Test

using JLD
using CSV
using DataFrames
using AxisArrays
include("utils.jl");

function example()

    # sets
    colors = [:blue, :green, :yellow, :orange, :red]
    bins = 1:10
    materials = 1:5;
    
    # data
    # [x^3 *sin(y) for x in colors, y in materials]
    capacity = rand(1:20, length(bins))
    #weight_data = rand(1:20, length(colors)*length(materials))
    profit_data = rand(1:20, length(colors)*length(bins))
   
    Random.seed!(123) 
    weight_distribution = Normal(15, 5)
    weight_data = rand(weight_distribution, length(colors)*length(materials))

    # parameters
    weight = parameter((materials, colors), weight_data)
    profit = parameter((colors, bins), profit_data);
    
    savefig(plot(bar(capacity)), "./plots/capacity.png")
    savefig(plot(surface(weight)), "./plots/weight.png")
    savefig(plot(surface(profit)), "./plots/profit.png")
    
    function run_model()
        
        model = Model(HiGHS.Optimizer)
        set_silent(model)
        @variable(model, x[materials,colors,bins], Bin)
        
        # Objective: maximize profit 
        @objective(model, Max, 
            sum(profit[c,b]*x[m,c,b] for m in materials, c in colors, b in bins))
        
        # Constraint: can carry all
        @constraint(model, test[b in bins],
            sum(weight[m,c] * x[m,c,b] for m in materials, c in colors) <= capacity[b])
        
        # Solve problem using MIP solver
        optimize!(model)
        return value.(x)
    end
    
    x = run_model();
    
    sol = []
    labels = String[]
    n = 1
    for m in materials, c in colors, b in bins 
        if x[m,c,b] == 1
            push!(sol, profit[c,b]/weight[m,c])
            push!(labels, "$(m)_$(c)_$(b)")
            n = n+1
        end
    end
    
    df = sort(DataFrame(x=sol, y=labels))
    labels = df[!,:y] 
    
    savefig(plot(bar(df[!,:x], label=false)), "./plots/profit_per_weight.png")
    xticks!(1:length(df[!,:y]), df[!,:y])

    return nothing
    
end

example()
