# frozen_string_literal: true

# Tests for lib/tk/place.rb (TkPlace module)

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestPlace < Minitest::Test
  include TkTestHelper

  def test_tkplace_configure_hash
    assert_tk_app("TkPlace.configure with hash", method(:app_tkplace_configure_hash))
  end

  def app_tkplace_configure_hash
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Place me")
    TkPlace.configure(btn, x: 100, y: 50)

    errors << "button not placed" unless btn.winfo_manager == "place"

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_configure_slot_value
    assert_tk_app("TkPlace.configure with slot/value", method(:app_tkplace_configure_slot))
  end

  def app_tkplace_configure_slot
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Slot test")
    TkPlace.configure(btn, x: 10, y: 10)

    # Reconfigure with slot/value form
    TkPlace.configure(btn, 'x', 200)

    info = TkPlace.info(btn)
    errors << "expected x=200, got #{info['x']}" unless info['x'].to_i == 200

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_place_alias
    assert_tk_app("TkPlace.place alias", method(:app_tkplace_place_alias))
  end

  def app_tkplace_place_alias
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Alias")
    TkPlace.place(btn, x: 50, y: 50)

    errors << "button not placed via alias" unless btn.winfo_manager == "place"

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_forget
    assert_tk_app("TkPlace.forget", method(:app_tkplace_forget))
  end

  def app_tkplace_forget
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Forget me")
    TkPlace.configure(btn, x: 10, y: 10)
    errors << "button should be placed" unless btn.winfo_manager == "place"

    TkPlace.forget(btn)
    errors << "button should be forgotten" unless btn.winfo_manager == ""

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_info
    assert_tk_app("TkPlace.info", method(:app_tkplace_info))
  end

  def app_tkplace_info
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Info test")
    TkPlace.configure(btn, x: 100, y: 200, anchor: :nw)

    info = TkPlace.info(btn)

    errors << "expected x 100, got #{info['x']}" unless info['x'].to_i == 100
    errors << "expected y 200, got #{info['y']}" unless info['y'].to_i == 200
    errors << "expected anchor nw, got #{info['anchor']}" unless info['anchor'].to_s == 'nw'

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_info_relative
    assert_tk_app("TkPlace.info relative positioning", method(:app_tkplace_info_relative))
  end

  def app_tkplace_info_relative
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Relative")
    TkPlace.configure(btn, relx: 0.5, rely: 0.5, anchor: :center)

    info = TkPlace.info(btn)

    errors << "expected relx 0.5, got #{info['relx']}" unless info['relx'].to_f == 0.5
    errors << "expected rely 0.5, got #{info['rely']}" unless info['rely'].to_f == 0.5

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_configinfo
    assert_tk_app("TkPlace.configinfo", method(:app_tkplace_configinfo))
  end

  def app_tkplace_configinfo
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Configinfo")
    TkPlace.configure(btn, x: 50, y: 75)

    # Single slot
    conf = TkPlace.configinfo(btn, :x)
    errors << "configinfo slot should return array" unless conf.is_a?(Array)
    errors << "configinfo slot[0] should be 'x', got #{conf[0]}" unless conf[0] == 'x'

    # All slots
    all = TkPlace.configinfo(btn)
    errors << "configinfo all should return array of arrays" unless all.is_a?(Array) && all[0].is_a?(Array)

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_current_configinfo
    assert_tk_app("TkPlace.current_configinfo", method(:app_tkplace_current_configinfo))
  end

  def app_tkplace_current_configinfo
    require 'tk'
    require 'tk/place'

    errors = []

    btn = TkButton.new(root, text: "Current")
    TkPlace.configure(btn, x: 30, y: 40)

    # Single slot
    info = TkPlace.current_configinfo(btn, :x)
    errors << "current_configinfo should return hash" unless info.is_a?(Hash)
    errors << "expected x key" unless info.key?('x')

    # All slots
    all = TkPlace.current_configinfo(btn)
    errors << "current_configinfo all should return hash" unless all.is_a?(Hash)
    errors << "expected x in all" unless all.key?('x')
    errors << "expected y in all" unless all.key?('y')

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_slaves
    assert_tk_app("TkPlace.slaves", method(:app_tkplace_slaves))
  end

  def app_tkplace_slaves
    require 'tk'
    require 'tk/place'

    errors = []

    frame = TkFrame.new(root, width: 200, height: 200)
    frame.pack
    btn1 = TkButton.new(frame, text: "S1")
    btn2 = TkButton.new(frame, text: "S2")

    TkPlace.configure(btn1, x: 0, y: 0)
    TkPlace.configure(btn2, x: 50, y: 50)

    slaves = TkPlace.slaves(frame)
    errors << "expected 2 slaves, got #{slaves.size}" unless slaves.size == 2

    raise errors.join("\n") unless errors.empty?
  end

  def test_tkplace_in_container
    assert_tk_app("TkPlace with in: container", method(:app_tkplace_in_container))
  end

  def app_tkplace_in_container
    require 'tk'
    require 'tk/place'

    errors = []

    frame = TkFrame.new(root, width: 200, height: 200)
    frame.pack
    btn = TkButton.new(root, text: "In frame")

    TkPlace.configure(btn, in: frame, x: 10, y: 10)

    info = TkPlace.info(btn)
    errors << "expected in to reference frame" unless info['in']

    raise errors.join("\n") unless errors.empty?
  end
end
