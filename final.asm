.data
ninecharacter: .word 0 
ninecharacter1: .asciiz "absoluter"
ninecharacter2: .asciiz "absolving"
ninecharacter3: .asciiz "crapulent"
ninecharacter4: .asciiz "lubricant"
ninecharacter5: .asciiz "narcotine"
ninecharacter6: .asciiz"paltering"
ninecharacter7: .asciiz "absolving"
space: .asciiz "\n"
start: .asciiz "Please input your word:"
correct: .asciiz "Correct! your score is:"
wrong: .asciiz "Wrong! your score is:"
time: .asciiz "Remaining time is:"
newLine: .asciiz "\n"
keepGuess: .asciiz "Good job! Keep trying:"
dontGiveUp: .asciiz "Don't give up! keep trying:" 
Option: .asciiz "More option: 0: give up; 1: keep playing; 2: shuffle"
allWords: .asciiz "All possible words from the grid: \n"
gameOver: .asciiz "Game over!"
in: .asciiz "randomDict.txt"
headOfDict: .word 0	#head of dictionary
headOfPool: .word 0	#head of possible words pool
buffer: .space 20
inputBuffer: .space 20

.text
main: 
######################################################## Create dictionary #########################################################
	jal readFile		#read input file into buffer	
	#Create the dictionary
	#Create the vitrual head node of the dictionary
	jal createDict		#create the head node of the linked list. first = address of header of linked list. Header here is a virtual node. 
	
	#add nodes in a loop
	li $a1, 0
	li $a2, 12003
	lw $a3, headOfDict	#$a3 = memory address of current node
	la $s7, buffer		#$s7 = address of current byte in buffer. 
	addi $s6, $zero, 0	#s6 save scores
	addi $s5, $zero, 60     #s5 save time
	listLoop: 
		beq $a1, $a2, grid	#add 100 nodes into the linked list. 
		
		addi $sp, $sp, -8	#make room for stack
		sw $a1, 0($sp)		#push $a1 into stack 
		sw $a2, 4($sp)		#push $a2 into stack 
		jal addNode 
		lw $a1, 0($sp)		#restore $a1 from stack
		lw $a2, 4($sp)		#restore $a2 from stack
		addi $sp, $sp, 8	#restore the stack pointer register
		addi $a1, $a1, 1	#increase $a1 by 1. 
		j listLoop	#Create the dictionary

########################################################Create the 3 x 3 grids#########################################################
grid: 					#exit to add string into list
	#generate a random number
	li $a1, 6  #Here you set $a1 to the max bound.
   	li $v0, 42  #generates the random number.
    	syscall

    	li $t0, 0
    	
    	bne $a0, $t0, gridSelect1
    	la $t1, ninecharacter1
    	sw $t1, ninecharacter
    	j shuffleDone
    	
    	gridSelect1: 
    	addi $t0, $t0, 1
    	bne $a0, $t0, gridSelect2
    	la $t1, ninecharacter2
    	sw $t1, ninecharacter
    	j shuffleDone
    	
    	gridSelect2:
    	addi $t0, $t0, 1
    	bne $a0, $t0, gridSelect3
    	la $t1, ninecharacter3
    	sw $t1, ninecharacter
    	j shuffleDone
    	
    	gridSelect3: 
    	addi $t0, $t0, 1
    	bne $a0, $t0, gridSelect4
    	la $t1, ninecharacter4
    	sw $t1, ninecharacter
    	j shuffleDone
    	
    	gridSelect4: 
    	addi $t0, $t0, 1
	bne $a0, $t0, gridSelect5
	la $t1, ninecharacter5
	sw $t1, ninecharacter
	j shuffleDone
	
	gridSelect5: 
	addi $t0, $t0, 1
	bne $a0, $t0, gridSelect6
	la $t1, ninecharacter6
	sw $t1 ninecharacter
	
	gridSelect6: 
	la $t1, ninecharacter7
	sw $t1, ninecharacter    	
	
	shuffleDone:   	
	
