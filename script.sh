#!/bin/bash

# 🚀 Enhanced AI Control Menu - Always-On Dashboard Edition
# Configuration
OLLAMA_PORT=11434
WEBUI_PORT=3210
WEBUI_CONTAINER_NAME="open-webui"
LOG_FILE="/tmp/ai_control_menu.log"
REFRESH_INTERVAL=2

# 🎨 Enhanced Color Palette with Gradients and Effects
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BRIGHT_RED='\033[1;91m'
BRIGHT_GREEN='\033[1;92m'
BRIGHT_YELLOW='\033[1;93m'
BRIGHT_BLUE='\033[1;94m'
BRIGHT_PURPLE='\033[1;95m'
BRIGHT_CYAN='\033[1;96m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
NC='\033[0m'

# 🎭 Visual Elements
SPARKLE="✨"
ROBOT="🤖"
GEAR="⚙️"
ROCKET="🚀"
FIRE="🔥"
LIGHTNING="⚡"
DIAMOND="💎"
STAR="⭐"
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ARROW="➤"
BULLET="●"
CLOCK="🕐"

# 🎪 Animation frames for loading
LOADING_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
PULSE_FRAMES=('◐' '◓' '◑' '◒')

# Global variables for dashboard state
LAST_ACTION=""
ACTION_STATUS=""
FRAME_COUNTER=0

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Terminal control functions
hide_cursor() {
    tput civis 2>/dev/null || printf '\033[?25l'
}

show_cursor() {
    tput cnorm 2>/dev/null || printf '\033[?25h'
}

move_cursor() {
    tput cup "$1" "$2" 2>/dev/null || printf '\033[%d;%dH' "$((${1}+1))" "$((${2}+1))"
}

clear_screen() {
    tput clear 2>/dev/null || printf '\033[2J\033[H'
}

goto_top() {
    tput home 2>/dev/null || printf '\033[H'
}

