# Publisher constants for Porch Light Software
# Referenced by each app's Fastfile via:
#   require_relative "../../../../PorchLightSoftwareCommon/fastlane/publisher.rb"

module PorchLightPublisher
  PUBLISHER_NAME   = "Porch Light Software"
  SUPPORT_URL      = "https://porchlightsoftware.com/support"
  PRIVACY_URL      = "https://porchlightsoftware.com/privacy"
  MARKETING_URL    = "https://porchlightsoftware.com"
  CONTACT_EMAIL    = "support@porchlightsoftware.com"

  # Fill in after creating Apple Developer account
  APPLE_ID         = ENV["APPLE_ID"]         || "TODO@porchlightsoftware.com"
  APPLE_TEAM_ID    = ENV["APPLE_TEAM_ID"]    || "TODO"
  ITC_TEAM_ID      = ENV["ITC_TEAM_ID"]      || "TODO"
end
