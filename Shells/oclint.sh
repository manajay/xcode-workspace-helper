#! /bin/sh
#或者source ~/.bash_profile
source /etc/profile
cd ${SRCROOT}

if which oclint 2>/dev/null; then
echo 'oclint exist'
else
brew tap oclint/formulae
brew install oclint
fi
if which xcpretty 2>/dev/null; then
echo 'xcpretty exist'
else
gem install xcpretty
fi

xcodebuild  clean&&
xcodebuild | xcpretty -r json-compilation-database

cp ./build/reports/compilation_db.json ./compile_commands.json

if [ -f ./compile_commands.json ]; then echo "compile_commands.json 文件存在";
else echo "-----compile_commands.json文件不存在-----"; fi


oclint-json-compilation-database  -- \
-report-type xcode \
-rc LONG_LINE=200 \
-rc=NCSS_METHOD=100 \
-max-priority-1=100000 \
-max-priority-2=100000 \
-max-priority-3=100000; \
rm compile_commands.json;
