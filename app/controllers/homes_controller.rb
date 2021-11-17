class HomesController < ApplicationController
  def top
  end

  def result
    face_value = params[:face_value].to_i
    @result = (face_value * 0.8).floor
  end
end
