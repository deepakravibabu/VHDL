# UART Transmission

- UARTs transmit data asynchronously, which means there is no clock signal to synchronize the output of bits from the transmitting UART to the sampling of bits by the receiving UART. 
- Instead of a clock signal, the transmitting UART adds start and stop bits to the data packet being transferred. 
 
- Start Bit: '0'
- End Bit  : '0'
- Odd Parity (if number of 1's in the transmitted data frame is even then, a parity bit '1' is added to make total number of 1's to be odd)


> Please refer the sub directories for the program.

![seq_det](https://github.com/deepakravibabu/VHDL/blob/master/UART/Simulation_Output/uart_simulation_waveform.png)
