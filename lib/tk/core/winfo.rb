# frozen_string_literal: true

module Tk
  module Core
    # Clean winfo methods for widgets.
    # Instance methods only. No include+extend pattern.
    module Winfo
      def winfo_reqwidth
        tk_call('winfo', 'reqwidth', @path).to_i
      end

      def winfo_reqheight
        tk_call('winfo', 'reqheight', @path).to_i
      end

      def winfo_width
        tk_call('winfo', 'width', @path).to_i
      end

      def winfo_height
        tk_call('winfo', 'height', @path).to_i
      end

      def winfo_x
        tk_call('winfo', 'x', @path).to_i
      end

      def winfo_y
        tk_call('winfo', 'y', @path).to_i
      end

      def winfo_rootx
        tk_call('winfo', 'rootx', @path).to_i
      end

      def winfo_rooty
        tk_call('winfo', 'rooty', @path).to_i
      end

      def winfo_exists?
        tk_call('winfo', 'exists', @path) == '1'
      end
      alias winfo_exist? winfo_exists?
      alias exist? winfo_exists?

      def destroyed?
        !winfo_exists?
      end

      def winfo_viewable?
        tk_call('winfo', 'viewable', @path) == '1'
      end

      def winfo_toplevel
        tk_call('winfo', 'toplevel', @path)
      end

      def winfo_parent
        tk_call('winfo', 'parent', @path)
      end

      def winfo_children
        result = tk_call('winfo', 'children', @path)
        TclTkLib._split_tklist(result)
      end

      def winfo_class
        tk_call('winfo', 'class', @path)
      end

      def winfo_id
        tk_call('winfo', 'id', @path)
      end

      def winfo_screenwidth
        tk_call('winfo', 'screenwidth', @path).to_i
      end

      def winfo_screenheight
        tk_call('winfo', 'screenheight', @path).to_i
      end

      def set_focus(force = false)
        if force
          tk_call('focus', '-force', @path)
        else
          tk_call('focus', @path)
        end
        self
      end
      alias focus set_focus
    end
  end
end
