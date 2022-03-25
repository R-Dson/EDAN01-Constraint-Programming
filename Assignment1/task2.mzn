include "globals.mzn";

%% DATA
int: n;
int: n_prefs;
array[1..n_prefs, 1..2] of int: prefs;

%% CODE

% Index is person and people[index] is the position in the line
array[1..n] of var 1..n: index;

% Distance between one person and their preference
array[1..n_prefs] of var 1..n-1: prefDist;

% Make sure all positions are different
constraint alldifferent(index);

% Calculate the distance between a person and their preference
constraint forall(i in 1..n_prefs)(
  prefDist[i] = abs(index[prefs[i, 1]] - index[prefs[i, 2]])
);

var 1..n_prefs: maxi = max(prefDist);

% Minimizing the maximum distance between two people with preference of one another
solve minimize maxi;

output[show(maxi)];