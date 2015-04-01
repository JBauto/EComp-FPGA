library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity camera_interface is port (
	clock			: IN std_logic;
   --control
	c15 			: IN std_logic;
	c14 			: IN std_logic;
	c13 			: IN std_logic;
	c12 			: IN std_logic;
	c11 			: IN std_logic;
	c10 			: IN std_logic;
	c09 			: IN std_logic_vector(7 downto 0);        
	c08 			: OUT std_logic;
	c07 			: OUT std_logic;
	c06 			: OUT std_logic;
	c05				: OUT std_logic;
	c04				: OUT std_logic;
	c03 			: OUT std_logic_vector(7 downto 0);
	c02				: IN std_logic_vector(12 downto 0); 
	c01 			: IN std_logic;
	--FSL interface
	FSL_M_Full 		: IN std_logic;  
	FSL_M_Clk 		: OUT std_logic;
	FSL_M_Write 	: OUT std_logic;
	FSL_M_Data 		: OUT std_logic_vector(0 to 31);
	FSL_M_Control 	: OUT std_logic
   );

end camera_interface;

architecture Behavioral of camera_interface is

	COMPONENT program_regs
	PORT(
		clk         : IN std_logic;
		extern_rst  : IN std_logic;    
		sda         : OUT std_logic;      
		button      : IN std_logic;
		scl         : OUT std_logic;
		cam_rst     : OUT std_logic
		);
	END COMPONENT;

	COMPONENT image_capture
	PORT(
		CLK         : IN std_logic;
		RST         : IN std_logic;
		exclk		: OUT STD_LOGIC;
		pwdn		: OUT STD_LOGIC;
		Yi          : IN std_logic_vector(7 downto 0);
		PXL_CLK     : IN std_logic;
		HREF        : IN std_logic;
		VSYNC       : IN std_logic;
		new_frame   : out std_logic;
    	yo1 		: OUT std_logic_vector(7 downto 0);
		addr1		: IN std_logic_vector(12 downto 0); 
		en1 		: IN std_logic;
		yo2			: OUT std_logic_vector(7 downto 0); 
		addr2		: IN std_logic_vector(12 downto 0); 
		en2 		: IN std_logic 
		);
	END COMPONENT;
	
	signal 	Clk 			: std_logic;
	signal	Reset 			: std_logic;
   --control
	signal 	clkinb 			: std_logic;
	signal 	b_reset 		: std_logic;
	--camera signals
	signal 	cfg_reg 		: std_logic;
	signal 	pxl_clock 		: std_logic;
	signal 	href 			: std_logic;
	signal 	vsync 			: std_logic;
	signal 	yi 				: std_logic_vector(7 downto 0);        
	signal 	SDA 			: std_logic;
	signal 	SCL 			: std_logic;
	signal 	cam_rst 		: std_logic;
	signal 	pwdn			: std_logic;
	signal 	exclk			: std_logic;
	--captured image
	signal 	yo1 			: std_logic_vector(7 downto 0);
	signal 	addr1			: std_logic_vector(12 downto 0); 
	signal 	en1 			: std_logic;

	attribute buffer_type : string;
	attribute buffer_type of pxl_clock	: signal is "bufg";
	--attribute buffer_type of Clk		: signal is "bufg";

--FSL signals
	signal yo2			: std_logic_vector(7 downto 0); 
	signal addr2		: std_logic_vector(12 downto 0); 
	signal en2 			: std_logic;
	signal new_frame  	: std_logic;

  	type STATE_TYPE is (Idle, WRITE1, WRITE2, WRITE3, WAIT1);
  	signal CS, NS: STATE_TYPE; 

  	SIGNAL ADDRESS          : std_logic_vector(12 downto 0);
  	SIGNAL nxt_ADDRESS      : std_logic_vector(12 downto 0);
	SIGNAL DATAOUT          : std_logic_vector(7 downto 0);
  	SIGNAL nxt_FSL_M_Write  : std_logic;

begin

--I/O assignments
	Clk			<= clock;
	Reset		<= c14;
   --control
	clkinb		<= c15;
	b_reset		<= c14;
	--camera signals
	cfg_reg		<= c13;
	pxl_clock 	<= c12;
	--buf_pxlc2 : BUFG port map (I => c12, O => pxl_clock);
	href 		<= c11;
	vsync 		<= c10;
	yi 			<= c09; 
	
	c08			<= SDA;
	c07			<= SCL;
	c06			<= cam_rst;
	c05			<= pwdn;
	c04			<= exclk;
	--captured image
	c03			<= yo1;
	--c03			<= X"FF";
	
	addr1		<= c02; 
	en1 		<= c01;


--Block used to program the camera registers
U2: program_regs PORT MAP(
		clk         => clkinB,
		button      => cfg_reg,
		sda         => sda,
		scl         => scl,
		extern_rst  => b_reset,
		cam_rst     => cam_rst
	);

--VGA camera image output
U3: image_capture PORT MAP(
		clk         => clkinB,
		rst         => b_reset,
		exclk       =>	exclk,
		pwdn        =>	pwdn, 
		yi          => yi,
		pxl_clk     => pxl_clock,
		href        => href,
		vsync       => vsync,
		new_frame   => new_frame,
		yo1     	=> yo1,
		addr1     	=> addr1,
		en1     	=> en1,
		yo2      	=> yo2,
		addr2     	=> addr2,
		en2     	=> en2
	);

--FSL state machine
	DATAOUT <= yo2;
	addr2	<= ADDRESS;
	en2 <= '1';

   SYNC_PROC: process (Clk, Reset)
    begin
      if (Reset='1') then
        CS            <= Idle;
        FSL_M_Write   <= '0';
        ADDRESS       <= (others => '0');
      elsif (Clk'event and Clk = '1') then
        CS            <= NS;
        ADDRESS       <= nxt_ADDRESS;
        FSL_M_Write   <= nxt_FSL_M_Write;
      end if;
    end process;


    COMB_PROC: process (CS, FSL_M_Full, ADDRESS, New_Frame)
    begin
       NS                 <= CS;   
       nxt_FSL_M_Write    <= '0';
       nxt_ADDRESS        <= ADDRESS;
       case CS is
            when Idle        =>
                nxt_ADDRESS <= (others =>'0');
                if (New_Frame ='1') then
                    NS <= WRITE1;  
                end if;

            when WRITE1 =>
                  if (FSL_M_Full='0') then
                    NS              <= WRITE2;
                  end if;
         
            when WRITE2 =>        
                  NS              <= WRITE3;
                  if (FSL_M_Full='0') then
                    nxt_FSL_M_Write <= '1';
                  end if; 

            when WRITE3 =>
                  NS              <= WRITE1;
                  nxt_ADDRESS     <= ADDRESS + 1;
                  if (ADDRESS = "1111111111111") then
                      NS              <= WAIT1;
                  end if;

            when WAIT1  => 
                if (New_Frame ='0') then
                    NS <= Idle;  
               end if;

            when others         =>
                  NS  <= idle; 
       end case;
    end process; 
    
    FSL_M_Data    <= X"000000" & DATAOUT;
    FSL_M_Control <= '0';
    FSL_M_Clk     <= Clk;    

end Behavioral;