# Enhanced status check functions
check_ollama_status() {
    if pgrep -x "ollama" > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_webui_status() {
    if docker ps --format '{{.Names}}' | grep -q "^${WEBUI_CONTAINER_NAME}$"; then
        return 0
    else
        return 1
    fi
}

check_docker_running() {
    if docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

get_system_metrics() {
    # CPU Usage - handle decimal values properly
    if command -v top >/dev/null 2>&1; then
        CPU_USAGE=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | tr -d '%' 2>/dev/null || echo "0")
        # Ensure CPU_USAGE is a valid number
        if ! [[ "$CPU_USAGE" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            CPU_USAGE="0"
        fi
    else
        CPU_USAGE="0"
    fi
    
    # Memory Usage
    if command -v free >/dev/null 2>&1; then
        MEM_USED=$(free -h | awk 'NR==2{print $3}')
        MEM_TOTAL=$(free -h | awk 'NR==2{print $2}')
        MEM_PERCENT=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}' 2>/dev/null || echo "0")
    else
        MEM_USED="N/A"
        MEM_TOTAL="N/A"
        MEM_PERCENT="0"
    fi
    
    # Disk Usage
    if command -v df >/dev/null 2>&1; then
        DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | tr -d '%' 2>/dev/null || echo "0")
        DISK_USED=$(df -h / | awk 'NR==2{print $3}')
        DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
        # Ensure DISK_USAGE is a valid integer
        if ! [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
            DISK_USAGE="0"
        fi
    else
        DISK_USAGE="0"
        DISK_USED="N/A"
        DISK_TOTAL="N/A"
    fi
}

draw_progress_bar() {
    local percentage=$1
    local width=20
    local color=$2
    
    if [[ "$percentage" == "N/A" ]] || [[ -z "$percentage" ]]; then
        echo -e "${GRAY}[$(printf '%*s' $width | tr ' ' '-')]${NC}"
        return
    fi
    
    # Convert decimal to integer for bash arithmetic
    local int_percentage=$(echo "$percentage" | cut -d'.' -f1)
    if [[ -z "$int_percentage" ]] || [[ "$int_percentage" -lt 0 ]] || [[ "$int_percentage" -gt 100 ]]; then
        int_percentage=0
    fi
    
    local filled=$((int_percentage * width / 100))
    local empty=$((width - filled))
    
    echo -ne "${color}["
    printf '%*s' $filled | tr ' ' '█'
    printf '%*s' $empty | tr ' ' '░'
    echo -e "]${NC}"
}

# 🌟 Always-on dashboard display
show_dashboard() {
    # Only clear screen on first run or after popups
    if [[ "$FIRST_RUN" == "1" ]] || [[ "$FORCE_CLEAR" == "1" ]]; then
        clear_screen
        FIRST_RUN=0
        FORCE_CLEAR=0
    else
        goto_top
    fi
    
    hide_cursor
    
    # Get current metrics
    get_system_metrics
    
    # Terminal size detection
    COLS=$(tput cols 2>/dev/null || echo 80)
    LINES=$(tput lines 2>/dev/null || echo 24)
    
    # Header with animation
    local spinner_char=${LOADING_FRAMES[$((FRAME_COUNTER % ${#LOADING_FRAMES[@]}))]}
    ((FRAME_COUNTER++))
    
    echo -e "${BRIGHT_CYAN}╔════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║ ${BRIGHT_WHITE}${ROBOT} ${BOLD}AI CONTROL CENTER${NC}${BRIGHT_CYAN} - Live Dashboard ${spinner_char} ${BRIGHT_YELLOW}Auto-Refresh: ${REFRESH_INTERVAL}s${NC}${BRIGHT_CYAN} ║"
    echo -e "║ ${BRIGHT_PURPLE}${DIM}Real-time monitoring • Status updates • Resource tracking${NC}${BRIGHT_CYAN}        ║"
    echo -e "╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Two-column layout for services
    echo -e "${BRIGHT_WHITE}${UNDERLINE}${GEAR} SERVICE STATUS${NC}                    ${BRIGHT_WHITE}${UNDERLINE}${LIGHTNING} SYSTEM RESOURCES${NC}"
    echo ""
    
    # Service status section
    printf "%-45s" ""
    echo -e "${BRIGHT_CYAN}CPU Usage: ${BRIGHT_WHITE}${CPU_USAGE}%${NC}"
    
    # Ollama Status
    if check_ollama_status; then
        local pid=$(pgrep -x ollama)
        printf "${BRIGHT_GREEN}${ARROW} Ollama Service    ${CHECK} ${BOLD}ONLINE${NC}%-9s" ""
        draw_progress_bar "$(echo "$CPU_USAGE" | cut -d'.' -f1)" "$BRIGHT_GREEN"
        
        printf "   ${BRIGHT_CYAN}${BULLET} PID: ${pid} | Port: ${OLLAMA_PORT}${NC}%-17s" ""
        echo -e "${BRIGHT_CYAN}Memory: ${BRIGHT_WHITE}${MEM_USED}/${MEM_TOTAL} (${MEM_PERCENT}%)${NC}"
        
        printf "   ${BRIGHT_GREEN}${BULLET} Status: Ready & Listening${NC}%-21s" ""
        draw_progress_bar "$MEM_PERCENT" "$BRIGHT_BLUE"
    else
        printf "${BRIGHT_RED}${ARROW} Ollama Service    ${CROSS} ${BOLD}OFFLINE${NC}%-8s" ""
        draw_progress_bar "$(echo "$CPU_USAGE" | cut -d'.' -f1)" "$BRIGHT_GREEN"
        
        printf "   ${GRAY}${BULLET} Port: ${OLLAMA_PORT} | Status: Stopped${NC}%-18s" ""
        echo -e "${BRIGHT_CYAN}Memory: ${BRIGHT_WHITE}${MEM_USED}/${MEM_TOTAL} (${MEM_PERCENT}%)${NC}"
        
        printf "   ${BRIGHT_RED}${BULLET} Action: Start service (Option 1)${NC}%-11s" ""
        draw_progress_bar "$MEM_PERCENT" "$BRIGHT_BLUE"
    fi
    
    echo ""
    
    # WebUI Status
    printf "%-45s" ""
    echo -e "${BRIGHT_CYAN}Disk (/): ${BRIGHT_WHITE}${DISK_USED}/${DISK_TOTAL} (${DISK_USAGE}%)${NC}"
    
    if check_webui_status; then
        printf "${BRIGHT_GREEN}${ARROW} Open WebUI       ${CHECK} ${BOLD}ONLINE${NC}%-9s" ""
        draw_progress_bar "$DISK_USAGE" "$BRIGHT_PURPLE"
        
        printf "   ${BRIGHT_CYAN}${BULLET} Port: ${WEBUI_PORT} | Container: Active${NC}%-15s" ""
        echo -e "${BRIGHT_CYAN}Uptime: ${BRIGHT_WHITE}$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}' 2>/dev/null || echo 'N/A')${NC}"
        
        echo -e "   ${BRIGHT_GREEN}${BULLET} URL: http://localhost:${WEBUI_PORT}${NC}"
    else
        printf "${BRIGHT_RED}${ARROW} Open WebUI       ${CROSS} ${BOLD}OFFLINE${NC}%-8s" ""
        draw_progress_bar "$DISK_USAGE" "$BRIGHT_PURPLE"
        
        printf "   ${GRAY}${BULLET} Port: ${WEBUI_PORT} | Container: Stopped${NC}%-14s" ""
        echo -e "${BRIGHT_CYAN}Uptime: ${BRIGHT_WHITE}$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}' 2>/dev/null || echo 'N/A')${NC}"
        
        echo -e "   ${BRIGHT_RED}${BULLET} Action: Start service (Option 1)${NC}"
    fi
    
    echo ""
    
    # Docker Status
    if check_docker_running; then
        echo -e "${BRIGHT_GREEN}${ARROW} Docker Engine    ${CHECK} ${BOLD}RUNNING${NC}"
        echo -e "   ${BRIGHT_CYAN}${BULLET} Version: $(docker --version | cut -d' ' -f3 | tr -d ',' 2>/dev/null)${NC}"
    else
        echo -e "${BRIGHT_RED}${ARROW} Docker Engine    ${CROSS} ${BOLD}STOPPED${NC}"
        echo -e "   ${BRIGHT_RED}${BULLET} Required for Open WebUI${NC}"
    fi
    
    echo ""
    echo ""
    
    # Process information section
    echo -e "${BRIGHT_WHITE}${UNDERLINE}${INFO} PROCESS DETAILS${NC}"
    echo ""
    
    # Ollama process info
    if check_ollama_status; then
        local ollama_pid=$(pgrep -x ollama)
        local ollama_cpu=$(ps -o %cpu -p "$ollama_pid" --no-headers 2>/dev/null | xargs || echo "0")
        local ollama_mem=$(ps -o %mem -p "$ollama_pid" --no-headers 2>/dev/null | xargs || echo "0")
        echo -e "${BRIGHT_GREEN}${ROCKET} Ollama Process: ${BRIGHT_WHITE}PID: ${ollama_pid} | CPU: ${ollama_cpu}% | Memory: ${ollama_mem}%${NC}"
    else
        echo -e "${GRAY}${ROCKET} Ollama Process: Not running${NC}"
    fi
    
    # Docker container info
    if check_webui_status; then
        local container_stats=$(docker stats --no-stream --format "CPU: {{.CPUPerc}} | Memory: {{.MemUsage}}" "$WEBUI_CONTAINER_NAME" 2>/dev/null || echo "Not available")
        echo -e "${BRIGHT_GREEN}${DIAMOND} Docker Container: ${BRIGHT_WHITE}${container_stats}${NC}"
    else
        echo -e "${GRAY}${DIAMOND} Docker Container: Not running${NC}"
    fi
    
    echo ""
    
    # Action status area
    if [[ -n "$LAST_ACTION" ]]; then
        echo -e "${BRIGHT_YELLOW}${GEAR} Last Action: ${BOLD}${LAST_ACTION}${NC}"
        echo -e "${ACTION_STATUS}"
        echo ""
    fi
    
    # Menu at bottom
    echo -e "${BRIGHT_WHITE}${UNDERLINE}${STAR} QUICK ACTIONS${NC}"
    echo ""
    echo -e "${BRIGHT_GREEN}1${NC}─Start  ${BRIGHT_YELLOW}2${NC}─Stop  ${BRIGHT_BLUE}3${NC}─Restart  ${BRIGHT_PURPLE}4${NC}─Logs  ${BRIGHT_CYAN}5${NC}─Health  ${BRIGHT_RED}6${NC}─Exit"
    echo ""
    
    # Status line with timestamp
    local current_time=$(date '+%H:%M:%S')
    echo -e "${BRIGHT_CYAN}${CLOCK} ${current_time} | Press any key for action menu | Auto-refresh in ${REFRESH_INTERVAL}s${NC}"
    
    # Clear any remaining lines to prevent artifacts
    local current_line=30
    local max_lines=$(tput lines 2>/dev/null || echo 40)
    while [[ $current_line -lt $max_lines ]]; do
        tput el 2>/dev/null || printf '\033[K'
        echo ""
        ((current_line++))
    done
}

# Service management functions with status updates
start_services_background() {
    LAST_ACTION="Starting Services"
    ACTION_STATUS="${BRIGHT_BLUE}${ROCKET} Initializing Ollama and Open WebUI...${NC}"
    
    # Start Ollama
    if ! check_ollama_status; then
        ACTION_STATUS="${BRIGHT_BLUE}${ROCKET} Starting Ollama service...${NC}"
        ollama serve > /dev/null 2>&1 &
        
        # Wait for startup
        local count=0
        while [ $count -lt 15 ] && ! check_ollama_status; do
            sleep 1
            ((count++))
            ACTION_STATUS="${BRIGHT_BLUE}${ROCKET} Starting Ollama... (${count}/15)${NC}"
        done
    fi
    
    # Start WebUI
    if check_docker_running && ! check_webui_status; then
        ACTION_STATUS="${BRIGHT_BLUE}${DIAMOND} Starting Open WebUI container...${NC}"
        docker rm "$WEBUI_CONTAINER_NAME" >/dev/null 2>&1
        
        if docker run -d \
            --name "$WEBUI_CONTAINER_NAME" \
            -p "$WEBUI_PORT:8080" \
            -v open-webui:/app/backend/data \
            --add-host=host.docker.internal:host-gateway \
            --restart unless-stopped \
            ghcr.io/open-webui/open-webui:main >/dev/null 2>&1; then
            ACTION_STATUS="${BRIGHT_GREEN}${CHECK} Services started successfully!${NC}"
        else
            ACTION_STATUS="${BRIGHT_RED}${CROSS} Failed to start Open WebUI${NC}"
        fi
    else
        ACTION_STATUS="${BRIGHT_GREEN}${CHECK} Services are now running!${NC}"
    fi
    
    log_message "Services started via dashboard"
}

stop_services_background() {
    LAST_ACTION="Stopping Services"
    ACTION_STATUS="${BRIGHT_YELLOW}${GEAR} Shutting down services...${NC}"
    
    # Stop WebUI
    if check_webui_status; then
        ACTION_STATUS="${BRIGHT_YELLOW}${GEAR} Stopping Open WebUI...${NC}"
        docker stop "$WEBUI_CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$WEBUI_CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Stop Ollama
    if check_ollama_status; then
        ACTION_STATUS="${BRIGHT_YELLOW}${GEAR} Stopping Ollama...${NC}"
        pkill -x ollama
    fi
    
    ACTION_STATUS="${BRIGHT_GREEN}${CHECK} All services stopped successfully!${NC}"
    log_message "Services stopped via dashboard"
}

restart_services_background() {
    LAST_ACTION="Restarting Services"
    ACTION_STATUS="${BRIGHT_YELLOW}${GEAR} Restarting all services...${NC}"
    
    stop_services_background
    sleep 2
    start_services_background
    
    ACTION_STATUS="${BRIGHT_GREEN}${CHECK} Services restarted successfully!${NC}"
    log_message "Services restarted via dashboard"
}

show_logs_popup() {
    FORCE_CLEAR=1
    clear_screen
    echo -e "${BRIGHT_PURPLE}╔════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║ ${BRIGHT_WHITE}${BOLD}${INFO} SYSTEM LOGS${NC}${BRIGHT_PURPLE} - Press any key to return to dashboard        ║"
    echo -e "╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BRIGHT_WHITE}Recent Activity (Last 20 entries):${NC}"
        echo
        tail -20 "$LOG_FILE" | while read line; do
            echo -e "   ${BRIGHT_CYAN}${BULLET}${NC} ${DIM}${line}${NC}"
        done
    else
        echo -e "${BRIGHT_YELLOW}   ${WARNING} No log entries found${NC}"
    fi
    
    echo
    echo -e "${BRIGHT_PURPLE}Log file: ${BOLD}${LOG_FILE}${NC}"
    echo
    echo -e "${BRIGHT_CYAN}Press any key to return to dashboard...${NC}"
    read -n 1
    FORCE_CLEAR=1
}

health_check_popup() {
    FORCE_CLEAR=1
    clear_screen
    echo -e "${BRIGHT_WHITE}╔════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║ ${BRIGHT_WHITE}${BOLD}${GEAR} HEALTH CHECK${NC} - Press any key to return to dashboard           ║"
    echo -e "╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${BRIGHT_BLUE}${INFO} ${BOLD}SYSTEM INFORMATION${NC}"
    echo -e "   OS: ${BRIGHT_CYAN}$(uname -s) $(uname -r)${NC}"
    echo -e "   Architecture: ${BRIGHT_CYAN}$(uname -m)${NC}"
    echo
    
    echo -e "${BRIGHT_BLUE}${INFO} ${BOLD}SERVICE STATUS${NC}"
    check_ollama_status && echo -e "   Ollama: ${BRIGHT_GREEN}${CHECK} Running${NC}" || echo -e "   Ollama: ${BRIGHT_RED}${CROSS} Stopped${NC}"
    check_webui_status && echo -e "   WebUI: ${BRIGHT_GREEN}${CHECK} Running${NC}" || echo -e "   WebUI: ${BRIGHT_RED}${CROSS} Stopped${NC}"
    check_docker_running && echo -e "   Docker: ${BRIGHT_GREEN}${CHECK} Running${NC}" || echo -e "   Docker: ${BRIGHT_RED}${CROSS} Stopped${NC}"
    echo
    
    echo -e "${BRIGHT_BLUE}${INFO} ${BOLD}PORT STATUS${NC}"
    lsof -i:$OLLAMA_PORT >/dev/null 2>&1 && echo -e "   Port $OLLAMA_PORT: ${BRIGHT_GREEN}${CHECK} In Use${NC}" || echo -e "   Port $OLLAMA_PORT: ${BRIGHT_YELLOW}${WARNING} Available${NC}"
    lsof -i:$WEBUI_PORT >/dev/null 2>&1 && echo -e "   Port $WEBUI_PORT: ${BRIGHT_GREEN}${CHECK} In Use${NC}" || echo -e "   Port $WEBUI_PORT: ${BRIGHT_YELLOW}${WARNING} Available${NC}"
    echo
    
    echo -e "${BRIGHT_GREEN}${CHECK} ${BOLD}Health check completed${NC}"
    echo
    echo -e "${BRIGHT_CYAN}Press any key to return to dashboard...${NC}"
    read -n 1
    FORCE_CLEAR=1
}

# Main dashboard loop
main() {
    # Setup
    log_message "AI Control Center Dashboard started"
    
    # Initialize variables
    FIRST_RUN=1
    FORCE_CLEAR=0
    
    # Setup terminal
    hide_cursor
    
    # Trap to cleanup on exit
    trap 'show_cursor; clear; echo "Dashboard closed"; exit 0' EXIT INT TERM
    
    while true; do
        show_dashboard
        
        # Non-blocking input check
        if read -t $REFRESH_INTERVAL -n 1 key; then
            case $key in
                1)
                    start_services_background &
                    ;;
                2)
                    stop_services_background &
                    ;;
                3)
                    restart_services_background &
                    ;;
                4)
                    show_logs_popup
                    ;;
                5)
                    health_check_popup
                    ;;
                6)
                    show_cursor
                    clear
                    echo -e "${BRIGHT_GREEN}${SPARKLE} Thank you for using AI Control Center!${NC}"
                    exit 0
                    ;;
                q|Q)
                    show_cursor
                    clear
                    echo -e "${BRIGHT_GREEN}${SPARKLE} Dashboard closed${NC}"
                    exit 0
                    ;;
                *)
                    # Show action menu for any other key
                    FORCE_CLEAR=1
                    clear_screen
                    echo -e "${BRIGHT_CYAN}╔════════════════════════════════════════════════════════════════════════════╗"
                    echo -e "║ ${BRIGHT_WHITE}${BOLD}QUICK ACTION MENU${NC}${BRIGHT_CYAN} - Select an option                              ║"
                    echo -e "╚════════════════════════════════════════════════════════════════════════════╝${NC}"
                    echo
                    echo -e "   ${BRIGHT_GREEN}${BOLD}1${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${GREEN}Start Services${NC}"
                    echo -e "   ${BRIGHT_YELLOW}${BOLD}2${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${YELLOW}Stop Services${NC}"
                    echo -e "   ${BRIGHT_BLUE}${BOLD}3${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${BLUE}Restart Services${NC}"
                    echo -e "   ${BRIGHT_PURPLE}${BOLD}4${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${PURPLE}View Logs${NC}"
                    echo -e "   ${BRIGHT_CYAN}${BOLD}5${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${CYAN}Health Check${NC}"
                    echo -e "   ${BRIGHT_RED}${BOLD}6${NC} ${BRIGHT_WHITE}${ARROW}${NC} ${RED}Exit Dashboard${NC}"
                    echo
                    echo -e "${BRIGHT_WHITE}Any other key returns to dashboard${NC}"
                    echo
                    echo -ne "${BRIGHT_WHITE}${ARROW} Choose: ${NC}"
                    read -n 1 menu_choice
                    
                    case $menu_choice in
                        1) start_services_background & ;;
                        2) stop_services_background & ;;
                        3) restart_services_background & ;;
                        4) show_logs_popup ;;
                        5) health_check_popup ;;
                        6) 
                            show_cursor
                            clear
                            echo -e "${BRIGHT_GREEN}${SPARKLE} Dashboard closed${NC}"
                            exit 0
                            ;;
                    esac
                    FORCE_CLEAR=1
                    ;;
            esac
        fi
        
        # Clear any completed background jobs
        jobs -p | xargs -r kill -0 2>/dev/null || true
    done
}

# 🚀 Initialize the always-on dashboard
main "$@"