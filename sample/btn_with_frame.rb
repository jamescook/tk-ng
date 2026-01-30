# frozen_string_literal: false
require 'tk'

class Button_with_Frame < TkButton
  def create_self(keys)
    @frame = TkFrame.new('widgetname'=>@path, 'background'=>'yellow')
    install_win(@path) # create new @path which is a daughter of old @path
    super(keys)
    TkPack(@path, :padx=>7, :pady=>7)
    @epath = @frame.path
  end
  def epath
    @epath
  end
end

btn = Button_with_Frame.new(:text=>'QUIT', :command=>proc{
  puts 'QUIT clicked'
  exit
}) {
  pack(:padx=>15, :pady=>5)
}

# Smoke test support
require 'tk/demo_support'
if TkDemo.active?
  TkDemo.on_visible {
    # Don't invoke QUIT - it calls exit which is unsafe from callback
    puts 'UI loaded'
    TkDemo.finish
  }
end

Tk.mainloop
