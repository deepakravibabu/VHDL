------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create Date: 06/16/2020 09:30:01 PM
-- Design Name: SPI_Slave
-- Module Name: spi_sl - Behavioral
-- Project Name: SPI_Slave
-- Target Devices: Zedboard Zync device
-- Tool Versions: 2019.2
-- Description: The slave sends data to the master once it's chip select is activated. The communication happens synchronized with the spi clock pulse.
-- Dependencies: vhdl ieee libraries 
-- Revision 0.01 - File Created
-- Additional Comments:The slave code has to be run along with master code by providing the test bench file (attached). If not, necessary 
-- input signals has to given manually to the ports (by writing different testbench file) to check the functionality of slave alone
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- required libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- unsigned data_type is defined in this library
use IEEE.NUMERIC_STD.ALL;

entity spi_sl is
	-- genric delcaration	
	generic ( USPI_SIZE : integer); 									-- bit size of data to be sent 
	-- port declarations
	Port ( 		bclk : in std_logic;									-- base clock
         		rstn : in std_logic;									-- active low reset
				done : out std_logic;									-- signal to indicate completion of spi communication
			   slsdo : out std_logic;									-- serial data out
			   slsdi : in std_logic;									-- serial data in
			  slsclk : in std_logic;									-- spi clock
			   slcsq : in std_logic;									-- serial chip select
		   slsndData : in std_logic_vector(USPI_SIZE-1 downto 0);		-- data to be sent by slave
           slrcvData : out std_logic_vector(USPI_SIZE-1 downto 0) );	-- data read by slave
end spi_sl;

architecture Behavioral of spi_sl is

-- defined states used for implementing the logic
type state is (idle, csstart, starthi_s, starthi, startlo_s, startlo, clkhi_s, clk_hi, clklo_s, clklo, leadout);
signal pr_state, nx_state : state;

-- defined internal signals used for implementing the logic
signal count : integer range 0 to USPI_SIZE-1;
signal sdo_buf : std_logic_vector(USPI_SIZE -1 downto 0);
signal sdi_buf : std_logic_vector(USPI_SIZE -1 downto 0) := (others => '0');

begin
-- the output port slrcvData is mapped to the created internal signal sdi_buf 
-- sdi_buf is used to perform shift operations converting the serial data to parallel
slrcvData <= sdi_buf;

--combinational section to evaluate the next state logic
comb_p : process(pr_state, slcsq, slsclk) 
begin
--default values for the signals to avoid creating unwanted storage elements
nx_state <= pr_state;
done <= '0';
	case pr_state is
		when idle =>
			done <= '1';
			if (slcsq = '0') then
				nx_state <= csstart;
			end if;
		when csstart =>
			if ( slsclk = '1') then
				nx_state <= starthi_s;
			end if;
		when starthi_s =>
			nx_state <= starthi;
		when starthi =>
			if (slsclk = '0') then
				nx_state <= startlo_s;
			end if;
		when startlo_s =>
			nx_state <= startlo;
		when startlo =>
			if ( slsclk = '1') then
				nx_state <= clkhi_s;
			end if;
		when clkhi_s =>
			nx_state <= clk_hi;
		when clk_hi =>
			if ( slsclk = '0') then
				nx_state <= clklo_s;
			end if;
		when clklo_s =>
			nx_state <= clklo;
		when clklo =>
			if (count = 0) then
				nx_state <= leadout;
			elsif ( slsclk = '1') then
				nx_state <= clkhi_s;
			end if;
		when leadout =>
			 if (slcsq = '1') then
				nx_state <= idle;
			end if;                 
	end case;
end process comb_p;

--sequential process to update the states
seq_p: process(bclk)
begin
    if (rising_edge(bclk)) then
        if (rstn = '0') then
            pr_state <= idle;
        elsif (nx_state = csstart) then
            count <= USPI_SIZE-1;
            sdo_buf <= slsndData; 
        elsif (nx_state = starthi_s) then
            slsdo <= sdo_buf(USPI_SIZE -1);        
        elsif (nx_state = startlo_s) then
            sdi_buf <= sdi_buf(USPI_SIZE -2 downto 0) & slsdi;  -- sdi_buf is bit shifted left and last bit is appended with bit from mosi line (slsdi line)
            sdo_buf <= std_logic_vector(shift_left(unsigned(sdo_buf), 1)); -- sdo_buf is bit shifted left to make the next bit to be transmitted as the MSB
        elsif (nx_state = clkhi_s) then
            slsdo <= sdo_buf(USPI_SIZE -1);        
            count <= count - 1;
        elsif ( nx_state = clklo_s) then
            sdi_buf <= sdi_buf(USPI_SIZE -2 downto 0) & slsdi;  -- sdi_buf is bit shifted left and last bit is appended with bit from mosi line (slsdi line)
            sdo_buf <= std_logic_vector(shift_left(unsigned(sdo_buf), 1));
        elsif (nx_state = idle) then
            slsdo <= '0';
        end if;
    pr_state <= nx_state;
    end if;
end process seq_p;

end Behavioral;
