//Patrick Quan - 10152770
//CPSC 355
//Assignment 3


//Templates for the strings to be printed
printOne: .string "v[%d] : %d\n"  //Value of each index in the array
printTwo: .string "\nSorted Array:\n"
printThree: .string "v[%d]: %d\n" //Value of each sorted index in the array

size = 50 //Constant for the size of the array
ia_base = 16 //Base address of the array in the frame record
ia_size = size * 4 //Total number of elements
i_s = 216 //Index i location in memory
j_s = 220 //Index j location in memory
i_size = 4 //Bytes used in the i index
j_size = 4 //Bytes used in j index
alloc = -(16 + i_size + j_size + ia_size) & -16 //Variable used to allocate the memory needed
dealloc = -alloc //Variable used to return memory back to the original state

fp .req x29 //Setting the x29 register to FP
lr .req x30 //Setting the x30 register to LR

define(i_r, w19) //counter i alias for register w19
define(j_r, w20) //counter j alias for register w20
define(ia_r, w21) //array alias for register w21
define(temp_r, w22) //temp variable alias for register w22
define(vJOne_r, w23) //counter used to represent variable j alias for register w23
define(vJTwo_r, w24) //counter used to represent variable j alias for register w23

.balign 4 //Word aligned instructions

.global main //Main function

main:
          stp         fp, lr, [sp, alloc]! //Storing FP and LR into the stack and allocating the required memory
          mov         fp, sp //Moving the FP into the sp
          add         x28, fp, ia_base //x28 = FP + ia_base
          mov         i_r, 0 //Setting the index i to 0
          str         i_r, [fp, i_s] //Storing index i to the stack

          b           testOne //Unconditional branch to the first test

//Loop used to generate random numbers for array elements and storing them into stack memory
forLoopOne:
          bl          rand //Calling random function rand
          and         ia_r, w0, 0xFF //Storing rand() and 0xFF into the array
          adrp        x0, printOne //Storing the first print template into register x0 to be printed
          add         w0, w0, :lo12:printOne	//Adding the first print template to the first 12 bits
          mov         w1, i_r //Storing the index i into register w1 to be printed
          mov         w2, ia_r //Storing the array at index i into register w2 to be printed
          bl          printf //Printing the first print template; unsorted array

          //Storing the array at index i into memory
          str         ia_r, [x28, i_r, SXTW 2] //sStoring the array element at index i into memory
          add         i_r, i_r, 1 //Incrementing the index i by 1
          str         i_r, [fp,i_s] //Storing the index i into stack memory

//Test to determine if i is less than array size
testOne:
          cmp         i_r, size //Comparing the index i to the maximum size of the array
          b.lt        forLoopOne //If index i is less than the size of the array, branch to the first for loop
          mov         i_r, size - 1 //Setting the index i to SIZE - 1 (49)
          str         i_r, [fp, i_s] //Storing the index i into stack memory

          b           testTwo //Unconditional branch to the second test

  //First loop for insertion sorting
forLoopTwo:
          mov         j_r, 1 //Setting the index j to 1
          str         j_r, [fp, j_s] //Storing the index j into stack memory
          b           testThree //Unconditional branch to the third test

//Nested loop for insertion sorting
forLoopThree:
          sub         j_r, j_r, 1 //Decrementing index j by 1
          ldr         vJOne_r, [x28, j_r, SXTW2] //Loading from stack memory at index j; which is v[j-1] in the C code
          add         j_r, j_r, 1 //Incrementing index j by 1
          ldr         vJTwo_r, [x28, j_r, SXTW2] //Loading from stack memory at index j; which is v[j] in the C code
          cmp         vJOne_r, vJTwo_r //Comparing vJOne_r to vJTwo_r
          b.le        else //Conditional branch to else if vJOne_r v[j-1] is less than vJTwo_r v[j]

          //If vJOne_r is greater than vJTwo_r then they must be swapped (insertion sorting)
          add         sp, sp, -4 & -16 //Allocating 4 bytes of memory for the temp Variable
          mov         temp_r, vJOne_r //Storing the value of v[j-1] into temp_r
          str         temp_r, [fp, -4] //Storing the temporary variable into stack memory
          ldr         j_r, [fp, j_s] //Loading the j index from stack memory
          sub         j_r, j_r, 1 //Decrementing j by 1
          str         vJTwo_r, [x28, j_r, SXTW 2] //Storing the element at vJTwo_r (v[j]) into stack memory at index j (v[j - 1])
          add         j_r, j_r, 1 //Incrementing j by 1
          str         temp_r, [x28, j_r, SXTW 2] //Storing the element at temp_r (v[j - 1]) into stack memory at index j (v[j])
          add         sp, sp, 16 //Deallocating memory for the temp variable

//Else branch if v[j-1] is less than v[j]. ie these two elements are already sorted
else:
          ldr         j_r, [fp, j_s] //Loading index j from stack memory
          add         j_r, j_r, 1 //Incrementing index j by 1
          str         j_r, [fp, j_s] //Storing index j into stack memory

testThree:
          ldr         j_r, [fp, j_s] //Loading index j from stack memory
          ldr         i_r, [fp, i_s] //Loading index i from stack memory
          cmp         j_r, i_r //Comparing index j and index i
          b.le        forLoopThree //If index j is less than index i, branch to the third for loop
          sub         i_r, i_r, 1 //Decrementing i by 1
          str         i_r, [fp, i_s] //Storing index i into stack memory

testTwo:
          ldr         i_r, [fp, i_s] //Loading index i from stack memory
          cmp         i_r, 0 //Comparing index i to 0
          b.ge        forLoopTwo //If index i is greater than 0, branch to the second for loop

          //Preparing to print the sorted loop
          adrp        x0, printTwo //Storing the second print template into register x0 to be printed
          add         x0, x0, :lo12:printTwo	//Adding the second print template to the first 12 bits
          bl          printf //Printing the second print template; sorted array header

          mov         i_r, 0 //Storing 0 into the index i
          str         i_r, [fp, i_s] //Storing index i into stack memory
          b           testFour //Unconditional branch to testFour

//Printing the elements of the sorted array
printSorted:
          ldr         i_r, [fp, i_s] //Loading index i from stack memory
          ldr         ia_r, [x28, i_r, SXTW 2] //Loading the element of the array at index i from the stack

          adrp        x0, printThree //Storing the third print template into register x0 to be printed
          add         x0, x0, :lo12:printThree	//Adding the third print template to the first 12 bits
          mov         w1, i_r //Storing the index i into register w1 to be printed
          mov         w2, ia_r //Storing the element of the array at index i into register w2 to be printed
          bl          printf //Printing the third print template; sorted array header

          ldr         i_r, [fp, i_s] //Loading index i from stack memory
          add         i_r, i_r, 1 //Incrementing index i by 1
          str         i_r, [fp, i_s] //Storing index i into stack memory

testFour:
          cmp         i_r, size //Comparing index i to the size of the array
          b.lt        printSorted //If index i is less than the size of the array, branch to printSorted

//Returning memory used for FP
done:
          ldp         fp, lr, [sp], dealloc //Restoring fp and lr from stack
          ret //Return function for program
