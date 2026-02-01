# frozen_string_literal: true
#
# tk/font.rb - TkFont class for creating and manipulating fonts
#
require 'tk'

# Creates named fonts that can be modified after creation.
#
# Unlike simple font strings ("Helvetica 12 bold"), TkFont objects create
# named Tcl fonts that automatically update all widgets using them when
# modified. This is useful for implementing font preferences or themes.
#
# @example Creating fonts
#   # From font description string
#   font = TkFont.new('Helvetica 12 bold')
#
#   # From keyword options
#   font = TkFont.new(family: 'Courier', size: 14, weight: 'bold')
#
#   # Apply to widget
#   label = TkLabel.new(root, font: font)
#
# @example Modifying fonts (auto-updates widgets)
#   font.family = 'Times'
#   font.size = 18
#   font.weight = 'bold'
#   # All widgets using this font update automatically
#
# @example Querying fonts
#   TkFont.families         # => ["Arial", "Courier", "Helvetica", ...]
#   TkFont.names            # => ["TkDefaultFont", "TkTextFont", ...]
#   TkFont.measure(font, "Hello")  # => pixel width
#   TkFont.metrics(font)    # => {ascent: 12, descent: 3, linespace: 15, fixed: 0}
#
# @example Deriving fonts (creates new font)
#   bold_font = font.weight('bold')  # New TkFont with bold weight
#   big_font = font.size(24)         # New TkFont with size 24
#
# @note **macOS limitation**: System fonts (TkDefaultFont, etc.) cannot be
#   directly modified on Aqua. Use {#actual} to get current attributes,
#   then create a new TkFont with those attributes.
#
# @note **Standard fonts warning**: Avoid modifying TkDefaultFont,
#   TkTextFont, etc. directly. Tk may alter these in response to system
#   changes, overwriting your modifications.
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/font.htm Tcl/Tk font manual
class TkFont
  @font_id = 0
  @font_id_mutex = Mutex.new
  @registry = {}
  @registry_mutex = Mutex.new

  def self.next_font_id
    @font_id_mutex.synchronize { @font_id += 1 }
  end

  # Registry for looking up TkFont objects by their Tcl font name
  def self.register(name, font)
    @registry_mutex.synchronize { @registry[name] = font }
  end

  def self.id2obj(name)
    @registry_mutex.synchronize { @registry[name] }
  end

  # Creates a new named font.
  # @param font_spec [String, nil] Font description (e.g., "Helvetica 12 bold")
  # @param fallback [String, nil] Fallback font (legacy, ignored in modern Tk)
  # @param widget [TkWindow, nil] Source widget for auto-reconfigure
  # @param opts [Hash] Font attributes
  # @option opts [String] :family Font family name
  # @option opts [Integer] :size Font size in points
  # @option opts [String] :weight "normal" or "bold"
  # @option opts [String] :slant "roman" or "italic"
  # @option opts [Boolean] :underline Underline text
  # @option opts [Boolean] :overstrike Strikethrough text
  def initialize(font_spec = nil, fallback = nil, widget: nil, **opts)
    if font_spec.is_a?(Hash)
      opts = font_spec
      font_spec = nil
    end

    # Track source widget so setters can reconfigure it
    @source_widget = widget

    # Create a named Tcl font so we can modify it later
    @tcl_font_name = "rbfont#{TkFont.next_font_id}"

    # Determine base font to derive from
    base_font = if font_spec && !font_spec.to_s.empty?
                  font_spec.to_s
                else
                  'TkDefaultFont'
                end

    if opts.any?
      # Get actual attributes of base font, then override with opts
      actual = Tk.tk_call('font', 'actual', base_font)
      attrs = Hash[*TkCore::INTERP._split_tklist(actual)]

      # Override with provided options
      attrs['-family'] = opts[:family].to_s if opts[:family]
      attrs['-size'] = opts[:size].to_s if opts[:size]
      attrs['-weight'] = opts[:weight].to_s if opts[:weight]
      attrs['-slant'] = opts[:slant].to_s if opts[:slant]
      attrs['-underline'] = (opts[:underline] ? '1' : '0') if opts.key?(:underline)
      attrs['-overstrike'] = (opts[:overstrike] ? '1' : '0') if opts.key?(:overstrike)

      create_opts = attrs.to_a.flatten
      Tk.tk_call('font', 'create', @tcl_font_name, *create_opts)
    else
      # Create named font from base font spec
      actual = Tk.tk_call('font', 'actual', base_font)
      Tk.tk_call('font', 'create', @tcl_font_name, *TkCore::INTERP._split_tklist(actual))
    end

    @font = @tcl_font_name

    # Register in lookup table so cget(:font) can return this same object
    TkFont.register(@tcl_font_name, self)

    # Store fallback for Japanese font support (ignored in modern Tk)
    @fallback = fallback
  end

  def to_s
    @font
  end

  def to_str
    @font
  end

  # Allow TkFont to be used directly where strings are expected
  def to_eval
    @font
  end

  # Attribute setters - modify the underlying Tcl font and reconfigure source widget
  def family=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-family', value)
    _reconfigure_source_widget
  end

  def size=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-size', value)
    _reconfigure_source_widget
  end

  def weight=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-weight', value)
    _reconfigure_source_widget
  end

  def slant=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-slant', value)
    _reconfigure_source_widget
  end

  def underline=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-underline', value ? '1' : '0')
    _reconfigure_source_widget
  end

  def overstrike=(value)
    Tk.tk_call('font', 'configure', @tcl_font_name, '-overstrike', value ? '1' : '0')
    _reconfigure_source_widget
  end

  # Attribute getters
  def family
    Tk.tk_call('font', 'configure', @tcl_font_name, '-family')
  end

  def actual_size
    Tk.tk_call('font', 'configure', @tcl_font_name, '-size').to_i
  end

  # Returns actual font attributes after Tk resolves substitutions.
  #
  # The "actual" attributes may differ from requested attributes due to
  # platform limitations or font unavailability.
  #
  # @param option [String, Symbol, nil] Specific attribute to query
  # @return [Hash, String] All attributes as hash, or single value if option given
  # @example Get all actual attributes
  #   font.actual  # => {family: "Helvetica", size: "12", weight: "normal", ...}
  # @example Get specific attribute
  #   font.actual(:family)  # => "Helvetica"
  def actual(option = nil)
    if option
      Tk.tk_call('font', 'actual', @tcl_font_name, "-#{option}")
    else
      result = {}
      TkCore::INTERP._split_tklist(Tk.tk_call('font', 'actual', @tcl_font_name)).each_slice(2) do |k, v|
        result[k.sub(/^-/, '').to_sym] = v
      end
      result
    end
  end

  # Font modifier methods - return new TkFont with modified attributes
  # Uses Tcl's font system to properly derive fonts from named fonts like TkDefaultFont
  def weight(w)
    TkFont.new(_derive_font('-weight', w))
  end

  def slant(s)
    TkFont.new(_derive_font('-slant', s))
  end

  def size(s)
    TkFont.new(_derive_font('-size', s))
  end

  private

  # Reconfigure the source widget to use this font (needed when wrapping existing fonts)
  def _reconfigure_source_widget
    return unless @source_widget
    @source_widget.apply_font(@tcl_font_name)
  end

  # Derive a new font spec by getting actual font attributes and modifying one
  def _derive_font(option, value)
    actual = Tk.tk_call('font', 'actual', @font)
    attrs = Hash[*TkCore::INTERP._split_tklist(actual)]
    attrs[option] = value.to_s
    "{#{attrs['-family']} #{attrs['-size']} #{attrs['-weight']} #{attrs['-slant']}}"
  end

  public

  # Returns all available font families on this display.
  # @return [Array<String>] Font family names
  # @example
  #   TkFont.families  # => ["Arial", "Courier", "Helvetica", ...]
  def self.families
    TkCore::INTERP._split_tklist(Tk.tk_call('font', 'families'))
  end

  # Returns all named fonts (including system fonts like TkDefaultFont).
  # @return [Array<String>] Named font identifiers
  def self.names
    TkCore::INTERP._split_tklist(Tk.tk_call('font', 'names'))
  end

  # Measures text width in pixels using a given font.
  # @param font [TkFont, String] Font to use for measurement
  # @param text [String] Text to measure
  # @return [Integer] Width in pixels
  # @example
  #   TkFont.measure("Helvetica 12", "Hello World")  # => 78
  def self.measure(font, text)
    font_str = font.respond_to?(:to_str) ? font.to_str : font.to_s
    Tk.tk_call('font', 'measure', font_str, text).to_i
  end

  # Returns font metrics.
  # @param font [TkFont, String] Font to query
  # @param option [String, Symbol, nil] Specific metric (:ascent, :descent, :linespace, :fixed)
  # @return [Hash, Integer] All metrics as hash, or single value if option given
  # @example
  #   TkFont.metrics("Helvetica 12")  # => {ascent: 11, descent: 3, linespace: 14, fixed: 0}
  #   TkFont.metrics("Helvetica 12", :ascent)  # => 11
  def self.metrics(font, option = nil)
    font_str = font.respond_to?(:to_str) ? font.to_str : font.to_s
    if option
      Tk.tk_call('font', 'metrics', font_str, "-#{option}").to_i
    else
      result = {}
      Tk.tk_call('font', 'metrics', font_str).split.each_slice(2) do |k, v|
        result[k.sub(/^-/, '').to_sym] = v.to_i
      end
      result
    end
  end
end
