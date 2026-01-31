# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestPhotoPutBlock < Minitest::Test
  include TkTestHelper

  def test_put_block_basic
    assert_tk_app("TkPhotoImage#put_block basic", method(:put_block_basic_app))
  end

  def put_block_basic_app
    require 'tk'

    # Create a 10x10 photo image
    img = TkPhotoImage.new(width: 10, height: 10)

    # Create RGBA data for solid red (10x10 = 100 pixels)
    red_pixel = [255, 0, 0, 255].pack('CCCC')
    rgba_data = red_pixel * 100

    # Write pixels
    img.put_block(rgba_data, 10, 10)

    # Verify a pixel
    pixel = img.get(5, 5)
    raise "Expected red pixel, got #{pixel.inspect}" unless pixel == [255, 0, 0]

    img.delete
  end

  def test_put_block_with_offset
    assert_tk_app("TkPhotoImage#put_block with offset", method(:put_block_offset_app))
  end

  def put_block_offset_app
    require 'tk'

    # Create a 20x20 photo image, fill with black first
    img = TkPhotoImage.new(width: 20, height: 20)
    black_data = ([0, 0, 0, 255].pack('CCCC')) * 400
    img.put_block(black_data, 20, 20)

    # Write a 5x5 green block at offset (10, 10)
    green_pixel = [0, 255, 0, 255].pack('CCCC')
    green_data = green_pixel * 25
    img.put_block(green_data, 5, 5, x: 10, y: 10)

    # Verify black pixel outside the green block
    pixel_black = img.get(5, 5)
    raise "Expected black at (5,5), got #{pixel_black.inspect}" unless pixel_black == [0, 0, 0]

    # Verify green pixel inside the block
    pixel_green = img.get(12, 12)
    raise "Expected green at (12,12), got #{pixel_green.inspect}" unless pixel_green == [0, 255, 0]

    img.delete
  end

  def test_put_block_size_validation
    assert_tk_app("TkPhotoImage#put_block size validation", method(:put_block_validation_app))
  end

  def put_block_validation_app
    require 'tk'

    img = TkPhotoImage.new(width: 10, height: 10)

    # Wrong data size should raise
    begin
      img.put_block("too short", 10, 10)
      raise "Should have raised ArgumentError for wrong data size"
    rescue ArgumentError => e
      raise "Wrong error message" unless e.message.include?("size mismatch")
    end

    # Zero dimensions should raise
    begin
      img.put_block("", 0, 10)
      raise "Should have raised ArgumentError for zero width"
    rescue ArgumentError => e
      raise "Wrong error message" unless e.message.include?("positive")
    end

    img.delete
  end

  def test_put_block_transparency
    assert_tk_app("TkPhotoImage#put_block transparency", method(:put_block_transparency_app))
  end

  def put_block_transparency_app
    require 'tk'

    img = TkPhotoImage.new(width: 10, height: 10)

    # Create fully transparent pixel
    transparent_pixel = [255, 0, 0, 0].pack('CCCC')  # Red but fully transparent
    rgba_data = transparent_pixel * 100

    img.put_block(rgba_data, 10, 10)

    # Verify the pixel is transparent
    raise "Expected transparent pixel" unless img.get_transparency(5, 5)

    img.delete
  end

  def test_put_zoomed_block_basic
    assert_tk_app("TkPhotoImage#put_zoomed_block basic", method(:put_zoomed_block_basic_app))
  end

  def put_zoomed_block_basic_app
    require 'tk'

    # Create a 30x30 destination image (will hold 10x10 zoomed 3x)
    img = TkPhotoImage.new(width: 30, height: 30)

    # Create 10x10 red source image
    red_pixel = [255, 0, 0, 255].pack('CCCC')
    rgba_data = red_pixel * 100

    # Write with 3x zoom
    img.put_zoomed_block(rgba_data, 10, 10, zoom_x: 3, zoom_y: 3)

    # Verify pixels at various positions (all should be red due to zoom)
    [[0, 0], [15, 15], [29, 29]].each do |x, y|
      pixel = img.get(x, y)
      raise "Expected red at (#{x},#{y}), got #{pixel.inspect}" unless pixel == [255, 0, 0]
    end

    img.delete
  end

  def test_get_image_basic
    assert_tk_app("TkPhotoImage#get_image basic", method(:get_image_basic_app))
  end

  def get_image_basic_app
    require 'tk'

    # Create a 10x10 photo image and fill with red
    img = TkPhotoImage.new(width: 10, height: 10)
    red_pixel = [255, 0, 0, 255].pack('CCCC')
    rgba_data = red_pixel * 100
    img.put_block(rgba_data, 10, 10)

    # Read pixels back
    result = img.get_image
    raise "Expected hash result" unless result.is_a?(Hash)
    raise "Expected width 10, got #{result[:width]}" unless result[:width] == 10
    raise "Expected height 10, got #{result[:height]}" unless result[:height] == 10
    raise "Expected #{100 * 4} bytes, got #{result[:data].bytesize}" unless result[:data].bytesize == 400

    # Verify first pixel is red
    r, g, b, a = result[:data][0, 4].unpack('CCCC')
    raise "Expected red pixel, got [#{r},#{g},#{b},#{a}]" unless r == 255 && g == 0 && b == 0 && a == 255

    img.delete
  end

  def test_get_image_unpack
    assert_tk_app("TkPhotoImage#get_image unpack", method(:get_image_unpack_app))
  end

  def get_image_unpack_app
    require 'tk'

    # Create a 3x2 photo image with known colors
    img = TkPhotoImage.new(width: 3, height: 2)

    # Row 1: red, green, blue
    # Row 2: white, black, transparent
    pixels = [
      255, 0, 0, 255,     # red
      0, 255, 0, 255,     # green
      0, 0, 255, 255,     # blue
      255, 255, 255, 255, # white
      0, 0, 0, 255,       # black
      128, 128, 128, 128  # gray semi-transparent
    ]
    rgba_data = pixels.pack('C*')
    img.put_block(rgba_data, 3, 2)

    # Read back with unpack: true
    result = img.get_image(unpack: true)
    raise "Expected :pixels key" unless result.key?(:pixels)
    raise "Should not have :data key" if result.key?(:data)
    raise "Expected array" unless result[:pixels].is_a?(Array)
    raise "Expected #{24} values, got #{result[:pixels].size}" unless result[:pixels].size == 24

    # Verify first pixel is red
    r, g, b, a = result[:pixels][0, 4]
    raise "Expected red [255,0,0,255], got [#{r},#{g},#{b},#{a}]" unless [r, g, b, a] == [255, 0, 0, 255]

    # Verify second pixel is green
    r, g, b, a = result[:pixels][4, 4]
    raise "Expected green [0,255,0,255], got [#{r},#{g},#{b},#{a}]" unless [r, g, b, a] == [0, 255, 0, 255]

    # Test each_slice usage
    pixel_tuples = result[:pixels].each_slice(4).to_a
    raise "Expected 6 pixel tuples" unless pixel_tuples.size == 6
    raise "Third pixel should be blue" unless pixel_tuples[2] == [0, 0, 255, 255]

    img.delete
  end

  def test_get_image_region
    assert_tk_app("TkPhotoImage#get_image region", method(:get_image_region_app))
  end

  def get_image_region_app
    require 'tk'

    # Create 20x20 image with different colors in quadrants
    img = TkPhotoImage.new(width: 20, height: 20)

    # Fill with black first
    black_data = ([0, 0, 0, 255].pack('CCCC')) * 400
    img.put_block(black_data, 20, 20)

    # Put green in bottom-right 10x10 quadrant
    green_pixel = [0, 255, 0, 255].pack('CCCC')
    green_data = green_pixel * 100
    img.put_block(green_data, 10, 10, x: 10, y: 10)

    # Read just the green quadrant
    result = img.get_image(x: 10, y: 10, width: 10, height: 10)
    raise "Expected width 10" unless result[:width] == 10
    raise "Expected height 10" unless result[:height] == 10

    # All pixels should be green
    r, g, b, a = result[:data][0, 4].unpack('CCCC')
    raise "Expected green pixel, got [#{r},#{g},#{b},#{a}]" unless r == 0 && g == 255 && b == 0 && a == 255

    # Read just the black quadrant (top-left)
    result = img.get_image(x: 0, y: 0, width: 10, height: 10)
    r, g, b, a = result[:data][0, 4].unpack('CCCC')
    raise "Expected black pixel, got [#{r},#{g},#{b},#{a}]" unless r == 0 && g == 0 && b == 0 && a == 255

    img.delete
  end

  def test_get_size
    assert_tk_app("TkPhotoImage#get_size", method(:get_size_app))
  end

  def get_size_app
    require 'tk'

    # Create images of various sizes
    [[10, 10], [100, 50], [1, 200]].each do |w, h|
      img = TkPhotoImage.new(width: w, height: h)
      size = img.get_size
      raise "Expected [#{w}, #{h}], got #{size.inspect}" unless size == [w, h]
      img.delete
    end
  end

  def test_blank
    assert_tk_app("TkPhotoImage#blank", method(:blank_app))
  end

  def blank_app
    require 'tk'

    # Create a 10x10 image and fill with red
    img = TkPhotoImage.new(width: 10, height: 10)
    red_pixel = [255, 0, 0, 255].pack('CCCC')
    rgba_data = red_pixel * 100
    img.put_block(rgba_data, 10, 10)

    # Verify pixel is red
    pixel = img.get(5, 5)
    raise "Expected red before blank, got #{pixel.inspect}" unless pixel == [255, 0, 0]

    # Blank the image
    result = img.blank
    raise "Expected self returned" unless result == img

    # After blank, pixel should be transparent (get returns empty or default)
    # The get method returns [0,0,0] for transparent/blank pixels
    pixel_after = img.get(5, 5)
    raise "Expected black/transparent after blank, got #{pixel_after.inspect}" unless pixel_after == [0, 0, 0]

    # Also verify transparency
    raise "Expected pixel to be transparent after blank" unless img.get_transparency(5, 5)

    img.delete
  end
end
