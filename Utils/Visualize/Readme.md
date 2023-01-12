# Visualize


----


## Licence
- :office: This work is part of the [MOSAICO PROJECT](https://www.mosaico-project.org/)
- :fr: Copyright (c) 2022 [Centre National de la Recherche Scientifique](https://cnrs.fr). All Rights Reserved.
- :black_nib: Author: GRAFF Philippe
- :link: The DT classifier has been trained thanks to `pcap` traces available on this website [link](https://cloud-gaming-traces.lhs.loria.fr/).


----


## Objective
- Retrieve values extracted with P4
- `FtsFromLog.sh` reads P4's log file (`p4s.s1.log`)
- Edits `out.csv`
  - One line per extracted window
  - 6x2=12 features per window + 2 fields

| Mean SZ | Std SZ | Mean IAT | Std IAT | Total Size | Nb Packets |
|-|-|-|-|-|-|

| Classif | Idf Conv |
|-|-|

- `Percent.awk` computes the % of reports labelled "CG"
- `GetGraphs.py` displays these features as boxplots (12: 1 per feature)


----


## P4 Program
- In the P4 program, **4** dedicated registers
- Registers `Write1Bit`, `Write12Bits`,`Write32Bits`, `Write48Bits` (just to **visualize**)
- Once we reach the end of a window for a conversation
- Compute the 12 features
- Write these features to these 3 **registers**
- Write the identifier and the classification result
- Makes appear the data in the log file


----


## How it works
- Run the P4 program (`make`, `make h1` in <em>P4FlowClass</em>)
- Launch some trafic: `./Host.sh INTERF PCAP`
  - `INTERF`: the network interface, *e.g eth0*
  - `PCAP`: path to the PCAP file, (*Data/*)
  - Traffic is launched from the **host (h1)** (*SRV & CLT*)
- Then launch the script `FtsFromLog.sh`
  - You will be asked to type an identifier
  - Focus on a specific conversation
  - Take the most frequent identifier (*see out.csv*)
- The graphs are in the folder <em>Out/</em>
- The  terminal prompts the percentage of reports categorized CG


----


Made with :heart: by GRAFF Philippe
