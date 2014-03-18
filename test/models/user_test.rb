require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup 
    clean_mongodb!
  end

  def teardown
    clean_mongodb!
  end

  test "third user climbs to top of the list" do
    make_sure_at_least_n_users_exist!(4)

    first = User.all.asc(:rank).first
    second = User.all.asc(:rank)[1]
    third = User.all.asc(:rank)[2]

    inactive = User.last
    rand_rank = rand(1..User.all.size)
    inactive.update_attributes(rank: rand_rank, active: false)

    third.update_rank_to(1)

    assert_equal(1, third.reload.rank, "Third user is not on first")
    assert_equal(2, first.reload.rank, "First user is not on second")
    assert_equal(3, second.reload.rank, "Second user is not on third")
    assert_equal(rand_rank, inactive.reload.rank, "Rank of inactive user gets touched")
  end

  test "first user gets neutralized" do
    make_sure_at_least_n_users_exist!(4)

    first = User.all.asc(:rank).first
    second = User.all.asc(:rank)[1]
    third = User.all.asc(:rank)[2]

    inactive = User.last
    rand_rank = rand(1..User.all.size)
    inactive.update_attributes(rank: rand_rank, active: false)

    first.neutralize

    assert_equal(1, first.reload.rank, "First user is not on first")
    assert_equal(1, second.reload.rank, "Second user is not on first")
    assert_equal(2, third.reload.rank, "Third user is not on second")
    assert_equal(false, first.reload.active, "First user is still active")
    assert_equal(rand_rank, inactive.reload.rank, "Rank of inactive user gets touched")
  end

  test "first user gets de-neutralized" do
    make_sure_at_least_n_users_exist!(4)

    first = User.all.asc(:rank).first
    second = User.all.asc(:rank)[1]
    third = User.all.asc(:rank)[2]

    inactive = User.last
    rand_rank = rand(1..User.all.size)
    inactive.update_attributes(rank: rand_rank, active: false)

    first.neutralize
    first.deneutralize_to(2)

    assert_equal(1, second.reload.rank, "Second user is not on first")
    assert_equal(2, first.reload.rank, "First user is not on second")
    assert_equal(3, third.reload.rank, "Third user is not on third")
    assert_equal(true, first.reload.active, "First user is still inactive")
    assert_equal(rand_rank, inactive.reload.rank, "Rank of inactive user gets touched")
  end
end
