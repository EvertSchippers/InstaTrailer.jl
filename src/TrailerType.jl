
abstract type TrailerType{T} end

export TrailerType

function read_data(::Type{T}, io::IO, number_of_bytes::Integer) where T <: TrailerType
    # By default, just read the raw bytes.
    return read(io, number_of_bytes)
end
