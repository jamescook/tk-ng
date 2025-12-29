require "bundler/gem_tasks"
require 'rake/extensiontask'
require 'rake/testtask'

Rake::ExtensionTask.new do |ext|
  ext.name = 'tcltklib'
  ext.ext_dir = 'ext/tk'
  ext.lib_dir = 'lib'
end

Rake::ExtensionTask.new do |ext|
  ext.name = 'tkutil'
  ext.ext_dir = 'ext/tk/tkutil'
  ext.lib_dir = 'lib'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end

task test: :compile

namespace :screenshots do
  desc "Generate screenshots (without comparison)"
  task generate: :compile do
    ruby "-I", "lib", "test/visual_regression/widget_showcase.rb"
  end

  desc "Bless current unverified screenshots as baseline"
  task :bless do
    require 'fileutils'
    src = 'screenshots/unverified'
    dst = 'screenshots/blessed'
    FileUtils.mkdir_p(dst)
    Dir.glob("#{src}/*.png").each do |f|
      FileUtils.cp(f, dst)
      puts "Blessed: #{File.basename(f)}"
    end
  end
end

task :default => :compile
