library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- XILINX LIBRARIES
library UNISIM;
use UNISIM.VComponents.all;

-- PERSONAL LIBRARIES
use WORK.types.ALL;

entity ToVGA is
	Port (
		clk	: IN STD_LOGIC;
		reset : IN STD_LOGIC;

		D1in	: IN std_logic_vector(7 downto 0);
		A1in	: OUT STD_LOGIC_VECTOR(12 downto 0);
		EN1i	: OUT STD_LOGIC;

      D2in	: IN STD_LOGIC_VECTOR(7 downto 0);
		A2in	: IN STD_LOGIC_VECTOR(12 downto 0);
		EN2i	: IN STD_LOGIC;
		WE2i	: IN STD_LOGIC;

		Dout	: OUT std_logic_vector(7 downto 0);
		HSYNC	: OUT STD_LOGIC;
		VSYNC	: OUT STD_LOGIC
		);
end ToVGA;

architecture Behavioral of ToVGA is

COMPONENT distram_n
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
	END COMPONENT;

COMPONENT ram_block2p
  GENERIC(
		dsize : integer ;
		asize : integer
		);
	PORT(
		ADDRA : IN std_logic_vector(asize-1 downto 0);
		ADDRB : IN std_logic_vector(asize-1 downto 0);
		CLKA  : IN std_logic;
		CLKB  : IN std_logic;
		DIA   : IN std_logic_vector(dsize-1 downto 0);
		ENA   : IN std_logic;
		ENB   : IN std_logic;
		WEA   : IN std_logic;          
		DOB   : OUT std_logic_vector(dsize-1 downto 0)
		);
	END COMPONENT;

	COMPONENT sync2
	PORT(
		CLK   : IN std_logic;
		RST   : IN std_logic;          
		HS    : OUT std_logic;
		VS    : OUT std_logic;
		h_vect : OUT std_logic_vector(9 downto 0);
		v_vect : OUT std_logic_vector(9 downto 0);
		blank : OUT std_logic
		);
	END COMPONENT;

COMPONENT yuvtorgb
	PORT(
		Y     : IN std_logic_vector(7 downto 0);
		U     : IN std_logic_vector(7 downto 0);
		V     : IN std_logic_vector(7 downto 0);          
		R     : OUT std_logic_vector(7 downto 0);
		G     : OUT std_logic_vector(7 downto 0);
		B     : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	signal Z              : std_logic_vector(7 downto 0);
	signal ADDRB    : std_logic_vector(12 downto 0);
	signal h_vect, v_vect : std_logic_vector(9 downto 0);
	signal blank: std_logic;
	signal clk2   : std_logic;

begin
--------------------------------------------------------------------------------------
-- OUTPUT DATA STORING FOR VISUALIZATION
--------------------------------------------------------------------------------------
UMa: ram_block2P
GENERIC MAP(
		dsize => 4,
		asize => 13
		) 
port map(
		DIA=>D2in(7 downto 4),			
		ENA=>EN2i,		
      ENB=>'1',
		WEA=>WE2i,			
		CLKA=>clk,			
      CLKB=>clk,
		ADDRA=>A2in,			
      ADDRB=>ADDRB,
		DOB=>Z(7 downto 4)
);


UMd: distram_n--ram_block2P
GENERIC MAP(
		dsize => 4,
		asize => 13
		) 
port map(
		DIA=>D2in(3 downto 0),			
		ENA=>EN2i,		
      ENB=>'1',
		WEA=>WE2i,			
		CLKA=>clk,			
      CLKB=>clk,
		ADDRA=>A2in,			
      ADDRB=>ADDRB,
		DOB=>Z(3 downto 0)
);
--------------------------------------------------------------------------------------
-- VGA DISPLAY SIGNALS
--------------------------------------------------------------------------------------
	
	--clock divider
	clk2<='0' when reset='1' else
		not clk2 when rising_edge(clk) else
		clk2;

	U2: sync2 port map(
		clk=>clk2,
		rst=>reset,
		HS=>HSYNC,
		VS=>VSYNC,
		h_vect=>h_vect,
		v_vect=>v_vect,
		blank=>blank
	);

process (h_vect, v_vect, blank, D1in, Z)
begin
	-- input image (or whatever)
	if V_VECT(9 DOWNTO 7)="000" and H_VECT(9 DOWNTO 8)="00" and blank='0' then
		Dout<= D1in;			             -- parte superior
	-- processed image (or any other name)
	elsif V_VECT(9 DOWNTO 7)="010" and H_VECT(9 DOWNTO 8)="00" and blank='0' then
		Dout<=Z;		                       -- parte inferior
	elsif blank='0' then	  
	-- other VISIBLE areas (or make a wild guess)
		Dout<=X"00";                     
	else 
	-- other areas (or make a wild guess)
		Dout<=X"00";
	end if;
end process;

ADDRB	<=  v_vect(6 downto 1) & h_vect(7 downto 1);
A1in <= ADDRB;
EN1i <= '1';

end Behavioral;
