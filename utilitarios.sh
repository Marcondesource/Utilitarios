#!/usr/bin/env bash
#Verificação de Dependencias
dependencias=("dialog" "ffmpeg" "yt-dlp" "adb")
for dep in "${dependencias[@]}"; do
  if ! command -v "$dep" &>/dev/null; then
    echo "[ERRO] o pacote '$dep' não esta instalado!"
    exit 1
  fi
done

#Variaveis de cor
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
NC='\033[0m'

while true; do

dialog --clear --title "𝖀𝖙𝖎𝖑𝖎𝖙𝖆𝖗𝖎𝖔" --msgbox "$(cat ascii.txt)" 0 0

clear

OPCAO=$(dialog --clear --menu "Script Multi-funções" 0 0 6 \
  1 "Fazer Backup" \
  2 "Gravar Tela" \
  3 "Download Mp3" \
  4 "Android Debloat" \
  5 "Sair" \
  3>&1 1>&2 2>&3)

  [ $? -ne 0 ] && break

case $OPCAO in

1)#Backup
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
;;
2)#Gravação de tela
MONITOR=$(dialog --menu "Escolha o monitor:" 15 40 5 \
$(xrandr | awk '/ connected/ {print $1 " " $1}') \
3>&1 1>&2 2>&3)
[ -z "$MONITOR" ] && continue

  RESOLUCOES=()
  while read -r res; do
    if xrandr | grep -A 20 "^$MONITOR" | grep "$res" | grep -q "\*"; then
      RESOLUCOES+=("$res" "" "on")
    else
      RESOLUCOES+=("$res" "" "off")
    fi
  done < <(xrandr | awk -v m="$MONITOR" '$1==m {f=1; next} f && /^[ ]+[0-9]+x/ {print $1} f && /^[A-Z]/ {f=0}')

  ESCOLHA=$(dialog --title "Resolução para $MONITOR" \
    --radiolist "Selecione a resolução:" 15 50 8 \
    "${RESOLUCOES[@]}" \
    3>&1 1>&2 2>&3)

  [ -z "$ESCOLHA" ] && continue

  # LOG TEMPORÁRIO PARA O TAILBOX
  LOG_FILE=$(mktemp)

  # EXECUTA FFMPEG EM BACKGROUND REDIRECIONANDO SAÍDA PARA O LOG
  ffmpeg -video_size "$ESCOLHA" -framerate 30 -f x11grab \
    -i :0.0 -f pulse -i default "gravacao_$(date +%H%M%S).mp4" > "$LOG_FILE" 2>&1 &
  
  FFMPEG_PID=$!

  # EXIBE O TAILBOX
  dialog --title "Gravando... (ESC ou OK para parar)" \
    --tailbox "$LOG_FILE" 15 70

  # QUANDO SAIR DO TAILBOX, MATA O FFMPEG SE AINDA ESTIVER RODANDO
  kill $FFMPEG_PID 2>/dev/null
  rm -f "$LOG_FILE"

  dialog --msgbox "Gravação finalizada e arquivo salvo!" 5 40
;;
3)#Download Mp3
link=$(dialog --inputbox "Link" 0 0 3>&1 1>&2 2>&3)

if [ -d "$HOME/Músicas" ]; then
  MUSIC_DIR="$HOME/Músicas"
elif [ -d "$HOME/Musicas" ]; then
  MUSIC_DIR="$HOME/Musicas"
elif [ -d "$HOME/Music" ]; then
  MUSIC_DIR="$HOME/Music"
else
  MUSIC_DIR="$HOME/Músicas"
  echo "Criando diretório de músicas: $MUSIC_DIR"
  mkdir -p "$MUSIC_DIR"
fi

yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$MUSIC_DIR/%(title)s.%(ext)s" \
  --newline \
  --progress-template "%(progress._percent_str)s" "$link" \
  | sed -un 's/%//p' \
  | dialog --title "Download" --gauge "Baixando" 10 70 0

dialog --msgbox "Download concluído!" 5 30
;;
4)#Android Debloat
  if dialog --yesno "Tem certeza que deseja fazer Debloat?" 0 0; then
    dialog --infobox "Iniciando Debloat" 0 0

    APPS=(
      "com.android.chrome"
      "org.lineageos.recorder"
      "com.android.providers.calendar"
      "org.lineageos.glimpse"
      "io.chaldeaprjkt.gamespace"
      "com.android.hotwordenrollment.xgoogle"
      "com.android.hotwordenrollment.okgoogle"
      "com.google.android.inputmethod.latin"
      "com.google.android.apps.nbu.files"
      "org.omnirom.logcat"
      "com.google.android.calendar"
      "com.android.gallery3d"
      "com.google.android.youtube"
      "com.facebook.appmanager"
      "com.facebook.system"
      "com.facebook.services"
      "android.apps.maps"
      "com.google.android.aiipps.photos"
      "com.google.android.apps.tachyon"
      "com.google.android.syncadapters.calendar"
      "com.xiaomi.calendar"
      "com.google.android.apps.safetyhub"
      "com.google.android.apps.youtube.music"
      "com.google.android.apps.maps"
      "com.mi.globalbrowser"
      "com.miui.fm"
      "com.miui.fmservice"
      "com.miui.player"
      "com.google.android.apps.subscriptions.red"
      "com.google.android.gm"
      "com.google.android.videos"
      "com.google.android.apps.docs"
      "com.xiaomi.glgm"
      "com.xiaomi.mipicks"
      "org.akanework.gramophone"
      "org.fdroid.fdroid"
      "org.eu.droid_ng.jellyfish"
      "com.android.inputmethod.latin"
      "com.libremobileos.recorder"
      "org.fdroid.fdroid.privileged"
      "com.libremobileos.etar" 
)

    # Limpa o log antigo
    >debloat.log

    TOTAL_APPS=${#APPS[@]}
    CONTADOR=0

    (
      for app in "${APPS[@]}"; do
        CONTADOR=$((CONTADOR + 1))
        PORCENTAGEM=$(((CONTADOR * 100) / TOTAL_APPS))
        adb shell pm uninstall -k --user 0 "$app" >>debloat.log 2>&1
        echo "$PORCENTAGEM"
        echo "XXX"
        echo "Removendo: $app ($CONTADOR/$TOTAL_APPS)"
        echo "XXX"
      done
    ) | dialog --title "Debloat" --gauge "Iniciando limpeza..." 10 70 0
fi
    dialog --title "Resultado do Debloat" --textbox debloat.log 15 80
;;
5)#Sair
dialog --yesno "Deseja sair?" 0 0 && exit 
esac
done
