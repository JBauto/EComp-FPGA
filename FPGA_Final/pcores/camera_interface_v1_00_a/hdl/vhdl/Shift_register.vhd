library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Shift_register is
	Generic (
		size : integer := 12;
		delay: integer := 1
		);
	Port (
		clk : IN std_logic;
		enb : IN std_logic;
		Di	 : IN std_logic_vector(size-1 downto 0);
		Do  : OUT std_logic_vector(size-1 downto 0)
		);
end Shift_register;

architecture Behavioral of Shift_register is

type matrix is array(integer range <>) of std_logic_vector(size-1 downto 0);

signal shift: matrix(delay downto 0);

begin

shift(0)<=Di;

process(clk)
begin
	if rising_edge(clk) then
		if enb='1' then
			shift(delay downto 1)<=shift(delay-1 downto 0);
		end if;
	end if;
end process;

Do<=shift(delay);
end Behavioral;
