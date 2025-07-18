#!/bin/bash

#===============================
#     MAKE IT EASY - ADVANCED
#     Author: Vaibhav Handekar
#===============================

trap "echo -e '\n\e[1;31mAborted by user. Exiting...\e[0m'; exit" SIGINT

#========== CONFIG =============
LOG_DIR="$HOME/make-it-easy-log"
mkdir -p "$LOG_DIR"

#========== COLORS =============
RED="\e[1;31m"
GREEN="\e[1;32m"
CYAN="\e[1;36m"
YELLOW="\e[1;33m"
RESET="\e[0m"
BOLD="\e[1m"

#========== DEP CHECK ==========
function check_dependencies() {
    local deps=("nmap" "figlet" "curl" "whois" "xsltproc" "subjack")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${RED}Missing dependency:${RESET} $dep"
            read -p "Do you want to install $dep? (y/n): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                sudo apt update && sudo apt install "$dep" -y
            else
                echo -e "${RED}Cannot continue without $dep. Exiting...${RESET}"
                exit 1
            fi
        fi
    done
}

#========== HEADER =============
function show_header() {
    clear
    echo -ne "${CYAN}Launching Make It Easy Tool"
    for i in {1..3}; do sleep 0.3; echo -n "."; done
    echo -e "\n"
    figlet -c "MAKE IT EASY" | lolcat 2>/dev/null || figlet -c "MAKE IT EASY"
    
    echo -e "${YELLOW}${BOLD}"
    printf "%*s\n" $(( ( $(tput cols) + 39 ) / 2 )) "[ MAKE IT EASY - ADVANCED TOOL ]"
    echo -e " Author   : Vaibhav Handekar (IG: vaibhavv_19)"
    echo -e " Version  : v2.0 | Updated Banner + Features"
    echo -e "${RESET}${CYAN}----------------------------------------------------------${RESET}\n"
}

