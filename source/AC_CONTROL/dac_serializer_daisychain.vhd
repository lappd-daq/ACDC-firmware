-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- e oberla                                                                  --
-- DATE: Mar. 2010                                                           --
-- PROJECT: psTDC_2 tester firmware                                          --
-- NAME: DAC_SERIALIZER                                                      --
-- Description:                                                              --
--      DAC serialization module                                             --
--    -- customized for use with Linear Tech. LTC2620 Octal 12-bit DAC--     --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity DAC_SERIALIZER_DAISYCHAIN is
  port(
        xCLK             : in    std_logic;      -- DAC clk ( < 50MHz ) 
        xUPDATE          : in    std_logic;
        xDAC_A           : in    std_logic_vector (63 downto 0);  
        xDAC_B           : in    std_logic_vector (63 downto 0);  
        xDAC_C           : in    std_logic_vector (63 downto 0);  
        xDAC_D           : in    std_logic_vector (63 downto 0);
        xDAC_E           : in    std_logic_vector (63 downto 0); 
        xDAC_F           : in    std_logic_vector (63 downto 0); 
        xDAC_G           : in    std_logic_vector (63 downto 0);  
        xDAC_H           : in    std_logic_vector (63 downto 0); 
       -- xSERIAL_DATIN	 : in	 std_logic;
        xLOAD            : out   std_logic;     -- load DACs- active low
        xCLR_BAR         : out   std_logic;     -- Asynch clear
        xSERIAL_DATOUT   : out   std_logic);    -- Serial data to DAC reg
end DAC_SERIALIZER_DAISYCHAIN;
        
architecture Behavioral of DAC_SERIALIZER_DAISYCHAIN is
  type STATE_TYPE is (IDLE, DATA_XFER, WAIT4XFER);
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------
  signal STATE          : STATE_TYPE;
  signal SERIAL_DATOUT  : std_logic := '1';
  signal LOAD           : std_logic := '1';
  signal DAT            : std_logic_vector(63 downto 0);
  signal CLR_BAR        : std_logic := '1';  --keep DAC regs 'uncleared' for now
  signal CHAN_CNT       : std_logic_vector(2 downto 0);
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  xSERIAL_DATOUT <= SERIAL_DATOUT;
  xLOAD <= LOAD;
  xCLR_BAR <= CLR_BAR;
  --xSERIAL_DATIN <= open;
-------------------------------------------------------------------------------
   process(CHAN_CNT, xDAC_A, xDAC_B, xDAC_C, xDAC_D, xDAC_E, xDAC_F, xDAC_G, xDAC_H)
     begin
       if CHAN_CNT = 0 then
         DAT <= xDAC_A;
       elsif CHAN_CNT = 1 then
         DAT <= xDAC_B;
       elsif CHAN_CNT = 2 then
         DAT <= xDAC_C;
       elsif CHAN_CNT = 3 then
         DAT <= xDAC_D;  
       elsif CHAN_CNT = 4 then
         DAT <= xDAC_E;
       elsif CHAN_CNT = 5 then
         DAT <= xDAC_F;
       elsif CHAN_CNT = 6 then
         DAT <= xDAC_G;
       elsif CHAN_CNT = 7 then
         DAT <= xDAC_H;
       end if;
     end process;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
    process(xCLK, xUPDATE, CHAN_CNT)
      variable i : integer range 63 downto -2;
    begin 
      if falling_edge(xCLK) then         
-------------------------------------------------------------------------------
        case STATE is
-------------------------------------------------------------------------------          
          when IDLE  =>                 --idle, DACs not updating
            LOAD <= '1';
            SERIAL_DATOUT <= '1';
            i := 63;
            CHAN_CNT <= "000";
            if xUPDATE = '0' then       --UPDATE ->0, then start dat transfer
              STATE <= DATA_XFER;
              --LOAD <= '0';
            end if;
-------------------------------------------------------------------------------
          when DATA_XFER =>             -- transfer data to DACs
            LOAD <= '0';
            SERIAL_DATOUT <= DAT(i); 
            i := i - 1;
            if i = -1 then
              i := 4;
              --LOAD <= '1';
              CHAN_CNT <= CHAN_CNT + 1;
              STATE <= WAIT4XFER;
            end if;
-------------------------------------------------------------------------------
          when WAIT4XFER =>               -- waiting period between transfers
            SERIAL_DATOUT <= '1';
            LOAD <= '1';
            i := i - 1;
            if CHAN_CNT = 0 then        -- done loading? 
              --if xUPDATE = '1' then
                STATE <= IDLE;          -- if so, go to idle state
              --end if;
            elsif i = 0 then            -- if not, go back to DATA_XFER
              i := 63;
              STATE <= DATA_XFER;
            end if;
-------------------------------------------------------------------------------
          when others =>
            STATE <= IDLE;
-------------------------------------------------------------------------------            
        end case;
       end if;
    end process;
     
end Behavioral;

