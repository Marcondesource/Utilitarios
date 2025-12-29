#!/usr/bin/env bash
if [ "$EUID" -eq 0 ]; then
echo "Iniciando Script"
else
echo "Favor Iniciar com Sudo"
exit 1
fi
   
echo "Abrindo Lsblk"
lsblk

read -p "Qual a partição? Exemplo:/dev/sdx" particao
echo "Primeira passada 1/3"
sudo dd if=/dev/zero of=$particao bs=4M status=progress
echo "Segunda passada 2/3"
sudo dd if=/dev/urandom of=$particao bs=4M status=progress
echo "Terceira Passada 3/3"
sudo dd if=/dev/zero of=$particao bs=4M status=progress

echo "Reforçando zerofill"
sudo shred -v -n 3 -z $particao

read -p "Deseja formatar o armazenamento? s/n" format
case $format in
s)echo "FAT32"
  echo "EXT4"
read -p "Qual tipo de formato voce deseja?" fodas
case $fodas in
FAT32) mkfs.fat -F32 $particao
;;
EXT4) mkfs.ext4 $particao
esac
;;
n) saindo...
sleep 5s
exit1
esac 
if [ "$?" -eq 0 ]; then
echo "Zerofill Finalizado"
else
echo "Erro ao fazer Zerofill"
exit 1
fi
