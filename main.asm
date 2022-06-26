	.data
strst:	.asciiz "Benvenuto nel gioco del BlackJack!"
strendm:.asciiz "\n\nCredito eaurito! Uscita dal gioco."
strpt:	.asciiz "\nPunteggio: "
strsba:	.asciiz "\n\nHai sballato!\nHai perso\n"
strbj:	.asciiz "\n\nHai fatto BLACKJACK!\nHai Vinto!\n"
	.text
	.globl main
	
main:
	li $t0 200	
	move $s0 $t0	#In s0 salviamo il saldo totale del giocatore
	li $v0 4
	la $a0 strst
	syscall		#Diamo il benvenuto al giocatore
	jal creaMazzoMescolato
puntata:
	move $a0 $s0
	jal stampaCredito	#Informiamo il giocatore del suo credito residuo
	jal inserisciPuntata	#Diamo la possibilità all'utente di posizionare la sua puntata
	move $s1 $v0		#In $s1 salviamo la puntata del giocatore
	move $a0 $s1
	move $a1 $s0
	jal controllaPuntataCorretta	#Controlliamo la validità della puntata
	beqz $v0 puntata
		
	move $a0 $s0
	neg $a1 $s1		#Neghiamo la puntata per ridurre il credito di quanto puntato
	jal modificaSaldo
	move $s0 $v0		#Aggiorniamo il nuovo saldo
	
	#GIOCATA
	jal estraiCartaPerBanco
	jal stampaBanco			#Stampiamo le carte del banco
	la $a0 carteb
	jal stampaValore		#Stampiamo il risultato del banco
	jal estraiCartaPerGiocatore
nuovaCarta:
	jal estraiCartaPerGiocatore
	jal stampaGiocatore		#Stampiamo le carte del giocatore
	la $a0 cartep
	jal stampaValore		#Stampiamo il risultato del giocatore
	la $a0 cartep
	jal calcolaValore
	beq $v0 21 giocataBanco	
	bgt $v0 21 sballa		#Controlliamo che il punteggio del giocatore non sia superiore a 21
	la $a0 cartep
	jal lenMazzo
	bne $v0 2 skipbj
	beq $v1 21 bj			#Se il giocatore ha totalizzato 21 e ha 2 carte allora ha fatto un BLACKJACK
skipbj:
	#DECISIONE GIOCATORE
	jal richiestaCarta		#Il giocatore può richiedere un'ulteriore carta
	beq $v0 1 nuovaCarta
	j giocataBanco
	
bj:
	li $v0 4
	la $a0 strbj
	syscall
	li $t0 2
	div $s1 $t0
	mflo $t0 
	add $s0 $s0 $s1
	add $s0 $s0 $s1
	add $s0 $s0 $t0
	j finale
	
sballa:
	li $v0 4
	la $a0 strsba			#Viene segnalato al giocatore che ha superato il massimo di 21 (Sballato)
	syscall
	j finale
	
giocataBanco:
	jal estraiCartaPerBanco		#Il banco continua a estrarre cate finchè il suo punteggio totale non è > 17
	la $a0 carteb
	jal calcolaValore
	move $s5 $v1
	bge $v1 17 fineBanco		#Controlliamo punteggio del banco per capire se si deve fermare
	move $s5 $v0
	bge $v0 17 fineBanco
	j giocataBanco
	
fineBanco:
	jal stampaBanco			#Mostriamo le carte del banco
	la $a0 carteb
	li $v0 4
	la $a0 strpt
	syscall
	move $a0 $s5			#Stampiamo il punteggio del banco
	li $v0 1			#Non utilizziamo la funzione "stampaValore" poichè se ce ne sono due dobbiamo mostrare il più alto
	syscall
	
	jal calcoloVincitore
	beq $v0 2 finale		#Se il giocatore perde salta alla fine poichè la puntata è gia stata scalata
	add $s0 $s0 $s1			
	beq $v0 1 vittoria		#Se il giocatore pareggia, allora gli sono stati ridati i soldi della puntata
	j finale
vittoria:			#Se il giocatore vince, oltre ai soldi della puntata, gli vengono dati i soldi della vincita
	add $s0 $s0 $s1
finale:
	la $a0 cartep			#Vengono resettate le carte del giocaatore e del banco
	jal resetArray
	la $a0 carteb
	jal resetArray
	bgtz $s0 puntata 	#Se il gioatore ha ancora credito può fare un'altra puntata.
	j exit			#Uscita per credito uguale o minore di zero
	

exit:		#Segnala esaurimento credito e esce dal programma
	li $v0 4
	la $a0 strendm
	syscall
	li $v0 10
	syscall
