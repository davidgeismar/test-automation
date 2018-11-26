module Hooks

def self.included(base)
 base.send :extend, ClassMethods
end


module ClassMethods
  # everytime we add a method to the class we check if we must redifine it
  def method_added(method)
    if @hooker_before.present? && @methods_to_hook_before.include?(method)
      binding.pry
      hooked_method = instance_method(@hooker_before)
      @methods_to_hook_before.each do |method_name|
        begin
          method_to_hook = instance_method(method_name)
        rescue NameError => e
          return
        end
        define_method(method_name) do |*args, &block|
          hooked_method.bind(self).call
          method_to_hook.bind(self).(*args, &block) ## your old code in the method of the class
        end
      end
     end
   end

  def before(*methods_to_hooks, hookers)
   @methods_to_hook_before = methods_to_hooks
   @hooker_before = hookers[:call]
  end
  #
  # def after(*methods_to_hooks, hookers)
  #  @methods_to_hook_after = methods_to_hooks
  #  @hooker_after = hookers[:call]
  # end

  def hooks
   @hooks ||= []
  end
 end
end
