# jdplyr
Dplyr-like syntax for DataFrames.jl.  Also exposes functions of packages `DataFrames`, `Lazy`, and `Statistics`.

### Installation
```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/dhopp1/jdplyr"))
using jdplyr
```

### Piping syntax
- **Native Julia pipes**: `df |> x-> _func(x, x.column)`. Anonymised function required, x is first argument in the function. `x.column` can be used to refer to columns in the previous dataframe.
- **Lazy.jl threading (one line)**: `@> df _func(arg2) _func2(arg2)`. Previous output will be first parameter in new function, subsequent parameters follow. No need for anonymised function.
- **Lazy.jl threading (multi-line)**:
```
@> begin df
	_func(arg2)
	_func2(arg2)
end
```
- **Lazy.jl threading (anonymised)**:
```
@> begin df
	_func(arg2)
x->	_func2(x, x.column)
end
```
In this case, when the dataframe needs to be referred to for columns etc., x is again the first argument of the function, `x.column` can be used to refer to columns in the dataframe.

### Functions
Most verbs follow exact dplyr syntax, though sometimes there are slight variations due to differences in how Julia DataFrames work. 

- **_select**: `df |> x-> _select(x, :col1, :col2)`
- **_mutate**: `df |> x-> _mutate(x, new_col=10, new_col2=x.old .+ 1)`
- **_filter**: `df |> x-> _filter(x, x.value .> 10, x.value2 .< 5, (x.value3 .== 1) .| (x.value4 .== 2))`
- **_arrange**: `df |> x-> _arrange(x, :col1, desc(:col2))`
- **_summarise**: `df |> x-> _summarise(x, new_col = :col => sum)`
- **_group_by**: `df |> x-> _group_by(x, :col1, :col2)`
- **_group_by + _summarise**: `df |> x-> _group_by(x, :col1, :col2) |> x-> summarise(x, total = :col3 => sum)` 
- **_left_join, _right_join, _inner_join, _outer_join**: `df |> x-> _left_join(x, y, on=Dict(:ida => :idb))`
- **_gather**: `df |> x-> _gather(x, key=:country, value=:population, factor_cols=[:date])`
- **_spread**: `df |> x-> _spread(x, :key, :value)`
- **_head**: `head(df)`
- **_tail**: `tail(df)`
- **_rename**: `df |> x->_rename(x, new_name=:old_name, new2=:old2)`
- **_slice**: `df |> x-> _slice(x, 1:10)`
- **_read_csv**: `_read_csv("path")`
- **_write_csv**: `_write_csv(df, "path")`
