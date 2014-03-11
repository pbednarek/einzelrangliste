class ChallengesController < ApplicationController
  def new
    @challenge = Challenge.new(
        challenging_player: current_user,
        challenged_player: params[:user_id],
        suggestions:[Time.now, Time.now, Time.now],
        due_date: (Time.now+14.days).to_date
    )
  end
end
