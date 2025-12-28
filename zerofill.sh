#!/usr/bin/env bash
read -p "Qual a partição?" particao
echo "Primeira passada 1/3"
sudo dd if=/dev/zero of=/dev/$particao bs=4M status=progress
echo "Segunda passada 2/3"
sudo dd if=/dev/urandom of=/dev/$particao bs=4M status=progress
echo "Terceira Passada 3/3"
sudo dd if=/dev/zero of=/dev/$particao bs=4M status=progress

echo "Reforçando zerofill"
sudo shred -v -n 3 -z /dev/$particao

read -p "Deseja formatar o armazenamento? s/n" format
case $format in
s)echo "FAT32"
  echo "EXT4"
read -p "Qual tipo de formato voce deseja?" fodas
case $fodas in
FAT32) mkfs.fat -F32 /dev/$particao
;;
EXT4) mkfs.ext4 /dev/$particao
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
