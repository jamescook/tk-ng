# frozen_string_literal: false
#
#  TkImg - format 'pixmap'
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkimg/setup.rb'

# TkPackage.require('img::pixmap', '1.3')
TkPackage.require('img::pixmap')

module Tk
  module Img
    # Pixmap image format support.
    #
    # Provides TkPixmapImage class for working with pixmap images.
    #
    # @example Creating a pixmap image
    #   require 'tkextlib/tkimg/pixmap'
    #   image = TkPixmapImage.new(file: 'icon.xpm')
    #   TkLabel.new(image: image).pack
    module PIXMAP
      PACKAGE_NAME = 'img::pixmap'.freeze
      def self.package_name
        PACKAGE_NAME
      end

      def self.package_version
        begin
          TkPackage.require('img::pixmap')
        rescue
          ''
        end
      end
    end
  end
end

# Image class for pixmap format.
#
# @example Loading an XPM file
#   image = TkPixmapImage.new(file: 'icon.xpm')
#   TkLabel.new(image: image).pack
class TkPixmapImage < TkImage
  def self.version
    Tk::Img::PIXMAP.version
  end

  def initialize(*args)
    @type = 'pixmap'
    super(*args)
  end
end
