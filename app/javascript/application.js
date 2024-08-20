// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Disable Turbo for the whole application right now
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
