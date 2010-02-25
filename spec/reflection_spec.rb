require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe BorrowsMany::Reflection::BorrowsManyReflection do
  before(:each) do
    @reflection = Allocation.reflections[:units]
  end
  
  it "should give us an BorrowsManyReflection" do
    @reflection.class.should == BorrowsMany::Reflection::BorrowsManyReflection
  end
  
  it "should give us Unit when asked for the klass" do
    @reflection.klass.should == Unit
  end
  
  it "should derive the correct join table name" do
    @reflection.link_table_name.should == "allocations_schedules"
  end
  
  it "should derive the correct source table name" do
    @reflection.source_table_name.should == "units"
  end
  
  it "should derive the correct foreign key" do
    @reflection.foreign_key_name.should == "schedule_id"
  end
  
  it "should derive the correct join key" do
    @reflection.join_key_name.should == "allocation_id"
  end
  
end