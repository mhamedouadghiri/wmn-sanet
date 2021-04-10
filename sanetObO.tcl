if {$argc != 1} {
    puts "The script requires one number - duration of simulation - to be inputed."
    exit 1
}

set duration [lindex $argv 0]

set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             7                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
#set val(rp)             DSR                       ;# routing protocol
set val(x)		1000
set val(y)		1000

# Initialize Global Variables
set ns_		[new Simulator]
set tracefd     [open sanetObO.tr w]
$ns_ trace-all $tracefd

set namtrace [open sanetObO.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# New API to config node: 
# 1. Create channel (or multiple-channels);
# 2. Specify channel in node-config (instead of channelType);
# 3. Create nodes for simulations.

# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace OFF \
		-channel $chan_1_ 

set node_(0) [$ns_ node]
set node_(1) [$ns_ node]
set node_(2) [$ns_ node]
set node_(3) [$ns_ node]
set node_(4) [$ns_ node]
set node_(5) [$ns_ node]
set node_(6) [$ns_ node]

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 20
}

# define some coordinate constants
set x1 100.0
set x2 200.0
set x3 300.0
set x4 400.0
set x5 500.0
set y1 100.0
set y2 200.0
set y3 300.0

$node_(0) set X_ $x1
$node_(0) set Y_ $y3
$node_(0) set Z_ 0.0

$node_(1) set X_ $x1
$node_(1) set Y_ $y1
$node_(1) set Z_ 0.0

$node_(2) set X_ $x2
$node_(2) set Y_ $y2
$node_(2) set Z_ 0.0

$node_(3) set X_ $x3
$node_(3) set Y_ $y2
$node_(3) set Z_ 0.0

$node_(4) set X_ $x4
$node_(4) set Y_ $y2
$node_(4) set Z_ 0.0

$node_(5) set X_ $x5
$node_(5) set Y_ $y3
$node_(5) set Z_ 0.0

$node_(6) set X_ $x5
$node_(6) set Y_ $y1
$node_(6) set Z_ 0.0

$ns_ at 0.0 "$node_(0) setdest $x1 $y3 0.0"
$ns_ at 0.0 "$node_(1) setdest $x1 $y1 0.0"
$ns_ at 0.0 "$node_(2) setdest $x2 $y2 0.0"
$ns_ at 0.0 "$node_(3) setdest $x3 $y2 0.0"
$ns_ at 0.0 "$node_(4) setdest $x4 $y2 0.0"
$ns_ at 0.0 "$node_(5) setdest $x5 $y3 0.0"
$ns_ at 0.0 "$node_(6) setdest $x5 $y1 0.0"

# node labels
$ns_ at 0.0 "$node_(0) label Source1"
$ns_ at 0.0 "$node_(1) label Source2"
$ns_ at 0.0 "$node_(2) label Gateway1"
$ns_ at 0.0 "$node_(3) label Gateway2"
$ns_ at 0.0 "$node_(4) label Gateway3"
$ns_ at 0.0 "$node_(5) label Destination1"
$ns_ at 0.0 "$node_(6) label Destination2"

# Setup traffic flow between nodes

set start_at 3.0
set end_at [expr $start_at + $duration]

set start_at_1 [expr $start_at + $end_at]
set end_at_1 [expr $start_at_1 + $duration]

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp
$ns_ attach-agent $node_(6) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at $start_at "$ftp start"
$ns_ at $end_at "$ftp stop"

set tcp1 [new Agent/TCP/Vegas]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(5) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $start_at_1 "$ftp1 start"
$ns_ at $end_at_1 "$ftp1 stop"

#
# Tell nodes when the simulation ends
#

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $end_at "$node_($i) reset";
    $ns_ at $end_at_1 "$node_($i) reset";
}
$ns_ at $end_at_1 "stop"
$ns_ at [expr $end_at_1 + 0.01] "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
