



INCLUDE Irvine32.inc
INCLUDE macros.inc
MAP_SIZE = 1000

.data
filename BYTE "map.txt", 0
filename2 BYTE "map2.txt", 0
filename3 BYTE "map3.txt", 0
map BYTE MAP_SIZE DUP(?)
fileHandle HANDLE ?
prompt BYTE "Select one: ", 0
mapLength DWORD ? 
numOfCol DWORD ?
numOfRow DWORD ?
pacmanCurrent DWORD ?
numOfGhost DWORD ?
pacmanPrev DWORD 0h



.code
main PROC
	mov ecx,10
	mov edx,OFFSET filename
	call OpenFile
L1:
	call PrintMenu
	call GetInput
	call PrintMap
	call FindVariables
	

	loop L1

	exit
main ENDP
; takes edx as filename to enable choosing what file to open
OpenFile PROC

	call OpenInputFile
	mov fileHandle,eax
	;check for error opening file
	cmp eax,INVALID_HANDLE_VALUE	
	jne file_ok
	call WriteWindowsMsg


file_ok:
	; Read the file into a buffer.
	mov edx,OFFSET map
	mov ecx,MAP_SIZE
	call ReadFromFile

	mov mapLength,eax

;	call WriteWindowsMsg

	call numOfRowCol
	call FindVariables


	;print the map
	mov edx,OFFSET map
	call WriteString
	call Crlf



	jmp close_file



close_file:
	mov eax,fileHandle
	call CloseFile

	ret

OpenFile ENDP
numOfRowCol PROC
	mov esi, OFFSET map
	;temp
	mov ecx, mapLength
	mov ebx, 0			;counter of row
	mov eax, 0			;counter of col

gettingColNum:
	
	cmp BYTE PTR [esi],0ah	;looking for a last char in a line
	jne Col
	inc ebx					;last count +1
	mov numOfCol, ebx
	mov esi, OFFSET map		;reinit
	mov ecx, mapLength
	jmp gettingRowNum		;if succesfully obtained number of row
	loop gettingColNum

	Col:
		inc ebx
		add esi,TYPE map
		loop gettingColNum

gettingRowNum:
	
	cmp BYTE PTR [esi],0ah	;looking for a last char in a line
	je Row
	add esi,TYPE map
	loop gettingRowNum

	Row:
		inc eax
		add esi,TYPE map
		loop gettingRowNum

	mov numOfRow, eax

	ret
numOfRowCol ENDP
PrintMap PROC
	mov edx, OFFSET map
	call WriteString
	ret
PrintMap ENDP
FindVariables PROC
	mov esi, OFFSET map
	;temp
	mov ecx, mapLength
	mov eax,0			; counter for ghost
	
L1:

	cmp BYTE PTR [esi],2ah
	je Wall
	cmp BYTE PTR [esi],24h
	je Ghost
	cmp BYTE PTR [esi],40h
	je Pacman
	add esi,TYPE map
	loop L1
	mov numOfGhost,eax
	ret

	Wall:
		add esi,TYPE map
		loop L1

	Ghost:
		inc eax
		add esi,TYPE map
		loop L1

	Pacman: 
		mov pacmanCurrent,esi		;store address
		add esi,TYPE map
		loop L1

		

	
	ret
FindVariables ENDP
PrintMenu PROC



	.IF numOfGhost == 0
		jmp PrintPSE
	.ELSEIF 
		jmp PrintAll
	.ENDIF
	PrintAll:
		call Crlf
		mWriteln "Start new games(N)"
		mWriteln "Print Map(P)"
		mWriteln "Move Up(U or W)"
		mWriteln "Move Down(S)"
		mWriteln "Move Left(L or A)"
		mWriteln "Move Right(R or D)"
		mWriteln "End game(E)"
		call Crlf

		ret

	PrintPSE:
		call Crlf
		mWriteln "Start new games(N)"
		mWriteln "Print Map(P)"
		mWriteln "End game(E)"
		call Crlf

		ret


	ret

PrintMenu ENDP
GetInput PROC

