class BaseLeaderboard < ApplicationRecord
  include PolymorphicSubmitter

  belongs_to :challenge
  belongs_to :meta_challenge, optional: true, class_name: 'Challenge'
  belongs_to :challenge_round

  as_enum :leaderboard_type,
          [:leaderboard, :ongoing],
          map: :string

  scope :by_country, ->(country_name) { where(participants: { country_cd: Participant.country_cd(country_name) }) }
  scope :by_affiliation, ->(affiliation) { where(participants: { affiliation: affiliation }) }

  def self.morph_submitter!(from:, to:, challenge_id:)
    raise ArgumentError unless challenge_id && from && to

    all.where(
      challenge_id: challenge_id,
      submitter:    from
    ).update_all(
      submitter_type: to.class.name,
      submitter_id:   to.id
    )
  end
end
