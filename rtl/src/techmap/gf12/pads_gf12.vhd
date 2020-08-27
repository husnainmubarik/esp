
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

-------------------------------------------------------------------------------
-- Inpad
-------------------------------------------------------------------------------
entity gf12_inpad is
  generic (
    PAD_TYPE : string := "V");
  port (
    pad : in  std_ulogic;
    o   : out std_ulogic);
end;

architecture rtl of gf12_inpad is

  component PBDIRCMD125_H is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_H;

  component PBDIRCMD125_V is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_V;

  signal pad_int : std_logic;

begin

  pad_int <= pad;

  pad_v_gen: if PAD_TYPE = "V" generate
    p_i: PBDIRCMD125_V
      port map (
        PAD => pad_int,
        Y   => o,
        A   => '0',
        OE  => '0',
        DS0 => '1',
        DS1 => '1',
        SR  => '0',
        IE  => '1');
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = "H" generate
    p_i: PBDIRCMD125_H
      port map (
        PAD => pad_int,
        Y   => o,
        A   => '0',
        OE  => '0',
        DS0 => '1',
        DS1 => '1',
        SR  => '0',
        IE  => '1');
  end generate pad_h_gen;

end;


-------------------------------------------------------------------------------
-- Inoutpad
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gf12_iopad is
  generic (
    PAD_TYPE : string := "V");
  port (
    pad : inout std_logic;
    i   : in    std_ulogic;
    en  : in    std_ulogic;
    o   : out   std_logic;
    sr  : in    std_ulogic;
    ds0 : in    std_ulogic;
    ds1 : in    std_ulogic
    );
end;

architecture rtl of gf12_iopad is

  component PBDIRCMD125_H is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_H;

  component PBDIRCMD125_V is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_V;

  signal ien : std_ulogic;

begin

  ien <= not en;

  pad_v_gen: if PAD_TYPE = "V" generate
    p_i: PBDIRCMD125_V
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        DS0 => ds0,
        DS1 => ds1,
        SR  => sr,
        IE  => ien);
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = "H" generate
    p_i: PBDIRCMD125_H
      port map (
        PAD => pad,
        Y   => o,
        A   => i,
        OE  => en,
        DS0 => ds0,
        DS1 => ds1,
        SR  => sr,
        IE  => ien);
  end generate pad_h_gen;

end;


-------------------------------------------------------------------------------
-- Outpad
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gf12_outpad is
  generic (
    PAD_TYPE : string := "V");
  port (
    pad : out std_ulogic;
    i   : in  std_ulogic;
    sr  : in    std_ulogic;
    ds0 : in    std_ulogic;
    ds1 : in    std_ulogic
    );
end;

architecture rtl of gf12_outpad is

  component PBDIRCMD125_H is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_H;

  component PBDIRCMD125_V is
    port (
      PAD : inout std_logic;
      Y   : out   std_ulogic;
      A   : in    std_ulogic;
      OE  : in    std_ulogic;
      DS0 : in    std_ulogic;
      DS1 : in    std_ulogic;
      SR  : in    std_ulogic;
      IE  : in    std_ulogic);
  end component PBDIRCMD125_V;

  signal pad_int : std_logic;

begin

  pad <= pad_int;

  pad_v_gen: if PAD_TYPE = "V" generate
    p_i: PBDIRCMD125_V
      port map (
        PAD => pad_int,
        Y   => open,
        A   => i,
        OE  => '1',
        DS0 => ds0,
        DS1 => ds1,
        SR  => sr,
        IE  => '0');
  end generate pad_v_gen;

  pad_h_gen: if PAD_TYPE = "H" generate
    p_i: PBDIRCMD125_H
      port map (
        PAD => pad_int,
        Y   => open,
        A   => i,
        OE  => '1',
        DS0 => ds0,
        DS1 => ds1,
        SR  => sr,
        IE  => '0');
  end generate pad_h_gen;


end;

