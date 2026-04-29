#!/bin/bash

# ======================================================================
# OMEGA SOVEREIGN v1.50 - FULL INFRASTRUCTURE INSTALLER
# ======================================================================

BLUE='\033[94m'
GREEN='\033[92m'
RED='\033[91m'
RESET='\033[0m'

echo -e "${BLUE}[*] Starte OMEGA SOVEREIGN Full-Installation...${RESET}"

# 1. System-Basis & Nikto & Fix für Requests
echo -e "${BLUE}[1/6] Installiere System-Tools, Python-Module & Nikto...${RESET}"
sudo apt update -y
sudo apt install -y python3 python3-pip python3-requests python3-urllib3 \
                     git unzip curl wget sqlite3 nikto build-essential

# 2. Metasploit-Framework (UserLAnd Spezial-Weg via Rapid7)
echo -e "${BLUE}[2/6] Installiere Metasploit-Framework (Rapid7)...${RESET}"
if ! command -v msfconsole &> /dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod 755 msfinstall
    sudo ./msfinstall
    rm msfinstall
    msfdb init --Xmx512M
else
    echo -e "${GREEN}[+] Metasploit bereits installiert.${RESET}"
fi

# 3. ExploitDB (Searchsploit)
echo -e "${BLUE}[3/6] Installiere ExploitDB & Searchsploit...${RESET}"
if [ ! -d "$HOME/exploitdb" ]; then
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git $HOME/exploitdb
    sudo ln -sf $HOME/exploitdb/searchsploit /usr/local/bin/searchsploit
else
    echo -e "${GREEN}[+] ExploitDB bereits vorhanden.${RESET}"
    cd $HOME/exploitdb && git pull && cd -
fi

# 4. Python-Failsafe
echo -e "${BLUE}[4/6] Verifiziere Python-Module (PIP Fallback)...${RESET}"
python3 -m pip install requests urllib3 --break-system-packages 2>/dev/null

# 5. Agent-Entpackung & Syntax-Fix
echo -e "${BLUE}[5/6] Entpacke und bereinige Agent-Dateien...${RESET}"
ZIP_FILE=$(ls autonomous_agent_v150.zip 2>/dev/null | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    unzip -o "$ZIP_FILE"
    # Entfernt unsichtbare "Geisterzeichen" die Fehler auslösen
    sed -i 's/\xe2\x80\x8b//g' autonomous_agent.py 2>/dev/null
    echo -e "${GREEN}[+] Agent-Code wurde gereinigt.${RESET}"
else
    echo -e "${RED}[!] autonomous_agent_v150.zip fehlt!${RESET}"
fi

# 6. Launcher & Berechtigungen
echo -e "${BLUE}[6/6] Finalisiere Launcher...${RESET}"
echo -e '#!/bin/bash\npython3 autonomous_agent.py' > pentest
chmod +x pentest
chmod +x *.py 2>/dev/null

echo -e "${GREEN}"
echo "===================================================="
echo "   FULL INSTALLATION ABGESCHLOSSEN (OMEGA STATUS)    "
echo "===================================================="
echo " Installiert: Metasploit, Nikto, Searchsploit       "
echo " Fixes: Requests-Modul, Python-Syntax-Zero-Width    "
echo "----------------------------------------------------"
echo " Starte das System mit: ./pentest                   "
echo "===================================================="
echo -e "${RESET}"
