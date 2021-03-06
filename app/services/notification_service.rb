class NotificationService
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper

  def initialize(participant_id, notifiable, notification_type)
    @participant       = Participant.find(participant_id)
    @notifiable        = notifiable
    @notification_type = notification_type
  end

  def call
    send(@notification_type) if ['graded', 'failed', 'leaderboard'].include?(@notification_type)
  end

  private

  def graded
    score   = @notifiable.score || 0.0
    message = "Your #{@notifiable.challenge.challenge} Challenge submission ##{@notifiable.id} has been graded with a score of #{score}"
    thumb   = @notifiable.challenge.image_file.url
    link    = challenge_submission_url(@notifiable.challenge, @notifiable.id)

    existing_notification = @participant.notifications.where(notifiable: @notifiable, is_new: true).first

    return if existing_notification.present?

    Notification
      .create!(
        participant:       @participant,
        notifiable:        @notifiable,
        notification_type: @notification_type,
        message:           message,
        thumbnail_url:     thumb,
        notification_url:  link,
        challenge_id:      @notifiable.challenge.id,
        is_new:            true)
  end

  def failed
    message = "Your #{@notifiable.challenge.challenge} Challenge submission ##{@notifiable.id} failed to evaluate."
    thumb   = @notifiable.challenge.image_file.url
    link    = challenge_submission_url(@notifiable.challenge, @notifiable.id)

    existing_notification = @participant.notifications.where(notifiable: @notifiable, is_new: true).first

    return if existing_notification.present?

    Notification
      .create!(
        participant:       @participant,
        notifiable:        @notifiable,
        notification_type: @notification_type,
        message:           message,
        thumbnail_url:     thumb,
        notification_url:  link,
        challenge_id:      @notifiable.challenge.id,
        is_new:            true)
  end

  def leaderboard
    return if @participant.nil? || @notifiable.previous_row_num == @notifiable.row_num

    # get similar unread notification of challenge
    existing_notification = @participant.notifications.where(notification_type: 'leaderboard', challenge_id: @notifiable.challenge.id, is_new: true)
    existing_notification.delete_all # delete old unread notification of this challenge

    message = "You have moved from #{@notifiable.previous_row_num} to #{@notifiable.row_num} place in the #{@notifiable.challenge.challenge} leaderboard"
    thumb   = @notifiable.challenge.image_file.url
    link    = challenge_leaderboards_url(@notifiable.challenge)

    # create new notification for this challenge
    Notification
      .create!(
        participant:       @participant,
        notifiable:        @notifiable,
        notification_type: @notification_type,
        message:           message,
        thumbnail_url:     thumb,
        notification_url:  link,
        challenge_id:      @notifiable.challenge.id,
        is_new:            true)
  end
end
