module PiecewiseSplicedArrays
using PiecewiseIncreasingRanges,Compat
import Base: tail, @propagate_inbounds

export PiecewiseSplicedArray

struct PiecewiseSplicedArray{TA,N,AA<:AbstractArray,R<:AbstractUnitRange} <: AbstractArray{TA,N}
    parent::AA
    axesranges::NTuple{N,PiecewiseUnitRange{Int,R}}
    function PiecewiseSplicedArray{T,N,AA,R}(a,axesranges) where {T,N,AA<:AbstractArray{T,N},R}
    	checknumberofinds(a,axesranges)
    	new{T,N,AA,R}(a,axesranges)
    end
end

function PiecewiseSplicedArray(a::AbstractVector{TA},
	axesranges::PiecewiseUnitRange{Int,R}) where {TA,R<:AbstractUnitRange}

	PiecewiseSplicedArray{TA,1,typeof(a),R}(a,(axesranges,))
end

function PiecewiseSplicedArray(a::AbstractVector{TA},
	axesranges::Vararg{<:AbstractUnitRange}) where {TA}
	ax = PiecewiseUnitRange([axesranges...])
	PiecewiseSplicedArray{TA,1,typeof(a),R}(a,(ax,))
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},
	axesranges::Vararg{PiecewiseUnitRange{Int,R},N}) where {TA,N,R<:AbstractUnitRange}
	PiecewiseSplicedArray{TA,N,typeof(a),R}(a,axesranges)
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},
	axesranges::NTuple{N,PiecewiseUnitRange{Int,R}}) where {TA,N,R<:AbstractUnitRange}
	axesranges = Tuple(PiecewiseUnitRange.(axesranges))
	PiecewiseSplicedArray{TA,N,typeof(a),R}(a,axesranges)
end

function PiecewiseSplicedArray(a::AbstractArray{TA,N},
	axesranges::Tuple{Vararg{Vector{R},N}}) where {TA,N,R<:AbstractUnitRange}
	ax = Tuple([PiecewiseUnitRange(axesranges[i]) for i in eachindex(axesranges)])
	PiecewiseSplicedArray{TA,N,typeof(a),R}(a,ax)
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
parenttype(::Type{PiecewiseSplicedArray{T,N,AA,R}}) where {T,N,AA,R} = AA
parenttype(A::PiecewiseSplicedArray) = parenttype(typeof(A))

@inline _parentinds(::Tuple{},::Tuple{}) = ()
@inline function _parentinds(ax::NTuple{N,<:PiecewiseUnitRange},inds::NTuple{N,Int}) where {N}
	(searchsortedfirst(ax[1],inds[1]),_parentinds(tail(ax),tail(inds))...)
end
@inline function parentinds(a::PiecewiseSplicedArray{<:Number,N},inds::NTuple{N,Int}) where {N}
	_parentinds(a.axesranges,inds)
end

@inline @propagate_inbounds function Base.getindex(A::PiecewiseSplicedArray{TA,N}, 
	I::Vararg{Int,N}) where {TA,N}

	@boundscheck checkbounds(A, I...)
	@inbounds ret = parent(A)[parentinds(A,I)...]
	ret
end

@inline @propagate_inbounds function Base.getindex(A::PiecewiseSplicedArray, i::Int)
    @boundscheck checkbounds(A, i)
    @inbounds ret = parent(A)[i]
    ret
end

@inline @propagate_inbounds function Base.setindex!(A::PiecewiseSplicedArray{TA,N},val,I::Vararg{Int,N}) where {TA,N}
	@boundscheck checkbounds(A, I...)
	@inbounds parent(A)[parentinds(A,I)...] = val
	val
end

@inline @propagate_inbounds function Base.setindex!(A::PiecewiseSplicedArray{TA,N},val,i::Int) where {TA,N}
	@boundscheck checkbounds(A, i)
	@inbounds parent(A)[i] = val
	val
end

Base.print_array(io::IO,A::PiecewiseSplicedArray) = Base.print_array(io,parent(A))

end
