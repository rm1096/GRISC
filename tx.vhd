library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           send : in STD_LOGIC;
           rst : in STD_LOGIC;
           char : in STD_LOGIC_VECTOR (7 downto 0);
           ready : out STD_LOGIC;
           tx : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is

    type state is (idle, data, stop);
    signal curr : state := idle;
    
    --shift register
    signal d        : std_logic_vector (7 downto 0) := (others => '0');
    
    --counter
    signal count    : std_logic_vector (2 downto 0) := (others => '0'); 
    

begin

    process (clk) begin
    
        if rst = '1' then
            curr    <=     idle;
            d       <=     (others => '0');
            count   <=     (others => '0'); 
            tx      <=      '1';
            ready   <=      '1';
        
        elsif rising_edge(clk) and en = '1' then
           case curr is
          
                when idle =>
                    if send = '1' then
                        d       <= char;
                        ready   <= '0';
                        count   <= (others => '0');
                        curr    <= data;
                        tx      <= '0';
                        
                    else
                        tx  <= '1';
                        ready <= '1';
                    
                    end if;
                when data =>
                    tx  <= d(0);
                    d   <= '0' & d(7 downto 1);
                    if unsigned(count) < 7 then                       
                        count <= std_logic_vector(unsigned(count) + 1);                   
                    else                       
                        curr <= stop;                     
                    end if;
                
                when stop => 
                    tx      <= '1';
                    ready   <= '0';
                    curr    <= idle;
                
                when others =>
                    curr <= idle;
          end case;         
        end if;
             
    end process;
end Behavioral;
