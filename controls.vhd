library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity controls is port (
-- Timing Signals
clk, en, rst : in std_logic;
-- Register File IO
rID1, rID2 : out std_logic_vector(4 downto 0);
wr_enR1, wr_enR2 : out std_logic;
regrD1, regrD2 : in std_logic_vector(15 downto 0);
regwD1, regwD2 : out std_logic_vector(15 downto 0);
-- Framebuffer IO
fb_wr_en : out std_logic;
--fbRST : out std_logic;
fbAddr1 : out std_logic_vector(11 downto 0);
fbDin1 : in std_logic_vector(15 downto 0);
fbDout1 : out std_logic_vector(15 downto 0);
-- Instruction Memory IO
irAddr : out std_logic_vector(13 downto 0);
irWord : in std_logic_vector(31 downto 0);
-- Data Memory IO
dAddr : out std_logic_vector(14 downto 0);
d_wr_en : out std_logic;
dOut : out std_logic_vector(15 downto 0);
dIn : in std_logic_vector(15 downto 0);
-- ALU IO
aluA, aluB : out std_logic_vector(15 downto 0);
aluOp : out std_logic_vector(3 downto 0);
aluResult : in std_logic_vector(15 downto 0);
-- UART IO
ready, newChar : in std_logic;
send : out std_logic;
charRec : in std_logic_vector(7 downto 0);
charSend : out std_logic_vector(7 downto 0)
);
end controls;

