# frozen_string_literal: false
#
#  TkImg - format 'png'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::png', '1.3')
TkPackage.require('img::png')

module Tk
  module Img
    # PNG image format support for TkPhotoImage.
    #
    # @note Tk 8.6+ includes native PNG support; this package adds
    #   additional options like compression level.
    #
    # @example Loading a PNG image
    #   require 'tkextlib/tkimg/png'
    #   image = TkPhotoImage.new(file: 'icon.png')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as PNG
    #   image.write('output.png', format: 'png')
    module PNG
      PACKAGE_NAME = 'img::png'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::png')
        rescue
          ''
        end
      end
    end
  end
end
