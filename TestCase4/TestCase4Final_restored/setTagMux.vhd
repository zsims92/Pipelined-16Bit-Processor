LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY setTagMux IS
	PORT(
		address         :IN STD_LOGIC_VECTOR(4 downto 0);
		result			 :OUT STD_LOGIC_VECTOR(5 downto 0);
		reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31 : IN STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END setTagMux;

ARCHITECTURE behavior OF setTagMux IS
BEGIN
	WITH address SELECT
		result <= reg0 WHEN "00000",
					 reg1 WHEN "00001",
					 reg2 WHEN "00010",
					 reg3 WHEN "00011",
					 reg4 WHEN "00100",
					 reg5 WHEN "00101",
					 reg6 WHEN "00110",
					 reg7 WHEN "00111",
					 reg8 WHEN "01000",
					 reg9 WHEN "01001",
					 reg10 WHEN "01010",
					 reg11 WHEN "01011",
					 reg12 WHEN "01100",
					 reg13 WHEN "01101",
					 reg14 WHEN "01110",
					 reg15 WHEN "01111",
					 reg16 WHEN "10000",
					 reg17 WHEN "10001",
					 reg18 WHEN "10010",
					 reg19 WHEN "10011",
					 reg20 WHEN "10100",
					 reg21 WHEN "10101",
					 reg22 WHEN "10110",
					 reg23 WHEN "10111",
					 reg24 WHEN "11000",
					 reg25 WHEN "11001",
					 reg26 WHEN "11010",
					 reg27 WHEN "11011",
					 reg28 WHEN "11100",
					 reg29 WHEN "11101",
					 reg30 WHEN "11110",
					 reg31 WHEN "11111";
END;