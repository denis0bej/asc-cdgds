This was an assignment for **Computer Systems Architecture** (ASC), in which I had to simulate a unidimensional and a bidimensional storage system in *Assembly Intel x86*. It's basically a huge array of numbers that is manipulated within certain criteria.<br><br>
*Unidimensional:* <br>
ADD descriptor size - Adds a certain **descriptor** to the array wich is of size **size** and prints the position. <br>
-Example1: 10022000 --*ADD 3 2*-> 13322000 *3: (1,2)* <br>
-Example2: 10022000 --*ADD 3 **3***-> 10022333 *3: (5,7)* <br><br>
GET descriptor - Returns the start and end coordonates of the **descriptor** <br>
-Example1: 10022000 --*GET 2*-> 2: (3,4) <br><br>
DELETE descriptor - Removes all appearences of the **descriptor** <br>
-Example1: 10022440 --*DELETE 2*-> 10022440 <br><br>
DEFRAGMENTATION - Moves all relevant descriptors to the left to fill all the gaps created by the DELETE command <br>
-Example: 10220030 --*DEFRAGMENTATION*-> 12230000)<br><br>

Bidimensional is a bit more complex but I can explian it to you at the interview. 😊

