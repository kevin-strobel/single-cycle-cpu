library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.types.mem_t;

entity memory is
    generic (
        instInit : boolean := false
    );
    port (
        clk : in std_logic;
        rstn : in std_logic;

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
            if rstn = '0' then
                if instInit then
                    mem <= (x"1301003f", x"ef00c000", x"6f004000", x"6f000000", x"130101fd", x"23261102", x"23248102", x"13040103", x"9307c4fd", x"9305000c", x"13850700", x"ef00400d", x"232004fe", x"032704fe", x"b7173d00", x"9387f78f", x"63cce700", x"13000000", x"832704fe", x"93871700", x"2320f4fe", x"6ff01ffe", x"9307c4fd", x"93053000", x"13850700", x"ef00c009", x"232204fe", x"032744fe", x"b7173d00", x"9387f78f", x"63cce700", x"13000000", x"832744fe", x"93871700", x"2322f4fe", x"6ff01ffe", x"9307c4fd", x"93050003", x"13850700", x"ef004006", x"232404fe", x"032784fe", x"b7173d00", x"9387f78f", x"63cce700", x"13000000", x"832784fe", x"93871700", x"2324f4fe", x"6ff01ffe", x"9307c4fd", x"9305c000", x"13850700", x"ef00c002", x"232604fe", x"0327c4fe", x"b7173d00", x"9387f78f", x"e3cce7f2", x"13000000", x"8327c4fe", x"93871700", x"2326f4fe", x"6ff01ffe", x"130101fe", x"232e8100", x"13040102", x"2326a4fe", x"93870500", x"a305f4fe", x"b7f7ad0b", x"9387d700", x"0347b4fe", x"23a0e700", x"13000000", x"0324c101", x"13010102", x"67800000"
                            , others => (others => '0'));
                else
                    mem <= (others => (others => '0'));
              end if;
            else
                if we = '1' then
                    mem(to_integer(unsigned(alignedAddress))) <= din;
                end if;
            end if;
        end if;
     end process;
end behav;
