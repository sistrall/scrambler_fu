require 'active_record'

module ScramblerFu
  module Acts #:nodoc:
    module Scramblable #:nodoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        def self.extended(base)
          base.class_inheritable_accessor :scrambler_options
        end
        
        def acts_as_scramblable(options = {})
          self.scrambler_options ||= {}
          
          self.scrambler_options[:columns] = options.dup
          
          extend  ScramblerFu::Acts::Scramblable::SingletonMethods
          include ScramblerFu::Acts::Scramblable::InstanceMethods
          
          Scrambler.register(self)
        end
      end
      
      module SingletonMethods
        def scramble!(columns = nil)
          scrambler_options[:columns].each do |column, actions|
            action_methods(actions).each do |action|
              send(action, column)
            end
          end
        end
        
        protected
          def scramble_order!(column)
            ordered   = find(:all)
            scrambled = find(:all, :select => column, :order => 'RAND()')
            
            ordered.each do |record|
              record.send("#{column}=", scrambled.shift.send("#{column}"))
              record.update_without_callbacks
            end
            
            log_scramble_info('order', column)
          end
          
          def scramble_letters!(column)
            list = find(:all)
            list.each do |record|
              record.scramble_letters(column)
              record.update_without_callbacks
            end
            
            log_scramble_info('letters', column)
          end
          
          def scramble_numbers!(column)
            list = find(:all)
            list.each do |record|
              record.scramble_numbers(column)
              record.update_without_callbacks
            end
            
            log_scramble_info('numbers', column)
          end
          
        private
          def action_methods(actions)
            actions = [actions] unless Array === actions
            actions.map { |action| "scramble_#{action}!" }.map(&:to_sym)
          end
          
          def log_scramble_info(method, column)
            logger.info("#{self.name}: Scrambled #{method} for column '#{column}'")
          end
      end
      
      module InstanceMethods
        def scramble_letters(column)
          value = self.send("#{column}")
          return false unless value
          
          self.send("#{column}=", Scrambler.scramble_letters(self.send("#{column}")))
        end
        
        def scramble_numbers(column)
          value = self.send("#{column}")
          return false unless value
          
          self.send("#{column}=", Scrambler.scramble_numbers(self.send("#{column}")))
        end
      end
      
    end
  end
end