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
    create_table :allocations_schedules, :force => true, :id => false do |t|
      t.column "allocation_id", :integer
      t.column "schedule_id", :integer
    end
    
    create_table :allocations, :force => true do |t|
    end  
    
    create_table :schedules, :force => true do |t|
    end

    create_table :units, :force => true do |t|
      t.column "quality", :integer
      t.column "quantity", :integer
      t.column "schedule_id", :integer
    end    
  end
end

# -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  ----- 8< -----  -----

class Unit < ActiveRecord::Base
  belongs_to :schedule  
  named_scope :high_quality, :conditions => ['quality > ?', 50]  
end

class Schedule < ActiveRecord::Base
  has_and_belongs_to_many :allocations
  has_many :units
end

class Allocation < ActiveRecord::Base
  has_and_belongs_to_many :schedules
  borrows_many :units, :from => :schedules
end