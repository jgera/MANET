 # shortest_path.tcl --
 #     Find the shortest path in a graph, using
 #     Floyd's algorithm
 #
 package require struct

 # mkMatrix --
 #     Make a square matrix with uniform entries
 # Arguments:
 #     size      Size (number of columns/rows) of the matrix
 #     value     Default value to use
 # Result:
 #     A list of lists that represents the matrix
 #
 proc mkMatrix {size value} {
     set row {}
     for { set i 0 } { $i < $size } { incr i } {
         lappend row $value
     }
     set matrix {}
     for { set i 0 } { $i < $size } { incr i } {
         lappend matrix $row
     }
     return $matrix
 }

 # mkPath --
 #     Use the resulting matrix to print the shortest path
 # Arguments:
 #     indices   Matrix of indices
 #     names     Names of the nodes
 #     from      The name of the node to start with
 #     to        The name of the node to go to
 # Result:
 #     A list of intermediate nodes along the path
 #
 proc mkPath {indices names from to} {
     set f [lsearch $names $from]
     set t [lsearch $names $to]

     set ipath [IntermediatePath $indices $f $t]
     set path  [list $from]

     foreach node $ipath {
         lappend path [lindex $names $node]
     }

     lappend path $to
     return $path
 }

 # IntermediatekPath --
 #     Construct the intermediate path
 # Arguments:
 #     indices   Matrix of indices
 #     from      The node to start with
 #     to        The node to go to
 # Result:
 #     A list of intermediate nodes along the path
 #
 proc IntermediatePath {indices from to} {

     set path {}
     set next [lindex $indices $from $to]
     if { $next >= 0 } {
        set path [concat $path [IntermediatePath $indices $from $next]]
        lappend path $next
        set path [concat $path [IntermediatePath $indices $next $to]]
     }
     return $path
 }

 # floydPaths --
 #     Construct the matrix that encodes the shortest paths,
 #     via Floyd's algorithm
 # Arguments:
 #     distances  Matrix of distances
 #     lmatrix    (Optional) the name of a variable to hold the
 #                shortest path lengths as a matrix
 # Result:
 #     A matrix encoding the shortest paths
 #
 proc floydPaths {distances {lmatrix {}}} {
     if { $lmatrix != {} } {
        upvar 1 $lmatrix lengths
     }

     set size [llength $distances]

     set indices [mkMatrix $size -1]
     set lengths $distances

     for { set k 0 } { $k < $size } { incr k } {
         for { set i 0 } { $i < $size } { incr i } {
             for { set j 0 } { $j < $size } { incr j } {
                 set dik [lindex $lengths $i $k]
                 set dij [lindex $lengths $i $j]
                 set dkj [lindex $lengths $k $j]

                 if { $dik == {} || $dkj == {} } {
                     continue ;# No connection - distance infinite
                 }

                 if { $dij == {} || $dik+$dkj < $dij } {
                     lset indices $i $j $k
                     lset lengths $i $j [expr {$dik+$dkj}]
                 }
             }
         }
     }

     return $indices
 }

 # determinePaths --
 #     Construct the matrix that encodes the shortest paths from
 #     the given graph
 # Arguments:
 #     graph      Graph to be examined
 #     key        Name of the (non-negative) attribute) holding the
 #                length of the arcs (defaults to "distance")
 #     lmatrix    (Optional) the name of a variable to hold the
 #                shortest path lengths as a matrix
 # Result:
 #     A matrix encoding the shortest paths
 #
 proc determinePaths {graph {key distance} {lmatrix {}} } {
     if { $lmatrix != {} } {
        upvar 1 $lmatrix lengths
     }

     set names     [$graph nodes]
     set distances [mkMatrix [llength $names] {}]
     for { set i 0 } { $i < [llength $names] } { incr i } {
         lset distances $i $i 0 ;# Distance of a node to itself is 0
     }

     foreach arc [$graph arcs $key] {
         set from [lsearch $names [$graph arc source $arc]]
         set to   [lsearch $names [$graph arc target $arc]]
         set d    [$graph arc get $arc $key]
         if { $from != $to } {
             lset distances $from $to $d
         }
     }
     puts $distances

     return [floydPaths $distances lengths]
 }