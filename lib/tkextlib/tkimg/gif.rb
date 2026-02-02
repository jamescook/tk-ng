# frozen_string_literal: false
#
#  TkImg - format 'gif'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::gif', '1.3')
TkPackage.require('img::gif')

module Tk
  module Img
    # GIF image format support for TkPhotoImage.
    #
    # Adds write support for GIF format. Tk has built-in GIF read support,
    # but this package enables saving images as GIF.
    #
    # @example Loading a GIF image
    #   require 'tkextlib/tkimg/gif'
    #   image = TkPhotoImage.new(file: 'animation.gif')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as GIF
    #   image.write('output.gif', format: 'gif')
    module GIF
      PACKAGE_NAME = 'img::gif'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::gif')
        rescue
          ''
        end
      end
    end
  end
end
