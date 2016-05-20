LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY instrTagBlocks IS
	PORT(
			address					:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data						:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			clock						:IN STD_LOGIC;
			reset						:IN STD_LOGIC;
			enable					:IN STD_LOGIC;
			Reg0,Reg1,Reg2,Reg3	:OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		  );
END instrTagBlocks;

ARCHITECTURE behavior OF instrTagBlocks IS
			signal enable1, enable2, enable3, enable4 : std_LOGIC;
			signal decode	: STD_LOGIC_VECTOR(3 downto 0);
			COMPONENT Reg_5 IS
			PORT(
				data									:IN std_logic_vector(5 downto 0);
				enable, reset, Clock				:IN std_logic;
				output								:OUT std_logic_vector(5 downto 0)
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
	regA: Reg_5 PORT MAP (Data, enable1, reset, clock, Reg0);
	regB: Reg_5 PORT MAP (Data, enable2, reset, clock, Reg1);
	regC: Reg_5 PORT MAP (Data, enable3, reset, clock, Reg2);
	regD: Reg_5 PORT MAP (Data, enable4, reset, clock, Reg3);	
END behavior;