include("common.jl")

function run_c_reco_test(test::ComparisonTest; testname = nothing)
    # Read the input events
    events = JetReconstruction.read_final_state_particles(test.events_file)
    # Read the fastjet results
    fastjet_jets = read_fastjet_outputs(test.fastjet_outputs)
    sort_jets!(fastjet_jets)

    # Run the jet reconstruction
    jet_collection = Vector{FinalJets}()
    for (ievent, event) in enumerate(events)
        cluster_seq = JetReconstruction.jet_reconstruct(event; R = test.R, p = test.power,
                                                        algorithm = test.algorithm,
                                                        strategy = test.strategy)
        finaljets = final_jets(test.selector(cluster_seq))
        sort_jets!(finaljets)
        push!(jet_collection, FinalJets(ievent, finaljets))
    end

    if isnothing(testname)
        testname = "FastJet comparison: alg=$(test.algorithm), p=$(test.power), R=$(test.R), strategy=$(test.strategy)"
        if test.selector_name != ""
            testname *= ", $(test.selector_name)"
        end
    end

    @testset "$testname" begin
        # Test each event in turn...
        for (ievt, event) in enumerate(jet_collection)
            @testset "Event $(ievt)" begin
                @test size(event.jets) == size(fastjet_jets[ievt]["jets"])
                # Test each jet in turn
                for (ijet, jet) in enumerate(event.jets)
                    if ijet <= size(fastjet_jets[ievt]["jets"])[1]
                        # Approximate test - note that @test macro passes the 
                        # tolerance into the isapprox() function
                        # Use atol for position as this is absolute, but rtol for
                        # the momentum
                        # Sometimes phi could be in the range [-π, π], but FastJet always is [0, 2π]
                        normalised_phi = jet.phi < 0.0 ? jet.phi + 2π : jet.phi
                        @test jet.rap≈fastjet_jets[ievt]["jets"][ijet]["rap"] atol=1e-7
                        @test normalised_phi≈fastjet_jets[ievt]["jets"][ijet]["phi"] atol=1e-7
                        @test jet.pt≈fastjet_jets[ievt]["jets"][ijet]["pt"] rtol=1e-6
                    end
                end
            end
        end
    end
end