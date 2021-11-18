class HomesController < ApplicationController
  def top
  end

  def result
    face_value = params[:face_value].to_i
    if face_value >= 635000
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range >= ?", 635000).first.standard_reward_bymonth
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value).last.standard_reward_bymonth
    else
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value).last.standard_reward_bymonth
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range <= ?", face_value).last.standard_reward_bymonth
    end
    @welfare_pension = @standard_reward_bymonth_wp * 18.3 / 100 / 2
    @helth_insurance = @standard_reward_bymonth_hi * 9.84 / 100 / 2
  end
end
