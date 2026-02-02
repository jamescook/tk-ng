# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class YARD::TestHasContent < Minitest::Test
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

  def test_method_with_docs_gets_has_docs_class
    File.write(File.join(@source_dir, "example.rb"), <<~RUBY)
      class Example
        # This method has documentation.
        # @param name [String] the name
        # @return [String] a greeting
        def greet(name)
          "Hello, \#{name}"
        end

        # No tags, just a description.
        def simple
        end

        def undocumented
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    output_file = File.join(@output_dir, "Example.md")
    assert File.exist?(output_file), "Example.md should exist"

    content = File.read(output_file)

    # Method with full docs should have has-docs class
    assert_match(/class="method-card has-docs".*greet/m, content,
      "greet method should have has-docs class")

    # Method with just description should have has-docs class
    assert_match(/class="method-card has-docs".*simple/m, content,
      "simple method should have has-docs class")

    # Undocumented method should NOT have has-docs class
    # Check the specific div for undocumented method
    assert_match(/<div class="method-card" markdown="1">\s*\n\s*## undocumented/m, content,
      "undocumented method should have method-card without has-docs class")
  end

  def test_method_with_only_tags_gets_has_docs_class
    File.write(File.join(@source_dir, "tags_only.rb"), <<~RUBY)
      class TagsOnly
        # @return [Boolean]
        def tagged?
        end
      end
    RUBY

    generate_markdown(@source_dir, @output_dir)

    content = File.read(File.join(@output_dir, "TagsOnly.md"))
    assert_match(/class="method-card has-docs".*tagged/m, content,
      "method with only tags should have has-docs class")
  end

  private

  def generate_markdown(source_dir, output_dir)
    YARD::Registry.clear
    YARD.parse(File.join(source_dir, "**", "*.rb"))

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
