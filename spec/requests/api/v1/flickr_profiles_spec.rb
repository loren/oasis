require 'rails_helper'

describe API::V1::FlickrProfiles do
  describe "GET /api/v1/flickr_profiles" do
    context 'when profiles exist' do
      before do
        FlickrProfile.create(name: 'profile2', id: '2', profile_type: 'group')
        FlickrProfile.create(name: 'profile1', id: '1', profile_type: 'user')
        FlickrProfile.refresh_index!
      end

      it "returns an array of indexed Flickr profiles" do
        get "/api/v1/flickr_profiles"
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first).to match(hash_including('name' => 'profile1', 'id' => '1', 'profile_type' => 'user'))
        expect(JSON.parse(response.body).last).to match(hash_including('name' => 'profile2', 'id' => '2', 'profile_type' => 'group'))
      end
    end
  end

  describe "POST /api/v1/flickr_profiles" do
    before do
      post "/api/v1/flickr_profiles", id: '61913304@N07', name: 'commercegov', profile_type: 'user'
      FlickrProfile.refresh_index!
    end

    it "creates a Flickr profile" do
      expect(FlickrProfile.find('61913304@N07')).to be_present
    end

    it "enqueues the importer to download and index photos" do
      expect(FlickrPhotosImporter).to have_enqueued_job('61913304@N07', 'user')
    end
  end
end