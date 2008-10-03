#!/bin/sh
REL=0.2

WDOT_HOME='/home/siuyin/prog/ruby/wdot'
cd $WDOT_HOME
echo "wdot-$REL" > README
cat scripts/README.in >> README
cd ..

rm wdot-$REL.tgz
rm wdot-$REL.zip
tar --exclude '.svn' -cvzf wdot-$REL.tgz wdot
zip -r wdot-$REL.zip wdot -x */*.svn/*
