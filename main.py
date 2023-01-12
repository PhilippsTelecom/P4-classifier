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


from p4app import P4Mininet
from mininet.topo import Topo
from threading import Thread # Mininet & Check
from scapy.utils import inet_ntoa # Print IP addr

PLY="10.1.0.1" # 10.1 préfixe pour idf client 0a010001 H1
# PREFIX=0x0A01 # Préfixe pour reco client (10.1)
PREFIX=0xC0A8 # Préfixe pour reco client (192.168 : tcpreplay)
SRV="10.0.0.2" # 0a000002 H2
OTH="10.0.0.3"




"""
    TOPOLOGY
    OKAY
"""
class MyTopo(Topo):
    """
        One switch between two hosts
    """
    def __init__(self, **opts):
        Topo.__init__(self, **opts)

        switch=self.addSwitch('s1')
        host1 = self.addHost('h1',ip = PLY,mac = '00:00:00:00:00:01')
        self.addLink(host1, switch, port1=0,port2=1)
        host2 = self.addHost('h2',ip= SRV,mac="00:00:00:00:00:02")
        self.addLink(host2,switch, port1=0,port2=2)
        host3 = self.addHost('h3',ip= OTH,mac="00:00:00:00:00:03")
        self.addLink(host3,switch, port1=0,port2=3)

topo = MyTopo()
net = P4Mininet(program='My.p4', topo=topo)
net.start()




"""
    VARIOUS TABLES : KNOW DIRECTION - FORWARDING
    OKAY
"""
# WORK ON THE SWITCH : PARAMETERS
sw = net.get('s1')


# TABLE TO KNOW DIRECTION
sw.insertTableEntry(table_name='basic_tutorial_ingress.Direc',
                    match_fields={'hdr.ipv4.srcAddr[31:16]':PREFIX},
                    action_name='basic_tutorial_ingress.src_CLT')


# TABLE TO FORWARD to the host connected to this switch
sw.insertTableEntry(table_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_lpm',
                    match_fields={'hdr.ipv4.dstAddr': PLY},
                    action_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_forward',
                    action_params={'dstAddr': '00:00:00:00:00:01','port':1})
sw.insertTableEntry(table_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_lpm',
                    match_fields={'hdr.ipv4.dstAddr': SRV},
                    action_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_forward',
                    action_params={'dstAddr': '00:00:00:00:00:02','port':2})
sw.insertTableEntry(table_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_lpm',
                    match_fields={'hdr.ipv4.dstAddr': OTH},
                    action_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_forward',
                    action_params={'dstAddr': '00:00:00:00:00:03','port':3})
# Otherwise send the packet clockwise
sw.insertTableEntry(table_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_lpm',
                    default_action=True,
                    action_name='basic_tutorial_ingress.ipv4_forwarding.ipv4_forward',
                    action_params={'dstAddr': '00:00:00:00:00:00', # the last hop will set this correctly
                                      'port': 2})




"""
    TABLES TO APPROXIMATE DIVISION
    INVERT POW 2
    OKAY
"""
# TABLE TO APPROX DIVISION
import csv
DIR="/p4app"
APPROX_FILE=DIR+"/Utils/Approx/Out.csv"
MAXSUM=3

def write_appr_switch(Range,Powers,switch,prio):
    # One Direction
    if Powers!=[0,0,0]:
        #print(Range)
        #print(Powers)
        #print("\n")
        switch.insertTableEntry(table_name='basic_tutorial_ingress.Divide1',
                            priority=prio,
                            match_fields={'track_meta.mNbElemInTable':[Range[0],Range[1]]},
                            action_name='basic_tutorial_ingress.Pow',
                            action_params={'powera': Powers[0],'powerb': Powers[1],'powerc': Powers[2]}
                            )
        # Other direction
        sw.insertTableEntry(table_name='basic_tutorial_ingress.Divide2',
                        priority=prio,
                        match_fields={'track_meta.mNbElemInTable':[Range[0],Range[1]]},
                        action_name='basic_tutorial_ingress.Pow',
                        action_params={'powera': Powers[0],'powerb': Powers[1],'powerc': Powers[2]}
                        )

