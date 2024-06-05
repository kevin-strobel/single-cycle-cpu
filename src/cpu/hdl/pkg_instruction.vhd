library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

use work.utils.all;

package instruction is
    constant INST_WIDTH : positive := 32;
    constant INST_WIDTH_BYTE : positive := INST_WIDTH / 8;
    -- immediate max length
    -- The immediate is one of imm12, imm20, shamt, shamt_32; the constant represents the maximum immediate
    -- length used for std_logic_vector allocation.
    constant IMM_LEN_MAX : positive := 20;

    -- ranges general
    constant RNG_FUNCT7_U : natural := 31;
    constant RNG_FUNCT7_L : natural := 25;
    constant RNG_RS2_U : natural := 24;
    constant RNG_RS2_L : natural := 20;
    constant RNG_RS1_U : natural := 19;
    constant RNG_RS1_L : natural := 15;
    constant RNG_FUNCT3_U : natural := 14;
    constant RNG_FUNCT3_L : natural := 12;
    constant RNG_RD_U : natural := 11;
    constant RNG_RD_L : natural := 7;
    constant RNG_OPC_U : natural := 6;
    constant RNG_OPC_L : natural := 0;

    -- opcodes
    constant RV_OP : std_logic_vector := "0110011";
    constant RV_OP_IMM : std_logic_vector := "0010011";
    constant RV_LUI : std_logic_vector := "0110111";
    constant RV_AUIPC : std_logic_vector := "0010111";
    constant RV_JAL : std_logic_vector := "1101111";
    constant RV_JALR : std_logic_vector := "1100111";
    constant RV_BRANCH : std_logic_vector := "1100011";
    constant RV_LOAD : std_logic_vector := "0000011";
    constant RV_STORE : std_logic_vector := "0100011";
    constant RV_MISC_MEM : std_logic_vector := "0001111"; -- fence
    constant RV_SYSTEM : std_logic_vector := "1110011";

    -- ENV instruction identification (bits 31 - 7) / everything except opcode
    constant ENV_ECALL : std_logic_vector(31 downto 7) := (others => '0');
    constant ENV_EBREAK : std_logic_vector(31 downto 7) := (20 => '1', others => '0');

    type opcode_t is (
        OP, OP_IMM,
        LUI, AUIPC,
        JAL, JALR,
        BRANCH,
        LOAD, STORE,
        MISC_MEM, SYSTEM
    );

    -- The decoder maps instructions to uops (microoperations)
    type uop_t is (
        -- ADD is also default uop (if not applicable or operation fully determined by opcode)
        ALU_ADD, ALU_SUB,
        ALU_SLT, ALU_SLTU,
        ALU_AND, ALU_OR, ALU_XOR,
        ALU_SLL, ALU_SRL, ALU_SRA,

        -- Jump (dedicated jump uops simplify fu_jump_branch)
        JMP_JAL, JMP_JALR,

        -- Branch
        BR_EQ, BR_NE, BR_LT, BR_GE, BR_LTU, BR_GEU,

        -- Load / store
        MEM_BYTE, MEM_HWORD, MEM_WORD,
        -- Load-only (load as unsigned)
        MEM_BYTE_U, MEM_HWORD_U,

        -- fences
        FENCE, -- currently the only instruction since other fences (f. ex. FENCE.I) are not supported as of now

        -- environment inst
        ECALL, EBREAK
    );

    type decoded_inst_t is record
        -- the opcode defines which of the below fields apply
        opcode : opcode_t;
        -- microinstruction
        uop : uop_t;

        -- registers
        rs1 : std_logic_vector(BIT_LOG2-1 downto 0);
        rs2 : std_logic_vector(BIT_LOG2-1 downto 0);
        rd : std_logic_vector(BIT_LOG2-1 downto 0);

        -- immediate (imm12, imm20, shamt, shamt_32 are merged into imm)
        -- o imm12: 11 downto 0 ; I-/S-/B- type: 12-bit immediate
        -- o imm20: 19 downto 0 ; U-/J- type: 20-bit immediate
        -- o shamt: 5 downto 0
        -- o shamt_32: 4 downto 0
        -- Note: The decoder zero-extends all data to 20 bits.
        -- If the data should be sign-extended or is a subset of the latter operand (f. ex. bits 31 downto 12),
        -- it must be propagated respectively during the following stages.
        imm : std_logic_vector(IMM_LEN_MAX-1 downto 0);
    end record;
end instruction;
