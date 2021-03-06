class ChallengesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @challenges = Challenge.active_challenges
    @history = Challenge.history
  end

  def new
    @challenge = Challenge.new(
        challenging_player: current_user,
        challenged_player: params[:user_id],
        suggestions:[Time.now.beginning_of_day + 19.hours, Time.now.beginning_of_day + 19.hours, Time.now.beginning_of_day + 19.hours]
    )
  end

  def create
    p = params[:challenge]
    @challenge = Challenge.new
    @challenge.challenged_player_id = p[:challenged_player_id]
    @challenge.challenging_player = current_user
    @challenge.suggestions = p[:suggestions].map do |suggestion|
      create_date_time suggestion[:date], suggestion[:time]
    end
    @challenge.location = p[:location]
    @challenge.state = 'created'
    @challenge.due_date = (Time.now+14.days).to_date
    if @challenge.save
      redirect_to root_path, notice: "Challenge has been created"
    else
      render action: 'new'
    end
  end

  def accept
    c = Challenge.find params[:id]
    accepted_date = params[:accepted_date]

    if Date.parse(accepted_date) < Date.today
      redirect_to root_path, alert: "Please pick a date in the future"
    end

    if c.update_attributes(play_date: accepted_date, state: 'accepted')
      redirect_to root_path, notice: 'Challenge accepted.'
    else
      redirect_to root_path, alert: c.errors.messages.join('; ')
    end
  end

  def deny
    needs_comment = current_user.needs_comment?
    c = Challenge.find(params[:id])
    comment = params[:comment]
    redirect_to root_path, alert: "You need to provide a comment." if needs_comment && (comment.nil? || comment.length < 1)
    unless needs_comment
      c.update_attributes(state: 'denied')
      redirect_to root_path, notice: "Challenge has been denied."
    else
      c.update_attributes(state: 'challenged', comment: comment)
      redirect_to root_path, notice: "An Admin will check your reason for denial."
    end
  end

  def pick_winner
    usr = User.find params[:winner_id]
    c = Challenge.find params[:id]
    c.set_winner usr
    redirect_to root_path, notice: "The winner has been set."
  end

  protected
  def create_date_time(date, time)
    DateTime.parse(date+" "+time+":00 +0100")
  end
end
