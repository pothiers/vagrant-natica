#!/bin/sh

sudo mkdir -p /hd2/var
sudo mv /var/tada /hd2/var/
sudo ln -s /hd2/var/tada /var/tada
sudo chmod -R 777 /hd2/var/tada 
