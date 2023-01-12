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


#!/usr/bin/awk
# Goal is to give percentage CG


BEGIN {
  lines=0; nb_CG=0;
}
{
  lines++;
  if ( $13 == "1" ) {
    nb_CG++;
  }
}
END {
  print "[!] Percentage CG = " nb_CG/lines
  print "[!] Total = " lines " reports and " nb_CG " predicted CG"
}
