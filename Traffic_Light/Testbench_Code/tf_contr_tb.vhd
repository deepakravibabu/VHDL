
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tf_contr_tb is
--  Port ( );
end tf_contr_tb;

architecture Behavioral of tf_contr_tb is

component tf_contr 
 Port ( clk : in std_logic;
        rst : in std_logic;
        Red : out std_logic_vector(4 downto 1);
        Yellow : out std_logic_vector(4 downto 1);
        Green : out std_logic_vector(4 downto 1) ); 
end component;

signal clk, rst : std_logic := '0';
signal Red, Yellow, Green : std_logic_vector(4 downto 1);
constant clock_period : time := 2 ns;

begin
uut: tf_contr port map ( clk => clk, rst => rst, Red => Red, Yellow => Yellow, Green => Green);

process
    begin
    wait for clock_period / 2;
    clk <= not clk;
end process;
end Behavioral;
