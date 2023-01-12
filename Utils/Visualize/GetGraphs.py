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


import matplotlib.pyplot as plt
import csv
DIR="."
FIL="/out.csv"


# VALUES DIR1
NbPaks1=[]
SumSze1=[]
MeanSZ1=[]
StdSZ1=[]
MeanIAT1=[]
StdIAT1=[]
# VALUES DIR2
NbPaks2=[]
SumSze2=[]
MeanSZ2=[]
StdSZ2=[]
MeanIAT2=[]
StdIAT2=[]


def Display(FTR,UNIT,Vals1,Vals2):
    plt.title("Boxplot: %s"%FTR)
    plt.xlabel("Direction")
    plt.ylabel(UNIT)
    plt.boxplot([Vals1,Vals2],showfliers=False)
    plt.xticks([1,2],["Down","Up"])
    plt.grid()
    plt.savefig(DIR+"/Out/"+FTR)
    plt.close()




with open(DIR+FIL,mode='r') as file:
    # READ VALUES
    csvFIL=csv.reader(file,delimiter=',')
    for lines in csvFIL:
        # VALUES DIR1
        MeanSZ1.append(int(lines[0]))
        StdSZ1.append(int(lines[1]))
        MeanIAT1.append(int(lines[2]))
        StdIAT1.append(int(lines[3]))
        SumSze1.append(int(lines[4]))
        NbPaks1.append(int(lines[5]))
        # VALUES DIR2
        MeanSZ2.append(int(lines[6]))
        StdSZ2.append(int(lines[7]))
        MeanIAT2.append(int(lines[8]))
        StdIAT2.append(int(lines[9]))
        SumSze2.append(int(lines[10]))
        NbPaks2.append(int(lines[11]))

    # DISPLAY VALUES
    Display("Nb Packets","Number",NbPaks1,NbPaks2)
    Display("Sum Sizes","Bytes",SumSze1,SumSze2)
    Display("Mean size","Bytes",MeanSZ1,MeanSZ2)
    Display("Std size","",StdSZ1,StdSZ2)
    Display("Mean iat","µs",MeanIAT1,MeanIAT2)
    Display("Std iat","",StdIAT1,StdIAT2)
    # END
    print("[!] 6 boxplots computed")
    print("[!] See %s "%(DIR+"/Out/"))
