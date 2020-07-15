library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sequence_detector_tb is
--  Port ( );
end sequence_detector_tb;

architecture Behavioral of sequence_detector_tb is

component sequence_detector is
    port ( clk, rst, din : in std_logic;
                    dout : out std_logic);
end component;

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal din : std_logic := '0';
signal dout : std_logic := '0';
constant clock_period : time := 2 ns;

begin
uut: sequence_detector port map ( 
                            clk => clk, 
                            rst => rst,
                            din => din,
                            dout => dout);

clock_timing: process
    begin
        wait for clock_period / 2 ;
        clk <= '1';
        wait for clock_period / 2 ;
        clk <= '0';
     end process;

input_values: process
    begin
        wait for clock_period;
        din <= '1';
        
        wait for clock_period;
        din <= '1';
        
        wait for clock_period;
        din <= '0';
        
        wait for clock_period;
        din <= '1';
        
        wait for clock_period;
        din <= '1';
        
        wait for clock_period;
        din <= '0';
        
        wait for clock_period;
        
     end process;
end Behavioral;
