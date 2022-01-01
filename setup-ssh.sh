#!/usr/bin/env bash

###
# #%L
# Codenjoy - it's a dojo-like platform from developers to developers.
# %%
# Copyright (C) 2012 - 2022 Codenjoy
# %%
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/gpl-3.0.html>.
# #L%
###

if [ "$EUID" -ne 0 ]
  then echo "[91mPlease run as root[0m"
  exit
fi

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

echo "[92m========================================================================================================================"
echo "===================================================== Setup SSH ======================================================="
echo "========================================================================================================================[0m"

NEW_USER=alex
eval_echo "adduser --disabled-password --gecos '' $NEW_USER"

eval_echo "usermod -aG sudo $NEW_USER"
groups $NEW_USER

eval_echo "usermod -aG docker $NEW_USER"
groups $NEW_USER

eval_echo "mkdir /home/$NEW_USER/.ssh"
ls -la /home/$NEW_USER/.ssh

eval_echo "chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh"
ls -la /home/$NEW_USER/.ssh

eval_echo "chmod 700 /home/$NEW_USER/.ssh"
ls -la /home/$NEW_USER/.ssh

eval_echo "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTH7actwVII/hwh/C/EuAR7shdfdOovjeak86k9V3vXHSTBIoarvZVEhsAd1i/2mlujmFhecbQvT78h7aKdmwF2r+2U/QgeWwPFmpGuNQXNGskidumW3FE1eI7v8wiGy1dxtdmxfEPHpZSr7C3+d6GQsR2WbhvNay5hU7ADDRHU6KPknBn1kZL/ZEaqxlBR1hMlHANeoUTLqQbdQL8DcNAlOicatjSfXMml93vy2y2Nz91GD646TIRPhjh+b2/JzxaREr3tHzFWzBLfqFXo/6k9beUVCi4GDrTSVLA/YKxqkcVItPlr+M9TvPZsr+84eQchpuCbUb0QoHmTBt//EMv indigo@indigo-pc' >> /home/$NEW_USER/.ssh/authorized_keys"
ls -la /home/$NEW_USER/.ssh/authorized_keys

eval_echo "chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh/authorized_keys"
ls -la /home/$NEW_USER/.ssh/authorized_keys

eval_echo "chmod 600 /home/$NEW_USER/.ssh/authorized_keys"
ls -la /home/$NEW_USER/.ssh/authorized_keys

eval_echo "sed -i 's/\(Port \).*\$/\14632/' /etc/ssh/sshd_config"
cat /etc/ssh/sshd_config | grep '^Port '

# comment PasswordAuthentication
# eval_echo "sed -i '/PasswordAuthentication /s/^/#/' /etc/ssh/sshd_config"
eval_echo "sed -i '/PasswordAuthentication /s/^#//' /etc/ssh/sshd_config"
eval_echo "sed -i 's/\(PasswordAuthentication \).*\$/\1no/' /etc/ssh/sshd_config"
cat /etc/ssh/sshd_config | grep '^PasswordAuthentication '

eval_echo "sed -i 's/\(RSAAuthentication \).*\$/\1yes/' /etc/ssh/sshd_config"
cat /etc/ssh/sshd_config | grep '^RSAAuthentication '

eval_echo "sed -i 's/\(PubkeyAuthentication \).*\$/\1yes/' /etc/ssh/sshd_config"
cat /etc/ssh/sshd_config | grep '^PubkeyAuthentication '

eval_echo "sudo systemctl reload sshd"

echo "[93mPlease try to connect via ssh as $NEW_USER[0m"

# setup dockerhub account
# https://docs.docker.com/engine/reference/commandline/login/
# copy ~/.docker/config.json <from other server>

