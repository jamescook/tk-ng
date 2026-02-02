---
layout: default
title: Home
nav_order: 1
---

# tk-ng API Documentation

Ruby bindings for Tcl/Tk 8.6+ and 9.x.

## Quick Links

- [Tk Module](/api/Tk/) - Main entry point
- [Tk::Button](/api/Tk/Button/) - Button widget
- [Tk::Canvas](/api/Tk/Canvas/) - Canvas for drawing
- [Tk::Text](/api/Tk/Text/) - Multi-line text editor

## Getting Started

```ruby
require 'tk'

root = Tk.root
Tk::Label.new(root, text: "Hello, World!").pack
Tk::Button.new(root, text: "Quit", command: -> { exit }).pack
Tk.mainloop
```

## Search

Use the search box above to find classes, modules, and methods.
