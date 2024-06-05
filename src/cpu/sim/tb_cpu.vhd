library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity tb_cpu is
end tb_cpu;

architecture behav of tb_cpu is
    signal clk : std_logic := '1';
    signal rstn : std_logic := '0';
    
    signal debug_regfile : regfile_t;
    signal debug_dmem : mem_t;
begin
    cpu: entity work.cpu
    generic map (
        TESTBENCH_MODE => true
    )
    port map (
        clk => clk,
        rstn => rstn,

        debug_regfile => debug_regfile,
        debug_dmem => debug_dmem
    );
    
    stimuli_clk: process
    begin
        wait for 5ns;
        clk <= not clk;
    end process;
    
    stimuli_rstn: process
    begin
        wait for 10ns * 4;
        rstn <= '1';

        wait;
    end process;

    test: process
        variable expectations : regfile_t;

        procedure checkRegs is
        begin
            for i in 0 to 31 loop
                if debug_regfile(i) /= expectations(i) then
                    report "Register " & integer'image(i) & " - actual: " &
                        integer'image(to_integer(unsigned(debug_regfile(i)))) & ", expected: " &
                        integer'image(to_integer(unsigned(expectations(i))));
                end if;

                assert debug_regfile(i) = expectations(i) severity failure;
            end loop;
        end checkRegs;

        procedure checkDMem (memLine : integer;
                             expected : std_logic_vector(31 downto 0)) is
        begin
            assert debug_dmem(memLine) = expected severity failure;
        end checkDMem;
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
        checkRegs;

        wait for 50ns; -- 406

        expectations(1)  := x"00000118";
        expectations(25) := x"0000000c";
        expectations(26) := x"00000018";
        checkRegs;

        wait for 130ns; -- 536
        expectations(1)  := x"00000118";
        expectations(2)  := x"00000004";
        expectations(3)  := x"ffffffff";
        expectations(4)  := x"00000004";
        expectations(10) := x"00000002";
        expectations(11) := x"00000000";
        checkRegs;

        wait for 140ns; -- 676

        expectations(20) := x"ffffffb7";
        expectations(21) := x"00000040";
        expectations(22) := x"00000023";
        expectations(24) := x"00000001";
        expectations(25) := x"000000b7";
        expectations(26) := x"00000040";
        expectations(27) := x"00000023";
        expectations(28) := x"00000001";
        expectations(10) := x"00000293";
        expectations(11) := x"ffffff81";
        expectations(12) := x"00000293";
        expectations(13) := x"0000ff81";
        expectations(14) := x"fff00493";
        expectations(15) := x"0014a513";
        checkRegs;

        wait for 130ns; -- 806

        expectations(2)  := x"fedcba98";
        expectations(3)  := x"000000ba";
        expectations(4)  := x"000000ec";
        expectations(5)  := x"000000cb";
        expectations(10) := x"00000008";
        checkRegs;

        checkDMem(2, x"98baeccb");
        checkDMem(3, x"98baba00");
        checkDMem(6, x"98badcfe");

        wait for 70ns; -- 876

        expectations(31)  := x"ffffff98";
        expectations(30)  := x"ffffffba";
        expectations(29)  := x"ffffffec";
        expectations(28)  := x"ffffffcb";
        expectations(27)  := x"ffffba98";
        expectations(26)  := x"000000ba";
        expectations(25)  := x"fedcba98";
        checkRegs;

        report "D O N E";

        wait;
    end process;
end behav;