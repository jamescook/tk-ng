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
end
