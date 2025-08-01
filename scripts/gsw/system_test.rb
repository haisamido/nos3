require 'cosmos'
require 'cosmos/script'
 
include Cosmos::Script
puts("Begin SAMPLE Test Case:")
initial_command_count = tlm("SAMPLE SAMPLE_HK_TLM CMD_COUNT")
puts("Inital Command Count: #{initial_command_count}")
initial_error_count = tlm("SAMPLE SAMPLE_HK_TLM CMD_ERR_COUNT")
puts("Initial Error Count: #{initial_error_count}")
initial_device_error_count = tlm("SAMPLE SAMPLE_HK_TLM DEVICE_ERR_COUNT")
puts("Inital Device Error Count: #{initial_device_error_count}")
cmd("SAMPLE SAMPLE_NOOP_CC")
wait_check("SAMPLE SAMPLE_HK_TLM CMD_COUNT > #{initial_command_count}", 30)
wait_check("SAMPLE SAMPLE_HK_TLM CMD_ERR_COUNT == #{initial_error_count}", 30)
wait_check("SAMPLE SAMPLE_HK_TLM DEVICE_ERR_COUNT == #{initial_device_error_count}", 30)
puts("")
puts("Final Values:")
final_command_count = tlm("SAMPLE SAMPLE_HK_TLM CMD_COUNT")
puts("Inital Command Count: #{final_command_count}")
final_error_count = tlm("SAMPLE SAMPLE_HK_TLM CMD_ERR_COUNT")
puts("Initial Error Count: #{final_error_count}")
final_device_error_count = tlm("SAMPLE SAMPLE_HK_TLM DEVICE_ERR_COUNT")
puts("Inital Device Error Count: #{final_device_error_count}")
puts("")
puts("SAMPLE TEST CASE COMPLETED SUCCESSFULLY!")
puts("")
