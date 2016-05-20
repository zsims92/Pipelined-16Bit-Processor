LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY instrTagSets IS
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
END instrTagSets;

ARCHITECTURE behavior OF instrTagSets IS
	COMPONENT instrTagBlocks IS
	PORT(
			address					:IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data						:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			clock						:IN STD_LOGIC;
			reset						:IN STD_LOGIC;
			enable					:IN STD_LOGIC;
			Reg0,Reg1,Reg2,Reg3	:OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		  );
	END COMPONENT;
	SIGNAL enableBlock1, enableBlock2: STD_LOGIC;
BEGIN
	enableBlock1 <= enable AND NOT bl;
	enableBlock2 <= enable AND bl;
	block1: instrTagBlocks PORT MAP (address, Data, clock, reset, enableBlock1, REG0, REG1, REG2, REG3);
	block2: instrTagBlocks PORT MAP (address, Data, clock, reset, enableBlock2, REG4, REG5, REG6, REG7);
END behavior;