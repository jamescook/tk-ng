# frozen_string_literal: false
#
#  TkImg - format 'xbm'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::xbm', '1.3')
TkPackage.require('img::xbm')

module Tk
  module Img
    # XBM (X BitMap) image format support for TkPhotoImage.
    #
    # XBM is a monochrome bitmap format used in X11.
    #
    # @example Loading an XBM image
    #   require 'tkextlib/tkimg/xbm'
    #   image = TkPhotoImage.new(file: 'cursor.xbm')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as XBM
    #   image.write('output.xbm', format: 'xbm')
    module XBM
      PACKAGE_NAME = 'img::xbm'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::xbm')
        rescue
          ''
        end
      end
    end
  end
end
