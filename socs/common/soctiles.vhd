-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.leon3.all;
use work.gencomp.all;
use work.sldcommon.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

package soctiles is

  component esp is
    generic (
      SIMULATION : boolean := false);
    port (
      rst                : in  std_logic;
      sys_clk            : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      refclk             : in  std_logic;
      pllbypass          : in  std_logic_vector(CFG_TILES_NUM - 1 downto 0);
      uart_rxd           : in  std_logic;
      uart_txd           : out std_logic;
      uart_ctsn          : in  std_logic;
      uart_rtsn          : out std_logic;
      cpuerr             : out   std_logic;
      ddr_ahbsi          : out ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);
      ddr_ahbso          : in  ahb_slv_out_vector_type(0 to CFG_NMEM_TILE - 1);
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      mon_noc            : out monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
      mon_acc            : out monitor_acc_vector(0 to relu(accelerators_num-1));
      mon_mem            : out monitor_mem_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE - 1);
      mon_l2             : out monitor_cache_vector(0 to relu(CFG_NL2 - 1));
      mon_llc            : out monitor_cache_vector(0 to relu(CFG_NLLC - 1));
      mon_dvfs           : out monitor_dvfs_vector(0 to CFG_TILES_NUM-1));
  end component esp;

  component tile_cpu is
    generic (
      SIMULATION         : boolean              := false;
      this_has_dvfs      : integer range 0 to 1 := 0;
      this_has_pll       : integer range 0 to 1 := 0;
      this_has_dco       : integer range 0 to 1 := 0;
      this_extra_clk_buf : integer range 0 to 1 := 0;
      test_if_en         : integer range 0 to 1 := 0;
      ROUTER_PORTS       : ports_vec            := "11111";
      HAS_SYNC           : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      srst               : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      cpuerr             : out std_ulogic;
      -- TODO: remove this; should use proxy
      irq                : in  std_logic_vector(1 downto 0);
      timer_irq          : in  std_ulogic;
      ipi                : in  std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- NOC
      sys_clk_int        : in  std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in  std_logic_vector(3 downto 0);
      noc1_stop_in       : in  std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in  std_logic_vector(3 downto 0);
      noc2_stop_in       : in  std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in  std_logic_vector(3 downto 0);
      noc3_stop_in       : in  std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in  std_logic_vector(3 downto 0);
      noc4_stop_in       : in  std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in  std_logic_vector(3 downto 0);
      noc5_stop_in       : in  std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in  std_logic_vector(3 downto 0);
      noc6_stop_in       : in  std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs_in        : in  monitor_dvfs_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_cpu;

  component tile_acc is
    generic (
      this_hls_conf      : hlscfg_t             := 0;
      this_device        : devid_t              := 0;
      this_irq_type      : integer              := 0;
      this_has_l2        : integer range 0 to 1 := 0;
      this_has_dvfs      : integer range 0 to 1 := 0;
      this_has_pll       : integer range 0 to 1 := 0;
      this_has_dco       : integer range 0 to 1 := 0;
      this_extra_clk_buf : integer range 0 to 1 := 0;
      test_if_en         : integer range 0 to 1 := 0;
      ROUTER_PORTS       : ports_vec            := "11111";
      HAS_SYNC           : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- NOC
      sys_clk_int        : in  std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in std_logic_vector(3 downto 0);
      noc1_stop_in       : in std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in std_logic_vector(3 downto 0);
      noc2_stop_in       : in std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in std_logic_vector(3 downto 0);
      noc3_stop_in       : in std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in std_logic_vector(3 downto 0);
      noc4_stop_in       : in std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in std_logic_vector(3 downto 0); 
      noc5_stop_in       : in std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in std_logic_vector(3 downto 0);
      noc6_stop_in       : in std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_dvfs_in        : in  monitor_dvfs_type;
      --Monitor signals
      mon_acc            : out monitor_acc_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type
      );
  end component tile_acc;

  component tile_io is
    generic (
      SIMULATION   : boolean              := false;
      this_has_dco : integer range 0 to 1 := 0;
      test_if_en   : integer range 0 to 1 := 0;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      srst               : out std_ulogic;
      clk                : in  std_ulogic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      dco_clk            : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- I/O bus interfaces
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      -- TODO: remove this; IRQ will flow through the NoC
      irq                : out std_logic_vector(CFG_NCPU_TILE * 2 - 1 downto 0);
      timer_irq          : out std_logic_vector(CFG_NCPU_TILE - 1 downto 0);
      ipi                : out std_logic_vector(CFG_NCPU_TILE - 1 downto 0);
      -- NOC
      sys_clk_int        : in  std_logic;
      sys_clk_out        : out std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in std_logic_vector(3 downto 0);
      noc1_stop_in       : in std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in std_logic_vector(3 downto 0);
      noc2_stop_in       : in std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in std_logic_vector(3 downto 0);
      noc3_stop_in       : in std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in std_logic_vector(3 downto 0);
      noc4_stop_in       : in std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in std_logic_vector(3 downto 0); 
      noc5_stop_in       : in std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in std_logic_vector(3 downto 0);
      noc6_stop_in       : in std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_io;

  component tile_mem is
    generic (
      this_has_dco : integer range 0 to 1 := 0;
      test_if_en   : integer range 0 to 1 := 0;
      this_has_ddr : integer range 0 to 1 := 1;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      srst               : in  std_ulogic;
      clk                : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      fpga_data_in       : in  std_logic_vector(ARCH_BITS downto 0);
      fpga_data_out      : out std_logic_vector(ARCH_BITS downto 0);
      fpga_oen           : out std_ulogic;
      fpga_clk_in        : in  std_ulogic;
      fpga_clk_out       : out std_ulogic;
      fpga_credit_in     : in  std_ulogic;
      fpga_credit_out    : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- NOC
      sys_clk_int        : in  std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in std_logic_vector(3 downto 0);
      noc1_stop_in       : in std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in std_logic_vector(3 downto 0);
      noc2_stop_in       : in std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in std_logic_vector(3 downto 0);
      noc3_stop_in       : in std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in std_logic_vector(3 downto 0);
      noc4_stop_in       : in std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in std_logic_vector(3 downto 0); 
      noc5_stop_in       : in std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in std_logic_vector(3 downto 0);
      noc6_stop_in       : in std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_mem            : out monitor_mem_type;
      mon_cache          : out monitor_cache_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_mem;

  component tile_empty is
    generic (
      SIMULATION   : boolean              := false;
      this_has_dco : integer range 0 to 1 := 0;
      test_if_en   : integer range 0 to 1 := 0;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_logic;
      refclk             : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- NoC
      sys_clk_int        : in  std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in std_logic_vector(3 downto 0);
      noc1_stop_in       : in std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in std_logic_vector(3 downto 0);
      noc2_stop_in       : in std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in std_logic_vector(3 downto 0);
      noc3_stop_in       : in std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in std_logic_vector(3 downto 0);
      noc4_stop_in       : in std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in std_logic_vector(3 downto 0); 
      noc5_stop_in       : in std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in std_logic_vector(3 downto 0);
      noc6_stop_in       : in std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_dvfs_out       : out monitor_dvfs_type);
  end component tile_empty;

  component tile_slm is
    generic (
      this_has_dco : integer range 0 to 1 := 0;
      test_if_en   : integer range 0 to 1 := 0;
      ROUTER_PORTS : ports_vec            := "11111";
      HAS_SYNC     : integer range 0 to 1 := 1);
    port (
      rst                : in  std_ulogic;
      clk                : in  std_ulogic;
      pllbypass          : in  std_ulogic;
      pllclk             : out std_ulogic;
      -- Test interface
      tdi                : in  std_logic;
      tdo                : out std_logic;
      tms                : in  std_logic;
      tclk               : in  std_logic;
      -- NoC
      sys_clk_int        : in  std_logic;
      noc1_data_n_in     : in  noc_flit_type;
      noc1_data_s_in     : in  noc_flit_type;
      noc1_data_w_in     : in  noc_flit_type;
      noc1_data_e_in     : in  noc_flit_type;
      noc1_data_void_in  : in std_logic_vector(3 downto 0);
      noc1_stop_in       : in std_logic_vector(3 downto 0);
      noc1_data_n_out    : out noc_flit_type;
      noc1_data_s_out    : out noc_flit_type;
      noc1_data_w_out    : out noc_flit_type;
      noc1_data_e_out    : out noc_flit_type;
      noc1_data_void_out : out std_logic_vector(3 downto 0);
      noc1_stop_out      : out std_logic_vector(3 downto 0);
      noc2_data_n_in     : in  noc_flit_type;
      noc2_data_s_in     : in  noc_flit_type;
      noc2_data_w_in     : in  noc_flit_type;
      noc2_data_e_in     : in  noc_flit_type;
      noc2_data_void_in  : in std_logic_vector(3 downto 0);
      noc2_stop_in       : in std_logic_vector(3 downto 0);
      noc2_data_n_out    : out noc_flit_type;
      noc2_data_s_out    : out noc_flit_type;
      noc2_data_w_out    : out noc_flit_type;
      noc2_data_e_out    : out noc_flit_type;
      noc2_data_void_out : out std_logic_vector(3 downto 0);
      noc2_stop_out      : out std_logic_vector(3 downto 0);
      noc3_data_n_in     : in  noc_flit_type;
      noc3_data_s_in     : in  noc_flit_type;
      noc3_data_w_in     : in  noc_flit_type;
      noc3_data_e_in     : in  noc_flit_type;
      noc3_data_void_in  : in std_logic_vector(3 downto 0);
      noc3_stop_in       : in std_logic_vector(3 downto 0);
      noc3_data_n_out    : out noc_flit_type;
      noc3_data_s_out    : out noc_flit_type;
      noc3_data_w_out    : out noc_flit_type;
      noc3_data_e_out    : out noc_flit_type;
      noc3_data_void_out : out std_logic_vector(3 downto 0);
      noc3_stop_out      : out std_logic_vector(3 downto 0);
      noc4_data_n_in     : in  noc_flit_type;
      noc4_data_s_in     : in  noc_flit_type;
      noc4_data_w_in     : in  noc_flit_type;
      noc4_data_e_in     : in  noc_flit_type;
      noc4_data_void_in  : in std_logic_vector(3 downto 0);
      noc4_stop_in       : in std_logic_vector(3 downto 0);
      noc4_data_n_out    : out noc_flit_type;
      noc4_data_s_out    : out noc_flit_type;
      noc4_data_w_out    : out noc_flit_type;
      noc4_data_e_out    : out noc_flit_type;
      noc4_data_void_out : out std_logic_vector(3 downto 0);
      noc4_stop_out      : out std_logic_vector(3 downto 0);
      noc5_data_n_in     : in  misc_noc_flit_type;
      noc5_data_s_in     : in  misc_noc_flit_type;
      noc5_data_w_in     : in  misc_noc_flit_type;
      noc5_data_e_in     : in  misc_noc_flit_type;
      noc5_data_void_in  : in std_logic_vector(3 downto 0);
      noc5_stop_in       : in std_logic_vector(3 downto 0);
      noc5_data_n_out    : out misc_noc_flit_type;
      noc5_data_s_out    : out misc_noc_flit_type;
      noc5_data_w_out    : out misc_noc_flit_type;
      noc5_data_e_out    : out misc_noc_flit_type;
      noc5_data_void_out : out std_logic_vector(3 downto 0);
      noc5_stop_out      : out std_logic_vector(3 downto 0);
      noc6_data_n_in     : in  noc_flit_type;
      noc6_data_s_in     : in  noc_flit_type;
      noc6_data_w_in     : in  noc_flit_type;
      noc6_data_e_in     : in  noc_flit_type;
      noc6_data_void_in  : in std_logic_vector(3 downto 0);
      noc6_stop_in       : in std_logic_vector(3 downto 0);
      noc6_data_n_out    : out noc_flit_type;
      noc6_data_s_out    : out noc_flit_type;
      noc6_data_w_out    : out noc_flit_type;
      noc6_data_e_out    : out noc_flit_type;
      noc6_data_void_out : out std_logic_vector(3 downto 0);
      noc6_stop_out      : out std_logic_vector(3 downto 0);
      noc1_mon_noc_vec   : out monitor_noc_type;
      noc2_mon_noc_vec   : out monitor_noc_type;
      noc3_mon_noc_vec   : out monitor_noc_type;
      noc4_mon_noc_vec   : out monitor_noc_type;
      noc5_mon_noc_vec   : out monitor_noc_type;
      noc6_mon_noc_vec   : out monitor_noc_type;
      mon_mem            : out monitor_mem_type;
      mon_dvfs           : out monitor_dvfs_type);
  end component tile_slm;

end soctiles;
