class Product
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

  # Editor
  belongs_to :editor
  belongs_to :editor_collection
  # Articles
  has_many :articles, order: :title.asc, dependent: :delete, after_add: :after_article_add, before_remove: :before_article_remove
  # Levels & subject
  has_and_belongs_to_many :school_levels
  # has_and_belongs_to_many :grades
  # has_and_belongs_to_many :degrees
  # has_and_belongs_to_many :subjects, order: :name.asc



  # Characteristics
  field :isbn, type: Integer
  field :secondary_isbn, type: Integer

  #REFERENCE
  field :reference, type: String
  field :reference_number, type: Integer
  # increments :reference_number


  field :description, type: String
  field :use_terms, type: String
  enumerize :type,
            in: [:application, :digital_book, :website],
            default: :digital_book,
            i18n_scope: ['models.product.enum.type'],
            scope: true,
            predicates: true
  field :editor_code, type: String
  field :title, type: String



  field :release_date, type: Date
  enumerize :language,
            in: [:arab, :chinese, :deutsch, :english, :french, :italian, :spanish],
            i18n_scope: ['models.product.enum.language'],
            scope: true,
            predicates: true,
            default: :french
  field :series_name, type: String
  enumerize :resource_type,
            in: [:textbook, :extracurricular, :multimedia, :educational_support],
            default: :textbook,
            i18n_scope: ['models.product.enum.resource_type'],
            scope: true,
            predicates: true
  field :keywords, type: Array, default: []
  field :authors, type: Array, default: []
  field :published, type: Boolean
  field :is_bundle, type: Boolean, default: false
  field :is_former_casteilla, type: Boolean, default: false # legacy for Casteilla
  field :year_of_edition, type: Integer

  # slug
  slug :reference, :title

  # Associations
  field :editor__name, type: String
  field :editor_collection__name, type: String
  field :school_levels__names, type: String
  field :grades__names, type: String
  field :degrees__names, type: String
  field :grades_degrees__names, type: String
  field :subjects__names, type: String
  field :article__ids, type: Array, default: []

  # Full text search
  search_in :isbn, :secondary_isbn, :title, :series_name, :keywords, :editor__name, :subjects__names, :authors, articles: [:isbn, :title]

  # Attachments
  has_mongoid_attached_file :image,
                            path: 'paperclip_assets/product/:id_:style.:extension',
                            styles: { thumb: ['64x64#'],
                                      small: ['100x100'],
                                      medium: ['250x250'],
                                      large: ['500x500>']
                            },
                            processors: [:thumbnail, :compression],
                            storage: :fog


  # Validations
  # validates :school_levels, presence: true
  # validates :grades, presence: true
  # validates :subjects, presence: true
  # validates :type, presence: true
  # validates :title, presence: true
  # validates :resource_type, presence: true
  # validates :release_date, presence: true
  # validates :editor, presence: true
  # validates :reference, presence: true, unless: :product_is_textboook?

  validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

  # index_name 'edulib__products'

  #MAPPING ELASTICSEARCH
  # settings index: { number_of_shards: 1 } do
  #   mappings dynamic: 'false' do
  #     indexes :type, type: 'string', index: 'not_analyzed'
  #     indexes :title, type: 'string', index: 'not_analyzed'
  #     indexes :subjects, type: 'string', index: 'not_analyzed'
  #     indexes :editor, type: 'string', fielddata: true
  #     indexes :series_name, type: 'text', index: 'not_analyzed'
  #     indexes :school_levels, type: 'string', index: 'not_analyzed'
  #   end
  # end

  # Validation helper
  def product_is_textboook?
    self.digital_book?
  end

  # Scopes
  scope :published, -> { where(published: true) }
  scope :with_image, -> { ne(image_fingerprint:'').exists(image_fingerprint: true) }
  scope :for_editors, -> (editor_ids) { where(:editor_id.in => editor_ids) }

  # Indexes
  index({ isbn: 1 }, { name: 'isbn__index' })
  index({ title: 1 }, { name: 'title__index' })
  index({ editor__name: 1 }, { name: 'editor__name__index' })

  # Datatable
  def self.datatable_exclude_fields
    %w( editor_code reference_number series_name editor_collection__name release_date language resource_type keywords authors secondary_isbn description use_terms is_bundle is_former_casteilla _keywords grades__names degrees__names)
  end

  def self.datatable_format_fields
    {
      isbn: :product_isbn_or_reference
    }
  end

  def self.datatable_callbacks
    [:row_href]
  end

  # Callbacks
  before_create do |product|
    product.reference = generate_reference
  end

  # def generate_reference
  #   custom_reference = self.reference_number.to_s
  #   (1..(8-custom_reference.length)).each{ custom_reference = "0#{custom_reference}"} if custom_reference.length < 8
  #   custom_reference = "PROD-#{custom_reference}"
  # end
  #
  # before_save do
  #   self.editor__name = self.editor.name if editor_id_changed?
  #   self.editor_collection__name = self.editor_collection&.name if editor_collection_id_changed?
  #   self.school_levels__names = product_school_level if school_level_ids_changed?
  #   if grade_ids_changed? || degree_ids_changed?
  #     self.grades__names = product_grades
  #     self.degrees__names = product_degrees
  #     grades_names = self.grades__names
  #     degrees_names = self.degrees__names
  #     custom_grades = [grades_names] unless grades_names.is_a?(Array)
  #     custom_degrees = [degrees_names] unless degrees_names.is_a?(Array)
  #     self.grades_degrees__names = (custom_grades + custom_degrees).uniq.compact.reject(&:blank?).join(' | ').to_s
  #   end
  #   self.subjects__names = product_subjects if subject_ids_changed?
  #   self.reference = self.generate_reference if self.reference.blank?
  # end
  #
  # after_save do |product|
  #   if product.title_changed? || product.isbn_changed?
  #     product.articles.each do |article|
  #       article.set_reference
  #       article.product__title = product.title
  #       article.save!
  #     end
  #   end
  # end

  def after_article_add(article)
    self.article__ids << article.id
  end

  def before_article_remove(article)
    self.article__ids.delete article.id
  end

  # Helpers
  # Product image:
  # @return product's image in small size if image is not nil
  def product_image
    image.url(:small) unless image.nil?
  end

  def product_school_level
    self.school_levels.join ' | '
  end

  def product_grades
    self.grades.where(degree_ids: nil).pluck(:name).uniq.join ' | '
  end

  def product_degrees
    self.degrees.pluck(:name).uniq.join ' | '
  end

  def product_grades_degrees
    grades = self.grades.where(degree_ids: nil).pluck(:name)
    degrees = self.degrees.pluck(:name)
    (grades + degrees).uniq.compact.join ' | '
  end

  def product_subjects
    self.subjects.join ' | '
  end

  def self.get_instance(product_to_find)
    product = nil
    if product_to_find.is_a? BSON::ObjectId
      product = Product.find product_to_find
    elsif product_to_find.is_a? String
      product = Product.in(_slugs: product_to_find).first
    elsif product_to_find.is_a? Product
      product = product_to_find
    end
    raise ArgumentError, 'Product not found' if product.nil?
    product
  end

  def as_indexed_json(options={})
    hash = as_json({
      except: [:id, :_id],
      only: [:isbn, :series_name]
    })
    hash['subjects']       = self.subjects.map{|subject| subject.name}
    hash['editor']         = self.editor.name
    hash['school_levels']  = self.school_levels.map{|school_level| school_level.name}
    hash
  end


end
