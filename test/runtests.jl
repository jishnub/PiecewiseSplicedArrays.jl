using Test,PiecewiseSplicedArrays,PiecewiseIncreasingRanges

@testset "initialization and indexing" begin
	ax = PiecewiseIncreasingRange([1:3,6:7]);
	a = zeros(5,5)
	psa = PiecewiseSplicedArray(a,ax,ax);
	@test parent(psa) === a
	for i in eachindex(psa)
       psa[i]=i
       @test psa[i]==i
    end
    @test PiecewiseSplicedArrays.parentinds(psa,(2,6)) == (2,4)

    b=@view psa[1:3,6:7];
    @. b= 99
    @test psa[3,6] == 99
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
