# frozen_string_literal: false
#
#   tk/dialog.rb : create dialog boxes
#
require 'tk/variable.rb'
require_relative 'core/callable'
require_relative 'callback'

# Creates custom dialog boxes with configurable buttons, message, and bitmap.
#
# TkDialogObj wraps Tk's `tk_dialog` command, which displays a modal dialog
# window and waits for user interaction before returning.
#
# @note **Largely deprecated**: The underlying `tk_dialog` command is largely
#   deprecated by {Tk.messageBox} (which wraps `tk_messageBox`). Use
#   {Tk.messageBox} for standard OK/Cancel/Yes/No dialogs. TkDialogObj is
#   still useful when you need highly customized button labels or dialog
#   appearance beyond what `tk_messageBox` offers.
#
# @example Basic usage with show class method
#   dialog = TkDialogObj.show(nil,
#     title: "Confirm Action",
#     message: "Are you sure you want to proceed?",
#     bitmap: "question",
#     buttons: ["Yes", "No", "Cancel"],
#     default: 0
#   )
#   case dialog.value
#   when 0 then puts "User clicked Yes"
#   when 1 then puts "User clicked No"
#   when 2 then puts "User clicked Cancel"
#   end
#
# @example Subclassing for reusable dialogs
#   class ConfirmDeleteDialog < TkDialogObj
#     private
#     def title; "Confirm Delete"; end
#     def message; "This cannot be undone. Continue?"; end
#     def bitmap; "warning"; end
#     def buttons; ["Delete", "Cancel"]; end
#     def default_button; 1; end  # Cancel is default
#   end
#
#   dialog = ConfirmDeleteDialog.new
#   dialog.show
#   if dialog.value == 0
#     # perform delete
#   end
#
# @see Tk.messageBox For standard message dialogs (preferred for simple cases)
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/dialog.htm Tcl/Tk tk_dialog manual
class TkDialogObj
  include Tk::Core::Callable
  include TkCallback

  TkCommandNames = ['tk_dialog'.freeze].freeze

  attr_reader :path

  # Creates and immediately shows a dialog, returning the dialog object.
  # @param args [Array] Arguments passed to {#initialize}
  # @return [TkDialogObj] The dialog object (call {#value} to get result)
  def self.show(*args)
    dlog = self.new(*args)
    dlog.show
    dlog
  end

  def initialize(parent = nil, keys = nil)
    if parent.is_a?(Hash)
      keys = parent
      parent = nil
    end
    keys = keys.transform_keys(&:to_s) if keys

    # Generate path
    id = Tk::Core::Widget.next_id
    parent_path = parent.respond_to?(:path) ? parent.path : '.'
    @path = parent_path == '.' ? ".w#{id}" : "#{parent_path}.w#{id}"
    TkCore::INTERP.tk_windows[@path] = self

    @val = nil

    @title   = title
    @message = message
    @message_config = message_config
    @msgframe_config = msgframe_config
    @bitmap  = bitmap
    @bitmap_config = bitmap_config
    @default_button = default_button
    @buttons = buttons
    @button_configs = proc{|num| button_configs(num)}
    @btnframe_config = btnframe_config
    @config = ""
    @command = prev_command

    if keys
      @title   = keys['title'] if keys.key? 'title'
      @message = keys['message'] if keys.key? 'message'
      @bitmap  = keys['bitmap'] if keys.key? 'bitmap'
      @bitmap  = '' unless @bitmap
      @default_button = keys['default'] if keys.key? 'default'
      @buttons = keys['buttons'] if keys.key? 'buttons'
      @command = keys['prev_command'] if keys.key? 'prev_command'
      @message_config = keys['message_config'] if keys.key? 'message_config'
      @msgframe_config = keys['msgframe_config'] if keys.key? 'msgframe_config'
      @bitmap_config  = keys['bitmap_config']  if keys.key? 'bitmap_config'
      @button_configs = keys['button_configs'] if keys.key? 'button_configs'
      @btnframe_config = keys['btnframe_config'] if keys.key? 'btnframe_config'
    end

    if @buttons.kind_of?(Array)
      _set_button_config(@buttons.collect{|cfg|
                           (cfg.kind_of? Array)? cfg[1]: nil})
      @buttons = @buttons.collect{|cfg| (cfg.kind_of? Array)? cfg[0]: cfg}
    end
    if @buttons.kind_of?(Hash)
      _set_button_config(@buttons)
      @buttons = @buttons.keys
    end
    @buttons = TclTkLib._split_tklist(@buttons) if @buttons.kind_of?(String)
    @buttons = [] unless @buttons

    if @message_config.kind_of?(Hash)
      @config << @path+'.msg configure '+
                   _hash_to_tcl_list(@message_config)+';'
    end

    if @msgframe_config.kind_of?(Hash)
      @config << @path+'.top configure '+
                   _hash_to_tcl_list(@msgframe_config)+';'
    end

    if @btnframe_config.kind_of?(Hash)
      @config << @path+'.bot configure '+
                   _hash_to_tcl_list(@btnframe_config)+';'
    end

    if @bitmap_config.kind_of?(Hash)
      @config << @path+'.bitmap configure '+
                   _hash_to_tcl_list(@bitmap_config)+';'
    end

    _set_button_config(@button_configs) if @button_configs
  end

  # Displays the dialog and waits for user interaction.
  #
  # This method blocks until the user clicks a button or closes the dialog.
  # During display, a local grab prevents interaction with other application
  # windows.
  #
  # @return [Integer] The button index (0 for leftmost, 1 for next, etc.)
  # @note Returns -1 if the dialog window is destroyed before a button is clicked.
  def show
    if TkComm._callback_entry?(@command)
      @command.call(self)
    end

    if @default_button.kind_of?(String)
      default_button = @buttons.index(@default_button)
    else
      default_button = @default_button
    end
    default_button = '' if default_button == nil
    Tk.ip_eval(@config)
    @val = Tk.ip_eval(TclTkLib._merge_tklist(*[
                                      self.class::TkCommandNames[0],
                                      @path, @title, @message, @bitmap,
                                      String(default_button)
                                    ].concat(@buttons))).to_i
  end

  # Returns the index of the button that was clicked.
  # @return [Integer, nil] 0 for leftmost button, 1 for next, etc.
  #   Returns -1 if dialog was destroyed, nil if not yet shown.
  def value
    @val
  end

  # Returns the label text of the button that was clicked.
  # @return [String, nil] The button label, or nil if no button was clicked
  def name
    (@val)? @buttons[@val]: nil
  end

  ############################################################
  #                                                          #
  #  following methods should be overridden for each dialog  #
  #                                                          #
  ############################################################
  private

  def title
    return "DIALOG"
  end
  def message
    return "MESSAGE"
  end
  def message_config
    return nil
  end
  def msgframe_config
    return nil
  end
  def bitmap
    return "info"
  end
  def bitmap_config
    return nil
  end
  def default_button
    return 0
  end
  def buttons
    return ["BUTTON1", "BUTTON2"]
  end
  def button_configs(num)
    return nil
  end
  def btnframe_config
    return nil
  end
  def prev_command
    return nil
  end

  def _set_button_config(configs)
    set_config = proc{|c,i|
      if $VERBOSE && (c.has_key?('command') || c.has_key?(:command))
        STDERR.print("Warning: cannot give a command option " +
                     "to the dialog button#{i}. It was removed.\n")
      end
      c.delete('command'); c.delete(:command)
      @config << @path+'.button'+i.to_s+' configure '+
                   _hash_to_tcl_list(c)+'; '
    }
    case configs
    when Proc
      @buttons.each_index{|i|
        if (c = configs.call(i)).kind_of?(Hash)
          set_config.call(c,i)
        end
      }
    when Array
      @buttons.each_index{|i|
        if (c = configs[i]).kind_of?(Hash)
          set_config.call(c,i)
        end
      }
    when Hash
      @buttons.each_with_index{|s,i|
        if (c = configs[s]).kind_of?(Hash)
          set_config.call(c,i)
        end
      }
    end
    @config = TclTkLib._merge_tklist('after', 'idle', @config) << ';' if @config != ""
  end

  # Convert hash to Tcl list of -key value pairs
  def _hash_to_tcl_list(hash)
    args = []
    hash.each do |k, v|
      args << "-#{k}"
      if v.respond_to?(:path)
        args << v.path
      elsif v.respond_to?(:to_eval)
        args << v.to_eval
      else
        args << v.to_s
      end
    end
    TclTkLib._merge_tklist(*args)
  end
