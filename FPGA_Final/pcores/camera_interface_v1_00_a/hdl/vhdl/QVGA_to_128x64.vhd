library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

--use WORK.General_Logic.ALL;

entity QVGA_to_128x64 is
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
end QVGA_to_128x64;

architecture Behavioral of QVGA_to_128x64 is

component Shift_register
	Generic (
		size : integer := 12;
		delay: integer := 1
		);
	Port (
		clk : IN std_logic;
		enb : IN std_logic;
		Di  : IN std_logic_vector(size-1 downto 0);
		Do  : OUT std_logic_vector(size-1 downto 0)
		);
end component;

type matrix  is array(integer range <>) of std_logic_vector(size-1 downto 0);

--constant coef  : matrixs(order-1 downto 0) := (X"07",X"11",X"20",X"2E");
constant a0 : std_logic_vector(7 downto 0) := X"22";
constant a1 : std_logic_vector(7 downto 0) := X"5E";

signal Di2 : std_logic_vector(size-1 downto 0);

signal xn_a1, xn_a0 : matrix(3 downto 0);
signal Yaux, Yaux2, Yaux3 : std_logic_vector(size-1 downto 0);

signal linaux: std_logic_vector(10 downto 0);
signal colaux: std_logic_vector(10 downto 0);

begin

Di2<=Di when rising_edge(clk) else Di2;

-- COMPUTE COLUMN
colaux<=icol(11 downto 1) - conv_std_logic_vector(64,11);--"00000011000";--("111"&X"E8"); -- column=column/4-24d
ocol<=colaux(6 downto 0);
-- COMPUTE LINE
linaux<=ilin(10 downto 0) - conv_std_logic_vector(44,11);--+('1'&X"F2"); -- line=line/4-14d
olin<=linaux(5 downto 0);
-- COMPUTE ENABLE
--en<='1' when colaux(10 downto 6)="0000000" and linaux(10 downto 5)="000000" and ilin(0)='0' and icol(1 downto 0)="00" else '0';
en<='1' when colaux(10 downto 7)="0000" and linaux(10 downto 6)="000" and icol(0)='0' else '0';

-- MULTIPLIER BY a0
process (Di2)
variable aux: std_logic_vector(size+size-1 downto 0);
begin
	aux:=Di2*a0;
	xn_a0(0)<=aux(size+size-1 downto size);
end process;

-- MULTIPLIER BY a1
process (Di2)
variable aux: std_logic_vector(size+size-1 downto 0);
begin
	aux:=Di2*a1;
	xn_a1(0)<=aux(size+size-1 downto size);
end process;

-- SHIFT REGISTER BLOCK FOR a0
u01: Shift_register 
	generic map(size=>size,delay=>2)
	port map(clk=>clk, enb=>'1', Di=>xn_a0(0), Do=>xn_a0(1));
u02: Shift_register 
	generic map(size=>size,delay=>2)
	port map(clk=>clk, enb=>'1', Di=>xn_a0(1), Do=>xn_a0(2));
u03: Shift_register 
	generic map(size=>size,delay=>2)
	port map(clk=>clk, enb=>'1', Di=>xn_a0(2), Do=>xn_a0(3));

-- SHIFT REGISTER BLOCK FOR a1
u11: Shift_register 
	generic map(size=>size,delay=>2)
	port map(clk=>clk, enb=>'1', Di=>xn_a1(0), Do=>xn_a1(1));
u12: Shift_register 
	generic map(size=>size,delay=>2)
	port map(clk=>clk, enb=>'1', Di=>xn_a1(1), Do=>xn_a1(2));

-- COMPUTE Y
process(xn_a0,xn_a1)
variable aux: std_logic_vector(size+1 downto 0);
begin
	aux:=("00"&xn_a0(0))+("00"&xn_a1(1))+("00"&xn_a1(2))+("00"&xn_a0(3));
	if aux(size+1)='1' or aux(size)='1' then
		Yaux<=(others=>'1');
	else
		Yaux<=aux(size-1 downto 0);
	end if;
end process;

-- OUTPUT COMPONENTS
Yaux2<=Yaux when rising_edge(clk) else Yaux2;
Yaux3<=Yaux2 when rising_edge(clk) else Yaux3;
Y<=Yaux3;

end Behavioral;