#========== VALIDATION =========
function validate_target() {
    if ! [[ "$1" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        echo -e "${RED}Invalid target. Try again.${RESET}"
        return 1
    fi
    return 0
}

#========== LOGGING ============
function timestamp_log() {
    ts=$(date +"%Y-%m-%d_%H-%M-%S")
    echo "$LOG_DIR/scan_${1//[:\/]/_}_$ts"
}

#========== MAIN LOOP ==========
function main_menu() {
    while true; do
        show_header
        echo -e "${GREEN}Select scan type:${RESET}"

        options=(
            "Ping Scan"
            "TCP SYN Scan"
            "UDP Scan"
            "OS Detection"
            "Version Detection"
            "Aggressive Scan"
            "Fast Scan"
            "All Ports Scan"
            "Top Ports Scan"
            "Firewall Evasion"
            "Vulnerability Scan"
            "NSE Script Scan"
            "Decoy Scan"
            "Traceroute"
            "Custom Ports"
            "Output to File"
            "Spoof MAC"
            "DNS Brute Force"
            "HTTP Title Enumeration"
            "SMB Enumeration"
            "FTP Anonymous Login Check"
            "SSL Certificate Info"
            "Detect Web Application Firewall"
            "HTTP Methods Check"
            "Extract HTTP Robots.txt"
            "Whois Lookup"
            "Run All Safe Scripts"
            "Subdomain Takeover Detection"
            "Quick HTTP Scan"
            "Quick DNS Scan"
            "Quick FTP Scan"
            "Exit"
        )

        for i in "${!options[@]}"; do
            printf "%2d. %s\n" $((i+1)) "${options[$i]}"
        done

        echo -ne "\nEnter option number: "
        read opt

        case $opt in
            1)  read -p "Target: " t; nmap -sn "$t" | tee "$(timestamp_log $t).log";;
            2)  read -p "Target: " t; nmap -sS "$t" | tee "$(timestamp_log $t).log";;
            3)  read -p "Target: " t; nmap -sU "$t" | tee "$(timestamp_log $t).log";;
            4)  read -p "Target: " t; nmap -O "$t" | tee "$(timestamp_log $t).log";;
            5)  read -p "Target: " t; nmap -sV "$t" | tee "$(timestamp_log $t).log";;
            6)  read -p "Target: " t; nmap -A "$t" -oX "$LOG_DIR/out.xml" && xsltproc "$LOG_DIR/out.xml" -o "$LOG_DIR/out.html" && echo "HTML report: $LOG_DIR/out.html";;
            7)  read -p "Target: " t; nmap -F "$t" | tee "$(timestamp_log $t).log";;
            8)  read -p "Target: " t; nmap -p- "$t" | tee "$(timestamp_log $t).log";;
            9)  read -p "Target: " t; nmap --top-ports 100 "$t" | tee "$(timestamp_log $t).log";;
            10) read -p "Target: " t; nmap -f --data-length 200 "$t" | tee "$(timestamp_log $t).log";;
            11) read -p "Target: " t; nmap --script vuln "$t" -oX "$LOG_DIR/vuln.xml" && xsltproc "$LOG_DIR/vuln.xml" -o "$LOG_DIR/vuln.html" && echo "Report: $LOG_DIR/vuln.html";;
            12) read -p "Target: " t; nmap --script default,vuln "$t" | tee "$(timestamp_log $t).log";;
            13) read -p "Target: " t; read -p "Decoy IP or RND:10: " d; nmap -D "$d" "$t" | tee "$(timestamp_log $t).log";;
            14) read -p "Target: " t; nmap --traceroute "$t" | tee "$(timestamp_log $t).log";;
            15) read -p "Target: " t; read -p "Ports (e.g. 21,22,80): " p; nmap -p "$p" "$t" | tee "$(timestamp_log $t).log";;
            16) read -p "Target: " t; read -p "Filename (no ext): " f; nmap -A -oA "$LOG_DIR/$f" "$t" && echo "Saved to $LOG_DIR/$f.*";;
            17) read -p "Target: " t; read -p "MAC type (0=random): " m; nmap --spoof-mac "$m" "$t" | tee "$(timestamp_log $t).log";;
            18) read -p "Domain: " t; nmap --script dns-brute "$t" | tee "$(timestamp_log $t).log";;
            19) read -p "Target: " t; nmap --script http-title "$t" | tee "$(timestamp_log $t).log";;
            20) read -p "Target: " t; nmap --script smb-enum-shares,smb-enum-users "$t" | tee "$(timestamp_log $t).log";;
            21) read -p "Target: " t; nmap --script ftp-anon "$t" | tee "$(timestamp_log $t).log";;
            22) read -p "Target: " t; nmap --script ssl-cert "$t" | tee "$(timestamp_log $t).log";;
            23) read -p "Target: " t; nmap --script http-waf-detect "$t" | tee "$(timestamp_log $t).log";;
            24) read -p "Target: " t; nmap --script http-methods "$t" | tee "$(timestamp_log $t).log";;
            25) read -p "Target: " t; nmap --script http-robots.txt "$t" | tee "$(timestamp_log $t).log";;
            26) read -p "Target: " t; whois "$t" | tee "$(timestamp_log $t)_whois.log";;
            27) read -p "Target: " t; nmap --script safe "$t" | tee "$(timestamp_log $t).log";;
            28) read -p "Enter subdomain list file: " file; subjack -w "$file" -t 100 -ssl -a -v -o "$LOG_DIR/subjack_$(date +%s).txt";;
            29) read -p "Target: " t; nmap -sV -p 80,443 "$t" | tee "$(timestamp_log $t)_http.log";;
            30) read -p "Target: " t; nmap -sU -p 53 "$t" | tee "$(timestamp_log $t)_dns.log";;
            31) read -p "Target: " t; nmap -sV -p 21 "$t" | tee "$(timestamp_log $t)_ftp.log";;
            32) echo -e "\n${RED}Exiting Make It Easy... Goodbye!${RESET}"; exit 0;;
            *) echo -e "${RED}Invalid option. Try again.${RESET}";;
        esac

        echo -e "\nPress ENTER to return to menu..."
        read
    done
}

#========== EXEC ================
check_dependencies
main_menu
