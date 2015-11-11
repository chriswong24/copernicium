# This is the workspace module
# The functions are clean, commit, checkout and status


require_relative 'RevLog'
require_relative 'repos'

module Workspace
  class Workspace
    def clean(list_files)
      head = repos.head
      snapshot = head.last_snapshot
      if list_files == nil
        @tree = checkout(head)
      else
        checkout(list_files)
      end
    end

    def commit(list_files)
      if list_files != nil
        hashs = []
        paths = []
        list_files.each do |x|
          paths.push(x)
          hashs.push(RevLog.hash_file(x))
        end
        head = repos.head
        snapshot = head.last_snapshot
        filePaths = snapshot.filePaths
        fileHashs = snapshot.fileHashs

        snapPaths = []
        snapHashs = []

        snapPaths.push(paths)
        snapHashs.push(hashs)

        size(filePaths).times do |i|
          if not paths.contains(filePaths[i])
            snapPaths.push(filePaths[i])
            snapHashs.push(fileHashs[i])
          end
        end

        repos.make_snapshot(snapPaths, snapHashs)
      else
        snapPaths = []
        snapHashs = []

        list_file.each do |x|
          snapPaths.push(x)
          snapHashs.push(RevLog.hash_file(x))
        end
      end

    end

    def checkout(list_files)

      if list_files.class == 'Array'
        list_files.each do |x|
          path = x.path
          hash = x.hash
          content = RevLog.get_file(hash)
          writeFile(path,content)
        end

      else
        branch = repos.getBranch(list_file)
        snapshot = branch.last_snapshot

        filePaths = snapshot.filePaths
        filehashs = snapshot.fileHashs

        size(filePaths).times do |i|
          path = filePaths[i]
          hash = fileHashs[i]
          content = RevLog.get_file(hash)
          writeFile(path,content)
        end
      end

    end

    def status()
      adds = []
      deletes = []
      edits = []

      head = repos.head
      snapshot = head.last_snapshot

      filePaths = snapshot.filePaths
      fileHashs = snapshot.fileHashs

      files = Dir.glob('.')

      size(filePaths).times do |i|

        if files.contains(filePaths[i])
          content = RevLog.get_file(fileHashs[i])
          diff = RevLog.diff_files(content, filePaths[i])
          if not diff == ''
            edits.push(filePaths[i])
          end
        else
          delete.push(files)
        end
      end

      size(files).times do |i|
        if not filePaths.contains(files[i])
          adds.push(files[i])
        end
      end

      return adds, edits, deletes

    end

  end
end

