//Patrick Quan - 10152770
//CPSC 355
//Assignment 5

queuesize = 8     //queuesize = 8
MODMASK = 0x7
FALSE = 0         //false = 0
TRUE = 1          //true = 1

//Setting up the head and tail registers
  head_r    .req    x19
  tail_r    .req    x20
  queue_r   .req    x25

//Initializing global variables
  .data
            .global   head_m         //head_m is global
  head_m:   .word   -1      //head_m = -1
            .global   tail_m        //tail is global
  tail_m:   .word   -1    //tail_m = -1

  .bss                  //Uninitialized variables
            .global   queue_m       //queue_m is global
  queue_m:  .skip     queuesize * 4    //queue_m is allocated to store word sized data

//Format string templates
  .text
fmt1: .string "\nQueue underflow! Cannot dequeue from an empty queue. \n"
fmt2: .string "\nQueue overflow! Cannot enqueue value into a full queue.\n"
fmt3: .string "\nEmpty queue\n"
fmt4: .string "\nCurrent queue contents:"
fmt5: .string " %d"
fmt6: .string " <-- head"
fmt7: .string " <-- tail"
fmt8: .string "\n"

//Int enqueue(int value) method
    .balign 4                 //Instructions are word aligned
    .global enqueue              //enqueue is global
enqueue:
    stp     x29, x30, [sp, -16]!  //Storing FP and LR into the stack and allocating the required memory
    mov     x29, sp               //Moving the SP into the FP

    mov     w22, w0               //Storing the input value into w22

    bl      queueFull              //Branch link to queueFull
    cmp     w0, FALSE             //If result of queueFull = false
    b.eq    elseEnqueue          //Branch to elseEnqueue

    adrp    x0, fmt2             //Add fmt2 to first print arg
    add     x0, x0, :lo12:fmt2    //Setting fmt2 to lower 12b
    bl      printf                 //Branch link to printf
    b       doneEnqueue            //Unconditional branch to doneEnqueue

elseEnqueue:
    bl      queueEmpty        //Branch link to queueEmpty
    cmp     w0, FALSE         //If result of queueEmpty = false
    b.eq    elseEnqueueTwo   //Branch to elseEnqueueTwo

    mov     w9, 0                 //w9 = 0

    adrp    head_r, head_m         //setting up head_r as head_m
    add     head_r, head_r, :lo12:head_m //loading to lower 12 bits
    str     w9, [head_r]          //head = 0

    adrp    tail_r, tail_m         //setting up head_r as head_m
    add     tail_r, tail_r, :lo12:tail_m //loading to lower 12 bits
    str     w9, [tail_r]          //tail = 0

    ldr     w24, [tail_r]          //load w24 = current tail_r

    adrp    queue_r, queue_m      //load queue_r with queue_m
    add     queue_r, queue_r, :lo12:queue_m //set to lower 12 bits
    str     w22, [queue_r, w24, SXTW 2]  //store w22 into the queue

    b       doneEnqueue           //Unconditional branch to nextEnqueue

elseEnqueueTwo:
    adrp    tail_r, tail_m         //setting up tail_r as tail_m
    add     tail_r, tail_r, :lo12:tail_m //loading to lower 12 bits
    ldr     w24, [tail_r]          //load w24 = current tail_r

    add     w24, w24, 1           //++tail
    str     w24, [tail_r]          //++tail

    adrp    queue_r, queue_m      //load queue_r with queue_m
    add     queue_r, queue_r, :lo12:queue_m //set to lower 12 bits
    str     w22, [queue_r, w24, SXTW 2]  //store w22 into the queue


doneEnqueue:
    ldp     x29, x30, [sp], 16    //Restoring fp and lr from stack
    ret                       //Returning to caller


//int dequeue() method
    .balign 4                 //Instructions are word aligned
    .global dequeue               //dequeue is global
dequeue:
    stp       x29, x30, [sp, -16]!  //Storing FP and LR into the stack and allocating the required memory
    mov       x29, sp               //Moving SP into FP

    bl        queueEmpty             //branch link to queueEmpty
    cmp       w0, FALSE             //If the queue is not empty
    b.eq      elseDequeue           //branch to elseDequeue

    adrp      x0, fmt1             //Setting fmt1 to 1st print arg
    add       x0, x0, :lo12:fmt1    //set fmt1 as lower 12 bit
    bl        printf                 //Branch link to printf
    mov       w0, -1                 //Setting return value to -1
    b         doneDequeue                    //branch to doneDequeue

elseDequeue:
    adrp      head_r, head_m         //setting head_r = head_m
    add       head_r, head_r, :lo12:head_m //set lower 12bit
    ldr       w9, [head_r]          //w9 = head

    adrp      tail_r, tail_m         //setting tail_r = tail_m
    add       tail_r, tail_r, :lo12:tail_m //set lower 12bit
    ldr       w10, [tail_r]          //w10 = tail

    adrp      queue_r, queue_m      //load the queue_r from queue_m
    add       queue_r, queue_r, :lo12:queue_m //lower 12 bit
    ldr       w11, [queue_r, w9, SXTW 2] //w10 = queue[head]
    mov       w0, w11           //Setting the return value to queue[head]


    cmp       w9, w10           //Comparing the head and tail
    b.eq      elseDequeueTwo             //If head == tail branch to elseDequeueTwo

    add       w9, w9, 1        //++head
    and       w9, w9, MODMASK     // & MODMASK
    str       w9, [head_r]       //head = w9

    b         doneDequeue       //branch to doneDequeue

