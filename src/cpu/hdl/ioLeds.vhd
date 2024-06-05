library ieee;
use ieee.std_logic_1164.all;

entity ioLeds is
    port (
        clk : in std_logic;
        rstn : in std_logic;

        wen : in std_logic;
        wdata : in std_logic_vector(7 downto 0);

        leds : out std_logic_vector(7 downto 0)
    );
end ioLeds;

architecture behav of ioLeds is
    signal ledState : std_logic_vector(7 downto 0);
begin
    leds <= ledState;

    ledsWrite: process(clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                ledState <= (others => '0');
            else
                if wen = '1' then
                    ledState <= wdata;
                end if;
            end if;
        end if;
    end process;
end behav;