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
                    mem <= (x"1301003f", x"ef00c000", x"6f004000", x"6f000000", x"b7402301", x"17018000", x"130101ff", x"13028100", x"930281ff", x"13034000", x"93234300", x"13245300", x"9304f0ff", x"13a51400", x"93b51400", x"13065000", x"9346c600", x"1367c600", x"9377c600", x"13184600", x"93d84400", x"13d94440", x"b3094100", x"330a8340", x"b39a6200", x"332b6100", x"b3ab8400", x"33bc8400", x"b34dc200", x"33de6400", x"b3de6440", x"336fc200", x"b37fc200", x"0f00f00f", x"73000000", x"73001000", x"37802401", x"93010000", x"ef008008", x"73001000", x"6f00c008", x"93000000", x"13010000", x"93010000", x"13020000", x"93020000", x"13030000", x"93030000", x"13040000", x"93040000", x"13050000", x"93050000", x"13060000", x"93060000", x"13070000", x"93070000", x"13080000", x"93080000", x"13090000", x"93090000", x"130a0000", x"930a0000", x"130b0000", x"930b0000", x"130c0000", x"930c0000", x"130d0000", x"930d0000", x"130e0000", x"930e0000", x"130f0000", x"930f0000", x"930cc000", x"130d8001", x"e7800000", x"13050000", x"93050000", x"13014000", x"9301f0ff", x"13024000", x"630e3100", x"631c4100", x"63044100", x"6f000001", x"13051500", x"63183100", x"6f004000", x"93051000", x"6ff0dfff", x"13051500", x"37c1dcfe", x"130181a9", x"9301a00b", x"1302c00e", x"9302b00c", x"13058000", x"23002500", x"a3003500", x"23014500", x"a3015500", x"23122500", x"23133500", x"23282500", x"830f0500", x"030f1500", x"830e2500", x"030e3500", x"831d4500", x"031d6500", x"832c0501", x"6f000000"
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
