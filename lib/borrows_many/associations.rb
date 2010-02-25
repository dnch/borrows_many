module BorrowsMany
  module Associations
    
    # Borrows_many!
    # ===Collection associations (one-to-many / many-to-many)
    #                                     | has_many |              |
    #   generated methods                 | :through | borrows_many |
    #   ----------------------------------+--------------------------
    #   others                            |    X     |      X       |
    #   other_ids                         |    X     |      X       |
    #   others.count                      |    X     |      X       |
    #   others.sum(args*,&block)          |    X     |      X       |
    #   others.empty?                     |    X     |      X       |
    #   others.find(*args)                |    X     |      X       |
    #   others.exists?                    |    X     |      X       |
    #   others.uniq                       |    X     |      X       |    
    def borrows_many(association_id, options = {})
      
      # our reflection gives us... well, not sure yet.
      reflection = create_borrows_many_reflection(association_id, options)
            
      # create the association and accessor methds
      collection_accessor_methods(reflection, BorrowsManyAssociation)
    end    


    mattr_accessor :valid_keys_for_borrows_many_association
    @@valid_keys_for_borrows_many_association = [:from]

    def create_borrows_many_reflection(association_id, options, &extension)
      options.assert_valid_keys(valid_keys_for_borrows_many_association)

      reflection = BorrowsMany::Reflection::BorrowsManyReflection.new(:borrows_many, association_id, options, self)
      write_inheritable_hash :reflections, association_id => reflection
      reflection
    end


    class BorrowsManyAssociation < ActiveRecord::Associations::AssociationCollection

      # Count all records using SQL. If the +:counter_sql+ option is set for the association, it will
      # be used for the query. If no +:counter_sql+ was supplied, but +:finder_sql+ was set, the
      # descendant's +construct_sql+ method will have set :counter_sql automatically.
      # Otherwise, construct options and pass them with scope to the target class's +count+.
      def count(*args)
        column_name, options = @reflection.klass.send(:construct_count_options_from_args, *args)


        options[:conditions] = "#{@reflection.quoted_link_table_name}.#{@reflection.join_key_name} = #{owner_quoted_id}"
        options[:conditions] << " AND (#{conditions})" if conditions
        
        construct_find_options!(options)

        @reflection.klass.send(:with_scope, construct_scope) { @reflection.klass.count(column_name, options) }
      end

      def calculate(operation, column_name, options = {})
        
        condtions = options.delete(:conditions)
        
        options[:conditions] = "#{@reflection.quoted_link_table_name}.#{@reflection.join_key_name} = #{owner_quoted_id}"
        options[:conditions] << " AND (#{conditions})" if conditions
        
        construct_find_options!(options)

        super(operation, column_name, options)
      end

      def construct_sql        
        @finder_sql = "#{@reflection.quoted_link_table_name}.#{@reflection.join_key_name} = #{owner_quoted_id}"
        @finder_sql << " AND (#{conditions})" if conditions
        @counter_sql = @finder_sql       
      end
      
      def construct_find_options!(options)
        options[:joins] = construct_join
      end
      
      def construct_join
        # INNER JOIN allocations_schedules ON allocations_schedules.schedule_id = units.schedule_id
        "INNER JOIN %s ON %s.%s = %s.%s" % [@reflection.link_table_name, 
                                            @reflection.link_table_name, 
                                            @reflection.foreign_key_name,
                                            @reflection.source_table_name,
                                            @reflection.foreign_key_name]
      end
    end
  end
end