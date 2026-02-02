# frozen_string_literal: false
#
#  tkextlib/trofs/trofs.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/trofs/setup.rb'

# TkPackage.require('trofs', '0.4')
TkPackage.require('trofs')

module Tk
  # Read-only virtual filesystem for Tcl.
  #
  # Trofs (Tcl Read-Only FileSystem) creates and mounts archive files
  # as virtual filesystems. This is useful for:
  # - Single-file application distribution
  # - Bundling resources (images, data files) with scripts
  # - Creating Tcl Modules (`.tm` files)
  #
  # ## Creating an Archive
  #
  #     # Bundle a directory into an archive
  #     Tk::Trofs.create_archive('/path/to/myapp', 'myapp.trofs')
  #
  # ## Mounting and Using
  #
  #     # Mount the archive
  #     mountpoint = Tk::Trofs.mount('myapp.trofs', '/vfs/myapp')
  #
  #     # Access files through the mountpoint
  #     File.read("#{mountpoint}/config.txt")
  #     TkPhotoImage.new(file: "#{mountpoint}/images/logo.png")
  #
  #     # Unmount when done
  #     Tk::Trofs.unmount(mountpoint)
  #
  # ## Self-Contained Scripts
  #
  # Trofs archives can be appended to Tcl scripts. The archive starts
  # with `\u001A` (EOF for Tcl's `source`), so the script runs normally
  # and can then mount itself:
  #
  #     # In your script:
  #     Tk::Trofs.mount(__FILE__, '/vfs/self')
  #
  # ## Nested Mounts
  #
  # Unlike tclvfs, trofs supports arbitrarily nested archives—an archive
  # inside a mounted archive can itself be mounted.
  #
  # @note Archives are read-only. Use regular filesystem for writes.
  # @note Requires the trofs Tcl package to be installed.
  #
  # @see https://wiki.tcl-lang.org/page/trofs Tcl Wiki: trofs
  module Trofs
    extend TkCore

    PACKAGE_NAME = 'trofs'.freeze
    def self.package_name
      PACKAGE_NAME
    end

    def self.package_version
      begin
        TkPackage.require('trofs')
      rescue
        ''
      end
    end

    ##############################################

    # Create a trofs archive from a directory.
    #
    # Bundles all files and subdirectories into a single archive file.
    # The archive can then be mounted as a virtual filesystem.
    #
    # @param dir [String] Source directory to archive
    # @param archive [String] Output archive file path
    # @return [String] The archive path
    #
    # @example Create an archive
    #   Tk::Trofs.create_archive('lib/myapp', 'myapp.trofs')
    #
    # @example Append to existing file (for self-contained scripts)
    #   Tk::Trofs.create_archive('resources', 'myapp.tcl')
    def self.create_archive(dir, archive)
      tk_call('::trofs::archive', dir, archive)
      archive
    end

    # Mount an archive as a virtual filesystem.
    #
    # After mounting, files in the archive are accessible through
    # the mountpoint path using normal file operations.
    #
    # @param archive [String] Path to trofs archive file
    # @param mountpoint [String, nil] Where to mount (auto-generated if nil)
    # @return [String] Normalized path to the mountpoint
    #
    # @example Mount with explicit path
    #   mp = Tk::Trofs.mount('data.trofs', '/vfs/data')
    #   File.read("#{mp}/config.json")
    #
    # @example Mount with auto-generated path
    #   mp = Tk::Trofs.mount('data.trofs')
    #   # mp is something like "/tmp/trofs12345"
    def self.mount(archive, mountpoint=None)
      # returns the normalized path to mountpoint
      tk_call('::trofs::mount', archive, mountpoint)
    end

    # Unmount a previously mounted archive.
    #
    # @param mountpoint [String] Path returned by {.mount}
    # @return [String] The mountpoint path
    #
    # @example
    #   mp = Tk::Trofs.mount('data.trofs', '/vfs/data')
    #   # ... use files ...
    #   Tk::Trofs.unmount(mp)
    def self.unmount(mountpoint)
      tk_call('::trofs::unmount', mountpoint)
      mountpoint
    end

    class << self
      # @!method umount(mountpoint)
      # Alias for {.unmount}.
      alias umount unmount
    end
  end
end
