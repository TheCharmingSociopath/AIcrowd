class CommentEveryEmailParticipantsQuery

  def initialize(comment_id)
    @comment_id = comment_id
  end

  def call
    ActiveRecord::Base.connection.select_values(sql)
  end

  # participant has 'receive every email' AND
  # (participant made a comment on one of the comments in the thread OR
  #  participant follows the challenge which has the comment)
  def sql
    %Q[
      SELECT p.participant_id AS id
        FROM comments c,
             email_preferences p,
             topics t
       WHERE c.topic_id = t.id
         AND p.participant_id = c.participant_id
         AND p.mentions IS TRUE
         AND p.receive_every_email IS TRUE
         AND t.id IN (SELECT c2.topic_id
                        FROM comments c2
                       WHERE c1.id = #{@comment_id})
      UNION
      SELECT p.participant_id AS id
        FROM comments c,
             email_preferences p,
             follows f,
             topics t
       WHERE c.id = #{@comment_id}
         AND f.participant_id = p.participant_id
         AND f.followable_type = 'Challenge'
         AND t.challenge_id = f.followable_id
         AND c.topic_id = t.id
         AND p.challenges_followed IS TRUE
         AND p.receive_every_email IS TRUE
    ]
  end

end
