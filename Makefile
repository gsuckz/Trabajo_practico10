ops = --std=08
arch_cf = work-onj08.cf
nombre = design
tb = testbench
arch_wav = $(nombre).ghw
wav_ops = --assert-level-none --wave=$(arch_wav)
all : receptor_control_remoto
.PHONY: all test wav
receptor_control_remoto : work-obj08.cf 
	ghdl -m --std=08 receptor_control_remoto_tb
	ghdl -r --std=08 receptor_control_remoto_tb


work-obj08.cf: testbench.vhd
	ghdl -i --std=08 testbench.vhd

wav: $(arch_wav)
		gtkwave -f $(arch_wav)
	 $(arch_wav): $(arch_cf)
	 ghdl -m $(ops) $(tb)
	 ghdl -r $(ops) $(tb) $(wav_ops)
	 $(arch_cf): testbench.vhd
	 ghdl -i $(ops) testbench.vhd