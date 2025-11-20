#!/usr/bin/env bash
#Script de utilitarios para o dia a dia!
cat << "EOF"

██╗░░░██╗████████╗██╗██╗░░░░░██╗████████╗░█████╗░██████╗░██╗░█████╗░░██████╗
██║░░░██║╚══██╔══╝██║██║░░░░░██║╚══██╔══╝██╔══██╗██╔══██╗██║██╔══██╗██╔════╝
██║░░░██║░░░██║░░░██║██║░░░░░██║░░░██║░░░███████║██████╔╝██║██║░░██║╚█████╗░
██║░░░██║░░░██║░░░██║██║░░░░░██║░░░██║░░░██╔══██║██╔══██╗██║██║░░██║░╚═══██╗
╚██████╔╝░░░██║░░░██║███████╗██║░░░██║░░░██║░░██║██║░░██║██║╚█████╔╝██████╔╝
░╚═════╝░░░░╚═╝░░░╚═╝╚══════╝╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░╚════╝░╚═════╝░

EOF
while true; do
echo "=========================================="
echo "           UTILITÁRIOS DIÁRIOS"
echo "=========================================="
echo "1) Backup de Pastas"
echo "2) Gravar Tela"
echo "3) Download de Midias"
echo "4) Sair"
echo "=========================================="
read -p "Escolha uma opção: " opcao

case $opcao in
1)read -p "Qual o diretorio que deseja fazer backup (origem): " origem
read -p "Qual o diretorio que deseja salvar o backup (destino)?: " destino
rsync -av --delete "$origem" "$destino"
if [ "$?" -eq 0 ]; then
echo "Backup feito"
else 
echo "erro ao fazer backup, consulte os logs" | tee "logs/backup$(date +%Y-%m-%d_%H-%M-%S).log"
exit 1 
fi
;;
2)read -p "Qual resolução? (Ex: 1280x720, 1368x768... :" resolucao
ffmpeg -video_size $resolucao -framerate 30 -f x11grab -i :0.0 \
-f pulse -i default gravação_com_audio.mp4
if [ "$?" -eq 0 ]; then
echo "Gravação concluida com sucesso"
else 
echo "erro ao fazer gravar, consulte os logs" | tee "logs/gravaçao$(date +%Y-%m-%d_%H-%M-%S).log"
exit 1 
fi
;;
3)read -p "Link do video: " link
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
yt-dlp -x --audio-format mp3 --audio-quality 0 -o "$HOME/Músicas/%(title)s.%(ext)s" $link
if [ "$?" -eq 0 ]; then
echo "Musica baixada, esta no Diretorio/Pasta Músicas"
else
echo "Erro ao baixar, Verifique os logs" | tee "logs/download_mp3$(date +%Y-%m-%d_%H-%M-%S).log"
fi
;;
4)echo "Saindo..."
sleep 1s
exit 1
;;
*)echo "Essa opcao nao existe, escolha uma das existentes"
;;
esac
read -p "Pressione Enter para continuar..."
clear
done
