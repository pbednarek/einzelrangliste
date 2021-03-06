class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type:  Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  field :name, type: String
  field :wins, type: Integer, default: 0
  field :losses, type: Integer, default: 0
  field :rank, type: Integer
  field :admin, type: Boolean, default: false
  field :active, type: Boolean, default: true
  field :inactive_until, type: Date

  has_many :own_challenges, class_name: 'Challenge', inverse_of: :challenging_player
  has_many :foreign_challenges, class_name: 'Challenge', inverse_of: :challenged_player
  has_many :won_challenges, class_name: 'Challenge', inverse_of: :winner

  validates_presence_of :name
  before_create :set_initial_rank

  def admin?
    admin
  end

  def can_challenge?(user)
    challengeables.include?(user.rank) && (Challenge.with_participation_of(self).size < 1)
  end

  def challengeables
    if active
      min_rank = rank - row + 1
      min_rank -= 1 if rank == 3
      max_rank = rank - 1
    else
      min_rank = rank
      max_rank = User.where(active: true).asc.last.rank
    end
    (min_rank..max_rank)
  end

  def update_rank_to(new_rank)
    User.where(active: true).where(rank: new_rank..rank-1).each do |standing|
      standing.rank +=1
      standing.save
    end
    update_attributes(rank: new_rank)
  end

  def neutralize(end_date)
    # Upping rank of each active player
    active_users = User.where(active: true)
    active_users.where(rank: rank+1..active_users.size).each do |player|
      player.rank -= 1
      player.save
    end

    update_attributes(active: false, inactive_until: end_date)
  end

  def needs_comment?
    !Challenge.where(challenged_player_id: self.id).where(winner_id: self.id).any? { |chlng| (Date.today-2.days..Date.today).include? chlng.play_date.to_date }
  end

  # Method to insert player to specific position e.g. after deneutralization
  def deneutralize_to(target)
    active_users = User.where(active: true)
    active_users.where(rank: target..active_users.size).each do |player| 
      player.rank += 1
      player.save
    end
    update_attributes(rank: target, active: true, inactive_until: nil)
  end

  def to_s
    name
  end

  protected
  def set_initial_rank
    user = User.all.desc(:rank).first
    unless user.nil?
      self.rank = user.rank+1
    else
      self.rank = 1
    end
  end

  def row
    row_counter = 1
    tri_num = 1
    while tri_num < rank
      row_counter += 1
      tri_num += row_counter
    end
    row_counter
  end

end
