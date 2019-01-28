//Patrick Quan
//10152770
//CPSC 355
//Assignment 2

//32 bit registers
define(multiplier, w19) //using macros to rename 32 bit register w0 to multiplier
define(multiplicand, w20) //using macros to rename 32 bit register w1 to multiplicand
define(product, w21) //using macros to rename 32 bit register w2 to product
define(i, w22) //using macros to rename 32 bit register w3 to i
define(negative, w23) //using macros to rename 32 bit register w4 to negative
define(false, w24) //Defining false
define(true, w25) //Defining true


//64 bit registers
define(result, x19) //using macros to rename 64 bit register x19 to result
define(temp1, x20) //using macros to rename 64 bit register x20 to temp1
define(temp2, x21) //using macros to rename 64 bit register x21 to temp2

//Setting up printf templates
printOne:   .string "Multiplier = 0x%08x (%d) Multiplicand = 0x%08x (%d) \n\n" //Printing the initial multiplier and multiplicand in hexadecimal and integer forms
printTwo:   .string "Product = 0x%08x Multiplier = 0x%08x \n" //Printing the  product and multiplicand in hexadecimal
printThree: .string "64-bit Result = 0x%0161x (%ld) \n" //Printing the final result of the integer multiplication as hexadecimal and integer form

.balign 4 //Word aligned instructions
.global main //Main function
main:
            stp         x29, x30, [sp, -16]! //Saving the FR and LR registers to stack and allocating 16 bytes
            mov         x29, sp //Updating the FP register to the current SP

            mov         false, 0
            mov         true, 1
            mov         multiplicand, 522133279 //Storing 522133279 into the multiplicand variable
            mov         multiplier, 200 //Storing 200 into the multiplier variable
            mov         product, 0 //Storing 0 into the product variable

            adrp        x0, printOne //Adding the first print template to register x0
            add         x0, x0, :lo12:printOne //Adding the first print template to the first 12 bits
            mov         w1, multiplier //Moving the contents of the multiplier regsiter to w1 to be printed
            mov         w2, multiplier //Moving the contents of the multiplier register to w2 to be printed
            mov         w3, multiplicand //Moving the contents of the multiplicand register to w3 to be printed
            mov         w4, multiplicand //Moving the contents of the multiplicand register to w4 to be printed
            bl          printf //Printing stringOne and all of the appropriate data

            cmp         multiplier, 0 //Comparing the multiplier to 0, to determine if it is negative
            b.lt        negativeTrue //Branch called if the multiplier is less than 0
            mov         negative, false //If the negative branch is not called, then the multiplier is set to not negative

            mov         i, 0 //Moving 0 into the i (loop counter) register
            b           test //unconditional branch to test for the for loop

negativeTrue:
            mov         negative, true //Moving the true value into the negative register
            mov         i, 0 //Moving 0 into the i (loop counter) register
            b           test //Unconditional branch to test the for loop
start:
            ands        wzr, multiplier, 0x1 //Determining if the multiplier ends in 1
            b.eq        isOne //Conditional branch to see if multiplier ends in 1
            add         product, product, multiplicand //Adding a single instance of the multiplicand to the product and storing into the product register

isOne:
            asr         multiplier, multiplier, 1 //Arithmetic shift right 1 bit to the multiplier register
            ands        wzr, product, 0x1 //Determining if the product ends in 1
            b.eq        isTwo
            orr         multiplier, multiplier, 0x80000000 //Inclusive Or comparing the contents of multiplier to 0x80000000
            b           end //Unconditional branch to the end of the loop

isTwo:
            and         multiplier, multiplier, 0x7FFFFFFF //Comparing multiplier and 0x7FFFFFFF by AND and storing in multiplier
            b           end //Unconditional branch to the end of the loop

isNegative:
            sub         product, product, multiplicand //Subtract the multiplicand from the product and store it in the product register
            b           toPrint

end:
            add         i, i, 1 //Incrementing the loop counter by 1
            asr         product, product, 1 //Arithmetic shift right by 1 bit in the product register
test:
            cmp         i, 32 //Iterating through the loop for 32 iterations
            b.lt        start //Conditional branch to the start of the loop

            cmp         negative, true //Comparing the negative flag to see if it is true
            b.eq        isNegative //Conditional branch executed if the negative flag is true
            b           toPrint //Unconditional branch which moves to toPrint

toPrint:
            adrp        x0, printTwo //Moving the printTwo template to x0 register to be printed
            add         x0, x0, :lo12:printTwo //Adding the second print template to the first 12 bits
            mov         w1, product //Moving the contents of the product regsiter to w1 to be printed
            mov         w2, multiplier //Moving the contents of the multiplier regsiter to w2 to be printed
            bl          printf

            sxtw        x22, product //Signed extend word of product to make it 64 bits and stored into the x22 64 bit register
            and         temp1, x22, 0xFFFFFFFF //Comparing x22 (product) and 0xFFFFFFFF by AND and storing in temp1
            lsl         temp1, temp1, 32 //Logical shift left temp1 bt 32 bits

            sxtw        x22, multiplier //Signed extend word of multiplier to make it 64 bits and stored into the x22 64 bit register
            and         temp2, x22, 0xFFFFFFFF //Comparing x22 (product) and 0xFFFFFFFF by AND and storing in temp2
            add         result, temp1, temp2 //Adding temp1 and temp2 and storing it in the result

            adrp        x0, printThree
            add         x0, x0, :lo12:printThree //Adding the thrid print template to the first 12 bits
            mov         x1, result //Moving the contents of the result regsiter to x1 to be printed
            mov         x2, result //Moving the contents of the result regsiter to x2 to be printed
            bl          printf
done:
            ldp         x29, x30, [sp], 16
            ret
