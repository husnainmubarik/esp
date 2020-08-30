 -- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.test_int_package.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.memoryctrl.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;



entity jtag_test is
  port (
    rst    : in std_ulogic;
    refclk : in std_ulogic;

    tdi  : in  std_logic;
    tdo  : out std_logic;
    tms  : in  std_logic;
    tclk : in  std_logic;

    noc1_output_port       : in noc_flit_type;
    noc1_cpu_data_void_out : in std_ulogic;
    noc2_output_port       : in noc_flit_type;
    noc2_cpu_data_void_out : in std_ulogic;
    noc3_output_port       : in noc_flit_type;
    noc3_cpu_data_void_out : in std_ulogic;
    noc4_output_port       : in noc_flit_type;
    noc4_cpu_data_void_out : in std_ulogic;
    noc5_output_port       : in misc_noc_flit_type;
    noc5_cpu_data_void_out : in std_ulogic;
    noc6_output_port       : in noc_flit_type;
    noc6_cpu_data_void_out : in std_ulogic;

    test1_cpu_data_void_out : out std_ulogic;
    test1_output_port       : out noc_flit_type;
    test2_cpu_data_void_out : out std_ulogic;
    test2_output_port       : out noc_flit_type;
    test3_cpu_data_void_out : out std_ulogic;
    test3_output_port       : out noc_flit_type;
    test4_cpu_data_void_out : out std_ulogic;
    test4_output_port       : out noc_flit_type;
    test5_cpu_data_void_out : out std_ulogic;
    test5_output_port       : out misc_noc_flit_type;
    test6_cpu_data_void_out : out std_ulogic;
    test6_output_port       : out noc_flit_type;

    noc1_in_port            : in noc_flit_type;
    tonoc1_cpu_data_void_in : in std_ulogic;
    noc2_in_port            : in noc_flit_type;
    tonoc2_cpu_data_void_in : in std_ulogic;
    noc3_in_port            : in noc_flit_type;
    tonoc3_cpu_data_void_in : in std_ulogic;
    noc4_in_port            : in noc_flit_type;
    tonoc4_cpu_data_void_in : in std_ulogic;
    noc5_in_port            : in misc_noc_flit_type;
    tonoc5_cpu_data_void_in : in std_ulogic;
    noc6_in_port            : in noc_flit_type;
    tonoc6_cpu_data_void_in : in std_ulogic;


    noc1_input_port       : out noc_flit_type;
    noc1_cpu_data_void_in : out std_ulogic;
    noc2_input_port       : out noc_flit_type;
    noc2_cpu_data_void_in : out std_ulogic;
    noc3_input_port       : out noc_flit_type;
    noc3_cpu_data_void_in : out std_ulogic;
    noc4_input_port       : out noc_flit_type;
    noc4_cpu_data_void_in : out std_ulogic;
    noc5_input_port       : out misc_noc_flit_type;
    noc5_cpu_data_void_in : out std_ulogic;
    noc6_input_port       : out noc_flit_type;
    noc6_cpu_data_void_in : out std_ulogic;

    noc1_stop_out_s4 : in std_logic;
    noc2_stop_out_s4 : in std_logic;
    noc3_stop_out_s4 : in std_logic;
    noc4_stop_out_s4 : in std_logic;
    noc5_stop_out_s4 : in std_logic;
    noc6_stop_out_s4 : in std_logic;

    noc1_cpu_stop_out : out std_ulogic;
    noc2_cpu_stop_out : out std_ulogic;
    noc3_cpu_stop_out : out std_ulogic;
    noc4_cpu_stop_out : out std_ulogic;
    noc5_cpu_stop_out : out std_ulogic;
    noc6_cpu_stop_out : out std_ulogic;

    noc1_cpu_stop_in : in std_ulogic;
    noc2_cpu_stop_in : in std_ulogic;
    noc3_cpu_stop_in : in std_ulogic;
    noc4_cpu_stop_in : in std_ulogic;
    noc5_cpu_stop_in : in std_ulogic;
    noc6_cpu_stop_in : in std_ulogic);

end;


