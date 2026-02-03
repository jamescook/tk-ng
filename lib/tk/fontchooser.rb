# frozen_string_literal: true
#
# tk/fontchooser.rb -- "tk fontchooser" support (Tcl/Tk8.6 or later)
#
require 'tk'
require_relative 'core/callable'
require_relative 'callback'

module TkFont::Chooser
  extend Tk::Core::Callable

  class << self
    def configure(options)
      args = options.flat_map { |k, v| ["-#{k}", v] }
      tk_call('tk', 'fontchooser', 'configure', *args)
      self
    end

    def parent
      val = tk_call('tk', 'fontchooser', 'configure', '-parent')
      (val =~ /^\./) ? (TkCore::INTERP.tk_windows[val] || val) : nil
    end

    def parent=(val)
      tk_call('tk', 'fontchooser', 'configure', '-parent', val)
    end

    def title
      tk_call('tk', 'fontchooser', 'configure', '-title')
    end

    def title=(val)
      tk_call('tk', 'fontchooser', 'configure', '-title', val)
    end

    def font
      tk_call('tk', 'fontchooser', 'configure', '-font')
    end

    def font=(val)
      tk_call('tk', 'fontchooser', 'configure', '-font', val)
    end

    def visible
      TkUtil.bool(tk_call('tk', 'fontchooser', 'configure', '-visible'))
    end
    alias visible? visible

    def command(cmd = nil, &block)
      if cmd || block
        tk_call('tk', 'fontchooser', 'configure', '-command', TkCallback.install_cmd(cmd || block))
      else
        tk_call('tk', 'fontchooser', 'configure', '-command')
      end
    end

    def command=(cmd)
      command(cmd)
    end

    # Bracket accessors
    def [](key)
      send(key)
    end

    def []=(key, val)
      send("#{key}=", val)
    end

    # Aliases for old API
    alias cget []

    def show
      tk_call('tk', 'fontchooser', 'show')
      self
    end

    def hide
      tk_call('tk', 'fontchooser', 'hide')
      self
    end

    def toggle
      visible? ? hide : show
    end
  end
end

module Tk
  Fontchooser = TkFont::Chooser
end
