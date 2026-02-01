# frozen_string_literal: false
#
# tk/texttag.rb - methods for treating text tags
#
require 'tk/text'
require 'tk/tagfont'

# A named style that can be applied to text ranges in a Text widget.
#
# Tags serve three purposes:
# 1. **Styling** - Set colors, fonts, margins, spacing on tagged text
# 2. **Event binding** - Attach click/hover handlers to tagged regions
# 3. **Selection** - The built-in "sel" tag manages text selection
#
# ## Tag Priority
#
# When multiple tags cover the same text, higher-priority tags override
# lower-priority tags for conflicting options. Priority is set by creation
# order but can be adjusted with {#raise} and {#lower}.
#
# @example Creating and applying a tag
#   text = TkText.new(root)
#   text.insert(:end, "Hello World")
#
#   # Create tag with styling
#   bold_tag = TkTextTag.new(text, foreground: 'blue', font: 'Helvetica 12 bold')
#   bold_tag.add("1.0", "1.5")  # Apply to "Hello"
#
# @example Adding ranges
#   tag.add("1.0", "1.5")           # Range from 1.0 to 1.5
#   tag.add("1.0", "1.5", "2.0", "2.10")  # Multiple ranges
#
# @example Event binding on tagged text
#   link_tag = TkTextTag.new(text, foreground: 'blue', underline: true)
#   link_tag.bind('Enter') { link_tag.configure(foreground: 'red') }
#   link_tag.bind('Leave') { link_tag.configure(foreground: 'blue') }
#   link_tag.bind('ButtonRelease-1') { open_url(url) }
#
# @example Controlling tag priority
#   tag1.raise           # Move to highest priority
#   tag2.lower           # Move to lowest priority
#   tag1.raise(tag2)     # Position tag1 just above tag2
#
# ## Common Tag Options
#
# - `:foreground`, `:background` - Text and background colors
# - `:font` - Font specification
# - `:underline`, `:overstrike` - Text decorations
# - `:justify` - :left, :right, :center
# - `:lmargin1`, `:lmargin2`, `:rmargin` - Margins
# - `:spacing1`, `:spacing2`, `:spacing3` - Line spacing
# - `:elide` - Hide text (still takes up index space)
# - `:relief`, `:borderwidth` - 3D border effects
#
# @see TkTextTagSel The built-in "sel" tag for text selection
# @see TkTextMark For position tracking
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm Tcl/Tk text manual
class TkTextTag<TkObject
  include TkTreatTagFont
  include Tk::Text::IndexModMethods

  (Tk_TextTag_ID = ['tag'.freeze, '00000']).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  # Look up a tag by ID. Delegates to the text widget's tagid2obj.
  def TkTextTag.id2obj(text, id)
    text.tagid2obj(id)
  end

  def initialize(parent, *args)
    #unless parent.kind_of?(TkText)
    #  fail ArgumentError, "expect TkText for 1st argument"
    #end
    @parent = @t = parent
    @tpath = parent.path
    Tk_TextTag_ID.mutex.synchronize{
      # @path = @id = Tk_TextTag_ID.join('')
      @path = @id = Tk_TextTag_ID.join(TkCore::INTERP._ip_id_).freeze
      Tk_TextTag_ID[1].succ!
    }
    #tk_call @t.path, "tag", "configure", @id, *hash_kv(keys)
    if args != []
      keys = args.pop
      if keys.kind_of?(Hash)
        add(*args) if args != []
        configure(keys)
      else
        args.push keys
        add(*args)
      end
    end
    @t._addtag id, self
  end

  def id
    Tk::Text::IndexString.new(@id)
  end

  def exist?
    #if ( tk_split_simplelist(_fromUTF8(tk_call_without_enc(@t.path, 'tag', 'names'))).find{|id| id == @id } )
    if ( tk_split_simplelist(tk_call_without_enc(@t.path, 'tag', 'names'), false, true).find{|id| id == @id } )
      true
    else
      false
    end
  end

  def first
    Tk::Text::IndexString.new(@id + '.first')
  end

  def last
    Tk::Text::IndexString.new(@id + '.last')
  end

  def add(*indices)
    tk_call_without_enc(@t.path, 'tag', 'add', @id,
                        *(indices.collect{|idx| _get_eval_enc_str(idx)}))
    self
  end

  def remove(*indices)
    tk_call_without_enc(@t.path, 'tag', 'remove', @id,
                        *(indices.collect{|idx| _get_eval_enc_str(idx)}))
    self
  end

  def ranges
    l = tk_split_simplelist(tk_call_without_enc(@t.path, 'tag', 'ranges', @id))
    r = []
    while key=l.shift
      r.push [Tk::Text::IndexString.new(key), Tk::Text::IndexString.new(l.shift)]
    end
    r
  end

  def nextrange(first, last=None)
    simplelist(tk_call_without_enc(@t.path, 'tag', 'nextrange', @id,
                                   _get_eval_enc_str(first),
                                   _get_eval_enc_str(last))).collect{|idx|
      Tk::Text::IndexString.new(idx)
    }
  end

  def prevrange(first, last=None)
    simplelist(tk_call_without_enc(@t.path, 'tag', 'prevrange', @id,
                                   _get_eval_enc_str(first),
                                   _get_eval_enc_str(last))).collect{|idx|
      Tk::Text::IndexString.new(idx)
    }
  end

  def [](key)
    cget key
  end

  def []=(key,val)
    configure key, val
    val
  end

  def cget_tkstring(key)
    @t.tag_cget_tkstring @id, key
  end
  def cget(key)
    @t.tag_cget @id, key
  end
  def cget_strict(key)
    @t.tag_cget_strict @id, key
  end
