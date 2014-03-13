require 'test_helper'

class ChallengeTest < ActiveSupport::TestCase
  def setup 
    clean_mongodb!
  end

  def teardown
    clean_mongodb!
  end

  test "valid challenges can be saved" do
    assert create_challenge!, "Challenge could not be created."
  end

  test "suggestions can't be in the past" do
    challenge = create_challenge!
    challenge.suggestions[0] = Time.now - 2.days
    assert_not challenge.save, "Challenge could be saved."
  end

  test "suggestions must be unique" do 
    suggestions = 3.times.map{|i| Time.now + (i+1).hour}
    challenge = create_challenge!
    challenge.suggestions = suggestions
    assert_not challenge.save, "Challenge could be saved."
  end

  test "suggestions can't be further than 14 days away" do
    challenge = create_challenge!
    challenge.suggestions[0] = Time.now + 15.days
    assert_not challenge.save, "Challenge could be saved."
  end
end
