library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sort is
end tb_sort;

architecture beh of tb_sort is
    component sort
    port( 
        clk        : in  std_logic;
        rst_n      : in  std_logic;
        init       : in  std_logic;
        done       : out std_logic;
        debug_addr : in  std_logic_vector( 4 downto 0);
        debug_din  : in  std_logic_vector(31 downto 0);
        debug_we   : in  std_logic;
        debug_dout : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clk, rst_n, init, done, debug_we : std_logic;
    signal debug_addr                       : std_logic_vector( 4 downto 0);
    signal debug_din, debug_dout            : std_logic_vector(31 downto 0);
    
    type MEM_TYPE is array (0 to 31) of std_logic_vector(31 downto 0);
    signal unsorted: MEM_TYPE:=(
        X"00000001",
        X"00000010",
        X"807FFFFF",
        X"00400000",
        X"80600000",
        X"00000100",
        X"FFFFFFFF",
        X"91800000",
        X"81800000",
        X"FF800000",
        X"80001000",
        X"80000100",
        X"80000010",
        X"80800001",
        X"80400000",
        X"80000001",
        X"80000000",
        X"00000000",
        X"80010000",
        X"00001000",
        X"7FFFFFFF",
        X"00010000",
        X"00600000",
        X"00700000",
        X"007FFFFF",
        X"80700000",
        X"00800001",
        X"01800001",
        X"11800000",
        X"7F800000",
        X"7F800000",
        X"FF800000"
        );

    signal sorted: MEM_TYPE:=(
        X"FFFFFFFF",
        X"FF800000",
        X"FF800000",
        X"91800000",
        X"81800000",
        X"80800001",
        X"807FFFFF",
        X"80700000",
        X"80600000",
        X"80400000",
        X"80010000",
        X"80001000",
        X"80000100",
        X"80000010",
        X"80000001",
        X"80000000",
        X"00000000",
        X"00000001",
        X"00000010",
        X"00000100",
        X"00001000",
        X"00010000",
        X"00400000",
        X"00600000",
        X"00700000",
        X"007FFFFF",
        X"00800001",
        X"01800001",
        X"11800000",
        X"7F800000",
        X"7F800000",
        X"7FFFFFFF"
        );

    function to_string (inp: std_logic_vector) return string is 
        variable image_str: string (1 to inp'length); 
        alias input_str: std_logic_vector (1 to inp'length) is inp; 
    begin 
        for i in input_str'range loop 
            image_str(i) := character'VALUE(std_ulogic'IMAGE(input_str(i))); 
        end loop; 
        -- report "image_str = " & image_str;
        return image_str; 
    end function;

begin


    -------------------------------------------------------------------------------
    -- Component instantiation
    -------------------------------------------------------------------------------
    UUT : sort
    port map(
        clk        => clk,
        rst_n      => rst_n,
        init       => init,
        done       => done,
        debug_addr => debug_addr,
        debug_din  => debug_din,
        debug_we   => debug_we,
        debug_dout => debug_dout
        );

    -----------------------------------------------------------------------------
    -- Process declaration
    -----------------------------------------------------------------------------
    -- Input clock
    p_clk : process
    begin
        clk <= '0', '1' after 5 ns;
        wait for 10 ns;
    end process p_clk;
  
    -- External reset
    p_rst : process
    begin
        rst_n <= '0';
        wait for 25 ns;
        rst_n <= '1';
        wait;
    end process p_rst;
  
    -- Test
    p_driver : process
        variable v_i, v_j    : natural := 0;
        variable ram_in      : std_logic_vector(31 downto 0);
    begin
        init       <= '0';
        debug_we   <= '0';
        debug_addr <= (others => '0');
        debug_din  <= (others => '0');
        wait for 25 ns;

        -- Write unsorted data into BRAM
        report "~~~~~~~~~~~~~~~ WRITING BRAM ~~~~~~~~~~~~~~~";
        wait until falling_edge(clk);
        debug_we   <= '1';
        write_mem_loop: for v_i in 0 to 31 loop
            debug_addr <= std_logic_vector(to_unsigned(v_i, 5));
            debug_din  <= unsorted(v_i);
            report "Write BRAM["& integer'image(v_i)&"]: " & to_string(unsorted(v_i)) & "b";
            wait until falling_edge(clk);
        end loop;
        debug_we   <= '0';
        report "~~~~~~~~~~~~~~~ WRITING BRAM DONE ~~~~~~~~~~~~~~~";

        -- Check that the BRAM has the unsorted values 
        report "~~~~~~~~~~~~~~~ CHECKING BRAM UNSORTED ~~~~~~~~~~~~~~~";
        check_unsorted_loop: for v_i in 0 to 31 loop
            wait until falling_edge(clk);
            debug_addr <= std_logic_vector(to_unsigned(v_i, 5));
            wait until falling_edge(clk);
            --report "BRAM["& integer'image(v_i)&"]: " & to_string(debug_dout) & "b " & to_string(unsorted(v_i)) & "b";
            assert debug_dout = unsorted(v_i)
                report "Error reading BRAM["& integer'image(v_i)&"] got " & to_string(debug_dout) &
                       "b instead of " & to_string(unsorted(v_i)) & "b"
                severity error;
        end loop;
        report "~~~~~~~~~~~~~~~ CHECKING BRAM UNSORTED DONE ~~~~~~~~~~~~~~~";

        report "~~~~~~~~~~~~~~~ SORTING ... ~~~~~~~~~~~~~~~";
        wait until falling_edge(clk);
        init <= '1';
        wait until falling_edge(clk);
        init <= '0';
        wait until done = '1';
        report "~~~~~~~~~~~~~~~ DONE !!! ~~~~~~~~~~~~~~~";

        -- Check that the BRAM is sorted 
        report "~~~~~~~~~~~~~~~ CHECKING BRAM SORTED ~~~~~~~~~~~~~~~";
        check_sorted_loop: for v_i in 0 to 31 loop
            wait until falling_edge(clk);
            debug_addr <= std_logic_vector(to_unsigned(v_i, 5));
            wait until falling_edge(clk);
            --report "BRAM["& integer'image(v_i)&"]: " & to_string(debug_dout) & "b " & to_string(sorted(v_i)) & "b";
            assert debug_dout = sorted(v_i)
                report "Error reading BRAM["& integer'image(v_i)&"] got " & to_string(debug_dout) &
                       "b instead of " & to_string(sorted(v_i)) & "b"
                severity error;
        end loop;
        report "~~~~~~~~~~~~~~~ CHECKING BRAM SORTED DONE ~~~~~~~~~~~~~~~";

        wait;
    end process p_driver;

end beh;