#! /usr/bin/env ruby -Ke

require 'gtk'

class Goban < Gtk::DrawingArea
  @@margin = 30

  def initialize
    super
    signal_connect("expose_event") { |w,e| expose_event(w,e) }
    signal_connect("configure_event") { |w, e| configure_event(w,e) }
    signal_connect("button_press_event") { |w,e| pressed(w,e) }
    set_events(Gdk::BUTTON_PRESS_MASK)

    @buffer = nil
    @bgc = nil
    @fgc = nil
    @boardsize = 9
    @moves = []

    set_usize(400, 400)
#    set_boardsize(9)
  end

  def set_boardsize(size) 
    @moves = []
    @boardsize = size
    g = self.window.get_geometry
    if (g[2] > 0 && g[3] > 0)
      b = Gdk::Pixmap::new(self.window, g[2], g[3], -1)
      clear(b)
      @buffer = b
      self.window.draw_pixmap(@bgc, @buffer, 0,0,
                              g[0], g[1], g[2], g[3])
    end
  end

  def expose_event(w,e)
    if ! @buffer.nil?
      rec = e.area
      w.window.draw_pixmap(@bgc, @buffer, rec.x, rec.y,
                           rec.x, rec.y, rec.width, rec.height)
    end
    false
  end

  def clear(b = @buffer)
    return if b.nil?

    g = b.get_geometry
    @bgc = self.style.bg_gc(self.state) if @bgc.nil?
    @fgc = self.style.fg_gc(self.state) if @fgc.nil?
    if (g[2] > 0 && g[3] > 0)
      b.draw_rectangle(@bgc, true, 0,0, g[2], g[3])

      width = if (g[2] < g[3])
              then g[2]
              else g[3]
              end
      @cell_w = (width - 2 * @@margin) / @boardsize
      o = @@margin + @cell_w / 2
      e =  o + (@boardsize - 1) * @cell_w

      (1..@boardsize).each { |i|
        pp = o + (i - 1) * @cell_w
        b.draw_line(@fgc, o, pp, e, pp)
        b.draw_line(@fgc, pp, o, pp, e)
      }
    end
  end

  def configure_event(w,e)
    g = w.window.get_geometry
    if (g[2] > 0 && g[3] > 0)
      b = Gdk::Pixmap::new(w.window, g[2], g[3], -1)
      clear(b)
      @buffer = b
      @moves.each { | color, i, j |
        draw_move(color, i, j)
      }
      g = @buffer.get_geometry
      b.draw_pixmap(@bgc, @buffer, 0,0,
                    g[0], g[1], g[2], g[3])
    end
    true
  end

  def move(color, i, j)
    p  [color, i, j]
    @moves << [color, i, j]

#    @moves.each { | a, b, c |
#      p [a, b, c]
#    }
    draw_move(color, i, j)
  end

  def undo
  end

  def draw_move(color, i, j)
    p ['dm', color, i, j]
    x = @@margin + (@cell_w / 2 ) + (i - 1) * @cell_w - @cell_w * 0.4
    y = @@margin + (@cell_w / 2 ) + (@boardsize - j) * @cell_w - @cell_w * 0.4
    if (color.upcase=='BLACK') 
        @buffer.draw_arc(@fgc, true, x, y, @cell_w * 0.8, @cell_w * 0.8, 0, 360*64)
    elsif (color.upcase=='WHITE') 
      @buffer.draw_arc(@bgc, true, x, y, @cell_w * 0.8, @cell_w * 0.8, 0, 360*64)
      @buffer.draw_arc(@fgc, false, x, y, @cell_w * 0.8, @cell_w * 0.8, 0, 360*64)
    end
    g = @buffer.get_geometry
    self.window.draw_pixmap(@bgc, @buffer, x, y, x, y, @cell_w, @cell_w)
    p ['dm', color, i, j, 'end']
  end

  def pressed(w, ev)
    o = @@margin + @cell_w / 2
    e =  o + (@boardsize - 1) * @cell_w

    i = Integer((ev.x - @@margin) / @cell_w) + 1
    j = @boardsize - Integer((ev.y - @@margin) / @cell_w)
    if (1 <= i && i <= @boardsize && 1 <= j && j <= @boardsize )
      move('w', i, j)
    end
    true
  end
end

#Gtk.init
=begin
goban = Goban.new()

window = Gtk::Window.new()
window.signal_connect('delete_event'){ Gtk::main_quit }
window.add(goban)
window.show_all

Gtk.main
=end
