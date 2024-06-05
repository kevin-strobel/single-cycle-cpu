library ieee;
use ieee.std_logic_1164.all;

use work.utils.BIT_WIDTH;

entity gpio is
    port (
        clk : in std_logic;
        rstn : in std_logic;

        wen : in std_logic;
        waddr : in std_logic_vector(BIT_WIDTH-1 downto 0);
        wdata : in std_logic_vector(7 downto 0);

        leds : out std_logic_vector(7 downto 0);

        isMmioAddr : out std_logic
    );
end gpio;

architecture behav of gpio is
    constant ADDRESS_LED : std_logic_vector(BIT_WIDTH-1 downto 0) := x"0badf00d";

    signal ledState : std_logic_vector(7 downto 0);
begin
    leds <= ledState;
    isMmioAddr <= '1' when waddr = ADDRESS_LED else '0';

    gpioWrite: process(clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                ledState <= (others => '0');
            else
                if wen = '1' then
                    if waddr = ADDRESS_LED then
                        ledState <= wdata;
                    end if;
                end if;
            end if;
        end if;
    end process;
end behav;