class ApplicationApi < Grape::API
  mount V1::Base
end