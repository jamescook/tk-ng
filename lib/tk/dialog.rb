# frozen_string_literal: false
#
#   tk/dialog.rb : create dialog boxes
#
require 'tk/variable.rb'

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
class TkDialogObj < TkWindow
  extend Tk

  TkCommandNames = ['tk_dialog'.freeze].freeze

  # Creates and immediately shows a dialog, returning the dialog object.
  # @param args [Array] Arguments passed to {#initialize}
  # @return [TkDialogObj] The dialog object (call {#value} to get result)
  def self.show(*args)
    dlog = self.new(*args)
    dlog.show
    dlog
  end

  def _set_button_config(configs)
    set_config = proc{|c,i|
      if $VERBOSE && (c.has_key?('command') || c.has_key?(:command))
        STDERR.print("Warning: cannot give a command option " +
                     "to the dialog button#{i}. It was removed.\n")
      end
      c.delete('command'); c.delete(:command)
      # @config << Kernel.format("%s.button%s configure %s; ",
      #                                @path, i, hash_kv(c).join(' '))
      # @config << @path+'.button'+i.to_s+' configure '+hash_kv(c).join(' ')+'; '
      @config << @path+'.button'+i.to_s+' configure '+
                   array2tk_list(hash_kv(c))+'; '
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
    # @config = 'after idle {' + @config + '};' if @config != ""
    @config = array2tk_list(['after', 'idle', @config]) << ';' if @config != ""
  end
  private :_set_button_config

  # initialize tk_dialog
  def create_self(keys)
    # @var = TkVariable.new
    @val = nil

    @title   = title

    @message = message
    @message_config = message_config
    @msgframe_config = msgframe_config

    @bitmap  = bitmap
    @bitmap_config = message_config

    @default_button = default_button

    @buttons = buttons
    @button_configs = proc{|num| button_configs(num)}
    @btnframe_config = btnframe_config

    #@config = "puts [winfo children .w0000];"
    @config = ""

    @command = prev_command

    if keys.kind_of?(Hash)
      @title   = keys['title'] if keys.key? 'title'
      @message = keys['message'] if keys.key? 'message'
      @bitmap  = keys['bitmap'] if keys.key? 'bitmap'
      # @bitmap  = '{}' if @bitmap == nil || @bitmap == ""
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

    #if @title.include? ?\s
    #  @title = '{' + @title + '}'
    #end

    if @buttons.kind_of?(Array)
      _set_button_config(@buttons.collect{|cfg|
                           (cfg.kind_of? Array)? cfg[1]: nil})
      @buttons = @buttons.collect{|cfg| (cfg.kind_of? Array)? cfg[0]: cfg}
    end
    if @buttons.kind_of?(Hash)
      _set_button_config(@buttons)
      @buttons = @buttons.keys
    end
    @buttons = tk_split_simplelist(@buttons) if @buttons.kind_of?(String)
    @buttons = [] unless @buttons
=begin
    @buttons = @buttons.collect{|s|
      if s.kind_of?(Array)
        s = s.join(' ')
      end
      if s.include? ?\s
        '{' + s + '}'
      else
        s
      end
    }
=end

    if @message_config.kind_of?(Hash)
      # @config << Kernel.format("%s.msg configure %s;",
      #                        @path, hash_kv(@message_config).join(' '))
      # @config << @path+'.msg configure '+hash_kv(@message_config).join(' ')+';'
      @config << @path+'.msg configure '+
                   array2tk_list(hash_kv(@message_config))+';'
    end

    if @msgframe_config.kind_of?(Hash)
      # @config << Kernel.format("%s.top configure %s;",
      #                        @path, hash_kv(@msgframe_config).join(' '))
      # @config << @path+'.top configure '+hash_kv(@msgframe_config).join(' ')+';'
      @config << @path+'.top configure '+
                   array2tk_list(hash_kv(@msgframe_config))+';'
    end

    if @btnframe_config.kind_of?(Hash)
      # @config << Kernel.format("%s.bot configure %s;",
      #                        @path, hash_kv(@btnframe_config).join(' '))
      # @config << @path+'.bot configure '+hash_kv(@btnframe_config).join(' ')+';'
      @config << @path+'.bot configure '+
                   array2tk_list(hash_kv(@btnframe_config))+';'
    end

    if @bitmap_config.kind_of?(Hash)
      # @config << Kernel.format("%s.bitmap configure %s;",
      #                        @path, hash_kv(@bitmap_config).join(' '))
      # @config << @path+'.bitmap configure '+hash_kv(@bitmap_config).join(' ')+';'
      @config << @path+'.bitmap configure '+
                    array2tk_list(hash_kv(@bitmap_config))+';'
    end

    _set_button_config(@button_configs) if @button_configs
  end
  private :create_self

  # Displays the dialog and waits for user interaction.
  #
  # This method blocks until the user clicks a button or closes the dialog.
  # During display, a local grab prevents interaction with other application
  # windows.
  #
  # @return [Integer] The button index (0 for leftmost, 1 for next, etc.)
  # @note Returns -1 if the dialog window is destroyed before a button is clicked.
  def show
    # if @command.kind_of?(Proc)
    if TkComm._callback_entry?(@command)
      @command.call(self)
    end

    if @default_button.kind_of?(String)
      default_button = @buttons.index(@default_button)
    else
      default_button = @default_button
    end
    # default_button = '{}' if default_button == nil
    default_button = '' if default_button == nil
    #Tk.ip_eval('eval {global '+@var.id+';'+@config+
    #          'set '+@var.id+' [tk_dialog '+
    #          @path+" "+@title+" {#{@message}} "+@bitmap+" "+
    #          String(default_button)+" "+@buttons.join(' ')+']}')
    Tk.ip_eval(@config)
    # @val = Tk.ip_eval('tk_dialog ' + @path + ' ' + @title +
    #                 ' {' + @message + '} ' + @bitmap + ' ' +
    #                 String(default_button) + ' ' + @buttons.join(' ')).to_i
    # @val = Tk.ip_eval(self.class::TkCommandNames[0] + ' ' + @path + ' ' +
    #                   @title + ' {' + @message + '} ' + @bitmap + ' ' +
    #                   String(default_button) + ' ' + @buttons.join(' ')).to_i
    @val = Tk.ip_eval(array2tk_list([
                                      self.class::TkCommandNames[0],
                                      @path, @title, @message, @bitmap,
                                      String(default_button)
                                    ].concat(@buttons))).to_i
  end

  # Returns the index of the button that was clicked.
  # @return [Integer, nil] 0 for leftmost button, 1 for next, etc.
  #   Returns -1 if dialog was destroyed, nil if not yet shown.
  def value
    # @var.value.to_i
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
    # returns a title string of the dialog window
    return "DIALOG"
  end
  def message
    # returns a message text to display on the dialog
    return "MESSAGE"
  end
  def message_config
    # returns a Hash {option=>value, ...} for the message text
    return nil
  end
  def msgframe_config
    # returns a Hash {option=>value, ...} for the message text frame
    return nil
  end
  def bitmap
    # returns a bitmap name or a bitmap file path
    # (@ + path ; e.g. '@/usr/share/bitmap/sample.xbm')
    return "info"
  end
  def bitmap_config
    # returns nil or a Hash {option=>value, ...} for the bitmap
    return nil
  end
  def default_button
    # returns a default button's number or name
    # if nil or null string, set no-default
    return 0
  end
  def buttons
    #return "BUTTON1 BUTTON2"
    return ["BUTTON1", "BUTTON2"]
  end
  def button_configs(num)
    # returns nil / Proc / Array or Hash (see _set_button_config)
    return nil
  end
  def btnframe_config
    # returns nil or a Hash {option=>value, ...} for the button frame
    return nil
  end
  def prev_command
    # returns nil or a Proc
    return nil
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
      if parent.kind_of?(TkWindow)
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
