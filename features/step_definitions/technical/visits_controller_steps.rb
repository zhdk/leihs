Given /^test data setup for "Hand over controller" feature$/ do
  @lending_manager = @current_user
  @inventory_pool = @lending_manager.inventory_pools.first
end

Given /^test data setup for scenario "Writing an unavailable inventory code"$/ do
  model = Model.all.detect do |m|
    m.contract_lines.where(returned_date: nil, item_id: nil).first and
    m.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first 
  end
  expect(model).not_to be nil
  @line = model.contract_lines.where(returned_date: nil, item_id: nil).first
  @item = model.contract_lines.where(returned_date: nil).where("item_id IS NOT NULL").first.item
  expect(@line.item).to eq nil
end

When /^an unavailable inventory code is assigned to a contract line$/ do
  @response = post "/manage/#{@inventory_pool.id}/contract_lines/#{@line.id}/assign", {:inventory_code => @item.inventory_code}
end

Then /^the response from this action should be successful$/ do
  expect(@response.successful?).to be true
end

Then /^the response from this action should not be successful$/ do
  expect(@response.successful?).to be false
end

Then /^the contract line has no item$/ do
  expect(@line.reload.item).to eq nil
end

Given /^visit that is overdue$/ do
  @visit = @inventory_pool.visits.hand_over.where("date < ?", Date.today).first
end

Given /^visit that is in future$/ do
  @visit = @inventory_pool.visits.hand_over.where("date >= ?", Date.today).first
end

When /^the visit is deleted$/ do
  @visit_count = Visit.count
  @response = delete manage_inventory_pool_destroy_hand_over_path(@inventory_pool, @visit.id), {:format => :json}
end

Then /^the visit does not exist anymore$/ do
  expect(Visit.find_by_id(@visit)).to eq nil
  expect(@visit_count).to eq Visit.count + 1
end

When /^the index action of the visits controller is called with the filter parameter "take back" and a given date$/ do
  @date = Date.today
  response = get manage_inventory_pool_take_backs_path(@inventory_pool), {date: @date.to_s, format: "json", date_comparison: "lteq"}
  @json = JSON.parse response.body
end

When /^the index action of the visits controller is called with the filter parameter "hand over" and a given date$/ do
  @date = Date.today
  response = get manage_inventory_pool_hand_overs_path(@inventory_pool), {date: @date.to_s, format: "json", date_comparison: "lteq"}
  @json = JSON.parse response.body
end

Then /^the result of this action are all take back visits for the given inventory pool and the given date$/ do
  expect(@json.empty?).to be false
  @json.each do |visit|
    expect(visit["action"]).to eq "take_back"
    if @date <= Date.today
      expect(Date.parse(visit["date"])).to be <= @date
    else 
      expect(Date.parse(visit["date"])).to eq @date
    end
  end
end

Then /^the result of this action are all hand over visits for the given inventory pool and the given date$/ do
  expect(@json.empty?).to be false
  @json.each do |visit|
    expect(visit["action"]).to eq "hand_over"
    if @date <= Date.today
      expect(Date.parse(visit["date"])).to be <= @date
    else 
      expect(Date.parse(visit["date"])).to eq @date
    end
  end
end
