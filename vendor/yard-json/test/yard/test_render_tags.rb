# frozen_string_literal: true

require "test_helper"

# Unit tests for render_tags - testing the function directly
class YARD::TestRenderTags < Minitest::Test
  def setup
    YARD::Registry.clear
  end

  def test_param_tag_includes_parameter_name
    YARD.parse_string <<~RUBY
      class Example
        # Does something useful.
        #
        # @param name [String] the user's name
        # @param age [Integer] the user's age
        # @return [Boolean] success status
        def greet(name, age)
        end
      end
    RUBY

    method_obj = YARD::Registry.at("Example#greet")
    output = render_tags(method_obj)

    # Exact expected lines
    assert_includes output, "**@param** name [String] the user's name"
    assert_includes output, "**@param** age [Integer] the user's age"
    assert_includes output, "**@return** [Boolean] success status"
  end

  def test_yieldparam_tag_includes_parameter_name
    YARD.parse_string <<~RUBY
      class Example
        # Yields stuff.
        #
        # @yield [item] yields each item
        # @yieldparam item [Object] the yielded item
        def each(&block)
        end
      end
    RUBY

    method_obj = YARD::Registry.at("Example#each")
    output = render_tags(method_obj)

    assert_includes output, "**@yield** [item] yields each item"
    assert_includes output, "**@yieldparam** item [Object] the yielded item"
  end

  def test_option_tag_includes_option_name
    YARD.parse_string <<~RUBY
      class Example
        # Configures settings.
        #
        # @param opts [Hash] the options
        # @option opts [String] :host the hostname
        # @option opts [Integer] :port the port number
        def configure(opts = {})
        end
      end
    RUBY

    method_obj = YARD::Registry.at("Example#configure")
    output = render_tags(method_obj)

    assert_includes output, "**@param** opts [Hash] the options"
    assert_includes output, "**@option** :host [String] the hostname"
    assert_includes output, "**@option** :port [Integer] the port number"
  end

  def test_deprecated_tag_renders
    YARD.parse_string <<~RUBY
      class Example
        # Old method.
        #
        # @deprecated Use new_method instead
        def old_method
        end
      end
    RUBY

    method_obj = YARD::Registry.at("Example#old_method")
    output = render_tags(method_obj)

    assert_includes output, "**@deprecated** [] Use new_method instead"
  end

  def test_example_tag_renders_with_code_block
    YARD.parse_string <<~RUBY
      class Example
        # Does something.
        #
        # @example Basic usage
        #   foo.bar(1, 2)
        def bar(a, b)
        end
      end
    RUBY

    method_obj = YARD::Registry.at("Example#bar")
    output = render_tags(method_obj)

    expected = <<~MD.strip
      **@example**
      ```ruby
      foo.bar(1, 2)
      ```
    MD
    assert_includes output, expected
  end

  private

  # Fixed version of render_tags that includes tag.name
  # Must match templates/default/fulldoc/markdown/setup.rb
  def render_tags(object)
    result = String.new("")
    object.tags.each do |tag|
      result << case tag.tag_name
      when "example"
        ""
      when "option"
        # @option tags store the actual option in tag.pair
        opt = tag.pair
        "**@#{tag.tag_name}** #{opt.name} [#{opt.types&.join(', ')}] #{opt.text}\n\n"
      else
        name_part = tag.name ? "#{tag.name} " : ""
        "**@#{tag.tag_name}** #{name_part}[#{tag.types&.join(', ')}] #{tag.text}\n\n"
      end
    end

    object.tags.each do |tag|
      result << if tag.tag_name == "example"
        "\n**@#{tag.tag_name}**\n```ruby\n#{tag.text}\n```"
      else
        ""
      end
    end

    result
  end
end
