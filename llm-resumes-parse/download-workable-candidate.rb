#!/usr/bin/env ruby

require 'json'
require 'pp'

ID = ARGV[0]

if ENV['COOKIE'].nil? || ENV['COOKIE'].empty?
  raise StandardError.new("Cookie not set")
end

response = `curl -s 'https://constructor-1.workable.com/backend/api/browser/candidates/#{ID}.json_api?fields[candidate]=id,type,activity_groups,address,informed_about_policy,informed_about_ccpa_policy,anonymized,questions,avatars,has_avatar,created_at,disqualified,disqualify_reason_id,disqualify_note,withdrew,education,experience,first_name,last_name,linkedin,is_obfuscated,has_files,has_pending_evaluation,has_sent_e_signature_request,has_pending_offer,account_id,pending_evaluations,headline,latest_offer,location,sources_of_location,is_edited,name,phone,email,rating,assessment_test,personality_questions,upcoming_event,sibling_count,snoozed,snoozed_until,talent_pool_id,via_common_source,via_common_source_tip,common_source,common_source_category,no_prior_email_history,latest_background_check,summary,tags,skills,texting_consent,custom_attributes,metadata,cover_letter,keywords,social_profiles,alternate_emails,alternate_phones,resume,avatars_source,permissions,recruiter_id,sample,requisition,timeline_visibility_restricted,available_background_check_providers,available_reference_check_providers,total_days_of_experience,candidate_application_summary,application_summary_score,follower_ids,unread,referrals,blocked&fields[job]=id,title,location_str,department_name,shortcode,state,state_code,country_code,language,job_requirements&fields[stage]=id,slug,name,kind&include=job,stage' --globoff --compressed \
-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:127.0) Gecko/20100101 Firefox/127.0' \
-H 'Accept: application/json' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Referer: https://constructor-1.workable.com/backend/jobs/4087255/browser/applied/candidate/370680602' \
-H 'Content-Type: application/json' \
-H 'Connection: keep-alive' \
-H 'Cookie: #{ENV['COOKIE']}' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H 'Priority: u=1' \
-H 'Pragma: no-cache' \
-H 'Cache-Control: no-cache' \
-H 'TE: trailers'`

puts(response)
# pp(JSON.parse(response)['data']['attributes']['resume'])
