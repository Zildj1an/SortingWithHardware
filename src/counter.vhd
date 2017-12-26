library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
	port (clk:  in std_logic;
			reset : in std_logic;
			counte : in std_logic;
			load : in std_logic;
			initial : in std_logic_vector(4 downto 0);
			output: inout std_logic_vector (4 downto 0));
end counter;

architecture counterARCH of counter is


begin

	process(clk, reset, load, counte)
	begin
	 if reset ='1' then --reseteo
		output <= (others => '0');
	 elsif clk'event and clk = '1' then
		if counte = '1' then
			output <= std_logic_vector(unsigned(output) + 1);
		elsif load = '1' then
			output <= initial;
		else
			output <= output; -- Nada nuevo
		end if;
	 end if; 
	end process;

end counterARCH;