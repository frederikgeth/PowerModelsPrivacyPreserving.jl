function calculate_losses!(result, data)
    for (l, branch) in result["solution"]["branch"]
        branch["ploss"] = branch["pf"] + branch["pt"]
    end
    result["totalloss"] = sum(branch["ploss"] for (l, branch) in result["solution"]["branch"])

    result["totalload"] = sum(load["pd"] for (l, load) in data["load"])

    result["totalgen"] = sum(gen["pg"] for (l, gen) in result["solution"]["gen"])

    return result["totalloss"]
end

"This function accepts a data dictionary, and returns a new data dictionary
with perturbation applied"
function create_impedance_perturbation(data_input, α, ϵ, λ)
    # Create a copy of the input so that a new dataset is returned
    data = deepcopy(data_input)

    # First apply the Laplace noise to each branch
    distribution = Distributions.Laplace(0, 3 * α / ϵ)
    sum_g = 0
    sum_b = 0
    sum_g_shunt = 0
    sum_b_shunt = 0
    for (l, branch) in data["branch"]
        noise = Random.rand(distribution, 1)[1]
        noise_shunt = Random.rand(distribution, 1)[1]
        z = branch["br_r"] + im*branch["br_x"]
        y = 1 / z
        g = real(y)
        b = imag(y)
        g_shunt = branch["g_to"] #assumes it is equal to branch["g_fr"]
        b_shunt = branch["b_to"] #assumes it is equal to branch["b_fr"]
        # println("g is: ", g)
        # println("b is: ", b)

        # Handle the case where resistance is 0 to avoid undefined behaviour
        if branch["br_r"] != 0
            r = b / g # Algorithm 1 and eq. (15)
            pert_b = b + noise
            pert_g = pert_b / r
        else
            pert_g = 0
            pert_b = b + noise # Just apply perturbation to b
        end

        pert_b_shunt = b_shunt + noise_shunt
        pert_g_shunt = g_shunt # Removed the perturbation of g_shunt

        branch["g_obj"] = pert_g
        branch["b_obj"] = pert_b
        branch["g_shunt_obj"] = pert_g_shunt
        branch["b_shunt_obj"] = pert_b_shunt
        # println("perturbed g is: ", pert_g)
        # println("perturbed b is: ", pert_b)
        sum_g += g
        sum_b += b
        sum_g_shunt += g_shunt
        sum_b_shunt += b_shunt
    end

    # Apply the noisy mean limit values for s4 and s5
    n = length(data["branch"])
    lap_μ = Distributions.Laplace(0, 3 * α / (n * ϵ))

    μ_g = (1 / n) * sum_g + Random.rand(lap_μ, 1)[1] # Eq 16
    μ_b = (1 / n) * sum_b + Random.rand(lap_μ, 1)[1] # Eq 17
    μ_g_shunt = (1 / n) * sum_g_shunt + Random.rand(distribution, 1)[1]
    μ_b_shunt = (1 / n) * sum_b_shunt + Random.rand(distribution, 1)[1]
    # In the case that random perturbations create negative values, floor these at 0
    if μ_g_shunt < 0
        μ_g_shunt = 0
    end
    if μ_b_shunt < 0
        μ_b_shunt = 0
    end

    # Add noisy mean limit values to our data dictionary
    # Note that we use min and max to handle negative parameters
    data["g_lb"] = min(μ_g / λ, μ_g * λ)
    data["g_ub"] = max(μ_g / λ, μ_g * λ)
    data["b_lb"] = min(μ_b / λ, μ_b * λ)
    data["b_ub"] = max(μ_b / λ, μ_b * λ)
    data["g_lb_shunt"] = min(μ_g_shunt / λ, μ_g_shunt * λ)
    data["g_ub_shunt"] = max(μ_g_shunt / λ, μ_g_shunt * λ)
    data["b_lb_shunt"] = min(μ_b_shunt / λ, μ_b_shunt * λ)
    data["b_ub_shunt"] = max(μ_b_shunt / λ, μ_b_shunt * λ)
    @show data["b_lb_shunt"], data["b_ub_shunt"]

    return data
end


function overwrite_impedances_in_data!(result, data)
    for (l, branch) in result["solution"]["branch"]
        y = branch["g"] + im* branch["b"]
        z = 1/y
        r = real(z)
        x = imag(z)
        b = branch["b_shunt"]
        data["branch"][l]["br_r"] = r
        data["branch"][l]["br_x"] = x
        data["branch"][l]["b_fr"] = b
        data["branch"][l]["b_to"] = b
    end
end
