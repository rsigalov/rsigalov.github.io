using NLopt
using Plots
using SparseArrays

struct ModelParameters
    γ; # RRA
    μ; # risk premium
    σ; # vol of risky asset
    ν; # vol of int rate
    ρ; # discount rate
    η; # correlation between risky return and risk free rate
    rgrid; # grid for interest rate
    rmin;  # min and max interest rates in the grid
    rmax;  # -//-
    Δr; # step in interest rates grid
    rbar; # [For the geometric OU]
    θ; # [For the geometric OU]
end

function solve_optimal_risky_share(A, params)
    # This function takes a vector of A (investment opportuinities)
    # for a given value of interest rate and a struct of model
    # parameters. It then numerically solves for optimal risky
    # asset allocation.
    rgrid = params.rgrid
    γ = params.γ
    σ = params.σ
    μ = params.μ
    η = params.η
    ν = params.ν;

    # Modifying for non-zero correlation
    αopt=zeros(size(A))
    for i = 1:size(rgrid)[1]
        ri = rgrid[i]
        Ai = A[i]

        if i == 1
            Ailower = A[1]
            Aihigher = A[2]
        elseif i == I
            Ailower = A[I-1]
            Aihigher = A[I]
        else
            Ailower = A[i-1]
            Aihigher = A[i+1]
        end

        # Forming function to solve numerically
        function to_minimize(x::Vector, grad::Vector)
            ((ri + x[1]*μ - 0.5*x[1]^2*σ^2)^(-γ) * (μ - x[1]*σ^2) + Ai*(1-γ)*x[1]*σ^2 + (Aihigher - Ailower)*σ*ri*ν*η/(2*Δr))^2
        end


        function positive_consumption_constraint(x::Vector, grad::Vector)
            -(ri + x[1]*μ - 0.5*x[1]^2*σ^2)
        end

        opt = Opt(:LN_COBYLA, 1)
        lower_bounds!(opt, [-5])
        upper_bounds!(opt, [Inf])
        ftol_abs!(opt, 1e-20)

        min_objective!(opt, to_minimize)
        inequality_constraint!(opt, (x,g) -> positive_consumption_constraint(x,g), 1e-8)

        (minf, minx, ret) = optimize(opt, [0.7])

        αopt[i] = minx[1]
    end

    return αopt
end

function form_matrix_B(α, params)
    # This function forms matrix B that is used in the iteration
    # step to solve for vector of investment opportunities A
    # given a vector of optimal risky shares

    # Getting parameters:
    Δr = params.Δr;
    γ = params.γ;
    ν = params.ν;
    σ = params.σ;
    γ = params.γ;
    η = params.η;
    I = size(params.rgrid)[1];
    rbar = params.rbar;
    θ = params.θ;

    # Modifying for nonzero correlation between risky and risk free asset.
    # Log risk free rate follows a random walk (implies a positive drift for
    # the level of interest rate). Using central differences
    xvec = ν^2 * rgrid.^2/(2 *Δr^2) .- (1-γ)*α.*rgrid*σ*ν*η/(2*Δr) .- rgrid .* 0.5 * ν^2 *0.5/Δr;
    yvec = 0.5*(1-γ)^2 .* α.^2 .* σ^2 .- rgrid.^2 .*ν^2/Δr^2;
    zvec = ν^2 * rgrid.^2/(2 *Δr^2) .+ (1-γ)*α.*rgrid*σ*ν*η/(2*Δr) .+ rgrid .* 0.5 * ν^2 *0.5/Δr;
    v1 = xvec[1];
    vI = zvec[I];
    yvec[1] = yvec[1] + v1;
    yvec[I] = yvec[I] + vI;

    # Forming matrix B using
    B = spdiagm(-1 => xvec[2:I], 0=>yvec, 1=>zvec[1:(I-1)])
    return B
end

function calculate_utility_flow(α, params)
    μ = params.μ;
    γ = params.γ;
    σ = params.σ;
    rgrid = params.rgrid;
    return (rgrid .+ α.*μ .- 0.5.*α.^2 .* σ^2).^(1-γ)
end

