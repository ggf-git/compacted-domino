int: row_count = 5;
int: col_count = 5;
int: n = 8;

set of int: D = 1..n;
set of int: ROWS = 1..row_count;
set of int: COLS = 1..col_count;

array[D,D,ROWS,COLS] of var bool: DOMINO;
array[ROWS,COLS] of var 0..n: SQ ;

array[D,D] of var bool: C;

% Domino definition constraint for (a,b) dominoes where a != b
constraint
  forall (a,b in 1..n, i in ROWS, j in COLS where a < b) (
    DOMINO[a,b,i,j] 
    <->
    SQ[i,j] == a
    /\
    (
      (j < col_count /\ SQ[i,j+1] == b)
      \/
      (i < row_count /\ SQ[i+1,j] == b)
      \/
      (j > 1 /\ SQ[i,j-1] == b)
      \/
      (i > 1 /\ SQ[i-1,j] == b)
    )     
  );

% Domino definition constraint for (a,a) dominoes
constraint
  forall (a in 1..n, i in ROWS, j in COLS where i < row_count \/ j < col_count) (
    DOMINO[a,a,i,j] 
    <->
    SQ[i,j] == a
    /\
    (
      (j < col_count /\ SQ[i,j+1] == a)
      \/
      (i < row_count /\ SQ[i+1,j] == a)    
    )    
  );

% No a-a domino in the bottom right corner.
constraint
  forall (a in 1..n) (
    DOMINO[a,a,row_count,col_count] == 0
  );

% Domino existence constraint
constraint
  forall (a,b in 1..n where a <= b) (
    C[a,b]
    \/
    exists (i in ROWS, j in COLS) (DOMINO[a,b,i,j])
  ); 

% Symmetry breaking constraint
constraint
forall (a in 2..n) (  
    sum (i in ROWS,j in COLS) (SQ[i,j] == a-1)
    >=
    sum (i in ROWS, j in COLS) (SQ[i,j] == a)
  );                

% -- Fixed solution size constraints -------
constraint 
  sum(i in ROWS, j in COLS)(SQ[i,j] > 0) == 24 ;
  
constraint
  SQ[row_count,col_count] == 0;
%-------------------------------------------
                                                                                                                                                                                                                                                                                                                                                                                                % --- use this objective function if the fixed solution size constraint is disabled.
                                                                                                                                                                                                                                                                                                                                                                                                %solve minimize sum(i in ROWS,j in COLS)(SQ[i,j] > 0) ;

% --- use this objective function if the fixed solution size constraint is enabled.
solve minimize sum(a,b in D)(C[a,b]) ;                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                 output [
  "SQ =\n",
  show2d(SQ)
] ;