presentGrid: 
	la $a0, space
	li $v0, 4
	syscall
	
	#create the 3x3 grid
   	addi $s2, $zero, 10             # s2 save the ascii \n
   	lw $t0, ninecharacter 		#to save nine characters
	lb $a0, 0($t0)     
	li $v0, 11
	syscall
	lb $a0, 1($t0)
	li $v0, 11
	syscall
	lb $a0, 2($t0)
	li $v0, 11
	syscall
	la $a0, space
	li $v0, 4
	syscall
	lb $a0, 3($t0)
	li $v0, 11
	syscall
	lb $a0, 4($t0)
	li $v0, 11
	syscall
	lb $a0, 5($t0)
	li $v0, 11
	syscall
	la $a0, space
	li $v0, 4
	syscall
	lb $a0, 6($t0)
	li $v0, 11
	syscall
	lb $a0, 7($t0)
	li $v0, 11
	syscall
	lb $a0, 8($t0)
	li $v0, 11
	syscall
	la $a0, space
	li $v0, 4
	syscall
	
####################################get all possible words from dictionary to match grids#####################################
#create a list to store all possible words from grids. 
	jal createPool
	lw $a3, headOfPool		#pointer of current string in word pool that could fit into the 3x3 grid, $a3 passed to addNode subroutine
	lw $s7, headOfDict 		#pointer of current string in dictionary, $s7 passed to getString subroutine
	lw $t0, ninecharacter 		#Address to the grid characters, $to passed to checkWord subroutine
	li $t3,	0x0A			#$t3 passed to addNode subroutine
	
	storeLoop: 
		move $t1, $s7		#$t1 = address of current string. $t1 is passed into checkWord subroutine. 
		addi $v1, $zero, 0	#boolean to indicate whether words can be formed in the 3x3 grid.
		beqz $t1, storeExit	#branch to exit if reaching the last word of dictionary
		
		jal checkWord		#branch to checkWord subroutine
		beq $v1, $zero, next	#branch to next subroutine if $v0 = 0 
		
		jal copyNode		#if not, add node into pool.
		next: 
		lw $s7, 12($s7)	#update $s7 to point to next word in dictionary. 
		j storeLoop	#loop 
	storeExit: 
		#lw $a1, headOfPool	
		#jal printList
###################################################Game Start##########################################################################
gstart:	
	la $a0, space
	li $v0, 4
	syscall
	
	la $a0, start
	li $v0, 4
	syscall
	
	lw $t8, headOfPool              #t8 save the start of pool
checkinput:
	li $v0, 8
	la $a0, inputBuffer   		#t9 save input string
	li $a1, 12     			#syscall to read a string with lengh 12
	syscall
	
	la $t9, inputBuffer
	lw $t8, 12($t8)
	li $t3, 0x0A
  checkloop:	
  		#move $a0, $t8
  		#li $v0, 4
  		#syscall
  		
  		lb $t7, ($t9)
		lb $t6, ($t8)
		bne $t7, $t6, checkpool #any characte at same position in input string and linklist string does not match, jump to next string
		lb $t7, 1($t9)
		lb $t6, 1($t8)
		bne $t7, $t6, checkpool
		lb $t7, 2($t9)
		lb $t6, 2($t8)
		bne $t7, $t6, checkpool
		lb $t7, 3($t9)
		lb $t6, 3($t8)
		bne $t7, $t3, checkelse
		beq $t6, $t3, printcorrect
		j checkpool
	checkelse:
		bne $t7, $t6, checkpool
		
		lb $t7, 4($t9)
		lb $t6, 4($t8)
		bne $t7, $t3, checkelse0
		beq $t6, $t3, printcorrect
		j checkpool
	checkelse0:
		bne $t7, $t6, checkpool
		
		
		lb $t7, 5($t9)
		lb $t6, 5($t8)
		bne $t7, $t3, checkelse1
		beq $t6, $t3, printcorrect
		j checkpool
	checkelse1:	
		bne $t7, $t6, checkpool
	
		lb $t7, 6($t9)
		lb $t6, 6($t8)
		bne $t7, $t3, checkelse2
		beq $t8, $t3, printcorrect
		j checkpool
	checkelse2:	
		bne $t7, $t6, checkpool
	
		lb $t7, 7($t9)
		lb $t6, 7($t8)
		bne $t7, $t3, checkelse3
		beq $t6, $t3, printcorrect
		j checkpool
	checkelse3:	
		bne $t7, $t6, checkpool
	
		lb $t7, 8($t9)
		lb $t6, 8($t8)
		bne $t7, $t3, checkelse4
		beq $t6, $t3, printcorrect
		j checkpool
	checkelse4:	
		bne $t7, $t6, checkpool
		
		j printcorrect
		
   checkpool:	
   		lw $t8, 12($t8)         #t8 save the next word to be compared               
                beqz $t8, printwrong
                #move $t9, $a0   	#why move the content of $t9 into $a0? 
	        j checkloop  			
  
