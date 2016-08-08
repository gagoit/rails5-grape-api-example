## Define all application constants here
API_VENDOR = 'rails5-grape-api-example'

# https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
RESPONSE_CODE = {
  success: 200,
  bad_request: 400,
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  unprocessable_entity: 422,
  internal_server_error: 500,
  common_error: 1001
}

# Request header

# 
PER_PAGE = 20