architecture rtl of jtag_test is

  type jtag_state_type is (rti, rti1, inject1, inject2, inject3,
                           inject4, inject5, inject6, extract,
                           read_and_check, request_instr,
                           waitforvoid1, waitforvoid2, waitforvoid3,
                           waitforvoid4, waitforvoid5, waitforvoid6);

  type jtag_ctrl_t is record
    state        : jtag_state_type;
    demux_sel    : std_logic_vector(5 downto 0);
    compare      : std_logic_vector(5 downto 0);
    sipo_clear   : std_ulogic;
    piso_load0   : std_ulogic;
    piso_en      : std_ulogic;
    piso_en0     : std_ulogic;
    piso_clear   : std_ulogic;
    piso_clear0  : std_ulogic;
    skip         : std_ulogic;
    lastwrite    : std_ulogic;
    rd_i_out     : std_logic_vector(1 to 6);
  end record jtag_ctrl_t;

  constant JTAG_CTRL_RESET : jtag_ctrl_t := (
    state        => rti,
    demux_sel    => (others => '0'),
    compare      => (others => '0'),
    sipo_clear   => '0',
    piso_load0   => '0',
    piso_en      => '0',
    piso_en0     => '0',
    piso_clear   => '0',
    piso_clear0  => '0',
    skip         => '0',
    lastwrite    => '0',
    rd_i_out     => (others => '0')
    );

  signal r, rin : jtag_ctrl_t;

  -- Main FSM output signals
  signal tdo_data     : std_ulogic;
  signal tdo_data0    : std_ulogic;
  signal sipo_done    : std_ulogic;
  signal piso_load    : std_ulogic;
  signal piso_done    : std_ulogic;
  signal piso_done0   : std_ulogic;
  signal skipwait     : std_ulogic;
  signal sipo_en_in   : std_ulogic;
  signal sipo_en_i    : std_logic_vector(1 to 6);
  signal op_i         : std_logic_vector(1 to 6);  -- maybe unused
  signal sipo_done_i  : std_logic_vector(1 to 6);
  signal sipo_clear_i : std_logic_vector(1 to 6);
  signal tdi_i        : std_logic_vector(1 to 6);

  --signals for logic JTAG->CPU
  signal rd_i            : std_logic_vector(1 to 6);
  signal we_in           : std_logic_vector(1 to 6);
  signal fwd_wr_full_o   : std_logic_vector(1 to 6);
  signal end_trace       : std_logic_vector(1 to 6);
  signal fwd_rd_empty_o1 : std_ulogic;
  signal fwd_rd_empty_o2 : std_ulogic;
  signal fwd_rd_empty_o3 : std_ulogic;
  signal fwd_rd_empty_o4 : std_ulogic;
  signal fwd_rd_empty_o5 : std_ulogic;
  signal fwd_rd_empty_o6 : std_ulogic;

  type test_vect is array(1 to 6) of noc_flit_type;
  signal test_in, test_in_sync : test_vect;

  signal sipo_comp         : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test_comp, sipo_c : std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
  signal data              : std_logic_vector(NOC_FLIT_SIZE+7 downto 0);
  signal data0             : std_logic_vector(7 downto 0);
  type t_comp is array (1 to 6) of std_logic_vector(NOC_FLIT_SIZE+8 downto 0);
  signal sipo_comp_i       : t_comp;

  signal source_compare : std_logic_vector(6 downto 0);
  signal test_out       : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal piso_in        : std_logic_vector(NOC_FLIT_SIZE+7 downto 0);
  signal piso0_in       : std_logic_vector(7 downto 0);
  
  --signals for logic CPU->JTAG
  signal A, B, C, D, E, F : std_logic_vector(NOC_FLIT_SIZE downto 0);

  signal test1_out, t1_out      : noc_flit_type;
  signal test1_cpu_data_void_in : std_ulogic;
  signal test1_cpu_stop_out     : std_ulogic;
  signal t1_cpu_data_void_in    : std_ulogic;

  signal test2_out, t2_out      : noc_flit_type;
  signal test2_cpu_data_void_in : std_ulogic;
  signal test2_cpu_stop_out     : std_ulogic;
  signal t2_cpu_data_void_in    : std_ulogic;

  signal test3_out, t3_out      : noc_flit_type;
  signal test3_cpu_data_void_in : std_ulogic;
  signal test3_cpu_stop_out     : std_ulogic;
  signal t3_cpu_data_void_in    : std_ulogic;

  signal test4_out, t4_out      : noc_flit_type;
  signal test4_cpu_data_void_in : std_ulogic;
  signal test4_cpu_stop_out     : std_ulogic;
  signal t4_cpu_data_void_in    : std_ulogic;

  signal test6_out, t6_out      : noc_flit_type;
  signal test6_cpu_data_void_in : std_ulogic;
  signal test6_cpu_stop_out     : std_ulogic;
  signal t6_cpu_data_void_in    : std_ulogic;

  signal test5_out, t5_out      : misc_noc_flit_type;
  signal test5_cpu_data_void_in : std_ulogic;
  signal test5_cpu_stop_out     : std_ulogic;
  signal t5_cpu_data_void_in    : std_ulogic;

  signal rd_i_out     : std_logic_vector(1 to 6);
  
  signal we_in_out          : std_logic_vector(1 to 6);

  signal fwd_rd_empty_o5out : std_ulogic;
  signal fwd_wr_full_o5out  : std_ulogic;

