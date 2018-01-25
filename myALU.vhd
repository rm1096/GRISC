
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myALU is
port ( 
    clk, en : in std_logic;
    A : in std_logic_vector(15 downto 0);
    B : in std_logic_vector(15 downto 0);
    Opcode : in std_logic_vector(3 downto 0);
    Y : out std_logic_vector(15 downto 0)
);
end myALU;

architecture Behavioral of myALU is

begin
   
    process(clk) begin
     if (rising_edge(clk) and en = '1') then
        case Opcode is
        when "0000" =>Y<= std_logic_vector(unsigned(A) + unsigned(B));
        when "0001" => Y<= std_logic_vector(unsigned(A) - unsigned(B));
        when "0010" => Y <= std_logic_vector(unsigned(A) sll 1);
        when "0011" => Y<= std_logic_vector(unsigned(A) srl 1);
        when "0100" => Y <= A(15) & A(15 downto 1);
        when "0101" => Y<=  A and B;
        when "0110" =>Y <=  A or B;
        when "0111" => Y <=  A xor B;
        when "1000" =>
        
        if (signed(A) < signed(B)) then
                                        Y(0) <= '1';
                                        Y(15 downto 1) <= (others => '0');    
                                    else
                                        Y(15 downto 0) <= (others => '0');
                                    end if;
        
        when "1001" =>
        
           if (signed(A) > signed(B)) then
                                             Y(0) <= '1';
                                             Y(15 downto 1) <= (others => '0');    
                                         else
                                             Y(15 downto 0) <= (others => '0');
                                         end if;
        when "1010" => 
        if signed(A) = signed(B) then
                                         Y(0) <= '1';
                                                       Y(15 downto 1) <= (others => '0');     
                                                   else
                                                       Y(15 downto 0) <= (others => '0');  
                                    end if;
        when "1011" => 
        if A < B then
                                         Y(0) <= '1';
                                                       Y(15 downto 1) <= (others => '0');   
                                                   else
                                                       Y(15 downto 0) <= (others => '0'); 
                                    end if;
        when "1100" =>
         if A > B then
                                                Y(0) <= '1';
                                                              Y(15 downto 1) <= (others => '0');   
                                                          else
                                                              Y(15 downto 0) <= (others => '0'); 
                                           end if;
        when "1101" => Y <=  std_logic_vector(unsigned(A) + 1);
        when "1110" => Y<=     std_logic_vector(unsigned(A) - 1);
        when "1111" => Y <= std_logic_vector(0 - unsigned(A));
        
       
    
        when others => Y <= (others => '0');
        end case;
        end if;
    end process;

end Behavioral;

