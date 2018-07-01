RC_HOME=`pwd`
echo "如果~/Library/Developer/Xcode/UserData/路径下没有CodeSnippets就会出问题"
ln -s ${SRC_HOME}/CodeSnippets ~/Library/Developer/Xcode/UserData/CodeSnippets
echo "done"

