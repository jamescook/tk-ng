# frozen_string_literal: false
#
#  tkextlib/bwidget/bitmap.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'
require 'tk/image'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Access BWidget's built-in bitmap images.
    #
    # Bitmap retrieves predefined bitmap images included with BWidget.
    #
    # @example Using a BWidget bitmap
    #   require 'tkextlib/bwidget'
    #   bmp = Tk::BWidget::Bitmap.new('folder')
    #   TkLabel.new(root, image: bmp).pack
    class Bitmap < TkPhotoImage
    end
  end
end

class Tk::BWidget::Bitmap
  def initialize(name)
    @path = tk_call_without_enc('Bitmap::get', name)
    Tk_IMGTBL[@path] = self
  end
end
