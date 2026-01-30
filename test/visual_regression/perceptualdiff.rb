# frozen_string_literal: true

require 'open3'

module VisualRegression
  # Image comparison for visual regression testing.
  # Uses ImageMagick's compare command to detect pixel differences.
  class Perceptualdiff
    class NotInstalledError < StandardError; end

    Result = Struct.new(:passed, :pixel_diff, :output, :diff_image, keyword_init: true) do
      def passed?
        passed
      end

      def failed?
        !passed
      end
    end

    DEFAULT_THRESHOLD = 100

    attr_reader :threshold

    def initialize(threshold: DEFAULT_THRESHOLD)
      @threshold = threshold
    end

    # Compare two images and return a Result
    #
    # @param expected [String] Path to the expected (blessed) image
    # @param actual [String] Path to the actual (unverified) image
    # @param diff_output [String, nil] Path to write diff image (optional)
    # @return [Result]
    def compare(expected:, actual:, diff_output: nil)
      validate_installation!
      validate_files!(expected, actual)

      args = build_args(expected, actual, diff_output)
      stdout, stderr, status = Open3.capture3(*args)
      output = stdout + stderr

      parse_result(output, status, diff_output)
    end

    # Check if ImageMagick compare is installed
    def self.installed?
      _, _, status = Open3.capture3('magick', 'compare', '-version')
      return true if status.success?

      # Fallback: try standalone compare command
      _, _, status = Open3.capture3('compare', '-version')
      status.success?
    end

    # Get the compare command (magick compare or standalone compare)
    def self.compare_command
      _, _, status = Open3.capture3('magick', 'compare', '-version')
      status.success? ? ['magick', 'compare'] : ['compare']
    end

    private

    def validate_installation!
      return if self.class.installed?

      raise NotInstalledError, <<~MSG
        ImageMagick is not installed. Install it with:
          macOS: brew install imagemagick
          Linux: apt-get install imagemagick
          Windows: pacman -S mingw-w64-ucrt-x86_64-imagemagick
      MSG
    end

    def validate_files!(*files)
      files.each do |file|
        raise ArgumentError, "File not found: #{file}" unless File.exist?(file)
      end
    end

    def build_args(expected, actual, diff_output)
      args = self.class.compare_command + ['-metric', 'AE']
      args += [expected, actual]
      args += [diff_output || 'null:']  # null: discards diff if not needed
      args
    end

    def parse_result(output, status, diff_output)
      pixel_diff = extract_pixel_diff(output)
      # compare returns exit code 1 if images differ, 0 if identical
      # We consider it "passed" if pixel diff is within threshold
      passed = pixel_diff.nil? ? status.success? : pixel_diff <= threshold

      Result.new(
        passed: passed,
        pixel_diff: pixel_diff,
        output: output.strip,
        diff_image: diff_output
      )
    end

    def extract_pixel_diff(output)
      # ImageMagick compare outputs just the number to stderr
      if output =~ /^(\d+)$/m
        $1.to_i
      elsif output =~ /(\d+)/
        $1.to_i
      else
        nil
      end
    end

    # Check if ImageMagick's composite command is installed
    def self.composite_installed?
      _, _, status = Open3.capture3('magick', 'composite', '-version')
      return true if status.success?

      _, _, status = Open3.capture3('composite', '-version')
      status.success?
    end

    # Get the composite command
    def self.composite_command
      _, _, status = Open3.capture3('magick', 'composite', '-version')
      status.success? ? ['magick', 'composite'] : ['composite']
    end

    # Create an overlay image showing the diff on top of the blessed image
    # Requires ImageMagick's composite command
    #
    # @param blessed [String] Path to the blessed image
    # @param diff [String] Path to the diff image
    # @param output [String] Path for the output overlay image
    # @return [Boolean] true if successful
    def self.create_overlay(blessed:, diff:, output:)
      unless composite_installed?
        warn "    (overlay skipped: install imagemagick for overlay images)"
        return false
      end
      return false unless File.exist?(blessed) && File.exist?(diff)

      # Use ImageMagick composite to blend diff (50% opacity) over blessed
      cmd = composite_command + ['-dissolve', '50', '-gravity', 'center', diff, blessed, output]
      _, _, status = Open3.capture3(*cmd)
      status.success?
    end
  end
end
