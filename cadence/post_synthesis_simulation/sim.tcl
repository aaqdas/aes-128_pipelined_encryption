database -open my_shm -shm 
probe -create Top_PipelinedCipher_tb.dut -depth all -shm -all -database my_shm -memories -packed 4096
run