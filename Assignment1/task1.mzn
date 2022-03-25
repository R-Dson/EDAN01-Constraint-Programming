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

%Make sure all positions are different
constraint alldifferent(index);

% calculate the distance between a person and their preference
constraint forall(i in 1..n_prefs)(
  prefDist[i] = abs(index[prefs[i, 1]] - index[prefs[i, 2]])
);

constraint index[1] > index[2];

% Calculated the number of satisfied people, higher is better
var int: costValue = sum(d in prefDist)(d = 1);

% Maximizing the amount of satisified people
solve maximize costValue;

output["Satisfied: ", show(costValue), "\npositions: ", show(index), "\ndist: ", show(prefDist)];