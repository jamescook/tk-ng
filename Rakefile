require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

# Documentation tasks - all doc gems are in docs_site/Gemfile
namespace :docs do
  desc "Install docs dependencies (docs_site/Gemfile)"
  task :setup do
    Dir.chdir('docs_site') do
      Bundler.with_unbundled_env { sh 'bundle install' }
    end
  end

  task :yard_clean do
    FileUtils.rm_rf('doc')
    FileUtils.rm_rf('docs_site/_api')
    FileUtils.rm_rf('docs_site/_site')
    FileUtils.rm_rf('docs_site/.jekyll-cache')
    FileUtils.rm_f('docs_site/assets/js/search-data.json')
  end

  desc "Generate YARD JSON (uses docs_site/Gemfile)"
  task yard_json: :yard_clean do
    # Run yard from docs_site bundle context, but in root dir to access lib/
    Bundler.with_unbundled_env do
      sh 'BUNDLE_GEMFILE=docs_site/Gemfile bundle exec yard doc'
    end
  end

  desc "Generate API docs (YARD JSON -> HTML)"
  task yard: :yard_json do
    Bundler.with_unbundled_env do
      sh 'BUNDLE_GEMFILE=docs_site/Gemfile bundle exec ruby docs_site/build_api_docs.rb'
    end
  end

  desc "Generate full docs site (YARD + Jekyll)"
  task generate: :yard do
    Dir.chdir('docs_site') do
      Bundler.with_unbundled_env { sh 'bundle exec jekyll build' }
    end
    puts "Docs generated in docs_site/_site/"
  end

  desc "Serve docs locally"
  task serve: :yard do
    Dir.chdir('docs_site') do
      Bundler.with_unbundled_env { sh 'bundle exec jekyll serve' }
    end
  end
end

# Aliases for convenience
task doc: 'docs:yard'
task yard: 'docs:yard'

# Compiling on macOS with Homebrew:
#
# Tcl/Tk 9.0:
#   rake clean && rake compile -- --with-tcltkversion=9.0 \
#     --with-tcl-lib=$(brew --prefix tcl-tk)/lib \
#     --with-tcl-include=$(brew --prefix tcl-tk)/include/tcl-tk \
#     --with-tk-lib=$(brew --prefix tcl-tk)/lib \
#     --with-tk-include=$(brew --prefix tcl-tk)/include/tcl-tk \
#     --without-X11
#
# Tcl/Tk 8.6:
#   rake clean && rake compile -- --with-tcltkversion=8.6 \
#     --with-tcl-lib=$(brew --prefix tcl-tk@8)/lib \
#     --with-tcl-include=$(brew --prefix tcl-tk@8)/include \
#     --with-tk-lib=$(brew --prefix tcl-tk@8)/lib \
#     --with-tk-include=$(brew --prefix tcl-tk@8)/include \
#     --without-X11

# Clean up extconf cached config files
CLEAN.include('ext/tk/config_list')
CLOBBER.include('tmp', 'lib/*.bundle', 'lib/*.so', 'ext/**/*.o', 'ext/**/*.bundle', 'ext/**/*.bundle.dSYM')

# Clean coverage artifacts before test runs to prevent accumulation
CLEAN.include('coverage/.resultset.json', 'coverage/results')

# Conditionally load rake-compiler to make CI doc build dependency
# easier
if Gem::Specification.find_all_by_name('rake-compiler').any?
  require 'rake/extensiontask'
  Rake::ExtensionTask.new do |ext|
    ext.name = 'tcltklib'
    ext.ext_dir = 'ext/tk'
    ext.lib_dir = 'lib'
  end
end

# NOTE: tkutil C extension eliminated - now pure Ruby in lib/tk/util.rb

desc "Clear stale coverage artifacts"
task :clean_coverage do
  require 'fileutils'
  FileUtils.rm_f('coverage/.resultset.json')
  FileUtils.rm_rf('coverage/results')
  FileUtils.mkdir_p('coverage/results')
end

namespace :coverage do
  desc "Collate coverage results from multiple test runs into a single report"
  task :collate do
    require 'simplecov'
    require 'simplecov_json_formatter'
    require_relative 'test/simplecov_config'

    # Find all result files from named test runs
    result_files = Dir['coverage/results/*/.resultset.json']
    if result_files.empty?
      puts "No coverage results found in coverage/results/"
      next
    end

    puts "Collating coverage from: #{result_files.map { |f| File.dirname(f).split('/').last }.join(', ')}"

    SimpleCov.collate(result_files) do
      coverage_dir 'coverage'
      formatter SimpleCov::Formatter::MultiFormatter.new([
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::JSONFormatter
      ])
      SimpleCovConfig.apply_filters(self)
      SimpleCovConfig.apply_groups(self)
    end

    puts "Coverage report generated: coverage/index.html, coverage/coverage.json"
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task test: [:compile, :clean_coverage]

namespace :test do
  Rake::TestTask.new(:widget) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/widget/test_*.rb']
    t.verbose = true
  end

  task widget: [:compile, :clean_coverage]

  Rake::TestTask.new(:tkimg) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/tkextlib/tkimg/test_*.rb']
    t.verbose = true
  end

  task tkimg: :compile

  Rake::TestTask.new(:tile) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/tkextlib/tile/test_*.rb']
    t.verbose = true
  end

  task tile: :compile

  desc "Run all tests (main, bwidget, tkdnd)"
  task all: ['test', 'bwidget:test', 'tkdnd:test']
end

def detect_platform
  case RUBY_PLATFORM
  when /darwin/ then 'darwin'
  when /linux/ then 'linux'
  when /mingw|mswin/ then 'windows'
  else 'unknown'
  end
end

