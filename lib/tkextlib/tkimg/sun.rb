# frozen_string_literal: false
#
#  TkImg - format 'sun'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::sun', '1.3')
TkPackage.require('img::sun')

module Tk
  module Img
    # Sun Raster image format support for TkPhotoImage.
    #
    # @example Loading a Sun Raster image
    #   require 'tkextlib/tkimg/sun'
    #   image = TkPhotoImage.new(file: 'image.ras')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as Sun Raster
    #   image.write('output.ras', format: 'sun')
    module SUN
      PACKAGE_NAME = 'img::sun'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::sun')
        rescue
          ''
        end
      end
    end
  end
end
