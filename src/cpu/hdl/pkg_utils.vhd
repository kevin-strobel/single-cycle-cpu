library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

package utils is
	constant BIT_WIDTH : integer := 32;
	constant BIT_LOG2 : integer := integer(ceil(log2(real(BIT_WIDTH))));
	constant BYTE_WIDTH : integer := BIT_WIDTH / 8;
    constant REG_COUNT : integer := 32;

    constant MEM_SIZE_BYTES : integer := 255;

    -- Convert 16-bit data between little-endian and big-endian
    function byte_swap_16 (vec : in std_logic_vector(15 downto 0)) return std_logic_vector;
    -- Convert 32-bit data between little-endian and big-endian
    function byte_swap_32 (vec : in std_logic_vector(31 downto 0)) return std_logic_vector;
	function is_all_zero (vec : std_logic_vector) return boolean;
	function sext (vec : in std_logic_vector;
                   len : in positive) return std_logic_vector;
	function zeros (count : positive) return std_logic_vector;
	function zext (vec : in std_logic_vector;
                   len : in positive) return std_logic_vector;
end utils;

package body utils is
    function byte_swap_16 (vec : in std_logic_vector(15 downto 0)) return std_logic_vector is
    begin
        return vec(7 downto 0) & vec(15 downto 8);
    end byte_swap_16;

    function byte_swap_32 (vec : in std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return vec(7 downto 0) & vec(15 downto 8) & vec(23 downto 16) & vec(31 downto 24);
    end byte_swap_32;

    function is_all_zero (vec : std_logic_vector) return boolean is
        constant zero_vec : std_logic_vector(vec'range) := (others => '0');
    begin
        return vec = zero_vec;
    end is_all_zero;

    function sext (vec : in std_logic_vector;
                   len : in positive) return std_logic_vector is
    begin
        return (len-1 downto vec'length => vec(vec'left)) & vec;
    end sext;

    function zeros (count : positive) return std_logic_vector is
        constant vec : std_logic_vector(count - 1 downto 0) := (others => '0');
    begin
        return vec;
    end zeros;

    function zext (vec : in std_logic_vector;
                   len : in positive) return std_logic_vector is
    begin
        return (len-1 downto vec'length => '0') & vec;
    end zext;
end utils;
