class BlackboardController < ApplicationController

  def index
    @special = MyGlobals::blackboard_messages[:special]
    @title   = MyGlobals::blackboard_messages[:title]
    @date    = ( MyGlobals::blackboard_messages[:date].nil? or MyGlobals::blackboard_messages[:date].empty?) ? (l DateTime.now, :format => 'date') : MyGlobals::blackboard_messages[:date]

    respond_to do |wants|
      wants.html
      wants.xml
    end
  end

  def update
    @special = MyGlobals::blackboard_messages[:special] = params[:special] if params[:special]
    @title = MyGlobals::blackboard_messages[:title] = params[:title] if params[:title]
    @date = MyGlobals::blackboard_messages[:date] = params[:date] if params[:date]
    render :nothing => true
  end

end
