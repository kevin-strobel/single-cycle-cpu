library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.utils.all;

entity program_counter is
    port(
        clk : in std_logic;
        rstn : in std_logic;

        wen_addr_in : in std_logic;
        addr_in : in std_logic_vector(BIT_WIDTH-1 downto 0);

        addr_out : out std_logic_vector(BIT_WIDTH-1 downto 0)
    );
end program_counter;

architecture behav of program_counter is
    signal counter : std_logic_vector(BIT_WIDTH-1 downto 0);
begin
    addr_out <= counter;

    count: process(clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                counter <= (others => '0');
            else
                if wen_addr_in = '1' then
                    counter <= addr_in;
                else
                    counter <= std_logic_vector(unsigned(counter) + BYTE_WIDTH);
                end if;
            end if;
        end if;
    end process;
end behav;
