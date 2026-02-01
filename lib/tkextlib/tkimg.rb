# frozen_string_literal: false
#
#  TkImg extension support
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# load all image format handlers
#TkPackage.require('Img', '1.3')
TkPackage.require('Img')

module Tk
  # Additional image format support for Tk.
  #
  # The Img package adds support for many image formats beyond Tk's
  # built-in GIF and PPM support. After requiring this package,
  # TkPhotoImage can load these formats automatically.
  #
  # ## Supported Formats
  #
  # - BMP, ICO (Windows formats)
  # - JPEG, PNG, TIFF
  # - XBM, XPM (X11 formats)
  # - TGA, PCX, PPM
  # - PostScript/PDF (read-only)
  # - Sun raster, SGI native
  #
  # ## Installation
  #
  # - ActiveTcl: included
  # - Homebrew: `brew install tcl-tk` (includes Img)
  # - Debian/Ubuntu: `apt install libtk-img`
  #
  # @example Loading a JPEG image
  #   require 'tkextlib/tkimg'
  #
  #   image = TkPhotoImage.new(file: 'photo.jpg')
  #   label = TkLabel.new(image: image)
  #   label.pack
  #
  # @example Converting formats
  #   image = TkPhotoImage.new(file: 'input.bmp')
  #   image.write('output.png', format: 'PNG')
  #
  # @note Modern Tk 8.6+ includes native PNG support. You only need
  #   this package for JPEG, TIFF, BMP, and other formats.
  #
  # @see https://wiki.tcl-lang.org/page/Img Tcl Wiki: Img package
  module Img
    PACKAGE_NAME = 'Img'.freeze
    def self.package_name
      PACKAGE_NAME
    end

    def self.package_version
      begin
        TkPackage.require('Img')
      rescue
        ''
      end
    end
  end
end

# autoload
autoload :TkPixmapImage, 'tkextlib/tkimg/pixmap'
