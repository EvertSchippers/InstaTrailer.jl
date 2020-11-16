using InstaTrailer
using Test

include("Utilities.jl")

@testset "Example Trailer" begin
     
     # Example files are the genuine end-parts of INSV files. Video is cut off, 100 random bytes prepended.

     example_file = joinpath("examples", "trailer_only_file.insv.partial")

     records = open(example_file , "r") do io 
          extract_trailers(io)
     end

     @test eltype(records[ImuDataType]) == ImuData
     @test eltype(records[ExposureDataType]) == ExposureData

     @test length(records[ImuDataType]) == 1548
     @test length(records[ExposureDataType]) == 97
     
     notes = records[MakerNotesDataType]
     @test notes isa MakerNotes
     @test notes.serial_number == "4267CGD3E15FAB"
     @test notes.model == "Insta360 EVO"
     @test notes.firmware == "v1.3.1_build1"
     @test length(notes.parameters) == 16

end
