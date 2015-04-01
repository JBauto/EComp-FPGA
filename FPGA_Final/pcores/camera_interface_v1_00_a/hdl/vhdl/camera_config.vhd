library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


use IEEE.NUMERIC_STD.ALL; 

--  Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

-- Personal components
--use WORK.camera_pack.ALL;

entity camera_config is
    Port ( 	clk : in std_logic;
	 		  	reset : in std_logic;	
			  	nw_r : in std_logic;
			  	n2_3 : in std_logic;
				id : in std_logic_vector(7 downto 0);
				addr_reg : in std_logic_vector(7 downto 0);
				data : in std_logic_vector(7 downto 0);
			  	start : in std_logic;
				error_cnt : out std_logic; -- returns '1' if has been an error
				data_out : out std_logic_vector(7 downto 0);
				SDA : out std_logic;
           	SCL : out std_logic;	
				done : out std_logic);
end camera_config;

architecture Behavioral of camera_config is

component gen_start
	Port  ( fscl : in std_logic;
			  rst : in std_logic;
			  restart : in std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end component;

component write_data
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
			  data_in : in std_logic_vector(7 downto 0 );
			  sda_read : in std_logic; --to read the ack
			  error : out std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end  component;

component gen_stop
	Port  ( fscl : in std_logic;
			  rst : in std_logic;
			  restart : in std_logic;
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic);
end component;

component read_data
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
			  restart : in std_logic;
			  data_out : out std_logic_vector(7 downto 0 );
           done : out std_logic;
           scl : out std_logic;
           sda : out std_logic;
			  sda_read : in std_logic
			  );
end component;

component write_cycle
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
end component;

component read_cycle
    Port ( fscl : in std_logic;
	 		  rst : in std_logic;
           restart : in std_logic;
           id : in std_logic_vector(7 downto 0);
			  block_done : in std_logic_vector(3 downto 0);
			  done : out std_logic;
			  data_to_send	: out std_logic_vector(7 downto 0);
			  restart_block : out std_logic_vector(3 downto 0);
			  sel_block : out std_logic_vector(2 downto 0));
end component;

component camera_config
    Port ( 	clk : in std_logic;
	 		  	reset : in std_logic;	
			  	nw_r : in std_logic;
			  	n2_3 : in std_logic;
				id : in std_logic_vector(7 downto 0);
				addr_reg : in std_logic_vector(7 downto 0);
				data : in std_logic_vector(7 downto 0);
			  	start : in std_logic;
				error_cnt : out std_logic;
				data_out : out std_logic_vector(7 downto 0);
				SDA : out std_logic;
				SCL : out std_logic;	
				done : out std_logic);
end component;


constant	BUS_IDLE : std_logic_vector := "11";
constant	BLOCK_IDLE : std_logic_vector := "000";
constant RESTART_IDLE : std_logic_vector := "0000";

signal restart : std_logic_vector(3 downto 0);
signal restart_w : std_logic_vector(2 downto 0);
signal restart_r : std_logic_vector(3 downto 0);
signal block_done : std_logic_vector(3 downto 0);
signal bus_start : std_logic_vector(1 downto 0);
signal bus_stop : std_logic_vector(1 downto 0);
signal bus_write : std_logic_vector(1 downto 0);
signal bus_read : std_logic_vector(1 downto 0);
signal data_to_send : std_logic_vector(7 downto 0);
signal data_to_send_w : std_logic_vector(7 downto 0);
signal data_to_send_r : std_logic_vector(7 downto 0);
signal sel_block : std_logic_vector(2 downto 0);
signal sel_block_w : std_logic_vector(1 downto 0);
signal sel_block_r : std_logic_vector(2 downto 0);
signal bus_out : std_logic_vector(1 downto 0);
signal restart_cycle : std_logic_vector(1 downto 0);
signal cycle_done : std_logic_vector(1 downto 0);
signal sda_int : std_logic;

signal error : std_logic;

begin

gen_start1 : gen_start port map
		  (  fscl => clk,
		  	  rst => reset,
			  restart => restart(0),
           done => block_done(0),
           scl => bus_start(0),
           sda => bus_start(1));

write_data1 : write_data port map
			( fscl => clk,
			  rst => reset,
			  restart => restart(1),
			  data_in => data_to_send,
           done => block_done(1),
			  sda_read => sda_int,
			  error => error,
           scl => bus_write(0),
           sda => bus_write(1));

gen_stop1 : gen_stop port map
			( fscl => clk,
			  rst => reset,
			  restart => restart(2),
           done => block_done(2),
           scl => bus_stop(0),
           sda => bus_stop(1));
 
read_data1 : read_data  port map
			( fscl => clk,
			  rst => reset,
			  restart => restart(3),
			  data_out => data_out,
           done => block_done(3),
           scl => bus_read(0),
           sda => bus_read(1),
			  sda_read => sda_int
			  );
			
write_cycle1 :	write_cycle	port map
     		( fscl => clk,
			  rst => reset,
           restart => restart_cycle(0),
           cycle3_ncycle2 => n2_3,
           id => id,
			  addr_reg => addr_reg,
			  data => data,
			  block_done => block_done(2 downto 0),
			  done => cycle_done(0),
			  data_to_send	=> data_to_send_w,
			  restart_block => restart_w,
			  sel_block => sel_block_w);

read_cycle1 : read_cycle	port map
     		( fscl => clk,
			  rst => reset,
           restart => restart_cycle(1),
           id => id,
			  block_done => block_done,
			  done => cycle_done(1),
			  data_to_send	=> data_to_send_r,
			  restart_block => restart_r,
			  sel_block => sel_block_r);

--mux dos blocos
process (sel_block, bus_start, bus_write, bus_stop, bus_read)
begin
   case sel_block is		
      when "001" => bus_out <= bus_start;
      when "010" => bus_out <= bus_write;
      when "011" => bus_out <= bus_stop;
      when "100" => bus_out <= bus_read;
	   when others => bus_out <= BUS_IDLE;
   end case;
end process;
--fim do mux dos blocos

--mux dos ciclos
process (nw_r, sel_block_w, sel_block_r)
begin
   case nw_r is
      when '0' => sel_block <= '0' & sel_block_w;
      when '1' => sel_block <= sel_block_r;
	   when others => sel_block <= BLOCK_IDLE;
   end case;
end process;
--fim do mux dos ciclos

--mux do restart
process (nw_r, restart_r, restart_w)
begin
   case nw_r is
      when '0' => restart <= '0' & restart_w;
      when '1' => restart <= restart_r;
	   when others => restart <= RESTART_IDLE;
   end case;
end process;
--mux fim do restart

--mux data
process (nw_r, data_to_send_w, data_to_send_r)
begin
   case nw_r is
      when '0' => data_to_send <= data_to_send_w;
      when '1' => data_to_send <= data_to_send_r;
	   when others => data_to_send <= (others => '0');
   end case;
end process;
--mux fim data

--generates error signal
process(clk, start)
begin
	if start='1' then
		error_cnt<='0';
	elsif rising_edge(clk) then
		if error='1' then
			error_cnt<='1';
		end if;
	end if;
end process;


SCL <= bus_out(0);
sda_int <= bus_out(1);

PROCESS(nW_R, start, cycle_done)
BEGIN
	IF nW_R='1' THEN
		restart_cycle(1)<=start;
		restart_cycle(0)<='0';
		done<=cycle_done(1);
	ELSE
		restart_cycle(0)<=start;
		restart_cycle(1)<='0';
		done<=cycle_done(0);
	END IF;
END PROCESS;

sda <= sda_int;

end Behavioral;
