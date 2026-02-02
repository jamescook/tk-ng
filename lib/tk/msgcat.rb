# frozen_string_literal: false
#
#   tk/msgcat.rb : methods for Tcl message catalog
#                     by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>
#

# Internationalization (i18n) support via Tcl's msgcat package.
#
# TkMsgCatalog provides message translation for multilingual applications.
# It automatically detects the user's locale and loads appropriate
# translation files.
#
# ## Basic Usage
#
#     # Set up translations
#     TkMsgCatalog.set_translation('en', 'Hello', 'Hello')
#     TkMsgCatalog.set_translation('es', 'Hello', 'Hola')
#     TkMsgCatalog.set_translation('ja', 'Hello', 'こんにちは')
#
#     # Translate (uses current locale)
#     TkMsgCatalog['Hello']  # => "Hola" (if locale is es)
#
# ## Loading Translation Files
#
# Create `.msg` files for each locale in a translations directory:
#
#     # translations/en.msg
#     en 'Hello', 'Hello'
#     en 'Goodbye', 'Goodbye'
#
#     # translations/es.msg
#     es 'Hello', 'Hola'
#     es 'Goodbye', 'Adiós'
#
# Then load them:
#
#     TkMsgCatalog.load('translations')
#
# ## Locale Detection
#
# The locale is auto-detected from environment variables (LANG, LC_ALL,
# etc.) but can be set explicitly:
#
#     TkMsgCatalog.locale = 'es'
#
# ## Namespace Scoping
#
# For large applications, use separate catalogs per namespace to avoid
# translation conflicts:
#
#     app_cat = TkMsgCatalog.new('::myapp')
#     app_cat.set_translation('en', 'title', 'My Application')
#
#     plugin_cat = TkMsgCatalog.new('::myapp::plugin')
#     plugin_cat.set_translation('en', 'title', 'Plugin Title')
#
# ## Missing Translations
#
# By default, missing translations return the source string. Set a
# custom handler for logging or fallback behavior:
#
#     TkMsgCatalog.def_unknown_proc do |locale, src|
#       warn "Missing translation for '#{src}' in #{locale}"
#       src
#     end
#
# @example Complete i18n setup
#   # In translations/en.msg:
#   en 'file_menu', 'File'
#   en 'edit_menu', 'Edit'
#   en 'open_cmd', 'Open'
#
#   # In translations/ja.msg:
#   ja 'file_menu', 'ファイル'
#   ja 'edit_menu', '編集'
#   ja 'open_cmd', '開く'
#
#   # In your application:
#   TkMsgCatalog.load('translations')
#
#   menu_spec = [
#     [[TkMsgCatalog['file_menu'], 0],
#       [TkMsgCatalog['open_cmd'], proc { open_file }]
#     ]
#   ]
#
# @see https://www.tcl-lang.org/man/tcl8.6/TclCmd/msgcat.htm Tcl msgcat manual
class TkMsgCatalog < TkObject
  include TkCore
  extend Tk
  #extend TkMsgCatalog

  TkCommandNames = [
    '::msgcat::mc'.freeze,
    '::msgcat::mcmax'.freeze,
    '::msgcat::mclocale'.freeze,
    '::msgcat::mcpreferences'.freeze,
    '::msgcat::mcload'.freeze,
    '::msgcat::mcset'.freeze,
    '::msgcat::mcmset'.freeze,
    '::msgcat::mcunknown'.freeze
  ].freeze

  # Note: Removed legacy 'package require Tcl 8.2' check.
  # We require Tcl 8.6+ in our C bridge, and Tcl 9's package system
  # doesn't consider itself compatible with 8.x version requirements.

  PACKAGE_NAME = 'msgcat'.freeze
  def self.package_name
    PACKAGE_NAME
  end

  if self.const_defined? :FORCE_VERSION
    tk_call_without_enc('package', 'require', 'msgcat', FORCE_VERSION)
  else
    tk_call_without_enc('package', 'require', 'msgcat')
  end

  MSGCAT_EXT = '.msg'

  # Table of unknown translation callbacks indexed by [interp][namespace]
  UNKNOWN_CBTBL = Hash.new{|hash,key| hash[key] = {}}

  # Callback invoked from Tcl unknowncmd procs
  def self.unknown_callback(namespace, locale, src_str, *args)
    src_str = sprintf(src_str, *args) unless args.empty?
    cmd_tbl = TkMsgCatalog::UNKNOWN_CBTBL[TkCore::INTERP.__getip]
    cmd = cmd_tbl[namespace]
    return src_str unless cmd  # no cmd -> return src-str (default action)
    begin
      cmd.call(locale, src_str)
    rescue SystemExit
      exit(0)
    rescue Interrupt
      exit!(1)
    rescue StandardError => e
      begin
        msg = e.class.inspect + ': ' +
              e.message + "\n" +
              "\n---< backtrace of Ruby side >-----\n" +
              e.backtrace.join("\n") +
              "\n---< backtrace of Tk side >-------"
        msg.force_encoding('utf-8')
      rescue StandardError
        msg = e.class.inspect + ': ' + e.message + "\n" +
              "\n---< backtrace of Ruby side >-----\n" +
              e.backtrace.join("\n") +
              "\n---< backtrace of Tk side >-------"
      end
      fail(e, msg)
    end
  end

  # Create a message catalog for a namespace.
  #
  # @param namespace [TkNamespace, String, nil] Namespace for translations.
  #   nil uses global namespace (::)
  #
  # @example Global catalog
  #   cat = TkMsgCatalog.new
  #
  # @example Namespaced catalog
  #   cat = TkMsgCatalog.new('::myapp')
  def initialize(namespace = nil)
    if namespace.kind_of?(TkNamespace)
      @namespace = namespace
    elsif namespace == nil
      @namespace = TkNamespace.new('::')  # global namespace
    else
      @namespace = TkNamespace.new(namespace)
    end
    @path = @namespace.path

    @msgcat_ext = '.msg'
  end

  # @return [String] File extension for translation files (default: '.msg')
  attr_accessor :msgcat_ext

  def method_missing(id, *args)
    # locale(src, trans) ==> set_translation(locale, src, trans)
    loc = id.id2name
    case args.length
    when 0 # set locale
      self.locale=(loc)

    when 1 # src only, or trans_list
      if args[0].kind_of?(Array)
        # trans_list
        #list = args[0].collect{|src, trans|
        #  [ Tk::UTF8_String.new(src), Tk::UTF8_String.new(trans) ]
        #}
        self.set_translation_list(loc, args[0])
      else
        # src
        #self.set_translation(loc, Tk::UTF8_String.new(args[0]))
        self.set_translation(loc, args[0])
      end

    when 2 # src and trans, or, trans_list and enc
      if args[0].kind_of?(Array)
        # trans_list
        self.set_translation_list(loc, *args)
      else
        #self.set_translation(loc, args[0], Tk::UTF8_String.new(args[1]))
        self.set_translation(loc, *args)
      end

    when 3 # src and trans and enc
      self.set_translation(loc, *args)

    else
      super(id, *args)
