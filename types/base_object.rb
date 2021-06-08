class Types::BaseObject < GraphQL::Schema::Object
  implements GraphQL::Relay::Node.interface
  global_id_field :id

  def self.connection(field_sym, connection_class, options={})
    field field_sym,
          connection_class,
          null: true,
          max_page_size: 200,
          resolve: ->(obj, args, ctx) {
            query = options[:base_resolve] ? options[:base_resolve].call(obj, args, ctx) : obj.send(field_sym)
            # ForeignKeyLoader.for(obj.class, field_sym).load([obj.id])
            # Run permission checks
            if (query.respond_to?(:relay_connection))
              query = query.relay_connection(ctx)
            end

            # TODO(eric): Don't allow filter or sort by on pre-resolved queries
            query = handle_filter(query, args[:filter])
            query = handle_sort_by(query,
                                   args[:sortBy],
                                   obj,
                                   connection_class::ATTRIBUTE_WHITELIST,
                                   connection_class::DIRECTION_WHITELIST,
                                 )

            query = options[:post_process].call(query, obj, args, ctx) if options[:post_process]
            query
          } do
      argument :sort_by, String, required: false

      filter_class = options[:filter]
      unless filter_class.nil?
        argument :filter, filter_class, required: false
      end
    end
  end

  def self.handle_filter(query, input)
    unless input.nil?
      query = input.resolve(query)
    end
    query
  end

  def self.handle_sort_by(query, input, obj, search_whitelist, direction_whitelist)
    unless input.nil?
      cleaned_args = []
      input.split(' ').each do |field|
        field_parts = field.rpartition('_')
        name = field_parts.first.underscore
        direction = field_parts.last

        unless search_whitelist.include?(name.to_sym)
          raise (GraphQL::ExecutionError.new("Sort search terms invalid: #{name}, whitelist: #{search_whitelist}"))
        end
        unless direction_whitelist.include?(direction.to_sym)
          raise (GraphQL::ExecutionError.new("Sort direction terms invalid: #{direction}"))
        end
        cleaned_args << "#{name} #{direction}"
      end


      if (obj.respond_to?(:graphql_custom_sort))
        query = obj.graphql_custom_sort(query, cleaned_args)
      else
        query = query.order(cleaned_args.join(','))
      end
    end
    query
  end


  # field :id, ID, null: false
  # def id
  #   # Rails.logger.tagged("GraphQL") { Rails.logger.info "#{self.class.to_s}#id is not defined, using fallback" }
  #   ident = "#{object.class.to_s}::#{self.get_record_id(object)}"
  #   Rails.env.development? ? ident : Base64.strict_encode64(ident)
  # end
  #
  # protected
  # # Override to specify a different way of retrieving ActiveRecord ID
  # def get_record_id(object)
  #   object.id
  # end
end
