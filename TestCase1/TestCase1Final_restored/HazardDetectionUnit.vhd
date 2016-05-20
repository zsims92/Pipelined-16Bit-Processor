library ieee;
use ieee.std_logic_1164.all;

entity HazardDetectionUnit is
	port(EX_regT, ID_regS, ID_regT: in std_logic_vector(3 downto 0);
		 EX_memRead, MEM_branch, MEM_jump, MEMmem_read, clock: in std_logic;
		 PC_write, IF_ID_write, deassert, flush: out std_logic);
end HazardDetectionUnit;

architecture arch of HazardDetectionUnit is

begin
	process(EX_regT, ID_regS, ID_regT, EX_memRead, MEM_branch, MEM_jump, clock)
	begin
	
			if(EX_memRead = '1' and (EX_regT = ID_regS or EX_regT = ID_regT) and MEMmem_read = '0') then
				PC_write <= '0';
				IF_ID_write <= '0';
				deassert <= '1';
				flush <= '0';
		
			-- if jump or branch
			elsif(MEM_branch = '1' or MEM_jump = '1') then
				PC_write <= '1';
				IF_ID_write <= '0';
				deassert <= '0';
				flush <= '1';
		
			-- no stalling or flushing needed
			else
				PC_write <= '1';
				IF_ID_write <= '1';
				deassert <= '0';
				flush <= '0';
			end if;
		
	end process;
end arch;