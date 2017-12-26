library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

entity controller is
	
	Port (  clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           init : in  STD_LOGIC;
           done : out  STD_LOGIC; --para saber cuando comienza la ejecución
			  control: out std_logic_vector(6 downto 0); --los controles (de i, de j)
			  status : in std_logic_vector(2 downto 0) -- para guardar los registros y el comparador
	);
end controller;

architecture controllerARCH of controller is
		
	type STATES is (inicioial, inicio, compareFirst, ceroAJota, menorQue, leeBRAM, menorQue2, EscribeBRAM, unoAJota, Ssumai);
	--ESTADOS
	signal reset : std_logic;	
	alias cntri_ld: std_logic is control(0); -- Creo alias para facilitar
	alias cntrj_ld: std_logic is control(1); -- la sintaxis que emplearé abajo
	alias cntri_ce: std_logic is control(2);
	alias cntrj_ce: std_logic is control(3);
	alias debug_mode: std_logic is control(4);
	alias wea: std_logic is control(5);
	alias web: std_logic is control(6);
	alias cmp_i : std_logic is status(0); --Para los dos comparadores
	alias cmp_j : std_logic is status(1);
	alias cmp_mem : std_logic is status(2);
	signal STATE, NEXT_STATE: STATES;
	
	
begin
	
reset <= not rst_n;
	
	SYNC: process (clk, reset)
	
		begin
	
			if clk'event and clk = '1' then
				if reset = '1' then
					STATE <= inicioial;
				else 
					STATE <= NEXT_STATE;
				end if;
		
			end if;
				
	end process SYNC;

	COMB: process (STATE, init, status, cmp_i, cmp_j, cmp_mem) 
		
		begin
		   done <= '0';
			control <= (others => '0');
	
	case STATE is
	
				when inicioial => --Done y debug_mode a 1
					done <= '1'; -- debug mode es uno para introducir
					debug_mode <= '1'; -- en la BRAM 	
					if (init = '1') then --Comienza la ejecución, nos vamos de inicioial			
						NEXT_STATE <= inicio;
					else
						NEXT_STATE <= inicioial; -- Aun no ha comenzado la ejedcución
					end if;
				when inicio =>
					cntri_ld <= '1';
					NEXT_STATE <= compareFirst;
				when compareFirst => --Aqui comparo para el loop mayor con i 
						--PARTE 3
								-- Increment counter
					if (cmp_i = '1') then
						NEXT_STATE <= inicioial;
					else
						NEXT_STATE <= ceroAJota;
				end if;
				when ceroAJota =>
					cntrj_ld <= '1';
					NEXT_STATE <= menorQue;	
				when menorQue =>
					--PARTE 3
								-- Increment counter
					if (cmp_j = '1') then
						NEXT_STATE <= Ssumai;
					else
						NEXT_STATE <= leeBRAM;
					end if;
				when leeBRAM =>						
					NEXT_STATE <= menorQue2;
				when menorQue2 => --Con cmp_mem reviso la comparación
						--PARTE 3
								-- Increment counter
					if (cmp_mem = '1') then
						NEXT_STATE <= EscribeBRAM;
					else
						NEXT_STATE <= unoAJota;
					end if;		
				when EscribeBRAM =>
					--PARTE 3
								-- Increment counter
					wea <= '1';
					web <= '1';
					NEXT_STATE <= unoAJota;
				
				when unoAJota =>	 --Aqui comparo para el loop mayor con j				
					cntrj_ce <= '1'; 
					NEXT_STATE <= menorQue;
				when Ssumai => --Sumo al registro con count enable de control i 		  
					cntri_ce <= '1';
					NEXT_STATE <= compareFirst;
					
			end case;	
		end process;
end controllerARCH;
