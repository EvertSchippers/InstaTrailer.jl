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

export ImuData, read_imu

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

export ExposureData, read_exposure

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
