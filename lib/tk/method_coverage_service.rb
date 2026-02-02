# frozen_string_literal: true

require "json"
require "prism"

module Tk
  # Transforms SimpleCov line coverage data into per-method coverage.
  #
  # Merges coverage data from all test suite result files, uses Prism to
  # parse Ruby source files and find method definitions, then maps
  # SimpleCov line coverage to calculate per-method percentages.
  #
  # @example
  #   service = MethodCoverageService.new(
  #     coverage_dir: "coverage",
  #     source_dirs: ["lib"]
  #   )
  #   service.call
  #   # => writes coverage/method_coverage.json
  #
  class MethodCoverageService
    attr_reader :coverage_dir, :source_dirs, :output_path

    def initialize(coverage_dir:, source_dirs: ["lib"], output_path: nil)
      @coverage_dir = coverage_dir
      @source_dirs = source_dirs
      @output_path = output_path || File.join(coverage_dir, "method_coverage.json")
    end

    def call
      coverage_files = Dir.glob(File.join(coverage_dir, "results", "*", "coverage.json"))
      if coverage_files.empty?
        warn "No coverage files found in #{coverage_dir}/results/*/coverage.json"
        return nil
      end

      coverage_data = load_and_merge_coverage(coverage_files)
      result = {}

      # Collect all methods from all files
      all_methods = []
      source_files.each do |file|
        all_methods.concat(extract_methods(file))
      end

      # Group by class path and calculate coverage
      all_methods.group_by { |m| m[:class_path] }.each do |class_path, methods|
        class_result = { "class_methods" => {}, "instance_methods" => {} }
        total_covered = 0
        total_relevant = 0

        methods.each do |method|
          file_coverage = coverage_data[method[:file]]
          next unless file_coverage

          cov = calculate_coverage(file_coverage, method[:start_line], method[:end_line])
          next unless cov

          if method[:scope] == :class
            class_result["class_methods"][method[:name]] = cov[:percent]
          else
            class_result["instance_methods"][method[:name]] = cov[:percent]
          end

          total_covered += cov[:covered]
          total_relevant += cov[:relevant]
        end

        next if class_result["class_methods"].empty? && class_result["instance_methods"].empty?

        if total_relevant > 0
          class_result["total"] = (total_covered.to_f / total_relevant * 100).round(1)
        end

        result[class_path] = class_result
      end

      File.write(output_path, JSON.pretty_generate(result))
      puts "Generated method coverage: #{output_path} (#{result.size} classes/modules)"
      result
    end

    private

    def load_and_merge_coverage(coverage_files)
      merged = {}

      # Read from coverage.json files
      coverage_files.each do |file|
        data = JSON.parse(File.read(file))
        merge_coverage_data(merged, data["coverage"])
      end

      # Also read from .resultset.json files (worker/subprocess results)
      resultset_files = Dir.glob(File.join(coverage_dir, "results", "*", ".resultset.json"))
      resultset_files.each do |file|
        data = JSON.parse(File.read(file))
        # Resultsets are nested: { "suite_name" => { "coverage" => { ... } } }
        data.each do |_suite_name, suite_data|
          next unless suite_data.is_a?(Hash) && suite_data["coverage"]
          merge_coverage_data(merged, suite_data["coverage"])
        end
      end

      merged
    end

    def merge_coverage_data(merged, coverage_hash)
      coverage_hash.each do |path, info|
        # Normalize Docker /app/... paths to local paths
        local_path = path.sub(%r{^/app/}, "")
        lines = info["lines"]
        if merged[local_path]
          merged[local_path] = merge_line_coverage(merged[local_path], lines)
        else
          merged[local_path] = lines
        end
      end
    end

    def merge_line_coverage(lines_a, lines_b)
      max_len = [lines_a.size, lines_b.size].max
      (0...max_len).map do |i|
        a = lines_a[i]
        b = lines_b[i]
        # null means not relevant, "ignored" also not relevant
        # Take max of numeric values, prefer non-null
        if a.nil? || a == "ignored"
          b
        elsif b.nil? || b == "ignored"
          a
        else
          [a.to_i, b.to_i].max
        end
      end
    end

    def source_files
      source_dirs.flat_map { |dir| Dir.glob("#{dir}/**/*.rb") }
    end

    def extract_methods(file)
      source = File.read(file)
      result = Prism.parse(source)
      methods = []

      visitor = MethodVisitor.new(methods, file)
      result.value.accept(visitor)

      methods
    rescue => e
      warn "Failed to parse #{file}: #{e.message}"
      []
    end

    def calculate_coverage(file_lines, start_line, end_line)
      relevant = 0
      covered = 0

      # Skip first line (def) and last line (end) - only count method body
      body_start = start_line + 1
      body_end = end_line - 1

      return nil if body_start > body_end  # empty method body

      (body_start..body_end).each do |line_num|
        next if line_num < 1 || line_num > file_lines.size
        line_cov = file_lines[line_num - 1]  # array is 0-indexed
        next if line_cov.nil? || line_cov == "ignored"  # not relevant
        relevant += 1
        covered += 1 if line_cov.to_i > 0
      end

      return nil if relevant == 0
      { covered: covered, relevant: relevant, percent: (covered.to_f / relevant * 100).round(1) }
    end

    # Prism AST visitor to extract method definitions with class context
    class MethodVisitor < Prism::Visitor
      def initialize(methods, file)
        @methods = methods
        @file = file
        @namespace_stack = []  # track current class/module nesting
        @singleton_depth = 0   # track if we're inside class << self
      end

      def visit_class_node(node)
        name = constant_path_to_string(node.constant_path)
        @namespace_stack.push(name)
        super
        @namespace_stack.pop
      end

      def visit_module_node(node)
        name = constant_path_to_string(node.constant_path)
        @namespace_stack.push(name)
        super
        @namespace_stack.pop
      end

      def visit_singleton_class_node(node)
        @singleton_depth += 1
        super
        @singleton_depth -= 1
      end

      def visit_def_node(node)
        return super if @namespace_stack.empty?  # skip top-level methods

        scope = if node.receiver || @singleton_depth > 0
          :class
        else
          :instance
        end

        @methods << {
          name: node.name.to_s,
          scope: scope,
          start_line: node.location.start_line,
          end_line: node.location.end_line,
          class_path: @namespace_stack.join("::"),
          file: @file
        }

        super
      end

      private

      def constant_path_to_string(node)
        case node
        when Prism::ConstantReadNode
          node.name.to_s
        when Prism::ConstantPathNode
          parent = node.parent ? constant_path_to_string(node.parent) + "::" : ""
          parent + node.name.to_s
        else
          node.to_s
        end
      end
    end
  end
end
