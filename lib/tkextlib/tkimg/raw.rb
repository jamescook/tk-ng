# frozen_string_literal: false
#
#  TkImg - format 'Raw Data'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::raw', '1.4')
TkPackage.require('img::raw')

module Tk
  module Img
    # Raw pixel data format support for TkPhotoImage.
    #
    # Allows reading/writing images as raw RGB/RGBA pixel data.
    #
    # @example Loading raw pixel data
    #   require 'tkextlib/tkimg/raw'
    #   image = TkPhotoImage.new(file: 'pixels.raw',
    #     format: 'raw -width 100 -height 100')
    module Raw
      PACKAGE_NAME = 'img::raw'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::raw')
        rescue
          ''
        end
      end
    end
  end
end
