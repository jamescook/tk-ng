# frozen_string_literal: true

# Tests for TkTextImage - images embedded in Text widgets
#
# See: https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTextImage < Minitest::Test
  include TkTestHelper

  def test_create_text_image
    assert_tk_app("TkTextImage create", method(:create_app))
  end

  def create_app
    require 'tk'
    require 'tk/textimage'

    errors = []

    text = TkText.new(root)
    text.pack

    # Create a small photo image
    photo = TkPhotoImage.new(width: 16, height: 16)

    img = TkTextImage.new(text, "1.0", image: photo)
    errors << "should have id" if img.id.nil?
    errors << "should have mark" if img.mark.nil?

    raise errors.join("\n") unless errors.empty?
  end

  def test_create_at_end
    assert_tk_app("TkTextImage at end", method(:end_app))
  end

  def end_app
    require 'tk'
    require 'tk/textimage'

    errors = []

    text = TkText.new(root)
    text.pack
    text.insert(:end, "Hello ")

    photo = TkPhotoImage.new(width: 16, height: 16)
    img = TkTextImage.new(text, :end, image: photo)
    errors << "should create at end" if img.id.nil?

    raise errors.join("\n") unless errors.empty?
  end

  def test_cget_and_configure
    assert_tk_app("TkTextImage cget/configure", method(:config_app))
  end

  def config_app
    require 'tk'
    require 'tk/textimage'

    errors = []

    text = TkText.new(root)
    text.pack

    photo = TkPhotoImage.new(width: 16, height: 16)
    img = TkTextImage.new(text, "1.0", image: photo, padx: 5)

    # cget
    padx = img.cget(:padx)
    errors << "padx should be 5, got '#{padx}'" unless padx.to_i == 5

    # configure
    result = img.configure(:pady, 3)
    errors << "configure should return self" unless result == img

    # [] and []=
    img[:padx] = 10
    errors << "[] should return 10, got '#{img[:padx]}'" unless img[:padx].to_i == 10

    raise errors.join("\n") unless errors.empty?
  end

  def test_image_accessor
    assert_tk_app("TkTextImage image get/set", method(:image_accessor_app))
  end

  def image_accessor_app
    require 'tk'
    require 'tk/textimage'

    errors = []

    text = TkText.new(root)
    text.pack

    photo1 = TkPhotoImage.new(width: 16, height: 16)
    photo2 = TkPhotoImage.new(width: 32, height: 32)

    img = TkTextImage.new(text, "1.0", image: photo1)

    # Get image
    result = img.image
    errors << "image should return the photo" unless result == photo1

    # Set image
    img.image = photo2
    result2 = img.image
    errors << "image should now be photo2" unless result2 == photo2

    raise errors.join("\n") unless errors.empty?
  end

  def test_configinfo
    assert_tk_app("TkTextImage configinfo", method(:configinfo_app))
  end

  def configinfo_app
    require 'tk'
    require 'tk/textimage'

    errors = []

    text = TkText.new(root)
    text.pack

    photo = TkPhotoImage.new(width: 16, height: 16)
    img = TkTextImage.new(text, "1.0", image: photo)

    info = img.configinfo
    errors << "configinfo should return array" unless info.is_a?(Array)

    raise errors.join("\n") unless errors.empty?
  end
end
