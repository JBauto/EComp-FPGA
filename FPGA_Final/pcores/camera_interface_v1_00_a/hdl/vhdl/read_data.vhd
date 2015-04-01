library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_data is
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
			  data_out : out std_logic_vector(7 downto 0 );
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic;
			  sda_read : in std_logic
			  );
end read_data;

architecture Behavioral of read_data is

type enum is ( idle, rd_a, rd_b, rd_c, rd_d, nack_a, nack_b, nack_c, nack_d, nack_e);

signal st,st_nxt : enum;
signal scl_nxt : std_logic;
signal sda_nxt : std_logic;
signal done_nxt : std_logic;
signal cnt : std_logic_vector(2 downto 0);
signal cnt_nxt : std_logic_vector(2 downto 0);
signal en_reg_nxt : std_logic;
signal en_reg : std_logic;
signal p_data_out : std_logic_vector(7 downto 0);

begin

comb: Process (st, cnt, restart)
begin
	case st is
		when idle =>
			-- update programming signals
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			if restart='1' then
				st_nxt <= rd_a;
			else
				st_nxt <= idle;
			end if;
		when rd_a =>
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= rd_b;
		when rd_b =>
			scl_nxt <= '1';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			en_reg_nxt <= '1';
			cnt_nxt <= cnt;
			st_nxt <= rd_c; 
		when rd_c =>
			scl_nxt <= '1';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= rd_d;
		when rd_d =>
			scl_nxt <= '0';
			sda_nxt <= 'Z';
			done_nxt <= '0';
			en_reg_nxt <= '0';	
			if cnt = "000" then
				st_nxt <= nack_a;
				cnt_nxt <= "111";
			else
				st_nxt <= rd_a;
				cnt_nxt <= cnt - 1;
			end if;	   
	-- bit ack
		when nack_a =>
			scl_nxt <= '0';
			sda_nxt <= '1';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= nack_b;       
		when nack_b =>
			scl_nxt <= '1';
			sda_nxt <= '1';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= nack_c;
		when nack_c =>
			scl_nxt <= '1';
			sda_nxt <= '1';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= nack_d;
		when nack_d =>
			scl_nxt <= '0';
			sda_nxt <= '1';
			done_nxt <= '1';
			en_reg_nxt <= '0';
			cnt_nxt <= cnt;
			st_nxt <= nack_e;
		when nack_e => 
			scl_nxt <= '0';
			sda_nxt <= '0';
			done_nxt <= '0';
			en_reg_nxt <= '0';
			cnt_nxt <= "111";
			st_nxt <= idle;
	end case;			
end process comb;

sinc: Process (fscl, rst)
begin
if rst='1' then
	cnt <= "111";	
	st <= idle;
elsif rising_edge(fscl) then
   st <=st_nxt;
	cnt <= cnt_nxt;
end if;
end process sinc;

--registo dos dados recebidos
process (fscl, restart)
begin
	if restart='1' then
		p_data_out <= (others => '0');
   elsif rising_edge(fscl) then
		if en_reg = '1' then
      	p_data_out <= p_data_out(6 downto 0) & sda_read;
		end if;
   end if;
end process;
data_out <= p_data_out;

process(fscl)
begin
	if rising_edge(fscl) then
		scl<=scl_nxt;
		sda<=sda_nxt;
		done<=done_nxt;
		en_reg <= en_reg_nxt;
	end if;
end process;

end Behavioral;
