// Copyright (c) 2022 Centre National de la Recherche Scientifique All Rights Reserved.
//
// This file is part of MOSAICO PROJECT.
//
// MOSAICO PROJECT is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MOSAICO PROJECT is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MOSAICO PROJECT. See the file COPYING.  If not, see <http://www.gnu.org/licenses/>.


/*
    Basic P4 switch program for tutor. (with simple functional support)
*/
#include <core.p4>
#include <v1model.p4>

#include "includes/headers.p4"
//#include "includes/actions.p4"
#include "includes/checksums.p4"
#include "includes/parser.p4"

// application
#include "includes/ipv4_forward.p4"
#include "includes/packetio.p4"
#define WIN_SZE 33000 // CSTE 33 ms = 33 000 microsecs


//------------------------------------------------------------------------------
// INGRESS PIPELINE
//------------------------------------------------------------------------------
control basic_tutorial_ingress(
    inout headers_t hdr,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata
){

    // Registers GEN
    register<bit<64>>(1024) flow_tracker; // Cf Keys
    register<bit<48>>(1024) flow_frst_time;


    // Registers DOWN
    register<bit<12>>(1024) DW_Nbelem; // NbElems
    register<bit<32>>(1024) DW_Sum_SZE;
    register<bit<32>>(1024) DW_Dlt_SZE; // (val-old-MU)**2
    register<bit<32>>(1024) DW_Lst_Mu_SZE; // Last mean for SZE
    register<bit<48>>(1024) DW_flow_tst;
    register<bit<48>>(1024) DW_Dlt_IAT; // (val-old-MU)**2
    register<bit<48>>(1024) DW_Lst_Mu_IAT; // Last mean for IAT


    // Registers UP
    register<bit<12>>(1024) UP_Nbelem; // NbElems
    register<bit<32>>(1024) UP_Sum_SZE;
    register<bit<32>>(1024) UP_Dlt_SZE; // (val-old-MU)**2
    register<bit<32>>(1024) UP_Lst_Mu_SZE; // Last mean for SZE
    register<bit<48>>(1024) UP_flow_tst;
    register<bit<48>>(1024) UP_Dlt_IAT; // (val-old-MU)**2
    register<bit<48>>(1024) UP_Lst_Mu_IAT; // Last mean for IAT


    // REGISTER DEBUG : TEMPORARY
    register<bit<12>>(1024) Write12Bits;
    register<bit<32>>(1024) Write32Bits;
    register<bit<48>>(1024) Write48Bits;
    register<bit<1>>(1024) Write1Bit;

    // Meta
    tracking_metadata_t track_meta; // Cf Header.p4

    // Read From Packet
    bit<32> siz; // Current SZE
    bit<48> arrival_time; // Current TIMST
    // Computed
    bit<12> nbElem;
    bit<32> sumSze;
    bit<32> sumSzeDlt;
    bit<48> sumIatDlt;
    bit<48> inter_arrival_time; // Computed IAT



    // KNOW TRAFFIC DIRECTION
    bool up=false;
     action src_CLT(){
        up=true;
    }
    table Direc {
        key = {
            hdr.ipv4.srcAddr[31:16]: exact;// IP src in LAN
        }
        actions = {src_CLT;}
    }



    // ACTIONS DIVIDE
    action Pow(bit<8> powera,bit<8> powerb, bit<8> powerc){
        track_meta.mMeanSZ=(track_meta.mSumSzeInTable>>powera) + (track_meta.mSumSzeInTable>>powerb) + (track_meta.mSumSzeInTable>>powerc);
        track_meta.mStdSZ=(track_meta.mSumSzeDltInTable>>powera)+(track_meta.mSumSzeDltInTable>>powerb)+(track_meta.mSumSzeDltInTable>>powerc);
        bit<48> WinS=WIN_SZE;
        track_meta.mMeanIAT=(WinS>>powera)+(WinS>>powerb)+(WinS>>powerc);
        track_meta.mStdIAT=(track_meta.mSumIatDltInTable>>powera)+(track_meta.mSumIatDltInTable>>powerb)+(track_meta.mSumIatDltInTable>>powerc);
    }
    // Direc 1
    table Divide1 {
        key = {
            track_meta.mNbElemInTable:range;
        }
        actions = {Pow;}
    }
    // Direc 2
    table Divide2 {
        key = {
            track_meta.mNbElemInTable:range;
        }
        actions = {Pow;}
    }




    // FEATURES RULES
    // DW
    action setIndex0(bit<6> index){
        track_meta.actionFt0=index;
    }
    table Feat0ruls{
        key={
            track_meta.mDWMeanSZ:range;
        }
        actions={setIndex0;}
    }
    action setIndex1(bit<6> index){
        track_meta.actionFt1=index;
    }
    table Feat1ruls{
        key={
            track_meta.mDWStdSZ:range;
        }
        actions={setIndex1;}
    }
    action setIndex2(bit<6> index){
        track_meta.actionFt2=index;
    }
    table Feat2ruls{
        key={
            track_meta.mDWMeanIAT:range;
        }
        actions={setIndex2;}
    }
    action setIndex3(bit<6> index){
        track_meta.actionFt3=index;
    }
    table Feat3ruls{
        key={
            track_meta.mDWStdIAT:range;
        }
        actions={setIndex3;}
    }
    action setIndex4(bit<6> index){
        track_meta.actionFt4=index;
    }
    table Feat4ruls{
        key={
            track_meta.mDWSum:range;
        }
        actions={setIndex4;}
    }
    action setIndex5(bit<6> index){
        track_meta.actionFt5=index;
    }
    table Feat5ruls{
        key={
            track_meta.mDWNb:range;
        }
        actions={setIndex5;}
    }
    // UP
    action setIndex6(bit<6> index){
        track_meta.actionFt6=index;
    }
    table Feat6ruls{
        key={
            track_meta.mUPMeanSZ:range;
        }
        actions={setIndex6;}
    }
    action setIndex7(bit<6> index){
        track_meta.actionFt7=index;
    }
    table Feat7ruls{
        key={
            track_meta.mUPStdSZ:range;
        }
        actions={setIndex7;}
    }
    action setIndex8(bit<6> index){
        track_meta.actionFt8=index;
    }
    table Feat8ruls{
        key={
            track_meta.mUPMeanIAT:range;
        }
        actions={setIndex8;}
    }
    action setIndex9(bit<6> index){
        track_meta.actionFt9=index;
    }
    table Feat9ruls{
        key={
            track_meta.mUPStdIAT:range;
        }
        actions={setIndex9;}
    }
    action setIndex10(bit<6> index){
        track_meta.actionFt10=index;
    }
    table Feat10ruls{
        key={
            track_meta.mUPSum:range;
        }
        actions={setIndex10;}
    }
    action setIndex11(bit<6> index){
        track_meta.actionFt11=index;
    }
    table Feat11ruls{
        key={
            track_meta.mUPNb:range;
        }
        actions={setIndex11;}
    }



    // ACTION RULES DICTIONARY
    action Set_Traffic(bit<1> CG){
        track_meta.is_CG=CG;
    }
    table ActRules{

        key={

            // DOWN
            track_meta.actionFt0:range;
            track_meta.actionFt1:range;
            track_meta.actionFt2:range;
            track_meta.actionFt3:range;
            track_meta.actionFt4:range;
            track_meta.actionFt5:range;
            // UP
            track_meta.actionFt6:range;
            track_meta.actionFt7:range;
            track_meta.actionFt8:range;
            track_meta.actionFt9:range;
            track_meta.actionFt10:range;
            track_meta.actionFt11:range;

        }

        actions={Set_Traffic;}
    }




    // Hachage niveau flux
    action gen_hash(bit<32> ipAddr1, bit<32> ipAddr2){

        // Packet TIMST
        arrival_time = standard_metadata.ingress_global_timestamp;

        // Compute Hash : -> mIndex and compute KEY (concat) 1024 est le Max du Hash
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, ipAddr2}, (bit<32>)1024);
        track_meta.mKeyCarried = (bit<64>)(hdr.ipv4.srcAddr++hdr.ipv4.dstAddr);

        // Check if collision or end of window
        flow_tracker.read(track_meta.mKeyInTable, track_meta.mIndex);
        flow_frst_time.read(track_meta.mFrstTimeInTable, track_meta.mIndex);
        track_meta.mSwapSpace = (track_meta.mKeyInTable - track_meta.mKeyCarried)*track_meta.mKeyInTable; // COLLISION <=> !=0
        track_meta.mEndWin =  ( (track_meta.mFrstTimeInTable != 0 && arrival_time - track_meta.mFrstTimeInTable > WIN_SZE) ? (bit<1>)1 : (bit<1>)0 );

        // Collision or End Window or Frst : update start
        flow_frst_time.write(track_meta.mIndex,((track_meta.mSwapSpace == 0 && track_meta.mEndWin == 0 && track_meta.mFrstTimeInTable != 0) ? track_meta.mFrstTimeInTable : arrival_time  ));
    }




    // NOT END WINDOW
    action updateDOWN(){
        siz = (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());
        arrival_time = standard_metadata.ingress_global_timestamp;

        // READ Values :
        DW_Nbelem.read(track_meta.mNbElemInTable, track_meta.mIndex);
        DW_Sum_SZE.read(track_meta.mSumSzeInTable, track_meta.mIndex);
        DW_Dlt_SZE.read(track_meta.mSumSzeDltInTable, track_meta.mIndex);// (xi-MU)**2
        DW_flow_tst.read(track_meta.mLastTimeInTable, track_meta.mIndex);
        DW_Dlt_IAT.read(track_meta.mSumIatDltInTable, track_meta.mIndex);// (xi-MU)**2
        // Last Means : 2
        DW_Lst_Mu_SZE.read(track_meta.mLstMuSze, track_meta.mIndex);
        DW_Lst_Mu_IAT.read(track_meta.mLstMuIat, track_meta.mIndex);


        // UPDATING
        nbElem=track_meta.mNbElemInTable+1;
        sumSze=track_meta.mSumSzeInTable+siz;
        inter_arrival_time= (track_meta.mLastTimeInTable != 0) ? arrival_time - track_meta.mLastTimeInTable : 0;// IAT if >= 2 elements
        // if not first flow window
        sumSzeDlt=(track_meta.mLstMuSze != 0) ? track_meta.mSumSzeDltInTable + (siz-track_meta.mLstMuSze)*(siz-track_meta.mLstMuSze) : 0;
        sumIatDlt=(track_meta.mLstMuIat != 0 && inter_arrival_time != 0) ? track_meta.mSumIatDltInTable + (inter_arrival_time-track_meta.mLstMuIat)*(inter_arrival_time-track_meta.mLstMuIat) : 0;


        // UPDATE Values
        DW_Nbelem.write(track_meta.mIndex,nbElem);
        DW_Sum_SZE.write(track_meta.mIndex,sumSze);
        DW_Dlt_SZE.write(track_meta.mIndex,sumSzeDlt);// (xi-MU)**2
        DW_flow_tst.write(track_meta.mIndex,arrival_time);
        DW_Dlt_IAT.write(track_meta.mIndex,sumIatDlt);// (xi-MU)**2
    }

    action updateUP(){
        siz = (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());
        arrival_time = standard_metadata.ingress_global_timestamp;

        // READ Values :
        UP_Nbelem.read(track_meta.mNbElemInTable, track_meta.mIndex);
        UP_Sum_SZE.read(track_meta.mSumSzeInTable, track_meta.mIndex);
        UP_Dlt_SZE.read(track_meta.mSumSzeDltInTable, track_meta.mIndex);// (xi-MU)**2
        UP_flow_tst.read(track_meta.mLastTimeInTable, track_meta.mIndex);
        UP_Dlt_IAT.read(track_meta.mSumIatDltInTable, track_meta.mIndex);// (xi-MU)**2
        // Last Means : 2
        UP_Lst_Mu_SZE.read(track_meta.mLstMuSze, track_meta.mIndex);
        UP_Lst_Mu_IAT.read(track_meta.mLstMuIat, track_meta.mIndex);


        // UPDATING
        nbElem=track_meta.mNbElemInTable+1;
        sumSze=track_meta.mSumSzeInTable+siz;
        inter_arrival_time= (track_meta.mLastTimeInTable != 0) ? arrival_time - track_meta.mLastTimeInTable : 0;// IAT if >= 2 elements
        // if not first flow window
        sumSzeDlt=(track_meta.mLstMuSze != 0) ? track_meta.mSumSzeDltInTable + (siz-track_meta.mLstMuSze)*(siz-track_meta.mLstMuSze) : 0;
        sumIatDlt=(track_meta.mLstMuIat != 0 && inter_arrival_time != 0) ? track_meta.mSumIatDltInTable + (inter_arrival_time-track_meta.mLstMuIat)*(inter_arrival_time-track_meta.mLstMuIat) : 0;


        // UPDATE Values
        UP_Nbelem.write(track_meta.mIndex,nbElem);
        UP_Sum_SZE.write(track_meta.mIndex,sumSze);
        UP_Dlt_SZE.write(track_meta.mIndex,sumSzeDlt);// (xi-MU)**2
        UP_flow_tst.write(track_meta.mIndex,arrival_time);
        UP_Dlt_IAT.write(track_meta.mIndex,sumIatDlt);// (xi-MU)**2
    }




    // WHEN END WINDOW OR COLLISION
    action initDOWN(){
        siz = (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());

        DW_Nbelem.write(track_meta.mIndex,(bit<12>)1);
        DW_Sum_SZE.write(track_meta.mIndex,(bit<32>)siz);
        DW_flow_tst.write(track_meta.mIndex,(bit<48>)arrival_time);
        // STD SZE
        DW_Lst_Mu_SZE.read(track_meta.mLstMuSze, track_meta.mIndex);
        sumSzeDlt=(track_meta.mLstMuSze != 0) ? (siz-track_meta.mLstMuSze)*(siz-track_meta.mLstMuSze) : 0;
        DW_Dlt_SZE.write(track_meta.mIndex,(bit<32>)sumSzeDlt);
        // STD IAT
        DW_Dlt_IAT.write(track_meta.mIndex,(bit<48>)0);

        UP_Nbelem.write(track_meta.mIndex,(bit<12>)0);
        UP_Sum_SZE.write(track_meta.mIndex,(bit<32>)0);
        UP_Dlt_SZE.write(track_meta.mIndex,(bit<32>)0);
        UP_flow_tst.write(track_meta.mIndex,(bit<48>)0);
        UP_Dlt_IAT.write(track_meta.mIndex,(bit<48>)0);
    }

    action initUP(){
        siz = (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());

        UP_Nbelem.write(track_meta.mIndex,(bit<12>)1);
        UP_Sum_SZE.write(track_meta.mIndex,(bit<32>)siz);
        UP_flow_tst.write(track_meta.mIndex,(bit<48>)arrival_time);
        // STD SZE
        UP_Lst_Mu_SZE.read(track_meta.mLstMuSze, track_meta.mIndex);
        sumSzeDlt=(track_meta.mLstMuSze != 0) ? (siz-track_meta.mLstMuSze)*(siz-track_meta.mLstMuSze) : 0;
        UP_Dlt_SZE.write(track_meta.mIndex,(bit<32>)sumSzeDlt);
        // STD IAT
        UP_Dlt_IAT.write(track_meta.mIndex,(bit<48>)0);

        DW_Nbelem.write(track_meta.mIndex,(bit<12>)0);
        DW_Sum_SZE.write(track_meta.mIndex,(bit<32>)0);
        DW_Dlt_SZE.write(track_meta.mIndex,(bit<32>)0);
        DW_flow_tst.write(track_meta.mIndex,(bit<48>)0);
        DW_Dlt_IAT.write(track_meta.mIndex,(bit<48>)0);
    }




    // RETRIEVE  DATS META CLASSIF
    action retrieveDW(){

        DW_Nbelem.read(track_meta.mNbElemInTable,track_meta.mIndex);
        DW_Sum_SZE.read(track_meta.mSumSzeInTable,track_meta.mIndex);
        DW_Dlt_SZE.read(track_meta.mSumSzeDltInTable,track_meta.mIndex);
        DW_Dlt_IAT.read(track_meta.mSumIatDltInTable,track_meta.mIndex);

    }

    action retrieveUP(){

        UP_Nbelem.read(track_meta.mNbElemInTable,track_meta.mIndex);
        UP_Sum_SZE.read(track_meta.mSumSzeInTable,track_meta.mIndex);
        UP_Dlt_SZE.read(track_meta.mSumSzeDltInTable,track_meta.mIndex);
        UP_Dlt_IAT.read(track_meta.mSumIatDltInTable,track_meta.mIndex);

    }



