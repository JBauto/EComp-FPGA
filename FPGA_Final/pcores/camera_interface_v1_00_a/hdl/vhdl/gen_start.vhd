library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gen_start is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end gen_start;

architecture Behavioral of gen_start is

type enum is ( idle, start_a, start_b, start_c, start_d, start_e);

signal st,st_nxt : enum;
signal scl_nxt : std_logic;
signal sda_nxt : std_logic;
signal done_nxt : std_logic;

begin

comb: Process (st, restart)
begin

case st is
	when idle =>
		-- update programming signals
		scl_nxt <= '1';
		sda_nxt <= '1';
		done_nxt <= '0';
		-- udate next state
		if restart='1' then
			st_nxt <= start_a;
		else
			st_nxt <= idle;
		end if;
	when start_a =>
		-- update programming signals
		scl_nxt <= '1';
		sda_nxt <= '1';
		done_nxt <= '0';
		-- udate next state
		st_nxt <= start_b;
	when start_b =>
		-- update programming signals
		scl_nxt <= '1';
		sda_nxt <= '0';
		done_nxt <= '0';
		-- udate next state
		st_nxt <= start_c;
	when start_c =>
		-- update programming signals
		scl_nxt <= '1';
		sda_nxt <= '0';
		done_nxt <= '0';
		-- udate next state
		st_nxt <= start_d;
	when start_d =>
		-- update programming signals
		scl_nxt <= '0';
		sda_nxt <= '0';
		done_nxt <= '1';
		-- udate next state
		st_nxt <= start_e;
	when start_e =>
		-- update programming signals
	   scl_nxt <= '0';
		sda_nxt <= '0';
		done_nxt <= '1';
		-- udate next state
		st_nxt <= idle;
end case;			
end process comb;

sinc: Process (fscl, rst)
begin
	if rst= '1' then
		st <= idle;
	elsif rising_edge(fscl) then
	   st <=st_nxt;
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
