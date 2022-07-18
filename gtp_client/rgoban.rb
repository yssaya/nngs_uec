#! /usr/bin/env ruby -Ke

require 'gtk'

window = Gtk::Window.new()
window.signal_connect('delete_event'){
  Gtk::main_quit
}

drawing_area = Gtk::DrawingArea.new()
drawing_area.set_usize(200, 200)
window.add(drawing_area)

drawing_area.signal_connect("expose_event") do | drawing_area, event |
  drawable = drawing_area.window
  gc = Gdk::GC.new(drawable)
  colormap = Gdk::Colormap.get_system()

  lines = [Gdk::LINE_SOLID, Gdk::LINE_SOLID, Gdk::LINE_SOLID]
  caps =  [Gdk::CAP_BUTT, Gdk::CAP_ROUND, Gdk::CAP_PROJECTING]
  joins = [Gdk::JOIN_MITER, Gdk::JOIN_ROUND, Gdk::JOIN_BEVEL]
  angle2s = [360*64, 270*64, 60*64]
  (0..2).each do |i|
    line_width = i * 5 + 1
    box_x = i * 25 + 20
    box_y = i * 25 + 20

    color = Gdk::Color.new(0x4000 * i, 0x4000 * i, 0x4000 * i)
    colormap.alloc_color(color, nil, true)
    gc.set_foreground(color)
    gc.set_line_attributes(line_width, lines[i], caps[i], joins[i])
    drawable.draw_arc(gc, false, box_x, box_y, 100, 100, 0, angle2s[i])
  end
end

window.show_all
Gtk.main
