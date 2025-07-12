-- NumGenerator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NumGenerator is 
  Port
  ( CLK   : in std_logic;
    PDI   : std_logic_vector(15 downto 0);      
    LOAD  : in std_logic;
    SHIFT : in std_logic;
    
    PDO : out std_logic_vector(15 downto 0);
    SDO : out std_logic_vector(7 downto 0)
  );
end NumGenerator;

architecture Behavior of NumGenerator is    

signal PDOi : std_logic_vector(15 downto 0) := (others => '0');

begin

  process(CLK)
    begin
      if rising_edge(CLK) then
        if LOAD = '1' then
          PDOi <= PDI;
        elsif SHIFT = '1' then
          PDOi(0) <=  PDOi(15) XOR PDOi(12) xor PDOi(3) xor PDOi(1); -- Galois generator polynomial
                PDOi <= PDOi(14 downto 0)& PDOi(0);
        end if;
      end if;
    end process;
   
    SDO <= PDOi(15 downto 8); -- Upper 8 bits serve as key
    PDO <= PDOi;
    

end Behavior;