# frozen_string_literal: false
#
# tk/image.rb : treat Tk image objects
#

require 'tk/option_dsl'
require_relative 'core/callable'
require_relative 'callback'

# Base class for Tk images.
#
# TkImage provides common functionality for bitmap and photo images.
# In most cases, you'll use the subclasses {TkBitmapImage} or {TkPhotoImage}.
#
# @abstract Use {TkBitmapImage} for two-color images or {TkPhotoImage} for
#   full-color images.
#
# @example Querying available image types
#   TkImage.types  # => ["bitmap", "photo"]
#
# @example Listing all images
#   TkImage.names  # => [#<TkPhotoImage:...>, ...]
#
# @see TkBitmapImage For two-color bitmap images
# @see TkPhotoImage For full-color photo images
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/image.htm Tcl/Tk image manual
class TkImage
  include Tk::Core::Callable
  include TkCallback

  TkCommandNames = ['image'.freeze].freeze

  Tk_IMGTBL = TkCore::INTERP.create_table

  (Tk_Image_ID = ['i'.freeze, '00000']).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  TkCore::INTERP.init_ip_env{
    Tk_IMGTBL.mutex.synchronize{ Tk_IMGTBL.clear }
  }

  attr_reader :path

  def self.new(keys=nil)
    if keys.kind_of?(Hash)
      name = nil
      if keys.key?(:imagename)
        name = keys[:imagename]
      elsif keys.key?('imagename')
        name = keys['imagename']
      end
      if name
        if name.kind_of?(TkImage)
          obj = name
        else
          name = if name.respond_to?(:path)
                   name.path
                 elsif name.respond_to?(:to_eval)
                   name.to_eval
                 else
                   name.to_s
                 end
          obj = nil
          Tk_IMGTBL.mutex.synchronize{
            obj = Tk_IMGTBL[name]
          }
        end
        if obj
          if !(keys[:without_creating] || keys['without_creating'])
            keys = keys.transform_keys(&:to_s)
            keys.delete('imagename')
            keys.delete('without_creating')
            obj.instance_eval{
              tk_call('image', 'create',
                      @type, @path, *_image_hash_kv(keys))
            }
          end
          return obj
        end
      end
    end
    (obj = self.allocate).instance_eval{
      Tk_IMGTBL.mutex.synchronize{
        initialize(keys)
        Tk_IMGTBL[@path] = self
      }
    }
    obj
  end

  def initialize(keys=nil)
    @path = nil
    without_creating = false
    if keys.kind_of?(Hash)
      keys = keys.transform_keys(&:to_s)
      @path = keys.delete('imagename')
      without_creating = keys.delete('without_creating')
    end
    unless @path
      Tk_Image_ID.mutex.synchronize{
        @path = Tk_Image_ID.join(TkCore::INTERP._ip_id_)
        Tk_Image_ID[1].succ!
      }
    end
    unless without_creating
      tk_call('image', 'create',
              @type, @path, *_image_hash_kv(keys))
    end
  end

  # Deletes this image and frees associated resources.
  # @return [self]
  def delete
    Tk_IMGTBL.mutex.synchronize{
      Tk_IMGTBL.delete(@id) if @id
    }
    tk_call('image', 'delete', @path)
    self
  end

  # Returns the image height in pixels.
  # @return [Integer]
  def height
    tk_call('image', 'height', @path).to_i
  end

  # Returns whether this image is currently displayed by any widget.
  # @return [Boolean]
  def inuse
    tk_call('image', 'inuse', @path) == '1'
  end

  # Get a configuration option value.
  # @param option [Symbol, String] Option name
  # @return [String] The option value
  def cget(option)
    tk_send('cget', "-#{option}")
  end

  # Configure one or more options.
  # @param keys [Hash] Option name/value pairs
  # @return [self]
  def configure(keys = {})
    tk_send('configure', *_image_hash_kv(keys.transform_keys(&:to_s)))
    self
  end

  # Hash-style option access (for compatibility)
  def [](key)
    cget(key)
  end

  def []=(key, val)
    configure(key.to_s => val)
    val
  end

  # Returns the image type ("bitmap" or "photo").
  # @return [String]
  def itemtype
    tk_call('image', 'type', @path)
  end

  # Returns the image width in pixels.
  # @return [Integer]
  def width
    tk_call('image', 'width', @path).to_i
  end

  # Returns all image objects.
  # @return [Array<TkImage, String>] Image objects or names
  def TkImage.names
    Tk_IMGTBL.mutex.synchronize{
      TkCore::INTERP._invoke('image', 'names').split.collect!{|id|
        (Tk_IMGTBL[id])? Tk_IMGTBL[id] : id
      }
    }
  end

  # Returns available image types.
  # @return [Array<String>] Typically ["bitmap", "photo"]
  def TkImage.types
    TkCore::INTERP._invoke('image', 'types').split
  end

  private

  # Convert hash to -key value args for image commands.
  def _image_hash_kv(keys)
    return [] unless keys
    hash_to_args(keys)
  end
