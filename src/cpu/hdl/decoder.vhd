library ieee;
use ieee.std_logic_1164.all;

use work.instruction.all;
use work.utils.all;

-- The decoder decodes 32-bit fixed-size instructions.
-- It does not support HINTs.
entity decoder is
    port (
        inst : in std_logic_vector(INST_WIDTH-1 downto 0);

        decoded_inst : out decoded_inst_t;
        -- '1' if instruction is illegal
        inst_exc : out std_logic
    );
end decoder;

architecture behav of decoder is
    signal funct7 : std_logic_vector(RNG_FUNCT7_U downto RNG_FUNCT7_L);
    signal funct3 : std_logic_vector(RNG_FUNCT3_U downto RNG_FUNCT3_L);
    signal opcode : std_logic_vector(RNG_OPC_U downto RNG_OPC_L);

    signal imm_i : std_logic_vector(31 downto 20);
    signal imm_s : std_logic_vector(11 downto 0);
    signal imm_b : std_logic_vector(11 downto 0);
    signal imm_u : std_logic_vector(31 downto 12);
    signal imm_j : std_logic_vector(31 downto 12);
begin
    funct7 <= inst(RNG_FUNCT7_U downto RNG_FUNCT7_L);
    funct3 <= inst(RNG_FUNCT3_U downto RNG_FUNCT3_L);
    opcode <= inst(RNG_OPC_U downto RNG_OPC_L);

    -- immediates
    imm_i <= inst(31 downto 20); -- I-type
    imm_s <= inst(31 downto 25) & inst(11 downto 7); -- S-type
    imm_b <= inst(31) & inst(7) & inst(30 downto 25) & inst(11 downto 8); -- B-type
    imm_u <= inst(31 downto 12); -- U-type
    imm_j <= inst(31) & inst(19 downto 12) & inst(20) & inst(30 downto 21); -- J-type - imm[20|10:1|11|19:12]

    decode: process(inst, funct7, funct3, opcode, imm_i, imm_s, imm_b, imm_u, imm_j)
    begin
        -- avoid latches - unfortunately, the more convenient array initialization is not supported by simulation :(
        decoded_inst.rs2 <= inst(RNG_RS2_U downto RNG_RS2_L);
        decoded_inst.rs1 <= inst(RNG_RS1_U downto RNG_RS1_L);
        decoded_inst.rd <= inst(RNG_RD_U downto RNG_RD_L);

        decoded_inst.uop <= ALU_ADD; -- overridden below
        decoded_inst.opcode <= OP; -- overridden below
        -- values of immediate overridden below as it depends on the instruction
        decoded_inst.imm <= (others => '0'); -- overridden below

        inst_exc <= '0';

        -- first decision according to opcode
        case opcode is
            -- R-type
            when RV_OP => -- reg <= reg OP reg
                decoded_inst.opcode <= OP; -- overridden for muldiv below

                case funct7 is
                    when "0000000" =>
                        -- the basic stuff
                        case funct3 is
                            when "000" =>
                                decoded_inst.uop <= ALU_ADD;
                            when "001" =>
                                decoded_inst.uop <= ALU_SLL;
                            when "010" =>
                                decoded_inst.uop <= ALU_SLT;
                            when "011" =>
                                decoded_inst.uop <= ALU_SLTU;
                            when "100" =>
                                decoded_inst.uop <= ALU_XOR;
                            when "101" =>
                                decoded_inst.uop <= ALU_SRL;
                            when "110" =>
                                decoded_inst.uop <= ALU_OR;
                            when others => -- "111"
                                decoded_inst.uop <= ALU_AND;
                            end case;
                    when "0100000" =>
                        -- SUB | SRA
                        case funct3 is
                            when "000" =>
                                decoded_inst.uop <= ALU_SUB;
                            when "101" =>
                                decoded_inst.uop <= ALU_SRA;
                            when others =>
                                inst_exc <= '1';
                        end case;
                    when others =>
                        inst_exc <= '1';
                end case;

            -- I-type
            when RV_OP_IMM => -- reg <= reg OP imm
                decoded_inst.opcode <= OP_IMM;

                decoded_inst.imm <= zeros(8) & imm_i;

                case funct3 is
                    when "000" =>
                        decoded_inst.uop <= ALU_ADD;
                    when "010" =>
                        decoded_inst.uop <= ALU_SLT;
                    when "011" =>
                        decoded_inst.uop <= ALU_SLTU;
                    when "100" =>
                        decoded_inst.uop <= ALU_XOR;
                    when "110" =>
                        decoded_inst.uop <= ALU_OR;
                    when "111" =>
                        decoded_inst.uop <= ALU_AND;

                    when "001" =>
                        decoded_inst.uop <= ALU_SLL;
                        decoded_inst.imm <= zeros(14) & inst(RNG_RS2_U + 1 downto RNG_RS2_L); -- value is at position of rs2 plus one bit

                        if not is_all_zero(funct7(31 downto 26)) then -- don't test funct7(0) since it is part of shamt
                            inst_exc <= '1';
                        end if;
                    when others => -- "101"
                        decoded_inst.imm <= zeros(14) & inst(RNG_RS2_U + 1 downto RNG_RS2_L); -- value is at position of rs2 plus one bit

                        case funct7 is
                            when "0000000" | "0000001" => -- funct7(0) is part of shamt
                                decoded_inst.uop <= ALU_SRL;
                            when "0100000" | "0100001" => -- funct7(0) is part of shamt
                                decoded_inst.uop <= ALU_SRA;
                            when others =>
                                inst_exc <= '1';
                        end case;
                end case;

            when RV_LUI =>
                decoded_inst.opcode <= LUI;

                decoded_inst.imm <= imm_u;

            when RV_AUIPC =>
                decoded_inst.opcode <= AUIPC;

                decoded_inst.imm <= imm_u;

            when RV_JAL =>
                decoded_inst.opcode <= JAL;
                decoded_inst.uop <= JMP_JAL;

                decoded_inst.imm <= imm_j;

            when RV_JALR =>
                decoded_inst.opcode <= JALR;
                decoded_inst.uop <= JMP_JALR;

                decoded_inst.imm <= zeros(8) & imm_i;

                if funct3 /= "000" then
                    inst_exc <= '1';
                end if;

            when RV_BRANCH =>
                decoded_inst.opcode <= BRANCH;

                decoded_inst.imm <= zeros(8) & imm_b;

                case funct3 is
                    when "000" =>
                        decoded_inst.uop <= BR_EQ;
                    when "001" =>
                        decoded_inst.uop <= BR_NE;
                    when "100" =>
                        decoded_inst.uop <= BR_LT;
                    when "101" =>
                        decoded_inst.uop <= BR_GE;
                    when "110" =>
                        decoded_inst.uop <= BR_LTU;
                    when "111" =>
                        decoded_inst.uop <= BR_GEU;
                    when others =>
                        inst_exc <= '1';
                end case;

            when RV_LOAD =>
                decoded_inst.opcode <= LOAD;

                decoded_inst.imm <= zeros(8) & imm_i;

                case funct3 is
                    when "000" =>
                        decoded_inst.uop <= MEM_BYTE;
                    when "001" =>
                        decoded_inst.uop <= MEM_HWORD;
                    when "010" =>
                        decoded_inst.uop <= MEM_WORD;
                    -- unsigned
                    when "100" =>
                        decoded_inst.uop <= MEM_BYTE_U;
                    when "101" =>
                        decoded_inst.uop <= MEM_HWORD_U;
                    when others =>
                        inst_exc <= '1';
                end case;

            when RV_STORE =>
                decoded_inst.opcode <= STORE;

                decoded_inst.imm <= zeros(8) & imm_s;

                case funct3 is
                    when "000" =>
                        decoded_inst.uop <= MEM_BYTE;
                    when "001" =>
                        decoded_inst.uop <= MEM_HWORD;
                    when "010" =>
                        decoded_inst.uop <= MEM_WORD;
                    when others =>
                        inst_exc <= '1';
                end case;

            -- fence
            when RV_MISC_MEM =>
                decoded_inst.opcode <= MISC_MEM;
                decoded_inst.uop <= FENCE;

                if not is_all_zero(funct3) then
                    inst_exc <= '1';
                end if;

            when RV_SYSTEM =>
                decoded_inst.opcode <= SYSTEM;

                case funct3 is
                    -- handle environment instructions
                    when "000" =>
                        case inst(31 downto 7) is -- the remaining bits now decide which environment inst to invoke
                            when ENV_ECALL =>
                                decoded_inst.uop <= ECALL;
                            when ENV_EBREAK =>
                                decoded_inst.uop <= EBREAK;
                            when others =>
                                inst_exc <= '1';
                        end case;

                    when others =>
                        inst_exc <= '1';
                end case;

            when others =>
                inst_exc <= '1';
        end case;
    end process;
end behav;
