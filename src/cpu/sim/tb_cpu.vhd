library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.regfile_t;

entity tb_cpu is
end tb_cpu;

architecture behav of tb_cpu is
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    
    signal debug_regfile : regfile_t;
begin
    cpu: entity work.cpu
    port map (
        clk => clk,
        rst => rst,
        debug_regfile => debug_regfile
    );
    
    stimuli_clk: process
    begin
        wait for 5ns;
        clk <= not clk;
    end process;
    
    stimuli_rst: process
    begin
        wait for 10ns * 4;
        rst <= '0';

        wait;
    end process;

    test: process
        variable expectations : regfile_t;
    begin
        wait for 356.9ns;

        expectations := (
            x"00000000", -- x0
            x"01234000", -- x1
            x"00800004", -- x2
            x"00000000", -- x3
            x"0080000c", -- x4
            x"007ffffc", -- x5
            x"00000004", -- x6
            x"00000000", -- x7
            x"00000001", -- x8
            x"ffffffff", -- x9
            x"00000001", -- x10
            x"00000000", -- x11
            x"00000005", -- x12
            x"00000009", -- x13
            x"0000000d", -- x14
            x"00000004", -- x15
            x"00000050", -- x16
            x"0fffffff", -- x17
            x"ffffffff", -- x18
            x"01000010", -- x19
            x"00000003", -- x20
            x"07ffffc0", -- x21
            x"00000000", -- x22
            x"00000001", -- x23
            x"00000000", -- x24
            x"00000000", -- x25
            x"00000000", -- x26
            x"00800009", -- x27
            x"0fffffff", -- x28
            x"ffffffff", -- x29
            x"0080000d", -- x30
            x"00000004"  -- x31
        );

        for i in 0 to 31 loop
            assert debug_regfile(i) = expectations(i) severity failure;
        end loop;

        report "D O N E";

        wait;
    end process;
end behav;