namespace :screenshots do
  desc "Generate screenshots (without comparison)"
  task generate: :compile do
    $LOAD_PATH.unshift(File.expand_path('lib', __dir__))
    require 'tk'
    platform = detect_platform
    tcl_version = "tcl#{Tk::TCL_VERSION}"
    output_dir = "screenshots/unverified/#{platform}/#{tcl_version}"
    ruby "-I", "lib", "test/visual_regression/widget_showcase.rb", output_dir
  end

  # Bless all tcl versions for a given platform
  def bless_platform(platform)
    require 'fileutils'
    unverified_base = "screenshots/unverified/#{platform}"
    unless Dir.exist?(unverified_base)
      puts "No unverified screenshots for #{platform}"
      return
    end

    total = 0
    Dir.glob("#{unverified_base}/tcl*").each do |tcl_dir|
      tcl_version = File.basename(tcl_dir)
      src = tcl_dir
      dst = "screenshots/blessed/#{platform}/#{tcl_version}"
      FileUtils.mkdir_p(dst)
      Dir.glob("#{src}/*.png").each do |f|
        FileUtils.cp(f, dst)
        puts "Blessed: #{platform}/#{tcl_version}/#{File.basename(f)}"
        total += 1
      end
    end
    puts "\nBlessed #{total} screenshots for #{platform}"
  end

  desc "Bless all unverified screenshots (all platforms)"
  task :bless do
    %w[darwin linux windows].each do |platform|
      bless_platform(platform)
    end
  end

  namespace :bless do
    desc "Bless Linux screenshots (from Docker)"
    task :linux do
      bless_platform('linux')
    end

    desc "Bless Darwin screenshots"
    task :darwin do
      bless_platform('darwin')
    end

    desc "Bless Windows screenshots"
    task :windows do
      bless_platform('windows')
    end
  end
end

task :default => :compile

# trofs - Tcl read-only filesystem extension
# This is a Tcl extension (not Ruby), built using standard TEA (Tcl Extension Architecture)
namespace :trofs do
  TROFS_DIR = 'ext/trofs'

  desc "Build trofs Tcl extension"
  task :compile do
    Dir.chdir(TROFS_DIR) do
      unless File.exist?('Makefile')
        if Gem.win_platform?
          # Find tclConfig.sh in MSYS2 ucrt64
          tcl_lib = File.join(RbConfig::CONFIG['prefix'], 'msys64', 'ucrt64', 'lib')
          sh "bash ./configure --with-tcl=#{tcl_lib}"
        else
          sh './configure'
        end
      end
      sh 'make binaries'
    end
  end

  desc "Clean trofs build artifacts (use distclean for full clean)"
  task :clean do
    Dir.chdir(TROFS_DIR) do
      sh 'make clean' if File.exist?('Makefile')
    end
  end

  desc "Full clean including configure-generated files"
  task :distclean do
    require 'fileutils'
    Dir.chdir(TROFS_DIR) do
      sh 'make distclean' if File.exist?('Makefile')
      FileUtils.rm_rf('autom4te.cache')
    end
  end

  desc "Run all trofs tests (Tcl and Ruby)"
  task test: ['trofs:test:tcl', 'trofs:test:ruby']

  namespace :test do
    desc "Run trofs Tcl tests"
    task tcl: :compile do
      trofs_dir = File.expand_path(TROFS_DIR)
      test_dir = File.join(TROFS_DIR, 'tests')

      tcl_tests = Dir.glob("#{test_dir}/*.tcl")
      if tcl_tests.any?
        tcl_tests.each do |test_file|
          sh "TCLLIBPATH='#{trofs_dir}' TROFS_LIBRARY='#{trofs_dir}/library' tclsh #{test_file}"
        end
      else
        puts "No Tcl tests found in #{test_dir}"
      end
    end

    desc "Run trofs Ruby integration tests (requires main tk extension compiled)"
    task ruby: ['trofs:compile', 'compile'] do
      trofs_dir = File.expand_path(TROFS_DIR)
      test_dir = File.join(TROFS_DIR, 'tests')

      ruby_tests = Dir.glob("#{test_dir}/*.rb")
      if ruby_tests.any?
        ENV['TROFS_LIBRARY'] = File.join(trofs_dir, 'library')
        ruby_tests.each do |test_file|
          sh "ruby -I#{trofs_dir} -Ilib #{test_file}"
        end
      else
        puts "No Ruby tests found in #{test_dir}"
      end
    end
  end
end

