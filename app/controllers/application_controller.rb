class ApplicationController < ActionController::Base
  include SessionsHelper

  add_flash_types :notice, :danger
end
