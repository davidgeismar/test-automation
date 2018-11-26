require_relative "spec"

module MongoidSpecs

  class DocumentSpec < Spec
    attr_accessor :klass, :file, :attribute, :indent

    def initialize(klass, file, indent=nil, attribute={})
      super(klass, file, indent)
      self.attribute = attribute
    end

    def generate
      file.write("it { is_expected.to have_field(:#{attribute.last.name}).of_type(#{attribute.last.type}).with_default_value_of(#{attribute.last.default_val}) } \n")
    end
  end

  class SlugSpecs < Spec
  end

  class TimestampSpec < Spec
  end

  class ValidationSpec < Spec
    attr_accessor :klass, :file, :validator, :indent

    def initialize(klass, file, indent=nil, validator)
      super(klass, file, indent)
      self.validator = validator
    end

    def generate
      if validator.instance_of? Mongoid::Validatable::PresenceValidator
        file.write("it { is_expected.to validate_presence_of(:#{validator.attributes.first}) }\n")
      end
    end
  end

  class IndexSpec < Spec
    attr_accessor :klass, :file, :index, :indent

    def initialize(klass, file, indent=nil, index)
      super(klass, file, indent)
      self.index = index
    end

    def generate
      file.write("it { is_expected.to have_index_for(#{index.key}).with_options(name: '#{index.options[:name]}') }\n") if index.options[:name]
    end
  end

  class AssociationSpec < Spec
    attr_accessor :klass, :file, :association, :indent

    def initialize(klass, file, indent=nil, association)
      super(klass, file, indent)
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
      file.write("it { is_expected.to #{relation_verb}(:#{association.name}).of_type(#{relation_klass}) } \n")
    end
  end
end
