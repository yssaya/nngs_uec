#! /usr/bin/ruby

require "socket"
require './GtpEngine'
require './Match'

while true
  gs = TCPServer.open(9646)
  socks = [gs]
  addr = gs.addr
  addr.shift
  printf("server is on %s\n", addr.join(":"))
  
  cb = nil
  cw = nil
  
  t1 = Thread.start(gs.accept) do |s|       # save to dynamic variable
    cb = GtpEngine.new('black', s)
    print(s, " is accepted as BLACK.\n")
  end
  
  t2 = Thread.start(gs.accept) do |s|       # save to dynamic variable
    cw = GtpEngine.new('white', s)
    print(s, " is accepted as WHITE.\n")
  end
  t1.join
  t2.join
  gs.close()

  m = Match.new(cb, cw)
  m.newgame

  print "next game?(y/N) "
  yn = gets
  if ! yn[/[yY]/]
    exit
  end
end
      
