;*****************************************************************************************************************************
; Program name: "Find_Area".  This program allow the user to input the sides of a triangle and compute its are in both       *
; decimal and hexadecimal while filtering for invalid inputs and side legnths. Copyright (C) 2020 AJ Albrecht                *
; This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License  *
; version 3 as published by the Free Software Foundation.                                                                    *
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied         *
; Warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.     *
; A copy of the GNU General Public License v3 is available here:  <https://www.gnu.org/licenses/>.                           *
;*****************************************************************************************************************************
;=======1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3**
;
;Author information
;Author name: AJ Albrecht
;Author email: ajalbrecht@fullerton.edu
;
;Program information
;  Program name: Find_Area
;  Programming languages: C, C++, x86 Assembly and Bash
;  Date program began:     2020-Nov-12
;  Date program completed: 2020-Nov-21
;  Date comments upgraded: 2020-Nov-25
;  Files in this program: r.sh triangle.c area.asm isfloat.cpp
;  Status: Complete. No bugs found after testing.
;
;References for this program
;  Albrecht, Find_Circumference, version 1
;  Albrecht, Least_to_Greatest, version 1
;  Haddad, isfloat, version 2.
;
;Purpose
;  Compute the area of a triangle while also providing its circumference in hexadecimal.
;
;This file
;   File name: area.asm
;   Language: X86 with Intel syntax
;   Max page width: 132 columns
;   Assemble: nasm -f elf64 -l area.lis -o area.o area.asm
;   Link: g++ -m64 -no-pie -o Find_Area.out -std=c17 triangle.o area.o isfloat.o
;   Optimal print specification: 132 columns width, 7 points, monospace, 8½x11 paper
;
;Purpose of this file
;   Compute the area of the triangle the user provides. The file will keep asking the user for inputs until 3 response work together.

global triangle

segment .data
stringoutputformat db "%s", 0 ; writes
stringinputformat db "%s",0 ; inputs
floatform db "%lf", 0 ; allows for decimal outputs
prompt db "Enter the floating point lengths of the 3 sides of your triangle.", 10, 10, 0
side1 db "Side 1: ", 0
side2 db "Side 2: ", 0
side3 db "Side 3: ", 0
allsides db 10, "These values were received: %lf %lf %lf", 10, 10, 0
error db "Invalid input(s) were detected. The is an invalid character(s) in your response or your sides do not create a triangle.", 10, 0
area db "The area of this triangle is %1.7lf square meters", 10, 10, 0

segment .bss
; There are no arrays in this program

segment .text
triangle:

; Declare the names of programs called from this X86 source file, but whose own source code is not in this file.
extern printf
extern scanf
extern isfloat
extern atof

; Back up the general purpose registers for the sole purpose of protecting the data of the caller.
push rbp                                                    ;Backup rbp
mov  rbp,rsp                                                ;The base pointer now points to top of stack
push rdi                                                    ;Backup rdi
push rsi                                                    ;Backup rsi
push rdx                                                    ;Backup rdx
push rcx                                                    ;Backup rcx
push r8                                                     ;Backup r8
push r9                                                     ;Backup r9
push r10                                                    ;Backup r10
push r11                                                    ;Backup r11
push r12                                                    ;Backup r12
push r13                                                    ;Backup r13
push r14                                                    ;Backup r14
push r15                                                    ;Backup r15
push rbx                                                    ;Backup rbx
pushf                                                       ;Backup rflags
push r15                                               ;Now the number of pushes is even

; Program register usage list
; xmm15 stores triangle side 1 and later result of semi-perimeter minus side 1
; xmm14 stores triangle side 2 and later result of semi-perimeter minus side 2
; xmm13 stores triangle side 3 and later result of semi-perimeter minus side 3
; xmm12 stores added and subtracted sides for checking purpose and later stores the final answer
; xmm11 stores semi-perimeter
; xmm10 stores the value of 0 for comparisons and later stores a copy of stores semi-perimeter, so it is not lost while doing mathematical operations
; xmm9 stores the value of 2, so the program can convert the perimeter to the semi perimeter
; xmm8 stores a side of the triangle before it is inputted into xmm15, xmm14 or xmm13
; r15 is used to keep on the boundary
; r14 is used to tell how many sides have currently been inputted
; r13 is used to determine if the integer is a float


; ---------- Inform the user on how to use the program ----------
; Ask the user for a floating point input.
mov qword rdi, stringoutputformat
mov qword rsi, prompt
mov qword rax, 0
call printf

