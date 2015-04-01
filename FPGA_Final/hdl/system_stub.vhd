-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    fpga_0_clk_1_sys_clk_pin : in std_logic;
    fpga_0_rst_1_sys_rst_pin : in std_logic;
    running_leds_GPIO_IO_pin : inout std_logic_vector(0 to 7);
    camera_interface_0_c04_pin : out std_logic;
    camera_interface_0_c05_pin : out std_logic;
    camera_interface_0_c06_pin : out std_logic;
    camera_interface_0_c07_pin : out std_logic;
    camera_interface_0_c08_pin : out std_logic;
    camera_interface_0_c09_pin : in std_logic_vector(7 downto 0);
    camera_interface_0_c11_pin : in std_logic;
    camera_interface_0_c10_pin : in std_logic;
    camera_interface_0_c13_pin : in std_logic;
    camera_interface_0_c12_pin : in std_logic;
    VGA_interface_0_v04_pin : out std_logic;
    VGA_interface_0_v05_pin : out std_logic_vector(12 downto 0);
    VGA_interface_0_v06_pin : in std_logic_vector(7 downto 0);
    camera_interface_0_c14_pin : in std_logic;
    VGA_interface_0_v03_pin : out std_logic_vector(7 downto 0);
    VGA_interface_0_v02_pin : out std_logic;
    VGA_interface_0_v01_pin : out std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      fpga_0_clk_1_sys_clk_pin : in std_logic;
      fpga_0_rst_1_sys_rst_pin : in std_logic;
      running_leds_GPIO_IO_pin : inout std_logic_vector(0 to 7);
      camera_interface_0_c04_pin : out std_logic;
      camera_interface_0_c05_pin : out std_logic;
      camera_interface_0_c06_pin : out std_logic;
      camera_interface_0_c07_pin : out std_logic;
      camera_interface_0_c08_pin : out std_logic;
      camera_interface_0_c09_pin : in std_logic_vector(7 downto 0);
      camera_interface_0_c11_pin : in std_logic;
      camera_interface_0_c10_pin : in std_logic;
      camera_interface_0_c13_pin : in std_logic;
      camera_interface_0_c12_pin : in std_logic;
      VGA_interface_0_v04_pin : out std_logic;
      VGA_interface_0_v05_pin : out std_logic_vector(12 downto 0);
      VGA_interface_0_v06_pin : in std_logic_vector(7 downto 0);
      camera_interface_0_c14_pin : in std_logic;
      VGA_interface_0_v03_pin : out std_logic_vector(7 downto 0);
      VGA_interface_0_v02_pin : out std_logic;
      VGA_interface_0_v01_pin : out std_logic
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      fpga_0_clk_1_sys_clk_pin => fpga_0_clk_1_sys_clk_pin,
      fpga_0_rst_1_sys_rst_pin => fpga_0_rst_1_sys_rst_pin,
      running_leds_GPIO_IO_pin => running_leds_GPIO_IO_pin,
      camera_interface_0_c04_pin => camera_interface_0_c04_pin,
      camera_interface_0_c05_pin => camera_interface_0_c05_pin,
      camera_interface_0_c06_pin => camera_interface_0_c06_pin,
      camera_interface_0_c07_pin => camera_interface_0_c07_pin,
      camera_interface_0_c08_pin => camera_interface_0_c08_pin,
      camera_interface_0_c09_pin => camera_interface_0_c09_pin,
      camera_interface_0_c11_pin => camera_interface_0_c11_pin,
      camera_interface_0_c10_pin => camera_interface_0_c10_pin,
      camera_interface_0_c13_pin => camera_interface_0_c13_pin,
      camera_interface_0_c12_pin => camera_interface_0_c12_pin,
      VGA_interface_0_v04_pin => VGA_interface_0_v04_pin,
      VGA_interface_0_v05_pin => VGA_interface_0_v05_pin,
      VGA_interface_0_v06_pin => VGA_interface_0_v06_pin,
      camera_interface_0_c14_pin => camera_interface_0_c14_pin,
      VGA_interface_0_v03_pin => VGA_interface_0_v03_pin,
      VGA_interface_0_v02_pin => VGA_interface_0_v02_pin,
      VGA_interface_0_v01_pin => VGA_interface_0_v01_pin
    );

end architecture STRUCTURE;

