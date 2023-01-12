#ifndef __HEADERS__
#define __HEADERS__

#include "codex/enum.p4"
#include "codex/l2.p4"
#include "codex/l3.p4"
#include "codex/l4.p4"
#include "codex/l567.p4"

#define CPU_PORT 255

// packet in
@controller_header("packet_in")
header packet_in_header_t {
	bit<16> algo_indicator;
    bit<32> src_ip;
    bit<32> dst_ip;
    bit<16> src_port;
    bit<16> dst_port;
    bit<8>  proto;
    bit<32> siz;
    bit<32> count;
    bit<48> iat;
    bit<16> class;
    bit<16> ingress_port;
}

// packet out
@controller_header("packet_out")
header packet_out_header_t {
    bit<16> egress_port;
    bit<16> mcast_grp;
}

// header struct for packet
struct headers_t {
    packet_out_header_t     packet_out;
    packet_in_header_t      packet_in;
    ethernet_t              ethernet;
    ipv4_t                  ipv4;
    tcp_t                   tcp;
    udp_t                   udp;
}

// metadata inside switch pipeline
struct metadata_t {
    bit<16> l4_src_port;
    bit<16> l4_dst_port;
    bit<1>  l3_admit;
    bit<12> dst_vlan;
    bit<1>  overflow_flag;
    bit<32> siz;
    bit<32> count;
    bit<48> iat;
    bit<16> class;
    bit<1>  send_cont;
}

struct tracking_metadata_t {

	// Cf Registers
	bit<32> mIndex;
	bit<64> mKeyCarried;
	bit<64> mKeyInTable;
	bit<48> mFrstTimeInTable;
	bit<64> mSwapSpace;
	bit<1> mEndWin;

	// UPDATE, cf Given Direction
	bit<12> mNbElemInTable;
	bit<32> mSumSzeInTable;
	bit<32> mSumSzeDltInTable;
	bit<32> mLstMuSze;
	bit<48> mLastTimeInTable;
	bit<48> mSumIatDltInTable;
	bit<48> mLstMuIat;

	// Temporal Division
	bit<32> mMeanSZ;
    bit<32> mStdSZ;
	bit<48> mMeanIAT;
	bit<48> mStdIAT;

	// FEATURES DOWN DT
	bit<32> mDWMeanSZ;
    bit<32> mDWStdSZ;
	bit<48> mDWMeanIAT;
	bit<48> mDWStdIAT;
	bit<32> mDWSum;
	bit<12> mDWNb;
	// INDEXES DOWN DT
	bit<6> actionFt0;
	bit<6> actionFt1;
	bit<6> actionFt2;
	bit<6> actionFt3;
	bit<6> actionFt4;
	bit<6> actionFt5;

	// FEATURES UP DT
	bit<32> mUPMeanSZ;
    bit<32> mUPStdSZ;
	bit<48> mUPMeanIAT;
    bit<48> mUPStdIAT;
	bit<32> mUPSum;
	bit<12> mUPNb;
	// INDEXES UP DT
	bit<6> actionFt6;
	bit<6> actionFt7;
	bit<6> actionFt8;
	bit<6> actionFt9;
	bit<6> actionFt10;
	bit<6> actionFt11;

	// RESULT
	bit<1> is_CG;

}


#endif
