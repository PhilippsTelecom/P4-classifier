#ifndef __IPV4_FORWARD__
#define __IPV4_FORWARD__

#include "headers.p4"
#include "actions.p4"

control ipv4_forwarding(
    inout headers_t hdr,
    inout metadata_t metadata,
    inout standard_metadata_t standard_metadata
){

    action ipv4_forward(bit<48> dstAddr, bit<9> port){
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        if(hdr.ipv4.isValid()){
            if(standard_metadata.ingress_port == CPU_PORT){
                standard_metadata.egress_spec = (bit<9>)hdr.packet_out.egress_port;
                standard_metadata.mcast_grp = hdr.packet_out.mcast_grp;
                hdr.packet_out.setInvalid();
            } else {
                ipv4_lpm.apply();
            }

        }
    }
}

#endif
