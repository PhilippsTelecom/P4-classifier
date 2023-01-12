# Copyright (c) 2022 Centre National de la Recherche Scientifique All Rights Reserved.
#
# This file is part of MOSAICO PROJECT.
#
# MOSAICO PROJECT is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MOSAICO PROJECT is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MOSAICO PROJECT. See the file COPYING.  If not, see <http://www.gnu.org/licenses/>.




#!/bin/bash
# Script to install tcpreplay
# Launch from Docker container
# ./Host.sh INTERF PCAP_PATH


# INSTALL PACKAGE IF NECESSARY
CURR_FOLD="/p4app"
BIN_FOLD="/usr/local/bin"
TCPREP_VERSION="4.4.3"
if [ ! -x $BIN_FOLD"/tcpreplay" ];
then
  echo "Launching the Installation..."
  echo "Which tcpreplay version ? (x.y.z)"
  read version
  if [[ ! -d $CURR_FOLD"/includes/tcpreplay-$version" ]]; then
    echo "[!] tcpreplay not installed or wrong version"
    echo "[!] Download tcpreplay and put it in includes/"
    echo "[!] Exiting..."
    exit
  fi
  cd $CURR_FOLD"/includes/tcpreplay-$version/"
  ./configure
  make
  make install
  make test
fi


NET_FOLD="/sys/class/net"
cd $CURR_FOLD
INTERF=$1
REPLAY=$2
# CHECK NB ARGS
if [ ! $# -eq 2 ];
then
  echo "You are supposed to provide 2 arguments"
else
  # CHECK IF PCAP EXISTS
  if [ ! -f $REPLAY ];
  then
    echo "The PCAP file doesn't exists"
    echo "Exiting..."
  else
    # CHECK IF INTERF EXISTS
    if [ ! -d $NET_FOLD"/"$INTERF ];
    then
      echo "Interface doesn't exist"
    else
      echo "Launching traffic..."
      # LAUNCH TRAFFIC
      tcpreplay -i eth0 -K $REPLAY
    fi
  fi
fi
