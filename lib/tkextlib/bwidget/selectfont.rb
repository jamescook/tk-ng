# frozen_string_literal: false
#
#  tkextlib/bwidget/selectfont.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/messagedlg'

module Tk
  module BWidget
    # Font selection widget (dialog or toolbar mode).
    #
    # SelectFont allows users to choose font family, size, and styles.
    # Can display as a modal dialog or embedded toolbar.
    #
    # @example Font dialog
    #   require 'tkextlib/bwidget'
    #   dlg = Tk::BWidget::SelectFont::Dialog.new(root,
    #     title: 'Choose Font')
    #   font = dlg.create  # Returns font name or nil
    #
    # @example Font toolbar
    #   toolbar = Tk::BWidget::SelectFont::Toolbar.new(root,
    #     command: proc { |font| apply_font(font) })
    #   toolbar.pack
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/SelectFont.html
    class SelectFont < Tk::BWidget::MessageDlg
      # Font selection as modal dialog.
      # @see Tk::BWidget::SelectFont
      class Dialog < Tk::BWidget::SelectFont
      end
      # Font selection as embedded toolbar.
      # @see Tk::BWidget::SelectFont
      class Toolbar < TkWindow
      end
    end
  end
end

class Tk::BWidget::SelectFont
  extend Tk

  TkCommandNames = ['SelectFont'.freeze].freeze
  WidgetClassName = 'SelectFont'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def __font_optkeys
    [] # without fontobj operation
  end
  private :__font_optkeys

  def create
    tk_call(self.class::TkCommandNames[0], @path, *hash_kv(@keys))
  end

  def self.load_font
    tk_call('SelectFont::loadfont')
  end
end

class Tk::BWidget::SelectFont::Dialog
  def __font_optkeys
    [] # without fontobj operation
  end

  def create_self(keys)
    super(keys)
    @keys['type'] = 'dialog'
  end

  def configure(slot, value=None)
    if slot.kind_of?(Hash)
      slot.delete['type']
      slot.delete[:type]
      return self if slot.empty?
    else
      return self if slot == 'type' || slot == :type
    end
    super(slot, value)
  end

  def create
    @keys['type'] = 'dialog'  # 'dialog' type returns font name
    tk_call(Tk::BWidget::SelectFont::TkCommandNames[0], @path, *hash_kv(@keys))
  end
end

class Tk::BWidget::SelectFont::Toolbar
  def __font_optkeys
    [] # without fontobj operation
  end

  def create_self(keys)
    keys = {} unless keys
    keys = _symbolkey2str(keys)
    keys['type'] = 'toolbar'  # 'toolbar' type returns widget path
    window(tk_call(Tk::BWidget::SelectFont::TkCommandNames[0],
                   @path, *hash_kv(keys)))
  end
end
