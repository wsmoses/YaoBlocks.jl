using Test, YaoBlocks, YaoArrayRegister

struct MockedTag{BT, N} <: TagBlock{BT, N}
    content::BT

    MockedTag(x::BT) where {N, BT <: AbstractBlock{N}} = new{BT, N}(x)
end

@test nqubits(MockedTag(X)) == nqubits(X)
@test nqubits(MockedTag(kron(X, Y))) == nqubits(kron(X, Y))

@test getiparams(MockedTag(phase(0.1))) == ()
@test getiparams(MockedTag(cache(phase(0.1)))) == ()
@test getiparams(MockedTag(Rx(0.1))) == ()

@test parameters(MockedTag(phase(0.1))) == [0.1]
@test parameters(MockedTag(cache(phase(0.1)))) == [0.1]
@test parameters(MockedTag(Rx(0.1))) == [0.1]

@test occupied_locs(MockedTag(chain(3, put(1=>X), put(3=>X)))) == occupied_locs(chain(3, put(1=>X), put(3=>X)))

@testset "scale apply" begin
    # factor
    @test factor(-X) == -1
    @test factor(-2*X) == -2

    # type
    @test -X isa Scale{<:Val}
    @test -im*X isa Scale{<:Val}
    @test -2*X isa Scale{<:Number}

    # apply!
    reg = rand_state(1)
    @test apply!(copy(reg), -X) ≈ -apply!(copy(reg), X)
    @test apply!(copy(reg), (-im*Y)') ≈ apply!(copy(reg), im*Y)
    @test apply!(copy(reg), (-2im*Y)') ≈ apply!(copy(reg), 2im*Y)

    # mat
    @test mat(-X) ≈ -mat(X)
    @test mat((-im*Y)') ≈ (-im*mat(Y))'
    @test mat((-2im*Y)') ≈ (-2im*mat(Y))'

    # other
    @test chsubblocks(-X, Y) == -Y
    @test cache_key(Scale(Val(-1), X)) == cache_key(Scale(-1, X))
    @test copy(-X) == -X
    @test copy(-X) isa Scale{<:Val}
end
