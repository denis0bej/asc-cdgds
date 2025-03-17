This was an assignment for Computer Systems Architecture (ASC), in which I had to simulate a unidimensional and a bidimensional storage system in Assembly Intel x86. It's basically a huge array of numbers that is manipulated within certain criteria.<br>
In this project, I:<br>

    learned to efficiently manipulate large amounts of data using very limited resources.<br>
    got accustomed to writing, debugging, and compiling code in Assembly Intel x86.<br>
    successfully followed strict instructions on what the output of every command had to be.<br><br>

Unidimensional:

ADD descriptor size – Adds a certain descriptor to the array, which is of size size, and prints the position. <br>

    Example 1: 10022000 -- ADD 3 2 -> 13322000 3: (1,2) <br>
    Example 2: 10022000 -- ADD 3 3 -> 10022333 3: (5,7) <br><br>

GET descriptor – Returns the start and end coordinates of the descriptor. <br>

    Example 1: 10022000 -- GET 2 -> 2: (3,4) <br><br>

DELETE descriptor – Removes all appearances of the descriptor. <br>

    Example 1: 10022440 -- DELETE 2 -> 10022440 <br><br>

DEFRAGMENTATION – Moves all relevant descriptors to the left to fill all the gaps created by the DELETE command. <br>

    Example: 10220030 -- DEFRAGMENTATION -> 12230000<br><br>

Bidimensional is a bit more complex, but I can explain it to you at the interview. 😊
