#! /usr/bin/ruby

require './GtpEngine'
require './Match'

program =if ARGV.size > 0 
           ARGV.join(' ')
         else
           "/usr/games/bin/gnugo --mode gtp --quiet"
         end

m = Match.new(GtpEngine.new('black', IO.popen(program, "r+")),
	      GtpEngine.new('white', IO.popen(program, "r+")))
m.newgame(10)

print "#{program}\n"
