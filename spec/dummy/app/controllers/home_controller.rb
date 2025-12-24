class HomeController < ApplicationController
  def show
  end

  def reset_user
    reset_session
    render :show
  end
end
