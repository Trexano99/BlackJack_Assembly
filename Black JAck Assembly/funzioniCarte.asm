	.data
	
strcard:.asciiz "\nSi desidera un'altra carta?\n0. NO | 1. SI\n"
	.text
	.globl richiestaCarta
	.globl generaCartaCasuale
	.globl cartaToValue
	
		
richiestaCarta:		#Questa funzione richiede all'utente se vuole un'altra carta. Ritorna 0 se "NO" o 1 se "SI" in $v0
	li $v0 4
	la $a0 strcard
	syscall
	li $v0 5
	syscall
	bgt $v0 1 richiestaCarta
	bltz $v0 richiestaCarta
	jr $ra
		
generaCartaCasuale:	#Ritorna in $v0 un valore casuale nel range consentito
	li $t0 13	#Minimo valore numerico carta
	li $t1 4	#Massimo valore seme
	li $v0 42
	move $a1 $t0
	syscall
	addi $t0 $a0 1	#Metto in $t0 il valore numerico casuale
	move $a1 $t1	
	syscall
	mul $a0 $a0 100	#Moltiplico per 100 il valore del seme
	add $v0 $t0 $a0	#Li sommo e li metto $v0
	jr $ra
	
cartaToValue:		#Preso il codice della carta $a0, ritorna il valore della carta
	move $v0 $zero
	li $t0 100
	div $a0 $t0
	mfhi $t1	#parte decimale da utilizzare per il valore
	mflo $t0	#Centinaia del seme
	li $t0 10
	div $t1 $t0	#Divido per 10 separando decine e unità
	mfhi $t1	#decine
	mflo $t0	#unità
	beq $t0, 1, nu
	add $v0 $v0 $t1	#Aggiungo le unità
nu:
	mul $t0 $t0 10	#Se la carta è sopra al 10 vale 10
	add $v0 $v0 $t0 
	jr $ra
