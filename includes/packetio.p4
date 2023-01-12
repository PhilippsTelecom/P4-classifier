#ifndef __PACKETIO__
#define __PACKETIO__

#include "headers.p4"

control packetio_ingress(inout headers_t hdr,
                         inout metadata_t metadata,
                         inout standard_metadata_t standard_metadata) {
    apply {
        if (standard_metadata.ingress_port == CPU_PORT) {
            standard_metadata.egress_spec = (bit<9>)hdr.packet_out.egress_port;
            hdr.packet_out.setInvalid();
            exit;
        }
    }
}

control packetio_egress(inout headers_t hdr,
                        inout metadata_t metadata,
                        inout standard_metadata_t standard_metadata) {
    apply {
        if (standard_metadata.egress_port == CPU_PORT) {
            hdr.packet_in.setValid();
            if (metadata.overflow_flag == (bit<1>) 1) {
                hdr.packet_in.algo_indicator =  (bit<16>) 3;
                hdr.packet_in.src_ip = hdr.ipv4.srcAddr;
                hdr.packet_in.dst_ip = hdr.ipv4.dstAddr;
                hdr.packet_in.proto = hdr.ipv4.protocol;
                hdr.packet_in.src_port = metadata.l4_src_port;
                hdr.packet_in.dst_port = metadata.l4_dst_port;
                hdr.packet_in.siz = metadata.siz;
                hdr.packet_in.count = metadata.count;
                hdr.packet_in.iat = metadata.iat;
                hdr.packet_in.class = metadata.class;
            }
            hdr.packet_in.ingress_port = (bit<16>)standard_metadata.ingress_port;
        }
    }
}

#endif