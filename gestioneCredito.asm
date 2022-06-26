	.data
strsld: .asciiz "\n\nSaldo: "
strpu:	.asciiz "\nInserisci la tua puntata: "
strnm:	.asciiz	"\nCredito insufficiente per la puntata desiderata!\n"
	.text
	.globl stampaCredito
	.globl inserisciPuntata
	.globl controllaPuntataCorretta
	.globl modificaSaldo

stampaCredito:		#Segnala al giocatore il credito residuo passato come parametro $a0
	move $t0 $a0 
	li $v0 4	
	la $a0 strsld
	syscall
	move $a0 $t0
	li $v0 1
	syscall
	jr $ra

inserisciPuntata:	#Chiede al giocarore di inserire la puntata e la ritorna come parametro
	li $v0 4
	la $a0 strpu
	syscall		#Chiediamo al giocatore di inserire la sua puntata
	li $v0 5
	syscall
	jr $ra
	
	
controllaPuntataCorretta:	#Controlla se la puntata $a0 è minore del credito totale $a1. Se lo è torniamo 1 altrimenti 0
	sub $t0 $a1 $a0
	li $v0 1
	bgez $t0 return		#Controlliamo se la puntata va bene. Altrimenti segnaliamo e torniamo 0
	li $v0 4
	la $a0 strnm
	syscall
	move $v0 $zero
	return: jr $ra
	
modificaSaldo:			#Modifica il saldo $a0 aggiungendo il contenuto $a1 che può anche essere negativo
	add $a0 $a0 $a1
	move $v0 $a0 
	jr $ra
