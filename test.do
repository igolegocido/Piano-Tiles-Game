vlib work

vlog MovingTiles.v

vsim part1

log {/*}

add wave {/*}

force {iClock} 1 0ns , 0 {1ns} -r 2ns
force {iResetn} 0
force {iClick} 0

run 4ns

force {iClock} 1 0ns , 0 {1ns} -r 2ns
force {iResetn} 1
force {iClick} 1

run 2ns

force {iClock} 1 0ns , 0 {1ns} -r 2ns
force {iResetn} 1
force {iClick} 0

run 100000ns