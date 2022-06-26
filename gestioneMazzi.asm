	.data
strpmix:.asciiz "\n\nStiamo mescolando il tuo mazzo. Attendi..."
strmix:	.asciiz "\n\nIl mazzo è appena stato mescolato e si può iniziare a giocare!"
		
	.align 3
mazzo:	.space 212
cartep:	.space 44	#Il numero massimo di carte ricevibili è 11 per calcoli dimostrabili matematicamente
carteb:	.space 44	
	.text
	.globl aggiungiCartaAMazzo
	.globl estraiCartaDaMazzo
	.globl creaMazzoMescolato
	.globl lenMazzo
	.globl calcolaValore
	.globl resetArray
	.globl estraiCartaPerBanco
	.globl estraiCartaPerGiocatore
	.globl cartep
	.globl carteb
	.globl mazzo
	
creaMazzoMescolato:		#Questa funzione aggiunge all'array Mazzo 52 carte mescolate così suddiviso: 
				#1-13 Hearts | 101-113 Diamonds | 201-213 Clubs | 301-313 Spades
	subu $sp, $sp, 16
	sw $fp, 12($sp)		# salvataggio dei registri e del puntatore di ritorno poichè chiamo un'altra funzione e uso $s0
	sw $s1, 8($sp)		
	sw $s0, 4($sp)		
	sw $ra, 0($sp)		
	addiu $fp, $sp , 12
	
	li $v0 4
	la $a0 strpmix
	syscall
	
	li $s0 0		#Contatore di carte estratte
ciclo:
	beq $s0 52 salta	#Se si è arrivati a completare tutte le 52 carte allora si ha finito.
	jal generaCartaCasuale
	move $s1 $v0		#Valore carta estratta
	move $a0 $s1 
	la $a1 mazzo
	jal controllaCartaNelMazzo	#Controlliamo se la carta generata casualmente è già presente nel mazzo. Nel caso la cambiamo.
	bnez $v0 ciclo
	move $a0 $s1 
	la $a1 mazzo 
	jal aggiungiCartaAMazzo	
	addi $s0 $s0 1
	j ciclo
salta:
	lw $ra, 0($sp)	
	lw $s0, 4($sp)		#Ripristino dei registri consumati
	lw $s1, 8($sp)
	lw $fp, 12($sp)	
	addi $sp, $sp, 16 	# deallocazione stack frame
	
	li $v0 4
	la $a0 strmix		#Comunichiamo che abbiamo mischiato correttamente il mazzo
	syscall
	jr $ra

controllaCartaNelMazzo:	#Questa funzione permette dato $a0 carta estratta e $a1 indirizzo del mazzo, di sapere se la carta è già nel mazzo. 1 se lo è 0 altrimenti. 
	subu $sp, $sp, 16
	sw $fp, 12($sp)	# salvataggio di $fp
	sw $s1, 8($sp)	# salvataggio di $s1
	sw $s0, 4($sp)	# salvataggio di $s0
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 12
	
	move $s0 $a0	#Carta estratta
	move $s1 $a1	#indirizzo mazzo
	move $a0 $s1
	jal lenMazzo
	move $t0 $zero	#variabile contatore
	move $t1 $zero 	#risultato finale del controllo
	
loop: 
	beq $t0 $v0 fine
	mul $t2 $t0 4
	add $t2 $t2 $s1
	lw $t2 ($t2)
	beq $t2 $s0 trovata	#se viene trovata la carta si aggiorna $t1 e si conclude
	addi $t0 $t0 1
	j loop
trovata: 
	li $t1 1		
fine:
	move $v0 $t1		#Carichiamo in $v0 il risultato della ricerca della carta nel mazzo
	
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 12($sp)	# ripristino di $fp
	lw $s1, 8($sp)	# ripristino di $s0
	lw $s0, 4($sp)	# ripristino di $s1
	addi $sp, $sp, 16 # deallocazione stack frame
	jr $ra
	
