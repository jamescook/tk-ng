# frozen_string_literal: false
#
# tk/image.rb : treat Tk image objects
#

require 'tk/option_dsl'

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
class TkImage<TkObject
  include Tk

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
          name = _get_eval_string(name)
          obj = nil
          Tk_IMGTBL.mutex.synchronize{
            obj = Tk_IMGTBL[name]
          }
        end
        if obj
          if !(keys[:without_creating] || keys['without_creating'])
            keys = _symbolkey2str(keys)
            keys.delete('imagename')
            keys.delete('without_creating')
            obj.instance_eval{
              tk_call_without_enc('image', 'create',
                                  @type, @path, *hash_kv(keys, true))
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
      keys = _symbolkey2str(keys)
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
      tk_call_without_enc('image', 'create',
                          @type, @path, *hash_kv(keys, true))
    end
  end

  # Deletes this image and frees associated resources.
  # @return [self]
  def delete
    Tk_IMGTBL.mutex.synchronize{
      Tk_IMGTBL.delete(@id) if @id
    }
    tk_call_without_enc('image', 'delete', @path)
    self
  end

  # Returns the image height in pixels.
  # @return [Integer]
  def height
    number(tk_call_without_enc('image', 'height', @path))
  end

  # Returns whether this image is currently displayed by any widget.
  # @return [Boolean]
  def inuse
    bool(tk_call_without_enc('image', 'inuse', @path))
  end

  # Returns the image type ("bitmap" or "photo").
  # @return [String]
  def itemtype
    tk_call_without_enc('image', 'type', @path)
  end

  # Returns the image width in pixels.
  # @return [Integer]
  def width
    number(tk_call_without_enc('image', 'width', @path))
  end

  # Returns all image objects.
  # @return [Array<TkImage, String>] Image objects or names
  def TkImage.names
    Tk_IMGTBL.mutex.synchronize{
      Tk.tk_call_without_enc('image', 'names').split.collect!{|id|
        (Tk_IMGTBL[id])? Tk_IMGTBL[id] : id
      }
    }
  end

  # Returns available image types.
  # @return [Array<String>] Typically ["bitmap", "photo"]
  def TkImage.types
    Tk.tk_call_without_enc('image', 'types').split
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

  # NOTE: __strval_optkeys override for 'maskdata', 'maskfile' removed - now declared via OptionDSL

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
    keys = _symbolkey2str(keys)
    NullArgOptionKeys.collect{|opt|
      if keys[opt]
        keys[opt] = None
      else
        keys.delete(opt)
      end
    }
    keys.collect{|k,v|
      ['-' << k, v]
    }.flatten
  end
  private :_photo_hash_kv

  # Create a new image with the given options.
  # == Examples of use :
  # === Create an empty image of 300x200 pixels
  #
  #		image = TkPhotoImage.new(:height => 200, :width => 300)
  #
  # === Create an image from a file
  #
  #		image = TkPhotoImage.new(:file: => 'my_image.gif')
  #
  # == Options
  # Photos support the following options:
  # * :data
  #   Specifies the contents of the image as a string.
  # * :format
  #   Specifies the name of the file format for the data.
  # * :file
  #   Gives the name of a file that is to be read to supply data for the image.
  # * :gamma
  #   Specifies that the colors allocated for displaying this image in a window
  #   should be corrected for a non-linear display with the specified gamma
  #   exponent value.
  # * height
  #   Specifies the height of the image, in pixels. This option is useful
  #   primarily in situations where the user wishes to build up the contents of
  #   the image piece by piece. A value of zero (the default) allows the image
  #   to expand or shrink vertically to fit the data stored in it.
  # * palette
  #   Specifies the resolution of the color cube to be allocated for displaying
  #   this image.
  # * width
  #   Specifies the width of the image, in pixels. This option is useful
  #   primarily in situations where the user wishes to build up the contents of
  #   the image piece by piece. A value of zero (the default) allows the image
  #   to expand or shrink horizontally to fit the data stored in it.
  # Base64-encoded signatures for formats that DON'T support base64 -data natively
  # These formats require binary data but users often pass base64 by mistake
  BASE64_TKIMG_SIGNATURES = {
    'Qk'   => 'bmp',    # "BM"
    '/9j/' => 'jpeg',   # 0xFF 0xD8 0xFF
    'SUkq' => 'tiff',   # "II*\x00" (little-endian TIFF)
    'TU0A' => 'tiff',   # "MM\x00*" (big-endian TIFF)
  }.freeze

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

  # Note: blank is defined below using the faster C API (Tk_PhotoBlank)

  def cget_strict(option)
    case option.to_s
    when 'data', 'file'
      tk_send 'cget', '-' << option.to_s
    else
      tk_tcl2ruby(tk_send('cget', '-' << option.to_s))
    end
  end

  # Returns the current value of the configuration option given by option.
  # Example, display name of the file from which <tt>image</tt> was created:
  # 	puts image.cget :file
  def cget(option)
    cget_strict(option)
  end

  # Copies a region from the image called source to the image called
  # destination, possibly with pixel zooming and/or subsampling. If no options
  # are specified, this method copies the whole of source into destination,
  # starting at coordinates (0,0) in destination. The following options may be
  # specified:
  #
  # * :from [x1, y1, x2, y2]
  #   Specifies a rectangular sub-region of the source image to be copied.
  #   (x1,y1) and (x2,y2) specify diagonally opposite corners of the rectangle.
  #   If x2 and y2 are not specified, the default value is the bottom-right
  #   corner of the source image. The pixels copied will include the left and
  #   top edges of the specified rectangle but not the bottom or right edges.
  #   If the :from option is not given, the default is the whole source image.
  # * :to [x1, y1, x2, y2]
  #   Specifies a rectangular sub-region of the destination image to be
  #   affected. (x1,y1) and (x2,y2) specify diagonally opposite corners of the
  #   rectangle. If x2 and y2 are not specified, the default value is (x1,y1)
  #   plus the size of the source region (after subsampling and zooming, if
  #   specified). If x2 and  y2 are specified, the source region will be
  #   replicated if necessary to fill the destination region in a tiled fashion.
  # * :shrink
  #   Specifies that the size of the destination image should be reduced, if
  #   necessary, so that the region being copied into is at the bottom-right
  #   corner of the image. This option will not affect the width or height of
  #   the image if the user has specified a non-zero value for the :width or
  #   :height configuration option, respectively.
  # * :zoom [x, y]
  #   Specifies that the source region should be magnified by a factor of x
  #   in the X direction and y in the Y direction. If y is not given, the
  #   default value is the same as x. With this option, each pixel in the
  #   source image will be expanded into a block of x x y pixels in the
  #   destination image, all the same color. x and y must be greater than 0.
  # * :subsample [x, y]
  #   Specifies that the source image should be reduced in size by using only
  #   every xth pixel in the X direction and yth pixel in the Y direction.
  #   Negative values will cause the image to be flipped about the Y or X axes,
  #   respectively. If y is not given, the default value is the same as x.
  # * :compositingrule rule
  #   Specifies how transparent pixels in the source image are combined with
  #   the destination image. When a compositing rule of <tt>overlay</tt> is set,
  #   the old  contents of the destination image are visible, as if the source
  #   image were  printed on a piece of transparent film and placed over the
  #   top of the  destination. When a compositing rule of <tt>set</tt> is set,
  #   the old contents of  the destination image are discarded and the source
  #   image is used as-is. The default compositing rule is <tt>overlay</tt>.
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

  # Returns image data in the form of a string. The following options may be
  # specified:
  # * :background color
  #   If the color is specified, the data will not contain any transparency
  #   information. In all transparent pixels the color will be replaced by the
  #   specified color.
  # * :format format-name
  #   Specifies the name of the image file format handler to be used.
  #   Specifically, this subcommand searches for the first handler whose name
  #   matches an initial substring of format-name and which has the capability
  #   to read this image data. If this option is not given, this subcommand
  #   uses the first handler that has the capability to read the image data.
  # * :from [x1, y1, x2, y2]
  #   Specifies a rectangular region of imageName to be returned. If only x1
  #   and y1 are specified, the region extends from (x1,y1) to the bottom-right
  #   corner of imageName. If all four coordinates are given, they specify
  #   diagonally opposite corners of the rectangular region, including x1,y1
  #   and excluding x2,y2. The default, if this option is not given, is the
  #   whole image.
  # * :grayscale
  #   If this options is specified, the data will not contain color information.
  #   All pixel data will be transformed into grayscale.
  def data(keys={})
    tk_split_list(tk_send('data', *_photo_hash_kv(keys)))
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
    bool(tk_send('transparency', 'get', x, y))
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
  #
  # @example Fill a 100x100 image with red pixels (RGBA)
  #   img = TkPhotoImage.new(width: 100, height: 100)
  #   red_rgba = "\xFF\x00\x00\xFF" * (100 * 100)
  #   img.put_block(red_rgba, 100, 100)
  #
  # @example Using ARGB format (common in SDL2, graphics libraries)
  #   # ARGB integers packed little-endian: 0xAARRGGBB -> [B,G,R,A] bytes
  #   argb_data = [0xFFFF0000].pack('V*') * (100 * 100)  # red
  #   img.put_block(argb_data, 100, 100, format: :argb)
  #
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
  #
  # @example Scale up 3x for display
  #   img = TkPhotoImage.new(width: 960, height: 720)
  #   img.put_zoomed_block(rgba_data, 320, 240, zoom_x: 3, zoom_y: 3)
  #
  # @example NES emulator with ARGB pixel data
  #   # Optcarrot outputs ARGB integers, pack and pass directly
  #   argb_data = colors.pack('V*')
  #   img.put_zoomed_block(argb_data, 256, 224, zoom_x: 3, zoom_y: 3, format: :argb)
  #
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
  #
  # @example Read all pixels as binary string
  #   result = img.get_image
  #   rgba_data = result[:data]  # "\xFF\x00\x00\xFF..."
  #
  # @example Read as unpacked integers
  #   result = img.get_image(unpack: true)
  #   pixels = result[:pixels]  # [255, 0, 0, 255, 255, 0, 0, 255, ...]
  #
  #   # Get individual RGBA tuples:
  #   pixels.each_slice(4) do |r, g, b, a|
  #     puts "R=#{r} G=#{g} B=#{b} A=#{a}"
  #   end
  #
  #   # Get rows of pixels:
  #   pixels.each_slice(result[:width] * 4) do |row|
  #     row.each_slice(4) do |r, g, b, a|
  #       # process pixel
  #     end
  #   end
  #
  # @example Read a 100x100 region at offset (50, 50)
  #   result = img.get_image(x: 50, y: 50, width: 100, height: 100)
  #
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
  #
  # @example
  #   width, height = img.get_size
  #
  def get_size
    Tk::INTERP.photo_get_size(@path)
  end

  # Clear the photo image to fully transparent using Tk_PhotoBlank.
  # Faster than manually setting all pixels.
  #
  # @return [self]
  #
  # @example
  #   img.blank
  #
  def blank
    Tk::INTERP.photo_blank(@path)
    self
  end
end
