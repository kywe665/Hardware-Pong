----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:05:15 09/27/2012 
-- Design Name: 
-- Module Name:    vga_timing - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_timing is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           pixel_x : out  STD_LOGIC_VECTOR (9 downto 0);
           pixel_y : out  STD_LOGIC_VECTOR (9 downto 0);
           last_column : out  STD_LOGIC;
           last_row : out  STD_LOGIC;
           blank : out  STD_LOGIC);
end vga_timing;

architecture Behavioral of vga_timing is
	signal r_reg: STD_LOGIC := '0';
	signal next_en: std_logic;
	signal h_counter : unsigned (9 downto 0) := "0000000000";
	signal h_counternext : unsigned (9 downto 0) := "0000000000";
	signal v_counter: unsigned (9 downto 0) := "0000000000";
	signal v_counternext : unsigned (9 downto 0) := "0000000000";
begin
	process(clk)
		begin
		if (clk'event and clk = '1') then
			r_reg <= next_en;
		end if;
	end process;
	next_en <= not r_reg;
	process(clk,rst)
		begin
		if (rst='1') then
			h_counter <= (others=>'0');
			v_counter <= (others=>'0');
		elsif (clk'event and clk = '1') then
			if(next_en = '1') then
				h_counter <= h_counternext;
				v_counter <= v_counternext;
			end if;
			end if;
	end process;
	

	
	h_counternext <= (others => '0') when h_counter = 799 else --799
							h_counter + 1; 
								
	last_column <= '1' when h_counter = 639 else --639
						'0';
	v_counternext <= (others => '0') when (v_counter = 520 and h_counter = 799) else --521
								v_counter  + 1 when (h_counter = 799) else
								v_counter ;
	last_row <= '1' when v_counter  = 479 else --479
					'0';
					
	blank <= '1' when (v_counter  > 479) or (h_counter > 639)else --480 or 640
				'0';
	
	HS <= '0' when (h_counter > 655 and h_counter <752) else --96
			'1';
			
	VS <= '0' when (v_counter > 489 and v_counter < 492) else
		   '1';
			
	pixel_x <= std_logic_vector(h_counter);
	pixel_y <= std_logic_vector(v_counter);

end Behavioral;