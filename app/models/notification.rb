class Notification < ApplicationRecord
  belongs_to :participant
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :challenge, optional: true

  default_scope { order(created_at: :desc) }

  scope :pristine, -> { where(is_new: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  validates :notification_type, presence: true

  NOTIFICATION_TYPE = {
    'Mention'        => :mention,
    'Graded'         => :graded,
    'Grading Failed' => :grading_failed,
    'Leaderboard'    => :leaderboard,
    'Article'        => :article,
    'Discourse'      => :discourse
  }.freeze

  def read?
    read_at.present?
  end

  def self.active
    participant      = first.participant
    part_leaderboard = participant.leaderboards

    participant_leaderbaord_notifications = participant.notifications.where(notifiable: part_leaderboard)

    freeze_leaderboard_ids = []

    part_leaderboard.each do |leaderboard|
      if leaderboard.is_freeze?(challenge_round: leaderboard.challenge_round, participant: participant)
        freeze_leaderboard_ids << leaderboard.id
      end
    end
    freeze_notification = participant_leaderbaord_notifications.where(notifiable_id: freeze_leaderboard_ids.uniq)

    all - freeze_notification
  end
end
