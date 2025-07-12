----------------------------------------------------------------------------------
-- Engineer: Maxim Mikhaylov
-- 
-- Design Name: UART Encryptor/Decryptor
-- Module Name: SerialCryptor - Behavior
-- Target Devices: Nexys A7-100T
-- Tool Versions: Vivado 2023.1.1
--
-- Description: 
-- This project implements a secure UART communication system. 
-- It includes the following components:
-- 
--  - UART interface for serial data transmission and reception
--  - Finite State Machine (FSM) to control data flow and trigger operations
--  - Pseudo-Random Number Generator (PRNG) for dynamic key generation
--  - XOR-based Encrypt/Decrypt module for simple symmetric encryption
-- 
-- Received UART data is encrypted using a key from the PRNG and sent back over
-- the UART interface. System behavior is controlled via user input switches.
-- 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
entity SerialCryptor is 
  Port
  ( CLK100MHZ   : in std_logic; -- Clock (100 MHz)
    BTNC        : in std_logic; -- Reset
    SW          : in std_logic_vector(15 downto 0); -- Switch Input
    UART_TXD_IN : in std_logic; -- UART Input
    
    UART_RXD_OUT : out std_logic -- UART Output
  );
end SerialCryptor;

architecture Behavior of SerialCryptor is 

-- UART signals
signal sTxData    : std_logic_vector(7 downto 0);
signal sRxData    : std_logic_vector(7 downto 0);
signal sTxBusy    : std_logic;
signal sRxDataRdy : std_logic;
signal sTxStart   : std_logic;

-- Number Generator Signals
signal sKey   : std_logic_vector(7 downto 0);
signal sPDO   : std_logic_vector(15 downto 0);
signal sLoad  : std_logic;
signal sShift : std_logic;

-- components
component FSM is
  Port
  ( CLK       : in std_logic;
    RST       : in std_logic;       
    RxDataRdy : in std_logic;
  
    TxStart : out std_logic;
    Load    : out std_logic;
    Shift   : out std_logic
  );
end component;

component NumGenerator is
  Port
  ( CLK   : in std_logic;
    PDI   : std_logic_vector(15 downto 0);      
    LOAD  : in std_logic;
    SHIFT : in std_logic;
  
    PDO : out std_logic_vector(15 downto 0);
    SDO : out std_logic_vector(7 downto 0)
  );
end component;

component EncryptDecrypt is
  Port
  ( CLK       : in std_logic;
    Key       : in std_logic_vector(7 downto 0);
    PlainText : in std_logic_vector(7 downto 0);
  
    CipherText : out std_logic_vector(7 downto 0)
  );
end component;

component UART is 
  Port
  ( CLK         : in std_logic;
    RST         : in std_logic;
    UART_TXD_IN : in std_logic;
    TxStart     : in std_logic;
    TxData      : in std_logic_vector(7 downto 0);
    
    RxDataRdy    : out std_logic;
    RxData       : out std_logic_vector(7 downto 0);
    TxBusy       : out std_logic;
    UART_RXD_OUT : out std_logic
  );
end component;

begin

 -- UART
  TransmitReceive : UART
  port map
  ( CLK => CLK100MHZ, 
    RST=> BTNC, 
    UART_TXD_IN  => UART_TXD_IN, 
    TxStart      => sTxStart,
    TxData       => sTxData,
    RxDataRdy    => sRxDataRdy,
    RxData       => sRxData,
    TxBusy       => sTxBusy,
    UART_RXD_OUT => UART_RXD_OUT
  );
 
  -- FSM
  FiniteStateMachine : FSM
  port map
  ( CLK       => CLK100MHZ,
    RST       => BTNC,
    RxDataRdy => sRxDataRdy,
    TxStart   => sTxStart,
    Load      => sLoad,
    Shift     => sShift
  );
 
 
  -- PRNG
  PRNG : NumGenerator
  port map
  ( CLK   => CLK100MHZ,
    PDI   => SW,   
    LOAD  => sLoad,
    SHIFT => sShift, 
    PDO   => sPDO,
    SDO   => sKey
  );
  
  -- XOR Encrypt/Decrypt
   XOR_E_D : EncryptDecrypt
   port map
   ( CLK        => CLK100MHZ,
     Key        => sKey,
     PlainText  => sRxData,
     CipherText => sTxData
   ); 

end Behavior;
