#!/bin/sh

sudo mkdir -p /hd2/var
sudo mv /var/tada /hd2/var/
sudo ln -s /hd2/var/tada /var/tada
