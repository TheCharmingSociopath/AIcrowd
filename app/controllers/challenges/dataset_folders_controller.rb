module Challenges
  class DatasetFoldersController < Challenges::BaseController
    before_action :authenticate_participant!
    before_action :set_dataset_folder, only: [:edit, :update, :destroy]
    before_action :check_participation_terms

    def new
      @dataset_folder = @challenge.dataset_folders.new
      authorize @dataset_folder
    end

    def create
      @dataset_folder = @challenge.dataset_folders.new(dataset_folder_params)

      if @dataset_folder.save
        redirect_to helpers.challenge_dataset_files_path(@challenge),
                    notice: 'Dataset folder was successfully created.'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @dataset_folder.update(dataset_folder_params)
        redirect_to helpers.challenge_dataset_files_path(@challenge), notice: 'Dataset folder was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @dataset_folder.destroy
      redirect_to helpers.challenge_dataset_files_path(@challenge), notice: "Dataset folder #{@dataset_folder.title} was deleted."
    end

    private

    def set_dataset_folder
      @dataset_folder = DatasetFolder.find(params[:id])
      authorize @dataset_folder
    end

    def check_participation_terms
      challenge = @challenge
      if @meta_challenge.present?
        challenge = @meta_challenge
      end

      unless policy(challenge).has_accepted_participation_terms?
        redirect_to [challenge, ParticipationTerms.current_terms]
        return
      end

      unless policy(challenge).has_accepted_challenge_rules?
        redirect_to [challenge, challenge.current_challenge_rules]
        return
      end
    end

    def dataset_folder_params
      params
        .require(:dataset_folder)
        .permit(
          :title,
          :description,
          :directory_path,
          :aws_access_key,
          :aws_secret_key,
          :bucket_name,
          :region,
          :aws_endpoint,
          :visible,
          :evaluation
        )
    end
  end
end
