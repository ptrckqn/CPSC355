//Patrick Quan - 10152770
//CPSC 355
//Assignment 4

//Templates for strings to be printed
printOne: .string "Initial box values:\n"
printTwo: .string "Box #%d: origin = (%d, %d) width = %d height = %d area = %d \n"
printThree: .string "\nChanged box values:\n"

define(FALSE, 0) //FALSE = 0
define(TRUE, 1) //TRUE = 1
define(first_base_r, x19) //Base address of b1 in stack
define(second_base_r, x20) //Base address of b2 in stack
  point = 0 //Point starting address
  pX = 0 //origin.x
  pY = 4 //origin.y
  dim = 8 //Dimension starting address
  dimW = 0 //size.width
  dimH = 4 //size.height
  area = 16 //Box area starting address

  first_size = 20 //Byte size of b1
  second_size = 20 //Byte size of b2
  alloc = -(16 + first_size + second_size) & -16 //Calculating the total size to allocate from stack
  dealloc = -alloc //Calculating the total size to deallocate from stack
  first_s = 16 //Location of the b1 struct in stack
  second_s = 36 //Location of b2 struct in stack

  fp .req x29 //Setting the x29 register to FP
  lr .req x30 //Setting the x30 register to LR

  .balign 4 //Word aligned instructions
  .global main //Main function
main:
  stp     fp, lr, [sp, alloc]! //Storing FP and LR into the stack and allocating the required memory
  mov     fp, sp //Moving the SP into the FP

  add     first_base_r, fp, first_s //Setting the base in the stack for b1
  add     second_base_r, fp, second_s //Setting the base in the stack for b2

  //Calling the subroutine newBox for b1
  mov     x0, first_base_r //Passing in the location of b1 into the argument
  bl      newBox //Calling subroutine newBox
  mov     x0, second_base_r //Passing in the location of b2 into the argument
  bl      newBox //Calling subroutine newBox

  //Printing the initial box values
  adrp    x0, printOne //Storing the first print template into register x0 to be printed
  add     x0, x0, :lo12:printOne //Adding the first print template to the first 12 bits
  bl      printf //Printing the first print template

  //Box 1
  mov     x0, first_base_r //b1 address in stack
  mov     x1, 1 //Box number
  bl      printBox //Calling the subroutine printBox to print the contents of the box

  //Box 2
  mov     x0, second_base_r //b1 address in stack
  mov     x1, 2 //Box number
  bl      printBox //Calling the subroutine printBox to print the contents of the box

  //if (equal(&first, &second))
  mov     x0, first_base_r //Storing the pointer of b1 to x0
  mov     x1, second_base_r //Storing the pointer of b2 to x1
  bl      equal //Calling subroutine equal
  mov     x23, x0 //Storing the results of equal to x23
  cmp     x23, TRUE //If equal == true
  b.ne    next //If equal != true, branch to next

  //Moving the origin of b1 to (-5, 7)
  mov     x0, first_base_r //Storing the pointer of b1 to x0
  mov     x1, -5 //Storing -5 as second argument x1
  mov     x2, 7  //Storing 7 as third argument x2
  bl      move //Calling subroutine move
  //Expanding the dimensions of b2 by a factor of 3
  mov     x0, second_base_r //Storing the pointer of b2 to x0
  mov     x1, 3 //Storing 3 as the second argument x1
  bl      expand //Calling subroutine expand

next:
  //Printing the final box values
  adrp    x0, printThree //Storing the third print template into register x0 to be printed
  add     x0, x0, :lo12:printThree //Adding the third print template to the first 12 bits
  bl      printf //Printing the third print template

  //Box 1
  mov     x0, first_base_r //b1 address in stack
  mov     x1, 1 //Box number
  bl      printBox //Calling the subroutine printBox to print the contents of the box

  //Box 2
  mov     x0, second_base_r //b1 address in stack
  mov     x1, 2 //Box number
  bl      printBox //Calling the subroutine printBox to print the contents of the box

done:
  ldp     fp, lr, [sp], dealloc  //Restoring fp and lr from stack
  ret //Return function for program

//Subroutine to initialize a box
define(box, x21)
newBox:
  stp     fp, lr, [sp, alloc]! //Storing fp and lr into the stack and allocating 16 bytes
  mov     fp, sp //Moving the SP into the FP

  mov     box, x0 //Moving the starting location of the box into start register
  mov     x10, 0 //Starting x and y of the box
  mov     x11, 1 //Starting width and height of the box
  mul     x12, x11, x11 //Calculating the area of the starting box

  str     x10, [box, point + pX] //b.origin.x = 0;
  str     x10, [box, point + pY] //b.origin.y = 0;
  str     x11, [box, dim + dimW] //b.size.width = 1;
  str     x11, [box, dim + dimH] //b.size.height = 1;
  str     x12, [box, area] //b.area = 1;

  mov     x0, box //Storing box b into w0 to be returned

  ldp     fp, lr, [sp], dealloc //Restoring fp and lr from stack
  ret //returning to main

