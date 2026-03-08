require "test_helper"

class DevisePagesTest < ActionDispatch::IntegrationTest
  test "sign in page renders branded auth form" do
    get new_user_session_url

    assert_response :success
    assert_includes response.body, "Prisijunkite prie savo paskyros"
    assert_includes response.body, "Tender Tinder paskyra"
    assert_includes response.body, 'data-controller="password-visibility"'
  end

  test "sign up page renders branded auth form" do
    get new_user_registration_url

    assert_response :success
    assert_includes response.body, "Susikurkite paskyrą"
    assert_includes response.body, "kasdienę el. pašto santrauką"
    assert_includes response.body, "Rodyti slaptažodį"
  end

  test "password reset request page renders branded auth form" do
    get new_user_password_url

    assert_response :success
    assert_includes response.body, "Atkurkite slaptažodį"
    assert_includes response.body, "Siųsti atkūrimo nuorodą"
  end

  test "password reset edit page renders branded auth form" do
    user = users(:one)
    raw_token, encrypted_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update!(reset_password_token: encrypted_token, reset_password_sent_at: Time.current)

    get edit_user_password_url(reset_password_token: raw_token)

    assert_response :success
    assert_includes response.body, "Sukurkite naują slaptažodį"
    assert_includes response.body, "Išsaugoti naują slaptažodį"
    assert_includes response.body, "Rodyti slaptažodį"
  end
end
