# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "../../tk_test_helper"

# Tests for Tk::Img::PS - PostScript image format support
# Requires: Ghostscript (gs/gswin64c) must be installed
#   Linux/macOS: apt install ghostscript / brew install ghostscript
#   Windows: pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-ghostscript
#            Note: MSYS2 installs as 'gs' but Tcl expects 'gswin64c.exe'.
#            Create symlink (run in admin shell):
#              ln -s /c/Ruby40-x64/msys64/ucrt64/bin/gs.exe /c/Ruby40-x64/msys64/ucrt64/bin/gswin64c.exe
# Generate with: magick sample.png sample.ps
class TestTkImgPs < Minitest::Test
  include TkTestHelper

  def test_ps_package
    assert_tk_app("TkImg PS package test", method(:ps_app))
  end

  def ps_app
    require "tk"
    require "tkextlib/tkimg/ps"

    errors = []

    errors << "package_name mismatch" unless Tk::Img::PS.package_name == "img::ps"

    version = Tk::Img::PS.package_version
    errors << "package_version is empty" if version.nil? || version.empty?

    fixture_path = File.expand_path("test/fixtures/sample.ps")
    begin
      img = TkPhotoImage.new(file: fixture_path, format: "ps")
      errors << "image width should be > 0" unless img.width > 0
      errors << "image height should be > 0" unless img.height > 0
    rescue => e
      errors << "Failed to load PS image: #{e.message}"
    end

    raise "Failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
