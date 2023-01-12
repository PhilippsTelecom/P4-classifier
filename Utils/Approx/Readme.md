# Approximation


----


## Licence
- :office: This work is part of the [MOSAICO PROJECT](https://www.mosaico-project.org/)
- :fr: Copyright (c) 2022 [Centre National de la Recherche Scientifique](https://cnrs.fr). All Rights Reserved.
- :black_nib: Author: GRAFF Philippe
- :link: The DT classifier has been trained thanks to `pcap` traces available on this website [link](https://cloud-gaming-traces.lhs.loria.fr/).


----


## Objective
- Edit a CSV file to approximate a division (*Out.csv*)
- :point_right: Approximates 1/Y with reverse power of two
- `MAXSUM` stands for the maximum number of reverse power of 2


----


## How to read the CSV File
- Each line stands for a value of Y (1/Y)
- First element: value of Y
- Then: we have got 1 to `MAXSUM` values
| 17 |5 | 6 | 7 |
|-|-|-|-|
- :point_right: means that 1/17 ~ (1/2)<sup>5</sup> + (1/2)<sup>6</sup> + (1/2)<sup>7</sup>
- :point_right: and so X/17 ~ X>>5 + X>>6 + X>>7
- We have Y<sub>Max</sub> lines
|  Y<sub>Max</sub> |a | b | c |
|-|-|-|-|


----


## How it works
- In the folder *Approx*, just type `make`
- Then, type `./a.out`
- You will be asked to type a number (Y<sub>Max</sub>)
- Type **4095** (=2<sup>12</sup>, *that's what the P4 controller waits for*)
- The mean precision is approx 97% :thumbsup:


----


Made with :heart: by GRAFF Philippe
