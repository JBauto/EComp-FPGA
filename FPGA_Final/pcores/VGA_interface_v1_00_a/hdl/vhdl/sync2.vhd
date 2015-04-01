library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SYNC2 is
	Port (
			CLK : IN STD_LOGIC;
			RST : IN STD_LOGIC;

			HS  : OUT STD_LOGIC;
			VS  : OUT STD_LOGIC;

			h_vect : OUT STD_LOGIC_VECTOR(9 downto 0);
			v_vect : OUT STD_LOGIC_VECTOR(9 downto 0);

			blank : out std_logic
			);
end SYNC2;

architecture Behavioral of SYNC2 is

signal Pblank : std_logic;
signal hsync, vsync: std_logic;

signal hcnt : std_logic_vector(9 downto 0);
signal vcnt : std_logic_vector(9 downto 0);      

begin

-- OUTPUT
HS<=HSYNC;
VS<=VSYNC;
blank<=pblank;

--contagem de pixels
H_PXL_CNT:process (clk,rst)
begin
	if rst = '1' then
		hcnt <= "0000000000";
	elsif rising_edge(clk) then
		if hcnt < 799 then 			-- numero total de pixels
			hcnt <= hcnt +1;
		else
			hcnt <= "0000000000";
		end if;
	end if;
end process;
h_vect<=hcnt;

--sincronismo horizontal
HSYNC_PULSE:process (rst,hcnt)
begin
	if rst = '1' then
		hsync <= '0';
	elsif (hcnt >= 656 and hcnt <752) then			-- inicio do horiz pulse		
		hsync <= '1';
	else
		hsync <= '0';
   end if;
end process;

--contagem de linhas
V_LINE_CNT:process (clk,rst)
begin
	if rst = '1' then
		vcnt <= "0000000000";
	elsif rising_edge(clk) then
		if hcnt=655 then
			if vcnt < 520 then			-- numero total de linhas
				vcnt <= vcnt +1;
			else
				vcnt <= "0000000000";
			end if;
		end if;
	end if;
end process;
v_vect<=vcnt;

--sincronismo vertival
VSYNC_PULSE:process (vcnt,rst)
begin
	if rst = '1' then
		vsync <= '0';
		elsif (vcnt >=490 and vcnt <492) then			-- inicio do vert pulse
			vsync <= '1';
	   else
			vsync <= '0';
   end if;
end process;


--zona do monitor com cor
Zona_Blank:process (hcnt,vcnt,rst)
begin
	if rst = '1' then
		Pblank <= '1';
	elsif (vcnt >= 0 and vcnt < 480 ) then	
		if (hcnt >= 0 and hcnt < 640 ) then
				Pblank <= '0';
		else
				Pblank <= '1';
		end if;
	else
				Pblank <= '1';
	end if;
end process;

end Behavioral;
