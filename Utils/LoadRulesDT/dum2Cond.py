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


"""
    Here, we load a serialized model
    We then generate CSV Files for FEATURE & ACTION rules (P4)
"""
import joblib
import graphviz
import sklearn
import os
# Retrieve DT
PROJ_FLD="../.." # ROOT
MODEL=PROJ_FLD+"/Data/DT_0.033.model"
# Save Results
CURR_FLD="."
ACT_OUT=CURR_FLD+"/ACT_Ruls.csv"
FTR_OUT=CURR_FLD+"/FTR_Ruls.csv"
IMGOUT=CURR_FLD+"/Out/DT.viz"
#
FTS={0:"MnSzDw",1:"VrSzDw",2:"MnItDw",3:"VrItDw",4:"SumSzDw",5:"NbDw",6:"MnSzUp",7:"VrSzUp",8:"MnItUp",9:"VrItUp",10:"SumSzUp",11:"NbUp"}
FTS_MAX={
    0:2**12-1,# SZE
    1:2**20-1,
    2:2**14-1,# IAT
    3:2**28-1,
    4:2**19-1,
    5:2**9-1,
    6:2**10-1,# SZE
    7:2**19-1,
    8:2**15-1,# IAT
    9:2**28-1,
    10:2**17-1,
    11:2**8-1
    } # Pow 2




"""
    Retrieve Data
"""
MODEL_LD = joblib.load(MODEL)
tree=MODEL_LD.tree_
children_left = tree.children_left
children_right = tree.children_right
feature = tree.feature
threshold = tree.threshold
value=tree.value




"""
    FUNCTION DT 2 PNG
"""
def displayDT():
    # Bleu : CG (droite)
    dot_data=sklearn.tree.export_graphviz(MODEL_LD,filled=True)
    graph=graphviz.Source(dot_data,format="png")
    graph.render(IMGOUT,view=False)




"""
    Browse DT ; retrieve Features & associated Thresholds
"""
def Get_Feats_Rec(curr_id,dicoFtsThr):
    # Not leaf node
    if int(feature[curr_id])>=0:

        # Feat - Thr
        ft=feature[curr_id]
        thr=threshold[curr_id]
        if ft not in dicoFtsThr:
            dicoFtsThr[ft]=[]
        dicoFtsThr[ft].append(thr)

        # Left Tree : True
        if children_left[curr_id]!=-1:
            Get_Feats_Rec(children_left[curr_id],dicoFtsThr)

        # Right Tree : False
        if children_right[curr_id]!=-1:
            Get_Feats_Rec(children_right[curr_id],dicoFtsThr)


def Sort_Feats_Thresh(DicoDat):
    print("[!] Features & associated thresholds")
    for k in DicoDat.keys():
        v=FTS_THRS[k]
        v.sort()
        v=[0]+v+[FTS_MAX[k]]
        DicoDat[k]=v




"""
    Browse DT ; write rules (xport CSV ?)
"""
def Export_Action_Rule(Fil,Typ,dicoConds):
    Lin="%d,"%(int(Typ)) # CG or NOT
    for k in dicoConds.keys(): # Browse Conds
        Lin=Lin+"%d,%d,%d,"%(k,int(dicoConds[k][0]),int(dicoConds[k][1]))
    Lin=Lin[:-1]
    Fil.write(Lin+"\n")


def Write_Rules_Rec(curr_id,dicoFtsThr,dicoFtsInds,Fil):
    # Not leaf node
    if int(feature[curr_id])>=0:

        # Feat - Thr
        ft=feature[curr_id]
        thr=threshold[curr_id]
        # Get Indexes
        newInd=dicoFtsThr[ft].index(thr)

        # Left Tree : True (<=)
        if children_left[curr_id]!=-1:
            # Update
            Remove=False
            if ft not in dicoFtsInds:
                dicoFtsInds[ft]=(0,newInd)
                Remove=True
            else:
                save=dicoFtsInds[ft]
                dicoFtsInds[ft]=(dicoFtsInds[ft][0],newInd)
            Write_Rules_Rec(children_left[curr_id],dicoFtsThr,dicoFtsInds,Fil)
            if not Remove:# Climbing the tree, remove feature
                dicoFtsInds[ft]=save
            else:
                del dicoFtsInds[ft]

        # Right Tree : False (>)
        if children_right[curr_id]!=-1:
            # Update
            Remove=False
            if ft not in dicoFtsInds:
                dicoFtsInds[ft]=(newInd+1,len(dicoFtsThr[ft])-1)
                Remove=True
            else:
                save=dicoFtsInds[ft]
                dicoFtsInds[ft]=(newInd+1,dicoFtsInds[ft][1])
            Write_Rules_Rec(children_right[curr_id],dicoFtsThr,dicoFtsInds,Fil)
            if not Remove:# Climbing the tree, remove feature
                dicoFtsInds[ft]=save
            else:
                del dicoFtsInds[ft]


    # Leaf node : write Action Rule
    else:
        is_CG=False
        tab=value[curr_id][0]
        if tab[0]<tab[1]:# CG
            is_CG=True
        Export_Action_Rule(Fil,is_CG,dicoFtsInds)




"""
    Write Feature Rules
"""
def Write_Feature_Rules(dicoFtsThr,Fil):
    for k,v in dicoFtsThr.items():
        Str=str(k)+","
        for e in v:
            Str=Str+str(int(e))+","
        Str=Str[:-1]
        Str=Str+"\n"
        Fil.write(Str)




"""
    Main
"""
if not os.path.isdir("./Out"):
    os.mkdir("./Out")


# See DT
# displayDT()


# Retrieve Features <-> Thresholds
curr_id=0 # root
FTS_THRS={} # Match Feats to Thresh
Get_Feats_Rec(curr_id,FTS_THRS)
Sort_Feats_Thresh(FTS_THRS)


# Write ACTION Rules
Fil=open(ACT_OUT,'w')
curr_id=0 # root
FTS_INDS={} # Match feats to indexes (min,Max)
Write_Rules_Rec(curr_id,FTS_THRS,FTS_INDS,Fil)
Fil.close()
print("[!] Export Action Rules : DONE")


# Write FEATURE Rules
Fil=open(FTR_OUT,'w')
Write_Feature_Rules(FTS_THRS,Fil)
Fil.close()
print("[!] Export Feature Rules : DONE")
