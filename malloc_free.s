;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				PUSH {r1-r7}			;PUSH MODIFIED REGISTERS
				LDR r0, =__AT_Start		;LOAD START ADDRESS OF ALLOCATION TABLE
				LDR r1, =__DATA_Start	;LOAD ADDRESS OF HEAD OF LINKED LIST
				LDR r2, =NUMBER_OF_AT	;LOAD ALLOCATION TABLE SIZE
				MOVS r3, #0				;INDEX i
malloc_loop		CMP r2, r3				;COMPARE i WITH SIZE
				BEQ malloc_fail			;LINKED LIST IS FULL. JUMP TO malloc_fail
				LDRB r4, [r0,r3]		;LOAD BYTE FROM AT
				MOVS r5, #0				;INDEX j
				MOVS r6, #1				;BIT MASKING REGISTER
shift_loop		CMP r5, #8				;COMPARE j WITH 8
				BEQ shift_loop_end		;COMPLETED BYTE READ
				MOVS r7, r4				;MOVE BYTE TO R7
				ANDS r7, r6				;r7 <- r7 & r6
				CMP r7, #0				;COMPARE r7 WITH 0
				BEQ malloc_success		;FOUND EMPTY PLACE. JUMP TO malloc_success
				LSLS r6, #1				;SHIFT MASKING REGISTER LEFT BY ONE
				ADDS r5, r5, #1			;j = j + 1
				B shift_loop			;JUMP TO COMPARE FOR shift_loop
shift_loop_end	ADDS r3, r3, #1			;i = i + 1
				B malloc_loop			;JUMP TO COMPARE FOR malloc_loop
malloc_fail		MOVS r0, #0				;RETURN 0 SINCE LINKED LIST IS FULL
				B malloc_end			;JUMP TO END
malloc_success	ORRS r4, r6				;FORM BYTE TO STORE TO AT
				STRB r4, [r0, r3]		;STORE BYTE TO AT
				LSLS r3, #3				;i = 8 * i
				ADDS r4, r5, r3			;r4 <- j + 8 * i
				LSLS r4, #3				;r4 <- 8 * r4
				ADDS r1, r1, r4			;r1 <- __DATA_Start + r4. RETURN EMPTY PLACE'S ADDRESS
				MOVS r0, r1				;MOVE ADDRESS TO RETURN REGISTER
malloc_end		POP {r1-r7}				;POP MODIFIED REGISTERS
				BX LR					;RETURN FROM FUNCTION		
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				PUSH {r1-r6}			;PUSH MODIFIED REGISTERS
				LDR r1, =__AT_Start		;LOAD START ADDRESS OF ALLOCATION TABLE
				LDR r2, =__DATA_Start	;LOAD ADDRESS OF HEAD OF LINKED LIST
				SUBS r3, r0, r2			;r3 <- ADDRESS TO DEALLOCATE MINUS __DATA_Start. r3 STORES DIFFERENCE BETWEEN ADDRESS TO DEALLOCATE AND ADDRESS OF HEAD
				LSRS r3, #3				;DIVIDE ADDRESS DIFFERENCE BY 8. r3 STORES DISTANCE IN TERMS OF NODES. E.G. HOW MANY NODES AWAY THE NODE TO BE DEALLOCATED IS FROM HEAD
				MOVS r4, r3				;MOVE DISTANCE TO r4
				; TO FIND THE CORRECT POSITION IN ALLOCATION TABLE
				; DIVIDE DISTANCE BY 32 TO KNOW OFFSET IN TERMS OF WORDS
				; THEN MAKE MODULO OPERATION WITH 32
				; DISTANCE % 32 TO KNOW OFFSET IN TERMS OF BITS
				LSRS r4, #5				;DIVIDE DISTANCE BY 32
				MOVS r5, #32			;MOVE 32 TO r5
modulo_loop		CMP r3, r5				;COMPARE DISTANCE WITH 32
				BCC modulo_loop_end		;IF DISTANCE < 32, BRANCH TO END OF LOOP
				SUBS r3, r3, r5			;DISTANCE = DISTANCE - 32
				B modulo_loop			;WHILE LOOP
modulo_loop_end	LSLS r4,#2;				double left shift for r4
				LDR r6, [r1,r4]			;LOAD WORD FROM __AT_Start WITH OFFSET IN r4
				; CLEAR nth BIT IN WORD
				; WORD &= ~(0x0001 << n)
				; r3 STORES MODULO RESULT (n)
				MOVS r5, #1				;MOVE 1 to r5
				LSLS r5, r3				;SHIFT 1 LEFT BY OFFSET IN r3 AND STORE IN r5
				MVNS r5, r5				;MOVE NOT. r5 <- ~r5
				ANDS r6, r5				;CLEAR THE BIT IN WORD
				STR r6, [r1,r4]			;STORE WORD IN ALLOCATION TABLE WITH OFFSET IN r4
				POP {r1-r6}				;POP MODIFIED REGISTERS
				BX LR					;BRANCH WITH LINK REGISTER
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
