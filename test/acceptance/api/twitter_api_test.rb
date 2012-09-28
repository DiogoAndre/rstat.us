require_relative '../acceptance_helper'

describe "twitter-api" do
  include AcceptanceHelper

  describe "user_timeline" do
    it "returns valid json" do

      log_in_as_some_user

      u = Fabricate(:user)

      5.times do |index|
        update = Fabricate(:update,
                           :text   => "Update test is #{index}",
                           :twitter => true,
                           :author => u.author
                         )
       u.feed.updates << update
      end

      visit "/api/statuses/user_timeline.json?screen_name=#{u.username}"

      parsed_json = JSON.parse(source)
      parsed_json.length.must_equal 5
      parsed_json[0]["text"].must_equal("Update test is 4")

    end
  end

  describe "home_timeline" do
    it "it returns the home timeline for the user" do
      @u = Fabricate(:user)
      log_in_username @u

      update = Fabricate(:update,
                         :text => "Hello World I'm on RStatus",
                         :author => @u.author)
      @u.feed.updates << update

      visit "/api/statuses/home_timeline.json"

      parsed_json = JSON.parse(source)
      parsed_json[0]["text"].must_equal(update.text)

    end
  end

  describe "statuses" do
    it "returns a single status" do
      log_in_as_some_user
      u = Fabricate(:user)

      update = Fabricate(:update,
                         :text => "Hello World I'm on RStatus",
                         :author => u.author)
      u.feed.updates << update
      author_decorator = AuthorDecorator.decorate(u.author)

      visit "/api/statuses/show/#{u.feed.updates.first.id}.json"

      parsed_json = JSON.parse(source)
      parsed_json["text"].must_equal(update.text)
      parsed_json["user"]["url"].must_equal(author_decorator.absolute_website_url)
      parsed_json["user"]["screen_name"].must_equal(author_decorator.username)
      parsed_json["user"]["name"].must_equal(author_decorator.display_name)
      parsed_json["user"]["profile_image_url"].must_equal("http://rstat.us#{author_decorator.absolute_avatar_url}")
      Time.parse(parsed_json["user"]["created_at"]).to_i.must_equal(author_decorator.created_at.to_i)
      parsed_json["user"]["description"].must_equal(author_decorator.bio)
      parsed_json["user"]["statuses_count"].must_equal(author_decorator.feed.updates.count)
    end

    it "returns a single status with trimmed user" do
      log_in_as_some_user
      u = Fabricate(:user)

      update = Fabricate(:update,
                         :text => "Hello World I'm on RStatus",
                         :author => u.author)
      u.feed.updates << update

      visit "/api/statuses/show/#{u.feed.updates.first.id}.json?trim_user=true"

      parsed_json = JSON.parse(source)
      parsed_json["text"].must_equal(update.text)
      parsed_json["user"].wont_include("url","url should not be included in trimmed status")
      parsed_json["user"].wont_include("screen_name","url should not be included in trimmed status")
      parsed_json["user"].wont_include("name","url should not be included in trimmed status")
      parsed_json["user"].wont_include("profile_image_url","url should not be included in trimmed status")
      parsed_json["user"].wont_include("created_at","url should not be included in trimmed status")
      parsed_json["user"].wont_include("description","url should not be included in trimmed status")
      parsed_json["user"].wont_include("statuses_count","url should not be included in trimmed status")
    end
  end
  
  describe "mentions" do
    it "gives mentions" do
      skip "unimplemented"

      u = Fabricate(:user)
      log_in_username u

      update = Fabricate(:update,
                         :text => "@#{u.username} How about them Bears",
                         :author => u.author)

      visit "/api/statuses/mention.json"

      parsed_json = JSON.parse(source)
      parsed_json[0]["text"].must_equal(update.text)

    end
  end

end
