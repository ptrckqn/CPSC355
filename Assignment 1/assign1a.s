//Patrick Quan
//10152770
//CPSC 355
//Assignment 1

.global main
main:
          stp       x29, x30, [sp, -16]
          mov       x29, sp

          mov       x23, -6 //Storing -6 into register x23. x23 is used as the counter for the loop, as well as the x in the equation
          mov       x25, -999 //Register x25 used to store the maximum value. Initially set to -999
loop:
          cmp       x23, 6 //Comparing the value stored in register x19 to 6. The range of the x values is -6 to 5.
          beq       done //Conditional branch: If the above comparison is equal then the code will move to branch 'done' and omit the loop

          //Storing all of the constants from the equation y = -5x^3 - 31x^2 + 4x + 31 into registers x19 to x22
          mov       x19, -5 //Storing -5 into register x19
          mov       x20, -31 //Storing 31 into register x20
          mov       x21, 4 //Storing 4 into register x21
          mov       x22, 31 //Storing 31 into register x22

          mov       x24, x23 //Storing the current x value, stored in register x23, into x24
          mul       x24, x24, x24 //Squaring the value in register x24 and storing it in the register x24
          mul       x24, x24, x23 //Multiplying the squared value in x24 by x to cube the original x
          mul       x19, x19, x24 //Multiplying the value stored in x19 with the value stored in x24 and storing the value in x19

          mov       x24, x23 //Storing the current x value, stored in register x23, into x24
          mul       x24, x24, x24 //Squaring the value in register x24 and storing it in the register x24
          mul       x20, x20, x24 //Multiplying the value stored in x20 with the value stored in x24 and storing the value in x20

          mov       x24, x23 //Storing the current x value, stored in register x23, into x24
          mul       x21, x21, x24 //Multiplying the value stored in x21 with the value stored in x24 and storing the value in x21

          add       x19, x19, x20 //Subtracting the value of x20 from x19 and storing it in x19

          add       x19, x19, x21 //Adding the value of x21 to x19 and storing it in x19

          add       x19, x19, x22 //Adding the value of x22 to x19 and storing the value in x19

          ldr       x0, =output //Loading the register x0 and storing the output into it
          mov       x1, x23 //Storing the value of x (x23) into register x1 to be printed
          mov       x2, x19 //Storing the value of y (x19) into register x2 to be printed

          cmp       x19, x25 //Comparing the value stored in x19 (current y) to x25 (current max)
          b.gt       greater //If the value in x19 is greater than x25, go to branch greater
toprint:  //Branch to print which is called from the end of the greater branch
          mov       x3, x25 //Storing the maximum value into register x3 to be printed
          bl        printf //Printing the output text

          add       x23, x23, 1 //Incrementing the counter, and x, by 1

          b         loop //Unconditional branch: Starting the code back at branch loop

greater:
          mov x25, x19 //Updating the maximum value in register x25 with the value in x19
          b toprint //Unconditional branch: Moving to the toprint branch after the new maximum value has been updated

done:
          ldp       x29, x30, [sp], 16
          ret
output:   .ascii "x = %li \t    y = %li \t  Maximum = %li\n" //Output text printed for every iteration of x; printing the subsequent y and current maximum value
