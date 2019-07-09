TITLE Integer Accumulator		(assemblyAdder.asm)

; Description: Prompts the user to enter integers from -100 to -1 with the choice to stop entering numbers
; with a non-negative number. Displays how many numbers were entered, the sum of the numbers, 
; and a rounded average of the numbers. Numbers each input line, and shows a floating point average. 
; Uses a library function to time the user to measure how long it takes them to input numbers and
; then displays results, including the average time per input.

INCLUDE Irvine32.inc

MIN_NUM	equ	-100d		; lowest number

.data
intro_1		BYTE	"The Integer Accumulator by Andrew Ngo", 0
prompt_name	BYTE	"What's your name? ", 0
hello		BYTE	"Hello, ", 0
username	BYTE	48 DUP(0)
intro_2		BYTE	"Please enter numbers in [-100, -1].", 0
intro_3		BYTE	"Enter a non-negative number when you are finished to see results.", 0
userinput	DWORD	0
count		DWORD	0
sum			DWORD	0
average		DWORD	0
badnum		BYTE	"Out of range. Please enter a number between greater than -100.", 0
result_1	BYTE	"You entered ", 0
result_2	BYTE	" valid numbers.", 0
result_3	BYTE	"The sum of your valid numbers is ", 0
result_4	BYTE	"The rounded average is ", 0
result_5	BYTE	"THe floating point average is ", 0
result_6	BYTE	"The total time you spent working on number inputs was ", 0
result_7	BYTE	" seconds.", 0
result_8	BYTE	"Since you entered ", 0
result_9	BYTE	" numbers, you spent an average of ", 0
result_10	BYTE	" seconds working on each input!", 0
noinputs	BYTE	"You did not enter any valid inputs to work with.", 0
bye			BYTE	"Thank you for your time, ", 0
period		BYTE	". ", 0
thousand	WORD	1000
startTime	DWORD	?
endTime		DWORD	?
totalTime	DWORD	?

.code
main PROC
; Intro
	call	introduction

; Get user's name and greet them
	call	getname
	call	greet

; Show program information
	call	info

; Start timer (for EC #3)
	call	GetMseconds
	mov		startTime, eax

; Get user input
	call	input

; Print results
	call	CrLf
	call	results
	call	CrLf

; Print timer results
	call	timer
	call	CrLf

; Say goodbye
	call	outro
	invoke ExitProcess,0
main endp

; Introduce program and programmer
introduction PROC
	mov		edx, OFFSET intro_1
	call	WriteString
	call	CrLf
	mov	edx, OFFSET ec_1
	call	WriteString
	call	CrLf
	mov	edx, OFFSET ec_2
	call	WriteString
	call	CrLf
	mov	edx, OFFSET ec_3
	call	WriteString
	call	CrLf
	ret
introduction ENDP

; Prompt for and get user's name with ReadString
getname PROC
	mov		edx, OFFSET prompt_name
	call	WriteString	
	mov		edx, OFFSET username
	mov		ecx, 48
	call	ReadString			
	ret
getname ENDP

; Greet the user with their name
greet PROC
	mov		edx, OFFSET hello
	call	WriteString
	mov		edx, OFFSET username	
	call	WriteString
	call	CrLf
	ret
greet ENDP

; Show program information to user (enter numbers)
info PROC
	mov		edx, OFFSET intro_2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro_3
	call	WriteString
	call	CrLf
	ret
info ENDP

; Get/validate user inputs, update count/sum
input PROC
	; period character kept in edx used to number lines
	mov		edx, OFFSET period

	; jump here after a bad number (< -100) or good number in [-100, -1]
	revalidate::	

	; number lines (EC)
	mov		eax, count
	call	WriteDec
	call	WriteString
	call	ReadInt
	mov		userinput, eax

	; note that ReadInt stores input in eax for cmp purposes

	; if input is not signed, we are done
	cmp		userinput, 0
	jns		done		; check to see if input is not signed

	; ensure input is greater than -100
	cmp		userinput, MIN_NUM
	jl		invalid

	; if input is good, adjust count and sum and get new number
	inc		count
	add		sum, eax	; eax = userinput here
	jmp		revalidate

	; on bad number, warn user 
	invalid::
	mov		edx, OFFSET badnum
	call	WriteString
	call	CrLf
	mov		edx, OFFSET period
	jmp		revalidate
	
	; jump here on input greater than -1
	done::
	ret
input ENDP

; calculate and print results 
results PROC
	; if no inputs, skip all calculations
	cmp		count, 0	
	je		noinput

	; print count
	mov		edx, OFFSET result_1
	call	WriteString
	mov		eax, count
	call	WriteDec
	mov		edx, OFFSET result_2
	call	WriteString
	call	CrLf

	; print sum
	mov		edx, OFFSET result_3
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf

	; calculate avg
	mov		edx, 0
	mov		eax, sum
	mov		ebx, count
	cdq					; extend sign bit into EDX for signed div
	idiv	ebx
	mov		average, eax

	; print rounded average
	mov		edx, OFFSET result_4
	call	WriteString
	mov		eax, average
	call	WriteInt
	call	CrLf	

	; print floating point average
	mov		edx, OFFSET result_5
	call	WriteString
	mov		edx, 0
	fild	sum			
	fidiv	count
	fimul	thousand	; .001 precision
	frndint
	fidiv	thousand	
	call	WriteFloat
	call	CrLf

	ret

	; no inputs (avoid div by zero as well for average calculations)
	noinput::
	mov		edx, OFFSET noinputs
	call	WriteString
	call	CrLf	
	ret
results ENDP

; Say goodbye to the user
outro PROC
	mov		edx, OFFSET bye
	call	WriteString
	mov		edx, OFFSET username
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf
	ret
outro ENDP

; Measure and print time used for inputs by user
timer PROC
	; get/print total elapsed time in seconds
	call	GetMseconds				; startTime is measured in main right before prompting user for inputs
	mov		endTime, eax
	sub		eax, startTime
	mov		totalTime, eax

	mov		edx, OFFSET result_6	; tell user how much time they took in seconds (floating point)
	call	WriteString
	fild	totalTime
	fimul	thousand
	frndint
	fidiv	thousand				; convert ms to sec
	fidiv	thousand	
	call	WriteFloat

	mov		edx, OFFSET result_7
	call	WriteString
	call	CrLf

	; get/print average time per input
	cmp		count, 0				; no inputs
	je		finish

	mov		edx, OFFSET result_8	
	call	WriteString
	mov		eax, count
	call	WriteDec
	mov		edx, OFFSET result_9
	call	WriteString
	fidiv	count
	call	WriteFloat
	mov		edx, OFFSET result_10
	call	WriteString
	call	CrLf

	finish::
	ret
timer ENDP
end main