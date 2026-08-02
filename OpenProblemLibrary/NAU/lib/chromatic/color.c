/*
 * The author of this software is Michael Trick.  Copyright (c) 1994 by 
 * Michael Trick.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose without fee is hereby granted, provided that this entire notice
 * is included in all copies of any software which is or includes a copy
 * or modification of this software and in all copies of the supporting
 * documentation for such software.
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY.  IN PARTICULAR, NEITHER THE AUTHOR DOES NOT MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
 */

/*
   COLOR.C: Easy code for graph coloring
   Author: Michael A. Trick, Carnegie Mellon University, trick+@cmu.edu
   Last Modified: November 2, 1994


Graph is input in a file.  First line contains the number of nodes and
edges.  All following contain the node numbers (from 1 to n) incident to 
each edge.  Sample:

4 4
1 2
2 3
3 4
1 4

represents a four node cycle graph.

Code is probably insufficiently debugged, but may be useful to some people.

For more information on this code, see Anuj Mehrotra and Michael A. Trick,
"A column generation approach to graph coloring", GSIA Technical report series.

*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/times.h>

#define MAX_RAND (2.0*(1 << 30))
#define MAX_NODE 600
#define TRUE 1
#define FALSE 0
#define INF 100000.0

struct tms buffer;			/* structure for timing              */
int current_time,start_time;
double utime;

int adj[MAX_NODE][MAX_NODE];
int BestColoring;
int num_node;
int ColorClass[MAX_NODE];
int prob_count;
int Order[MAX_NODE];
int Handled[MAX_NODE];
int ColorAdj[MAX_NODE][MAX_NODE];
int ColorCount[MAX_NODE];
int lb;
int num_prob,max_prob;


int best_clique;


int greedy_clique(valid,clique)
int *valid,*clique;

{
  int i,j,k;
  int max;
  int place,done;
  int *order;
  int weight[MAX_NODE];
  
  for (i=0;i<num_node;i++) clique[i] = 0;
  order = (int *)calloc(num_node+1,sizeof(int));
  place = 0;
  for (i=0;i<num_node;i++) {
    if (valid[i]) {
      order[place] = i;
      place++;
    }
  }
  for (i=0;i<num_node;i++)
    weight[i] = 0;
  for (i=0;i<num_node;i++) 
    {
      if (!valid[i]) continue;
      for (j=0;j<num_node;j++) 
	{
	  if (!valid[j]) continue;
	  if (adj[i][j]) weight[i]++;
	}
    }
  

  done = FALSE;
  while (!done) {
    done = TRUE;
    for (i=0;i<place-1;i++) {
      j = order[i];
      k = order[i+1];
      if (weight[j] < weight[k]) {
	order[i] = k;
	order[i+1] = j;
	done = FALSE;
      }
    }
  }


  clique[order[0]] = TRUE;
  for (i=1;i<place;i++) {
    j = order[i];
    for (k=0;k<i;k++) {
      if (clique[order[k]] && !adj[j][order[k]]) break;
    }
    if (k==i) {
      clique[j] = TRUE;
    }
    else clique[j] = FALSE;
    
  }
  max = 0;
  for (i=0;i<place;i++) 
    if (clique[order[i]]) max ++;
  
  free(order);
/*  printf("Clique found of size %d\n",max);*/
  
  return max;
}

/* Target is a goal value:  once a clique is found with value target
   it is possible to return
   
   Lower is a bound representing an already found clique:  once it is
   determined that no clique exists with value better than lower, it
   is permitted to return with a suboptimal clique.

   Note, to find a clique of value 1, it is not permitted to just set
   the lower to 1:  the recursion will not work.  Lower represents a
   value that is the goal for the recursion.
*/

int max_w_clique(valid,clique,lower,target)
int *valid,*clique;
int lower,target;


