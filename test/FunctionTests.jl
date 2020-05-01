include("../src/jdplyr.jl")

using DataFrames, Test, .jdplyr

df_a = DataFrame(one = [1, 2, 3, 4, 5], two = [6, 7, 8, 9, 10])
df_b = DataFrame(one = [1, 1, 2, 2, 2], two = [20, 21, 22, 23, 24])
df_c = DataFrame(one = [1, 2, 3], two = [1, 2, 3], three = [1, 2, 3])

@testset "Functions" begin
    @test _select(df_a, :one, :two) == df_a

    mutate_test = copy(df_a)
    mutate_test[!, :new] = df_a.one .+ 1
    @test _mutate(df_a, new = df_a.one .+ 1) == mutate_test

    @test _filter(df_a, df_a.one .> 2, df_a.two .> 8) ==
          df_a[(df_a.one.>2).&(df_a.two.>8), :]

    @test _arrange(df_a, :one, desc(:two)) ==
          sort(df_a, (:one, order(:two, rev = true)))

    @test _summarise(df_a, sum = :one => sum).sum[1] == 15
    @test _summarize(df_a, sum = :one => sum).sum[1] == 15
    @test _summarise(_group_by(df_b, :one), sum = :two => sum).sum[1] == 41

    @test _left_join(df_a, df_b, on = :one).two_1[1] ==
          join(df_a, df_b, on = :one, kind = :left, makeunique = true).two_1[1]

    @test (
        _gather(df_c, key = :variable, factor_cols = [:one]) |>
        x -> _select(x, :variable, :value) |> x -> _arrange(x, desc(:variable))
    ) == stack(df_c, [:two, :three])[!, [:variable, :value]]

    @test _head(df_a, 2) == df_a[1:2, :]
    @test _tail(df_a, 2) == df_a[end-1:end, :]

    rename_test = copy(df_a)
    rename!(rename_test, :one => :new_one)
    @test _rename(df_a, new_one=:one) == rename_test

    @test _slice(df_a, 1:2) == df_a[1:2, :]
end
