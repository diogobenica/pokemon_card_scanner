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

original = cv::imread("logo.png")


original = CvMat.load("TRAPEZIO.jpg", CV_LOAD_IMAGE_COLOR)
trapezio = OpenCV.BGR2GRAY CvMat.load("TRAPEZIO.jpg", CV_LOAD_IMAGE_COLOR)
trapezio = trapezio.canny 100, 100
contour_node = trapezio.find_contours(:mode => OpenCV::CV_RETR_TREE, :method => OpenCV::CV_CHAIN_APPROX_SIMPLE)
original.draw_contours!(contour_node, CvColor::Blue, CvColor::Red, 0, nil)

lines = trapezio.hough_lines(:probabilistic, 1, Math::PI/180, 70, 30, 10)

def compute_intersect(a, b)
  x1, y1, x2, y2 = a[0], a[1], a[2], a[3]
  x3, y3, x4, y4 = b[0], b[1], b[2], b[3]

  if d = ((x1-x2) * (y3-y4)) - ((y1-y2) * (x3-x4))
    point = CvPoint.new
    point.x = ((x1*y2 - y1*x2) * (x3-x4) - (x1-x2) * (x3*y4 - y3*x4)) / d
    point.y = ((x1*y2 - y1*x2) * (y3-y4) - (y1-y2) * (x3*y4 - y3*x4)) / d
    point
  else
    point = CvPoint.new(-1, -1)
  end
end

corners = []
byebug
lines.size.times do |i|
  lines.size.times do |j|
    point = compute_intersect(lines[i], lines[j])
    if point.x >= 0 and point.y >= 0
      corners.push point
    end
  end
end

corners.reverse!

byebug

# Pontos em retângulo
contour_node.min_area_rect2.points

window = GUI::Window.new('Display window') # Create a window for display.
window.show(original) # Show our image inside it.
GUI::wait_key # Wait for a keystroke in the window.

byebug

img = CvMat.load("deitado.jpg", CV_LOAD_IMAGE_COLOR)
bw_img = OpenCV.BGR2GRAY CvMat.load("deitado.jpg", CV_LOAD_IMAGE_COLOR)
bw_img = bw_img.canny 100, 100
contours = []
contour_node = bw_img.find_contours(:mode => OpenCV::CV_RETR_TREE, :method => OpenCV::CV_CHAIN_APPROX_SIMPLE)

while contour_node
  unless contour_node.hole?
    contours << contour_node
  end
  contour_node = contour_node.h_next
end

max = contours.max_by { |c| c.contour_area }
return unless max
# return unless max.contour_area > 10_000
peri = max.arc_length
approx = max.approx_poly(:method => :dp, :recursive => true, :accuracy => 0.02 * peri)
x = approx.convex_hull2.rect.points
return unless x.length == 4
clockwise_points = clockwise x.reverse
top_length = distance clockwise_points[0], clockwise_points[1]
side_length = distance clockwise_points[0], clockwise_points[3]
points = nil
unless top_length > side_length
  points = clockwise_points.map { |point|
    OpenCV::CvPoint2D32f.new(point)
  }
end

to = [
  OpenCV::CvPoint2D32f.new(0, 0),
  OpenCV::CvPoint2D32f.new(width, 0),
  OpenCV::CvPoint2D32f.new(width, height),
  OpenCV::CvPoint2D32f.new(0, height),
]
