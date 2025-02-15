#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root.${NC}"
    exit 1
fi

# Function to display the logo and system information
function show_header() {
    print_logo
    echo -e "\n${BLUE}==========================================${NC}"
    echo -e "${CYAN}   Network Optimizer Script V0.7${NC}"
    echo -e "${BLUE}==========================================${NC}"

    echo -e "${GREEN}Hostname       : $(hostname)${NC}"
    
    # Get OS description using lsb_release; fallback to /etc/os-release if needed
    os_info=$(lsb_release -d 2>/dev/null | cut -f2)
    if [ -z "$os_info" ]; then
        os_info=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    fi
    echo -e "${GREEN}OS             : $os_info${NC}"
    
    echo -e "${GREEN}Kernel Version : $(uname -r)${NC}"
    echo -e "${GREEN}Uptime         : $(uptime -p)${NC}"
    echo -e "${GREEN}IP Address     : $(hostname -I | awk '{print $1}')${NC}"
    
    # Get CPU model information
    cpu_model=$(grep -m1 'model name' /proc/cpuinfo | cut -d ':' -f2 | xargs)
    echo -e "${GREEN}CPU            : $cpu_model${NC}"
    
    echo -e "${GREEN}Architecture   : $(uname -m)${NC}"
    
    # Display memory usage in a human-readable format
    mem_usage=$(free -h | awk '/^Mem:/{print $3 " / " $2}')
    echo -e "${GREEN}Memory Usage   : $mem_usage${NC}"
    
    # Extract load average from uptime output and trim leading space
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')
    echo -e "${GREEN}Load Average   : $load_avg${NC}"
    
    echo -e "${BLUE}==========================================${NC}\n"
}


# Function to print the DevElf logo
print_logo() {
    echo -e "\n${CYAN}"
    echo " ______   _______           _______  _        _______ "
    echo "(  __  \ (  ____ \|\     /|(  ____ \( \      (  ____ \\"
    echo "| (  \  )| (    \/| )   ( || (    \/| (      | (    \/"
    echo "| |   ) || (__    | |   | || (__    | |      | (__    "
    echo "| |   | ||  __)   ( (   ) )|  __)   | |      |  __)   "
    echo "| |   ) || (       \ \_/ / | (      | |      | (      "
    echo "| (__/  )| (____/\  \   /  | (____/\| (____/\| )      "
    echo "(______/ (_______/   \_/   (_______/(_______/|/       "
    echo -e "${NC}"
    echo -e "\n${BLUE}Developed by DevElf.${NC}"
    echo -e "${CYAN}GitHub: https://github.com/develfishere${NC}\n"
}


# Fix /etc/hosts file
function fix_etc_hosts() { 
    local host_path=${1:-/etc/hosts}

    echo -e "${YELLOW}Starting to fix the hosts file...${NC}"

    # Backup current hosts file
    if cp "$host_path" "${host_path}.bak"; then
        echo -e "${YELLOW}Hosts file backed up as ${host_path}.bak${NC}"
    else
        echo -e "${RED}Backup failed. Cannot proceed.${NC}"
        return 1
    fi

    # Check if hostname is in hosts file; add if missing
    if ! grep -q "$(hostname)" "$host_path"; then
        if echo "127.0.1.1 $(hostname)" | sudo tee -a "$host_path" > /dev/null; then
            echo -e "${GREEN}Hostname entry added to hosts file.${NC}"
        else
            echo -e "${RED}Failed to add hostname entry.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Hostname entry already present. No changes needed.${NC}"
    fi
}

# Temporarily fix DNS by modifying /etc/resolv.conf
function fix_dns() {
    local dns_path=${1:-/etc/resolv.conf}

    echo -e "${YELLOW}Starting to update DNS configuration...${NC}"

    # Backup current DNS settings
    if cp "$dns_path" "${dns_path}.bak"; then
        echo -e "${YELLOW}DNS configuration backed up as ${dns_path}.bak${NC}"
    else
        echo -e "${RED}Backup failed. Cannot proceed.${NC}"
        return 1
    fi

    # Clear current nameservers and add temporary ones
    if sed -i '/nameserver/d' "$dns_path" && {
        echo "nameserver 1.1.1.2" | sudo tee -a "$dns_path" > /dev/null
        echo "nameserver 1.0.0.2" | sudo tee -a "$dns_path" > /dev/null
    }; then
        echo -e "${GREEN}Temporary DNS servers set successfully.${NC}"
    else
        echo -e "${RED}Failed to update DNS configuration.${NC}"
        return 1
    fi
}


