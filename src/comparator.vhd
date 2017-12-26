library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator is
    Port ( primero : in  STD_LOGIC_VECTOR (31 downto 0);
           segundo : in  STD_LOGIC_VECTOR (31 downto 0);
           MAX : out  STD_LOGIC_VECTOR (31 downto 0));
end comparator;

architecture Behavioral of comparator is

begin
			process(primero,segundo)
			begin
					if (primero(30 downto 0) > segundo(30 downto 0)) then
							if(primero(31) = '0') then
								MAX <= primero;	
							elsif (segundo(31) = '1') then
								MAX <= segundo;
							end if;
					elsif ( primero(30 downto 0) < segundo(30 downto 0))  then
							if(segundo(31) = '0') then
								MAX <= segundo;	
							elsif (primero(31) = '1') then
								MAX <= primero;
							end if;
					else --they are equal from 30 to 0
							if(primero(31) = '0') then
									if(segundo(31) = '1') then
										MAX <= primero;
									else 
										MAX <= segundo;
									end if;
							else
									MAX <= segundo;
							end if;
					end if;
			end process;


end Behavioral;

