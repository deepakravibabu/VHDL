----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2020 10:36:13 AM
-- Design Name: 
-- Module Name: uart - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
  Generic (data_len : integer);
  Port (rst   : in std_logic;
        clk     : in std_logic;
        start   : in std_logic;
        txdata  : in std_logic_vector(data_len-1 downto 0);
        TxD     : out std_logic;
        done    : out std_logic
        );
end uart;

architecture Behavioral of uart is

type state is (idle, start_tx, start_bit, snd_data, end_tx_parity, stop_bit);
signal pr_state, nx_state   : state;
signal wr_buff              : std_logic_vector(data_len-1 downto 0);
signal ones                 : integer := 0;
signal cnt                  : integer := 0;
signal TxDi                 : std_logic := '1';

begin

TxD <= TxDi;
cmb_p: process(pr_state, start, cnt, ones, wr_buff)
begin
nx_state <= pr_state; 
case pr_state is 
    when idle =>
    TxDi <= '1';
    done <= '1';
        if (start = '1') then
            nx_state <= start_tx;
        end if;
    
    when start_tx =>
        done <= '0';
        nx_state <= start_bit;
        
    when start_bit =>
        TxDi <= '0';
        done <= '0';
        nx_state <= snd_data;
    
    when snd_data =>
        TxDi <= wr_buff(data_len-1);
        if (cnt > data_len-2) then
            nx_state <= end_tx_parity;
        end if;
        
    when end_tx_parity =>
        if(ones mod 2) = 0 then
            TxDi <= '1';
        else
            TxDi <= '0';
        end if;
        nx_state <= stop_bit;
        
    when stop_bit =>
        TxDi <= '0';
        nx_state <= idle;    
   
   end case;        
end process cmb_p;


seq_p: process(clk, rst) 
begin
    if rising_edge(clk) then
        if (rst = '1') then
            pr_state <= idle;
        else
            pr_state <= nx_state;
            if (pr_state = idle and nx_state = start_tx) then
                wr_buff <= txdata;
            elsif(pr_state = idle and nx_state = idle) then
                cnt <= 0;
                ones <= 0;
            elsif (pr_state = snd_data) then
                wr_buff <= std_logic_vector(unsigned(wr_buff) sll 1);
                cnt <= cnt + 1;
                if(wr_buff(data_len-1) = '1') then
                    ones <= ones + 1;
                end if;
            end if;
        end if;
    end if;
end process seq_p;


end Behavioral;
