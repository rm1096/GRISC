library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pixel_pusher is
Port (
    clk     : in std_logic;
    en      : in std_logic;
    VS      : in std_logic;
    pixel   : in std_logic_vector(15 downto 0);
    hcount  : in std_logic_vector(9 downto 0); 
	vcount 	: in std_logic_vector(9 downto 0);
	
    vid     : in std_logic;
    R       : out std_logic_vector(4 downto 0) := (others => '0');
    B       : out std_logic_vector(4 downto 0) := (others => '0');
    G       : out std_logic_vector(5 downto 0) := (others => '0');
    addr    : out std_logic_vector(11 downto 0):= (others => '0')   
    
);
end pixel_pusher;

architecture Behavioral of pixel_pusher is

signal counter : std_logic_vector(11 downto 0);

begin

    addr_count: process(clk)
    begin
    if rising_edge(clk) and en = '1' then 

        if VS = '0' then
              counter <= (others => '0');
         
        elsif vid = '1' and hcount < std_logic_vector(to_unsigned(64, 10)) and vcount < std_logic_vector(to_unsigned(64, 10)) then 
            counter       <= std_logic_vector( unsigned(counter) + 1 ); 
            R <= pixel(15 downto 11);
            G <= pixel(10 downto 5);
            B <= pixel(4 downto 0);
            else
                 R <= (others => '0');
                 G <= (others => '0');
                 B <= (others => '0');
            
        end if;

    end if; --end clock
    end process addr_count;


addr <= counter;

end Behavioral;