architecture Behavioral of controls is
	--Signals
	signal instruct : std_logic_vector(31 downto 0) := (others => '0');
	signal pc     : std_logic_vector(15 downto 0) := (others => '0');
	signal result  : std_logic_vector(15 downto 0) := (others => '0');
	
	--Rops Signals
	signal opcode_r    : std_logic_vector(4 downto 0) := (others => '0');
	signal source1_r   : std_logic_vector(4 downto 0) := (others => '0');
	signal source2_r   : std_logic_vector(4 downto 0) := (others => '0');
	signal dest_r      : std_logic_vector(4 downto 0) := (others => '0');
	
	--Iops Signals
	signal opcode_i    : std_logic_vector(4 downto 0) := (others => '0');
	signal source_i    : std_logic_vector(4 downto 0) := (others => '0');
	signal dest_i      : std_logic_vector(4 downto 0) := (others => '0');
	signal imm_i       : std_logic_vector(15 downto 0) := (others => '0');
	
	--Jops Signals
	signal opcode_j    : std_logic_vector(4 downto 0) := (others => '0');
	signal dest_j      : std_logic_vector(15 downto 0) := (others => '0');
	
	signal regA, regB, regC : std_logic_vector(15 downto 0);
	signal sum : std_logic_vector(15 downto 0);
    
    signal count : std_logic := '0';
	
	--FSM States
	type state is (fetch, decode, Rops, Iops, Jops, calc, store, jr, recv, rpix, wpix, send_state, equals, nequal, ori, lw, sw, jmp, jal,  finish, getAluResult, getAluResult2, lw2, send_temp); --clrsrc
	signal curr : state := fetch;
	
	
	begin 
	
	p: process (clk)
	begin
	
		if rst = '1' then
		 --- SET EVERYTHING TO 0 
		  rID1 <= (others => '0');
		  rID2 <= (others => '0');
		  wr_enR1 <= '0';
		  wr_enR2 <= '0';
		  regwD1 <= (others => '0');
		  regwD2 <= (others => '0');
		  --fbRST <= '0';
		  fbAddr1 <= (others => '0');
		  fbDout1 <= (others => '0');
		  irAddr <= (others => '0');
		  dAddr <= (others => '0');
		  d_wr_en <= '0';
		  aluA <= (others => '0');
		  aluB <= (others => '0');
		  aluOp <= (others => '0');
		  send <= '0';
		  charSend <= (others => '0');
		  
		  instruct <= (others => '0');
		  pc <= (others => '0');
		  result <= (others => '0');
		  opcode_r <= (others => '0');
		  source1_r <= (others => '0');
		  source2_r <= (others => '0');
		  dest_r <= (others => '0');
		  opcode_i <= (others => '0');
		  source_i <= (others => '0');
		  dest_i <= (others => '0');
		  imm_i <= (others => '0');
		  opcode_j <= (others => '0');
		  dest_j <= (others => '0');
		  regA <= (others => '0');
		  regB <= (others => '0');
		  regC <= (others => '0');
		  sum <= (others => '0');
		  
		 
		  curr <= fetch;  
		
		
		elsif rising_edge(clk) and en = '1' then
		
			case curr is
				--Fetch
				when fetch =>
				    if count = '0' then
				        rID1 <= "00001";
				        curr <= fetch;
				        count <= '1';
				    
				    else
				        pc <= regrD1;
				        irAddr   <= regrD1(13 downto 0);
				        report integer'image(to_integer(unsigned(pc)));
				    --NS
					    curr <= decode;
                        count <= '0';
                    end if;
				--Decode
				when decode =>
				    
				    if count = '0' then
				        instruct <= irWord;
				    
				        curr <= decode;
				        count <= '1';
				    else
				    --increment
				        rID1 <= "00001";
				        regwD1 <= std_logic_vector( unsigned(pc) + 1 ); 		   			
				        wr_enR1 <= '1';
				    
				    --NS 
				        count <= '0';       
				        if instruct(31 downto 30) = "00" or instruct(31 downto 30) = "01" then
                            curr <= rops;
                        elsif instruct(31 downto 30) = "10" then
                            curr <= iops;
                        else
                            curr <= jops;
                        end if;
                    end if;
				   
	
				--Rops
				when rops =>	
				    wr_enR1 <= '0';
				    opcode_r    <= instruct(31 downto 27);
				    dest_r      <= instruct(26 downto 22);
				    source1_r   <= instruct(21 downto 17);
				    source2_r   <= instruct(16 downto 12);
				    
				    
				    rID1 <= instruct(21 downto 17);
				    rID2 <= instruct(16 downto 12);
				    
				    regA <= regrD1;
				    regB <= regrD2;
						    				    
				    --NS
				    if instruct(31 downto 27) = "01101" then
				        curr <= jr;
				    elsif instruct(31 downto 27) = "01100" then
				        curr <= recv;
				    elsif instruct(31 downto 27) = "01111" then
				        curr <= rpix;
				    elsif instruct(31 downto 27) = "01110" then
				        curr <= wpix;
				           rID2 <= instruct(26 downto 22);
				    elsif instruct(31 downto 27) = "01011" then
				        curr <= send_state;
				    else
				        curr <= calc;
				    end if;
				
				
				--Iops
				when iops =>
				    wr_enR1 <= '0';
				    opcode_i    <= instruct(31 downto 27);
				    dest_i      <= instruct(26 downto 22);
				    source_i    <= instruct(21 downto 17);
				    imm_i       <= instruct(16 downto 1);
				    
				    rID1 <= instruct(26 downto 22);
				    rID2 <= instruct(21 downto 17);
				    
				    regA <= regrD1;
				    regB <= regrD2;
				    
				  
                    if instruct(29 downto 27) = "000" then
                        curr <= equals;
                    elsif instruct(29 downto 27) = "001" then
                        curr <= nequal;
                    elsif instruct(29 downto 27) = "010" then
                        curr <= ori;
                    elsif instruct(29 downto 27) = "011" then
                        curr <= lw;
                    else
                        curr <= sw;
                    end if;
				    

				--Jops
				when jops =>
				    wr_enR1 <= '0';
				    opcode_j <= instruct(31 downto 27);
				    dest_j   <= instruct(26 downto 11);
				    
				    --rID1 <= instruct(26 downto 11);
				    --regC <= regRD1;
				
				    --NS
				    if instruct(31 downto 27) = "11000" then
				        curr <= jmp;
				    elsif instruct(31 downto 27) = "11001" then
				        curr <= jal;
				    else
				        curr <=  finish;
				    end if;
				        			    

				--calc
				when calc => 

				    aluOp <= opcode_r(3 downto 0);
				    aluA  <= regrD1;
				    aluB  <= regrD2;
				    curr <= getAluResult;
				 
				 when getAluResult =>
			
				    --result <= aluResult;			  			 
				    curr <= getAluResult2;
				   
				 when getAluResult2 =>
                                
                                        result <= aluResult;                           
                                        curr <= store;
				--store
				
				when store =>
				    if count = '0' then 
				        rID1 <= instruct(26 downto 22);
				    
                        regwD1 <= result;
				        wr_enR1 <= '1';
				        count <= '1';
				        curr <= store;
				     else
				        wr_enR1 <= '0';
				        count <= '0';
				        --NS
				        curr <= finish;
				    end if;
				--jr
				when jr =>
				    --rID1 <= dest_j;
				    --result <= regRD1;
				    result <= dest_j;
				    --NS
				    curr <= store;
				
				--recv
				when recv =>		    
				    result <= "00000000" & charRec;
				    --NS
				    if newChar = '0' then
				        curr <= recv;
				    else
				        curr <= store;
				    end if;
				    
				--rpix
				when rpix =>
				    --rID2 <= instruct(21 downto 17);
				    --fbAddr1 <=regrD2(11 downto 0);
				    fbAddr1 <= regrD2(11 downto 0);
				    
				    result <= fbDin1;
				
				    --NS
				    curr <= store;
				    
				
				--wpix
				when wpix =>
				    if count = '0' then
				     
				        fbAddr1 <= regrD2(11 downto 0);
				        --fbAddr1 <= regA(11 downto 0);			  
				        
				        
				        count <= '1';
				        curr <= wpix;
				    else
				        fb_wr_en <= '1';
                        rID1 <= instruct(21 downto 17);
                        fbDout1 <= regrD1;
				        count <= '0';
				    --NS
				        curr <= finish;
				    end if;
				--send
				when send_state =>
				   
				    if count = '0' then
				        
				        rID1 <= dest_r;
				        
				        count <= '1';
				        curr <= send_state;
                    else			    
				    --NS
				     send <= '1';
				        charSend <= regrD1(7 downto 0);
				        --send <= '1';
				        count <= '0';
				        curr <= send_temp;
				 end if;
				 
				 when send_temp =>
				    send <= '0';
				    if ready = '1' then
                                             curr <= finish;
                                             count <= '0';
                                            
                                         else
                                             count <= '0';
                                             curr <= send_temp;
                                         end if;
				       
				
				--equals 
				when equals =>
				    if regRD1 = regRD2 then
				        result <= instruct(16 downto 1); 
				        instruct(26 downto 22) <= "00001"; 
				        curr <= store;
				        --dest_i <= regrD1;
				    else
				        curr <= finish;
				    end if;
				   
				
				--nequal 
				when nequal =>
				    if regRD1 /= regRD2 then				      
                        result <= imm_i;
                        dest_i <= "00001";
                        curr <= store;
				    else
				        curr <= finish;
				    
				    end if;
				
				    --NS
				    
				    
				--ori
				when ori =>		
				   		
				    result <= regB OR imm_i;				
				    --NS 
				    curr <= store;
				--lw
				when lw =>		
				    if count = '0' then
				        sum <= std_logic_vector( unsigned(regrD2) + unsigned(imm_i) );                        
				        count <= '1';
				        curr <= lw;
				        
				    else
				         dAddr <= sum(14 downto 0);
                         
				    --NS
				        curr <= lw2;
				        count <= '0';
				     end if;
				     
				  when lw2 =>
				        
				        result <= dIn;
				        curr <= store;		                  
				    
				--sw 
				when sw =>
				    if count = '0' then
				        sum <= std_logic_vector( unsigned(regrD2) + unsigned(imm_i) ); 
				        dAddr <= sum(14 downto 0);
				     --dOut <= std_logic_vector( unsigned(regB) + unsigned(imm_i) ); 
				        d_wr_en <= '1';
				        rID1 <= dest_i;
				        dout <= regrD1;
				        count <= '1';
				        curr <= sw;
				    else
				        d_wr_en <= '0';
				        count <= '0';
				    --dAddr <= regrD1;
				    --NS
				        curr <= finish;
				    end if;
				
				--jmp
				when jmp =>
				    if count = '0' then
                      rID1 <= "00001";          
                      count <= '1';
                      curr <= jmp;
                      wr_enR1 <= '1';
                      regWD1 <= instruct(26 downto 11);
                   else
                       
                      wr_enR1 <= '0';
                     count <= '0';
				
				    --NS
				      curr <= finish;
			       end if;
				--jal
				when jal =>
				    if count = '0' then
				        rID1 <= "00001"; --pc
				        rID2 <= "00010"; --ra
				        wr_enR1 <= '1';
				        wr_enR2 <= '1';
				    
				   
				        regWD2 <=  pc;
				        regWD1 <= regC;		    
				        count <= '1';
				        curr <= jal;
				    else
				        --wr_enR1 <= '0';
                        --wr_enR2 <= '0';
				        count <= '0';
				    --NS
				        curr <= finish;
				    end  if;
				    
				--clrscr
--				when clrscr =>
--				    fbRST <= '1';
--				    --NS
--				    curr <= finish;
				
				--finish 
				
				when finish =>
--				    fbRST <= '0';
				    d_wr_en <= '0';
				    wr_enR1 <= '0';
				    wr_enR2 <= '0';
				    count <= '0';
				    fb_wr_en <= '0';
					curr <= fetch;
				when others =>
					curr <= fetch;
					
			end case;
			
		end if;
		
	end process p;
	
end Behavioral;