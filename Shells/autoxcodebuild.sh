source /etc/profile
#说明
show_usage="args: [-m , -v , -b , -s , -w , -j , -u]\
                                  [--method=, --app-version=, --build-version=, --sdk=, --workspace-path=, --job-build-version=, --update-description=]"

#参数
# 打包签名的方式 development/ad-hoc/app-store/enterprise
opt_method="development"

# 应用的版本号
opt_app_version="1.0.0"

# 应用的build构建版本号 主要用于TestFlight 区分同一个应用版本号下的多个测试包
opt_build_version="1"

# sdk: 真机/模拟器  iphoneos/iphonesimulator
opt_sdk="iphoneos"

# 工作目录路径
opt_workspace_path=""

# jenkins 当前job的构建号
opt_job_build_version="1"

# 本次打包更新的说明
opt_update_description="测试更新: "

echo "=================== 开始解析参数 ===================" # https://my.oschina.net/leejun2005/blog/202376
GETOPT_ARGS=`getopt -o m:v:b:s:w:j:u: -al method:,app-version:,build-version:,sdk:,workspace-path:,job-build-version:,update-description: -- "$@"`
eval set -- "$GETOPT_ARGS"
#获取参数
while [ -n "$1" ]
do
        case "$1" in
                -m|--method) opt_method=$2; shift 2;;
                -v|--app-version) opt_app_version=$2; shift 2;;
                -b|--build-version) opt_build_version=$2; shift 2;;
                -s|--sdk) opt_sdk=$2; shift 2;;
                -w|--workspace-path) opt_workspace_path=$2; shift 2;;
                -j|--job-build-version) opt_job_build_version=$2; shift 2;;
                -u|--update-description) opt_update_description=$2; shift 2;;

                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done
echo "=================== 解析参数结束 ==================="

SCHEME="App"
TARGET="App"
PROJECT_NAME_DEBUG="测试"
PROJECT_NAME_ADHOC="测试"
PROJECT_NAME_APP_STORE="发布"

echo ${opt_workspace_path}
echo ${opt_job_build_version}

# 路径
# 当前job所有的打包总的路径
APP_BUILDS_PATH="${opt_workspace_path}/builds"
# 打包总路径下 当前应用版本号下 所有的打包记录目录
APP_VERSION_PATH="${APP_BUILDS_PATH}/${opt_app_version}"
# 本次打包的路径
BUILD_PATH="${APP_VERSION_PATH}/${opt_job_build_version}"
# 源文件的打包xcodeproj 路径
PROJECT_PATH="${opt_workspace_path}/${TARGET}/${TARGET}.xcodeproj"
PLIST_PATH="${opt_workspace_path}/${TARGET}/${TARGET}/${TARGET}.plist"

EXPORT_PATH="${BUILD_PATH}/${opt_method}"
IPA_PATH="${EXPORT_PATH}/${TARGET}.ipa"
ARCHIVE_PATH="${BUILD_PATH}/${opt_build_version}.xcarchive"


# 其他参数
TEAM_ID="L3xxxD8MT"
API_KEY="47c10xxx9e1b0"
USER_KEY="9802xxxxd5c5425"

METHOD_DEVELOPMENT="development"
METHOD_ADHOC="ad-hoc"
METHOD_APPSTORE="app-store"
METHOD_ENTERPRISE="enterprise"

BUILD_CONFIGURATION_DEBUG="Debug"
BUILD_CONFIGURATION_RELEASE="Release"
BUILD_CONFIGURATION_ADHOC="Adhoc"

#开发者(development)证书名#描述文件
DEVELOPMENT_CODE_SIGN_IDENTITY="iPhone Developer: xxxxx"
DEVELOPMENT_ROVISIONING_PROFILE_NAME="xxxx_dev"

# ad-hoc
#证书名#描述文件
ADHOC_CODE_SIGN_IDENTITY="iPhone Distribution: xxxxx"
ADHOC_PROVISIONING_PROFILE_NAME="xxxx_adhc"

