-------------SEQUENCE DETECTOR "11011"-------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sequence_detector is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           din : in STD_LOGIC;
           dout : out STD_LOGIC);
end sequence_detector;

architecture Behavioral of sequence_detector is

    type state is (S0, S1, S2, S3, S4, S5);
    signal pr_state, nx_state : state;
    attribute enum_encoding : string;
    attribute enum_encoding of state : type is "sequential";
    
    begin
    
    process(clk, rst)
        begin
        if (rst = '1') then
            pr_state <= S0;
        elsif (clk'event and clk ='1') then
            pr_state <= nx_state;
        end if;
    end process;
    
    process(pr_state, din)
        begin
        case pr_state is
            when S0 =>
                if ( din ='1') then
                    nx_state <= S1;
                elsif ( din ='0') then
                    nx_state <= S0 ;
                end if;
            
            when S1 =>
                if ( din = '1') then
                    nx_state <= S2;
                elsif (din ='0') then
                    nx_state <= S0;
                end if;
                
            when S2 =>
                if ( din = '1') then
                    nx_state <= S1;
                elsif (din ='0') then
                    nx_state <= S3;
                end if;
                
            when S3 =>
                if ( din = '1') then
                    nx_state <= S4;
                elsif (din ='0') then
                    nx_state <= S0;
                end if;
                
            when S4 =>
                if ( din = '1') then
                    nx_state <= S5;
                elsif (din ='0') then
                    nx_state <= S0;
                end if;
                
            when S5 =>
                if ( din = '1') then
                    nx_state <= S1;
                elsif (din ='0') then
                    nx_state <= S0;
                end if;
         
         end case;
    end process;      
                
    process (pr_state)
        begin
        if (pr_state = S5) then
            dout <= '1';
        else
            dout <= '0';
        end if;
    end process;

end Behavioral;
