## SPI Protocol
- Serial Peripheral Interface (SPI) is a synchronous communication protocol
- Devices communicating via SPI are in a master-slave relationship. The master is the
controlling device (usually a micro-controller), while the slave (usually a sensor, display, or
memory chip) takes instruction from the master. (one master can control more than one slave)

## SPI Master:
- The SPI master upon getting the start signal, will select the slave to communicate with
by lowering the corresponding chip_select (SCSQ) line. Then the master will generate a spi
clock signal with number of clock ticks equal to the number of bits to be transferred or read.
Since the SPI mode chosen is CPOL=0 and CPHA=1, the master transmits the data bit by bit
for every rising edge of the spi clock (sclk) on the MOSI line with MSB first. On every falling
edge of sclk, the master reads the data sent by the slave from its MISO line. Once the data is
sent, the sclk line becomes 0 and the chip select is made to 1.

## SPI Slave:
- The slave devices listens to its chip select (slcsq) line. When the slcsq line becomes
low, then the slave understands that it is being selected by the master. The slave starts
transmitting data on its serial data out port (miso) on the rising edge of the sclk
simultaneously, reading data from its serial data in port (mosi) on every falling edge of sclk.
The sclk is generated and transmitted by the master to the slave. The SPI mode chosen is
CPOL=0 and CPHA=1.

> Please refer the sub directories for the program.

![Alt text](https://github.com/deepakravibabu/VHDL/blob/master/SPI/Simulation_Waveform/spi.png)
![spi_ms_wavf](https://github.com/deepakravibabu/VHDL/blob/master/SPI/Simulation_Waveform/spi_ms_sl.png)
