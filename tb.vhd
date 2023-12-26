-------------------------------------------------------------------------------------------------------------------
-- Date: 		10/08/2023
-- Description:  TB for multiplier and divider with the following criteria
--  
-- 
-- 
-- 
-- 
------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use ieee.math_real.all;


entity test_bench is 
end entity;


architecture test01 of test_bench is 
   ---------------------------------------------------------------
   -- create instances of the designs
   ---------------------------------------------------------------
   component inst_comb    	-- Combinational design component
	generic (N: integer := 5);
	 port (
       		 a			: in std_logic_vector(N-1 downto 0);
        	 b			: in std_logic_vector(N-1 downto 0);
      		 m			: out std_logic_vector(N-1 downto 0);	
		 r			: out std_logic_vector(N-1 downto 0);   
		error 			: out std_logic;
		mode			: in std_logic );
   end component;
   component inst_seq     	-- Sequential design component
	generic (N: integer := 5);
	 port (
       		 a				: in std_logic_vector(N-1 downto 0);
        	 b				: in std_logic_vector(N-1 downto 0);
      		 m				: out std_logic_vector(N-1 downto 0);	
		 r				: out std_logic_vector(N-1 downto 0);   
		busy_bit, valid_bit,error_bit 	: out std_logic;
		clk,rst,mode			: in std_logic );
   end component;
   ----------------------------------------------------------------
   -------- TB's signals to connect to the DUT....
   ----------------------------------------------------------------
   constant   N       				:  integer := 5;
   signal     a					:  std_logic_vector(N-1 downto 0);
   signal     b					:  std_logic_vector(N-1 downto 0);
   signal     m_seq				:  std_logic_vector(N-1 downto 0); -- m contains MSB of the product value / the quotient for sequential design	
   signal     r_seq				:  std_logic_vector(N-1 downto 0); -- r contains LSB of the product value / the reminder for sequential design 
   signal     m_com				:  std_logic_vector(N-1 downto 0); -- m contains MSB of the product value / the quotient for combinational design	
   signal     r_com				:  std_logic_vector(N-1 downto 0); -- r contains LSB of the product value / the reminder for combinational design 
   signal  busy, valid, clk, error_seq, error_com,mode, reset 	:  std_logic := '0';    
   signal count_error,count_tests,count_passed		:integer := 0 ;   -- accumulators to catch up errors 
  

   -------------------------------------------------------------------------
   -- check_output procedure acts like a score-board it gets the two
   -- inputs signals and calculates the results using built-in 
   -- operators (*,/) and checks if it is matching the results from our design
   -- if not a text file with the error messages will be created 
   -------------------------------------------------------------------------
 procedure check_output (signal a     : in std_logic_vector(N-1 downto 0);     signal b : in std_logic_vector(N-1 downto 0); 
		         signal  error_seq,error_com , valid: in std_logic;    signal m_seq  : in std_logic_vector(N-1 downto 0);
			 signal m_com  : in std_logic_vector(N-1 downto 0);    signal r_com     : in std_logic_vector(N-1 downto 0);
                         signal r_seq     : in std_logic_vector(N-1 downto 0); signal mode: in std_logic;
			 signal count_error   : out integer) is 

 --  variables to write into file and hold the expected results  
 variable expected_q, expected_r      : std_logic_vector (N-1 downto 0);
 variable expected_p,temp             : std_logic_vector (2*N-1 downto 0);
 variable vector_l                    : line ;
 file     result_f                    : text open write_mode is "errors_log.txt";
		    
 begin
 expected_p := std_logic_vector (signed(a)* signed(b));               -- golden outputs 
 expected_q := std_logic_vector (signed (a) / signed(b));
 temp       := std_logic_vector (signed (expected_q) * signed(b));
 expected_r := std_logic_vector (signed (a) - signed (temp (N-1 downto 0)));

