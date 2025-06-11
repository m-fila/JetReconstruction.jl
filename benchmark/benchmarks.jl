using BenchmarkTools
using JetReconstruction

const events_file_pp = joinpath(@__DIR__, "..", "test", "data", "events.pp13TeV.hepmc3.gz")
const events_file_ee = joinpath(@__DIR__, "..", "test", "data", "events.eeH.hepmc3.gz")

const pp_events = JetReconstruction.read_final_state_particles(events_file_pp,
                                                               T = PseudoJet)
const ee_events = JetReconstruction.read_final_state_particles(events_file_ee, T = EEJet)

function jet_reconstruct_harness(events; algorithm, strategy, power, distance,
                                 recombine = RecombinationMethods[RecombinationScheme.EScheme],
                                 ptmin::Real = 5.0, dcut = nothing, njets = nothing,)
    for event in events
        cs = jet_reconstruct(event; R = distance, p = power, algorithm = algorithm,
                             strategy = strategy, recombine...)
        if !isnothing(njets)
            finaljets = exclusive_jets(cs; njets = njets)
        elseif !isnothing(dcut)
            finaljets = exclusive_jets(cs; dcut = dcut)
        else
            finaljets = inclusive_jets(cs; ptmin = ptmin)
        end
    end
end

const SUITE = BenchmarkGroup()
SUITE["jet_reconstruction"] = BenchmarkGroup(["reconstruction"])

## pp events
for stg in [RecoStrategy.N2Plain, RecoStrategy.N2Tiled]
    strategy_name = "$(stg)"
    SUITE["jet_reconstruction"][strategy_name] = BenchmarkGroup(["pp", strategy_name])
    for alg in [JetAlgorithm.AntiKt, JetAlgorithm.CA, JetAlgorithm.Kt]
        for distance in [0.4]
            power = JetReconstruction.algorithm2power[alg]
            SUITE["jet_reconstruction"][strategy_name]["Alg=$alg, R=$distance"] = @benchmarkable jet_reconstruct_harness($pp_events;
                                                                                                                         algorithm = $alg,
                                                                                                                         strategy = $stg,
                                                                                                                         power = $power,
                                                                                                                         distance = $distance,
                                                                                                                         ptmin = 5.0) evals=1 samples=32
        end
    end
end

## ee events
SUITE["jet_reconstruction"]["ee"] = BenchmarkGroup(["ee"])
for alg in [JetAlgorithm.Durham]
    for distance in [0.4]
        power = -1
        SUITE["jet_reconstruction"]["ee"]["Alg=$alg, R=$distance"] = @benchmarkable jet_reconstruct_harness($ee_events;
                                                                                                            algorithm = $alg,
                                                                                                            strategy = $RecoStrategy.Best,
                                                                                                            power = $power,
                                                                                                            distance = $distance,
                                                                                                            ptmin = 5.0) evals=1 samples=32
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    @info "Running benchmark suite"
    results = run(SUITE, verbose = true)
    @info results
end
