library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- XILINX LIBRARIES
library UNISIM;
use UNISIM.VComponents.all;

-- PERSONAL LIBRARIES
use WORK.types.ALL;

entity vga_interface is
	Port (
		clock	        : in std_logic;
		--captured without processing
		v07       		: in std_logic;
		v06        		: in std_logic_vector(7 downto 0);
		v05	    		: out std_logic_vector(12 downto 0);
		v04	    		: out std_logic;
		--VGA signals
		v03             : out std_logic_vector(7 downto 0);
    	v02             : out std_logic;
    	v01             : out std_logic;
		--FSL signals
		FSL_S_Clk       : out std_logic;
    	FSL_S_Read      : out std_logic;
    	FSL_S_Data      : in  std_logic_vector(0 to 31);
    	FSL_S_Control   : in  std_logic;
    	FSL_S_Exists    : in  std_logic
		);
end vga_interface;

architecture Behavioral of vga_interface is

	COMPONENT tovga
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		D1in : IN std_logic_vector(7 downto 0);
		D2in : IN std_logic_vector(7 downto 0);
		A2in : IN std_logic_vector(12 downto 0);
		EN2i : IN std_logic;
		WE2i : IN std_logic;          
		A1in : OUT std_logic_vector(12 downto 0);
		EN1i : OUT std_logic;
		Dout : OUT std_logic_vector(7 downto 0);
		HSYNC : OUT std_logic;
		VSYNC : OUT std_logic
		);
	END COMPONENT;
	
	alias	CLK		: std_logic	is clock;
	alias	RESET	: std_logic	is v07;

	--captured without processing
	alias 	disp_yi1        : std_logic_vector(7 downto 0)	is v06;
	alias 	disp_addr1	    : std_logic_vector(12 downto 0)	is v05;
	alias 	disp_en1	   	: std_logic						is v04;
	--VGA signals
	alias 	yo              : std_logic_vector(7 downto 0)	is v03;
    alias 	hs              : std_logic						is v02;
    alias 	vs              : std_logic						is v01;

  signal disp_yi2        : std_logic_vector(7 downto 0);
  signal disp_addr2	    : std_logic_vector(12 downto 0);
  signal disp_en2	       : std_logic;
  signal disp_we2	       : std_logic;

  type STATE_TYPE is (Idle, READ1, READ2, READ3);
  signal CS, NS: STATE_TYPE; 

  SIGNAL Dout, data_in      : std_logic_vector(7 downto 0);
  SIGNAL addr_A,nxt_addr_A  : STD_LOGIC_VECTOR(12 downto 0);
  SIGNAL nxt_FSL_S_Read     : std_logic;
  SIGNAL write_ram1_en      : std_logic;

begin

	FSL_S_Clk <= CLK;

--FSL transfer state machine
	disp_yi2	<= FSL_S_Data(24 to 31);
	disp_addr2 <= addr_A;
	disp_en2 <= '1';
	disp_we2	<= write_ram1_en;

    SYNC_PROC: process (Clk, Reset)
    begin
      if (Reset='1') then
        CS            <= READ1;
        FSL_S_Read    <= '0';
        addr_A        <= (others => '0');       
      elsif (Clk'event and Clk = '1') then
        CS <= NS;
        addr_A        <= nxt_addr_A;
        FSL_S_Read    <= nxt_FSL_S_Read;          
      end if;
    end process;

     COMB_PROC: process (CS, FSL_S_Exists, addr_A)
      begin
       NS                 <= CS;
       nxt_addr_A         <= addr_A;
       nxt_FSL_S_Read     <= '0';  
       write_ram1_en      <= '0';    
        
       case CS is
            when Idle        =>
                nxt_addr_A  <= (others =>'0');

                if (FSL_S_Exists='1') then
                    NS <= READ1;  
                end if;
	     
            when READ1 =>   
                if (FSL_S_Exists='1') then
                    NS             <= READ2;
                    nxt_FSL_S_Read <= '1';
                    write_ram1_en  <= '1'; 
                 end if;

            when READ2 =>
           
                NS              <= READ3;
                nxt_addr_A      <= addr_A + 1;
           
                if (addr_A = "1111111111111") then
                    NS          <= Idle;
                    nxt_addr_A  <= "0000000000000";
                end if;
                
             when READ3 =>             
                 NS              <= READ1;                               

          when others         =>
                  NS  <= idle; 
       end case;
    end process; 
 
 --Displays in the VGA port   
   U1: tovga PORT MAP(
		clk     => CLK,
		reset   => RESET,
      D1in    => data_in,
		A1in    => disp_addr1,
		EN1i    => disp_en1,
		D2in	  => disp_yi2, 
		A2in    => disp_addr2,
		EN2i    => disp_en2,
		WE2i    => disp_we2,
		Dout    => Dout,
		HSYNC   => hs,
		VSYNC   => vs
	); 
     
	yo        <= Dout;
	data_in <= disp_yi1;

end Behavioral;
