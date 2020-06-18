module Challenges
  class WinnersController < Challenges::BaseController
    before_action :authenticate_participant!

    def index; end
  end
end