end

# A two-color bitmap image.
#
# Bitmap images display in foreground/background colors with no gradients.
# Useful for icons, cursors, and simple graphics.
#
# @example Creating from file
#   icon = TkBitmapImage.new(file: '/path/to/icon.xbm')
#
# @example With foreground/background colors
#   icon = TkBitmapImage.new(file: 'check.xbm', foreground: 'green', background: 'white')
#
# @see TkPhotoImage For full-color images
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/bitmap.htm Tcl/Tk bitmap manual
class TkBitmapImage<TkImage
  extend Tk::OptionDSL

  option :maskdata, type: :string
  option :maskfile, type: :string

  def initialize(*args)
    @type = 'bitmap'
    super(*args)
  end
end

# A full-color image with optional transparency.
#
# Photo images can display any color and support per-pixel transparency.
# Built-in support for PNG, GIF, and PPM/PGM formats; additional formats
# (JPEG, TIFF, etc.) available via the tkimg extension.
#
# @note **Supported formats**: Only PNG, GIF, and PPM/PGM are built-in.
#   For JPEG, BMP, TIFF, etc., install the tkimg extension.
#
# @note **Dithering quirk**: If loading image data in pieces, the dithered
#   image may not be exactly correct. Call {#redither} to recalculate.
#
# @example Creating from file
#   img = TkPhotoImage.new(file: '/path/to/photo.png')
#
# @example Creating empty image with fixed size
#   img = TkPhotoImage.new(width: 200, height: 150)
#
# @example Getting/setting pixels
#   r, g, b = img.get(10, 20)  # Get pixel at (10, 20)
#   img.put('{red green blue}', to: [0, 0, 3, 1])  # Set 3 pixels
#
# @example Copying regions with zoom
#   dest.copy(source, from: [0, 0, 100, 100], zoom: [2, 2])
#
# @example High-performance pixel writes (e.g. for games)
#   rgba_data = "\xFF\x00\x00\xFF" * (100 * 100)  # 100x100 red
#   img.put_block(rgba_data, 100, 100)
#   # Or with scaling:
#   img.put_zoomed_block(rgba_data, 100, 100, zoom_x: 3, zoom_y: 3)
#
# @see TkBitmapImage For two-color images
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/photo.htm Tcl/Tk photo manual
class TkPhotoImage<TkImage
  NullArgOptionKeys = [ "shrink", "grayscale" ]

  def _photo_hash_kv(keys)
    keys = keys.transform_keys(&:to_s)
    NullArgOptionKeys.each do |opt|
      if keys[opt]
        keys[opt] = NONE
      else
        keys.delete(opt)
      end
    end
    hash_to_args(keys, flat_arrays: true)
  end
  private :_photo_hash_kv

  # Base64-encoded signatures for formats that DON'T support base64 -data natively
  # These formats require binary data but users often pass base64 by mistake
  BASE64_TKIMG_SIGNATURES = {
    'Qk'   => 'bmp',    # "BM"
    '/9j/' => 'jpeg',   # 0xFF 0xD8 0xFF
    'SUkq' => 'tiff',   # "II*\x00" (little-endian TIFF)
    'TU0A' => 'tiff',   # "MM\x00*" (big-endian TIFF)
  }.freeze

  None = TkUtil::None

  def initialize(*args)
    @type = 'photo'

    # Detect base64-encoded tkimg format data (common mistake - tkimg needs binary)
    if args[0].is_a?(Hash)
      data = args[0][:data] || args[0]['data']
      if data.is_a?(String)
        BASE64_TKIMG_SIGNATURES.each do |prefix, format|
          if data.start_with?(prefix)
            Tk::Warnings.warn_once(:tkimg_base64,
              "Detected base64-encoded #{format.upcase} data. " \
              "tkimg formats require binary data, not base64. " \
              "Use Base64.decode64(data) or load from file. " \
              "Only PNG/GIF support base64 -data natively.")
            break
          end
        end
      end
    end

    super(*args)
  end

  def cget_strict(option)
    case option.to_s
    when 'data', 'file'
      tk_send 'cget', '-' << option.to_s
    else
      value_from_tcl(tk_send('cget', '-' << option.to_s))
    end
  end

  # Returns the current value of the configuration option given by option.
  # Example, display name of the file from which <tt>image</tt> was created:
  # 	puts image.cget :file
  def cget(option)
    cget_strict(option)
  end

  # Copies a region from the image called source to the image called
  # destination, possibly with pixel zooming and/or subsampling.
  def copy(src, *opts)
    if opts.size == 0
      tk_send('copy', src)
    elsif opts.size == 1 && opts[0].kind_of?(Hash)
      tk_send('copy', src, *_photo_hash_kv(opts[0]))
    else
      # for backward compatibility
      args = opts.collect{|term|
        if term.kind_of?(String) && term.include?(?\s)
          term.split
        else
          term
        end
      }.flatten
      tk_send('copy', src, *args)
    end
    self
  end

  # Returns image data in the form of a string.
  def data(keys={})
    result = tk_send('data', *_photo_hash_kv(keys))
    TclTkLib._split_tklist(result)
  end

  # Returns the color of the pixel at coordinates (x,y) in the image as a list
  # of three integers between 0 and 255, representing the red, green and blue
  # components respectively.
  def get(x, y)
    tk_send('get', x, y).split.collect{|n| n.to_i}
  end

  def put(data, *opts)
    if opts.empty?
      tk_send('put', data)
    elsif opts.size == 1 && opts[0].kind_of?(Hash)
      tk_send('put', data, *_photo_hash_kv(opts[0]))
    else
      # for backward compatibility
      tk_send('put', data, '-to', *opts)
    end
    self
  end

  def read(file, *opts)
    if opts.size == 0
      tk_send('read', file)
    elsif opts.size == 1 && opts[0].kind_of?(Hash)
      tk_send('read', file, *_photo_hash_kv(opts[0]))
    else
      # for backward compatibility
      args = opts.collect{|term|
        if term.kind_of?(String) && term.include?(?\s)
          term.split
        else
          term
        end
      }.flatten
      tk_send('read', file, *args)
    end
    self
  end

  def redither
    tk_send 'redither'
    self
  end

  # Returns a boolean indicating if the pixel at (x,y) is transparent.
  def get_transparency(x, y)
    tk_send('transparency', 'get', x, y) == '1'
  end

  # Makes the pixel at (x,y) transparent if <tt>state</tt> is true, and makes
  # that pixel opaque otherwise.
  def set_transparency(x, y, state)
    tk_send('transparency', 'set', x, y, state)
    self
  end

  def write(file, *opts)
    if opts.size == 0
      tk_send('write', file)
    elsif opts.size == 1 && opts[0].kind_of?(Hash)
      tk_send('write', file, *_photo_hash_kv(opts[0]))
    else
      # for backward compatibility
      args = opts.collect{|term|
        if term.kind_of?(String) && term.include?(?\s)
          term.split
        else
          term
        end
      }.flatten
      tk_send('write', file, *args)
    end
    self
  end

  # Fast pixel writes using Tk_PhotoPutBlock C API.
  #
  # Much faster than #put for real-time graphics - uses direct memory copy
  # instead of parsing hex color strings.
  #
  # @param pixel_data [String] Binary string of pixels (4 bytes per pixel)
  # @param width [Integer] Width in pixels
  # @param height [Integer] Height in pixels
  # @param x [Integer] X offset in destination image (default: 0)
  # @param y [Integer] Y offset in destination image (default: 0)
  # @param format [Symbol] :rgba (default) or :argb
  # @return [self]
  def put_block(pixel_data, width, height, x: 0, y: 0, format: :rgba)
    opts = {}
    opts[:x] = x if x != 0
    opts[:y] = y if y != 0
    opts[:format] = format if format != :rgba
    Tk::INTERP.photo_put_block(@path, pixel_data, width, height, opts.empty? ? nil : opts)
    self
  end

  # Fast pixel writes with zoom/subsample using Tk_PhotoPutZoomedBlock.
  #
  # Writes pixels and scales in a single operation - faster than put_block + copy.
  # Zoom replicates pixels, subsample skips pixels.
  #
  # @param pixel_data [String] Binary string of pixels (4 bytes per pixel)
  # @param width [Integer] Source width in pixels
  # @param height [Integer] Source height in pixels
  # @param x [Integer] X offset in destination (default: 0)
  # @param y [Integer] Y offset in destination (default: 0)
  # @param zoom_x [Integer] Horizontal zoom factor (default: 1)
  # @param zoom_y [Integer] Vertical zoom factor (default: 1)
  # @param subsample_x [Integer] Horizontal subsample factor (default: 1)
  # @param subsample_y [Integer] Vertical subsample factor (default: 1)
  # @param format [Symbol] :rgba (default) or :argb
  # @return [self]
  def put_zoomed_block(pixel_data, width, height, x: 0, y: 0,
                       zoom_x: 1, zoom_y: 1, subsample_x: 1, subsample_y: 1, format: :rgba)
    opts = {}
    opts[:x] = x if x != 0
    opts[:y] = y if y != 0
    opts[:zoom_x] = zoom_x if zoom_x != 1
    opts[:zoom_y] = zoom_y if zoom_y != 1
    opts[:subsample_x] = subsample_x if subsample_x != 1
    opts[:subsample_y] = subsample_y if subsample_y != 1
    opts[:format] = format if format != :rgba
    Tk::INTERP.photo_put_zoomed_block(@path, pixel_data, width, height, opts.empty? ? nil : opts)
    self
  end

  # Read RGBA pixel data from the photo image using Tk_PhotoGetImage.
  #
  # Returns a hash with pixel data, width, and height.
  # Can optionally read a sub-region of the image.
  #
  # @param x [Integer] X offset to start reading (default 0)
  # @param y [Integer] Y offset to start reading (default 0)
  # @param width [Integer, nil] Width to read (default: full width)
  # @param height [Integer, nil] Height to read (default: full height)
  # @param unpack [Boolean] If true, return flat array of integers instead
  #   of binary string (default: false)
  #
  # @return [Hash] With keys:
  #   - :width [Integer] - Width of returned data
  #   - :height [Integer] - Height of returned data
  #   - :data [String] - Binary RGBA string (when unpack: false)
  #   - :pixels [Array<Integer>] - Flat array [r,g,b,a,r,g,b,a,...] (when unpack: true)
  def get_image(x: 0, y: 0, width: nil, height: nil, unpack: false)
    opts = {}
    opts[:x] = x if x != 0
    opts[:y] = y if y != 0
    opts[:width] = width if width
    opts[:height] = height if height
    opts[:unpack] = true if unpack
    Tk::INTERP.photo_get_image(@path, opts.empty? ? nil : opts)
  end

  # Get dimensions of the photo image using Tk_PhotoGetSize.
  # Faster than querying width/height separately via Tcl.
  #
  # @return [Array<Integer>] [width, height]
  def get_size
    Tk::INTERP.photo_get_size(@path)
  end

  # Clear the photo image to fully transparent using Tk_PhotoBlank.
  # Faster than manually setting all pixels.
  #
  # @return [self]
  def blank
    Tk::INTERP.photo_blank(@path)
    self
  end
end
