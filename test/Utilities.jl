@testset "Utilities" begin

    bytes = collect(rand(UInt8, 100))
    magic = bytes[42:62]
    
    @test InstaTrailer.find_index(bytes, magic) == 42

    vector = rand(UInt8, 12)
    io = IOBuffer(vcat(0x42, UInt8(length(vector)), vector))

    @test InstaTrailer.read_note(io) == (0x42 => vector)
    @test eof(io)
    
end