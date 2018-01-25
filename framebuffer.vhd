library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity framebuffer is
Port (
	--clk, en1, en2           : in std_logic;
	clk_a, clk_b            : in std_logic;
	addr1, addr2			: in std_logic_vector(11 downto 0); --addresses
	wr_en1					: in std_logic;
	din1					: in std_logic_vector(15 downto 0);
	dout1, dout2			: out std_logic_vector(15 downto 0)
);
end framebuffer;

architecture Behavioral of framebuffer is
	
	--Memory  consisting of 4096 16-bit words
	type memory is array (0 to 4095) of std_logic_vector(15 downto 0);
	signal memSignal	: memory := (others => (others => '0'));
	
begin

-- Port A
process(clk_a)
begin
    if(rising_edge(clk_a)) then
        if(wr_en1='1') then
            memSignal(to_integer(unsigned(addr1))) <= din1;
        end if;
        dout1 <=  memSignal(to_integer(unsigned(addr1)));
   end if;
end process;

--Port B
process (clk_b)
begin
    if(rising_edge(clk_b)) then 

               dout2 <=  memSignal(to_integer(unsigned(addr2)));
          
    end if;
end process;

 
end Behavioral;