library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_cycle is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
           restart : in std_logic;
           cycle3_ncycle2 : in std_logic;
           id : in std_logic_vector(7 downto 0);
			  addr_reg : in std_logic_vector(7 downto 0);
			  data : in std_logic_vector(7 downto 0);
			  block_done : in std_logic_vector(2 downto 0);
			  done : out std_logic;
			  data_to_send	: out std_logic_vector(7 downto 0);
			  restart_block : out std_logic_vector(2 downto 0);
			  sel_block : out std_logic_vector(1 downto 0));
end write_cycle;

architecture Behavioral of write_cycle is

type enum is (idle, start, phase1, phase2, phase3, stop, idle_end);

signal st,st_nxt : enum;
signal restart_block_nxt : std_logic_vector(2 downto 0);
signal done_nxt : std_logic;
signal data_to_send_nxt : std_logic_vector(7 downto 0);
signal sel_block_nxt : std_logic_vector(1 downto 0);

begin

comb: Process (st, id, addr_reg, cycle3_ncycle2, data, block_done, restart)
begin

case st is
	when idle =>
		data_to_send_nxt <= (others => '0');
		restart_block_nxt <= "001";
		sel_block_nxt <= "01";
		done_nxt <= '0';
		st_nxt <= start;

	when start =>
		done_nxt <= '0';
		if block_done = "001" then
			data_to_send_nxt <= id;
			restart_block_nxt <= "010";
			sel_block_nxt <= "10";
			st_nxt <= phase1;
		else
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "000";
			sel_block_nxt <= "01";
			st_nxt <= start;
		end if;

	when phase1 =>
		done_nxt <= '0';
		if block_done = "010" then
			data_to_send_nxt <= addr_reg;
			restart_block_nxt <= "010";
			sel_block_nxt <= "10";
			st_nxt <= phase2;
		else
			data_to_send_nxt <= id;
			restart_block_nxt <= "000";
			sel_block_nxt <= "10";
			st_nxt <= phase1;
		end if;

	when phase2 =>
		done_nxt <= '0';
		if block_done = "010" then
			if cycle3_ncycle2 = '1' then
				data_to_send_nxt <= data;
				restart_block_nxt <= "010";
				sel_block_nxt <= "10";
				st_nxt <= phase3;
			else
				data_to_send_nxt <= (others => '0');
				restart_block_nxt <= "100";
				sel_block_nxt <= "11";
				st_nxt <= stop;
			end if;
		else
			data_to_send_nxt <= addr_reg;
			restart_block_nxt <= "000";
			sel_block_nxt <= "10";
			st_nxt <= phase2;
		end if;

	when phase3 =>
		done_nxt <= '0';
		if block_done = "010" then
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "100";
			sel_block_nxt <= "10";
			st_nxt <= stop;
		else
			data_to_send_nxt <= data;
			restart_block_nxt <= "000";
			sel_block_nxt <= "10";
			st_nxt <= phase3;
		end if;

	when stop =>
		if block_done = "100" then
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "000";
			sel_block_nxt <= "00";
			done_nxt <= '1';
			st_nxt <= idle_end;
		else
			data_to_send_nxt <= (others => '0');
			restart_block_nxt <= "000";
			sel_block_nxt <= "11";
			done_nxt <= '0';
			st_nxt <= stop;
		end if;
	when idle_end =>
		data_to_send_nxt <= (others => '0');
		restart_block_nxt <= "000";
		sel_block_nxt <= "00";
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
if rst = '1' then
	data_to_send <= (others => '0');
	restart_block <= "000";
	sel_block <= "00";
	done <= '0';
	st <= idle_end;
elsif rising_edge(fscl) then
	restart_block <= restart_block_nxt;
	sel_block <= sel_block_nxt;
	data_to_send <= data_to_send_nxt;
   st <=st_nxt;
	done <= done_nxt;
end if;
end process sinc;

end Behavioral;