aggiungiCartaAMazzo:	#Questa funzione, passati per parametri $a0 valore carta e $a1 indirizzo del mazzo, aggiunge la carta nel mazzo
	subu $sp, $sp, 16
	sw $fp, 12($sp)	# salvataggio di $fp
	sw $s1, 8($sp)	# salvataggio di $s1
	sw $s0, 4($sp)	# salvataggio di $s0
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 12
	
	move $s0 $a0 	#Valore carta
	move $s1 $a1	#indirizzo mazzo
	move $a0 $s1
	jal lenMazzo
	mul $t0 $v0 4	#Troviamo la posizione in cui mettere la carta
	add $t0 $t0 $s1
	sw $s0 ($t0)
	
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 12($sp)	# ripristino di $fp
	lw $s1, 8($sp)	# ripristino di $s0
	lw $s0, 4($sp)	# ripristino di $s1
	addi $sp, $sp, 16 # deallocazione stack frame
	jr $ra

estraiCartaDaMazzo:	#Questa funzione, passati per parametri $a0 mazzo, ritorna l'ultima carta estraibile azzerandone la posizione. Se il mazzo risulta vuoto lo riempie nuovamente.
	subu $sp, $sp, 12
	sw $fp, 8($sp)		# salvataggio di $fp
	sw $s0, 4($sp)
	sw $ra, 0($sp)		# salvataggio di $ra	
	addiu $fp, $sp , 8
	
	move $s0 $a0	 	#Indirizzo mazzo
	jal checkMazzoVuoto	#Controlliamo se sono ancora presenti carte da estrarre dal mazzo
	beq $v0 0 skip
	la $a0 mazzo
	jal resetArray
	jal creaMazzoMescolato	#Se non ci sono più carte lo rempiamo nuovamente
skip:
	move $a0 $s0
	jal lenMazzo
	mul $t0 $v0 4
	subi $t0 $t0 4		#L'ultima posizione va ridotta di 4 o si va a estrarre una posizione vuota
	add $t0 $t0 $s0
	lw $v0 ($t0)
	sw $zero ($t0)		#Azzero la posizione da cui ho estratto la carta
	
	lw $ra, 0($sp)		# ripristino di $ra
	lw $s0, 4($sp)
	lw $fp, 8($sp)		# ripristino di $fp
	addi $sp, $sp, 12 	# deallocazione stack frame
	jr $ra
	
checkMazzoVuoto:	#Questa funzione, passato l'indirizzo del mazzo, restituisce 0 se il mazzo è pieno e 1 se è vuoto
	subu $sp, $sp, 8
	sw $fp, 4($sp)	# salvataggio di $fp
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 4
	
	jal lenMazzo
	bgtz $v0 vuoto	#Se il mazzo è vuoto lo segnalo
	li $v0 1
	j fineMV
vuoto:
	li $v0 0
fineMV:
	lw $ra, 0($sp)	# ripristino di $ra
	lw $fp, 4($sp)	# ripristino di $fp
	addi $sp, $sp, 8 # deallocazione stack frame
	jr $ra
	
lenMazzo: 		#Dato l'indirizzo del mazzo $a0, viene calcolato quanti elementi contiene e restituito in $v0
	move $t0 $zero
lop:
	lw $t1 ($a0)
	beqz $t1 end	#Se la posizione è 0 allora ho finito di contare
	addi $a0 $a0 4
	addi $t0 $t0 1
	j lop
end: 
	move $v0 $t0
	jr $ra
	
calcolaValore:		#Dato l'indirizzo del mazzo $a0, ne calcola il valore e lo restituisce $v0. Se è possibile un secondo valore viene messo in $v1 che altrimenti torna -1.
	subu $sp, $sp, 28
	sw $fp, 24($sp)	# salvataggio di $fp
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 24
	
	move $s0 $a0	#indirizzoMazzo
	jal lenMazzo
	move $s1 $v0	#lunghezza mazzo
	move $s2 $zero	#primo calcolo dei valori
	move $s3 $zero	#secondo calcolo dei valori
	move $s4 $zero 	#contatore carte
	
