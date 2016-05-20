library ieee;
use ieee.std_logic_1164.all;

-- Control Unit for CSCE 230 Project
-- Fall 201
--
-- Basic idea: set signals based on each stage of instruction execution
--             stage 1 initializes every control signal
--             subsequent stages only change contol signals as needed

entity control_unit_230 is
	port (op_code, cond: in std_logic_vector(3 downto 0);
		  opx: in std_logic_vector(2 downto 0);
		  s, n, z, v, c, mfc, clock, reset: in std_logic;
		  
		  -- datapath control signals
		  alu_op	:out std_logic_vector(2 downto 0);
		  c_select, y_select: out std_logic_vector(1 downto 0);
		  rf_write, b_select, b_inv, flag_enable: out std_logic;
		  
		  -- memory interface control signals
		  extend: out std_logic;
		  ir_enable, ma_select, mem_write, mem_read: out std_logic;
		  
		  -- instruction address control signals
		  pc_select, pc_enable, inc_select: out std_logic;
		  
		  -- other control signals
		  exe, branch, jump, jtype: out std_logic);
		  
		  
end control_unit_230;


architecture control_unit_230_arch of control_unit_230 is
	
	signal wmfc, execute: std_logic;
	shared variable stage: integer:= 0;
	
begin
	
	process (op_code, opx, reset)
	begin

	exe <= execute;
		CASE Cond IS
			WHEN "0000" => execute <= '1';
			WHEN "0001" => execute <= '0';
			WHEN "0010" => execute <= Z;
			WHEN "0011" => execute <= (NOT Z);
			WHEN "0100" => execute <= V;
			WHEN "0101" => execute <= (NOT V);
			WHEN "0110" => execute <= N;
			WHEN "0111" => execute <= (NOT N);
			WHEN "1000" => execute <= C;
			WHEN "1001" => execute <= (NOT C);
			WHEN "1010" => execute <= C AND (NOT Z);
			WHEN "1011" => execute <= (NOT C) OR Z;
			WHEN "1100" => execute <= (NOT Z) AND ((N AND V) OR ((NOT N) AND (NOT V)));
			WHEN "1101" => execute <= (N AND (NOT V)) OR ((NOT Z) AND V);
			WHEN "1110" => execute <= (N AND V) OR ((NOT N) AND (NOT V));
			WHEN "1111" => execute <= Z OR (((N AND (NOT V)) OR ((NOT Z) AND V)));
		END CASE;
	
		if(reset = '1') then
			alu_op <= "000";
			c_select <= "01";
			y_select <= "00";
			rf_write <= '0';
			b_select <= '0';
			b_inv <= '0';
			flag_enable <= '0';
			extend <= '0';
			ir_enable <= '1';
			ma_select <= '0';
			mem_write <= '0';
			mem_read <= '0';
			pc_select <= '1';
			pc_enable <= '1';
			inc_select <= '0';
			branch <= '0';
			jump <= '0';
		end if;
	
		
		
		-- instruction fetch
		if(execute = '1') then
			jtype <= '0';
			-- R-type instructions
			if(op_code(3 downto 2) = "00") then
		
				flag_enable <= s;
				pc_enable <= '1';
				c_select <= "01";
				y_select <= "00";
				b_select <= '0';
				extend <= '0';
				ir_enable <= '1';
				ma_select <= '0';
				mem_write <= '0';
				mem_read <= '0';
				inc_select <= '0';
				branch <= '0';
		
				-- jr instruction
				if(op_code(1 downto 0) = "11") then
					pc_select <= '0';
					alu_op <= "000";
					rf_write <= '0';
					b_inv <= '0';
					jump <= '1';
				elsif(op_code(1 downto 0) = "01") then
					rf_write <= '1';
					pc_select <= '1';
					jump <= '0';
					if(opx = "000") then
						alu_op <= "100";
					elsif(opx = "001") then
						alu_op <= "101";
					end if;
				-- other r-type instructions
				elsif(op_code(1 downto 0) = "00") then
					
					rf_write <= '1';
					pc_select <= '1';
					jump <= '0';
					
					-- add instruction
					if(opx = "010") then
						alu_op <= "011";
						b_inv <= '0';
					
					-- sub instruction
					elsif(opx = "000") then
						alu_op <= "011";
						b_inv <= '1';
						
					-- and instruction
					elsif(opx = "101") then
						alu_op <= "000";
						b_inv <= '0';
						
					-- or instruction
					elsif(opx = "100") then
						alu_op <= "001";
						b_inv <= '0';
						
					-- xor instruction
					elsif(opx = "001") then
						alu_op <= "010";
						b_inv <= '0';
						
					end if;
				end if;
			
			
			-- D-type instructions
			elsif(op_code(3 downto 2) = "01") then
				
				flag_enable <= s;
				extend <= '1';
				b_select <= '1';
				alu_op <= "011";
				c_select <= "00";
				b_inv <= '0';
				ir_enable <= '1';
				ma_select <= '0';
				pc_select <= '1';
				pc_enable <= '1';
				inc_select <= '0';
				branch <= '0';
				jump <= '0';
				
				-- lw instruction
				if(op_code(1 downto 0) = "00") then
					mem_write <= '0';
					mem_read <= '1';
					rf_write <= '1';
					y_select <= "01";
					extend <= '0';
			
				-- sw instruction
				elsif(op_code(1 downto 0) = "01") then
					mem_write <= '1';
					mem_read <= '0';
					rf_write <= '0';
					y_select <= "01";
					extend <= '0';
			
				-- addi instruction
				elsif(op_code(1 downto 0) = "10") then
					mem_write <= '0';
					mem_read <= '0';
					rf_write <= '1';
					y_select <= "00";
			
				end if;
				
				
			-- B-type instructions
			elsif(op_code(3 downto 2) = "10") then
			
				-- b, bal instructions
					extend <= '1';
					inc_select <= '1';
					pc_enable <= '1';
					pc_select <= '1';
					y_select <= "10";
					c_select <= "10";
					
					alu_op <= "000";
					b_select <= '0';
					b_inv <= '0';
					flag_enable <= '0';
					ir_enable <= '1';
					ma_select <= '0';
					mem_write <= '0';
					mem_read <= '0';
					branch <= '1';
					jump <= '0';
					
					-- b instruction
				if(op_code(1 downto 0) = "00") then
					rf_write <= '0';
					
					-- bal instruction
				elsif(op_code(1 downto 0) = "10") then
					rf_write <= '1';
					
				end if;
		
		
			-- J-type instructions
			elsif(op_code(3 downto 2) = "11") then
				-- Load immediate
				if(op_code(1 downto 0) = "00") then
						flag_enable <= '0';
						pc_enable <= '1';
						c_select <= "11";
						y_select <= "11";
						b_select <= '0';
						extend <= '0';
						ir_enable <= '1';
						ma_select <= '0';
						mem_write <= '0';
						mem_read <= '0';
						inc_select <= '0';
						branch <= '0';
						rf_write <= '1';
						pc_select <= '1';
						jump <= '0';
				end if;
				
			end if; -- instruction check
		else
			if(op_code(3 downto 2) = "11") then
				-- Load immediate
				if(op_code(1 downto 0) = "00") then
						flag_enable <= '0';
						pc_enable <= '1';
						c_select <= "11";
						y_select <= "11";
						b_select <= '0';
						extend <= '0';
						ir_enable <= '1';
						ma_select <= '0';
						mem_write <= '0';
						mem_read <= '0';
						inc_select <= '0';
						branch <= '0';
						rf_write <= '1';
						pc_select <= '1';
						jump <= '0';
						jtype <= '1';
				end if;
			end if;
		end if; -- execute
		
		
	--end if; -- clock cycle
	end process;
end control_unit_230_arch;