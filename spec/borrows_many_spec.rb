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

      @allocation.schedules << schedules
    end
  end

  it "should have the same unit count as both schedules combined" do
    @allocation.units.count.should == (@schedule_a.units.count + @schedule_b.units.count)
  end

  it "should have the total sum of quality as both schedules combined" do
    @allocation.units.sum(:quality).should == (@schedule_a.units.sum(:quality) + @schedule_b.units.sum(:quality))
  end

  it "should allow me to make a complex group query" do

    # allows us to find them quickly later.
    @indexed_schedules = {}
    @indexed_schedules[@schedule_a.to_param] = @schedule_a
    @indexed_schedules[@schedule_b.to_param] = @schedule_b

    @complex_results = @allocation.units.find(:all, :select => 'schedule_id, count(*) AS unit_count, sum(quality) AS sum_unit_quality, avg(quantity) AS avg_unit_quantity', :group => 'schedule_id')

    @complex_results.attributes.each do |result|
      result.symbolize_keys!
      schedule = @indexed_schedules[result[:schedule_id]]

      result[:unit_count].should == schedule.units.count
      result[:sum_unit_quality].should == schedule.units.sum(:quality)
      result[:avg_unit_quantity].should == schedule.units.average(:quantity)
    end
  end
end