loopCalVal:
	
	beq $s1 $s4 fineCalVal
	mul $t0 $s4 4		#offset
	add $t0 $t0 $s0		#indirizzo + offset
	lw $t0 ($t0)		#contenuto posizione contatore array
	move $a0 $t0
	jal cartaToValue
	bne $v0 1 aggVal	#Se non è un'asso andiamo avanti, altrimenti aggiungiamo 10 alla seconda somma parziale
	addi $s3 $s3 10
aggVal:
	add $s2 $s2 $v0 	#Aggiungiamo il valore della carte ad entrambe le somme
	add $s3 $s3 $v0
	addi $s4 $s4 1
	j loopCalVal
	
fineCalVal:
	li $t0 21
	ble $s3 $t0 noDel	#Se $s3 ha un valore minore di 21 non lo cancelliamo. Altrimenti sì
	li $s3 -1
noDel:
	bne $s2 $s3 endCalVal	#Se i valori $s2 e $s3 sono gli stessi, allora cancelliamo $s3
	li $s3 -1
endCalVal:
	move $v0 $s2		#Prepariamo i valori per essere restituiti
	move $v1 $s3
	
	lw $ra, 0($sp)		# ripristino di $ra
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $fp, 24($sp)		# ripristino di $fp
	addi $sp, $sp, 28 	# deallocazione stack frame
	jr $ra
	
resetArray:
	subu $sp, $sp, 12
	sw $fp, 8($sp)	# salvataggio di $fp
	sw $s0, 4($sp)
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 8
	
	move $s0 $a0
	jal lenMazzo
	move $t0 $v0	#lunghezza mazzo
	move $t1 $zero	#contatore
loopResAr:
	beq $t0 $t1 fineRes
	mul $t2 $t1 4
	add $t2 $t2 $s0
	sw $zero ($t2)
	add $t1 $t1 1
	j loopResAr
fineRes:
	lw $ra, 0($sp)	# ripristino di $ra
	lw $s0, 4($sp)
	lw $fp, 8($sp)	# ripristino di $fp
	addi $sp, $sp, 12 # deallocazione stack frame
	jr $ra

estraiCartaPerBanco:	#Questa funzione aggiunge la carta al banco dal mazzo principale
	subu $sp, $sp, 12
	sw $fp, 8($sp)	# salvataggio di $fp
	sw $s0, 4($sp)
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 8
	
	la $a0 mazzo
	jal estraiCartaDaMazzo
	move $s0 $v0		#Salviamo la carta estratta in $s0
	move $a0 $s0
	la $a1 carteb
	jal aggiungiCartaAMazzo	
		
	lw $ra, 0($sp)	# ripristino di $ra
	lw $s0, 4($sp)
	lw $fp, 8($sp)	# ripristino di $fp
	addi $sp, $sp, 12 # deallocazione stack frame
	jr $ra


estraiCartaPerGiocatore:	#Questa funzione aggiunge la carta al giocatore dal mazzo principale
	subu $sp, $sp, 12
	sw $fp, 8($sp)	# salvataggio di $fp
	sw $s0, 4($sp)
	sw $ra, 0($sp)	# salvataggio di $ra	
	addiu $fp, $sp , 8
	
	la $a0 mazzo
	jal estraiCartaDaMazzo
	move $s0 $v0		#Salviamo la carta estratta in $s0
	move $a0 $s0
	la $a1 cartep
	jal aggiungiCartaAMazzo	
		
	lw $ra, 0($sp)	# ripristino di $ra
	lw $s0, 4($sp)
	lw $fp, 8($sp)	# ripristino di $fp
	addi $sp, $sp, 12 # deallocazione stack frame
	jr $ra
	
