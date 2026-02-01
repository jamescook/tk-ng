# frozen_string_literal: false
#
# tk/textmark.rb - methods for treating text marks
#
require 'tk/text'

# A position marker in a Text widget that floats with the text.
#
# Marks track positions between characters, persisting even when surrounding
# text is deleted. Unlike character indices (like "1.5"), marks automatically
# adjust as text is inserted or deleted around them.
#
# ## Gravity
#
# Each mark has **gravity** (left or right) that determines what happens
# when text is inserted exactly at the mark's position:
#
# - **:left** - Mark stays with character on its left; new text appears to the right
# - **:right** (default) - New text appears to the left; mark stays rightmost
#
# @example Creating and using a mark
#   text = TkText.new(root)
#   mark = TkTextMark.new(text, "1.5")
#   text.insert(mark, "Hello")  # Text inserted at mark position
#   mark.pos                    # => "1.10" (position updated)
#
# @example Controlling gravity
#   mark = TkTextMark.new(text, "1.0")
#   mark.gravity = :left        # New text at mark goes to the right
#   text.insert(mark, "A")
#   mark.pos                    # Mark didn't move; still at start
#
# @example Using index arithmetic
#   mark = TkTextMark.new(text, "1.0")
#   text.get(mark, mark + "5 chars")    # Get 5 chars from mark
#   text.get(mark, mark + 5)            # Same thing
#
# @note Marks and tags have separate namespaces—you can have a mark and
#   tag with the same name referring to different things.
#
# @see TkTextMarkInsert The "insert" mark (cursor position)
# @see TkTextMarkCurrent The "current" mark (mouse position)
# @see TkTextTag For styling and event handling on text ranges
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm Tcl/Tk text manual
class TkTextMark<TkObject
  include Tk::Text::IndexModMethods

  (Tk_TextMark_ID = ['mark'.freeze, '00000']).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  # Look up a mark by ID. Delegates to the text widget's tagid2obj.
  def TkTextMark.id2obj(text, id)
    text.tagid2obj(id)
  end

  def initialize(parent, index)
    #unless parent.kind_of?(Tk::Text)
    #  fail ArgumentError, "expect Tk::Text for 1st argument"
    #end
    @parent = @t = parent
    @tpath = parent.path
    Tk_TextMark_ID.mutex.synchronize{
      # @path = @id = Tk_TextMark_ID.join('')
      @path = @id = Tk_TextMark_ID.join(TkCore::INTERP._ip_id_).freeze
      Tk_TextMark_ID[1].succ!
    }
    tk_call_without_enc(@t.path, 'mark', 'set', @id,
                        _get_eval_enc_str(index))
    @t._addtag id, self
  end

  def id
    Tk::Text::IndexString.new(@id)
  end

  def exist?
    #if ( tk_split_simplelist(_fromUTF8(tk_call_without_enc(@t.path, 'mark', 'names'))).find{|id| id == @id } )
    if ( tk_split_simplelist(tk_call_without_enc(@t.path, 'mark', 'names'), false, true).find{|id| id == @id } )
      true
    else
      false
    end
  end

=begin
  # move to Tk::Text::IndexModMethods module
  def +(mod)
    return chars(mod) if mod.kind_of?(Numeric)

    mod = mod.to_s
    if mod =~ /^\s*[+-]?\d/
      Tk::Text::IndexString.new(@id + ' + ' + mod)
    else
      Tk::Text::IndexString.new(@id + ' ' + mod)
    end
  end

  def -(mod)
    return chars(-mod) if mod.kind_of?(Numeric)

    mod = mod.to_s
    if mod =~ /^\s*[+-]?\d/
      Tk::Text::IndexString.new(@id + ' - ' + mod)
    elsif mod =~ /^\s*[-]\s+(\d.*)$/
      Tk::Text::IndexString.new(@id + ' - -' + $1)
    else
      Tk::Text::IndexString.new(@id + ' ' + mod)
    end
  end
