ENV["RAILS_ENV"] ||= "test"

require File.expand_path(File.join(File.dirname(__FILE__), "../../../../config/environment"))
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'
end

# -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  -----

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :groups, :force => true do |t|
    end
    
    create_table :groups_posts, :force => true, :id => false do |t|
      t.column "group_id", :integer
      t.column "post_id", :integer
    end
    
    create_table :posts, :force => true do |t|
    end

    create_table :comments, :force => true do |t|
      t.column "quality", :integer
      t.column "post_id", :integer
    end    
  end
end

# -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  -----

class Comment < ActiveRecord::Base
  belongs_to :post
end

class Post < ActiveRecord::Base
  has_and_belongs_to_many :groups
  has_many :comments
end

class Group < ActiveRecord::Base
  has_and_belongs_to_many :posts
  has_many :comments, :through => :posts
end