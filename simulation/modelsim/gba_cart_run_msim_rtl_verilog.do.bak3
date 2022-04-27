transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/fpga_deca/gba_cart {E:/fpga_deca/gba_cart/gba_cart.v}
vlog -sv -work work +incdir+E:/fpga_deca/gba_cart {E:/fpga_deca/gba_cart/dump_fsm.sv}
vlog -sv -work work +incdir+E:/fpga_deca/gba_cart {E:/fpga_deca/gba_cart/clock_divider.sv}
vlog -sv -work work +incdir+E:/fpga_deca/gba_cart {E:/fpga_deca/gba_cart/debouncer.sv}

