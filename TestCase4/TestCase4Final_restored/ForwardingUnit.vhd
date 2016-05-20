library ieee;
use ieee.std_logic_1164.all;

entity ForwardingUnit is
	port(EX_regS, EX_regT, MEM_regD, WB_regD: in std_logic_vector(3 downto 0);
		 MEM_rfwrite, WB_rfwrite: in std_logic;
		 forwardA, forwardB: out std_logic_vector(1 downto 0));
end ForwardingUnit;

architecture arch of ForwardingUnit is


begin
	process(EX_regS, EX_regT, MEM_regD, WB_regD, MEM_rfwrite, WB_rfwrite)
	begin
		-- The following two cases occur when an instruction is in the EX stage, but one or both inputs
		-- are going to be written in the WB stage of the previous stage
		
		-- forward from MEM
		if (MEM_rfwrite = '1' and MEM_regD /= "0000" and MEM_regD = EX_regS) then
			forwardA <= "10";
			
		-- forward from WB
		elsif(WB_rfwrite = '1' and WB_regD /= "0000" and WB_regD = EX_regS) then
			forwardA <= "01";
			
		-- no forwarding
		else
			forwardA <= "00";
		end if;
		
		-- forward from MEM
		if (MEM_rfwrite = '1' and MEM_regD /= "0000" and MEM_regD = EX_regT) then
			forwardB <= "10";
		
		-- forward from WB
		elsif(WB_rfwrite = '1' and WB_regD /= "0000" and WB_regD = EX_regT) then
			forwardB <= "01";

		-- no forwarding
		else
			forwardB <= "00";
		end if;
		
	end process;
end arch;