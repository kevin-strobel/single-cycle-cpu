library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.instruction.all;
use work.utils.all;

entity cpu is
    port (
      clk : in std_logic;
      rst : in std_logic
    );
end cpu;

architecture behav of cpu is
    signal pc_wen_addr_in : std_logic;
    signal pc_addr_in : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal pc_addr_out : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal imem_addr : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal imem_dout : std_logic_vector(BIT_WIDTH-1 downto 0);

    signal dec_inst : std_logic_vector(INST_WIDTH-1 downto 0);
    signal dec_decoded_inst : decoded_inst_t;
    signal dec_inst_exc : std_logic; -- debug-only

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
begin
    pc: entity work.program_counter
    port map (
        clk => clk,
        rst => rst,
        wen_addr_in => pc_wen_addr_in,
        addr_in => pc_addr_in,
        addr_out => pc_addr_out
    );

    imem: entity work.memory
    port map (
        clk => clk,
        rst => rst,
        addr => imem_addr,
        we => '0',
        din => (others => '0'),
        dout => imem_dout
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
        rst => rst,
        raddr1 => regf_raddr1,
        raddr2 => regf_raddr2,
        wen => regf_wen,
        waddr => regf_waddr,
        wdata => regf_wdata,
        rdata1 => regf_rdata1,
        rdata2 => regf_rdata2
    );

    alu: entity work.alu
    port map (
        operand1 => alu_operand1,
        operand2 => alu_operand2,
        uop => alu_uop,
        result => alu_result,
        branch_comp_true => alu_branch_comp_true
    );

---------------------------------------------------------------------------

    -- PC <----> IMEM
    imem_addr <= pc_addr_out;
    -- IMEM <----> DECODER
    dec_inst <= byte_swap_32(imem_dout); -- little-endian --> big-endian

    -- DECODER <----> REGFILE
    regf_raddr1 <= dec_decoded_inst.rs1;
    regf_raddr2 <= dec_decoded_inst.rs2;
    regf_waddr <= dec_decoded_inst.rd;

    -- DECODER <----> ALU
    alu_uop <= dec_decoded_inst.uop;

---------------------------------------------------------------------------

    -- TODO sensitivity list
    cpu_ctrl: process(alu_result, dec_decoded_inst, pc_addr_out, regf_rdata1, regf_rdata2)
    begin
        pc_wen_addr_in <= '0';
        pc_addr_in <= (others => '0');
        alu_operand1 <= (others => '0');
        alu_operand2 <= (others => '0');
        regf_wen <= '0';
        regf_wdata <= alu_result;

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
            when MISC_MEM | SYSTEM =>
                -- no operation
            when others =>
                -- no operation
            -- TODO: JAL, JALR, BRANCH, LOAD, STORE
        end case;
    end process;
end behav;