//Subroutine to move the origin of a box
move:
  stp     fp, lr, [sp, alloc]! //Storing FP and LR into the stack and allocating the required memory
  mov     fp, sp //Moving the SP into the FP

  ldr     x9, [x0, point + pX] //b.origin.x
  ldr     x10, [x0, point + pY] //b.origin.y

  add     x9, x9, x1 //b.origin.x + deltaX
  add     x10, x10, x2 //b.origin.y + deltaY

  str     x9, [x0, point + pX] //b.origin.x = b.origin.x + deltaX
  str     x10, [x0, point + pY] //b.origin.y = b.origin.y + deltaY

  ldp     fp, lr, [sp], dealloc //Restoring fp and lr from stack
  ret //returning to main

//Subroutine to expand the dimensions of the box
expand:
stp     fp, lr, [sp, alloc]! //Storing FP and LR into the stack and allocating the required memory
mov     fp, sp //Moving the SP into the FP

ldr     x9, [x0, dim + dimW] //b.size.width
ldr     x10, [x0, dim + dimH] //b.size.height

mul     x9, x9, x1 //b.origin.x * factor
mul     x10, x10, x1 //b.origin.y * factor
mul     x11, x9, x10 //b.origin.x * b.origin.y

str     x9, [x0, dim + dimW] //b.origin.x = b.origin.x * factor
str     x10, [x0, dim + dimH] //b.origin.y = b.origin.y * factor
str     x11, [x0, area] //b.origin.area = b.origin.x * b.origin.y

ldp     fp, lr, [sp], dealloc //Restoring fp and lr from stack
ret //returning to main

//Subroutine to print the contents of each box
printBox:
  stp     fp, lr, [sp, alloc]! //Storing fp and lr into the stack and allocating 16 bytes
  mov     fp, sp //Moving the SP into the FP

  mov     x9, x0
  mov     x10 ,x1

  adrp    x0, printTwo
  add     x0, x0, :lo12:printTwo
  mov     x1, x10
  ldr     x2, [x9, point + pX] //b.origin.x
  ldr     x3, [x9, point + pY] //b.origin.y
  ldr     x4, [x9, dim + dimW] //b.size.width
  ldr     x5, [x9, dim + dimH] //b.size.height
  ldr     x6, [x9, area] //b.area
  bl      printf

  ldp     fp, lr, [sp], dealloc //Restoring fp and lr from stack
  ret //returning to main

//Subroutine to determine if the boxes are completely equal
define(result, x22)
equal:
  stp     fp, lr, [sp, alloc]! //Storing fp and lr into the stack and allocating 16 bytes
  mov     fp, sp //Moving the SP into the FP

  mov     result, FALSE //Default of result is FALSE; both arguments are not equal
  //if(b1 -> origin.x == b2 -> origin.x)
  ldr     x9, [x0, point + pX] //b1.origin.x
  ldr     x10, [x1, point + pX] //b2.origin.x
  cmp     x9, x10 //Comparing b1.origin.x to b2.origin.x
  b.ne    notEqual //If they're not equal, branch to notEqual

  //if(b1 -> origin.y == b2 -> origin.y)
  ldr     x9, [x0, point + pY] //b1.origin.y
  ldr     x10, [x1, point + pY] //b2.origin.y
  cmp     x9, x10 //Comparing b1.origin.y to b2.origin.y
  b.ne    notEqual //If they're not equal, branch to notEqual

  //if(b1 -> size.width == b2 -> size.width)
  ldr     x9, [x0, dim + dimW] //b1.size.width
  ldr     x10, [x1, dim + dimW] //b2.size.width
  cmp     x9, x10 //Comparing b1.size.width to b2.size.width
  b.ne    notEqual //If they're not equal, branch to notEqual

  ldr     x9, [x0, dim + dimH] //b1.size.height
  ldr     x10, [x1, dim + dimH] //b2.size.height
  cmp     x9, x10 //Comparing b1.size.height to b2.size.height
  b.ne    notEqual //If they're not equal, branch to notEqual

  mov     result, TRUE //If all of the above statements are equal, then both boxes are equal and the result is changed to true

notEqual:
  mov     x0, result //Storing the result to x0 to be returned to main
  ldp     fp, lr, [sp], dealloc //Restoring fp and lr from stack
  ret //returning to main
