function plot_optimalpolicy(model)

    a_grid = model.grid.gridpoints
    vstar  = model.optimal_policy.value
    astar  = model.optimal_policy.assets    
    cstar  = model.optimal_policy.consumption   
    
    p  = GroupPlot(3,1, groupStyle = "horizontal sep = 1cm,vertical sep = 2cm");
    pv = PGFPlots.Axis(title="Value",style="width=8cm, height=6cm");
    pc = PGFPlots.Axis(title="Consumption",style="width=8cm, height=6cm");
    pa = PGFPlots.Axis(title="Asset growth",style="width=8cm, height=6cm"); 
    push!(pv, PGFPlots.Linear(a_grid,vstar,style="red,smooth,no marks"));
    push!(pc, PGFPlots.Linear(a_grid,cstar,style="red,smooth,no marks"));    

    for i in 1:n_θ
        push!(pa, PGFPlots.Linear(a_grid,[a[i] for a in astar].-a_grid,style="red,smooth,no marks")); 
    end
    push!(p,pv)
    push!(p,pc)
    push!(p,pa)    

    save("images/optimalpolicy.tex",p)
#     display(p)
end




function plot_simulateddata(model)

    a_grid = model.grid.gridpoints
    θ_path = model.simulated_data.income
    a_path = model.simulated_data.assets    
    c_path = model.simulated_data.consumption   

    n_periods = size(θ_path)[1]


    p    = GroupPlot(1,3, groupStyle = "horizontal sep = 2cm,vertical sep = 2cm");

    push!(p,Axis(PGFPlots.Linear(collect(1:n_periods),θ_path,style="no marks"),
                 title = "a typical income path",
                 style = "height = 6cm,width=24cm,xmin=0,xmax=$(n_periods)"))
    
    push!(p,Axis(PGFPlots.Linear(collect(1:n_periods),a_path,style="no marks"),
                 title = "a typical asset path",
                 style = "height = 6cm,width=24cm,xmin=0,xmax=$(n_periods)"))
    
    push!(p,Axis(PGFPlots.Linear(collect(1:n_periods),c_path,style="no marks"),
                 title = "a typical consumption path",
                 style = "height = 6cm,width=24cm,xmin=0,xmax=$(n_periods)"))
    

    save("images/simulateddata.tex",p)
#     display(p)
end


function plot_distributions(model)

    ϕ_0    = model.parameters[:ϕ_0]  
    astar  = model.optimal_policy.assets
    cstar  = model.optimal_policy.consumption
    a_grid = model.grid.gridpoints
    n_grid = size(model.grid.gridpoints)[1]    
    π_θ    = model.parameters[:π_θ]
    θ      = model.parameters[:θ]   
    
    cdf    = model.distribution.cdf
    ϕ      = model.distribution.pdf_grid
    pdf_u  = model.distribution.pdf_uniform
    
    lorenz_consumption  = model.distribution.lorenz_consumption
    lorenz_assets       = model.distribution.lorenz_assets
    
    gini_income      = model.distribution.gini_income
    gini_assets      = model.distribution.gini_assets
    gini_consumption = model.distribution.gini_consumption
    
    
    a_trunc = [maximum([a,0.0]) for a in a_grid]    

    cutoff =  size(cdf[cdf .< 0.999])[1]
    
    p    = GroupPlot(3,2, groupStyle = "horizontal sep = 2cm,vertical sep = 2cm");
    
    ppdf = PGFPlots.Axis(title="Distribution of assets",
                         style="width=8cm, height=6cm",
                         xlabel="assets (liabilities if -ve)",
                         ylabel="density",
                         legendPos="north east",
                         legendStyle="draw = none");

    ppdfc = PGFPlots.Axis(title="Distribution of consumption",
                         style="width=8cm, height=6cm",
                         xlabel="consumption",
                         ylabel="density",
                         legendPos="north east",
                         legendStyle="draw = none");
    
    pcdf = PGFPlots.Axis(title="Cumulative distribution of assets",
                         style="width=8cm, height=6cm",
                         xlabel="assets (liabilities if -ve)",
                         ylabel="cumulative density");

    pcdfc = PGFPlots.Axis(title="Cumulative distribution of consumption",
                         style="width=8cm, height=6cm",
                         xlabel="consumption",
                         ylabel="cumulative density");

    plorenz = PGFPlots.Axis(title="Lorenz curves",
                            style="width=8cm, height=6cm",
                            xlabel="percentile",
                            ylabel="cumulative share",
                            legendPos="north west",
                            legendStyle="draw = none");
    


    push!(ppdf, PGFPlots.Linear(a_grid[1:cutoff],pdf_u[1:cutoff],style="red,smooth,no marks",
                                legendentry="density"));

    push!(ppdf, PGFPlots.Linear([a_grid'*pdf_u,a_grid'*pdf_u],
                                [0,maximum(pdf_u)],
                                style="black,dashed,no marks",
                                legendentry="mean ($(round(a_grid'*pdf_u;digits=2)))"));

    push!(ppdf, PGFPlots.Linear([a_grid[findmax(pdf_u)[2]],a_grid[findmax(pdf_u)[2]]],
                                [0,maximum(pdf_u)],
                                style="black,dotted,no marks",
                                legendentry="mode ($(round(a_grid[findmax(pdf_u)[2]];digits=2)))"));




    push!(ppdfc, PGFPlots.Linear(cstar[1:cutoff],pdf_u[1:cutoff],style="red,smooth,no marks",
                                legendentry="density"));

    push!(ppdfc, PGFPlots.Linear([cstar'*pdf_u,cstar'*pdf_u],
                                [0,maximum(pdf_u)],
                                style="black,dashed,no marks",
                                legendentry="mean ($(round(cstar'*pdf_u;digits=2)))"));

    push!(ppdfc, PGFPlots.Linear([cstar[findmax(pdf_u)[2]],cstar[findmax(pdf_u)[2]]],
                                [0,maximum(pdf_u)],
                                style="black,dotted,no marks",
                                legendentry="mode ($(round(cstar[findmax(pdf_u)[2]];digits=2)))"));

    
    push!(pcdf, PGFPlots.Linear(a_grid[1:cutoff],cdf[1:cutoff],style="red,smooth,no marks"));
    push!(pcdfc, PGFPlots.Linear(cstar[1:cutoff],cdf[1:cutoff],style="red,smooth,no marks"));

    push!(plorenz, PGFPlots.Linear(cdf,cdf,style="black, dashed, no marks",legendentry="perfect equality"));
    push!(plorenz, PGFPlots.Linear(cdf,lorenz_consumption,style="red, smooth, no marks",legendentry="consumption"));
    push!(plorenz, PGFPlots.Linear(cdf,lorenz_assets,style="blue, smooth, no marks",legendentry=L"assets ($>$0)"));



    pgini = Axis(Plots.BarChart(["income", L"assets ($>$0)", "consumption"], 
                                [gini_income, gini_assets, gini_consumption], 
                                style="cyan"),
                 title  = "Gini index",
                 xlabel = "variable",
                 ylabel = "Gini",
                 width  = "8cm",
                 height = "6cm",
                 style="bar width=25pt")
    
    push!(p,ppdf)
    push!(p,ppdfc)
    push!(p,plorenz)

    push!(p,pcdf)
    push!(p,pcdfc)
    push!(p,pgini)

    save("images/distributions.tex", p)
    
#     display(p)

end
