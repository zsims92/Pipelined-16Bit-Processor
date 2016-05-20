LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY decoder2to4 IS
	PORT(
		  Sel		:IN std_logic_vector(1 downto 0);
		  Output :OUT std_logic_vector(3 downto 0)
	);
END decoder2to4;

ARCHITECTURE behavior OF decoder2to4 IS
BEGIN
	WITH sel SELECT
		output <= "0001" WHEN "00",
		          "0010" WHEN "01",
					 "0100" when "10",
					 "1000" when "11";
END behavior;