elseDequeueTwo:
    mov       w12, -1          //w12 = -1
    str       w12, [head_r]   //head = -1
    str       w12, [tail_r]   //tail = -1

doneDequeue:
    ldp       x29, x30, [sp], 16      //Restoring fp and lr from stack
    ret                         //Returning to caller


//int queueFull() method
queueFull:
    stp       x29, x30, [sp, -16]!    //Storing FP and LR into the stack and allocating the required memory
    mov       x29, sp                 //Moving the SP into the FP

    adrp      head_r, head_m          //Loading head_r
    add       head_r, head_r, :lo12:head_m  //Lower 12 bits
    ldr       w9,[head_r]             //w9 = head

    adrp      tail_r, tail_m        //Loading tail_r
    add       tail_r, tail_r, :lo12:tail_m //Lower 12 bits
    ldr       w10,[tail_r]          //w10 = tail

    add       w10, w10, 1
    and       w10, w10, MODMASK

    cmp       w9, w10             //Comparing head to tail
    b.ne      elseQueueFull         //If they are not equal, branch to elseQueueFull
    mov       w0, TRUE          //Set return value to true
    b         doneQueueFull     //Branch to doneQueueFull

elseQueueFull:
    mov       w0, FALSE         //Set return value to false

doneQueueFull:
    ldp       x29, x30, [sp], 16     //Restoring fp and lr from stack
    ret                            //Returning to caller

//int queueEmpty() method
queueEmpty:
    stp       x29, x30, [sp, -16]!     //Storing FP and LR into the stack and allocating the required memory
    mov       x29, sp                 //Moving the SP into the FP

    adrp      head_r, head_m           //set head_r as head_m
    add       head_r, head_r, :lo12:head_m //set to lower 12bits
    ldr       w9,[head_r]             //load w9 as current head
    cmp       w9, -1                 //if w9 = -1, then the queue is empty
    b.ne      elseQueueEmpty                 //if w9 != -1 branch to elseQueueEmpty
    mov       w0, TRUE                //w0 = true
    b         doneQueueEmpty          //branch to doneQueueEmpty

elseQueueEmpty:
    mov       w0, FALSE               //w0 = false

doneQueueEmpty:
    ldp     x29, x30, [sp], 16      //Restoring fp and lr from stack
    ret                             //Returning to caller

//void display() method
.balign 4                       //Instructions are word aligned
.global display                 //display() is global
display:
    stp       x29, x30, [sp, -16]!    //Storing FP and LR into the stack and allocating the required memory
    mov       x29, sp                 //Moving SP into FP
    mov       w9, 0                  //w9 = 0
    bl        queueEmpty               //Branch link to queueEmpty
    cmp       w0, FALSE               //Comparing if queueEmpty returned false
    b.eq      elseDisplay              //If the queue is not empty branch to elseDisplay
    adrp      x0, fmt3               //Setting fmt3 to the 1st argument
    add       x0, x0, :lo12:fmt3      //lower 12bits
    bl        printf                   //Branch link to printf
    b         doneDisplay               //Unconditional branch to doneDisplay

elseDisplay:
    adrp      head_r, head_m           //loading head_r
    add       head_r, head_r, :lo12:head_m //setting lower 12 bits
    ldr       w10, [head_r]            //w10 = head

    mov       w21, w10                //i = head

    adrp      tail_r, tail_m           //loading tail_r
    add       tail_r, tail_r, :lo12:tail_m //setting lower 12 bits
    ldr       w11, [tail_r]            //w11 = tail

    mov       w26, 0                //j = 0
    sub       w27, w11, w10         //count = tail - head
    add       w27, w27, 1           //count = count + 1

    cmp       w27, 0        //Comparing count to 0
    b.gt      elseDisplayTwo        //If greater than queuesize, branch to elseDisplayTwo
    add       w27, w27, queuesize //count += queuesize

elseDisplayTwo:
    adrp      x0, fmt4               //Setting fmt4 as the first argument
    add       x0, x0, :lo12:fmt4      //set lower 12bits
    bl        printf                   //Branch link to printf

    adrp      queue_r, queue_m           //loading queue_r
    add       queue_r, queue_r, :lo12:queue_m //setting lower 12 bits

    b         test                  //branch to test of the for loop

for:
    adrp        x0, fmt8               //Setting fmt8 as the first argument
    add         x0, x0, :lo12:fmt8      //set lower 12bits
    bl          printf                //Branch link to printf

    adrp      x0, fmt5               //Setting fmt5 as the first argument
    add       x0, x0, :lo12:fmt5      //set lower 12bits

    ldr       w1, [queue_r, w21, SXTW 2] //Setting queue[i] as the second argument
    bl        printf                //Branch link to printf

    cmp       w21, w10              //Comparing i to head
    b.ne      nextDisplay           //If i != head branch to nextDisplay

    adrp      x0, fmt6               //Setting fmt6 as the first argument
    add       x0, x0, :lo12:fmt6      //set lower 12bits
    bl        printf                //Branch link to printf

nextDisplay:
    add         w21, w21, 1           //++i
    and         w21, w21, MODMASK     // i & MODMASK
    add         w26, w26, 1           //j++

test:
    cmp         w26, w27        //Comparing j to count
    b.lt        for               //If less than count, branch to for

    adrp      x0, fmt7               //Setting fmt7 as the first argument
    add       x0, x0, :lo12:fmt7      //set lower 12bits
    bl        printf                //Branch link to printf

doneDisplay:
    ldp       x29, x30, [sp], 16 //Restoring fp and lr from stack
    ret                     //Returning to caller
