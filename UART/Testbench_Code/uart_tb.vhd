----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2020 11:20:45 AM
-- Design Name: 
-- Module Name: uart_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tb is
--  Port ( );
end uart_tb;

architecture Behavioral of uart_tb is

component uart is
  Generic (data_len : integer);
  Port (rst   : in std_logic;
        clk     : in std_logic;
        start   : in std_logic;
        txdata  : in std_logic_vector(data_len-1 downto 0);
        TxD     : out std_logic;
        done    : out std_logic);
end component uart;
constant data_len_tb : integer := 7;
signal rst      : std_logic := '0';
signal clk      : std_logic := '0';
signal start    : std_logic := '0';
signal txdata   : std_logic_vector(data_len_tb-1 downto 0);
signal TxD      : std_logic;
signal done     : std_logic;
constant clk_period : time := 10 ns;
begin

uut: uart 
generic map (data_len => data_len_tb)
port map (rst => rst, clk => clk, start => start, txdata => txdata, TxD => TxD, done => done);

clk_p: process
begin
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
end process clk_p;

sim_p: process
begin
    wait for clk_period * 3;
    wait for clk_period/2;
    txdata <= "1100100";  --data to be sent
    start <= '1';
    wait for clk_period;
    start <= '0';
    wait for clk_period;
    wait;
end process sim_p;


end Behavioral;
