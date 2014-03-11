class HomeController < ApplicationController
  def index
    @challenge = Challenge.with_participation_of(current_user).first
  end
end
