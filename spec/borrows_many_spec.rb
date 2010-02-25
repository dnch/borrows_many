require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Allocation do
  before(:each) do
    # empty schedules
    @schedule_a = Schedule.create!
    @schedule_b = Schedule.create!

    # a                                                                                                                                                                                                                                                                                                     2nd our allocation
    @allocation = Allocation.create!

    # create an indeterminate number of units for each schedule; this way our spec comparisons are only ever compared against eachother, never hard-coded data
    [@schedule_a, @schedule_b].each do |schedule|
      (rand(15) + 1).times do
        schedule.units.create(:quality => rand(100), :quantity => rand(100))
      end

      @allocation.schedules << schedule
    end
    
    # finally, create some bullshit data in the database to ensure what we're querying is not the entire scope of operations
    (rand(150) + 1).times do
      Unit.create!(:quality => rand(100), :quantity => rand(100))
    end
  end


  it "should be simulated to prove our theory..." do    
    simulated_args = {
      :conditions => ["allocations_schedules.allocation_id = ?", @allocation.id],
      :joins => "INNER JOIN allocations_schedules ON allocations_schedules.schedule_id = units.schedule_id"
    }
    
    Unit.find(:all, simulated_args).count.should == (@schedule_a.units.count + @schedule_b.units.count)
  end

  it "should find the same units as both schedules combined" do
    @allocation.units.to_a.should == (@schedule_a.units.to_a + @schedule_b.units.to_a)
  end

  it "should have the same unit count as both schedules combined" do
    @allocation.units.count.should == (@schedule_a.units.count + @schedule_b.units.count)
    @allocation.units.count.should_not == Unit.count
  end

  it "should have the total sum of quality as both schedules combined" do
    @allocation.units.sum(:quality).should == (@schedule_a.units.sum(:quality) + @schedule_b.units.sum(:quality))
  end

  it "should operate through scopes" do
    @allocation.units.high_quality.count.should == (@schedule_a.units.high_quality.count + @schedule_b.units.high_quality.count)    
  end
  

  it "should allow me to make a complex group query" do
    # allows us to find them quickly later.
    @indexed_schedules = {}
    @indexed_schedules[@schedule_a.to_param] = @schedule_a
    @indexed_schedules[@schedule_b.to_param] = @schedule_b
  
    @complex_results = @allocation.units.find(:all, :select => 'units.schedule_id, count(*) AS unit_count, sum(quality) AS sum_unit_quality, avg(quantity) AS avg_unit_quantity', :group => 'units.schedule_id')

    Rails.logger.debug { "=" * 120 }
    Rails.logger.debug { "*** Group Query Complex Results: #{@complex_results.map(&:attributes).inspect}" }
    Rails.logger.debug { "=" * 120 }
  
    @complex_results.map(&:attributes).each do |result|
      result.to_options!
      schedule = @indexed_schedules[result[:schedule_id].to_s]
  
      result[:unit_count].to_i.should == schedule.units.count
      result[:sum_unit_quality].to_i.should == schedule.units.sum(:quality)
      BigDecimal.new(result[:avg_unit_quantity]).should == schedule.units.average(:quantity)
    end
  end
end