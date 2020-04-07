function calculate_losses!(result, data)
    for (l, branch) in result["solution"]["branch"]
        branch["ploss"] = branch["pf"] + branch["pt"]
    end
    result["totalloss"] = sum(branch["ploss"] for (l, branch) in result["solution"]["branch"])

    result["totalload"] = sum(load["pd"] for (l, load) in data["load"])

    result["totalgen"] = sum(gen["pg"] for (l, gen) in result["solution"]["gen"])

    return result["totalloss"]
end
