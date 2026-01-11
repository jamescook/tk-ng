# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../tk_test_helper"

# Tests for Tk::Img::PNG - PNG image format support
# Requires tkimg extension (libtk-img on Ubuntu, build from source on macOS)
class TestTkImgPng < Minitest::Test
  include TkTestHelper

  def test_png_package
    # Pass fixture path to subprocess via env var
    ENV["TEST_FIXTURE_PNG"] = File.join(FIXTURES_PATH, "sample.png")
    assert_tk_app("TkImg PNG package test", method(:png_app))
  end

  def png_app
    require "tk"
    require "tkextlib/tkimg/png"

    errors = []

    # Test package info
    errors << "package_name mismatch" unless Tk::Img::PNG.package_name == "img::png"

    version = Tk::Img::PNG.package_version
    errors << "package_version is empty" if version.nil? || version.empty?

    # Test loading a real PNG file (path passed via env var)
    fixture_path = ENV["TEST_FIXTURE_PNG"]
    begin
      img = TkPhotoImage.new(file: fixture_path, format: "png")
      errors << "image width should be > 0" unless img.width > 0
      errors << "image height should be > 0" unless img.height > 0
    rescue => e
      errors << "Failed to load PNG image: #{e.message}"
    end

    raise "Failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
