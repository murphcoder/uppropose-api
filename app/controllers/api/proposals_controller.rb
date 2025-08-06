class Api::ProposalsController < ApplicationController
    before_action :set_proposal, only: [:show, :destroy]
  
    # GET /proposals
    def index
      @proposals = current_user.proposals.select(:title, :id)
      render json: @proposals
    end
  
    # GET /proposals/:id
    def show
      render json: @proposal
    end
  
    # POST /proposals
    def create
      description = proposal_params[:job_description]
      addresse = proposal_params[:addresse]
    
      generated_content = ProposalGenerator.generate(description: description, user: current_user, addresse: addresse)
    
      if generated_content.blank?
        render json: { error: "Failed to generate proposal." }, status: :unprocessable_entity
        return
      end
    
      @proposal = current_user.proposals.build(
        job_description: description,
        addresse: addresse,
        title: proposal_params[:title], 
        body: generated_content
      )
    
      if @proposal.save
        render json: { proposal: @proposal }, status: :created
      else
        render json: @proposal.errors, status: :unprocessable_entity
      end
    end
    
  
    # DELETE /proposals/:id
    def destroy
      @proposal.destroy
      head :no_content
    end
  
    private
  
    def set_proposal
      @proposal = current_user.proposals.find_by(id: params[:id])
      render json: { error: 'Proposal not found' }, status: :not_found unless @proposal
    end
  
    def proposal_params
      params.require(:proposal).permit(:title, :addresse, :job_description)
    end
end
