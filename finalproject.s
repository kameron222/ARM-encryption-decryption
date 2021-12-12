@Kameron Bains
@ Encrypt/Decrypt with xor cipher

@ R0 - line
		line 	.req R0
@ R5 - key
		key	.req R5
@ R4 - input file
		input	.req R4
@ R6 - char
		char 	.req R6
@ R7 - counter
		counter .req R7
@ R9 - output file
		output	.req R9	


	.global main
main:
@ Display my first and last name

	LDR R0, =name
	BL printf

@ Ask the user to encrypt or decrypt

	LDR R0, =question			@ Prompt the user for input
	BL printf

	MOV R7, #3				@ Get input from the user
	MOV R0, #0
	MOV R2, #5
	LDR R1, =choice
	SWI 0

	LDR R0, =choice				@ Convert choice to binary
	BL to_binary	
	MOV R7, R0				@ Put choice in R7

	CMP R7, #1				@ If choice is less than 1, branch to error
	BLT _choiceerror
	CMP R7, #2				@ If choice is greater than 2, branch to error
	BGT _choiceerror
	
@ Ask the user for the key
_key:
	LDR R0, =keyask				@ Prompt the user for the key
	BL printf

	MOV R7, #3				@ Get input from the user
	MOV R0, #0
	MOV R2, #5
	LDR R1, =key
	SWI 0

	LDR R0, =key				@ Convert key to binary
	BL to_binary

	CMP R0, #-1				@ If there was an error in binary function, branch to error
	BEQ _keyerror	
	MOV key, R0				@ Move key into register 5

@ Open the files
_open:

	LDR R0, =pathin				@ Move input file path to R0
	LDR R1, =read				@ Move read identifier to R1
	BL fopen				@ Open input file in read mode
	MOV input, R0				@ Move file pointer to input register
	CMP input, #NULL			@ if (inputfile == null)
	BEQ _openerror				@ Display error

	LDR R0, =pathout			@ Move output file path to R0
	LDR R1, =write				@ Move write identifier to R1
	BL fopen				@ Open the output file in write mode
	MOV output, R0				@ Move file pointer to output register
	CMP output, #NULL			@ if (outputfile == null)
	BEQ _openerror				@ Dispaly error

@ Display encrypt or decrypt line

	CMP R7, #2				@ If (choice == 2)
	BEQ line2				@ Display decrypt line
	
	LDR R0, =encrypt			@ Else print encrypt line
	BL printf		
	BAL _read				@ Branch to read
line2:
	LDR R0, =decrypt			@ Print decrypt line
	BL printf

@ Get line from input file
_read:

@ for line in file
@ while (line != null) {

	LDR line, =line				@ Load line into line register
	LDR R8, =endline			@ Load endline into R8
	SUB R1, R8, line			@ Subtract endline from line and store in R1
	MOV R2, input				@ Move input file pointer to R2
	BL fgets				@ Get line from input file and store in line register
	CMP line, #NULL				@ If (line == terminating byte)	
	BEQ _close				@ Close the files
	MOV counter, #0				@ Reset the byte counter

@ Encrypt/decrypt a character in the line
_do:
@ for char in line
@ do {
	LDRB char, [line,counter]		@ Load a character from line
	CMP char, #10				@ While character is not a newline
	BEQ _print				@ print the newline
	MOV R2, char				@ else move character into R2
	MOV R1, key				@ move key into R1
	BL encrypt_decrypt			@ call encrypt_decypt function

@ Copy the encrypted/decrypted character to the line
_copy:
	STRB R3, [line, R7]			@ Store encrypted/decrypted character back in line
	ADD counter, counter, #1		@ Increment the byte counter
	BAL _do					@ Go back to start of loop

@ } while (char != newline)

@ Print a line and copy it to output file
_print:
	LDR R0, =line				@ Move line to R0
	LDR R1, =return				@ Move format specifier into R1
	BL printf				@ Print the line 
	LDR R0, =line				@ Move line to R0
	MOV R1, output				@ Mov output file to R1
	BL fputs				@ Put the line in the file
	BAL _read				@ Go to top of the loop
@ }	

@ Close the input and output files
_close:
	MOV R0, input				@ Move input file to R0
	BL fclose				@ Close the file
	CMP R0, #NULL				@ if(input file == null) 
	BNE _closeerror				@ display close error
	
	MOV R0, output				@ Move output file to R0
	BL fclose				@ Close the file
	CMP R0, #NULL				@ if (output file == null)
	BNE _closeerror				@ display close error
	BAL _exit				@ exit
		
@ Display an error for if files don't open properly
_openerror:

	LDR R0, =openerror		@ Load up error message
	BL printf			@ Print error message
	BAL _exit			@ Exit the program

@ Display an error for if files don't close properly
_closeerror:

	LDR R0, =closeerror		@ Load up error message
	BL printf			@ Print error message
	BAL _exit			@ Exit the program

@ Display an error for invalid key input
_keyerror:

	LDR R0, =keyerror		@ Load up error message
	BL printf			@ Print error message
	BAL _exit			@ Exit the program

@Display an error for wrong choice input
_choiceerror:
	
	LDR R0, =choiceerror		@ Load up error message
	BL printf			@ Print error message
	BAL _exit			@ Exit the program

@ Exit the program
_exit:
	MOV R7, #1
	SWI 0



	.data

name:		.asciz "Kameron Bains\n"
question:	.asciz "Press 1 to encrypt or 2 to decrypt:\n"
keyask:		.asciz "Key: \n"
choice:		.asciz " "
choiceerror:	.asciz "You didn't choose one of the options!\n"
key: 		.asciz "               \n"
keyerror:	.asciz "The key you entered was not valid!\n"
pathin:		.asciz "input.txt"
pathout:	.asciz "output.txt"
read:		.asciz "r"
write:		.asciz "w"
openerror:	.asciz "Error while opening the file!\n"
closeerror:	.asciz "Error while closing the file!\n"
encrypt:	.asciz "Encrypted string: \n"
decrypt:	.asciz "Decrypted string: \n"
line:		.asciz "                                                      "
return:		.asciz "%s"
newline:	.asciz "\n"

endline:	.byte 0			@ 0 byte to denote end of file

	.equ NULL, 0			@ Null to be equal to 0
