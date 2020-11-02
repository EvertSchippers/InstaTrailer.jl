using InstaTrailer
using Test

include("Utilities.jl")

@testset "Example Trailer" begin
     
     # Example files are the genuine end-parts of INSV files. Video is cut off, 100 random bytes prepended.

     example_file = joinpath("examples", "trailer_only_file.insv.partial")

     records = open(example_file , "r") do io 
          extract_trailers(io)
     end

     @test TrailerType{0x0101} in keys(records)
     #  UInt16[0x0101, 0x0200, 0x0300, 0x0400, 0x0500]

     @test eltype(records[TrailerType{0x300}]) == ImuData
     @test eltype(records[TrailerType{0x400}]) == ExposureData

     @test length(records[TrailerType{0x300}]) == 1548
     @test length(records[TrailerType{0x400}]) == 97
     
end
