# Trustfix-
A powershell script for fixing trust relationship issues on windows domains...BEFORE they happen!

We have an enterprise windows domain, and recently a ton of computers started randomly getting this erorr that reads "The trust relationship between this workstation and the primary domain failed

To fix this, we would have to log on to a local account on the computer, take it off the domain and rejoin it. This began eating more of our time than we were ok with, and decided to write a script to fix it!

Powershell 3 introduced a new cmdlet that could check the computers trust relationship, and also fix it if it was broken. This was the key to solving our troubles. We had several hurdles to jump though...

Firstly, windows 7 ships with powershell 2 and a good 90% of our workstations have windows 7 and powershell version 2. We needed to mass upgrade them to powershell 3 (or 4, we decided to go with 4). Second, we needed to keep track of which computers had which version. And of course third, we wanted to implement this solution in a way that was completely hands off. We thought about just running the cmdlet remotely each time a pc lost its trust relationship, but Mr Caren wanted to take it a step farther and have it fix the issue as soon as it happens, so no one even knows it did happen.

We came to all this after failing to pin down the cause of the issue, and instead came up with an elegant triage which it the trustfix script. 

The trustfix script does several things for us upfront. It checks the pc's powershell version, checks it's group membership in AD, and then it actually runs its check of the computer trust relationship, fixing if neccessary. For efficiency, we didn't want it to check everything everytime. If all the prerequisites are met, it just runs the trust relationship fixing cmdlet. In this way it can fix it (if it's broken) quickly before the logon screen can come up. The script itself we set up to run on event id 10000 which is the network-profile up status event. As soon as the PC has network connectivity, the script runs(task engine runs it). 

The actual script follows this flow: Check for a special file called pie.txt. The pie file tells the program that all prereqs are met. If it does not find pie, which it won't on first run, it flows to the next function. The next function checks the PC's powershell version. If it is version 2 or less, it installs version 4. Next time the script runs, it will get to that function and see that it now has PS4, at which point it moves to the next function which looks at the group membership. We put all PC's into a group called "Needs PS4" and created an empty group called "trust fix". This fuction moves the pc from the first group to the second. This way you can keep track of which computers have successfully ran the script. It then moves to the next function, which is the create_pie function. This simply creates the pie.txt file that tells the script next time it runs that all the backend stuff is done, and it can just check the trust relationship.
