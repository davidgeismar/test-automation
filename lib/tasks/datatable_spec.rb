require_relative "spec"

module DatatableSpecs

  class ExcludeFieldsSpec < Spec

    def generate
      file.write("it { expect(#{klass}.datatable_exclude_fields).to match_array %w(#{klass.datatable_exclude_fields.join(" ")}) }\n")
    end
  end
  class FieldsSpec < Spec

    def generate
      file.write("\t\tit { expect(#{klass}.datatable_fields).to match #{klass.datatable_fields} }\n")
    end
  end
  class SearchFieldsSpec < Spec
    def generate
      file.write("\t\tit { expect(#{klass}.datatable_search_fields).to contain_exactly  #{klass.datatable_search_fields} }\n")
    end
  end

  class ConfigSpec < Spec
    def generate
      file.write("\t\tit { expect(#{klass}.datatable_config('http://example.com')).to include 'ajax', 'pagingType', 'serverSide', 'pageLength', 'columns', 'language' }\n")
    end
  end
end
