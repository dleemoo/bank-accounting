# frozen_string_literal: true

Rails.application.routes.draw do
  constraints format: :json do
    post "accounts", to: "accounts/create#call"
    post "deposit", to: "operations/deposit#call"
    post "balance", to: "operations/balance#call"
    post "transfer", to: "operations/transfer#call"
  end

  root to: proc { [404, {}, [""]] }
end
