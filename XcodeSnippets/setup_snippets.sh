RC_HOME=`pwd`
CodeSnippets_PATH=~/Library/Developer/Xcode/UserData/CodeSnippets
#如果文件夹不存在，创建文件夹
if [ ! -d "${CodeSnippets_PATH}" ]; then
  mkdir ${CodeSnippets_PATH}
fi
ln -s ${SRC_HOME}/CodeSnippets ${CodeSnippets_PATH}
echo "done"

