class EventsController < ApplicationController

	def pull_google_events
		@calendar_id = revert_google_calendar_id(pbl_events_calendar_id)
	    all_events = google_api_request(
	      'calendar', 'v3', 'events', 'list',
	      {
	        calendarId: @calendar_id,
	        timeMin: beginning_of_fall_semester,
	        timeMax: (DateTime.now + 6.month),
	      }
	    ).data.items
	    result = all_events
	    
    	all_events = process_google_events(all_events)
    	render json: all_events
    # all_events.each do |e|
	end
 #      event = Event.new
 #      if Event.where(google_id: e[:id]).length != 0
 #        event = Event.where(google_id: e[:id]).first
 #        # Event.where(google_id: e[:id]).each do |ev|
 #          # ev.destroy
 #        # end
 #      else
 #        puts "event is ging to be created"
 #      end
 #      event.google_id = e[:id]
 #      event.start_time = e[:start_time]
 #      event.end_time = e[:end_time]
 #      event.name = e[:summary]
 #      event.save

 #    end
 #    redirect_to(:back)
	# end
end
