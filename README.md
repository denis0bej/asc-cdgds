This was an assignment for **Computer Systems Architecture** (ASC), in which I had to simulate a unidimensional and a bidimensional storage system in *Assembly Intel x86*. It's basically a huge array of numbers that is manipulated within certain criteria.
*Unidimensional:*
ADD descriptor size - Adds a certain **descriptor** to the array wich is of size **size** and prints the position (Ex. 10022000 --*ADD 3 2*-> 13322000 *3: (1,2)* or another example: 10022000 --*ADD 3 3*-> 10022333 *3: (5,7)*)
GET descriptor - Returns the start and end coordonates of the **descriptor** 
DELETE descriptor - Removes all appearences of the **descriptor** 
DEFRAGMENTATION - Moves all relevant descriptors to the left to fill all the gaps created by the DELETE command (Ex. 10220030 --*DEFRAGMENTATION*-> 12230000)
