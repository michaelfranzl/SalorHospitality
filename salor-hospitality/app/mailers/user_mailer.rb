class UserMailer < ActionMailer::Base
  default from: "#{SalorHospitality::Application::SH_DEBIAN_SITEID}.sh@#{ `hostname`.strip }"
  
  def technician_message(company, subject, msg='', request=nil)
    if request
      @ip = request.remote_ip
      @useragent = request.env['HTTP_USER_AGENT']
    end
    @message = msg
    mail(:to => company.technician_email, :subject => "[SalorHospitalityMessage #{ company.name }] #{ subject }") 
  end
end