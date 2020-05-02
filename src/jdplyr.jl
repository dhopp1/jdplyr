module jdplyr

include("Functions.jl")
using DataFrames, Lazy

for n in [names(DataFrames); names(Lazy)]
        @eval export $n
end

end
