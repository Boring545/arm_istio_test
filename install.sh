#!/bin/bash

# 日志文件
LOGFILE="install.log"

# 日志记录函数
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# 错误处理函数
error_exit() {
    log "Error: $1"
    exit 1
}

# 检查命令是否成功执行
check_command() {
    if [ $? -ne 0 ]; then
        error_exit "Error executing: $1"
    else
        log "Successfully executed: $1"
    fi
}

# 确保脚本在任何错误时退出
set -e

# 询问用户是否执行某一步骤
confirm() {
    while true; do
        read -p "$1 (Y/N): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "请输入 Y 或 N.";;
        esac
    done
}

# 下载 istio-1.22.1
if confirm "是否下载 istio?"; then
    log "开始下载 istio..."
    if [ ! -d "istio" ]; then
        git clone --branch 1.22.1 https://github.com/istio/istio.git
        check_command "git clone --branch 1.22.1 https://github.com/istio/istio.git"
    else
        log "istio 已经下载，跳过此步骤."
    fi
fi

# 安装 Go 语言
if confirm "是否安装 Go 语言?"; then
    GO_URL="https://github.com/Boring545/go_golang.git"
    log "开始下载 Go 语言..."
    if [ ! -d "go_golang" ]; then
        git clone ${GO_URL} 
        check_command "git clone ${GO_URL}"
        log "Go 安装完成."
    else
        log "Go 安装包已经下载，跳过此步骤."
    fi

    log "设置 Go 环境变量..."
    export GOROOT=$PWD/go_golang/go
    export GOPATH=$PWD/go_golang/golang
    export PATH=$GOROOT/bin:$GOPATH/bin:$PATH 
    export GOSUMDB=sum.golang.org
    go env -w GO111MODULE=on
    go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
    log "Go 环境变量设置完成."

    go install github.com/jstemmer/go-junit-report@latest
    check_command "go install github.com/jstemmer/go-junit-report@latest"
fi

# 将脚本移动到指定目录中
mv run_tests.sh ./istio
mv performance_counter_920.sh ./istio
mv count_test.py ./istio
mv count_perf.py ./istio
log "赋予执行权限"
chmod +x -R .

if confirm "是否切换目录位置到 istio 文件下?"; then
    log "切换目录位置到 istio 文件下"
    cd istio
fi

# 下载构建所需的 Docker 镜像
if confirm "是否下载构建所需的 Docker 镜像?"; then
    docker pull registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac
    check_command "docker pull registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac"
    docker tag registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac gcr.io/istio-testing/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac
    check_command "docker tag registry.cn-hangzhou.aliyuncs.com/iloveyuanshen/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac gcr.io/istio-testing/build-tools:release-1.22-90c1573ac8a673ef69c7d0587232efa748243fac"
fi

# 初始化构建
if confirm "是否初始化构建?"; then
    log "初始化构建"
    make init
    check_command "make init"
    go mod download
    mkdir backup
    mv Makefile.overrides.mk backup/
    make build
    check_command "make build"
fi

# 进行测试和性能测试
if confirm "是否进行测试和性能测试?"; then
    log "进行测试和性能测试"
    ./run_tests.sh
    check_command "./run_tests.sh"
fi

# 安装 Python 依赖包并统计测试结果
if confirm "是否安装 Python 依赖包并统计测试结果?"; then
    log "安装 Python 依赖包并统计测试结果"
    pip3 install os pandas openpyxl
    check_command "pip3 install os pandas openpyxl"

    log "依赖安装成功，开始统计"
    python count_test.py
    check_command "python count_test.py"
    python count_perf.py
    check_command "python count_perf.py"
fi

log "所有步骤完成"
