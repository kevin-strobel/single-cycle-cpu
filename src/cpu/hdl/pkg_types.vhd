library ieee;
use ieee.std_logic_1164.all;

use work.utils.all;

package types is
    type regfile_t is array(0 to REG_COUNT-1) of std_logic_vector(BIT_WIDTH-1 downto 0);
    type mem_t is array(0 to MEM_SIZE_BYTES) of std_logic_vector(BIT_WIDTH-1 downto 0);
end types;
