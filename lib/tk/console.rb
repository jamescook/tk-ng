# frozen_string_literal: false
#
#   tk/console.rb : control the console on system without a real console
#
require_relative 'core/callable'

module TkConsole
  extend Tk::Core::Callable
  extend TkUtil

  TkCommandNames = ['console'.freeze, 'consoleinterp'.freeze].freeze

  def self.create
    TkCore::INTERP.create_console
  end

  def self.title(str=None)
    tk_call 'console', 'title', str
  end
  def self.hide
    tk_call('console', 'hide')
  end
  def self.show
    tk_call('console', 'show')
  end
  def self.eval(tcl_script)
    #
    # supports a Tcl script only
    # I have no idea to support a Ruby script seamlessly.
    #
    tk_call('console', 'eval', tcl_script.to_s)
  end
  def self.maininterp_eval(tcl_script)
    #
    # supports a Tcl script only
    # I have no idea to support a Ruby script seamlessly.
    #
    tk_call('consoleinterp', 'eval', tcl_script.to_s)
  end
  def self.maininterp_record(tcl_script)
    #
    # supports a Tcl script only
    # I have no idea to support a Ruby script seamlessly.
    #
    tk_call('consoleinterp', 'record', tcl_script.to_s)
  end
end
