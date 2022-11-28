all : receptor_control_remoto

receptor_control_remoto : work-obj08.cf 
	ghdl -m --std=08 receptor_control_remoto_tb
	ghdl -r --std=08 receptor_control_remoto_tb


work-obj08.cf: *.vhd
	ghdl -i --std=08 *.vhd