# frozen_string_literal: false
#
#  TkImg - format 'ppm'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::ppm', '1.3')
TkPackage.require('img::ppm')

module Tk
  module Img
    # PPM/PGM/PBM (Portable Pixmap) image format support for TkPhotoImage.
    #
    # Tk has built-in PPM support; this package adds additional options.
    #
    # @example Loading a PPM image
    #   require 'tkextlib/tkimg/ppm'
    #   image = TkPhotoImage.new(file: 'image.ppm')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as PPM
    #   image.write('output.ppm', format: 'ppm')
    module PPM
      PACKAGE_NAME = 'img::ppm'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::ppm')
        rescue
          ''
        end
      end
    end
  end
end