#AppStore证书名#描述文件
APPSTORE_CODE_SIGN_IDENTITY="iPhone Distribution: xxxxx"
APPSTORE_ROVISIONING_PROFILE_NAME="xxxxDistribution"

# 更新应用的版本号
defaults write ${PLIST_PATH} CFBundleShortVersionString ${opt_app_version}
# 更新应用的构建版本号
defaults write ${PLIST_PATH} CFBundleVersion ${opt_build_version}

if [ "${opt_method}" = "${METHOD_DEVELOPMENT}" ]
then
defaults write ${PLIST_PATH} CFBundleDisplayName ${PROJECT_NAME_DEBUG}
elif [ "${opt_method}" = "${METHOD_ADHOC}" ]
then
defaults write ${PLIST_PATH} CFBundleDisplayName ${PROJECT_NAME_ADHOC}
else
defaults write ${PLIST_PATH} CFBundleDisplayName ${PROJECT_NAME_APP_STORE}
fi

# 解决 You must supply a CFBundleIdentifier for this request 问题


# 暂时不整理清空build文件夹 -d file 文件存在 并且是一个目录 https://billie66.github.io/TLCL/book/zh/chap28.html
if [ -d "${APP_BUILDS_PATH}" ]; \
then echo "builds文件夹存在"; \
else \
    mkdir ${APP_BUILDS_PATH}; \
fi

if [ -d "${APP_VERSION_PATH}" ] ;\
then mkdir ${BUILD_PATH};\
else \
mkdir ${APP_VERSION_PATH};\
mkdir ${BUILD_PATH};\
fi


if [ "${opt_method}" = "${METHOD_DEVELOPMENT}" ]
then

#development build archive file from source code
xcodebuild -project ${PROJECT_PATH} \
-scheme ${SCHEME} \
-configuration ${BUILD_CONFIGURATION_DEBUG} \
-sdk ${SDK} \
archive -archivePath ${ARCHIVE_PATH} \
CODE_SIGN_IDENTITY="${DEVELOPMENT_CODE_SIGN_IDENTITY}" \
PROVISIONING_PROFILE="${DEVELOPMENT_ROVISIONING_PROFILE_NAME}"

elif [ "${opt_method}" = "${METHOD_ADHOC}" ]
then
    
#ad-hoc build archive file from source code
xcodebuild -project ${PROJECT_PATH} \
-scheme ${SCHEME} \
-configuration ${BUILD_CONFIGURATION_ADHOC} \
-sdk ${SDK} \
archive -archivePath ${ARCHIVE_PATH} \
CODE_SIGN_IDENTITY="${ADHOC_CODE_SIGN_IDENTITY}" \
PROVISIONING_PROFILE="${ADHOC_PROVISIONING_PROFILE_NAME}"

else 

#AppStore build archive file from source code
xcodebuild -project ${PROJECT_PATH} \
-scheme ${SCHEME} \
-configuration ${BUILD_CONFIGURATION_RELEASE} \
-sdk ${SDK} \
archive -archivePath ${ARCHIVE_PATH} \
CODE_SIGN_IDENTITY="${APPSTORE_CODE_SIGN_IDENTITY}" \
PROVISIONING_PROFILE="${APPSTORE_ROVISIONING_PROFILE_NAME}"

fi


echo "=================== create plist  @ `date`==================="
cat <<EOF >export.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>teamID</key>
<string>${TEAM_ID}</string>
<key>method</key>
<string>${opt_method}</string>
<key>compileBitcode</key>
	<false/>
<key>uploadSymbols</key>
	<false/>
</dict>
</plist>
EOF


# export ipa file from .archive
echo "=================== exportArchive ${PROJECT_NAME}  @ `date`==================="
xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} \
-exportOptionsPlist export.plist \
-exportPath ${EXPORT_PATH} 

#上传蒲公英
echo "=================== upload ipa  @ `date`==================="

curl -F "file=@${IPA_PATH}" \
-F "uKey=${USER_KEY}" \
-F "_api_key=${API_KEY}" \
-F "updateDescription=${opt_update_description}" \
https://qiniu-storage.pgyer.com/apiv1/app/upload
echo "=================== done  @ `date` ==================="