function update_value_function(Acurrent, params)
    # 1. Given current A vector calculate optimal risky share
    αopt = solve_optimal_risky_share(Acurrent, params)

    # 2. Given optimal risky share calculate utility flow
    u = calculate_utility_flow(αopt, params)

    # 3. Given optimal alpha calculate "transition" matrix B
    B = form_matrix_B(αopt, params)

    # 4. Given old A vector, flow utility and "transition"
    # matrix update A vector
    I = size(params.rgrid)[1];
    ρ = params.ρ;
    Δ = 1;
    γ = params.γ;

    Aupdated = ((1/Δ + ρ) .* spdiagm(0 => ones(I)) .- B) \ (u .+ Acurrent./Δ);

    return Aupdated, αopt, u
end

function iterate_value_function(params, A_init, tol)
    A_prev = A_init;
    i = 0;
    dist = Inf
    while dist > tol
        i += 1;
        A_next,_ = update_value_function(A_prev, params);

        # Calculating the difference between value functions:
        dist = sum(abs.(A_next .- A_prev));
        A_prev = A_next;
        if i % 1000 == 0
            @show i
            @show dist
            print("\n")
        end
    end

    # Iterate one more step to get all parameters:
    return update_value_function(A_prev, params)
end

# Start with a guess of negative exponential declining A
rmin = 0;
rmax = 1;
I = 1001;
rgrid = range(rmin, stop = rmax, length = I);
Δr = (rmax - rmin)/(I-1);

I = size(rgrid)[1];
A_init = 10000 * exp.(-rgrid);

# params = ModelParameters(4, 0.04, 0.18, 0.01, 0.05, -0.25, rgrid,rmin,rmax,Δr)
params = ModelParameters(3, 0.04, 0.18, 0.01, 0.075, -0.0, rgrid,rmin,rmax,Δr,0.1,1)

Anew, αopt, u = update_value_function(A_init, params)
Plots.plot(Anew)
Plots.plot(αopt)
Plots.plot(u)

Anew, αopt, u = update_value_function(Anew, params)
Plots.plot(rgrid,Anew)
Plots.plot(rgrid,αopt)
Plots.plot(u*(1-params.γ))

# 1. Given current A vector calculate optimal risky share
αopt = solve_optimal_risky_share(A_init, params)

# 2. Given optimal risky share calculate utility flow
u = calculate_utility_flow(αopt, params)

# 3. Given optimal alpha calculate "transition" matrix B
B = form_matrix_B(αopt, params)
sum(B)


mathematicaColor1 = RGBA(0.37,0.51,0.71,1)
mathematicaColor2 = RGBA(0.88,0.61,0.14,1)
mathematicaColor3 = RGBA(0.56,0.69,0.19,1)

# Solving for different value of correlation:
params1 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0.99, rgrid,rmin,rmax,Δr,0.02,1)
params2 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0.0, rgrid,rmin,rmax,Δr,0.02,1)
params3 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, -0.99, rgrid,rmin,rmax,Δr,0.02,1)

A1, α1, flow1 = iterate_value_function(params1, A_init, 1e-6)
A2, α2, flow2 = iterate_value_function(params2, A_init, 1e-6)
A3, α3, flow3 = iterate_value_function(params3, A_init, 1e-6)

Plots.plot(rgrid, α1, label = string("Corr = ", params1.η),
    xaxis = ("Risk Free Rate", (0,0.1)), yaxis = "Risky Share",legend=:bottomleft, lw = 2.75,grid=false,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.plot!(rgrid, α2, label = string("Corr = ", params2.η), lw = 2.75, color=mathematicaColor2)
Plots.plot!(rgrid, α3, label = string("Corr = ", params3.η), lw = 2.75, color=mathematicaColor3)
Plots.savefig("../figures/share_dynamic_vary_corr.pdf")

# Plotting hedging demand: difference between α under non-zero correlation and
# α under zero correlation.


# Solving for different value of Risk Premium:
params4 = ModelParameters(3, 0.02, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)
params5 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)
params6 = ModelParameters(3, 0.10, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)

A4, α4, flow4 = iterate_value_function(params4, A_init, 1e-4)
A5, α5, flow5 = iterate_value_function(params5, A_init, 1e-4)
A6, α6, flow6 = iterate_value_function(params6, A_init, 1e-7)

