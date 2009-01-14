class Scrambler
  cattr_accessor :scramblable_models
  
  class << self
    def register(model)
      self.scramblable_models ||= []
      
      self.scramblable_models << model
    end
    
    def scramble_letters(string)
      upcase_letters = ('A'..'Z').to_a
      downcase_letters = ('a'..'z').to_a
      
      new_string = string.dup
      new_string.gsub!(/[A-Z]/) { |letter| upcase_letters[rand(upcase_letters.length)] }
      new_string.gsub!(/[a-z]/) { |letter| downcase_letters[rand(downcase_letters.length)] }
      
      return new_string
    end
    
    def scramble_numbers(string)
      numbers = ('0'..'9').to_a
      
      new_string = string.dup
      new_string.gsub!(/[0-9]/) { |letter| numbers[rand(numbers.length)] }
      
      return new_string
    end
    
    def scramble!
      self.scramblable_models.each(&:scramble!)
    end
  end
end
