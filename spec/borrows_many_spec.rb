require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Group do
  before(:each) do
    @group = Group.create!

    @post1 = Post.create!
    @post2 = Post.create!
    
    3.times { @post1.comments.create }
    6.times { @post2.comments.create }

    @group.posts << @post1
    @group.posts << @post2
  end
  
  it "should have the correct number of comments" do
    @group.comments.count.should == (@post1.comments.count + @post2.comments.count)
  end
end
