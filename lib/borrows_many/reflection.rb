module BorrowsMany
  module Reflection
    class BorrowsManyReflection < ActiveRecord::Reflection::MacroReflection
    
      # Given Thing.borrows_many :widgets, :from => :sources, this will return the widgets reflection on Source
      def source_reflection
        @source_reflection ||= from_reflection.klass.reflect_on_association(name)
      end
      
      # Given Thing.borrows_many :widgets, :from => :sources, this will return the sources reflection on Thing
      def from_reflection
        @from_reflection ||= active_record.reflect_on_association(options[:from])
      end

      def klass
        @klass ||= active_record.send(:compute_type, class_name)
      end

      def link_table_name
        @link_table_name ||= derive_link_table_name
      end
      
      def foreign_key_name 
        @foreign_key_name ||= derive_foreign_key_name         
      end
      
      def join_key_name
        @join_key_name ||= derive_join_key_name
      end
      
      def source_table_name
        @source_table_name ||= derive_source_table_name
      end

      def quoted_source_table_name
        %Q{"#{source_table_name}"}
      end
      
      def quoted_link_table_name
        %Q{"#{link_table_name}"}
      end

      def class_name
        name.to_s.singularize.camelize
      end

      
      private
      
      def derive_link_table_name
        [active_record.table_name, from_reflection.table_name].sort.join("_")
      end
      
      def derive_foreign_key_name
        "#{from_reflection.table_name.singularize}_id"
      end
      
      def derive_join_key_name
        "#{active_record.table_name.singularize}_id"
      end
      
      def derive_source_table_name
        source_reflection.table_name
      end
    end
  end
end