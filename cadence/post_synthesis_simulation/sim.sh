# xrun +nc64bit -batch -loadpli1 debpli.so:novas_pli_boot -elaborate -s +linedebug +access+rwc -timescale 1ps/1ps -f src.args -q -top Top_PipelinedCipher_tb -input sim.tcl
xrun -input sim.tcl -batch -elaborate -s +linedebug +access+rwc -timescale 1ps/1ps -f src.args -q -top Top_PipelinedCipher_tb 
xrun -input sim.tcl -R