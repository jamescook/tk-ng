# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

# Tests that modules with nested classes still get their own markdown file
class YARD::TestNestedModules < Minitest::Test
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

  def test_module_with_nested_class_gets_own_file
    # Create a module with methods AND a nested class
    File.write(File.join(@source_dir, "outer.rb"), <<~RUBY)
      # The outer module with its own methods.
      #
      # This module should get its own markdown file.
      module Outer
        # A module-level method.
        # @return [String] a greeting
        def self.greet
          "hello"
        end

        # A nested class inside Outer.
        class Inner
          # An inner method.
          # @return [Integer] the answer
          def answer
            42
          end
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    # Both Outer.md AND Outer/Inner.md should exist
    outer_file = File.join(@output_dir, "Outer.md")
    inner_file = File.join(@output_dir, "Outer", "Inner.md")

    assert File.exist?(outer_file), "Expected Outer.md to exist, but it doesn't. Files: #{Dir.glob(@output_dir + '/**/*')}"
    assert File.exist?(inner_file), "Expected Outer/Inner.md to exist"

    # Outer.md should contain the module docs and greet method
    outer_content = File.read(outer_file)
    assert_includes outer_content, "Module: Outer", "Should have module title"
    assert_includes outer_content, "greet", "Should document the greet method"
    assert_includes outer_content, "module-level method", "Should have method description"

    # Inner.md should contain the class docs
    inner_content = File.read(inner_file)
    assert_includes inner_content, "Class: Outer::Inner", "Should have class title"
    assert_includes inner_content, "answer", "Should document the answer method"
  end

  def test_deeply_nested_modules
    File.write(File.join(@source_dir, "deep.rb"), <<~RUBY)
      # Top level module.
      module Top
        # Top method.
        def self.top_method; end

        # Middle module.
        module Middle
          # Middle method.
          def self.middle_method; end

          # Bottom class.
          class Bottom
            # Bottom method.
            def bottom_method; end
          end
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    # All three should get their own files
    assert File.exist?(File.join(@output_dir, "Top.md")), "Top.md should exist"
    assert File.exist?(File.join(@output_dir, "Top", "Middle.md")), "Top/Middle.md should exist"
    assert File.exist?(File.join(@output_dir, "Top", "Middle", "Bottom.md")), "Top/Middle/Bottom.md should exist"
  end

  def test_module_without_docstring_still_gets_file
    # Module has methods but NO docstring - should still get a file
    File.write(File.join(@source_dir, "nodoc.rb"), <<~RUBY)
      module NoDoc
        # A method with docs.
        # @return [String]
        def self.some_method
          "value"
        end

        # Nested class.
        class Child
          # Child method.
          def child_method; end
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    nodoc_file = File.join(@output_dir, "NoDoc.md")
    child_file = File.join(@output_dir, "NoDoc", "Child.md")

    assert File.exist?(nodoc_file), "NoDoc.md should exist even without module docstring. Files: #{Dir.glob(@output_dir + '/**/*')}"
    assert File.exist?(child_file), "NoDoc/Child.md should exist"

    content = File.read(nodoc_file)
    assert_includes content, "some_method", "Should still document the method"
  end

  def test_module_reopened_multiple_times
    # Simulates Tk - module defined in multiple files
    File.write(File.join(@source_dir, "multi1.rb"), <<~RUBY)
      module Multi
        def self.method_one; end
      end
    RUBY

    File.write(File.join(@source_dir, "multi2.rb"), <<~RUBY)
      module Multi
        def self.method_two; end

        class Nested
          def nested_method; end
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    multi_file = File.join(@output_dir, "Multi.md")
    nested_file = File.join(@output_dir, "Multi", "Nested.md")

    assert File.exist?(multi_file), "Multi.md should exist. Files: #{Dir.glob(@output_dir + '/**/*')}"
    assert File.exist?(nested_file), "Multi/Nested.md should exist"

    content = File.read(multi_file)
    assert_includes content, "method_one", "Should have method from first file"
    assert_includes content, "method_two", "Should have method from second file"
  end

  def test_module_with_many_nested_children
    # This reproduces the Tk issue - module with many children spread across files
    # The parent module must still get its own .md file

    # Main module file with docstring
    File.write(File.join(@source_dir, "parent.rb"), <<~RUBY)
      # The parent module documentation.
      # @example Usage
      #   Parent.greet
      module Parent
        # Parent method.
        def self.greet
          "hello"
        end
      end
    RUBY

    # Many child classes in separate files (simulating Tk::Button, Tk::Canvas, etc.)
    %w[Alpha Beta Gamma Delta Epsilon].each do |name|
      File.write(File.join(@source_dir, "#{name.downcase}.rb"), <<~RUBY)
        module Parent
          class #{name}
            def #{name.downcase}_method; end
          end
        end
      RUBY
    end

    generate_markdown(@source_dir, @output_dir)

    # Parent.md MUST exist alongside Parent/ directory
    parent_file = File.join(@output_dir, "Parent.md")
    parent_dir = File.join(@output_dir, "Parent")

    files = Dir.glob(@output_dir + "/**/*")
    assert File.exist?(parent_file), "Parent.md should exist even with many children. Files: #{files.join(', ')}"
    assert File.directory?(parent_dir), "Parent/ directory should exist"

    # All children should exist
    %w[Alpha Beta Gamma Delta Epsilon].each do |name|
      child_file = File.join(parent_dir, "#{name}.md")
      assert File.exist?(child_file), "#{name}.md should exist in Parent/"
    end

    # Parent.md should have the module documentation
    content = File.read(parent_file)
    assert_includes content, "parent module documentation", "Should have module docstring"
    assert_includes content, "greet", "Should have the greet method"
  end

  private

  def generate_markdown(source_dir, output_dir)
    YARD::Registry.clear
    YARD.parse(File.join(source_dir, "**", "*.rb"))

    # Run YARD with markdown format
    YARD::CLI::Yardoc.run(
      "--no-stats",
      "--quiet",
      "-o", output_dir,
      "-f", "markdown",
      "--no-save",
      source_dir
    )
  end
end
