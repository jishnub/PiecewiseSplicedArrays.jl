module PiecewiseSplicedArrays
using PiecewiseIncreasingRanges,StaticArrays
export PiecewiseSplicedArray

struct PiecewiseSplicedArray{TA,N,AA<:AbstractArray} <: AbstractArray{TA,N}
    parent::AA
    axesranges::Tuple{Vararg{<:PiecewiseIncreasingRange,N}}
    parentinds::MVector{N,Int64}
    function PiecewiseSplicedArray{T,N,AA}(a::AA,axesranges,parentinds) where {T,N,AA<:AbstractArray{T,N}}
    	checknumberofinds(a,axesranges)
    	new{T,N,AA}(a,axesranges,parentinds)
    end
end

function PiecewiseSplicedArray(a::AbstractVector{TA},axesranges::PiecewiseIncreasingRange) where {TA}
	PiecewiseSplicedArray{TA,1,typeof(a)}(a,(axesranges,),MVector{1,Int64}(zeros(Int64,1)))
end

function PiecewiseSplicedArray(a::AbstractVector{TA},axesranges::Vararg{<:AbstractUnitRange}) where {TA}
	ax = PiecewiseIncreasingRange([axesranges...])
	PiecewiseSplicedArray{TA,1,typeof(a)}(a,(ax,),MVector{1,Int64}(zeros(Int64,1)))
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},axesranges::Vararg{<:PiecewiseIncreasingRange,N}) where {TA,N}
	PiecewiseSplicedArray{TA,N,typeof(a)}(a,axesranges,MVector{N,Int64}(zeros(Int64,N)))
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},axesranges) where {TA,N}
	checknumberofdims(a,axesranges)
	axesranges = Tuple(PiecewiseIncreasingRange.(axesranges))
	PiecewiseSplicedArray{TA,N,typeof(a)}(a,axesranges,MVector{N,Int64}(zeros(Int64,N)))
end

struct ArraySizeMismatch{T1,T2,T3} <: Exception
	dim::T1
	s :: T2
	ninds :: T3
end

struct DimensionMismatch{T1,T2} <: Exception
	ndims :: T1
	naxes :: T2
end

Base.showerror(io::IO, e::ArraySizeMismatch) = println("size along dimension $(e.dim) is $(e.s) but you have provided $(e.ninds) indices")
Base.showerror(io::IO, e::DimensionMismatch) = println("array has $(e.ndims) dimension but you have provided indices along $(e.naxes) axes")

function checknumberofdims(a,axesranges)
	length(axesranges) == ndims(a) || throw(DimensionMismatch(ndims(a),length(axesranges)))
end

function checknumberofinds(a,axesranges)
	s = size(a)
	for (dim,inds) in enumerate(axesranges)
		(s[dim] == length(inds)) || throw(ArraySizeMismatch(dim,s[dim],length(inds)))
	end
end

Base.parent(A::PiecewiseSplicedArray) = A.parent

Base.size(a::PiecewiseSplicedArray) = size(parent(a))
Base.size(a::PiecewiseSplicedArray,d) = size(parent(a),d)

Base.axes(A::PiecewiseSplicedArray) = A.axesranges
Base.axes(A::PiecewiseSplicedArray{T,N},d) where {T,N} = 1 <= d <= N ? A.axesranges[d] : 1:1

Base.IndexStyle(::Type{OA}) where {OA<:PiecewiseSplicedArray} = IndexStyle(parenttype(OA))
parenttype(::Type{PiecewiseSplicedArray{T,N,AA}}) where {T,N,AA} = AA
parenttype(A::PiecewiseSplicedArray) = parenttype(typeof(A))

function Base.getindex(A::PiecewiseSplicedArray{TA,N}, I::Vararg{Int,N}) where {TA,N}
	checkbounds(A, I...)
	for dim=1:N
		@inbounds A.parentinds[dim] = searchsortedfirst(A.axesranges[dim],I[dim])
	end
	@inbounds A.parent[A.parentinds...]
end

function Base.getindex(A::PiecewiseSplicedArray, i::Int)
    checkbounds(A, i)
    @inbounds ret = parent(A)[i]
    ret
end

function Base.setindex!(A::PiecewiseSplicedArray{TA,N},val,I::Vararg{Int,N}) where {TA,N}
	checkbounds(A, I...)
	for dim=1:N
		@inbounds A.parentinds[dim] = searchsortedfirst(A.axesranges[dim],I[dim])
	end
	@inbounds A.parent[A.parentinds...] = val
	val
end

function Base.setindex!(A::PiecewiseSplicedArray{TA,N},val,i::Int) where {TA,N}
	checkbounds(A, i)
	@inbounds A.parent[i] = val
	val
end

Base.print_array(io::IO,A::PiecewiseSplicedArray) = Base.print_array(io,A.parent)

end