{
  int start,j,k;
  int incumb,new_weight;
  int *valid1,*clique1;
  int *order;
  int *value;
  int i,place,finish,done,place1,place2;
  int total_left;
  
/*  printf("entered with lower %d target %d\n",lower,target);*/
  num_prob++;
  if (num_prob > max_prob) return -1;
  for (j=0;j<num_node;j++) clique[j] = 0;
  total_left = 0;
  for (i=0;i<num_node;i++)
    if (valid[i]) total_left ++;
  if (total_left < lower) {
    return 0.0;
  }

  order = (int *)calloc(num_node+1,sizeof(int));
  value = (int *) calloc(num_node,sizeof(int));
  incumb = greedy_clique(valid,clique);
  if (incumb >=target) return incumb;
  if (incumb > best_clique) {
    best_clique=incumb;
/*    printf("Clique of size %5d found.\n",best_clique);*/
  }
/*  printf("Greedy gave %f\n",incumb);*/
  
  place = 0;
  for (i=0;i<num_node;i++) {
    if (clique[i]) {
      order[place] = i;
      total_left --;
      place++;
    }
  }
  start = place;
  for (i=0;i<num_node;i++) {
    if (!clique[i]&&valid[i]) {
      order[place] = i;
      place++;
    }
  }
  finish = place;
  for (place=start;place<finish;place++) {
    i = order[place];
    value[i] = 0;
    for (j=0;j<num_node;j++) {
      if (valid[j] && adj[i][j]) value[i]++;
    }
  }

  done = FALSE;
  while (!done) {
    done = TRUE;
    for (place=start;place<finish-1;place++) {
      i = order[place];
      j = order[place+1];
      if (value[i] < value[j] ) {
	order[place] = j;
	order[place+1] = i;
	done = FALSE;
      }
    }
  }
  free(value);
  for (place=start;place<finish;place++) {
    if (incumb + total_left < lower) {
      return 0;
    }
    
    j = order[place];
    total_left --;
    
    if (clique[j]) continue;
    
    valid1 = (int *)calloc(num_node,sizeof(int));
    clique1 = (int *)calloc(num_node,sizeof(int));
    for (place1=0;place1 < num_node;place1++) valid1[place1] = FALSE;
    for (place1=0;place1<place;place1++) {
      k = order[place1];
      if (valid[k] && (adj[j][k])){
	valid1[k] = TRUE;
      }
      else
	valid1[k] = FALSE;
    }
    new_weight = max_w_clique(valid1,clique1,incumb-1,target-1);
    if (new_weight+1 > incumb)  {
/*      printf("Taking new\n");*/
      incumb = new_weight+1;
      for (k=0;k<num_node;k++) clique[k] = clique1[k];
      clique[j] = TRUE;
      if (incumb > best_clique) {
	best_clique=incumb;
/*	printf("Clique of size %5d found.\n",best_clique);*/
      }
    }
    
  /*    else printf("Taking incumb\n");*/
    free(valid1);
    free(clique1);
    if (incumb >=target) break;
  }
  free(order);
  return(incumb);
}



AssignColor(node,color)
int node,color;

{
  int node1;

/*  printf("  %d color +%d\n",node,color);*/
  ColorClass[node] = color;
  for (node1=0;node1<num_node;node1++) 
    {
      if (node==node1) continue;
      if (adj[node][node1]) 
	{
	  if (ColorAdj[node1][color]==0) ColorCount[node1]++;
	  ColorAdj[node1][color]++;
	  ColorAdj[node1][0]--;
	  if (ColorAdj[node1][0] < 0) printf("ERROR on assign\n");	
	}
    }
  
}


RemoveColor(node,color)
int node,color;

{
  int node1;
/*  printf("  %d color -%d\n",node,color);  */
  ColorClass[node] = 0;
  for (node1=0;node1<num_node;node1++) 
    {
      if (node==node1) continue;
      if (adj[node][node1]) 
	{
	  ColorAdj[node1][color]--;
	  if (ColorAdj[node1][color]==0) ColorCount[node1]--;
	  if (ColorAdj[node1][color] < 0) printf("ERROR on assign\n");
	  ColorAdj[node1][0]++;
	}
    }
  
}

/*int lower_bound(current_color) 
     int current_color;

{
  int i,j,k;
  int max;
  int done;
  int clique[MAX_NODE];
  int order[MAX_NODE];
  int weight[MAX_NODE];
  
  for (i=0;i<num_node;i++) clique[i] = 0;
  for (i=0;i<num_node;i++) {
    order[i] = i;
    weight[i] = ColorAdj[i][0];
    for (k=1;k<=current_color;k++)
      if (ColorClass[i] != k) weight[i] +=ColorAdj[i][k];
  }
  
  done = FALSE;
  while (!done) {
    done = TRUE;
    for (i=0;i<num_node-1;i++) {
      j = order[i];
      k = order[i+1];
      if (weight[j] < weight[k]) {
	order[i] = k;
	order[i+1] = j;
	done = FALSE;
      }
    }
  }
  clique[order[0]] = TRUE;
  printf("Node %d in clique\n",order[0]);
  for (i=1;i<num_node;i++) {
    j = order[i];
    for (k=0;k<i;k++) {
      if (clique[order[k]]) {
	if (!adj[j][order[k]]) 
	  {
	    if ((ColorClass[order[k]]==0) || (ColorClass[j]==0) ||(ColorClass[order[k]]==ColorClass[j]))
	      break;
	  }
      }
    }
    if (k==i) {
      clique[j] = TRUE;
      printf("Node %d in clique\n",j);
    }
  }
  max = 0;
  for (i=0;i<num_node;i++) 
    if (clique[order[i]]) max++;
  printf("Lower bound of %d found with Best Coloring %d\n",max,BestColoring);
  return max;
}
*/

/*int lower_bound(current_color)
int current_color;
{
  return 0;
  
}
*/

