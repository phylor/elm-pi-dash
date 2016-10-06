#!/bin/bash

sudo apt-get install -y xscreensaver
sudo bash -c "echo 'xserver_command = X -nocursor' >> /etc/lightdm/lightdm.conf"
# no need to add xscreensaver to autostart, because LXDE automatically starts it if it's available
echo '@/home/pi/Dashboard-linux-armv7l/Dashboard' >> ~/.config/lxsession/LXDE-pi/autostart
echo '@/home/pi/screensaver-power' >> ~/.config/lxsession/LXDE-pi/autostart


echo > ~/.xscreensaver << EOF
timeout:        0:00:40
cycle:          0:05:00
lock:           False
lockTimeout:    0:00:00
passwdTimeout:  0:00:30
fade:           False
unfade:         False
fadeSeconds:    0:00:00
fadeTicks:      0
dpmsEnabled:    True
dpmsStandby:    0:00:40
dpmsSuspend:    0:00:40
dpmsOff:        0:00:40
EOF

echo > ~/screensaver-power << EOF
#!/usr/bin/perl

my $blanked = 0;
open (IN, "xscreensaver-command -watch |");
while (<IN>) {
    if (m/^(BLANK|LOCK)/) {
        if (!$blanked) {
        printf("Turning display off..");
            system "tvservice -o";
            $blanked = 1;
        }
    } elsif (m/^UNBLANK/) {
        printf("Turning display on..");
        system "tvservice -p";
        system "xset dpms force on -display :0";
        $blanked = 0;
    }
}
EOF
