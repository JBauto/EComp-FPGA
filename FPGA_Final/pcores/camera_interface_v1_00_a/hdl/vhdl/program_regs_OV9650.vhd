library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

-- Personal components
--use WORK.camera_pack.camera_config;

entity program_regs is
	Port (
		clk		: IN std_logic;
		button	: IN std_logic;
		SDA		: OUT std_logic;
		SCL		: OUT std_logic;
		extern_rst : IN std_logic;
		cam_rst	: OUT std_logic
		);
end program_regs;



architecture Behavioral of program_regs is

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


type STATE is (S0,S1,S2,S3,S4);

constant pt_ADD_WRITE : std_logic_VECTOR(7 DOWNTO 0) := X"60";
constant pt_ADD_READ : std_logic_VECTOR(7 DOWNTO 0) := X"61";
constant pt_READ : std_logic := '1';
constant pt_WRITE : std_logic := '0';
constant pt_3cycle : std_logic := '1';
constant pt_2cycle : std_logic := '0';
constant pt_NONE : std_logic_VECTOR(7 DOWNTO 0) := X"00";

signal ID  : std_logic_vector(7 downto 0);
signal iData, oData: std_logic_vector(7 downto 0);
signal Add : std_logic_vector(7 downto 0);
signal restart_cycle, cycle_done, eCycle, eCycle2, eCycle3 : std_logic;
signal n2_3, nW_R : std_logic;
signal program_reset : std_logic;
signal program2, program : std_logic;
signal prog_add, nxt_prog_add : std_logic_vector(7 downto 0);
signal prog_data : std_logic_vector(15 downto 0);

-- CLOCK GENERATION
signal divider : std_logic_vector(7 downto 0);
signal sclk	: std_logic;

-- ERROR VERIFICATION
signal error : std_logic;--this signal is ignored since the SCCB protocol
					--does implement ack

constant pt_PROG_N : std_logic_VECTOR(7 DOWNTO 0) := X"09";

signal cs, ns : STATE;
begin

process(prog_add)
begin
	case prog_add is
-- QQCIF YUV CONFIGURATION
--		when X"00"  => prog_data<=X"04" & X"24"; 
--		when X"01"  => prog_data<=X"0C" & X"04"; 
--		when X"02"  => prog_data<=X"0D" & X"80"; 
--		when X"03"  => prog_data<=X"11" & X"87"; 
--		when X"04"  => prog_data<=X"12" & X"08"; 
--		when X"05"  => prog_data<=X"37" & X"91"; 
--		when X"06"  => prog_data<=X"38" & X"12"; 
--		when X"07"  => prog_data<=X"39" & X"43"; 
--		when others => prog_data<=X"39" & X"43"; 
-- VGA YUV CONFIGURATION
--		when X"00"  => prog_data<=X"04" & X"00"; 
--		when X"01"  => prog_data<=X"0C" & X"04"; 
--		when X"02"  => prog_data<=X"0D" & X"80"; 
--		when X"03"  => prog_data<=X"11" & X"81"; 
--		when X"04"  => prog_data<=X"12" & X"40"; 
--		when X"05"  => prog_data<=X"37" & X"91"; 
--		when X"06"  => prog_data<=X"38" & X"12"; 
--		when X"07"  => prog_data<=X"39" & X"43"; 
--		when others => prog_data<=X"39" & X"43"; 
-- QQVGA YUV CONFIGURATION -> c'est la meme merde chi QVGA
--		when X"00"  => prog_data<=X"04" & X"24"; 
--		when X"01"  => prog_data<=X"0C" & X"04"; 
--		when X"02"  => prog_data<=X"0D" & X"80"; 
--		when X"03"  => prog_data<=X"11" & X"83"; 
--		when X"04"  => prog_data<=X"12" & X"10"; 
--		when X"05"  => prog_data<=X"37" & X"91"; 
--		when X"06"  => prog_data<=X"38" & X"12"; 
--		when X"07"  => prog_data<=X"39" & X"43"; 
--		when others => prog_data<=X"39" & X"43";
-- QVGA YUV CONFIGURATION
		when X"00"  => prog_data<=X"04" & X"00"; 
		when X"01"  => prog_data<=X"0C" & X"04"; 
		when X"02"  => prog_data<=X"0D" & X"80"; 
		when X"03"  => prog_data<=X"11" & X"83"; 
		when X"04"  => prog_data<=X"12" & X"10"; 
		when X"05"  => prog_data<=X"37" & X"91"; 
		when X"06"  => prog_data<=X"38" & X"12"; 
		when X"07"  => prog_data<=X"39" & X"43"; 
		when others => prog_data<=X"39" & X"43";
