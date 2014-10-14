require 'av_capture'
require 'phashion'
require 'opencv'
# require 'vips'
require "RMagick"
require "byebug"
# require "imgkit"

session = AVCapture::Session.new
dev     = AVCapture.devices.find(&:video?)

p dev.name
p dev.video?

session.run_with(dev) do |connection|
  sleep 4
  File.open("scan.jpg", 'wb') { |f|
    f.write connection.capture
  }
end