printcorrect: 
	li $v0, 4
	la $a0, correct
	syscall
	
	addi $s6, $s6, 20		
	addi $s5, $s5, 5		
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 4
	la $a0, time
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 4
	la $a0, Option
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, $zero, Exit
	li $t4, 2
	beq $v0, $t4, shuffle
	j gstart
	shuffle: 
		j grid
printwrong:
	li $v0, 4
	la $a0, wrong
	syscall
	
	addi $s5, $s5, -10
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	blez $s5, Exit
	
	li $v0, 4
	la $a0, time
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 4
	la $a0, Option
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	li $v0, 5
	syscall

	beq $v0, $zero, Exit
	li $t4, 2
	beq $v0, $t4, shuffle
	j gstart
															   															
#Exit of the whole program.   
Exit: 
	la $a0, space
	li $v0, 4
	syscall
	
	la $a0, allWords
	li $v0, 4
	syscall
	
	lw $a1, headOfPool	
	jal printList
	
	la $a0, space
	li $v0, 4
	syscall
	
	la $a0, gameOver
	li $v0, 4
	syscall
	
 	li $v0, 10
 	syscall

#subroutine to read file from disk into memory		
readFile: 				
	li $v0, 13			#system call to open files
	la $a0, in			#input file name
	li $a1, 0			#flags
	li $a2, 0			#permission
	syscall 
	
	move $s7, $v0			#save file descriptor in $s7. 
	
	#read from file 
	li $v0, 14			#system call to read from file
	la $a1, buffer
	li $a2, 102400
	move $a0, $s7
	syscall 

	jr $ra
#subroutine to create a list with size = 0
createDict: 
	#construct the first node. 
	li $v0, 9		#syscall to allocate memory space
	li $a0, 16		#16 bytes are allocated (12 bytes to store string, 4 bytes to store the pointer to next node)
	syscall
	
	sw $v0, headOfDict		#copy the address of current node into $a1. $a1 = address of current node
	jr $ra
#subroutine to add a node into a list. 
addNode: 
   	#create a node
   	li $v0, 9
   	li $a0, 16
   	syscall			#v0 = address of new node
   	
   	#lw $a3, headOfDict
   	lw $t5, 12($a3)		#save the address of node next to first
   	sw $v0, 12($a3)		#copy the address of new node to the next pointer of first. 
   	sw $t5, 12($v0)		#current node point to its previous node. 
   	
   	#initial the node
   	move $a3, $v0
   	#push $ra into stack
   	addi $sp, $sp, -4
   	sw $ra, ($sp)
   	jal getString 
   	lw $ra, ($sp)
   	addi $sp, $sp, 4
   	#restore $a3
   	move $a3, $v0
	jr $ra

#subroutine to read a string from memory given the memory address
getString: 
	li $t3, 0x0A		#$t3 = new line character
  Loop0:lb $t2, ($s7)		#load the first character into $t2, $t2 = first character. 
   	sb $t2, ($a3) 		#store the character into $a3, current address allocated to character in linked list. 
   	addi $a3, $a3, 1	#increase $a3 by one byte.
   	addi $s7, $s7, 1 	#increase $s7 by one byte. 
   	beq $t2, $t3, Done0	#if $t2 = new line character, stop reading more character. 
   	j Loop0			#if not, keep reading next character. 
  Done0: 
   	jr $ra			#jump back to the address calling getString subroutine. 

#subroutine to copy a node from a linked list
copyNode: 
	#create a node
   	li $v0, 9
   	li $a0, 16
   	syscall			#v0 = address of new node
   	
   	lw $t5, 12($a3)		#save the address of node next to first
   	sw $v0, 12($a3)		#copy the address of new node to the next pointer of first. 
   	sw $t5, 12($v0)		#current node point to its previous node. 
   	
   	#initial the node
   	move $a3, $v0
   	#push $ra into stack
   	addi $sp, $sp, -4
   	sw $ra, ($sp)
   	jal getStringFromList 
   	lw $ra, ($sp)
   	addi $sp, $sp, 4
   	#restore $a3
   	move $a3, $v0
	jr $ra   	
   	