/*

    action fill_meta(){
        metadata.send_cont = (bit<1>)1;
        metadata.siz = track_meta.mSizeCurrent;
        metadata.count = track_meta.mCountCurrent;
        metadata.iat = track_meta.mIatCurrent;
        metadata.class = class;
        classified.write(track_meta.mIndex, class);
    }
*/

/*
    action send_to_controller(bit<16> srcport, bit<16> dstport){
        hdr.packet_in.setValid();
        metadata.overflow_flag        = (bit<1>) 1;
        standard_metadata.egress_spec       = CPU_PORT;
        hdr.packet_in.ingress_port = (bit<16>)standard_metadata.ingress_port;
    }
*/
    apply {
        if (hdr.ipv4.isValid() && hdr.ipv4.ttl > 0) {//IP4 OKAY

            // Forwarding
            ipv4_forwarding.apply(hdr, metadata, standard_metadata);

            // First Filter : CG
             if (hdr.udp.isValid()){// UDP TRAFFIC

                 // Get to know direction
                 Direc.apply();

                 // Compute Hash & Window size
                 if (up){
                     gen_hash(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr);
                 }
                 else{
                     gen_hash(hdr.ipv4.dstAddr, hdr.ipv4.srcAddr);
                 }

                 // End Window OR Collision OR new element : init
                 if (track_meta.mEndWin == 1 || track_meta.mSwapSpace != 0 || track_meta.mFrstTimeInTable == 0){

                     if(track_meta.mEndWin == 1){// Retrieve Values Down & Up -> Metas

                         // FEATURES DOWN
                         retrieveDW();
                         track_meta.mDWMeanSZ=0;
                         track_meta.mDWStdSZ=0;
                         track_meta.mDWMeanIAT=0;
                         track_meta.mDWStdIAT=0;
                         track_meta.mDWSum=track_meta.mSumSzeInTable;
                         track_meta.mDWNb=track_meta.mNbElemInTable;
                         if(track_meta.mNbElemInTable>0){// More than One packet
                             Divide1.apply();
                             track_meta.mDWMeanSZ=track_meta.mMeanSZ;
                             track_meta.mDWStdSZ=track_meta.mStdSZ;
                             track_meta.mDWMeanIAT=track_meta.mMeanIAT;
                             track_meta.mDWStdIAT=track_meta.mStdIAT;
                         }
                         // DEBUG : SEE FEATURES DW
                         Write32Bits.write(track_meta.mIndex,track_meta.mDWMeanSZ);
                         Write32Bits.write(track_meta.mIndex,track_meta.mDWStdSZ);
                         Write48Bits.write(track_meta.mIndex,track_meta.mDWMeanIAT);
                         Write48Bits.write(track_meta.mIndex,track_meta.mDWStdIAT);
                         Write32Bits.write(track_meta.mIndex,track_meta.mDWSum); // SUM SZE
                         Write12Bits.write(track_meta.mIndex,track_meta.mDWNb); // NB PAKS
                         // Last Mean
                         DW_Lst_Mu_SZE.write(track_meta.mIndex,track_meta.mDWMeanSZ);
                         DW_Lst_Mu_IAT.write(track_meta.mIndex,track_meta.mDWMeanIAT);


                         // FEATURES UP
                         retrieveUP();
                         track_meta.mUPMeanSZ=0;
                         track_meta.mUPStdSZ=0;
                         track_meta.mUPMeanIAT=0;
                         track_meta.mUPStdIAT=0;
                         track_meta.mUPSum=track_meta.mSumSzeInTable;
                         track_meta.mUPNb=track_meta.mNbElemInTable;
                         if(track_meta.mNbElemInTable>0){// More than One Packet
                             Divide2.apply();
                             track_meta.mUPMeanSZ=track_meta.mMeanSZ;
                             track_meta.mUPStdSZ=track_meta.mStdSZ;
                             track_meta.mUPMeanIAT=track_meta.mMeanIAT;
                             track_meta.mUPStdIAT=track_meta.mStdIAT;
                         }
                         // DEBUG : SEE FEATURES UP
                         Write32Bits.write(track_meta.mIndex,track_meta.mUPMeanSZ);
                         Write32Bits.write(track_meta.mIndex,track_meta.mUPStdSZ);
                         Write48Bits.write(track_meta.mIndex,track_meta.mUPMeanIAT);
                         Write48Bits.write(track_meta.mIndex,track_meta.mUPStdIAT);
                         Write32Bits.write(track_meta.mIndex,track_meta.mUPSum); // SUM SZE
                         Write12Bits.write(track_meta.mIndex,track_meta.mUPNb); // NB PAKS
                         // Last Mean
                         UP_Lst_Mu_SZE.write(track_meta.mIndex,track_meta.mUPMeanSZ);
                         UP_Lst_Mu_IAT.write(track_meta.mIndex,track_meta.mUPMeanIAT);

                         // DEBUG : write idf conversation
                         Write32Bits.write(track_meta.mIndex,track_meta.mIndex);



                         // Compute Indexes
                         Feat0ruls.apply();
                         Feat1ruls.apply();
                         Feat2ruls.apply();
                         Feat3ruls.apply();
                         Feat4ruls.apply();
                         Feat5ruls.apply();
                         Feat6ruls.apply();
                         Feat7ruls.apply();
                         Feat8ruls.apply();
                         Feat9ruls.apply();
                         Feat10ruls.apply();
                         Feat11ruls.apply();
                         // Classify F(Indexes)
                         ActRules.apply();

                         // DEBUG : write if CG or NOT
                         Write1Bit.write(track_meta.mIndex,track_meta.is_CG);
                     }


                     if (up){// Init Uplink
                         initUP();
                     }
                     else{// Init Downlink
                         initDOWN();
                     }
                 }
                 else{

                      if (up){// Update Uplink
                          updateUP();
                      }
                      else{// Update Downlink
                          updateDOWN();
                      }

                 }



                 /*
                 if (end_window == (bit<1>)1) {
                     //classify_count_table.apply();
                     //classify_size_table.apply();
                     //classify_iat_table.apply();
                     if (class_diff == (bit<1>)1) {
                         fill_meta();
                     }

                     //send_to_classify((bit<16>)0);
                 }
                 if (metadata.send_cont == (bit<1>)1) {
                     send_to_controller(metadata.l4_src_port, metadata.l4_dst_port);
                 }
                 */


             }
        }
    }
}

//------------------------------------------------------------------------------
// EGRESS PIPELINE
//------------------------------------------------------------------------------
control basic_tutorial_egress(
    inout headers_t hdr,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata
){
    apply {
        // Pipelines in Egress
        packetio_egress.apply(hdr,metadata,standard_metadata);
    }
}

//------------------------------------------------------------------------------
// SWITCH ARCHITECTURE
//------------------------------------------------------------------------------
V1Switch(
    basic_tutor_switch_parser(),
    basic_tutor_verifyCk(),
    basic_tutorial_ingress(),
    basic_tutorial_egress(),
    basic_tutor_computeCk(),
    basic_tutor_switch_deparser()
) main;
