These ruby files are for connecting your GTP program to NNGS for UEC Cup.


How to use this script

1. Edit config.rb (following is a sample).

# From '#' to the end-of-line is a comment.
--------------------------------------------------------------
$config = {
  'NNGS' => {
#   'server'=>'jsb.cs.uec.ac.jp', #NNGS test server IP
    'server'=>'192.168.11.1',     #NNGS server IP
    'port'=>'9696',               #NNGS port (fixed)
    'user'=>'test1',              #your account
#   'pass'=>''                    #your password, not necessary
  },
  'GTP' => {	# command to start your program
    'command'=>'/usr/games/bin/gnugo --mode gtp --quiet'
  },
  'SIZE' => 19,	# board size: 9, 13, or 19
  'KOMI' => 6.5,# komi
  'TIME' => 30	# sudden death time in minutes
  'BYO_YOMI' => 0
}
--------------------------------------------------------------


2. Run scrpit

  $ ruby nngsCUI.rb


3. Revision history
  2022-07-17   Restart game. Refuse wrong time. by Hiroshi Yamashita

  2018-07-15   AI Ryusei version, by Nobuo Araki

  2015-06-29   add sending "time_settings" gtp commamd by Hideki Kato

  2015-06-25   unified two versions and fixed waitfor by Hideki Kato

  2015-06-17   by Hiroshi Yamashita.
    modified for ruby 1.8, 1.9 and newer.
    This script works at least
      ruby 2.1.5p273,
      ruby 1.9.3p194, and
      ruby 1.8.5.

  2010-08-25   fixed BYO_YOMI by Manabe@UEC

  2010-05-19   added BYO_YOMI by Iwakawa@UEC

  2009-11-06   by Hideki Kato and UEC students
    komi has changed from 0 to 6.5.
    handle 'resign' correctly.

  2008-10-25   KOMI was added by sakage

  2004-09-12   created by <unknown>.
    First version for Gifu Challenge.
    http://www.computer-go.jp/gifu2004/regulations/sample.html


4. Notice

  This script is distributed without any warranty. No one is
  responsible for any troubles or problems caused by using this script.