-- QVGA GRB422 CONFIGURATION
--		when X"00"  => prog_data<=X"04" & X"00"; 
--		when X"01"  => prog_data<=X"0C" & X"04"; 
--		when X"02"  => prog_data<=X"0D" & X"80"; 
--		when X"03"  => prog_data<=X"11" & X"83"; 
--		when X"04"  => prog_data<=X"12" & X"14"; 
--		when X"05"  => prog_data<=X"37" & X"91"; 
--		when X"06"  => prog_data<=X"38" & X"12"; 
--		when X"07"  => prog_data<=X"39" & X"43";
--		when X"08"  => prog_data<=X"40" & X"C0"; 
--		when others => prog_data<=X"39" & X"43";
-- CIF YUV CONFIGURATION
--		when X"00"  => prog_data<=X"04" & X"00"; 
--		when X"01"  => prog_data<=X"0C" & X"04"; 
--		when X"02"  => prog_data<=X"0D" & X"80"; 
--		when X"03"  => prog_data<=X"11" & X"83"; 
--		when X"04"  => prog_data<=X"12" & X"20"; 
--		when X"05"  => prog_data<=X"37" & X"91"; 
--		when X"06"  => prog_data<=X"38" & X"12"; 
--		when X"07"  => prog_data<=X"39" & X"43"; 
--		when others => prog_data<=X"39" & X"43";
	end case;
end process;

process(clk)
begin
	if rising_edge(clk) then 
		cam_rst<=extern_rst; 
	end if;
end process;

program <= button;

U1: camera_config port map(
	clk=>sclk,
	reset=>program_reset,
	nw_r=>nW_R,
	n2_3=>n2_3,
	id=>ID,
	addr_reg=>Add,
	data=>oData,
	start=>restart_cycle,
	error_cnt=>error,
	data_out=>iData,
	SDA=>SDA,
	SCL=>SCL,
	done=>cycle_done
	);
----------------------------------------------------------------------------
-- SLOW CLOCK GENERATION
----------------------------------------------------------------------------
BUFG_SCCB : BUFG
port map (
   O => sclk,     -- Clock buffer output
   I => divider(7)      -- Clock buffer input
);

divider<=(others=>'0') when EXTERN_RST='1' else 
			divider+1 when rising_edge(clk) else divider;

process(clk)
begin
	if rising_edge(clk) then
		case cs is
			-- IDLE STATE
			when S0=>
				-- DEFINE PROGRAMMING SIGNALS
				ID<=PT_NONE;
				Add<=PT_NONE;
				oData<=PT_NONE;
				n2_3<=pt_2CYCLE;
				nW_R<=pt_READ;
				eCycle<='0';
				-- OUTPUT I2C SIGNALS
				ns<=S1;
				-- FIRST STAGE OF PROGRAMMING
				nxt_prog_add<=X"00";
			when S1=>
				-- DEFINE PROGRAMMING SIGNALS
				ID<=PT_ADD_WRITE;
				Add<=prog_data(15 downto 8);
				oData<=prog_data(7 downto 0);
				n2_3<=pt_3CYCLE;
				nW_R<=pt_WRITE;
				-- OUTPUT I2C SIGNALS
				if cycle_done='1' then
					eCycle<='0';
					ns<=S2;
					nxt_prog_add<=prog_add+1;
				else
					eCycle<='1';
					ns<=S1;
					nxt_prog_add<=prog_add;
				end if;
			-- WAIT CYCLE
			when S2=>
				ID<=PT_NONE;
				Add<=PT_NONE;
				oData<=PT_NONE;
				n2_3<=pt_2CYCLE;
				nW_R<=pt_READ;
				if cycle_done='1'	then
					if prog_add=PT_PROG_N then
						ns<=S3;
					else
						ns<=S1;
					end if;
					eCycle<='0';
				else
					ns <= S2;
					eCycle<='1';
				end if;
				nxt_prog_add<=prog_add;
			when others=>
				ID<=PT_NONE;
				Add<=PT_NONE;
				oData<=PT_NONE;
				n2_3<=pt_2CYCLE;
				nW_R<=PT_READ;
				ns<=S3;
				nxt_prog_add<=prog_add;
		end case;
	end if;
end process;

eCycle2<=eCycle when rising_edge(sclk) else eCycle2;
eCycle3<=eCycle2 when rising_edge(sclk) else eCycle3;
restart_cycle<=((not eCycle2) or (not eCycle3)) and eCycle;

program2<=program when rising_edge(clk) else program2;
program_reset<='1' when PROGRAM='1' AND PROGRAM2='0' else '0';

process(sclk, program)
begin
	if program='0' then
		cs<=S0;
		prog_add<=X"00";
	elsif rising_edge(sclk) then
		cs<=ns;
		prog_add<=nxt_prog_add;
	end if;
end process;

end Behavioral;
