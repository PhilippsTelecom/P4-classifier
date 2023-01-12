# Loading Rules


----


## Licence
- :office: This work is part of the [MOSAICO PROJECT](https://www.mosaico-project.org/)
- :fr: Copyright (c) 2022 [Centre National de la Recherche Scientifique](https://cnrs.fr). All Rights Reserved.
- :black_nib: Author: GRAFF Philippe
- :link: The DT classifier has been trained thanks to `pcap` traces available on this website [link](https://cloud-gaming-traces.lhs.loria.fr/).


----


## Objective
- Loads the ML model (DT)
- Displays the DT (<em>graphviz</em>)
- Loads the Thresholds (:point_right: <em> Feature Rules </em>)
- Write the rules for each leaf (:point_right: <em> Action rules </em>)
- Both rules will be loaded by the **P4 Controller**


----


## Feature Rules
- CSV File (<em> FTR_Ruls.csv </em>)
- One line per feature
- How to read it : `N° Feature, 0, thresholds, Max `
- The value Max is hardcoded in : <em>FTS_MAX</em>
- Power of Two that bounds the current feature
- All the features don't have the same number of columns

| Feature      | Threshold 1  | Threshold2 | ...  |
|--------------|-----------   |------------|------|
| F1           | 0            | F<sub>11</sub>        | ...  |
| F2           | 0            | F<sub>21</sub>        | ...  |


----


## Action Rules
- CSV File (<em> ACT_Ruls.csv </em>)
- One line per leaf
- Recap the conditions to reach that leaf
- How to read it : `Class, Conditions`
- Concerning the **Conditions** :
  - 3 fields per feature
  - `Idf Feature, Index1, Index2`
- Both indexes give the lower & upper Bounds of the feature

| Class  | Feat  | Feat min | Feat Max  |  ...|
|------- |-------|------    |-----      |-----|
| CG     | 1     | Ind<sub>1,1,m</sub>      | Ind<sub>1,1,M</sub>      |     |
| NOT_CG | 4     | Ind<sub>2,4,m</sub>        | Ind<sub>2,4,M</sub>       | ... |
| ...    | ...   | ...      | ...       | ... |

Ind<sub>a,b,c</sub> :
- a: stands for the <em>leaf</em>
- b: stands for the <em>feature</em>
- c: if it's the <em>lower</em> or <em>upper</em> bound


----


## Example
| Feature      | Thr1  | Thr2 | Thr3  | Thr4  |Thr5   |
|--------------|-----  |----- |------ |------ |-------|
**Index** | **0** | **1** | **2** | **3** | **4**
| F1           | 0     | 10   | 20    | 40    |   70  |


For a given leaf, if for `F1` we have:
-  ~~F1 > 10~~
- F1 > 20
- F1 <= 70

So our Indexes would be:
- Ind<sub>m</sub> = **3**
- Ind<sub>M</sub> = **4**


----


## How it works
- The path to the ML model & to the Output is constant
- Once the model is trained, just call `python3 dum2cond.py`


----


Made with :heart: by GRAFF Philippe