case (mode) is 
when '0' =>
--wait until valid = '1' and valid'event ;
if (expected_p /= r_seq&m_seq or expected_p /= r_com&m_com ) then
	report "Error! UNEXPECTED MULTIPLICATION....." severity note;
	write (vector_l,string'("Multiplier EEROR! "));
        write (vector_l,now);
	write (vector_l,string'("  The multiplicand: "));
	write (vector_l,to_integer (signed (a)));
	write (vector_l,string'("  The multiplier: "));
	write (vector_l,to_integer (signed (b)));
	write (vector_l,string'("  The expected output: "));
	write (vector_l,to_integer (signed(expected_p)));
	write (vector_l,string'("  The actual sequential output: "));
	write (vector_l,to_integer (signed (m_seq&r_seq)));
	write (vector_l,string'("  The actual combinational output: "));
	write (vector_l,to_integer (signed (m_com&r_com)));
	count_error <= count_error +1;
end if;

 -- check for division 
when '1' =>
--wait until valid = '1' and valid'event ;
 if ( b = std_logic_vector (to_unsigned (0,N))  and (error_seq /= '1' or error_com /= '1' )) then    -- check if the error flag is rised when the dividend is zero
	write (vector_l,string'("  Divide by zero has not detected =>  "));
 end if ;
 if ( expected_q /= m_seq or expected_r /=  r_seq or expected_q /= m_com or expected_r /=  r_com) then
	report "Error! UNEXPECTED DIVISION....." severity note;
	write (vector_l,string'("  DIVIDER EEROR! "));
        write (vector_l,now);
	write (vector_l,string'("  The divisor: "));
	write (vector_l,to_integer (signed (a)));
	write (vector_l,string'("  The dividend: "));
	write (vector_l,to_integer (signed (b)));
	write (vector_l,string'("  The expected quotient: "));
	write (vector_l,to_integer (signed (expected_q)));
	write (vector_l,string'("  The actual sequential quotient: "));
	write (vector_l,to_integer (signed (m_seq)));
	write (vector_l,string'("  The actual combinational quotient: "));
	write (vector_l,to_integer (signed (m_com)));
	write (vector_l,string'("  The expected reminder: "));
	write (vector_l,to_integer (signed (expected_r)));
	write (vector_l,string'("  The actual sequential reminder: "));
	write (vector_l,to_integer (signed (r_seq)));
	write (vector_l,string'("  The actual combinational reminder: "));
	write (vector_l,to_integer (signed (r_com)));
	count_error <= count_error +1;
end if;
when others => null;
end case;

	writeline (result_f,vector_l);
end procedure;
   ------------------------------------------------------------------------------
   -- compare procedure gets the two outputs signals and compare them  
   -- if there are not equal a text file with the error messages will be created 
   -------------------------------------------------------------------------------
 procedure compare (   signal  error_com, error_seq, valid: in std_logic;      signal m_seq  : in std_logic_vector(N-1 downto 0);
			 signal m_com  : in std_logic_vector(N-1 downto 0);    signal r_com  : in std_logic_vector(N-1 downto 0);
                         signal r_seq  : in std_logic_vector(N-1 downto 0);    signal mode   : in std_logic) is 

 --  variables to write into file and hold the expected results 
 variable vector2_l                    : line ;
 file     result2_f                    : text open write_mode is "compare_log.txt";
		    
 begin
case (mode) is
when '0' =>
--wait until valid = '1' and valid'event ;
if (r_seq&m_seq /= r_com&m_com ) then
	report "Error! The multiplication outputs not equal....." severity note;
	write (vector2_l,string'("NOT EQUAL OUTPUT EEROR! "));
        write (vector2_l,now);
	write (vector2_l,string'("  The sequential multiplier output: "));
	write (vector2_l,to_integer (signed (m_seq&r_seq)));
	write (vector2_l,string'("  The combinational multiplier output: "));
	write (vector2_l,to_integer (signed (m_com&r_com)));
	
end if;

 -- check for division 
when '1' =>
--wait until valid = '1' and valid'event ;
 if ( m_seq /= m_com or r_seq /= r_seq ) then
	report "Error! The division outputs not equal....." severity note;
	write (vector2_l,string'(" NOT EQUAL OUTPUT EEROR!  "));
        write (vector2_l,now);
	write (vector2_l,string'("  The sequential divider output:  "));
	write (vector2_l,to_integer (signed (m_seq&r_seq)));
	write (vector2_l,string'("  The combinational divider output: "));
	write (vector2_l,to_integer (signed (m_com&r_com)));
end if;
if (  error_com /= error_seq) then    -- check if the error flag is rised when the dividend is zero
	write (vector2_l, now);
	write (vector2_l,string'("   Divide by zero signals are not equal:   "));
	write (vector2_l, error_com);
	write (vector2_l, error_seq);
end if ;
when others => null ;
end case;
	writeline (result2_f,vector2_l);
end procedure;
--
--
--
procedure random (signal a,b : inout std_logic_vector(N-1 downto 0); variable r : inout real; variable seed1,seed2 : inout integer; signal mode : inout std_logic)is          --- defined procedure to convert the output of uniform function								
	begin
	 for i in a'range loop
          uniform(seed1, seed2, r);
          a(i) <= '1' when r > 0.3 else '0';
         end loop;
	 mode <= '1' when r > 0.3 else '0';
	 for i in b'range loop
          uniform(seed1, seed2, r);
          b(i) <= '1' when r > 0.5 else '0';
	 end loop;
end procedure;
 
begin 
comb: inst_comb generic map (N)
	                   port map (a=>a, b=>b,mode=>mode, m=>m_com, r=>r_com,  error=>error_com);
seq: inst_seq generic map (N)
	                   port map (a=>a, b=>b, m=>m_seq, r=>r_seq, clk=>clk,
                            busy_bit =>busy, valid_bit=>valid, error_bit=>error_seq,rst=>reset,mode=>mode);   		
clk_proc: process is      -- virtual clock
	begin  		
	clk <= '0', '1' after 10 ns;
	wait for 20 ns;
	end process;

file_proc: process is    -- 
		 variable r : real;					                -- from real to std_logic_vector 
                 variable seed1, seed2 : integer := 999; 
		--  variables for read and write from file 
		variable a_file, b_file 	 : std_logic_vector (N-1 downto 0);
		variable mode_file	         : std_logic;
		variable vector_l 		 : line ;
		variable pause  		 : time;
		file vector_f   		 : text open read_mode is "vector_f.txt";
                file result_f                    : text open write_mode is "errors_log.txt";
		variable vector2_l               : line ;
		file     result2_f               : text open write_mode is "compare_log.txt";
		    
	    begin 
              report "Starting testing...." severity note;
	      while not endfile (vector_f)loop
		wait until valid = '1' and valid'event ;
                
		readline (vector_f, vector_l);
		read (vector_l, pause);
		read (vector_l, a_file);
		read (vector_l, b_file);
		read (vector_l, mode_file);
		 a <= a_file; b <= b_file; mode <=mode_file; count_tests <= count_tests +1; count_passed <= count_tests - count_error; reset <= '1' ; --wait for pause;
		compare(error_com, error_seq,valid,m_seq,m_com,r_seq,r_com,mode);
		check_output(a,b,error_seq, error_com,valid,m_seq,m_com,r_seq,r_com,mode,count_error);
		    
 		end loop; 
		for i in 0 to 10 loop -- run simulation for random inputs
		wait until valid = '1' and valid'event ;
		random (a,b,r,seed1,seed2,mode); count_tests <= count_tests +1; count_passed <= count_tests - count_error; --wait for 10 ns;
		compare(error_com, error_seq,valid,m_seq,m_com,r_seq,r_com,mode);
		check_output(a,b,error_seq, error_com,valid,m_seq,m_com,r_seq,r_com,mode,count_error);
		
		end loop;
		-- Reporting the ratio of the passed testcases over total testcases
		report " End of testcases!  " severity note ;
		write (vector_l,string'(" The passed testcases: "));
	        write (vector_l,  count_passed);
		write (vector_l,string'(" from total testcases: "));
	        write (vector_l, count_tests);
                writeline (result_f,vector_l);
		writeline (result2_f,vector2_l);
	wait;end process;

end architecture ;

--********************************************************************************************************
--				        -- CONFIGURATION  --
--********************************************************************************************************

configuration device_confg of test_bench is 
  	--  configuration of the designs for both combinational and sequential  --
for test01           
  for comb: inst_comb 
     use entity work.comp(mult_div);
  end for;
  
  for seq: inst_seq 
     use entity work.muldiv(behavioral);
  end for;
 
end for;

end configuration;