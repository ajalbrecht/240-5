#*****************************************************************************************************************************
# Program name: "Find_Area".  This program allow the user to input the sides of a triangle and compute its are in both       *
# decimal and hexadecimal while filtering for invalid inputs and side legnths. Copyright (C) 2020 AJ Albrecht                *
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License  *
# version 3 as published by the Free Software Foundation.                                                                    *
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied         *
# Warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.     *
# A copy of the GNU General Public License v3 is available here:  <https://www.gnu.org/licenses/>.                           *
#*****************************************************************************************************************************
#=======1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3**
#
#Author information
#Author name: AJ Albrecht
#Author email: ajalbrecht@fullerton.edu
#
#Program information
#  Program name: Find_Area
#  Programming languages: C, C++, x86 Assembly and Bash
#  Date program began:     2020-Nov-12
#  Date program completed: 2020-Nov-21
#  Date comments upgraded: 2020-Nov-25
#  Files in this program: r.sh triangle.c area.asm isfloat.cpp
#  Status: Complete. No bugs found after testing.
#
#References for this program
#  Albrecht, Find_Circumference, version 1
#  Albrecht, Least_to_Greatest, version 1
#  Haddad, isfloat, version 2.
#
#Purpose
#  Compute the area of a triangle while also providing its circumference in hexadecimal.
#
#This file
#   File name: r.sh
#   Language: Bash
#   Max page width: 132 columns
#   Assemble: sh r.sh
#   Link: g++ -m64 -no-pie -o Find_Area.out -std=c17 triangle.o area.o isfloat.o
#   Optimal print specification: 132 columns width, 7 points, monospace, 8½x11 paper
#
#Purpose of this file
#   Compile and run the program.

#!/bin/bash

# Compile all individual filles togeather.
# The order of compelation is based on which file is needed first.
gcc -c -Wall -m64 -no-pie -o triangle.o triangle.c -std=c17
nasm -f elf64 -l area.lis -o area.o area.asm
g++ -c -Wall -m64 -std=c++14 -no-pie -o isfloat.o isfloat.cpp

# Assemble files togeather
g++ -m64 -no-pie -o Find_Area.out -std=c17 triangle.o area.o isfloat.o

#Run the program
./Find_Area.out
