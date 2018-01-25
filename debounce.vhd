
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
port (
  clk   : in std_logic;
  btn   : in std_logic;
  dbnc  : out std_logic 
);
end debounce;

architecture Behavioral of debounce is
   signal count     : std_logic_vector (21 downto 0) := (others => '0');
   signal sregister : std_logic_vector (1 downto 0)  := (others => '0');

begin
    process(clk)
    begin
 
        if rising_edge(clk) then 
            sregister(1)    <= sregister(0);
            sregister(0)    <= btn;
            
            if count =  std_logic_vector(to_unsigned(2500000,22)) then 
                dbnc <= '1';
            else
                dbnc <= '0';
            end if;
            
            if sregister(1) = '1' then
                 if count        /=  std_logic_vector(to_unsigned(2500000,22)) then
                           count <= std_logic_vector(unsigned(count)+ 1);
                 end if;
           else
             count <= (others => '0');
           end if;
     
        end if;
   
    end process;

end Behavioral;