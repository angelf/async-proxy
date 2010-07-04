require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Integer
  def slow_inc
    Kernel.sleep(1)
    self + 1
  end
end

describe "AsyncProxy" do

  it "sync is idempotent" do
    1.sync.should == 1
  end

  it "async is idempotent" do
    x = 1.async
    x.async == x
  end
  
  it "simple call" do
    1.async.slow_inc.sync.should == 2
  end
  
  it "chained call" do
    1.async.slow_inc.div(2).sync.should == 1
  end

  it "chained call with intermediate object already synchronized" do
    intermediate = 1.async.slow_inc
    divided = intermediate.div(2)
    
    intermediate.sync
    divided.sync.should == 1
  end

  it "chained call + when ready" do
    1.async.slow_inc.div(2).when_ready{|one| one + 2}.sync.should == 3
  end
  
  it "shared intermediate object" do
    intermediate = 0.async.slow_inc
    intermediate_plus_1 = intermediate.when_ready{|x| x + 1}
    intermediate_plus_2 = intermediate.when_ready{|x| x + 2}

    intermediate.sync.should == 1
    intermediate_plus_1.sync.should == 2
    intermediate_plus_2.sync.should == 3
  end
  
end