#subroutine to read a string from a linked list
getStringFromList: 
	li $t3, 0x0A		#$t3 = new line character 
	move $t5, $s7		#copy $s7 into $t5, $t5 = address of current node
  listLoop1:lb $t2, ($s7)		#load the first character into $t2, $t2 = first character. 
   	sb $t2, ($a3) 		#store the character into $a3, current address allocated to character in linked list. 
   	addi $a3, $a3, 1	#increase $a3 by one byte.
   	addi $s7, $s7, 1 	#increase $s7 by one byte. 
   	beq $t2, $t3, listDone1	#if $t2 = new line character, stop reading more character. 
   	j listLoop1			#if not, keep reading next character. 
  listDone1: 
  	move $s7, $t5		#restore $s7
   	jr $ra			#jump back to the address calling getString subroutine. 	

#subroutine to print out a string. 		
printList:
	li $t3, 0x0A		#$t3 = new line character
  Loop1:
  	beqz $a1 Done1		#get a pointer to the node
  	innerLoop: la $a0, 0($a1)		#get the data of the char stored in this node 
  		   li $v0, 4			#syscall to print the string
  		   syscall	
		   
		   beq $a0, $t3, innerDone	#if the char is new line char, branch to next node. 
	innerDone: lw $a1, 12($a1)		#$a1 = the address of next node. 
		   j Loop1			
  Done1:jr $ra
  
#subroutine to create a pool of possible words from the grid
createPool: 
	#construct the first node. 
	li $v0, 9		#syscall to allocate memory space
	li $a0, 16		#16 bytes are allocated (12 bytes to store string, 4 bytes to store the pointer to next node)
	syscall
	
	sw $v0, headOfPool	#copy the address of current node into $a1. $a1 = address of current node
	jr $ra	  
	