end
TkDialog2 = TkDialogObj

# Dialog that automatically shows when instantiated.
#
# Unlike {TkDialogObj}, TkDialog displays immediately upon creation,
# so you don't need to call {#show} separately.
#
# @example
#   dialog = TkDialog.new(nil, title: "Info", message: "Done!", buttons: ["OK"])
#   puts "User clicked button #{dialog.value}"
#
# @see TkDialogObj For dialogs that don't auto-show
class TkDialog < TkDialogObj
  def self.show(*args)
    self.new(*args)
  end

  def initialize(*args)
    super(*args)
    show
  end
end


# Pre-configured warning dialog with "warning" bitmap and single OK button.
#
# A convenience subclass of {TkDialogObj} for simple warning messages.
# Title defaults to "WARNING" with a warning icon.
#
# @example Simple warning message
#   warn_dialog = TkWarningObj.new("File not found!")
#   warn_dialog.show
#
# @example With parent window
#   warn_dialog = TkWarningObj.new(parent_window, "Invalid input")
#   warn_dialog.show
#
# @see TkWarning For auto-showing warning dialogs
# @see Tk.messageBox For more flexible message dialogs
class TkWarningObj < TkDialogObj
  def initialize(parent = nil, mes = nil)
    if !mes
      if parent.respond_to?(:path)
        mes = ""
      else
        mes = parent.to_s
        parent = nil
      end
    end
    super(parent, :message=>mes)
  end

  def show(mes = nil)
    mes_bup = @message
    @message = mes if mes
    ret = super()
    @message = mes_bup
    ret
  end

  #######
  private

  def title
    return "WARNING";
  end
  def bitmap
    return "warning";
  end
  def default_button
    return 0;
  end
  def buttons
    return "OK";
  end
end
TkWarning2 = TkWarningObj

# Warning dialog that automatically shows when instantiated.
#
# Combines {TkWarningObj}'s pre-configured warning appearance with
# auto-show behavior (like {TkDialog}).
#
# @example One-liner warning
#   TkWarning.new("Operation failed!")
#
# @see TkWarningObj For warnings that don't auto-show
class TkWarning < TkWarningObj
  def self.show(*args)
    self.new(*args)
  end
  def initialize(*args)
    super(*args)
    show
  end
end
