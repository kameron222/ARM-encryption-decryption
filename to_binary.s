@to_binary.s
@Convert a ascii number to binary
@ Input:
@ R0 = ascii number
@ Output:
@ R0 = binary number

	.global to_binary
to_binary:
	STMFD SP!,{R4,R5,LR} @Save R4 and R5
			@Push link register onto stack
@ Do
_do:
/*
* Register usage
* R0 = address of ascii characters
* R1 = byte pointer
* R2 = sum of digits
* R3 = 10
* R4 = contains ascii character to convert to binary
* R5 = working register
*/
@ Initialize registers
	MOV R1, #0
	MOV R2, #0
	MOV R3, #10

@Convert ascii to binary
@while character is inbetween 0 and 9
_while:
	LDRB R4, [R0,R1]	@ Get byte at R0+R1
	CMP R4, #10		@ Check for new line
	BEQ _end_while
	CMP R4, #48		@ is less than 0
	BLT _error
	CMP R4, #57		@ is greater than 9
	BGT _error		
	SUB R4,R4,#48		@ convert ascii to binary
	MUL R5, R2, R3		@ Shift decimal one digits over
	MOV R2, R5
	ADD R2, R2, R4
	ADD R1, R1, #1		@ increment byte pointer
	BAL _while
@ while end
_end_while:
	MOV R0, R2		@put the sum into R0 and return it
	BAL _exit
_error:
	MOV R0, #-1		@ put -1 in R0 for error
	
_exit:
	LDMFD SP!, {R4, R5,PC}  @ Restore R4 and R5
				@ Pop the link register from the stack to get back	
