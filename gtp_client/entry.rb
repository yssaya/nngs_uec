#! /usr/bin/env ruby -Ke

require 'gtk'

class GoProg
  @io
  @text
  def start(text)
#      prog="/home/kubo/tmp/nngs/clients/gtp_skel/sample"
    prog="/usr/games/bin/gnugo --mode gtp --quiet"
    @io = IO.popen(prog, "r+")
    @text = text
  end

  def send(s)
    return unless @io
    @io.puts(s)
    receive
  end

  def receive
    return unless @io
    while (s = @io.gets) 
      if s == "\n"
	break
      end
      @text.insert_text(s, @text.get_length)
    end
#    s = @io.read
#    @text.insert_text(s + "\n", @text.get_length)
  end
end

class Canvas < Gtk::DrawingArea
  def initialize
    super
    signal_connect("expose_event") { |w,e| expose_event(w,e) }
    signal_connect("configure_event") { |w, e| configure_event(w,e) }
    @buffer = nil
    @bgc = nil
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
    if (g[2] > 0 && g[3] > 0)
      b.draw_rectangle(@bgc, true, 0,0, g[2], g[3])
    end
  end

  def configure_event(w,e)
    g = w.window.get_geometry
    if (g[2] > 0 && g[3] > 0)
      b = Gdk::Pixmap::new(w.window, g[2], g[3], -1)
      clear(b)
      if not @buffer.nil?
        g = @buffer.get_geometry
        b.draw_pixmap(@bgc, @buffer, 0,0,
                      g[0], g[1], g[2], g[3])
      end
      @buffer = b
    end
    true
  end
end

class Goban < Canvas
  
  def initialize
    super
    set_usize(400, 400)
    signal_connect("button_press_event") { |w,e| pressed(w,e) }
    set_events(Gdk::BUTTON_PRESS_MASK)
  end

  

  def pressed(widget, ev)
    if not @last.nil?
      @buffer.draw_line(widget.style.fg_gc(widget.state),
                        @last.x, @last.y, ev.x, ev.y)

      x1,x2 = if (@last.x < ev.x)
              then [@last.x, ev.x]
              else [ev.x,    @last.x]
              end
      y1,y2 = if (@last.y < ev.y)
            then [@last.y, ev.y]
            else [ev.y,    @last.y]
            end
      widget.draw(Gdk::Rectangle.new(x1,y1,x2-x1+1,y2-y1+1))
    end
    @last = nil
    @last = ev
    true
  end
end

goban = Goban.new()

goprog = GoProg.new

text = Gtk::Text.new()
text.set_editable(false)

entry = Gtk::Entry.new()
entry.signal_connect('activate') do | entry | 
  p entry.get_text
  text.insert_text(entry.get_text + "\n", text.get_length)
  goprog.send(entry.get_text + "\n")
  entry.set_text('')
end


newgame = Gtk::Button.new('newgame')
newgame.signal_connect('clicked'){
  goprog.send("boardsize 5\n")
  goprog.send("komi 0\n")
  goprog.send("clear_board\n")
}

quit = Gtk::Button.new('quit')
quit.signal_connect('clicked'){
  goprog.send("quit\n")
  Gtk::main_quit
}

vbox = Gtk::VBox.new();
vbox.add(goban)
vbox.add(entry)
vbox.add(text)
vbox.add(newgame)
vbox.add(quit)

window = Gtk::Window.new()
window.signal_connect('delete_event'){ Gtk::main_quit }
window.add(vbox)
window.show_all


goprog.start(text)

Gtk.main
