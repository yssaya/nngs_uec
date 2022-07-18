require './NngsClient'
require './GtpEngine'
require './config'

user = if ARGV[0].nil?
	 $config['NNGS']['user']
       else
	 ARGV[0]
       end

server = if ARGV[1].nil?
	   $config['NNGS']['server']
	 else
	   ARGV[1]
	 end


nngs = NNGSClient.new(server,
		      $config['NNGS']['port'],
		      user,
		      $config['NNGS']['pass'],
		      $config['SIZE'],
		      $config['TIME'],
		      $config['KOMI'],          # added by sakage 2008/10/25
		      $config['BYO_YOMI']);     # added by iwakawa 2010/5/19

announce = Class.new
class << announce
  def update(args) 
    case args[0]
    when 'my_turn'
      puts '****** I am thinking now   ******'
    when 'his_turn'
      puts '****** wating for his move ******'
    end
  end
end

engine = Class.new
class << engine
  attr_writer :nngs

  def update(args)
    #puts ('update'+args[0].to_s+args[1].to_s)
    case args[0]
    when 'start'
      @my_color = case args[1]
                  when NNGSClient::BLACK
                    'BLACK'
                  else 
                    'WHITE'
                  end
      @his_color = case args[1]
                  when NNGSClient::BLACK
                    'WHITE'
                  else 
                    'BLACK'
                  end
      @gtp = GtpEngine.new(@my_color,
                           IO.popen($config['GTP']['command'], "r+"))
      @gtp.newgame(@nngs.size, @nngs.komi, 60*@nngs.time)  # by sakage 2008/10/25, kato 2015/6/29

    when 'my_turn'
      @gtp.time_left('WHITE', @nngs.white_user[2])
      @gtp.time_left('BLACK', @nngs.black_user[2])
      mv, c = @gtp.genmove
      if mv.nil?
        mv = 'PASS'
      elsif mv == "resign"
        
      else
        i, j = mv
        mv = '' << 'ABCDEFGHJKLMNOPQRST'[i-1]
        mv = "#{mv}#{j}"
      end
      @nngs.input mv

    when 'his_move'
      mv = nngsmv_to_mv(args[1])
      @gtp.playmove([mv, @his_color])

    when 'play_move'
      mv = nngsmv_to_mv(args[1])
      @gtp.playmove([mv, args[2]])

    when 'scoring'
      @gtp.quit
    end
  end

  def nngsmv_to_mv(nngsmv)
    mv = if nngsmv == 'Pass'
           nil
         elsif nngsmv.downcase[/resign/] == "resign"
           "resign"
         else
           i = nngsmv.upcase[0].ord - ?A.ord + 1
           i = i - 1 if i > ?I.ord - ?A.ord
           j = nngsmv[/[0-9]+/].to_i
           [i, j]
         end
    return mv
  end

end

human = Class.new
class << human
  attr_writer :nngs
  
  def update(args) 
#    puts "human[#{args[0]}]"
    case args[0]
    when 'login'
      select_user
    when 'request'
      ask_match(args[1], args[2])
    when 'cancel'
      select_user
    when 'scoring'
      @nngs.input 'done'
    when 'end'
      @nngs.logout
      exit
    end
  end
  
  def select_user
    #puts 'input user:'
    #STDIN.gets
    #user = $_.chop
    #if user.empty?
    puts 'wating match request.'
    #else
    #  @nngs.cmd_match user
    #end
  end

  def ask_match(ok, cancel)
    puts 'match requested. accept? (Y/n):'
    #STDIN.gets
    #user = $_.chop
    #puts user
    #if not user.scan(/n/).empty?
    #  @nngs.cmd_match_cancel
    #else
    @nngs.cmd_match_ok
    #end
  end
end


nngs.add_observer(announce)
nngs.add_observer(engine)
engine.nngs= nngs
nngs.add_observer(human)
human.nngs= nngs

nngs.login
#t = Thread.new {
#  begin
while res = select([nngs.socket], nil, nil, nil)
    nngs.parse
end
#  rescue Exception

#  end
#}
#t.join
