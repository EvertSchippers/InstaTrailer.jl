@testset "Utilities" begin

    bytes = collect(rand(UInt8, 100))
    magic = bytes[42:62]
    
    @test InstaTrailer.find_index(bytes, magic) == 42

end