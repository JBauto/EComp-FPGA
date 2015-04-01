library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gen_stop is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end gen_stop;

architecture Behavioral of gen_stop is

type enum is ( idle, stop_a, stop_b, stop_c, stop_d, stop_e);

signal st,st_nxt : enum;
signal scl_nxt : std_logic;
signal sda_nxt : std_logic;
signal done_nxt : std_logic;

begin

comb: Process (st, restart)
begin
	case st is
		when idle =>
			scl_nxt <= '0';
			sda_nxt <= '0';
			done_nxt <= '0';
			if restart='1' then
				st_nxt <= stop_a;
			else
				st_nxt <= idle;
			end if;
		when stop_a =>
			scl_nxt <= '0';
			sda_nxt <= '0';
			done_nxt <= '0';
			st_nxt <= stop_b;
		when stop_b =>
			scl_nxt <= '1';
			sda_nxt <= '0';
			done_nxt <= '0';
			st_nxt <= stop_c;
		when stop_c =>
			scl_nxt <= '1';
			sda_nxt <= '0';
			done_nxt <= '0';
			st_nxt <= stop_d;
		when stop_d =>
			scl_nxt <= '1';
			sda_nxt <= '1';
			done_nxt <= '1';
			st_nxt <= stop_e;
		when stop_e =>
		   scl_nxt <= '1';
			sda_nxt <= '1';
			done_nxt <= '1';
			st_nxt <= idle;
	end case;			
end process comb;

sinc: Process (fscl, rst)
begin
	if rst= '1' then
		st <= idle;
	elsif rising_edge(fscl) then
	   st <= st_nxt;
	end if;
end process sinc;

process(fscl)
begin
	if rising_edge(fscl) then
		scl<=scl_nxt;
		sda<=sda_nxt;
		done<=done_nxt;
	end if;
end process;

end Behavioral;
