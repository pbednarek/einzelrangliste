ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def clean_mongodb!
    Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/}.each {|c| c.find.remove_all}
  end

  def make_sure_at_least_n_users_exist!(n)
    if User.count < n
      # print "User.count = #{User.count}, creating users..."
      left_over = n - User.count
      count = User.count
      left_over.times do |i|
        # puts "creating user #{count+i+1}"
        User.create! name: "user#{count+i+1}", email: "user#{count+i+1}@example.com", password: Devise.friendly_token
        # u.confirm!
      end
      # puts " done"
    end
  end

  def create_challenge!
    make_sure_at_least_n_users_exist!(2)
    Challenge.create(
      challenging_player: User.first, 
      challenged_player: User.last,
      location: "Foo",
      suggestions: 3.times.map{ |i| Time.now + (i+1).days }
    )
  end
end
