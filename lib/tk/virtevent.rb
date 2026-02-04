# frozen_string_literal: false
#
# tk/virtevent.rb : treats virtual events
#                   1998/07/16 by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>
#
# Virtual events are custom, application-defined events that can be triggered
# by one or more physical event sequences. They provide a layer of abstraction
# between the physical events (like key presses) and application actions.
#
# == Use Cases
#
# - Define application-specific shortcuts that can be customized
# - Create platform-independent bindings (different keys on Mac vs Windows)
# - Group multiple key sequences that trigger the same action
# - Define semantic events like <<Save>>, <<Undo>>, <<MyCustomAction>>
#
# == Example Usage
#
#   require 'tk'
#   require 'tk/virtevent'
#
#   # Create a virtual event triggered by Ctrl+S or F2
#   save_event = TkVirtualEvent.new('Control-s', 'F2')
#
#   # Bind a widget to the virtual event
#   button = TkButton.new(root, text: 'Click me')
#   button.bind(save_event.path) { puts "Save triggered!" }
#
#   # Add another trigger sequence later
#   save_event.add('Control-Shift-s')
#
#   # Query what sequences trigger this event
#   save_event.info  #=> ['Control-s', 'F2', 'Control-Shift-s']
#
#   # Remove a sequence
#   save_event.delete('F2')
#
#   # Delete the entire virtual event
#   save_event.delete
#
#   # Access predefined virtual events (platform-dependent)
#   TkVirtualEvent.info  #=> [<<Copy>>, <<Paste>>, <<Cut>>, ...]
#
require 'tk'
require_relative 'core/callable'

class TkVirtualEvent
  include Tk::Core::Callable
  extend Tk::Core::Callable

  TkCommandNames = ['event'.freeze].freeze

  (TkVirtualEventID = ["VirtEvent".freeze, "00000"]).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  TkVirtualEventTBL = TkCore::INTERP.create_table

  TkCore::INTERP.init_ip_env{
    TkVirtualEventTBL.mutex.synchronize{ TkVirtualEventTBL.clear }
  }

  class PreDefVirtEvent<self
    def self.new(event, *sequences)
      if event =~ /^<(<.*>)>$/
        event = $1
      elsif event !~ /^<.*>$/
        event = '<' + event + '>'
      end
      TkVirtualEvent::TkVirtualEventTBL.mutex.synchronize{
        if TkVirtualEvent::TkVirtualEventTBL.has_key?(event)
          TkVirtualEvent::TkVirtualEventTBL[event]
        else
          # super(event, *sequences)
          (obj = self.allocate).instance_eval{
            initialize(event, *sequences)
            TkVirtualEvent::TkVirtualEventTBL[@id] = self
          }
        end
      }
    end

    def initialize(event, *sequences)
      @path = @id = event
      add_sequences(sequences)
    end
  end

  def TkVirtualEvent.getobj(event)
    obj = nil
    TkVirtualEventTBL.mutex.synchronize{
      obj = TkVirtualEventTBL[event]
    }
    if obj
      obj
    else
      if tk_call('event', 'info').index("<#{event}>")
        PreDefVirtEvent.new(event)
      else
        fail ArgumentError, "undefined virtual event '<#{event}>'"
      end
    end
  end

  def TkVirtualEvent.info
    tk_call('event', 'info').split(/\s+/).collect!{|seq|
      TkVirtualEvent.getobj(seq[1..-2])
    }
  end

  def initialize(*sequences)
    TkVirtualEventID.mutex.synchronize{
      # @path = @id = '<' + TkVirtualEventID.join('') + '>'
      @path = @id = '<' + TkVirtualEventID.join(TkCore::INTERP._ip_id_) + '>'
      TkVirtualEventID[1].succ!
    }
    add_sequences(sequences)
  end

  attr_reader :path

  def to_eval
    @path
  end

  def add_sequences(seq_ary)
    unless seq_ary.empty?
      tk_call('event', 'add', "<#{@id}>",
                          *(seq_ary.collect{|seq|
                              "<#{tk_event_sequence(seq)}>"
                            }) )
    end
    self
  end
  private :add_sequences

  # Normalize an event sequence string or array.
  # Handles TkVirtualEvent objects, arrays, and comma-separated strings.
  def tk_event_sequence(context)
    if context.kind_of? TkVirtualEvent
      context = context.path
    end
    if context.kind_of? Array
      context = context.collect{|ev|
        if ev.kind_of? TkVirtualEvent
          ev.path
        else
          ev
        end
      }.join("><")
    end
    if /,/ =~ context
      context = context.split(/\s*,\s*/).join("><")
    else
      context
    end
  end
  private :tk_event_sequence

  def add(*sequences)
    if sequences != []
      add_sequences(sequences)
      TkVirtualEventTBL.mutex.synchronize{
        TkVirtualEventTBL[@id] = self
      }
    end
    self
  end

  def delete(*sequences)
    if sequences.empty?
      tk_call('event', 'delete', "<#{@id}>")
      TkVirtualEventTBL.mutex.synchronize{
        TkVirtualEventTBL.delete(@id)
      }
    else
      tk_call('event', 'delete', "<#{@id}>",
                          *(sequences.collect{|seq|
                              "<#{tk_event_sequence(seq)}>"
                            }) )
      if tk_call('event','info',"<#{@id}>").empty?
        TkVirtualEventTBL.mutex.synchronize{
          TkVirtualEventTBL.delete(@id)
        }
      end
    end
    self
  end

  def info
    tk_call('event','info',"<#{@id}>").split(/\s+/).collect!{|seq|
      lst = seq.scan(/<*[^<>]+>*/).collect!{|subseq|
        case (subseq)
        when /^<<[^<>]+>>$/
          TkVirtualEvent.getobj(subseq[1..-2])
        when /^<[^<>]+>$/
          subseq[1..-2]
        else
          subseq.split('')
        end
      }.flatten
      (lst.size == 1) ? lst[0] : lst
    }
  end
end

TkNamedVirtualEvent = TkVirtualEvent::PreDefVirtEvent
