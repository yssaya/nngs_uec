# NNGS for UEC cup
This is modified nngs(No Name Go Server) for Computer Go tournament, UEC Cup.  
Based on nngs-1.1.22.

# Changes
For Japanese rule, 3 kos.  
adminmatch command. (Scince AI-Ryusei 2017)  
Restart game(admin can use load command.)  
Some bug fixed. 64 bit support.

# GTP Client
Linux, Windows  
Ruby script to connnect nngs is on gtp_client.  
For Windows10, [CgfGoban](http://www.yss-aya.com/cgfgoban.html) is also available to connect nngs.

# How to install nngs for uec cup
```
$ git clone https://github.com/yssaya/nngs_uec
$ cd nngs_uec
$ chmod 777 ./configure
$ ./configure -prefix=/home/name/go/cgf2021/
$ cd mlrate/src
$ make
$ cd ../../
$ make
$ make install

$ cd ~/go/cgf2021/share/nngssrv/lists
$ cp admin.default admin

$ cd ~/go/cgf2021
$ bin/nngssrv

$ telnet localhost 9696
login admin. cgf2021/share/nngssrv/players/a/admin  is made.
Stop nngssrv(or run "shutdown now" by admin)
$ kill -9 xxxx

Change admin password
 cd /home/name/go/cgf2021/share/nngssrv/players/a
$ nano admin
Password: admin

Add this one line after Fullname. And restart nngs.
```

# Some useful admin commands
```
force user logout
># nuke test1
login players
># who
unfinished game for test1 (test1 has to be logged in)
># stored test1
```

# Start new game test1 as black
'''
># adminmatch test1 test2 b 19 30 0
'''
test1 as white
'''
># adminmatch test1 test2 w 19 30 0
'''
RubyScript does not require a black or white setting; CgfGoban does.

# Restart game
'''
1. ruby nngsCUI.rb   (login test1)
2. ruby nngsCUI.rb   (login hoge2)
3. login admin       (telnet localhost 9696)
4. #> adminmatch test1 hoge2 b 19 30 0
5. ctrl+c on test1   (after 5th moves)
6. ctrl+c on hoge2   (stop opponent too)
7. ruby nngsCUI.rb   (login test1)
8. ruby nngsCUI.rb   (login hoeg2. need to re-login both player)
9. #> load hoge2-test1   (admin. sometimes have to wait 30 second?)
'''
# Restart any game record. (hoge2(white) vs test1(black))
'''
1. Copy an unfinished game from share/nngssrv/games/*/* to
  "share/nngssrv/games/t/hoge2-test1"

2. Edit hoge2-test1, left time and SGF
  Left Time is (W_Time: 12897 means White left time is 1289.7 sec.)

  W_Time: 12897
  B_Time: 17196

  SGF, replace this part

  ;B[hn];W[bq];B[qi];W[ld];B[pg];W[ir];B[dd];W[jk]

3. Copy  (If test2-test game, this is not necessary.)
  "share/nngssrv/games/t/hoge2-test1"
  to
  "share/nngssrv/games/h/hoge2-test1"

4. restart game(hoge2 and tes1 must login).
  #> load hoge2-test1
'''

# Contributors In Historical Order
Nobusuke Sasaki  
Nobuo Araki  
Remi Coulom  
Hiroshi Yamashita  
