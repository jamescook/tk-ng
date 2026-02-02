# frozen_string_literal: false
#
#  TkImg - format 'sgi'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::sgi', '1.3')
TkPackage.require('img::sgi')

module Tk
  module Img
    # SGI (Silicon Graphics) image format support for TkPhotoImage.
    #
    # @example Loading an SGI image
    #   require 'tkextlib/tkimg/sgi'
    #   image = TkPhotoImage.new(file: 'image.sgi')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as SGI
    #   image.write('output.sgi', format: 'sgi')
    module SGI
      PACKAGE_NAME = 'img::sgi'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::sgi')
        rescue
          ''
        end
      end
    end
  end
end