# tkdnd - Tk drag-and-drop extension
# Unlike trofs, tkdnd is actively maintained and supports Tcl 8.6/9.0 out of the box.
# We don't vendor it - instead provide tasks to install from upstream prebuilt releases.
# See: https://github.com/petasis/tkdnd
namespace :tkdnd do
  TKDND_REPO = 'petasis/tkdnd'
  TKDND_BUILD_DIR = 'tmp/tkdnd'

  def tkdnd_installed?
    result = `echo 'if {[catch {package require tkdnd}]} {exit 1}; exit 0' | tclsh`
    $?.success?
  end

  def tkdnd_version
    `echo 'puts [package require tkdnd]; exit 0' | tclsh 2>/dev/null`.chomp
  end

  def latest_tkdnd_release
    require 'open-uri'
    require 'json'
    api_url = "https://api.github.com/repos/#{TKDND_REPO}/releases/latest"
    JSON.parse(URI.open(api_url).read)
  end

  def detect_tcl_version
    tclsh = ENV.fetch('TCLSH', 'tclsh')
    version = `#{tclsh} <<< 'puts [info patchlevel]' 2>/dev/null`.chomp rescue ''
    return nil if version.empty?
    version.split('.')[0..1].join('.')
  end

  def detect_tcl_lib_path
    tclsh = ENV.fetch('TCLSH', 'tclsh')
    # Get the first writable path from auto_path, or fall back to tcl_pkgPath
    paths = `#{tclsh} <<< 'puts $tcl_pkgPath' 2>/dev/null`.chomp.split rescue []
    paths.first
  end

  # Find prebuilt binary asset matching platform/arch/tcl version
  def find_prebuilt_asset(release, tcl_version)
    assets = release['assets'] || []

    platform = case RUBY_PLATFORM
               when /darwin/ then 'macOS'
               when /linux/ then 'linux'
               when /mingw|mswin|cygwin/ then 'windows'
               end

    arch = case RUBY_PLATFORM
           when /arm64|aarch64/ then 'arm64'
           when /x86_64|x64/ then 'x86_64'
           when /i[3-6]86/ then 'i686'
           end

    tcl_pattern = "tcl#{tcl_version}"

    assets.each do |asset|
      name = asset['name']
      next unless name.include?(platform) && name.include?(tcl_pattern)
      return [asset['browser_download_url'], name] if name.include?(arch)
    end
    nil
  end

  desc "Check if tkdnd is installed"
  task :check do
    if tkdnd_installed?
      puts "tkdnd is installed (version #{tkdnd_version})"
    else
      puts "tkdnd is NOT installed"
      puts "Run 'rake tkdnd:install' to download prebuilt binary"
    end
  end

  desc "Download prebuilt tkdnd from GitHub releases"
  task :install do
    if tkdnd_installed?
      puts "tkdnd #{tkdnd_version} is already installed"
      puts "Use 'rake tkdnd:install:force' to reinstall"
      next
    end

    Rake::Task['tkdnd:install:force'].invoke
  end

  namespace :install do
    desc "Force download tkdnd (even if installed)"
    task :force do
      require 'fileutils'
      require 'open-uri'

      tcl_version = detect_tcl_version
      unless tcl_version
        puts "Could not detect Tcl version. Set TCLSH env var to your tclsh."
        exit 1
      end

      tcl_lib_path = detect_tcl_lib_path
      puts "Detected Tcl #{tcl_version}"
      puts "Tcl library path: #{tcl_lib_path || '(unknown)'}"
      puts "Fetching latest tkdnd release info..."
      release = latest_tkdnd_release
      tag = release['tag_name']
      puts "Latest release: #{tag}"

      asset = find_prebuilt_asset(release, tcl_version)
      unless asset
        puts "\nNo prebuilt binary available for:"
        puts "  Platform: #{RUBY_PLATFORM}"
        puts "  Tcl: #{tcl_version}"
        puts "\nAvailable prebuilt binaries:"
        release['assets'].each { |a| puts "  - #{a['name']}" }
        puts "\nYou may need to build from source. See:"
        puts "  https://github.com/petasis/tkdnd"
        exit 1
      end

      url, name = asset
      puts "Downloading #{name}..."

      FileUtils.rm_rf(TKDND_BUILD_DIR)
      FileUtils.mkdir_p(TKDND_BUILD_DIR)

      archive_path = "#{TKDND_BUILD_DIR}/#{name}"
      URI.open(url) do |remote|
        File.open(archive_path, 'wb') { |f| f.write(remote.read) }
      end

      puts "Extracting..."
      Dir.chdir(TKDND_BUILD_DIR) do
        if name.end_with?('.zip')
          sh "unzip -q #{name}"
        else
          sh "tar xzf #{name}"
        end
      end

      # Find extracted directory (usually tkdnd2.9.5 or similar)
      pkg_dir = Dir.glob("#{TKDND_BUILD_DIR}/tkdnd*").reject { |f| f == archive_path }.first
      unless pkg_dir
        fail "Could not find extracted tkdnd directory"
      end

      pkg_dir = File.expand_path(pkg_dir)
      pkg_name = File.basename(pkg_dir)

      # Try to install to Tcl library path
      if tcl_lib_path
        dest = File.join(tcl_lib_path, pkg_name)
        if File.writable?(tcl_lib_path)
          puts "Installing to #{dest}..."
          FileUtils.rm_rf(dest)
          FileUtils.cp_r(pkg_dir, dest)
          puts "Done! tkdnd #{tag} installed successfully."
        else
          puts "\nExtracted to: #{pkg_dir}"
          puts "\nTo install (requires write access to #{tcl_lib_path}):"
          puts "  sudo cp -r #{pkg_dir} #{tcl_lib_path}/"
        end
      else
        puts "\nExtracted to: #{pkg_dir}"
        puts "\nCould not detect Tcl library path."
        puts "Copy #{pkg_dir} to your Tcl library path manually."
      end
    end
  end

  desc "Clean tkdnd build directory"
  task :clean do
    require 'fileutils'
    FileUtils.rm_rf(TKDND_BUILD_DIR)
    puts "Cleaned #{TKDND_BUILD_DIR}"
  end

  desc "Run tkdnd tests"
  task test: :compile do
    unless tkdnd_installed?
      puts "tkdnd is not installed. Run 'rake tkdnd:install' first."
      exit 1
    end

    test_dir = 'lib/tkextlib/tkDND/test'
    test_files = Dir.glob("#{test_dir}/test_*.rb")
    if test_files.any?
      test_files.each do |f|
        sh "ruby -Ilib -Itest #{f}"
      end
    else
      puts "No tkdnd tests found in #{test_dir}"
    end
  end
end

# bwidget - BWidget Tcl extension
# Usually bundled with system Tcl/Tk or available via package manager.
namespace :bwidget do
  def bwidget_installed?
    result = `echo 'if {[catch {package require BWidget}]} {exit 1}; exit 0' | tclsh`
    $?.success?
  end

  def bwidget_version
    `echo 'puts [package require BWidget]; exit 0' | tclsh 2>/dev/null`.chomp
  end

  desc "Check if bwidget is installed"
  task :check do
    if bwidget_installed?
      puts "bwidget is installed (version #{bwidget_version})"
    else
      puts "bwidget is NOT installed"
      puts "Install via package manager (e.g., 'brew install bwidget' or 'apt install bwidget')"
    end
  end

  Rake::TestTask.new(:test) do |t|
    t.libs << 'test'
    t.test_files = FileList['lib/tkextlib/bwidget/test/test_*.rb']
    t.verbose = true
  end

  task test: :compile do
    unless bwidget_installed?
      puts "bwidget is NOT installed"
      puts "Install via package manager (e.g., 'brew install bwidget' or 'apt install bwidget')"
      exit 1
    end
  end
