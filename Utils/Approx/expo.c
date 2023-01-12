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

// Run program from `Utils/Approx`

# include <stdio.h>
# include <stdlib.h>
# define VALMAX 10000
# define MAXSUM 3
# define PREC 0.95
const char* CSV_FIL="./Out.csv";



int Read_Value(){
  int Read;
  printf(">> Type the maximum number of packets per temporal window (33ms): ");
  scanf("%d",&Read);
  if(Read<1 || Read > VALMAX){
    printf("[!] Too much packets \n");
    printf("[!] Exiting...\n");
    exit(0);
  }
  return Read;
}


int* Handle_Element(int elem, int* ExpPow2Gen, int *Pow2Gen,double *SumPrec){

  // Update Power 2
  if(*Pow2Gen<elem){
    (*ExpPow2Gen)++;
    *Pow2Gen*=2;
  }

  // First Inverse of 2
  int* Tab=calloc(MAXSUM,sizeof(int));
  Tab[0]=*ExpPow2Gen;
  int nbSum=1;

  // Current Values
  double sum=(double)1/(*Pow2Gen);
  double prec=(double)sum/((double)1/elem);
  int Pow2Loc=*Pow2Gen*2;
  int ExpPow2Loc=*ExpPow2Gen+1;

  // Add elements to sum
  while(nbSum<MAXSUM && prec<PREC){
    // If can add inverse current power of two
    if(sum + (double)1/Pow2Loc <= (double) 1/elem){
      Tab[nbSum++]=ExpPow2Loc;
      sum+=(double)1/Pow2Loc;
      prec=sum/((double)1/elem);
    }
    // Next Power
    Pow2Loc*=2;
    ExpPow2Loc++;
  }

  // Update Precision
  *SumPrec+=prec;

  return Tab;
}


void Display_Tab(int ** tab,int nbElem){
  printf("\n>> Display Table :");
  printf("\n\t-i=1 1/(2^0)");
  for(int i=1 ; i<nbElem ; i++){
    printf("\n\t-i=%d ",i+1);
    for(int j=0 ; j<MAXSUM ; j++){
      if(tab[i][j]!=0){
        printf("1/(2^%d) ",tab[i][j]);
      }
    }
  }
}


void Export_CSV(int** tab, int nbelem){
  printf("\n>> Export CSV : DONE");
  FILE* fp;
  fp=fopen(CSV_FIL,"w");
  if(fp==NULL){
    printf("[!] File CSV_FIL can't be opened\n");
    printf("[!] Exiting...\n");
    exit(0);
  }

  fprintf(fp,"1 0 ");
  for(int i=1 ; i<nbelem ; i++){
    fprintf(fp,"\n%d ",i+1);
    for(int j=0;j<MAXSUM;j++){
      if(tab[i][j]!=0){
        fprintf(fp,"%d ",tab[i][j]);
      }
    }
  }

  fclose(fp);
}


void Free_Tab(int ** tab,int nbElem){
  for(int i=0 ; i<nbElem ; i++){
    free(tab[i]);
  }
  free(tab);
}




int main(){

  // Read Value
  int nb=Read_Value();

  // Handle elements from 1 to 'Value'
  int** res=(int**)malloc(sizeof(int*)*nb);
  int Pow2Gen=1;
  int ExpPow2Gen=0;
  double SumPrec=0;
  for(int i=1; i<= nb ; i++){
    res[i-1]=Handle_Element(i,&ExpPow2Gen,&Pow2Gen,&SumPrec);
  }

  // Display Results
  // Display_Tab(res,nb);

  // Save Results : CSV
  Export_CSV(res,nb);

  // Free Memory
  printf("\n\n>> End of the Program. Mean precision = %lf\n",(double)SumPrec/nb);
  Free_Tab(res,nb);
}
