---------------------------------------------------------------------------------------------------------------------------------------------
-- Create Date: 06/07/2020 05:37:04 PM
-- Design Name: SPI_Master
-- Module Name: spi_ms - Behavioral
-- Project Name:SPI_Master 
-- Target Devices: Zedboard Zync device
-- Tool Versions: 2019.2
-- Description: The master sends to and reads data from a slave device. Master generates a spi clock
-- pulse to synchronizes the communication with the salve.
-- Dependencies: vhdl ieee libraries 
-- Revision 0.01 - File Created
-- Additional Comments: The master code has to be run along with slave code by providing the test bench file (attached). If not, necessary 
-- input signals has to given manually to the ports (by writing different testbench file) to check the functionality of master alone
----------------------------------------------------------------------------------------------------------------------------------------------

-- required libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- unsigned data_type is defined in this library
use IEEE.NUMERIC_STD.ALL;

entity spi_ms is
	--genric delcarations	
	generic ( USPI_SIZE : integer;	-- bit size of data to be sent 
			max_clk_div : integer);	-- generate spi clock with freqency of 2x(max_clk_div) of bclk  
	
	--port delcarations		
	Port (     bclk : in std_logic;									-- base clock
			   rstn : in std_logic;									-- active low reset
			sndData : in std_logic_vector(USPI_SIZE-1 downto 0);	-- data to be sent by master
			rcvData : out std_logic_vector(USPI_SIZE-1 downto 0);	-- data read by master
			    sdi : in std_logic;									-- serial data in
			  start : in std_logic;									-- start signal for spi communication
			   scsq : out std_logic;								-- serial chip select of master to activate a slave
			   sclk : out std_logic;								-- spi clock signal
			    sdo : out std_logic;								-- serial data out
			   done : out std_logic );								-- signal to indicate completion of spi communication
end spi_ms;

architecture Behavioral of spi_ms is
	
	-- defined states used for implementing the logic
	type state is (sidle, sstartx, sstart_lo, sclk_hi, sclk_lo, stop_hi, stop_lo);
	signal pr_state, nx_state : state;
	
	-- defined internal signals used for implementing the logic
	signal scsq_i : std_logic;
	signal wr_buf : std_logic_vector(USPI_SIZE-1 downto 0);
	signal rd_buf : std_logic_vector(USPI_SIZE-1 downto 0) := (others=> '0');
	signal count : integer range 0 to USPI_SIZE -1;
	signal sclk_i : std_logic;
	signal sdo_i : std_logic;
	signal sclk_p : std_logic;
	
begin
-- the output port rcvData is mapped to the created internal signal rd_buf
-- rd_buf is used to perform shift operations converting the serial data to parallel
rcvData <= rd_buf;

--combinational section to evaluate the next state logic
comb :process(pr_state, start, count, wr_buf)
	begin
	--default values for the signals to avoid creating unwanted storage elements
	nx_state <= pr_state;
	scsq_i <= '0';
	sclk_i <= '0';
	done <= '0';
	sdo_i <= '0';
	case pr_state is
		when sidle =>
			done <= '1';
			7scsq_i <= '1';
			if(start = '1') then
				nx_state <= sstartx;
			end if;
		when sstartx =>
			nx_state <= sstart_lo;
		when sstart_lo =>
			sdo_i <= wr_buf(USPI_SIZE-1);
			sclk_i <= '1'; -- sclk_i becomes 1 but it will update the sclk only on the next transition
			nx_state <= sclk_hi;
		when sclk_hi =>
			sdo_i <= wr_buf(USPI_SIZE-1);
			-- sdo_i becomes wr_buf(7-1) but it will update the sdo only on the next transition
			nx_state <= sclk_lo;
		when sclk_lo =>
			sclk_i <= '1';
			sdo_i <= wr_buf(USPI_SIZE-1);
			-- parallel to serial conv
			if ( count = 0 ) then
				nx_state <= stop_hi;
			else
				nx_state <= sclk_hi; -- loop back to sclk_hi when not all bits are transmitted
			end if;
		when stop_hi =>
			sdo_i <= wr_buf(USPI_SIZE-1);
			nx_state <= stop_lo;
		when stop_lo =>
			scsq_i <= '1';
			nx_state <= sidle;
	end case;
end process comb;

--sequential process to update the states
seq: process(bclk, sdi)
begin
	if (rising_edge(bclk)) then
		if(rstn = '0') then
			pr_state <= sidle;
		elsif (sclk_p = '1') then
			-- sclk_p becomes 1 for every 3rd bclk slowing down the state transition by 1/3
			if(nx_state = sstartx) then
				wr_buf <= sndData;
				count <= USPI_SIZE-1;
			elsif(nx_state = sclk_hi) then
				count <= count - 1;
			elsif(nx_state = sclk_lo) then
				rd_buf <= rd_buf(USPI_SIZE-2 downto 0) & sdi;
				-- rd_buf is bit shifted left and last bit is appended with bit from miso line (sdi line)
				wr_buf <= std_logic_vector(shift_left(unsigned(wr_buf), 1));
				-- wr_buf is bit shifted left to make the next bit to be transmitted into the msb
			elsif(nx_state = stop_lo) then
				rd_buf <= rd_buf(USPI_SIZE-2 downto 0) & sdi;
				-- rd_buf is bit shifted left and last bit is appended with bit from miso line (sdi line)
				-- serial to parallel word conv
			end if;
			pr_state <= nx_state;
			-- the output ports are updated with their internal signals only during transition making it stabe (flip-flop)
			scsq <= scsq_i;
			sclk <= sclk_i;
			sdo <= sdo_i;
		end if;
	end if;
8end process seq;

--process created to divide the bclk and generate sclk
clk_div: process (bclk)
variable clk_div : integer range 0 to max_clk_div-1 := max_clk_div-1;
begin
	if rising_edge(bclk) then
		if (clk_div = 0) then
			sclk_p <= '1';
			clk_div := max_clk_div-1;
			elsif (clk_div > 0) then
				clk_div := clk_div - 1;
				sclk_p <= '0';
			end if;
		end if;
end process clk_div;
end Behavioral;
