#!/bin/bash
shopt -s extglob
set -e
script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
source_dir=$script_dir/LingmoSrcBuild/Src
deb_dir=$script_dir/LingmoSrcBuild/Deb

echo 'Welcome to astraOS Builder!'
echo 'NOTE: Powered by CutefishOS and LingmoOS Sources'

if test -e $source_dir
then
  echo 'Deleting existing astraOS WorkDir...'
  rm -rf $source_dir
fi
echo 'Creating existing astraOS WorkDir...'
mkdir -p $source_dir

if test -e $deb_dir
then
  echo 'Wait a second...'
  rm -rf $deb_dir
fi
echo 'Wait YET ANOTHER second ASSHOLE...'
mkdir -p $deb_dir

function InstallDepends() {
    echo 'Installing Dependences... (i like dick :3)'
    apt-get --yes install git  devscripts equivs
    rm -rfv astraOSBuildDeps
    git clone https://github.com/teamsakuraos/astraOSBuildDeps.git
    cd astraOSBuildDeps
    mk-build-deps -i -t "apt-get -y" -r  > /dev/null
}

# 定义一个函数来编译项目
function Compile() {
    repo_name=$1
    echo "Cloning $repo_name ..."
    cd $source_dir
    if test -d $repo_name; then
        echo "已存在 $repo_name 目录，更新中..."
        cd $repo_name && git reset --hard HEAD && git pull
    else
        echo "正在克隆 $repo_name ..."
        git clone https://github.com/teamsakuraos/$repo_name.git
        cd $repo_name
    fi
    echo "正在安装 $repo_name 依赖..."
    # 在这里添加项目的依赖安装代码
    mk-build-deps -i -t "apt-get --yes" -r
    echo "构建 $repo_name ..."
    dpkg-buildpackage -b -uc -us -tc -j$(nproc)
    # 在这里添加项目构建和编译命令
    echo "$repo_name 编译完成"

    # lingmo-kwin 需要安装
    # if [ "$repo_name" = "lingmo-kwin" ]; then
    #     echo "安装 lingmo-kwin"
    #     apt install -y --no-install-recommends $source_dir/!(*dbgsym*).deb
    # fi
    
    echo "复制 $repo_name 的安装包"
    cd $source_dir
    mv -v !(*dbgsym*).deb $deb_dir/
}
REPOS="astra-screenlocker astra-settings astra-screenshots lingmo-cursor-themes astra-sddm-theme astra-appmotor lingmo-neofetch lingmo-daemon lingmo-ocr astra-terminal astra-gtk-themes PetalyUI astra-systemicons astra-wallpapers lingmo-debinstaller astra-calculator astra-launcher astra-statusbar lingmo-qt-plugins astra-dock liblingmo lingmo-filemanager lingmo-core astra-texteditor lingmo-kwin-plugins lingmo-videoplayer astra-plymouth-theme"

# 先安装依赖
InstallDepends

# 列出所有项目供用户选择
select project in \
astra-screenlocker \
astra-settings \
astra-screenshots \
lingmo-cursor-themes \
astra-sddm-theme \
astra-appmotor \
lingmo-neofetch \
lingmo-daemon \
lingmo-ocr \
astra-terminal \
astra-gtk-themes \
PetalyUI \
astra-systemicons \
astra-wallpapers \
lingmo-debinstaller \
astra-calculator \
astra-launcher \
astra-statusbar \
lingmo-qt-plugins \
astra-dock \
liblingmo \
lingmo-filemanager \
lingmo-core \
astra-texteditor \
lingmo-kwin-plugins \
lingmo-videoplayer \
astra-plymouth-theme \
all \
quit

do
    if [[ $project == "all" ]]; then
        for repo in $REPOS; do
            Compile $repo
        done
        exit 0
    elif [[ $project == "quit" ]]; then
        break
    else
        Compile $project
    fi
done
