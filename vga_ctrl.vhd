library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_ctrl is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           hcount : out STD_LOGIC_VECTOR (9 downto 0);
           vcount : out STD_LOGIC_VECTOR (9 downto 0);
           vid : out STD_LOGIC;
           hs : out STD_LOGIC;
           vs : out STD_LOGIC);
end vga_ctrl;

architecture Behavioral of vga_ctrl is
signal hcount_s : std_logic_vector(9 downto 0) := (others => '0');
signal vcount_s : std_logic_vector(9 downto 0) := (others => '0');

begin

    incrementing_hcount:process(clk)
    begin

        if rising_edge(clk) then
            if en = '1' then
                if hcount_s         = std_logic_vector(to_unsigned(799, 10)) then
                     hcount_s       <= (others => '0');
                 else
                     hcount_s    <= std_logic_vector( unsigned(hcount_s) + 1 );
                end if;
            end if;
        end if;
    end process incrementing_hcount;
    
    incrementing_vcount:process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if hcount_s = std_logic_vector(to_unsigned(0, 10)) then
                    if vcount_s    = std_logic_vector(to_unsigned(524, 10)) then
                        vcount_s    <= (others => '0');
                    else
                        vcount_s       <= std_logic_vector( unsigned(vcount_s) + 1 );
                    end if; 
                end if;
            end if;
        end if;
    end process incrementing_vcount;
    
    display:process(hcount_s, vcount_s) 
    begin
        if hcount_s >= std_logic_vector(to_unsigned(0, 10)) and hcount_s <= std_logic_vector(to_unsigned(639, 10)) and vcount_s >= std_logic_vector(to_unsigned(0, 10)) and vcount_s <= std_logic_vector(to_unsigned(479, 10)) then
            vid <= '1';
        else
            vid <= '0';
        end if; --end display on/off condition     
    end process display;
    
    hs_signal:process(hcount_s)
    begin
        if hcount_s >= std_logic_vector(to_unsigned(656, 10)) and hcount_s <= std_logic_vector(to_unsigned(751, 10)) then
            hs <= '0';
        else
            hs <= '1';
        end if; 
    end process hs_signal;
    
    vs_signal:process(vcount_s)
    begin                
        if vcount_s >= std_logic_vector(to_unsigned(490, 10)) and vcount_s <= std_logic_vector(to_unsigned(491, 10)) then
            vs <= '0';
        else
            vs <= '1';
        end if;                    
    end process vs_signal;                      
               
                    

    hcount  <= hcount_s;
    vcount  <= vcount_s;
end Behavioral;