=begin
  def cget(key)
    case key.to_s
    when 'text', 'label', 'show', 'data', 'file'
      _fromUTF8(tk_call_without_enc(@t.path, 'tag', 'cget', @id, "-#{key}"))
    when 'font', 'kanjifont'
      #fnt = tk_tcl2ruby(tk_call(@t.path, 'tag', 'cget', @id, "-#{key}"))
      fnt = tk_tcl2ruby(_fromUTF8(tk_call_without_enc(@t.path, 'tag', 'cget',
                                                      @id, '-font')))
      unless fnt.kind_of?(TkFont)
        fnt = tagfontobj(@id, fnt)
      end
      if key.to_s == 'kanjifont' && JAPANIZED_TK && TK_VERSION =~ /^4\.*/
        # obsolete; just for compatibility
        fnt.kanji_font
      else
        fnt
      end
    else
      tk_tcl2ruby(_fromUTF8(tk_call_without_enc(@t.path, 'tag', 'cget',
                                                @id, "-#{key}")))
    end
  end
=end

  def configure(key, val=None)
    @t.tag_configure @id, key, val
  end
#  def configure(key, val=None)
#    if key.kind_of?(Hash)
#      tk_call @t.path, 'tag', 'configure', @id, *hash_kv(key)
#    else
#      tk_call @t.path, 'tag', 'configure', @id, "-#{key}", val
#    end
#  end
#  def configure(key, value)
#    if value == false
#      value = "0"
#    elsif value.kind_of?(Proc)
#      value = install_cmd(value)
#    end
#    tk_call @t.path, 'tag', 'configure', @id, "-#{key}", value
#  end

  def configinfo(key=nil)
    @t.tag_configinfo @id, key
  end

  def current_configinfo(key=nil)
    @t.current_tag_configinfo @id, key
  end

  def bind(seq, *args, &block)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind([@t.path, 'tag', 'bind', @id], seq, cmd, *args)
    self
  end

  def bind_append(seq, *args, &block)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind_append([@t.path, 'tag', 'bind', @id], seq, cmd, *args)
    self
  end

  def bind_remove(seq)
    _bind_remove([@t.path, 'tag', 'bind', @id], seq)
    self
  end

  def bindinfo(context=nil)
    _bindinfo([@t.path, 'tag', 'bind', @id], context)
  end

  # Raises this tag's priority.
  #
  # Higher priority tags override lower priority tags when display
  # options conflict on the same text.
  #
  # @param above [TkTextTag, nil] Position just above this tag, or nil for highest
  # @return [self]
  def raise(above=None)
    tk_call_without_enc(@t.path, 'tag', 'raise', @id,
                        _get_eval_enc_str(above))
    self
  end

  # Lowers this tag's priority.
  # @param below [TkTextTag, nil] Position just below this tag, or nil for lowest
  # @return [self]
  def lower(below=None)
    tk_call_without_enc(@t.path, 'tag', 'lower', @id,
                        _get_eval_enc_str(below))
    self
  end

  def destroy
    tk_call_without_enc(@t.path, 'tag', 'delete', @id)
    self
  end
end
TktTag = TkTextTag

# Named tags are cached per (parent, name) pair via the text widget's @tags hash.
# self.new returns existing tag if found, otherwise creates new via initialize.
class TkTextNamedTag<TkTextTag
  def self.new(parent, name, *args)
    # Return existing tag if already registered with this parent
    existing = parent.tagid2obj(name)
    return existing if existing.kind_of?(TkTextTag)

    # Create new tag via normal instantiation
    super
  end

  def initialize(parent, name, *args)
    @parent = @t = parent
    @tpath = parent.path
    @path = @id = name
    @t._addtag @id, self

    if args != []
      keys = args.pop
      if keys.kind_of?(Hash)
        add(*args) if args != []
        configure(keys)
      else
        args.push keys
        add(*args)
      end
    end
  end
end
TktNamedTag = TkTextNamedTag

# The built-in "sel" tag that manages text selection.
#
# This special tag is automatically created and cannot be deleted.
# Its display options are tied to widget options like `-selectbackground`
# and `-selectforeground`.
#
# @example Getting selected text
#   sel = TkTextTagSel.new(text)
#   ranges = sel.ranges  # => [["1.5", "1.10"], ...]
#   selected_text = text.get(*ranges.first) if ranges.any?
#
# @example Programmatic selection
#   sel = TkTextTagSel.new(text)
#   sel.add("1.0", "1.10")  # Select first 10 chars
class TkTextTagSel<TkTextNamedTag
  def self.new(parent, *args)
    super(parent, 'sel', *args)
  end
end
TktTagSel = TkTextTagSel

# Add deprecation warning for removed TTagID_TBL constant
TkTextTag.extend(TkTextTagCompat)
