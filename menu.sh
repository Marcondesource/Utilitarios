#!/usr/bin/env bash 
#Variaveis
LOG="/tmp/zerofill.log"
#Variaveis de cor

dialog --clear --title "𝖀𝖙𝖎𝖑𝖎𝖙𝖆𝖗𝖎𝖔" --msgbox "$(cat ascii.txt)" 0 0

clear

OPCAO=$(dialog --clear --menu "Script Multi-funções" 0 0 5 \
1 "Fazer Backup" \
2 "Zero Fill" \
3 "Gravar Tela" \
4 "Download Mp3" \
5 "Cria Maquina Virtual" \
3>&1 1>&2 2>&3)

clear

if [ "$OPCAO" -eq 1 ]; then
OK=$(dialog --clear --menu "Selecione uma opção" 0 0 2 \
1 "E um Arquivo" \
2 "E um Pasta/Diretorio" \
3>&1 1>&2 2>&3)

case $OK in
1)
origem=$(dialog --clear --fselect / 0 0 3>&1 1>&2 2>&3)
destino=$(dialog --clear --fselect / 0 0 3>&1 1>&2 2>&3)
origem="${origem/#\~/$HOME}"
destino="${destino/#\~/$HOME}"
origem_real=$(realpath -m "$origem")
destino_real=$(realpath -m "$destino")
rsync -av --delete "$origem_real" "$destino_real"
;;
2)
origem=$(dialog --clear --dselect / 0 0 3>&1 1>&2 2>&3)
destino=$(dialog --clear --dselect / 0 0 3>&1 1>&2 2>&3)
origem="${origem/#\~/$HOME}"
destino="${destino/#\~/$HOME}"
origem_real=$(realpath -m "$origem")
destino_real=$(realpath -m "$destino")
rsync -av --delete "$origem_real" "$destino_real"
;;
esac
fi

if [ "$OPCAO" -eq 2 ]; then
PARTS=$(lsblk -ln -o NAME,MOUNTPOINT | grep -v '^$' | grep -v '^\s*$' | awk '$2!="" {print "/dev/"$1" "$2}')
DIALOG_LIST=()
while read -r line; do
    DEV=$(echo $line | awk '{print $1}')
    MOUNT=$(echo $line | awk '{print $2}')
    DIALOG_LIST+=("$DEV" "$MOUNT" "off")
done <<< "$PARTS"
CHOICE=$(dialog --stdout --checklist "Escolha partições:" 0 0 0 "${DIALOG_LIST[@]}")
{
sudo dd if=/dev/zero of=$PARTS bs=4M status=progress
sudo dd if=/dev/urandom of=$PARTS bs=4M status=progress
sudo dd if=/dev/zero of=$PARTS bs=4M status=progress
sudo shred -v -n 1 -z $PARTS
} > $LOG 2>&1 &
dialog --titles "Zerofill em andamento" \
--tailbox "$LOG" 20 70
dialog --msgbox "Zerofill Finalizado com Sucesso" 8 40

fi

if [ "$OPCAO" -eq 3 ]; then
MONITOR=$(xrandr | awk '/ connected/ {print $1}' | \
dialog --menu "Escolha o monitor:" 15 40 5 \
$(xrandr | awk '/ connected/ {print $1 " " $1}') \
2>&1 >/dev/tty)

[[ -z "$MONITOR" ]] && exit 1

RESOLUCOES=()

while read -r linha; do
    if [[ $linha =~ ^[[:space:]]+([0-9]+x[0-9]+) ]]; then
        res="${BASH_REMATCH[1]}"
        status="off"
        [[ $linha =~ \* ]] && status="on"
        RESOLUCOES+=("$res" "" "$status")
    fi
done < <(xrandr | awk -v m="$MONITOR" '
    $1 == m {flag=1; next}
    flag && /^[[:space:]]+[0-9]/ {print}
    flag && /^[A-Z]/ {exit}
')

# escolhe resolução
ESCOLHA=$(dialog \
    --title "Resolução para $MONITOR" \
    --radiolist "Selecione a resolução:" \
    15 50 8 \
    "${RESOLUCOES[@]}" \
    2>&1 >/dev/tty)

clear

[[ -z "$ESCOLHA" ]] && exit 1

ffmpeg -video_size $ESCOLHA -framerate 30 -f x11grab -i :0.0 \
-f pulse -i default gravação_com_audio.mp4

fi
