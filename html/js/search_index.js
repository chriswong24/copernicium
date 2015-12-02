var search_data = {"index":{"searchIndex":["copernicium","driver","fileobj","pushpull","repos","revlog","snapshot","uicomm","workspace","object","string","==()","uicommandparser()","add_file()","blu()","branch()","branches()","checkout()","checkout()","clean()","clean()","clear()","clone()","clone()","colorize()","commit()","commit()","connect()","delete_branch()","delete_file()","delete_snapshot()","diff_files()","diff_snapshots()","fetch()","get()","get_file()","get_snapshot()","getroot()","grn()","hash_array()","hash_array()","hash_file()","hasher()","history()","history()","include?()","indexof()","init()","make_branch()","make_snapshot()","merge()","merge()","merge_branch()","new()","new()","new()","new()","new()","new()","notcn()","notroot()","pexit()","pull()","pull()","push()","push()","readfile()","red()","reset()","restore_snapshot()","run()","status()","status()","transfer()","update_branch()","update_log_file()","update_snap()","writefile()","ws_files()","yel()","readme"],"longSearchIndex":["copernicium","copernicium::driver","copernicium::fileobj","copernicium::pushpull","copernicium::repos","copernicium::revlog","copernicium::snapshot","copernicium::uicomm","copernicium::workspace","object","string","copernicium::fileobj#==()","copernicium::pushpull#uicommandparser()","copernicium::revlog#add_file()","string#blu()","copernicium::driver#branch()","copernicium::repos#branches()","copernicium::driver#checkout()","copernicium::workspace#checkout()","copernicium::driver#clean()","copernicium::workspace#clean()","copernicium::workspace#clear()","copernicium::driver#clone()","copernicium::pushpull#clone()","string#colorize()","copernicium::driver#commit()","copernicium::workspace#commit()","copernicium::pushpull#connect()","copernicium::repos#delete_branch()","copernicium::revlog#delete_file()","copernicium::repos#delete_snapshot()","copernicium::revlog#diff_files()","copernicium::repos#diff_snapshots()","copernicium::pushpull#fetch()","copernicium::driver#get()","copernicium::revlog#get_file()","copernicium::repos#get_snapshot()","copernicium#getroot()","string#grn()","copernicium::repos#hash_array()","copernicium::revlog#hash_array()","copernicium::revlog#hash_file()","copernicium::repos#hasher()","copernicium::repos#history()","copernicium::revlog#history()","copernicium::workspace#include?()","copernicium::workspace#indexof()","copernicium::driver#init()","copernicium::repos#make_branch()","copernicium::repos#make_snapshot()","copernicium::driver#merge()","copernicium::revlog#merge()","copernicium::repos#merge_branch()","copernicium::fileobj::new()","copernicium::repos::new()","copernicium::revlog::new()","copernicium::snapshot::new()","copernicium::uicomm::new()","copernicium::workspace::new()","copernicium#notcn()","copernicium#notroot()","copernicium#pexit()","copernicium::driver#pull()","copernicium::pushpull#pull()","copernicium::driver#push()","copernicium::pushpull#push()","copernicium#readfile()","string#red()","string#reset()","copernicium::repos#restore_snapshot()","copernicium::driver#run()","copernicium::driver#status()","copernicium::workspace#status()","copernicium::pushpull#transfer()","copernicium::repos#update_branch()","copernicium::revlog#update_log_file()","copernicium::repos#update_snap()","copernicium#writefile()","copernicium::workspace#ws_files()","string#yel()",""],"info":[["Copernicium","","Copernicium.html","","<p>Revlog Top Level Function Definitions (Xiangru)\n<p>add_file: add a file to the revision history in - file …\n"],["Copernicium::Driver","","Copernicium/Driver.html","",""],["Copernicium::FileObj","","Copernicium/FileObj.html","",""],["Copernicium::PushPull","","Copernicium/PushPull.html","",""],["Copernicium::Repos","","Copernicium/Repos.html","",""],["Copernicium::RevLog","","Copernicium/RevLog.html","",""],["Copernicium::Snapshot","","Copernicium/Snapshot.html","",""],["Copernicium::UIComm","","Copernicium/UIComm.html","","<p>Communication object that will pass commands to backend modules rev -\nrevision indicator (commit #, branch …\n"],["Copernicium::Workspace","","Copernicium/Workspace.html","",""],["Object","","Object.html","",""],["String","","String.html","","<p>open up string class, enable terminal colors add some colors, windowing\nmethods\n"],["==","Copernicium::FileObj","Copernicium/FileObj.html#method-i-3D-3D","(rhs)",""],["UICommandParser","Copernicium::PushPull","Copernicium/PushPull.html#method-i-UICommandParser","(ui_comm)","<p>Chris&#39;s edit Takes in Ethan&#39;s UICommandCommunicator object and\ncalls a method based on the command …\n"],["add_file","Copernicium::RevLog","Copernicium/RevLog.html#method-i-add_file","(file_name, content)",""],["blu","String","String.html#method-i-blu","()",""],["branch","Copernicium::Driver","Copernicium/Driver.html#method-i-branch","(args)",""],["branches","Copernicium::Repos","Copernicium/Repos.html#method-i-branches","()","<p>Return string array of what branches we have\n"],["checkout","Copernicium::Driver","Copernicium/Driver.html#method-i-checkout","(args)",""],["checkout","Copernicium::Workspace","Copernicium/Workspace.html#method-i-checkout","(comm = UIComm.new(rev: @branch))",""],["clean","Copernicium::Driver","Copernicium/Driver.html#method-i-clean","(args = [])",""],["clean","Copernicium::Workspace","Copernicium/Workspace.html#method-i-clean","(comm)","<p>reset first: delete them from disk and reset @files restore it with\ncheckout() if we have had a branch …\n"],["clear","Copernicium::Workspace","Copernicium/Workspace.html#method-i-clear","()","<p>Clear the current workspace\n"],["clone","Copernicium::Driver","Copernicium/Driver.html#method-i-clone","(args)",""],["clone","Copernicium::PushPull","Copernicium/PushPull.html#method-i-clone","(remote, dir, user = nil, passwd = nil)",""],["colorize","String","String.html#method-i-colorize","(color, mod)",""],["commit","Copernicium::Driver","Copernicium/Driver.html#method-i-commit","(args)",""],["commit","Copernicium::Workspace","Copernicium/Workspace.html#method-i-commit","(comm)","<p>commit a list of files or the entire workspace to make a new snapshot\n"],["connect","Copernicium::PushPull","Copernicium/PushPull.html#method-i-connect","(remote, user = nil, passwd = nil, &block)",""],["delete_branch","Copernicium::Repos","Copernicium/Repos.html#method-i-delete_branch","(branch)","<p>Exit status code\n"],["delete_file","Copernicium::RevLog","Copernicium/RevLog.html#method-i-delete_file","(file_id)","<p>return 1 if succeed, otherwise 0\n"],["delete_snapshot","Copernicium::Repos","Copernicium/Repos.html#method-i-delete_snapshot","(id)","<p>Find snapshot, delete from snaps/memory\n"],["diff_files","Copernicium::RevLog","Copernicium/RevLog.html#method-i-diff_files","(file_id1, file_id2)",""],["diff_snapshots","Copernicium::Repos","Copernicium/Repos.html#method-i-diff_snapshots","(id1, id2)","<p>Return list of filenames and versions\n"],["fetch","Copernicium::PushPull","Copernicium/PushPull.html#method-i-fetch","(remote, dest, local, user = nil, passwd = nil)",""],["get","Copernicium::Driver","Copernicium/Driver.html#method-i-get","(info)","<p>Get some info from the user when they dont specify it\n"],["get_file","Copernicium::RevLog","Copernicium/RevLog.html#method-i-get_file","(id)",""],["get_snapshot","Copernicium::Repos","Copernicium/Repos.html#method-i-get_snapshot","(id)","<p>Find snapshot, return snapshot (or just contents) given id\n"],["getroot","Copernicium","Copernicium.html#method-i-getroot","()","<p>find  the root .cn folder\n"],["grn","String","String.html#method-i-grn","()",""],["hash_array","Copernicium::Repos","Copernicium/Repos.html#method-i-hash_array","()","<p>array of hashes constructor\n"],["hash_array","Copernicium::RevLog","Copernicium/RevLog.html#method-i-hash_array","()",""],["hash_file","Copernicium::RevLog","Copernicium/RevLog.html#method-i-hash_file","(file_name, content)",""],["hasher","Copernicium::Repos","Copernicium/Repos.html#method-i-hasher","(obj)","<p>returns the hash if of an object\n"],["history","Copernicium::Repos","Copernicium/Repos.html#method-i-history","(branch_name = nil)","<p>Return array of snapshot IDs\n"],["history","Copernicium::RevLog","Copernicium/RevLog.html#method-i-history","(file_name)",""],["include?","Copernicium::Workspace","Copernicium/Workspace.html#method-i-include-3F","(files)","<p>if include all the elements in list_files\n"],["indexOf","Copernicium::Workspace","Copernicium/Workspace.html#method-i-indexOf","(x)",""],["init","Copernicium::Driver","Copernicium/Driver.html#method-i-init","(args)","<p>create a new copernicium repository\n"],["make_branch","Copernicium::Repos","Copernicium/Repos.html#method-i-make_branch","(branch)","<p>Return hash ID of new branch\n"],["make_snapshot","Copernicium::Repos","Copernicium/Repos.html#method-i-make_snapshot","(files = [])","<p>Create snapshot, and return hash ID of snapshot\n"],["merge","Copernicium::Driver","Copernicium/Driver.html#method-i-merge","(args)",""],["merge","Copernicium::RevLog","Copernicium/RevLog.html#method-i-merge","(id1, id2)",""],["merge_branch","Copernicium::Repos","Copernicium/Repos.html#method-i-merge_branch","(branch)","<p>Merge the target branch into current\n"],["new","Copernicium::FileObj","Copernicium/FileObj.html#method-c-new","(path, ids)",""],["new","Copernicium::Repos","Copernicium/Repos.html#method-c-new","(root, branch = 'master')","<p>read in file of snapshots (.cn/history) check the current branch\n(.cn/branch)\n"],["new","Copernicium::RevLog","Copernicium/RevLog.html#method-c-new","(root)",""],["new","Copernicium::Snapshot","Copernicium/Snapshot.html#method-c-new","(files = [])","<p>id is computed after creation\n"],["new","Copernicium::UIComm","Copernicium/UIComm.html#method-c-new","(command: nil, files: nil, rev: nil, cmt_msg: nil, repo: nil, opts: nil)",""],["new","Copernicium::Workspace","Copernicium/Workspace.html#method-c-new","(bname = 'master')",""],["notcn","Copernicium","Copernicium.html#method-i-notcn","()",""],["notroot","Copernicium","Copernicium.html#method-i-notroot","()",""],["pexit","Copernicium","Copernicium.html#method-i-pexit","(msg, sig)","<p>Print and exit with a specific code\n"],["pull","Copernicium::Driver","Copernicium/Driver.html#method-i-pull","(args)",""],["pull","Copernicium::PushPull","Copernicium/PushPull.html#method-i-pull","(remote, branch, remote_dir)",""],["push","Copernicium::Driver","Copernicium/Driver.html#method-i-push","(args)",""],["push","Copernicium::PushPull","Copernicium/PushPull.html#method-i-push","(remote, branch, remote_dir)",""],["readFile","Copernicium","Copernicium.html#method-i-readFile","(path)",""],["red","String","String.html#method-i-red","()",""],["reset","String","String.html#method-i-reset","()",""],["restore_snapshot","Copernicium::Repos","Copernicium/Repos.html#method-i-restore_snapshot","(id)","<p>Return comm object with status change files in workspace back to specified\ncommit get clear the current …\n"],["run","Copernicium::Driver","Copernicium/Driver.html#method-i-run","(args)","<p>Executes the required action for a given user command.\n<p>Parameters:\n\n<pre>* args - an array containing the tokenized ...</pre>\n"],["status","Copernicium::Driver","Copernicium/Driver.html#method-i-status","(args)","<p>show the current repos status\n"],["status","Copernicium::Workspace","Copernicium/Workspace.html#method-i-status","(comm)",""],["transfer","Copernicium::PushPull","Copernicium/PushPull.html#method-i-transfer","(remote, local, dest, user = nil, passwd = nil)",""],["update_branch","Copernicium::Repos","Copernicium/Repos.html#method-i-update_branch","()",""],["update_log_file","Copernicium::RevLog","Copernicium/RevLog.html#method-i-update_log_file","()",""],["update_snap","Copernicium::Repos","Copernicium/Repos.html#method-i-update_snap","()",""],["writeFile","Copernicium","Copernicium.html#method-i-writeFile","(path, content)","<p>helper methods for file IO\n"],["ws_files","Copernicium::Workspace","Copernicium/Workspace.html#method-i-ws_files","()","<p>get all files currently in workspace\n"],["yel","String","String.html#method-i-yel","()",""],["README","","README_md.html","","<p>copernicium\n<p><img src=\"https://badge.fury.io/rb/copernicium.svg\">\n<img\nsrc=\"https://travis-ci.org/jeremywrnr/copernicium.svg\"> ...\n"]]}}