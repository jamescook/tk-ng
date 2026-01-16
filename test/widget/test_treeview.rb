# frozen_string_literal: true

# Comprehensive test for Tk::Tile::Treeview widget options.
# Tests widget options AND item/column/heading/tag configuration.
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_treeview.html

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestTreeviewWidget < Minitest::Test
  include TkTestHelper

  def test_treeview_comprehensive
    assert_tk_app("Treeview widget comprehensive test", method(:treeview_app))
  end

  def treeview_app
    require 'tk'
    require 'tkextlib/tile/treeview'

    errors = []

    # --- Basic creation with columns ---
    tree = Tk::Tile::Treeview.new(root,
      columns: ['name', 'size', 'modified'],
      show: ['tree', 'headings'],
      height: 10
    )
    tree.pack(fill: "both", expand: true)

    errors << "height mismatch" unless tree.cget(:height) == 10

    # --- Configure headings ---
    tree.heading_configure('#0', text: 'Item')
    tree.heading_configure('name', text: 'Name')
    tree.heading_configure('size', text: 'Size')
    tree.heading_configure('modified', text: 'Modified')

    # Test heading cget
    heading_text = tree.headingcget('name', :text)
    errors << "heading text failed, got: #{heading_text}" unless heading_text == 'Name'

    # --- Configure columns ---
    tree.column_configure('#0', width: 150, stretch: false)
    tree.column_configure('name', width: 200, minwidth: 100)
    tree.column_configure('size', width: 80, anchor: 'e')
    tree.column_configure('modified', width: 150)

    # Test column cget
    col_width = tree.columncget('name', :width)
    errors << "column width failed, got: #{col_width}" unless col_width == 200

    col_stretch = tree.columncget('#0', :stretch)
    errors << "column stretch failed, got: #{col_stretch}" unless col_stretch == false

    # --- Insert items ---
    folder1 = tree.insert('', 'end', text: 'Documents', values: ['Documents', '4 KB', '2024-01-15'])
    folder2 = tree.insert('', 'end', text: 'Pictures', values: ['Pictures', '2.5 MB', '2024-01-10'])

    # Insert child items
    file1 = tree.insert(folder1, 'end', text: 'report.pdf', values: ['report.pdf', '1.2 MB', '2024-01-14'])
    file2 = tree.insert(folder1, 'end', text: 'notes.txt', values: ['notes.txt', '256 B', '2024-01-15'])

    # --- Item configuration ---
    # Configure item to be open
    tree.itemconfigure(folder1, open: true)
    open_val = tree.itemcget(folder1, :open)
    errors << "item open failed, got: #{open_val}" unless open_val == true

    # Configure item values
    tree.itemconfigure(file1, values: ['report_v2.pdf', '1.5 MB', '2024-01-16'])
    values = tree.itemcget(file1, :values)
    errors << "item values failed" unless values.is_a?(Array) && values[0] == 'report_v2.pdf'

    # --- Tags and tag configuration ---
    # Create a tag and apply to item
    tree.tag_configure('important', foreground: 'red', background: 'yellow')
    tree.itemconfigure(file1, tags: ['important'])

    # Test tag cget
    tag_fg = tree.tagcget('important', :foreground)
    errors << "tag foreground failed, got: #{tag_fg}" unless tag_fg.to_s.include?('red') || tag_fg == 'red'

    tag_bg = tree.tagcget('important', :background)
    errors << "tag background failed, got: #{tag_bg}" unless tag_bg.to_s.include?('yellow') || tag_bg == 'yellow'

    # --- Selection ---
    tree.selection_set(folder1)
    selection = tree.selection
    errors << "selection failed" unless selection.any? { |item| item.id == folder1.id }

    # --- Navigation ---
    children = tree.children('')
    errors << "children count wrong" unless children.size == 2

    folder1_children = tree.children(folder1)
    errors << "folder1 children count wrong" unless folder1_children.size == 2

    parent = tree.parent_item(file1)
    errors << "parent_item failed" unless parent.id == folder1.id

    # --- Item existence ---
    errors << "exist? failed for folder1" unless tree.exist?(folder1)

    # --- Focus ---
    tree.focus_item(folder2)
    focused = tree.focus_item
    errors << "focus_item failed" unless focused && focused.id == folder2.id

    # --- See (scroll into view) ---
    tree.see(file2)

    # --- Widget options ---
    tree.configure(selectmode: 'browse')
    errors << "selectmode failed" unless tree.cget(:selectmode) == 'browse'

    # --- Detach and reattach ---
    tree.detach(file2)
    errors << "detach failed, still in children" if tree.children(folder1).any? { |c| c.id == file2.id }

    tree.move(file2, folder1, 'end')
    errors << "move failed, not in children" unless tree.children(folder1).any? { |c| c.id == file2.id }

    # --- Delete item ---
    tree.delete(file2)
    errors << "delete failed, still exists" if tree.exist?(file2)

    # Check errors
    unless errors.empty?
      raise "Treeview test failures:\n  " + errors.join("\n  ")
    end
  end
end
