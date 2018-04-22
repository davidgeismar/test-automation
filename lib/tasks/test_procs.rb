module TestProcs
  def field_proc
     Proc.new do |test_subjects|
        test_subjects.each do |key, value|
            file.write("\t\tit { is_expected.to have_field(:#{value.name}).of_type(#{value.type}) } \n")
        end
      end
  end

  def enumerize_proc
    Proc.new do |test_subjects|
      test_subjects.attributes.each do |key, value|
        file.write("\t\tit { is_expected.to enumerize(:#{value.name}).in(#{value.values}).with_i18n_scope(#{value.i18n_scope.first}) } \n")
      end
    end
  end

  def validation_proc
     Proc.new do |test_subjects|
        test_subjects.each do |validator|
          if validator.instance_of? Mongoid::Validatable::PresenceValidator
             file.write("\t\tit { is_expected.to validate_presence_of(:#{validator.attributes.first}) }\n")
          end
        end
      end
  end
  def index_proc
     Proc.new do |test_subjects|
        test_subjects.each do |index|
          file.write("\t\tit { is_expected.to have_index_for(#{index.key}).with_options(name: '#{index.options[:name]}') }\n") if index.options[:name]
        end
      end
  end

  def association_proc
    Proc.new do |klass, klass_method, klass_method_args|
      klass_method_args.each do |klass_method_arg|
        klass.send(klass_method, klass_method_arg).each do |relation|
          case klass_method_arg
          when :belongs_to
            verb = "belong_to"
            relation_type = relation.name.to_s.classify.constantize
          when :has_many
            verb = "have_many"
            relation_type = relation.name.to_s[0..-2].classify.constantize
          when :has_and_belongs_to_many
            verb = "have_and_belong_to_many"
            relation_type = relation.name.to_s[0..-2].classify.constantize
          end
          file.write("\t\tit { is_expected.to #{verb}(:#{relation.name}).of_type(#{relation_type}) } \n")
        end
      end
    end
  end
end
