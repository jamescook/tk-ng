# frozen_string_literal: false
#
# tk/texttag.rb - methods for treating text tags
#
require 'tk/text'
require 'tk/tagfont'
require_relative 'callback'
require_relative 'core/callable'

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
class TkTextTag
  include TkUtil
  include Tk::Core::Callable
  include TkTreatTagFont
  include Tk::Text::IndexModMethods

  (Tk_TextTag_ID = ['tag'.freeze, '00000']).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  attr_reader :path

  def to_eval
    @path
  end

  # Look up a tag by ID. Delegates to the text widget's tagid2obj.
  def TkTextTag.id2obj(text, id)
    text.tagid2obj(id)
  end

  def initialize(parent, *args)
    @parent = @t = parent
    @tpath = parent.path
    Tk_TextTag_ID.mutex.synchronize{
      @path = @id = Tk_TextTag_ID.join(TkCore::INTERP._ip_id_).freeze
      Tk_TextTag_ID[1].succ!
    }
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
    TclTkLib._split_tklist(tk_call(@t.path, 'tag', 'names')).include?(@id)
  end

  def first
    Tk::Text::IndexString.new(@id + '.first')
  end

  def last
    Tk::Text::IndexString.new(@id + '.last')
  end

  def add(*indices)
    tk_call(@t.path, 'tag', 'add', @id,
            *(indices.collect{|idx| idx.to_s}))
    self
  end

  def remove(*indices)
    tk_call(@t.path, 'tag', 'remove', @id,
            *(indices.collect{|idx| idx.to_s}))
    self
  end

  def ranges
    l = TclTkLib._split_tklist(tk_call(@t.path, 'tag', 'ranges', @id))
    r = []
    while key=l.shift
      r.push [Tk::Text::IndexString.new(key), Tk::Text::IndexString.new(l.shift)]
    end
    r
  end

  def nextrange(first, last=TkUtil::None)
    args = [@t.path, 'tag', 'nextrange', @id, first.to_s]
    args << last.to_s unless last == TkUtil::None
    TclTkLib._split_tklist(tk_call(*args)).collect{|idx|
      Tk::Text::IndexString.new(idx)
    }
  end

  def prevrange(first, last=TkUtil::None)
    args = [@t.path, 'tag', 'prevrange', @id, first.to_s]
    args << last.to_s unless last == TkUtil::None
    TclTkLib._split_tklist(tk_call(*args)).collect{|idx|
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

  def configure(key, val=TkUtil::None)
    @t.tag_configure @id, key, val
  end

  def configinfo(key=nil)
    @t.tag_configinfo @id, key
  end

  def current_configinfo(key=nil)
    @t.current_tag_configinfo @id, key
  end

  # Tag binding helpers — same pattern as Treeview tags.
  # Uses install_bind/uninstall_cmd/tk_event_sequence from TkCallback.
  include TkCallback

  def bind(seq, *args, &block)
    if TkCallback._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    do_tag_bind([@t.path, 'tag', 'bind', @id], seq, cmd, *args)
    self
  end

  def bind_append(seq, *args, &block)
    if TkCallback._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    do_tag_bind_append([@t.path, 'tag', 'bind', @id], seq, cmd, *args)
    self
  end

  def bind_remove(seq)
    do_tag_bind_remove([@t.path, 'tag', 'bind', @id], seq)
    self
  end

  def bindinfo(context=nil)
    do_tag_bindinfo([@t.path, 'tag', 'bind', @id], context)
  end

  # Raises this tag's priority.
  #
  # Higher priority tags override lower priority tags when display
  # options conflict on the same text.
  #
  # @param above [TkTextTag, nil] Position just above this tag, or nil for highest
  # @return [self]
  def raise(above=TkUtil::None)
    val = if above.respond_to?(:path) then above.path
          elsif above == TkUtil::None then above
          else above.to_s
          end
    tk_call(@t.path, 'tag', 'raise', @id, val)
    self
  end

  # Lowers this tag's priority.
  # @param below [TkTextTag, nil] Position just below this tag, or nil for lowest
  # @return [self]
  def lower(below=TkUtil::None)
    val = if below.respond_to?(:path) then below.path
          elsif below == TkUtil::None then below
          else below.to_s
          end
    tk_call(@t.path, 'tag', 'lower', @id, val)
    self
  end

  def destroy
    tk_call(@t.path, 'tag', 'delete', @id)
    self
  end

  private

  def do_tag_bind(what, context, cmd, *args)
    id = install_bind(cmd, *args) if cmd
    begin
      tk_call(*(what + ["<#{tk_event_sequence(context)}>", id]))
    rescue
      uninstall_cmd(id) if cmd
      raise
    end
  end

  def do_tag_bind_append(what, context, cmd, *args)
    id = install_bind(cmd, *args) if cmd
    begin
      tk_call(*(what + ["<#{tk_event_sequence(context)}>", '+' + id]))
    rescue
      uninstall_cmd(id) if cmd
      raise
    end
  end

  def do_tag_bind_remove(what, context)
    tk_call(*(what + ["<#{tk_event_sequence(context)}>", '']))
  end

  def do_tag_bindinfo(what, context=nil)
    if context
      tk_call(*what + ["<#{tk_event_sequence(context)}>"]).each_line.collect { |cmdline|
        if cmdline =~ /rb_out\S*(?:\s+(::\S*|[{](::.*)[}]|["](::.*)["]))? (c(_\d+_)?(\d+))/
          [TkCore::INTERP.tk_cmd_tbl[$4], $5]
        else
          cmdline
        end
      }
    else
      TclTkLib._split_tklist(tk_call(*what)).collect! { |seq|
        seq[1..-2]
      }
    end
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
