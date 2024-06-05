library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;

entity memory is
    port (
        clk : in std_logic;
        rst : in std_logic;

        addr : in std_logic_vector(BIT_WIDTH-1 downto 0);

        we : in std_logic;
        din : in std_logic_vector(BIT_WIDTH-1 downto 0);

        dout : out std_logic_vector(BIT_WIDTH-1 downto 0)
    );
end memory;

architecture behav of memory is
    type mem_t is array(0 to MEM_SIZE_BYTES) of std_logic_vector(BIT_WIDTH-1 downto 0);
    signal mem : mem_t := (others => (others => ('0')));

    signal alignedAddress : std_logic_vector(BIT_WIDTH-1 downto 0);
begin
    alignedAddress <= "00" & addr(BIT_WIDTH-1 downto 2);
    dout <= mem(to_integer(unsigned(alignedAddress)));

    write: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- TODO
                -- mem <= (others => (others => '0'));
                mem <= (x"B7402301", x"17018000", x"13028100", x"930281FF", x"13034000", x"93234300", x"13245300", x"9304F0FF", x"13A51400", x"93B51400", x"13065000", x"9346C600", x"1367C600", x"9377C600", x"13184600", x"93D84400", x"13D94440", x"B3094100", x"330A8340", x"B39A6200", x"332B6100", x"B3AB8400", x"33BC8400", x"B34DC200", x"33DE6400", x"B3DE6440", x"336FC200", x"B37FC200", x"0F00F00F", x"73000000", x"73001000", x"37802401", x"93000000"
                        , others => (others => '0'));
            else
                if we = '1' then
                    mem(to_integer(unsigned(addr))) <= din;
                end if;
            end if;
        end if;
     end process;
end behav;
