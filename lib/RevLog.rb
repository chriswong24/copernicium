module RevLog
  class RevLog
    def initialize(project_path)
    end 

    
    def add_file(file_name, content)
      return content
    end

    def get_file(file_id)
        return file_id
    end


    def diff_files(file_id1, file_id2)
        if file_id1 == file_id2
            return ''
        else
            return file_id1+file_id2
        end
    end
  end
end
