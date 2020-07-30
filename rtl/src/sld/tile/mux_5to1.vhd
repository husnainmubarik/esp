library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_5to1 is
  generic (sz: integer);
  port
    ( sel : in  std_logic_vector(5 downto 0);
      A   : in  std_logic_vector (sz-1 downto 0);
      B   : in  std_logic_vector (sz-1 downto 0);
      C   : in  std_logic_vector (sz-1 downto 0);
      D   : in  std_logic_vector (sz-1 downto 0);
      E   : in  std_logic_vector (sz-1 downto 0);
      X   : out std_logic_vector (sz-1 downto 0));
end mux_5to1;

architecture arch of mux_5to1 is
begin

  process(sel,A,B,C,D,E)
    begin
      case sel is
        when "100000" =>
          X<=A;
        when "001000" =>
          X<=B;
        when "000100"=>
          X<=C;
        when "000010"=>
          X<=D;
        when "000001"=>
          X<=E;
        when others =>
          X<= (others =>'0');
      end case;
    end process;

end arch;



