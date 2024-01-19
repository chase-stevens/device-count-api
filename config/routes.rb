Rails.application.routes.draw do
  namespace "v1" do
    post "/record_count",    to: "devices#record_count"
    get "/latest_timestamp/:uuid", to: "devices#latest_timestamp"
    get "/cumulative_count/:uuid", to: "devices#cumulative_count" 
  end
end