Plots.plot(rgrid, α4, label = string("RP = ", params4.μ*100,"%"),
    xaxis = ("Risk Free Rate", (0,0.1)), yaxis = "Risky Share",legend=:bottomleft, lw = 2.75,grid=false,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.plot!(rgrid, α5, label = string("RP = ", params5.μ*100,"%"), lw = 2.75, color=mathematicaColor2)
Plots.plot!(rgrid, α6, label = string("RP = ", params6.μ*100,"%"), lw = 2.75, color=mathematicaColor3)
Plots.savefig("../figures/share_dynamic_vary_rp.pdf")

# Solving for different value of Discount Rate:
params7 = ModelParameters(3, 0.06, 0.18, 0.01, 0.050, 0, rgrid,rmin,rmax,Δr,0.02,1)
params8 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)
params9 = ModelParameters(3, 0.06, 0.18, 0.01, 0.100, 0, rgrid,rmin,rmax,Δr,0.02,1)

A7, α7, flow7 = iterate_value_function(params7, A_init, 1e-7)
A8, α8, flow8 = iterate_value_function(params8, A_init, 1e-7)
A9, α9, flow9 = iterate_value_function(params9, A_init, 1e-7)

Plots.plot(rgrid, α7, label = string("Discount Rate  = ", params7.ρ*100,"%"),
    xaxis = ("Risk Free Rate", (0,0.1)), yaxis = "Risky Share",legend=:bottomleft, lw = 2.75,grid=false,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.plot!(rgrid, α8, label = string("Discount Rate  = ", params8.ρ*100,"%"), lw = 2.75, color=mathematicaColor2)
Plots.plot!(rgrid, α9, label = string("Discount Rate  = ", params9.ρ*100,"%"), lw = 2.75, color=mathematicaColor3)
Plots.savefig("../figures/share_dynamic_vary_discount_rate.pdf")

# Solving for different value of Risk Aversion:
params10 = ModelParameters(2, 0.06, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)
params11 = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)
params12 = ModelParameters(4, 0.06, 0.18, 0.01, 0.075, 0, rgrid,rmin,rmax,Δr,0.02,1)

A10, α10, flow10 = iterate_value_function(params10, A_init, 1e-7)
A11, α11, flow11 = iterate_value_function(params11, A_init, 1e-7)
A12, α12, flow12 = iterate_value_function(params12, A_init, 1e-7)

Plots.plot(rgrid, α10, label = string("RRA = ", params10.γ),
    xaxis = ("Risk Free Rate", (0,0.1)), yaxis = "Risky Share",legend=:bottomleft, lw = 2.75,grid=false,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.plot!(rgrid, α11, label = string("RRA = ", params11.γ), lw = 2.75, color=mathematicaColor2)
Plots.plot!(rgrid, α12, label = string("RRA = ", params12.γ), lw = 2.75, color=mathematicaColor3)
Plots.savefig("../figures/share_dynamic_vary_rra.pdf")



################################################################
# Numerically calculating drift of log consumption

params = ModelParameters(3, 0.06, 0.18, 0.01, 0.075, 0.0, rgrid,rmin,rmax,Δr,0.1,1)
A, α, flow=iterate_value_function(params, A_init, 1e-6)
γ = params.γ
σ = params.σ
μ = params.μ
ν = params.ν
ρ = params.ρ

dα = (α[2:(I-1)] .- α[1:(I-2)])./Δr;
ddα = (α[3:I] - 2*α[2:(I-1)] + α[1:(I-2)])./Δr;
α = α[2:(I-1)]
r = rgrid[2:(I-1)]
f = r .+ α * μ .- 0.5*α.^2 * σ^2;
df = 1 .+ dα * μ .- α .* dα * σ^2;
ddf = ddα * μ .- (dα.^2 + α .* ddα) * σ^2;
dlogc = 0.5*ν^2 * r .* (df .* f .+ ddf .* f - df.^2)./(f.^2);

Plots.plot(r,dlogc,xaxis = ("Risk Free Rate", (0,0.25)),label="",
    yaxis = "Log Consumption Drift",lw = 2.75,grid=false,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.savefig("../figures/dynamic_model_log_consumption_drift.pdf")

# Calculating instantenous volatility of log(c):
voldlogc = ν * r .* df./f

Plots.plot(r,dlogc,xaxis = ("Risk Free Rate", (0,0.25)),label="Drift",
    yaxis = "Log Consumption Drift",lw = 2.75,grid=false,legend=:topleft,
    yguidefontsize=12,guidefontsize=12,legendfontsize=12,tickfontsize=12, color=mathematicaColor1)
Plots.plot!(r,voldlogc,lw = 2.75, color=mathematicaColor2, label = "Volatility")
