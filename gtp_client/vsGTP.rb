#! /usr/bin/env ruby -Ke

require 'gtk'
require './Goban'


class GoEngine
  def newgame(color, size, komi = 6.5)
  end

  def genmove
  end

  def play
  end

  def score
  end
end


class GtpEngine < GoEngine
  def initialize(prog="/usr/games/bin/gnugo --mode gtp --quiet")
    @program=prog
    @io = nil
    @listener = []
    @color = nil
    @boardsize = 0
    @komi = 0
  end

  def add_listener(l)
    @listener << l
  end

  def send(s)
    return unless @io
    @io.puts(s)
    @listener.each  { | l | l.listen(s) }
    receive
  end

  def receive
    return unless @io
    result = ''
    while (s = @io.gets) 
      result += s
      if s == "\n"
	break
      end
      @listener.each  { | l | l.listen(s) }
    end
    result
  end

  def decode_coords(mv_str) 
    if (mv_str.upcae == 'PASS')
      return [-1, -1]
    end

    i = (mv_str.upcase[0] - ?A) + 1
    if (i >= ?I - ?A)
      i -= 1
    end
    j = mv_str[/[0-9]+/].to_i

    return [i, j]
  end


  def encode_coods(i, j)
    if (i == -1 && j == -1) 
      return 'PASS'
    end
      
    if (i >= ?I - ?A)
      i += 1
    end
      
    return '' << (?A + i) << j    
  end

  def newgame(color, size = 19, komi = 6.5)


    @color = color
    @boardsize = size
    @komi = komi

    send("boardsize #{@boardsize}\n")
    send("komi #{@komi}\n")
    send("clear_board\n")

    true
  end

  def genmove
    return false if @color.nil?
    mv = send("genmove #{@color}\n")
    decode_coords(mv[/[a-zA-Z][0-9]+/])
  end

  def play (i, j)
    return false if @color.nil?

    move = encode_coods(i, j)
    p move
    if (@color == 'white')  
      send("play black #{move}\n")
    elsif (@color == 'black')
      send("play white #{move}\n")
    end 
  end
  
  def score
  end
end

class Listener
  def initialize(text)
    @text=text
  end

  def listen(s)
    @text.insert_text(s, @text.get_length)
  end
end

class HumanUI < GoEngine
  def initialize(goban)
    @goban = goban
  end
  def newgame(color, size, komi = 0.0)
    @goban.set_boardsize(size)
  end

  def genmove
    
  end

  def play
  end

  def score
  end
end




goban = Goban.new()

goprog = GoProg.new

text = Gtk::Text.new()
text.set_editable(false)


l = Listener.new(text)
gtp = GtpEngine.new
gtp.add_listener(l)

entry = Gtk::Entry.new()
entry.signal_connect('activate') do | entry | 
  p entry.get_text
  text.insert_text(entry.get_text + "\n", text.get_length)
  goprog.send(entry.get_text + "\n")
  entry.set_text('')
end


newgame = Gtk::Button.new('newgame')
newgame.signal_connect('clicked'){
  goban.set_boardsize(5)
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
