library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity ram_block2P is
	generic(
		dsize : integer := 32;
		asize : integer := 9
		);
	port (
      	DOB   : out std_logic_vector(dsize-1 downto 0);
      	ADDRA : in  std_logic_vector(asize-1 downto 0);
      	ADDRB : in  std_logic_vector(asize-1 downto 0);
      	CLKA  : in  std_ulogic;
      	CLKB  : in  std_ulogic;
      	DIA   : in  std_logic_vector(dsize-1 downto 0);
      	ENA   : in  std_ulogic;
      	ENB   : in  std_ulogic;
      	WEA   : in  std_ulogic
		); 
end ram_block2P; 
 
architecture Behavioral of ram_block2P is 
 
type ram_type is array (2**asize-1 downto 0) of std_logic_vector (dsize-1 downto 0); 
signal RAM : ram_type; 
signal read_dpra : std_logic_vector(asize-1 downto 0);
 
begin 

process (CLKA)
begin
   if (CLKA'event and CLKA = '1') then
      if (ENA = '1') then
         if (WEA = '1') then
            	RAM(conv_integer(ADDRA)) <= DIA; 
         end if;
      end if;
   end if;
end process;

process (CLKB)
begin
   if (CLKB'event and CLKB = '1') then
      if (ENB = '1') then
         read_dpra <= ADDRB;
      end if;
   end if;
end process;

DOB <= RAM(conv_integer(read_dpra)); 

end Behavioral;
 