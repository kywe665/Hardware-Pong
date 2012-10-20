----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:13:35 10/04/2012 
-- Design Name: 
-- Module Name:    paddle_top - Behavioral 
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

entity paddle_top is
	port(
		clk: in std_logic;
		btn: in std_logic_vector(3 downto 0);
		HS_OUT: out std_logic;
		VS_OUT: out std_logic;
		RED_OUT: out std_logic_vector(2 downto 0);
		GREEN_OUT: out std_logic_vector(2 downto 0);
		BLUE_OUT: out std_logic_vector(1 downto 0);
		an: out std_logic_vector(3 downto 0);
		dp: out std_logic;
		seg: out std_logic_vector(6 downto 0)
	);
end paddle_top;

architecture Behavioral of paddle_top is
	signal rst, last_column, last_row, blank: std_logic;
	signal pixel_x, pixel_y: unsigned(9 downto 0);
	signal pixel_xs, pixel_ys: std_logic_vector(9 downto 0);
	signal colors: std_logic_vector(7 downto 0);
	signal border_rgb : std_logic_vector(7 downto 0) := "11100000";
	signal paddleL_rgb : std_logic_vector(7 downto 0) := "00011111"; --yellow
	signal paddleR_rgb : std_logic_vector(7 downto 0) := "00011100"; --green
	signal border_on, paddleL_on, paddleR_on, move_en, box_on : std_logic;
	signal move_up, move_right, discard_cycle : std_logic := '0';
	signal anim_counter : unsigned(16 downto 0) := (others=>'0');
	signal paddleR_top, paddleR_top_next, paddleL_top, paddleL_top_next : unsigned(8 downto 0) := "000001111";
	signal box_top, box_top_next, box_left, box_left_next : unsigned(9 downto 0) := "0000011111";
	signal frame_count : unsigned(15 downto 0) := (others => '0');
	signal q_next, q_reg: unsigned(16 downto 0);
	signal counter_number: std_logic_vector(15 downto 0);
begin
	U1 : entity work.vga_timing
	port map(
		clk => clk,
		rst => rst,
		HS => HS_OUT,
		VS => VS_OUT,
		pixel_x => pixel_xs,
		pixel_y => pixel_ys,
		last_column => last_column,
		last_row => last_row,
		blank => blank
	);
	
	U2: entity work.seven_segment_display
		port map
		(
			clk => clk,
			data_in => counter_number,
			dp_in => "0000",
			blank =>"0000",
			dp => dp,
			an=>an,
			seg=> seg
		);
	process(clk)
	begin
		if (clk'event and clk='1') then
			q_reg <= q_next;
		end if;
	end process;
		
		
	q_next <= q_reg + 1 when last_column ='1' and last_row ='1' else
				q_reg;
	counter_number <= std_logic_vector(q_reg(16 downto 1));
	
	pixel_x <= unsigned(pixel_xs);
	pixel_y <= unsigned(pixel_ys);
	border_rgb <= "11100000";
	paddleL_rgb <= "11111100";
	paddleR_rgb <= "00011100";
	
	
	--draw process
	process(pixel_x, pixel_y, blank, border_on, border_rgb, box_on, paddleR_on, paddleR_rgb, paddleL_on, paddleL_rgb)
	begin
		rst <= '0';
		if blank='0' then
			if (border_on = '1') then
				colors <= border_rgb;
			elsif (paddleR_on = '1') then
				colors <= paddleR_rgb;
			elsif (paddleL_on = '1') then
				colors <= paddleL_rgb;
			elsif (box_on = '1') then
				colors <= "11111111";
			else
				colors <= "00000000";
			end if;
		else
			colors <= "00000000";
		end if;
	end process;
	
	--counter for moving
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if(anim_counter = 80000) then
				move_en <= '1';--move pixel
				anim_counter <= (others => '0');
			else
				anim_counter <= anim_counter + 1;
				move_en <= '0';
			end if;
		end if;
	end process;
	
	--flip flop for moving
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (move_en = '1') then
				paddleL_top <= paddleL_top_next;
				paddleR_top <= paddleR_top_next;
				box_top <= box_top_next;
				box_left <= box_left_next;
				if (box_top_next < 11 or box_top_next+4 > 468) then
					move_up <= not move_up;
				end if;
				if(box_left_next < 11 or box_left_next+4 > 628) then
					move_right <= not move_right;
				end if;
			end if;
		end if;
	end process;
	
	paddleL_top_next <= paddleL_top - 1 when ((btn(3) = '1') and (paddleL_top > 10)) else
							  paddleL_top + 1 when ((btn(2) = '1') and (paddleL_top + 50 < 469)) else
							  paddleL_top;
							  
	paddleR_top_next <= paddleR_top - 1 when ((btn(1) = '1') and (paddleR_top > 10)) else
							  paddleR_top + 1 when ((btn(0) = '1') and (paddleR_top + 50 < 469)) else
							  paddleR_top;
							  
	box_top_next <= box_top + 1 when (move_up = '1') else
						 box_top - 1;
						 
	box_left_next <= box_left + 1 when (move_right = '1') else
						  box_left - 1;
	
	RED_OUT <= colors(7 downto 5);
	GREEN_OUT <= colors(4 downto 2);
	BLUE_OUT <= colors(1 downto 0);
	
	paddleL_on <= '1' when (pixel_x >= 20 and pixel_x < 27) and
								  (pixel_y >= paddleL_top and pixel_y < paddleL_top+50) else
					  '0';
	
	paddleR_on <= '1' when (pixel_x >= 614 and pixel_x < 621) and
								  (pixel_y >= paddleR_top and pixel_y < paddleR_top+50) else
					  '0';
	
	border_on <= '1' when pixel_x < 10 or
								(pixel_x > 629 and pixel_x < 640) or
								pixel_y < 10 or
								(pixel_y > 469 and pixel_y < 480) else
					 '0';
	box_on <= '1' when (pixel_x >= box_left and pixel_x < box_left+5) and
							 (pixel_y >= box_top and pixel_y < box_top+5) else
					  '0';
					 
end Behavioral;



	