force_ipv4_apt() {
    local config_file="/etc/apt/apt.conf.d/99force-ipv4"
    local config_line='Acquire::ForceIPv4 "true";'

    # Check if the configuration already exists
    if [[ -f "$config_file" && "$(grep -Fx "$config_line" "$config_file")" == "$config_line" ]]; then
        echo "Configuration is already set in $config_file."
        return 0
    fi

    # Add the configuration
    echo "$config_line" | sudo tee "$config_file" >/dev/null
    if [[ $? -eq 0 ]]; then
        echo "Configuration set successfully in $config_file."
    else
        echo "Failed to set configuration."
        return 1
    fi
}


# Function to fully update and upgrade the server
function full_update_upgrade() {
    echo -e "\n${YELLOW}Updating package list...${NC}"
    sudo apt -o Acquire::ForceIPv4=true update

    echo -e "\n${YELLOW}Upgrading installed packages...${NC}"
    sudo apt -o Acquire::ForceIPv4=true upgrade -y

    echo -e "\n${YELLOW}Performing full distribution upgrade...${NC}"
    sudo apt -o Acquire::ForceIPv4=true dist-upgrade -y

    echo -e "\n${YELLOW}Removing unnecessary packages...${NC}"
    sudo apt -o Acquire::ForceIPv4=true autoremove -y

    echo -e "\n${YELLOW}Cleaning up any cached packages...${NC}"
    sudo apt -o Acquire::ForceIPv4=true autoclean

    echo -e "\n${GREEN}Server update and upgrade complete.${NC}\n"
}


