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


#!/usr/bin/env bash

FLD="../../" # ROOT
FILIN=$FLD"/logs/p4s.s1.log"
FILOUT=$FLD"/Utils/Visualize/out.csv"
FILOUT_TEMP=$FLD"/Utils/Visualize/Temp.csv"
echo -n "" > $FILOUT

# DATA
VLS=(`cat $FILIN | grep "ingress.Write" | cut -d ' ' -f 17`)

# EDIT CSV FILE
for ((i=0;i<${#VLS[@]};i+=14));
do
  echo "${VLS[$i]},${VLS[$(($i+1))]},${VLS[$(($i+2))]},${VLS[$(($i+3))]},${VLS[$(($i+4))]},${VLS[$(($i+5))]},${VLS[$(($i+6))]},${VLS[$(($i+7))]},${VLS[$(($i+8))]},${VLS[$(($i+9))]},${VLS[$(($i+10))]},${VLS[$(($i+11))]},${VLS[$(($i+13))]},${VLS[$(($i+12))]}" >> $FILOUT
done

# Filter Out CSV File
echo "Conversation to keep (type identifier) : "
read IDF
cat $FILOUT | grep ",$IDF$" > $FILOUT_TEMP
mv $FILOUT_TEMP $FILOUT

# Compute Percentage CG : AWK
awk -F, -f Percent.awk $FILOUT

# Generate Graphs
if [[ ! -d Out ]]; then
  mkdir Out
fi
python3 GetGraphs.py
