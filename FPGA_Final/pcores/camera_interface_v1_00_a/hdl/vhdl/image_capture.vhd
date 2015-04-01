				library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- XILINX LIBRARIES
library UNISIM;
use UNISIM.VComponents.all;

-- PERSONAL LIBRARIES
--use WORK.Retina_model_pack.ALL;
use WORK.types.ALL;
--use WORK.utils_pack.ALL;

entity image_capture is
	Port (
		-- control
		CLK	    : IN STD_LOGIC;
		RST	    : IN STD_LOGIC;

		-- input image
		exclk		 : OUT STD_LOGIC;
		pwdn		 : OUT STD_LOGIC;
		Yi	       : IN STD_LOGIC_VECTOR(7 downto 0);
		PXL_CLK   : IN STD_LOGIC;
		HREF      : IN STD_LOGIC;
		VSYNC     : IN STD_LOGIC;

		--	Display signals
      new_frame : out std_logic;
     	yo1 		 : OUT std_logic_vector(7 downto 0);
		addr1		 : IN std_logic_vector(12 downto 0); 
		en1 		 : IN std_logic;
		yo2		 : OUT std_logic_vector(7 downto 0); 
		addr2		 : IN std_logic_vector(12 downto 0); 
		en2 	 	 : IN std_logic
		);
end image_capture;

architecture Behavioral of image_capture is

component camera_sync
	Port (
		clk	: IN STD_LOGIC;

		VSYNC : IN STD_LOGIC;
		HREF  : IN STD_LOGIC;
		PXL_CLK: IN STD_LOGIC;

		cLINE	: OUT STD_LOGIC_VECTOR(11 downto 0);
		cCOL	: OUT STD_LOGIC_VECTOR(12 downto 0);
		WEY : OUT STD_LOGIC
		);
end component;

component QVGA_to_128x64
	generic (
		size : integer := 8
		);
	Port (
		-- CONTROL SIGNALS
		clk  : IN  std_logic;
		-- INPUT SIGNALS
		Di   : IN  std_logic_vector(size-1 downto 0);
		ilin : IN  std_logic_vector(11 downto 0);
		icol : IN  std_logic_vector(12 downto 0);
		-- OUTPUT SIGNALS
		Y    : OUT std_logic_vector(size-1 downto 0);
		olin : OUT std_logic_vector(5 downto 0);
		ocol : OUT std_logic_vector(6 downto 0);
		en   : OUT std_logic
		);
end component;

component ram_block3P is
	generic(
		dsize : integer := 8;
		asize : integer := 13
		);
	port (
			RST	: in  std_ulogic;
      	DOB1   : out std_logic_vector(dsize-1 downto 0);
			DOB2   : out std_logic_vector(dsize-1 downto 0);
      	ADDRA : in  std_logic_vector(asize-1 downto 0);
      	ADDRB1 : in  std_logic_vector(asize-1 downto 0);
			ADDRB2 : in  std_logic_vector(asize-1 downto 0);
      	CLKA  : in  std_ulogic;
      	CLKB  : in  std_ulogic;
      	DIA   : in  std_logic_vector(dsize-1 downto 0);
      	ENA   : in  std_ulogic;
      	ENB1   : in  std_ulogic;
			ENB2   : in  std_ulogic;
      	WEA   : in  std_ulogic
		); 
	end component;


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

	signal imageY: std_logic_vector(7 downto 0); 

	signal line: std_logic_vector(11 downto 0);
	signal column: std_logic_vector(12 downto 0);

	signal we: std_logic;
	signal ADDRA: std_logic_vector(12 downto 0); 
	signal ENA: std_logic;

--camera clock generation
	constant DIV_CAM : integer:=1;
	signal cnt_cam : integer range 0 to DIV_CAM;
	signal clk_div : std_logic;

begin
	pwdn <= '0';

	--clock divider
	process(clk, rst)
	begin
		if rst='1' then
			clk_div<='0';
		elsif rising_edge(clk) then
			if cnt_cam=DIV_CAM then
				cnt_cam<=0;
				clk_div<=not clk_div;
			else
				cnt_cam<=cnt_cam+1;
			end if;
		end if;
	end process;
	exclk <= clk_div;

----------------------------------------------------------------------------------------
---- CAMERA SYNCHRONIZATION
--------------------------------------------------------------------------------------
	U3: camera_sync port map(
		clk=>clk,
		vsync=>vsync,
		href=>href,
		pxl_clk=>pxl_clk,
		cline=>line,
		ccol=>column,
		wey=>we
	);

--------------------------------------------------------------------------------------
-- CAMERA INPUT DATA PROCESSING
--------------------------------------------------------------------------------------
u_qvgatoarray: QVGA_to_128x64
	generic map(size => 8)
	Port map (
		clk  => pxl_clk,
		Di   => Yi,
		ilin => line,
		icol => column,
		Y    => imageY,
		olin => ADDRA(12 downto 7),
		ocol => ADDRA(6 downto 0),
		en   => ENA
		);

--------------------------------------------------------------------------------------
-- INPUT DATA STORING FOR PROCESSING OR DISPLAY
------------------------------------------------------------------------------------
UM0a: ram_block3P
GENERIC MAP(
		dsize => 8,
		asize => 13
		)
PORT MAP(
		RST	  =>RST,
		DIA     =>ImageY,	
		ENA     =>ENA,			
      ENB1     =>en1,
		ENB2     =>en2,
		WEA     =>we,				
		CLKA    =>CLK,	
      CLKB    =>CLK,
		ADDRA   =>ADDRA,	
      ADDRB1   =>addr1,
		ADDRB2   =>addr2,
		DOB1     =>yo1,
		DOB2     =>yo2
	);

--UM1: ram_block2P
--GENERIC MAP(
--		dsize => 8,
--		asize => 13
--		)
--PORT MAP(
--		DIA=>ImageY,			
--		ENA=>ENA,		
--      ENB=>en1,
--		WEA=>we,			
--		CLKA=>CLK,			
--      CLKB=>CLK,
--		ADDRA=>ADDRA,			
--      ADDRB=>addr1,
--		DOB=>yo1
--	);


--UM2: ram_block2P
--GENERIC MAP(
--		dsize => 8,
--		asize => 13
--		)
--PORT MAP(
--	DIA=>ImageY,			
--		ENA=>ENA,		
--      ENB=>en2,
--		WEA=>we,			
--		CLKA=>CLK,			
--      CLKB=>CLK,
--		ADDRA=>ADDRA,			
--      ADDRB=>addr2,
--		DOB=>yo2
--	);



	new_frame <='1' when ADDRA = "1111111111111" else '0';

end Behavioral;