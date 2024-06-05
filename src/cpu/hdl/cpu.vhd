library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.load_store.all;
use work.instruction.all;
use work.utils.all;
use work.types.all;

entity cpu is
    port (
        clk : in std_logic;
        rstn : in std_logic;

        io_leds : out std_logic_vector(7 downto 0);

        j2a_master_axi_arvalid : in std_logic;
        j2a_master_axi_araddr : in std_logic_vector(31 downto 0);
        j2a_master_axi_arready : out std_logic;
        j2a_master_axi_rvalid : out std_logic;
        j2a_master_axi_rdata : out std_logic_vector(31 downto 0);
        j2a_master_axi_rready : in std_logic;
        j2a_master_axi_awvalid : in std_logic;
        j2a_master_axi_awaddr : in std_logic_vector(31 downto 0);
        j2a_master_axi_awready : out std_logic;
        j2a_master_axi_wvalid : in std_logic;
        j2a_master_axi_wdata : in std_logic_vector(31 downto 0);
        j2a_master_axi_wready : out std_logic;
        j2a_master_axi_bvalid : out std_logic;
        j2a_master_axi_bready : in std_logic

        -- TESTBENCH-ONLY (connect below signals, too)
        -- debug_dec_inst_exc : out std_logic;
        -- debug_regfile : out regfile_t;
        -- debug_dmem : out mem_t
    );
end cpu;

architecture behav of cpu is
    signal pc_wen_addr_in : std_logic;
    signal pc_addr_in : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal pc_addr_out : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal imem_addr : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal imem_we : std_logic;
    signal imem_din : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal imem_dout : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal dec_inst : std_logic_vector(INST_WIDTH-1 downto 0);
    signal dec_decoded_inst : decoded_inst_t;
    signal dec_inst_exc : std_logic;

    signal regf_raddr1 : std_logic_vector(BIT_LOG2-1 downto 0);
    signal regf_raddr2 : std_logic_vector(BIT_LOG2-1 downto 0);
    signal regf_wen : std_logic;
    signal regf_waddr : std_logic_vector(BIT_LOG2-1 downto 0);
    signal regf_wdata : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal regf_rdata1 : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal regf_rdata2 : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal alu_operand1 : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal alu_operand2 : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal alu_uop : uop_t;
    signal alu_result : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal alu_branch_comp_true : std_logic;

    signal dmem_addr : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal dmem_we : std_logic;
    signal dmem_din : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal dmem_dout : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal ioLeds_wen : std_logic;
    signal ioLeds_wdata : std_logic_vector(7 downto 0);

    signal j2a_rxActive : std_logic;
    signal j2a_rxAddr : std_logic_vector(31 downto 0);
    signal j2a_rxData : std_logic_vector(31 downto 0);
    signal j2a_rxValid : std_logic;

    signal debug_out_dec_inst_exc : std_logic;
    signal debug_out_regfile : regfile_t;
    signal debug_out_dmem : mem_t;
begin
    pc: entity work.program_counter
    port map (
        clk => clk,
        rstn => rstn,
        wen_addr_in => pc_wen_addr_in,
        addr_in => pc_addr_in,
        addr_out => pc_addr_out
    );

    imem: entity work.memory
    port map (
        clk => clk,
        addr => imem_addr,
        we => imem_we,
        din => imem_din,
        dout => imem_dout,
        debug_mem => open
    );

    decoder: entity work.decoder
    port map (
        inst => dec_inst,
        decoded_inst => dec_decoded_inst,
        inst_exc => dec_inst_exc
    );

    regfile: entity work.regfile
    port map (
        clk => clk,
        rstn => rstn,
        raddr1 => regf_raddr1,
        raddr2 => regf_raddr2,
        wen => regf_wen,
        waddr => regf_waddr,
        wdata => regf_wdata,
        rdata1 => regf_rdata1,
        rdata2 => regf_rdata2,
        debug_regfile => debug_out_regfile
    );

    alu: entity work.alu
    port map (
        operand1 => alu_operand1,
        operand2 => alu_operand2,
        uop => alu_uop,
        result => alu_result,
        branch_comp_true => alu_branch_comp_true
    );

    dmem: entity work.memory
    port map (
        clk => clk,
        addr => dmem_addr,
        we => dmem_we,
        din => dmem_din,
        dout => dmem_dout,
        debug_mem => debug_out_dmem
    );

    ioLeds: entity work.ioLeds
    port map (
        clk => clk,
        rstn => rstn,
        wen => ioLeds_wen,
        wdata => ioLeds_wdata,
        leds => io_leds
    );

    jtagToAxiInterface: entity work.axiDataReceiver
    port map (
        clk => clk,
        rstn => rstn,
        master_axi_arready => j2a_master_axi_arready,
        master_axi_rvalid => j2a_master_axi_rvalid,
        master_axi_rdata => j2a_master_axi_rdata,
        master_axi_awvalid => j2a_master_axi_awvalid,
        master_axi_awaddr => j2a_master_axi_awaddr,
        master_axi_awready => j2a_master_axi_awready,
        master_axi_wvalid => j2a_master_axi_wvalid,
        master_axi_wdata => j2a_master_axi_wdata,
        master_axi_wready => j2a_master_axi_wready,
        master_axi_bvalid => j2a_master_axi_bvalid,
        master_axi_bready => j2a_master_axi_bready,
        rxActive => j2a_rxActive,
        rxAddr => j2a_rxAddr,
        rxData => j2a_rxData,
        rxValid => j2a_rxValid
    );