; -------------------- Central loop for inputting sides --------------------

; ---------- Write the correct input header ----------
mov r14, 0  ; Start asking for the first side
askAgain:   ; Return point for loop to restart again if another user input is needed

; Write side1:, side2: or side3: depending on what side the user is on.
; If side 1 is in already, then side 2 or 3 needs to be inputted.
cmp r14, 0
jne one_side_has_already_been_inputted

   ; Write side 1 header
   mov qword rdi, stringoutputformat
   mov qword rsi, side1
   mov qword rax, 0
   call printf
   jmp main_block

; If side 2 has also been inputted, then side 3 is what we need to input.
one_side_has_already_been_inputted:
cmp r14, 1
jne two_sides_has_already_been_inputted

   ; Write side 2 header
   mov qword rdi, stringoutputformat
   mov qword rsi, side2
   mov qword rax, 0
   call printf
   jmp main_block

; Since side 1 and two must have already been inputted, then it has to be side 3.
two_sides_has_already_been_inputted:

   ; Write side 3 header
   mov qword rdi, stringoutputformat
   mov qword rsi, side3
   mov qword rax, 0
   call printf

; ---------- Taken in the user response, and verify that it is a numerical input ----------
main_block:
; Take in the users response to a side.
mov qword rdi, stringinputformat
push qword 0
mov qword rsi, rsp
mov qword rax, 0
call scanf

; Verify that side is a float.
mov rax, 0
mov rdi, rsp       ; pointer to stack, which contains r13s
call isfloat      ; call is float function to verify if the number is a float.
mov r13, rax
cmp r13, 0   ;
je invalid

; Convert the string to a float.
mov rax, 0
mov rdi,rsp     ; pointer to the stack
call atof
movsd xmm8, xmm0
pop r15
inc r14

; ---------- Inform the user on how to use the program ----------
; check what side the user is on, then put in the float into the correct register.
; if the user has input side 1, move on to check for side 2 and 3
cmp r14, 1
jne leg2

   ; Put side 1 into xmm15.
   movsd xmm15, xmm8
   jmp askAgain

; If the user has input side 2, that has to mean they are inputting side 3
leg2:
cmp r14, 2
jne leg3

   ; Put side 2 into xmm14
   movsd xmm14, xmm8
   jmp askAgain

; If it was not side 1 or 2, it must be side 3
leg3:

   ; Put side 3 into xmm13
   movsd xmm13, xmm8
   ; that was the last side, check to see if they all combined make a triangle now!

; ---------- Make sure the 3 input together make up a triangle. ----------
; If the one of the sides is larger then the other two, ask the user to input new information, because that would mean the figure is not a triangle
; --- While doing mathematical computations, side 1, 2 and 3 refers to a, b and c respectively to avoid confusion. ---

; Move the IEEE754 value of 0 to xmm10, so the result can be compared to the number zero.
mov r15, 0x0000000000000000 ; 0 in hexadecimal
push r15
movsd xmm10, [rsp]
pop r15

; Move the IEEE754 value of 0 to xmm12, so the total counter starts with the correct current total.
mov r15, 0x0000000000000000 ; 0 in hexadecimal
push r15
movsd xmm12, [rsp]
pop r15

; Compare side 1 to see if it is larger than other sides. ( a > b + c ) or ( -a +b +c )
subsd xmm12, xmm15  ; subtract side a, so if it is larger, the comparison will be negative
addsd xmm12, xmm14  ; add side b to positive side of check
addsd xmm12, xmm13  ; add side c to positive side of check

   ; If side 1 is larger than the other sides, ask the user to try again.
   comisd xmm12, xmm10
   jbe invalidNoPop

; Compare side 2 to see if it is larger than other sides. ( a + c < b ) or ( -a +b -c )
subsd xmm12, xmm13 ; remove side c from check
subsd xmm12, xmm13 ; subtract side c, so if and c and a combined are smaller then b, the comparison will be positive

   ; If side 2 is larger than the other sides, ask the user to try again.
   comisd xmm12, xmm10
   jae invalidNoPop

; Compare side 3 to see if it is larger than other sides. ( c > a + b) or ( +a +b -c )
addsd xmm12, xmm15 ; remove side a from the check
addsd xmm12, xmm15 ; add side b,  so if and a and b combined are smaller then c, the comparison will be negative

   comisd xmm12, xmm10
   jbe invalidNoPop
   jmp calculate ; The 3 sides are ready for calculation!

