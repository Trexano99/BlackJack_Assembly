	.data

strwin:	.asciiz "\n\nHai vinto!\n"
strlose:.asciiz "\n\nHai perso\n"
strdraw:.asciiz "\n\nPareggio\n"
	.text
	.globl calcoloVincitore

calcoloVincitore:		#Questa funzione indica al giocatore se ha vinto o meno e ritorna in $v0: 0 se c'è stato un pareggio, 1 se ha vinto il giocatore, 2 se ha vinto il banco
	subu $sp, $sp, 16
	sw $fp, 12($sp)		# salvataggio dei registri e del puntatore di ritorno poichè chiamo un'altra funzione e uso $s0
	sw $s1, 8($sp)		
	sw $s0, 4($sp)		
	sw $ra, 0($sp)		
	addiu $fp, $sp , 12

	la $a0 cartep
	jal calcolaValore
	move $s0 $v1		#Valore più alto giocatore
	bne $s0	-1 secVal
	move $s0 $v0
	secVal:
	la $a0 carteb
	jal calcolaValore
	move $s1 $v1		#Valore più alto banco
	bne $s1	-1 compara
	move $s1 $v0
compara:			#Switch per capire chi ha vinto
	bgt $s1 21 vittoria
	beq $s0 $s1 pareggio
	bgt $s0 $s1 vittoria
	blt $s0 $s1 sconfitta
pareggio:			#Case pareggio
	li $v0 4
	la $a0 strdraw
	syscall
	li $v0 0
	j finale
vittoria:			#Case vittoria del giocatore
	li $v0 4
	la $a0 strwin
	syscall
	li $v0 1
	j finale
sconfitta:			#Case vittoria del banco
	li $v0 4
	la $a0 strlose
	syscall
	li $v0 2
	
finale:
	lw $ra, 0($sp)	
	lw $s0, 4($sp)		#Ripristino dei registri consumati
	lw $s1, 8($sp)
	lw $fp, 12($sp)	
	addi $sp, $sp, 16 	# deallocazione stack frame
	
	jr $ra			#Ritorno valore del vincitore
