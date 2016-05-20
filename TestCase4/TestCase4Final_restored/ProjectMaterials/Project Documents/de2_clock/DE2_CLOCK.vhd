LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
-- This code displays time in the DE2's LCD Display
-- Key2  resets time
ENTITY DE2_CLOCK IS
	PORT(reset, clk_50Mhz				: IN	STD_LOGIC;
		 LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
		 LCD_RW						: BUFFER STD_LOGIC;
		 DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		 CHARWRITE				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 ENABLE					: IN STD_LOGIC);
END DE2_CLOCK;

ARCHITECTURE a OF DE2_CLOCK IS
	TYPE STATE_TYPE IS (HOLD, FUNC_SET, DISPLAY_ON, MODE_SET, WRITE_CHAR1,
	WRITE_CHAR2,WRITE_CHAR3,WRITE_CHAR4,WRITE_CHAR5,WRITE_CHAR6,WRITE_CHAR7,
	WRITE_CHAR8, WRITE_CHAR9, WRITE_CHAR10, WRITE_CHAR11,  WRITE_CHAR12,  WRITE_CHAR13, 
	WRITE_CHAR14,  WRITE_CHAR15,  WRITE_CHAR16, SHIFTDOWN, WRITE_CHAR17,  WRITE_CHAR18, 
	WRITE_CHAR19, WRITE_CHAR20, WRITE_CHAR21,  WRITE_CHAR22,  WRITE_CHAR23, 
	WRITE_CHAR24,  WRITE_CHAR25,  WRITE_CHAR26, WRITE_CHAR27,  WRITE_CHAR28, 
	WRITE_CHAR29, WRITE_CHAR30, WRITE_CHAR31,  WRITE_CHAR32, RETURN_HOME, TOGGLE_E, RESET1, RESET2, 
	RESET3, DISPLAY_OFF, DISPLAY_CLEAR);
	SIGNAL state, next_command: STATE_TYPE;
	SIGNAL DATA_BUS_VALUE: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLK_COUNT_400HZ: STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL CLK_COUNT_10HZ: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CHAR1, CHAR2, CHAR3, CHAR4, CHAR5, CHAR6, CHAR7, CHAR8, CHAR9, CHAR10: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CHAR11, CHAR12, CHAR13, CHAR14, CHAR15, CHAR16, CHAR17, CHAR18:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CHAR19, CHAR20, CHAR21, CHAR22, CHAR23, CHAR24, CHAR25, CHAR26:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CHAR27, CHAR28, CHAR29, CHAR30, CHAR31, CHAR32:	STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CLK_400HZ, CLK_10HZ : STD_LOGIC;
BEGIN
	LCD_ON <= '1';
	RESET_LED <= NOT RESET;
-- BIDIRECTIONAL TRI STATE LCD DATA BUS
	DATA_BUS <= DATA_BUS_VALUE WHEN LCD_RW = '0' ELSE "ZZZZZZZZ";

	PROCESS
	BEGIN
	 WAIT UNTIL CLK_50MHZ'EVENT AND CLK_50MHZ = '1';
		IF RESET = '0' THEN
		 CLK_COUNT_400HZ <= X"00000";
		 CLK_400HZ <= '0';
		ELSE
				IF CLK_COUNT_400HZ < X"0F424" THEN 
				 CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1;
				ELSE
		    	 CLK_COUNT_400HZ <= X"00000";
				 CLK_400HZ <= NOT CLK_400HZ;
				END IF;
		END IF;
	END PROCESS;
	PROCESS (CLK_400HZ, reset)
	BEGIN
		IF reset = '0' THEN
			state <= RESET1;
			DATA_BUS_VALUE <= X"38";
			next_command <= RESET2;
			LCD_E <= '1';
			LCD_RS <= '0';
			LCD_RW <= '0';

		ELSIF CLK_400HZ'EVENT AND CLK_400HZ = '1' THEN
-- GENERATE 1/10 SEC CLOCK SIGNAL FOR SECOND COUNT PROCESS
			IF CLK_COUNT_10HZ < 19 THEN
				CLK_COUNT_10HZ <= CLK_COUNT_10HZ + 1;
			ELSE
				CLK_COUNT_10HZ <= X"00";
				CLK_10HZ <= NOT CLK_10HZ;
			END IF;
-- SEND TIME TO LCD			
			CASE state IS
-- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
-- see Hitachi HD44780 family data sheet for LCD command and timing details
				WHEN RESET1 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= TOGGLE_E;
						next_command <= RESET2;
				WHEN RESET2 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= TOGGLE_E;
						next_command <= RESET3;
				WHEN RESET3 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= TOGGLE_E;
						next_command <= FUNC_SET;
-- EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD
				WHEN FUNC_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= TOGGLE_E;
						next_command <= DISPLAY_OFF;
-- Turn off Display and Turn off cursor
				WHEN DISPLAY_OFF =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"0E";
						state <= TOGGLE_E;
						next_command <= DISPLAY_CLEAR;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_CLEAR =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"01";
						state <= TOGGLE_E;
						next_command <= DISPLAY_ON;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_ON =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"0C";
						state <= TOGGLE_E;
						next_command <= MODE_SET;
-- Set write mode to auto increment address and move cursor to the right
				WHEN MODE_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"06";
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR1;
-- Write ASCII hex character in first LCD character location
				WHEN WRITE_CHAR1 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR1;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR2;
-- Write ASCII hex character in second LCD character location
				WHEN WRITE_CHAR2 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR2;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR3;
-- Write ASCII hex character in third LCD character location
				WHEN WRITE_CHAR3 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR3;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR4;
-- Write ASCII hex character in fourth LCD character location
				WHEN WRITE_CHAR4 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR4;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR5;
