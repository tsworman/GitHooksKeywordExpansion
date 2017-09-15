# Variable expansion for Git (Windows/Linux?) #

## About ##
I'm fairly reliant on variable expansion in work that I do. This was a common function to use in CVS, SVN, PVCS, etc. 
Our specific use case put a version number and the last commit message into the top of a SQL file. This was often used to keep history are we didn't have a traditional build process. Code was simply run on the server and even with an automated deployment process this made it handy to see an indicator of the last version deployed.

This code specifically expands a tag of "--$Log:" which was common in PVCS to the last commit message, user, time for that specific file.
It does this only for .sql files (you can change it) and the expansion is done via a call to Git log.

Documentation of Git Hooks and Smudge/Clean filters is pretty sparse at the level of detail that I wanted.

## Setup ##
Everything from the hooks directory added to your projects .git/hooks directory.
.git attributes file in the root of your project.
.gitconfig file has changes to add the filters to your home directory c:\users\usernamehere\
.vbs files in c:\ or change where the hooks/.gitconfig point to them.

The newSQLFile.sql is a test file showing what the expansion handler is currently setup to do.

## Testing ##
Create a .sql file in this Git project.
Add the text (no quotes) "--$Log:"
Commit the sql file and then look at the file after. It should now have the commit message included if everything ran.
Make another change and commit and push to a remote server/repository.
The checked in version will have nothing but --$Log:
The local version if your working tree will have your commit message included in a formatted form.

## Hooks and Filters ##
###Why not just filters?###
Filters work fine for expansion if the keywords you are expanding are able to be populated at the time a filter is run.
This doesn't work with checkouts / clones / pulls _if_ you are using information from the git log to populate the expansion. 
The files you are working with will not have meta-data available in the current log and you end up with an empty message (and no error!) until the commit works.

###Why not just re-execute the clean/smudge filters after the commit/pull completes?###
This is what the hook does. I looked for a cleaner way to re-execute the filters but didn't find one which did not involves deleting the Git index and forcing a checkout again. 

###Why not just hooks?###
Hooks are great for doing something on their trigger. They don't fire a trigger for certain actions that make this super useful.
My biggest issue was when using a diff tool. I don't want my working tree (handled by the hooks) to differ from the last commit (in git log at time of diff). The smudge filter handles this.
Also the visual indicators in Windows were being triggered by clean/filters working properly, so I needed clean to still work.
We also want to clean up and remove this message before checkin which you could totally do with pre-commit filters. 
Most posts I've read say that changing the commit files in a major way was a bad thing to do with hooks. I disregard that here otherwise expansion isn't consistent.

###Why a post-merge and a post-commit hook?###
It's not enough to just add comments on post commit which was my first thought. That handles the use case where you are the only person commiting and not merging from other people.
The post-merge filter fires in most cases where a successful pull or merge has been performed and this will put the comments into the proper files. 

## Modifying for your expansion ##
The .gitattributes applies the filters to .sql files only. You'll need to change the filter there.
The hook files have a filter that additionally applies the hooks only on .sql files being processed.
The vbscript files do the actual heavy lifting and clean/replace the expansion keyworks. We use the same vbscripts from everywhere.

## Windows only? No, not really ##
No reason this same strategy can't be used elsewhere. My hope is to update it and provide scripts for Linux at some point in the near future.
I specifically coded this for use with mSysGit/Tortoisegit on a Windows 7 build without a unix like environment installed. 
I stuck to shell commands handled by mSysGit.
I stuck to heavy lifting done by vb scripts as Powershell isn't available to everyone on my team yet.

## Known issues##
### Tortoise Git for Windows ###
* Git Post commit/Post Merge Hook are not showing in hooks menu v2.5.0
* Git .hooks directory in each project doesn't list sample post-commit / post-merge scripts but they do work as of 9/14/2017

### Git for Windows ###
* Hooks require #bin/sh at the top. Use a mSysGit compatible shell script to fire the vbscripts.