LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY instructionCache IS
	PORT(
			address			:IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			clock				:IN STD_LOGIC;
			reset				:IN STD_LOGIC;
			memMFC			:IN STD_LOGIC;
			cacheHit, loadBlock: OUT STD_LOGIC;
			mfc				:OUT STD_LOGIC;
			cacheHitRatio	:OUT INTEGER RANGE 0 TO 32768;
			blockWordAddress:OUT STD_LOGIC_VECTOR(9 downto 0);
			currDataData	:OUT STD_LOGIC_VECTOR(23 downto 0);
			currTagData    :OUT STD_LOGIC_VECTOR(5 downto 0);
			dataOut			:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			setEnab			:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			curreData		:OUT STD_LOGIC_VECTOR(23 downto 0);
			curreTag			:OUT STD_LOGIC_VECTOR(5 downto 0);
			r0,r1,r2,r3,r4,r5,r6:OUT STD_LOGIC_VECTOR(23 downto 0)
		  );
END instructionCache;

ARCHITECTURE behavior OF instructionCache IS
	SIGNAL hit: std_logic;
	COMPONENT instrDataSets IS
	PORT(
			address					:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			clock						:IN STD_LOGIC;
			reset						:IN STD_LOGIC;
			enable					:IN STD_LOGIC;
			bl							:IN STD_LOGIC;
			Reg0,Reg1,Reg2,Reg3	:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			Reg4,Reg5,Reg6,Reg7	:OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		  );
	END COMPONENT;
	COMPONENT instrTagSets IS
	PORT(
			address					:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data						:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			clock						:IN STD_LOGIC;
			reset						:IN STD_LOGIC;
			enable					:IN STD_LOGIC;
			bl							:IN STD_LOGIC;
			Reg0,Reg1,Reg2,Reg3	:OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			Reg4,Reg5,Reg6,Reg7	:OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		  );
	END COMPONENT;
	COMPONENT decoder2to4 IS
	PORT(
		Sel		:IN std_logic_vector(1 downto 0);
		Output :OUT std_logic_vector(3 downto 0)
	);
	END COMPONENT;
	COMPONENT setDataMux IS
	PORT(
		address         :IN STD_LOGIC_VECTOR(4 downto 0);
		result			 :OUT STD_LOGIC_VECTOR(23 downto 0);
		reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31 : IN STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
	END COMPONENT;
	COMPONENT setTagMux IS
	PORT(
		address         :IN STD_LOGIC_VECTOR(4 downto 0);
		result			 :OUT STD_LOGIC_VECTOR(5 downto 0);
		reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31 : IN STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
	END COMPONENT;
	COMPONENT instrMem IS
	PORT(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
	END COMPONENT;
	SIGNAL data1, data2, data3, data4, currData, currentData : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL tdata1, tdata2, tdata3, tdata5, tagData, currentTag: STD_LOGIC_VECTOR(5 DOWNTO 0); --10 bit address, 2 bits for word, 1 bit for block, 2 bits for set, 5 bits for tag, 1 valid
	SIGNAL setEnable1, setEnable2, setEnable3, setEnable4 : STD_LOGIC;
	SIGNAL reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL treg0, treg1, treg2, treg3, treg4, treg5, treg6, treg7, treg8, treg9, treg10, treg11, treg12, treg13, treg14, treg15 : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL treg16, treg17, treg18, treg19, treg20, treg21, treg22, treg23, treg24, treg25, treg26, treg27, treg28, treg29, treg30, treg31 : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL loadingBlock,bl : STD_LOGIC;
	SIGNAL setLoc, wordLoc : STD_LOGIC_VECTOR(3 downto 0);
	shared variable blockWordNum: integer:= 0;
	SIGNAL addressDet: STD_LOGIC_VECTOR(9 downto 0);
	SIGNAL notCounted 				:STD_LOGIC;
BEGIN
--PortMapping to each set	
	set0: instrDataSets PORT MAP(addressDet(1 downto 0), currData,  clock, reset, setEnable1, address(2), reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
	set1: instrDataSets PORT MAP(addressDet(1 downto 0), currData,  clock, reset, setEnable2, address(2), reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15);
	set2: instrDataSets PORT MAP(addressDet(1 downto 0), currData,  clock, reset, setEnable3, address(2), reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23);
	set3: instrDataSets PORT MAP(addressDet(1 downto 0), currData,  clock, reset, setEnable4, address(2), reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31);
--PortMapping to each words tag/v/d bits
	tset0: instrTagSets PORT MAP(addressDet(1 downto 0), addressDet(9 downto 5) & '1',  clock, reset, setEnable1, address(2), treg0, treg1, treg2, treg3, treg4, treg5, treg6, treg7);
	tset1: instrTagSets PORT MAP(addressDet(1 downto 0), addressDet(9 downto 5) & '1',  clock, reset, setEnable2, address(2), treg8, treg9, treg10, treg11, treg12, treg13, treg14, treg15);
	tset2: instrTagSets PORT MAP(addressDet(1 downto 0), addressDet(9 downto 5) & '1',  clock, reset, setEnable3, address(2), treg16, treg17, treg18, treg19, treg20, treg21, treg22, treg23);
	tset3: instrTagSets PORT MAP(addressDet(1 downto 0), addressDet(9 downto 5) & '1',  clock, reset, setEnable4, address(2), treg24, treg25, treg26, treg27, treg28, treg29, treg30, treg31);
	decodeSet: decoder2to4 PORT MAP(address(4 downto 3), setLoc);
	decodeword: decoder2to4 PORT MAP(address(1 downto 0), wordLoc);
	
	curTag: setTagMux PORT MAP (address(4 downto 0), currentTag, treg0, treg1, treg2, treg3, treg4, treg5, treg6, treg7, treg8, treg9, treg10, treg11, treg12, treg13, treg14, treg15, treg16, treg17, treg18, treg19, treg20, treg21, treg22, treg23, treg24, treg25, treg26, treg27, treg28, treg29, treg30, treg31);
	curData: setDataMux PORT MAP (address(4 downto 0), currentData, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19, reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29, reg30, reg31);
	dataOut <= currentData;
	loadData: instrMem PORT MAP(addressDet, NOT clock, currData);
	setEnable1 <= setLoc(0) AND loadingBlock;
	setEnable2 <= setLoc(1) AND loadingBlock;
	setEnable3 <= setLoc(2) AND loadingBlock;
	setEnable4 <= setLoc(3) AND loadingBlock;
	r0 <= reg0;
	r1 <= reg1;
	r2 <= reg2;
	r3 <= reg3;
	r4 <= reg4;
	r5 <= reg5;
	r6 <= reg6;
	blockWordAddress <= addressDet;
	currTagData <= tagData;
	currDataData <= currData;
	curreData <= currentData;
	curreTag <= currentTag;
	cacheHit <= hit;
	loadBlock <= loadingBlock;
	setEnab <= setEnable1 & setEnable2 & setEnable3 & setEnable4;
	PROCESS(clock, reset)
	BEGIN
		IF(reset = '1')THEN
			hit <= '0';
			mfc <= '0';
		ELSIF(rising_edge(clock)) THEN
			IF(currentTag(5 DOWNTO 1) /= address(9 downto 5) OR currentTag(0) /= '1' OR loadingBlock = '1') THEN
				hit <= '0';
				mfc <= '0';
			ELSE	
				hit <= '1';
				mfc <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(clock, reset, hit)
	BEGIN
		IF(reset = '1')THEN
			blockWordNum := 0;
		ELSIF(falling_edge(clock)) THEN
			IF(hit = '0' AND blockWordNum < 5) THEN
				IF(blockWordNum < 1) THEN
					loadingBlock <= '1';
				ELSE
					loadingBlock <= '1';
				END IF;
			ELSE
				loadingBlock <= '0';
			END IF;
		ELSIF(rising_edge(clock)) THEN
			IF(hit = '0' AND blockWordNum < 5) THEN
				blockWordNum := blockWordNum + 1;
				IF(blockWordNum <= 1)THEN
					addressDet <= address;
				ELSE
					addressDet <= addressDet + "1";
				END IF;
			else
				blockWordNum := 0;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(clock, reset, loadingBlock, hit)
		VARIABLE  counter					:INTEGER RANGE -32768 TO  32767;
		VARIABLE  MISS,HITS				:INTEGER RANGE 0 TO 32768;
	BEGIN
		cacheHitRatio <= counter;
		IF(reset = '1') THEN
			counter := 0;
			MISS := 0;
			HITS := 0;
		ElSIF(address(5 downto 0) = "111111" OR address(6 downto 0) = "1000000") THEN
		ELSIF(rising_edge(clock)) THEN
			IF(loadingBlock = '1' AND notCounted = '1') THEN
				MISS := MISS + 1;
				notCounted <= '0';
			ELSIF(hit = '1' AND loadingBlock = '0' AND memMFC = '1') THEN
				HITS := HITS + 1;
				notCounted <= '1';
			END IF;
			counter := HITS - 1 - MISS;
		END IF;
	END PROCESS;
END behavior;