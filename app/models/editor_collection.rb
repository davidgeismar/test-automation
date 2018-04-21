class EditorCollection
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Search
  include Mongoid::Slug
  include Mongoid::Timestamps
  # include Mongoid::Autoinc
  # include Edulib::Datatable
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  # include Elasticsearch::DSL
  extend Enumerize
end
