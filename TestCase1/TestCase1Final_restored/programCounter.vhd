LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY programCounter IS
	PORT(
			stall,memMFC,irMFC,clock,reset				:IN STD_LOGIC;
			address			:IN STD_LOGIC_VECTOR(9 downto 0);
			output			:OUT INTEGER RANGE 0 TO 32768
		);
END programCounter;

ARCHITECTURE behavior OF programCounter IS
	
BEGIN
	
	PROCESS(clock, reset, stall, memMFC, irMFC)
	VARIABLE  cycles				:INTEGER RANGE 0 TO 32768;
	BEGIN
		output <= cycles;
		IF(reset =  '1') THEN
			cycles := 0;
		ElSIF(address(5 downto 0) = "111111" OR address(6 downto 0) = "1000000") THEN
		ELSIF(rising_edge(clock)) THEN
			IF(stall /= '0' AND memMFC = '1' and irMFC = '1')THEN
				cycles := cycles + 1;
			END IF;
		END IF;
	END PROCESS;
END behavior;