# Function to gather system information
function gather_system_info() {
    CPU_CORES=$(nproc)
    TOTAL_RAM=$(free -m | awk '/Mem:/ { print $2 }')
    echo -e "\n${GREEN}Detected CPU cores: $CPU_CORES${NC}"
    echo -e "${GREEN}Detected Total RAM: ${TOTAL_RAM}MB${NC}\n"
}
# Function to intelligently set buffer sizes and sysctl settings
function intelligent_settings() {
    echo -e "\n${YELLOW}Starting intelligent network optimizations...${NC}\n"

    echo -e "\n${YELLOW}Fixing /etc/hosts file...${NC}\n"
    fix_etc_hosts
    sleep 2

    echo -e "\n${YELLOW}Waiting for DNS to propagate...${NC}\n"
    fix_dns
    sleep 2

    echo -e "\n${YELLOW}Forcing IPv4 for APT...${NC}\n"
    force_ipv4_apt
    sleep 2

    echo -e "\n${YELLOW}Performing full system update and upgrade...${NC}\n"
    full_update_upgrade
    sleep 2

    echo -e "\n${YELLOW}Gathering system information...${NC}\n"
    gather_system_info
    sleep 2

    echo -e "\n$(date): Starting sysctl configuration..."
    sleep 2

    echo -e "\n${YELLOW}Backing up current sysctl.conf...${NC}\n"
    if [ -f /etc/sysctl.conf.bak ]; then
        echo -e "\n${YELLOW}Backup already exists. Skipping backup...${NC}\n"
    else
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
    fi

    ############################################################################
    # Dynamic tuning based on hardware resources with values adjusted for 
    # serving clients with low internet speed and lossy networks.
    #
    # These values have been set more conservatively while still optimizing for
    # high TCP connection counts and efficiency.
    ############################################################################
    if [ "$TOTAL_RAM" -lt 2000000 ] && [ "$CPU_CORES" -le 2 ]; then
        rmem_max=2097152         # 2 MB
        wmem_max=2097152         # 2 MB
        netdev_max_backlog=100000
        queuing_disc="fq_codel"
        tcp_mem="2097152 4194304 8388608"
    elif [ "$TOTAL_RAM" -lt 4000000 ] && [ "$CPU_CORES" -le 4 ]; then
        rmem_max=4194304         # 4 MB
        wmem_max=4194304         # 4 MB
        netdev_max_backlog=200000
        queuing_disc="fq_codel"
        tcp_mem="4194304 8388608 16777216"
    else
        rmem_max=8388608         # 8 MB
        wmem_max=8388608         # 8 MB
        netdev_max_backlog=300000
        queuing_disc="cake"
        tcp_mem="8388608 16777216 33554432"
    fi

    tcp_rmem="4096 87380 $rmem_max"
    tcp_wmem="4096 65536 $wmem_max"
    tcp_congestion_control="bbr"
    tcp_retries2=8

    echo "$(date): Set rmem_max=$rmem_max, wmem_max=$wmem_max, netdev_max_backlog=$netdev_max_backlog. Queuing discipline: $queuing_disc"
    echo "$(date): Set tcp_rmem=$tcp_rmem, tcp_wmem=$tcp_wmem."
    echo "$(date): Using TCP congestion control: $tcp_congestion_control, tcp_retries2: $tcp_retries2."

    ############################################################################
    # Overwrite /etc/sysctl.conf with the new configuration including
    # additional parameters for high TCP connection handling and efficiency.
    ############################################################################
    cat <<EOL > /etc/sysctl.conf

## File system settings
fs.file-max = 67108864

## Network core settings
net.core.default_qdisc = $queuing_disc
net.core.netdev_max_backlog = $netdev_max_backlog
net.core.optmem_max = 65536
net.core.somaxconn = 65536
net.core.rmem_max = $rmem_max
net.core.rmem_default = 524288    # 512 KB tuned for low-speed links
net.core.wmem_max = $wmem_max
net.core.wmem_default = 524288    # 512 KB tuned for low-speed links

## TCP settings
net.ipv4.tcp_rmem = $tcp_rmem
net.ipv4.tcp_wmem = $tcp_wmem
net.ipv4.tcp_congestion_control = $tcp_congestion_control
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 7
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_max_orphans = 1048576
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_mem = $tcp_mem
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_retries2 = $tcp_retries2
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_syncookies = 1

# Additional TCP tuning for high connection loads and efficiency:
net.ipv4.tcp_tw_reuse = 1                   # Reuse TIME_WAIT sockets for new connections
net.ipv4.tcp_fastopen = 3                   # Enable TCP Fast Open on both client and server sides
net.ipv4.ip_local_port_range = 1024 65535   # Expand ephemeral port range
net.ipv4.tcp_rfc1337 = 1                    # Improve behavior for port exhaustion

## UDP settings
net.ipv4.udp_mem = 65536 131072 262144

## IPv6 settings
#net.ipv6.conf.all.disable_ipv6 = 0
#net.ipv6.conf.default.disable_ipv6 = 0
#net.ipv6.conf.lo.disable_ipv6 = 0

## UNIX domain sockets
net.unix.max_dgram_qlen = 256

## Virtual memory (VM) settings
vm.min_free_kbytes = 131072
vm.swappiness = 10
vm.vfs_cache_pressure = 250

## Network configuration
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.neigh.default.gc_thresh1 = 512
net.ipv4.neigh.default.gc_thresh2 = 2048
net.ipv4.neigh.default.gc_thresh3 = 16384
net.ipv4.neigh.default.gc_stale_time = 60
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

kernel.panic = 1
vm.dirty_ratio = 10
EOL

    echo "$(date): Network optimizations written to /etc/sysctl.conf."

    sysctl -p > /dev/null 2>&1 && echo -e "\n${GREEN}Network settings applied successfully!${NC}\n"

    # Log the final dynamic values for reference
    echo -e "\n${YELLOW}Logging dynamic values...${NC}\n\n"
    echo "$(date): Final settings applied."
    echo "Total RAM: $TOTAL_RAM MB, CPU Cores: $CPU_CORES"
    echo "rmem_max: $rmem_max, wmem_max: $wmem_max, netdev_max_backlog: $netdev_max_backlog"
    echo "tcp_rmem: $tcp_rmem, tcp_wmem: $tcp_wmem"
    echo "TCP Congestion Control: $tcp_congestion_control, tcp_retries2: $tcp_retries2"
    echo "Queuing discipline: $queuing_disc"
    echo ""
    prompt_reboot
}


