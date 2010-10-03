#!/bin/sh
WDOT_HOME='/home/siuyin/prog/ruby/wdot'
cd $WDOT_HOME
#rdoc --main wdot.rb  -t wdot -T hidden.rb wdot.rb
rdoc --main wdot.rb  -t wdot wdot.rb FAQ
rsync --delete --exclude .svn -avz doc/ siuyin@rubyforge.org:/var/www/gforge-projects/wdot/rdoc
