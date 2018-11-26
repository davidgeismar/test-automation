module Indentation
  def indent
    binding.pry
    @indent.times{ file.write("\t\t") }
  end

  def write_end
    file.write("end \n")
  end
end
