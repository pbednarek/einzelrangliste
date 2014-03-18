require 'test_helper'

class ChallengesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "a winner and all ranks, wins and losses are set correctly" do
    make_sure_at_least_n_users_exist!(4)
    challenge = create_challenge! # user.first vs. user.last

    last = User.last
    first = User.first

    sign_in first

    post :pick_winner, id: challenge.id, winner_id: last.id 

    assert_equal last.reload.id, challenge.reload.winner_id, "Winner ID is not set correctly"
    assert_equal 1, last.reload.wins, "The wins are not correct"
    assert_equal 1, first.reload.losses, "The losses of the opponent are not correct"
    assert_equal 1, last.reload.rank, "The rank of the winning player is not set correctly"
    assert_equal 2, first.reload.rank, "The rank of the losing player is not set correctly"
  end
end
