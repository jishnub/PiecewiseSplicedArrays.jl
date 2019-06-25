module PiecewiseSplicedArrays
using PiecewiseIncreasingRanges,StaticArrays
export PiecewiseSplicedArray

struct PiecewiseSplicedArray{TA,N,AA<:AbstractArray} <: AbstractArray{TA,N}
    parent::AA
    axesranges::Tuple{Vararg{<:PiecewiseIncreasingRange,N}}
    parentinds::MVector{N,Int64}
end

function PiecewiseSplicedArray(a::AbstractVector{TA},axesranges::PiecewiseIncreasingRange) where {TA}
	PiecewiseSplicedArray{TA,1,typeof(a)}(a,(axesranges,),MVector{1,Int64}(zeros(Int64,1)))
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},axesranges::Vararg{<:PiecewiseIncreasingRange,N}) where {TA,N}
	PiecewiseSplicedArray{TA,N,typeof(a)}(a,axesranges,MVector{N,Int64}(zeros(Int64,N)))
end

Base.parent(A::PiecewiseSplicedArray) = A.parent

Base.size(a::PiecewiseSplicedArray) = size(parent(a))
Base.size(a::PiecewiseSplicedArray,d) = size(parent(a),d)

Base.axes(A::PiecewiseSplicedArray) = A.axesranges
Base.axes(A::PiecewiseSplicedArray{T,N},d) where {T,N} = 1 <= d <= N ? A.axesranges[d] : 1:1

function Base.getindex(A::PiecewiseSplicedArray{TA,N}, I::Vararg{Int,N}) where {TA,N}
	checkbounds(A, I...)
	for (dimno,(r,ind)) in enumerate(zip(A.axesranges,I))
		A.parentinds[dimno] = findfirst(isequal(ind),r)
	end
	A.parent[A.parentinds...]
end

function Base.setindex!(A::PiecewiseSplicedArray{TA,N},val,I::Vararg{Int,N}) where {TA,N}
	checkbounds(A, I...)
	for (dimno,(r,ind)) in enumerate(zip(A.axesranges,I))
		A.parentinds[dimno] = findfirst(isequal(ind),r)
	end
	A.parent[A.parentinds...] = val
	val
end

Base.print_array(io::IO,A::PiecewiseSplicedArray) = Base.print_array(io,A.parent)

end