#      fail NameError, "undefined method `#{name}' for #{self.to_s}", error_at

    end
  end

  # Translate a message using the current locale.
  #
  # If multiple arguments given, the first is a format string and
  # remaining arguments are substituted (like sprintf).
  #
  # @param args [Array<String>] Source string(s) to translate
  # @return [String] Translated string
  #
  # @example Simple translation
  #   TkMsgCatalog['Hello']  # => "Hola"
  #
  # @example With format substitution
  #   TkMsgCatalog['Hello %s', 'World']  # => "Hola World"
  def self.translate(*args)
    dst = args.collect{|src|
      tk_call_without_enc('::msgcat::mc', _get_eval_string(src, true))
    }
    sprintf(*dst)
  end
  class << self
    alias mc translate
    # @!method [](src, *args)
    # Alias for {.translate}
    alias [] translate
  end

  # (see .translate)
  def translate(*args)
    dst = args.collect{|src|
      @namespace.eval{tk_call_without_enc('::msgcat::mc',
                                          _get_eval_string(src, true))}
    }
    sprintf(*dst)
  end
  alias mc translate
  alias [] translate

  def self.maxlen(*src_strings)
    tk_call('::msgcat::mcmax', *src_strings).to_i
  end
  def maxlen(*src_strings)
    @namespace.eval{tk_call('::msgcat::mcmax', *src_strings).to_i}
  end

  # Get the current locale.
  #
  # @return [String] Locale code (e.g., "en", "en_us", "ja_jp")
  #
  # @example
  #   TkMsgCatalog.locale  # => "en_us"
  def self.locale
    tk_call('::msgcat::mclocale')
  end

  # (see .locale)
  def locale
    @namespace.eval{tk_call('::msgcat::mclocale')}
  end

  # Set the current locale.
  #
  # @param locale [String] Locale code
  # @return [String] The new locale
  #
  # @example
  #   TkMsgCatalog.locale = 'ja'
  def self.locale=(locale)
    tk_call('::msgcat::mclocale', locale)
  end

  # (see .locale=)
  def locale=(locale)
    @namespace.eval{tk_call('::msgcat::mclocale', locale)}
  end

  # Get locale preference list.
  #
  # Returns locales to search in order of preference, from most
  # specific to least (e.g., `['en_us', 'en', '']`).
  #
  # @return [Array<String>] Locale codes in preference order
  def self.preferences
    tk_split_simplelist(tk_call('::msgcat::mcpreferences'))
  end

  # (see .preferences)
  def preferences
    tk_split_simplelist(@namespace.eval{tk_call('::msgcat::mcpreferences')})
  end

  # Load Tcl-format translation files from a directory.
  #
  # @param dir [String] Directory containing .msg files
  # @return [Integer] Number of files loaded
  def self.load_tk(dir)
    number(tk_call('::msgcat::mcload', dir))
  end

  # Load Ruby-format translation files from a directory.
  #
  # Looks for files named `{locale}.msg` (e.g., `en.msg`, `ja.msg`)
  # and evaluates them. Files should contain calls like:
  #
  #     en 'Hello', 'Hello'
  #     en 'Goodbye', 'Goodbye'
  #
  # @param dir [String] Directory containing .msg files
  # @return [Integer] Number of files loaded
  def self.load_rb(dir)
    count = 0
    preferences().each{|loc|
      file = File.join(dir, loc + self::MSGCAT_EXT)
      if File.readable?(file)
        count += 1
        eval(IO.read(file, encoding: "ASCII-8BIT"))
      end
    }
    count
  end

  # (see .load_tk)
  def load_tk(dir)
    number(@namespace.eval{tk_call('::msgcat::mcload', dir)})
  end

  # (see .load_rb)
  def load_rb(dir)
    count = 0
    preferences().each{|loc|
      file = File.join(dir, loc + @msgcat_ext)
      if File.readable?(file)
        count += 1
        @namespace.eval(IO.read(file, encoding: "ASCII-8BIT"))
      end
    }
    count
  end

  # Load translation files (alias for {.load_rb}).
  #
  # @param dir [String] Directory containing .msg files
  # @return [Integer] Number of files loaded
  def self.load(dir)
    self.load_rb(dir)
  end
  alias load load_rb

  # Set a translation for a locale.
  #
  # @param locale [String] Locale code (e.g., 'en', 'ja')
  # @param src_str [String] Source string (key)
  # @param trans_str [String, nil] Translated string (nil to clear)
  # @param enc [String] Encoding (default: 'utf-8')
  # @return [String] The translation
  #
  # @example
  #   TkMsgCatalog.set_translation('es', 'Hello', 'Hola')
  #   TkMsgCatalog.set_translation('ja', 'Hello', 'こんにちは')
  def self.set_translation(locale, src_str, trans_str=None, enc='utf-8')
    if trans_str && trans_str != None
      tk_call_without_enc('::msgcat::mcset', locale,
                          _get_eval_string(src_str, true), trans_str)
    else
      tk_call_without_enc('::msgcat::mcset', locale,
                          _get_eval_string(src_str, true))
    end
  end

  # (see .set_translation)
  def set_translation(locale, src_str, trans_str=None, enc='utf-8')
    # ScopeArgs overrides tk_call_without_enc to wrap with namespace eval
    if trans_str && trans_str != None
      @namespace.eval{
        tk_call_without_enc('::msgcat::mcset', locale,
                            _get_eval_string(src_str, true), trans_str)
      }
    else
      @namespace.eval{
        tk_call_without_enc('::msgcat::mcset', locale,
                            _get_eval_string(src_str, true))
      }
    end
  end

  # Set multiple translations for a locale at once.
  #
  # @param locale [String] Locale code
  # @param trans_list [Array<Array>] List of [source, translation] pairs
  # @param enc [String] Encoding (default: 'utf-8')
  # @return [Integer] Number of translations set
  #
  # @example
  #   TkMsgCatalog.set_translation_list('es', [
  #     ['Hello', 'Hola'],
  #     ['Goodbye', 'Adiós'],
  #     ['Yes', 'Sí']
  #   ])
  def self.set_translation_list(locale, trans_list, enc='utf-8')
    # trans_list ::= [ [src, trans], [src, trans], ... ]
    list = []
    trans_list.each{|src, trans|
      if trans && trans != None
        list << _get_eval_string(src, true)
        list << trans.to_s
      else
        list << _get_eval_string(src, true) << ''
      end
    }
    number(tk_call_without_enc('::msgcat::mcmset', locale, list))
  end

  # (see .set_translation_list)
  def set_translation_list(locale, trans_list, enc='utf-8')
    # trans_list ::= [ [src, trans], [src, trans], ... ]
    # ScopeArgs overrides tk_call_without_enc to wrap with namespace eval
    list = []
    trans_list.each{|src, trans|
      if trans && trans != None
        list << _get_eval_string(src, true)
        list << trans.to_s
      else
        list << _get_eval_string(src, true) << ''
      end
    }
    number(@namespace.eval{
             tk_call_without_enc('::msgcat::mcmset', locale, list)
           })
  end

  # Register a callback for missing translations.
  #
  # Called when a translation is not found. The callback receives
  # the locale and source string, and should return the string to use.
  #
  # @param cmd [Proc, nil] Callback proc (or use block)
  # @yield [locale, src_str] Called for missing translations
  # @yieldparam locale [String] Current locale
  # @yieldparam src_str [String] Source string that wasn't found
  # @yieldreturn [String] String to use instead
  #
  # @example Log missing translations
  #   TkMsgCatalog.def_unknown_proc do |locale, src|
  #     File.open('missing.log', 'a') { |f| f.puts "#{locale}: #{src}" }
  #     src  # Return source as fallback
  #   end
  #
  # @example Fallback to another locale
  #   TkMsgCatalog.def_unknown_proc do |locale, src|
  #     # Try English as fallback
  #     TkMsgCatalog.set_translation('en', src, src)
  #     src
  #   end
  def self.def_unknown_proc(cmd=nil, &block)
    ns_path = '::'
    TkMsgCatalog::UNKNOWN_CBTBL[TkCore::INTERP.__getip][ns_path] = cmd || block
    _setup_unknowncmd(ns_path)
  end

  # (see .def_unknown_proc)
  def def_unknown_proc(cmd=nil, &block)
    ns_path = @namespace.path
    TkMsgCatalog::UNKNOWN_CBTBL[TkCore::INTERP.__getip][ns_path] = cmd || block
    _setup_unknowncmd(ns_path)
  end

  private

  # Set up mcpackageconfig unknowncmd for the given namespace
  def _setup_unknowncmd(ns_path)
    self.class._setup_unknowncmd(ns_path)
  end

  # Callback IDs indexed by interpreter (like UNKNOWN_CBTBL)
  UNKNOWN_CB_IDS = {}

  def self._setup_unknowncmd(ns_path)
    # Create a unique Tcl proc name for this namespace's unknown handler
    # Replace :: with _ to make a valid proc name
    proc_suffix = ns_path.gsub('::', '_').sub(/^_/, '')
    proc_suffix = 'global' if proc_suffix.empty?
    proc_name = "::ruby_tk::msgcat_unknown_#{proc_suffix}"

    # Register Ruby callback if not already done (per-interpreter)
    ip = TkCore::INTERP.__getip
    UNKNOWN_CB_IDS[ip] ||= TkCore::INTERP.register_callback(
      proc { |*args| TkMsgCatalog.unknown_callback(*args) }
    )
    cb_id = UNKNOWN_CB_IDS[ip]

    # Create the Tcl proc that will call back to Ruby
    tk_call_without_enc('namespace', 'eval', '::ruby_tk', '')
    TkCore::INTERP._invoke_without_enc('proc', proc_name, 'args',
      "ruby_callback #{cb_id} {#{ns_path}} {*}$args")

    # Register it as the unknowncmd for this namespace
    TkCore::INTERP._invoke_without_enc(
      'namespace', 'eval', ns_path,
      "::msgcat::mcpackageconfig set unknowncmd #{proc_name}")
  end
end

TkMsgCat = TkMsgCatalog
