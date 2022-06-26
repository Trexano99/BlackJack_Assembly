	.data
strh:	.asciiz "H "
strd:	.asciiz "D "
strc:	.asciiz "C "
strs:	.asciiz "S "
strsp:	.asciiz "\\"
strcu:	.asciiz "\n\nLe tue carte: "
strcb:	.asciiz "\nCarte del banco: "
strpt:	.asciiz "\nPunteggio: "
	.text
	.globl cartaPrint
	.globl stampaValore
	.globl stampaBanco
	.globl stampaGiocatore
	

cartaPrint:		#Preso il codice della carta $a0, stampa la sua rappresentazione
	li $t0 100
	div $a0 $t0
	mfhi $a0	#Selettore valore
	mflo $t0	#Selettore seme
	li $v0 1
	syscall		#Stampo il numero della carta
	li $v0 4
	beqz $t0 sch	#Controllo cos'è la prima cifra. In base a quella stampo il seme adeguato.
	beq $t0 2 scc
	beq $t0 3 scs
	la $a0 strd	#case Diamonds
	j f		
	scc: 		#case Clubs
	la $a0 strc
	j f
	scs: 		#case Spades
	la $a0 strs
	j f
	sch: 		#case Hearts
	la $a0 strh
	f: syscall
	jr $ra
	
stampaValore:		#Dato l'indirizzo del mazzo $a0 ne stampa il valore totale
	subu $sp, $sp, 8
	sw $fp, 4($sp)	# salvataggio di $fp
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 4
	
	jal calcolaValore
	move $t0 $v0
	move $t1 $v1
	li $v0 4
	la $a0 strpt		#Stampa stringa punteggio
	syscall
	li $v0 1
	move $a0 $t0		
	syscall
	beq $t1 -1 endStVa	#Se c'è solo un valore allora abbiamo finito
	li $v0 4
	la $a0 strsp		#Se ci sono più valori stiamo il carattere di separazione e il secondo valore
	syscall
	li $v0 1
	move $a0 $t1
	syscall
endStVa:
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 4($sp)	# ripristino di $fp
	addi $sp, $sp, 8 # deallocazione stack frame
	jr $ra
	
stampaBanco:	#Questa funzione stampa le carte del banco
	subu $sp, $sp, 8
	sw $fp, 4($sp)	# salvataggio di $fp
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 4
	
	li $v0 4
	la $a0 strcb
	syscall
	la $a0 carteb
	jal stampaMazzo
	
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 4($sp)	# ripristino di $fp
	addi $sp, $sp, 8 # deallocazione stack frame
	jr $ra
	
stampaGiocatore:	#Questa funzione stampa le carte del giocatore
	subu $sp, $sp, 8
	sw $fp, 4($sp)	# salvataggio di $fp
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 4
	
	li $v0 4
	la $a0 strcu
	syscall
	la $a0 cartep
	jal stampaMazzo
	
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 4($sp)	# ripristino di $fp
	addi $sp, $sp, 8 # deallocazione stack frame
	jr $ra

stampaMazzo: 	#Dato l'indirizzo di un mazzo $a0, ne viene stampato il contenuto
	subu $sp, $sp, 20
	sw $s2, 16($sp)
	sw $fp, 12($sp)	
	sw $s0, 8($sp)	# salvataggio di $s0
	sw $s1, 4($sp)	# salvataggio di $s1
	sw $ra, 0($sp)	# salvataggio di $ra
	addiu $fp, $sp , 16
	
	move $s0 $zero		#Contatore
	move $s2 $a0		#Indirizzo mazzo stampare
	jal lenMazzo
	move $s1 $v0		#Lunghezza mazzo
back:
	beq $s0 $s1 endSM	#Se abbiamo stampato tutte le carte usciamo
	lw $a0 ($s2)		
	jal cartaPrint
	addi $s2 $s2 4		
	addi $s0 $s0 1		#Aggiorniamo contatore e indirizzo per la prossima carta
	j back
	
endSM:
	lw $ra, 0($sp) 	# ripristino di $ra
	lw $s1, 4($sp)	# ripristino di $s1
	lw $s0, 8($sp)	# ripristino di $s0
	lw $fp, 12($sp)	
	lw $s2, 16($sp)	# ripristino di $s2
	addi $sp, $sp, 20 # deallocazione stack frame
	jr $ra
	
	