#Subroutine to check a word in a dictionary could fit into the 3x3 grid. 
checkWord:
	checkcenter:
        	lb $s0, 4($t0) #load center character of the grid to s0
        	lb $s1, ($t1)  #load the first charecter of input string to s1
		beq $s1,$s0,checkmatch
		lb $s1, 1($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 2($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 3($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 4($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 5($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 6($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 7($t1)
		beq $s1,$s0,checkmatch
		lb $s1, 8($t1)
		beq $s1,$s0,checkmatch
		j checkdone
	checkmatch: 
        	lb $s1, ($t1)
        	lb $s0, ($t0)
        	beq $s1,$s0,else0
        	lb $s0, 1($t0)
        	beq $s1,$s0,else0
        	lb $s0, 2($t0)
        	beq $s1,$s0,else0
        	lb $s0, 3($t0)
        	beq $s1,$s0,else0
        	lb $s0, 4($t0)
        	beq $s1,$s0,else0
        	lb $s0, 5($t0)
        	beq $s1,$s0,else0
        	lb $s0, 6($t0)
        	beq $s1,$s0,else0
        	lb $s0, 7($t0)
        	beq $s1,$s0,else0
        	lb $s0, 8($t0)
        	beq $s1,$s0,else0
        	j checkdone
	else0:  
        	lb $s1, 1($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else1
        	lb $s0, 1($t0)
        	beq $s1,$s0,else1
        	lb $s0, 2($t0)
        	beq $s1,$s0,else1
        	lb $s0, 3($t0)
       		beq $s1,$s0,else1
        	lb $s0, 4($t0)
        	beq $s1,$s0,else1
        	lb $s0, 5($t0)
        	beq $s1,$s0,else1
        	lb $s0, 6($t0)
        	beq $s1,$s0,else1
        	lb $s0, 7($t0)
        	beq $s1,$s0,else1
        	lb $s0, 8($t0)
        	beq $s1,$s0,else1
        	j checkdone       
	else1:  
        	lb $s1, 2($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else2
        	lb $s0, 1($t0)
        	beq $s1,$s0,else2
        	lb $s0, 2($t0)
        	beq $s1,$s0,else2
        	lb $s0, 3($t0)
        	beq $s1,$s0,else2
        	lb $s0, 4($t0)
        	beq $s1,$s0,else2
        	lb $s0, 5($t0)
        	beq $s1,$s0,else2
        	lb $s0, 6($t0)
        	beq $s1,$s0,else2
        	lb $s0, 7($t0)
        	beq $s1,$s0,else2
        	lb $s0, 8($t0)
        	beq $s1,$s0,else2
        	j checkdone
	else2:  
        	lb $s1, 3($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else3
        	lb $s0, 1($t0)
        	beq $s1,$s0,else3
        	lb $s0, 2($t0)
        	beq $s1,$s0,else3
        	lb $s0, 3($t0)
        	beq $s1,$s0,else3
        	lb $s0, 4($t0)
        	beq $s1,$s0,else3
        	lb $s0, 5($t0)
        	beq $s1,$s0,else3
        	lb $s0, 6($t0)
        	beq $s1,$s0,else3
        	lb $s0, 7($t0)
        	beq $s1,$s0,else3
        	lb $s0, 8($t0)
        	beq $s1,$s0,else3
        	j checkdone
	else3:  
        	lb $s1, 4($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else4
        	lb $s0, 1($t0)
        	beq $s1,$s0,else4
        	lb $s0, 2($t0)
        	beq $s1,$s0,else4
        	lb $s0, 3($t0)
        	beq $s1,$s0,else4
        	lb $s0, 4($t0)
        	beq $s1,$s0,else4
        	lb $s0, 5($t0)
        	beq $s1,$s0,else4
        	lb $s0, 6($t0)
        	beq $s1,$s0,else4
        	lb $s0, 7($t0)
        	beq $s1,$s0,else4
        	lb $s0, 8($t0)
        	beq $s1,$s0,else4
        	j checkdone        
 	else4:  
        	lb $s1, 5($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else5
        	lb $s0, 1($t0)
        	beq $s1,$s0,else5
        	lb $s0, 2($t0)
        	beq $s1,$s0,else5
        	lb $s0, 3($t0)
        	beq $s1,$s0,else5
        	lb $s0, 4($t0)
        	beq $s1,$s0,else5
        	lb $s0, 5($t0)
        	beq $s1,$s0,else5
        	lb $s0, 6($t0)
        	beq $s1,$s0,else5
        	lb $s0, 7($t0)
        	beq $s1,$s0,else5
        	lb $s0, 8($t0)
        	beq $s1,$s0,else5
        	j checkdone
	else5:  
        	lb $s1, 6($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else6
        	lb $s0, 1($t0)
        	beq $s1,$s0,else6
        	lb $s0, 2($t0)
        	beq $s1,$s0,else6
        	lb $s0, 3($t0)
        	beq $s1,$s0,else6
        	lb $s0, 4($t0)
        	beq $s1,$s0,else6
        	lb $s0, 5($t0)
        	beq $s1,$s0,else6
        	lb $s0, 6($t0)
        	beq $s1,$s0,else6
        	lb $s0, 7($t0)
        	beq $s1,$s0,else6
        	lb $s0, 8($t0)
        	beq $s1,$s0,else6
        	j checkdone
	else6:  
        	lb $s1, 7($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else7
        	lb $s0, 1($t0)
        	beq $s1,$s0,else7
        	lb $s0, 2($t0)
        	beq $s1,$s0,else7
        	lb $s0, 3($t0)
        	beq $s1,$s0,else7
        	lb $s0, 4($t0)
        	beq $s1,$s0,else7
        	lb $s0, 5($t0)
        	beq $s1,$s0,else7
        	lb $s0, 6($t0)
        	beq $s1,$s0,else7
        	lb $s0, 7($t0)
        	beq $s1,$s0,else7
        	lb $s0, 8($t0)
        	beq $s1,$s0,else7
        	j checkdone        
	else7:  
        	lb $s1, 8($t1)
        	beq $s2, $s1, else8
        	lb $s0, ($t0)
        	beq $s1,$s0,else8
        	lb $s0, 1($t0)
        	beq $s1,$s0,else8
        	lb $s0, 2($t0)
        	beq $s1,$s0,else8
        	lb $s0, 3($t0)
        	beq $s1,$s0,else8
        	lb $s0, 4($t0)
        	beq $s1,$s0,else8
        	lb $s0, 5($t0)
        	beq $s1,$s0,else8
        	lb $s0, 6($t0)
        	beq $s1,$s0,else8
        	lb $s0, 7($t0)
        	beq $s1,$s0,else8
        	lb $s0, 8($t0)
        	beq $s1,$s0,else8
        	j checkdone                                                           
	else8:	addi $v1, $v1, 1	#set $t0 as 1, indicating that the word can fit into the 3x3 grid.  
	checkdone:
		jr $ra