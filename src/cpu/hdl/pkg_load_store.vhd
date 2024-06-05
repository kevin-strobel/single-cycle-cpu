library ieee;
use ieee.std_logic_1164.all;

use work.utils.all;
use work.instruction.all;

package load_store is
    -- LOAD
    function convertMemoryToRegister (memoryData : in std_logic_vector(BIT_WIDTH-1 downto 0);
                                      mode : in uop_t;
                                      addressOffset : in std_logic_vector(1 downto 0)) return std_logic_vector;

    -- STORE
    function convertRegisterToMemory (mode : in uop_t;
                                      addressOffset : in std_logic_vector(1 downto 0);
                                      registerData : in std_logic_vector(BIT_WIDTH-1 downto 0);
                                      memoryData : in std_logic_vector(BIT_WIDTH-1 downto 0)) return std_logic_vector;
end load_store;

package body load_store is
    function convertMemoryToRegister (memoryData : in std_logic_vector(BIT_WIDTH-1 downto 0);
                                      mode : in uop_t;
                                      addressOffset : in std_logic_vector(1 downto 0)) return std_logic_vector is
        variable as_byte : std_logic_vector(7 downto 0);
        variable as_hword : std_logic_vector(15 downto 0);
        variable as_word : std_logic_vector(31 downto 0);
    begin
        case mode is
            when MEM_BYTE | MEM_BYTE_U =>
                -- all constellations are legal
                case addressOffset is
                    when "00" =>
                        as_byte := memoryData(BIT_WIDTH-1 downto 24);
                    when "01" =>
                        as_byte := memoryData(23 downto 16);
                    when "10" =>
                        as_byte := memoryData(15 downto 8);
                    when others => -- "11"
                        as_byte := memoryData(7 downto 0);
                end case;

                if mode = MEM_BYTE_U then
                    return zext(as_byte, BIT_WIDTH);
                else
                    return sext(as_byte, BIT_WIDTH);
                end if;
            when MEM_HWORD | MEM_HWORD_U =>
                -- x0 constellations are legal
                case addressOffset is
                    when "00" =>
                        as_hword := byte_swap_16(memoryData(BIT_WIDTH-1 downto 16));
                    when others => -- "10"
                        as_hword := byte_swap_16(memoryData(15 downto 0));
                end case;

                if mode = MEM_HWORD_U then
                    return zext(as_hword, BIT_WIDTH);
                else
                    return sext(as_hword, BIT_WIDTH);
                end if;
            when MEM_WORD =>
                return byte_swap_32(memoryData);
            when others =>
                -- invalid mode
                return zeros(BIT_WIDTH);
        end case;
    end convertMemoryToRegister;

    function convertRegisterToMemory (mode : in uop_t;
                                      addressOffset : in std_logic_vector(1 downto 0);
                                      registerData : in std_logic_vector(BIT_WIDTH-1 downto 0);
                                      memoryData : in std_logic_vector(BIT_WIDTH-1 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(BIT_WIDTH-1 downto 0);
        -- byte swapping
        constant data_byte : std_logic_vector(7 downto 0) := registerData(7 downto 0);
        constant data_hword : std_logic_vector(15 downto 0) := byte_swap_16(registerData(15 downto 0));
        constant data_word : std_logic_vector(31 downto 0) := byte_swap_32(registerData(31 downto 0));
    begin
        case mode is
            when MEM_BYTE =>
                case addressOffset is
                    when "00" =>
                        result := data_byte & memoryData(23 downto 0);
                    when "01" =>
                        result := memoryData(31 downto 24) & data_byte & memoryData(15 downto 0);
                    when "10" =>
                        result := memoryData(31 downto 16) & data_byte & memoryData(7 downto 0);
                    when others => -- "11"
                        result := memoryData(31 downto 8) & data_byte;
                end case;

            when MEM_HWORD =>
                case addressOffset is
                    when "00" =>
                        result := data_hword & memoryData(15 downto 0);
                    when others => -- "10"
                        result := memoryData(31 downto 16) & data_hword;
                end case;

            when others => -- MEM_WORD
                result := data_word;
        end case;

        return result;
    end convertRegisterToMemory;
end load_store;