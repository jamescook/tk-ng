# frozen_string_literal: true

# Tests for TkVirtualEvent - virtual event handling
#
# TkVirtualEvent wraps Tcl/Tk's event command for defining and managing
# virtual events (application-defined events triggered by physical sequences).
#
# See: https://www.tcl-lang.org/man/tcl8.6/TkCmd/event.htm

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestVirtEvent < Minitest::Test
  include TkTestHelper

  def test_create_virtual_event
    assert_tk_app("VirtualEvent create", method(:create_app))
  end

  def create_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    # Create a virtual event with a sequence
    ve = TkVirtualEvent.new('Control-x')
    errors << "should have path" unless ve.path
    errors << "path should be wrapped in <>: #{ve.path}" unless ve.path =~ /^<.*>$/

    raise errors.join("\n") unless errors.empty?
  end

  def test_create_with_multiple_sequences
    assert_tk_app("VirtualEvent multiple sequences", method(:multi_seq_app))
  end

  def multi_seq_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    ve = TkVirtualEvent.new('Control-s', 'F2')
    seqs = ve.info
    errors << "should have 2 sequences, got #{seqs.size}" unless seqs.size == 2

    raise errors.join("\n") unless errors.empty?
  end

  def test_add_sequence
    assert_tk_app("VirtualEvent add sequence", method(:add_seq_app))
  end

  def add_seq_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    ve = TkVirtualEvent.new('Control-a')
    ve.add('Control-b')
    seqs = ve.info
    errors << "should have 2 sequences after add, got #{seqs.size}" unless seqs.size == 2

    raise errors.join("\n") unless errors.empty?
  end

  def test_delete_sequence
    assert_tk_app("VirtualEvent delete sequence", method(:delete_seq_app))
  end

  def delete_seq_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    ve = TkVirtualEvent.new('Control-a', 'Control-b')
    ve.delete('Control-b')
    seqs = ve.info
    errors << "should have 1 sequence after delete, got #{seqs.size}" unless seqs.size == 1

    raise errors.join("\n") unless errors.empty?
  end

  def test_delete_all
    assert_tk_app("VirtualEvent delete all", method(:delete_all_app))
  end

  def delete_all_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    ve = TkVirtualEvent.new('Control-z')
    ve.delete

    # After deleting all, info on the event should be empty or raise
    begin
      seqs = ve.info
      errors << "info should be empty after delete all" unless seqs.empty?
    rescue TclTkLib::TclError
      # Expected - event no longer exists
    end

    raise errors.join("\n") unless errors.empty?
  end

  def test_info_class_method
    assert_tk_app("VirtualEvent class info", method(:class_info_app))
  end

  def class_info_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    # Class-level info returns all defined virtual events
    all = TkVirtualEvent.info
    errors << "info should return Array" unless all.is_a?(Array)
    # Tk always has some predefined virtual events
    errors << "should have predefined events" if all.empty?

    raise errors.join("\n") unless errors.empty?
  end

  def test_getobj
    assert_tk_app("VirtualEvent getobj", method(:getobj_app))
  end

  def getobj_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    # getobj for a predefined event (Copy exists on all platforms)
    obj = TkVirtualEvent.getobj("Copy")
    errors << "getobj should return TkVirtualEvent" unless obj.is_a?(TkVirtualEvent)

    # getobj for nonexistent should raise
    begin
      TkVirtualEvent.getobj("TotallyFakeEvent12345")
      errors << "getobj for nonexistent should raise"
    rescue ArgumentError
      # Expected
    end

    raise errors.join("\n") unless errors.empty?
  end

  def test_bind_to_virtual_event
    assert_tk_app("VirtualEvent bind to widget", method(:bind_app))
  end

  def bind_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    ve = TkVirtualEvent.new('Control-t')
    btn = TkButton.new(root)
    btn.bind(ve.path) { }

    # Generate the virtual event
    btn.event_generate(ve.path)
    Tk.update

    ve.delete

    raise errors.join("\n") unless errors.empty?
  end

  def test_predef_virtual_event
    assert_tk_app("PreDefVirtEvent", method(:predef_app))
  end

  def predef_app
    require 'tk'
    require 'tk/virtevent'

    errors = []

    # PreDefVirtEvent wraps existing platform events
    copy = TkVirtualEvent::PreDefVirtEvent.new("Copy")
    errors << "should have path" unless copy.path
    errors << "path should contain Copy, got '#{copy.path}'" unless copy.path.include?("Copy")

    # Creating same event again should return cached instance
    copy2 = TkVirtualEvent::PreDefVirtEvent.new("Copy")
    errors << "should return same object" unless copy2.equal?(copy) || copy2.path == copy.path

    raise errors.join("\n") unless errors.empty?
  end
end
