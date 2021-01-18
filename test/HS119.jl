@testset "Constrained linear example 6: HS119" begin

    # blackbox
    function bb(x)
        M = zeros(16, 16)
        M = [1.0  0.0  0.0  1.0  0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0;
             0.0  1.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0;
             0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0;
             0.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0;
             0.0  0.0  0.0  0.0  1.0  1.0  0.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  1.0;
             0.0  0.0  0.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0  0.0  1.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  1.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  1.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0;
             0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0]

        f = 0.0
        for i in 1:16
            for j in 1:16
                f += M[i,j] * (x[i]^3 + 1) * (x[j]^3 + 1)
            end
        end
        bb_outputs = [f]
        success = true
        count_eval = true
        return (success, count_eval, bb_outputs)
    end

    # linear constraints
    A = [0.22   0.2    0.19   0.25   0.15   0.11   0.12   0.13   1.0   0.0  0.0  0.0  0.0  0.0  0.0  0.0;
         -1.46   0.0   -1.3    1.82  -1.15   0.0    0.8    0.0    0.0   1.0  0.0  0.0  0.0  0.0  0.0  0.0;
         1.29  -0.89   0.0    0.0   -1.16  -0.96   0.0   -0.49   0.0   0.0  1.0  0.0  0.0  0.0  0.0  0.0;
         -1.1   -1.06   0.95  -0.54   0.0   -1.78  -0.41   0.0    0.0   0.0  0.0  1.0  0.0  0.0  0.0  0.0;
         0.0    0.0    0.0   -1.43   1.51   0.59  -0.33  -0.43   0.0   0.0  0.0  0.0  1.0  0.0  0.0  0.0;
         0.0   -1.72  -0.33   0.0    1.62   1.24   0.21  -0.26   0.0   0.0  0.0  0.0  0.0  1.0  0.0  0.0;
         1.12   0.0    0.0    0.31   0.0    0.0    1.12   0.0   -0.36  0.0  0.0  0.0  0.0  0.0  1.0  0.0;
         0.0    0.45   0.26  -1.1    0.58   0.0   -1.03   0.1    0.0   0.0  0.0  0.0  0.0  0.0  0.0  1.0]
    b = [2.5; 1.1; -3.1; -3.5; 1.3; 2.1; 2.3; -1.5]

    p = NomadProblem(16, 1, ["OBJ"], bb,
                     lower_bound = zeros(16),
                     upper_bound = 5.0 * ones(16),
                     A = A, b = b)

    p.options.max_bb_eval = 700
    #p.options.linear_converter = "QR"

    x0 = [0.47954703198607029346334229558124;
          0.20903361134259468290252925726236;
          1.9195872190834724069219419106958;
          2.0409390972982839329574744624551;
          0.33137413872482429644250601086242;
          2.1982600582891782536876235099044;
          0.66348662113045742128036863505258;
          2.1460997916513342431699129519984;
          0.82761049007325315773897500548628;
          0.43138385705448173412790424663399;
          0.013736797620440043335432456217404;
          0.71250903603782800299626387641183;
          3.5629680206545710774435065104626;
          0.24898677218596276805584466274013;
          0.68505096477339177951648707676213;
          0.4284594451010815263636288818816]

    result = solve(p, x0)

    # solve problem
    @test length(result.x_best_feas) == 16
    @test bb(result.x_best_feas)[3] ≈ result.bbo_best_feas
    @test result.x_best_inf == nothing
    @test isapprox(A * result.x_best_feas, b, atol=1e-13)
    @test all(0.0 .<= result.x_best_feas .<= 5.0)

end
