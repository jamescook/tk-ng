# frozen_string_literal: false

module Tk
  # Window Manager interface for toplevel windows.
  #
  # The Wm module provides methods to control window behavior through
  # the window manager: title, geometry, iconification, resize constraints,
  # and platform-specific attributes.
  #
  # This module is mixed into {Tk::Root} and {TkToplevel}.
  #
  # ## Common Methods
  #
  # - {#title} - Get/set window title bar text
  # - {#geometry} - Get/set window size and position ("WxH+X+Y")
  # - {#iconify} - Minimize window to taskbar/dock
  # - {#deiconify} - Restore window from minimized state
  # - {#withdraw} - Hide window completely (still exists, just invisible)
  # - {#state} - Get/set window state ("normal", "iconic", "withdrawn", "zoomed")
  # - {#resizable} - Control whether user can resize window
  # - {#minsize}/{#maxsize} - Set size constraints
  # - {#protocol} - Handle window manager events (e.g., WM_DELETE_WINDOW)
  # - {#attributes} - Platform-specific attributes (alpha, fullscreen, topmost)
  #
  # ## Terminology
  #
  # - **iconify** = minimize to taskbar/dock
  # - **deiconify** = restore from minimized (raise + focus on Windows)
  # - **withdraw** = hide completely (no taskbar icon, still exists)
  # - **transient** = dialog-like window that follows its master
  #
  # @example Basic window setup
  #   root = Tk::Root.new
  #   root.title = "My Application"
  #   root.geometry = "800x600+100+100"  # 800x600 at position (100,100)
  #   root.minsize(400, 300)
  #
  # @example Handling window close
  #   root.protocol('WM_DELETE_WINDOW') do
  #     if confirm_quit?
  #       root.destroy
  #     end
  #   end
  #
  # @example Window states
  #   root.iconify            # Minimize
  #   root.deiconify          # Restore
  #   root.withdraw           # Hide completely
  #   root.state              # => "normal"
  #   root.state = "zoomed"   # Maximize (platform-dependent)
  #
  # @example Platform-specific attributes
  #   root.attributes(alpha: 0.9)       # 90% opacity
  #   root.attributes(topmost: true)    # Always on top
  #   root.attributes(fullscreen: true) # Fullscreen mode
  #
  # @note **Platform differences**: Some attributes behave differently or
  #   are unavailable on certain platforms. `deiconify` on Windows also
  #   raises and focuses the window. `zoomed` state handling varies.
  #
  # @note **Window manager quirks**: Some changes may not take effect
  #   immediately due to window manager async behavior. Try withdraw +
  #   deiconify to force updates.
  #
  # @see Tk::Root The main application window
  # @see TkToplevel Additional toplevel windows
  # @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/wm.htm Tcl/Tk wm manual
  module Wm
    #include TkComm
    extend TkCore

    TkCommandNames = ['wm'.freeze].freeze

    # Gets or sets aspect ratio constraints for a window.
    #
    # Aspect ratio is expressed as a range from minNumer/minDenom to
    # maxNumer/maxDenom. The window manager will enforce these constraints
    # during interactive resizing.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Integer>] Four integers: minNumer, minDenom, maxNumer, maxDenom
    # @return [Array<Integer>, TkWindow] Current aspect values if querying, window if setting
    # @example Constrain to 4:3 aspect ratio
    #   win.aspect(4, 3, 4, 3)
    # @example Allow range from 4:3 to 16:9
    #   win.aspect(4, 3, 16, 9)
    # @example Remove constraints
    #   win.aspect('', '', '', '')
    def Wm.aspect(win, *args)
      if args.length == 0
        list(tk_call_without_enc('wm', 'aspect', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call('wm', 'aspect', win.epath, *args)
        win
      end
    end
    # @see Wm.aspect
    def aspect(*args)
      Wm.aspect(self, *args)
    end
    alias wm_aspect aspect

    # Gets or sets platform-specific window attributes.
    #
    # ## Cross-platform attributes
    # - **alpha** (Float 0.0-1.0) - Window transparency (1.0 = opaque)
    # - **fullscreen** (Boolean) - Fullscreen mode
    # - **topmost** (Boolean) - Always on top of other windows
    #
    # ## Windows-only
    # - **disabled** (Boolean) - Disable all input to window
    # - **toolwindow** (Boolean) - Smaller titlebar, omit from taskbar
    # - **transparentcolor** (String) - Color to render as transparent
    #
    # ## macOS-only
    # - **modified** (Boolean) - Show unsaved indicator in close button
    # - **notify** (Boolean) - Bounce dock icon for attention
    # - **titlepath** (String) - Proxy icon file path
    # - **transparent** (Boolean) - Transparent background
    #
    # ## X11-only
    # - **type** (String) - Window type hint (desktop, dock, toolbar, menu,
    #   utility, splash, dialog, dropdown_menu, popup_menu, tooltip,
    #   notification, combo, dnd, normal)
    # - **zoomed** (Boolean) - Maximized state
    #
    # @param win [TkWindow] Window to configure
    # @param slot [Symbol, String, Hash, nil] Attribute name, hash of attributes, or nil to query all
    # @param value [Object] Value to set (when slot is a single attribute name)
    # @return [Hash, Object, TkWindow] All attributes if querying all, single value if querying one, window if setting
    # @example Query all attributes
    #   win.attributes  # => {"alpha" => 1.0, "fullscreen" => false, ...}
    # @example Query single attribute
    #   win.attributes(:alpha)  # => 1.0
    # @example Set single attribute
    #   win.attributes(:alpha, 0.9)
    # @example Set multiple attributes
    #   win.attributes(alpha: 0.9, topmost: true)
    def Wm.attributes(win, slot=nil,value=TkComm::None)
      if slot == nil
        lst = tk_split_list(tk_call('wm', 'attributes', win.epath))
        info = {}
        while key = lst.shift
          info[key[1..-1]] = lst.shift
        end
        info
      elsif slot.kind_of? Hash
        tk_call('wm', 'attributes', win.epath, *hash_kv(slot))
        win
      elsif value == TkComm::None
        tk_call('wm', 'attributes', win.epath, "-#{slot}")
      else
        tk_call('wm', 'attributes', win.epath, "-#{slot}", value)
        win
      end
    end
    # @see Wm.attributes
    def attributes(slot=nil,value=TkComm::None)
      Wm.attributes(self, slot, value)
    end
    alias wm_attributes attributes

    # Gets or sets the WM_CLIENT_MACHINE property.
    #
    # This property stores the hostname of the machine running the application.
    # Used by some window managers and session managers for identification.
    #
    # @param win [TkWindow] Window to configure
    # @param name [String, nil] Hostname to set, nil/empty to clear, omit to query
    # @return [String, TkWindow] Current hostname if querying, window if setting
    def Wm.client(win, name=TkComm::None)
      if name == TkComm::None
        tk_call('wm', 'client', win.epath)
      else
        name = '' if name == nil
        tk_call('wm', 'client', win.epath, name)
        win
      end
    end
    # @see Wm.client
    def client(name=TkComm::None)
      Wm.client(self, name)
    end
    alias wm_client client

    # Gets or sets the WM_COLORMAP_WINDOWS property.
    #
    # Manages windows with private colormaps. The window manager installs
    # colormaps in priority order from this list. Rarely needed on modern
    # systems with true-color displays.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<TkWindow>] Windows with private colormaps
    # @return [Array, TkWindow] Current list if querying, window if setting
    def Wm.colormapwindows(win, *args)
      if args.size == 0
        list(tk_call_without_enc('wm', 'colormapwindows', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'colormapwindows', win.epath, *args)
        win
      end
    end
    # @see Wm.colormapwindows
    def colormapwindows(*args)
      Wm.colormapwindows(self, *args)
    end
    alias wm_colormapwindows colormapwindows

    # Gets or sets the WM_COMMAND property.
    #
    # Stores the command line used to invoke the application. Used by
    # session managers to restart applications. Value should be a proper
    # list representing command-line arguments.
    #
    # @param win [TkWindow] Window to configure
    # @param value [String, nil] Command string, or nil to query
    # @return [String, TkWindow] Current command if querying, window if setting
    def Wm.command(win, value=nil)
      if value
        tk_call('wm', 'command', win.epath, value)
        win
      else
        #procedure(tk_call('wm', 'command', win.epath))
        tk_call('wm', 'command', win.epath)
      end
    end
    # @see Wm.command
    def wm_command(value=nil)
      Wm.command(self, value)
    end

    # Restores a window from minimized (iconic) state.
    #
    # "Deiconify" = restore from minimized. The window becomes visible
    # and usable again.
    #
    # @param win [TkWindow] Window to deiconify
    # @param ex [Boolean] true to deiconify, false to iconify
    # @return [TkWindow] The window
    # @note On Windows, deiconify also raises the window and gives it focus.
    def Wm.deiconify(win, ex = true)
      if ex
        tk_call_without_enc('wm', 'deiconify', win.epath)
      else
        Wm.iconify(win)
      end
      win
    end
    # Restores this window from minimized state.
    # @see Wm.deiconify
    def deiconify(ex = true)
      Wm.deiconify(self, ex)
    end
    alias wm_deiconify deiconify

    # Gets or sets the input focus model.
    #
    # - **active**: Window claims focus itself when clicked
    # - **passive** (default): Window manager decides when to grant focus
    #
    # Tk generally assumes passive focusing. Most applications don't need
    # to change this.
    #
    # @param win [TkWindow] Window to configure
    # @param mode [String, nil] "active" or "passive", or nil to query
    # @return [String, TkWindow] Current mode if querying, window if setting
    def Wm.focusmodel(win, mode = nil)
      if mode
        tk_call_without_enc('wm', 'focusmodel', win.epath, mode)
        win
      else
        tk_call_without_enc('wm', 'focusmodel', win.epath)
      end
    end
    # @see Wm.focusmodel
    def focusmodel(mode = nil)
      Wm.focusmodel(self, mode)
    end
    alias wm_focusmodel focusmodel

    # Removes a window from window manager control.
    #
    # The window is unmapped and becomes a frame-like widget that can be
    # re-parented into another container. Use {#wm_manage} to restore
    # window manager control.
    #
    # @param win [TkWindow] Window to forget
    # @return [TkWindow] The window
    # @note Requires Tcl/Tk 8.5+
    def Wm.forget(win)
      # Tcl/Tk 8.5+
      # work with dockable frames
      tk_call_without_enc('wm', 'forget', win.epath)
      win
    end
    # @see Wm.forget
    def wm_forget
      Wm.forget(self)
    end

    # Returns the platform-specific window identifier.
    #
    # If the window manager reparented this window into a decorative frame,
    # returns the ID of that outermost frame. Otherwise returns the window's
    # own ID.
    #
    # @param win [TkWindow] Window to query
    # @return [String] Platform-specific window identifier
    def Wm.frame(win)
      tk_call_without_enc('wm', 'frame', win.epath)
    end
    # @see Wm.frame
    def frame
      Wm.frame(self)
    end
    alias wm_frame frame

    # Gets or sets window geometry (size and position).
    #
    # Geometry format: "WxH+X+Y" or "WxH" or "+X+Y"
    # - W = width in pixels
    # - H = height in pixels
    # - X = horizontal position (+ from left, - from right)
    # - Y = vertical position (+ from top, - from bottom)
    #
    # @param win [TkWindow] Window to configure
    # @param geom [String, nil] Geometry string, or nil to query
    # @return [String, TkWindow] Current geometry if querying, window if setting
    # @example
    #   win.geometry = "800x600+100+100"  # 800x600 at (100, 100)
    #   win.geometry = "800x600"          # Size only, position unchanged
    #   win.geometry = "+100+100"         # Position only, size unchanged
    #   win.geometry                      # => "800x600+100+100"
    def Wm.geometry(win, geom=nil)
      if geom
        tk_call_without_enc('wm', 'geometry', win.epath, geom)
        win
      else
        tk_call_without_enc('wm', 'geometry', win.epath)
      end
    end
    # @see Wm.geometry
    def geometry(geom=nil)
      Wm.geometry(self, geom)
    end
    alias wm_geometry geometry

    # Configures gridded geometry management.
    #
    # Gridded windows resize in discrete increments (grid units) rather than
    # pixels. Useful for terminal emulators or text editors where size should
    # be in character units.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Integer>] baseWidth, baseHeight, widthInc, heightInc
    # @return [Array<Integer>, TkWindow] Current grid values if querying, window if setting
    # @example Set up character-based grid (10px wide, 16px tall characters)
    #   win.wm_grid(0, 0, 10, 16)
    # @example Disable gridded geometry
    #   win.wm_grid('', '', '', '')
    def Wm.grid(win, *args)
      if args.size == 0
        list(tk_call_without_enc('wm', 'grid', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'grid', win.epath, *args)
        win
      end
    end
    # @see Wm.grid
    def wm_grid(*args)
      Wm.grid(self, *args)
    end

    # Gets or sets the window group leader.
    #
    # Associates this window with a group leader. The window manager may
    # iconify/deiconify grouped windows together. Commonly used to keep
    # dialogs associated with their parent window.
    #
    # @param win [TkWindow] Window to configure
    # @param leader [TkWindow, nil] Group leader window, or nil to query
    # @return [TkWindow, nil] Current leader if querying, window if setting
    # @example Associate dialog with main window
    #   dialog.group(main_window)
    def Wm.group(win, leader = nil)
      if leader
        tk_call('wm', 'group', win.epath, leader)
        win
      else
        window(tk_call('wm', 'group', win.epath))
      end
    end
    # @see Wm.group
    def group(leader = nil)
      Wm.group(self, leader)
    end
    alias wm_group group

    # Gets or sets the window icon bitmap.
    #
    # On Windows, can accept full paths to .ico or .icr files. On X11,
    # accepts standard Tk bitmap names or files.
    #
    # @param win [TkWindow] Window to configure
    # @param bmp [String, nil] Bitmap name or file path, or nil to query
    # @return [Object, TkWindow] Current bitmap if querying, window if setting
    # @note For modern applications, prefer {#iconphoto} which accepts photo images
    def Wm.iconbitmap(win, bmp=nil)
      if bmp
        tk_call_without_enc('wm', 'iconbitmap', win.epath, bmp)
        win
      else
        image_obj(tk_call_without_enc('wm', 'iconbitmap', win.epath))
      end
    end
    # @see Wm.iconbitmap
    def iconbitmap(bmp=nil)
      Wm.iconbitmap(self, bmp)
    end
    alias wm_iconbitmap iconbitmap

    # Sets the window icon from photo images.
    #
    # Provide multiple images at different sizes for best results across
    # different contexts (taskbar, alt-tab, title bar). The window manager
    # chooses the most appropriate size.
    #
    # Image data is captured at call time; subsequent changes to the
    # image objects won't affect the icon.
    #
    # @param win [TkWindow] Window to configure
    # @param imgs [Array<TkPhotoImage>] One or more photo images
    # @return [Array, TkWindow] Current images if querying (empty call), window if setting
    # @example Set icon with multiple sizes
    #   icon16 = TkPhotoImage.new(file: 'icon16.png')
    #   icon32 = TkPhotoImage.new(file: 'icon32.png')
    #   win.iconphoto(icon16, icon32)
    # @note On macOS, only the first image is used
    def Wm.iconphoto(win, *imgs)
      if imgs.empty?
        win.instance_eval{
          @wm_iconphoto = nil unless defined? @wm_iconphoto
          return @wm_iconphoto
        }
      end

      imgs = imgs[0] if imgs.length == 1 && imgs[0].kind_of?(Array)
      tk_call_without_enc('wm', 'iconphoto', win.epath, *imgs)
      win.instance_eval{ @wm_iconphoto = imgs  }
      win
    end
    # @see Wm.iconphoto
    def iconphoto(*imgs)
      Wm.iconphoto(self, *imgs)
    end
    alias wm_iconphoto iconphoto

    # Sets the default icon for all future toplevel windows.
    #
    # Same as {#iconphoto} but applies to all toplevels created after
    # this call, not just the specified window.
    #
    # @param win [TkWindow] Any toplevel window
    # @param imgs [Array<TkPhotoImage>] One or more photo images
    # @return [TkWindow] The window
    def Wm.iconphoto_default(win, *imgs)
      imgs = imgs[0] if imgs.length == 1 && imgs[0].kind_of?(Array)
      tk_call_without_enc('wm', 'iconphoto', win.epath, '-default', *imgs)
      win
    end
    # @see Wm.iconphoto_default
    def iconphoto_default(*imgs)
      Wm.iconphoto_default(self, *imgs)
    end
    alias wm_iconphoto_default iconphoto_default

    # Minimizes a window to the taskbar/dock.
    #
    # "Iconify" = minimize. The window is hidden but still exists,
    # represented by an icon in the taskbar or dock.
    #
    # @param win [TkWindow] Window to iconify
    # @param ex [Boolean] true to iconify, false to deiconify
    # @return [TkWindow] The window
    def Wm.iconify(win, ex = true)
      if ex
        tk_call_without_enc('wm', 'iconify', win.epath)
      else
        Wm.deiconify(win)
      end
      win
    end
    # Minimizes this window to taskbar/dock.
    # @see Wm.iconify
    def iconify(ex = true)
      Wm.iconify(self, ex)
    end
    alias wm_iconify iconify

    # Gets or sets the icon mask bitmap.
    #
    # The mask determines which pixels of the icon bitmap are displayed.
    # Where the mask has zeros, nothing displays; where ones, the icon
    # bitmap shows through.
    #
    # @param win [TkWindow] Window to configure
    # @param bmp [String, nil] Bitmap name or file, or nil to query
    # @return [Object, TkWindow] Current mask if querying, window if setting
    # @note Rarely used on modern systems; prefer {#iconphoto} with PNG images
    def Wm.iconmask(win, bmp=nil)
      if bmp
        tk_call_without_enc('wm', 'iconmask', win.epath, bmp)
        win
      else
        image_obj(tk_call_without_enc('wm', 'iconmask', win.epath))
      end
    end
    # @see Wm.iconmask
    def iconmask(bmp=nil)
      Wm.iconmask(self, bmp)
    end
    alias wm_iconmask iconmask

    # Gets or sets the text displayed with the window's icon.
    #
    # When the window is iconified/minimized, this name may be displayed
    # below or near the icon. If not set, the window title is used.
    #
    # @param win [TkWindow] Window to configure
    # @param name [String, nil] Icon label text, or nil to query
    # @return [String, TkWindow] Current name if querying, window if setting
    def Wm.iconname(win, name=nil)
      if name
        tk_call('wm', 'iconname', win.epath, name)
        win
      else
        tk_call('wm', 'iconname', win.epath)
      end
    end
    # @see Wm.iconname
    def iconname(name=nil)
      Wm.iconname(self, name)
    end
    alias wm_iconname iconname

    # Gets or sets icon position hints.
    #
    # Suggests where the window manager should place the icon when the
    # window is iconified. The window manager may ignore this hint.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Integer>] x, y coordinates for icon placement
    # @return [Array<Integer>, TkWindow] Current position if querying, window if setting
    def Wm.iconposition(win, *args)
      if args.size == 0
        list(tk_call_without_enc('wm', 'iconposition', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'iconposition', win.epath, *args)
        win
      end
    end
    # @see Wm.iconposition
    def iconposition(*args)
      Wm.iconposition(self, *args)
    end
    alias wm_iconposition iconposition

    # Gets or sets a window to use as the icon.
    #
    # When this window is iconified, the specified icon window is mapped
    # in its place. When deiconified, the icon window is unmapped.
    #
    # @param win [TkWindow] Window to configure
    # @param iconwin [TkWindow, nil] Window to use as icon, or nil to query
    # @return [TkWindow, nil] Current icon window if querying, window if setting
    # @note X11-only feature; not supported on Windows or macOS
    def Wm.iconwindow(win, iconwin = nil)
      if iconwin
        tk_call_without_enc('wm', 'iconwindow', win.epath, iconwin)
        win
      else
        w = tk_call_without_enc('wm', 'iconwindow', win.epath)
        (w == '')? nil: window(w)
      end
    end
    # @see Wm.iconwindow
    def iconwindow(iconwin = nil)
      Wm.iconwindow(self, iconwin)
    end
    alias wm_iconwindow iconwindow

    # Converts a frame widget into a toplevel window.
    #
    # Takes a frame, labelframe, or toplevel widget and gives it window
    # manager decorations (title bar, borders, etc.). Use {#wm_forget}
    # to reverse this operation.
    #
    # @param win [TkWindow] Frame or labelframe widget to manage
    # @return [TkWindow] The window
    # @note Requires Tcl/Tk 8.5+
    # @note Only works with frame, labelframe, and toplevel widgets
    def Wm.manage(win)
      # Tcl/Tk 8.5+ feature
      tk_call_without_enc('wm', 'manage', win.epath)
      win
    end
    # @see Wm.manage
    def wm_manage
      Wm.manage(self)
    end
=begin
    def Wm.manage(win, use_id = nil)
      # Tcl/Tk 8.5+ feature
      # --------------------------------------------------------------
      # In the future release, I want to support to embed the 'win'
      # into the container which has window-id 'use-id'.
      # It may give users flexibility on controlling their GUI.
      # However, it may be difficult for current Tcl/Tk (Tcl/Tk8.5.1),
      # because it seems to require to modify Tcl/Tk's source code.
      # --------------------------------------------------------------
      if use_id
        tk_call_without_enc('wm', 'manage', win.epath, '-use', use_id)
      else
        tk_call_without_enc('wm', 'manage', win.epath)
      end
      win
    end
=end

    # Gets or sets maximum window size.
    #
    # The window manager prevents the user from resizing beyond these
    # dimensions. For gridded windows, values are in grid units; otherwise
    # pixels. Defaults to screen size.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Integer>] width, height maximum dimensions
    # @return [Array<Integer>, TkWindow] Current max size if querying, window if setting
    # @example Limit window to 1024x768
    #   win.maxsize(1024, 768)
    def Wm.maxsize(win, *args)
      if args.size == 0
        list(tk_call_without_enc('wm', 'maxsize', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'maxsize', win.epath, *args)
        win
      end
    end
    # @see Wm.maxsize
    def maxsize(*args)
      Wm.maxsize(self, *args)
    end
    alias wm_maxsize maxsize

    # Gets or sets minimum window size.
    #
    # The window manager prevents the user from resizing below these
    # dimensions. For gridded windows, values are in grid units; otherwise
    # pixels. Defaults to 1x1.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Integer>] width, height minimum dimensions
    # @return [Array<Integer>, TkWindow] Current min size if querying, window if setting
    # @example Require at least 400x300
    #   win.minsize(400, 300)
    def Wm.minsize(win, *args)
      if args.size == 0
        list(tk_call_without_enc('wm', 'minsize', win.epath))
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'minsize', win.path, *args)
        win
      end
    end
    # @see Wm.minsize
    def minsize(*args)
      Wm.minsize(self, *args)
    end
    alias wm_minsize minsize

    # Gets or sets the override-redirect flag.
    #
    # When true, the window manager ignores this window completely:
    # no decorations, no taskbar entry, no keyboard focus management.
    # Useful for splash screens, tooltips, or custom popups.
    #
    # @param win [TkWindow] Window to configure
    # @param mode [Boolean, nil] true to enable override-redirect, or nil to query
    # @return [Boolean, TkWindow] Current state if querying, window if setting
    # @note Changes only take effect on window map or after withdraw/deiconify
    # @example Create an undecorated splash screen
    #   splash.overrideredirect(true)
    def Wm.overrideredirect(win, mode=TkComm::None)
      if mode == TkComm::None
        bool(tk_call_without_enc('wm', 'overrideredirect', win.epath))
      else
        tk_call_without_enc('wm', 'overrideredirect', win.epath, mode)
        win
      end
    end
    # @see Wm.overrideredirect
    def overrideredirect(mode=TkComm::None)
      Wm.overrideredirect(self, mode)
    end
    alias wm_overrideredirect overrideredirect

    # Gets or sets who specified the window position.
    #
    # Indicates whether the position came from the program or user.
    # Window managers may ignore program-specified positions but honor
    # user-specified ones.
    #
    # @param win [TkWindow] Window to configure
    # @param who [String, nil] "program" or "user", or nil to query
    # @return [String, nil, TkWindow] "user", "program", or nil if querying; window if setting
    # @note Tk sets this to "user" automatically when {#geometry} is called
    def Wm.positionfrom(win, who=TkComm::None)
      if who == TkComm::None
        r = tk_call_without_enc('wm', 'positionfrom', win.epath)
        (r == "")? nil: r
      else
        tk_call_without_enc('wm', 'positionfrom', win.epath, who)
        win
      end
    end
    # @see Wm.positionfrom
    def positionfrom(who=TkComm::None)
      Wm.positionfrom(self, who)
    end
    alias wm_positionfrom positionfrom

    # Handles window manager protocol events.
    #
    # The most common use is handling WM_DELETE_WINDOW to intercept
    # window close requests (e.g., for "Save changes?" confirmation).
    #
    # @param win [TkWindow] Window to configure
    # @param name [String, nil] Protocol name (e.g., "WM_DELETE_WINDOW")
    # @param cmd [Proc, nil] Handler to execute when protocol triggered
    # @yield Block form of handler
    # @return [TkWindow, Proc, Array] Window if setting, handler if querying
    #   one protocol, or list of protocol names if querying all
    #
    # @example Confirm before close
    #   root.protocol('WM_DELETE_WINDOW') do
    #     if confirm_quit?
    #       root.destroy
    #     end
    #   end
    #
    # @example Query registered protocols
    #   root.protocol  # => ["WM_DELETE_WINDOW", ...]
    def Wm.protocol(win, name=nil, cmd=nil, &b)
      if cmd
        tk_call_without_enc('wm', 'protocol', win.epath, name, cmd)
        win
      elsif b
        tk_call_without_enc('wm', 'protocol', win.epath, name, proc(&b))
        win
      elsif name
        result = tk_call_without_enc('wm', 'protocol', win.epath, name)
        (result == "")? nil : tk_tcl2ruby(result)
      else
        tk_split_simplelist(tk_call_without_enc('wm', 'protocol', win.epath))
      end
    end
    # @see Wm.protocol
    def protocol(name=nil, cmd=nil, &b)
      Wm.protocol(self, name, cmd, &b)
    end
    alias wm_protocol protocol

    # Gets or sets multiple protocol handlers at once.
    #
    # Convenience method to query all registered protocols or set
    # multiple handlers in one call.
    #
    # @param win [TkWindow] Window to configure
    # @param kv [Hash, nil] Hash of protocol_name => handler, or nil to query all
    # @return [Hash, TkWindow] Hash of all protocols if querying, window if setting
    # @example Set multiple handlers
    #   win.protocols(
    #     'WM_DELETE_WINDOW' => proc { confirm_quit },
    #     'WM_SAVE_YOURSELF' => proc { save_state }
    #   )
    def Wm.protocols(win, kv=nil)
      unless kv
        ret = {}
        Wm.protocol(win).each{|name|
          ret[name] = Wm.protocol(win, name)
        }
        return ret
      end

      unless kv.kind_of?(Hash)
        fail ArgumentError, 'expect a hash of protocol=>command'
      end
      kv.each{|k, v| Wm.protocol(win, k, v)}
      win
    end
    # @see Wm.protocols
    def protocols(kv=nil)
      Wm.protocols(self, kv)
    end
    alias wm_protocols protocols

    # Gets or sets whether the window can be resized.
    #
    # Controls whether the user can interactively resize the window
    # in each dimension. Does not prevent programmatic resizing.
    #
    # @param win [TkWindow] Window to configure
    # @param args [Array<Boolean>] width_resizable, height_resizable (1/true or 0/false)
    # @return [Array<Boolean>, TkWindow] Current [width, height] resizability if querying, window if setting
    # @example Prevent all resizing
    #   win.resizable(false, false)
    # @example Allow only horizontal resizing
    #   win.resizable(true, false)
    def Wm.resizable(win, *args)
      if args.length == 0
        list(tk_call_without_enc('wm', 'resizable', win.epath)).map!{|e| bool(e)}
      else
        args = args[0] if args.length == 1 && args[0].kind_of?(Array)
        tk_call_without_enc('wm', 'resizable', win.epath, *args)
        win
      end
    end
    # @see Wm.resizable
    def resizable(*args)
      Wm.resizable(self, *args)
    end
    alias wm_resizable resizable

    # Gets or sets who specified the window size.
    #
    # Indicates whether the size came from the program or user.
    # Window managers may treat these differently.
    #
    # @param win [TkWindow] Window to configure
    # @param who [String, nil] "program" or "user", or nil to query
    # @return [String, nil, TkWindow] "user", "program", or nil if querying; window if setting
    def Wm.sizefrom(win, who=TkComm::None)
      if who == TkComm::None
        r = tk_call_without_enc('wm', 'sizefrom', win.epath)
        (r == "")? nil: r
      else
        tk_call_without_enc('wm', 'sizefrom', win.epath, who)
        win
      end
    end
    # @see Wm.sizefrom
    def sizefrom(who=TkComm::None)
      Wm.sizefrom(self, who)
    end
    alias wm_sizefrom sizefrom

    # Returns the stacking order of toplevel windows.
    #
    # Returns a list of all mapped toplevel windows in stacking order,
    # from lowest (bottom) to highest (top).
    #
    # @param win [TkWindow] Window to query from
    # @return [Array<TkWindow>] Windows in stacking order (bottom to top)
    def Wm.stackorder(win)
      list(tk_call('wm', 'stackorder', win.epath))
    end
    # @see Wm.stackorder
    def stackorder
      Wm.stackorder(self)
    end
    alias wm_stackorder stackorder

    # Tests if this window is above another in stacking order.
    #
    # @param win [TkWindow] Window to test
    # @param target [TkWindow] Window to compare against
    # @return [Boolean] true if win is above target
    def Wm.stackorder_isabove(win, target)
      bool(tk_call('wm', 'stackorder', win.epath, 'isabove', target))
    end
    # @see Wm.stackorder_isabove
    def Wm.stackorder_is_above(win, target)
      Wm.stackorder_isabove(win, target)
    end
    # @see Wm.stackorder_isabove
    def stackorder_isabove(target)
      Wm.stackorder_isabove(self, target)
    end
    alias stackorder_is_above stackorder_isabove
    alias wm_stackorder_isabove stackorder_isabove
    alias wm_stackorder_is_above stackorder_isabove

    # Tests if this window is below another in stacking order.
    #
    # @param win [TkWindow] Window to test
    # @param target [TkWindow] Window to compare against
    # @return [Boolean] true if win is below target
    def Wm.stackorder_isbelow(win, target)
      bool(tk_call('wm', 'stackorder', win.epath, 'isbelow', target))
    end
    # @see Wm.stackorder_isbelow
    def Wm.stackorder_is_below(win, target)
      Wm.stackorder_isbelow(win, target)
    end
    # @see Wm.stackorder_isbelow
    def stackorder_isbelow(target)
      Wm.stackorder_isbelow(self, target)
    end
    alias stackorder_is_below stackorder_isbelow
    alias wm_stackorder_isbelow stackorder_isbelow
    alias wm_stackorder_is_below stackorder_isbelow

    # Gets or sets the window state.
    #
    # Valid states:
    # - "normal" - Normal visible window
    # - "iconic" - Minimized to taskbar/dock (see {#iconify})
    # - "withdrawn" - Hidden completely (see {#withdraw})
    # - "zoomed" - Maximized (platform-dependent)
    #
    # @param win [TkWindow] Window to configure
    # @param st [String, nil] New state, or nil to query
    # @return [String, TkWindow] Current state if querying, window if setting
    def Wm.state(win, st=nil)
      if st
        tk_call_without_enc('wm', 'state', win.epath, st)
        win
      else
        tk_call_without_enc('wm', 'state', win.epath)
      end
    end
    # @see Wm.state
    def state(st=nil)
      Wm.state(self, st)
    end
    alias wm_state state

    # Gets or sets the window title bar text.
    # @param win [TkWindow] Window to configure
    # @param str [String, nil] New title, or nil to query
    # @return [String, TkWindow] Current title if querying, window if setting
    # @example
    #   win.title = "My Application"
    #   win.title  # => "My Application"
    def Wm.title(win, str=nil)
      if str
        tk_call('wm', 'title', win.epath, str)
        win
      else
        tk_call('wm', 'title', win.epath)
      end
    end
    # @see Wm.title
    def title(str=nil)
      Wm.title(self, str)
    end
    alias wm_title title

    # Gets or sets the transient (dialog) relationship.
    #
    # Marks this window as a transient (dialog) for a master window.
    # The window manager may:
    # - Keep the transient window on top of its master
    # - Omit minimize/maximize buttons
    # - Iconify the transient with its master
    # - Skip the transient in taskbar/pager
    #
    # @param win [TkWindow] Window to configure
    # @param master [TkWindow, nil] Master window, empty string to remove, or nil to query
    # @return [TkWindow, nil] Current master if querying, window if setting
    # @example Create a dialog window
    #   dialog = TkToplevel.new
    #   dialog.transient(main_window)
    #   dialog.title = "Preferences"
    # @note The graph of transient relationships must be acyclic
    def Wm.transient(win, master=nil)
      if master
        tk_call_without_enc('wm', 'transient', win.epath, master)
        win
      else
        window(tk_call_without_enc('wm', 'transient', win.epath))
      end
    end
    # @see Wm.transient
    def transient(master=nil)
      Wm.transient(self, master)
    end
    alias wm_transient transient

    # Hides a window completely.
    #
    # Unlike iconify, withdrawn windows have no taskbar/dock icon.
    # The window still exists and can be shown again with deiconify.
    # Useful for temporary hiding or creating windows to show later.
    #
    # @param win [TkWindow] Window to withdraw
    # @param ex [Boolean] true to withdraw, false to deiconify
    # @return [TkWindow] The window
    def Wm.withdraw(win, ex = true)
      if ex
        tk_call_without_enc('wm', 'withdraw', win.epath)
      else
        Wm.deiconify(win)
      end
      win
    end
    # Hides this window completely.
    # @see Wm.withdraw
    def withdraw(ex = true)
      Wm.withdraw(self, ex)
    end
    alias wm_withdraw withdraw
  end

  module Wm_for_General
    Wm.instance_methods.each{|m|
      if (m = m.to_s) =~ /^wm_(.*)$/
        eval "def #{m}(*args, &b); Tk::Wm.#{$1}(self, *args, &b); end"
      end
    }
  end
end
