module Edulib
  module Datatable

    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end

    module ClassMethods

      def datatable_config(url, start = nil, length = nil, order = nil)
        search_fields = datatable_search_fields
        class_name = self.model_name.element

        config = {
          ajax: {
            url: url,
            type: :post
          },
          scrollX: true,
          pagingType: 'full_numbers',
          serverSide: true,
          displayStart: start || 0,
          pageLength: length || 25,
          filter: false,
          columns: [],
          order: order || [[0, 'asc']],
          language: {
            processing: I18n.t('datatable.treatment_ongoing'),
            search: "#{I18n.t('datatable.search')} :",
            lengthMenu: I18n.t('datatable.show'),
            info: I18n.t('datatable.info'),
            infoEmpty: I18n.t('datatable.info_empty'),
            infoFiltered: I18n.t('datatable.info_filtered'),
            loadingRecords: I18n.t('datatable.loading_records'),
            zeroRecords: I18n.t('datatable.zero_records'),
            emptyTable: I18n.t('datatable.empty_table'),
            paginate: {
              first: I18n.t('datatable.paginate.first'),
              previous: I18n.t('datatable.paginate.previous'),
              next: I18n.t('datatable.paginate.next'),
              last: I18n.t('datatable.paginate.last')
            }
          }
        }
        datatable_fields.each do |field|
          title = (field == :_id) ?
            I18n.t("table.#{class_name}.thead.action") :
            I18n.t("table.#{class_name}.thead.#{field}")
          config[:columns] << {
            title: title,
            name: field,
            searchable: search_fields.include?(field),
            orderable: search_fields.include?(field),
            className: column_css_class(field)
          }
        end

        unless datatable_callbacks.blank?
          if datatable_callbacks.include? :row_href
            config[:rowCallback] = 'jsCallBack::rowHref'
            config[:columns].last[:visible] = false
          end
        end

        config.to_json
      end

      ##
      # Exclude fields from table display
      #
      # It expects to be an Array of String
      def datatable_exclude_fields
        # None
        []
      end

      ##
      # Define formatters for specifics fields
      # Expected format :
      # {
      #   field_name: :formatter,
      #   field_name: :formatter
      # }
      #
      # Exemple :
      # {
      #   amount: :currency,
      #   tax: :percentage
      # }
      #
      def datatable_format_fields
        # None
        {}
      end

      def datatable_fields_order
        # None
        []
      end

      def datatable_callbacks
        # None
        []
      end

      def datatable_fields
        attributes = model_fields
        attributes += enumerized_fields
        attributes += vat_fields if vat_fields.present?
        attributes += attachment_fields.map{|af| (datatable_exclude_fields.include?(af.to_s)) ? nil : af}.compact
        #TODO FIX that ugly hack
        #attributes = datatable_fields_order & attributes unless datatable_fields_order.blank?
        attributes = datatable_fields_order unless datatable_fields_order.blank?
        attributes << '_id'
        attributes.map! &:to_sym
        attributes
      end

      def datatable_fields_types
        datatable_fields.map { |field| field_type field.to_s }
      end

      def datatable_search_fields
        attributes = model_fields
        attributes = remove_fields attributes, non_searchable_fields
        attributes.map! &:to_sym
      end

      def enum_fields
        enumerized_fields.map! &:to_sym
      end

      def vat_fields
      end

      def date_fields
        self.fields.select { |key, field| field.type == Date }.keys.map!(&:to_sym).select { |att| datatable_fields.include? att }
      end

      def date_time_fields
        self.fields.select { |key, field| field.type == DateTime }.keys.map!(&:to_sym).select { |att| datatable_fields.include? att }
      end

      def boolean_fields
        self.fields.select { |key, field| field.type == Mongoid::Boolean }.keys.map!(&:to_sym).select { |att| datatable_fields.include? att }
      end

      def paperclip_fields
        attachment_fields.map!(&:to_sym)
      end

      def is_image
        true
      end

      private

      def column_css_class(field)
        case field
        when :_id
          return nil #:right
        when :published
          return :published
        else
          return boolean_fields.include?(field) ? :center : nil
        end
      end

      def model_fields
        attributes = self.attribute_names - %w(_id created_at updated_at _slugs)
        attachments_names = attachment_fields
        if attachments_names.present?
          attributes = remove_attachment_fields attributes, attachments_names
        end
        attributes = remove_fields attributes, relation_fields
        remove_fields attributes, datatable_exclude_fields
      end

      def enumerized_fields
        attributes = []
        if self.respond_to?(:enumerized_attributes) && !self.enumerized_attributes.empty?
          attributes = self.enumerized_attributes.attributes.keys
        end
        remove_fields attributes, datatable_exclude_fields
      end

      def attachment_fields
        attachments = self.attribute_names.select { |val| %r{.*_file_name} =~ val }
        attachments.map! { |x| x.remove '_file_name' }
      end

      def relation_fields
        self.attribute_names.select { |val| %r{.*_id} =~ val }
      end

      def non_searchable_fields
        self.attribute_names.select do |val|
          %w(String Integer Float Mongoid::Boolean).exclude? field_type val
        end
      end

      def field_type(field_name)
        type = ''
        field = self.fields[field_name]
        if field
          type = field.type.to_s
        elsif attachment_fields.include? field_name
          type = 'attachment'
        end
        type
      end

      def remove_fields(attributes, relation_names)
        attributes - relation_names
      end

      def remove_attachment_fields(attributes, attachments_names)
        attachments_names.each do |name|
          attributes -= %W(#{name}_content_type #{name}_file_name #{name}_file_size #{name}_updated_at #{name}_fingerprint)
        end
        attributes
      end
    end

    module InstanceMethods
      def is_image?(field)
        self.respond_to?("#{field}_content_type") && %w(image/jpeg image/png image/gif).include?(self.send("#{field}_content_type"))
      end
    end
  end
end
