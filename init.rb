require 'borrows_many'

ActiveRecord::Base.extend BorrowsMany::Associations
ActiveRecord::Base.extend BorrowsMany::Reflection