# PiecewiseSplicedArrays.jl
[![Build Status](https://travis-ci.com/jishnub/PiecewiseSplicedArrays.jl.svg?branch=master)](https://travis-ci.com/jishnub/PiecewiseSplicedArrays.jl)

Arrays with discontinuous ranges as indices. As of now only `AbstractUnitRange`s are allowed as axes, but more ranges might be allowed in the future. Getting and setting indices are supported.

```julia
julia> psa=PiecewiseSplicedArray(zeros(5,5),([1:3,6:7],[1:4,7:7]))
5×5 PiecewiseSplicedArray{Float64,2,Array{Float64,2},UnitRange{Int64}} with indices [1, 2, 3, 6, 7]×[1, 2, 3, 4, 7]:
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

 julia> axes(psa)
([1, 2, 3, 6, 7], [1, 2, 3, 4, 7])
 ```

`eachindex` uses linear indexing based on the parent array


```julia
 julia> for i in eachindex(psa)
       	  psa[i]=i
       	end

julia> psa
5×5 PiecewiseSplicedArray{Float64,2,Array{Float64,2},UnitRange{Int64}} with indices [1, 2, 3, 6, 7]×[1, 2, 3, 4, 7]:
 1.0   6.0  11.0  16.0  21.0
 2.0   7.0  12.0  17.0  22.0
 3.0   8.0  13.0  18.0  23.0
 4.0   9.0  14.0  19.0  24.0
 5.0  10.0  15.0  20.0  25.0
```

Can get and set indices linearly as well as using Cartesian index notation

```julia
julia> psa[19]
19.0

julia> psa[6,4]
19.0

julia> psa[2,2]=34
34

julia> psa[7]
34.0
```

Note that `CartesianIndices` are not supported at the moment.

The arrays are not as performant as standard `Array`s or `OffsetArray`s, so do not use these for performance-critical applications. There is a performance penalty of around 8-10x.

```julia
julia> using BenchmarkTools

julia> a=zeros(5,5);

julia> @btime $a[3,3]; # Array
  3.197 ns (0 allocations: 0 bytes)

julia> using OffsetArrays; a=zeros(1:5,1:5);

julia> @btime $a[3,3]; # OffsetArray
  7.673 ns (0 allocations: 0 bytes)

julia> @btime $psa[3,3]; # PiecewiseSplicedArray
  33.578 ns (0 allocations: 0 bytes)
```
