Given /^the "([^"]*)" department has (\d+) pending, (\d+) validated, (\d+) open, (\d+) closed and (\d+) rejected petitions$/ do |department_name, pending, validated, open, closed, rejected|
  department = Factory(:department, :name => department_name)
  pending.times{ Factory(:pending_petition, :department => department) }
  validated.times{ Factory(:validated_petition, :department => department) }
  open.times{ Factory(:open_petition, :department => department) }
  closed.times{ Factory(:closed_petition, :department => department) }

  if rejected > 1
    Factory(:hidden_petition, :department => department)
    rejected -= 1
  end
  rejected.times{ Factory(:rejected_petition, :department => department) }
end

Then /^I see the following reports table:$/ do |values_table|
  actual_table = tableish(xpath_of_section('admin report table') + '//tr', 'th,td')
  values_table.diff!(actual_table)
end

Given /^I am logged in as a moderator for the "([^"]*)" department$/ do |department_name|
  step "I am logged in as an admin"
  department = Factory(:department, :name => department_name)
  @user.departments << department
end

Then /^I should see trending petitions for all my departments for the last (\d+) (hours|days)$/ do |time_period, hours_or_days|
  @user.departments.each do |department|
    (11..15).each do |petition_number|
      page.should have_css("tr.trending_petition td.title", :text => "#{department.name} Petition ##{petition_number}")
      page.should have_css("tr.trending_petition td.count", :text => "#{petition_number+1}")
    end
  end
end

Given /^there has been activity on a number of petitions in the last (\d+) (hours|days)$/ do |number_of_days, hours_or_days|
  Department.all.each do |department|
    (1..15).each do |count|
      petition = Factory(:open_petition, :department => department, :title => "#{department.name} Petition ##{count}")
      timestamp = (number_of_days - 1).send(hours_or_days).ago
      count.times { Factory(:validated_signature, :petition => petition, :updated_at => timestamp) }
    end
  end
end

Then /^I choose to view (\d+) days of trends$/ do |arg1|
  select '7', :from => :number_of_days_to_trend
  click_button "Go"
end

Then /^I should not see trending petitions for any other department$/ do
  page.should_not have_content('DFID')
end
