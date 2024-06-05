library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity axiDataReceiver is
    port (
        clk : in std_logic;
        rstn : in std_logic;

        master_axi_arready : out std_logic;
        master_axi_rvalid : out std_logic;
        master_axi_rdata : out std_logic_vector(31 downto 0);

        master_axi_awvalid : in std_logic;
        master_axi_awaddr : in std_logic_vector(31 downto 0);
        master_axi_awready : out std_logic;
        master_axi_wvalid : in std_logic;
        master_axi_wdata : in std_logic_vector(31 downto 0);
        master_axi_wready : out std_logic;
        master_axi_bvalid : out std_logic;
        master_axi_bready : in std_logic;

        rxActive : out std_logic;
        rxAddr : out std_logic_vector(31 downto 0);
        rxData : out std_logic_vector(31 downto 0);
        rxValid : out std_logic
    );
end axiDataReceiver;

architecture behav of axiDataReceiver is
begin
    -- do not support reads
    master_axi_arready <= '0';
    master_axi_rvalid <= '0';
    master_axi_rdata <= (others => '0');

    axiWrite: process(clk)
        type axiWriteState_t is (IDLE, ADDR, DATA);

        variable axiWriteState : axiWriteState_t;
        variable address : integer;
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                axiWriteState := IDLE;
                master_axi_awready <= '0';
                master_axi_wready <= '0';
                master_axi_bvalid <= '0';
                rxActive <= '0';
                rxValid <= '0';
            else
                case axiWriteState is
                    when IDLE =>
                        master_axi_awready <= '1';

                        if master_axi_awvalid = '1' then
                            rxActive <= '1';
                            rxAddr <= master_axi_awaddr;
                            master_axi_awready <= '0';
                            master_axi_wready <= '1';
                            axiWriteState := ADDR;
                        end if;

                    when ADDR =>
                        if master_axi_wvalid = '1' then
                            rxData <= master_axi_wdata;
                            rxValid <= '1';

                            master_axi_wready <= '0';
                            master_axi_bvalid <= '1';
                            axiWriteState := DATA;
                        end if;

                    when DATA =>
                        rxValid <= '0';

                        if master_axi_bready = '1' then
                            rxActive <= '0';
                            master_axi_bvalid <= '0';
                            axiWriteState := IDLE;
                        end if;
                end case;
            end if;

        end if;
    end process;
end behav;
