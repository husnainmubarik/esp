-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-------------------------------------------------------------------------------
-- FPGA Proxy for chip testing and DDR access
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
use work.jtag.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.memoryctrl.all;

entity ext2ahbm is
  generic (
    hindex : integer range 0 to NAHBSLV - 1);
  port (
    clk             : in  std_ulogic;
    rstn            : in  std_ulogic;
    -- Memory link
    fpga_data_in    : out std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_data_out   : in  std_logic_vector(ARCH_BITS - 1 downto 0);
    fpga_valid_in   : out std_ulogic;
    fpga_valid_out  : in  std_ulogic;
    fpga_data_ien   : out std_logic;
    fpga_clk_in     : out std_logic;
    fpga_clk_out    : in  std_logic;
    fpga_credit_in  : out std_logic;
    fpga_credit_out : in  std_logic;
    ahbmo           : out ahb_mst_out_type;
    ahbmi           : in  ahb_mst_in_type);

end entity ext2ahbm;

architecture rtl of ext2ahbm is

  -- Synchronized to clk
  signal ext_snd_wrreq    : std_ulogic;
  signal ext_snd_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_full     : std_ulogic;
  signal ext_rcv_rdreq    : std_ulogic;
  signal ext_rcv_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_empty    : std_ulogic;
  -- Synchronized to fpga_clk_in
  signal ext_snd_rdreq    : std_ulogic;
  signal ext_snd_data_out : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_snd_empty    : std_ulogic;
  -- Synchronized to fpga_clk_out
  signal ext_rcv_wrreq    : std_ulogic;
  signal ext_rcv_data_in  : std_logic_vector(ARCH_BITS - 1 downto 0);
  signal ext_rcv_full     : std_ulogic;


begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Drive fpga_clk_in (use clk if FPGA design freq = link freq)
  fpga_clk_in <= clk;

  -- TODO: implement FPGA side of link
  fpga_data_in <= (others => '0');
  fpga_data_ien <= '0';
  fpga_valid_in <= '0';

  fpga_clk_in <= '0';
  fpga_credit_in <= '0';
  ahbmo <= ahbm_none;

end architecture rtl;
