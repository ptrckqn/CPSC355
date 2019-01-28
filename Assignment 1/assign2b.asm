//Patrick Quan
//10152770
//CPSC 355
//Assignment 1

define(xVal, x24) //Using a macro to rename the x24 register to xVal
define(yVal, x26) //Using a macro to rename the x26 register to yVal

.global main
main:
        stp       x29, x30, [sp, -16]
        mov       x29, sp

        mov       x23, -6 //Storing -6 into register x23. x23 is used as the counter for the loop, as well as the x in the equation
        mov       x25, -999 //Register x25 used to store the maximum value. Initially set to -999

        b         test //Branch to test the pre-condition loop
top:
        //Storing all of the constants from the equation y = -5x^3 - 31x^2 + 4x + 31 into registers x19 to x22
        mov       x19, -5 //Storing -5 into register x19
        mov       x20, -31 //Storing 31 into register x20
        mov       x21, 4 //Storing 4 into register x21
        mov       x22, 31 //Storing 31 into register x22
        mov       yVal, 0 //Register x26 is used to store the y value

        mov       xVal, x23 //Storing the current x value, stored in register x23, into xVal
        mul       xVal, xVal, xVal //Squaring the value in register xVal and storing it in the register xVal
        mul       xVal, xVal, x23 //Multiplying the squared value in xVal by x to cube the original x
        madd      yVal, x19, xVal, yVal //Multiplying the value stored in x19 with the value stored in xVal and adding the value stored in yVal and storing everything in yVal

        mov       xVal, x23 //Storing the current x value, stored in register x23, into xVal
        mul       xVal, xVal, xVal //Squaring the value in register xVal and storing it in the register xVal
        madd      yVal, x20, xVal, yVal //Multiplying the value stored in x20 with the value stored in xVal and adding it to the value in yVal and storing it all in yVal

        mov       xVal, x23 //Storing the current x value, stored in register x23, into xVal
        madd      yVal, x21, xVal, yVal //Multiplying the value stored in x21 with the value stored in xVal and adding the value stored in yVal and storing everything in yVal

        add       yVal, yVal, x22 //Adding the value of x22 to yVal and storing the value in yVal

        ldr       x0, =output //Loading the register x0 and storing the output into it
        mov       x1, x23 //Storing the value of x (x23) into register x1 to be printed
        mov       x2, yVal //Storing the value of y (x26) into register x2 to be printed

        cmp       yVal, x25 //Comparing the value stored in x19 (current y) to x25 (current max)
        b.gt       greater //If the value in x19 is greater than x25, go to branch greater
toprint:  //Branch to print which is called from the end of the greater branch
        mov       x3, x25 //Storing the maximum value into register x3 to be printed
        bl        printf //Printing the output text

        add       x23, x23, 1 //Incrementing the counter, and x, by 1

test:
        cmp       x23, 6  //Unconditional branch: Starting the code back at branch loop
        b.ne      top

greater:
        mov x25, yVal //Updating the maximum value in register x25 with the value in x19
        b toprint //Unconditional branch: Moving to the toprint branch after the new maximum value has been updated

done:
        ldp       x29, x30, [sp], 16
        ret
output:   .ascii "x = %li \t    y = %li \t  Maximum = %li\n" //Output text printed for every iteration of x; printing the subsequent y and current maximum value
