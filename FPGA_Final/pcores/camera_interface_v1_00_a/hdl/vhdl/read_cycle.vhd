library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_cycle is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
           restart : in std_logic;
           id : in std_logic_vector(7 downto 0);
			  block_done : in std_logic_vector(3 downto 0);
			  done : out std_logic;
			  data_to_send	: out std_logic_vector(7 downto 0);
			  restart_block : out std_logic_vector(3 downto 0);
			  sel_block : out std_logic_vector(2 downto 0));
end read_cycle;

architecture Behavioral of read_cycle is

type enum is (idle, start, phase1, phase2, stop, idle_end);

signal st,st_nxt : enum;
signal sel_block_nxt : std_logic_vector(2 downto 0);
signal done_nxt : std_logic;
signal data_to_send_nxt : std_logic_vector(7 downto 0);
signal restart_block_nxt : std_logic_vector(3 downto 0);

begin

comb: Process (st, block_done, id, restart)
begin


case st is
	when idle =>
		data_to_send_nxt <= (others => '0');
		restart_block_nxt <= "0001";
		sel_block_nxt <= "001";
		done_nxt <= '0';
		st_nxt <= start;
	when start =>
		done_nxt <= '0';
		if block_done = "0001" then
			data_to_send_nxt <= id;
			restart_block_nxt <= "0010";
			sel_block_nxt <= "010";
			st_nxt <= phase1;
		else
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "0000";
			sel_block_nxt <= "001";
			st_nxt <= start;
		end if;
	when phase1 =>
		done_nxt <= '0';
		if block_done = "0010" then
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "1000";
			sel_block_nxt <= "100";
			st_nxt <= phase2;
		else
			data_to_send_nxt <= id;
			restart_block_nxt <= "0000";
			sel_block_nxt <= "010";
			st_nxt <= phase1;
		end if;
	when phase2 =>
		data_to_send_nxt <= (others => '0');
		done_nxt <= '0';
		if block_done = "1000" then
			restart_block_nxt <= "0100";
			sel_block_nxt <= "011";
			st_nxt <= stop;
		else
			restart_block_nxt <= "0000";
			sel_block_nxt <= "100";
			st_nxt <= phase2;
		end if;
	when stop =>
		data_to_send_nxt <= (others => '0');
		if block_done = "0100" then
			restart_block_nxt <= "0000";
			sel_block_nxt <= "000";
			done_nxt <= '1';
			st_nxt <= idle_end;	
		else
			restart_block_nxt <= "0000";
			sel_block_nxt <= "011";
			done_nxt <= '0';
			st_nxt <= stop;
		end if;
	when idle_end =>
		data_to_send_nxt <= (others => '0');
		restart_block_nxt <= "0000";
		sel_block_nxt <= "000";
		done_nxt <= '0';
		if restart='1' then
			st_nxt <= idle;
		else
			st_nxt <= idle_end;
		end if;
end case;			
end process comb;

sinc: Process (fscl, rst)
begin
if rst= '1' then
	data_to_send <= (others => '0');
	restart_block <= "0000";
	sel_block <= "000";
	done <= '0';
	st <= idle_end;
elsif rising_edge(fscl) then
	sel_block <= sel_block_nxt;
	data_to_send <= data_to_send_nxt;
   st <=st_nxt;
	done <= done_nxt;
	restart_block <= restart_block_nxt;
end if;
end process sinc;

end;