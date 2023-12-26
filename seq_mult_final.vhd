library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Muldiv is
    generic(N : positive := 5);
    port(
        clk : in std_logic;
        rst : in std_logic;
        mode : in std_logic; 
        a : in std_logic_vector(N-1 downto 0);
        b : in std_logic_vector(N-1 downto 0);
        m : out std_logic_vector(N-1 downto 0);
        r : out std_logic_vector(N-1 downto 0);
        error_bit : out std_logic;
        busy_bit : out std_logic;
        valid_bit : out std_logic
    );
end entity Muldiv;

architecture Behavioral of Muldiv is

begin
    process(clk, rst)
    variable Multiplier : std_logic_vector(N-1 downto 0);
    variable Multiplicand : std_logic_vector(2*N-1 downto 0);
    variable P : std_logic_vector(2*N-1 downto 0);
    variable count : integer := 0;
    variable signs : std_logic;
    variable remainder: std_logic_vector(2*N-1 downto 0):=(others=>'0');
    variable temp_quotient: std_logic_vector(N-1 downto 0):=(others=>'0');
    variable shifted_divisor: std_logic_vector(2*N-1 downto 0):=(others=>'0');
    variable qsign,rsign: std_logic;
    begin
        if rst = '0' then
            Multiplicand := (others => '0');
            Multiplier:=(others=>'0');
            P := (others => '0');
	    r <= (others => '0');
            m <= (others => '0');
            count := 0;
            error_bit <= '0';
            busy_bit <= '0';
            valid_bit <= '1';
        elsif rising_edge(clk) then
            if mode = '0' then 
                if count = 0 then
                    P := (others => '0');
                    Multiplier := b;
                    Multiplicand(N-1 downto 0) := a;
                    signs:= a(N-1) xor b(N-1);
                    if a(N-1)='1' then
                        Multiplicand(N-1 downto 0) := not(a)+1;
			        end if;
                    if b(N-1)='1' then
                        Multiplier := not(b)+1;
                    end if;
                    count := 1;
                    busy_bit <= '1';
                    valid_bit <= '0';
                    error_bit<='0';
                elsif count <= N then
                    if Multiplier(0) = '1' then
                        P := Multiplicand + P;
                    end if;
                    Multiplicand := Multiplicand(2*N-2 downto 0) & '0';
                    Multiplier := '0' & Multiplier(N-1 downto 1);
                    count := count + 1;
                elsif count = N+1 then
                    if signs='1' then
                        P:=not(P)+1;
                    end if;
                    m <= P(N-1 downto 0);
                    r <= P(2*N-1 downto N);
                    busy_bit <= '0';
                    valid_bit <= '1';
                    count:=0;
                    Multiplicand := (others => '0');
                    Multiplier:=(others=>'0');
                else
                error_bit<='1';
                busy_bit <= '0';
                valid_bit <= '0';
                count:=0;
                end if;
            else

            if count = 0 then
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
                count:=1;
                busy_bit <= '1';
                valid_bit <= '0';
		if b=0 then 
		error_bit<='1';
		else
		error_bit<='0';
		end if;
            elsif count <= N+1 then

                if remainder >= shifted_divisor then

                    temp_quotient := temp_quotient(N-2 downto 0) & '1';
                    remainder:=remainder-shifted_divisor;
                    shifted_divisor := '0'&shifted_divisor(2*N-1 downto 1);
    
                    else
                    remainder:=remainder;
                    temp_quotient := temp_quotient(N-2 downto 0) & '0';
                    shifted_divisor := '0'&shifted_divisor(2*N-1 downto 1);
    
                end if;
                count := count + 1;
            elsif count = n+2 then
                if qsign='1' then
                    temp_quotient:=not (temp_quotient)+1;
                end if;
        
                if rsign='1' then
                    remainder:=not (remainder)+1;
                end if;
                r<=remainder(N-1 downto 0);
                m<=temp_quotient;
                error_bit<='0';
                busy_bit <= '0';
                valid_bit <= '1';
                count:=0;
            else
            error_bit<='1';
            busy_bit <= '0';
            valid_bit <= '0';
            count:=0;
            end if;

            end if;
        end if;
    end process;
end architecture Behavioral;
