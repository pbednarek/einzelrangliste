class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @challenge = Challenge.with_participation_of(current_user).first
  end
end
