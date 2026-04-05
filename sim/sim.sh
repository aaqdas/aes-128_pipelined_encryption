# /package/eda/cadence/XCELIUM2303/tools/bin/xrun -elaborate -s +linedebug +access+rwc -f src.args -q -top Top_PipelinedCipher_tb
# /package/eda/cadence/XCELIUM2303/tools/bin/xrun -gui -R
xrun -batch -elaborate -s +linedebug +access+rwc -timescale 1ps/1ps -f src.args -q -top Top_PipelinedCipher_tb 
xrun -R