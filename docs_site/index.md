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
require 'tkextlib/tkimg/png'

root = Tk.root
root.title = "Tk Demo"

teapot = TkPhotoImage.new(file: "teapot.png")
Tk::Label.new(root, image: teapot).pack(padx: 10, pady: 10)

Tk::Label.new(root, text: "Ruby/Tk", font: "Helvetica 16 bold").pack
Tk::Button.new(root, text: "Quit", command: -> { exit }).pack(pady: 10)

Tk.mainloop
```

![Getting Started screenshot]({{ '/assets/images/getting_started.png' | relative_url }})

## Search

Use the search box above to find classes, modules, and methods.
