# frozen_string_literal: true

module Tk
  module Core
    # Clean window manager interface for toplevel windows.
    # Replaces the old Tk::Wm module (which extended TkCore).
    #
    # All methods call tk_call('wm', ...) directly via Callable.
    module Wm
      def aspect(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'aspect', @path)).map(&:to_i)
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'aspect', @path, *args)
          self
        end
      end
      alias wm_aspect aspect

      def attributes(slot = nil, value = :_none_)
        if slot.nil?
          lst = TclTkLib._split_tklist(tk_call('wm', 'attributes', @path))
          info = {}
          while (key = lst.shift)
            info[key[1..-1]] = lst.shift
          end
          info
        elsif slot.is_a?(Hash)
          args = []
          slot.each { |k, v| args << "-#{k}" << v.to_s }
          tk_call('wm', 'attributes', @path, *args)
          self
        elsif value == :_none_
          tk_call('wm', 'attributes', @path, "-#{slot}")
        else
          tk_call('wm', 'attributes', @path, "-#{slot}", value)
          self
        end
      end
      alias wm_attributes attributes

      def client(name = :_none_)
        if name == :_none_
          tk_call('wm', 'client', @path)
        else
          name = '' if name.nil?
          tk_call('wm', 'client', @path, name)
          self
        end
      end
      alias wm_client client

      def colormapwindows(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'colormapwindows', @path))
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'colormapwindows', @path, *args)
          self
        end
      end
      alias wm_colormapwindows colormapwindows

      def wm_command(value = nil)
        if value
          tk_call('wm', 'command', @path, value)
          self
        else
          tk_call('wm', 'command', @path)
        end
      end

      def deiconify(ex = true)
        if ex
          tk_call('wm', 'deiconify', @path)
        else
          iconify
        end
        self
      end
      alias wm_deiconify deiconify

      def focusmodel(mode = nil)
        if mode
          tk_call('wm', 'focusmodel', @path, mode)
          self
        else
          tk_call('wm', 'focusmodel', @path)
        end
      end
      alias wm_focusmodel focusmodel

      def wm_forget
        tk_call('wm', 'forget', @path)
        self
      end

      def frame
        tk_call('wm', 'frame', @path)
      end
      alias wm_frame frame

      def geometry(geom = nil)
        if geom
          tk_call('wm', 'geometry', @path, geom)
          self
        else
          tk_call('wm', 'geometry', @path)
        end
      end
      alias wm_geometry geometry

      def wm_grid(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'grid', @path)).map(&:to_i)
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'grid', @path, *args)
          self
        end
      end

      def group(leader = nil)
        if leader
          tk_call('wm', 'group', @path, leader)
          self
        else
          tk_call('wm', 'group', @path)
        end
      end
      alias wm_group group

      def iconbitmap(bmp = nil)
        if bmp
          tk_call('wm', 'iconbitmap', @path, bmp)
          self
        else
          tk_call('wm', 'iconbitmap', @path)
        end
      end
      alias wm_iconbitmap iconbitmap

      def iconphoto(*imgs)
        if imgs.empty?
          @wm_iconphoto
        else
          imgs = imgs[0] if imgs.length == 1 && imgs[0].is_a?(Array)
          tk_call('wm', 'iconphoto', @path, *imgs)
          @wm_iconphoto = imgs
          self
        end
      end
      alias wm_iconphoto iconphoto

      def iconphoto_default(*imgs)
        imgs = imgs[0] if imgs.length == 1 && imgs[0].is_a?(Array)
        tk_call('wm', 'iconphoto', @path, '-default', *imgs)
        self
      end
      alias wm_iconphoto_default iconphoto_default

      def iconify(ex = true)
        if ex
          tk_call('wm', 'iconify', @path)
        else
          deiconify
        end
        self
      end
      alias wm_iconify iconify

      def iconmask(bmp = nil)
        if bmp
          tk_call('wm', 'iconmask', @path, bmp)
          self
        else
          tk_call('wm', 'iconmask', @path)
        end
      end
      alias wm_iconmask iconmask

      def iconname(name = nil)
        if name
          tk_call('wm', 'iconname', @path, name)
          self
        else
          tk_call('wm', 'iconname', @path)
        end
      end
      alias wm_iconname iconname

      def iconposition(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'iconposition', @path)).map(&:to_i)
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'iconposition', @path, *args)
          self
        end
      end
      alias wm_iconposition iconposition

      def iconwindow(iconwin = nil)
        if iconwin
          tk_call('wm', 'iconwindow', @path, iconwin)
          self
        else
          w = tk_call('wm', 'iconwindow', @path)
          w == '' ? nil : w
        end
      end
      alias wm_iconwindow iconwindow

      def wm_manage
        tk_call('wm', 'manage', @path)
        self
      end

      def maxsize(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'maxsize', @path)).map(&:to_i)
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'maxsize', @path, *args)
          self
        end
      end
      alias wm_maxsize maxsize

      def minsize(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'minsize', @path)).map(&:to_i)
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'minsize', @path, *args)
          self
        end
      end
      alias wm_minsize minsize

      def overrideredirect(mode = :_none_)
        if mode == :_none_
          tk_call('wm', 'overrideredirect', @path)
        else
          tk_call('wm', 'overrideredirect', @path, mode)
          self
        end
      end
      alias wm_overrideredirect overrideredirect

      def positionfrom(who = :_none_)
        if who == :_none_
          r = tk_call('wm', 'positionfrom', @path)
          r == '' ? nil : r
        else
          tk_call('wm', 'positionfrom', @path, who)
          self
        end
      end
      alias wm_positionfrom positionfrom

      def protocol(name = nil, cmd = nil, &b)
        if cmd
          tk_call('wm', 'protocol', @path, name, install_cmd(cmd))
          self
        elsif b
          tk_call('wm', 'protocol', @path, name, install_cmd(b))
          self
        elsif name
          tk_call('wm', 'protocol', @path, name)
        else
          TclTkLib._split_tklist(tk_call('wm', 'protocol', @path))
        end
      end
      alias wm_protocol protocol

      def protocols(kv = nil)
        unless kv
          ret = {}
          protocol.each { |name| ret[name] = protocol(name) }
          return ret
        end
        raise ArgumentError, 'expect a hash' unless kv.is_a?(Hash)
        kv.each { |k, v| protocol(k, v) }
        self
      end
      alias wm_protocols protocols

      def resizable(*args)
        if args.empty?
          TclTkLib._split_tklist(tk_call('wm', 'resizable', @path))
        else
          args = args[0] if args.length == 1 && args[0].is_a?(Array)
          tk_call('wm', 'resizable', @path, *args)
          self
        end
      end
      alias wm_resizable resizable

      def sizefrom(who = :_none_)
        if who == :_none_
          r = tk_call('wm', 'sizefrom', @path)
          r == '' ? nil : r
        else
          tk_call('wm', 'sizefrom', @path, who)
          self
        end
      end
      alias wm_sizefrom sizefrom

      def stackorder
        TclTkLib._split_tklist(tk_call('wm', 'stackorder', @path))
      end
      alias wm_stackorder stackorder

      def stackorder_isabove(target)
        tk_call('wm', 'stackorder', @path, 'isabove', target)
      end
      alias stackorder_is_above stackorder_isabove
      alias wm_stackorder_isabove stackorder_isabove
      alias wm_stackorder_is_above stackorder_isabove

      def stackorder_isbelow(target)
        tk_call('wm', 'stackorder', @path, 'isbelow', target)
      end
      alias stackorder_is_below stackorder_isbelow
      alias wm_stackorder_isbelow stackorder_isbelow
      alias wm_stackorder_is_below stackorder_isbelow

      def state(st = nil)
        if st
          tk_call('wm', 'state', @path, st)
          self
        else
          tk_call('wm', 'state', @path)
        end
      end
      alias wm_state state

      def title(str = nil)
        if str
          tk_call('wm', 'title', @path, str)
          self
        else
          tk_call('wm', 'title', @path)
        end
      end
      alias wm_title title

      def transient(master = nil)
        if master
          tk_call('wm', 'transient', @path, master)
          self
        else
          tk_call('wm', 'transient', @path)
        end
      end
      alias wm_transient transient

      def withdraw(ex = true)
        if ex
          tk_call('wm', 'withdraw', @path)
        else
          deiconify
        end
        self
      end
      alias wm_withdraw withdraw
    end
  end
end
