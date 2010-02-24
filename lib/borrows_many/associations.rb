module BorrowsMany
  module Associations
    
    # We're overloading has_many so we can pre-emptively check to see if we're trying to define a hm :thru habtm
    # If we are, use our own Association class, rather than the stock HM.
    def borrows_many(association_id, options = {})

      # grab the reflection for what we're targeting... if we're trying to go through habtm...
      if options[:through] && reflect_on_association(options[:through]).macro == :has_and_belongs_to_many

        # build the reflection
        reflection = create_has_many_reflection(association_id, options, &extension)

        # configure_dependency_for_has_many(reflection)
        # 
        # add_association_callbacks(reflection.name, reflection.options)

        # finally, define our methods -- the current usecase for this is READ ONLY, so let's just leave it at that.
        collection_accessor_methods(reflection, BorrowsManyAssociation, false)


        # Rails.logger.debug { "*" * 120 }
        # Rails.logger.debug { "Create our own macro!" }
        # Rails.logger.debug { "*" * 120 }
      else
        super      
      end
    end    
  end
end