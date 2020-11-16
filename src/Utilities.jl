"""
    find_index(bytes::AbstractVector, magic_bytes::AbstractVector)

Finds the index where a string of "magic" bytes occurs in a larger series of bytes. Returns -1 if the magic string cannot be found.

Example:
```@jldoctest
bytes = rand(UInt8, 100)
magic = bytes[42:50]
find_index(bytes, magic)
output:
42
```
"""
function find_index(bytes::AbstractVector, magic_bytes::AbstractVector)

    i_magic = 1
    
    for i_bytes in 1:length(bytes)
        
        if bytes[i_bytes] == magic_bytes[i_magic]
            i_magic += 1
        else
            i_magic = 1
        end

        if i_magic > length(magic_bytes)
            return i_bytes - length(magic_bytes) + 1
        end
    end

    return -1
end

"""
    read_samples(::Type{T}, io::IO, number_of_bytes::Integer) where T

Reads `number_of_bytes` bytes from `io` and reinterprets them as elements of `T`.
"""
function read_samples(::Type{T}, io::IO, number_of_bytes::Integer) where T
    
    if mod(number_of_bytes, sizeof(T)) != 0 
        throw(InstaTrailerException("Cannot fit a whole number of $(T)'s in trailer."))
    end

    return reinterpret(T, read(io, number_of_bytes))
end

export get_time

"""
    get_time(sample_with_milliseconds::T) where T

Assumes the type `T` has a `milliseconds` field and returns normal seconds based on that value.
"""
function get_time(sample_with_milliseconds::T) where T
    return sample_with_milliseconds.milliseconds / 1000
end

"""
    read_notes(io::IO, number_of_bytes::Integer)

Read a series of byte vectors, which are preceeded by an ID-byte and a vector-lenght-byte. Thus, the vector lengths cannot exceed 255 bytes.
"""
function read_notes(io::IO, number_of_notes::Int, number_of_bytes::Integer)

    result = Dict{UInt8,Vector{UInt8}}()
    max_position = position(io) + number_of_bytes

    while !eof(io) && ((position(io) + 2) < max_position)
       note = read_note(io)
       result[note.first] = note.second
       if length(result) == number_of_notes
            break
       end
    end

    if position(io) > max_position
        throw(InstaTrailerException("Maker notes corrupted. IO-stream overread..."))
    end

    if length(result) != number_of_notes
        throw(InstaTrailerException("Maker notes corrupted. Could not read $(number_of_notes) notes..."))
    end

    # todo: what's this data?
    the_rest = read(io, max_position - position(io))

    return result
end

function read_note(io::IO)::Pair{UInt8, Vector{UInt8}}
    id = read(io, UInt8)
    note_size = read(io, UInt8)
    bytes = read(io, note_size)

    if length(bytes) < note_size
        throw(InstaTrailerException("Read note reached EOF."))
    end

    return id => bytes
end