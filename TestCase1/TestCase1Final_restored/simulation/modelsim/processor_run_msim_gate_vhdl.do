transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {processor.vho}

do "H:/Onedrive/UNL/Classes/SPRING2015/CSCE/430/FinalVersions/TestCase1/TestCase1Final_restored/test.do"
