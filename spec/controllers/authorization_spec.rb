require 'rails_helper'

# Exercises the Authorization concern through an anonymous controller.
RSpec.describe ApplicationController, type: :controller do
  controller(described_class) do
    def raises
      raise Authorization::NotAuthorized
    end

    def checked
      authorize(Widget.new(params[:owner_id]), :show?)
      head :ok
    end
  end

  let(:user) { build_stubbed(:user) }

  before do
    stub_const("Widget", Struct.new(:owner_id))
    stub_const(
      "WidgetPolicy",
      Class.new(ApplicationPolicy) do
        def show? = record.owner_id.to_s == user.id.to_s
      end
    )
    routes.draw do
      get "raises" => "anonymous#raises"
      get "checked" => "anonymous#checked"
    end
    allow(controller).to receive(:current_user).and_return(user)
  end

  it 'translates NotAuthorized into 403' do
    get :raises

    expect(response).to have_http_status(:forbidden)
  end

  it 'denies with 403 when the policy returns false' do
    get :checked, params: { owner_id: 999 }

    expect(response).to have_http_status(:forbidden)
  end

  it 'allows with 200 when the policy returns true' do
    get :checked, params: { owner_id: user.id }

    expect(response).to have_http_status(:ok)
  end
end