--  variable v : jtag_ctrl_t;
  
begin

  -- jtag_fsm
  CU_REG : process (tclk, rst)
  begin
    if rst = '0' then
      r <= JTAG_CTRL_RESET;
    elsif tclk'event and tclk = '1' then
      r <= rin;
    end if;
  end process CU_REG;

  NSL : process(r, sipo_done, sipo_done_i,
                piso_done, piso_done0,
                tms, sipo_comp, sipo_comp_i)
    
    variable v : jtag_ctrl_t;
  begin
    -- Default assignments
    v := r;
    -- 
    rd_i_out<=(others=>'0');
    we_in<=(others=>'0');
        
    
    case r.state is

      when rti =>
        if tms = '1' then
          v.state := waitforvoid1;
        end if;

      when request_instr =>  v.piso_load0 :='0';
                             we_in <= (others =>'0');
                             v.piso_en0 :='1';
                             v.sipo_clear :='1';
                             if piso_done0 ='1' then
                               v.sipo_clear :='0';
                               case r.compare is
                                 when "100000" => v.state := inject1;
                                 when "010000" => v.state := inject2;
                                 when "001000" => v.state := inject3;
                                 when "000100" => v.state := inject4;
                                 when "000010" => v.state := inject5;
                                 when "000001" => v.state := inject6;
                                 when others => null;
                               end case;
                             end if;
                             
  
        
      when inject1 =>   v.piso_en0 := '0';
                        v.demux_sel := "100000";
                        sipo_en_in <='1';
                        
                        if sipo_done_i(1) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid1;
                        end if;
                    


      when inject2 =>   v.piso_en0 := '0';
                        v.demux_sel := "010000";
                        sipo_en_in <='1';
                        if sipo_done_i(2) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid2;
                        end if;
                      
      
      when inject3 =>   v.piso_en0 := '0';
                        v.demux_sel := "001000";
                        sipo_en_in <='1';
                        if sipo_done_i(3) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid3;
                        end if;
                     
      
      when inject4 =>   v.piso_en0 := '0';
                        v.demux_sel := "000100";
                        sipo_en_in <='1';
                        if sipo_done_i(4) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid4;
                        end if;
                      
      
      when inject5 =>   v.piso_en0 := '0';
                        v.demux_sel := "000010";
                        sipo_en_in <='1';
                        if sipo_done_i(5) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid5;
                        end if;
                      
      
      when inject6 =>   v.piso_en0 := '0';
                        v.demux_sel := "000001";
                        sipo_en_in <='1';
                        if sipo_done_i(6) = '1' then
                          --v.piso_clear0:='1';
                          sipo_en_in <='0';
                          v.compare := (others => '0');
                          v.state := waitforvoid6;
                        end if;
                      
      
                      
                      
      when rti1 => if end_trace(1)='0' then
                     v.state:=waitforvoid1;
                   elsif end_trace(2)='0' then
                     v.state:=waitforvoid2;
                   elsif end_trace(3)='0' then
                     v.state:=waitforvoid3;
                   elsif end_trace(4)='0' then
                     v.state:=waitforvoid4;
                   elsif end_trace(5)='0' then
                     v.state:=waitforvoid5;
                   elsif end_trace(6)='0' then
                     v.state:=waitforvoid6;
                   end if;
                   
      when waitforvoid1 =>  if sipo_done_i(1)='1' then 
                             if op_i(1)='0' then            -- instr is a wait
                               if test1_cpu_data_void_in = '0' then -- check queue
                                 v.compare:="100000";
                                 --piso_load<='1';
                                 --rd_i_out(1)<='1';
                                 v.state:=read_and_check;
                               else                       --plane not manageable
                                 v.state:=waitforvoid2; 
                               end if;
                             else                              -- instr is a write
                               if fwd_wr_full_o(1)='0' then    -- check queue
                                 v.compare:="100000";
                                 
                                 we_in(1)<='1';
                                 v.piso_load0:='1';
                                 v.state:=request_instr;
                               else                     --plane not manageable
                                 v.state:=waitforvoid2;
                              end if;
                             end if;
                            else           -- register still empty 
                              v.state:=request_instr;
                              v.compare:="100000";
                              v.piso_load0:='1';
                            end if ;

      when waitforvoid2 =>  if sipo_done_i(2)='1' then 
                             if op_i(2)='0' then            -- instr is a wait
                               if test2_cpu_data_void_in = '0' then -- check queue
                                 v.compare:="010000";
                                 --piso_load<='1';
                                 --rd_i_out(2)<='1';
                                 v.state:=read_and_check;
                               else                       --plane not manageable
                                 v.state:=waitforvoid3; 
                               end if;
                             else                              -- instr is a write
                               if fwd_wr_full_o(2)='0' then    -- check queue
                                 v.compare:="010000";
                                 
                                 we_in(2)<='1';
                                 v.piso_load0:='1';
                                 v.piso_clear0:='0';
                                 v.state:=request_instr;
                               else                     --plane not manageable
                                 v.state:=waitforvoid3;
                               end if;
                             end if;
                            else           -- register still empty 
                             
                             v.state:=request_instr;
                             v.compare:="010000";
                             v.piso_load0:='1';
                            end if ;
                           
      when waitforvoid3 =>  if sipo_done_i(3)='1' then 
                              if op_i(3)='0' then            -- instr is a wait
                                if test3_cpu_data_void_in = '0' then -- check queue
                                  v.compare:="001000";
                                  --piso_load<='1';
                                  --rd_i_out(3)<='1';
                                  v.state:=read_and_check;
                                else                       --plane not manageable
                                  v.state:=waitforvoid4; 
                                end if;
                              else                              -- instr is a write
                                if fwd_wr_full_o(3)='0' then    -- check queue
                                  v.compare:="001000";
                                  
                                  we_in(3)<='1';
                                  v.piso_load0:='1';
                                  v.piso_clear0:='0';
                                  v.state:=request_instr;
                                else                     --plane not manageable
                                  v.state:=waitforvoid4;
                                end if;
                              end if;
                            else           -- register still empty 
                              v.state:=request_instr;
                              v.compare:="001000";
                              v.piso_load0:='1';
                            end if ;

      when waitforvoid4 =>  if sipo_done_i(4)='1' then 
                             if op_i(4)='0' then            -- instr is a wait
                               if test4_cpu_data_void_in = '0' then -- check queue
                                 v.compare:="000100";
                                 --piso_load<='1';
                                 --rd_i_out(4)<='1';
                                 v.state:=read_and_check;
                               else                       --plane not manageable
                                 v.state:=waitforvoid5; 
                               end if;
                             else                              -- instr is a write
                               if fwd_wr_full_o(1)='0' then    -- check queue
                                 v.compare:="000100";

                                 we_in(4)<='1';
                                 v.piso_load0:='1';
                                 v.piso_clear0:='0';
                                 v.state:=request_instr;
                               else                     --plane not manageable
                                 v.state:=waitforvoid5;
                              end if;
                             end if;
                            else           -- register still empty 
                             v.state:=request_instr;
                             v.compare:="000100";
                             v.piso_load0:='1';
                            end if ;

      when waitforvoid5 =>  if sipo_done_i(5)='1' then 
                             if op_i(5)='0' then            -- instr is a wait
                               if test5_cpu_data_void_in = '0' then -- check queue
                                 v.compare:="000010";
                                 --piso_load<='1';
                                 --rd_i_out(5)<='1';
                                 v.state:=read_and_check;
                               else                       --plane not manageable
                                 v.state:=waitforvoid6; 
                               end if;
                             else                              -- instr is a write
                               if fwd_wr_full_o(5)='0' then    -- check queue
                                 v.compare:="000010";
                                 
                                 we_in(5)<='1';
                                 v.piso_load0:='1';
                                 v.piso_clear0:='0';
                                 v.state:=request_instr;
                               else                     --plane not manageable
                                 v.state:=waitforvoid6;
                              end if;
                             end if;
                            else           -- register still empty 
                             v.state:=request_instr;
                             v.compare:="000010";
                             v.piso_load0:='1';
                            end if ;

      when waitforvoid6 =>  if sipo_done_i(6)='1' then 
                             if op_i(6)='0' then            -- instr is a wait
                               if test6_cpu_data_void_in = '0' then -- check queue
                                 v.compare:="000001";
                                 --piso_load<='1';
                                 --rd_i_out(6)<='1';
                                 v.state:=read_and_check;
                               else                       --plane not manageable
                                 v.state:=rti1; 
                               end if;
                             else                              -- instr is a write
                               if fwd_wr_full_o(6)='0' then    -- check queue
                                 v.compare:="000001";
                                 
                                 we_in(1)<='1';
                                 v.piso_load0:='1';
                                 v.piso_clear0:='0';
                                 v.state:=request_instr;
                               else                     --plane not manageable
                                 v.state:=rti1;
                              end if;
                             end if;
                            else           -- register still empty 
                             v.piso_load0:='1';
                             v.state:=request_instr;
                             v.compare:="000001";
                            end if ;


      when read_and_check => case r.compare is
                               when "100000" => rd_i_out(1)<='1';
                               when "010000" => rd_i_out(2)<='1';
                               when "001000" => rd_i_out(3)<='1';
                               when "000100" => rd_i_out(4)<='1';
                               when "000010" => rd_i_out(5)<='1';
                               when "000001" => rd_i_out(6)<='1';
                               when others=>null;
                             end case;
                             piso_load <='1';
                             v.state := extract;
                             v.piso_en      := '1';
                          

      when extract =>   piso_load<='0';
                        rd_i_out<=(others=>'0');
                        if piso_done = '1' then
                          v.state:= request_instr;
                          v.piso_load0 :='1';
                          v.sipo_clear := '1';
                          v.piso_en :='0';
                        end if;

    end case;

    rin <= v;

  end process NSL;

  -- lastwrite    <= lastw;
  -- skipwait     <= skip;
  -- compare_reg1 <= compare_reg;



