require_relative "spec"

module MongoidSpecs

  class DocumentSpec < Spec
    attr_accessor :klass, :file, :attribute

    def initialize(klass, file, attribute={})
      super(klass, file)
      self.attribute = attribute
    end

    def generate
      file.write("\t\tit { is_expected.to have_field(:#{attribute.last.name}).of_type(#{attribute.last.type}) } \n")
    end


  end
  class SlugSpecs < Spec
  end
  class TimestampSpec < Spec
  end

  class ValidationSpec < Spec
    attr_accessor :klass, :file, :validator

    def initialize(klass, file, validator)
      super(klass, file)
      self.validator = validator
    end

    def generate
      if validator.instance_of? Mongoid::Validatable::PresenceValidator
        file.write("\t\tit { is_expected.to validate_presence_of(:#{validator.attributes.first}) }\n")
      end
    end
  end

  class IndexSpec < Spec
    attr_accessor :klass, :file, :index

    def initialize(klass, file, index)
      super(klass, file)
      self.index = index
    end

    def generate
      file.write("\t\tit { is_expected.to have_index_for(#{index.key}).with_options(name: '#{index.options[:name]}') }\n") if index.options[:name]
    end
  end

  class AssociationSpec < Spec
    attr_accessor :klass, :file, :association

    def initialize(klass, file, association)
      super(klass, file)
      self.association = association
    end

    def generate
      case association.relation.to_s
      when Mongoid::Relations::Referenced::In.to_s
        relation_verb = "belong_to"
        relation_klass = association.name.to_s.classify.constantize
      when Mongoid::Relations::Referenced::Many.to_s
        relation_verb = "have_many"
        relation_klass = association.name.to_s[0..-2].classify.constantize
      when Mongoid::Relations::Referenced::ManyToMany.to_s
        relation_verb = "have_and_belong_to_many"
        relation_klass = association.name.to_s[0..-2].classify.constantize
      end
      file.write("\t\tit { is_expected.to #{relation_verb}(:#{association.name}).of_type(#{relation_klass}) } \n")
    end
  end
end