end

# Convenience alias
namespace :compile do
  desc "Build trofs Tcl extension"
  task trofs: 'trofs:compile'
end

# Docker tasks for local testing and CI
namespace :docker do
  DOCKERFILE = 'Dockerfile.ci-test'
  DOCKER_LABEL = 'project=ruby-tk'

  def docker_image_name(tcl_version, ruby_version = nil)
    ruby_version ||= ruby_version_from_env
    base = tcl_version == '8.6' ? 'tk-ci-test-8' : 'tk-ci-test-9'
    # Include Ruby version suffix for non-default versions
    ruby_version == '3.4' ? base : "#{base}-ruby#{ruby_version}"
  end

  def tcl_version_from_env
    version = ENV.fetch('TCL_VERSION', '9.0')
    unless ['8.6', '9.0'].include?(version)
      abort "Invalid TCL_VERSION='#{version}'. Must be '8.6' or '9.0'."
    end
    version
  end

  def ruby_version_from_env
    ENV.fetch('RUBY_VERSION', '3.4')
  end

  desc "Build Docker image (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
  task :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    verbose = ENV['VERBOSE'] || ENV['V']
    quiet = !verbose
    if quiet
      puts "Building Docker image for Ruby #{ruby_version}, Tcl #{tcl_version}... (VERBOSE=1 for details)"
    else
      puts "Building Docker image for Ruby #{ruby_version}, Tcl #{tcl_version}..."
    end
    cmd = "docker build -f #{DOCKERFILE}"
    cmd += " -q" if quiet
    cmd += " --label #{DOCKER_LABEL}"
    cmd += " --build-arg RUBY_VERSION=#{ruby_version}"
    cmd += " --build-arg TCL_VERSION=#{tcl_version}"
    cmd += " -t #{image_name} ."

    sh cmd, verbose: !quiet
  end

  desc "Run tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|..., TEST=path/to/test.rb)"
  task test: :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    # Ensure output directories exist on host
    require 'fileutils'
    FileUtils.mkdir_p('screenshots')
    FileUtils.mkdir_p('coverage')

    puts "Running tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
    cmd = "docker run --rm --init"
    cmd += " -v #{Dir.pwd}/screenshots:/app/screenshots"
    cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
    cmd += " -e TCL_VERSION=#{tcl_version}"
    # Pass TEST env var (quoted to support multiple files)
    cmd += " -e TEST='#{ENV['TEST']}'" if ENV['TEST']
    # Pass TESTOPTS for minitest options (e.g., -v for verbose)
    cmd += " -e TESTOPTS=#{ENV['TESTOPTS']}" if ENV['TESTOPTS']
    if ENV['COVERAGE'] == '1'
      cmd += " -e COVERAGE=1"
      cmd += " -e COVERAGE_NAME=#{ENV['COVERAGE_NAME'] || 'main'}"
    end
    cmd += " #{image_name}"

    sh cmd
  end

  namespace :test do
    desc "Run widget tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
    task widget: 'docker:build' do
      tcl_version = tcl_version_from_env
      ruby_version = ruby_version_from_env
      image_name = docker_image_name(tcl_version, ruby_version)

      puts "Running widget tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
      cmd = "docker run --rm --init"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      cmd += " #{image_name}"
      cmd += " xvfb-run -a bundle exec rake test:widget"

      sh cmd
    end

    desc "Run bwidget tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
    task bwidget: 'docker:build' do
      tcl_version = tcl_version_from_env
      ruby_version = ruby_version_from_env
      image_name = docker_image_name(tcl_version, ruby_version)

      require 'fileutils'
      FileUtils.mkdir_p('coverage')

      puts "Running bwidget tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
      cmd = "docker run --rm --init"
      cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      if ENV['COVERAGE'] == '1'
        cmd += " -e COVERAGE=1"
        cmd += " -e COVERAGE_NAME=bwidget"
      end
      cmd += " #{image_name}"
      cmd += " xvfb-run -a bundle exec rake bwidget:test"

      sh cmd
    end

    desc "Run tkdnd tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
    task tkdnd: 'docker:build' do
      tcl_version = tcl_version_from_env
      ruby_version = ruby_version_from_env
      image_name = docker_image_name(tcl_version, ruby_version)

      require 'fileutils'
      FileUtils.mkdir_p('coverage')

      puts "Running tkdnd tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
      cmd = "docker run --rm --init"
      cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      if ENV['COVERAGE'] == '1'
        cmd += " -e COVERAGE=1"
        cmd += " -e COVERAGE_NAME=tkdnd"
      end
      cmd += " #{image_name}"
      cmd += " xvfb-run -a bundle exec rake tkdnd:test"

      sh cmd
    end

    desc "Run tkimg tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
    task tkimg: 'docker:build' do
      tcl_version = tcl_version_from_env
      ruby_version = ruby_version_from_env
      image_name = docker_image_name(tcl_version, ruby_version)

      require 'fileutils'
      FileUtils.mkdir_p('coverage')

      puts "Running tkimg tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
      cmd = "docker run --rm --init"
      cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      if ENV['COVERAGE'] == '1'
        cmd += " -e COVERAGE=1"
        cmd += " -e COVERAGE_NAME=tkimg"
      end
      cmd += " #{image_name}"
      cmd += " xvfb-run -a bundle exec rake test:tkimg"

      sh cmd
    end

    desc "Run tile tests in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|..., TEST=path/to/test.rb)"
    task tile: 'docker:build' do
      tcl_version = tcl_version_from_env
      ruby_version = ruby_version_from_env
      image_name = docker_image_name(tcl_version, ruby_version)

      require 'fileutils'
      FileUtils.mkdir_p('coverage')

      puts "Running tile tests in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
      cmd = "docker run --rm --init"
      cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      cmd += " -e TEST=#{ENV['TEST']}" if ENV['TEST']
      cmd += " -e TESTOPTS=#{ENV['TESTOPTS']}" if ENV['TESTOPTS']
      if ENV['COVERAGE'] == '1'
        cmd += " -e COVERAGE=1"
        cmd += " -e COVERAGE_NAME=tile"
      end
      cmd += " #{image_name}"
      cmd += " xvfb-run -a bundle exec rake test:tile"

      sh cmd
    end

    desc "Run background_work tests on Ruby 4.x (tests Ruby 4.x Ractor code paths)"
    task ruby4x: 'docker:build' do
      tcl_version = tcl_version_from_env

      # Force Ruby 4.0 for this task
      ruby_version = '4.0'
      image_name = docker_image_name(tcl_version, ruby_version)

      require 'fileutils'
      FileUtils.mkdir_p('coverage')

      puts "Running Ruby 4.x Ractor tests in Docker..."
      cmd = "docker run --rm --init"
      cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
      cmd += " -e TCL_VERSION=#{tcl_version}"
      if ENV['COVERAGE'] == '1'
        cmd += " -e COVERAGE=1"
        cmd += " -e COVERAGE_NAME=ruby4x"
      end
      cmd += " #{image_name}"
      # Run tests directly (don't use default CMD which runs `rake test` and triggers clean_coverage)
      cmd += " xvfb-run -a bundle exec ruby -Itest -Ilib test/test_background_work.rb"

      sh cmd
    end

    desc "Run all tests in Docker with combined coverage (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
    task all: :build do
      # Clean coverage results first
      require 'fileutils'
      FileUtils.rm_rf('coverage')
      FileUtils.mkdir_p('coverage/results')

      # Run each test suite
      Rake::Task['docker:test'].invoke
      Rake::Task['docker:test:bwidget'].invoke
      Rake::Task['docker:test:tkdnd'].invoke
      Rake::Task['docker:test:tkimg'].invoke
      Rake::Task['docker:test:tile'].invoke
      Rake::Task['docker:test:ruby4x'].invoke

      # Collate coverage inside Docker (paths match)
      if ENV['COVERAGE'] == '1'
        tcl_version = tcl_version_from_env
        ruby_version = ruby_version_from_env
        image_name = docker_image_name(tcl_version, ruby_version)

        puts "Collating coverage results..."
        cmd = "docker run --rm --init"
        cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
        cmd += " #{image_name}"
        cmd += " bundle exec rake coverage:collate"

        sh cmd
      end
    end
  end

  desc "Run interactive shell in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
  task shell: :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    cmd = "docker run --rm --init -it"
    cmd += " -v #{Dir.pwd}/screenshots:/app/screenshots"
    cmd += " -v #{Dir.pwd}/coverage:/app/coverage"
    cmd += " -e TCL_VERSION=#{tcl_version}"
    cmd += " #{image_name} bash"

    sh cmd
  end

  desc "Generate options in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
  task generate_options: :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    puts "Generating options in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
    cmd = "docker run --rm --init"
    cmd += " -v #{Dir.pwd}/lib/tk/generated:/app/lib/tk/generated"
    cmd += " -e TCL_VERSION=#{tcl_version}"
    cmd += " #{image_name} xvfb-run -a bundle exec rake tk:generate_options"

    sh cmd
  end

  desc "Generate item options in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
  task generate_item_options: :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    puts "Generating item options in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
    cmd = "docker run --rm --init"
    cmd += " -v #{Dir.pwd}/lib/tk/generated:/app/lib/tk/generated"
    cmd += " -e TCL_VERSION=#{tcl_version}"
    cmd += " #{image_name} xvfb-run -a bundle exec rake tk:generate_item_options"

    sh cmd
  end

  desc "Generate Ttk options in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|...)"
  task generate_ttk_options: :build do
    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    puts "Generating Ttk options in Docker (Ruby #{ruby_version}, Tcl #{tcl_version})..."
    cmd = "docker run --rm --init"
    cmd += " -v #{Dir.pwd}/lib/tk/generated:/app/lib/tk/generated"
    cmd += " -e TCL_VERSION=#{tcl_version}"
    cmd += " #{image_name} xvfb-run -a bundle exec rake tk:generate_ttk_options"

    sh cmd
  end

  desc "Remove dangling Docker images from ruby-tk builds"
  task :prune do
    sh "docker image prune -f --filter label=#{DOCKER_LABEL}"
  end

  # Auto-prune after test tasks
  ['docker:test', 'docker:test:widget'].each do |t|
    Rake::Task[t].enhance { Rake::Task['docker:prune'].invoke }
  end

  # Scan sample files for # tk-record magic comment
  # Format: # tk-record: title=My Demo, codec=vp9
  # Window geometry is queried dynamically from the demo via TkDemo.signal_recording_ready
  def find_recordable_samples
    Dir['sample/**/*.rb'].filter_map do |path|
      first_lines = File.read(path, 500) # Read enough to find the comment
      match = first_lines.match(/^#\s*tk-record(?::\s*(.+))?$/)
      next unless match

      options = {}
      if match[1]
        match[1].split(',').each do |pair|
          key, value = pair.strip.split('=', 2)
          options[key.strip] = value&.strip if key
        end
      end
      options['sample'] = path
      options
    end
  end

  desc "Record demos in Docker (TCL_VERSION=9.0|8.6, RUBY_VERSION=3.4|4.0|..., DEMO=sample/foo.rb)"
  task record_demos: :build do
    require 'fileutils'
    FileUtils.mkdir_p('recordings')

    tcl_version = tcl_version_from_env
    ruby_version = ruby_version_from_env
    image_name = docker_image_name(tcl_version, ruby_version)

    demos = if ENV['DEMO']
              # Single demo from env var
              find_recordable_samples.select { |d| d['sample'] == ENV['DEMO'] }
            else
              find_recordable_samples
            end

    if demos.empty?
      puts "No recordable samples found. Add '# tk-record' comment to samples."
      next
    end

    demos.each do |demo|
      sample = demo['sample']
      codec = ENV['CODEC'] || demo['codec'] || 'x264'
      name = demo['name']  # Optional custom output name

      puts
      puts "Recording #{sample} (#{codec})..."
      env = "CODEC=#{codec}"
      env += " NAME=#{name}" if name
      sh "#{env} ./scripts/docker-record.sh #{sample}"
    end

    puts "Done! Recordings in: recordings/"
  end
end

namespace :windows do
  desc "Record demos on Windows using gdigrab. DEMO=sample/foo.rb, CODEC=x264|vp9"
  task :record do
    unless Gem.win_platform?
      puts "This task is Windows-only. For Linux/Docker, use:"
      puts "  ./scripts/record-sample.sh sample/foo.rb"
      puts "  rake docker:record_demos"
      exit 1
    end

    require 'fileutils'
    require 'socket'
    require 'timeout'
    require 'open3'
    FileUtils.mkdir_p('recordings')

    demos = if ENV['DEMO']
              find_recordable_samples.select { |d| d['sample'] == ENV['DEMO'] }
            else
              find_recordable_samples
            end

    if demos.empty?
      puts "No recordable samples found. Add '# tk-record: title=...' comment to samples."
      next
    end

    demos.each do |demo|
      sample = demo['sample']
      codec = ENV['CODEC'] || demo['codec'] || 'x264'
      name = demo['name']
      window_title = demo['title']

      unless window_title
        puts "SKIP #{sample}: No title= in tk-record comment (required for gdigrab)"
        next
      end

      puts
      puts "Recording #{sample} (#{codec})..."

      # Build output filename
      basename = name || File.basename(sample, '.rb')
      ext = (codec == 'vp9') ? 'webm' : 'mp4'
      output = "recordings/#{basename}.#{ext}"
      thumbnail = "recordings/#{basename}.png"

      # Codec options
      codec_opts = case codec
                   when 'vp9' then '-c:v libvpx-vp9 -crf 30 -b:v 0'
                   when 'x264', 'h264' then '-c:v libx264 -preset fast -crf 23'
                   else raise "Unknown codec: #{codec}"
                   end

      # Create socket server to receive signals from demo
      stop_server = TCPServer.new('127.0.0.1', 0)
      stop_port = stop_server.addr[1]

      # Start sample in background with stop port
      sample_pid = spawn(
        { 'TK_RECORD' => '1', 'TK_STOP_PORT' => stop_port.to_s, 'TK_THUMBNAIL_PATH' => thumbnail },
        RbConfig.ruby, '-Ilib', '-rtk', sample
      )

      # Wait for "ready" signal with geometry (e.g., "R:640x480")
      ready_socket = stop_server.accept rescue nil
      ready_data = ready_socket&.read(20)
      ready_socket&.close

      width, height = nil, nil
      if ready_data =~ /R:(\d+)x(\d+)/
        width, height = $1.to_i, $2.to_i
        puts "  Window geometry: #{width}x#{height}"
      end

      # gdigrab captures at screen DPI, but Tk renders at logical size
      # Use crop filter to extract just the window content from the top-left
      crop_filter = (width && height && width > 0) ? ['-vf', "crop=#{width}:#{height}:0:0"] : []

      ffmpeg_cmd = [
        'ffmpeg', '-y',
        '-f', 'gdigrab',
        '-framerate', '30',
        '-i', "title=#{window_title}",
        *crop_filter,
        *codec_opts.split,
        output
      ]

      ffmpeg_stdin, ffmpeg_stdout, ffmpeg_stderr, ffmpeg_thread = Open3.popen3(*ffmpeg_cmd)

      # Wait for stop signal (with timeout) or sample exit
      demo_socket = nil
      stop_thread = Thread.new { demo_socket = stop_server.accept rescue nil }
      begin
        Timeout.timeout(120) do
          loop do
            break if stop_thread.join(0.5)  # Stop signal received
            break unless Process.waitpid(sample_pid, Process::WNOHANG).nil?  # Process exited
          end
        end
      rescue Timeout::Error
        puts "  Recording timeout (120s)"
      ensure
        stop_server.close rescue nil
      end

      # Gracefully stop ffmpeg by sending 'q' to stdin
      sleep 0.5
      begin
        ffmpeg_stdin.puts 'q'
      rescue Errno::EPIPE
        # ffmpeg already exited (window closed)
      end
      ffmpeg_stdin.close rescue nil
      ffmpeg_thread.join(10)  # Wait up to 10s for ffmpeg to finalize
      Process.kill('KILL', ffmpeg_thread.pid) rescue nil if ffmpeg_thread.alive?

      # Signal demo it can exit now (send byte and close)
      if demo_socket
        demo_socket.write('x') rescue nil
        demo_socket.close rescue nil
      end

      # Wait for sample to exit
      Process.waitpid(sample_pid, 0) rescue nil

      puts "Done: #{output}"
    end

    puts
    puts "Recordings saved to: recordings/"
  end
end

# Helper to find recordable samples (also used by docker:record_demos)
# Window geometry is queried dynamically from demo via TkDemo.signal_recording_ready
def find_recordable_samples
  Dir['sample/**/*.rb'].filter_map do |path|
    first_lines = File.read(path, 500)
    match = first_lines.match(/^#\s*tk-record(?::\s*(.+))?$/)
    next unless match

    options = {}
    if match[1]
      match[1].split(',').each do |pair|
        key, value = pair.strip.split('=', 2)
        options[key.strip] = value&.strip if key
      end
    end
    options['sample'] = path
    options
  end
end

# Option generation from Tk introspection
namespace :tk do
  GENERATED_DIR = 'lib/tk/generated'

  # List of standard Tk widgets to introspect
  WIDGETS = {
    'Button' => 'button',
    'Canvas' => 'canvas',
    'Checkbutton' => 'checkbutton',
    'Entry' => 'entry',
    'Frame' => 'frame',
    'Label' => 'label',
    'Labelframe' => 'labelframe',
    'Listbox' => 'listbox',
    'Menu' => 'menu',
    'Menubutton' => 'menubutton',
    'Message' => 'message',
    'Panedwindow' => 'panedwindow',
    'Radiobutton' => 'radiobutton',
    'Scale' => 'scale',
    'Scrollbar' => 'scrollbar',
    'Spinbox' => 'spinbox',
    'Text' => 'text',
    'Toplevel' => 'toplevel',
  }.freeze

  # List of Ttk (themed) widgets to introspect
  TTK_WIDGETS = {
    'TtkButton' => 'ttk::button',
    'TtkCheckbutton' => 'ttk::checkbutton',
    'TtkCombobox' => 'ttk::combobox',
    'TtkEntry' => 'ttk::entry',
    'TtkFrame' => 'ttk::frame',
    'TtkLabel' => 'ttk::label',
    'TtkLabelframe' => 'ttk::labelframe',
    'TtkMenubutton' => 'ttk::menubutton',
    'TtkNotebook' => 'ttk::notebook',
    'TtkPanedwindow' => 'ttk::panedwindow',
    'TtkProgressbar' => 'ttk::progressbar',
    'TtkRadiobutton' => 'ttk::radiobutton',
    'TtkScale' => 'ttk::scale',
    'TtkScrollbar' => 'ttk::scrollbar',
    'TtkSeparator' => 'ttk::separator',
    'TtkSizegrip' => 'ttk::sizegrip',
    'TtkSpinbox' => 'ttk::spinbox',
    'TtkTreeview' => 'ttk::treeview',
  }.freeze

  desc "Generate option DSL from Tk introspection (requires display)"
  task generate_options: :compile do
    require_relative 'lib/tk/option_generator'

    $LOAD_PATH.unshift(File.expand_path('lib', __dir__))
    require 'tk'

    tcl_version = Tk::TCL_VERSION
    version_dir = "#{GENERATED_DIR}/#{tcl_version.gsub('.', '_')}"
    generator = Tk::OptionGenerator.new(tcl_version: tcl_version)

    puts "Introspecting Tk widgets for Tcl #{tcl_version}..."
    FileUtils.mkdir_p(version_dir)

    widget_files = []
    WIDGETS.each do |ruby_name, tk_cmd|
      print "  #{ruby_name}..."
      begin
        entries = generator.introspect_widget(tk_cmd)
        filename = ruby_name.downcase
        filepath = "#{version_dir}/#{filename}.rb"
        File.write(filepath, generator.generate_widget_file(ruby_name, entries, widget_cmd: tk_cmd))
        widget_files << filename
        puts " #{entries.size} options -> #{filename}.rb"
      rescue => e
        puts " FAILED: #{e.message}"
      end
    end

    # Generate loader file
    loader_content = <<~RUBY
      # frozen_string_literal: true
      # Auto-generated loader for Tcl/Tk #{tcl_version} widget options
      # DO NOT EDIT - regenerate with: rake tk:generate_options

      #{widget_files.map { |f| "require_relative '#{tcl_version.gsub('.', '_')}/#{f}'" }.join("\n")}
    RUBY
    loader_file = "#{GENERATED_DIR}/options_#{tcl_version.gsub('.', '_')}.rb"
    File.write(loader_file, loader_content)

    puts "\nGenerated #{widget_files.size} widget files in #{version_dir}/"
    puts "Loader: #{loader_file}"
  end

  desc "Generate Ttk option DSL from Tk introspection (called by docker:generate_ttk_options)"
  task generate_ttk_options: :compile do
    require_relative 'lib/tk/option_generator'

    $LOAD_PATH.unshift(File.expand_path('lib', __dir__))
    require 'tk'

    tcl_version = Tk::TCL_VERSION
    version_dir = "#{GENERATED_DIR}/ttk/#{tcl_version.gsub('.', '_')}"
    generator = Tk::OptionGenerator.new(tcl_version: tcl_version)

    puts "Introspecting Ttk widgets for Tcl #{tcl_version}..."
    FileUtils.mkdir_p(version_dir)

    widget_files = []
    TTK_WIDGETS.each do |ruby_name, tk_cmd|
      print "  #{ruby_name}..."
      begin
        entries = generator.introspect_widget(tk_cmd)
        filename = ruby_name.downcase
        filepath = "#{version_dir}/#{filename}.rb"
        File.write(filepath, generator.generate_widget_file(ruby_name, entries, widget_cmd: tk_cmd))
        widget_files << filename
        puts " #{entries.size} options -> #{filename}.rb"
      rescue => e
        puts " FAILED: #{e.message}"
      end
    end

    # Generate loader file
    loader_content = <<~RUBY
      # frozen_string_literal: true
      # Auto-generated loader for Ttk #{tcl_version} widget options
      # DO NOT EDIT - regenerate with: rake docker:generate_ttk_options

      #{widget_files.map { |f| "require_relative 'ttk/#{tcl_version.gsub('.', '_')}/#{f}'" }.join("\n")}
    RUBY
    loader_file = "#{GENERATED_DIR}/ttk_options_#{tcl_version.gsub('.', '_')}.rb"
    File.write(loader_file, loader_content)

    puts "\nGenerated #{widget_files.size} Ttk widget files in #{version_dir}/"
    puts "Loader: #{loader_file}"
  end

  # Map generated widget names to source files and Ruby class names
  # Generated names come from Tcl (lowercase), Ruby classes use CamelCase
  WIDGET_FILES = {
    'Button'      => { file: 'lib/tk/button.rb',      class: 'Tk::Button' },
    'Canvas'      => { file: 'lib/tk/canvas.rb',      class: 'Tk::Canvas' },
    'Checkbutton' => { file: 'lib/tk/checkbutton.rb', class: 'Tk::CheckButton' },
    'Entry'       => { file: 'lib/tk/entry.rb',       class: 'Tk::Entry' },
    'Frame'       => { file: 'lib/tk/frame.rb',       class: 'Tk::Frame' },
    'Label'       => { file: 'lib/tk/label.rb',       class: 'Tk::Label' },
    'Labelframe'  => { file: 'lib/tk/labelframe.rb',  class: 'Tk::LabelFrame' },
    'Listbox'     => { file: 'lib/tk/listbox.rb',     class: 'Tk::Listbox' },
    'Menu'        => { file: 'lib/tk/menu.rb',        class: 'Tk::Menu' },
    'Menubutton'  => { file: 'lib/tk/menu.rb',        class: 'Tk::Menubutton' },
    'Message'     => { file: 'lib/tk/message.rb',     class: 'Tk::Message' },
    'Panedwindow' => { file: 'lib/tk/panedwindow.rb', class: 'Tk::PanedWindow' },
    'Radiobutton' => { file: 'lib/tk/radiobutton.rb', class: 'Tk::RadioButton' },
    'Scale'       => { file: 'lib/tk/scale.rb',       class: 'Tk::Scale' },
    'Scrollbar'   => { file: 'lib/tk/scrollbar.rb',   class: 'Tk::Scrollbar' },
    'Spinbox'     => { file: 'lib/tk/spinbox.rb',     class: 'Tk::Spinbox' },
    'Text'        => { file: 'lib/tk/text.rb',        class: 'Tk::Text' },
    'Toplevel'    => { file: 'lib/tk/toplevel.rb',    class: 'Tk::Toplevel' },
  }.freeze

  desc "Inject option documentation comments into widget source files (requires generate_options first)"
  task inject_option_comments: :generate_options do
    require_relative 'lib/tk/option_generator'
    require_relative 'lib/tk/option_comment_injector'

    tcl_version = Tk::TCL_VERSION
    version_dir = "#{GENERATED_DIR}/#{tcl_version.gsub('.', '_')}"

    puts "Injecting option comments into widget files..."

    WIDGET_FILES.each do |widget_name, info|
      file_path = info[:file]
      class_name = info[:class]
      next unless File.exist?(file_path)

      # Load the generated options for this widget
      generated_file = "#{version_dir}/#{widget_name.downcase}.rb"
      next unless File.exist?(generated_file)

      print "  #{class_name} -> #{file_path}..."

      begin
        # Parse the generated file to get options
        generator = Tk::OptionGenerator.new(tcl_version: tcl_version)
        entries = generator.introspect_widget(WIDGETS[widget_name])

        # Inject comments
        injector = Tk::OptionCommentInjector.new(file_path)
        injector.inject!(class_name, entries)
        puts " done"
      rescue => e
        puts " FAILED: #{e.message}"
      end
    end

    puts "\nDone!"
  end

  desc "Inspect a widget's options and their dbClass (usage: rake tk:inspect[widget_name])"
  task :inspect, [:widget] => :compile do |t, args|
    widget = args[:widget]
    unless widget
      puts "Usage: rake tk:inspect[widget_name]"
      puts "Example: rake tk:inspect[menubutton]"
      exit 1
    end

    require_relative 'lib/tk/type_registry'
    require_relative 'lib/tk/option_generator'

    $LOAD_PATH.unshift(File.expand_path('lib', __dir__))

    gen = Tk::OptionGenerator.new(tcl_version: "9.0")
    entries = gen.introspect_widget(widget)

    puts "Options for '#{widget}':\n\n"
    entries.each do |entry|
      if entry.alias?
        puts "  #{entry.name} -> alias for #{entry.alias_target}"
      else
        puts "  #{entry.name}: dbclass=#{entry.db_class}, type=#{entry.ruby_type}"
      end
    end
  end

  desc "Generate item option DSL from Tk introspection (requires display)"
  task generate_item_options: :compile do
    require_relative 'lib/tk/item_option_generation_service'

    $LOAD_PATH.unshift(File.expand_path('lib', __dir__))
    require 'tk'

    Tk::ItemOptionGenerationService.new(tcl_version: Tk::TCL_VERSION).call
  end

  # Widgets to generate tests for (start with Button only for validation)
  TEST_GEN_WIDGETS = %w[Button Canvas Checkbutton Entry Frame Label Labelframe Listbox Menu Menubutton Message Panedwindow Radiobutton Scale Scrollbar Spinbox Text Toplevel].freeze

  desc "Generate minitest files from option metadata (usage: rake tk:generate_option_tests)"
  task :generate_option_tests do
    require_relative 'lib/tk/option_test_generator'

    tcl_version = ENV.fetch('TCL_VERSION', '9.0')
    version_dir = "lib/tk/generated/#{tcl_version.gsub('.', '_')}"
    output_dir = 'test/generated'

    FileUtils.mkdir_p(output_dir)

    generator = Tk::OptionTestGenerator.new(tcl_version: tcl_version)

    puts "Generating option tests from #{version_dir}..."

    TEST_GEN_WIDGETS.each do |widget_name|
      generated_file = "#{version_dir}/#{widget_name.downcase}.rb"
      unless File.exist?(generated_file)
        puts "  #{widget_name}: SKIP (no generated options file)"
        next
      end

      print "  #{widget_name}..."
      options = generator.parse_generated_file(generated_file)
      test_content = generator.generate_test_file(widget_name, options)

      output_file = "#{output_dir}/test_#{widget_name.downcase}_options.rb"
      File.write(output_file, test_content)
      puts " #{options.size} options -> #{output_file}"
    end

    puts "\nDone! Run with: rake docker:test TEST=test/generated/test_button_options.rb"
  end
end