# Function to restore the original sysctl settings
function restore_original() {
    if [ -f /etc/sysctl.conf.bak ]; then
        echo -e "\n${YELLOW}Restoring original network settings from backup...${NC}\n"
        cp /etc/sysctl.conf.bak /etc/sysctl.conf
        rm /etc/sysctl.conf.bak
        
        sysctl -p > /dev/null 2>&1 && echo -e "\n${GREEN}Network settings restored successfully!${NC}\n"

        prompt_reboot
    else
        echo -e "\n${RED}No backup found. Please manually restore sysctl.conf.${NC}\n"

        # Prompt user to press any key to continue
        read -n 1 -s -r -p "Press any key to continue..."
        echo # for a new line
    fi
}

find_best_mtu() {
    local server_ip=8.8.8.8   # Google DNS server
    local low=1200          # Lower bound MTU
    local high=1500         # Standard MTU
    local optimal=0

    echo "[MTU LOG] Starting MTU search for server: $server_ip"

    # Check if the server is reachable
    if ! ping -c 1 -W 1 "$server_ip" &>/dev/null; then
        echo "[MTU LOG] ERROR: Server $server_ip unreachable."
        return 1
    fi

    # Verify that the minimum MTU works
    if ! ping -M do -s $((low - 28)) -c 1 "$server_ip" &>/dev/null; then
        echo "[MTU LOG] ERROR: Minimum MTU of $low bytes not viable."
        return 1
    fi

    optimal=$low
    # Use binary search to find the highest MTU that works
    while [ $low -le $high ]; do
        local mid=$(( (low + high) / 2 ))
        if ping -M do -s $((mid - 28)) -c 1 "$server_ip" &>/dev/null; then
            optimal=$mid
            low=$(( mid + 1 ))
        else
            high=$(( mid - 1 ))
        fi
    done

    echo "[MTU LOG] Optimal MTU found: ${optimal} bytes"

    # Ask user if they want to set the current MTU to the found value
    read -p "[MTU LOG] Do you want to set the optimal MTU on a network interface? (Y/n): " set_mtu_choice
    if [[ -z "$set_mtu_choice" || "$set_mtu_choice" =~ ^[Yy] ]]; then
        read -p "[MTU LOG] Enter the network interface name: " iface
        if [[ -z "$iface" ]]; then
            echo "[MTU LOG] ERROR: No interface provided."
            return 1
        fi

        # Attempt to set the MTU using the ip command
        if ip link set dev "$iface" mtu "$optimal"; then
            echo "[MTU LOG] MTU set to ${optimal} bytes on interface $iface"
        else
            echo "[MTU LOG] ERROR: Failed to set MTU on interface $iface"
            return 1
        fi
    else
        echo "[MTU LOG] MTU setting skipped by user."
    fi

    return 0
}

# Function to prompt the user for a reboot
function prompt_reboot() {
    read -p "It is recommended to reboot for changes to take effect. Reboot now? (y/[default=n]): " reboot_choice

    if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
        echo -e "\n${YELLOW}Rebooting now...${NC}\n"
        reboot
    else
        echo -e "\n${YELLOW}Reboot skipped. Please remember to reboot manually for all changes to take effect.${NC}\n"
    fi

    # Prompt user to press any key to continue
    read -n 1 -s -r -p "Press any key to continue..."
    echo # for a new line
}

# Function to display the menu
function show_menu() {
    while true; do
        clear
        show_header
        echo -e "${CYAN}Menu:${NC}"
        echo -e "${GREEN}1. Apply BBR and Intelligent Optimizations${NC}"
        echo -e "${GREEN}2. Find Best MTU for Server${NC}"
        echo -e "${GREEN}3. Restore Original Settings${NC}"
        echo -e "${GREEN}0. Exit${NC}"
        echo
        read -p "Enter your choice: " choice

        case $choice in
            1) intelligent_settings ;;
            2) find_best_mtu ;;
            3) restore_original ;;
            0) echo -e "\n${YELLOW}Exiting...${NC}" ; exit 0 ;;
            *) echo -e "\n${RED}Invalid option. Please try again.${NC}\n" ; sleep 2 ;;
        esac
    done
}

# Run the menu
show_menu