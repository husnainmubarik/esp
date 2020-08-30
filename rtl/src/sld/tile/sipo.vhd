library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


  entity sipo is
    generic (DIM: integer);
      port(
         clk      : in std_logic;
         clear    : in std_logic;
         en_in    : in std_logic;
         serial_in: in std_logic;
         test_comp: out std_logic_vector(DIM-1 downto 0);  
         data_out : out std_logic_vector(DIM-10 downto 0);  
         op       : out std_logic; 
         done     : out std_logic;
         end_trace: out std_logic);
   end sipo;

      
  architecture arch of sipo is
      signal q: std_logic_vector(DIM-1 downto 0);
      signal data: std_logic_vector(DIM-10 downto 0);
      constant ZERO : std_logic_vector(DIM-10 downto 0) := std_logic_vector(to_unsigned(0,DIM-9));
        
    begin
        
    process(clk,en_in,clear,serial_in)
    begin
      if clear='1' then
        q<=(others=>'0');
      elsif (clk'event and clk='1' and en_in='1') then
        q(DIM-2 downto 0)<=q(DIM-1 downto 1);
        q(DIM-1)<=serial_in;
      end if;
    end process;

    process(data)
    begin
        if data=ZERO then
            end_trace<='1';
        else
            end_trace<='0';
        end if;
                  
    end process;
              
      
    done<=q(0);  
    op<=q(1);   
    test_comp<=q(DIM-1 downto 0);
    data<=q(DIM-1 downto 9);         
    data_out<=data;   
  end;
  
    