asking:

	mov edx, OFFSET prompt
	call writeString		;display message
	call ReadChar			;input from keyboard
	call WriteChar			;echo on screen
	call crlf
	
	.IF numOfGhost == 0
		jmp GettingPSEInput
	.ELSE
		jmp GettingAllInput
	.ENDIF

	GettingPSEInput:
		.IF al == "N" || al == "n"
			; inside if statement is checking what number the user entered: 1,2,3.
			;_1 and _2 are for avoiding label conflicts with GettingAllInput label
			; this section is similar to the GettingAllInput
			; also reset some variables
			mov PacmanPrev, 0h
		FILECHOICE_1:
			mWriteln "Choose a file: (1): ""map.txt"" (2): ""map2.txt"" (3): ""map3.txt"""
			CALL ReadChar
			cmp al, "1"
			jne MAP2_1
			mov edx, OFFSET filename
			call OpenFile
			jmp AFTERMAP_1
		MAP2_1:
			cmp al, "2"
			jne MAP3_1
			mov edx, OFFSET filename2
			call OpenFile
			jmp AFTERMAP_1
		MAP3_1:
			cmp al, "3"
			jne INVALIDPSE
			mov edx, OFFSET filename3
			call OpenFile
			jmp AFTERMAP_2
		INVALIDPSE:
			mWriteln "INVALID"
			jmp FILECHOICE_1
		AFTERMAP_1:
		.ELSEIF al == "P" || al == "p"

		.ELSEIF al == "E" || al == "e"
			exit

		.ELSE
			mWriteln "INVALID"
			jmp asking
		.ENDIF
		ret
	
	GettingAllInput:
		.IF al == "N" || al == "n"
		mov PacmanPrev, 0h
		FILECHOICE_2:
			mWriteln "Choose a file: (1): ""map.txt"" (2): ""map2.txt"" (3): ""map3.txt"""
			CALL ReadChar
			cmp al, "1"
			jne MAP2_2
			mov edx, OFFSET filename
			call OpenFile
			jmp AFTERMAP_2
		MAP2_2:
			cmp al, "2"
			jne MAP3_1
			mov edx, OFFSET filename2
			call OpenFile
			jmp AFTERMAP_2
		MAP3_2:
			cmp al, "3"
			jne INVALIDALL
			mov edx, OFFSET filename3
			call OpenFile
			jmp AFTERMAP_2
		INVALIDALL:
			mWriteln "INVALID"
			jmp FILECHOICE_2
		AFTERMAP_2:
		.ELSEIF al == "P" || al == "p"
			

		.ELSEIF al == "U" || al == "u" || al == "W" || al == "w"
			mov eax, pacmanCurrent	
			sub eax, numOfCol		;subtract one line
			call CheckAvailibity

		.ELSEIF al == "L" || al == "l" || al == "A" || al == "a"
			mov eax, pacmanCurrent	
			dec eax
			call CheckAvailibity
		
		.ELSEIF al == "S" || al == "s"
			mov eax, pacmanCurrent	
			add eax, numOfCol		;subtract one line
			call CheckAvailibity


		.ELSEIF al == "R" || al == "r" || al == "D" || al == "d"
			mov eax, pacmanCurrent	
			inc eax
			call CheckAvailibity

		.ELSEIF al == "E" || al == "e"
			exit

		.ELSE
			mWriteln "INVALID"
			jmp asking
		.ENDIF
		ret

	ret
GetInput ENDP
CheckAvailibity PROC
	mov esi, OFFSET map			
	mov edi,eax					;edi = current position

	cmp BYTE PTR [edi],2ah		;wall	*
	je Wall
	cmp BYTE PTR [edi],24h		;ghost  $
	je Ghost
	cmp BYTE PTR [edi],20h		;blank  
	je Blank
	cmp BYTE PTR [edi],23h		;deghost #
	je DeGhost


	Wall:
		mwriteln "it's a wall"
		ret
	DeGhost:
		mwriteln "it's a deghost"
		jmp MoveToDeGhost
	Ghost:
		mWriteln "it's a ghost"
		jmp MoveToGhost
	Blank:
		mWriteln "it's a blank"
		jmp MoveToBlank

	;------------DEGHOST---------------
	MoveToDeGhost:
		mov ebx,3h
		cmp  pacmanPrev,1h			;if pacman ate ghost at previous turn
		je CurrentToDeghost
		cmp  pacmanPrev,0h			;if pacman didn't ate ghost at previous turn
		je CurretnToBlank
		cmp pacmanPrev,3h			;if pacman was at deghost at previous turn
		je StillDeghost
		ret

	StillDeghost:
		mov pacmanPrev, ebx			;save status in ebx
		mov esi, pacmanCurrent	
		mov BYTE PTR [esi],23h		;current position -> #	
		jmp NextToPacman
		ret
	;------------Blank-----------------
	MoveToBlank:
		mov ebx,0h
		cmp  pacmanPrev,1h			;if pacman's ate ghost at previous turn
		je CurrentToDeghost
		cmp  pacmanPrev,0h			;if pacman didn't ate ghost at previous turn
		je CurretnToBlank
		cmp pacmanPrev,3h			;if pacman was at deghost at previous turn
		je StillDeghost
		ret


	;------------GHOST-----------------
	MoveToGhost:
		mov ebx,1h
		cmp  pacmanPrev,1h			;if pacman's ate ghost at prev turn
		je CurrentToDeghost
		cmp  pacmanPrev,0h			;if pacman didn't ate ghost at previous turn
		je CurretnToBlank
		cmp pacmanPrev,3h			;if pacman was at deghost at previous turn
		je StillDeghost
		ret

	CurretnToBlank:
		mov pacmanPrev, ebx
		mov esi, pacmanCurrent
		mov BYTE PTR [esi],20h		;Current position ->  
		jmp NextToPacman

	CurrentToDeghost:
		mov pacmanPrev, ebx
		mov esi, pacmanCurrent
		mov BYTE PTR [esi],23h		;current position -> #
		jmp NextToPacman

	NextToPacman:
		mov esi, edi
		mov BYTE PTR [esi],40h		;currentPosition -> @
		mov pacmanCurrent, esi		;update pacman's position
		ret


	ret
CheckAvailibity ENDP

END main