.text
.global _start
		//The first four instruction are hard coded right now, and would need changed when assembler is done and working.
_start:
			li		r2, 119
			li		r3, 123
			li		r4, 2
			li		r5, 202
			addi	r1, r0, 0
			addi	r12, r0, 0
			mov		r6, 0
			mov		r7, 0
			mov		r8, 0
			mov		r13, 0
			mov		r14, 0
OUTER:		cmp		r6, r2
			beq		r6, r2, FINISHED
MIDDLE:		cmp		r7, r3												
			beq		r7, r3, ZDone													
			add		r1, r4, r6		//r1 is pointing to current pos of A							
			add		r12, r5, r7		//r12 is pointing to current pos of B						
			addi	r8, r0, 0		//Reset counter to zero											
			
INNER:		ldw		r9, 0(r1)		//Load char of string 1															
			ldw		r10, 0(r12)		//Load char of string 2											
			cmp		r9, r10																			
			bne		r9, r10, CONTZ																	
			addi	r8, r8, 1																		
			add		r11, r6, r8		//Check if string 1 is over										
			cmp 	r11, r2																			
			bgt		r11, r2, CONTZ																	
			add		r11, r7, r8		//Check if string 2 is over										
			cmp 	r11, r3																			
			bgt		r11, r3, CONTZ																	
			addi	r1, r1, 1																		
			addi	r12, r12, 1																		
			cmp 	r8, r14																			
			ble		r8, r14, INNER																	
			add		r14, r0, r8																		
			add		r13, r0, r6																
			br 		INNER															
CONTZ:		addi	r7, r7, 1		//Increment Z												
			br		MIDDLE														
ZDONE:		addi	r6, r6, 1		//Increment Y							
			add		r7, r0, r0		//Reset Z										
			br 		OUTER						
FINISHED:   li		r2, 0x1000											
			stw		r13, 0(r2)									
			li		r3, 0x2000									
			stw		r14, 0(r3)							
			
			li		r1, 0xD000			
			li		r9, 0x0100		
			li		r10, 0x0100			
			addi	r2, r14, 0			//Num chars to write							
			addi	r3, r13, STRING1	//Starting address of string				
			addi	r4, r0, 1			//Will store first before loop								
			ldw		r5, 0(r3)			//Load first char											
			addi	r3, r3, 1			//Increase to point to next char						
			stw		r5, 0(r1)			//Store first char on LCD								
LOOP:		cmp		r4, r2																		
			beq		r4, r2, DONE		//While there are more chars							
			ldw		r5, 0(r3)			//Load current char										
			or		r6, r5, r9			//OR with address to form single data						
			stw		r6, 0(r1)			//Store current char at current address						
			addi	r3, r3, 1																		
			addi	r4, r4, 1			//Increase counter											
			add		r9, r9, r10																		
			br LOOP																					
DONE		
			br DONE																					
			
.data		
		sizeA:	.word	119
		sizeB:	.word	123
		.origin 0x2
		STRING1: .word  "TheInternationalSymposiumOnComputerArchitectureIsThePremierForumForNewIdeasAndExperimentalResultsInComputerArchitecture\0"		//Starts at address 2 for testing right now
		.origin 0x202
		STRING2: .word  "HPCAAcronymForInternationalSymposiumOnHighPerformanceComputerArchitectureProvidesAHighQualityForumForScientistsAndEngineers\0"	//Start at address 202 for testing right now