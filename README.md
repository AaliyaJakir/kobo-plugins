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




Reader - QuizGenerator
Reader - Update Books

Main - SyllabusFetch (in the future notebook)
Main - LogseqSearch
Main - Update Logseq
Main - Upload Notebooks

Library - FTP Server
Library - Telnet Server
Library - Upload Highlights

// put an icon for Nickelmenu

# Run test.sh script
menu_item:main:Update Logseq:cmd_spawn:/bin/sh /mnt/onboard/updateLogseqSearch.sh

menu_item :main :Start FTP :cmd_spawn :quiet :exec /bin/sh -c "/usr/bin/tcpsvd -E 0.0.0.0 1021 /usr/sbin/ftpd -w -t 30 /mnt/onboard & sleep 300; /usr/bin/pkill -f '^/usr/bin/tcpsvd -E 0.0.0.0 1021'"


# Telnet (toggle)
menu_item:main:Telnet2 (toggle):cmd_output:500:quiet:/usr/bin/pkill -f "^/usr/bin/tcpsvd -E 0.0.0.0 2023"
  # If pkill succeeds (Telnet server was running), skip the next 5 actions and show a stopped message
  chain_success:skip:5
  # If pkill fails (Telnet server was not running), proceed to start it
  chain_failure:cmd_spawn:quiet:/bin/mount -t devpts | /bin/grep -q /dev/pts || { /bin/mkdir -p /dev/pts && /bin/mount -t devpts devpts /dev/pts; }
  chain_success:cmd_spawn:quiet:exec /usr/bin/tcpsvd -E 0.0.0.0 2023 /usr/sbin/telnetd -i -l /bin/login
  chain_success:dbg_toast:Started Telnet server on port 2023
  chain_failure:dbg_toast:Error starting Telnet server on port 2023
  # Reset chain regardless of success or failure
  chain_always:skip:-1
# If pkill succeeds (Telnet server stopped), display a stopped message
chain_success:dbg_toast:Stopped Telnet server on port 2023



