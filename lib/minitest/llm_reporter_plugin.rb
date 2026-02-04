# frozen_string_literal: true

require "json"

# Minitest plugin: JSONL reporter for LLM consumption
#
# Emits one JSON object per line. Passes are silent.
# Only failures, errors, and a final summary line are emitted.
#
# On by default when required. Disable with MINITEST_REPORTER=default or -v.
#
# Options:
#   --llm-backtrace N      max backtrace lines per failure (default: 3, 0=all)
#   --llm-suite NAME       tag output with suite name (for multi-suite runs)
#
# Env vars:
#   MINITEST_REPORTER=default      disable JSONL, use standard minitest output
#   MINITEST_LLM_BACKTRACE=5       max backtrace lines (default: 3, 0=all)
#   MINITEST_LLM_SUITE=bwidget     tag output with suite name
#
# Parse with jq:
#   ... | jq 'select(.status=="fail")'
#   ... | jq 'select(.summary)'
#   ... | jq 'select(.suite=="bwidget")'
#   ... | jq -s '[.[] | select(.summary)] | {tests: map(.tests)|add, failures: map(.failures)|add}'

module Minitest
  class LlmReporter < AbstractReporter
    def initialize(io = $stdout, backtrace_limit: 3, suite: nil)
      super()
      @io = io
      @backtrace_limit = backtrace_limit
      @suite = suite
      @results = []
      @test_count = 0
      @assertion_count = 0
      @skip_count = 0
    end

    def start
      @start_time = Minitest.clock_time
    end

    def record(result)
      @test_count += 1
      @assertion_count += result.assertions

      if result.skipped?
        @skip_count += 1
      elsif !result.passed?
        @results << result
        @io.puts build_result_json(result)
        @io.flush
      end
    end

    def report
      failures = @results.count { |r| r.failure.is_a?(Assertion) }
      errors = @results.count { |r| r.failure.is_a?(UnexpectedError) }
      elapsed = (Minitest.clock_time - @start_time).round(2)

      data = {
        summary: true,
        tests: @test_count,
        assertions: @assertion_count,
        failures: failures,
        errors: errors,
        skips: @skip_count,
        elapsed: elapsed
      }
      data[:suite] = @suite if @suite

      @io.puts JSON.generate(data)
    end

    def passed?
      @results.empty?
    end

    private

    def build_result_json(result)
      failure = result.failure
      status = failure.is_a?(UnexpectedError) ? "error" : "fail"

      file, line = source_location(result)
      bt = truncate_backtrace(filter_backtrace(failure.backtrace || []))

      data = {
        status: status,
        test: "#{result.class}##{result.name}",
        file: file,
        line: line,
        message: failure.message.strip,
        backtrace: bt
      }
      data[:suite] = @suite if @suite

      JSON.generate(data)
    end

    def source_location(result)
      loc = result.method(result.name).source_location
      [loc[0], loc[1]]
    rescue
      if result.location =~ /\[(.+):(\d+)\]/
        [$1, $2.to_i]
      else
        [result.location, nil]
      end
    end

    def filter_backtrace(bt)
      Minitest.backtrace_filter.filter(bt)
    end

    def truncate_backtrace(bt)
      return bt if @backtrace_limit == 0
      bt.first(@backtrace_limit)
    end
  end

  extensions << "llm_reporter" unless extensions.include?("llm_reporter")

  def self.plugin_llm_reporter_options(opts, options)
    opts.on("--llm-backtrace N", Integer,
            "Max backtrace lines per failure (default: 3, 0=all)") do |n|
      options[:llm_backtrace] = n
    end

    opts.on("--llm-suite NAME", String,
            "Tag JSONL output with suite name") do |name|
      options[:llm_suite] = name
    end
  end

  def self.plugin_llm_reporter_init(options)
    return if ENV["MINITEST_REPORTER"] == "default" || options[:verbose]

    backtrace = options[:llm_backtrace] ||
                Integer(ENV.fetch("MINITEST_LLM_BACKTRACE", "3"))
    suite = options[:llm_suite] || ENV["MINITEST_LLM_SUITE"]

    self.reporter.reporters.clear
    self.reporter.reporters << LlmReporter.new(
      options[:io] || $stdout,
      backtrace_limit: backtrace,
      suite: suite
    )
  end
end
