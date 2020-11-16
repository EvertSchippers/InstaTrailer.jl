######### IMU DATA #############

const ImuDataType = TrailerType{0x300}

struct ImuData
    milliseconds::UInt64
    accelerationX::Float64
    accelerationY::Float64
    accelerationZ::Float64
    angularvelocityX::Float64
    angularvelocityY::Float64
    angularvelocityZ::Float64
end

export ImuData, ImuDataType, read_imu

read_data(::Type{ImuDataType}, io::IO, number_of_bytes::Integer) = read_samples(ImuData, io, number_of_bytes)

"""
    read_imu(insv_file::AbstractString)

Reads the raw IMU data from an Insta360 INSV or INSP file.
"""
function read_imu(insv_file::AbstractString)
    records = open(insv_file) do io
        extract_trailers(io)
    end
    return records[ImuDataType]
end

######### EXPOSURE/TIME DATA #############

const ExposureDataType = TrailerType{0x400}

struct ExposureData
    milliseconds::UInt64
    exposure::Float64
end

export ExposureData, ExposureDataType, read_exposure

read_data(::Type{ExposureDataType}, io::IO, number_of_bytes::Integer) = read_samples(ExposureData, io, number_of_bytes)

"""
    read_imu(insv_file::AbstractString)

Reads the timestamps and exposure for the frames in an Insta360 INSV file.
"""
function read_exposure(insv_file::AbstractString)
    records = open(insv_file) do io
        extract_trailers(io)
    end

    return records[ExposureDataType]
end


########## MAKER NOTES #####################

const MakerNotesDataType = TrailerType{0x101}

export MakerNotes, MakerNotesDataType

struct MakerNotes
    MakerNotes(raw::Dict{UInt8, Vector{UInt8}}) = new(
        String(raw[0x0a]),
        String(raw[0x12]),
        String(raw[0x1a]),
        String.(split(String(raw[0x2a]), '_'))
    )

    serial_number::String
    model::String
    firmware::String
    parameters::Vector{String}
end

function read_data(::Type{MakerNotesDataType}, io::IO, number_of_bytes::Integer) 
    notes = MakerNotes( read_notes(io, 4, number_of_bytes) )
    return notes
end
