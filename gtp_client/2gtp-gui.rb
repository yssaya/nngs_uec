#! /usr/bin/ruby

require 'socket'
require './Goban'
require './GtpEngine'
require './Match'

vbox = Gtk::VBox.new()
goban = Goban.new()
vbox.add(goban)

class << goban
  def newgame(size, komi)
    set_boardsize(size)
  end
  def move(mv)
    p mv
    coords = mv[0]
    color = mv[1]
    if ! coords.nil?
      p coords
      draw_move(color, coords[0], coords[1])
    end
  end
end

def net_match (dpy)
  gs = TCPServer.open(9646)
  socks = [gs]
  addr = gs.addr
  addr.shift
  printf("server is on %s\n", addr.join(":"))
  printf("waiting for clients\n")

  cb = nil
  cw = nil

  t1 = Thread.start(gs.accept) do |s|       # save to dynamic variable
    cb = GtpEngine.new('black', s)
    print cb.send("name\n")
    print cb.send("name\n")
    print cb.send("version\n")
    print(s, " is accepted as BLACK.\n")
  end

  t2 = Thread.start(gs.accept) do |s|       # save to dynamic variable
    cw = GtpEngine.new('white', s)
    print cw.send("name\n")
    print cw.send("name\n")
    print cw.send("name\n")
    print cw.send("version\n")
    print(s, " is accepted as WHITE.\n")
  end

  t1.join
  t2.join
  gs.close()

  m = Match.new(cb, cw)
  m.add_display(dpy)
  m.newgame(5)
end

def gnugo_match(dpy)
  program = "/usr/games/bin/gnugo --mode gtp --quiet"
  m = Match.new(GtpEngine.new('black', IO.popen(program, "r+")),
                GtpEngine.new('white', IO.popen(program, "r+")))
  m.add_display(dpy)
  m.newgame(5)
end



netgame = Gtk::Button.new('new game (net)')
netgame.signal_connect('clicked'){
  Thread.new {
    net_match(goban)
  }
}

vbox.add(netgame)

newgame = Gtk::Button.new('new game')
newgame.signal_connect('clicked'){
  Thread.new {
    gnugo_match(goban)
  }
}

vbox.add(newgame)

quit = Gtk::Button.new('quit')
quit.signal_connect('clicked'){
  Gtk::main_quit
}
vbox.add(quit)

window = Gtk::Window.new()
window.signal_connect('delete_event'){ Gtk::main_quit }
window.add(vbox)
window.show_all

Gtk.timeout_add(10) {
  while (Gtk.events_pending)
    Gtk.main_iteration
  end
}

Gtk.main
