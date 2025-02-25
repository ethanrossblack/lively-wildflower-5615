require "rails_helper"

RSpec.describe "The Guest Show Page", type: :feature do
  before(:each) do
    @hotel = Hotel.create!(name:"Vail Inn", location:"Vail")

    @room1 = @hotel.rooms.create!(rate: 125, suite: "Presidential")
    @room2 = @hotel.rooms.create!(rate: 130, suite: "Executive")
    @room3 = @hotel.rooms.create!(rate: 100, suite: "Basic")
    
    @guest1 = Guest.create!(name: "Ethan", nights: 3)
    @guest2 = Guest.create!(name: "Zahava", nights: 3)
    @guest3 = Guest.create!(name: "Ezzy", nights: 1)

    @room1.guests << @guest1
    @room1.guests << @guest2
    
    @room2.guests << @guest1
    @room2.guests << @guest3

    @room3.guests << @guest1
  end

  # =========================
  # STORY 1: GUEST SHOW TESTS
  # =========================

  it "I see a guest's name" do
    visit "/guests/#{@guest1.id}"
    
    within("div#guest_info") do
      expect(page).to have_content(@guest1.name)
      expect(page).to_not have_content(@guest2.name)
    end
    
    visit "/guests/#{@guest2.id}"
    
    within("div#guest_info") do
      expect(page).to have_content(@guest2.name)
      expect(page).to_not have_content(@guest1.name)
    end
  end

  it "I see a list of all the rooms they've stayed in, including information on a room's suite, nightly rate, and the name of the hotel to which it belongs" do
    # Guest 1 Room History
    visit "/guests/#{@guest1.id}"
    within("div#guest_room_history") do
      expect(page).to have_css("div#room-#{@room1.id}")
      within("div#room-#{@room1.id}") do
        expect(page).to have_content(@room1.suite)
        expect(page).to have_content(@room1.rate)
        expect(page).to have_content(@hotel.name)
      end

      expect(page).to have_css("div#room-#{@room2.id}")
      within("div#room-#{@room2.id}") do
        expect(page).to have_content(@room2.suite)
        expect(page).to have_content(@room2.rate)
        expect(page).to have_content(@hotel.name)
      end

      expect(page).to have_css("div#room-#{@room3.id}")
      within("div#room-#{@room3.id}") do
        expect(page).to have_content(@room3.suite)
        expect(page).to have_content(@room3.rate)
        expect(page).to have_content(@hotel.name)
      end
    end
    
    #Guest 2 Room History
    visit "/guests/#{@guest2.id}"
    within("div#guest_room_history") do
      expect(page).to have_css("div#room-#{@room1.id}")
      within("div#room-#{@room1.id}") do
        expect(page).to have_content(@room1.suite)
        expect(page).to have_content(@room1.rate)
        expect(page).to have_content(@hotel.name)
      end
      
      expect(page).to_not have_css("div#room-#{@room2.id}")
      
      expect(page).to_not have_css("div#room-#{@room3.id}")
    end

    # Guest 3 Room History
    visit "/guests/#{@guest3.id}"
    within("div#guest_room_history") do
      expect(page).to_not have_css("div#room-#{@room1.id}")
    
      expect(page).to have_css("div#room-#{@room2.id}")
      within("div#room-#{@room2.id}") do
        expect(page).to have_content(@room2.suite)
        expect(page).to have_content(@room2.rate)
        expect(page).to have_content(@hotel.name)
      end
    
      expect(page).to_not have_css("div#room-#{@room3.id}")
    end
  end
  # =================
  # END STORY 1 TESTS
  # =================

  # ====================================
  # STORY 2: ADD A GUEST TO A ROOM TESTS
  # ====================================

  it "I see a form to add a room to this guest" do
    visit "/guests/#{@guest2.id}"

    within("div#add-room") do
      expect(page).to have_css("form")
      expect(page).to have_field(:room_id, type: "text")
    end
  end

  describe "When I fill in a field with the ID of an existing room and click 'submit'" do
    it "Then I am redirected back to the guest's show page see the room now listed under this guest's rooms" do
      visit "/guests/#{@guest2.id}"
      
      expect(@guest2.rooms).to_not include(@room2)
      within("div#guest_room_history") do
        expect(page).to_not have_css("div#room-#{@room2.id}")
      end

      within("div#add-room") do
        fill_in "room_id", with: "#{@room2.id}"
        click_button "Submit"
      end

      expect(current_path).to eq("/guests/#{@guest2.id}")

      within("div#guest_room_history") do
        expect(page).to have_css("div#room-#{@room2.id}")
        within("div#room-#{@room2.id}") do
          expect(page).to have_content(@room2.suite)
          expect(page).to have_content(@room2.rate)
          expect(page).to have_content(@hotel.name)
        end
      end

      @guest2.reload
      expect(@guest2.rooms).to include(@room2)
    end
  end

  # =================
  # END STORY 2 TESTS
  # =================

end