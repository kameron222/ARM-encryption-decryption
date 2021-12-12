@encrypt_decrypt.s
@ encrypt a character using a xor cipher
@ Input:
@ R2 = character
@ R1 = key
@ Output:
@ R3 = encrypted/decrypted character

	.global encrypt_decrypt
encrypt_decrypt:

	STMFD SP!, {LR}		@ Push link register on to the stack
/*
* R1 = key
* R2 = char
* R3 = encrypted char
*/
	EOR R3, R2, R1		@ Use the exclusive or operation on the key and char and save to R3

	LDMFD SP!, {PC}		@ Pop the link register to get back to main
	
