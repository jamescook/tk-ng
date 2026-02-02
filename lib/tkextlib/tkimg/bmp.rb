# frozen_string_literal: false
#
#  TkImg - format 'bmp'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

#TkPackage.require('img::bmp', '1.3')
TkPackage.require('img::bmp')

module Tk
  module Img
    # BMP (Windows Bitmap) image format support for TkPhotoImage.
    #
    # @example Loading a BMP image
    #   require 'tkextlib/tkimg/bmp'
    #   image = TkPhotoImage.new(file: 'image.bmp')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as BMP
    #   image.write('output.bmp', format: 'bmp')
    module BMP
      PACKAGE_NAME = 'img::bmp'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::bmp')
        rescue
          ''
        end
      end
    end
  end
end
