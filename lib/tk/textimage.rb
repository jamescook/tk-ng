# frozen_string_literal: false
#
# tk/textimage.rb - treat Tk text image object
#
require 'tk/text'

# An image embedded within a Text widget.
#
# Embedded images appear inline with text, occupying a single character
# position in the text index. They move with surrounding text as edits
# are made.
#
# @example Inserting an image
#   text = TkText.new(root)
#   photo = TkPhotoImage.new(file: 'icon.png')
#   img = TkTextImage.new(text, "1.0", image: photo)
#
# @example With alignment and padding
#   img = TkTextImage.new(text, :end,
#     image: photo,
#     align: :center,   # top, center, bottom, baseline
#     padx: 5,
#     pady: 2
#   )
#
# @example Accessing the image later
#   img.image           # => TkPhotoImage object
#   img.image = other   # Change the displayed image
#   img.mark            # => TkTextMark tracking position
#
# ## Options
#
# - `:image` - The TkImage to display (required)
# - `:name` - Custom identifier for this image instance
# - `:align` - Vertical alignment: :top, :center, :bottom, :baseline
# - `:padx`, `:pady` - Padding around the image
#
# @note Multiple instances of the same TkImage can be embedded in one
#   Text widget, each with its own position and options.
#
# @note Deleting the text range containing the image removes it from display.
#
# @see TkTextWindow For embedding widgets instead of images
# @see TkPhotoImage For creating images
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm Tcl/Tk text manual
class TkTextImage<TkObject
  include Tk::Text::IndexModMethods

  def initialize(parent, index, keys)
    #unless parent.kind_of?(Tk::Text)
    #  fail ArgumentError, "expect Tk::Text for 1st argument"
    #end
    @t = parent
    if index == 'end' || index == :end
      @path = TkTextMark.new(@t, tk_call(@t.path, 'index', 'end - 1 chars'))
    elsif index.kind_of? TkTextMark
      if tk_call_without_enc(@t.path,'index',index.path) == tk_call_without_enc(@t.path,'index','end')
        @path = TkTextMark.new(@t, tk_call_without_enc(@t.path, 'index',
                                                       'end - 1 chars'))
      else
        @path = TkTextMark.new(@t, tk_call_without_enc(@t.path, 'index',
                                                       index.path))
      end
    else
      @path = TkTextMark.new(@t, tk_call_without_enc(@t.path, 'index',
                                                     _get_eval_enc_str(index)))
    end
    @path.gravity = 'left'
    @index = @path.path
    @id = tk_call_without_enc(@t.path, 'image', 'create', @index,
                              *hash_kv(keys, true)).freeze
    @path.gravity = 'right'
  end

  def id
    Tk::Text::IndexString.new(@id)
  end
  def mark
    @path
  end

  def [](slot)
    cget(slot)
  end
  def []=(slot, value)
    configure(slot, value)
    value
  end

  def cget(slot)
    @t.image_cget(@index, slot)
  end

  def cget_strict(slot)
    @t.image_cget_strict(@index, slot)
  end

  def configure(slot, value=None)
    @t.image_configure(@index, slot, value)
    self
  end
#  def configure(slot, value)
#    tk_call @t.path, 'image', 'configure', @index, "-#{slot}", value
#  end

  def configinfo(slot = nil)
    @t.image_configinfo(@index, slot)
  end

  def current_configinfo(slot = nil)
    @t.current_image_configinfo(@index, slot)
  end

  def image
    img = tk_call_without_enc(@t.path, 'image', 'cget', @index, '-image')
    TkImage::Tk_IMGTBL[img]? TkImage::Tk_IMGTBL[img] : img
  end

  def image=(value)
    tk_call_without_enc(@t.path, 'image', 'configure', @index, '-image',
                        _get_eval_enc_str(value))
    #self
    value
  end
end

TktImage = TkTextImage
