# jdplyr
Dplyr-like syntax for DataFrames.jl. Made to leverage Julia's existing pipe functionality and the elegant syntax of dplyr.

### Installation
```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/dhopp1/jdplyr"))
using jdplyr
```

### Functions
Most verbs follow exact dplyr syntax, though sometimes there are slight variations due to differences in how Julia DataFrames work. For instance for pipes, `df |> x-> _func(x)` is the usual expected syntax of the package.

- **_select**: `df |> x-> _select(x, :col1, :col2)`
- **_mutate**: `df |> x-> _mutate(x, new_col=10, new_col2=x.old .+ 1)`
- **_filter**: `df |> x-> _filter(x, x.value .> 10, x.value2 .< 5, (x.value3 .== 1) .| (x.value4 .== 2))`
- **_arrange**: `df |> x-> _arrange(x, :col1, desc(:col2))`
- **_summarise**: `df |> x-> _summarise(x, new_col = :col => sum)`
- **_group_by**: `df |> x-> _group_by(x, [:col1, :col2])`
- **_left_join, _right_join, _inner_join, _outer_join**: `df |> x-> _left_join(x, y, Dict(:ida => :idb))`
- **_gather**: `df |> x-> _gather(x, key=:country, value=:population, factor_cols=[:date])`
- **_spread**: `df |> x-> _spread(x, :type, :value)`
- **_head**: `head(df)`
- **_tail**: `tail(df)`
- **_rename**: `df |> x->_rename(x, new_name=:old_name, new2=:old2)`
- **_slice**: `df |> x-> _slice(x, 1:10)`
