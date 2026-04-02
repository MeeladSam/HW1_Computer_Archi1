.data  
A: .space 40
B: .space 40
C: .space 80

MSG_a: .asciiz "Please keep entering integer numbers until you read word done\n"
MSGdone: .asciiz "done\n"
msgA: .asciiz "\nArray A: "
msgB: .asciiz "\nArray B: "
msgCountA: .asciiz "\nCountA = "
msgCountB: .asciiz "\nCountB = "

COUNTA: .word 0 
COUNTB: .word 0
COUNTC: .word 0

msgC: .asciiz "\nArray C: "
msgPos: .asciiz "\nPositive count = "
msgNeg: .asciiz "\nNegative count = "
msgAvg: .asciiz "\nAverage = "
msgBye: .asciiz "\nGood Bye \n"
myName: .asciiz "Melad Sam AbdAlqader AlFoqahahaa \n"

.text
.globl main

main:
li $v0, 4
la $a0, MSG_a
syscall

Loop1:
li $v0, 5
syscall 
move $t1, $v0
beq $t1, $zero, ENDLoop1

andi $t0, $t1, 1   # it checks the LSB bit in $t1
beq $t0, $zero, ArrayA_Partb  # even => 0 / odd => 1

ArrayB_partb:
li $t2, 10 
lw $t3, COUNTB
beq $t3, $t2, ENDLoop1

sll $t4, $t3, 2 
la $t5, B # count here is treated like i
add $t5, $t5, $t4
sw $t1, 0($t5) # store the input number itself

# i++
addi $t3, $t3, 1
sw $t3, COUNTB

li $t2, 10 
lw $t3, COUNTB
beq $t3, $t2, ENDLoop1

j Loop1


ArrayA_Partb:
li $t2, 10 
lw $t3, COUNTA
beq $t3, $t2, ENDLoop1

sll $t4, $t3, 2# count here is treated like i  
la $t5, A
add $t5, $t5, $t4
sw $t1, 0($t5)# store the input number itself

# i++
addi $t3, $t3, 1
sw $t3, COUNTA
 
 li $t2, 10 
lw $t3, COUNTA
beq $t3, $t2, ENDLoop1

j Loop1

ENDLoop1:
li $v0, 4
la $a0, MSGdone
syscall

# Array A and its size
li $v0, 4
la $a0, msgA
syscall

la $a0, A
lw $a1, COUNTA
jal PRINTARRAY
    
li $v0, 4
la $a0, msgCountA
syscall

li $v0, 1
lw $a0, COUNTA
syscall

  
# Array B and its size
li $v0, 4
la $a0, msgB
syscall

la $a0, B
lw $a1, COUNTB
jal PRINTARRAY

li $v0, 4
la $a0, msgCountB
syscall

li $v0, 1
lw $a0, COUNTB
syscall

# call combine and pass A, B and C addresses  to them
la $a0, A
la $a1, B
la $a2, C
jal combine

# save returned values
move $s0, $v0#POS count
move $s1, $v1 #NEG count



# prnt POS count
li $v0, 4
la $a0, msgPos
syscall

li $v0, 1
move $a0, $s0
syscall

# print NEF count
li $v0, 4
la $a0, msgNeg
syscall

li $v0, 1
move $a0, $s1
syscall



# Array C Content
li $v0, 4
la $a0, msgC
syscall

la $a0, C
lw $a1, COUNTC
jal PRINTARRAY


# THe average of all elements in C
lw $t0, COUNTC
beq $t0, $zero, AVG_ZERO

la $t1, C
li $t2, 0 # i = 0
li $t3, 0# sum = 0

AVG_LOOP:
beq $t2, $t0, AVG_DONE#i ==? COUNTC

sll $t4, $t2, 2#   $t4i*4
add $t5, $t1, $t4
lw $t6, 0($t5)

add $t3, $t3, $t6 #sum+= 
addi $t2, $t2, 1
j AVG_LOOP

AVG_DONE:
div $t3, $t0
mflo $t7
j PRINT_AVG

AVG_ZERO:
li $t7, 0

PRINT_AVG:
li $v0, 4
la $a0, msgAvg
syscall

li $v0, 1
move $a0, $t7
syscall

# print Good Bye and full nameee
li $v0, 4
la $a0, msgBye
syscall

li $v0, 4
la $a0, myName
syscall

li $v0, 10
syscall


PRINTARRAY:
move $t0, $a0                 # base address
move $t1, $a1                 # count
li $t2, 0                     # i = 0

PRINTLoop:
beq $t2, $t1, FINISHPRINT

sll $t3, $t2, 2 # i * 4 for the offset
add $t4, $t0, $t3 # address of array[i]
lw $a0, 0($t4)

li $v0, 1
syscall

li $v0, 11
li $a0, 32 # space character
syscall

addi $t2, $t2, 1
j PRINTLoop

FINISHPRINT:
jr $ra

#combine
combine:

lw $t0, COUNTA
lw $t1, COUNTB

# COUNTC = 
add $t2, $t0, $t1
sw $t2, COUNTC

# copy A into C
li $t3, 0# i = 0

COPY_A_LOOP:
beq $t3, $t0, COPY_B_START

sll $t4, $t3, 2
add $t5, $a0, $t4#offset 
lw $t6, 0($t5)

add $t7, $a2, $t4#offset 
sw $t6, 0($t7)

addi $t3, $t3, 1#i++
j COPY_A_LOOP

#copy B into C
COPY_B_START:
li $t3, 0# i = 0

COPY_B_LOOP:
beq $t3, $t1, SORT_START

sll $t4, $t3, 2
add $t5, $a1, $t4#offset 
lw $t6, 0($t5)

add $t8, $t0, $t3
sll $t9, $t8, 2#COUNTA + i 
add $t7, $a2, $t9#offset
sw $t6, 0($t7)

addi $t3, $t3, 1
j COPY_B_LOOP

# sort C 
SORT_START:
lw $t0, COUNTC
li $t1, 0# i = 0

OUTER_LOOP:
beq $t1, $t0, COUNT_NEGPOS#i=?=COUNTC

li $t2, 0# j = 0
addi $t3, $t0, -1
sub $t3, $t3, $t1# limit = countC - 1 - i

INNER_LOOP:
beq $t2, $t3, NEXT_OUTER

sll $t4, $t2, 2
add $t5, $a2, $t4 #offset C address + j*4
lw $t6, 0($t5)#c[j]
lw $t7, 4($t5)#c[j+1]

bgt $t6, $t7, DO_SWAP
j NO_SWAP

# swap
DO_SWAP:
sw $t7, 0($t5)
sw $t6, 4($t5)

NO_SWAP:#j+=1
addi $t2, $t2, 1
j INNER_LOOP

NEXT_OUTER:#i+=1
addi $t1, $t1, 1
j OUTER_LOOP

# count +ve and -ve numberas in C
COUNT_NEGPOS:
lw $t0, COUNTC
li $t1, 0#i
li $v0, 0# POS count
li $v1, 0# NEG count

NEGPOS_LOOP:
beq $t1, $t0, COMBINE_DONE

sll $t2, $t1, 2
add $t3, $a2, $t2#offset
lw $t4, 0($t3)

bgtz $t4, POS_NUM
bltz $t4, NEG_NUM
j NEXT_SIGN#nither

POS_NUM:
addi $v0, $v0, 1
j NEXT_SIGN

NEG_NUM:
addi $v1, $v1, 1

NEXT_SIGN:
addi $t1, $t1, 1#i+=1
j NEGPOS_LOOP

COMBINE_DONE:
jr $ra
