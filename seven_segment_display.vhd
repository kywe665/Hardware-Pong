----------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date: 15:44:58 09/13/2012
-- Design Name:
-- Module Name: seven_seg_decode - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_display is
generic(COUNTER_BITS: natural:=16);
Port ( 

clk : in STD_LOGIC;

seg : out STD_LOGIC_VECTOR (6 downto 0);
dp : out STD_LOGIC;
an : out STD_LOGIC_VECTOR (3 downto 0);
data_in: in STD_LOGIC_VECTOR(15 downto 0);
dp_in: in STD_LOGIC_VECTOR(3 downto 0);
blank: in STD_LOGIC_VECTOR(3 downto 0)

);
end seven_segment_display;

architecture Behavioral of seven_segment_display is
signal mux2: STD_LOGIC_VECTOR(3 downto 0);
signal r_reg: unsigned(COUNTER_BITS -1 downto 0):=(others=>'0');
signal r_next: unsigned(COUNTER_BITS -1 downto 0):=(others=>'0');
--signal switch_temp: STD_LOGIC_VECTOR(3 downto 0);
signal counter_2bit: STD_LOGIC_VECTOR(1 downto 0);
begin
	counter_2bit <= r_reg(COUNTER_BITS -1)& r_reg(COUNTER_BITS -2);
	process(clk)
	begin
	--r_reg<=(others=>'0');
	if(clk'event and clk='1') then 
		r_reg<= r_next;
	end if;
	end process;
	r_next <= r_reg +1;
	--q <= std_logic_vector(r_reg);
		--dp <= not(btn(3));
	
	
	--switch_temp <= "1000" when btn(3)='1' else
		--					sw(3 downto 0) when (btn(1)='0' and btn(0)='0') else
			--				sw(7 downto 4) when (btn(1)='0' and btn(0)='1') else
				--			(sw(7 downto 4) xor sw(3 downto 0)) when (btn(1)='1' and btn(0)='0') else
					--		(sw(1 downto 0) & sw(3 downto 2));
	
	with counter_2bit select
		mux2<= data_in(3 downto 0) when "00",
					data_in(7 downto 4) when "01",
					data_in(11 downto 8) when "10",
					data_in(15 downto 12) when others;
					
	with counter_2bit select
		dp <= not dp_in(0) when "00",
			not dp_in(1) when "01",
			not dp_in(2) when "10",
			not dp_in(3) when others;
		
	with mux2 select 
		seg <= "1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0010000" when "1001",
				"0001000" when "1010",
				"0000011" when "1011",
				"1000110" when "1100",
				"0100001" when "1101",
				"0000110" when "1110",
				"0001110" when others;
		
		an(0) <= '0' when (blank(0)='0' and counter_2bit ="00") else
					'1';
		an(1) <= '0' when (blank(1)='0' and counter_2bit ="01") else
					'1';
		an(2) <= '0' when (blank(2)='0' and counter_2bit ="10") else
					'1';
		an(3) <= '0' when (blank(3)='0' and counter_2bit ="11") else
					'1';


end Behavioral;