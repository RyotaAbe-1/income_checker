class HomesController < ApplicationController
  def top
  end

  def result
    @face_value_y = params[:face_value].to_i
    face_value_m = (@face_value_y / 12).floor
    
    # 厚生年金保険料、健康保険料
    if face_value_m >= 635000
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range >= ?", 635000).first.standard_reward_bymonth
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
    else
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
    end
    @welfare_pension = (@standard_reward_bymonth_wp * 18.3 / 100 / 2 * 12).floor
    @helth_insurance = (@standard_reward_bymonth_hi * 9.84 / 100 / 2 * 12).floor
    
    # 介護保険料
    age_range = params[:age_range]
    if age_range == "40_to_65"
      @standard_reward_bymonth_ni = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
      @nursing_insurance = (@standard_reward_bymonth_ni * 1.8 / 100 / 2 * 12).floor
    elsif age_range == "and_over_65"
      flash[:notice] = "前年の所得や市区町村ごとに変化します。全国平均は6014円/月です。"
    end
    
    # 雇用保険料
    profession = params[:profession]
    if profession == "general"
      @employment_insurance = (face_value_m * 3 / 1000 * 12).floor
    else
      @employment_insurance = (face_value_m * 4 / 1000 * 12).floor
    end
    
    # 給与所得控除額  
    if @face_value_y <= 1625000
      @face_value_deduction = 550000
    elsif (1625000 < @face_value_y) && (@face_value_y <= 1800000)
      @face_value_deduction = (@face_value_y * 0.4 - 100000).floor
    elsif (1800000 < @face_value_y) && (@face_value_y <= 3600000)
      @face_value_deduction = (@face_value_y * 0.3 + 80000).floor
    elsif (3600000 < @face_value_y) && (@face_value_y <= 6600000)
      @face_value_deduction = (@face_value_y * 0.2 + 440000).floor
    elsif (6600000 < @face_value_y) && (@face_value_y <= 8500000)
      @face_value_deduction = (@face_value_y * 0.1 + 1100000).floor
    elsif 8500000 < @face_value_y
      @face_value_deduction = 1950000
    end
    
    
  end
end
