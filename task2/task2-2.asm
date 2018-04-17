.386
WRITELV MACRO CHR;PRINT PROFIT LEVEL
	LEA DX, CRLF
	MOV AH,9
	INT 21H
	MOV DL, CHR
	MOV AH, 2
	INT 21H
	LEA DX, CRLF
	MOV AH, 9
	INT 21H
ENDM WRITELV
STACK SEGMENT USE16 STACK
	DB 200 DUP(0)
STACK ENDS

DATA SEGMENT USE16
	M EQU 29975
	BNAME DB 'NING JIA',0DH,0	;BOSS NAME,0DH TO MATCH LF
	BPASS DB 'SECRET',0DH		;PASSWORD
	N EQU 30
	S1 DB 'SHOP1' ,0		;END WITH ZERO
	GA1 DB 'PEN', 7 DUP(0)	;GOODS NAME
		DW 35, 56, 30000, 25, ?;PROFIT MARGIN IS REMAINED HERE
		;PURCHASE PRICE:35		SELLING PRICE:56
		;PURCHASE NUM:70		SELL NUM:25
		;PROFIT = (SP * SN - PP * PN) * 100 / (PP * PN)
	GA2 DB 'BOOK', 6 DUP(0)
		DW 12, 30, 25, 5, ?
	GA3 DB 'CIGARETTE', 0
		DW 30, 100, 50, 40, ?
	GA4 DB 'CLOUTHES', 2 DUP(0)
		DW 200, 580, 20, 18, ?
	GA5 DB 'NECKLACE', 2 DUP(0)
		DW 500, 1900, 5, 4, ?
	GAN DB N-5 DUP ('TEMP-VALUE', 15, 0, 20, 0, 30, 0, 2, 0, ?, ?)
	S2 DB 'SHOP2', 0
	DIF EQU $-GA1
	GB2 DB 'PEN', 7 DUP(0)
		DW 35, 50, 30, 25, ?
	GB1 DB 'BOOK', 6 DUP(0)
		DW 12, 28, 20, 15, ?
	GB3 DB 'CIGARETTE', 0, ?
		DW 30, 90, 45, 40, ?
	GB4 DB 'CLOUTHES', 2 DUP(0)
		DW 200, 550, 20, 15, ?
	GB5 DB 'NECKLACE', 2 DUP(0)
		DW 500, 2000, 8, 5, ?
	GBN DB N-5 DUP ('TEMP-VALUE', 15, 0, 18, 0, 50, 0, 40, 0, ?, ?)

	HINT1 DB 0DH, 0AH, 'PLEASE ENTER YOUR NAME:', 0DH, 0AH, '$'
	HINT2 DB 0DH, 0AH, 'PLEASE ENTER YOUR PASSWORD:', 0DH, 0AH, '$'
	HINT3 DB 0DH, 0AH, 'FAIL TO LOG IN!', 0DH, 0AH, '$'
	HINT4 DB 0DH, 0AH, 'PLEASE ENTER THE GOODS YOU WANT', 0DH, 0AH, '$'
	CRLF DB 0DH, 0AH, '$'
	BUF1 DB 10,?	;10 IS THE LENGTH OF NAME
	IN_NAME DB 10 DUP(0)
	BUF2 DB 7,?	;6 IS THE LENGTH OF PASSWORD
	IN_PWD DB 6 DUP(0)
	BUF3 DB 10,?
	GN DB 10 DUP(0)
	AUTH DB 0
DATA ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA, SS:STACK
START:
	MOV AX, DATA
	MOV DS, AX
I_NAME:;NAME is a keyword in asm(Pseudo instruction)
	;PRINT HINT1
	LEA DX, HINT1
	MOV AH, 9
	INT 21H	
	;INPUT NAME
	MOV CX, 10
	LEA EDX, IN_NAME
L1:
	MOV BYTE PTR [EDX], 0;r16 must be index or base register, so change the EX to EDX
	INC EDX
	LOOP L1
	LEA DX, BUF1
	MOV AH, 0AH
	INT 21H
	CMP IN_NAME, 0DH
	JE BEFORE
	CMP IN_NAME, 'q'
	JNE JNAME
	CMP IN_NAME + 1, 0DH
	JE EXIT
;MATCH THE NAME
JNAME:
	LEA BX, BNAME
	LEA SI, IN_NAME
	MOV CX, 10
LOPA:
	MOV AL, [BX]
	CMP AL, [SI]
	JNE ERROR
	INC BX
	INC SI
	LOOP LOPA

I_PWD:
	;PRINT HINT2
	LEA DX, HINT2
	MOV AH,9
	INT 21H	
	;INPUT PASSWORD
	MOV CX, 7
	LEA EDX, IN_PWD
L2:
	MOV BYTE PTR [EDX], 0
	INC EDX
	LOOP L2
	LEA DX, BUF2
	MOV AH, 0AH
	INT 21H
;MATCH THE PASSWORD
JPASS:
	LEA BX, BPASS
	LEA SI, IN_PWD
	MOV CX, 7
LP:
	MOV AL, [BX]
	CMP AL, [SI]
	JNE ERROR
	INC BX
	INC SI
	LOOP LP
	MOV AUTH, 1
	JMP GOODS
ERROR:
	LEA DX, HINT3
	MOV AH, 9
	INT 21H
	JMP I_NAME
BEFORE:
	MOV AUTH, 0
GOODS:
	LEA DX, HINT4
	MOV AH, 9
	INT 21H;PRINT HINT
	MOV CX, 10
	LEA EDX, GN
