# InstaTrailer.jl

Reads the special meta-data in Insta360 "INSV" and "INSP" files.

Inspired by https://github.com/exiftool/exiftool, but without the memory limitations.

Very special thanks to Phil Harvey (https://github.com/boardhead) for the reverse engineering!

"Fun fact": if you didn't know yet, *.insv files are just *.mp4 files with an extra trailer. So, tools like FFMPEG will just extract the raw frames for you.

And *.insp files are readable as *.jpg files, again, with an extra trailer bit.

```
using InstaTrailer

# to read all trailer data (even unknown types as raw byte data)
records = open("VID_20200929_095645_00_186.insv") do io
            extract_trailers(io)
          end

# to just read imu data:
imu = read_imu("VID_20200929_095645_00_186.insv")

# also from image data:
imu = read_imu("IMG_20200322_162224_00_173.insp")

# and the exposure/time for all video frames (so you can relate the imu):
exposure = read_exposure("VID_20200929_095645_00_186.insv")
```

Check out `lib\Image\ExifTool\QuickTimeStream.pl` in the ExifTool repository to figure out how to decode other meta data types, like I did for `ImuData` and `ExposureData`.

Contribute another section in this repo's `src/DataTypes.jl`, or, if you don't feel like sharing, just overload `InstaTrailer.read_data` for the `TrailerType{0x???}` you want to decode, and `extract_trailers` will also decode that type.

## TODO ##
More documentation!

More data types, besides IMU and Exposure. Calibration parameters are up next!