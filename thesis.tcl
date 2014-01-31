# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 15 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 1000 ;# X dimension of topography
set val(y) 1000 ;# Y dimension of topography
set val(stop) 150 ;# time of simulation end

set ns [new Simulator]
set tracefd [open thesis.tr w]
set namtrace [open thesis.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)



# configure the nodes
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

# Energy model for every node
#Energy=Power*time
#Jule is unit of initialEnergy and rest of Energy is unit is watt
$ns node-config  -energyModel EnergyModel \
-initialEnergy 20 \
-txPower 0.744 \
-rxPower 0.0648 \
-idlePower 0.05 \
-sensePower 0.0175 



for {set i 0} {$i < $val(nn) } { incr i } {
set n($i) [$ns node]
}

$n(0) set initialEnergy 5
$n(1) set initialEnergy 25
$n(2) set initialEnergy 15
# Provide initial location of mobilenodes
           
if {$val(nn) >0} {
    for {set i 1} {$i < $val(nn) } { incr i } {
          set xx [expr rand()*600]                 
          set yy [expr rand()*500];
          $n($i) set X_ $xx
          $n($i) set Y_ $yy
    }
}

# Set a TCP connection between n(1) and n(31)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n(1) $tcp
$ns attach-agent $n(13) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

# Set a TCP connection between n(31) and n(43)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n(13) $tcp
$ns attach-agent $n(7) $sink
$ns connect $tcp $sink

#defining heads
$ns at 0.0 "$n(0) label CH"
$ns at 0.0 "$n(1) label Source"
$ns at 0.0 "$n(13) label Destination"
#$ns at 0.0 "$n(2) label N2"

#new location after move
$ns at 10.0 "$n(0) setdest 130.0 208.0 5.0"
$ns at 10.0 "$n(1) setdest 485.0 128.0 5.0"
$ns at 10.0 "$n(2) setdest 615.0 340.0 5.0"
$ns at 10.0 "$n(3) setdest 680.0 458.0 5.0"
$ns at 10.0 "$n(4) setdest 580.0 368.0 5.0"
$ns at 10.0 "$n(5) setdest 785.0 228.0 5.0"
$ns at 10.0 "$n(6) setdest 750.0 638.0 5.0"
$ns at 10.0 "$n(7) setdest 185.0 120.0 5.0"
$ns at 10.0 "$n(8) setdest 335.0 700.0 5.0"
$ns at 10.0 "$n(9) setdest 425.0 590.0 5.0"
$ns at 10.0 "$n(10) setdest 105.0 620.0 5.0"
$ns at 10.0 "$n(11) setdest 565.0 420.0 5.0"
$ns at 13.0 "$n(12) setdest 700.0 20.0 5.0"
$ns at 15.0 "$n(13) setdest 115.0 85.0 5.0"

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 40 defines the node size for nam
$ns initial_node_pos $n($i) 40
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "$n($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
	exec nam thesis.nam &

}
proc finish {} {
	source shortest_path.tcl
	mkMatrix
	 exec xgraph simple.tr -geometry 1000*1000
	 exit 0
}

$ns run
