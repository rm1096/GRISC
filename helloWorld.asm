.data
val1: str "Hello_World"

.text

ori $r3 $zero 0
ori $r5 $zero 1
ori $r6 $zero 4095

ori $r8 $zero 0
beg:
// read char, if not zero print it else end
// la $r6 val2
lw $r4 $r3 val1
beq $r4 $zero end
send $r4 //send
add $r3 $r3 $r5 // increment char pointer
j beg 

end:
recv $r7
ori $r8 $zero 0
loop:
beq $r8 $r6 end
wpix $r8 $r7
add $r8 $r8 $r5 
j loop