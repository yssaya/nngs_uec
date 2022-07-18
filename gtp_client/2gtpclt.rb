#! /usr/bin/ruby
require "socket"

if ARGV.size < 2
  print "\nusage: ruby 2gtpclt <hostname> <program> <program option>\n\n"
  exit
else
  host, *prog_v = ARGV
  program = prog_v.join(' ')
  print "host: #{host}\n"
  print "program: #{program}\n"
end

srv = TCPSocket.open(host, 9646)
gtp = IO.popen(program, "r+")
#srv.write("init\n")

while cmd = srv.gets
  p ["cmd", cmd]
  gtp.puts "#{cmd}\n"
  gtp.flush
  rcv = ""
  while (s = gtp.gets) 
    rcv += s
    if s == "\n"
      break
    end
  end
  p ["rcv", rcv]
  srv.write rcv
end
srv.close
gtp.close
