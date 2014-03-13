class ChallengesController < ApplicationController
  def new
    @challenge = Challenge.new(
        challenging_player: current_user,
        challenged_player: params[:user_id],
        suggestions:[Time.now.beginning_of_day + 19.hours, Time.now.beginning_of_day + 19.hours, Time.now.beginning_of_day + 19.hours]
    )
  end

  def create
    p = params[:challenge]
    challenge = Challenge.new
    challenge.challenged_player_id = p[:challenged_player_id]
    challenge.challenging_player = current_user
    challenge.suggestions = p[:suggestions].map do |suggestion|
      create_date_time suggestion[:date], suggestion[:time]
    end
    challenge.location = p[:location]
    challenge.state = 'created'
    challenge.due_date = (Time.now+14.days).to_date
    puts challenge.to_json
    challenge.save!
    redirect_to root_path
  end

  def accept
    c = Challenge.find params[:id]
    date = params[:accepted_date]
    c.update_attributes(play_date: date, state: 'active')
    redirect_to root_path, notice: 'Challenge accepted.'
  end

  protected
  def create_date_time(date, time)
    DateTime.parse(date+" "+time+":00 +0100")
  end
end
