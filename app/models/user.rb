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

  has_many :own_challenges, class_name: 'Challenge', inverse_of: :challenging_player
  has_many :foreign_challenges, class_name: 'Challenge', inverse_of: :challenged_player

  validates_presence_of :name
  before_create :set_rank

  def admin?
    admin
  end

  protected
  def set_rank
    user = User.all.desc(:rank).first
    unless user.nil?
      self.rank = user.rank+1
    else
      self.rank = 1
    end
  end

end
