include "globals.mzn";

int: graph_size;
int: start;
int: n_dests;
array[1..n_dests] of int: dest;
int: n_edges;
array[1..n_edges] of int: from;
array[1..n_edges] of int: to;
array[1..n_edges] of int: cost;

int: nbr_arcs = n_edges;
int: nbr_nodes = graph_size;

% The array of From, To, To, From
array [1..4*n_edges] of 1..graph_size: arcArray = (from ++ to) ++ (to ++ from);

% Create a 2d array of the arcArray, row 1 will have one array of From To and row 2 will have another array of To From
array[1..2, 1..2*n_edges] of 1..graph_size: TempStructure  = array2d(1..2, 1..2*n_edges, arcArray);

% This takes the columns and places them on a row (F_1,T_1,F_2,T_2 ... F_n,T_n,T_1,F_1 ... T_n,F_n)
array[1..2*n_edges] of 1..graph_size: arcList = [TempStructure[j, i] | i in 1..n_edges, j in 1..2];

% Takes the arcList elements, places them, filling the 2darray one row at a time
array[1..n_edges, 1..2] of 1..graph_size: arcs = array2d(1..n_edges, 1..2, arcList);

array[1..nbr_arcs] of var -n_dests..n_dests: flows;

array[1..graph_size] of int: balances = [ 
% look through the destinations and if the value at dest[j] equals the value of i, then the value should be a sink (-1)
if exists(j in 1..length(dest))(dest[j] == i) 
  then -1
% set the value of number destinations at the index of start
elseif start == i
  then n_dests 
% normal node 
else 0 
endif | i in 1..nbr_nodes];

constraint network_flow(arcs, balances, flows);
    
var int: totalCost = sum([cost[i] | i in 1..nbr_arcs where flows[i] != 0]);
solve minimize totalCost;


output[ show(totalCost) ];