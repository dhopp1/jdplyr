using DataFrames

export _select
export _mutate
export _filter
export _arrange
export _summarise
export _summarize
export _group_by
export _left_join
export _right_join
export _inner_join
export _outer_join
export _gather
export _spread
export _head
export _tail
export _rename
export _slice
export desc
export summarise_cols
export summarize_cols

# select
"""
    select columns from a dataframe

    parameters:
        args[1] : DataFrame
            dataframe to select from
        args[2:end] : Symbol
            arbitrary number of columns to select

    returns: DataFrame
        selected columns of the dataframe

    example:
        df |> x->
            _select(x, :col1, :col2)
"""
function _select(args...)
    args[1][!, collect(args[2:end])]
end


# mutate
"""
    create new columns in a dataframe

    parameters:
        df : DataFrame
            dataframe to mutate
        kwargs :
            column names and values, values can either be a scalar or vector of same length as number of rows of dataframe

    returns: DataFrame
        dataframe with mutated columns. If same name given to column, will update values in place.

    example:
        df |> x->
            _mutate(x, new_col=10, new_col2=x.old .+ 1)
"""
function _mutate(df::DataFrame; kwargs...)
    new_df = copy(df)
    for (new_col, values) in Dict(kwargs)
        new_df[!, Symbol(new_col)] .= values
    end
    return new_df
end


# filter
"""
    filter a dataframe row-wise

    parameters:
        args[1] : DataFrame
            dataframe to filter
        args[2:end] : BitArray
            arbitrary number of arrays boolean BitArrays

    returns: DataFrame
        dataframe with filtered rows. Subsequent kwargs will be treated as AND operators

    example:
        df |> x->
            _filter(x, x.value .> 10, x.value2 .< 5, (x.value3 .== 1) .| (x.value4 .== 2))
"""
function _filter(args...)
    new_df = copy(args[1])
    conds = [minimum(x) for x in eachrow(hcat(collect(args[2:end])...))]
    new_df[conds, :]
end


# arrange
"""
    sort a dataframe

    parameters:
        args[1] : DataFrame
            dataframe to sort
        args[2:end] : Symbol
            columns to be sorted by, in order input. desc(:col) will sort Z to A

    returns: DataFrame
        sorted dataframe

    example:
        df |> x->
            _arrange(x, :col1, desc(:col2))
"""
desc(x) = order(x, rev=true)
function _arrange(args...)
    sort(args[1], args[2:end])
end


#summarise
"""
    summarise columns of a dataframe

    parameters:
        args[1] : DataFrame
            dataframe to summarise
        args[2:end] : Pair
            (optional) column and function to be summarised, e.g. :col => sum
        kwargs : Pair
            (optional) name of new column, column and function to be summarised, e.g. new_col = :col => sum

    returns: DataFrame
        summarised dataframe

    example:
        df |> x->
            _summarise(x, new_col = :col => sum)

    notes:
        parameters must be passed either as all args (default new column names), or all kwargs (named new column names)
        can be used with summarise_cols function to summarise many columns without explicitly typing them out (only works for column names with no spaces)
            e.g.: data |> x->
                    _summarise(x, summarise_cols([:col1, :col2], "mean")...)
"""
function _summarise(args...; kwargs...)
    typeof(args[1]) == GroupedDataFrame{DataFrame} ? df = args[1] : df = groupby(args[1], [])
    if !isempty(kwargs)
        new_df = combine(values(kwargs), df)
    else
        new_df = combine(args[2:end], df)
    end
    return new_df
end
_summarize = _summarise
summarise_cols(cols, operator) = eval(Meta.parse(replace(":" .* (cols .|> string) .* " => $operator" .|> string |> string, r"\"|\[|\]"=>"")))
summarize_cols = summarise_cols



# group by
"args[1] = dataframe to group, args[2:end = column names to group by (Symbols)]"
function _group_by(args...)
    groupby(args[1], collect(args[2:end]))
end



# join
"""
    identical functionality to DataFrames.join, reproduced here for syntactical continuity

    parameters:
        a : DataFrame
            original dataframe
        b : DataFrame
            dataframe to join to a
        on : Dict{Symbol, Symbol} | Symbol
            key columns, e.g. Dict(:ida => :idb, :id2a => :id2b), or just :id if the id column is named the same in both dataframes

    returns: DataFrame
        joined dataframe

    example:
        df |> x->
            _left_join(x, y, Dict(:ida => :idb))
"""
function _macro_join(a::DataFrame, b::DataFrame; on, kind)
    typeof(on) == Dict{Symbol, Symbol} ? join_on = [Pair(key, value) for (key, value) in on] : join_on = on
    join(a, b, on=join_on, kind=kind, makeunique=true)
end
_left_join(a, b; on) = _macro_join(a, b; on=on, kind=:left)
_right_join(a, b; on) = _macro_join(a, b; on=on, kind=:right)
_inner_join(a, b; on) = _macro_join(a, b; on=on, kind=:inner)
_outer_join(a, b; on) = _macro_join(a, b; on=on, kind=:outer)



# gather
"""
    convert a dataframe from long format to wide format

    parameters:
        df : DataFrame
            original dataframe
        key : Symbol
            what to name the new key column (previously the wide column names)
        value : Symbol
            what to call the new value column
        factor_cols :  Array{Symbol}
            which columns are factors and should not be put into the key column

    returns: DataFrame
        long dataframe

    example:
        df |> x->
            _gather(x, key=:country, value=:population, factor_cols=[:date])
"""
function _gather(df::DataFrame; key=:type, value=:value, factor_cols)
    non_factor_cols = collect(setdiff(Set(names(df)), Set(factor_cols)))
    new_df = stack(df, non_factor_cols)
    rename!(new_df, Dict(:variable => key, :value => value))
    col_order = [factor_cols; key; value]
    return new_df[!, col_order]
end


# spread
"identical to DataFrames.unstack, reproduced here for syntactical continuity"
_spread = unstack


# head / tail
"return the first n rows of a dataframe"
function _head(df::DataFrame, n=5)
    first(df, n)
end

"return the last n rows of a dataframe"
function _tail(df::DataFrame, n=5)
    df[end-n+1:end,:]
end


# rename
"""
    rename columns of a dataframe

    parameters:
        df : DataFrame
            original dataframe
        kwargs : new_name=:old_name
            arbitrary number of new colum names to rename old columns

    returns: DataFrame
        dataframe with renamed columns

    example:
        df |> x->
            _rename(x, new_name=:old_name, new2=:old2)
"""
function _rename(df::DataFrame; kwargs...)
    rename(df, Dict(zip(values(kwargs), Symbol.(keys(kwargs)))))
end


# slice
"return selected rows of form 1:10 of a dataframe"
function _slice(df::DataFrame, rows)
    return df[rows, :]
end
