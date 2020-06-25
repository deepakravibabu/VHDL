

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_ms_sl_tb is
--  Port ( );
end spi_ms_sl_tb;

architecture Behavioral of spi_ms_sl_tb is

constant spi_bits : integer := 8;
constant spi_clk_div : integer := 3;

component spi_ms
  generic ( USPI_SIZE : integer := 4 ;
            max_clk_div : integer := 3);
  Port ( bclk : in std_logic;
         rstn : in std_logic;
         sndData : in std_logic_vector(USPI_SIZE-1 downto 0);
         rcvData : out std_logic_vector(USPI_SIZE-1 downto 0);
         sdi  : in std_logic;
         start : in std_logic;
         scsq : out std_logic;
         sclk : out std_logic;
         sdo  : out std_logic;
         done : out std_logic  );
end component spi_ms;

component spi_sl is
 generic ( USPI_SIZE : integer := 4);
  Port ( bclk : in std_logic;
         rstn : in std_logic;
         done : out std_logic;
         slsdo : out std_logic;
         slsdi : in std_logic;
         slsclk : in std_logic;
         slcsq : in std_logic;
         slsndData : in std_logic_vector(USPI_SIZE-1 downto 0);
         slrcvData : out std_logic_vector(USPI_SIZE-1 downto 0) );
end component spi_sl;

signal rstn : std_logic := '1';
signal bclk : std_logic := '0';
signal start : std_logic := '0';
signal done_ms : std_logic := '0';
signal done_sl : std_logic := '0';
signal scsq : std_logic := '0';
signal sclk : std_logic := '0';
signal mosi : std_logic := '0';
signal miso : std_logic := '0';
signal sndData_ms : std_logic_vector(spi_bits-1 downto 0) := "11010101";
signal rcvData_ms : std_logic_vector(spi_bits-1 downto 0);
signal sndData_sl : std_logic_vector(spi_bits-1 downto 0) := "10100111";
signal rcvData_sl : std_logic_vector(spi_bits-1 downto 0);

constant clock_period : time := 10 ns;

begin

uut_ms: spi_ms
     generic map ( USPI_SIZE => spi_bits, max_clk_div => spi_clk_div )
     port map ( bclk => bclk, rstn => rstn, sndData => sndData_ms, rcvData => rcvData_ms, sdi => miso,
                           start => start, scsq => scsq, sclk => sclk, sdo => mosi, done => done_ms);
                           
uut_sl: spi_sl 
     generic map ( USPI_SIZE => spi_bits)   
     port map ( bclk => bclk, rstn => rstn, slsndData => sndData_sl, slrcvData => rcvData_sl, slsdi => mosi,
                           slcsq => scsq, slsclk => sclk, slsdo => miso, done => done_sl);


clk: process
begin
    wait for clock_period / 2;
    bclk <= not bclk;
end process;

rst: process
begin
    wait for clock_period *2;
    rstn <= '0';
    wait for clock_period *1;
    rstn <= '1';
    wait;
end process rst;

start_p : process
begin
    wait for clock_period * 4;
    start <= '1';
    wait for clock_period * 4;
    start <= '0';
    wait;
end process start_p;

end Behavioral;
