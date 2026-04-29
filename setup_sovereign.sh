#!/bin/bash

# ======================================================================
# OMEGA SOVEREIGN v1.50 - FULL INFRASTRUCTURE INSTALLER
# ======================================================================

BLUE='\033[94m'
GREEN='\033[92m'
RED='\033[91m'
RESET='\033[0m'

echo -e "${BLUE}"
echo "   ____  __  ____________ ___    "
echo "  / __ \/  |/  / ____/ __ \/   |   "
echo " / / / / /|_/ / __/ / / _  / /| |   "
echo "/ /_/ / /  / / /___/ /_/ / ___ |   "
echo "\____/_/  /_/_____/\____/_/  |_|   "
echo "        OMEGA SOVEREIGN INSTALLER v1.50"
echo -e "${RESET}"

# 1. System & Basis-Tools (Inklusive Nikto)
echo -e "${BLUE}[1/6] Installiere System-Pakete & Nikto...${RESET}"
sudo apt update -y
sudo apt install -y python3 python3-pip python3-requests python3-urllib3 git unzip curl wget sqlite3 nikto

# 2. ExploitDB & Searchsploit
echo -e "${BLUE}[2/6] Installiere ExploitDB (Searchsploit)...${RESET}"
if [ ! -d "$HOME/exploitdb" ]; then
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git $HOME/exploitdb
    sudo ln -sf $HOME/exploitdb/searchsploit /usr/local/bin/searchsploit
else
    echo -e "${GREEN}[+] ExploitDB bereits vorhanden.${RESET}"
fi

# 3. Metasploit-Framework (Omnibus-Installer für UserLAnd/ARM)
echo -e "${BLUE}[3/6] Installiere Metasploit-Framework (Rapid7)...${RESET}"
if ! command -v msfconsole &> /dev/null; then
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod 755 msfinstall
    sudo ./msfinstall
    rm msfinstall
    # MSF Datenbank initialisieren
    msfdb init --Xmx512M
else
    echo -e "${GREEN}[+] Metasploit bereits vorhanden.${RESET}"
fi

# 4. Python-Module Verifizierung (Requests Fix)
echo -e "${BLUE}[4/6] Verifiziere Python-Abhängigkeiten...${RESET}"
python3 -m pip install requests urllib3 --break-system-packages 2>/dev/null

# 5. Agent-Entpackung & Syntax-Fix (Geisterzeichen entfernen)
echo -e "${BLUE}[5/6] Entpacke und bereinige Agent-Dateien...${RESET}"
ZIP_FILE=$(ls autonomous_agent_v150.zip 2>/dev/null | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    unzip -o "$ZIP_FILE"
    # Entfernt unsichtbare Zeichen, die Syntax-Fehler verursachen
    sed -i 's/\xe2\x80\x8b//g' autonomous_agent.py 2>/dev/null
    echo -e "${GREEN}[+] Agent-Code bereinigt.${RESET}"
fi

# 6. Finalisierung & Launcher
echo -e "${BLUE}[6/6] Erstelle Start-Routine...${RESET}"
echo -e '#!/bin/bash\npython3 autonomous_agent.py' > pentest
chmod +x pentest
chmod +x *.py 2>/dev/null

echo -e "${GREEN}"
echo "===================================================="
echo "   KOMPLETT-INSTALLATION ABGESCHLOSSEN              "
echo "===================================================="
echo " Alle Tools (MSF, Nikto, EDB) sind einsatzbereit.   "
echo " Start: ./pentest                                   "
echo "===================================================="
echo -e "${RESET}"
