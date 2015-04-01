library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ram_block3P is
generic(
		dsize : integer := 8;
		asize : integer := 10
		);
	port (
			CLKA  : in  std_ulogic;
      	CLKB  : in  std_ulogic;
			RST	: in  std_ulogic;
      	DOB1  : out std_logic_vector(dsize-1 downto 0);
			DOB2  : out std_logic_vector(dsize-1 downto 0);
      	ADDRA : in  std_logic_vector(asize-1 downto 0);
      	ADDRB1: in  std_logic_vector(asize-1 downto 0);
      	ADDRB2: in  std_logic_vector(asize-1 downto 0);
      	DIA   : in  std_logic_vector(dsize-1 downto 0);
      	ENA   : in  std_ulogic;
      	ENB1  : in  std_ulogic;
      	ENB2  : in  std_ulogic;
      	WEA   : in  std_ulogic
		); 

end ram_block3P;

architecture Behavioral of ram_block3P is

	component ram_block2P is
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
	end component;

	signal CLKB_div : std_logic;
	signal ENB : std_logic;
	signal DOB, DOB1_aux, DOB2_aux : std_logic_vector(dsize-1 downto 0);
	signal ADDRB : std_logic_vector(asize-1 downto 0);

begin
	UM0a: ram_block2P
	GENERIC MAP(
		dsize => dsize,
		asize => asize
		)
	PORT MAP(
		DIA     =>DIA,	
		ENA     =>ENA,			
      ENB     =>ENB,
		WEA     =>WEA,				
		CLKA    =>CLKA,	
      CLKB    =>CLKB,
		ADDRA   =>ADDRA,	
      ADDRB   =>ADDRB,
		DOB     =>DOB
	);

	--clock divider
	CLKB_div<='0' when rst='1' else
		not CLKB_div when rising_edge(CLKB) else
		CLKB_div;	
 
	process(CLKB_div, ADDRB1, ADDRB2, ENB1, ENB2)
	begin	
		case CLKB_div is
      	when '0' => ADDRB <= ADDRB1;
							ENB <= ENB1;
			when '1' => ADDRB <= ADDRB2;
							ENB <= ENB2;
			when others => NULL;
		end case;
	end process;
	
	process(CLKB, rst)
	begin
		if (rst='1')then
			DOB1_aux <= (others => '1');
		elsif (CLKB'event and CLKB='0')then
			if(CLKB_div='1')then
				DOB1_aux <= DOB;
			else
				DOB1_aux <= DOB1_aux;
			end if;
		end if;
	end process;

	process(CLKB, rst)
	begin
		if (rst='1')then
			DOB2_aux <= (others => '0');
		elsif (CLKB'event and CLKB='1')then
			if(CLKB_div='0')then
				DOB2_aux <= DOB; 
			else				
				DOB2_aux <= DOB2_aux;
			end if;
		end if;
	end process;
	DOB1 <= DOB1_aux;
	DOB2 <= DOB2_aux;

end Behavioral;
