LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY instrDataBlockRegs IS
	PORT(
			address					:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			clock						:IN STD_LOGIC;
			reset						:IN STD_LOGIC;
			enable					:IN STD_LOGIC;
			Reg0,Reg1,Reg2,Reg3	:OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		  );
END instrDataBlockRegs;

ARCHITECTURE behavior OF instrDataBlockRegs IS
			signal enable1, enable2, enable3, enable4 : std_LOGIC;
			signal decode	: STD_LOGIC_VECTOR(3 downto 0);
			COMPONENT Reg_24 IS
			PORT(
				aclr		: IN STD_LOGIC ;
				clock		: IN STD_LOGIC ;
				data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
				enable		: IN STD_LOGIC ;
				q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
			);
			END COMPONENT;
			COMPONENT decoder2to4 IS
			PORT(
				Sel		:IN std_logic_vector(1 downto 0);
				Output :OUT std_logic_vector(3 downto 0)
			);
			END COMPONENT;
BEGIN
	deco: decoder2to4 PORT MAP (address, decode);
	enable1 <= decode(0) AND enable;
	enable2 <= decode(1) AND enable;
	enable3 <= decode(2) AND enable;
	enable4 <= decode(3) AND enable;
	regA: Reg_24 PORT MAP (reset, clock, Data, enable1, Reg0);
	regB: Reg_24 PORT MAP (reset, clock, Data, enable2, Reg1);
	regC: Reg_24 PORT MAP (reset, clock, Data, enable3, Reg2);
	regD: Reg_24 PORT MAP (reset, clock, Data, enable4, Reg3);	
END behavior;