-- EncryptDecrypt

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EncryptDecrypt is 
  Port
  ( CLK       : in std_logic;
    Key       : in std_logic_vector(7 downto 0);
    PlainText : in std_logic_vector(7 downto 0); -- Input
    
    CipherText : out std_logic_vector(7 downto 0) -- Output
  );
end EncryptDecrypt;

architecture Behavior of EncryptDecrypt is    

begin

  process(CLK)
    begin
      if rising_edge(CLK) then
        CipherText <= PlainText XOR (Key AND "00011111"); -- Encryption Function
      end if;
    end process;

end Behavior;