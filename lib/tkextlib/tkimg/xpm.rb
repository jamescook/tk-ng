# frozen_string_literal: false
#
#  TkImg - format 'xpm'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::xpm', '1.3')
TkPackage.require('img::xpm')

module Tk
  module Img
    # XPM (X PixMap) image format support for TkPhotoImage.
    #
    # XPM is a text-based image format common in X11 applications.
    #
    # @example Loading an XPM image
    #   require 'tkextlib/tkimg/xpm'
    #   image = TkPhotoImage.new(file: 'icon.xpm')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as XPM
    #   image.write('output.xpm', format: 'xpm')
    module XPM
      PACKAGE_NAME = 'img::xpm'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::xpm')
        rescue
          ''
        end
      end
    end
  end
end
