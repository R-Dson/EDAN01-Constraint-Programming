include "globals.mzn";
include "jacop.mzn";

int : del_add;
int : del_mul;

int : number_add;
int : number_mul;

int : n; % number of operations
set of int : last;
set of int : add;
set of int : mul;
array[1..n] of set of int : dependencies;

%%

int: AddNumber = length(add);
int: MultiNumber = length(mul);

array[1..n] of var 0..100: time;

% precedence constraints for all the nodes and their dependencies
constraint forall(i in 1..n, j in dependencies[i])(
  time[i] + getDel(i) <= time[j]
);

% Find if a value is a multiplier or addition
function int: getDel(int: i) = 
  if i in mul 
    then del_mul
  else 
    del_add 
  endif
;
% Picks out the index from add or mul and uses it to get var from time, resources and duration
% Addition ----
% start time
array[1..AddNumber] of var 0..1000: tAdd = [time[i] | i in add];
% resource
array[1..AddNumber] of var 1..AddNumber: rAdd;
% duration
array[1..AddNumber] of var 0..del_add: dAdd = [ del_add | i in 1..AddNumber];
% just a array with 1
array[1..AddNumber] of var 1..1: onesA = [1 | i in 1..AddNumber];

%% Multiplication ----
array[1..MultiNumber] of var 0..100: tMulti = [time[i] | i in mul];
array[1..MultiNumber] of var 1..MultiNumber: rMulti;
array[1..MultiNumber] of var 0..del_mul: dMulti = [ del_mul | i in 1..MultiNumber];
array[1..MultiNumber] of var 1..1: onesM = [1 | i in 1..MultiNumber];

% Resource constraint
constraint diff2(tAdd, rAdd, dAdd, onesA);
constraint diff2(tMulti, rMulti, dMulti, onesM);

var 1..number_add: alim;
var 1..number_mul: mlim;
% duration is always fixed here, length del_add or del_mul
constraint cumulative(tAdd, [del_add | i in 1..AddNumber], onesA, alim);
constraint cumulative(tMulti, [del_mul | i in 1..MultiNumber], onesM, mlim);

var int: cost = max([time[i] + getDel(i) | i in last]);

% solving by the smallest max value of time to minimize the domain
solve :: int_search(time, smallest_max, indomain_min) minimize cost;

output(["start time " ++ show(time) ++ 
"\nmulti1: " ++ show([tMulti[i] | i in 1..MultiNumber where rMulti[i] == 1])++
"\nmulti2: " ++ show([tMulti[i] | i in 1..MultiNumber where rMulti[i] == 2]) ++ 
"\nmulti3: " ++ show([tMulti[i] | i in 1..MultiNumber where rMulti[i] == 3]) ++
"\nmulti4: " ++ show([tMulti[i] | i in 1..MultiNumber where rMulti[i] == 4]) ++
"\nadder1: " ++ show([tAdd[i] | i in 1..AddNumber where rAdd[i] == 1]) ++ 
"\nadder2: " ++ show([tAdd[i] | i in 1..AddNumber where rAdd[i] == 2]) ++ "\ncost: " ++ show(cost) ++ "\n multi: " ++ show(rMulti) ++ "\nadd:" ++ show(rAdd)] );