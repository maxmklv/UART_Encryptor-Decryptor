-- FSM 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is 
  Port
  ( CLK       : in std_logic;
    RST       : in std_logic;       
    RxDataRdy : in std_logic;
    
    TxStart : out std_logic;
    Load    : out std_logic;
    Shift   : out std_logic
  );
end FSM;

architecture Moore of FSM is    

  type FSM_State is (Init,WaitForData,MakeKey,Encrypt);
  signal CurrentState : FSM_State;
  signal NextState    : FSM_State;

begin

  -- Current State Register
  process(CLK, RST)
  begin
    if RST = '1' then
      CurrentState <= Init;
    elsif rising_edge(CLK) then
      CurrentState <= NextState;
    end if;
  end process;
  
  -- Next State Process
  process (CurrentState, RxDataRdy)
  begin
    case CurrentState is
      when Init =>
        NextState <= WaitForData;
      when WaitForData =>
        if RxDataRdy = '1' then
          NextState <= MakeKey;
        else 
          NextState <= WaitForData;
        end if;
      when MakeKey =>
        NextState <= Encrypt;
      when Encrypt =>
        NextState <= WaitForData;
      end case;
    end process;
    
    -- Output Function
    TxStart <= '1' when CurrentState = Encrypt else '0';
    Load <= '1' when CurrentState = Init else '0';
    Shift <= '1' when CurrentState = MakeKey else '0';

end Moore;