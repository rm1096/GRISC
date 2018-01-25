library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_div1 is
port (
  clk : in std_logic;
  div : out std_logic --new clock
);
end clock_div1;

architecture Behavioral of clock_div1 is
  signal count   : std_logic_vector (10 downto 0) := (others => '0');
  signal clk_1 : std_logic := '0';
begin
  
  process(clk)
  begin
  
    if rising_edge(clk) then
      
      if count  =  std_logic_vector(to_unsigned(1084,11)) then
       count    <= (others => '0');
       clk_1  <= '1';       
       else
       clk_1  <= '0';
       count    <=  std_logic_vector( unsigned(count) + 1 );
      end if;
     
    end if;
    
  end process;
  
  div <= clk_1;

end Behavioral;