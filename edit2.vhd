library IEEE;
LIBRARY std;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_bit.ALL;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
 -- Combinational designs
entity comp is

    generic (N:integer:=5);
    port (
        a: in std_logic_vector(N-1 downto 0);
        b: in std_logic_vector(N-1 downto 0);
        mode : in std_logic;
        m: out std_logic_vector(N-1 downto 0);
        r: out std_logic_vector(N-1 downto 0);
        error : out std_logic
        
    );
end comp;

architecture mult_div of comp is
    type partial_products is array(N+1 downto 0) of std_logic_vector(2*N-1 downto 0);
    signal dividend, divisor, quotient, remainders: std_logic_vector(N-1 downto 0);
    signal error_bit: std_logic := '0';
    signal p:  std_logic_vector(2*N-1 downto 0);
begin
   error <= error_bit;
    process(all)
variable sum : std_logic_vector(2*N downto 0):= (others => '0');
variable temp_valu: std_logic_vector(2*N downto 0):= conv_std_logic_vector(2,2*N+1);
variable pp : partial_products:= (others=>(others=>'0'));
variable remainder: std_logic_vector(2*N-1 downto 0):=(others=>'0');
variable temp_quotient: std_logic_vector(N-1 downto 0):=(others=>'0');
variable shifted_divisor: std_logic_vector(2*N-1 downto 0):=(others=>'0');
variable qsign,rsign: std_logic;
    begin
        --error <= '0';
if mode = '0' then
        for i in 0 to N-2 loop

             pp(i)(i+N-2 downto i) := (a(i) and b(N-2 downto 0));
        end loop;
        
        pp(N-1)(2*N-2) := (a(N-1) and b(N-1));
        pp(N)(2*N-3 downto N-1) := not ((b(N-1) and a(N-2 downto 0)));
	pp(N)(N-2 downto 0):=((others => '1'));
	pp(N)(2*N-1 downto 2*N-2) :=(others => '1');
        pp(N+1)(2*N-3 downto N-1) := not ((a(N-1) and b(N-2 downto 0)));
	pp(N+1)(N-2 downto 0):=((others => '1'));
	pp(N+1)(2*N-1 downto 2*N-2) :=(others => '1');
        
        sum:=(others => '0');
        for i in 0 to N+1 loop
            sum := sum + ('0'&pp(i));
        end loop;

        sum := sum +(temp_valu); 
        P <= sum(2*N-1 downto 0);
	m <= P(N-1 downto 0);
        r <= P(2*N-1 downto N);
elsif mode = '1' then
 qsign:=a(N-1)xor b(N-1);
        rsign:=a(N-1);
remainder:=(others=>'0');
shifted_divisor:=(others=>'0');
        remainder(N-1 downto 0) := a;
        shifted_divisor(2*N-1 downto N) := b;
        if a(N-1)='1' then
            remainder(N-1 downto 0) := not(a)+1;
        end if;
        if b(N-1)='1' then
            shifted_divisor(2*N-1 downto N) := not(b)+1;
        end if;

        temp_quotient := (others => '0');
        
        for i in 0 to N loop

            if remainder >= shifted_divisor then

                temp_quotient := temp_quotient(N-2 downto 0) & '1';
                remainder:=remainder-shifted_divisor;
                shifted_divisor := '0'&shifted_divisor(2*N-1 downto 1);

                else
                remainder:=remainder;
                temp_quotient := temp_quotient(N-2 downto 1) & "00";
                shifted_divisor := '0'&shifted_divisor(2*N-1 downto 1);

            end if;
        end loop;
        
        if qsign='1' then
            temp_quotient:=not (temp_quotient)+1;
            else
            temp_quotient:=temp_quotient;
        end if;

        if rsign='1' then
            remainder:=not (remainder)+1;
            else
            remainder:=remainder;
        end if;
remainders<=remainder(N-1 downto 0);
quotient<=temp_quotient;
 m <= quotient;
    r <= remainders;
else
            error_bit <= '1';
        end if;
    end process;
    
end architecture;

