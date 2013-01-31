require 'spec_helper'

describe MicroQ do
  describe '.configure' do
    it 'should be the config' do
      MicroQ.configure {|config| config.class.should == MicroQ::Config }
    end

    it "should cache the value" do
      configs = []

      2.times { MicroQ.configure {|c| configs << c } }

      configs[0].should == configs[1]
    end
  end

  describe '.config' do
    it 'should be the config' do
      MicroQ.config.class.should == MicroQ::Config
    end
  end

  describe '.start' do
    def start
      MicroQ.start
    end

    before do
      @queue = mock(MicroQ::Queue::Default, :start => nil)
      MicroQ::Queue::Default.stub(:new).and_return(@queue)
    end

    it 'should create a queue' do
      MicroQ::Queue::Default.should_receive(:new).and_return(@queue)

      start
    end

    it 'should cache the queue' do
      MicroQ::Queue::Default.should_receive(:new).once.and_return(@queue)

      2.times { start }
    end
  end

  describe '.push' do
    let(:args) { { 'class' => 'WorkerClass' } }

    def push
      MicroQ.push(args)
    end

    before do
      @async = mock(Celluloid::ActorProxy)
      @queue = mock(MicroQ::Queue::Default, :run => nil, :async => @async)

      MicroQ::Queue::Default.stub(:new).and_return(@queue)

      MicroQ.start
    end

    it 'should delegate to the default queue' do
      @async.should_receive(:push).with([args])

      push
    end
  end
end