L3:
	MOV BYTE PTR [EDX], 0
	INC EDX
	LOOP L3
	LEA DX, BUF3
	MOV AH, 0AH
	INT 21H;INPUT GOODS NAME
	CMP GN, 0DH
	JE I_NAME;JUMP WHEN INPUT ONLY ENTER
	MOV CX, N
	LEA BX, GA1;USE BX TO STORE THE OFFSET OF GOODS NAME
MATCH:
	PUSH CX
	MOV CL, BUF3+1
	MOV CH, 0
	MOV AH, CL
	LEA SI, GN	
	MOV DI, BX
LOOPA:
	MOV AL, [SI];MOV INPUT GOODS NAME
	CMP AL, [DI]
	JNE CONTINUE
	INC SI
	INC DI
	LOOP LOOPA
	CMP AH, 10
	JE TRUE
	CMP BYTE PTR [DI], 0
	JE TRUE
CONTINUE:
	POP CX
	ADD BX, 20
	LOOP MATCH
	JMP GOODS;FAIL TO MATCH RESTART
TRUE:
	CMP AUTH, 1
	JE SUC
	;IF AUTH = 0 THEN PRINT GOODS AGAIN
	LEA DX, CRLF
	MOV AH, 9
	INT 21H
	MOV AL, [SI-1]
	MOV BYTE PTR [SI-1], '$';must indicate the type of oprand
	LEA DX, GN
	MOV AH, 9
	INT 21H
	MOV DL, AL
	MOV AH, 2
	INT 21H
	JMP I_NAME
SUC:
	MOV CX, M
	MOV DI, BX
	LEA DX, CRLF
	MOV AH, 9
	INT 21H
	CALL DISPTIME
LM:;TO CIRCLE M TIMES
	PUSH CX;TO PROTECT CX
	MOV BX, DI
	MOV AX, WORD PTR 14[DI]
	CMP WORD PTR 16[DI], AX
	JE I_NAME
	INC WORD PTR 16[DI]
	CALL PROFIT;RET EAX AS PROFIT
	PUSH EAX
	ADD BX, DIF;COMPUTE THE SHOP2 GOODS
	CALL PROFIT
	POP ECX
	ADD EAX, ECX
	SAR EAX, 1;(EAX) = APR
	MOV 18[DI], AX
	POP CX
	LOOP LM
	PUSH EAX
	CALL DISPTIME;IF ALL OF THE M CUSTOMERS SUCCEED TO BUY THE GOODS,THEN CALL DISPTIME
	POP EAX
	CMP EAX, 90
	JNGE NA 
	PUSH EAX
	WRITELV 'A'
	POP EAX
	CALL BASE
	JMP I_NAME
NA:
	CMP EAX, 50
	JNGE NB
	PUSH EAX
	WRITELV 'B'
	POP EAX
	CALL BASE
	JMP I_NAME
NB:
	CMP EAX, 20
	JNGE NC
	PUSH EAX
	WRITELV 'C'
	POP EAX
	CALL BASE
	JMP I_NAME
NC:
	CMP EAX, 0
	JNGE ND
	PUSH EAX
	WRITELV 'D'
	POP EAX
	CALL BASE
	JMP I_NAME
ND:
	PUSH EAX
	WRITELV 'F'
	POP EAX
	CALL BASE
	JMP I_NAME

BASE PROC;(EAX) IS THE NUM CONVERGING TO THE 10-BASE AND PRINT
	MOV ESI, 10
	MOV CX, 0
	CMP EAX, 0
	JGE POS
	PUSH EAX
	MOV DL, '-'
	MOV AH, 2
	INT 21H
	POP EAX
	NEG EAX;CX TO RECORD THE STEP COUNT
POS:
	MOV EDX, 0
	DIV ESI
	ADD EDX, '0'
	PUSH EDX
	INC CX
	CMP EAX, 0
	JNE POS
PRC:
	POP EDX
	MOV AH, 2
	INT 21H
	LOOP PRC
	MOV DL, '%'
	MOV AH, 2
	INT 21H
	RET
BASE ENDP
PROFIT PROC ;(BX) IS THE GOODS OFFSET
	MOV AX, 10[BX];PP
	MUL WORD PTR 14[BX]
	SHL EDX, 16
	MOV DX, AX
	MOV ECX, EDX;(ECX) = PP * PN
	MOV AX, 12[BX];SP
	MUL WORD PTR 16[BX]
	SHL EDX, 16
	MOV DX, AX
	MOV EAX, EDX;(EAX) = SP * SN
	SUB EAX, ECX
	MOV ESI, 100
	IMUL ESI
	IDIV ECX;ASSUME THE ABS OF THE RESULT NOT EXCEEDING 2^31
	RET
PROFIT ENDP

DISPTIME PROC        ;显示秒和百分秒，精度为55MS。(未保护AX寄存器)
    LOCAL TIMESTR[8]:BYTE     ;0,0,'"',0,0,0DH,0AH,'$'

         PUSH CX
         PUSH DX         
         PUSH DS
         PUSH SS
         POP  DS
         MOV  AH,2CH 
         INT  21H
         XOR  AX,AX
         MOV  AL,DH
         MOV  CL,10
         DIV  CL
         ADD  AX,3030H
         MOV  WORD PTR TIMESTR,AX
         MOV  TIMESTR+2,'"'
         XOR  AX,AX
         MOV  AL,DL
         DIV  CL
         ADD  AX,3030H
         MOV  WORD PTR TIMESTR+3,AX
         MOV  WORD PTR TIMESTR+5,0A0DH
         MOV  TIMESTR+7,'$'    
         LEA  DX,TIMESTR  
         MOV  AH,9
         INT  21H    
         POP  DS 
         POP  DX
         POP  CX
         RET
DISPTIME	ENDP
EXIT:
	MOV AH, 4CH
	INT 21H
CODE ENDS
END START