-- Write ASCII hex character in fifth LCD character location
				WHEN WRITE_CHAR5 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR5;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR6;
-- Write ASCII hex character in sixth LCD character location
				WHEN WRITE_CHAR6 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR6;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR7;
-- Write ASCII hex character in seventh LCD character location
				WHEN WRITE_CHAR7 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR7;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR8;
-- Write ASCII hex character in eighth LCD character location
				WHEN WRITE_CHAR8 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR8;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR9;
				WHEN WRITE_CHAR9 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR9;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR10;
				WHEN WRITE_CHAR10 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR10;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR11;
				WHEN WRITE_CHAR11 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR11;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR12;
				WHEN WRITE_CHAR12 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR12;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR13;
				WHEN WRITE_CHAR13 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR13;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR14;
				WHEN WRITE_CHAR14 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR14;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR15;
				WHEN WRITE_CHAR15 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR15;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR16;
				WHEN WRITE_CHAR16 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR16;
						state <= TOGGLE_E;
						next_command <= SHIFTDOWN;
				WHEN SHIFTDOWN =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"A8";
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR17;
				WHEN WRITE_CHAR17 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR17;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR18;
				WHEN WRITE_CHAR18 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR18;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR19;
				WHEN WRITE_CHAR19 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR19;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR20;
				WHEN WRITE_CHAR20 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR20;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR21;
				WHEN WRITE_CHAR21 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR21;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR22;
				WHEN WRITE_CHAR22 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR22;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR23;
				WHEN WRITE_CHAR23 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR23;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR24;
				WHEN WRITE_CHAR24 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR24;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR25;
				WHEN WRITE_CHAR25 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR25;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR26;
				WHEN WRITE_CHAR26 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR26;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR27;
				WHEN WRITE_CHAR27 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR27;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR28;
				WHEN WRITE_CHAR28 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR28;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR29;
				WHEN WRITE_CHAR29 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR29;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR30;
				WHEN WRITE_CHAR30 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR30;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR31;
				WHEN WRITE_CHAR31 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR31;
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR32;
				WHEN WRITE_CHAR32 =>
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= CHAR32;
						state <= TOGGLE_E;
						next_command <= RETURN_HOME;

-- Return write address to first character postion
				WHEN RETURN_HOME =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW <= '0';
						DATA_BUS_VALUE <= X"80";
						state <= TOGGLE_E;
						next_command <= WRITE_CHAR1;
-- The next two states occur at the end of each command to the LCD
-- Toggle E line - falling edge loads inst/data to LCD controller
				WHEN TOGGLE_E =>
						LCD_E <= '0';
						state <= HOLD;
-- Hold LCD inst/data valid after falling edge of E line				
				WHEN HOLD =>
						state <= next_command;
			END CASE;
		END IF;
	END PROCESS;
	PROCESS (CLK_50MHZ, reset, ENABLE)
	BEGIN
		IF reset = '0' THEN	
			CHAR1 <= X"20";		
			CHAR2 <= X"20";
			CHAR3 <= X"20";
			CHAR4 <= X"20";
			CHAR5 <= X"20";
			CHAR6 <= X"20";
			CHAR7 <= X"20";
			CHAR8 <= X"20";
			CHAR9 <= X"20";
			CHAR10 <= X"20";
			CHAR11 <= X"20";
			CHAR12 <= X"20";
			CHAR13 <= X"20";
			CHAR14 <= X"20";
			CHAR15 <= X"20";
			CHAR16 <= X"20";
			CHAR17 <= X"20";
			CHAR18 <= X"20";
			CHAR19 <= X"20";
			CHAR20 <= X"20";
			CHAR21 <= X"20";
			CHAR22 <= X"20";
			CHAR23 <= X"20";
			CHAR24 <= X"20";
			CHAR25 <= X"20";
			CHAR26 <= X"20";
			CHAR27 <= X"20";
			CHAR28 <= X"20";
			CHAR29 <= X"20";
			CHAR30 <= X"20";
			CHAR31 <= X"20";
			CHAR32 <= X"20";
		ELSIF(rising_edge(CLK_50MHZ)) THEN
			IF(ENABLE = '1')THEN
				IF(CHARWRITE(12 DOWNTO 8) = "00000") THEN
					CHAR1 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00001")THEN
					CHAR2 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00010")THEN
					CHAR3 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00011")THEN
					CHAR4 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00100")THEN
					CHAR5 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00101")THEN
					CHAR6 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00110")THEN
					CHAR7 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "00111")THEN
					CHAR8 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01000")THEN
					CHAR9 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01001")THEN
					CHAR10 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01010")THEN
					CHAR11 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01011")THEN
					CHAR12 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01100")THEN
					CHAR13 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01101")THEN
					CHAR14 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01110")THEN
					CHAR15 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "01111")THEN
					CHAR16 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10000")THEN
					CHAR17 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10001")THEN
					CHAR18 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10010")THEN
					CHAR19 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10011")THEN
					CHAR20 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10100")THEN
					CHAR21 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10101")THEN
					CHAR22 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10110")THEN
					CHAR23 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "10111")THEN
					CHAR24 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11000")THEN
					CHAR25 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11001")THEN
					CHAR26 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11010")THEN
					CHAR27 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11011")THEN
					CHAR28 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11100")THEN
					CHAR29 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11101")THEN
					CHAR30 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11110")THEN
					CHAR31 <= CHARWRITE(7 DOWNTO 0);
				ELSIF(CHARWRITE(12 DOWNTO 8) = "11111")THEN
					CHAR32 <= CHARWRITE(7 DOWNTO 0);
				END IF;
			END IF;
		END IF;
 END PROCESS;
END a;
