library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.types.regfile_t;

entity regfile is
    port (
        clk : in std_logic;
        rst : in std_logic;

        raddr1 : in std_logic_vector(BIT_LOG2-1 downto 0);
        raddr2 : in std_logic_vector(BIT_LOG2-1 downto 0);

        wen : in std_logic;
        waddr : in std_logic_vector(BIT_LOG2-1 downto 0);
        wdata : in std_logic_vector(BIT_WIDTH-1 downto 0);

        rdata1 : out std_logic_vector(BIT_WIDTH-1 downto 0);
        rdata2 : out std_logic_vector(BIT_WIDTH-1 downto 0);

        debug_regfile : out regfile_t
    );
end regfile;

architecture behav of regfile is
    signal regfile : regfile_t;
begin
    rdata1 <= regfile(to_integer(unsigned(raddr1)));
    rdata2 <= regfile(to_integer(unsigned(raddr2)));
    debug_regfile <= regfile;

    write: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regfile <= (others => (others => '0'));
            else
                -- x0: always zero
                if wen = '1' and waddr /= zeros(BIT_LOG2) then
                    regfile(to_integer(unsigned(waddr))) <= wdata;
                end if;
            end if;
        end if;
    end process;
end behav;
