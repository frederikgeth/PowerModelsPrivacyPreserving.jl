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
    for (l, branch) in data["branch"]
        noise = Random.rand(distribution, 1)[1]
        z = branch["br_r"] + im*branch["br_x"]
        y = 1 / z
        g = real(y)
        b = imag(y)
        # println("g is: ", g)
        # println("b is: ", b)

        # Handle the case where resistance is 0 to avoid undefined behaviour
        if branch["br_r"] != 0
            r = b / g # Algorithm 1 and eq. (15)
            pert_g = g + noise # noisy conductances
            pert_b = r * pert_g # get noisy susceptances
        else
            pert_g = 0
            pert_b = b + noise # Just apply perturbation to b
        end

        branch["g_obj"] = pert_g
        branch["b_obj"] = pert_b
        # println("perturbed g is: ", pert_g)
        # println("perturbed b is: ", pert_b)
        sum_g += g
        sum_b += b
    end

    # Apply the noisy mean limit values for s4 and s5
    n = length(data["branch"])
    lap_μ = Distributions.Laplace(0, 3 * α / (n * ϵ))

    μ_g = (1 / n) * sum_g + Random.rand(lap_μ, 1)[1] # Eq 16
    μ_b = (1 / n) * sum_b + Random.rand(lap_μ, 1)[1] # Eq 17

    # Add noisy mean limit values to our data dictionary
    # Note that we use min and max to handle negative parameters
    data["g_lb"] = min(μ_g / λ, μ_g * λ)
    data["g_ub"] = max(μ_g / λ, μ_g * λ)
    data["b_lb"] = min(μ_b / λ, μ_b * λ)
    data["b_ub"] = max(μ_b / λ, μ_b * λ)

    return data
end
