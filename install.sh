#!/bin/bash

sudo bash -c "echo 'xserver_command = X -nocursor' >> /etc/lightdm/lightdm.conf"
echo '@/home/pi/Dashboard-linux-armv7l/Dashboard' >> ~/.config/lxsession/LXDE-pi/autostart