int color(i,current_color)
     int i;
{
  int j,new_val;
  int k,max,count,place;
  

  prob_count++;
  if (current_color >=BestColoring) return(current_color);
  if (BestColoring <=lb) return(BestColoring);
  
  if (i >= num_node) return(current_color);
/*  printf("Node %d, num_color %d\n",i,current_color);*/
  
/* Find node with maximum color_adj */
  max = -1;
  place = -1;
  for(k=0;k<num_node;k++) 
    {
/*      count = 0;*/
      if (Handled[k]) continue;
/*      for (j=1;j<=current_color;j++)
	if (ColorAdj[k][j] > 0) count++;
      if (count!=ColorCount[k]) printf("Trouble with color count\n");
*/      
/*      printf("ColorCount[%3d] = %d\n",k,ColorCount[k]);*/
      if ((ColorCount[k] > max) || ((ColorCount[k]==max)&&(ColorAdj[k][0]>ColorAdj[place][0])))
	{
/*	  printf("Best now at %d\n",k);*/
	  max = ColorCount[k];
	  place = k;
	}
    }
  if (place==-1) 
    {
      printf("Graph is disconnected.  This code needs to be updated for that case.\n");
      exit(1);
    }

  
  Order[i] = place;
  Handled[place] = TRUE;
/*  printf("Using node %d at level %d\n",place,i);*/
  for (j=1;j<=current_color;j++) 
    {
      if (!ColorAdj[place][j]) 
	{
	  ColorClass[place] = j;
	  AssignColor(place,j);
	  new_val = color(i+1,current_color);
	  if (new_val < BestColoring){
	    BestColoring = new_val;
	    print_colors();
	  }
	  RemoveColor(place,j);
	  if (BestColoring<=current_color) {
	    Handled[place] = FALSE;
	    return(BestColoring);
	  }
	}
    }
  if (current_color+1 < BestColoring) 
    {
      ColorClass[place] = current_color+1;
      AssignColor(place,current_color+1);
      new_val = color(i+1,current_color+1);
      if (new_val < BestColoring) {
	BestColoring = new_val;
	print_colors();
      }
      
      RemoveColor(place,current_color+1);
    }
  Handled[place] = FALSE;
  return(BestColoring);
}

print_colors() 
{
  int i,j;

  times(&buffer);
  current_time = buffer.tms_utime;
  
  printf("Best coloring is %d at time %7.1f\n",BestColoring,(current_time-start_time)/60.0);
  
/*  for (i=0;i<num_node;i++)
    printf("Color[%3d] = %d\n",i,ColorClass[i]);*/
  for (i=0;i<num_node;i++)
    for (j=0;j<num_node;j++) 
      {
	if (i==j) continue;
	if (adj[i][j] && (ColorClass[i]==ColorClass[j]))
	  printf("Error with nodes %d and %d and color %d\n",i,j,ColorClass[i]);
      }
}

main(argc,argv)
  int argc; 
  char *argv[];
{
  FILE *fp;
  int m,i,j,k,val;
  int valid[MAX_NODE],clique[MAX_NODE];
  int place;
  
  if (argc < 2) 
    {
      printf("Provide data file in command.\n");
      exit(1);
    }
  
  if ((fp = fopen(argv[1],"r"))==NULL) 
    {
      printf("No such graph as %s\n",argv[1]);
      exit(1);
    }
  
  fscanf(fp,"%d %d",&num_node,&m);
  for (i=0;i<num_node;i++)
    for (j=0;j<num_node;j++) 
      {
	adj[i][j] = FALSE;
      }

  for (k=0;k<m;k++) {
    fscanf(fp,"%d %d",&i,&j);
    adj[i-1][j-1] = TRUE;
    adj[j-1][i-1] = TRUE;
  }
  fclose(fp);


  prob_count = 0;
  for (i=0;i<num_node;i++)
    for (j=0;j<=num_node;j++)
      ColorAdj[i][j] = 0;
  for (i=0;i<num_node;i++)
    for (j=0;j<num_node;j++)
      if (adj[i][j]) ColorAdj[i][0]++;
  for (i=0;i<num_node;i++)
    ColorCount[i]=0;
  times(&buffer);
  start_time=buffer.tms_utime;
  printf("Graph %s read with %d nodes and %d edges\n",argv[1],num_node,m);
  for (i=0;i<num_node;i++)
    Handled[i] = FALSE;
  BestColoring = num_node+1;
/*  ColorClass[0] = 1;
  AssignColor(0,1);
  Handled[0] = TRUE;*/
  for (i=0;i<num_node;i++) valid[i] = TRUE;
  best_clique = 0;
  num_prob = 0;
  max_prob = 10000;
  
  lb = max_w_clique(valid,clique,0,num_node);
  place = 0;
  for (i=0;i<num_node;i++) 
    {
      if (clique[i]) 
	{
	  Order[place] = i;
	  Handled[i] = TRUE;
	  place++;
	  AssignColor(i,place);
	  for (j=0;j<num_node;j++)
	    if ((i!=j)&&clique[j] && (!adj[i][j])) printf("Result is not a clique!\n");
	  
	}
    }
  
  printf("Lower bound is %d",lb);
  if (num_prob >=max_prob) printf(" (not confirmed)\n");
  else printf("\n");
  val = color(place,place);
  times(&buffer);
  current_time=buffer.tms_utime;
  
  printf("Best coloring has value %d, subproblems: %d time:%7.1f\n",val,prob_count,(current_time-start_time)/60.0);
  
}
	

	  
