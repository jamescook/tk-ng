# Windows Setup for tk-ng

This guide covers setting up tk-ng on Windows using RubyInstaller with MSYS2.

## Prerequisites

- **RubyInstaller with Devkit** (Ruby 3.2+): https://rubyinstaller.org/
  - During installation, select "MSYS2 development toolchain"

## Install Tcl/Tk Development Libraries

Open an **Administrator PowerShell** and run:

```powershell
# Add MSYS2 to system PATH (one-time setup)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Ruby40-x64\msys64\usr\bin;C:\Ruby40-x64\msys64\ucrt64\bin", "Machine")

# Install Tcl/Tk for UCRT64 toolchain
pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-tcl mingw-w64-ucrt-x86_64-tk
```

> **Note**: Adjust `Ruby40-x64` to match your Ruby installation path (e.g., `Ruby33-x64`).

## Build and Test

Open a new terminal (to pick up PATH changes), then:

```bash
cd path/to/tk-ng
bundle install
bundle exec rake compile
bundle exec rake test
```

## Verify Installation

```ruby
ruby -Ilib -e "require 'tk'; puts Tk::TCL_VERSION"
```

## Troubleshooting

### "Permission denied" when running pacman

Run the command in an Administrator terminal.

### "unable to lock database"

Close any MSYS2 terminals and try again in an Administrator PowerShell.

### Tcl/Tk headers not found

Verify the packages installed correctly:

```bash
ls /c/Ruby40-x64/msys64/ucrt64/include/tcl.h
ls /c/Ruby40-x64/msys64/ucrt64/lib/libtclstub86.a
```

### Tests fail with tkimg errors

The tkimg extension is optional. Install it with:

```bash
pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-tkimg
```
