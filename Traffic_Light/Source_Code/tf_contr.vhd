--Traffic controller at the crossroad
--Traffic indicator changes in a specified cyclic intervals to clear traffic in all 4 roads   

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tf_contr is
  Generic(  timerRY  : integer := 5 ;
            timerG   : integer := 20;
            timerY   : integer := 5 ;
            timerR   : integer := 5; 
            timermax : integer := 100;
            road_no   : integer := 4 );
            
  Port ( clk : in std_logic;
        rst : in std_logic;
        Red : out std_logic_vector(4 downto 1);
        Yellow : out std_logic_vector(4 downto 1);
        Green : out std_logic_vector(4 downto 1)
  );    
end tf_contr;

architecture Behavioral of tf_contr is

type state is (RY, G, Y, R);
signal pr_state, nx_state : state;
signal timer : integer;

begin

process(clk, rst)
    variable counter : integer range 0 to timermax;
    begin
    if(rst = '1') then
        pr_state <= Y;
    elsif (counter < timer ) then
        if rising_edge (clk) then
            counter := counter + 1;
        end if;
    elsif(counter = timer) then
        pr_state <= nx_state;
        counter := 0;
    end if;

end process;

process(pr_state)
    variable no : integer range 1 to road_no; 
    begin
    if ( no <= road_no) then
            case pr_state is
                when RY =>
                    Red <= (others => '1');
                    Yellow <= (others => '0');
                    Green <= (others => '0');
                    
                    Red(no) <= '1';
                    Yellow(no) <= '1';
                    Green(no) <= '0';
                    
                    timer <= timerRY;
                    nx_state <= G;
                
                when G =>
                    Red <= (others => '1');
                    Yellow <= (others => '0');
                    Green <= (others => '0');
                    
                    Red(no) <= '0';
                    Yellow(no) <= '0';
                    Green(no) <= '1';
                    
                    timer <= timerG;
                    nx_state <= Y;
                    
                when Y =>
                    Red <= (others => '1');
                    Yellow <= (others => '0');
                    Green <= (others => '0');
                    
                    Red(no) <= '0';
                    Yellow(no) <= '1';
                    Green(no) <= '0';
                    
                    timer <= timerY;
                    nx_state <= R;
                    
                when R =>
                    Red <= (others => '1');
                    Yellow <= (others => '0');
                    Green <= (others => '0');
                    
                    Red(no) <= '1';
                    Yellow(no) <= '0';
                    Green(no) <= '0';                    
                    
                    timer <= 1; 
                    
                    if (no = 4) then
                        no := 1;
                    elsif (no < 4) then
                        no := no + 1;
                    end if;
                    nx_state <= RY;
                    
            end case;
    end if;
end process;

end Behavioral;
