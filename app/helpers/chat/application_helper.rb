module Chat
  module ApplicationHelper
    def send_time(date_time)
      if date_time.day == Time.now.day
        "Today, #{date_time.strftime("%m/%d/%Y")}"
      else
        date_time.strftime("%I:%M%p, %m/%d/%Y")
      end
    end
  end
end
