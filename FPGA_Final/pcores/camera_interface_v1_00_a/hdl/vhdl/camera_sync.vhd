library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity camera_sync is
	Port (
		clk	: IN STD_LOGIC;

		VSYNC : IN STD_LOGIC;
		HREF  : IN STD_LOGIC;
		PXL_CLK: IN STD_LOGIC;

		cLINE	: OUT STD_LOGIC_VECTOR(11 downto 0);
		cCOL	: OUT STD_LOGIC_VECTOR(12 downto 0);
		WEY : OUT STD_LOGIC
		);
end camera_sync;

architecture Behavioral of camera_sync is

SIGNAL line: std_logic_vector(11 downto 0);
SIGNAL column: std_logic_vector(12 downto 0);
SIGNAL PXL_CLK2, PXL_CLK3, HREF2, HREF3, HREF4: std_logic;
signal VSYNC2, VSYNC3 : std_logic;

signal WE : std_logic;

begin

----------------------------------------------------
-- LINE UPDATE
----------------------------------------------------
process(clk)
begin
	if rising_edge(clk) then
		if VSYNC2='1' and VSYNC3='1' then
			line<="000000000000";
		elsif HREF2='0' and HREF3='1' and HREF4='1' then
--			if line/="1111111111" then
				line<=line+1;
--			end if;
		end if;
	end if;
end process;

VSYNC2<=VSYNC  when rising_edge(clk) else VSYNC2;
VSYNC3<=VSYNC2 when rising_edge(clk) else VSYNC3;

HREF2<=HREF  when rising_edge(clk) else HREF2;
HREF3<=HREF2 when rising_edge(clk) else HREF3;
HREF4<=HREF3 when rising_edge(clk) else HREF4;

----------------------------------------------------
-- COLUMN UPDATE
----------------------------------------------------
process(clk)
begin
	if rising_edge(clk) then
		if HREF2='0' then
			column<="0000000000000";
		elsif PXL_CLK2='1' and PXL_CLK3='0' then
--			if column/="11111111111" then
				column<=column+1;
--			end if;
		end if;
	end if;
end process;
PXL_CLK2<=PXL_CLK  when rising_edge(clk) else PXL_CLK2;
PXL_CLK3<=PXL_CLK2 when rising_edge(clk) else PXL_CLK3;

----------------------------------------------------
-- OUTPUT DATA
----------------------------------------------------
cLINE<=line;--(9 downto 0) when line(11 downto 10)="00" else "1111111111";
cCOL<=column;--(10 downto 1) when column(12 downto 11)="00" else "1111111111";

process(clk)
begin
	if rising_edge(clk) then
		if VSYNC='0' and HREF2='1' and PXL_CLK2='0' and PXL_CLK3='1' then
			WE<='1';
		else
			WE<='0';
		end if;
	end if;
end process;

WEY <= WE;-- and (not column(0));

end Behavioral;
