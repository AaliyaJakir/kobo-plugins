# Kobo-Plugins

A series of kobo plugins I created


| Plugin                     | Description            |
|----------------------------|------------------------|
| AaliyaJakir/QuizGenerator  | Generates AI quizzes |
| AaliyaJakir/LogseqSearch   | Search Logseq Questions |
| AaliyaJakir/SyllabusFetch  | Fetches Syllabus Details |

To run these, get Nickelmenu
Here is my config file

They are built on NickelTC
Get .niluje's kobostuffs 


// if you update the repos, make sure to update this with submodule update ..


Main - SyllabusFetch (in the future notebook)
Main - LogseqSearch
Main - Upload Notebooks

Reader - QuizGenerator
Reader - Update Books

Library - FTP Server
Library - Telnet Server
Library - Upload Highlights

// put an icon for Nickelmenu

# UPDATE LOGSEQ QUESTIONS
menu_item:main:Update Logseq:cmd_spawn:/bin/sh /mnt/onboard/.adds/logseq/updateLogseqSearch.sh

# FTP SERVER 
menu_item :main :Start FTP :cmd_spawn :quiet :exec /bin/sh -c "/usr/bin/tcpsvd -E 0.0.0.0 1021 /usr/sbin/ftpd -w -t 30 /mnt/onboard & sleep 300; /usr/bin/pkill -f '^/usr/bin/tcpsvd -E 0.0.0.0 1021'"

# TELNET SERVER
menu_item:main:Start Telnet (5 min):cmd_spawn:quiet:/bin/sh -c "/bin/mount -t devpts | /bin/grep -q /dev/pts || { /bin/mkdir -p /dev/pts && /bin/mount -t devpts devpts /dev/pts; }; /usr/bin/tcpsvd -E 0.0.0.0 2023 /usr/sbin/telnetd -i -l /bin/login & sleep 300; /usr/bin/pkill -f '^/usr/bin/tcpsvd -E 0.0.0.0 2023'"




