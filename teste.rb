require 'av_capture'
require 'phashion'
require 'opencv'
# require 'vips'
require "RMagick"
require "byebug"
# require "imgkit"

# session = AVCapture::Session.new
# dev     = AVCapture.devices.find(&:video?)

# p dev.name
# p dev.video?

# session.run_with(dev) do |connection|
#   sleep 4
#   File.open("scan.jpg", 'wb') { |f|
#     f.write connection.capture
#   }
# end

height = 441
width = 312

def distance a, b
  Math.sqrt(((a.x - b.x) ** 2) + ((a.y - b.y) ** 2))
end
# probably a better way, but care =~ 0
def clockwise points
  ul = Struct.new(:x, :y).new 0, 0
  upper_left = points.min_by { |point| distance point, ul }
  until points.first == upper_left
    points = points.rotate
  end
  points
end

include Magick
include OpenCV
