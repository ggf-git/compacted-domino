# compacted-domino
Finds optimal compact placements of domino sets with OR-Tools CP-SAT. Read [this blog post](https://gabrielgimenezfranz.com/compacted_dominoes/) for more information regarding this project before proceeding. This model was mostly used for finding solutions of a given area for the Domino-n problem, and was also used early on to experiment with bounds of possible area values.

# How to Run
Clone repository and open the model-solutions.mzn file with the MiniZinc IDE. The recommended solver configuration is running OR Tools CP-SAT with free search, optimization level O1, with at least 4 threads and Free Search enabled.

# Parameter settings
The model looks for solutions within a rectangle grid, of width and height defined by the **row_count** and **col_count** parameters. Generally, you want to use the smallest grid possible, as most of the complexity comes from the grid size. 

The **n** parameter defines the Domino-n set, as described in the blog post. Note that domino numbers range from 1 to n here, instead of from 0 to n, due to 0 representing an empty square. This means that if you wanted to look for solutions of the Domino-6 set as defined in the post, you'd have to set n := 7.

# Variables and constraints rundown
The **SQ** variables, indexed by row and column, represent the square in that position in the modeled grid. SQ can range from 0 to n, with 0 representing the square being empty. The area of a solution is then the number of SQ variables that are strictly greater than 0.

The **DOMINO** variables are indexed by [row, column, a, b], with a and b being numbers from 1 to n. They are boolean variables that represent the placement of the (a,b) domino piece in the (row, column) position. More specifically, SQ[row,column] == a, and one of the (up to) 4 adjacent SQ must be b. This behaviour is codified by the **Domino definition constraints**. Cases where a == b and a != b are handled separately for efficiency, due to the symmetry inherent to (a,a) domino pieces.

The **C** variables, indexed by [a,b], with a and b being numbers from 1 to n, are auxiliary constraint-breaking boolean variables. They are TRUE if and only if the (a,b) domino is not placed in a solution. These variables are used when looking for a solution of a set size.

The **domino existence constraint** defines the fact that, for a solution to be valid, every domino piece must be placed at least once in the grid. If the (a,b) domino is not present, then C[a,b] must be TRUE, as defined above. Therefore, for a solution to be valid, all C variables must be FALSE.

The **symmetry breaking constraint** helps with breaking lexicographic symmetry. Further sym breaking constraints were tested, but experimentally they seemed to only slow down the solution search, so they were removed except for the one currently present in the model.

The **fixed solution size constraints** can be enabled or disabled, depending on the goal when running the model. If you're looking for a solution with a specific area, then these must be activated. The default settings look for a solution of size 24 for n = 8. Since the given grid is a 5x5 grid, the SQ[row_count,col_count] == 0 constraint simply fixes the shape of the solution (it could be seen as an additional symmetry breaking constraint). This constraint can be disabled without much efficiency loss, but it is nice to force the shape of the solution when your grid size forces 2 or more empty squares.

# Objective functions
If the fixed solution size constraints are disabled, you should enable the first objective function, which simply looks to minimize the area. This will try to find the valid solution with the smallest area possible in the row_count x col_count grid.

If the fixed solution size constraints are enabled, use the second objective function, which minimizes the sum of the C variables. If a valid solution of your selected area exists, then the optimal value of the objective function will be 0, and it will give you a valid solution of that size. If it doesn't, then the optimal value will be greater than or equal to 1.
