function calculate_losses!(res, data)
    for (l, branch) in res["solution"]["branch"]
        branch["ploss"] = branch["pf"] + branch["pt"]
    end
    res["totalloss"] = sum(branch["ploss"] for (l, branch) in res["solution"]["branch"])

    res["totalload"] = sum(load["pd"] for (l, load) in data["load"])

    res["totalgen"] = sum(gen["pg"] for (l, gen) in res["solution"]["gen"])
end
