--for every 3rd camshaft signal, the inject should be triggered for certian specified clock period
--after a gap spark signal should be fired (ignition)
--cycle should repeat


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fuel_injector is
    Generic ( clock_counter_range : integer := 100;
              cam_count_value : integer := 3 ; 
              inject_time : integer := 3 ;
              wait_time : integer := 2 ;
              spark_time : integer := 1 ;
              state_check_time : integer := 0 );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           cam_pos : in STD_LOGIC;
           inject : out STD_LOGIC;
           spark : out STD_LOGIC);
end fuel_injector;

architecture Behavioral of fuel_injector is

type state is ( idle, cam_pos_on, cam_pos_off, injection, wait_state, spark_fuel );
signal pr_state, nx_state : state;
signal counter : integer range 0 to clock_counter_range;
signal timer : integer range 0 to clock_counter_range;
signal cam_count : integer range 0 to cam_count_value;

begin

--state_change: process(rst, clk)
----variable counter : integer range 0 to clock_counter_range;
--begin
--    if(rst = '1') then
--        pr_state <= idle;
--    elsif(counter < timer) then
--        if (rising_edge(clk)) then
----            counter := counter + 1;
--            counter <= counter + 1;
--        end if;
--    elsif(counter = timer) then
--        pr_state <= nx_state;
----        counter := 0;
--        counter <= 0;
--    end if;
--end process state_change;
    
process (rst, clk, timer, cam_count)
begin
    if(rst = '1') then
        pr_state <= idle;
    elsif( rising_edge (clk) ) then
        if(counter < timer) then
            counter <= counter + 1 ;
        elsif(cam_count = cam_count_value) then
            pr_state <= injection;
        elsif ( ( counter = timer) ) then
            pr_state <= nx_state;
            counter <= 0;
        end if;   
        
    
        
    end if;   
end process;


state_description: process(pr_state, cam_pos)
--variable cam_count : integer range 0 to cam_count_value;
begin
    case pr_state is
        
        when idle =>
            inject <= '0';
            spark <= '0';
            if(cam_pos = '0') then
                nx_state <= idle;
            elsif(cam_pos = '1') then
                nx_state <= cam_pos_on;
            end if;
            timer <= state_check_time;
        
        when cam_pos_on =>
            if(cam_count = cam_count_value) then
                nx_state <= injection;
                cam_count <= 0;
                timer <= state_check_time;
            elsif (cam_count /= cam_count_value) then
                if(cam_pos = '0') then
                    nx_state <= cam_pos_off;
                    timer <= state_check_time;
                    inject <= '0';
                    spark <= '0';
                elsif(cam_pos = '1') then
                    cam_count <= cam_count + 1;
                    nx_state <= cam_pos_on;
                    timer <= state_check_time;
                    inject <= '0';
                    spark <= '0';
                end if;
            end if;           
                     
        when cam_pos_off =>
            inject <= '0';
            spark <= '0';                   
            if(cam_pos = '0') then
                nx_state <= cam_pos_off;
                timer <= state_check_time;
            elsif(cam_pos = '1') then
                nx_state <= cam_pos_on;
                timer <= state_check_time;
            end if;
            
        when injection =>
            inject <= '1';
            spark <= '0';
            timer <= inject_time;
            nx_state <= wait_state;
            cam_count <= 0;
        
        when wait_state =>
            inject <= '0';
            spark <= '0';
            timer <= wait_time;
            nx_state <= spark_fuel;
        
        when spark_fuel =>
            inject <= '0';
            spark <= '1';
            timer <= spark_time;
            nx_state <= idle;
    end case;
    
end process state_description;

    
end Behavioral;
