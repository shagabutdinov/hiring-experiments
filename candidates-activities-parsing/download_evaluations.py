#!/usr/bin/env python3
"""
Download candidate evaluation events from Workable API.

Usage:
    python download_evaluations.py <job_id> <cookie>

Output format:
    candidate_id;interviewer_id;timestamp;evaluation_result;evaluation_text
"""

import sys
import json
import requests
from typing import List, Dict, Any
from urllib.parse import quote


def get_candidates(job_id: str, cookie: str, account: str = "constructor-1") -> List[Dict[str, Any]]:
    """Fetch all candidates for a given job ID."""
    url = f"https://{account}.workable.com/backend/api/browser/candidates.json_api"

    params = {
        "fields[candidate]": "id,name,phone,headline,anonymized,avatars,tags,via_common_source,common_source,created_at,snoozed,snoozed_until,unread,rating,has_pending_evaluation,video_interview_completed,video_interview_unread,video_interview_duration,assessment_completed,assessment_unread,overall_score,sort,linkedin,email,locked,social_profiles,application_summary_score,blocked,bookmarked,show_bookmark_info",
        "fields[stage]": "id,slug,name,kind",
        "filter[consideration_status]": "under_consideration",
        "filter[job_ids]": job_id,
        "filter[stage_slug]": "all",
        "include": "stage",
        "include_hits": "true",
        "include_total": "true",
        "page[limit]": "100",
        "sort": "+blocked,+snoozed,-created_at,-id"
    }

    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:146.0) Gecko/20100101 Firefox/146.0",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Cookie": cookie,
        "Connection": "keep-alive"
    }

    all_candidates = []
    page = 1

    while True:
        params["page[number]"] = str(page)

        try:
            response = requests.get(url, params=params, headers=headers)
            response.raise_for_status()
            data = response.json()

            candidates = data.get("data", [])
            if not candidates:
                break

            all_candidates.extend(candidates)

            # Check if there are more pages
            meta = data.get("meta", {})
            total = meta.get("total", 0)
            if len(all_candidates) >= total:
                break

            page += 1

        except requests.RequestException as e:
            print(f"Error fetching candidates: {e}", file=sys.stderr)
            sys.exit(1)

    return all_candidates


def get_candidate_evaluations(candidate_id: str, cookie: str, account: str = "constructor-1") -> List[Dict[str, Any]]:
    """Fetch evaluation activities for a specific candidate."""
    url = f"https://{account}.workable.com/backend/api/browser/candidates/{candidate_id}/activities.json_api"

    params = {
        "fields[activity]": "action,activity_group,created_at,trackable,avatars,member_id,member_initials,confidential,content,icon,summary,unread,attachments,visibility_data,evaluation_summary",
        "filter[activity_groups]": "evaluations",
        "include": "trackable",
        "page[number]": "1",
        "page[size]": "300"
    }

    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:146.0) Gecko/20100101 Firefox/146.0",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Cookie": cookie,
        "Connection": "keep-alive"
    }

    try:
        response = requests.get(url, params=params, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data.get("data", [])
    except requests.RequestException as e:
        print(f"Error fetching evaluations for candidate {candidate_id}: {e}", file=sys.stderr)
        return []


def parse_evaluation(activity: Dict[str, Any]) -> Dict[str, Any]:
    """Parse an evaluation activity into structured data."""
    attributes = activity.get("attributes", {})

    # Extract evaluation summary
    evaluation_summary = attributes.get("evaluation_summary", {})

    # Get the result (positive, negative, neutral, etc.)
    if isinstance(evaluation_summary, dict):
        result = evaluation_summary.get("decision", "unknown")
    elif isinstance(evaluation_summary, str):
        result = evaluation_summary
    else:
        result = "unknown"

    # Get the evaluation text/content
    content = attributes.get("content", "")
    summary = attributes.get("summary", "")
    evaluation_text = content or summary

    # Clean up text - remove HTML tags and newlines
    import re
    evaluation_text = re.sub(r'<[^>]+>', '', evaluation_text)
    evaluation_text = re.sub(r'\s+', ' ', evaluation_text).strip()

    return {
        "candidate_id": activity.get("relationships", {}).get("candidate", {}).get("data", {}).get("id", ""),
        "interviewer_id": attributes.get("member_id", ""),
        "timestamp": attributes.get("created_at", ""),
        "evaluation_result": result,
        "evaluation_text": evaluation_text
    }


def main():
    if len(sys.argv) != 3:
        print("Usage: python download_evaluations.py <job_id> <cookie>", file=sys.stderr)
        sys.exit(1)

    job_id = sys.argv[1]
    cookie = sys.argv[2]

    # Optional: extract account name from cookie or use default
    account = "constructor-1"

    # Print CSV header immediately
    print("candidate_id;interviewer_id;timestamp;evaluation_result;evaluation_text")
    sys.stdout.flush()

    # Fetch all candidates
    print(f"Fetching candidates for job {job_id}...", file=sys.stderr)
    sys.stderr.flush()
    candidates = get_candidates(job_id, cookie, account)
    print(f"Found {len(candidates)} candidates", file=sys.stderr)
    sys.stderr.flush()

    # Fetch and parse evaluations for each candidate
    for candidate in candidates:
        candidate_id = candidate.get("id")
        if not candidate_id:
            continue

        print(f"Fetching evaluations for candidate {candidate_id}...", file=sys.stderr)
        sys.stderr.flush()
        evaluations = get_candidate_evaluations(candidate_id, cookie, account)

        for evaluation in evaluations:
            parsed = parse_evaluation(evaluation)

            # Escape semicolons in text fields
            text = parsed["evaluation_text"].replace(";", ",")

            print(f"{parsed['candidate_id']};{parsed['interviewer_id']};{parsed['timestamp']};{parsed['evaluation_result']};{text}")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