=end

  def pos
    @t.index(@id)
  end

  def pos=(where)
    set(where)
  end

  def set(where)
    tk_call_without_enc(@t.path, 'mark', 'set', @id,
                        _get_eval_enc_str(where))
    self
  end

  def unset
    tk_call_without_enc(@t.path, 'mark', 'unset', @id)
    self
  end
  alias destroy unset

  # Returns the mark's gravity.
  # @return [String] "left" or "right"
  def gravity
    tk_call_without_enc(@t.path, 'mark', 'gravity', @id)
  end

  # Sets the mark's gravity.
  # @param direction [String, Symbol] :left or :right
  # @return [String] The direction set
  # @note Left gravity: mark stays put when text inserted at position.
  #   Right gravity (default): mark moves right when text inserted.
  def gravity=(direction)
    tk_call_without_enc(@t.path, 'mark', 'gravity', @id, direction)
    #self
    direction
  end

  def next(index = nil)
    if index
      @t.tagid2obj(tk_call_without_enc(@t.path, 'mark', 'next', _get_eval_enc_str(index)))
    else
      @t.tagid2obj(tk_call_without_enc(@t.path, 'mark', 'next', @id))
    end
  end

  def previous(index = nil)
    if index
      @t.tagid2obj(tk_call_without_enc(@t.path, 'mark', 'previous', _get_eval_enc_str(index)))
    else
      @t.tagid2obj(tk_call_without_enc(@t.path, 'mark', 'previous', @id))
    end
  end
end
TktMark = TkTextMark

# A mark with a user-specified name (cached per text widget).
#
# Unlike auto-generated TkTextMark IDs, named marks use your chosen name.
# Creating the same named mark twice returns the existing instance.
#
# @example
#   mark1 = TkTextNamedMark.new(text, "my_bookmark", "1.0")
#   mark2 = TkTextNamedMark.new(text, "my_bookmark")  # Same object as mark1
#   mark1.equal?(mark2)  # => true
class TkTextNamedMark<TkTextMark
  def self.new(parent, name, index=nil)
    # Return existing mark if already registered with this text widget
    existing = parent.tagid2obj(name)
    return existing if existing.kind_of?(TkTextMark)

    # Create new mark via normal instantiation
    super
  end

  def initialize(parent, name, index=nil)
    @parent = @t = parent
    @tpath = parent.path
    @path = @id = name
    tk_call_without_enc(@t.path, 'mark', 'set', @id,
                        _get_eval_enc_str(index)) if index
    @t._addtag @id, self
  end
end
TktNamedMark = TkTextNamedMark

# The "insert" mark - the text cursor position.
#
# This built-in mark shows where the blinking cursor appears when the
# text widget has focus. It cannot be deleted.
#
# @example Moving the cursor
#   insert = TkTextMarkInsert.new(text)
#   insert.set("1.0")           # Move cursor to start
#   insert.set("end - 1 char")  # Move to end
class TkTextMarkInsert<TkTextNamedMark
  def self.new(parent,*args)
    super(parent, 'insert', *args)
  end
end
TktMarkInsert = TkTextMarkInsert

# The "current" mark - tracks character nearest the mouse.
#
# This built-in mark automatically updates as the mouse moves over
# the text widget, except when mouse buttons are pressed.
# It cannot be deleted.
class TkTextMarkCurrent<TkTextNamedMark
  def self.new(parent,*args)
    super(parent, 'current', *args)
  end
end
TktMarkCurrent = TkTextMarkCurrent

# The "anchor" mark - selection anchor point.
#
# Used internally for tracking the start of a text selection.
class TkTextMarkAnchor<TkTextNamedMark
  def self.new(parent,*args)
    super(parent, 'anchor', *args)
  end
end
TktMarkAnchor = TkTextMarkAnchor

# Add deprecation warning for removed TMarkID_TBL constant
TkTextMark.extend(TkTextMarkCompat)
