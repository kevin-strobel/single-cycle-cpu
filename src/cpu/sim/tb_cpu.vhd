library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity tb_cpu is
end tb_cpu;

architecture behav of tb_cpu is
    signal clk : std_logic := '1';
    signal rstn : std_logic := '0';

    signal j2a_master_axi_awvalid : std_logic;
    signal j2a_master_axi_awaddr : std_logic_vector(31 downto 0);
    signal j2a_master_axi_wvalid : std_logic;
    signal j2a_master_axi_wdata : std_logic_vector(31 downto 0);
    signal j2a_master_axi_bready : std_logic;

    signal debug_regfile : regfile_t;
    signal debug_dmem : mem_t;

    signal programLoaded : boolean := false;
begin
    cpu: entity work.cpu
    port map (
        clk => clk,
        rstn => rstn,
        j2a_master_axi_arvalid => '0',
        j2a_master_axi_araddr => (others => '0'),
        j2a_master_axi_rready => '0',
        j2a_master_axi_awvalid => j2a_master_axi_awvalid,
        j2a_master_axi_awaddr => j2a_master_axi_awaddr,
        j2a_master_axi_wvalid => j2a_master_axi_wvalid,
        j2a_master_axi_wdata => j2a_master_axi_wdata,
        j2a_master_axi_bready => j2a_master_axi_bready,
        debug_regfile => debug_regfile,
        debug_dmem => debug_dmem
    );
    
    stimuli_clk: process
    begin
        wait for 5ns;
        clk <= not clk;
    end process;
    
    load_program: process
        -- cpu_test.S
        constant MEM : mem_t := (x"1301003f", x"ef00c000", x"6f004000", x"6f000000", x"b7402301", x"17018000", x"130101ff", x"13028100", x"930281ff", x"13034000", x"93234300", x"13245300", x"9304f0ff", x"13a51400", x"93b51400", x"13065000", x"9346c600", x"1367c600", x"9377c600", x"13184600", x"93d84400", x"13d94440", x"b3094100", x"330a8340", x"b39a6200", x"332b6100", x"b3ab8400", x"33bc8400", x"b34dc200", x"33de6400", x"b3de6440", x"336fc200", x"b37fc200", x"0f00f00f", x"73000000", x"73001000", x"37802401", x"93010000", x"ef008008", x"73001000", x"6f00c008", x"93000000", x"13010000", x"93010000", x"13020000", x"93020000", x"13030000", x"93030000", x"13040000", x"93040000", x"13050000", x"93050000", x"13060000", x"93060000", x"13070000", x"93070000", x"13080000", x"93080000", x"13090000", x"93090000", x"130a0000", x"930a0000", x"130b0000", x"930b0000", x"130c0000", x"930c0000", x"130d0000", x"930d0000", x"130e0000", x"930e0000", x"130f0000", x"930f0000", x"930cc000", x"130d8001", x"e7800000", x"13050000", x"93050000", x"13014000", x"9301f0ff", x"13024000", x"630e3100", x"631c4100", x"63044100", x"6f000001", x"13051500", x"63183100", x"6f004000", x"93051000", x"6ff0dfff", x"13051500", x"37c1dcfe", x"130181a9", x"9301a00b", x"1302c00e", x"9302b00c", x"13058000", x"23002500", x"a3003500", x"23014500", x"a3015500", x"23122500", x"23133500", x"23282500", x"830f0500", x"030f1500", x"830e2500", x"030e3500", x"831d4500", x"031d6500", x"832c0501", x"6f000000"
                            , others => (others => '0'));
    begin
        wait until rstn = '1';
        wait for 5ns;

        j2a_master_axi_awvalid <= '0';
        j2a_master_axi_awaddr <= (others => '0');
        j2a_master_axi_wvalid <= '0';
        j2a_master_axi_wdata <= (others => '0');
        j2a_master_axi_bready <= '0';

        for i in 0 to MEM'RIGHT loop
            j2a_master_axi_awvalid <= '1';
            j2a_master_axi_awaddr <= std_logic_vector(to_unsigned(i*4, 32));
            wait for 10ns;

            j2a_master_axi_awvalid <= '0';
            j2a_master_axi_wvalid <= '1';
            j2a_master_axi_wdata <= MEM(i);
            wait for 10ns;

            j2a_master_axi_wvalid <= '0';
            j2a_master_axi_bready <= '1';
            wait for 10ns;

            j2a_master_axi_bready <= '0';
            wait for 10ns;
        end loop;

        programLoaded <= true;

        wait;
    end process;

    stimuli_rstn: process
    begin
        wait for 10ns * 4;
        rstn <= '1';

        wait until programLoaded = true;

        rstn <= '0';
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
        wait until programLoaded = true;
        wait for 356.9ns; -- 10641

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

        wait for 80ns; -- 10721

        expectations(1)  := x"0000012c";
        expectations(25) := x"0000000c";
        expectations(26) := x"00000018";
        checkRegs;

        wait for 130ns; -- 10851
        expectations(1)  := x"0000012c";
        expectations(2)  := x"00000004";
        expectations(3)  := x"ffffffff";
        expectations(4)  := x"00000004";
        expectations(10) := x"00000002";
        expectations(11) := x"00000000";
        checkRegs;

        wait for 130ns; -- 10981
        expectations(2)  := x"fedcba98";
        expectations(3)  := x"000000ba";
        expectations(4)  := x"000000ec";
        expectations(5)  := x"000000cb";
        expectations(10) := x"00000008";
        checkRegs;

        checkDMem(2, x"98baeccb");
        checkDMem(3, x"98baba00");
        checkDMem(6, x"98badcfe");

        wait for 70ns; -- 11051
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