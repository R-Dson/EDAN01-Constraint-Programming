include "globals.mzn";

%% DATA
int: n;
int: n_commercial;
int: n_residential;
array[1..n+1] of int: point_distribution;

%% CODE
% Use the JaCoP solver for the fastest result on urban_3

%%% We only need to maximize the amount of points we get from residential lots 
%%% to maximize the total points. 

% Column & row arrays. These count the amount of occurances of residential lots
array[1..n] of var 0..n*n: column;
array[1..n] of var 0..n*n: row;

var int: totalPoints; %FEEDBACK: Changed from -100..100 to int

% Table of how we place the residential or commercial lots, this is a 2D array 
% with the domain 1 or 2.
array[1..n, 1..n] of var 0..1: table; %FEEDBACK: Changed from 1..2 to 0..1

% The 1 in table is residential lots and 2 in table is commercial lots.
int: residential = 0;
int: commercial = 1;

% Makes sure that we will always have a total of n_residential 1's and 
% a total of n*n - n_residential 2's.
%constraint sum(i in 1..n, j in 1..n)(table[i, j] == residential) == n_residential;
constraint sum(table) == n_commercial; %FEEDBACK: Changed from the above row to this new line

% Sorts the table such that the adjacent rows and columns are lexicographically strictly 
% ordered to break the symmetry to prevent symmetrical solutions (better efficiency). 
constraint lex2(table);

% I have to use lex2 since I can't get lex_lesseq to work properly.
% constraint forall(i in 1..n-1)(
%  lex_lesseq([table[i,j] | j in 1..n], [table[i+1,j] | j in 1..n])
%);

% Counts the amount of residential lots in the row and column.
% The +1 is to count for the array offset (starting at 1).
constraint forall(i in 1..n)(
  row[i] = sum(r in 1..n)(table[r, i] == residential) + 1 /\
  column[i] = sum(c in 1..n)(table[i, c] == residential) + 1
);

% Since we want to maximize the amount of points from the residential lots we can just 
% sum the row and column.
totalPoints = sum(i in 1..n)(point_distribution[row[i]] + point_distribution[column[i]]);

% Solve for the maximum amount of points
solve maximize totalPoints;

output["points: " ++ show(totalPoints) ++ "\nrow: " ++ show(row) ++ "\ncolumn: " ++ show(column) ++ "\n"];
output[show(table[i,j]) ++ if j mod n == 0 then "\n" else ", " endif| i in 1..n, j in 1..n ];