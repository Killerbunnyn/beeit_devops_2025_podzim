!/bin/bash

#tyhle prikazy jsou presunty do zakladniho infa
#echo $SHELL
#whoami
#cat /etc/os-release
#printenv

LOGOVAT_DO_SOUBORU=false
SOUBOR_LOGU="./linux_cli.log"

# --------- 1. MANUÁL ---------

function zobrazitManual() {
    echo -e "
=======================================================
----------------MANUÁL (linux_cli.sh)-----------------
=======================================================
----------Script pro správu systému a souborů----------


-----------------------POUŽITÍ-------------------------

 Pro spuštění napiš ./linux_cli.sh <příkaz z manuálu>

=======================================================

-----------------------PŘÍKAZY-------------------------

  -h, help          Zobrazí manuál

  zakladni-info     Vypíše info o uživateli, shellu a OS
  log-stdout        Nastaví výpis logů
  log-soubor        Nastaví výpis logů do souboru '$SOUBOR_LOGU'

  seznam-update     Vypíše balíčky, který čekaj na aktualizaci
  udelat-upgrade    Provede 'apt update' a 'apt upgrade'

  vytvorit-link     Vytvoří soft nebo hard link
    Parametry: <typ: soft/hard> <zdroj> <cil>

  najit-regex       Najde soubory obsahující b,e,a,e
    Parametr: [adresar_kde_hledat] (volitelné)

  samoinstalace     Vytvoří soft link na tento skript do /bin/linux_cli

-------------------------------------------------------
"
}

# --------- 2. LOGOVÁNÍ ---------

function zaloguj() {
    local zprava="[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    if [ "$LOGOVAT_DO_SOUBORU" = true ]; then
        echo "$zprava" >> "$SOUBOR_LOGU"
    else
        echo -e "\033[32m$zprava\033[0m" #pozivitni_zelena
    fi
}

function zalogujChybu() {
    local zprava="[CHYBA] $(date '+%Y-%m-%d %H:%M:%S') - $1"
    local kod_ukonceni=$2

    if [ "$LOGOVAT_DO_SOUBORU" = true ]; then
        echo "$zprava" >> "$SOUBOR_LOGU"
    else
        echo -e "\033[31m$zprava\033[0m" >&2 #negativni_cervena
    fi

    if [ ! -z "$kod_ukonceni" ]; then
        exit "$kod_ukonceni"
    fi
}

function nastavitVystupLogu() {
    local volba="$1"
    if [ "$volba" == "soubor" ]; then
        LOGOVAT_DO_SOUBORU=true
        zaloguj "Logování přepnuto do $SOUBOR_LOGU"
    elif [ "$volba" == "stdout" ]; then
        LOGOVAT_DO_SOUBORU=false
        zaloguj "Logování přepnuto na STDOUT"
    else
        zalogujChybu "Chyba - napiš 'soubor' nebo 'stdout'." 1
    fi
}

# --------- 3. SYSTÉMOVÉ FUNKCE ---------

function zakladniInfo() {
    zaloguj "Vypsání informací o systému:"
    echo "Shell: $SHELL"
    echo "Uživatel: $(whoami)"
    echo "Verze OS:"
    cat /etc/os-release
    printenv | head -n 5
}

function vypsatAktualizace() {
    zaloguj "Vyhledávání balíčků"
    if ! sudo apt update 2>/dev/null; then
        zalogujChybu "Chyba"
        return 1
    fi
    local seznam_balicku=$(apt list --upgradable 2>/dev/null | grep -v 'hledání')

    if [ -z "$seznam_balicku" ]; then
        zaloguj "Žádný aktualizace k dispozici"
    else
        zaloguj "Dostupné aktualizace:"
        echo "$seznam_balicku"
    fi
}

function provestUpgrade() {
    zaloguj "Probíhá aktualizace"
    if sudo apt update && sudo apt upgrade -y; then
        zaloguj "Update a Upgrade hotovo."
    else
        zalogujChybu "Chyba" 1
    fi
}

# --------- 4. SOUBORY A LINKY ---------

function vytvoritLink() {
    if [ "$#" -ne 3 ]; then
        zalogujChybu "chyba mrkni na manual" 1
    fi

    local typ_linku="$1"
    local zdroj="$2"
    local cil="$3"
    local prikaz="ln"

    if [ ! -e "$zdroj" ]; then
        zalogujChybu "soubor neexistuje" 1
    fi

    if [ "$typ_linku" == "soft" ]; then
        prikaz="ln -s"
        zaloguj "Vytváří se SOFT link"
    elif [ "$typ_linku" == "hard" ]; then
        prikaz="ln"
        zaloguj "Vytváří se HARD link"
    else
        zalogujChybu "Použij 'soft' nebo 'hard'" 1
    fi

    if $prikaz "$zdroj" "$cil"; then
        zaloguj "Link byl vytvořen"
    else
        zalogujChybu "Vytváření linku selhalo" 1
    fi
}

function najitRegex() {
    local adresar="${1:-.}"

    zaloguj "Hledám soubory v: $adresar"

    # Použití find s rozšířeným regexem
    find "$adresar" -regextype posix-extended -regex '.*b.*e.*a.*e.*'

    if [ $? -eq 0 ]; then
        zaloguj "Hledání hotovooo."
    else
        zalogujChybu "Příkaz skončil chybou."
    fi
}

function samoinstalace() {
    zaloguj "Instaluju tvuj link do /linux_cli"
    local cesta_skriptu=$(realpath "$0")

    if sudo ln -sf "$cesta_skriptu" "/bin/linux_cli"; then
        zaloguj "Hotovo"
    else
        zalogujChybu "Nepodařilo se vytvořit link" 1
    fi
}

# --------- 5. MAIN PRIKAZY ---------

if [ $# -eq 0 ]; then
    zalogujChybu "Žádný příkaz - mrkni na manuál"
    zobrazitManual
    exit 1
fi

case "$1" in
    -h|help)
        zobrazitManual
        ;;
    zakladni-info)
        zakladniInfo
        ;;
    log-stdout)
        nastavitVystupLogu "stdout"
        ;;
    log-soubor)
        nastavitVystupLogu "soubor"
        ;;
    seznam-update)
        vypsatAktualizace
        ;;
    udelat-upgrade)
        provestUpgrade
        ;;
    vytvorit-link)
        vytvoritLink "$2" "$3" "$4"
        ;;
    najit-regex)
        najitRegex "$2"
        ;;
    samoinstalace)
        samoinstalace
        ;;
    *)
        zalogujChybu "Neznámý příkaz '$1'. Pro nápovědu použijte -h." 1
        ;;
esac

exit 