def write_appr_rule(File,switch):
    with open(File,newline='') as csvfile:
        reader=csv.reader(csvfile,delimiter=' ')
        # To Save
        prio=1
        oldPow=[0,255,255]
        Range=(1,1)
        for row in reader:
            # Retrieve Values
            row=row[:-1]
            elem=int(row[0])
            pow=row[1:len(row)]
            pow=[int(i) for i in pow]
            pow=pow+[255 for i in range(len(pow),MAXSUM)]

            # Same representation
            if pow==oldPow:
                Range=(Range[0],elem)
            else:
                write_appr_switch(Range,[e for e in oldPow],switch,prio)
                oldPow=pow
                Range=(elem,elem)
                prio+=1
        if oldPow!=[0,0,0]:
            write_appr_switch(Range,[e for e in pow],switch,prio)

write_appr_rule(APPROX_FILE,sw)




"""
    FEATURE RULES
    DT
"""
FEAT_RUL=DIR+"/Utils/LoadRulesDT/FTR_Ruls.csv"
FTS={0:"mDWMeanSZ",1:"mDWStdSZ",2:"mDWMeanIAT",3:"mDWStdIAT",4:"mDWSum",5:"mDWNb",
6:"mUPMeanSZ",7:"mUPStdSZ",8:"mUPMeanIAT",9:"mUPStdIAT",10:"mUPSum",11:"mUPNb"}


def write_ftr_switch(numFeat,thr1,thr2,ind,switch):
    switch.insertTableEntry(table_name='basic_tutorial_ingress.Feat%sruls'%numFeat,
                        priority=int(numFeat)+1,
                        match_fields={'track_meta.%s'%(FTS[int(numFeat)]):[int(thr1),int(thr2)]},
                        action_name='basic_tutorial_ingress.setIndex%s'%numFeat,
                        action_params={'index':int(ind)}
                        )


def write_feat_rule(File,switch):
    with open(File,newline='') as csvfile:
        reader=csv.reader(csvfile,delimiter=',')
        for row in reader:# Browse Features
            feat=row[0]
            thrs=row[1:]
            index=1
            for i in range(1,len(thrs)):
                write_ftr_switch(feat,thrs[i-1],thrs[i],index,switch)
                index+=1


write_feat_rule(FEAT_RUL,sw)




"""
    ACTION RULES
    DT
"""
ACT_RUL=DIR+"/Utils/LoadRulesDT/ACT_Ruls.csv"


def write_act_switch(TypTraf,Conditions,prio,switch):
    switch.insertTableEntry(table_name='basic_tutorial_ingress.ActRules',
                        priority=prio,
                        match_fields=Conditions,
                        action_name='basic_tutorial_ingress.Set_Traffic',
                        action_params={'CG':int(TypTraf)}
                        )


def write_act_rule(File,switch):
    with open(File,newline='') as csvfile:
        reader=csv.reader(csvfile,delimiter=',')
        prio=1
        for row in reader:# Browse leafs
            match_fields={}
            traf=row[0]
            for i in range(1,len(row)-1,3):
                feat=row[i]
                indm=row[i+1]
                indM=row[i+2]
                match_fields['track_meta.actionFt%s'%feat]=[int(indm),int(indM)]
            write_act_switch(traf,match_fields,prio,switch)
            prio+=1


write_act_rule(ACT_RUL,sw)




"""
    RETRIEVE VALUES
"""
# Recap
# sw.printTableEntries()
import logging
logging.basicConfig(filename='./logs/' + 'out.log', level=logging.DEBUG)
# Start the mininet CLI to interactively run commands in the network:
from mininet.cli import CLI



# Threads
#print("Start : Threading...")
t1 = Thread(target=lambda: CLI(net))
t1.start()
