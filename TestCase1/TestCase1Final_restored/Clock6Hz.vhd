
-- Clock6Hz.vhd
-- Orginal clock(50 MHz) divided by 25,000,000 then generate a new clock
-- one new clock cycle = (25,000,000 x 2) / 50.000M sec = 1 sec
-- but want 6 time quicker: 25,000,000/6 = 4,166,667

ENTITY Clock6Hz IS
     PORT ( 
		reset: 	IN BIT;
		fast:	IN BIT;
		slow:	OUT BIT
        );
END Clock6Hz;

ARCHITECTURE a OF Clock6Hz IS
	SIGNAL clockTmp: BIT;
BEGIN
PROCESS (reset, fast)
    VARIABLE cnt : INTEGER RANGE 0 TO 4166667;
BEGIN
    IF (reset = '1') THEN
        clockTmp <= '0';
        cnt := 0;
	ELSIF (fast'EVENT AND fast = '1') THEN
		-- 4166667 for board
		-- 1 for waveforms
		IF (cnt = 1) THEN
           	cnt := 0;
           	clockTmp <= NOT clockTmp;
        ELSE
   			cnt := cnt + 1;
	    END IF;
	END IF;
END PROCESS;

slow <= clockTmp;	
END a;

