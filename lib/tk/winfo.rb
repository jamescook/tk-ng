# frozen_string_literal: false
#
# tk/winfo.rb : methods for winfo command
#
# @deprecated This module uses the problematic include+extend Tk pattern.
#   New widgets should use Tk::Core::Winfo instead, which provides clean
#   instance methods without the module function anti-pattern.
#   This file will be removed once all widgets migrate to Tk::Core::Widget.
#

# Window information query methods.
#
# TkWinfo provides methods to query window properties: geometry, hierarchy,
# display characteristics, and state. Methods can be called as module methods
# or as instance methods on windows.
#
# ## Categories of Information
#
# - **Geometry**: width, height, x, y, rootx, rooty, geometry
# - **Hierarchy**: parent, children, toplevel, containing
# - **Display**: depth, visual, colormap, cells, screen
# - **State**: exists, ismapped, viewable, manager
# - **Pointer**: pointerx, pointery, pointerxy
#
# @example Query window dimensions
#   TkWinfo.width(my_window)   # => 300
#   my_window.winfo_width      # => 300
#
# @example Find window under mouse pointer
#   win = TkWinfo.containing(x, y)
#
# @example Query window hierarchy
#   TkWinfo.children(parent)   # => [child1, child2, ...]
#   TkWinfo.parent(child)      # => parent_window
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/winfo.htm Tcl/Tk winfo manual
module TkWinfo
end

