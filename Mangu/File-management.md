# Easy
Absolutely! Here's the revised scenario that includes a brief hint about the ps aux command for context, without requiring students to already know it. This way, they stay focused on file management and redirection, but aren’t confused by unknown commands.


---

Scenario: System Audit at Acme Corp (Beginner Edition)

You're a junior sysadmin at Acme Corp, and your supervisor has asked you to prepare and organize audit logs. You won't be writing commands to analyze the system yet—but you will need to manage files, organize output, and use redirection correctly.


---

Allowed Commands:

File Management: mkdir, cd, cp, mv, rm, ls, touch

Viewing Files: cat, less, more

Counting & Sorting: find, wc, sort, head, tail, du

Redirection: >, >>, 2>, &>



---

TASKS

Task 1: Prepare Your Workspace

Create a directory named audit_logs and move into it.

> Deliverables: A directory called audit_logs that contains all your audit files.




---

Task 2: CPU Usage Report

Your supervisor has run the command:

ps aux --sort=-%cpu | head -n 11

This command shows the top 10 processes using the most CPU.

Your Task: Redirect this output into a file named top_cpu.txt.

> Hint: You don’t need to run ps aux yourself. Just focus on how you'd redirect this output into a file.




---

Task 3: Largest Files

A team member used a command to list the top 10 largest files starting from the current directory:

find . -type f -exec du -h {} + | sort -rh | head -n 10

Your Task: Redirect this kind of output into a file named largest_files.txt.


---

Task 4: Count Files and Directories

Your teammate used two commands to count:

Files: find . -type f | wc -l

Directories: find . -type d | wc -l


Your Task:

Redirect the file count to file_count.log

Redirect the directory count to dir_count.log



---

Task 5: Error Handling

Try to list a folder that doesn’t exist: /fakedir

Your Task: Redirect the error message into error.log, so that nothing prints on screen.

> Hint: Use standard error redirection (2>)




---

Task 6: Combine Into One Report

Create a combined report file: system_audit_report.txt

1. Add a header: ==== Top CPU Processes ====


2. Append contents of top_cpu.txt


3. Add a header: ==== Largest Files ====


4. Append contents of largest_files.txt


5. Add a header: ==== File & Directory Counts ====


6. Append contents of file_count.log and dir_count.log



> Hint: Use echo for headers, and >> for appending content




---

Task 7: Organize and Archive

1. Create a folder called final_report


2. Copy all .txt and .log files into it


3. Create a compressed archive: final_report.tar.gz



> Hint: Use cp, mkdir, and tar -czf




---

Optional Bonus

List the files inside the final_report folder and save the list to report_index.txt.


---

Let me know if you want:

A filled answer key

A version formatted for students or printable PDF

A script template with blanks for practice

## intermediate 

> follow online sources and install apache2 on ubuntu (either on local computer or Azure VM)
> enable custom domains for that (not in real but got doing that you need ln -s and a2ensite type of commands) 
