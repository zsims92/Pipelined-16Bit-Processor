LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BranchCounter IS
	PORT(
		mfc, branch, execute, reset, Clock				:IN std_logic;
		address													:IN std_logic_vector(9 downto 0);
		output													:OUT INTEGER RANGE 0 TO 32768
	);
END BranchCounter;

ARCHITECTURE behavior OF BranchCounter IS
BEGIN
	PROCESS(clock, mfc, reset)
	   VARIABLE  counter					:INTEGER RANGE -32768 TO  32767;
		VARIABLE  MISS,HIT				:INTEGER RANGE 0 TO 32768;
	BEGIN
		output <= counter;
		IF(reset = '1') THEN
			counter := 0;
			MISS := 0;
			HIT := 0;
		ElSIF(address(5 downto 0) = "111111" OR address(6 downto 0) = "1000000") THEN
		ELSIF(rising_edge(clock)) THEN
			IF(mfc = '1') THEN
				IF(execute = '1' AND branch = '1') THEN
					MISS := MISS + 1;
				ELSIF(execute = '0' AND branch = '1') THEN
					HIT := HIT + 1;
				END IF;
				counter := HIT - MISS;
			END IF;
		END IF;
	END PROCESS;
END behavior;