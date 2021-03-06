vsim processor
view wave

add wave clock
add wave reset

add wave -radix unsigned currPC
add wave IDmfc
add wave MEMMfc
add wave IDcacheHIT
add wave MEMCacheHit
add wave -radix dec IDcacheHitRatio
add wave -radix dec MEMcacheHitRatio
add wave -radix hex IDcacheOut
add wave -radix hex MEMCacheOut


add wave -radix hex IFinstr
add wave -radix hex IDinstr
add wave -radix hex EXinstru
add wave -radix hex MEMinstr
add wave -radix hex WBinstr

add wave redLEDS
add wave greenData

add wave -radix dec register09
add wave -radix dec register10


force clock 0 0, 1 525 -repeat 1050
force reset 1 0

run 750000