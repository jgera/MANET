# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 20 ;# number of mobilenodes
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
-macTrace ON \
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

#source 'thesis1.tcl';

for {set i 0} {$i < $val(nn) } { incr i } {
set n($i) [$ns node]
}

$n(0) set initialEnergy 5
$n(1) set initialEnergy 25
$n(2) set initialEnergy 15

# Provide initial location of mobilenodes

$n(0) set X_ 105.0
$n(0) set Y_ 206.0
$n(0) set Z_ 0.0

$n(1) set X_ 805.0
$n(1) set Y_ 742.0
$n(1) set Z_ 0.0

$n(2) set X_ 515.0
$n(2) set Y_ 606.0
$n(2) set Z_ 0.0

$n(3) set X_ 405.0
$n(3) set Y_ 342.0
$n(3) set Z_ 0.0

$n(4) set X_ 675.0
$n(4) set Y_ 156.0
$n(4) set Z_ 0.0

$n(5) set X_ 905.0
$n(5) set Y_ 549.0
$n(5) set Z_ 0.0

$n(6) set X_ 675.0
$n(6) set Y_ 336.0
$n(6) set Z_ 0.0

$n(7) set X_ 555.0
$n(7) set Y_ 762.0
$n(7) set Z_ 0.0

$n(8) set X_ 258.0
$n(8) set Y_ 646.0
$n(8) set Z_ 0.0

$n(9) set X_ 645.0
$n(9) set Y_ 522.0
$n(9) set Z_ 0.0

$n(10) set X_ 265.0
$n(10) set Y_ 376.0
$n(10) set Z_ 0.0

$n(11) set X_ 495.0
$n(11) set Y_ 502.0
$n(11) set Z_ 0.0

$n(12) set X_ 75.0
$n(12) set Y_ 426.0
$n(12) set Z_ 0.0

$n(13) set X_ 145.0
$n(13) set Y_ 119.0
$n(13) set Z_ 0.0

$n(14) set X_ 85.0
$n(14) set Y_ 702.0
$n(14) set Z_ 0.0

$n(15) set X_ 340.0
$n(15) set Y_ 36.0
$n(15) set Z_ 0.0

$n(16) set X_ 758.0
$n(16) set Y_ 602.0
$n(16) set Z_ 0.0

$n(17) set X_ 435.0
$n(17) set Y_ 186.0
$n(17) set Z_ 0.0

$n(18) set X_ 5.0
$n(18) set Y_ 2.0
$n(18) set Z_ 0.0

$n(19) set X_ 515.0
$n(19) set Y_ 366.0
$n(19) set Z_ 0.0


# Set a TCP connection between n(1) and n(13)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $n(1) $tcp
$ns attach-agent $n(13) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

# Set a TCP connection between n(13) and n(7)
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
$ns at 0.0 "$n(0) setdest 130.0 208.0 5.0"
$ns at 0.0 "$n(1) setdest 485.0 128.0 5.0"
$ns at 1.0 "$n(2) setdest 615.0 340.0 5.0"
$ns at 1.0 "$n(3) setdest 680.0 458.0 5.0"
$ns at 3.0 "$n(4) setdest 580.0 368.0 5.0"
$ns at 3.0 "$n(5) setdest 785.0 228.0 5.0"
$ns at 2.0 "$n(6) setdest 750.0 638.0 5.0"
$ns at 1.0 "$n(7) setdest 185.0 120.0 5.0"
$ns at 0.0 "$n(8) setdest 335.0 700.0 5.0"
$ns at 2.0 "$n(9) setdest 425.0 590.0 5.0"
$ns at 2.0 "$n(10) setdest 105.0 620.0 5.0"
$ns at 0.0 "$n(11) setdest 565.0 420.0 5.0"
$ns at 1.0 "$n(12) setdest 700.0 20.0 5.0"
$ns at 1.0 "$n(13) setdest 115.0 85.0 5.0"
$ns at 1.0 "$n(14) setdest 195.0 185.0 5.0"
$ns at 1.0 "$n(15) setdest 387.0 590.0 5.0"
$ns at 2.0 "$n(16) setdest 165.0 620.0 5.0"
$ns at 0.0 "$n(17) setdest 765.0 320.0 5.0"
$ns at 1.0 "$n(18) setdest 109.0 20.0 5.0"
$ns at 1.0 "$n(19) setdest 175.0 185.0 5.0"


# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 40 defines the node size for nam
$ns initial_node_pos $n($i) 60
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
	 exec xgraph thesis.tr -geometry 800x400 &
     
	 	exit 0
}

$ns run
