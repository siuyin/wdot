#!/bin/sh

WDOT_HOME="/home/siuyin/prog/ruby/wdot"
SVN_URL="svn+ssh://siuyin@rubyforge.org/var/svn/wdot"
TRUNK_URL="${SVN_URL}/trunk"
TAG_URL="${SVN_URL}/tags"

read < scripts/RELEASE REL
VERSION_TAG="wdot-${REL}"
SVN_MESSAGE="Release ${VERSION_TAG} ."

cd $WDOT_HOME
svn cp $TRUNK_URL ${TAG_URL}/${VERSION_TAG} -m "$SVN_MESSAGE"
