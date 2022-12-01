ops = --std=08
arch_cf = work-obj08.cf
nombre = receptor_control_remoto
tb = $(nombre)_tb
arch_wav = $(nombre).ghw
wav_ops = --assert-level=none --wave=$(arch_wav)
all : test
.PHONY: all test wav
test: $(arch_cf) 
	ghdl -m --std=08 $(tb)
	ghdl -r --std=08 $(tb)
$(arch_cf): *.vhd
	ghdl -i --std=08 *.vhd

wav: $(arch_wav)
	gtkwave -f $(arch_wav)

$(arch_wav): $(arch_cf)
	ghdl -m $(ops) $(tb)
	ghdl -r $(ops) $(tb) $(wav_ops)
$(arch_cf): *.vhd
	ghdl -i $(ops) *.vhd
