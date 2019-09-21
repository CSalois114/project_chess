require "yaml"

module Saving
  def save
    file_name = get_save_name
    Dir.mkdir("saves") unless Dir.exist?("saves")
    save = YAML.dump({
      :squares => @squares.dup,
      :turn_color => @turn_color.dup
    })
    save_file = File.open("./saves/#{file_name}", 'w')
    save_file.puts save
    save_file.close
  end

  def load
    saved_file = get_saved_file
    return nil unless saved_file
    data = YAML.load File.read(saved_file)
    @squares = data[:squares]
    @turn_color = data[:turn_color]
  end

  private

  def get_saved_file
    save_files = Dir.glob("saves/*").map {|file| file.split("/")[1]}
    return puts "There are no saved games." if save_files.size == 0   
    puts "Which saved game would you like to load?\n\n"
    puts  save_files
    puts "\nLeave the File Name empty to cancle loading."
    print "\nFile Name: "
    file_name = gets.chomp
    until save_files.include? file_name
      return nil if file_name.length == 0
      puts "INVALID ENTRY"
      puts "\nPlease enter the name of a save file from the list above."
      print "\nFile: "
      file_name = gets.chomp
    end
    file_name = "saves/#{file_name}"
  end

  def get_save_name
    puts "\nWhat would you like to name your save?"
    print "\nSave Name: "
    name = gets.chomp
    while Dir.glob("saves/*").map {|file| file.split("/")[1]}.include? name
      puts "\nA save already exists whith that name."
      puts "To overwrite the old save, re-enter the file name."
      puts "or enter a new name for your save."
      print "\nSave Name: "
      new_name = gets.chomp
      name == new_name ? break : name = new_name
    end
    name
  end
end