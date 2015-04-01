library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity distram_n is
	generic(
		dsize : integer := 8;
		asize : integer := 10
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
end distram_n; 
 
architecture Behavioral of distram_n is 

 
type ram_type is array (2**asize-1 downto 0) of std_logic_vector (dsize-1 downto 0); 
signal RAM : ram_type; 
signal read_dpra : std_logic_vector(asize-1 downto 0);

attribute ram_style: string;
attribute ram_style of RAM : signal is "distributed";
 
begin 

process(clka) 
begin 
 	if (clka'event and clka = '1') then
		if ENA = '1' then
			if WEA = '1' then
				RAM(conv_integer(ADDRA)) <= DIA;
			end if;
		end if;
	end if; 
end process; 

process(clkb)
begin
 	if (clkb'event and clkb = '1') then
		if ENB = '1' then
			DOB <= RAM(conv_integer(ADDRB));
		end if;
	end if;
end process;


-- FPGA RAM
 --
-- process (clka) 
-- begin   
-- 	if (clka'event and clka = '1') then  
--	  	if (WEA = '1') then 
--		  	RAM(conv_integer(ADDRA)) <= DIA; 
--		  end if; 
--		 read_dpra <= ADDRB; 
--	  end if; 
-- end process; 

-- DOB <= RAM(conv_integer(read_dpra)); 

end Behavioral;
 