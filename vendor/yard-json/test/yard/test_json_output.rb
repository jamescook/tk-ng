# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"

class YARD::TestJsonOutput < Minitest::Test
  def setup
    YARD::Registry.clear
    @tmpdir = Dir.mktmpdir
    @source_dir = File.join(@tmpdir, "src")
    @output_dir = File.join(@tmpdir, "doc")
    FileUtils.mkdir_p(@source_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_json_output_structure
    File.write(File.join(@source_dir, "example.rb"), <<~RUBY)
      # A sample class for testing.
      #
      # @example Basic usage
      #   Example.new.greet("World")
      class Example
        # Greet someone.
        #
        # @param name [String] the name to greet
        # @return [String] the greeting
        # @see #farewell
        # @example Simple
        #   greet("Alice")
        # @example With title
        #   greet("Bob")
        def greet(name)
          "Hello, \#{name}"
        end

        # Say goodbye.
        # @return [String]
        def farewell
          "Goodbye"
        end

        def mystery
        end
      end
    RUBY

    generate_json(@source_dir, @output_dir)

    json_file = File.join(@output_dir, "Example.json")
    assert File.exist?(json_file), "Example.json should exist"

    doc = JSON.parse(File.read(json_file))

    # Basic structure
    assert_equal "Example", doc["name"]
    assert_equal "Example", doc["path"]
    assert_equal "class", doc["type"]
    assert_includes doc["docstring"], "sample class for testing"

    # Instance methods
    assert doc["instance_methods"], "Should have instance_methods"
    assert_equal 3, doc["instance_methods"].size

    # Find greet method
    greet = doc["instance_methods"].find { |m| m["name"] == "greet" }
    assert greet, "Should have greet method"
    assert_equal "greet(name)", greet["signature"]
    assert_includes greet["docstring"], "Greet someone"
    assert greet["has_content"], "greet should have content"

    # Check tags structure
    tags = greet["tags"]
    assert tags["regular"], "Should have regular tags"

    param_tag = tags["regular"].find { |t| t["tag"] == "param" }
    assert param_tag, "Should have @param tag"
    assert_equal "name", param_tag["name"]
    assert_equal ["String"], param_tag["types"]

    return_tag = tags["regular"].find { |t| t["tag"] == "return" }
    assert return_tag, "Should have @return tag"
    assert_equal ["String"], return_tag["types"]

    # Check @see tags grouped
    assert tags["see_also"], "Should have see_also"
    assert_equal 1, tags["see_also"].size
    assert_equal "instance_method", tags["see_also"][0]["type"]
    assert_equal "#farewell", tags["see_also"][0]["ref"]

    # Check @example tags grouped
    assert tags["examples"], "Should have examples"
    assert_equal 2, tags["examples"].size
    assert_equal "Simple", tags["examples"][0]["title"]
    assert_includes tags["examples"][0]["code"], "greet(\"Alice\")"

    # Check undocumented method
    mystery = doc["instance_methods"].find { |m| m["name"] == "mystery" }
    assert mystery, "Should have mystery method"
    refute mystery["has_content"], "mystery should NOT have content"
  end

  def test_class_methods
    File.write(File.join(@source_dir, "with_class_methods.rb"), <<~RUBY)
      class WithClassMethods
        # A class method.
        # @return [String]
        def self.class_greet
          "Hello from class"
        end

        # An instance method.
        def instance_greet
          "Hello from instance"
        end
      end
    RUBY

    generate_json(@source_dir, @output_dir)

    doc = JSON.parse(File.read(File.join(@output_dir, "WithClassMethods.json")))

    assert doc["class_methods"], "Should have class_methods"
    assert_equal 1, doc["class_methods"].size
    assert_equal "class_greet", doc["class_methods"][0]["name"]

    assert doc["instance_methods"], "Should have instance_methods"
    assert_equal 1, doc["instance_methods"].size
    assert_equal "instance_greet", doc["instance_methods"][0]["name"]
  end

  def test_inheritance_and_mixins
    File.write(File.join(@source_dir, "inheritance.rb"), <<~RUBY)
      module Greeter
        def greet; end
      end

      class Parent
      end

      class Child < Parent
        include Greeter
        extend Greeter
      end
    RUBY

    generate_json(@source_dir, @output_dir)

    doc = JSON.parse(File.read(File.join(@output_dir, "Child.json")))

    assert_equal "Parent", doc["superclass"]
    assert_includes doc["instance_mixins"], "Greeter"
    assert_includes doc["class_mixins"], "Greeter"
  end

  def test_see_tag_types
    File.write(File.join(@source_dir, "see_tags.rb"), <<~RUBY)
      class SeeTags
        # @see https://example.com
        # @see #instance_method
        # @see .class_method
        # @see OtherClass#method
        def documented
        end
      end
    RUBY

    generate_json(@source_dir, @output_dir)

    doc = JSON.parse(File.read(File.join(@output_dir, "SeeTags.json")))
    method = doc["instance_methods"].find { |m| m["name"] == "documented" }
    see_tags = method["tags"]["see_also"]

    assert_equal 4, see_tags.size

    url_tag = see_tags.find { |t| t["type"] == "url" }
    assert url_tag, "Should have URL see tag"
    assert_equal "https://example.com", url_tag["url"]

    instance_tag = see_tags.find { |t| t["type"] == "instance_method" }
    assert instance_tag, "Should have instance method see tag"
    assert_equal "#instance_method", instance_tag["ref"]

    class_tag = see_tags.find { |t| t["type"] == "class_method" }
    assert class_tag, "Should have class method see tag"
    assert_equal ".class_method", class_tag["ref"]

    external_tag = see_tags.find { |t| t["type"] == "external_method" }
    assert external_tag, "Should have external method see tag"
    assert_equal "OtherClass#method", external_tag["ref"]
  end

  def test_option_tags_grouped
    File.write(File.join(@source_dir, "options.rb"), <<~RUBY)
      class WithOptions
        # Configure the connection.
        #
        # @param opts [Hash] connection options
        # @option opts [String] :host the hostname
        # @option opts [Integer] :port the port number
        # @option opts [Boolean] :ssl use SSL
        # @return [Connection]
        def connect(opts = {})
        end
      end
    RUBY

    generate_json(@source_dir, @output_dir)

    doc = JSON.parse(File.read(File.join(@output_dir, "WithOptions.json")))
    method = doc["instance_methods"].find { |m| m["name"] == "connect" }
    tags = method["tags"]

    # Options should be grouped separately from regular tags
    assert tags["options"], "Should have options array"
    assert_equal 3, tags["options"].size

    host_opt = tags["options"].find { |o| o["name"] == ":host" }
    assert host_opt, "Should have :host option"
    assert_equal ["String"], host_opt["types"]
    assert_equal "the hostname", host_opt["text"]

    port_opt = tags["options"].find { |o| o["name"] == ":port" }
    assert port_opt, "Should have :port option"
    assert_equal ["Integer"], port_opt["types"]

    ssl_opt = tags["options"].find { |o| o["name"] == ":ssl" }
    assert ssl_opt, "Should have :ssl option"
    assert_equal ["Boolean"], ssl_opt["types"]

    # @param should still be in regular tags
    param_tag = tags["regular"].find { |t| t["tag"] == "param" }
    assert param_tag, "Should have @param in regular tags"
    assert_equal "opts", param_tag["name"]
  end

  private

  def generate_json(source_dir, output_dir)
    YARD::Registry.clear
    YARD.parse(File.join(source_dir, "**", "*.rb"))

    YARD::CLI::Yardoc.run(
      "--no-stats",
      "--quiet",
      "-o", output_dir,
      "-f", "json",
      "--no-save",
      source_dir
    )
  end
end
