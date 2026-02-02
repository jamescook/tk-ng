# frozen_string_literal: false
#
#  TkImg - format 'tga'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::tga', '1.3')
TkPackage.require('img::tga')

module Tk
  module Img
    # TGA (Truevision Targa) image format support for TkPhotoImage.
    #
    # @example Loading a TGA image
    #   require 'tkextlib/tkimg/tga'
    #   image = TkPhotoImage.new(file: 'texture.tga')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as TGA
    #   image.write('output.tga', format: 'tga')
    module TGA
      PACKAGE_NAME = 'img::tga'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::tga')
        rescue
          ''
        end
      end
    end
  end
end
