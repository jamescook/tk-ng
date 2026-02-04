# frozen_string_literal: false
#
# tk/selection.rb : control selection
#

require_relative 'core/callable'

module TkSelection
  extend Tk::Core::Callable
  extend TkUtil

  TkCommandNames = ['selection'.freeze].freeze

  def self.clear(sel=nil)
    if sel
      tk_call('selection', 'clear', '-selection', sel)
    else
      tk_call('selection', 'clear')
    end
  end
  def self.clear_on_display(win, sel=nil)
    if sel
      tk_call('selection', 'clear',
                          '-displayof', win, '-selection', sel)
    else
      tk_call('selection', 'clear', '-displayof', win)
    end
  end
  def clear(sel=nil)
    TkSelection.clear_on_display(self, sel)
    self
  end

  def self.get(keys=nil)
    tk_call('selection', 'get', *hash_kv(keys))
  end
  def self.get_on_display(win, keys=nil)
    tk_call('selection', 'get', '-displayof', win, *hash_kv(keys))
  end
  def get(keys=nil)
    TkSelection.get_on_display(self, keys)
  end

  def self.handle(win, func=nil, keys=nil, &b)
    func ||= b
    if func.kind_of?(Hash) && keys == nil
      keys = func
      func = b
    end
    args = ['selection', 'handle']
    args.concat(hash_kv(keys))
    args.concat([win, func])
    tk_call(*args)
  end
  def handle(func=nil, keys=nil, &b)
    TkSelection.handle(self, func || b, keys, &b)
  end

  def self.get_owner(sel=nil)
    id = if sel
      tk_call('selection', 'own', '-selection', sel)
    else
      tk_call('selection', 'own')
    end
    TkCore::INTERP.tk_windows[id] || id
  end
  def self.get_owner_on_display(win, sel=nil)
    id = if sel
      tk_call('selection', 'own', '-displayof', win, '-selection', sel)
    else
      tk_call('selection', 'own', '-displayof', win)
    end
    TkCore::INTERP.tk_windows[id] || id
  end
  def get_owner(sel=nil)
    TkSelection.get_owner_on_display(self, sel)
    self
  end

  def self.set_owner(win, keys=nil)
    tk_call('selection', 'own', *(hash_kv(keys) << win))
  end
  def set_owner(keys=nil)
    TkSelection.set_owner(self, keys)
    self
  end
end
