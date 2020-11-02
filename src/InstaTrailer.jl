module InstaTrailer

include("Utilities.jl")
include("TrailerType.jl")

include("DataTypes.jl")

export extract_trailers

struct InstaTrailerException <: Exception
    message::String
end

const magic_bytes = UInt8.(collect("8db42d694ccc418790edff439fe026bf"))

"""
    extract_trailers(io::IO)

Extracts all trailers from an INSV file that has trailers.
"""
function extract_trailers(io::IO)

    # Get the index bounds of the trailer part in the file:
    # Notice that the start_index comes after the stop_index as we need to read from end to front.
    trailer_bounds = get_trailer_bounds!(io)

    records = []

    seek(io, trailer_bounds.start_index)

    while position(io) > trailer_bounds.stop_index 
        data = extract_trailer!(io)
        push!(records, data)
    end

    return Dict(records)
end

function extract_trailer!(io::IO)

    current_position = position(io)

    # read id and size:
    id = TrailerType{read(io, UInt16)}
    number_of_bytes = read(io, UInt32)

    # jump back, as the data preceeds the id/size (how convenient!)
    seek(io, current_position - number_of_bytes)

    # read the data for this type
    data = read_data(id, io, number_of_bytes)
    
    # jump back, 6 places more so the next read cycle can start with reading id and size again
    seek(io, current_position - number_of_bytes - 6)

    return id => data
end

function get_trailer_bounds!(io)
  
    # Let's go the the end of the file!
    seekend(io)

    # Position there is the size of the file.
    file_end = position(io)

    # Move 78 bytes back and check for magic:
    start = file_end - 78
    seek(io, start)
    bytes = read(io)

    # Insta360 video file ends with "magic" byte string:
    if find_index(bytes, magic_bytes) != 47
        throw(InstaTrailerException("This file contains no magic!"))
    end
    
    trailer_length = reinterpret(UInt32, bytes[39:42])[1]
    stop_index = file_end - trailer_length + 1

    return (start_index = start, stop_index = stop_index)
end

end # module
