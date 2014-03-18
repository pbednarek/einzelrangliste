class AdminController < ApplicationController
  def index
    @challenges = Challenge.active_challenges
    @need_action = Challenge.challenged_challenges
  end
end