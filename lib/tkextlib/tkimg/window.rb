# frozen_string_literal: false
#
#  TkImg - format 'window'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::window', '1.3')
TkPackage.require('img::window')

module Tk
  module Img
    # Window capture format - captures Tk windows as images.
    #
    # Allows capturing the contents of a Tk window into a TkPhotoImage.
    #
    # @example Capturing a window
    #   require 'tkextlib/tkimg/window'
    #   image = TkPhotoImage.new
    #   image.copy(window, format: 'window')
    module WINDOW
      PACKAGE_NAME = 'img::window'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::window')
        rescue
          ''
        end
      end
    end
  end
end
