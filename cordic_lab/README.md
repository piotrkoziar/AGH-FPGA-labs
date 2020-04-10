# cordic-lab

## Content

### __nios_cordic_system__
__*nios_cordic_system.qsys*__

### __cordic_pipeline_avalon_interface__ component

Component consists of: __*cordic_pipeline_avalon_interface.v, cordic_pipeline_rtl.v, cordic_step.v,	mul_Kn.v*__

### software
- bsp: folder with generated bsp module for __*nios_cordic_system*__. To update, do the following:
  1. open __*nios_cordic_system.qsys*__ in Platform Designer and Generate HDL. 
  2. cd __*cordic_lab/software/bsp*__ 
  3. make sure you have __Altera Nios2 Command Shell__ active (if not, execute {PATH_to_nios2eds}/__*nios2_command_shell.sh*__)
  4. run __*nios2-bsp hal . ../../nios_cordic_system.sopcinfo --settings settings.bsp*__
  5. make all

- Application_Cordic: program for nios processor. To update, do the following:
  1. save changes in main.c
  2. cd __*cordic_lab/software/Application_Cordic*__ 
  3. make sure you have __Altera Nios2 Command Shell__ active (if not, execute {PATH_to_nios2eds}/__*nios2_command_shell.sh*__)
  4. run __*nios2-app-generate-makefile --bsp-dir ../bsp --app-dir . --src-dir .*__
  5. make all && make mem_init_generate
  
  mem_init folder is generated in step v. above. File __*nios_cordic_system_RAM.hex*__ is used to initialize memory content of __RAM__ component in __*nios_cordic_system.qsys*__. 
  The path to the hex file is specified in __Memory Initialization__ section of the __RAM__ instance (in Platform Designer: right-click on the component -> Edit...). Make sure the path is valid.
  
### testbench file (__*nios_cordic_system_tb.v*__)
This file is a proposition of top-level testbench Verilog file. To generate testbench system (__*nios_cordic_system_tb.v*__ will be replaced with generated one):
  1. in Platform Designer: Generate -> Generate Testbench System...

## Simulation

You can simulate the system in ModelSim:
1. open ModelSim ({PATH_to_modelsim_ase}/__*bin/vsim*__)
2. cd __*cordic_lab/nios_cordic_system/testbench/mentor*__ (exists only if testbench was generated)
3. __*do msim_setup.tcl*__
4. __*ld_debug*__
