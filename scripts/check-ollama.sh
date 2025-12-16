#!/bin/bash
# Ollama 连接诊断脚本

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

log_info() {
    printf "%b\n" "${BLUE}[INFO]${NC} $1"
}

log_success() {
    printf "%b\n" "${GREEN}[✓]${NC} $1"
}

log_error() {
    printf "%b\n" "${RED}[✗]${NC} $1"
}

log_warning() {
    printf "%b\n" "${YELLOW}[!]${NC} $1"
}

echo ""
printf "%b\n" "${GREEN}========================================${NC}"
printf "%b\n" "${GREEN}  Ollama 连接诊断工具${NC}"
printf "%b\n" "${GREEN}========================================${NC}"
echo ""

# 获取 Ollama URL
OLLAMA_URL="${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"

log_info "检查 Ollama 配置..."
echo "  OLLAMA_BASE_URL: ${OLLAMA_BASE_URL:-未设置（使用默认值）}"
echo "  目标 URL: $OLLAMA_URL"
echo ""

# 检查 Ollama 是否在本地运行
log_info "1. 检查本地 Ollama 服务..."

if command -v ollama &> /dev/null; then
    log_success "Ollama CLI 已安装"
    
    # 检查 Ollama 服务是否运行
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        log_success "本地 Ollama 服务正在运行 (localhost:11434)"
        
        # 获取版本信息
        VERSION=$(curl -s http://localhost:11434/api/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "未知")
        if [ -n "$VERSION" ] && [ "$VERSION" != "未知" ]; then
            log_info "  Ollama 版本: $VERSION"
        fi
        
        # 列出已安装的模型
        log_info "  已安装的模型:"
        curl -s http://localhost:11434/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
            if [ -n "$model" ]; then
                echo "    - $model"
            fi
        done
    else
        log_error "本地 Ollama 服务未运行 (localhost:11434)"
        log_warning "  请启动 Ollama 服务: ollama serve"
    fi
else
    log_warning "Ollama CLI 未安装"
    log_info "  安装方法:"
    echo "    macOS: brew install ollama"
    echo "    Linux: curl -fsSL https://ollama.com/install.sh | sh"
fi

echo ""

# 检查 Docker 容器内的连接
log_info "2. 检查 Docker 容器连接..."

if command -v docker &> /dev/null && docker info &> /dev/null; then
    # 检查 WeKnora-app 容器是否运行
    if docker ps | grep -q "WeKnora-app"; then
        log_success "WeKnora-app 容器正在运行"
        
        # 从容器内测试连接
        log_info "  从容器内测试连接到 $OLLAMA_URL..."
        
        # 提取主机和端口
        if [[ $OLLAMA_URL == http://* ]]; then
            HOST_PORT="${OLLAMA_URL#http://}"
        elif [[ $OLLAMA_URL == https://* ]]; then
            HOST_PORT="${OLLAMA_URL#https://}"
        else
            HOST_PORT="$OLLAMA_URL"
        fi
        
        HOST="${HOST_PORT%%:*}"
        PORT="${HOST_PORT##*:}"
        
        log_info "  解析结果: Host=$HOST, Port=$PORT"
        
        # 测试 DNS 解析
        if [ "$HOST" = "host.docker.internal" ]; then
            log_info "  测试 host.docker.internal DNS 解析..."
            if docker exec WeKnora-app getent hosts host.docker.internal > /dev/null 2>&1; then
                log_success "  host.docker.internal 可以解析"
            else
                log_error "  host.docker.internal 无法解析"
                log_warning "  可能需要在 docker-compose.yml 中添加 extra_hosts 配置"
            fi
        fi
        
        # 测试网络连接
        log_info "  测试网络连接..."
        if docker exec WeKnora-app sh -c "timeout 5 nc -z $HOST $PORT 2>/dev/null" 2>/dev/null; then
            log_success "  网络连接成功 ($HOST:$PORT)"
        else
            log_error "  网络连接失败 ($HOST:$PORT)"
            
            # 提供诊断建议
            echo ""
            log_warning "  可能的解决方案:"
            if [ "$HOST" = "host.docker.internal" ]; then
                echo "    1. 确保 docker-compose.yml 中包含:"
                echo "       extra_hosts:"
                echo "         - \"host.docker.internal:host-gateway\""
                echo ""
                echo "    2. 如果问题仍然存在，尝试使用:"
                echo "       - macOS/Linux: 使用 host.docker.internal"
                echo "       - Linux (旧版本): 使用 172.17.0.1 或网关 IP"
                echo ""
                echo "    3. 检查主机防火墙是否允许端口 $PORT"
            else
                echo "    1. 检查 $HOST 是否可达"
                echo "    2. 检查端口 $PORT 是否开放"
                echo "    3. 检查防火墙设置"
            fi
        fi
        
        # 测试 HTTP API
        log_info "  测试 HTTP API 连接..."
        if docker exec WeKnora-app sh -c "timeout 5 curl -s $OLLAMA_URL/api/tags > /dev/null 2>&1" 2>/dev/null; then
            log_success "  HTTP API 连接成功"
            
            # 获取版本信息
            VERSION=$(docker exec WeKnora-app sh -c "curl -s $OLLAMA_URL/api/version 2>/dev/null" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "")
            if [ -n "$VERSION" ]; then
                log_info "  Ollama 版本: $VERSION"
            fi
        else
            log_error "  HTTP API 连接失败"
            log_warning "  请检查:"
            echo "    1. Ollama 服务是否在 $OLLAMA_URL 运行"
            echo "    2. 网络连接是否正常"
            echo "    3. 防火墙规则是否允许连接"
        fi
    else
        log_warning "WeKnora-app 容器未运行"
        log_info "  启动容器: docker-compose up -d app"
    fi
else
    log_warning "Docker 未运行或未安装"
fi

echo ""

# 检查环境变量
log_info "3. 检查环境变量配置..."

if [ -f ".env" ]; then
    if grep -q "OLLAMA_BASE_URL" .env; then
        OLLAMA_ENV=$(grep "OLLAMA_BASE_URL" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        if [ -n "$OLLAMA_ENV" ]; then
            log_success "  .env 文件中已配置 OLLAMA_BASE_URL=$OLLAMA_ENV"
        else
            log_warning "  .env 文件中 OLLAMA_BASE_URL 为空"
        fi
    else
        log_warning "  .env 文件中未找到 OLLAMA_BASE_URL"
        log_info "  建议添加: OLLAMA_BASE_URL=http://host.docker.internal:11434"
    fi
else
    log_warning "  .env 文件不存在"
fi

echo ""

# 提供解决方案
printf "%b\n" "${GREEN}========================================${NC}"
log_info "诊断完成！"
echo ""
log_info "常见问题解决方案:"
echo ""
echo "1. 如果本地 Ollama 未运行:"
echo "   ollama serve"
echo ""
echo "2. 如果容器无法连接到 host.docker.internal:"
echo "   确保 docker-compose.yml 中包含:"
echo "   extra_hosts:"
echo "     - \"host.docker.internal:host-gateway\""
echo ""
echo "3. 如果使用 Linux 且 host.docker.internal 不工作:"
echo "   尝试使用网关 IP 或 172.17.0.1:"
echo "   OLLAMA_BASE_URL=http://172.17.0.1:11434"
echo ""
echo "4. 如果 Ollama 运行在不同的端口:"
echo "   更新 .env 文件中的 OLLAMA_BASE_URL"
echo ""
echo "5. 重启容器以应用新的环境变量:"
echo "   docker-compose restart app"
echo ""
printf "%b\n" "${GREEN}========================================${NC}"
echo ""