--  process(tclk, cnt_en, cnt_rs)
--  begin
--    if cnt_rs = '1' then
--      cnt_r <= (others => '0');
--    elsif tclk'event and tclk = '1' and cnt_en = '1' then
--      cnt_r <= cnt_r+1;
--    end if;
--  end process;



  -- process(sipo_en_is, sipo_en_ii, jtag_current)
  -- begin
  --   if jtag_current = inject_instruction then
  --     sipo_en_i <= sipo_en_is;
  --   else
  --     sipo_en_i <= sipo_en_ii;
  --   end if;
  -- end process;

  process(r.compare, sipo_done_i)
  begin
    case r.compare is
      when "100000" => sipo_done <= sipo_done_i(1);
      when "010000" => sipo_done <= sipo_done_i(2);
      when "001000" => sipo_done <= sipo_done_i(3);
      when "000100" => sipo_done <= sipo_done_i(4);
      when "000010" => sipo_done <= sipo_done_i(5);
      when "000001" => sipo_done <= sipo_done_i(6);
      when others   => null;
    end case;

  end process;


  -- Enable serial-in-parallel-out register to get next instruction from trace

  process(sipo_en_in, r.compare)
  begin
    if sipo_en_in = '1' then
      case r.compare is
        when "100000" => sipo_en_i(1) <= '1';
        when "010000" => sipo_en_i(2) <= '1';
        when "001000" => sipo_en_i(3) <= '1';
        when "000100" => sipo_en_i(4) <= '1';
        when "000010" => sipo_en_i(5) <= '1';
        when "000001" => sipo_en_i(6) <= '1';
        when others   => sipo_en_i <= (others => '0');
      end case;
    else
      sipo_en_i <= (others => '0');
    end if;
  end process;

  process(r.sipo_clear, r.compare)
  begin
    if r.sipo_clear = '1' then
      case r.compare is
        when "100000" => sipo_clear_i(1) <= '1';
        when "010000" => sipo_clear_i(2) <= '1';
        when "001000" => sipo_clear_i(3) <= '1';
        when "000100" => sipo_clear_i(4) <= '1';
        when "000010" => sipo_clear_i(5) <= '1';
        when "000001" => sipo_clear_i(6) <= '1';

        when others => null;
      end case;
    else
      sipo_clear_i <= (others => '0');
    end if;
  end process;

  GEN_SIPO : for i in 1 to 6 generate

    sipo_i : sipo
      generic map (DIM => NOC_FLIT_SIZE+9)
      port map (
        clk       => tclk,
        clear     => sipo_clear_i(i),
        en_in     => sipo_en_i(i),
        serial_in => tdi_i(i),
        test_comp => sipo_comp_i(i),
        data_out  => test_in(i),
        op        => op_i(i),
        done      => sipo_done_i(i),
        end_trace => end_trace(i));


  end generate GEN_SIPO;


  demux_1to6_1 : demux_1to6
    port map(
      data_in => tdi,
      sel     => r.demux_sel,
      out1    => tdi_i(1),
      out2    => tdi_i(2),
      out3    => tdi_i(3),
      out4    => tdi_i(4),
      out5    => tdi_i(5),
      out6    => tdi_i(6));


  --from NoC plane 1
  rd_i(1) <= noc1_cpu_stop_in nor fwd_rd_empty_o1;

  async_fifo_01 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(1),
      d_i        => test_in(1),
      wr_full_o  => fwd_wr_full_o(1),
      clk_rd_i   => refclk,
      rd_i       => rd_i(1),
      q_o        => test_in_sync(1),
      rd_empty_o => fwd_rd_empty_o1);


  test1_output_port <= test_in_sync(1) when tms = '1' else noc1_output_port;
  test1_cpu_data_void_out <= fwd_rd_empty_o1 when tms = '1' else noc1_cpu_data_void_out;



  --from NoC plane 2
  rd_i(2) <= noc2_cpu_stop_in nor fwd_rd_empty_o2;

  async_fifo_02 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(2),
      d_i        => test_in(2),
      wr_full_o  => fwd_wr_full_o(2),
      clk_rd_i   => refclk,
      rd_i       => rd_i(2),
      q_o        => test_in_sync(2),
      rd_empty_o => fwd_rd_empty_o2);


  test2_output_port <= test_in_sync(2) when tms = '1' else noc2_output_port;
  test2_cpu_data_void_out <= fwd_rd_empty_o2 when tms = '1' else noc2_cpu_data_void_out;


  --from NoC plane 3
  rd_i(3) <= noc3_cpu_stop_in nor fwd_rd_empty_o3;

  async_fifo_03 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(3),
      d_i        => test_in(3),
      wr_full_o  => fwd_wr_full_o(3),
      clk_rd_i   => refclk,
      rd_i       => rd_i(3),
      q_o        => test_in_sync(3),
      rd_empty_o => fwd_rd_empty_o3);


  test3_output_port <= test_in_sync(3) when tms = '1' else noc3_output_port;
  test3_cpu_data_void_out <= fwd_rd_empty_o3 when tms = '1' else noc3_cpu_data_void_out;

  --from NoC plane 4
  rd_i(4) <= noc4_cpu_stop_in nor fwd_rd_empty_o4;

  async_fifo_04 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(4),
      d_i        => test_in(4),
      wr_full_o  => fwd_wr_full_o(4),
      clk_rd_i   => refclk,
      rd_i       => rd_i(4),
      q_o        => test_in_sync(4),
      rd_empty_o => fwd_rd_empty_o4);


  test4_output_port <= test_in_sync(4) when tms = '1' else noc4_output_port;
  test4_cpu_data_void_out <= fwd_rd_empty_o4 when tms = '1' else noc4_cpu_data_void_out;



  --from NoC plane 5
  rd_i(5) <= noc5_cpu_stop_in nor fwd_rd_empty_o5;

  async_fifo_05 : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(5),
      d_i        => test_in(5)(MISC_NOC_FLIT_SIZE-1 downto 0),
      wr_full_o  => fwd_wr_full_o(5),
      clk_rd_i   => refclk,
      rd_i       => rd_i(5),
      q_o        => test_in_sync(5)(MISC_NOC_FLIT_SIZE-1 downto 0),
      rd_empty_o => fwd_rd_empty_o5);


  test5_output_port <= test_in_sync(5)(MISC_NOC_FLIT_SIZE-1 downto 0) when tms = '1' else noc5_output_port;
  test5_cpu_data_void_out <= fwd_rd_empty_o5 when tms = '1' else noc5_cpu_data_void_out;


  --from NoC plane 6
  rd_i(6) <= noc6_cpu_stop_in nor fwd_rd_empty_o6;

  async_fifo_06 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 2)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => tclk,
      we_i       => we_in(6),
      d_i        => test_in(6),
      wr_full_o  => fwd_wr_full_o(6),
      clk_rd_i   => refclk,
      rd_i       => rd_i(6),
      q_o        => test_in_sync(6),
      rd_empty_o => fwd_rd_empty_o6);


  test6_output_port <= test_in_sync(6) when tms = '1' else noc6_output_port;
  test6_cpu_data_void_out <= fwd_rd_empty_o6 when tms = '1' else noc6_cpu_data_void_out;

  -- Pick data for comparison with expected value
  process(r.compare, sipo_comp_i)
  begin
    case r.compare is
      when "100000" => sipo_comp <= sipo_comp_i(1)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(1)(1);
      when "010000" => sipo_comp <= sipo_comp_i(2)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(2)(1);
      when "001000" => sipo_comp <= sipo_comp_i(3)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(3)(1);
      when "000100" => sipo_comp <= sipo_comp_i(4)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(4)(1);
      when "000010" => sipo_comp <= sipo_comp_i(5)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(5)(1);
      when "000001" => sipo_comp <= sipo_comp_i(6)(NOC_FLIT_SIZE+8 downto 9) & sipo_comp_i(6)(1);
      when others   => sipo_comp <= (others => '0');
    end case;
  end process;

  -- Drive tdo
  tdoout : process(r.piso_en, r.piso_en0, sipo_comp, tdo_data, tdo_data0, r.state, test_comp, sipo_c)
  begin
    if r.piso_en = '1' then
      tdo <= tdo_data;
    elsif r.piso_en0 = '1' then
      tdo <= tdo_data0;
    else
      if (r.state = read_and_check and test_comp = sipo_c) then
        tdo <= '1';
      else
        tdo <= '0';
      end if;
    end if;
  end process tdoout;

  sipo_c <= sipo_comp(NOC_FLIT_SIZE downto 1);

  -- to NoC plane 1
  we_in_out(1)  <=  t1_cpu_data_void_in nor test1_cpu_stop_out;

  async_fifo_i1 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(1),
      d_i        => t1_out,
      wr_full_o  => test1_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(1),
      q_o        => test1_out,
      rd_empty_o => test1_cpu_data_void_in);

  noc1_input_port <= noc1_in_port;
  noc1_cpu_data_void_in <= '1' when tms = '1' else tonoc1_cpu_data_void_in;

  t1_out <= noc1_in_port;
  t1_cpu_data_void_in <= tonoc1_cpu_data_void_in when tms = '1' else '1';


  -- to NoC plane 2
  we_in_out(2)  <=  t2_cpu_data_void_in nor test2_cpu_stop_out;

  async_fifo_i2 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(2),
      d_i        => t2_out,
      wr_full_o  => test2_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(2),
      q_o        => test2_out,
      rd_empty_o => test2_cpu_data_void_in);

  noc2_input_port <= noc2_in_port;
  noc2_cpu_data_void_in <= '1' when tms = '1' else tonoc2_cpu_data_void_in;

  t2_out <= noc2_in_port;
  t2_cpu_data_void_in <= tonoc2_cpu_data_void_in when tms = '1' else '1';


  -- to NoC plane 3
  we_in_out(3)  <= t3_cpu_data_void_in nor test3_cpu_stop_out;

  async_fifo_i3 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(3),
      d_i        => t3_out,
      wr_full_o  => test3_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(3),
      q_o        => test3_out,
      rd_empty_o => test3_cpu_data_void_in);

  noc3_input_port <= noc3_in_port;
  noc3_cpu_data_void_in <= '1' when tms = '1' else tonoc3_cpu_data_void_in;

  t3_out <= noc3_in_port;
  t3_cpu_data_void_in <= tonoc3_cpu_data_void_in when tms = '1' else '1';


  -- to NoC plane 4
  we_in_out(4)  <= t4_cpu_data_void_in nor test4_cpu_stop_out;

  async_fifo_i4 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(4),
      d_i        => t4_out,
      wr_full_o  => test4_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(4),
      q_o        => test4_out,
      rd_empty_o => test4_cpu_data_void_in);

  noc4_input_port <= noc4_in_port;
  noc4_cpu_data_void_in <= '1' when tms = '1' else tonoc4_cpu_data_void_in;

  t4_out <= noc4_in_port;
  t4_cpu_data_void_in <= tonoc4_cpu_data_void_in when tms = '1' else '1';


  -- to NoC plane 5
  we_in_out(5)  <= t5_cpu_data_void_in nor test5_cpu_stop_out;

  async_fifo_i5 : inferred_async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(5),
      d_i        => t5_out,
      wr_full_o  => test5_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(5),
      q_o        => test5_out,
      rd_empty_o => test5_cpu_data_void_in);

  noc5_input_port <= noc5_in_port;
  noc5_cpu_data_void_in <= '1' when tms = '1' else tonoc5_cpu_data_void_in;

  t5_out <= noc5_in_port;
  t5_cpu_data_void_in <= tonoc5_cpu_data_void_in when tms = '1' else '1';


  -- to NoC plane 6
  we_in_out(6)  <= t6_cpu_data_void_in nor test6_cpu_stop_out;

  async_fifo_i6 : inferred_async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE,
      g_size       => 4)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in_out(6),
      d_i        => t6_out,
      wr_full_o  => test6_cpu_stop_out,
      clk_rd_i   => tclk,
      rd_i       => rd_i_out(6),
      q_o        => test6_out,
      rd_empty_o => test6_cpu_data_void_in);

  noc6_input_port <= noc6_in_port;
  noc6_cpu_data_void_in <= '1' when tms = '1' else tonoc6_cpu_data_void_in;

  t6_out <= noc6_in_port;
  t6_cpu_data_void_in <= tonoc6_cpu_data_void_in when tms = '1' else '1';

  -- Stop signals from NoC/JTAG to tile
  process(tms,
          noc1_stop_out_s4,
          noc2_stop_out_s4,
          noc3_stop_out_s4,
          noc4_stop_out_s4,
          noc5_stop_out_s4,
          noc6_stop_out_s4,
          test1_cpu_stop_out,
          test2_cpu_stop_out,
          test3_cpu_stop_out,
          test4_cpu_stop_out,
          test5_cpu_stop_out,
          test6_cpu_stop_out)
  begin
    if tms = '0' then
      noc1_cpu_stop_out <= noc1_stop_out_s4;
      noc2_cpu_stop_out <= noc2_stop_out_s4;
      noc3_cpu_stop_out <= noc3_stop_out_s4;
      noc4_cpu_stop_out <= noc4_stop_out_s4;
      noc5_cpu_stop_out <= noc5_stop_out_s4;
      noc6_cpu_stop_out <= noc6_stop_out_s4;
    else
      noc1_cpu_stop_out <= test1_cpu_stop_out;
      noc2_cpu_stop_out <= test2_cpu_stop_out;
      noc3_cpu_stop_out <= test3_cpu_stop_out;
      noc4_cpu_stop_out <= test4_cpu_stop_out;
      noc5_cpu_stop_out <= test5_cpu_stop_out;
      noc6_cpu_stop_out <= test6_cpu_stop_out;
    end if;
  end process;

  --final mux to test_out_reg
  A <=test1_out & test1_cpu_data_void_in;
  B <=test2_out & test2_cpu_data_void_in;
  C <=test3_out & test3_cpu_data_void_in;
  D <=test4_out & test4_cpu_data_void_in;
  E <=noc_flit_pad & test5_out & test5_cpu_data_void_in;
  F <=test6_out & test6_cpu_data_void_in;


  mux_6to1_1 : mux_6to1
    generic map(sz => NOC_FLIT_SIZE+1)
    port map(
      sel => r.compare,
      A   =>A,
      B   =>B,
      C   =>C,
      D   =>D,
      E   =>E,
      F   =>F,
      X   =>test_out);

  piso_in <= "0" & test_out & r.compare;
  piso0_in <= "11" & r.compare ;

  piso_0 : piso
    generic map(sz => 8)
    port map(
      clk      =>tclk,
      clear    =>r.piso_clear0,
      load     =>r.piso_load0,
      A        =>piso0_in,
      B        =>data0,
      shift_en =>r.piso_en0,
      Y        =>tdo_data0,
      done     =>piso_done0);

  test_comp<=piso_in(NOC_FLIT_SIZE+6 downto 7);

  piso_1 : piso
    generic map(sz => NOC_FLIT_SIZE+8)
    port map(
      clk      =>tclk,
      clear    =>r.piso_clear,
      load     =>piso_load,
      A        =>piso_in,
      B        =>data,
      shift_en =>r.piso_en,
      Y        =>tdo_data,
      done     =>piso_done);

end;
