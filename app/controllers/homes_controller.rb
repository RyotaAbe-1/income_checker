class HomesController < ApplicationController
  def top
  end

  def result
    @face_value_y = params[:face_value].to_i
    face_value_m = (@face_value_y / 12).floor

    # 厚生年金保険料、健康保険料
    if face_value_m >= 635000
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range >= 635000").first.standard_reward_bymonth
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
    else
      @standard_reward_bymonth_hi = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
      @standard_reward_bymonth_wp = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
    end
    @welfare_pension = (@standard_reward_bymonth_wp * 18.3 / 100 / 2 * 12).floor
    @helth_insurance = (@standard_reward_bymonth_hi * 9.84 / 100 / 2 * 12).floor

    # 介護保険料
    age_range = params[:age_range]
    @standard_reward_bymonth_ni = 0
    @nursing_insurance = 0
    if age_range == "40_to_65"
      @standard_reward_bymonth_ni = InsuranceFee.where("first_range <= ?", face_value_m).last.standard_reward_bymonth
      @nursing_insurance = (@standard_reward_bymonth_ni * 1.8 / 100 / 2 * 12).floor
    elsif age_range == "and_over_65"
      @nursing_insurance = 6014 * 12
      flash[:notice] = "※介護保険料は前年の所得や市区町村ごとに変化します。全国平均の6014円/月で計算しています。"
    end

    # 雇用保険料
    profession = params[:profession]
    if profession == "general"
      @employment_insurance = (face_value_m * 3 / 1000 * 12).floor
    elsif (profession == "agriculture") or (profession == "construction")
      @employment_insurance = (face_value_m * 4 / 1000 * 12).floor
    end

    # 給与所得控除
    if @face_value_y <= 1625000
      @face_value_deduction = 550000
    elsif (1625001..1800000) === @face_value_y
      @face_value_deduction = (@face_value_y * 0.4 - 100000).floor
    elsif (1800001..3600000) === @face_value_y
      @face_value_deduction = (@face_value_y * 0.3 + 80000).floor
    elsif (3600001..6600000) === @face_value_y
      @face_value_deduction = (@face_value_y * 0.2 + 440000).floor
    elsif (6600001..8500000) === @face_value_y
      @face_value_deduction = (@face_value_y * 0.1 + 1100000).floor
    elsif 8500001 < @face_value_y
      @face_value_deduction = 1950000
    end

    # 給与所得(給与収入ー給与所得控除)
    @employment_income = @face_value_y - @face_value_deduction

    # 社会保険料控除
    @social_insurance_deduction = @welfare_pension + @helth_insurance + @nursing_insurance + @employment_insurance

    # 基礎控除
    if @face_value_y <= 24000000
      @basic_deduction = 480000
    elsif (24000001..24500000) === @face_value_y
      @basic_deduction = 320000
    elsif (24500001..25000000) === @face_value_y
      @basic_deduction = 160000
    elsif 25000000 < @face_value_y
      @basic_deduction = 0
    end

    # 所得控除(社会保険料控除＋基礎控除)
    @income_deduction = @social_insurance_deduction + @basic_deduction

    # 課税所得(給与所得ー所得控除)　1000円未満切捨て
    @taxable_income = (@employment_income - @income_deduction).floor(-3)

    # 所得税
    if (1000...1950000) === @taxable_income
      income_tax = @taxable_income * 0.05
    elsif (1950000...3300000) === @taxable_income
      income_tax = @taxable_income * 0.1 - 97500
    elsif (3300000...6950000) === @taxable_income
      income_tax = @taxable_income * 0.2 - 427500
    elsif (6950000...9000000) === @taxable_income
      income_tax = @taxable_income * 0.23 - 636000
    elsif (9000000...18000000) === @taxable_income
      income_tax = @taxable_income * 0.33 - 1536000
    elsif (18000000...40000000) === @taxable_income
      income_tax = @taxable_income * 0.4 - 2796000
    elsif 40000000 <= @taxable_income
      income_tax = @taxable_income * 0.45 - 4796000
    end

    @income_tax = income_tax.to_i.floor

    # 復興特別所得税
    @extra_income_tax = (@income_tax * 0.021).floor

    # 合計納付額(所得税＋復興特別所得税) 100円未満切捨て
    @total_tax = (@income_tax + @extra_income_tax).floor(-2)

    # 手取り額
    @net_income = @face_value_y - @social_insurance_deduction - @total_tax

  end
end
