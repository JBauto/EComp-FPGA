library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_data is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
			  data_in : in std_logic_vector(7 downto 0 );
			  sda_read : in std_logic; --to read the ack
			  error : out std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end write_data;

architecture Behavioral of write_data is

type enum is ( idle, wr_a, wr_b, wr_c, wr_d, ack_a0, ack_a1, ack_a2, ack_b, ack_c, ack_d);

signal st,st_nxt : enum;
signal scl_nxt : std_logic;
signal sda_nxt : std_logic;
signal done_nxt : std_logic;
signal cnt : std_logic_vector(2 downto 0);
signal cnt_nxt : std_logic_vector(2 downto 0);
signal error_nxt : std_logic;

begin

comb: Process (st, cnt, restart, sda_read)
begin
	case st is
		when idle =>
			-- update programming signals
			scl_nxt <= '0';
			sda_nxt <= '0';
			done_nxt <= '0';
			error_nxt <= '0';
			-- update shift register counter
			cnt_nxt <= cnt;
			-- update next state
			st_nxt <= wr_a;
			if restart='1' then
				st_nxt <= wr_a;
			else
				st_nxt <= idle; 		
			end if;
		when wr_a =>
			-- update programming signals
			scl_nxt <= '0';
			sda_nxt <= data_in(conv_integer(cnt));
			done_nxt <= '0';
			error_nxt <= '0';
			-- update shift register counter
			cnt_nxt <= cnt;
			-- update next state
			st_nxt <= wr_b;
		when wr_b =>
			-- update programming signals
			scl_nxt <= '1';
			sda_nxt <= data_in(conv_integer(cnt));
			done_nxt <= '0';
			error_nxt <= '0';
			-- update shift register counter
			cnt_nxt <= cnt;
			-- update next state
			st_nxt <= wr_c; 
		when wr_c =>
			-- update programming signals
			scl_nxt <= '1';
			sda_nxt <= data_in(conv_integer(cnt));
			done_nxt <= '0';
			error_nxt <= '0';
			-- update shift register counter
			cnt_nxt <= cnt;
			-- update next state
			st_nxt <= wr_d;
		when wr_d =>
			-- update programming signals
			scl_nxt <= '0';
			sda_nxt <= data_in(conv_integer(cnt));
			done_nxt <= '0';
			error_nxt <= '0';				
			-- decide if whole byte has been sent
			if cnt = "000" then
				-- update next state
				st_nxt <= ack_a0;
				-- update shift register counter
				cnt_nxt <= "111";
			else
				-- update next state
				st_nxt <= wr_a;
				-- update shift register counter
				cnt_nxt <= cnt - 1;
			end if;	   
		-- bit ack
		when ack_a0 =>
			scl_nxt <= '0';
			sda_nxt <= '0';
			done_nxt <= '0';
			error_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= ack_a1;       
		when ack_a1 =>
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			error_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= ack_a2;       
		when ack_a2 =>
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			error_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= ack_b;       
		when ack_b =>
			scl_nxt <= '1';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			error_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= ack_c;
		when ack_c =>
			scl_nxt <= '1';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			if sda_read = '0' then
				error_nxt <= '0';
			else
				error_nxt <= '1';
			end if;
			cnt_nxt <= cnt;
			st_nxt <= ack_d;
		when ack_d => 
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '1';
			error_nxt <= '0';
			cnt_nxt <= "111";
			st_nxt <= idle;
	end case;			
end process comb;

sinc: Process (fscl, rst)
begin
if rst = '1' then
	cnt <= "111";
	st <= idle;
elsif rising_edge(fscl) then
   st <=st_nxt;
	cnt <= cnt_nxt;
end if;
end process sinc;

process(fscl)
begin
	if rising_edge(fscl) then
		scl<=scl_nxt;
		sda<=sda_nxt;
		done<=done_nxt;
		error<=error_nxt;
	end if;
end process;

end Behavioral;
	