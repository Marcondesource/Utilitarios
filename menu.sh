#!/usr/bin/env bash 
OPCAO=$(dialog --clear --menu "Script Multi-funções" 0 0 3 \
1 "Fazer Backup" \
2 "Gravar Tela" \
3 "Download Mp3" \
3>&1 1>&2 2>&3)

clear

case $OPCAO in
1) OK=$(dialog --clear --menu "Selecione uma opção" 0 0 2 \
1 "E um Arquivo" \
2 "E um Pasta/Diretorio" \
3>&1 1>&2 2>&3)

clear
;;
esac

case $OK in
1)
ORIGEM=$(dialog --clear --fselect / 0 0 3>&1 1>&2 2>&3) 
DESTINO=$(dialog --clear --fselect / 0 0 3>&1 1>&2 2>&3)
;;
2)
ORIGEM=$(dialog --clear --dselect / 0 0 3>&1 1>&2 2>&3)
DESTINO=$(dialog --clear --dselect / 0 0 3>&1 1>&2 2>&3)
;;
esac
