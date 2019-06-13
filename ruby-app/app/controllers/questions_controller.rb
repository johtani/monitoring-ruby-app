class QuestionsController < ApplicationController
  before_action :set_question, only: [:vote, :destroy]

  # POST /questions/1/vote
  def vote
    # get session key
    session_id = session.id
    logger.info("Session id : ["+session_id+"]")
    # get question
    # get vote
    votes = Vote.where(:question_id => params[:id], :session_key => session_id)
    if votes.empty?
      @vote = Vote.new(:question_id => params[:id], :session_key => session_id)
      @vote.save
    end
    respond_to do |format|
      format.html {redirect_to root_path}
      format.json {redirect_to root_path}
    end
  end

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.left_joins(:votes)
                .group(:id)
                .order('count(votes.session_key) desc')
                .order(created_at: :asc)
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to root_path }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :author, :pubDate)
    end
end