module TkWinfo
  include Tk
  extend Tk

  TkCommandNames = ['winfo'.freeze].freeze

  # @!group Atom Methods

  # Returns the integer identifier for an X11 atom.
  #
  # Atoms are unique identifiers for strings used in X11 properties
  # and selections. This is rarely needed in typical Tk programming.
  #
  # @param name [String] The atom name to look up
  # @param win [TkWindow, nil] Window for display context (optional)
  # @return [Integer] The atom's integer identifier
  def TkWinfo.atom(name, win=nil)
    if win
      number(tk_call_without_enc('winfo', 'atom', '-displayof', win,
                                 _get_eval_enc_str(name)))
    else
      number(tk_call_without_enc('winfo', 'atom', _get_eval_enc_str(name)))
    end
  end
  # @see TkWinfo.atom
  def winfo_atom(name)
    TkWinfo.atom(name, self)
  end

  # Returns the name of an X11 atom given its integer identifier.
  #
  # @param id [Integer] The atom's integer identifier
  # @param win [TkWindow, nil] Window for display context (optional)
  # @return [String] The atom's name
  def TkWinfo.atomname(id, win=nil)
    if win
      tk_call_without_enc('winfo', 'atomname', '-displayof', win, id)
    else
      tk_call_without_enc('winfo', 'atomname', id)
    end
  end
  # @see TkWinfo.atomname
  def winfo_atomname(id)
    TkWinfo.atomname(id, self)
  end

  # @!endgroup

  # @!group Color and Visual Methods

  # Returns the number of cells in the window's colormap.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Number of colormap cells
  def TkWinfo.cells(win)
    number(tk_call_without_enc('winfo', 'cells', win))
  end
  # @see TkWinfo.cells
  def winfo_cells
    TkWinfo.cells self
  end

  # @!endgroup

  # @!group Hierarchy Methods

  # Returns a list of all child windows.
  #
  # @param win [TkWindow] The parent window
  # @return [Array<TkWindow>] List of child windows
  # @example
  #   children = TkWinfo.children(parent_frame)
  #   children.each { |child| child.destroy }
  def TkWinfo.children(win)
    list(tk_call_without_enc('winfo', 'children', win))
  end
  # @see TkWinfo.children
  def winfo_children
    TkWinfo.children self
  end

  # @!endgroup

  # @!group Identification Methods

  # Returns the window's class name.
  #
  # The class name is used for option database lookups and determines
  # default widget behavior.
  #
  # @param win [TkWindow] The window to query
  # @return [String] The window's class name (e.g., "Button", "Frame")
  def TkWinfo.classname(win)
    tk_call_without_enc('winfo', 'class', win)
  end
  # @see TkWinfo.classname
  def winfo_classname
    TkWinfo.classname self
  end
  alias winfo_class winfo_classname

  # @!endgroup

  # @!group Color and Visual Methods

  # Checks if the window's colormap is full.
  #
  # @param win [TkWindow] The window to query
  # @return [Boolean] true if colormap is full
  def TkWinfo.colormapfull(win)
     bool(tk_call_without_enc('winfo', 'colormapfull', win))
  end
  # @see TkWinfo.colormapfull
  def winfo_colormapfull
    TkWinfo.colormapfull self
  end

  # @!endgroup

  # @!group Pointer Methods

  # Returns the window containing the given screen coordinates.
  #
  # Finds the topmost window at the specified root window coordinates.
  # Useful for implementing drag-and-drop or context menus.
  #
  # @param rootX [Integer] X coordinate relative to root window
  # @param rootY [Integer] Y coordinate relative to root window
  # @param win [TkWindow, nil] Window for display context (optional)
  # @return [TkWindow, nil] The window at those coordinates, or nil
  # @example Find window under mouse
  #   x, y = TkWinfo.pointerxy(root)
  #   win = TkWinfo.containing(x, y)
  def TkWinfo.containing(rootX, rootY, win=nil)
    if win
      window(tk_call_without_enc('winfo', 'containing',
                                 '-displayof', win, rootX, rootY))
    else
      window(tk_call_without_enc('winfo', 'containing', rootX, rootY))
    end
  end
  # @see TkWinfo.containing
  def winfo_containing(x, y)
    TkWinfo.containing(x, y, self)
  end

  # @!endgroup

  # @!group Color and Visual Methods

  # Returns the color depth (bits per pixel) of the window.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Bits per pixel (e.g., 24, 32)
  def TkWinfo.depth(win)
    number(tk_call_without_enc('winfo', 'depth', win))
  end
  # @see TkWinfo.depth
  def winfo_depth
    TkWinfo.depth self
  end

  # @!endgroup

  # @!group State Methods

  # Checks if a window exists.
  #
  # @param win [TkWindow, String] The window or path to check
  # @return [Boolean] true if window exists
  # @example
  #   if TkWinfo.exist?(my_dialog)
  #     my_dialog.destroy
  #   end
  def TkWinfo.exist?(win)
    bool(tk_call_without_enc('winfo', 'exists', win))
  end
  # @see TkWinfo.exist?
  def winfo_exist?
    TkWinfo.exist? self
  end

  # @!endgroup

  # @!group Geometry Methods

  # Converts a distance to floating-point pixels.
  #
  # @param win [TkWindow] Window for screen context
  # @param dist [String] Distance with units (e.g., "2.5c", "1i", "10m")
  # @return [Float] Distance in pixels
  # @see TkWinfo.pixels For integer result
  def TkWinfo.fpixels(win, dist)
    number(tk_call_without_enc('winfo', 'fpixels', win, dist))
  end
  # @see TkWinfo.fpixels
  def winfo_fpixels(dist)
    TkWinfo.fpixels self, dist
  end

  # Returns the window's geometry string.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Geometry in format "WIDTHxHEIGHT+X+Y"
  # @example
  #   TkWinfo.geometry(root)  # => "800x600+100+50"
  def TkWinfo.geometry(win)
    tk_call_without_enc('winfo', 'geometry', win)
  end
  # @see TkWinfo.geometry
  def winfo_geometry
    TkWinfo.geometry self
  end

  # Returns the window's current height in pixels.
  #
  # This is the actual displayed height, which may differ from
  # the requested height before the window is mapped.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Height in pixels
  # @see TkWinfo.reqheight For requested height
  def TkWinfo.height(win)
    number(tk_call_without_enc('winfo', 'height', win))
  end
  # @see TkWinfo.height
  def winfo_height
    TkWinfo.height self
  end

  # @!endgroup

  # @!group Identification Methods

  # Returns the platform-specific window identifier.
  #
  # On X11, this is the X window ID. On Windows, this is the HWND.
  # Useful for interfacing with external libraries.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Platform-specific window identifier
  def TkWinfo.id(win)
    tk_call_without_enc('winfo', 'id', win)
  end
  # @see TkWinfo.id
  def winfo_id
    TkWinfo.id self
  end

  # @!endgroup

  # @!group Inter-Process Communication

  # Returns list of Tcl interpreters registered on the display.
  #
  # These are interpreters that can receive 'send' commands for
  # inter-process communication.
  #
  # @param win [TkWindow, nil] Window for display context (optional)
  # @return [Array<String>] List of interpreter names
  # @raise [NotImplementedError] On Windows (X11 only)
  # @note On Windows, use DDE or comm package instead
  def TkWinfo.interps(win=nil)
    if Gem.win_platform?
      raise NotImplementedError, "winfo interps requires X11 (use DDE or comm on Windows)"
    end
    if win
      tk_split_simplelist(tk_call_without_enc('winfo', 'interps',
                                              '-displayof', win),
                          false, true)
    else
      tk_split_simplelist(tk_call_without_enc('winfo', 'interps'),
                          false, true)
    end
  end
  # @see TkWinfo.interps
  def winfo_interps
    TkWinfo.interps self
  end

  # @!endgroup

  # @!group State Methods

  # Checks if the window is currently mapped (visible).
  #
  # A window is mapped when it has been made visible with pack, grid,
  # or place. Unmapped windows exist but are not displayed.
  #
  # @param win [TkWindow] The window to query
  # @return [Boolean] true if window is mapped
  def TkWinfo.mapped?(win)
    bool(tk_call_without_enc('winfo', 'ismapped', win))
  end
  # @see TkWinfo.mapped?
  def winfo_mapped?
    TkWinfo.mapped? self
  end

  # Returns the name of the geometry manager for the window.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Geometry manager name ("pack", "grid", "place", or "")
  # @example
  #   TkWinfo.manager(button)  # => "pack"
  def TkWinfo.manager(win)
    tk_call_without_enc('winfo', 'manager', win)
  end
  # @see TkWinfo.manager
  def winfo_manager
    TkWinfo.manager self
  end

  # @!endgroup

  # @!group Identification Methods

  # Returns the window's name within its parent.
  #
  # This is the last component of the window's path, not the full path.
  #
  # @param win [TkWindow] The window to query
  # @return [String] The window's local name
  # @example
  #   # For window with path ".frame.button"
  #   TkWinfo.appname(button)  # => "button"
  def TkWinfo.appname(win)
    tk_call('winfo', 'name', win)
  end
  # @see TkWinfo.appname
  def winfo_appname
    TkWinfo.appname self
  end

  # @!endgroup

  # @!group Hierarchy Methods

  # Returns the parent window.
  #
  # @param win [TkWindow] The window to query
  # @return [TkWindow, nil] The parent window, or nil for root
  def TkWinfo.parent(win)
    window(tk_call_without_enc('winfo', 'parent', win))
  end
  # @see TkWinfo.parent
  def winfo_parent
    TkWinfo.parent self
  end

  # @!endgroup

  # @!group Identification Methods

  # Returns the window for a given platform-specific identifier.
  #
  # This is the inverse of {TkWinfo.id}.
  #
  # @param id [String] Platform-specific window identifier
  # @param win [TkWindow, nil] Window for display context (optional)
  # @return [TkWindow] The window with that identifier
  def TkWinfo.widget(id, win=nil)
    if win
      window(tk_call_without_enc('winfo', 'pathname', '-displayof', win, id))
    else
      window(tk_call_without_enc('winfo', 'pathname', id))
    end
  end
  # @see TkWinfo.widget
  def winfo_widget(id)
    TkWinfo.widget id, self
  end

  # @!endgroup

  # @!group Geometry Methods

  # Converts a distance to integer pixels.
  #
  # Distance can include units: c (centimeters), i (inches),
  # m (millimeters), p (points).
  #
  # @param win [TkWindow] Window for screen context
  # @param dist [String] Distance with units (e.g., "2c", "1i", "10m")
  # @return [Integer] Distance in pixels (rounded)
  # @see TkWinfo.fpixels For floating-point result
  # @example
  #   TkWinfo.pixels(root, "2.54c")  # => 96 (at 96 DPI)
  #   TkWinfo.pixels(root, "1i")     # => 96 (at 96 DPI)
  def TkWinfo.pixels(win, dist)
    number(tk_call_without_enc('winfo', 'pixels', win, dist))
  end
  # @see TkWinfo.pixels
  def winfo_pixels(dist)
    TkWinfo.pixels self, dist
  end

  # Returns the window's requested height.
  #
  # This is the height requested by the geometry manager, which may
  # differ from the actual height.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Requested height in pixels
  # @see TkWinfo.height For actual height
  def TkWinfo.reqheight(win)
    number(tk_call_without_enc('winfo', 'reqheight', win))
  end
  # @see TkWinfo.reqheight
  def winfo_reqheight
    TkWinfo.reqheight self
  end

  # Returns the window's requested width.
  #
  # This is the width requested by the geometry manager, which may
  # differ from the actual width.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Requested width in pixels
  # @see TkWinfo.width For actual width
  def TkWinfo.reqwidth(win)
    number(tk_call_without_enc('winfo', 'reqwidth', win))
  end
  # @see TkWinfo.reqwidth
  def winfo_reqwidth
    TkWinfo.reqwidth self
  end

  # @!endgroup

  # @!group Color and Visual Methods

  # Returns RGB values for a color name.
  #
  # @param win [TkWindow] Window for colormap context
  # @param color [String] Color name or hex value
  # @return [Array<Integer>] [red, green, blue] values (0-65535)
  # @example
  #   TkWinfo.rgb(root, "red")     # => [65535, 0, 0]
  #   TkWinfo.rgb(root, "#ff8000") # => [65535, 32896, 0]
  def TkWinfo.rgb(win, color)
    list(tk_call_without_enc('winfo', 'rgb', win, color))
  end
  # @see TkWinfo.rgb
  def winfo_rgb(color)
    TkWinfo.rgb self, color
  end

  # @!endgroup

  # @!group Geometry Methods

  # Returns the X coordinate relative to the root window.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] X coordinate in root window pixels
  # @see TkWinfo.x For position within parent
  def TkWinfo.rootx(win)
    number(tk_call_without_enc('winfo', 'rootx', win))
  end
  # @see TkWinfo.rootx
  def winfo_rootx
    TkWinfo.rootx self
  end

  # Returns the Y coordinate relative to the root window.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Y coordinate in root window pixels
  # @see TkWinfo.y For position within parent
  def TkWinfo.rooty(win)
    number(tk_call_without_enc('winfo', 'rooty', win))
  end
  # @see TkWinfo.rooty
  def winfo_rooty
    TkWinfo.rooty self
  end

  # @!group Screen Methods

  # Returns the screen name for the window's display.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Screen name in format "displayName.screenIndex"
  # @example
  #   TkWinfo.screen(root)  # => ":0.0" on X11
  def TkWinfo.screen(win)
    tk_call('winfo', 'screen', win)
  end
  # @see TkWinfo.screen
  def winfo_screen
    TkWinfo.screen self
  end

  # Returns the number of colormap cells for the screen.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Number of colormap cells
  def TkWinfo.screencells(win)
    number(tk_call_without_enc('winfo', 'screencells', win))
  end
  # @see TkWinfo.screencells
  def winfo_screencells
    TkWinfo.screencells self
  end

  # Returns the color depth of the screen.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Bits per pixel for the screen
  def TkWinfo.screendepth(win)
    number(tk_call_without_enc('winfo', 'screendepth', win))
  end
  # @see TkWinfo.screendepth
  def winfo_screendepth
    TkWinfo.screendepth self
  end

  # Returns the screen height in pixels.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Screen height in pixels
  def TkWinfo.screenheight(win)
    number(tk_call_without_enc('winfo', 'screenheight', win))
  end
  # @see TkWinfo.screenheight
  def winfo_screenheight
    TkWinfo.screenheight self
  end

  # Returns the screen height in millimeters.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Screen height in millimeters
  def TkWinfo.screenmmheight(win)
    number(tk_call_without_enc('winfo', 'screenmmheight', win))
  end
  # @see TkWinfo.screenmmheight
  def winfo_screenmmheight
    TkWinfo.screenmmheight self
  end

  # Returns the screen width in millimeters.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Screen width in millimeters
  def TkWinfo.screenmmwidth(win)
    number(tk_call_without_enc('winfo', 'screenmmwidth', win))
  end
  # @see TkWinfo.screenmmwidth
  def winfo_screenmmwidth
    TkWinfo.screenmmwidth self
  end

  # Returns the default visual class for the screen.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Visual class (e.g., "truecolor", "pseudocolor")
  def TkWinfo.screenvisual(win)
    tk_call_without_enc('winfo', 'screenvisual', win)
  end
  # @see TkWinfo.screenvisual
  def winfo_screenvisual
    TkWinfo.screenvisual self
  end

  # Returns the screen width in pixels.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Screen width in pixels
  def TkWinfo.screenwidth(win)
    number(tk_call_without_enc('winfo', 'screenwidth', win))
  end
  # @see TkWinfo.screenwidth
  def winfo_screenwidth
    TkWinfo.screenwidth self
  end

  # Returns information about the display server.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Server information string
  # @example
  #   TkWinfo.server(root)  # => "X11R6 ..."
  def TkWinfo.server(win)
    tk_call('winfo', 'server', win)
  end
  # @see TkWinfo.server
  def winfo_server
    TkWinfo.server self
  end

  # @!endgroup

  # @!group Hierarchy Methods

  # Returns the toplevel window containing this window.
  #
  # @param win [TkWindow] The window to query
  # @return [TkWindow] The toplevel ancestor
  def TkWinfo.toplevel(win)
    window(tk_call_without_enc('winfo', 'toplevel', win))
  end
  # @see TkWinfo.toplevel
  def winfo_toplevel
    TkWinfo.toplevel self
  end

  # @!endgroup

  # @!group Color and Visual Methods

  # Returns the visual class for the window.
  #
  # @param win [TkWindow] The window to query
  # @return [String] Visual class: directcolor, grayscale, pseudocolor,
  #   staticcolor, staticgray, or truecolor
  def TkWinfo.visual(win)
    tk_call_without_enc('winfo', 'visual', win)
  end
  # @see TkWinfo.visual
  def winfo_visual
    TkWinfo.visual self
  end

  # Returns the X identifier for the window's visual.
  #
  # @param win [TkWindow] The window to query
  # @return [String] X visual identifier
  def TkWinfo.visualid(win)
    tk_call_without_enc('winfo', 'visualid', win)
  end
  # @see TkWinfo.visualid
  def winfo_visualid
    TkWinfo.visualid self
  end

  # Returns list of available visual types for the screen.
  #
  # @param win [TkWindow] The window to query
  # @param includeids [Boolean] Include X visual identifiers
  # @return [Array] List of [class, depth] or [class, depth, id] arrays
  def TkWinfo.visualsavailable(win, includeids=false)
    if includeids
      list(tk_call_without_enc('winfo', 'visualsavailable',
                               win, "includeids"))
    else
      list(tk_call_without_enc('winfo', 'visualsavailable', win))
    end
  end
  # @see TkWinfo.visualsavailable
  def winfo_visualsavailable(includeids=false)
    TkWinfo.visualsavailable self, includeids
  end

  # @!endgroup

  # @!group Virtual Root Methods

  # Returns the height of the virtual root window.
  #
  # If no virtual window manager is running, returns the screen height.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Virtual root height in pixels
  def TkWinfo.vrootheight(win)
    number(tk_call_without_enc('winfo', 'vrootheight', win))
  end
  # @see TkWinfo.vrootheight
  def winfo_vrootheight
    TkWinfo.vrootheight self
  end

  # Returns the width of the virtual root window.
  #
  # If no virtual window manager is running, returns the screen width.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Virtual root width in pixels
  def TkWinfo.vrootwidth(win)
    number(tk_call_without_enc('winfo', 'vrootwidth', win))
  end
  # @see TkWinfo.vrootwidth
  def winfo_vrootwidth
    TkWinfo.vrootwidth self
  end

  # Returns the X offset of the virtual root.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] X offset (0 if no virtual root)
  def TkWinfo.vrootx(win)
    number(tk_call_without_enc('winfo', 'vrootx', win))
  end
  # @see TkWinfo.vrootx
  def winfo_vrootx
    TkWinfo.vrootx self
  end

  # Returns the Y offset of the virtual root.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Y offset (0 if no virtual root)
  def TkWinfo.vrooty(win)
    number(tk_call_without_enc('winfo', 'vrooty', win))
  end
  # @see TkWinfo.vrooty
  def winfo_vrooty
    TkWinfo.vrooty self
  end

  # @!endgroup

  # @!group Geometry Methods

  # Returns the window's current width in pixels.
  #
  # This is the actual displayed width, which may differ from
  # the requested width before the window is mapped.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Width in pixels
  # @see TkWinfo.reqwidth For requested width
  def TkWinfo.width(win)
    number(tk_call_without_enc('winfo', 'width', win))
  end
  # @see TkWinfo.width
  def winfo_width
    TkWinfo.width self
  end

  # Returns the X coordinate within the parent window.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] X coordinate relative to parent
  # @see TkWinfo.rootx For absolute screen position
  def TkWinfo.x(win)
    number(tk_call_without_enc('winfo', 'x', win))
  end
  # @see TkWinfo.x
  def winfo_x
    TkWinfo.x self
  end

  # Returns the Y coordinate within the parent window.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Y coordinate relative to parent
  # @see TkWinfo.rooty For absolute screen position
  def TkWinfo.y(win)
    number(tk_call_without_enc('winfo', 'y', win))
  end
  # @see TkWinfo.y
  def winfo_y
    TkWinfo.y self
  end

  # @!endgroup

  # @!group State Methods

  # Checks if the window and all ancestors are mapped.
  #
  # A viewable window is displayed on screen. Non-viewable windows
  # are either unmapped or have an unmapped ancestor.
  #
  # @param win [TkWindow] The window to query
  # @return [Boolean] true if window is viewable
  # @see TkWinfo.mapped? For just this window's map state
  def TkWinfo.viewable(win)
    bool(tk_call_without_enc('winfo', 'viewable', win))
  end
  # @see TkWinfo.viewable
  def winfo_viewable
    TkWinfo.viewable self
  end

  # @!endgroup

  # @!group Pointer Methods

  # Returns the pointer's X coordinate on the window's screen.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] X coordinate, or -1 if on different screen
  def TkWinfo.pointerx(win)
    number(tk_call_without_enc('winfo', 'pointerx', win))
  end
  # @see TkWinfo.pointerx
  def winfo_pointerx
    TkWinfo.pointerx self
  end

  # Returns the pointer's Y coordinate on the window's screen.
  #
  # @param win [TkWindow] The window to query
  # @return [Integer] Y coordinate, or -1 if on different screen
  def TkWinfo.pointery(win)
    number(tk_call_without_enc('winfo', 'pointery', win))
  end
  # @see TkWinfo.pointery
  def winfo_pointery
    TkWinfo.pointery self
  end

  # Returns the pointer's X and Y coordinates.
  #
  # @param win [TkWindow] The window to query
  # @return [Array<Integer>] [x, y] coordinates, or [-1, -1] if on different screen
  # @example
  #   x, y = TkWinfo.pointerxy(root)
  def TkWinfo.pointerxy(win)
    list(tk_call_without_enc('winfo', 'pointerxy', win))
  end
  # @see TkWinfo.pointerxy
  def winfo_pointerxy
    TkWinfo.pointerxy self
  end

  # @!endgroup
end
