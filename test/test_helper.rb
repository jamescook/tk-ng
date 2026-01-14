# frozen_string_literal: true

# Common test helper - loads SimpleCov for coverage, then minitest.
# All test files should require this FIRST.
#
# Set COVERAGE=1 to enable coverage collection.

if ENV['COVERAGE']
  require 'simplecov'

  # Use COVERAGE_NAME to save results to a unique subdirectory
  # This allows multiple test runs (main, bwidget, tkdnd) to be collated later
  coverage_name = ENV['COVERAGE_NAME'] || 'default'
  SimpleCov.coverage_dir "coverage/results/#{coverage_name}"

  # Unique command name for each process (enables subprocess merging)
  SimpleCov.command_name "#{coverage_name}:#{Process.pid}"

  SimpleCov.start do
    add_filter '/test/'
    add_filter '/ext/'
    add_filter '/benchmark/'

    add_group 'Core', 'lib/tk.rb'
    add_group 'Widgets', 'lib/tk'
    add_group 'Extensions', 'lib/tkextlib'
    add_group 'Utilities', ['lib/tkutil.rb', 'lib/tk/util.rb']

    # Track all lib files
    track_files 'lib/**/*.rb'
  end
end

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

# Absolute path to test fixtures directory - works from any test file location
FIXTURES_PATH = File.expand_path('fixtures', __dir__)

require 'minitest/autorun'

# Note: Coverage collation across multiple test suites (main, bwidget, tkdnd)
# is done by `rake coverage:collate` after all test runs complete.
# Each test run saves to coverage/results/<COVERAGE_NAME>/.resultset.json