; ===== error message handler ======
invalid:
pop r15
invalidNoPop:
mov qword rdi, stringoutputformat
mov qword rsi, error
mov qword rax, 0
call printf
mov r14, 0
jmp askAgain
; ==================================
; ------------------------------------------------------------------ ; The loop has ended

; ---------- Display all sides. ----------
calculate:
push qword 0
mov rax, 3
mov rdi, allsides
movsd xmm0, xmm15
movsd xmm1, xmm14
movsd xmm2, xmm13
call printf
pop r15

; ---------- Calculate the response. ----------
; begin to mathematically calculate area of triangle with Heron's formula
; sqrt[s(s-a)(s-b)(s-c)]    s = semi-perimeter
; --- While doing mathematical computations, side 1, 2 and 3 refers to a, b and c respectively to avoid confusion. ---


; Move the IEEE754 value of 0 to xmm11, so it does not add a random number into the semi-perimeter.
mov r15, 0x0000000000000000 ; 0 in hexadecimal
push r15
movsd xmm11, [rsp]
pop r15

; Move the IEEE754 value of 1 to xmm12, so it can be multiplied by first component correctly.
mov r15, 0x3FF0000000000000 ; 1 in hexadecimal
push r15
movsd xmm12, [rsp]
pop r15

; Move the IEEE754 value of 2 to xmm9, so the perimeter can be divided by two to get the semi perimeter.
mov r15, 0x4000000000000000 ; 2 in hexadecimal
push r15
movsd xmm9, [rsp]
pop r15

; Calculate semi-perimeter.
addsd xmm11, xmm15 ; add side a to the semi perimeter count
addsd xmm11, xmm14 ; add side b to the semi perimeter count
addsd xmm11, xmm13 ; add side c to the semi perimeter count
divsd xmm11, xmm9  ; divide the total perimeter by two to get the semi perimeter
movsd xmm10, xmm11 ; make a copy of the semi perimeter, so it is not lost.

; Calculate (s-a) which will be left in r15.
subsd xmm11, xmm15 ; actually subtract s-a
movsd xmm15, xmm11 ; put that sides semi-perimeter minus side operation back into its original register
movsd xmm11, xmm10 ; restore the semi-perimeter back to its original register

; Calculate (s-b) which will be left in r14.
subsd xmm11, xmm14 ; actually subtract s-b
movsd xmm14, xmm11 ; put that sides semi-perimeter minus side operation back into its original register
movsd xmm11, xmm10 ; restore the semi-perimeter back to its original register

; Calculate (s-c) which will be left in r13.
subsd xmm11, xmm13 ; actually subtract s-c
movsd xmm13, xmm11 ; put that sides semi-perimeter minus side operation back into its original register
movsd xmm11, xmm10 ; restore the semi-perimeter back to its original register

; Multiply all four components [s(s-a)(s-b)(s-c)] of the answer together.
mulsd xmm12, xmm10 ; multiply s into the formula
mulsd xmm12, xmm15 ; multiply a into the formula
mulsd xmm12, xmm14 ; multiply b into the formula
mulsd xmm12, xmm13 ; multiply c into the formula

; Take the square root of the 4 components combined sqrt[xmm12]
sqrtsd xmm12, xmm12

; xxmm12 now holds the area of the triangle!

; ---------- Display the and pass on the results ---------
; Display the result to the user.
push qword 0
mov rax, 1
mov rdi, area
movsd xmm0, xmm12
call printf
pop r15

; Store the answer into xmm0 so it can be returned to the driver.
movsd xmm0, xmm12

; Restore the original values to the general registers before returning to the caller.
pop r15                                                     ;Remove the extra -1 from the stack
popf                                                        ;Restore rflags
pop rbx                                                     ;Restore rbx
pop r15                                                     ;Restore r15
pop r14                                                     ;Restore r14
pop r13                                                     ;Restore r13
pop r12                                                     ;Restore r12
pop r11                                                     ;Restore r11
pop r10                                                     ;Restore r10
pop r9                                                      ;Restore r9
pop r8                                                      ;Restore r8
pop rcx                                                     ;Restore rcx
pop rdx                                                     ;Restore rdx
pop rsi                                                     ;Restore rsi
pop rdi                                                     ;Restore rdi
pop rbp                                                     ;Restore rbp

; Pass back the result of the area computation to the main file.
ret
