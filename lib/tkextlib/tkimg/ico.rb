# frozen_string_literal: false
#
#  TkImg - format 'ico'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::ico', '1.3')
TkPackage.require('img::ico')

module Tk
  module Img
    # ICO (Windows Icon) image format support for TkPhotoImage.
    #
    # @example Loading an ICO image
    #   require 'tkextlib/tkimg/ico'
    #   image = TkPhotoImage.new(file: 'app.ico')
    #   TkLabel.new(image: image).pack
    #
    # @example Saving as ICO
    #   image.write('output.ico', format: 'ico')
    module ICO
      PACKAGE_NAME = 'img::ico'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::ico')
        rescue
          ''
        end
      end
    end
  end
end
