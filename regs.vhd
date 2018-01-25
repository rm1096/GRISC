library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regs is
Port (
	clk, en, reset  : in std_logic;
	id1, id2		: in std_logic_vector(4 downto 0); --addresses
	wr_en1, wr_en2	: in std_logic;
	din1, din2		: in std_logic_vector(15 downto 0);
	dout1, dout2	: out std_logic_vector(15 downto 0)
);
end regs;

architecture Behavioral of regs is

	
	--Memory consisting of 32 16-bit words
	type memory is array (0 to 31) of std_logic_vector(15 downto 0);
	signal registers	: memory := (others => (others => '0'));

begin
   
        dout1 <= registers(to_integer(unsigned(id1)));
        dout2 <= registers(to_integer(unsigned(id2))); 
   
    write : process(clk, reset, en)
    begin
    
     if reset = '1' then
               registers <= (others => (others => '0'));
		
    elsif rising_edge(clk) and en = '1' then 
		registers(0) <= (others => '0');
		
		
		if wr_en1 = '1' then
			registers(to_integer(unsigned(id1))) <= din1;
		end if;
		
		if wr_en2 = '1' then
			registers(to_integer(unsigned(id2))) <= din2;
		end if;
		
    end if; --end clock
	
    end process write;


end Behavioral;
