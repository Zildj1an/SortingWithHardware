library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port( clk: 		in std_logic;
			rst_n: 		in std_logic;
			debug_dout : out STD_LOGIC_VECTOR (31 downto 0);
			debug_addr : in STD_LOGIC_VECTOR (4 downto 0);
         debug_din : in STD_LOGIC_VECTOR (31 downto 0);
         debug_we : in STD_LOGIC;
			control : in std_logic_vector(6 downto 0);
			status : out std_logic_vector(2 downto 0));
			-- PART 3
			-- in_counter: in STD_LOGIC;
		   -- clear_counter: in STD_LOGIC;
end datapath;


architecture dataARCH of datapath is

	component counter
	port (clk:  in std_logic;
			aux_rst : in std_logic;
			count_enable : in std_logic;
			load : in std_logic;
			initial : in std_logic_vector(4 downto 0);
			output: inout std_logic_vector (4 downto 0));
	end component;
	
-- PARTE 3
 -- component counterClk 
 --	generic (n: integer := 8);
 --	port (clk, reset, count: in std_logic;
 --				output: out std_logic_vector (n-1 downto 0));
 --end component;
	
	component comparator
	port (A : in std_logic_vector(31 downto 0);
			B : in std_logic_vector(31 downto 0);
			MAX : out std_logic_vector(31 downto 0));
	end component;

	component sort_mem
		port (
			clka	: in std_logic;
			wea	: in std_logic_vector(0 downto 0);
			addra	: in std_logic_vector(4 downto 0);
			dina	: in std_logic_vector(31 downto 0);
			douta	: out std_logic_vector(31 downto 0);
			clkb	: in std_logic;
			web	: in std_logic_vector(0 downto 0);
			addrb	: in std_logic_vector(4 downto 0);
			dinb	: in std_logic_vector(31 downto 0);
			doutb	: out std_logic_vector(31 downto 0)
			);
	end component;
	
	--STATUS
	
	alias compari: std_logic is status(0);
	alias comparj: std_logic is status(1);
	alias theMemCmp: std_logic is status(2);
	
	--VECTOR OF CONTROL SIGNALS
	
	alias control_loader: std_logic is control(0);
	alias control_loaderj: std_logic is control(1);
	alias control_ce_i: std_logic is control(2);
	alias control_ce_j: std_logic is control(3);
	alias debug_mode: std_logic is control(4);
	alias firstWea: std_logic is control(5);
	alias firstWeb: std_logic is control(6);		
	
	
	--Señales intermedias
	
	signal contadorDei, contadorDeJ : std_logic_vector(4 downto 0);
	signal aux_rst : std_logic;
	signal aux_address, aux_address_b : std_logic_vector(4 downto 0);
	signal dina_aux, dinb_aux : std_logic_vector(31 downto 0);
	signal DOUTA_as, DOUTB_as : std_logic_vector(31 downto 0);
	signal aux_wea, aux_web : std_logic_vector(0 downto 0);
	signal biggerThan : std_logic_vector(31 downto 0);
	--signal auxcounterClk1, auxcounterClk2: std_logic;

begin
	
	aux_rst <= not rst_n; --Señal intermedia
	my_counter_j: counter
		port map(clk,aux_rst,control_ce_j,control_loaderj,"00000",contadorDeJ
					);
	--PART 3
-- auxcounterClk <= in_counter;
-- auxcounterClk2 <= clear_counter
 -- my_counter: counterClk 
 --	generic (n: integer := 8);
 --	port (clk, auxcounterClk2 , auxcounterClk , output);
 --end counter;
	
	my_counter_i: counter -- Asigno todas
		port map(clk,aux_rst,control_ce_i,control_loader,"00000",contadorDei);
	my_sort_mem: sort_mem
			PORT MAP(clk,aux_wea,aux_address,dina_aux,DOUTA_as,clk,aux_web,aux_address_b,dinb_aux,DOUTB_as);
	
	my_comparator: comparator
			PORT MAP(DOUTA_as,DOUTB_as,biggerThan);
			

	comparj <= '1' when contadorDeJ = "11111" else '0';
		compari <= '1' when contadorDei = "11111" else '0'; 
	
	-- USO ESTO EN VEZ DE MULTIPLEXORES POR SIMPLIFICAR
	aux_address <= debug_addr when debug_mode = '1' else contadorDeJ;
	dina_aux <= debug_din when debug_mode = '1' else DOUTB_as;
	aux_wea <= ""&debug_we when debug_mode = '1' else ""&firstWea;
	debug_dout <= DOUTA_as when debug_mode = '1' else (others => '0');
	
	aux_address_b <= std_logic_vector(unsigned(contadorDeJ) + 1);
	dinb_aux <= DOUTA_as; --direcciones 
	aux_web <= ""&firstWeb;
	
	theMemCmp <= '1' when biggerThan = DOUTA_as else '0';
	
end dataARCH;

-- El componente del contador sería asi: 
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--
--entity counter is
--	generic (n: integer := 8);
--	port (clk, reset, count: in std_logic;
--				output: out std_logic_vector (n-1 downto 0));
--end counter;
--
--architecture ARCH of counter is
--
--signal aux_output: unsigned(n-1 downto 0);
--
--begin
--
--	output <= std_logic_vector(aux_output);
--
--	process(clk, reset)
--	begin
--	 if reset ='1' then
--		aux_output <= (others => '0');
--	 elsif clk'event and clk = '1' then
--		if count = '1' then
--			aux_output <= aux_output + 1;
--		else
--			aux_output <= aux_output;
--		end if;
--	 end if; 
--	end process;
--	
--	
--
--end ARCH;