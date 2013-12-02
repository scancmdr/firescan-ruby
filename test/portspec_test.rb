require 'test/unit'
require 'shoulda'
require_relative '../lib/firebind/portspec'

class TestPortspec < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail


    #fail('Not implemented')
  end


  context 'parsing' do

    should 'properly handle out of order ports and collapse ranges' do
      assert_equal(Firebind::Portspec.new('6,5,4,3,2,50-60').to_s, '2-6,50-60')
    end

    should 'reject invalid characters' do
      assert_raises(ArgumentError) do
        Firebind::Portspec.new('1-10,abc,20,30')
      end
    end

    should 'handle out of order ports and contiguous ranges' do
      assert_equal(Firebind::Portspec.new('6,5,4445,4,3,2,50-60,666,69,55,65534,65535').to_s, '2-6,50-60,69,666,4445,65534-65535')
    end

    should 'reject invalid port numbers' do
      assert_raises(ArgumentError) do
        Firebind::Portspec.new('1-10,65536')
      end
    end


  end

end
