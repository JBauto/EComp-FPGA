--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package types is

type matrix8 is array(integer range <>) of std_logic_vector(7 downto 0);
 
end types;
