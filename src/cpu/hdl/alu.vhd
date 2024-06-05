library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.instruction.all;
use work.utils.all;

entity alu is
    port (
        operand1 : in std_logic_vector(BIT_WIDTH-1 downto 0); -- rs1, pc
        operand2 : in std_logic_vector(BIT_WIDTH-1 downto 0); -- rs2, imm
        uop : in uop_t;

        result : out std_logic_vector(BIT_WIDTH-1 downto 0);
        -- '1' if comparison of branching instruction evaluates to true
        -- (i. e. take the branch), otherwise '0'
        branch_comp_true : out std_logic
    );
end alu;

architecture behav of alu is
    signal shamt_5_bits : std_logic_vector(4 downto 0); -- 32 bit instructions
    signal comp_eq : std_logic;
    signal comp_less_signed : std_logic;
    signal comp_less_unsigned : std_logic;
begin
    shamt_5_bits <= operand2(4 downto 0);
    mux_comp_eq: with operand1 = operand2 select
        comp_eq <= '1' when true,
            '0' when others;
    mux_comp_less_signed: with signed(operand1) < signed(operand2) select
        comp_less_signed <= '1' when true,
            '0' when others;
    mux_comp_less_unsigned: with unsigned(operand1) < unsigned(operand2) select
        comp_less_unsigned <= '1' when true,
            '0' when others;

    calc_general_arithmetic: process(operand1, operand2, uop, shamt_5_bits, comp_less_signed, comp_less_unsigned)
        variable tmp_result : std_logic_vector(BIT_WIDTH-1 downto 0); -- the intermediate result of arithmetic operations where applicable
        variable shift_result_32 : std_logic_vector(31 downto 0);
    begin
        result <= (others => '0');

        -- OP | OP_IMM
        -- AUIPC (only perform addition here)
        -- LUI (only perform addition here; operand1 MUST be zeros)
        -- other values are illegal in the ALU and result in undefined behavior
        case uop is
            when ALU_ADD =>
                -- In twos-complement arithmetic, signed and unsigned addition are the same operation
                -- [https://stackoverflow.com/questions/35075976/does-risc-v-mandate-twos-complement-or-ones-complement-signedness-or-is-it-im]
                tmp_result := std_logic_vector(unsigned(operand1) + unsigned(operand2));

                -- ADDI | ADD | AUIPC | LUI
                result <= tmp_result;
            when ALU_SLT =>
                -- SLTI | SLT
                result <= zeros(BIT_WIDTH-1) & comp_less_signed;
            when ALU_SLTU =>
                -- SLTIU | SLTU
                result <= zeros(BIT_WIDTH-1) & comp_less_unsigned;
            when ALU_XOR =>
                -- XORI | XOR
                result <= operand1 xor operand2;
            when ALU_OR =>
                -- ORI | OR
                result <= operand1 or operand2;
            when ALU_AND =>
                -- ANDI | AND
                result <= operand1 and operand2;
            when ALU_SUB =>
                tmp_result := std_logic_vector(unsigned(operand1) - unsigned(operand2));
                -- SUB
                result <= tmp_result;
            -- shift instructions (see https://jdebp.eu/FGA/bit-shifts-in-vhdl.html)
            -- shift operand1 by lower 5 bits of operand2
            when ALU_SLL =>
                -- SLLI | SLL
                result <= std_logic_vector(shift_left(unsigned(operand1), to_integer(unsigned(shamt_5_bits))));
            when ALU_SRL =>
                -- SRLI | SRL
                result <= std_logic_vector(shift_right(unsigned(operand1), to_integer(unsigned(shamt_5_bits))));
            when ALU_SRA =>
                -- SRAI | SRA
                result <= std_logic_vector(shift_right(signed(operand1), to_integer(unsigned(shamt_5_bits))));

            when others =>
                -- branch should never be reached
                -- outgoing signals are zero (default)
        end case;
    end process;

    calc_branch_arithmetic: process(uop, comp_eq, comp_less_signed, comp_less_unsigned)
    begin
        branch_comp_true <= '0';

        case uop is
            when BR_EQ =>
                branch_comp_true <= comp_eq;
            when BR_NE =>
                branch_comp_true <= not comp_eq;
            when BR_LT =>
                branch_comp_true <= comp_less_signed;
            when BR_LTU =>
                branch_comp_true <= comp_less_unsigned;
            when BR_GE =>
                branch_comp_true <= not comp_less_signed;
            when others => -- BR_GEU
                branch_comp_true <= not comp_less_unsigned;
        end case;
    end process;
end behav;
