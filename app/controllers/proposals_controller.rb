class ProposalsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_proposal, only: [:show, :update, :destroy]
  
    # GET /proposals
    def index
      @proposals = current_user.proposals
      render json: @proposals
    end
  
    # GET /proposals/:id
    def show
      render json: @proposal
    end
  
    # POST /proposals
    def create
      @proposal = current_user.proposals.build(proposal_params)
  
      if @proposal.save
        render json: @proposal, status: :created
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
      params.require(:proposal).permit(:title, :body)
    end
end
