-------------------------------------------------------------------------------
-- system_camera_interface_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library camera_interface_v1_00_a;
use camera_interface_v1_00_a.all;

entity system_camera_interface_0_wrapper is
  port (
    clock : in std_logic;
    c15 : in std_logic;
    c14 : in std_logic;
    c13 : in std_logic;
    c12 : in std_logic;
    c11 : in std_logic;
    c10 : in std_logic;
    c09 : in std_logic_vector(7 downto 0);
    c08 : out std_logic;
    c07 : out std_logic;
    c06 : out std_logic;
    c05 : out std_logic;
    c04 : out std_logic;
    c03 : out std_logic_vector(7 downto 0);
    c02 : in std_logic_vector(12 downto 0);
    c01 : in std_logic;
    FSL_M_Full : in std_logic;
    FSL_M_Clk : out std_logic;
    FSL_M_Write : out std_logic;
    FSL_M_Data : out std_logic_vector(0 to 31);
    FSL_M_Control : out std_logic
  );
end system_camera_interface_0_wrapper;

architecture STRUCTURE of system_camera_interface_0_wrapper is

  component camera_interface is
    port (
      clock : in std_logic;
      c15 : in std_logic;
      c14 : in std_logic;
      c13 : in std_logic;
      c12 : in std_logic;
      c11 : in std_logic;
      c10 : in std_logic;
      c09 : in std_logic_vector(7 downto 0);
      c08 : out std_logic;
      c07 : out std_logic;
      c06 : out std_logic;
      c05 : out std_logic;
      c04 : out std_logic;
      c03 : out std_logic_vector(7 downto 0);
      c02 : in std_logic_vector(12 downto 0);
      c01 : in std_logic;
      FSL_M_Full : in std_logic;
      FSL_M_Clk : out std_logic;
      FSL_M_Write : out std_logic;
      FSL_M_Data : out std_logic_vector(0 to 31);
      FSL_M_Control : out std_logic
    );
  end component;

begin

  camera_interface_0 : camera_interface
    port map (
      clock => clock,
      c15 => c15,
      c14 => c14,
      c13 => c13,
      c12 => c12,
      c11 => c11,
      c10 => c10,
      c09 => c09,
      c08 => c08,
      c07 => c07,
      c06 => c06,
      c05 => c05,
      c04 => c04,
      c03 => c03,
      c02 => c02,
      c01 => c01,
      FSL_M_Full => FSL_M_Full,
      FSL_M_Clk => FSL_M_Clk,
      FSL_M_Write => FSL_M_Write,
      FSL_M_Data => FSL_M_Data,
      FSL_M_Control => FSL_M_Control
    );

end architecture STRUCTURE;

