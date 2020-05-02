module jdplyr

include("Functions.jl")
using DataFrames, Lazy, Statistics

for n in [names(DataFrames); names(Lazy); names(Statistics)]
        @eval export $n
end

end
