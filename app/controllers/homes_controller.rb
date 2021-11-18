class HomesController < ApplicationController
  def top
  end

  def result
    face_value = params[:face_value].to_i
    if face_value < 1355000
      @standard = InsuranceFee.where("first_range <= ? and last_range > ?", face_value, face_value).first
    else
      @standard = InsuranceFee.where("first_range <= ?", face_value).first
    end
  end
end
