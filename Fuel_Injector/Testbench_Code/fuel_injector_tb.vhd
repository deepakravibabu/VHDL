----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2020 05:44:22 PM
-- Design Name: 
-- Module Name: fuel_injector_tb - Behavioral
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

entity fuel_injector_tb is
--  Port ( );
end fuel_injector_tb;

architecture Behavioral of fuel_injector_tb is

component fuel_injector 
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           cam_pos : in STD_LOGIC;
           inject : out STD_LOGIC;
           spark : out STD_LOGIC);
end component;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal cam_pos, inject, spark : std_logic := '0';
constant clock_period : time := 1 ns;
constant cam_period : time := 2 ns;

begin
uut: fuel_injector port map ( clk => clk,rst => rst, cam_pos => cam_pos, inject => inject, spark => spark);

    clock_signal: process
    begin
        wait for clock_period / 2;
        clk <= not clk;
        rst <= '0';
    end process clock_signal;
    
    cam_signal: process
    begin
        wait for cam_period;
        cam_pos <= '1';
        wait for cam_period;
        cam_pos <= '0';
        wait for cam_period;
        cam_pos <= '1';
        wait for cam_period;
        cam_pos <= '0';
        wait for cam_period;
        cam_pos <= '1';
        wait for cam_period;
        cam_pos <= '0';
        wait for cam_period;
        wait;
    end process cam_signal;
    
end Behavioral;
