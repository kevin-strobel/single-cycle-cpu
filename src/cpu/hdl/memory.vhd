library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.types.mem_t;

entity memory is
    port (
        clk : in std_logic;

        addr : in std_logic_vector(BIT_WIDTH-1 downto 0);

        we : in std_logic;
        din : in std_logic_vector(BIT_WIDTH-1 downto 0);

        dout : out std_logic_vector(BIT_WIDTH-1 downto 0);

        debug_mem : out mem_t
    );
end memory;

architecture behav of memory is
    signal mem : mem_t := (others => (others => ('0')));

    signal alignedAddress : std_logic_vector(BIT_WIDTH-1 downto 0);
begin
    alignedAddress <= "00" & addr(BIT_WIDTH-1 downto 2);
    dout <= mem(to_integer(unsigned(alignedAddress))) when to_integer(unsigned(alignedAddress)) <= MEM_SIZE_BYTES else (others => '0');
    debug_mem <= mem;

    write: process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(alignedAddress))) <= din;
            end if;
        end if;
     end process;
end behav;
