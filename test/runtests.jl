using Test,PiecewiseSplicedArrays,PiecewiseIncreasingRanges

@testset "initialization and indexing" begin
	ax = PiecewiseIncreasingRange([1:3,6:7]);
	psa = PiecewiseSplicedArray(zeros(5,5),ax,ax);
	for i in eachindex(psa)
       psa[i]=i
       @test psa[i]==i
    end
end

@testset "size and axes" begin
	ax = PiecewiseIncreasingRange([1:3,6:7]);
	psa = PiecewiseSplicedArray(zeros(5,5),ax,ax);
	for d in 1:ndims(psa)
		@test axes(psa,d)==ax
	end
	@test length(psa)==25
	@test size(psa)==(5,5)
end
