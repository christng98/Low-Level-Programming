.equ LED, 0xFF200000
.equ JTAG, 0xFF201000
.global _start

.section .text

_start:
	ldr		r6, =JTAG			// Load base address of JTAG to r6.
	ldr		r8, =input			// Load base address of input to r8.
	ldr 	r9, =input 			// Load base address of input to r9.
	ldr 	r10, =LED			// Load base address of LED to r5.
	b 		check_input
	
check_input:				// Counting length of input.
	mov 	r0, #0 			// Setting up a counter.
	loop_input:
	ldrb 	r2, [r9] 		// Byte load.
	cmp		r2, #32			// Whitespace handler.
	subeq	r0, #1			// Decrement counter.
	cmp 	r2, #0 			// If r2 is 0, we have finished counting the input.
	beq 	check_pal		// Branch to check_pal after finished counting.
	add 	r9, #1			// Increment address to point to the next byte.
	add 	r0, #1			// Increment counter.
	b 		loop_input
	
check_pal:
	mov 	r1, #0			// Counter from base address of input.
	sub		r9, #1			// Last address of input.
	lsr		r0, #1			// Division by 2.
	loop_check:
	cmp		r1, r0			// Check if counter has made it halfway of input.
	bgt		pal_found		// Branch to pal_found if everything looks good.		
	add		r1, #1			// Increment counter.
	ldrb	r2, [r8]		// Byte load base address of input to r2.
	ldrb	r3, [r9]		// Byte load last address of input to r3.
	// Whitespace handler	
	cmp		r2, #32			// Check if r2 is a whitespace.
	addeq	r8, #1			// Skip to next character if whitespace.
	cmp		r3, #32			// Check if r3 is a white space.
	subeq	r9, #1			// Skip to next character if whitespace.

	ldrb	r2, [r8]		// Byte load base address of input to r2.
	ldrb	r3, [r9]		// Byte load last address of input to r3.
	// Lowercase handler
	cmp		r2, #97			// ASCII lowercase characters are 97+.
	subge	r2, #32			// Convert lowercase characters into uppercase.
	cmp		r3, #97			// Same as for r2.
	subge	r3, #32			// Same as for r2.	
	// Compare front and back character
	cmp 	r2, r3
	bne 	pal_not_found	// Difference detected -> Not palindrome.
	add		r8, #1			// Next front input.
	sub		r9, #1			// Next back input.
	b		loop_check		
	
pal_found:
	ldr 	r11, =found		// Load "found" message.
	// Switch on only the 5 rightmost LEDs
	mov		r0, #0x1F
	str 	r0, [r10]
	b		loop_print		// Print to JTAG UART
	
pal_not_found:
	ldr 	r11, =not_found	// Load "not found" message.
	// Switch on only the 5 leftmost LEDs
	mov		r0, #0x3E0
	str 	r0, [r10]
	b		loop_print		// Print to JTAG UART
	
loop_print:
	ldrb	r0, [r11]		// Byte load address of jtag to r0.	
	cmp		r0, #0			// Check if we reached end of string.
	beq		exit			// Exit if we've reached the end of string.
	
	str		r0, [r6]		// Store r0 in [r6]
	add		r11, #1			// Increment address pointer of r11.
	b		loop_print		
	
exit:
	b exit
	

.section .data
.align
	//input: .asciz "level"
	//input: .asciz "8448"
    //input: .asciz "KayAk"
    //input: .asciz "step on no pets"
    input: .asciz "Never odd or even"
	found: .asciz "Palindrome detected.\n"
	not_found: .asciz "Not a palindrome.\n"

.end