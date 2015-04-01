-------------------------------------------------------------------------------
-- system_vga_interface_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library VGA_interface_v1_00_a;
use VGA_interface_v1_00_a.all;

entity system_vga_interface_0_wrapper is
  port (
    clock : in std_logic;
    v07 : in std_logic;
    v06 : in std_logic_vector(7 downto 0);
    v05 : out std_logic_vector(12 downto 0);
    v04 : out std_logic;
    v03 : out std_logic_vector(7 downto 0);
    v02 : out std_logic;
    v01 : out std_logic;
    FSL_S_Clk : out std_logic;
    FSL_S_Read : out std_logic;
    FSL_S_Data : in std_logic_vector(0 to 31);
    FSL_S_Control : in std_logic;
    FSL_S_Exists : in std_logic
  );
end system_vga_interface_0_wrapper;

architecture STRUCTURE of system_vga_interface_0_wrapper is

  component vga_interface is
    port (
      clock : in std_logic;
      v07 : in std_logic;
      v06 : in std_logic_vector(7 downto 0);
      v05 : out std_logic_vector(12 downto 0);
      v04 : out std_logic;
      v03 : out std_logic_vector(7 downto 0);
      v02 : out std_logic;
      v01 : out std_logic;
      FSL_S_Clk : out std_logic;
      FSL_S_Read : out std_logic;
      FSL_S_Data : in std_logic_vector(0 to 31);
      FSL_S_Control : in std_logic;
      FSL_S_Exists : in std_logic
    );
  end component;

begin

  VGA_interface_0 : vga_interface
    port map (
      clock => clock,
      v07 => v07,
      v06 => v06,
      v05 => v05,
      v04 => v04,
      v03 => v03,
      v02 => v02,
      v01 => v01,
      FSL_S_Clk => FSL_S_Clk,
      FSL_S_Read => FSL_S_Read,
      FSL_S_Data => FSL_S_Data,
      FSL_S_Control => FSL_S_Control,
      FSL_S_Exists => FSL_S_Exists
    );

end architecture STRUCTURE;

