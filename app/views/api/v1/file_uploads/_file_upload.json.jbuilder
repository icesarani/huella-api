# frozen_string_literal: true

json.id file_upload.id
json.ai_analyzed_age file_upload.ai_analyzed_age
json.ai_analyzed_weight file_upload.ai_analyzed_weight
json.ai_analyzed_breed file_upload.ai_analyzed_breed
json.processed_at file_upload.processed_at
json.photo_url rails_blob_url(file_upload.file)
