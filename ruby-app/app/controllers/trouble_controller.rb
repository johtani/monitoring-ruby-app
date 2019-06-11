class TroubleController < ApplicationController
  include ElasticAPM::SpanHelpers

  def soslow
    do_something("Set something...")
    sleeeeeeeep()
    do_something("Call external API")
  end


  def sleeeeeeeep()
    millis = rand(1000)
    sleep( millis/100 )
  end
  span_method :sleeeeeeeep, 'sleeeeeeeep', 'app'

  def do_something(apm_name)
    @result_of_work = ElasticAPM.with_span apm_name do
      millis = rand(1000)
      sleep( millis/100 )
    end
  end

  # Error sample
  def zerodivide()
    begin
      1 / 0
    rescue ZeroDivisionError => e
      ElasticAPM.report e
    end

    render plain: 'error', status: 500
  end

  def message
    ElasticAPM.report_message "This is a message"
    render plain: 'error', status: 500
  end

  def throw_error
    1 / 0
  end

end
