# frozen_string_literal: true

# Tests for lib/tk/pack.rb (TkPack module)

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestPack < Minitest::Test
  include TkTestHelper

  def test_tkpack_configure
    assert_tk_app("TkPack.configure", method(:app_tkpack_configure))
  end

  def app_tkpack_configure
    require 'tk'
    require 'tk/pack'

    errors = []

    btn = TkButton.new(root, text: "Pack me")
    TkPack.configure(btn, side: :left, padx: 5)

    errors << "button not packed" unless btn.winfo_manager == "pack"

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_configure_multiple
    assert_tk_app("TkPack.configure multiple", method(:app_tkpack_configure_multi))
  end

  def app_tkpack_configure_multi
    require 'tk'
    require 'tk/pack'

    errors = []

    btn1 = TkButton.new(root, text: "B1")
    btn2 = TkButton.new(root, text: "B2")
    btn3 = TkButton.new(root, text: "B3")

    TkPack.configure(btn1, btn2, btn3, side: :left)

    errors << "btn1 not packed" unless btn1.winfo_manager == "pack"
    errors << "btn2 not packed" unless btn2.winfo_manager == "pack"
    errors << "btn3 not packed" unless btn3.winfo_manager == "pack"

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_configure_no_widget_error
    assert_tk_app("TkPack.configure no widget error", method(:app_tkpack_no_widget))
  end

  def app_tkpack_no_widget
    require 'tk'
    require 'tk/pack'

    errors = []

    begin
      TkPack.configure()
      errors << "should raise ArgumentError for no widget"
    rescue ArgumentError => e
      errors << "wrong message" unless e.message == 'no widget is given'
    end

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_pack_alias
    assert_tk_app("TkPack.pack alias", method(:app_tkpack_pack_alias))
  end

  def app_tkpack_pack_alias
    require 'tk'
    require 'tk/pack'

    errors = []

    btn = TkButton.new(root, text: "Alias")
    TkPack.pack(btn, side: :top)

    errors << "button not packed via alias" unless btn.winfo_manager == "pack"

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_forget
    assert_tk_app("TkPack.forget", method(:app_tkpack_forget))
  end

  def app_tkpack_forget
    require 'tk'
    require 'tk/pack'

    errors = []

    btn = TkButton.new(root, text: "Forget me")
    TkPack.configure(btn, side: :top)
    errors << "button should be packed" unless btn.winfo_manager == "pack"

    TkPack.forget(btn)
    errors << "button should be forgotten" unless btn.winfo_manager == ""

    # forget with no args returns empty string
    result = TkPack.forget
    errors << "forget with no args should return ''" unless result == ''

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_info
    assert_tk_app("TkPack.info", method(:app_tkpack_info))
  end

  def app_tkpack_info
    require 'tk'
    require 'tk/pack'

    errors = []

    btn = TkButton.new(root, text: "Info test")
    TkPack.configure(btn, side: :left, padx: 10, pady: 5, fill: :both, expand: true)

    info = TkPack.info(btn)

    errors << "expected side left, got #{info['side']}" unless info['side'] == 'left'
    errors << "expected fill both, got #{info['fill']}" unless info['fill'] == 'both'
    errors << "expected expand 1, got #{info['expand']}" unless info['expand'].to_s == '1'

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_propagate
    assert_tk_app("TkPack.propagate", method(:app_tkpack_propagate))
  end

  def app_tkpack_propagate
    require 'tk'
    require 'tk/pack'

    errors = []

    frame = TkFrame.new(root)

    # Default is true
    result = TkPack.propagate(frame)
    errors << "default propagate should be true" unless result == true

    # Disable
    TkPack.propagate(frame, false)
    result = TkPack.propagate(frame)
    errors << "propagate should be false" unless result == false

    # Re-enable
    TkPack.propagate(frame, true)
    result = TkPack.propagate(frame)
    errors << "propagate should be true again" unless result == true

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkpack_slaves
    assert_tk_app("TkPack.slaves", method(:app_tkpack_slaves))
  end

  def app_tkpack_slaves
    require 'tk'
    require 'tk/pack'

    errors = []

    frame = TkFrame.new(root)
    btn1 = TkButton.new(frame, text: "S1")
    btn2 = TkButton.new(frame, text: "S2")

    TkPack.configure(btn1, side: :left)
    TkPack.configure(btn2, side: :left)

    slaves = TkPack.slaves(frame)
    errors << "expected 2 slaves, got #{slaves.size}" unless slaves.size == 2

    raise errors.join("\n") unless errors.empty?
  end
end
