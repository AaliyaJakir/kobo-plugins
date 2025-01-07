# Kobo-Plugins

A set of QT plugins for Kobo e-readers that I made designed to improve my personal knowledge management systems.
*I use Logseq which is a block based note-taking application.*

| Plugin | Description |
|--------|-------------|
| [kobo-LogseqSearch](https://github.com/AaliyaJakir/kobo-LogseqSearch) | Search Logseq Questions¹ |
| [kobo-QuizGenerator](https://github.com/AaliyaJakir/kobo-QuizGenerator) | Generate AI quizzes |
| [kobo-SyllabusFetch](https://github.com/AaliyaJakir/kobo-SyllabusFetch) | Fetch recommended course syllabi |

All of these plugins are written in C++ using the Qt framework. Source code can found in the respective `src/` directories. 
#### Utilities

`uploadNotebooks.sh`: takes Notebooks from Exported Notebooks that start with Log and sends it to Logseq's daily journal
`notes/export_highlights`: exports annotations by reading the koreader.sqlite

## Setup
1. Put `KoboRoot.tgz` on your .kobo folder to install Plugins
2. Make sure to include the scripts you need on your device on `mnt/onboard/.adds`

***To work with your Kobo...***
- telnet {ip} {port} || ftp {ip} -> put KoboRoot.tgz || set up ssh using kobo's .nilujes dropbear || just plug your damn Kobo into the computer
**warning: telnet is very insecure as a protocol. do not use in the middle of your diplomatic tour of iran's nuclear facilities**
---


### Overview
Kobo is an e-reader that is Linux based and uses the QT framework (C++) to create their UI. The base firmware of Kobo is `Nickel` with the core library of `libnickelso.1.0.0`

Nickelmenu is a community-created mod that hooks directly onto Nickel to add new menu items to Kobo ereaders. We can create custom plugins with our own QT apps.

### Some important information for Development

**Kobo Embedded systems development**
There's no such thing as a free lunch... (also known as the curl binary is not available on the kobo environment. BUT you can get it at .niluje's kobostuff which has a bunch of useful things like curl, jq, nano, lsof, sqlite3, tmux, objdump, GDB, htop)

**QT C++ Development**
QT widgets, signal/slots, parent-child relationships, layout management, eventFilters (touch -> mouse), constructors/destructors, styling, header file, QLabel, QProcess, QJsonDocument, QTimer

**Git Organization**
If you update this repo's submodules, make sure to update this main repo with
`git submodule update --remote --recursive` and then add and commit your changes
---


## Future Ideas
- convert books into vector embeddings to generate more accurate quizzes
- implement evaluation and observability for AI quizzes
- create more granularity to the course recommendations. right now it's just sending the syllabi of a relevant course. but i'd like to expand with giving specific topics or concepts and sending resources or assignments to the reader. 
- add menu item to the notebook (I was able to hook onto a function using NickelHook that I found in disassembly and it worked!!!!!!!!!!!!) -> [nickelmenu-notebook](https://github.com/AaliyaJakir/nickelmenu-notebook.git)
