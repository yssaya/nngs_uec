require './Ord.rb'

class GtpEngine
  def initialize(color, io)
    @program = p
    @io = io
    @color = color
  end

  def send(s)
    return unless @io
    puts " GTP <- #{s}"
    @io.puts(s)
    receive
  end

  def receive
    return unless @io
    rcv = ''
    while (s = @io.gets) 
      puts " GTP -> #{s}"
      rcv += s
      if s == "\n"
	break
      end
    end
    rcv
  end

  def newgame(size, komi, time) 
    send("boardsize #{size}\n")
    send("komi #{komi}\n")
    send("clear_board\n")
    send("time_settings #{time} 0 0")
  end

  def decode_coords(mv)
    if mv == "resign"
      "resign"
    elsif mv.nil?
      nil
    else
      i = mv.upcase[0].ord - ?A.ord + 1
      i = i - 1 if i > ?I.ord - ?A.ord
      j = mv[/[0-9]+/].to_i
      [i, j]
    end
  end

  def encode_coords(mv)
    if mv.nil?
      "PASS"
    else
      i = mv[0]
      j = mv[1]
      is = '' << 'ABCDEFGHJKLMNOPQRSTUVWXYZ'[i - 1]
      "#{is}#{j}"
    end
  end

  def genmove
    rcv = send("genmove #{@color}\n")
    tmp = rcv.downcase[/resign/]
    if tmp == "resign"
       #move = "resign"
       return ["resign" , @color]
    else
       move = rcv[/[a-zA-Z][0-9]+/]
    end
    [decode_coords(move), @color]
  end

  def playmove (mv)
    move = encode_coords(mv[0])
    color = mv[1]
    
    send("play #{color} #{move}\n")
  end

  def undo
    send("undo\n")
  end

  def time_left (color, left)
    send("time_left #{color} #{left} 0\n")
  end

  def quit
    send("quit\n")
    @io.close
  end
end
