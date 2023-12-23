; 姓名:李其祐
; 學號:111016041
; 操作說明: 輸入中序運算式求出答案
; 自評分數:100 功能完整，可以支援括號，可以求出正確答案




INCLUDE Irvine32.inc

.386
;.model flat, stdcall
.stack 4096
ExitProcess PROTO, deExitCode:DWORD

.data
input BYTE 50 DUP(?)

output BYTE 50 DUP(?)
outputIndex DWORD 0

eOperandStack DWORD 50 DUP(?)
eOperandStackIndex Dword 0

pre DWORD 0
priority DWORD 0

priorityStack DWORD 50 DUP(?)
priorityStackIndex DWORD 0

operatorStack BYTE 50 DUP(?)
operatorStackIndex DWORD 0
preOperator BYTE 0
.code
main PROC
	mov edx, OFFSET input
	mov ecx, LENGTHOF input
	call readString
	mov esi,0
	detect: 
		; check is operator or end string
		mov al, input[esi]
		cmp al, '+'
		je isAdd
		cmp al, '-'
		je isMinus
		cmp al, '*'
		je isMul
		cmp al, '/'
		je isDiv
		cmp al, '('
		je isLeftCol
		cmp al, ')'
		je isRightCol
		cmp al, 0
		je done
		;call writeChar

		; store operand
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov [ebx], al
		inc outputIndex

		inc esi
		jmp detect	
		
	isLeftCol:
		mov priority, 0
		inc esi
		jmp pushOperator
	
	isRightCol:
		; pop out until (

		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex

		popUntilLeftCol:
			mov ecx, OFFSET operatorStack
			mov edx, operatorStackIndex
			add ecx, edx
		
			push eax
			mov eax, [ecx - 1]
		
			;test
			cmp al, '('
			jne notLeftCol
			sub operatorStackIndex, 1
			sub priorityStackIndex, 4
			inc esi
			cmp input[esi], 0
			je C1 ; if last char is )
			
			mov preOperator, al
			jmp detect
		
			notLeftCol:
			mov ebx, OFFSET output
			mov edx, outputIndex
			add edx, ebx
			mov [edx], al
			;call writeChar
			inc outputIndex
			pop eax
		
			sub operatorStackIndex, 1
			sub priorityStackIndex, 4
			jmp popUntilLeftCol

	isAdd:
		mov priority, 1
		cmp preOperator, '('
		je special
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex
		inc esi
		jmp next
	isMinus:	
		mov priority, 1
		cmp preOperator, '('
		je special
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex
		inc esi
		jmp next
	isMul:
		mov priority, 2
		cmp preOperator, '('
		je special
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex
		inc esi
		jmp next
	isDiv:
		mov priority, 2
		cmp preOperator, '('
		je special
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex 
		special:
		mov preOperator, 0
		inc esi
		jmp next

	next:
		cmp operatorStackIndex,0
		je pushFirstOperator	

		mov ecx, OFFSET priorityStack
		mov edx, priorityStackIndex
		sub edx, 4
		add ecx, edx
		mov ecx, [ecx]	; stack top priority

		cmp priority, ecx
		ja pushOperator
		jmp popOperator

	popOperator:
		mov ecx, OFFSET operatorStack
		mov edx, operatorStackIndex
		add ecx, edx

		push eax
		mov eax, [ecx - 1]
	
		; store in output
		mov ebx, OFFSET output
		mov edx, outputIndex
		add edx, ebx
		mov [edx], al
		;call writeChar
		inc outputIndex
		pop eax

		sub operatorStackIndex, 1
		sub priorityStackIndex, 4
		jmp next

	pushFirstOperator:
		; push priority
		mov ebx, priority
		mov ecx, OFFSET priorityStack
		mov [ecx], ebx
		add priorityStackIndex, 4

		; push operator
		mov ecx, OFFSET operatorStack
		mov [ecx], al
		add operatorStackIndex, 1
		
		jmp detect

	pushOperator:
		; push priority
		mov ebx, priority
		mov ecx, OFFSET priorityStack
		mov edx, priorityStackIndex
		add ecx, edx
		mov [ecx], ebx
		add priorityStackIndex, 4

		; push operator
		mov ecx, OFFSET operatorStack
		mov edx, operatorStackIndex
		add ecx, edx
		mov [ecx], al
		add operatorStackIndex, 1
		jmp detect

	done:
		mov ebx, OFFSET output
		mov ecx, outputIndex
		add ebx, ecx
		mov cl, ' '
		mov [ebx], cl
		inc outputIndex
		C1:
		mov ebx, OFFSET operatorStack
		mov edx, operatorStackIndex
		add edx, ebx

		popOperatorStack: 
			cmp operatorStackIndex, 0
			je calculate
			sub edx, 1
			sub operatorStackIndex, 1
			mov al, [edx]

			mov ebx, OFFSET output
			mov ecx, outputIndex
			add ecx, ebx
			mov [ecx], al

			;call writeChar
			inc outputIndex
			jmp popOperatorStack

	calculate:
		mov ebx, OFFSET output
		mov ecx, outputIndex
		mov esi, 0

	detection:
		; check if is space
		mov al, output[esi]
		cmp al, ' '

		je isSpace
		cmp al, 0
		je printResult

		cmp al, '+'
		je e_add

		cmp al, '-'
		je e_sub

		cmp al, '*'
		je e_mul

		cmp al, '/'
		je e_div

		cbw
		cwd
	
		; process ASCII Char to Number -> 1. first number 2. add pre
		and eax, 00Fh

		; add previous number
		mov ebx, eax
		mov eax, pre
		mov edx, 10
		mul edx
		add ebx, eax
		mov pre, ebx
		mov eax, pre
	
		inc esi
		jmp detection	
	
	e_add:
		mov ebx, OFFSET eOperandStack
		sub eOperandStackIndex, 8
		mov ecx, eOperandStackIndex
		add ecx, ebx
		mov eax, [ecx]
		mov ebx, [ecx+4]
		add eax, ebx
		mov [ecx], eax	; push
		add eOperandStackIndex, 4
		inc esi
		jmp detection

	e_sub:
		mov ebx, OFFSET eOperandStack
		sub eOperandStackIndex, 8
		mov ecx, eOperandStackIndex
		add ecx, ebx
		mov eax, [ecx]
		mov ebx, [ecx+4]
		sub eax, ebx
		mov [ecx], eax	; push
		add eOperandStackIndex, 4
		inc esi
		jmp detection
	e_mul:
		mov ebx, OFFSET eOperandStack
		sub eOperandStackIndex, 8
		mov ecx, eOperandStackIndex
		add ecx, ebx
		mov eax, [ecx]
		mov ebx, [ecx+4]
		mul ebx
		mov [ecx], eax	; push
		add eOperandStackIndex, 4
		inc esi
		jmp detection

	e_div:
		mov ebx, OFFSET eOperandStack
		sub eOperandStackIndex, 8
		mov ecx, eOperandStackIndex
		add ecx, ebx
		mov eax, [ecx]
		mov ebx, [ecx+4]
		div ebx
		mov [ecx], eax	; push
		add eOperandStackIndex, 4
		inc esi
		jmp detection

	isSpace:
		mov eax, pre ; get current operand
		mov pre, 0

		mov ebx, OFFSET eOperandStack
		mov ecx, eOperandStackIndex
		add ecx, ebx
		mov [ecx], eax	; push 
		add eOperandStackIndex, 4
		inc esi
		jmp detection

	printResult:
		mov al, '='
		call writeChar
		mov eax, OFFSET eOperandStack
		mov eax, [eax]
		call writeDec
		
main ENDP
END main