---------------------------------------------------------------------------

    -- PC / JTAG2AXI <----> IMEM
    imem_addr <= pc_addr_out when j2a_rxActive = '0' else j2a_rxAddr;

    -- IMEM <----> DECODER
    dec_inst <= byte_swap_32(imem_dout); -- little-endian --> big-endian

    -- DECODER <----> REGFILE
    regf_raddr1 <= dec_decoded_inst.rs1;
    regf_raddr2 <= dec_decoded_inst.rs2;
    regf_waddr <= dec_decoded_inst.rd;

    -- DECODER <----> ALU
    alu_uop <= dec_decoded_inst.uop;

    -- DECODER <----> DMEM
    -- entity "memory" takes care of address alignment
    dmem_addr <= std_logic_vector(unsigned(regf_rdata1) + unsigned(sext(dec_decoded_inst.imm(11 downto 0), BIT_WIDTH)));
    dmem_din <= convertRegisterToMemory(dec_decoded_inst.uop, dmem_addr(1 downto 0), regf_rdata2, dmem_dout);

    -- DECODER <----> IO_LEDS
    ioLeds_wdata <= regf_rdata2(7 downto 0); -- no endianness conversion

    -- JTAG2AXI <----> IMEM
    imem_din <= j2a_rxData;
    imem_we <= j2a_rxValid;


    -- DEBUG
    debug_out_dec_inst_exc <= dec_inst_exc;

    -- TESTBENCH-ONLY
    -- debug_dec_inst_exc <= debug_out_dec_inst_exc;
    -- debug_regfile <= debug_out_regfile;
    -- debug_dmem <= debug_out_dmem;

---------------------------------------------------------------------------

    cpu_ctrl: process(alu_result, dec_decoded_inst, pc_addr_out, regf_rdata1, regf_rdata2, alu_branch_comp_true, dmem_dout, dmem_addr)
        constant MMIO_ADDR_LED : std_logic_vector(BIT_WIDTH-1 downto 0) := x"0badf00d";
    begin
        pc_wen_addr_in <= '0';
        pc_addr_in <= (others => '0');
        alu_operand1 <= (others => '0');
        alu_operand2 <= (others => '0');
        regf_wen <= '0';
        regf_wdata <= alu_result;
        dmem_we <= '0';
        ioLeds_wen <= '0';

        case dec_decoded_inst.opcode is
            when LUI =>
                alu_operand2 <= dec_decoded_inst.imm & zeros(12);
                regf_wen <= '1';
            when AUIPC =>
                alu_operand1 <= pc_addr_out;
                alu_operand2 <= dec_decoded_inst.imm & zeros(12);
                regf_wen <= '1';
            when OP_IMM =>
                alu_operand1 <= regf_rdata1;
                alu_operand2 <= sext(dec_decoded_inst.imm(11 downto 0), BIT_WIDTH);
                regf_wen <= '1';
            when OP =>
                alu_operand1 <= regf_rdata1;
                alu_operand2 <= regf_rdata2;
                regf_wen <= '1';
            when JAL =>
                pc_wen_addr_in <= '1';
                pc_addr_in <= std_logic_vector(unsigned(pc_addr_out) + unsigned(sext(dec_decoded_inst.imm & '0', BIT_WIDTH)));
                regf_wen <= '1';
                regf_wdata <= std_logic_vector(unsigned(pc_addr_out) + INST_WIDTH_BYTE);
            when JALR =>
                pc_wen_addr_in <= '1';
                pc_addr_in <= std_logic_vector(unsigned(regf_rdata1) + unsigned(sext(dec_decoded_inst.imm(11 downto 0), BIT_WIDTH-1) & '0'));
                regf_wen <= '1';
                regf_wdata <= std_logic_vector(unsigned(pc_addr_out) + INST_WIDTH_BYTE);
            when BRANCH =>
                alu_operand1 <= regf_rdata1;
                alu_operand2 <= regf_rdata2;

                if alu_branch_comp_true = '1' then
                    pc_wen_addr_in <= '1';
                    pc_addr_in <= std_logic_vector(unsigned(pc_addr_out) + unsigned(sext(dec_decoded_inst.imm(11 downto 0) & '0', BIT_WIDTH)));
                end if;
            when LOAD =>
                regf_wen <= '1';
                regf_wdata <= convertMemoryToRegister(dmem_dout, dec_decoded_inst.uop, dmem_addr(1 downto 0));
            when STORE =>
                if dmem_addr = MMIO_ADDR_LED then
                    -- STORE to IO_LEDS
                    ioLeds_wen <= '1';
                else
                    -- Regular STORE to DMEM
                    dmem_we <= '1';
                end if;
            when MISC_MEM | SYSTEM =>
                -- no operation
            when others =>
                -- no operation
        end case;
    end process;
end behav;
