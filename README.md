# Linux_File_Ownership
This is essentially a command line tool that asks for Username or UserID, groupname or GroupId,
and absolute path that you want to search in. 
The tool will then recursively search into the given directory and all its subdirectories
for all the files, for which the given user has execute permissions.
Additionally it will also check whether group or other has execute permissions on it.

Output file will have one file name on each line and one of the 6 initials

OY - Other Yes
ON - Other No
UY - User Yes
UN - User No
GY - Group Yes
GN - Group No

indicating what kind of permissions each has.
