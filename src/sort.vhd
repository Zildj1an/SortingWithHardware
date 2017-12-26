library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sort is
	Port (  clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           init : in  STD_LOGIC; 
           done : out  STD_LOGIC; -- mientras sea 1 no comienza el flujo
           debug_addr : in  STD_LOGIC_VECTOR (4 downto 0); -- Los debug se usan para
           debug_din : in  STD_LOGIC_VECTOR (31 downto 0); -- Introducir los valores al 
           debug_we : in  STD_LOGIC;							  -- principio y 
           debug_dout : out  STD_LOGIC_VECTOR (31 downto 0)); -- revisarlos al final 
end sort;

architecture sortARCH of sort is

	component datapath -- Recibe los control signal de Controller
		port( clk, rst_n: in std_logic;
			debug_dout : out STD_LOGIC_VECTOR (31 downto 0);
			debug_addr : in STD_LOGIC_VECTOR (4 downto 0);
         debug_din : in STD_LOGIC_VECTOR (31 downto 0);
         debug_we : in STD_LOGIC;
			control : in std_logic_vector(6 downto 0); 
			status : out std_logic_vector(2 downto 0)
			  -- PART 3
			  -- in_counter: in STD_LOGIC;
			  -- clear_counter: in STD_LOGIC;
			);
	end component datapath;

	component controller --Genera los control signal siguiendo el ASM
		Port (clk : in  STD_LOGIC;
				rst_n : in  STD_LOGIC;
           	init : in  STD_LOGIC;
           	done : out  STD_LOGIC;
				control: out std_logic_vector(6 downto 0); --para facilitar el paso de señales
				status : in std_logic_vector(2 downto 0) --cmpi_i, cmp_j, cmp_mem se guardan aqui
				 -- PART 3
			   -- in_counter: out STD_LOGIC;
			   -- clear_counter: out STD_LOGIC;
				);
	end component controller;
	
signal control: std_logic_vector(6 downto 0);
signal status: std_logic_vector(2 downto 0); --señales intermedias entre ambos componentes de sort

begin
	
		my_controller : controller --asocio los I/0
					PORT MAP(clk,rst_n,init,done,control,status);
					
		my_datapath : datapath --asocio los I/0
					PORT MAP(clk, rst_n,debug_dout,debug_addr,debug_din,debug_we,control,status
					);

end sortARCH;